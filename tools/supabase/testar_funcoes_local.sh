#!/usr/bin/env bash
# Testes das Edge Functions: unitários (sempre) + integração com o Supabase LOCAL (supabase start).
set -euo pipefail
cd "$(dirname "$0")/../.."
( cd supabase/functions && deno fmt --check && deno lint && deno check */index.ts && deno test --allow-env --allow-net --allow-read )
bash tools/supabase/configurar_agendador_local.sh
set -a
eval "$(supabase status -o env)"
[ -f supabase/functions/.env ] && . supabase/functions/.env
set +a
BOOKNEST_INTEGRACAO=1 deno test --allow-env --allow-net --allow-read supabase/functions/_integracao/
