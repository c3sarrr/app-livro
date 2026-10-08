# Relatório da FASE G17 — Telas 23 e 23b: painéis da caneta e do marca-texto

Data: 08/10/2026 · branch `feat/g17-paineis-caneta-marcatexto` (a partir de `feat/g16-modo-anotacao`, `137259f`) ·
nada enviado ao GitHub. Evidências de cada subfase: `docs/progresso/G17.md`.

Decisões usadas (respondidas por você em 08/10, antes do código):
- A prévia da 23b mostra as primeiras frases da página que cabem na linha, com o grifo na palavra mais longa da 1ª
  (D-171).
- As alturas do fundo seguem as amostras do painel: Baixa 50–92 %, Média 12–92 %, Alta 0–100 % da letra (D-172).
- A sobreposição da D-32 vale para todos os grifos, de seleção e à mão; unidos ficam com o jeito do mais antigo
  (D-173).
- A tinta quase preta (contraste abaixo de 1,5 : 1 com o papel do Noite) sai na cor das letras no Noite; o dado não
  muda (D-174).
- Favoritas em fileiras de 7, com "+", pressão longa para tirar e Desfazer (D-175).
- O hex se digita com o teclado e o painel sobe até o campo (D-176).
- "Editar rótulos" e "Outra cor" abrem folhas de baixo, como a da nota (D-177, D-178).
- As regras derivadas do desenho, R1–R27, e a R28 da revisão da spec: o desenho do Marca-texto na prateleira fica na
  cor dele (D-179).

Respondida depois deste relatório (08/10), para fechar o achado 12 da revisão:
- Grifos que se cruzam no Noite, **sem camada** (D-180): a regra 12.4 continua; cada fundo é recortado pela forma dos
  que vão por cima dele.

## Resultado

| Subfase | Entrega | Prova |
|---|---|---|
| G17.1 Cor | HSV, nomes, contraste (WCAG), a roda, o brilho, o hex e o `ColorPicker` | `hsv_test`, `color_names_test`, `color_picker_test` |
| G17.2 Sessão e painéis | Os ajustes das 2 ferramentas no `pen_presets`; o Marca-texto como ferramenta; abrir e fechar os painéis (R1–R7), o véu e a seta | `annotation_session_test`, `tool_panel_frame_test`, `annotation_mode_test` |
| G17.3 Painel da caneta (23) | Cabeçalho, prévia ampliada 17/11, pontas, espessura, favoritas (D-175), seletor com o hex (D-176) | `pen_panel_test`, L23 |
| G17.4 Marca-texto na página | O traço gruda nas palavras (≥ 50 %), a D-32 na sessão para todos os grifos (D-173), tinta translúcida na margem, Desfazer, Borracha, o Concluir na transação da tinta e o rascunho no formato 2; a tela 21 também com a D-173 | `marker_snap_test`, `highlight_desk_test`, `ink_changes_test`, `ink_repository_test`, `reader_annotations_test` |
| G17.5 Painel do marca-texto (23b) | Prévia (D-171), estilos, cores com rótulos e contagens (D-40), a folha "Rótulos" (D-177), altura, dica | `marker_preview_test`, `marker_panel_test`, `labels_sheet_test`, `highlight_labels_store_test`, L23b |
| G17.6 Pintura e Noite | Alturas (D-172), a mancha na altura, o ondulado medido no arquivo, D-174, achado 17, a folha "Outra cor" (D-178), os painéis no Noite | `page_marks_test`, `wavy_underline_test`, `ink_painter_test`, `other_color_sheet_test`, `reader_screen_g13_test` |
| G17.7 Prova | Mundo da 23; L23 e L23b; goldens; comportamento; revisão independente com correções; mutação; cobertura; gitleaks; capturas | Abaixo |

Números finais:
- `flutter analyze` sem problemas.
- `flutter test`: **2.429 verdes** (+7 pulados; eram 2.212 no fim da G16).
- **Fases L23 e L23b** (as telas pela rota real: "Anotar" e o 2º toque na Caneta, ou o Marca-texto e o 2º toque
  nele): **10/10**:
  - os ids no lugar e no tamanho certos (48 na 23, 53 na 23b);
  - as linhas nas baselines;
  - cores, bordas, sombras duras e fontes;
  - o leitor de tela;
  - os dados do banco (o subtítulo, o `pen_presets`, os rótulos e as contagens 5/3/2/2 da D-40).
- **Golden @3x** contra as pranchas: **0,21 %** (23) e **0,14 %** (23b), com limite de 0,5 %. O lado a lado foi
  conferido a olho.
