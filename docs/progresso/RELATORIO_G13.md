# Relatório da FASE G13 — Tela 21: seleção e grifos

Data: 06/10/2026 · branch `feat/g13-selecao-grifos` (a partir de `feat/g12-controles`, `c01582e`) · nada enviado ao
GitHub. Evidências de cada subfase: `docs/progresso/G13.md`.

Decisões usadas (respondidas por você em 06/10, antes do código):
- "Outra cor" mostra "Chega numa próxima fase" por 2 s até a G17; a seleção continua (D-129).
- Sublinhar usa a última cor, guardada no aparelho; amarelo se ainda não houver (D-130).
- Nota abre uma folha que sobe com o teclado; Salvar cria o grifo de fundo na última cor e a nota (D-131).
- Tocar num grifo abre a barra com a cor dele marcada; a cor marcada apaga, com "Grifo apagado · Desfazer" (D-132).
- No Noite, o grifo fica na cor viva e as letras escuras, sem refazer a página (D-133).
- PDF sem seleção nesta fase (D-134); a lupa do app (D-135); as regras derivadas do desenho (D-136).
- Mais as que já valiam: D-23, D-32, D-39, D-45 e D-47.

Respondidas depois da revisão independente e da suíte completa:
- Tocar num grifo mostra só a barra, sem alças nem o fundo da seleção (D-137).
- A Nota numa seleção nova que vai unir ou cobrir um grifo com nota abre com a nota que vai ficar (D-138).
- Com o leitor de tela, "Grifo apagado · Desfazer" fica até a próxima ação (D-139).
- Os grifos que vieram da tinta (o marca-texto à mão livre) ficam para a G16/G17 (D-140).

## Resultado

| Subfase | Entrega | Prova |
|---|---|---|
| G13.1 Página | Letra e palavra sob o dedo, caixas por linha com a linha de base, limite da página; pintura do grifo (faixa 12–92 %), da seleção (62 %) e do sublinhado (4 px), com o Noite | `page_text_geometry_test`, `page_snapshot_test`, `reader_page_view_test` |
| G13.2 Grifos do livro | Âncora com citação, página e capítulo; reancoragem; sobreposição da D-32 com as notas; trocar, apagar e desfazer; nota; última cor | `highlight_overlap_test`, `reader_annotations_test` |
| G13.3 Seleção | Pressão longa com vibração, alças por palavra e por letra com a lupa, limite da página, barra em cima, embaixo ou presa, Voltar e precedência dos toques | `selection_controller_test`, `selection_layer_test`, `highlight_toolbar_test`, `reader_screen_g13_test` |
| G13.4 Ações | Cores, Sublinhar, Outra cor, Nota, Copiar, Compartilhar, Buscar e o grifo existente com Desfazer | `reader_actions_test`, `note_sheet_test`, `reader_screen_g13_test` |
| G13.5 Verificação | Fases L21a e L21b, golden, revisão independente com correções, mutação, cobertura, gitleaks e capturas | Abaixo |

Números finais:
- `flutter analyze` sem problemas.
- `flutter test`: **1.739 verdes** (+7 pulados, os mesmos da G12; eram 1.595 no fim da G12).
- **Fases L21a e L21b** (a tela 21 pela rota real, no mundo da tela 21, com a seleção feita pelos gestos):
  - os 34 ids da prancha (12 da página e 22 da barra) na posição e no tamanho certos;
  - o grifo e a seleção conferidos linha por linha;
  - as 19 linhas da página e os textos da barra, com as baselines;
  - cores, bordas, raios, sombras duras e fontes;
  - leitor de tela: um só "Trecho selecionado" e os 10 rótulos da barra;
  - Copiar entrega, letra por letra, "“como a vaga que se retira da praia, nos dias de ressaca.” — Machado de
    Assis, Dom Casmurro (pág. 159)".
- **Golden @3x** contra a prancha corrigida: **0,12 %** de diferença na página e **0,03 %** na barra (limite 0,5 %).
  As telas 20 e 26b seguem em 0,0 %.
- **Cobertura** dos arquivos mexidos na fase: **98,5 %**. O menor é o `reader_actions` (78,6 %): as 3 linhas que
  faltam são a folha de compartilhar do sistema, trocada nos testes.
