# Relatório da FASE G11 — Tela 19: leitor limpo (+ tokens dos 4 papéis)

Data: 06/10/2026 · branch `feat/g11-leitor-limpo` (a partir de `feat/g10-paginacao`, `bfcbe20`) · nada enviado ao GitHub.
Evidências de cada subfase: `docs/progresso/G11.md`.

Decisões usadas (respondidas por você em 06/10, antes do código):
- Literata variável só no texto do livro; a interface segue com as estáticas (Q22 → D-104).
- Barra de status escondida no leitor limpo (D-105).
- Até a G12, o toque no centro mostra só o círculo "Fechar o livro" (D-106).
- A página segue o dedo: 1/4 da largura ou 300 px/s, 220 ms `easeOutCubic`, batente no começo e no fim (D-107).
- Links internos com "← Voltar à pág. N" por 6 s ou 2 viradas (D-108).
- PDF básico: página inteira na largura − 8 px, sem zoom, grifo e tinta (D-109).
- Cor do rodapé por papel (D-110); tela acesa por 120 s depois do último toque (D-111); áreas do aparelho (D-112); regras derivadas (D-113).

Respondidas depois da revisão independente:
- Imagens do EPUB já na G11 (D-114).
- Fechar com a pílula valendo grava a página de onde se saiu (D-115).
- Com leitor de tela, a pílula fica até as 2 viradas e é anunciada; a página ganha "Fechar o livro"; "Abrindo" e erros são região viva (D-116).

## Resultado

| Subfase | Entrega | Prova |
|---|---|---|
| G11.1 Tokens | Cores dos 4 papéis e do rodapé (D-110), estilo do rodapé com números tabulares, Figtree 800 de verdade para as telas do leitor, áreas do aparelho (D-112) e a cor `brand` guardada no aparelho para o app todo (D-33) | `reader_palette_test` (papéis e áreas com aparelhos reais), `brand_preference_test` |
| G11.2 Documento e sessão | Página pronta para a tela (texto, link conferido no desenho das letras), página vizinha sem virar, documento EPUB aberto na posição com números, virada e links. Sessão de leitura: abre o livro da estante, mostra os 5 erros da D-21, grava a posição, conta o tempo e liga a tela acesa | `reader_session_controller_test`, `epub_reader_document_test`, `book_pager_test` |
| G11.3 Tela 19 | Rota real `/leitor/:bookId` aberta pela Início. Página, rodapé "pág. X de Y · %", toque nos terços, arrasto (D-107), fechar provisório, pílula do link, "abrindo" depois de 300 ms, erros, barra de status, Voltar, ciclo de vida e leitor de tela | `reader_page_view_test`, `reader_screen_test`, `router_test` |
| G11.4 PDF básico | PDF página a página pelo PDFium, encaixado na largura e centralizado; pág. = página do PDF; % pelo começo da página; posição própria (`PdfLocator`) | `pdf_reader_document_test` com A4, carta e A4 deitada |
| G11.5 Verificação | Fase L19, golden, revisão independente com correções, imagens (D-114), mutação, cobertura, gitleaks e capturas | Abaixo |

Números finais:
- `flutter analyze` sem problemas.
- `flutter test`: **1.438 verdes** (+7 pulados, os mesmos da G10; eram 1.313 no fim da G10).
- **Fase L19** (a tela 19 pela rota real, no mundo de referência):
  - os 5 ids da prancha na posição e no tamanho certos;
  - as 19 linhas iguais às do arquivo (texto, baseline e bordas ±0,5 px);
  - papel, cor e letra do texto e do rodapé;
  - "Dom Casmurro, página 159 de 256" para o leitor de tela;
  - 159, 256 e 62 % calculados pelo livro, nunca escritos.
