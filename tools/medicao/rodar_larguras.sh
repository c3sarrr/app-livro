#!/usr/bin/env bash
# T03 — a prancha 01 medida a 360 e 430 px de largura (conjunto inicio2_larguras de conjuntos.json): a mesma extração
# da inicio2 com a largura do quadro trocada (CSS fluido, como a F13 da v1 fez com a Início antiga). Pré-requisito: a
# extração da inicio2 (rodar_tudo.sh com CONJUNTO=inicio2, passo G01.1). Ao final grava <tmp>/hashes_saida.txt —
# rodar 2× e comparar. Do Windows: MSYS_NO_PATHCONV=1 wsl bash tools/medicao/wsl.sh 'bash tools/medicao/rodar_larguras.sh'
set -euo pipefail
export NODE_PATH="${NODE_PATH:-$(npm root -g)}"
export CONJUNTO=inicio2_larguras
TMP="$(python3 -c "import sys; sys.path.insert(0, 'tools/medicao'); from conjunto import C; print(C['tmp'])")"
# um passo por linha: com `set -e`, um erro no meio de `a && b` não para o script
node tools/medicao/medir.js todas
python3 tools/medicao/build_layout.py
node tools/medicao/supershot.js todas
node tools/medicao/supershot.js todas 20
python3 tools/medicao/reduzir.py
node tools/medicao/perturbar.js todas
python3 tools/medicao/gen_reference_dart.py
mkdir -p "$TMP"
python3 tools/medicao/hashes_saida.py > "$TMP/hashes_saida.txt"
wc -l "$TMP/hashes_saida.txt"
