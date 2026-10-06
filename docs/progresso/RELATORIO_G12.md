# Relatório da FASE G12 — Telas 20 e 26b: controles, chip de tempo, marcador, tema Noite e busca

Data: 06/10/2026 · branch `feat/g12-controles` (a partir de `feat/g11-leitor-limpo`, `78d2b29`) · nada enviado ao GitHub.
Evidências de cada subfase: `docs/progresso/G12.md`.

Decisões usadas (respondidas por você em 06/10, antes do código):
- Os controles abrem no toque no centro e ficam até fechar: tocar fora das ilhas, arrastar ou o Voltar (D-117).
- Fonte, Grifos, Anotar e Sumário mostram "Chega numa próxima fase" por 2 s (D-118).
- Salto pela barra ou pela busca mostra "← Voltar à pág. N", com as regras do link (D-119).
- Busca de tela inteira, sem acento e sem maiúsculas; tocar marca a palavra com a `brand` (D-120).
- Tema alterna o último papel claro e o Noite, gravado na conta, em 220 ms, sem repaginar (D-121).
- PDF: Fonte cinza, Tema só em volta da página, tempo por páginas × 1.500 caracteres (D-122).
- Livro físico vai à página do livro; no leitor, "Este livro é físico: não tem arquivo para ler aqui." (D-123).
- Regras derivadas: ilhas com o aparelho, contador, chip, véu, cores do Noite (D-124).

Respondidas depois da revisão independente:
- O prazo da pílula (6 s e 2 viradas) só conta com ela à vista; com os controles ou a busca por cima, para (D-125).
- Saltos seguidos mantêm a volta para antes do 1º salto; o prazo recomeça a cada salto (D-126).
- No Noite, a palavra marcada fica escura sobre a `brand` viva, sem refazer a página (D-127).
- Busca que falha: "Não deu para buscar no livro agora." (D-128).

## Resultado

| Subfase | Entrega | Prova |
|---|---|---|
| G12.1 Tokens | Cores das ilhas nos papéis claros e no Noite, sombra com cor, estado de alternância, ícones `_noite` e a fita desmarcada, Bricolage 17/800, o "≈" (D-54) | `reader_chrome_palette_test`, `g12_primitivos_test`, `leitor_svgs_test` |
| G12.2 Dados e sessão | Ilhas lidas do banco (título, autor, fita, contador, minutos, tempo restante), salto por página com volta, marcador, Tema da conta e o livro físico (D-123) | `reader_chrome_test`, `reader_session_controller_test`, `inicio_estados_test` |
| G12.3 Controles | Véu, ilha de cima, chip de tempo, ilha de baixo (barra com balão, progresso, ferramentas), aviso provisório, Voltar, PDF e leitor de tela | `reader_screen_g12_test`, `scrubber_test`, `bottom_island_test`, `islands_test` |
| G12.4 Busca | Busca do EPUB num isolate e do texto do PDF; painel com grupos por capítulo, trecho e a palavra marcada na página | `book_search_test`, `book_search_document_test`, `book_search_panel_test` |
| G12.5 Verificação | Fases L20a, L20b, L20c e L26b, goldens, revisão independente com correções, mutação, cobertura, gitleaks e capturas | Abaixo |

Números finais:
- `flutter analyze` sem problemas.
- `flutter test`: **1.595 verdes** (+7 pulados, os mesmos da G11; eram 1.438 no fim da G11).
- **Fases L20a, L20b, L20c e L26b** (a tela pela rota real, no mundo de referência, controles abertos):
  - os 45 ids da prancha na posição e no tamanho certos, em Creme e no Noite;
  - linhas, baselines e bordas dos textos das ilhas, do chip e do balão;
  - cores, bordas, raios, sombras duras e fontes;
  - leitor de tela: os rótulos do arquivo, a fita marcada e "página 159 de 256";
  - 159, 256, 62 %, "18 min hoje" e o contador 12 calculados do mundo, nunca escritos.
- **Goldens @3x** contra as pranchas: **0,0 %** de diferença na 20 e na 26b (limite 0,5 %).
- **Cobertura** dos arquivos mexidos na fase: **97,9 %**. O menor é o `main.dart` (62,1 %), onde a G12 só acrescentou os ícones do leitor ao pré-carregamento; entre os do leitor, o menor é o `reader_chrome` (93,1 %).
- **Mutação: 56/56** trocas derrubadas pelos testes. Elas cobrem cada regra de D-117 a D-128, as medidas e cores da prancha e cada correção da revisão.

  Duas trocas sobreviveram na 1ª rodada, e reforcei os testes:
  - **Onda sem traço:** na prancha, o traço fica sob o botão da barra, então o golden não o vê. Agora um teste confere o que o pintor desenha.
  - **Abrir no Noite passando pelo Creme:** o teste só começava a olhar depois de a abertura assentar. Agora ele lê o papel em todos os quadros.
