#!/usr/bin/env bash
# G02 · S5 — recria o banco e roda os 14 testes da Edge Function (Deno 2.9+).
# Requer as variáveis PG* (Postgres local) e DENO apontando para o binário do Deno.
set -euo pipefail
cd "$(dirname "$0")/.."
bash scripts/preparar_banco.sh
S5_DB_URL="postgresql://${PGUSER}:${PGPASSWORD}@${PGHOST}:${PGPORT}/booknest_s5" \
  "${DENO:-deno}" test --allow-net --allow-env --allow-read --allow-write=dados testes/
