# T13 — Medição do projeto: plano de implementação

> **Para quem executa:** execução inline (superpowers:executing-plans), uma tarefa por vez; onde há código, TDD (o
> teste falha, o código mínimo passa) e commit pequeno. Passos com `- [ ]`.
> Spec: `docs/progresso/T13.md` (D-271…D-273, R1…R10), citada por T13.n. Branch `feat/t13-medicao-projeto`, a partir
> da `main` em `debd9ed`. **Respostas de 11/10/2026:** D-271 (as 41 completas), D-272 (360/430) e D-273 (baixar a
> Roboto e as respostas do `css2`), e a spec e o plano aprovados — todas as recomendadas: o plano vale inteiro (os
> passos "se a D-273 recusar" não se aplicam).

**Objetivo:** a ferramenta de medição lê os `.dc.html` do projeto e gera, para as 41 telas das etapas 7–11, as mesmas
saídas que a T02 gerou para a Início — layout, texto, estilos, PNG @1x/@2x/@3x, recortes, redlines, referências Dart,
fontes, SVGs, tokens, mapa id → widget e fases L —, provada contra as 19 telas que já têm medição.

**Arquitetura:** uma extração nova (`extrair_dc.py`) transforma cada `.dc.html` na pasta que o pipeline da T02 já sabe
medir (`original.html` com as fontes embutidas e o `dc-runtime.js` como `support.js`, `template.html`, `props.json`,
`assets/`). O índice do conjunto passa a dizer o seletor do quadro e o tpl dele; o resto do pipeline roda como na T02,
com `CONJUNTO=projeto` (as 41), `projeto_conferencia` (as 19 já medidas) e `projeto_larguras` (360/430).

**Pilha:** WSL (Ubuntu 24.04) com o ambiente `/opt/booknest-medicao` (Node 22, Playwright 1.56 / Chromium 141, Python
3.11 com Pillow, numpy, fontTools, brotli, uharfbuzz), chamado por `MSYS_NO_PATHCONV=1 wsl bash tools/medicao/wsl.sh
'<comando>'`; Flutter 3.47.2 no Windows para os testes Dart; `python3` do Windows (3.7) só para scripts sem
dependências.

**Execução e ambiente:** um `flutter test` por vez; não editar `rodar_tudo.sh` enquanto ele roda; antes de cada
tarefa, `git status` limpo e nenhuma outra sessão no checkout. Rodadas longas em segundo plano, com o log em
`tools/medicao/tmp/`. O celular não é usado (etapa sem tela).

## Arquivos

