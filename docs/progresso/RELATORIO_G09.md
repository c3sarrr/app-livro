# Relatório da FASE G09 — Importação e conteúdo canônico

Data: 05/10/2026 · branch `feat/g09-importacao` (a partir de `feat/g08-inicio`, `f3b7072`) · nada enviado ao GitHub.
Evidências de cada subfase: `docs/progresso/G09.md`.

Decisões usadas (respondidas por você em 05/10, antes do código):
- Sem acervo de domínio público agora (Q11 → D-86).
- Entrada pela Biblioteca mínima + "Abrir com" (D-87).
- "Novo" nos 7 primeiros dias (D-88).
- Página de referência a cada 1.500 caracteres (Q23 → D-89).
- Capa do arquivo primeiro (D-90).
- ISBN só no aparelho e no Worker do catálogo (D-91).
- EPUB de páginas fixas: guarda e avisa (D-92).
- Regras derivadas, aprovadas com o desenho (D-93).

## Resultado

| Subfase | Entrega | Prova |
|---|---|---|
| G09.1 EPUB por dentro | Leitor de ZIP próprio, com limites contra arquivo malicioso e CRC. Pacote OPF de EPUB 2 e 3: título, autores, língua, ISBN, capa, sumário, páginas fixas. Proteção (Adobe, LCP, `encryption.xml`), com a ofuscação de fonte liberada. XHTML vira blocos com o CSS do livro e o **texto canônico** (NFC, `\n` entre blocos, imagem = U+FFFC, `<br>` = U+2028). Roda num *isolate* | 44 testes, inclusive o Dom Casmurro real do Gutenberg |
| G09.2 Índice e páginas | `book_content_index`: itens, caracteres, sumário com a posição de cada entrada, páginas de referência (page-list da edição, senão a cada 1.500 caracteres; no PDF, as páginas do PDF), capítulos | `book_index_test` (13) |
| G09.3 Âncoras | Citação (trecho + 32 caracteres em volta) e reancoragem pelo Anexo 03 §5.3. Marcações nunca são apagadas | `anchoring_test` (14), com a propriedade de 1.000 edições; `mundo_epub_test` (2) |
| G09.4 Importar | EPUB e PDF pelo botão e pelo "Abrir com"/"Compartilhar". Cópia com SHA-256, mesmo arquivo não duplica, título/autor/capa do arquivo, ISBN no catálogo (só aparelho e Worker, até 4 s), índice em segundo plano. Nenhuma falha deixa arquivo ou linha pela metade | `book_importer_test` (17), `pdf_inspector_test` (5, com o PDFium de verdade), `import_privacy_test` (1) |
| G09.5 Na tela | Aba Biblioteca com "Traga seus livros em EPUB ou PDF." e o botão **Importar livro (EPUB ou PDF)**, o "Importando…" e o aviso de cada resultado. O "Abrir com" leva à Biblioteca de qualquer aba. Na Início, "Novo" nos 7 primeiros dias e a capa do próprio arquivo | `library_import_test` (9), `local_home_repository_test`, `cover_store_test`, `local_library_test` |

Números finais:
- `flutter analyze` sem problemas.
- `flutter test`: **1.230 verdes** (+6 pulados, como antes; eram 1.117 no fim da G08).
- **Dom Casmurro** (Gutenberg 55752, 222 KB): 395.352 caracteres, **264 páginas** de referência (a meta era ≈ 256), 153 entradas no sumário, índice em 0,7–0,8 s no *isolate* (PC, modo de teste). O orçamento de 2 s no celular será medido na G26.
- **Reancoragem** (1.000 edições sorteadas de um trecho real, semente fixa): **760/760 (100 %)** quando o trecho exato sobrevive (meta ≥ 99 %). Quando o trecho é mudado: 224/240 achados, 222 no intervalo certo.
- **Mundo de referência:** o EPUB montado com os capítulos da fixture dá o mesmo texto canônico, e as 12 anotações, a posição de leitura e os 3 marcadores caem exatamente no lugar.
- **Privacidade (§4.3.7):** pela montagem real do app, importar um EPUB com ISBN manda só `GET /v1/isbn/<isbn>` ao Worker. Título, autor, nome do arquivo, conteúdo e o resto da estante ficam no aparelho; sem ISBN (ou PDF), nenhum pedido; comunidade e consulta externa nunca são chamadas.
- Mutação: **33/33** trocas derrubadas pelos testes. Exemplos: limites e CRC do ZIP, NFC, `display:none`, `<br>`, fronteira e tamanho da página, itens não lineares, capítulos, DRM, janela de ±2.000 e limite de 10 % da reancoragem, duplicado, PDF pelo conteúdo, "Novo" nos 7 dias, capa do arquivo e sha conferido, fila única. Também derrubaram as trocas de cada correção da revisão. A lista está em `tools/medicao/tmp/g09/mutacoes.json` (fora do git).
- Cobertura dos módulos novos (meta ≥ 85 % em domínio e aplicação):
  - reancoragem 88,1 %;
  - aplicação da importação 90,9 %;
  - domínio da biblioteca 96,5 %;
  - conteúdo do EPUB 88,5 %.
  - A cola com a plataforma fica abaixo (pasta do app, seletor do sistema, canal do "Abrir com": 83 % na camada de dados), porque só roda no aparelho.
