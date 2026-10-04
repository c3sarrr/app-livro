#!/usr/bin/env bash
# Configura o agendador no Supabase LOCAL: grava no Vault a URL interna do gateway e a chave secreta
# local (a do `supabase status`, padrão do CLI — não é segredo de produção). Em stg/prod a chave é a
# secreta "agendador" criada no painel, gravada pelo mesmo vault.create_secret (nunca em migration).
set -euo pipefail
cd "$(dirname "$0")/../.."
eval "$(supabase status -o env | grep -E '^(SECRET_KEY|DB_URL)=')"
psql "$DB_URL" -X -q -v ON_ERROR_STOP=1 \
  -v url="http://supabase_kong_booknest:8000" -v chave="$SECRET_KEY" <<'SQL'
delete from vault.secrets where name in ('booknest_project_url', 'booknest_scheduler_key');
select vault.create_secret(:'url', 'booknest_project_url');
select vault.create_secret(:'chave', 'booknest_scheduler_key');
SQL
echo "agendador local configurado (Vault: booknest_project_url, booknest_scheduler_key)"