| Arquivo | Responsabilidade | Tarefa |
|---|---|---|
| `docs/progresso/T13.md`, `T13_plano.md` | spec e plano com as respostas | 1 |
| `docs/progresso/PLANO_FIDELIDADE_TELAS.md` §3 | D-271…D-273 | 1 |
| `tools/medicao/pranchas_projeto.json` (novo) | as 41 + as 19 da conferência: tela, slug, arquivo, prefixo, etapa, canvas, frame, tplQuadro | 2 |
| `tools/medicao/extrair_dc.py` (novo) | `.dc.html` → pasta da tela; `@font-face` pela consulta (R2); `extracao.json` | 2 |
| `tools/medicao/fontes_css2.py` (novo) | a consulta `css2` → as `@font-face` (estilo, pesos, subconjuntos, `unicode-range`) e os binários locais | 2 |
| `tools/medicao/test_extrair_dc.py` (novo) | R2 contra os 35 helmets antigos (e o `css2` real, se D-273); `$preview` × `CATALOGO`; quadro | 2, 3 |
| `tools/medicao/conjuntos.json`, `comum.js`, `medir.js`, `idmaps_spec.py`, `esboco.py` e os outros com o tpl 4 fixo | `frame` e `tplQuadro` do índice | 2 |
| `tools/medicao/rodar_tudo.sh` | a extração do formato `dc` | 2 |
| `tools/fonts/originais_v2/manifesto.json`, `tools/fonts/css2_projeto/` (novos itens) | Roboto 500 e as respostas do `css2` (se D-273) | 3 |
| `tools/medicao/comparar_conferencia.py` (novo) | as 19 telas: layouts sem o `tpl`, PNGs byte a byte (R3) | 4 |
| `tools/medicao/idmaps_spec_projeto.py` + `_t14.py` … `_t18.py` (novos) | ids semânticos (R4) | 5–9 |
| `docs/design/medicao/projeto/**` | layout, png, idmaps, svg, tokens, mapa, validação | 5–13 |
| `test/reference/projeto/**` | referências Dart e o teste delas | 5–9 |
| `tools/medicao/pranchas_projeto_larguras.json`, `rodar_larguras.sh` | 360/430 (se D-272) | 10 |
| `tools/fonts/build_fonts.py`, `fontes_projeto.json`, `assets/fonts/*`, `pubspec.yaml`, `lib/core/design_system/tokens/app_typography.dart` | fontes novas (R6) | 11 |
| `test/design_system/t13_recursos_projeto_test.dart` (novo) | fontes e assets registrados | 11, 12 |
| `assets/icons/{biblioteca,scanner,entrada,perfil,cronometro}/`, `assets/illustrations/…`, classes `AppIcons…`/`AppIllustrations…` | SVGs (R7) | 12 |
| `tools/medicao/svgs_nomes_projeto.py`, `fases_projeto.json`, `fases_notas_projeto.py` (novos) | nomes dos SVGs, índice e notas das fases | 12, 13 |
| `docs/design/fases/L*_*.md`, `LEIA-ME_projeto.md`, `L00_projeto_tokens_e_widgets.md` | fases L (R5) | 13 |
| `docs/progresso/T13_hashes_saida.txt`, `docs/STATUS.md`, `docs/design/projeto/COBERTURA.md`, `docs/ROTEIRO.md` | fechamento | 14 |

## Tarefa 1 — Spec e plano com as respostas

- [ ] Preencher as respostas no topo deste plano e na tabela de decisões da spec; registrar D-271…D-273 no
      `PLANO_FIDELIDADE_TELAS.md` §3 (a próxima livre passa a ser a D-274).
- [ ] Apagar os passos que não se aplicam (os "se D-27x" recusados) e ajustar o escopo das tarefas 5–13 se a D-271
      não for a recomendada.
- [ ] Commit: `docs(progresso): spec e plano da T13 com as respostas (T13)`.

## Tarefa 2 — Índice, extração e os conjuntos (T13.1, R1, R2)

- [ ] **Teste primeiro** (`tools/medicao/test_extrair_dc.py`, `unittest`, roda no WSL):
      `test_faces_iguais_aos_helmets_antigos` — para cada uma das 35 telas antigas (`conferencia_projeto.md`), as
      `@font-face` montadas pela consulta do `.dc.html` são iguais às do `<helmet>` da extração antiga, comparadas
      normalizadas (família, estilo, peso, `font-stretch`, `unicode-range`, ordem) e com a `url` trocada pelo binário
      local que tem o mesmo sha256 do antigo; `test_preview_igual_ao_catalogo` — o `$preview` das 41 = o tamanho do
      `CATALOGO.md`; `test_consultas_conhecidas` — as 5 consultas das 41 têm todos os binários (falha listando o que
      falta: hoje, a Roboto 500).
- [ ] `fontes_css2.py`: parser da consulta (`family=Nome:eixos@tuplas`, `ital`, faixas `a..b`, pesos discretos), a
      tabela de subconjuntos com os `unicode-range` copiados dos helmets antigos (latin, latin-ext, vietnamese,
      cyrillic, cyrillic-ext, greek, greek-ext, math, symbols) e o mapa (família, estilo, subconjunto) → binário local.
      Uma face por peso discreto (como o `css2` faz) e uma por faixa; a ordem de saída a do `css2`.
