# Anexo 01 — Inventário de telas

> Parte do pacote `handoff_v2/` · versão 2.0 · 03/10/2026
> Fonte: `referencia/original/Redesign mobile — App de leitura (1).html` (bundle do Claude Design, 13 pranchas, título interno das páginas "… — BookNest").
> Prévias (NÃO medidas, só para orientação): `referencia/previa/*.png` (@2x, renderizadas no Chromium a partir do bundle).
> Marcação literal de cada prancha (sem as fontes base64): `referencia/extraido/<id>.body.html`.

## 0. Visão geral

| Nº no arquivo | id interno | Nome | Canvas | Estado do leitor |
|---|---|---|---|---|
| 00 | `inicio` | Início | 390 × 2390 | — (já entregue, F00–F13) |
| 01–18 | — | **não estão neste arquivo** | — | ver §15 |
| 19 | `reader_clean` | Leitor — modo limpo (e-book) | 390 × 844 | lendo, sem controles |
| 20 | `reader_controls` | Leitor — com controles | 390 × 844 | controles abertos (tema Creme) |
| 21 | `reader_selection` | Leitor — seleção de texto | 390 × 844 | trecho selecionado + barra de ações |
| 22 | `annotate` | Leitor — modo anotação | 390 × 844 | anotação, ferramenta Caneta |
| 23 | `annotate_pen` | Leitor — ajustes da caneta | 390 × 844 | anotação + painel da caneta |
| 23b | `annotate_marker` | Leitor — ajustes do marca-texto | 390 × 844 | anotação + painel do marca-texto |
| 24 | `annotate_space` | Leitor — abrindo espaço (arrastar) | 390 × 844 | anotação, ferramenta Espaço, arrastando |
| 24b | `annotate_note` | Leitor — nota à mão escrita | 390 × 844 | anotação, espaço aberto com nota à mão |
| 25 | `highlights` | Grifos e notas (Dom Casmurro) | 390 × **2170** | tela própria (rolagem) |
| 26 | `reader_settings` | Leitor — ajustes de leitura (Aa) | 390 × 844 | folha de ajustes + prévia ao vivo |
| 26b | `reader_controls_night` | Leitor — tema Noite (com controles) | 390 × 844 | controles abertos (tema Noite) |
| 27 | `toc` | Leitor — sumário | 390 × 844 | folha do sumário, aba Capítulos |
| 27b | `toc_bookmarks` | Leitor — sumário, aba Marcadas | 390 × 844 | folha do sumário, aba Marcadas |

**Props do componente (editáveis no Claude Design) — viram tokens/estado, não constantes soltas:**

| Prop | Telas | Padrão | Opções no arquivo |
|---|---|---|---|
| `paper` | 19–24b | `#F8F1E4` | `#F8F1E4`, `#F3E7CF`, `#FFFDF8` |
| `paper` (Noite) | 26b | `#1F1B17` | `#1F1B17`, `#14110E`, `#E3D9C6` |
| `brand` | 20, 22–27b (a 21 não tem a prop — D-51) | `#B6ACE4` | `#B6ACE4`, `#FFC1C6`, `#ABCF82`, `#FED170` (as mesmas da Início, D-11) |
| `ink` | 22 | `#FF552E` | `#FF552E`, `#552CB7`, `#058CD7`, `#00995E`, `#1A1714` |

**Fontes usadas nestas telas** (achados técnicos — tratamento na G01/G02):

- **Literata** (corpo do livro e citações) — fonte **variável** com eixos `opsz` 7–72 e `wght` 400–900. O navegador aplica `opsz = tamanho`. Tamanhos usados: 15, 15,5, 16, 16,5, 17, 18, 19, 20,5 (corpo do leitor), 25, 26. Pesos 400 e 500. Só o subconjunto *latin* está embutido; *latin-ext*, cirílico, grego e vietnamita apontam para a internet → para o conteúdo real dos livros é preciso a fonte completa (D-18).
- **Bricolage Grotesque** 800 — tamanhos novos 15,5, 17, 23 (além de 22, 26, 34 que já existem). Mesma regra de família por tamanho da Início.
- **Figtree** — **aqui o peso 800 é real**: o `@font-face` deste arquivo declara 800 sobre a fonte variável (eixo `wght` 300–900). Medido no Chromium: "Concluir Marcadas 148" a 40 px = 418,41 px em 700 e 423,48 px em 800. A regra D-14 da Início (800 → 700) **não vale** para estas telas (D-16).
- **Instrument Serif** itálico (títulos "Grifos *e notas*", "Ajustes *de leitura*", frase final da tela 25).
- **Lora** (variável `wght` 400–700) e **Atkinson Hyperlegible** (estática) — só nos cartões de fonte da tela 26 (opções do leitor).

