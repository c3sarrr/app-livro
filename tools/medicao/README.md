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
  Inter para os glifos de fallback como o "≈" das pranchas 20 e 26b, e suavização em tons de cinza — `rgba none`, sem o
  subpixel que o Ubuntu do WSL liga em `10-sub-pixel-rgb.conf`). `wsl.sh` liga esse ambiente e roda o comando na
  raiz do repositório:

  ```bash
  MSYS_NO_PATHCONV=1 wsl bash tools/medicao/wsl.sh 'CONJUNTO=inicio2 bash tools/medicao/rodar_tudo.sh'
  ```

  Conferência (T02, `CONJUNTO=leitor_conferencia`): com esse ambiente a G01 sai igual byte a byte em 291 de 305
  arquivos (layouts, SVGs, referências Dart, fases, tokens, mapa, fontes, validação); os 14 restantes são PNGs das 20 e
  26b, que diferem só no glifo "≈" (a Inter do Ubuntu é outra versão): 86 e 90 px a @3x, no máximo 15/255. Os tokens
  da G01 são conferidos com os arquivos de `lib/core/design_system/tokens/` do commit `cbfc021` (os de hoje já têm a G11).
  O gate A2 (render × prévias) passa nas 11 sem fallback; nas 20 e 26b, ~200 px pelo mesmo glifo.

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
o índice das fases (`fases_inicio2.json`) e, no `pranchas_inicio2.json`, a exclusão documentada do gate de convergência
da 63 (`convergenciaExcluirY`). `comparar_layouts.py` compara dois conjuntos de `layout_*.json` campo a campo.

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
