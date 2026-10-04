#!/usr/bin/env bash
# G02 · S2 — variáveis do ambiente local do spike. Segredos de TESTE gerados por execução em
# $RUN/ps.env (padrão: spikes/_dados/s2_run, fora do git): senha do Postgres local, segredo HS256
# do JWT e token da API.
RUN=${RUN:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/_dados/s2_run}
export RUN
mkdir -p "$RUN"
if [ ! -f "$RUN/ps.env" ]; then
  gera() { "${NODE:-node}" -e "console.log(require('crypto').randomBytes($1).toString('$2'))"; }
  SENHA=$(gera 12 hex)
  cat > "$RUN/ps.env" <<EOT
PGHOST=127.0.0.1
PGPORT=55432
PGUSER=postgres
PGPASSWORD=$SENHA
PS_FONTE_URI=postgresql://postgres:$SENHA@127.0.0.1:55432/booknest
PS_STORAGE_URI=postgresql://postgres:$SENHA@127.0.0.1:55432/powersync_storage
PS_PORTA=8080
PS_JWT_K=$(gera 32 base64url)
PS_API_TOKEN=$(gera 16 hex)
EOT
fi
set -a; . "$RUN/ps.env"; set +a
