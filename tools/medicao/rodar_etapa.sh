#!/usr/bin/env bash
# T13.4–T13.8 — mede as telas de uma etapa do projeto (conjunto projeto, telas separadas por vírgula): a extração, os
# ids, a medição, o supersample (zoom 10 e 20, e a faixa com defeito noutro zoom), as reduções com a convergência, os
# recortes por fase (fases_projeto.json: as etapas já medidas), a dependência de texto e os fios de navalha (juntos aos
# das etapas de antes) e as referências Dart (o índice com as telas que já têm referência). Rodar da raiz, no WSL:
#   MSYS_NO_PATHCONV=1 wsl bash tools/medicao/wsl.sh 'bash tools/medicao/rodar_etapa.sh 02,36,17,17b'
# O fechamento (T13.13) roda as 41 de uma vez com rodar_tudo.sh, que tem de dar os mesmos bytes.
set -euo pipefail
TELAS="${1:?uso: rodar_etapa.sh <telas separadas por vírgula, ex.: 02,36,17,17b>}"
export NODE_PATH="${NODE_PATH:-$(npm root -g)}"
export CONJUNTO=projeto
cfg() { python3 -c "import sys; sys.path.insert(0, 'tools/medicao'); from conjunto import C; print(C['$1'])"; }
INDICE="$(cfg indice)"
# um passo por linha: com `set -e`, um erro no meio de `a && b` não para o script
python3 tools/medicao/extrair_dc.py "$INDICE" "$(cfg extracao)"                                              # T13.1
python3 tools/medicao/idmaps_spec.py "$TELAS"                                                               # R4
node tools/medicao/medir.js "$TELAS"
python3 tools/medicao/build_layout.py "$TELAS"
node tools/medicao/supershot.js "$TELAS"
node tools/medicao/supershot.js "$TELAS" 20
# a faixa com defeito de raster no zoom 20 é conferida noutro zoom (convergenciaFaixa do índice, como a R3 da T02)
python3 -c "
import json
telas = '$TELAS'.split(',')
for p in json.load(open('$INDICE', encoding='utf-8'))['pranchas']:
    if p.get('convergenciaFaixa') and (p['tela'] in telas or p['slug'] in telas):
        print(p['tela'], p['convergenciaFaixa']['zoom'])" |
  while read -r TELA ZOOM; do node tools/medicao/supershot.js "$TELA" "$ZOOM"; done
python3 tools/medicao/reduzir.py "$TELAS"
python3 tools/medicao/recortar.py
node tools/medicao/perturbar.js "$TELAS"
python3 tools/medicao/gen_reference_dart.py "$TELAS"
