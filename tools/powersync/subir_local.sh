#!/usr/bin/env bash
# G06 — sobe o serviço PowerSync local (Docker no WSL, D-71) ligado ao Supabase local (`supabase start`).
# Segredos de DESENVOLVIMENTO gerados na 1ª vez em _local/powersync.env (fora do git): a senha do papel
# powersync_role (migration powersync_papel) e o token da API do serviço. Uso, na raiz do repositório:
#   bash tools/powersync/subir_local.sh        → http://127.0.0.1:54330 (o app usa POWERSYNC_URL)
#   bash tools/powersync/parar_local.sh
set -euo pipefail
cd "$(dirname "$0")/../.."
IMAGEM='journeyapps/powersync-service:1.26.1@sha256:413a0c813e96935ebe7203b5759f8a594a7b7cd8aa42134713e63af637e0f079'
BANCO=supabase_db_booknest
REDE=supabase_network_booknest
NOME=booknest_powersync
PORTA=${PORTA_POWERSYNC:-54330}

mkdir -p _local
if [ ! -f _local/powersync.env ]; then
  umask 077
  {
    echo "PS_SENHA=$(openssl rand -hex 24)"
    echo "PS_API_TOKEN=$(openssl rand -hex 24)"
  } > _local/powersync.env
fi
# shellcheck disable=SC1091
. _local/powersync.env

docker inspect "$BANCO" >/dev/null 2>&1 || { echo "Supabase local parado: rode 'supabase start'"; exit 1; }

# login do papel (só local) e o banco de armazenamento dos buckets — pela entrada padrão, sem a senha
# na linha de comando
docker exec -i "$BANCO" psql -U postgres -v ON_ERROR_STOP=1 -q <<SQL
alter role powersync_role with login password '$PS_SENHA';
select 'create database powersync_storage'
 where not exists (select 1 from pg_database where datname = 'powersync_storage')\gexec
grant connect, create, temporary on database powersync_storage to powersync_role;
SQL

docker rm -f "$NOME" >/dev/null 2>&1 || true
docker run -d --name "$NOME" --network "$REDE" -p "127.0.0.1:$PORTA:8080" \
  -v "$PWD/powersync:/config:ro" \
  -e POWERSYNC_CONFIG_PATH=/config/service.yaml \
  -e NODE_OPTIONS=--max-old-space-size=1000 \
  -e "PS_DATA_SOURCE_URI=postgresql://powersync_role:$PS_SENHA@$BANCO:5432/postgres" \
  -e "PS_STORAGE_URI=postgresql://powersync_role:$PS_SENHA@$BANCO:5432/powersync_storage" \
  -e PS_JWKS_URL=http://supabase_kong_booknest:8000/auth/v1/.well-known/jwks.json \
  -e "PS_API_TOKEN=$PS_API_TOKEN" \
  "$IMAGEM" start -r unified >/dev/null

for _ in $(seq 1 60); do
  if curl -fsS "http://127.0.0.1:$PORTA/probes/liveness" >/dev/null 2>&1; then
    echo "PowerSync local no ar: http://127.0.0.1:$PORTA"
    exit 0
  fi
  sleep 1
done
echo "o serviço não respondeu; últimos registros:"
docker logs --tail 40 "$NOME"
exit 1
