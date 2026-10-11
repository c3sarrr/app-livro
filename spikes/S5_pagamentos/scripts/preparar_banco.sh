#!/usr/bin/env bash
# G02 · S5 — banco local "booknest_s5" = stub do Supabase + SQL de referência (sem mudanças).
# Usa as variáveis PG* do ambiente (ex.: as do S2: spikes/_dados/s2_run/ps.env).
set -euo pipefail
cd "$(dirname "$0")/.."
SQL=../../handoff_v2/sql
psql -q -d postgres -c "drop database if exists booknest_s5 with (force)"
psql -q -d postgres -c "create database booknest_s5"
psql -q -v ON_ERROR_STOP=1 -d booknest_s5 -f "$SQL/00_stub_supabase_local.sql"
psql -q -v ON_ERROR_STOP=1 -d booknest_s5 -f "$SQL/01_schema_booknest.sql" > /dev/null
echo "booknest_s5 pronto"