**Cores novas (além das da Início):** papéis Creme `#F8F1E4` / Branco `#FFFDF8` / Sépia `#EEDDBF` / Noite `#1F1B17`; texto do livro `#2A2520` (Creme), `#1A1714` (Branco), `#4A3622` (Sépia), `#E3D9C6`/`#EDE3D1` (Noite); rodapé `#A89D8B`; grifos amarelo `#FED170`, rosa `#FFC1C6`, verde `#ABCF82`, lavanda `#B6ACE4`; tintas da caneta coral `#FF552E`, roxo `#552CB7`, azul `#058CD7`, verde `#00995E`, dourado `#F2A815`, preta `#1A1714`; seleção/alças `#552CB7`. A tabela exata sai da medição (G01) — estes valores servem de conferência.

**Ilhas e folhas (geometria do arquivo — conferir na medição):**
- Página do leitor: `article` absoluto `left/right 28`, `top 92`, `bottom 82`; parágrafo Literata 20,5 / `line-height 1.72` / `text-indent 1.3em` / cor `#2A2520` / alinhado à esquerda.
- No modo anotação a página desce: `top 116`, `bottom 0`, `padding-top 6` (comentário do arquivo: "nudged down; text is locked (no reflow) while drawing").
- Ilha inferior de controles: `left/right 14`, `bottom 30`, `padding 30 16 14`, raio 28, `#FFFAF1`, borda 1,5, sombra dura 3/3. No tema Noite: fundo `#2A2520`, borda `#EDE3D1`, sombra `#0B0A08`.
- Barra de anotação: `left/right 14`, `bottom 30`, altura 90, raio 26.
- Painéis da caneta/marca-texto: `left/right 14`, `bottom 190`, raio 26, sombra 4/4.
- Folhas (ajustes, sumário): `left/right 10`, `bottom 10`, raio `32 32 44 44`, sombra `0 4`; sumário com `top 112`.

---

## 1. Tela 19 — Leitor, modo limpo

**O que é:** a página do e-book sem nenhum controle. Rodapé discreto.

**Elementos (de cima para baixo):**
1. Página (`article`, rótulo "Dom Casmurro, página 159 de 256"): um parágrafo de Dom Casmurro, cap. XXXII ("Retórica dos namorados, dá-me uma comparação exata e poética … puxar-me e tragar-me.").
2. Rodapé (`left/right 28`, `bottom 40`): "pág. 159 de 256" à esquerda e "62%" à direita — Figtree 11,5 / 600 / `#A89D8B`, números tabulares (`font-variant-numeric: tabular-nums` → `FontFeature.tabularFigures()`).

**Interações (fora do arquivo → D-22):** toque no centro abre os controles (tela 20); toque nas laterais/arrasto horizontal vira a página; pressão longa numa palavra inicia a seleção (tela 21).

**Dados:** texto da página = layout do capítulo atual (Anexo 03); "pág. 159" = página de referência do primeiro caractere visível; "256" = total de páginas de referência do livro; "62%" = progressão (caractere global ÷ total).

**Armadilhas Flutter:** quebras de linha idênticas ao Chromium com `text-indent` (o Flutter não tem `text-indent` → `PlaceholderSpan` de 1,3 em no início do parágrafo; validar na G02/S3); `tabular-nums`; o parágrafo é cortado pela página (`overflow: hidden`) — no app real o corte é a paginação.

## 2. Tela 20 — Leitor com controles (Creme) · Tela 26b — idem no tema Noite

**O que é:** controles por cima da página, que esmaece ("page fades back while the controls are up"); o rodapé some.

