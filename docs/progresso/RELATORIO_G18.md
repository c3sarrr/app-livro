# Relatório da FASE G18 — Telas 24 e 24b: espaço aberto e nota à mão

Data: 08/10/2026 · branch `feat/g18-espaco-nota-mao` (a partir de `feat/g17-paineis-caneta-marcatexto`, `b0ff07f`;
o 1º commit da fase é a spec, `54d3b67`) · nada enviado ao GitHub. Evidências de cada subfase:
`docs/progresso/G18.md`.

Decisões usadas (respondidas por você em 08/10, antes do código):
- O espaço abre logo depois da última frase da linha de cima da fresta; o resto da linha desce sem recuo (D-181).
- As alturas das pranchas: a área do abridor mede n·L − 2 com margens 14/24; a caixa, 42·n + 24 com margens 30/26
  e pautas a cada 42 (D-182).
- No leitor limpo, a caixa com a etiqueta, as pautas e a tinta, sem botões, alça e dica (D-183).
- Recolher vira uma faixa de uma linha; no leitor limpo, um toque nela abre (D-184).
- Apagar na hora, com a pílula "Nota apagada · Desfazer" (D-185).
- A alça não sobe além da última linha escrita (D-186).
- Depois de soltar o arrasto, a ferramenta passa para a Caneta (D-187).
- Nota vazia no Concluir é descartada (D-188).
- As regras derivadas do desenho, R1–R15 (D-189).

## Resultado

| Subfase | Entrega | Prova |
|---|---|---|
| G18.1 Layout com espaços | O parágrafo partido na âncora (o resto sem recuo), a fatia do espaço no paginador (cabe ou vai inteira para a página seguinte — R12), a página que começa no espaço, o cache com a assinatura dos espaços, os espaços na `DisplayPage` | `space_cut_test`, `laid_block_test`, `paginator_test`, `chapter_layout_test`, `book_pager_test` |
| G18.2 Dados e sessão | A costura (R1, D-181), as notas na sessão, os comandos do Desfazer, a tinta na nota (R6, unidade da caixa), o Concluir com a camada `space` e a anotação `handwriting` na mesma transação, o rascunho no formato 3, a leitura no leitor | `space_seam_test`, `note_ink_test`, `annotation_session_g18_test`, `ink_repository_test`, `reader_ink_test` |
| G18.3 Abridor (24) | A área hachurada, a costura, o rastro, o dedo, o chip "↕ N linhas", o texto de baixo descendo, o subtítulo "Arraste entre as linhas" | `space_opener_test`, `annotation_mode_test`, L24 |
| G18.4 Caixa da nota (24b) | A caixa, a etiqueta, as pautas, os botões, a tinta, a alça, a dica, recolher e apagar | `hand_note_test`, `hand_note_mode_test`, L24b |
| G18.5 Leitor limpo | A caixa e a faixa na página, o toque na faixa (abre e grava), o leitor de tela, o Noite | `reader_page_view_test`, `reader_screen_g18_test` |
| G18.6 Prova | Mundo das 24 e 24b; L24 e L24b; goldens; comportamento; revisão independente com correções; mutação; cobertura; gitleaks; capturas | Abaixo |

Números finais:
- `flutter analyze` sem problemas.
- `flutter test`: **2.609 verdes** (+7 pulados; eram 2.429 no fim da G17).
- **Fases L24 e L24b** (as telas pela rota real: "Anotar", o Espaço e o dedo parado 3 linhas abaixo da fresta na 24;
  "Anotar" com a nota salva na 24b): **12/12**:
  - os ids no lugar e no tamanho certos (18 na 24, 24 na 24b);
  - as linhas de cima e de baixo nas baselines, e as escondidas fora;
  - cores, bordas, raios, sombras duras e fontes;
  - o leitor de tela;
  - os dados do banco (a camada `space` e a anotação `handwriting`).
- **Golden @3x** contra as pranchas: **0,36 %** (24) e **0,37 %** (24b), com limite de 0,5 %. O lado a lado foi
  conferido a olho.
- **Cobertura** dos arquivos mexidos na fase: **97,2 %**. O menor é o `ink_commands.dart` (91,1 %).
- **Mutação:** **90/90** trocas derrubadas pelos testes. As trocas cobrem:
  - as regras numéricas (as alturas da D-182, a faixa, 1–12, o arrasto, as pautas, a menor caixa da tinta);
  - a costura e o leitor de tela (D-181, R1, R13);
  - o corte do parágrafo e a paginação (R12, o fim na âncora, a página que começa no espaço, o cache);
  - a sessão (R2, R5, R6, R7, D-184 a D-188);
  - a geometria das peças, a pintura, a tela e o repositório (R4, R10, R11, R14);
  - cada correção da revisão.

  Na 1ª rodada passaram 6; os testes ganharam o que faltava e as 6 caíram na 2ª.
