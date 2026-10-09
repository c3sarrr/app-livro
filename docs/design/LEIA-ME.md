# docs/design — as telas do Claude Design

**Regra do projeto todo:** antes de construir, mudar ou conferir qualquer tela, leia a prancha dela no arquivo HTML
do design. O HTML é a fonte da verdade do visual e dos dados que a tela mostra (textos, números, estados). Se a tela
não está em nenhum arquivo daqui nem do `handoff_v2/`, pergunte antes de inventar.

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
