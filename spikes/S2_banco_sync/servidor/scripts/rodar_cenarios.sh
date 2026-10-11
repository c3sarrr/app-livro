#!/usr/bin/env bash
# G02 · S2 — roda tudo do zero: recria os bancos, sobe o serviço PowerSync, executa os 8 cenários
# (node --test) e grava ../dados/resultado_s2.json. Requer Postgres 16+ com wal_level=logical em
# 127.0.0.1:55432 e Node 24 (o serviço usa `using`). NODE aponta para o binário do Node 24.
set -euo pipefail
cd "$(dirname "$0")/.."
. scripts/ambiente.sh
NODE=${NODE:-node}
if [ -f "$RUN/servico.pid" ]; then kill "$(cat "$RUN/servico.pid")" 2>/dev/null || true; sleep 2; fi
bash scripts/preparar_banco.sh
setsid nohup bash scripts/subir_servico.sh > "$RUN/servico.log" 2>&1 < /dev/null &
echo $! > "$RUN/servico.pid"
for i in $(seq 1 60); do grep -q "Activated new replication stream\|Service started" "$RUN/servico.log" && break; sleep 1; done
sleep 3
rm -f ../dados/resultado_s2.json
"$NODE" --test --test-concurrency=1 --test-force-exit cenarios/*.test.mjs 2>&1 | grep -v "Could not apply checkpoint\|MaxListeners\|trace-warnings" | tee "$RUN/cenarios.log" | grep -E "^(✔|✖|ℹ)" || true
kill "$(cat "$RUN/servico.pid")" 2>/dev/null || true
grep -q "^ℹ fail 0" "$RUN/cenarios.log"