- **gitleaks:** os commits da fase e as pastas tocadas, sem vazamento.
- **Latência no celular:** continua pendente, da G16.

## Capturas

Mandadas na conversa e guardadas em `tools/medicao/tmp/capturas_g18/` (fora do git):
- as telas 24 e 24b em Creme e no Noite, e o lado a lado com as pranchas;
- a faixa recolhida no modo e no leitor limpo;
- a página do leitor limpo com a nota;
- a nota que não cabe no resto da página, inteira na seguinte;
- a pílula "Nota apagada · Desfazer".

## Revisão independente

Um agente separado leu a fase inteira sem editar e fez **11 achados confirmados** e 7 suspeitas. Nenhum dado sai do
aparelho no Grátis.

Corrigi os 11 com teste, nos commits `a9bfdb8` e `b7492d2`. Os testes novos falharam antes da correção. Do achado 7
ficou uma parte, a da abertura do livro (em Pendências).

| # | Achado | O que fiz |
|---|---|---|
| 1 | Na página do modo, a nota (ou o abridor) que não cabia no resto da página sumia, com o texto de baixo | No modo, o espaço fica no pé da página e ela sobe com 2 dedos até o pé dele; a alça não fica presa |
| 2 | A nota que o leitor passou para a página seguinte ficava em branco no modo e não barrava a mesma costura | A sessão recebe as notas do capítulo inteiro |
| 3 | O desenho cujas palavras passavam do pé ficava sobre outras palavras e era gravado nelas | Anda com as palavras, escondido, e é gravado nelas |
| 4 | Apagar a nota salva e abrir outra igual no mesmo lugar deixava a nova sem caixa | Corrigido (a página compara qual nota é cada espaço) |
| 5 | A tinta que saía da caixa ficava guardada, escondida: a alça pulava por ela e a Borracha a apagava fora | O traço é recortado na borda; o Laço da nota move só dentro dela |
| 6 | Passado o teto de 256 KiB, o Concluir falhava sempre | A nota cheia não aceita mais traços |
| 7 | A repaginação pelos espaços podia apagar a página do modo | Ela espera o modo sair |
| 8 | Dois espaços no mesmo lugar no fim do parágrafo: o 2º sumia | Um embaixo do outro |
| 9 | A falha da repaginação ficava sem tratamento | Mostra o aviso, como numa falha ao virar página |
| 10 | Com o Espaço, o poço não abria painel | Abre o da última ferramenta de tinta |
| 11 | Na volta do batente, os botões da nota pulavam | Andam com a página |

## O que mudou do desenho

Nenhuma decisão mudou sem você. Os desvios estão na seção "Desvios" do `G18.md`:
- a D-169 vale também para a nota à mão nas pranchas de antes da sessão (ela conta e não aparece);
- o anel do toque fica escondido com o Espaço, porque o dedo do abridor já é o indicador;
- a íris da 24b é preenchida em fileiras, não em espiral;
- a menor caixa da tinta da 24b é de 3 linhas;
- o Desfazer aparece esmaecido ao abrir o modo, porque não há passos ainda;
- na página do modo, o espaço que não cabe fica no pé dela (no leitor limpo ele vai para a página seguinte, R12);
- a nota cheia (256 KiB) não aceita mais traços: o traço some ao soltar.

## Pendências

- **Abrir o livro com nota no capítulo:** a página aparece um instante sem a caixa e logo depois o texto desce (as
  notas chegam depois do 1º layout). Para tirar isso, o livro precisa ler as notas antes de montar a 1ª página.
- **Latência no celular:** pendente da G16. Com o celular no cabo, eu rodo a medição: uns 20 traços seus no modo
  anotação.
- **Achado 17 da G17:** no Noite, traços do Marca-texto de cores diferentes que se cruzam (D-180).
- **O Laço da prateleira no Noite:** fica para o design.
- **G26, no celular:** TalkBack e VoiceOver no abridor, na caixa e na faixa, e a caneta do aparelho na nota.

✅ FASE G18 concluída — aguardando sua aprovação para iniciar a FASE G19.
