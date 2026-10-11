# Relatório da FASE G14 — Tela 26: ajustes de leitura (Aa)

Data: 06/10/2026 · branch `feat/g14-ajustes-leitura` (a partir de `feat/g13-selecao-grifos`, `515d6a3`) · nada
enviado ao GitHub. Evidências de cada subfase: `docs/progresso/G14.md`.

Decisões usadas (respondidas por você em 06/10, antes do código):
- O texto do livro usa os arquivos completos das 4 fontes, no app e sem internet (D-18).
- Tamanhos, entrelinhas e margens da D-20 (Q10).
- A folha fecha pelo ×, pelo Voltar, tocando na página de cima ou puxando pela alça (D-141), e volta aos controles
  (D-142).
- No Noite, a folha usa as cores das ilhas; os cartões de papel ficam nas cores de cada papel (D-143).
- As regras derivadas do desenho (D-144).

Respondidas depois da revisão independente:
- Numa tela baixa, a folha para abaixo da pílula e o conteúdo rola por dentro (D-145).
- Se a repaginação falhar, o ajuste fica gravado e o leitor mostra o erro de leitura, como hoje (D-146).
- A legenda da Atkinson é "baixa visão", no lugar do "dislexia" da prancha (D-147).
- O toque soma ao ajuste que chegou de outro aparelho (D-148).

## Resultado

| Subfase | Entrega | Prova |
|---|---|---|
| G14.1 Fontes | Lora, Figtree e Atkinson no texto do livro, com itálico e negrito dos arquivos; letras que faltam vindas da Literata; área do grifo por fonte; cache por fonte | `fontes_livro_g14_test`, `reader_fonts_g14_test`, `page_text_geometry_test` |
| G14.2 Aplicar | Cada toque grava com versão e repagina no caractere que se lia; só o papel troca a cor sem repaginar; último claro do Tema; fila; falhas | `reader_session_controller_test` (grupo G14), `epub_reader_document_test` |
| G14.3 Folha | Título, tamanho (A, trilho, arrasto, leitor de tela), fonte, papel, entrelinha, margens, pílula e a página de cima até o corte | `reader_settings_sheet_test`, `g14_primitivos_test`, `fontes_leitor_g14_test` |
| G14.4 Tela | "Aa Fonte" abre a folha; ×, Voltar, toque e arrasto fecham e devolvem os controles; Noite; PDF não abre | `reader_screen_g14_test`, `reader_screen_g12_test` |
| G14.5 Verificação | Fase L26, golden, revisão independente com correções, mutação, cobertura, gitleaks e capturas | Abaixo |

Números finais:
- `flutter analyze` sem problemas.
- `flutter test`: **1.822 verdes** (+7 pulados, os mesmos da G13; eram 1.739 no fim da G13).
- **Fase L26** (a tela 26 pela rota real, no mundo da tela 26, com "Aa Fonte" tocado): 5/5.
  - os 83 ids da página, da pílula e da folha na posição e no tamanho certos;
  - as 14 linhas da prévia (6 à vista e 8 atrás do papel do corte) e os textos da folha, com as baselines;
  - cores, bordas, raios, sombras duras e fontes;
  - leitor de tela: o diálogo, a prévia, os botões, o controle deslizante e os grupos com as opções marcadas;
  - os ajustes mostrados são os da linha do mundo, lidos do banco.
- **Golden @3x** contra a prancha: **0,147 %** de diferença (limite 0,5 %). Era 0,106 % antes da D-147; o resto é a
  legenda "baixa visão".
- **Cobertura** dos arquivos mexidos na fase: **98,3 %**. O menor é a sessão (96,0 %): faltam caminhos de falha
  antigos e a falha de uma repaginação (D-146), que só acontece com o livro solto no meio dela.
- **Mutação:** **42/42** trocas derrubadas pelos testes: as regras das fontes, dos ajustes e da folha, cada
  correção da revisão e as D-145, D-147 e D-148. Uma troca caía só por compilação; refeita, também foi pega pelo
  comportamento.
- **gitleaks:** os 20 commits da fase e as pastas tocadas, sem vazamento.

## Capturas

Mandadas nesta conversa e guardadas em `tools/medicao/tmp/capturas_g14/` (fora do git):
- a folha em Creme e no Noite;
- a página nas 4 fontes;
- os tamanhos 1 e 7, Justo e Solto, Estreita e Larga;
- o lado a lado com a prancha e o recorte dos cartões de fonte com "baixa visão".

## Revisão independente

Um agente separado leu tudo sem editar e fez **14 achados de código** e **5 sobre testes**. Quatro viraram perguntas
para você (D-145 a D-148). Corrigi os técnicos com teste nos commits `fc98d78`, `cd37bd3`, `8adbc53` e `8bbf83b`; as
suas respostas entraram em `2f39427` e `a036c35`. Os principais:

| # | Achado | O que fiz |
|---|---|---|
| 1 | A troca de cor deixava escapar o erro quando o livro saía no meio ("Tentar de novo") | A falha vai para o caminho das viradas |
| 2 | Um toque no trilho logo depois de outro se perdia; "aumentar" duas vezes no leitor de tela andava um passo só | Vale o último toque; o leitor de tela soma |
| 3 | O grego do negrito da Atkinson ganharia negrito sintético | **Não se confirmou** (a imagem já era a da Literata em 700); o teste ficou como guarda |
| 4 | Setas e as linhas ′ ″ vinham do sistema na Lora, Figtree e Atkinson | A Literata base vem antes dos subconjuntos |
| 6, 8 | Falha ao guardar o último claro desfazia o ajuste; a sessão reaberta no meio da gravação perdia o ajuste | O ajuste vale e vai para o livro de agora |
| 7 | Trocar o papel no meio de uma repaginação segurava a fila | Vai junto com a repaginação |
| 9 | O toque apagava o ajuste que chegou de outro aparelho | D-148 |
| 10, 11 | A pílula não deixava o toque fechar; o empurrão para cima fechava | Corrigidos |
| 12 | O título não era cabeçalho e os rótulos repetiam os grupos no leitor de tela | Corrigido |

Os outros (incluindo os aceitos e as pendências) estão em `G14.md`, seção "Revisão independente".

## O que mudou do desenho

Nenhuma decisão mudou sem você. Mudou a forma, registrada em `G14.md` (seção "Desvios"):
- **Legenda da Atkinson (D-147):** a L26 confere "baixa visão" no mesmo centro e na mesma linha de base da prancha.
- **Prévia da L26:** a prancha corta o parágrafo em "dias de ressaca."; no livro ele continua. A L26 mede as 14
  linhas da prancha e confere a 14ª pelo começo.
- **Plano:** o lugar da folha, o tamanho e as opções foram feitos num ciclo só, porque a folha só monta com as três.

## Pendências

- **Tablet:** um limite de largura para a folha (fase de tablet).
- **Desempenho:** os caches de área do texto e de páginas crescem com as combinações de ajustes; as imagens não são
  decodificadas de novo ao trocar a margem.
- **Sincronização ao vivo:** o ajuste de outro aparelho entra no próximo toque ou ao reabrir; a sessão não escuta a
  linha.
- **G26 (no celular):** o arrasto da alça, a rolagem numa tela baixa, TalkBack e VoiceOver na folha.
- **Fora da G14, como combinado:** a tinta que acompanha a fonte (G16/G17), o sumário e as Marcadas (G15).

✅ FASE G14 concluída — aguardando sua aprovação para iniciar a FASE G15.