**Ilha superior:** botão circular "Fechar o livro" (seta ←) · título "Dom Casmurro" + autor "Machado de Assis" · botão "Buscar no livro" (lupa) · fita de marcador coral "Página marcada" (`aria-pressed="true"`).

**Chip de tempo** (logo abaixo da ilha superior, sobre a página esmaecida — não encosta na ilha; amarelo `#FED170`, ícone de cronômetro): "18 min hoje · contando sozinho" — comentário do arquivo: "e-book time counts by itself".

**Ilha inferior ("Controles de leitura"):**
- Barra de posição (`role=slider`, `aria-valuenow=159`): trilho preenchido com a cor `brand` até o botão; o resto hachurado (mesmo padrão 135° da Início — reutilizar `HatchPainter`); botão redondo + balão preto "pág. 159".
- Linha de texto: "**62%** do livro · 256 pág." à esquerda; "≈ 2 h 10 min" à direita (tempo para terminar).
- 5 ferramentas (botão circular + rótulo): **Aa** "Fonte" → tela 26 · ☀ "Tema" (no Noite vira ☾) → alterna Creme ↔ Noite (D-37) · ✎ "Grifos" com contador amarelo **12** → tela 25 · "Anotar" (`aria-label="Anotar à mão"`) → tela 22 · "Sumário" → tela 27.

**Dados:** título/autor do livro; marcador da página atual (existe bookmark na página de referência atual?); minutos de hoje (soma das sessões de hoje, fuso do usuário, incluindo a sessão aberta); progresso; total de páginas; tempo restante (Anexo 03 §8); contador = total de anotações do livro (as 4 categorias da tela 25: 6 + 2 + 1 + 3 = 12).

**Tema Noite (26b):** papel `#1F1B17`, texto `#E3D9C6`; ilhas com fundo `#2A2520`, borda `#EDE3D1`, sombra `#0B0A08`; ícone do botão Tema = lua. Todos os tokens do tema Noite saem da medição — nada de "inverter cores" automaticamente.

**Armadilhas:** esmaecer a página é mudar a cor do texto/opacidade da camada da página (medir a cor resultante no PNG; a página continua no lugar); arrastar a barra mostra o balão e só vira a página ao soltar (D-22); a fita é um toggle (cria/remove bookmark — tela 27b).

## 3. Tela 21 — Seleção de texto

**O que é:** um trecho selecionado ("como a vaga que se retira da praia, nos dias de ressaca.") com alças roxas `#552CB7` e uma barra flutuante de ações sobre o texto; um grifo amarelo já existente ("aqueles olhos de Capitu").

**Barra de ações** (`role=toolbar`, "Ações para o trecho selecionado"):
- Linha 1: rótulo "GRIFAR" + 4 círculos de cor (amarelo `#FED170`, rosa `#FFC1C6`, verde `#ABCF82`, lavanda `#B6ACE4`) + "Escolher outra cor" (anel arco-íris) + "Sublinhar" (círculo com "a" sublinhado).
- Divisor.
- Linha 2: **Nota** (balão) · **Copiar** · **Compartilhar** · **Buscar**.

**Interações:** cor → cria grifo `style=fill` com a cor e fecha a barra; Sublinhar → grifo `style=underline`; outra cor → seletor de cor (o mesmo da tela 23, D-38); Nota → cria grifo + nota ligada (`parent_id`), abre editor de nota (não desenhado → D-23); Copiar → área de transferência com citação + referência (D-39); Compartilhar → `share_plus` com o texto e "— Machado de Assis, Dom Casmurro (pág. 159)"; Buscar → busca no livro pelo trecho (UI não desenhada → D-23).

**Dados:** seleção = intervalo de caracteres do conteúdo canônico; grifos existentes renderizados por baixo do texto.

**Armadilhas:** seleção própria (não usar `SelectableText` nem a barra do Material); alças e "lupa" desenhadas pelo design system; a barra aparece acima ou abaixo da seleção conforme o espaço (posição do arquivo = caso "acima"); o texto sob a barra fica oculto (a barra é opaca).

## 4. Tela 22 — Modo anotação (Caneta)

