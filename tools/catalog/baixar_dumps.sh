#!/usr/bin/env bash
# G07 — baixa os dumps abertos do catálogo (Anexo 02 §7, ADR-008) com retomada.
#   Open Library (CC0): edições, obras, autores, notas e estantes de leitura (popularidade).
#   DNB — Deutsche Nationalbibliothek (CC0 1.0): títulos em N-Triples.
# Destino: $BOOKNEST_CATALOGO_DADOS (padrão /root/booknest_catalogo/dumps) — fora do git.
# Uso: bash tools/catalog/baixar_dumps.sh [ol|dnb|tudo|sha] [tipos da OL...]
#   ex.: baixar_dumps.sh ol works   e, em outro terminal, baixar_dumps.sh ol editions (arquivos distintos;
#   nunca rode duas cópias para o MESMO arquivo — a retomada `-C -` de duas cópias corrompe o .parte).
set -euo pipefail
DADOS="${BOOKNEST_CATALOGO_DADOS:-/root/booknest_catalogo}/dumps"
mkdir -p "$DADOS"
QUAIS="${1:-tudo}"
shift || true
TIPOS="${*:-ratings reading-log authors works editions}"

baixar() { # url destino
  local url="$1" destino="$2"
  echo "== $(date -u +%FT%TZ) $destino"
  # HTTP/1.1: o archive.org derruba streams HTTP/2 longos (curl 92); a retomada continua do ponto.
  # Trava por arquivo: uma segunda cópia para o mesmo destino sai na hora em vez de corromper o .parte.
  exec 9>"$DADOS/$destino.trava"
  flock -n 9 || { echo "outra cópia já baixa $destino" >&2; exit 1; }
  curl --http1.1 -L --fail --retry 30 --retry-delay 15 --retry-all-errors -C - -sS -o "$DADOS/$destino.parte" "$url"
  gzip -t "$DADOS/$destino.parte"   # o arquivo inteiro confere (CRC do gzip) antes de valer
  mv "$DADOS/$destino.parte" "$DADOS/$destino"
  rm -f "$DADOS/$destino.trava"
  ls -l "$DADOS/$destino"
}

ol_url() { # tipo → URL datada (o "latest" redireciona para o archive.org)
  curl -sSI "https://openlibrary.org/data/ol_dump_$1_latest.txt.gz" | tr -d '\r' \
    | awk 'tolower($1)=="location:"{print $2; exit}'
}

if [[ "$QUAIS" == ol || "$QUAIS" == tudo ]]; then
  for tipo in $TIPOS; do
    url="$(ol_url "$tipo")"
    [[ -n "$url" ]] || { echo "sem URL para $tipo" >&2; exit 1; }
    arq="$(basename "$url")"
    if [[ -f "$DADOS/$arq" ]]; then echo "já baixado: $arq"; continue; fi
    baixar "$url" "$arq"
  done
fi

if [[ "$QUAIS" == dnb || "$QUAIS" == tudo ]]; then
  arq=dnb-all_lds.nt.gz
  if [[ -f "$DADOS/$arq" ]]; then echo "já baixado: $arq"; else
    baixar "https://data.dnb.de/opendata/$arq" "$arq"
  fi
fi

if [[ "$QUAIS" == sha || "$QUAIS" == tudo ]]; then
  echo "== sha256"
  ( cd "$DADOS" && sha256sum ./*.gz | tee SHA256SUMS )
fi
echo "== fim $(date -u +%FT%TZ)"
