#!/usr/bin/env bash
# G01 — pipeline completo de medição das telas 19–27b, na ordem das subfases. Rodar da raiz do repositório
# (Linux com Playwright 1.56 / Chromium 141, Node 22, Python 3.11+ com Pillow, numpy, fonttools, brotli, uharfbuzz).
# Ao final grava <tmp do conjunto>/hashes_saida.txt (sha256 de todas as saídas versionadas) — rodar 2× e comparar.
# T02: CONJUNTO=inicio2 (ou leitor_conferencia) mede outro conjunto de conjuntos.json; sem CONJUNTO, o leitor da G01.
#      No Windows, pelo WSL: MSYS_NO_PATHCONV=1 wsl bash tools/medicao/wsl.sh 'CONJUNTO=inicio2 bash tools/medicao/rodar_tudo.sh'
set -euo pipefail
export NODE_PATH="${NODE_PATH:-$(npm root -g)}"
export CONJUNTO="${CONJUNTO:-leitor}"
cfg() { python3 -c "import sys; sys.path.insert(0, 'tools/medicao'); from conjunto import C; print(C['$1'])"; }
INDICE="$(cfg indice)"
EXTRACAO="$(cfg extracao)"
TMP="$(cfg tmp)"
# T13: o índice de formato "dc" são telas do projeto (docs/design/projeto/telas/*.dc.html), extraídas por extrair_dc.py;
# não há página raiz nem prévias (o A1 e o A2 não se aplicam — a prova é a conferência da T13, R3).
FORMATO="$(python3 -c "import json; print(json.load(open('$INDICE', encoding='utf-8')).get('formato', 'bundle'))")"
if [ "$FORMATO" = dc ]; then
  python3 tools/medicao/extrair_dc.py "$INDICE" "$EXTRACAO"                                                    # T13.1
else
  if [ "$CONJUNTO" = leitor ] || [ "$CONJUNTO" = leitor_conferencia ]; then
    ORIG="handoff_v2/referencia/original/Redesign mobile — App de leitura (1).html"
  else
    ORIG="$(python3 -c "import json; print(json.load(open('$INDICE', encoding='utf-8'))['fonte'])")"
  fi
  python3 tools/medicao/extrair_bundle.py "$ORIG" "$EXTRACAO" --aninhado "$INDICE"                            # G01.1
fi
python3 tools/medicao/idmaps_spec.py                                                                           # G01.3
if [ "$FORMATO" != dc ]; then
  node tools/medicao/conferir_render.js todas nenhum 1 && node tools/medicao/conferir_render.js todas nenhum 2  # G01.2
  node tools/medicao/render_raiz.js nenhum 1 && node tools/medicao/render_raiz.js nenhum 2
  python3 tools/medicao/comparar_previa.py
fi
node tools/medicao/medir.js todas && python3 tools/medicao/build_layout.py                                     # G01.4
node tools/medicao/supershot.js todas && node tools/medicao/supershot.js todas 20                              # G01.5
# T02 (R3): a faixa com defeito de raster no zoom 20 é conferida noutro zoom (convergenciaFaixa do índice)
python3 -c "import json; [print(p['tela'], p['convergenciaFaixa']['zoom']) for p in json.load(open('$INDICE', encoding='utf-8'))['pranchas'] if p.get('convergenciaFaixa')]" |
  while read -r TELA ZOOM; do node tools/medicao/supershot.js "$TELA" "$ZOOM"; done
# D-279: a prancha com zoomBase/zoomConvergencia fora de 10/20 (a 30b: 20 e 40) ganha o supershot nesses zooms
python3 -c "import json; [print(p['tela'], z) for p in json.load(open('$INDICE', encoding='utf-8'))['pranchas'] for z in sorted({p.get('zoomBase', 10), p.get('zoomConvergencia', 20)} - {10, 20})]" |
  while read -r TELA ZOOM; do node tools/medicao/supershot.js "$TELA" "$ZOOM"; done
if [ "$CONJUNTO" = leitor ] || [ "$CONJUNTO" = leitor_conferencia ] || [ "$CONJUNTO" = projeto_conferencia_leitor ]; then
  CSS_EXTRA='article[aria-label^="Dom Casmurro"]{clip-path: inset(-400px -40px 0 -40px)}' SUFIXO=corrigida node tools/medicao/supershot.js 21
fi
python3 tools/medicao/reduzir.py && python3 tools/medicao/recortar.py
node tools/medicao/perturbar.js todas && python3 tools/medicao/gen_reference_dart.py                          # G01.6
# T13 (R3): a conferência das telas já medidas para aqui (fontes, SVGs, tokens e fases não fazem parte da prova)
if [ "${ATE:-}" = referencias ]; then exit 0; fi
python3 tools/fonts/build_fonts.py && python3 tools/fonts/validar_fontes.py                                   # G01.7
node tools/medicao/svgs.js && python3 tools/medicao/exportar_svgs.py && python3 tools/medicao/recortes_elementos.py   # G01.8
python3 tools/medicao/tokens_widgets.py "${TOKENS_DART:-lib/core/design_system/tokens}"                        # G01.10
python3 tools/medicao/gen_fases.py                                                                             # G01.9
mkdir -p "$TMP"
python3 tools/medicao/hashes_saida.py > "$TMP/hashes_saida.txt"                                              # G01.11
wc -l "$TMP/hashes_saida.txt"
