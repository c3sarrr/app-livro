#!/usr/bin/env bash
# T03 — a prancha 01 medida a 360 e 430 px de largura (conjunto inicio2_larguras de conjuntos.json): a mesma extração
# da inicio2 com a largura do quadro trocada (CSS fluido, como a F13 da v1 fez com a Início antiga). Pré-requisito: a
# extração da inicio2 (rodar_tudo.sh com CONJUNTO=inicio2, passo G01.1). Ao final grava <tmp>/hashes_saida.txt —
# rodar 2× e comparar. Do Windows: MSYS_NO_PATHCONV=1 wsl bash tools/medicao/wsl.sh 'bash tools/medicao/rodar_larguras.sh'
# T13.9 (D-272): CONJUNTO=projeto_larguras mede as 41 telas do projeto a 360 e 430 (pré-requisito: a extração do
# projeto, rodar_etapa.sh); o índice vem de indice_larguras.py. As fotos nos zooms especiais (a faixa da R3 e o zoom da
# D-279) são as do índice, como no rodar_tudo.sh; na inicio2_larguras não há nenhuma.
set -euo pipefail
export NODE_PATH="${NODE_PATH:-$(npm root -g)}"
export CONJUNTO="${CONJUNTO:-inicio2_larguras}"
TMP="$(python3 -c "import sys; sys.path.insert(0, 'tools/medicao'); from conjunto import C; print(C['tmp'])")"
INDICE="$(python3 -c "import sys; sys.path.insert(0, 'tools/medicao'); from conjunto import C; print(C['indice'])")"
# um passo por linha: com `set -e`, um erro no meio de `a && b` não para o script
node tools/medicao/medir.js todas
python3 tools/medicao/build_layout.py
node tools/medicao/supershot.js todas
node tools/medicao/supershot.js todas 20
# T02 (R3): a faixa com defeito de raster no zoom 20 é conferida noutro zoom (convergenciaFaixa do índice)
python3 -c "import json; [print(p['tela'], p['convergenciaFaixa']['zoom']) for p in json.load(open('$INDICE', encoding='utf-8'))['pranchas'] if p.get('convergenciaFaixa')]" |
  while read -r TELA ZOOM; do node tools/medicao/supershot.js "$TELA" "$ZOOM"; done
# D-279: a prancha com zoomBase/zoomConvergencia fora de 10/20 (a 30b: 20 e 40) ganha o supershot nesses zooms
python3 -c "import json; [print(p['tela'], z) for p in json.load(open('$INDICE', encoding='utf-8'))['pranchas'] for z in sorted({p.get('zoomBase', 10), p.get('zoomConvergencia', 20)} - {10, 20})]" |
  while read -r TELA ZOOM; do node tools/medicao/supershot.js "$TELA" "$ZOOM"; done
python3 tools/medicao/reduzir.py
node tools/medicao/perturbar.js todas
python3 tools/medicao/gen_reference_dart.py
# T13.9: onde a tela deixa de ser fluida, contra a tela a 390 (só nos conjuntos com conjuntoBase: o projeto)
if python3 -c "import sys; sys.path.insert(0, 'tools/medicao'); from conjunto import C; sys.exit(0 if 'conjuntoBase' in C else 1)"; then
  python3 tools/medicao/fluidez.py
fi
mkdir -p "$TMP"
python3 tools/medicao/hashes_saida.py > "$TMP/hashes_saida.txt"
wc -l "$TMP/hashes_saida.txt"
