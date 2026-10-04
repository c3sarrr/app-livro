#!/usr/bin/env bash
# G02 · S2 — sobe o serviço PowerSync local (fonte = Postgres "booknest", armazenamento = "powersync_storage").
# Segredos de teste: scripts/ambiente.sh ($RUN/ps.env, fora do repositório).
set -euo pipefail
cd "$(dirname "$0")/.."
. scripts/ambiente.sh
echo $$ > "$RUN/servico.pid"
exec "${NODE:-node}" node_modules/@powersync/service-image/lib/entry.js start -r unified -c config/powersync.yaml
