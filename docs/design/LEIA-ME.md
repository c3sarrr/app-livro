# docs/design — as telas do Claude Design

**Regra do projeto todo:** antes de construir, mudar ou conferir qualquer tela, leia a prancha dela no arquivo HTML
do design. O HTML é a fonte da verdade do visual e dos dados que a tela mostra (textos, números, estados). Se a tela
não está em nenhum arquivo daqui nem do `handoff_v2/`, pergunte antes de inventar.

## O projeto completo (fonte principal desde 10/10/2026)

`docs/design/projeto/` tem o projeto inteiro do Claude Design ("Redesign mobile — App de leitura"): **128 telas** e o
**Mapa de navegação** (00), no formato de origem (`telas/*.dc.html`, renderizados pelo `dc-runtime.js`), com o índice
original (`canvas.json`), o catálogo (`CATALOGO.md`: número, título, arquivo e tamanho de cada tela) e as notas do
design para o Flutter (`NOTAS.md`). Não edite: uma versão nova entra numa pasta nova. A ordem em que as telas entram no
app está em `docs/ROTEIRO.md`.

Os três arquivos abaixo são exportações de uma página só e continuam como a referência medida das telas já feitas.

### A conferência, a cobertura e o mapa (R00, 11/10/2026)

- **O `support.js`** que os `.dc.html` chamam é o próprio `dc-runtime.js` do projeto: ele junta, byte a byte e nessa
  ordem, os 3 scripts que renderizavam as pranchas antigas (React, ReactDOM e o runtime).
- **As pranchas já medidas não mudaram no projeto:** `tools/medicao/conferir_projeto.py` compara as 35 que tinham
  exportação antiga (as 6 da Início e da revisão: 01, 01b, 60–63; as 13 do leitor 19–27b; as 16 do clube) com os
  `.dc.html` — DOM normalizado e CSS sem as `@font-face` — e grava `medicao/projeto/conferencia_projeto.md`: **35/35
  iguais**. Rodar de novo quando o projeto mudar (uma pasta nova, com `--projeto`):
  `PYTHONIOENCODING=utf-8 python3 tools/medicao/conferir_projeto.py`.
- **Renderizar um `.dc.html`** no Chromium do WSL, com o `dc-runtime.js` servido como `support.js`:
  `MSYS_NO_PATHCONV=1 wsl bash tools/medicao/wsl.sh 'node tools/medicao/renderizar_dc.js telas/MainLendo.dc.html --dsf 3'`
  (a 01b do projeto sai igual pixel a pixel à exportação antiga; o método de medida continua o da T02 — ROTEIRO §6b).
- **`projeto/COBERTURA.md`:** as 128 telas (rota no app, situação ✅/🟠/⬜, etapa), as 9 que o Mapa marca como faltando
  (D-268) e o futuro; `test/design/cobertura_test.dart` confere com o `CATALOGO.md` e o ROTEIRO §3.
- **`medicao/projeto/mapa_navegacao.json`:** as ligações do Mapa de navegação (00), lidas da geometria das setas
  (`tools/medicao/mapa_navegacao.py`); a `docs/NAVEGACAO.md` (c) as põe ao lado do que o app faz.

## Os arquivos

| Arquivo | Telas | sha256 |
|---|---|---|
| `handoff_v2/referencia/original/Redesign mobile — App de leitura (1).html` | o leitor e os grifos: 19, 20, 21, 22, 23, 23b, 24, 24b, 25, 26, 26b, 27, 27b | `1ff5ec4fc5413b5752ec35db1901a51562742621d4ff7edbfddf1b252720d740` |
| `docs/design/referencia/Redesign_mobile___App_de_leitura__1_.html` | a Início e a revisão: 01 Início, 01b Início lendo agora (cronômetro ativo), 60 grifos de hoje (revisão), 61 revisão grifo 2 de 5, 62 revisão fim, 63 imagem para compartilhar | `942adf82885b8b3a99e8041912b3173ae6bd1e2ae9ef7253baa8d688e43fd783` |
| `docs/design/referencia/Redesign_mobile___App_de_leitura_2.html` | o clube (16): 04 Clube, 31 discussão da semana, 32 membros, 33 criar clube, 34 convite (link e QR), 47 enquete criar, 48 indicar um livro, 49 votar, 50 resultado, 70 encontro detalhe, 71 sala aberta, 72 mudar presença com recado, 73 encontro depois, 102 quem votou (aberta), 103 quem votou (resultado), 104 voto secreto | `fee4cad51b92184b4e33e70d3e5518e82c9d9972617f87c1fcdbcca1e6165517` |

A tela Início da 1ª fase (F00–F13) está em `design_handoff/` (não mexer). Os arquivos de `docs/design/referencia/`
ficam byte a byte como vieram (`.gitattributes`): não edite; uma versão nova entra com outro nome.

## Como ler uma prancha

Os arquivos são bundles do Claude Design: abrir no navegador mostra tudo, mas para medir é preciso extrair.

```bash
# listar as pranchas de um arquivo
python3 tools/medicao/extrair_bundle.py "docs/design/referencia/Redesign_mobile___App_de_leitura_2.html" --listar

# extrair as 16 do clube (saída fora do git)
python3 tools/medicao/extrair_bundle.py "docs/design/referencia/Redesign_mobile___App_de_leitura_2.html" \
  tools/medicao/pranchas_clube --aninhado tools/medicao/pranchas_clube.json
```

Cada prancha vira `<slug>/original.html`, que renderiza sozinho no Chromium (`tools/medicao/comum.js`), com o
`template.html`, os `assets/` e o `props.json`. O resto do processo de medição está em `tools/medicao/README.md`.

## Estados sem design

`estados_sem_design.md`: o que o app mostra sem prancha (vazios, erros, folhas novas), para o design desenhar.
