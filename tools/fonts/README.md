# tools/fonts — fontes do app

| Arquivo | O que é |
|---|---|
| `build_fonts.py` | Gera as fontes **novas** das telas do leitor (19–27b) em `assets/fonts/` — Figtree 800, Bricolage 15,5/17/23, Literata estáticas por tamanho + variável, Lora variável, Atkinson — e, com `CONJUNTO=inicio2`, as da Início nova e da revisão (T02). As fontes da Início v1 continuam sendo as da v1 (`design_handoff/ferramentas/build_fonts.py`). |
| `originais_v2/` | Os subconjuntos que o arquivo novo referencia no `fonts.gstatic.com` (latin-ext, vietnamita, cirílico, grego…), baixados das URLs exatas do arquivo. `manifesto.json` = URL + sha256. O subconjunto **latin** vem embutido no próprio arquivo: `handoff_v2/referencia/fontes_do_arquivo/`. |
| `validar_fontes.py` | Mede com HarfBuzz cada linha de texto das 13 pranchas usando o TTF que o app vai usar e compara com a largura medida no Chromium → `validacao_fontes.json`. |
| `pubspec_fonts_leitor.yaml` | Bloco proposto para o `pubspec.yaml` (entra na G11). |
| `fontes_leitor.json` | Lista dos arquivos gerados. |

```bash
pip install fonttools brotli uharfbuzz
python3 tools/fonts/build_fonts.py      # 69 arquivos em assets/fonts/, bytes reprodutíveis
python3 tools/fonts/validar_fontes.py   # 498 linhas; código 1 se alguma passar de 0,05 px
```

T02 — Início e revisão (`CONJUNTO=inicio2`, no WSL como a medição): `build_fonts.py` gera só o que falta — Bricolage 14 e
32, Literata 15 e 22 em 400 (12 arquivos, lista em `fontes_inicio2.json`); `validar_fontes.py` confere as 368 linhas das 6
pranchas (resultado em `docs/design/medicao/inicio2/validacao_fontes.json`). A Figtree usa o maior peso que a prancha
declara (700 nas 01/01b/60, D-246) e a `Figtree-Bold.ttf` da v1 tem limite próprio de 0,055 px (motivo em
`tools/medicao/conjuntos.json` → `validacaoFontesLimites`).

Decisões (detalhes no topo de `build_fonts.py` e em `docs/progresso/G01.md`):
- Instâncias estáticas com UPM 10000 e **avanços tirados do HVAR** (o que o Chromium usa via HarfBuzz). Sem isso a Literata estática sai até 0,13 px por linha mais estreita que o navegador; com isso, ≤ 0,01 px.
- Subconjuntos em famílias separadas (fallback na ordem do `unicode-range`), nunca mesclados.
- Lora: só conversão WOFF2 → TTF (Reserved Font Name "Lora" impede instanciar/renomear).
