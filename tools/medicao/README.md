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
