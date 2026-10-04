#!/usr/bin/env bash
# G04.6 — EXPLAIN (ANALYZE, BUFFERS) das consultas quentes (Anexo 02 §10) e tempo da RPC de sync com
# 100 mil usuários sintéticos, no Supabase LOCAL. Recria o banco antes e depois (os dados sintéticos
# não ficam). Uso: bash tools/supabase/medir_consultas.sh [arquivo de saída]
set -euo pipefail
cd "$(dirname "$0")/../.."
eval "$(supabase status -o env | grep '^DB_URL=')"
case "$DB_URL" in *127.0.0.1*|*localhost*) ;; *) echo "só no banco local" >&2; exit 1 ;; esac
saida=${1:-docs/progresso/G04_consultas_quentes.txt}
supabase db reset > /dev/null 2>&1
{
  echo "# G04.6 — $(date -u +%FT%TZ) — Postgres $(psql "$DB_URL" -X -At -c 'show server_version')"
  echo "## carga (01_dados_sinteticos.sql)"
  /usr/bin/time -f 'carga: %e s' psql "$DB_URL" -X -q -f supabase/bench/01_dados_sinteticos.sql
  echo "## consultas quentes (02_consultas_quentes.sql)"
  psql "$DB_URL" -X -q -f supabase/bench/02_consultas_quentes.sql
  echo "## RPC de sync, lotes de 500 (03_sync_500.sql)"
  psql "$DB_URL" -X -q -f supabase/bench/03_sync_500.sql
} > "$saida" 2>&1
supabase db reset > /dev/null 2>&1
echo "resultado em $saida"
