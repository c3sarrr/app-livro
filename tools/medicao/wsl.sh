#!/usr/bin/env bash
# T02 — roda um comando da medição no WSL (Ubuntu 24.04) com o ambiente da G01: Node 22, Playwright 1.56 (Chromium 141)
# e o Python com Pillow, numpy, fontTools, brotli e uharfbuzz (instalados por tools/medicao/ambiente_wsl.sh em
# /opt/booknest-medicao). Do Windows: MSYS_NO_PATHCONV=1 wsl bash tools/medicao/wsl.sh '<comando>' (na raiz do repo).
set -euo pipefail
B=/opt/booknest-medicao
export PATH="$B/venv/bin:$B/node/bin:$PATH"
export NODE_PATH="$B/node_modules"
export PYTHONIOENCODING=utf-8
cd "$(dirname "$0")/../.."
bash -c "$1"