- **gitleaks:** os commits da fase e as pastas tocadas sem vazamento. Um falso positivo foi registrado no `.gitleaksignore`: a regra genérica de chave casava com a chave de widget `'r20.bottomIsland'` no plano.

## Capturas

Mandadas nesta conversa e guardadas em `tools/medicao/tmp/capturas_g12/` (fora do git):
- a tela 20 em Creme, Branco e Sépia, e a 26b no Noite;
- a barra arrastando, com o balão em outra página;
- o painel da busca e a palavra marcada na página, em Creme e no Noite (D-127);
- o PDF com os controles (Fonte cinza);
- o lado a lado com as pranchas (`build/visual_diff_g12/`).

## Revisão independente

Um agente separado leu tudo sem editar e fez **28 achados**: 1 alto, 11 médios e 16 entre médio-baixos e baixos. Quatro viraram perguntas para você (D-125 a D-128). Corrigi os técnicos com teste nos commits `72d8a91`, `ed0be8e`, `35c7c3c` e `f49cb63`; poucos ficaram como pendência. Os principais:

| # | Achado | O que fiz |
|---|---|---|
| 1 (alta) | No PDF, a marca da busca ficava coberta pela imagem da página | A marca vai por cima da imagem, multiplicada |
| 2 | No Noite, os botões da barra de navegação do Android ficavam escuros sobre o papel escuro | Ícones claros também embaixo |
| 3 | Abrir um livro no Noite dava um clarão Creme | O papel da conta chega antes da página; o Tema só anima depois |
| 4 | Tocar no botão da barra saltava uma página | O botão fica na página mostrada |
| 5 | Uma falha do banco no Tema derrubava a leitura | Só relata; o papel fica como estava |
| 6 | Em tela grande, a barra caía uma página antes e o passo do leitor de tela travava | Pedir a página seguinte sempre anda |
| 7 | Ícone esmaecido pintava numa camada (proibida no app) | O ícone com filtro é desenhado como imagem |
| 8 | Busca com erro aparecia como "Nada encontrado" | D-128, e a falha é relatada |
| 9, 10, 27 | Prazo da pílula escondida, origem trocada em saltos seguidos, marca apagada no Noite | D-125, D-126, D-127 |
| 12, 20 | Hífen discreto e espaço especial atrapalhavam a busca; a lista piscava | Ignorados na busca; a lista anterior fica até chegar a nova |

Os outros estão em `G12.md`, seção "Revisão independente".

## O que mudou do desenho

Nenhuma decisão mudou sem você. Mudou a forma, registrada em `G12.md` (seção "Desvios"):
- **Salto por página:** o documento ganhou "ir à página de referência" e "fim do livro". O tempo restante some na última página, mesmo quando ela é curta.
- **Botão da barra:** fica pela página mostrada, não pelo % de caracteres.
- **Dados das ilhas:** releitura quando as tabelas mudam, em vez de consultas vivas.
- **Marca no Noite (D-127):** duas camadas de cor combinadas fazem a palavra ficar escura sem refazer a página.

## Pendências

- **Para você confirmar:** num livro **sem sumário**, os resultados da busca vêm num grupo só, com o **título do livro**. Antes saía "Começo do livro". Se preferir outro título, troco.
- **Comportamento conhecido:** o resultado mostra a página do caractere achado. Depois do salto, o rodapé mostra a do começo da página da tela, que pode ser uma antes.
- **Busca:** manter um isolate por livro (hoje cada busca reabre o arquivo) e parar a busca ao escolher um resultado.
- **G26 (no celular):**
  - o alvo de toque da barra (26 px de altura);
  - com TalkBack e VoiceOver, o anúncio e o foco ao abrir os controles;
  - a barra de navegação no Noite com os 3 botões do Android.
- **Fora da G12, como combinado:**
  - a folha "Aa" (G14);
  - o sumário e as Marcadas (G15);
  - a seleção e os grifos (G13);
  - o modo anotação (G16+);
  - a tela de grifos (G19).

✅ FASE G12 concluída — aguardando sua aprovação para iniciar a FASE G13.
