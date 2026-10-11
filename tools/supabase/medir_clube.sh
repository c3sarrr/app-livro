#!/usr/bin/env bash
# G21.1 — o tempo dos resumos do clube num clube grande (Anexo 02 §10), no Supabase LOCAL. Recria o banco
# antes e depois (os dados sintéticos não ficam). Uso: bash tools/supabase/medir_clube.sh [arquivo de saída]
set -euo pipefail
cd "$(dirname "$0")/../.."
eval "$(supabase status -o env | grep '^DB_URL=')"
case "$DB_URL" in *127.0.0.1*|*localhost*) ;; *) echo "só no banco local" >&2; exit 1 ;; esac
saida=${1:-docs/progresso/G21_resumos_clube.txt}
supabase db reset > /dev/null 2>&1
{
  echo "# G21.1 — $(date -u +%FT%TZ) — Postgres $(psql "$DB_URL" -X -At -c 'show server_version')"
  echo "## carga (04_clube_grande.sql)"
  /usr/bin/time -f 'carga: %e s' psql "$DB_URL" -X -q -f supabase/bench/04_clube_grande.sql
  echo "## resumos (05_resumos_clube.sql)"
  psql "$DB_URL" -X -q -f supabase/bench/05_resumos_clube.sql
} > "$saida" 2>&1
supabase db reset > /dev/null 2>&1
echo "resultado em $saida"