- **Mutação: 84/84** trocas derrubadas pelos testes. Elas cobrem cada regra de D-129 a D-140, as medidas da prancha e
  cada correção da revisão.

  Seis trocas sobreviveram na 1ª rodada, e reforcei os testes:
  - **Página da âncora:** nenhum teste tinha um grifo passando de uma página de referência para outra.
  - **Lupa sem os 300 ms:** o teste só olhava depois do prazo.
  - **Alça fora da página:** a página de teste já prendia o ponto sozinha.
  - **Arrasto que não fecha a seleção:** a virada fechava a seleção depois. Agora um arrasto curto que volta também confere.
  - **Lupa sem ampliar e sem recorte:** agora o teste confere a altura ampliada e uma letra que passaria da caixa.
- **gitleaks:** os commits da fase e as pastas tocadas, sem vazamento.

## Capturas

Mandadas nesta conversa e guardadas em `tools/medicao/tmp/capturas_g13/` (fora do git):
- a tela 21 em Creme e no Noite;
- a lupa;
- a barra embaixo da seleção;
- a folha da nota;
- a barra de um grifo existente (só a barra, com a cor dele marcada);
- "Grifo apagado · Desfazer";
- o lado a lado com a prancha (`build/visual_diff_g13/`).

## Revisão independente

Um agente separado leu tudo sem editar e fez **20 achados**: 1 alto, 7 médios, 8 entre médio-baixos e baixos e 4
sobre testes. Três viraram perguntas para você (D-137 a D-139); a suíte completa trouxe a D-140. Corrigi os técnicos
com teste nos commits `1da300a`, `130bd3b`, `d20237b` e `b0210ce`. Os principais:

| # | Achado | O que fiz |
|---|---|---|
| 1 (alta) | Uma nota numa seleção nova sobrescrevia, sem aviso, a nota do grifo que ela unia | D-138 |
| 2 | O Desfazer devolvia o grifo por cima de um grifo feito depois | O Desfazer some na próxima ação |
| 3 | Dois toques rápidos na cor marcada perdiam o Desfazer | Uma ação da barra de cada vez |
| 4 | As alças de um grifo existente mudavam o trecho, mas as ações agiam no grifo antigo | D-137 |
| 5 | A página vizinha entrava sem os grifos durante a virada | A vizinha vem com os grifos dela |
| 6 | Um grifo que passa da página fechava a barra sozinho e copiava só um pedaço | A barra fica; o texto é o do grifo inteiro |
| 8 | Compartilhar falhava calado no iPad | A folha sai do botão |
| 9, 12, 13 | A alça roubava o toque da barra; a lupa entrava na barra de status; arrastar mexia na seleção anterior | Corrigidos |
| 11 | Leitor de tela: Desfazer curto e a cor marcada sem dizer que apaga | D-139 e "Apaga o grifo" |
| 14 | Falhas que sumiam (cor, área de transferência, nota) e o limite de 10.000 contado de outro jeito que o banco | Relatadas; a folha fecha só se gravou |

Os outros estão em `G13.md`, seção "Revisão independente".

## O que mudou do desenho

Nenhuma decisão mudou sem você. Mudou a forma, registrada em `G13.md` (seção "Desvios"):
- **Arrastar sem soltar:** o plano crescia a seleção para os dois lados. O código seguiu o desenho (o começo fica —
  D-136), e o plano foi corrigido.
- **Pintura:** a página e a vizinha usam a mesma rotina; o fundo da seleção vem de uma vista que fica vazia no grifo
  existente.

## Pendências

- **Para você aprovar:** as regras que derivei das suas respostas, todas em `G13.md` ("Regras derivadas da revisão"):
  - trocar a cor de um grifo também une com um vizinho da mesma cor (D-32);
  - o Desfazer some na próxima ação também sem o leitor de tela;
  - a cor marcada diz "Apaga o grifo" ao leitor de tela.
- **Desempenho:** quando o arquivo do livro muda, achar o lugar dos grifos roda no 1º quadro do capítulo. Vai para
  fora da pintura numa fase de desempenho.
- **Sincronização:** dois grifos sobrepostos, vindos de aparelhos diferentes, são pintados um sobre o outro.
- **G16/G17:** os grifos da tinta (D-140), o seletor "Outra cor", as alturas e o Ondulado.
- **G19:** todas as notas de um grifo (a G13 mostra a mais antiga) e os grifos sem lugar (D-44).
- **G26 (no celular):** o toque das alças e da barra, a lupa, a vibração, o Compartilhar no iPad, TalkBack e
  VoiceOver.
- **Fora da G13, como combinado:** seleção e grifos no PDF (D-134) e seleção que atravessa páginas (D-47).

✅ FASE G13 concluída — aguardando sua aprovação para iniciar a FASE G14.