- **Cobertura** dos arquivos mexidos na fase: **97,8 %**. O menor é o `page_marks.dart` (90,7 %); os 3 arquivos de
  tokens só têm constantes, sem linhas para medir.
- **Mutação:** **60/60** trocas derrubadas pelos testes. As trocas cobrem:
  - as regras numéricas;
  - as decisões D-171, D-173 e D-174, mais o achado 17;
  - as regras R1, R2, R4, R6, R18, R20, R22 e R28;
  - cada correção da revisão.

  Na 1ª rodada passaram 3; os testes ganharam o que faltava e as 3 caíram na 2ª. As 5 do fechamento dos achados 4, 8
  e 12 caíram na 1ª.
- **gitleaks:** os commits da fase e as pastas tocadas, sem vazamento.
- **Latência no celular:** continua pendente, da G16.

## Capturas

Mandadas na conversa e guardadas em `tools/medicao/tmp/capturas_g17/` (fora do git):
- as telas 23 e 23b em Creme e no Noite, e o lado a lado com as pranchas;
- o marca-texto ao vivo e depois de soltar;
- a D-32 com o marca-texto;
- as folhas "Rótulos" e "Outra cor";
- a tinta preta no Noite.

## Revisão independente

Um agente separado leu a fase inteira sem editar e fez **14 achados**: 4 defeitos, 3 riscos e 7 detalhes. Nenhum
dado sai do aparelho no Grátis.

Corrigi os 14 com teste, nos commits `917ab3f`, `574300b` e `44893b4`. Os testes novos falharam antes da correção,
menos o do toque simples no seletor, que guarda a R13. Os achados 4, 8 e 12 ficaram pela metade na 1ª entrega deste
relatório e foram fechados depois, no `44893b4` (o 12 pela D-180).

| # | Achado | O que fiz |
|---|---|---|
| 1 | A Borracha não alcançava o grifo à mão salvo em Sublinhado ou Ondulado | Ela passa a alcançar pelas palavras |
| 2 | As notas dos grifos que a D-32 encolheu ou estendeu ficavam com o lugar velho | Andam com o grifo, como na tela 21 |
| 3 | O grifo tirado sumia mesmo sem o destino das notas | O tirado fica, com as notas |
| 4 | No Noite, a página repintava a cada amostra de qualquer traço | Repinta só quando a tinta muda ou com o marca-texto ao vivo, sem regravar a tinta |
| 5 | Um traço que se juntava a um grifo antigo deixava os outros trechos num grupo inexistente | Os trechos ficam no grupo do grifo antigo |
| 6 | As prévias eram refeitas a cada quadro | Guardadas |
| 7, 8 | A folha "Rótulos" perdia o texto numa falha; os rótulos que não abriam travavam o modo; as contagens liam todos os grifos | A folha fica aberta; o modo abre com os nomes das cores; as contagens saem do banco (`COUNT … GROUP BY`) |
| 9, 10 | A caneta usava os nomes do marca-texto; favoritas repetidas derrubavam o painel | Só os 6 nomes da tela 23; a repetida não quebra |
| 11 | Um arrasto que virava rolagem gravava a cor do ponto | A cor de antes volta |
| 12 | O achado 17 cobria só parte dos casos (grifos sobrepostos de antes da D-173) | Sem camada (D-180): cada fundo é recortado pela forma dos de cima; o Marca-texto vai por baixo dos fundos |
| 13, 14 | A criação do grifo pela hora do Concluir; o caminho sem a mesa perdia o marca-texto | Corrigidos |

## O que mudou do desenho

Nenhuma decisão mudou sem você. Os desvios do arquivo estão na seção "Desvios" do `G17.md`:
- o "+" das favoritas aparece apagado na 23, porque o coral já é favorito (D-175);
- o Desfazer aparece apagado ao abrir o modo, porque não há passos ainda;
- a tinta antiga da 23b fica coral, como manda a D-59.
- no Noite, o Marca-texto vai por baixo dos fundos e das manchas, e a caneta e a Reta por cima de tudo (D-180).

## Pendências

- **Latência no celular:** pendente da G16. Com o celular no cabo, eu rodo a medição: uns 20 traços seus no modo
  anotação.
- **Achado 17:** no Noite, traços do Marca-texto de cores diferentes que se cruzam saem com a cor do cruzamento errada
  (sem camada, pela D-180). Os fundos, as manchas e o Marca-texto da mesma cor saem certos.
- **O Laço da prateleira no Noite:** fica para o design.
- **G26, no celular:** TalkBack e VoiceOver nos painéis, o teclado do hex e a caneta do aparelho.

✅ FASE G17 concluída — aguardando sua aprovação para iniciar a FASE G18.