- [ ] `extrair_dc.py <índice> <saída>`: para cada tela, `original.html` (o `.dc.html` com o `<link>` trocado pelas
      faces e o `<script src="./support.js">` intacto), `support.js` (= `dc-runtime.js`), `assets/` (os `.woff2`
      usados), `template.html` (o HTML entre `<x-dc>` e `</x-dc>`), `props.json` (`data-props`), e o
      `extracao.json` (sha256 do `.dc.html`, do runtime e de cada saída; o tamanho do `CATALOGO.md`).
- [ ] `pranchas_projeto.json` com as 41 (R4: prefixos; etapa) e `pranchas_projeto_conferencia.json` com as 19 (os
      slugs e prefixos antigos, o arquivo do projeto e `tplDeslocamento: -1` para reaproveitar os idmaps antigos).
- [ ] `frame`/`tplQuadro` do índice: `comum.js` (`abrir` espera o quadro; seletor do índice), `medir.js`,
      `idmaps_spec.py` (`nos_medidos` corta em `tplQuadro`), `esboco.py` e cada script com `4` fixo (procurar
      `data-dc-tpl` e `tpl'] >= 4`); sem índice novo, tudo como antes.
- [ ] `conjuntos.json`: `projeto`, `projeto_conferencia` (saídas em `tools/medicao/tmp/conferencia_projeto/`) e,
      se D-272, `projeto_larguras`; `.gitignore` com `tools/medicao/pranchas_projeto/*` e a exceção do
      `extracao.json`; `.gitattributes` com as saídas novas `-text` (como as da T02).
- [ ] `rodar_tudo.sh`: com o índice de formato `dc`, chama `extrair_dc.py` no lugar do `extrair_bundle.py` e pula o
      `conferir_render.js`/`render_raiz.js`/`comparar_previa.py` (não há raiz nem prévias).
- [ ] Rodar os testes (verdes, menos `test_consultas_conhecidas` se a Roboto ainda faltar) e o conjunto `leitor` e o
      `inicio2` só na extração e nos ids (`idmaps_spec.py`): iguais ao commitado.
- [ ] Commit: `feat(medicao): extração dos .dc.html do projeto e o quadro pelo índice (T13.1)`.

## Tarefa 3 — Fontes de fora do arquivo (T13.2, D-273)

- [ ] (se D-273) No Windows (o WSL não acessa o Google), baixar as respostas do `css2` das 5 consultas novas com o
      User-Agent de um Chrome atual (o que o Claude Design usa → `woff2` com subconjuntos) para
      `tools/fonts/css2_projeto/<consulta>.css`, e os binários da Roboto 500 que a resposta da 07 aponta (latin e
      latin-ext, e os outros subconjuntos que ela listar) para `tools/fonts/originais_v2/`, cada um com URL, família,
      estilo, subconjunto, pesos, sha256 e bytes no `manifesto.json`. Licenças (OFL/Apache 2.0) em
      `assets/fonts/LICENCAS_FONTES_OFL.txt` se a Roboto entrar no app.
- [ ] Teste `test_faces_iguais_ao_css2_real`: as faces montadas = as das respostas baixadas (menos a `url`); e
      `test_versoes_iguais`: as URLs da Figtree, Bricolage, Instrument Serif e Literata nas respostas novas = as do
      manifesto antigo. Diferença de versão → **parar e perguntar** (o desenho teria usado outra fonte).
- [ ] (se a D-273 recusar o download) a 07 é medida com a reserva do Linux e o botão do Google entra no R8
      (informativo); `test_consultas_conhecidas` passa a aceitar a Roboto ausente só para a 07.
- [ ] Commit: `feat(fontes): a Roboto 500 e as respostas do css2 do projeto (T13.2)`.

## Tarefa 4 — A prova da ferramenta (T13.3, R3)