**O que é:** a página entra no modo de escrever à mão. Comentários do arquivo: "text is locked (no reflow) while drawing"; "two fingers drag the page up to write near the bottom"; "Tools: physical objects tucked behind the island; the active one pops up".

**Topo:** pílula "Modo anotação" (círculo amarelo com lápis) + subtítulo "2 dedos movem a página" · botão verde `#ABCF82` "✓ Concluir".

**Página:** deslocada para baixo (`top 116`), com anotações visíveis: grifo amarelo "olhos de Capitu" (marca-texto), elipse coral à mão em volta de "Olhos de ressaca?", sublinhado ondulado coral em "fluido misterioso", sublinhado duplo coral em "a vaga que se retira"; um indicador de toque (círculo lavanda com ponto coral) sobre o traço que está sendo feito; "borda de mesa" suave no fim da página.

**Prateleira de ferramentas** (`radiogroup` "Ferramentas de anotação", objetos físicos atrás da ilha; a ativa sobe): Caneta · Marca-texto · Borracha · "Laço — selecionar e mover traços" · "Linha reta" · "Espaço — arrastar entre as linhas para abrir lugar de escrever".

**Ilha ("Barra de anotação"):** rótulos Caneta (ativo, pílula `brand`) · Marcador · Borracha · Laço · Reta · Espaço; poço de cor ("Cor da caneta: coral. Toque para escolher qualquer cor" — anel arco-íris com a tinta atual no meio); espessura (`radiogroup`: Fina · **Média** · Grossa); Desfazer · Refazer.

**Interações:** 1 dedo/caneta desenha com a ferramenta ativa; 2 dedos movem a página; tocar de novo na ferramenta ativa abre o painel dela (telas 23/23b); Concluir salva e volta ao leitor.

**Dados:** camadas de tinta e grifos da página; ferramenta, cor e espessura atuais (`pen_presets`).

**Armadilhas:** latência de traço (Anexo 03 §9); rejeição de palma quando há caneta (stylus); a página não refaz layout durante o desenho; os objetos da prateleira são ilustrações (SVG do arquivo), não ícones.

## 5. Tela 23 — Ajustes da caneta

Painel (`role=dialog`, "Ajustes da caneta") que sai da caneta, com seta apontando para ela; a página esmaece.

- Título "Caneta" · subtítulo "Esferográfica · 1,2 mm · coral" · fechar (×).
- **Prévia do traço** numa faixa pautada (`role=img`, "Prévia do traço").
- **PONTA** (`radiogroup` "Tipo de ponta"): **Esferográfica** (ativa, fundo `brand`) · Tinteiro · Pincel — cada uma com amostra de traço.
- **ESPESSURA** "1,2 mm": slider com ponto pequeno/grande nas pontas, trilho hachurado.
- **COR** (`radiogroup` "Cores favoritas"): Coral (ativa) · Roxo · Azul · Verde · Dourado · Tinta preta · "+ Salvar a cor atual nas favoritas".
- **Roda de cores** ("tom e intensidade") + slider **BRILHO** (100) + campo hex "#FF552E" com amostra.

**Dados:** `pen_presets.pen_tip`, `pen_width_mm`, `pen_color`, `favorite_colors` (máx. 12).

**Armadilhas:** roda de cores HSV desenhada por `CustomPainter` (gradiente cônico + radial), não pacote de color picker; o slider de mm usa a conversão D-28; o subtítulo é derivado (tipo · mm com vírgula · nome da cor ou hex).

## 6. Tela 23b — Ajustes do marca-texto

Painel "Marca-texto" · subtítulo "Fundo · amarelo “lindo” · média" · fechar.

- **Prévia** com uma linha real da página: "Olhos de **ressaca**? Vá, de ressaca." com fundo amarelo em "ressaca".
- **ESTILO** (`radiogroup`): **Fundo** (ativo) · Sublinhado · Ondulado — cada um com a palavra "ressaca" no estilo.
- **CORES E RÓTULOS** + link "Editar rótulos": amarelo **lindo** "5 grifos" (ativo) · rosa **personagem** "3 grifos" · verde **ideia** "2 grifos" · lavanda **pro clube** "2 grifos".
- **ALTURA** (`radiogroup` "Altura do fundo"): Baixa · **Média** · Alta.
- Nota: "**Gruda nas palavras.** Mesmo torto, o traço encaixa na linha e acompanha se a fonte mudar."

