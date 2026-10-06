# Relatório da FASE G10 — Paginação, páginas de referência e posição

Data: 05/10/2026 · branch `feat/g10-paginacao` (a partir de `feat/g09-importacao`, `18759cb`) · nada enviado ao GitHub.
Evidências de cada subfase: `docs/progresso/G10.md`.

Decisões usadas (respondidas por você em 05/10, antes do código):
- Altura de linha exata e pintura linha a linha (Q21 → D-94).
- Tempo automático com pausa após 120 s parado (D-27 confirmada → D-95).
- Estilo BookNest nos livros (D-96).
- Tempo restante pela velocidade pessoal, no leitor e na Início (D-97).
- Títulos em Literata maior (D-98).
- Quebra de cena "* * *" centralizada (D-99).
- Cada capítulo começa numa página nova (D-100).
- Capturas das páginas em vez de tela provisória (D-101).

## Resultado

| Subfase | Entrega | Prova |
|---|---|---|
| G10.1 Tipografia e blocos | Literata variável com `opsz` e `wght` explícitos (sem negrito sintético) e os subconjuntos de fallback. Altura de linha exata e pintura linha a linha. Recuo por `PlaceholderSpan`. Estilo BookNest (alinhamento, citação, lista, títulos, quebra de cena, imagens). Parágrafos longos montados em pedaços com as mesmas linhas do inteiro | **Gate da tela 19:** as 19 linhas iguais, e a página seguinte começa pelas 3 escondidas. Baseline máx. 0,0027 px, borda direita 0,0065 px, PNG 0,2149 % |
| G10.2 Paginação | Páginas por capítulo com título nunca sozinho no pé, objetos inteiros e `page-break-before`. Layout em fatias de ≤ 4 ms. O capítulo atual primeiro, e só ele e os vizinhos ficam montados. Cache de páginas por ajustes/tela/fontes/arquivo. Livro aberto: abre numa posição, vira atravessando capítulos e repagina quando os ajustes mudam | `chapter_layout_test`, `layout_scheduler_test`, `book_pager_test` (Dom Casmurro real), `page_layout_cache_test` |
| G10.3 Posição e números | Posição salva (1º caractere visível, citação, página, %) depois de 1 s parado e ao sair. Reaberta pela reancoragem da G09. "pág. X de Y", "%", capítulo atual, sumário com páginas de início | `reader_numbers_test`: pág. 159 de 256 no cap. XXXII, 62 %, sumário do arquivo. `reading_position_keeper_test` |
| G10.4 Tempo | Sessão automática (D-95): conta só com o leitor visível; pausa por parado, segundo plano ou tela bloqueada; < 10 s não grava; páginas lidas = ≥ 3 s. Velocidade pessoal (média móvel α 0,2; 1.000 car./min no começo) e tempo restante arredondado, também na Início | `reading_session_tracker_test` (relógio falso), `reading_speed_test`, `local_home_repository_test` |
| G10.5 Verificação | Revisão independente com correções, capturas, medidas, mutação, cobertura e gitleaks | Abaixo |

Números finais:
- `flutter analyze` sem problemas.
- `flutter test`: **1.313 verdes** (+7 pulados: os 6 de antes e a medida por tamanho de letra, que só roda na rodada de medida; eram 1.230 no fim da G09).
- **Desempenho no PC** (rodada de medida sozinha; o celular é medido na G26):

  | Métrica (Anexo 03 §12) | Orçamento | PC |
  |---|---|---|
  | Abrir no meio de um capítulo até a 1ª página, sem cache | < 600 ms | 327 ms |
  | O mesmo, com o cache de páginas | < 600 ms | 65 ms |
  | Paginar 40 páginas | < 120 ms | 39 ms |
  | Fatias | ≤ 4 ms | 2,3 % acima (maior 4,8 ms) |

  - **As fatias acima de 4 ms** são a 1ª vez de um tamanho ou peso de letra: o Skia cria a instância da fonte variável, uma vez por sessão.
  - **Páginas do Dom Casmurro por tamanho de letra:** 464 (16) · 550 (17,5) · 652 (19) · **741 (20,5)** · 886 (22) · 1.026 (24) · 1.273 (26).
