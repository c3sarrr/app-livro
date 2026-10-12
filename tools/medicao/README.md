# tools/medicao — medição dos arquivos do Claude Design

Duas gerações de ferramentas:

| Pasta/arquivo | Para quê |
|---|---|
| `inicio/` | Cópia **literal** de `design_handoff/ferramentas/medicao/` (v1, tela Início). Só referência; o pacote `design_handoff/` continua intocado. |
| `extrair_bundle.py` | Versão adaptada da v1: modo simples (igual à v1) **e** modo aninhado (bundle com `__bundler/page_order`, uma prancha por bundle). |
| `pranchas.json` | As 13 pranchas do arquivo novo (telas 19–27b): uuid, slug, título, canvas, prefixo dos ids. |
| `comum.js` | Abre uma prancha isolada no Chromium (rede bloqueada, fontes prontas, zoom), seletor do frame. |
| `pranchas/` | Saída da extração (gerada, fora do git — só `extracao.json` é versionado). |

## Ambiente

- Playwright **1.56** (Chromium 141), Node 22, Python 3.11 com Pillow, numpy e fontTools — o mesmo da v1.
- Chromium com `--font-render-hinting=none`.
- Rodar sempre a partir da raiz do repositório.
- **Linux** (T02): o Chromium do Windows mede texto diferente do Linux; a G01 foi medida no Linux. No Windows, usar o WSL
  com o ambiente em `/opt/booknest-medicao` (`ambiente_wsl.sh`: venv + Node + Playwright 1.56, `fonts-inter` e um fontconfig que prefere a
  Inter para os glifos de fallback como o "≈" das pranchas 20 e 26b, suavização em tons de cinza — `rgba none`, sem o
  subpixel que o Ubuntu do WSL liga em `10-sub-pixel-rgb.conf` — e sem hinting — o Ubuntu liga o `hintslight` em
  `10-hinting-slight.conf`; as fontes do arquivo não sentem, o Chromium roda com `--font-render-hinting=none`, mas as do
  sistema sim). `wsl.sh` liga esse ambiente e roda o comando na raiz do repositório:

  ```bash
  MSYS_NO_PATHCONV=1 wsl bash tools/medicao/wsl.sh 'CONJUNTO=inicio2 bash tools/medicao/rodar_tudo.sh'
  ```

  Conferência (T02, `CONJUNTO=leitor_conferencia`): com esse ambiente a G01 sai **igual byte a byte nos 305 arquivos**
  (layouts, PNGs, SVGs, referências Dart, fases, tokens, mapa, fontes, validação) e o gate A2 (render × prévias) passa
  nas 13 pranchas. Os tokens da G01 são conferidos com os arquivos de `lib/core/design_system/tokens/` do commit
  `cbfc021` (os de hoje já têm a G11): `TOKENS_DART=<pasta com eles> CONJUNTO=leitor_conferencia bash rodar_tudo.sh`.
  Com o `hintslight` do Ubuntu ligado, só o "≈" das 20 e 26b (Inter Bold 4.0, a mesma versão da G01) saía 0,012 px mais
  baixo — 86 e 90 px a @3x, ≤ 15/255. Não editar `rodar_tudo.sh` enquanto ele roda: o bash lê o arquivo aos pedaços.

## Conjuntos (T02)

Os scripts medem o conjunto de pranchas da variável `CONJUNTO` (padrão `leitor`, os caminhos da G01); `conjuntos.json`
diz onde fica cada entrada e saída (`conjunto.py` / `conjunto.js` resolvem os caminhos):

| Conjunto | Índice | Saídas |
|---|---|---|
| `leitor` | `pranchas.json` (19–27b) | `handoff_v2/referencia/…`, `handoff_v2/fases/`, `test/reference/leitor/`, `assets/*/leitor/` |
| `inicio2` | `pranchas_inicio2.json` (01, 01b, 60–63) | `docs/design/medicao/inicio2/`, `docs/design/fases/` (L01a1…L63 + `LEIA-ME_inicio2.md`), `test/reference/inicio2/`, `assets/*/inicio2/` (D-242) |
| `leitor_conferencia` | `pranchas.json` | tudo em `tools/medicao/tmp/conferencia_g01/` — refaz a G01 para comparar com o que está commitado |
| `inicio2_larguras` | `pranchas_inicio2_larguras.json` (a 01 a 360 e 430, T03) | `docs/design/medicao/inicio2_larguras/`, `test/reference/inicio2_larguras/` |
| `projeto` | `pranchas_projeto.json` (as 41 das etapas 7–11, T13) | `docs/design/medicao/projeto/`, `docs/design/fases/` (`fases_projeto.json`), `test/reference/projeto/` |
| `projeto_larguras` | `pranchas_projeto_larguras.json` (as 41 a 360 e 430, T13.9) | `docs/design/medicao/projeto_larguras/` (com o `fluidez.json`), `test/reference/projeto_larguras/` |

