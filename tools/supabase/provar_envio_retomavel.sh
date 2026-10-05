#!/usr/bin/env bash
# G06.4 — prova: o upload RETOMÁVEL (TUS) do Storage aceita o token da URL assinada (x-signature)?
# Supabase LOCAL (supabase start). Usa a chave local de serviço só dentro deste processo (nunca
# impressa). Saída: só códigos HTTP. ROTA=/storage/v1/upload/resumable mostra o controle (403).
# Uso, na raiz do repositório (WSL): bash tools/supabase/provar_envio_retomavel.sh
set -uo pipefail
cd "$(dirname "$0")/../.."
eval "$(supabase status -o env 2>/dev/null | grep -E '^(API_URL|SERVICE_ROLE_KEY|ANON_KEY|PUBLISHABLE_KEY)=')"
U=$API_URL; K=$SERVICE_ROLE_KEY; P=${PUBLISHABLE_KEY:-$ANON_KEY}
case "$U" in *127.0.0.1*|*localhost*) ;; *) echo 'só no Supabase LOCAL'; exit 1 ;; esac
D=$(mktemp -d)
CAM="00000000-0000-7000-8000-0000000000aa/tus-$(date +%s)/livro.epub"
assinar() {
  curl -s -X POST "$U/storage/v1/object/upload/sign/ebooks/$1" -H "Authorization: Bearer $K" -H "apikey: $K" -H 'x-upsert: true' |
    python3 -c 'import sys,json,urllib.parse as u; d=json.load(sys.stdin); print(u.parse_qs(u.urlparse(d["url"]).query)["token"][0])'
}
TOKEN=$(assinar "$CAM")
[ -n "$TOKEN" ] && echo "url assinada: ok" || { echo "sem url assinada"; exit 1; }
LEN=7340032   # 7 MiB: 1 pedaço de 6 MiB + o resto
head -c $LEN /dev/urandom > "$D/livro.bin"
b64() { printf %s "$1" | base64 -w0; }
ROTA=${ROTA:-/storage/v1/upload/resumable/sign}
criar() { # $1 = objeto, $2 = token
  curl -s -D "$D/h" -o "$D/corpo" -w '%{http_code}' -X POST "$U$ROTA" \
    -H 'Tus-Resumable: 1.0.0' -H "Upload-Length: $LEN" -H "apikey: $P" -H "x-signature: $2" \
    -H "Upload-Metadata: bucketName $(b64 ebooks),objectName $(b64 "$1"),contentType $(b64 application/epub+zip)"
}
echo "rota: $ROTA"
echo "criar (token certo): $(criar "$CAM" "$TOKEN") $(head -c 200 "$D/corpo")"
LOC=$(grep -i '^location:' "$D/h" | tr -d '\r' | awk '{print $2}')
case "$LOC" in http*) ;; *) LOC="$U$LOC";; esac
CH=6291456
head -c $CH "$D/livro.bin" > "$D/p1"; tail -c +$((CH+1)) "$D/livro.bin" > "$D/p2"
echo "pedaço 1: $(curl -s -o /dev/null -w '%{http_code}' -X PATCH "$LOC" -H 'Tus-Resumable: 1.0.0' -H 'Upload-Offset: 0' \
  -H 'Content-Type: application/offset+octet-stream' -H "apikey: $P" -H "x-signature: $TOKEN" --data-binary @"$D/p1")"
# "a conexão caiu": o app pergunta onde parou e continua dali
OFF=$(curl -s -I "$LOC" -H 'Tus-Resumable: 1.0.0' -H "apikey: $P" -H "x-signature: $TOKEN" | grep -i '^upload-offset:' | tr -d '\r' | awk '{print $2}')
echo "retomar de: $OFF (esperado $CH)"
echo "pedaço 2: $(curl -s -o /dev/null -w '%{http_code}' -X PATCH "$LOC" -H 'Tus-Resumable: 1.0.0' -H "Upload-Offset: $OFF" \
  -H 'Content-Type: application/offset+octet-stream' -H "apikey: $P" -H "x-signature: $TOKEN" --data-binary @"$D/p2")"
curl -s -o "$D/volta.bin" "$U/storage/v1/object/ebooks/$CAM" -H "Authorization: Bearer $K" -H "apikey: $K"
[ "$(sha256sum < "$D/livro.bin")" = "$(sha256sum < "$D/volta.bin")" ] && echo "arquivo no Storage: igual (sha256)" || echo "arquivo no Storage: DIFERENTE"
# controles: token inválido e token de OUTRO caminho (a cota é por caminho reservado)
echo "criar (token inválido): $(criar "$CAM.x" "token-invalido")"
OUTRO="00000000-0000-7000-8000-0000000000aa/tus-outro/livro.epub"
echo "criar (token de outro caminho): $(criar "$OUTRO" "$TOKEN")"
curl -s -o /dev/null -X DELETE "$U/storage/v1/object/ebooks" -H "Authorization: Bearer $K" -H "apikey: $K" \
  -H 'Content-Type: application/json' -d "{\"prefixes\":[\"$CAM\"]}"
rm -rf "$D"