- [ ] `comparar_conferencia.py`: para as 19, compara `tmp/conferencia_projeto/layout/layout_<slug>.json` com o
      commitado (o da G01 em `handoff_v2/referencia/layout/` e o da T02 em `docs/design/medicao/inicio2/layout/`)
      campo a campo, ignorando só o `tpl`; e os PNGs @1x/@2x/@3x e recortes byte a byte; saída em tabela.
- [ ] Rodar `CONJUNTO=projeto_conferencia bash tools/medicao/rodar_tudo.sh` no WSL (em segundo plano; só até as
      reduções e recortes — as fontes, SVGs e fases não fazem parte da prova) e o comparador.
- [ ] Esperado: 19/19 iguais. Diferença → investigar a causa (fonte, helmet, quadro) antes de seguir; se for do
      próprio projeto (não do método), registrar e **perguntar**.
- [ ] Resultado na seção "Resultados" da spec. Commit: `test(medicao): as 19 telas medidas pelo .dc.html iguais às
      commitadas (T13.3)`.

## Tarefas 5 a 9 — As telas, por etapa (T13.4 a T13.8, R4, R8, R9)

Uma tarefa por grupo: **5** = T14 (02, 36, 17, 17b), **6** = T15 (03, 39, 40, 41, 42, 69, 69b, 28, 28b, 28c, 28d),
**7** = T16 (35, 07, 08, 09, 09b, 10, 11, 12, 13, 13b, 14, 15, 16, 36a), **8** = T17 (05, 64, 65, 06, 58, 59, 56, 30,
30b, 30c), **9** = T18 (18, 18b). Em cada uma:

- [ ] Ler a prancha (o `.dc.html` e a nota do `NOTAS.md`) e o render; escrever os ids em
      `idmaps_spec_projeto_t1N.py` com `--mostrar <tela>` (tpl, tag, aria, texto) até o gerador passar sem erro:
      cada elemento com id (os `<br>` sem), todos dentro de uma seção, nomes iguais nas telas irmãs (R4).
- [ ] Rodar o conjunto `projeto` só nas telas do grupo (`medir.js <telas>`, `build_layout.py`, `supershot.js` em 10
      e 20, as reduções e os recortes): convergência 0,0000 % (faixa com defeito → zoom alternativo no índice, com o
      motivo, como a R3 da T02); as fontes reais por nó só as do arquivo, salvo os do R8 marcados `informativo`.
- [ ] Referências Dart do grupo (`gen_reference_dart.py`) e os testes delas em
      `test/reference/projeto/referencias_projeto_test.dart` (cada tela = o JSON; dependência de texto; fios de
      navalha; nas irmãs, os elementos comuns com a mesma caixa onde o desenho é o mesmo e a lista do que difere);
      `flutter test test/reference/projeto/` verde.
- [ ] Commit: `feat(medicao): <grupo> medidas pelo projeto (T13.<n>)`.

## Tarefa 10 — As larguras (T13.9, D-272)

- [ ] (se D-272) `pranchas_projeto_larguras.json` (as 41 a 360 e 430, com `base` = o slug da tela) e o conjunto
      `projeto_larguras`; `rodar_larguras.sh` aceitando o conjunto; medir; referências Dart e teste.
- [ ] Listar as telas que não são fluidas (elemento que vaza ou corta a 360) — informação para a etapa da tela.
- [ ] Commit: `feat(medicao): as 41 telas a 360 e 430 px (T13.9)`.

## Tarefa 11 — Fontes no app (T13.10, R6)

- [ ] `tools/fonts/fontes_projeto.json` com a lista que a medição pede (família × peso × tamanho) menos o que já
      existe; `build_fonts.py` com `CONJUNTO=projeto` gera só o que falta (latin, latin-ext e vietnamita, HVAR).