Por conjunto também: o módulo dos ids (`idmaps_spec_inicio2.py`), as notas das fases (`fases_notas_inicio2.py`), os nomes
dos SVGs (`svgs_nomes_inicio2.py`: reuso de asset existente por C14N, ids normalizados, altura em %, tamanho do layout;
`svgs_nomes_projeto.py` na T13.11, ver abaixo),
o índice das fases (`fases_inicio2.json`) e, no `pranchas_inicio2.json`, a faixa da 63 que o gate de convergência confere
noutro zoom (`convergenciaFaixa`: y 60–80 com o zoom 15 × 10, porque nos zooms 13, 14 e 16–20 o Skia desenha errado a
borda de cima da folha; o resto da prancha com o 20 × 10). No `pranchas_projeto.json`, a 18b tem a mesma faixa pelo
mesmo motivo (T13.8: a folha com a borda de cima de 1,5 px e os cantos de cima arredondados; y 290–335 com o zoom
12 × 10, porque nos zooms 14, 15, 16, 20 e 40 sai um bloco preto no canto). `comparar_layouts.py` compara dois
conjuntos de `layout_*.json` campo a campo.

## Passo 1 — extrair as pranchas (G01.1)

```bash
python3 tools/medicao/extrair_bundle.py \
  "handoff_v2/referencia/original/Redesign mobile — App de leitura (1).html" --listar
python3 tools/medicao/extrair_bundle.py \
  "handoff_v2/referencia/original/Redesign mobile — App de leitura (1).html" \
  tools/medicao/pranchas --aninhado tools/medicao/pranchas.json
```

Para cada prancha: `pranchas/<slug>/original.html` (o bundle da prancha byte a byte — renderiza sozinho), `template.html` (HTML com `{{props}}`), `assets/` (fontes e runtime) e `props.json` (props editáveis e `$preview`). A extração confere uuids × `page_order`, títulos × `<h2>` da página raiz e canvas × `$preview`, e grava os sha256 em `pranchas/extracao.json`.

Como o bundle aninhado funciona: a página raiz guarda as 13 pranchas no próprio manifest (`text/html`, gzip) e cria cada `<iframe src="about:blank#<uuid>">` a partir desse texto. Cada prancha é outro bundle com `dc-runtime` + React; as props (`paper`, `brand`, `ink`) vêm de `data-props` com valor padrão. Depois de desempacotar, o retângulo da prancha é `#dc-root > .sc-host > [data-dc-tpl="4"]` (na v1 era o pai de `<main>`).

## Telas do projeto completo (T13, formato `dc`)

As telas de `docs/design/projeto/telas/*.dc.html` não são bundles: cada uma chama o `./support.js` (= o `dc-runtime.js`
do projeto, R00) e pede as fontes ao Google Fonts (`<link>` para o `css2`). `extrair_dc.py <índice> <saída>` gera para
cada tela a mesma pasta da extração antiga (`original.html`, `template.html`, `props.json`, `support.js`, `assets/`) e o
`extracao.json`: só o `<link>` do `css2` vira um `<style>` com as `@font-face` que o Google devolve para aquela consulta
(`fontes_css2.py` + a tabela `fontes_css2.json`: o latin local, os outros subconjuntos no `gstatic`, como as exportações
antigas). O `<helmet>` continua com 3 filhos, então o quadro (`data-dc-tpl="4"`) e a numeração são os de antes e os
scripts não mudam. O índice tem `"formato": "dc"`; o `rodar_tudo.sh` usa a extração nova e pula a página raiz e as
prévias (que o projeto não tem). Conjuntos: `projeto` (as 41 das etapas 7–11, `pranchas_projeto.json`) e
`projeto_conferencia_inicio2`/`_leitor` (as 19 já medidas, extraídas do projeto e medidas de novo para comparar com o
commitado: `ATE=referencias` para no fim das referências Dart). Testes: `python3 -m unittest
tools/medicao/test_extrair_dc.py` (as faces contra os 35 helmets antigos e as respostas reais do `css2`, as versões,
a numeração, o catálogo, o texto fora do latin e a pasta gerada).

