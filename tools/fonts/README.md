# tools/fonts — fontes do app

| Arquivo | O que é |
|---|---|
| `build_fonts.py` | Gera as fontes **novas** das telas do leitor (19–27b) em `assets/fonts/` — Figtree 800, Bricolage 15,5/17/23, Literata estáticas por tamanho + variável, Lora variável, Atkinson —; com `CONJUNTO=inicio2`, as da Início nova e da revisão (T02); com `CONJUNTO=projeto`, as das 41 telas das etapas 7–11 (T13); com o argumento `v1`, as estáticas da Início v1 refeitas com os avanços do HVAR (D-249). |
| `originais_v2/` | Os subconjuntos que o arquivo novo referencia no `fonts.gstatic.com` (latin-ext, vietnamita, cirílico, grego…), baixados das URLs exatas do arquivo. `manifesto.json` = URL + sha256. O subconjunto **latin** vem embutido no próprio arquivo: `handoff_v2/referencia/fontes_do_arquivo/`. |
| `baixar_css2.py` | T13.2 (D-273): baixa as respostas do `css2` das consultas das telas de um índice para `css2_projeto/` (com `consultas.json`: URL, telas, sha256, data) e os binários das famílias que a tabela da medição não tem — a Roboto 500 da 07 — em latin, latin-ext e vietnamita para `originais_v2/` (no `manifesto.json`). Roda no Windows. |
| `css2_projeto/` | As 5 respostas do `css2` das 41 telas das etapas 7–11, baixadas em 11/10/2026: as URLs dos subconjuntos fora do latin são as mesmas das exportações antigas (as fontes não mudaram de versão) e os `unicode-range`, os das exportações de outubro. |
| `validar_fontes.py` | Mede com HarfBuzz cada linha de texto das pranchas do conjunto usando o TTF que o app vai usar e compara com a largura medida no Chromium → `validacao_fontes.json` (leitor) ou a do conjunto. Nos conjuntos `projeto` e `projeto_larguras` (T13), **por trecho**: toda linha, também a composta de fontes diferentes, contra a largura crua do Chromium (3 casas), com a reserva do "≈"/"→" e o limite de 0,01 px. |
| `test_validar_fontes.py` | T13.10: a conferência por trecho em casos montados à mão — o espaço da borda que é do elemento (no começo e no fim), a quebra dentro de um trecho, o recuo inline, a junção dos trechos da mesma fonte, a reserva no peso do texto, a família sem `@font-face`, os arquivos do projeto, as ligaduras da D-282 e os limites — e as saídas gravadas dos dois conjuntos. No WSL. |
| `conferir_estaticas.py` | Confere cada fonte dos quatro manifestos contra a variável de origem modelada pelo HarfBuzz com as variações da instância (T02): mesmos glifos e clusters, avanços ≤ 0,5 unidade e offsets ≤ 1,5 da UPM do arquivo; as convertidas sem instanciar, idênticas. |
| `pubspec_fonts_leitor.yaml` | Bloco proposto para o `pubspec.yaml` (entrou na G11). |
| `fontes_leitor.json` · `fontes_inicio2.json` · `fontes_v1.json` · `fontes_projeto.json` | Listas dos arquivos gerados (G01, T02, D-249 e T13). |

```bash
pip install fonttools brotli uharfbuzz
python3 tools/fonts/build_fonts.py          # 69 arquivos em assets/fonts/, bytes reprodutíveis
python3 tools/fonts/build_fonts.py v1       # D-249: as 32 estáticas da Início v1, bytes reprodutíveis
python3 tools/fonts/validar_fontes.py       # 498 linhas; código 1 se alguma passar de 0,05 px
CONJUNTO=projeto python3 tools/fonts/build_fonts.py            # T13: os 60 arquivos das etapas 7–11
CONJUNTO=projeto python3 tools/fonts/validar_fontes.py         # 1216 linhas por trecho; código 1 acima de 0,01 px
CONJUNTO=projeto_larguras python3 tools/fonts/validar_fontes.py   # as mesmas telas a 360 e 430: 2438 linhas
python3 tools/fonts/conferir_estaticas.py   # 173 arquivos × 1588 textos × 3 conjuntos de features
PYTHONIOENCODING=utf-8 python3 -m unittest tools/fonts/test_validar_fontes.py -v   # 13 testes
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

T13 — as 41 telas das etapas 7–11 (`CONJUNTO=projeto`, lista em `fontes_projeto.json`, registro no `pubspec.yaml` e no
`AppFonts` na T13.10): Bricolage 800 em 15, 19, 21, 25, 27, 28, 30, 36, 38, 40, 46, 58 e 74, a 700 em 15, Literata 14/16/24
em 600, 24 em 400 e 18 em 500, e a Roboto 500 só convertida (o botão do Google da 07, D-273) — 60 arquivos, bytes
reprodutíveis. As instâncias novas são feitas nas coordenadas que o HarfBuzz usa (`coordenadas_do_harfbuzz`): ele
normaliza com F2Dot14 antes e depois do `avar`, o instanciador em ponto flutuante; com as do instanciador, duas Literata
saíam com o kerning arredondado para o outro lado (−32,52 × −32,495 unidades) e o conferidor reprovava (0,520). A
reserva do "≈" e da "→" (D-281) ganhou a SemiBold e a ExtraBold (`tools/fontes/gerar_aprox_inter.py`, da Inter 4.0 do
WSL, a mesma build da Bold da D-54). Validação por trecho: as 1216 linhas a 390 (72 compostas) e as 2438 a 360/430 (143)
ficam ≤ 0,0048 px do Chromium; estática × origem ≤ 0,0053; de fora só o informativo do R8 (o botão da Apple, os
teclados da 69/69b) e o `<text>` do desenho da 28c. Com letter-spacing ≠ 0 o validador desliga `liga` e `clig`, o que o
Blink desliga (D-282; até a T13.10 desligava também `dlig` e `calt`, sem diferença em nenhuma das 1349 linhas espaçadas
dos conjuntos) — e o `AppFonts` faz o mesmo no app. O conferidor passa nas 173 fontes (824 172 modelagens): nas novas,
avanço ≤ 0,502 unidade e offset ≤ 1,076; as três Roboto, idênticas.

Decisões (detalhes no topo de `build_fonts.py` e em `docs/progresso/G01.md`):
- Instâncias estáticas com UPM 10000 e **avanços tirados do HVAR** (o que o Chromium usa via HarfBuzz). Sem isso a Literata estática sai até 0,13 px por linha mais estreita que o navegador; com isso, ≤ 0,01 px.
- Subconjuntos em famílias separadas (fallback na ordem do `unicode-range`), nunca mesclados.
- Lora: só conversão WOFF2 → TTF (Reserved Font Name "Lora" impede instanciar/renomear).