- **Golden @3x** contra a prancha: **0,19 %** de diferença (limite 0,5 %).
- **Cobertura** dos arquivos mexidos na fase: **95,8 %**. A tela e a página estão em 99,3 %; o menor é o livro aberto, com 91,6 %.
- **Mutação: 51/51** trocas derrubadas pelos testes:
  - terços, 1/4, 300 px/s, batente, 220 ms, `easeOutCubic`;
  - link antes dos terços; pressão longa sem ação;
  - 4 s, 6 s, 2 viradas, 120 s;
  - áreas do aparelho, barra de status, margem e % do PDF, cores do rodapé, `brand`;
  - livro de outra conta, páginas fixas, arquivo que mudou de pasta;
  - posição e tempo ao sair;
  - cada correção da revisão.

  Uma troca ("Tentar de novo" mostra "Abrindo" na hora) sobreviveu duas vezes: o teste procurava o texto "Abrindo o livro…", mas essa reabertura mostra "Preparando o livro…". Reforcei o teste.
- **gitleaks:** os commits da fase e as pastas tocadas sem vazamento.

## Capturas

Mandadas nesta conversa e guardadas em `tools/medicao/tmp/capturas_g11/` (fora do git):
- a tela 19 em Creme, Branco, Sépia e Noite;
- o "Indice" do Dom Casmurro depois do link, com "Voltar à pág. 1" no vão do rodapé;
- PDF em A4 em pé e deitada;
- uma página com imagem (D-114);
- o lado a lado com a prancha.

## Revisão independente

Um agente separado leu tudo sem editar: **1 achado alto, 11 médios e 12 baixos**. Três viraram perguntas para você (D-114, D-115, D-116). Corrigi os outros com teste (commit `de45724` e `83b7fe0`), menos um, que fica para a G14. Os principais:

| # | Achado | O que fiz |
|---|---|---|
| 1 (alta) | Se o capítulo seguinte não abrisse, a página travava para sempre ou o livro "acabava" ali, sem aviso | A página nunca fica presa; o capítulo que não abre mostra "O arquivo pode estar danificado" |
| 3 | Segurar o dedo e soltar virava a página | Pressão longa não faz nada (D-113) |
| 4 | O leitor de tela achava um nó sem nome cobrindo a tela, e o toque duplo voltava uma página | Só o nó da página, com as ações |
| 6 | Num celular de 360 px, a pílula cobria parte do "pág. X de Y" | A pílula fica no vão medido entre os dois textos |
| 7 | Arrastar da borda esquerda fechava o livro (iOS) | Só o Voltar e o "Fechar o livro" fecham |
| 8 | Tocar no link e logo virar misturava as duas coisas | Uma coisa de cada vez |
| 16 | A tela acesa religava sozinha em segundo plano | Liga só com a página aparecendo, toques e a volta ao app |
| 18–20 | PDF: duas viradas rápidas perdiam uma; PDF trocado abria na página antiga | Viradas em fila; arquivo trocado abre pela % |

Os outros estão em `G11.md`, seção "Revisão independente".

## O que mudou do desenho

Nenhuma decisão mudou sem você. Mudou a forma, registrada em `G11.md` (seção "Desvios"):
- **Testes da tela:** a fila de layout roda na prioridade de animação; o app usa a ociosa, como na G10.
- **L19:** abre o Dom Casmurro inteiro do mundo, com o índice da tela 19.
- **Pílula:** o vão entre "pág." e "%" é medido, para o rodapé não se mexer.
- **Voltar do sistema:** passa pelo mesmo caminho do "Fechar o livro".
- **Imagens:** pedidas pela página que vai ser pintada, com um limite de memória de 48 MB.

## Pendências

- **G14:** repaginar quando a tela muda de tamanho (tela dividida, dobrável, giro) e ligar a folha de ajustes.
- **G26 (no celular):**
  - conferir com TalkBack e VoiceOver a pílula anunciada, os avisos e o "Fechar o livro";
  - o Voltar por gesto do Android e o arrastar da borda no iOS;
  - a memória das imagens.
- **Pergunta para você:** um livro **físico** aberto pelo cartão "lendo" da Início hoje mostra "O arquivo deste livro não está mais no aparelho." Quer outro texto, ou a Início não deve abrir o leitor para livro físico?
- **Fora da G11, como combinado:** zoom, links, grifo e tinta no PDF.

✅ FASE G11 concluída — aguardando sua aprovação para iniciar a FASE G12.
