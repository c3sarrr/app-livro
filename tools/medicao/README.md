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

Por conjunto também: o módulo dos ids (`idmaps_spec_inicio2.py`), as notas das fases (`fases_notas_inicio2.py`), os nomes
dos SVGs (`svgs_nomes_inicio2.py`: reuso de asset existente por C14N, ids normalizados, altura em %, tamanho do layout),
o índice das fases (`fases_inicio2.json`) e, no `pranchas_inicio2.json`, a faixa da 63 que o gate de convergência confere
noutro zoom (`convergenciaFaixa`: y 60–80 com o zoom 15 × 10, porque nos zooms 13, 14 e 16–20 o Skia desenha errado a
borda de cima da folha; o resto da prancha com o 20 × 10). `comparar_layouts.py` compara dois conjuntos de
`layout_*.json` campo a campo.

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