- **Início:** pela velocidade pessoal (D-97), o tempo restante do mundo de referência sai **~1h 10min**. A prancha escreve 2h 10min à mão, e essa diferença continua registrada no teste.
- **Cobertura** dos módulos da fase: **95,8 %** (de 91,5 % no livro aberto a 100 % na tipografia, na pintura, no índice e na velocidade).
- **Mutação: 39/39** trocas derrubadas pelos testes:
  - tolerância e altura exata da linha;
  - costura dos pedaços;
  - recuo e imagem ampliada;
  - título órfão;
  - prioridade e orçamento das fatias;
  - cache de outro arquivo;
  - repaginação que anda para trás;
  - % com 5 casas;
  - citação sem cortar palavra;
  - 120 s, 10 s e 3 s;
  - média móvel e arredondamento;
  - cada correção da revisão.

  Uma 40ª troca sobreviveu e mostrou que uma regra que eu tinha posto não fazia diferença (descartar 2 linhas quando o corte cai no meio da palavra). Simplifiquei.
- **gitleaks:** os commits da fase e as pastas tocadas sem vazamento.

## Capturas (D-101)

Mandadas nesta conversa e guardadas em `tools/medicao/tmp/g10/capturas/` (fora do git):
- a página da tela 19;
- o começo do cap. I do Dom Casmurro em 20,5 e em 26;
- 2 páginas de um capítulo de teste com título + subtítulo, citação, lista com subnível, imagem e quebra de cena.

São só as páginas do motor sobre o papel creme. O rodapé e o resto da tela são da G11.

## Revisão independente

Um agente separado leu tudo sem editar: **3 achados altos, 7 médios, 12 baixos e 7 suspeitas**. Corrigi com teste os altos, os médios, 7 dos baixos e 5 das suspeitas (commit `2a7d71f`). Os principais:

| # | Achado | O que fiz |
|---|---|---|
| A1 (alta) | Virar página podia ficar parado para sempre se o capítulo fosse descartado no meio (mudar a letra, abrir outro capítulo) | Quem esperava um capítulo descartado desiste em vez de esperar |
| A2 (alta) | Aberturas e viradas cruzadas no tempo: uma atrasada trocava a página de uma mais nova, e um capítulo descartado virava "vazio" e quebrava o leitor | Vale a abertura mais nova; viradas em fila depois da abertura em andamento |
| A3 (alta) | Mudar a letra descartava a página ainda na tela, e pintar no meio quebrava | A página da tela continua viva até a nova chegar |
| A6 | Ler às 23:50 e voltar às 8:00: os minutos iam para ontem | Voltar a ler noutro dia abre outra sessão |
| A7 | Acertar o relógio no meio da leitura apagava ou inventava tempo | O tempo é medido por um relógio que não muda quando o relógio do aparelho é acertado |
| A8 | Sumário com partes dava "Cap. 6 de 4" | Capítulo contado do mesmo jeito que o total |
| S1 | Um "carregando" girando na tela impediria a página de chegar | Quem espera uma página passa na frente da animação |

Os outros estão em `G10.md`, seção "Revisão independente". Ficaram registrados sem correção, por serem raros ou da G11:
- título seguido de imagem muito alta;
- título antes de quebra de página do livro;
- sessão de "folhear" puxando a velocidade para cima: um teto mudaria a regra da D-97, então pergunto se aparecer no beta;
- imagem acima de 8 MB;
- livro terminado ainda "lendo" mostrando "~0h 00min";
- números do PDF.

## O que mudou do desenho

Nenhuma decisão mudou. Mudou a forma, registrada em `G10.md` (seção "Desvios"):
- **Fatias ociosas, mas não sempre:** as fatias usam a prioridade ociosa, e passam à prioridade de animação enquanto alguém espera uma página.
- **Previsão da fatia:** o tempo de cada passo de layout é previsto pelo tamanho dele.
- **Âncora ao mudar a letra:** mudar a letra várias vezes volta sempre ao mesmo caractere. A posição salva continua sendo o 1º caractere visível.
- **Velocidade:** é calculada pelas páginas lidas × caracteres por página. Começa na 1ª sessão de 3 min, e o tempo restante nunca fica abaixo de 5 min.
- **Edição diferente do livro:** quando a citação guardada não está no mesmo capítulo da outra edição, a reabertura usa a %.
- **Chave do cache:** a tela que entra na chave do cache vem dos próprios ajustes.

## Pendências

- **G11 (tela do leitor):**
  - ligar o livro aberto, a posição e a sessão à tela: ciclo de vida do app, "carregando" e erro (D-21);
  - rodapé "pág. X de Y · %" pelo 1º caractere visível;
  - números do PDF.
- **G26 (no celular):**
  - medir os orçamentos num aparelho intermediário;
  - se a 1ª vez de um tamanho de letra pesar, preparar as fontes ao abrir o livro.

✅ FASE G10 concluída — aguardando sua aprovação para iniciar a FASE G11.