A prova (R3): `comparar_conferencia.py` (no WSL) compara a conferência com o commitado e escreve
`docs/design/medicao/projeto/conferencia_medicao.md` — layouts campo a campo sem a origem, a frase do método e a lista
`fontFaces` (que muda pelo método e vai descrita), PNGs byte a byte (num redline diferente, todo pixel diferente tem de
estar dentro de um rótulo numerado), idmaps e referências Dart.

As 41 telas são medidas uma etapa por vez (T13.4 a T13.8): `bash tools/medicao/rodar_etapa.sh 02,36,17,17b` (no WSL)
roda a extração e, só para as telas do argumento, os ids (`idmaps_spec.py <telas>`, com os módulos
`idmaps_spec_projeto_t14.py` … `_t18.py` juntos em `idmaps_spec_projeto.py`), a medição, o supersample, as reduções e a
dependência de texto (juntada à das etapas de antes); os recortes por fase (`fases_projeto.json`, que ganha as fases de
cada etapa) e as referências Dart (`gen_reference_dart.py <telas>`: o índice `referencias_projeto.dart` lista as telas
que já têm referência). O fechamento roda as 41 de uma vez com `rodar_tudo.sh` e tem de dar os mesmos bytes.

As larguras (T13.9, D-272): o conjunto `projeto_larguras` mede as 41 a 360 e 430 px, como a T03 fez com a 01
(`inicio2_larguras`): cada entrada abre a extração e o idmap da tela base e troca a largura do quadro (CSS fluido; a
altura do quadro é a da tela a 390). O índice `pranchas_projeto_larguras.json` sai do `indice_larguras.py` (as
fontes de reserva e o zoom da D-279 vêm da tela base; a faixa da R3 é de cada largura, gravada à mão e mantida
quando o índice é refeito). Rodar: `CONJUNTO=projeto_larguras bash tools/medicao/rodar_larguras.sh` (no WSL; sem
`CONJUNTO`, a `inicio2_larguras`). O `fluidez.py` compara cada id a 360 e 430 com o mesmo id a 390 (o
`conjuntoBase`) e escreve `docs/design/medicao/projeto_larguras/fluidez.json`: onde a tela deixa de ser fluida — a
caixa que sai do quadro, que passa do pai (cortada, rola ou vaza, pelo `overflow` do pai), o texto que passa da
caixa, o vizinho invadido, as reticências novas —, com `novo` (não acontecia a 390) e se o elemento tem largura fixa.

Fonte de reserva (R8): no índice do projeto, `reserva` diz, por tela, os ids cujo texto o Chromium desenha com uma
fonte de fora das `@font-face` (o motivo e se é `informativo`: texto que o sistema desenha, não o app — o botão da
Apple, o teclado). O `build_layout.py` falha com qualquer outra e com a declarada que não aparece; o `informativo` vai
para o layout e para a referência Dart (`kInformativo<tela>`, id → motivo, e o `kInformativoProjeto` do índice). O CDP
atribui a fonte do texto também ao pai em alguns casos (como o `progressRow` da 20): os dois entram.

SVGs do projeto (T13.11, R7): `svgs_nomes_projeto.py` dá o nome, a descrição, as cores dinâmicas, as armadilhas e as
opções do `exportar_svgs.py` — o reuso pelo desenho (D-283: a C14N sem o tamanho da raiz, com os ids renumerados e sem
o linejoin que não muda nada), a pasta da área da 1ª etapa que usa (`areas` no conjunto, D-284), a armadilha por uso,
as notas de um uso só (`NOTAS_USO`), os `atributos` do `<svg>` quando o layout é outro e o `id="tracejado"` no
elemento tracejado de um desenho com outros do mesmo nome com traço (`idTracejado`, D-285); `SECO=1` só mostra o plano. A
ida e volta tem dois modos: o da T02 (`<img>`, mostra as armadilhas do uso como imagem) e `MODO=inline` (o arquivo em
linha, com o layout do original: prova o desenho — 0 px nas 41), e aceita a lista de telas
(`CONJUNTO=projeto MODO=inline node tools/medicao/conferir_svgs.js 017_detalhes_fisico && … conferir_svgs.py`). Os
recortes @3x (`ITENS_PROJETO`) aceitam a união de ids e uma região. As classes por área saem do catálogo por
`gen_classes_svg.py` (no Windows, com o `dart format`: `CONJUNTO=projeto python3 tools/medicao/gen_classes_svg.py`).
Testes: `python3 -m unittest tools/medicao/test_svgs_projeto.py` e `test/design_system/t13_recursos_projeto_test.dart`.
Os tracejados do registro do app (`svgDashes`, D-285/D-286): `node tools/medicao/tracejados_chromium.js` (no WSL) desenha
no Chromium cada elemento com `stroke-dasharray` de `assets/` sozinho, a 3× e a 8×, em
`docs/design/medicao/projeto/png/tracejados/`; o `test/design_system/t01_svg_dash_test.dart` compara o traço que a
`AppSvg` pinta com esses PNGs.