- gitleaks: os commits da fase e as pastas novas (incluindo `android/` e `ios/`) sem vazamento.

## Revisão independente

Um agente separado leu tudo sem editar e encontrou **15 achados**: 1 alto, 6 médios e 8 baixos. **Todos foram corrigidos** (commit `f7a62fa`): os 13 do código Dart com teste, e os 2 do código nativo, que não compila aqui, com passo de teste no celular (abaixo). Os principais:

| # | Achado | O que fiz |
|---|---|---|
| 1 (alta) | Um EPUB pequeno com o mesmo capítulo repetido milhares de vezes esgotava a memória, e isso voltava a cada abertura | O spine ignora item repetido; o índice guarda só o texto; livro acima de 40 milhões de caracteres é recusado |
| 2 (média) | Página da edição sem lugar no texto virava "começo do capítulo" | Ela fica de fora; marcador de página escondido vale onde está |
| 3 (média) | O ZIP podia pôr na memória um tamanho comprimido mentiroso | Conferido antes de ler |
| 4 (média) | Um livro que falhava no índice travava os outros e era refeito a cada abertura | Cada livro isolado; o que não abre fica marcado |
| 5 (média) | Sobras de importação interrompida ficavam para sempre | Limpeza ao abrir (só do que tem mais de 1 hora) |
| 6–7 (média, iOS) | A cópia no Inbox ia para o backup do iCloud; o caminho do arquivo muda quando o app atualiza | O arquivo sai do Inbox; o índice acha o arquivo pelo nome |
| 14 (baixa) | A reancoragem tinha um passo a mais que o Anexo 03 | Agora segue os 4 passos do anexo |

Os outros (sumário aninhado sem fim, `id` de imagem, fronteira de página entre capítulos, botão e "Abrir com" ao mesmo tempo, Android reimportando pelos Recentes, disco cheio no banco, testes fracos) estão em `G09.md`.

## O que mudou do desenho

Nenhuma decisão mudou. Mudou a forma, e está registrado em `G09.md` (seção "Desvios"):
- leitor de ZIP próprio no lugar do `InputFileStream`;
- `xml` 7.0.1;
- busca aproximada por alinhamento de Sellers no lugar do bitap;
- formato das colunas JSON;
- página da edição sem lugar fica de fora;
- marca de "não abre" no segundo tempo;
- "Abrir com" do Android só com `content://`.

## Pendências

- **Compilar o nativo** (pendência de ambiente):
  - Android: o JDK desta máquina está quebrado, então o `MainActivity.kt` e o `AndroidManifest.xml` não foram compilados;
  - iOS: sem Mac, o `SceneDelegate.swift` e o `Info.plist` não foram compilados.
- **No celular** (quando você ligar):
  - Biblioteca → "Importar livro (EPUB ou PDF)" → escolher um EPUB: aparece "«Título» está na sua estante." e o livro entra na Início em Recém-chegados, com "Novo" e a capa do arquivo;
  - o mesmo arquivo de novo: "Esse livro já está na sua estante.";
  - um PDF: a capa é a 1ª página;
  - num gerenciador de arquivos, "Abrir com" → BookNest com o app na Início: o app vai para a Biblioteca e importa;
  - "Compartilhar" de 2 arquivos de uma vez: entram um depois do outro;
  - fechar o app, abrir de novo pelos Recentes: nada é importado outra vez;
  - um EPUB com DRM (comprado em loja): "Este arquivo tem proteção e não pode ser aberto.";
  - no iPhone (com o Mac, no Xcode → Devices → baixar o contêiner do app): depois de importar, `Documents/Inbox` fica vazio.
- **Leitor (G11):** abrir o arquivo também pelo nome na pasta dos livros, porque o caminho absoluto guardado em `local_files` muda no iOS depois de uma atualização. A G09 já faz isso no índice.
- **Nuvem do Pro:** o botão "Guardar na nuvem" continua esperando a tela do livro (pendência da G06).
- **Biblioteca:** a lista de livros e o acervo de domínio público (D-86) esperam o design das telas 01–18.
- **Eventos de uso** da importação (livro importado, falha por tipo) entram com a telemetria da G24.

✅ FASE G09 concluída — aguardando sua aprovação para iniciar a FASE G10.
