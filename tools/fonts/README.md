# tools/fonts — fontes do app

| Arquivo | O que é |
|---|---|
| `build_fonts.py` | Gera as fontes **novas** das telas do leitor (19–27b) em `assets/fonts/` — Figtree 800, Bricolage 15,5/17/23, Literata estáticas por tamanho + variável, Lora variável, Atkinson —; com `CONJUNTO=inicio2`, as da Início nova e da revisão (T02); com o argumento `v1`, as estáticas da Início v1 refeitas com os avanços do HVAR (D-249). |
| `originais_v2/` | Os subconjuntos que o arquivo novo referencia no `fonts.gstatic.com` (latin-ext, vietnamita, cirílico, grego…), baixados das URLs exatas do arquivo. `manifesto.json` = URL + sha256. O subconjunto **latin** vem embutido no próprio arquivo: `handoff_v2/referencia/fontes_do_arquivo/`. |
| `baixar_css2.py` | T13.2 (D-273): baixa as respostas do `css2` das consultas das telas de um índice para `css2_projeto/` (com `consultas.json`: URL, telas, sha256, data) e os binários das famílias que a tabela da medição não tem — a Roboto 500 da 07 — em latin, latin-ext e vietnamita para `originais_v2/` (no `manifesto.json`). Roda no Windows. |
| `css2_projeto/` | As 5 respostas do `css2` das 41 telas das etapas 7–11, baixadas em 11/10/2026: as URLs dos subconjuntos fora do latin são as mesmas das exportações antigas (as fontes não mudaram de versão) e os `unicode-range`, os das exportações de outubro. |
| `validar_fontes.py` | Mede com HarfBuzz cada linha de texto das pranchas do conjunto usando o TTF que o app vai usar e compara com a largura medida no Chromium → `validacao_fontes.json` (leitor) ou a do conjunto. |
| `conferir_estaticas.py` | Confere cada fonte dos três manifestos contra a variável de origem modelada pelo HarfBuzz com as variações da instância (T02): mesmos glifos e clusters, avanços ≤ 0,5 unidade e offsets ≤ 1,5 da UPM do arquivo; as convertidas sem instanciar, idênticas. |
| `pubspec_fonts_leitor.yaml` | Bloco proposto para o `pubspec.yaml` (entrou na G11). |
| `fontes_leitor.json` · `fontes_inicio2.json` · `fontes_v1.json` | Listas dos arquivos gerados (G01, T02 e D-249). |

```bash
pip install fonttools brotli uharfbuzz
python3 tools/fonts/build_fonts.py          # 69 arquivos em assets/fonts/, bytes reprodutíveis
python3 tools/fonts/build_fonts.py v1       # D-249: as 32 estáticas da Início v1, bytes reprodutíveis
python3 tools/fonts/validar_fontes.py       # 498 linhas; código 1 se alguma passar de 0,05 px
python3 tools/fonts/conferir_estaticas.py   # 113 arquivos × 430 textos × 3 conjuntos de features
```

Resultados (T02, no WSL como a medição): as 498 linhas do leitor e as 368 da Início (`CONJUNTO=inicio2`, resultado em
`docs/design/medicao/inicio2/validacao_fontes.json`) ficam **≤ 0,01 px** do Chromium — a resolução da medida, que o
navegador dá com 2 casas. O conferidor passa nas 113 fontes (145 770 modelagens): maior diferença de avanço 0,504 unidade
e de offset 1,191 (UPM 10000; 1,5 unidade a 42 px = 0,006 px); as 25 convertidas, idênticas. Com as estáticas antigas da
v1 o conferidor reprova (avanços até 5,5 unidades, offsets até 5,3).

T02 — Início e revisão (`CONJUNTO=inicio2`): `build_fonts.py` gera só o que falta — Bricolage 14 e 32, Literata 15 e 22
em 400 (12 arquivos, lista em `fontes_inicio2.json`), registrados no `pubspec.yaml` e no `AppFonts` na T02. A Figtree usa
o maior peso que a prancha declara (700 nas 01/01b/60, D-246); os trechos inline com fonte própria (o `<mark>` do grifo
da 61/62) e o texto próprio contíguo ("Revisão" de "Revisão feita.") entram na conferência (`validacaoTrechos` do
conjunto).

D-249 — as estáticas da Início v1 (`build_fonts.py v1`): Figtree 400–700 (latin, latin-ext) e Bricolage 12…42 (latin,
latin-ext, vietnamita), os mesmos 32 arquivos e nomes de família que `design_handoff/ferramentas/build_fonts.py` gerou,
agora com os avanços do HVAR como as da G01. A origem é o binário do arquivo (as tabelas são as mesmas da v1, salvo a
data do `head`); contornos, ordem dos glifos, `cmap` e kerning saem idênticos; mudam os avanços (≤ 5/10000 em) e os
offsets dos acentos, que ficam mais perto da variável (erro médio 2,62 → 0,34 unidade). Antes: até 0,0528 px por linha
("Continuar lendo"); depois: ≤ 0,01. `design_handoff/assets/fonts/` (o pacote da v1) não muda.

Decisões (detalhes no topo de `build_fonts.py` e em `docs/progresso/G01.md`):
- Instâncias estáticas com UPM 10000 e **avanços tirados do HVAR** (o que o Chromium usa via HarfBuzz). Sem isso a Literata estática sai até 0,13 px por linha mais estreita que o navegador; com isso, ≤ 0,01 px.
- Subconjuntos em famílias separadas (fallback na ordem do `unicode-range`), nunca mesclados.
- Lora: só conversão WOFF2 → TTF (Reserved Font Name "Lora" impede instanciar/renomear).
