#!/usr/bin/env bash
# G01 — pipeline completo de medição das telas 19–27b, na ordem das subfases. Rodar da raiz do repositório
# (Linux com Playwright 1.56 / Chromium 141, Node 22, Python 3.11+ com Pillow, numpy, fonttools, brotli, uharfbuzz).
# Ao final grava tools/medicao/tmp/hashes_saida.txt (sha256 de todas as saídas versionadas) — rodar 2× e comparar.
set -euo pipefail
export NODE_PATH="${NODE_PATH:-$(npm root -g)}"
ORIG="handoff_v2/referencia/original/Redesign mobile — App de leitura (1).html"
python3 tools/medicao/extrair_bundle.py "$ORIG" tools/medicao/pranchas --aninhado tools/medicao/pranchas.json   # G01.1
python3 tools/medicao/idmaps_spec.py                                                                           # G01.3
node tools/medicao/conferir_render.js todas nenhum 1 && node tools/medicao/conferir_render.js todas nenhum 2    # G01.2
node tools/medicao/render_raiz.js nenhum 1 && node tools/medicao/render_raiz.js nenhum 2
python3 tools/medicao/comparar_previa.py
node tools/medicao/medir.js todas && python3 tools/medicao/build_layout.py                                     # G01.4
node tools/medicao/supershot.js todas && node tools/medicao/supershot.js todas 20                              # G01.5
CSS_EXTRA='article[aria-label^="Dom Casmurro"]{clip-path: inset(-400px -40px 0 -40px)}' SUFIXO=corrigida node tools/medicao/supershot.js 21
python3 tools/medicao/reduzir.py && python3 tools/medicao/recortar.py
node tools/medicao/perturbar.js todas && python3 tools/medicao/gen_reference_dart.py                          # G01.6
python3 tools/fonts/build_fonts.py && python3 tools/fonts/validar_fontes.py                                   # G01.7
node tools/medicao/svgs.js && python3 tools/medicao/exportar_svgs.py && python3 tools/medicao/recortes_elementos.py   # G01.8
python3 tools/medicao/tokens_widgets.py "${TOKENS_DART:-lib/core/design_system/tokens}"                        # G01.10
python3 tools/medicao/gen_fases.py                                                                             # G01.9
python3 tools/medicao/hashes_saida.py > tools/medicao/tmp/hashes_saida.txt                                     # G01.11
wc -l tools/medicao/tmp/hashes_saida.txt
