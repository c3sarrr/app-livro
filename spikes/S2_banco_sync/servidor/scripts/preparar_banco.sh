#!/usr/bin/env bash
# G02 · S2 — recria os bancos "booknest" (fonte: stub do Supabase + esquema de referência do
# handoff_v2/sql) e "powersync_storage" (armazenamento de buckets do serviço) e a publicação.
set -euo pipefail
cd "$(dirname "$0")/.."
. scripts/ambiente.sh
SQL=../../../handoff_v2/sql
PGPASSWORD= psql -q -d postgres -c "alter role postgres password '$PGPASSWORD'" 2>/dev/null || true
for db in booknest powersync_storage; do
  psql -q -d postgres -c "drop database if exists $db with (force)"
  psql -q -d postgres -c "create database $db"
done
psql -q -v ON_ERROR_STOP=1 -d booknest -f "$SQL/00_stub_supabase_local.sql"
psql -q -v ON_ERROR_STOP=1 -d booknest -f "$SQL/01_schema_booknest.sql" > /dev/null
psql -q -v ON_ERROR_STOP=1 -d booknest -f sql/spike_s2.sql
echo "banco pronto"