Seção sem contêiner (T13.5): no projeto há seções sem um elemento que as embrulhe (a Busca põe o título e a lista de
cada seção direto no `<main>`). Nesse caso a caixa da seção é a união das caixas dos ids de topo dela (os que não estão
dentro de outro id da mesma seção) — a mesma de um contêiner justo —, e o layout lista esses ids em
`meta.secoesSemElemento`. Fora do projeto toda seção continua sendo um elemento (o `build_layout.py` para).

Tokens, mapa e fases L do projeto (T13.12, R5): `CONJUNTO=projeto python3 tools/medicao/tokens_widgets.py <tokens do
app>` gera `docs/design/medicao/projeto/tokens_projeto.json` (o que é novo em relação aos tokens do app, com o nome
proposto), `mapa_widgets.json` (os 3409 ids; o widget de cada SVG é `AppSvg(Classe.constante, …)`, com a constante das
classes do app — as por área da T13.11 e as de antes, para os reusados) e o `L00_projeto_tokens_e_widgets.md`. Os
arquivos commitados saíram dos tokens do app do commit `66ec95a` (T13.11): a partir da T14 o app ganha tokens e
classes, e o "já existe" mudaria — para refazê-los, passe a pasta com os arquivos daquele commit (`TOKENS_DART`, como
na conferência da G01). `CONJUNTO=projeto python3 tools/medicao/gen_fases.py` gera as 73 fases L e o
`LEIA-ME_projeto.md` em `docs/design/fases/`: a parte medida sai das medições — as props de cada tela no CSS literal
(o halo é verde na 17 e lavanda na 17b; a 07 não tem props), a seção "Nas outras larguras" (a fluidez e os fios de
navalha a 360 e 430 da T13.9, só dos ids da fase) e as seções sem contêiner no HTML literal —; a parte escrita à mão
está em `fases_notas_projeto_t14.py` … `_t18.py` (juntos em `fases_notas_projeto.py`, que recusa fase repetida; o que
se repete em `fases_notas_projeto_comum.py`). Os módulos de notas não têm barra invertida (a ferramenta de escrita a
decodifica). Na T13.12 o gerador ganhou correções que valem para a Início e o projeto: a caixa visual dos elementos
com transform sai com os números (desde a G01 saía `{fmt(...)}` cru), o HTML literal de um elemento que divide a linha
do arquivo com outro sai só com ele (os confetes da 16) e a seção "Diferenças" sem nada que mude diz "Nenhuma
diferença"; no projeto, o fio de navalha de uma seção reaproveitada da base sai na fase que a mostra (a fileira do
autor da 17b). As fases do leitor saem como na G01 (`LEGADO_G01`: o `handoff_v2` é só leitura, G01 305/305); na
Início mudaram 7 fases, e o manifesto da T02 acompanha. Testes: `python3 -m unittest
tools/medicao/test_fases_projeto.py` (os tokens do app entram fixos naquele commit; o teste do leitor roda quando a
conferência da G01 está em `tools/medicao/tmp/conferencia_g01/`).

Fechamento (T13.13, R10): as duas rodadas inteiras de cada conjunto (`CONJUNTO=projeto bash rodar_tudo.sh` e
`CONJUNTO=projeto_larguras bash rodar_larguras.sh`) dão os mesmos sha256 → `docs/progresso/T13_hashes_saida.txt`. O
`hashes_saida.py` lista as pastas que o conjunto tem (o projeto não tem SVG de tinta) e, com `areas`, a pasta de cada
área dos ícones e ilustrações. As métricas de fonte do layout (`fontMetrics`: o topo do "H" e a linha de base numa
sonda) saíam da fonte de reserva quando a face ainda não tinha chegado — na 28c a chave `Figtree|400|normal|16px` é
só de um texto em branco, que não faz o navegador baixar a face, e a sonda media a serif de reserva conforme a
corrida. O `medir.js` espera cada face (`document.fonts.load`) antes da sonda; a família que não existe (as do
sistema, R8) resolve vazia e continua com a métrica de reserva, como antes. A Início conferida contra o manifesto da
T02 pede os tokens do app do commit em que ela foi gerada (`1d4a7d4`), como a G01 os do `cbfc021`: a T03 e a T04
criaram no app tokens com os nomes propostos (`reviewLineNeutral`, `tagReadBg`…), e o "já existe" dos tokens e do L00
mudaria (`TOKENS_DART=<pasta com os arquivos de lib/core/design_system/tokens/ daquele commit> CONJUNTO=inicio2 bash
rodar_tudo.sh`).