**Dados:** `pen_presets.highlighter_*`; `highlight_labels` (cor → rótulo, **global do usuário**); contagens 5 + 3 + 2 + 2 = 12. **Atenção:** se a contagem fosse só do livro aberto, não bateria com a tela 25 (lá, Dom Casmurro tem 6 grifos: 3 amarelos, 1 rosa, 1 verde, 1 lavanda). A leitura coerente é: o rótulo é do usuário e a contagem é "grifos com esta cor em **todos** os livros" (D-40 — confirmar). A fixture inclui grifos em outros livros para os números baterem.

**Comportamento-chave ("gruda nas palavras"):** o traço livre do marca-texto vira **grifo ancorado no texto** (palavras sob o traço), com o estilo/altura escolhidos → acompanha a mudança de fonte (Anexo 03 §9.4).

## 7. Tela 24 — Abrindo espaço (arrastar)

Ferramenta **Espaço** ativa (subtítulo do topo muda para "Arraste entre as linhas"). O dedo começou entre duas linhas (costura roxa) e arrasta para baixo; a área aberta é hachurada roxa com bordas tracejadas, setas ⇣, rótulo vivo "↕ 3 linhas" (`role=status`, "Abrindo espaço: 3 linhas"); "height snaps to whole lines"; o texto de baixo desce.

**Dados/regras:** cria `ink_layers(kind='space', space_lines=n)` ancorado na posição de texto da costura; altura sempre em linhas inteiras do tamanho atual; mínimo 1 linha (máximo D-41).

## 8. Tela 24b — Nota à mão escrita

O espaço aberto virou uma caixa tracejada ("Nota à mão, depois de “Vá, de ressaca.”", `role=group`) com etiqueta amarela "✎ Nota à mão", botões "Recolher a nota" (˄) e "Apagar a nota" (lixeira), escrita à mão coral "ressaca = o mar / que puxa de volta" + desenho de olho + ondas, dica "puxe a alça para aumentar" e alça "Arrastar para mudar a altura do espaço". O texto de baixo continua depois da caixa.

**Dados:** `ink_layers` (`kind='space'`, `collapsed`, `strokes_b64`) + `annotations(kind='handwriting', ink_layer_id)`; o rótulo semântico do SVG ("ressaca = o mar que puxa de volta (escrito à mão)") NÃO vem de OCR no app real → usar rótulo genérico "Nota à mão" + data (D-31).

## 9. Tela 25 — Grifos e notas (canvas 390 × 2170, rola)

**Topo:** voltar ("Voltar ao livro") · botão pílula "⇪ Exportar" ("Exportar grifos e notas").
**Título:** "**Grifos** *e notas*" (Bricolage 34 + Instrument Serif itálico 42) + estrela decorativa; subtítulo "**Dom Casmurro** · na ordem do livro".
**Busca:** campo "Buscar nos grifos e notas".
**Tipo** (`radiogroup`, rola na horizontal — o 5º chip fica cortado): **Tudo 12** (ativo, `brand`) · Grifos 6 · Notas 2 · À mão 1 · Desenhos 3.
**Cor** (`group` "Filtrar por cor", caixas de seleção): "COR" + amarelo, rosa, verde, lavanda, tinta coral · interruptor **"Só do clube"** (ícone de pessoas).
**Lista** ("Grifos e notas na ordem do livro"), agrupada por página com separador "pág. N" + linha tracejada:

| Página | Cartão | Conteúdo |
|---|---|---|
| 3 | ● GRIFO (amarelo) · 2 set | "…encontrei no trem da Central um rapaz aqui do bairro," (contexto cinza) + **"que eu conheço de vista e de chapéu."** (grifo) |
| 6 | ● GRIFO (rosa) + NOTA · 3 set | "O meu fim evidente era atar as duas pontas da vida, e restaurar na velhice a adolescência." + post-it amarelo com fita: NOTA "É o livro todo nessa frase." |
| 41 | ● GRIFO (verde) · 8 set | "— A vida é uma ópera e uma grande ópera." |
| 121 | ● GRIFO (amarelo) · 15 set | "…olhos de cigana oblíqua e dissimulada." |
| 152 | ● GRIFO (lavanda) + NOTA · 19 set | "Capitu era Capitu, isto é, uma criatura mui particular, mais mulher do que eu era homem." + NOTA "Levar para o encontro de quinta." + chip rosa "👥 Leitoras de Capitu · 3 respostas" (compartilhado no clube) |
| **159 · você parou aqui** (pílula coral) | ● GRIFO · hoje ("Grifo à mão livre") | "…o que foram aqueles **olhos de Capitu**." |
| 159 | ● DESENHO + À MÃO · hoje | "Olhos de ressaca? Vá, de ressaca." com a elipse desenhada + miniatura da nota à mão ("ressaca = o mar / que puxa de volta") |
| 159 | ● 2 DESENHOS · hoje | "Traziam não sei que fluido misterioso e enérgico, uma força que arrastava para dentro, como a vaga que se retira da praia…" com ondulado e sublinhado duplo |

**Fim:** cartão tracejado "*Daqui para frente, / as margens ainda estão em branco.*" + botão preto "Continuar lendo · pág. 159".

**Interações:** filtros combináveis (tipo é exclusivo; cores são múltiplas; "Só do clube" = só itens com `shared_club_post_id`); busca em texto do grifo + texto da nota (FTS5 local); tocar no cartão abre o leitor na âncora; "Mais opções" (•••) → menu não desenhado (D-23); chip do clube → discussão do clube (`/clube/:id/discussao`); Exportar → regra do plano (D-24).

**Regras de dados (verificadas no arquivo):** contagens por tipo somam o total (6 + 2 + 1 + 3 = 12 = contador "Grifos 12" da tela 20); o separador "você parou aqui" fica antes do primeiro item da página da posição atual; datas relativas ("hoje") e "2 set" (dia + mês abreviado minúsculo, sem ponto) no fuso do usuário; o agrupamento em cartões usa `group_id` (Anexo 02 §4.3).

**Contexto cinza antes do grifo:** no arquivo tem de 0 a 55 caracteres e não segue uma regra única ("…encontrei no trem da Central um rapaz aqui do bairro,", "— ", "…", "…o que foram aqueles "). Regra de produção (D-49): até 55 caracteres antes do grifo, a partir do começo da frase, cortado em palavra, com "…" quando cortado; a fixture da tela 25 guarda os textos literais do arquivo.

**Armadilhas:** a lista é longa → `CustomScrollView` com slivers (não `Column`); miniaturas de tinta renderizadas a partir dos traços salvos (cache em imagem); o rótulo `role=img` da nota à mão no arquivo contém o texto escrito ("ressaca = o mar que puxa de volta") — no app vale a D-31 (rótulo genérico), registrado como divergência conhecida (D-51) nos testes de semântica.

## 10. Tela 26 — Ajustes de leitura (Aa)

**O que é:** folha inferior; a página fica viva em cima ("The page stays live above the sheet: every change shows here at once") com pílula "● prévia ao vivo".

- Título "**Ajustes** *de leitura*" + fechar.
- **Tamanho:** botão "A" pequeno ("Diminuir a letra") · 7 pontos (`slider`, valor 4 = ativo, lavanda) · botão "A" grande ("Aumentar a letra").
- **FONTE** (4 cartões): **Literata** "tela" (ativo) · Lora "clássica" · Figtree "sem serifa" · Atkinson "dislexia" — cada cartão mostra "Aa" na própria fonte.
- **PAPEL** (4 cartões com "Aa" + 2 linhas): **Creme** (ativo, selo ✓ com `brand`) · Branco · Sépia · Noite.
- **ENTRELINHA** (segmentado): Justo · **Médio** · Solto.
- **MARGENS** (segmentado): Estreita · **Média** · Larga.

**Dados:** `reader_settings` (global por usuário). Valores numéricos dos passos não visíveis no arquivo → D-20.