- [ ] `validar_fontes.py` no conjunto: todas as linhas ≤ 0,01 px, sem limite próprio (com `validacaoTrechos` se
      houver trecho inline com fonte própria); `conferir_estaticas.py` com o manifesto novo.
- [ ] **Teste primeiro** (`t13_recursos_projeto_test.dart`): as famílias novas no FontManifest e no `AppFonts`; as
      linhas medidas pelo Flutter ≤ 0,01 px do Chromium (uma por família/tamanho novo). Depois o registro no
      `pubspec.yaml` e no `AppFonts` (`bricolageOpsz` + a Bricolage 700, `literataStatic`, a Roboto se D-273).
- [ ] Commit: `feat(fontes): as estáticas das telas das etapas 7–11 (T13.10)`.

## Tarefa 12 — SVGs e assets (T13.11, R7)

- [ ] `svgs_nomes_projeto.py` (nomes, área, reuso), `svgs.js` e `exportar_svgs.py` no conjunto: reuso por C14N contra
      todas as pastas de assets; os novos nas pastas por área; ids internos normalizados; tamanho do layout.
- [ ] A ida e volta (cada `<svg>` trocado pelo exportado): 0 px, salvo os `<text>` dentro de `<img>` (armadilha da
      T02) e o que mais aparecer, registrado.
- [ ] `recortes_elementos.py`: capas e cartões em CSS, degradês, hachuras, ilustrações em `div`s → recortes @3x.
- [ ] **Teste primeiro** (no mesmo `t13_recursos_projeto_test.dart`): ícones e ilustrações = os arquivos das pastas,
      no pubspec, abrindo e no tamanho do catálogo. Depois as classes por área e o `pubspec.yaml`.
- [ ] Commit: `feat(medicao): SVGs e assets das telas das etapas 7–11 (T13.11)`.

## Tarefa 13 — Tokens, mapa e fases L (T13.12, R5)

- [ ] `tokens_widgets.py` no conjunto: `tokens_projeto.json` (o que já existe no app e o que é novo, com nome
      proposto) e `mapa_widgets.json` com todos os ids.
- [ ] `fases_projeto.json` (fase, tela, seções, título, telas irmãs) e `fases_notas_projeto.py` (as notas escritas:
      armadilhas, interações da nota do design, dados, o que é informativo — R8 —, folhas sobre outra tela — R9 —,
      e as decisões em uso de cada etapa); `gen_fases.py` gera as fases, o `LEIA-ME_projeto.md` e o
      `L00_projeto_tokens_e_widgets.md`.
- [ ] Ler cada fase gerada contra a prancha (texto, números, armadilhas). Commit: `docs(design): tokens, mapa e fases L
      das telas das etapas 7–11 (T13.12)`.

## Tarefa 14 — Fechamento (T13.13, R10)

- [ ] Duas rodadas completas `CONJUNTO=projeto` (e `projeto_larguras`) no WSL → os mesmos sha256 →
      `docs/progresso/T13_hashes_saida.txt`, conferido contra os blobs do commit.
- [ ] As conferências antigas: `CONJUNTO=leitor_conferencia` (305/305) e o manifesto da T02.
- [ ] `dart format` sem mudanças, `flutter analyze` 0, `flutter test` inteira, os testes Python
      (`test_extrair_dc.py` e os da R00), mutação nas regras novas (R2: trocar um peso, um `unicode-range`, o estilo;
      R3: um campo do layout; o quadro), gitleaks nos commits da etapa.
- [ ] `COBERTURA.md` (as 41 com "medida na T13" na observação; nenhuma situação muda), ROTEIRO §3 (T13 ✅, T14 ▶) e
      §6b (o que a T13 fez), STATUS (última T13, próxima 7 · T14, "nada muda no celular", D-274 livre).
- [ ] Resultados, desvios, pendências e checklist na spec; relatório terminando com
      `✅ ETAPA 6 · T13 concluída — aguardando sua aprovação para a ETAPA 7 · T14.` **PARAR.**