Fio de navalha de uma linha (D-275): nos conjuntos com `"facaLinhaUnica": true` (o projeto), o `perturbar.js`
também marca a linha única que pode quebrar (tem espaço; caixa que não é flex/grid) numa caixa de largura imposta
com sobra entre 0 e 1,5 px, medida pela largura real da linha (um Range sobre os nós de texto). O leitor e a Início
seguem a regra da G01 (só texto de 2+ linhas). Em todos os conjuntos (D-276), a linha que dá a largura da caixa (sobra
0: a caixa é do tamanho do texto e cresce junto) não é fio de navalha, nem no texto de 2+ linhas.

Fio de navalha de fileira (D-278): nos mesmos conjuntos (`facaLinhaUnica`), o `perturbar.js` mede também cada fileira
de um flex-wrap (`flex-wrap: wrap`), pelo tamanho hipotético de cada item — crescer e encolher desligados enquanto mede
(não mudam as fileiras) e religados depois. A fileira cheia por < 1,5 px (sobra) ou que receberia o 1º item da
seguinte faltando < 1,5 px (estouro) é marcada: no Flutter (`Wrap`) uma diferença mínima de largura de texto muda as
fileiras e desloca todos os itens seguintes. A entrada fica no id do contêiner, com `fileiras: true`; cada "linha" é
uma fileira e o texto são os textos dos itens separados por " | " (um item sem texto entra pelo id). Vai para a
referência Dart com o mesmo `LeitorKnifeEdge` (id do contêiner, número da fileira) e para as fases L com a frase própria.

Zoom da referência por prancha (D-279): o supersample é no zoom 10 e a convergência é conferida com o 20. Na 30b,
no zoom 10, o Chromium arredonda a altura dos rótulos com `line-height: normal` (a métrica da fonte vira pixel inteiro
no espaço com zoom) e o erro soma até 0,59 px na metade de baixo; o índice diz `zoomBase: 20` e `zoomConvergencia: 40`
para ela (o 20 fica a 0,06 px do JSON e o 40 a 0,015). `rodar_etapa.sh`/`rodar_tudo.sh` fotografam a prancha nesses
zooms e o `reduzir.py` reduz do zoomBase e confere com o zoomConvergencia, reduzindo a conferência faixa a faixa (as
faixas de 2000 px caem em bordas de pixel: os mesmos bytes que a imagem inteira, e o zoom 40 cabe na memória).

Fio de navalha medido no navegador (D-280; `facaNavegador` em `conjuntos.json`: o projeto, a Início e as larguras da
Início). Para cada linha de cada texto, o `perturbar.js` põe +δ ou −δ num `<span>` em volta do último espaço entre
palavras da linha (ou do último caractere, se ela tem uma palavra só) e deixa o navegador quebrar de novo (com δ = 0 as
quebras têm de ser as da prancha). O δ é uma margem à direita do `<span>`; no texto com `text-wrap: pretty` ou
`balance` é `word-spacing` (`letter-spacing` no caractere), porque com margem o Chromium deixa de aplicar o pretty — e
lá o estouro maior do que os espaços da linha conseguem encolher (uns 3–4 px) fica `null`, sem virar quebra imposta: a sobra é o menor δ que muda as quebras do texto e o estouro, o menor encolhimento que faz a próxima palavra
subir (busca binária, 0,0002 px; a sobra até 4096 px, o estouro até a largura da linha). `null` = não muda: a linha
não quebra ao crescer (uma palavra só; caixa do tamanho do texto com espaço — a D-276) ou a quebra é imposta (`<br>`,
`nowrap`). Antes de medir, o texto solto de uma caixa flex/grid vai num `<span>` (é o mesmo item anônimo; a ferramenta
confere que nenhuma caixa se move). A estimativa da G01 (cada linha como texto simples, na fonte da caixa, contra a
largura da caixa) continua no leitor, porque o `handoff_v2` é só leitura; lá ela marca 5 fios que não existem (a linha
7 das 22–24b: quem subiria é o trecho marcado com `nowrap`, não a palavra).