**Armadilhas:** cada mudança refaz a paginação mantendo o localizador (o primeiro caractere visível continua visível); a prévia usa o mesmo motor do leitor (não um `Text` à parte).

## 11. Tela 27 — Sumário (aba Capítulos)

Folha sobre a página esmaecida: alça · "Sumário" · "Dom Casmurro · 148 capítulos" · fechar.
- Abas (`tablist`): **Capítulos 148** (ativa) · ▮ Marcadas 3.
- Faixa rosa do clube: ícone de bandeira · "LEITORAS DE CAPITU · QUI 24/9" · "**Até o cap. L · faltam 18**" · seta →.
- Lista "Capítulos" aberta no capítulo atual: numeral romano (como no livro) · título (Literata) · marcas (símbolos por tipo + número, `aria-label="N marcas"` — regra dos símbolos no Anexo 02 §4.2; o arquivo escreve "1 marcas", ver D-51) · página de início · ✓ verde "lido":

| Cap. | Título | Marcas | Pág. | Estado |
|---|---|---|---|---|
| XXV | No Passeio Público | 1 (círculo amarelo) | 121 | lido |
| XXVI | As leis são belas | — | 126 | lido |
| XXVII | Ao portão | — | 131 | lido |
| XXVIII | Na rua | — | 136 | lido |
| XXIX | O imperador | — | 141 | lido |
| XXX | O Santíssimo | — | 146 | lido |
| XXXI | As curiosidades de Capitu | 2 (círculo lavanda + quadradinho amarelo inclinado = nota) | 152 | lido |
| **XXXII** | **Olhos de ressaca** (cartão destacado, `aria-current=location`) | 5 (círculo amarelo + círculo coral + círculo claro com caneta) | 157 | lendo (anel coral parcial) + pílula "▮ você está na pág. 159" |
| XXXIII | O penteado | — | 163 | — |
| XXXIV | Sou homem! | — | 166 | — |
| XXXV | O protonotário apostólico | — | 170 | — |
| XXXVI | Ideia sem pernas | — | 175 | — |
| XXXVII | A alma é cheia de mistérios | — | 179 | — |

**Regras (verificadas):** "faltam 18" = meta do clube (cap. L = 50) − capítulo atual (32); as marcas batem com a tela 25 (XXV → 1 grifo na pág. 121; XXXI → grifo + nota na pág. 152; XXXII → 5 itens na pág. 159); "lido" = posição atual depois do fim do capítulo; o anel do capítulo atual = progresso dentro do capítulo.

## 12. Tela 27b — Sumário (aba Marcadas)

Mesma folha, aba **Marcadas 3** ativa. Lista "Páginas marcadas" na ordem do livro:
- pág. 3 · "cap. I · Do título" · "Uma noite destas, vindo da cidade para o Engenho Novo, encontrei no trem da Central…" · "marcada em 2 set" · fita coral ("Tirar a marca da página 3", `aria-pressed`).
- pág. 6 · "cap. II · Do livro" · "Agora que expliquei o título, passo a escrever o livro…" · "marcada em 3 set".
- pág. 159 · "cap. XXXII · Olhos de ressaca" · pílula coral "você está aqui" · "Retórica dos namorados, dá-me uma comparação exata e poética…" · "marcada hoje".
- Dica no fim (ícone de fita tracejado): "Toque na fita no alto do leitor para marcar ou desmarcar."

**Dados:** `bookmarks` (excerto gravado na criação = começo da página de referência; no arquivo tem 54–83 caracteres e termina em "…"; regra de produção D-49: até 90 caracteres cortados em palavra + "…", exibido com no máximo 3 linhas; a fixture guarda os textos literais).

## 13. Mapa de navegação do leitor (máquina de estados)

