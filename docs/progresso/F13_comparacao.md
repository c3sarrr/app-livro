# F13 — Revisão de designer (13.5) e autorrevisão

Método: `build/visual_diff/F13/canvas_lado_a_lado.png` (canvas inteiro 1170×7170: **Flutter | referência | diferença ×4**) e 9 recortes a 300 %
(`build/visual_diff/F13/revisao_01 … 09_*.png`, mesmas 3 colunas), abertos e percorridos seção por seção. A coluna da direita é `|Δ| × 4` por pixel:
fundo branco = idêntico; vermelho = diferença. Contagens: pixels (@3×) com Δ > 24/255 dentro do recorte.

| Recorte | O que foi conferido a 300 % | Resultado | Px com Δ > 24 |
|---|---|---|---|
| 01 capa do hero (rotação −3°) | borda 1,5, lombada, sombra 3/3, círculo + anel, "Dom Casmurro" (serifada 26), autor 6,5 px "MACHADO DE / ASSIS" | idênticos | 1,33 % |
| 02 capas de "Também lendo" (−4° / +3°) | sombra 2/2, lombadas, meia-lua da Mrs. Dalloway, anel do Orgulho, anéis de progresso 34 %, reticências | idênticos | 1,55 % |
| 03 gráfico semanal | **meia-lua** do topo de cada preenchimento, direção "/" e fase das **hachuras**, borda 1,2 (1,5 em "hoje"), **linha tracejada** da meta por cima das barras | idênticos | 2,16 % |
| 04 dial + meta | arco do dial, ponta, números, chips, frase em 2 linhas | idênticos | 2,00 % |
| 05 capas de "Para você" | Memórias Póstumas (3 linhas + semicírculo preto sob o autor), Quincas Borba (3 barras + 2 linhas), O Cortiço (arco vazado) | idênticos | 2,45 % |
| 06 ticket do clube | **2 entalhes**, **perfuração tracejada**, avatares sobrepostos "A J L +8", hachura do trilho, marcador "M", CTA com badge | idênticos | 2,85 % |
| 07 avatares + pílula | ordem de empilhamento e bordas dos 4 círculos | idênticos | 4,32 %\* |
| 08 mini-capas de "Recém-chegados" | 3 artes, lombadas, borda 1,2, divisores de 1 px | idênticos (ver divisor abaixo) | 1,56 % |
| 09 navegação + FAB | pílula ativa, rótulos, **sombra 0/4 do FAB sobre a barra**, ícone do scanner 28 | idêntico | 0,47 % |

\* o recorte 07 é pequeno (234×40 px CSS) e quase todo contorno de texto/círculos: a porcentagem é alta porque a área é pequena; o desenho é o mesmo.

## Diferenças residuais — todas de rasterização, com a causa medida

1. **Contornos finos em toda a coluna de diferença (texto, círculos, curvas).** O Flutter rasteriza direto a 3×; a referência é o Chromium a 10× reduzido a 3× (suavização de borda e *hinting* de glifo do motor). Mesmo padrão e mesmos números das fases anteriores (ex.: gráfico semanal: **952 px > 64** em F07 e hoje, idêntico → sem regressão). A barra de "hoje" (hachura `#FDE2B2`, borda 1,5) tem 179 px > 64 (0,74 %), dentro da faixa das outras 6 (0,22–0,92 %).
2. **Divisor de 1 px da lista (recent.row0 → row1).** Perfil medido na coluna x = 200 dos dois PNGs:
   `Flutter: 6087→244 · 6088→233 · 6089→233 · 6090→244` (cobertura 6087,5–6090,5 @3× = a posição do JSON, 2029,16–2030,16 CSS, com meio pixel nas pontas) ·
   `Referência: 6087→255 · 6088→233 · 6089→233 · 6090→233` (a borda do Chromium "encaixa" em pixels inteiros de dispositivo e o PNG está 0,5 px @3× ≈ 0,17 px CSS mais abaixo).
   Causa: deslocamento já documentado do PNG de referência (zoom 10 fica abaixo do JSON, +0,07…+0,20 px na metade inferior; **o JSON vence** e a geometria do app bate com ele: ver tabela dos 10 maiores desvios, todos < 0,05 px). Nenhuma diferença de forma, cor, espessura, ordem ou recorte.
3. **Textos de 6,5 px** (autor das capas): mesma largura de linha e mesma quebra; a diferença é só o contorno do glifo.

Nenhuma diferença de forma, posição, cor, espessura, ordem de pintura ou recorte foi encontrada. Nada foi "empurrado" nem tolerância alguma foi alterada.

## Achados de auditoria que mereceram investigação (todos resolvidos sem mexer na UI)

- **Rotação de −45° na varredura.** `RotationTransition` do slot de FAB do `Scaffold` (framework) **sem filho**: não pinta. O FAB do app é o `ScannerFab` do `MainShell`. A varredura passou a ignorar `Transform` sem filho e imprime as 3 rotações reais (−3° hero, −4° e +3° "Também lendo").
- **"7 hachuras" no checklist da F13 × 8 no app.** O **HTML original tem 8** `repeating-linear-gradient(135deg…)` (7 trilhos da semana + 1 trilho do clube); o app tem 8 e as duas seções estão em 0,0 %. O arquivo vence (§2 do prompt mestre): o texto do checklist contou só os trilhos da semana. Registrado no relatório para o usuário confirmar.
- **Comentário "NÃO use google_fonts" no `pubspec.yaml`** fazia a busca literal da auditoria devolver 1 linha (era comentário copiado do handoff, não dependência). Comentário reescrito sem o nome do pacote.
