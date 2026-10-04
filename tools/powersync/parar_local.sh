#!/usr/bin/env bash
# G06 — para o serviço PowerSync local (os buckets ficam no banco powersync_storage do Supabase local).
set -euo pipefail
docker rm -f booknest_powersync >/dev/null 2>&1 && echo "PowerSync local parado" || echo "já estava parado"