```
                 ┌──────────── toque no centro ────────────┐
   [19 limpo] ───┤                                          ▼
      ▲  ▲       │                                   [20 controles] ──Tema──▶ [26b controles Noite]
      │  │  pressão longa                                 │  │  │  │  │
      │  │       ▼                                       Aa │  │  │  Sumário
      │  └── [21 seleção] ── ação/toque fora ──┐          │  Grifos │   ▼
      │                                          │          ▼  │  Anotar [27 sumário] ⇄ [27b marcadas]
      │                                          │   [26 ajustes]  ▼       │ (toque num item: vai e fecha)
      │                                          │          │   [25 grifos e notas] (rota própria)
      │                                          ▼          │      ▼
      └──────────── fechar/voltar ◀────── [22 anotação] ⇄ [23 caneta] / [23b marca-texto]
                                                 ⇅ ferramenta Espaço
                                          [24 abrindo espaço] → [24b nota à mão]
```

Rotas: `/leitor/:bookId` (estado interno: limpo/controles/seleção/anotação/folhas — não são rotas separadas, para não perder a página e o layout), `/livro/:bookId/destaques` (tela 25, já existe como placeholder no `router.dart`). Botão Voltar do Android: fecha a camada mais alta (folha → controles → limpo → sai do leitor); no modo anotação com mudanças não salvas, Voltar = Concluir (D-42).

## 14. Consistência entre telas (vira teste da fixture)

As pranchas são **fotos independentes** do mesmo mundo e nem sempre podem sair de um único estado (ex.: a 19/20/26/26b/27 mostram a pág. 159 sem nenhuma anotação; a 21 mostra um grifo de fundo em "aqueles olhos de Capitu" e nenhuma tinta; as 22–25 mostram um grifo à mão livre em "olhos de Capitu" e tinta de "hoje"). Por isso (D-34): **um "mundo de referência" base** (domingo 20/09/2026 20:00, D-09) + **um instantâneo por tela** derivado dele (`test/fixtures/telas/t19.dart` … `t27b.dart`), cada um reproduzindo exatamente a sua prancha. As asserções abaixo valem para o mundo base e para os instantâneos que mostram os mesmos dados:
- Hero da Início "Dom Casmurro" ↔ leitor: mesmo livro, capítulo XXXII/148, progresso 62 %, "~2h 10min" ↔ "≈ 2 h 10 min", 12 anotações.
- "18 min hoje" (chip da tela 20) = minutos lidos hoje no cartão "Seu dia de leitura" da Início.
- Clube "Leitoras de Capitu": encontro quinta 24/09, meta cap. L (50) — ticket da Início ↔ faixa do sumário (27) ↔ chip da tela 25.
- Tela 25: 6 + 2 + 1 + 3 = 12; páginas 3/6/41/121/152/159 coerentes com o sumário (XXV → 121, XXXI → 152, XXXII → 157..162).
- Marcadas: 3 (págs. 3, 6, 159) — a fita da tela 20 está "pressionada" porque a pág. 159 é marcada.

**Com dados reais** (G20) estas asserções viram **relações** (contagens que somam, páginas crescentes, capítulo atual coerente com a posição), não os números literais do arquivo: os números do sumário (121, 126…179 para os caps. XXV–XXXVII de 256 páginas) são ilustrativos e não saem de nenhuma regra uniforme de páginas aplicada a um EPUB real.

## 15. Telas 01–18 (pendentes)

O arquivo começa na prancha 19. As telas 01–18 (provavelmente onboarding/entrada, Biblioteca, detalhe do livro, Scanner, Clubes, Perfil, Notificações, Para você, Assinatura/Paywall, Configurações…) **não estão neste pacote**. Quando chegarem:
1. Colocar o(s) HTML em `handoff_v2/referencia/original/`.
2. Rodar a G01 para eles (mesmas ferramentas) e acrescentar as linhas nesta tabela e no mapa de fases.
3. Até lá: as rotas continuam com `PlaceholderScreen` e **nenhum design é inventado** (regra 3.2 da v1).

Rotas já existentes que esperam design: `/biblioteca`, `/clubes`, `/perfil`, `/scanner`, `/notificacoes`, `/para-voce`, `/livro/:bookId`, `/clube/:clubId/discussao`. Necessárias para o produto e ainda sem design: entrar/criar conta, onboarding ("Seus dados: só neste celular"), paywall/assinatura (R$ 9,99/mês e R$ 79,99/ano — D-26), configurações/conta (excluir conta, exportar, restaurar compras), estados vazios/carregando/erro/offline (D-21).
