## Relatório — FASE 7: Seção 5 — "Seu dia de leitura" (dial da meta, chips, gráfico semanal, selo)

### Entregue
- **Seção:** `lib/features/home/presentation/sections/reading_day_card.dart` (`ReadingDayCard`), com a construção obrigatória da fase:
  - `Semantics(seção)` > `NeoBox` `#FED170` (borda 1,5, raio 28, sombra 4/4, recorte 26,5) > `Stack(Clip.none)`;
  - na `Stack`, os 2 círculos decorativos primeiro (atrás) e depois `Padding(18)` > `Column(gap 16)` com os 4 blocos;
  - cabeçalho: h3 misto (`AppText.rich`: Bricolage 20 + Instrument Serif itálico 23) e a pílula 84,23 × 32 com a chama;
  - linha da meta: dial 112 (`GoalDialPainter` fora da semântica + "18"/"de 30 min") e a coluna de 181 com a frase de 2 linhas e os chips num `Wrap` (gap 6 nos dois sentidos);
  - cartão da semana: cabeçalho por baseline; gráfico com 7 trilhos (`HatchPainter` + `TopBorderCrescentPainter` no recorte do trilho) e a linha da meta `ChromiumDashPainter` por cima; rótulos centralizados;
  - rodapé com o brilho 16 e a frase do selo.
- **Dados:** strings pelos formatadores da F02 (`countLabel`, `remainingGoal`, `weekTotalLabel`, `weekAria`, `weekInitials`, `badgeHint`). Alturas das barras pelos dados (D-10) e `weekColor` pelo `homeThemeProvider` (D-11). "18" e "de 30 min" são montados a partir de `readMinutes`/`goalMinutes`, como o contador da F06.
- **Tela:** em `lib/features/home/presentation/home_screen.dart` o placeholder `today` virou `ReadingDayCard()` (1 import + 1 linha).
- **Testes (32 novos):**
  - `test/home/geometry_today_test.dart` (10);
  - `text_today_test.dart` (5);
  - `style_today_test.dart` (16);
  - `semantics_today_test.dart` (1).
- **Golden:** `test/golden/goldens/inicio_canvas@3x.png` regenerado, agora com a seção.
- **Documentação:** `docs/progresso/FASE_07.md`, `F07_verificacao.txt`, `F07_comparacao.md` e este relatório.
- **Evidências** em `build/visual_diff/F07/`:
  - lado a lado, heatmap e onion;
  - recortes ampliados das barras (4× e detalhes da barra 0 e da de hoje), do dial, do cabeçalho, da frase com os chips e do rodapé;
  - `todas/`, `nao_regressao/` e `sonda_escala/`;
  - `golden_F06_aprovado.png`.
- **Sondas:** as duas sondas de escala (10×) foram testes temporários, já removidos.

### Checklist (100%)
- [x] 7.1 Cartão 350×400,8 `#FED170`, borda 1,5, raio 28, sombra 4/4, padding 18, gap 16, recorte
  - 400,8 = 1,5 + 18 + 32 + 16 + 112 + 16 + 153,8 + 16 + 16 + 18 + 1,5.
  - Decoração exata; `ClipRRect` 26,5 `antiAlias` na padding box. A `Stack` não recorta de novo.
- [x] 7.1 Círculos 153 e 101 (content-box), borda 1,5 `rgba(26,23,20,.14)`, em −46/−46 e −20/−20, atrás do conteúdo
  - Posição (241,5; −44,5) e (267,5; −18,5); cor `0x241A1714`.
  - Nos pixels: o anel sai em src-over exato; sob a pílula aparece a pílula; acima do cartão, o papel.
- [x] 7.2 Título misto numa linha (29,9) centrado em 32; pílula 84,23×32 (padding 0/11/0/8, gap 5, chama 17)
  - Título 156,77 × 29,900 a y + 1,05, uma linha; "leitura" na mesma baseline, a ≤ 0,01 do arquivo.
  - Pílula 84,232 × 32 = 1,5 + 8 + 17 + 5 + texto + 11 + 1,5.
- [x] 7.3 Dial: face r54 + traço 1,5; 31 marcações; arco 60% traço 10; pino (30,1; 91,6); "18" 34/1 ls −1 + "de 30 min" `#4A4238`
  - `GoalDialPainter(18/30)` com 112 × 112. O teste da F01 cobre face, 31 marcações, arco e pino (30,137; 91,597).
  - 11 pontos de pixel: face, traço, marcação .35, vão, arco, ponta redonda e o pino por cima do arco.
- [x] 7.4 Frase 15/600/1,3 com "12 min" 700, 2 linhas exatas; chips 5/9, borda 1,2, fundo .7, gap 6 (com quebra de linha)
  - "Faltam 12 min para fechar" / "a meta de hoje." (com o "a", estouraria 181 por 5,528; arquivo: 5,55).
  - Chips 80,513 e 86,858 × 26,8, fundo `0xB3FFFAF1`. Em 360 o segundo chip desce com gap 6.
- [x] 7.5 Cartão semana 311×153,8, padding 14/14/12, gap 8, cabeçalho por baseline
  - 153,8 = 1,5 + 14 + 15,6 + 8 + 80 + 8 + 13,2 + 12 + 1,5.
  - O total começa 0,95 abaixo, com a mesma baseline.
- [x] 7.6 7 colunas de 33,143 (gap 8); trilhos 80 com borda 1,2 / 1,5; hachuras corretas (listra 3/período 7, "/", origem interna)
  - Bordas 1,2 e 1,5; recortes 15,371 / 15,071.
  - Nos pixels: listra/base em t = 22,5 / 26 / 29,5, constantes ao longo de "/"; `#FDE2B2` na de hoje.
- [x] 7.6 Preenchimentos com meia-lua 1,5 e alturas do arquivo; recorte pela curva do trilho
  - Alturas 43, 60, 40, 30, 51, 73 e 24; meia-lua em tinta; `#B6ACE4` e `#FF552E`.
  - No canto de hoje, a borda do trilho continua em tinta onde o preenchimento (raio 12) passaria.
- [x] 7.7 Linha tracejada 288×1,5 em bottom 38, 64 traços, alpha .45, por cima das barras
  - 64 traços de 3 com vão 1,5238; cor `0x731A1714`.
  - Traço sobre o preenchimento = `0xFF706986` (src-over exato); vão = `#B6ACE4`.
- [x] 7.7 Rótulos 11 px centralizados; "Hoje" 700 tinta
  - Centrados nas colunas (±10⁻³); `#5B544B` × tinta; 7/7 linhas a ≤ 0,01 do arquivo.
- [x] 7.8 Rodapé: brilho 16 + frase com "2 dias" 700, gap 8
  - Frase a 8 do brilho, a y + 0,2; "2 dias" de 73,842 a 108,588 (arquivo 73,84–108,59).
- [x] Geometria 49/49 · Texto OK · Estilo OK · Tema OK · Visual ≤ 0,5% · Não-regressão OK — números abaixo.
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes: 0 mudanças · No issues found! · +305: All tests passed!
- [x] Relatório com lado-a-lado, heatmap e recorte ampliado das barras inspecionados: todos abertos e anexados na conversa.

### Verificação
- **Geometria:** 49/49 ids da seção dentro da tolerância.
  - Maior desvio: `today.footer.text.w` = 0,021 px.
  - Os 14 retângulos das barras e dos preenchimentos têm Δ ≤ 0,004; os blocos estruturais, Δ 0,000.
  - Sondagem informativa em 360: os chips quebram para (169,50; 936,36), o mesmo do arquivo. A validação formal é da F13.
- **Texto:**
  - 17 textos e 18 linhas, com strings e quebras idênticas;
  - baselines com Δ 0,000; inícios e fins com Δ ≤ 0,031;
  - os trechos mistos "leitura" (serifa), "12 min" e "2 dias" (700) a ≤ 0,02 do arquivo, na mesma baseline da linha. Isso prova os tokens `cardTitleM`/`cardSerifM` e `goalSentence`/`goalSentenceStrong`.
- **Estilo:** 16 testes.
  - Decorações e pintores exatos: cartão, círculos, pílula, chips, cartão da semana, 7 trilhos, 7 hachuras, 7 meias-luas e a linha da meta.
  - Os 12 tokens de texto da seção, conferidos pela mesma instância.
  - 37 pontos de pixel @3x, todos no valor exato, inclusive as 7 composições translúcidas.
- **Tema:** as 4 opções de `weekColorOptions` mudam só os preenchimentos 0–5 (≈ 71 mil pixels, 0 fora deles). A barra de hoje continua `#FF552E`, e a opção padrão muda 0 pixels.
- **Semântica:** 1 teste.
  - Seção "Seu dia de leitura" com 18 filhos na ordem do documento; h3 de nível 3.
  - O gráfico é um nó com o `aria-label` literal ("Minutos lidos por dia: segunda 32, …, hoje 18 de 30").
  - Círculos, chama, desenho do dial, brilho e linha tracejada fora da árvore. Nenhuma ação na seção.
- **Visual:**

  | Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
  |---|---:|---:|---:|---:|---|
  | today (16, 758, 358, 418) | 0,0 | 1,2989 | 1,138 | 228 | PASSOU |
  | today, modo `--layout` | 0,0 | 1,3001 | 1,139 | 228 | PASSOU |
  | header / headline / hero / alsoReading, modo `--layout` (não-regressão) | 0,0 / 0,0 / 0,0 / 0,0 | 0,4113 / 1,3126 / 0,6195 / 0,8922 | — | 142 / 221 / 128 / 189 | PASSOU (iguais à F06) |
  | acima do cartão (0, 0, 390, 766) × golden aprovado da F06 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |
  | abaixo do cartão e da sombra (0, 1172, 390, 1218) × golden aprovado da F06 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |
  | informativo: sonda 10× reduzida a 3× × referência | 0,0 | 0,4915 | 0,77 | 121 | PASSOU |

  As diferenças que sobram são todas de rasterização; a análise completa está em `F07_comparacao.md`:
  - **Bordas de glifo (Figtree/Bricolage).** Somem a 10× → 3×: título, "12 dias", frase e cabeçalho da semana caem para 0 pixels > 64.
  - **"leitura" (Instrument Serif 23 itálico).** É o max da seção (228). É o hinting da fonte, a mesma assinatura da F04/F06: a 10× → 3× cai para 0 pixels > 64 e max 39.
  - **Deriva vertical da própria referência** (screenshot com `zoom: 10`).
    - Na parte de baixo do cartão, a imagem de referência está de +0,09 a +0,19 px abaixo do JSON: rótulos, rodapé e bordas de baixo. O "18" está −0,07.
    - O Flutter pinta as bordas na posição do CSS (±0,04). Nas seções de cima e na metade de cima desta a deriva é zero.
    - Compensando o deslocamento, os pixels > 64 caem a zero.

  Forma, posição, cor, espessura, ordem de pintura e recorte são iguais ao arquivo. Dos 1.283.109 pixels alterados em relação ao golden da F06, 1.283.108 estão dentro do cartão com a sombra. O que sobra encosta na aresta direita da sombra (suavização do canto).
- **Qualidade:** flutter analyze com 0 problemas · dart format ok (90 arquivos, 0 mudanças) · flutter test com 305 passando · `design_handoff/` intacto (131/131).
- **Estabilidade:** 3 execuções completas da suíte, todas `+305`, nenhuma "did not complete".

### Decisões fora do arquivo usadas nesta fase
- Nenhuma decisão D-xx nova. Usadas:
  - D-10: alturas das barras = px do arquivo, vindas dos dados;
  - D-11: `weekColor` configurável, padrão `#B6ACE4`, só nos preenchimentos dos dias anteriores;
  - D-14: "12 dias", "12 min", "Esta semana", "Hoje" e "2 dias" com 800 → 700;
  - D-15: rótulo da seção e do gráfico = `aria-label` do arquivo.
- O `<h3>` usa `headingLevel: 3`, como o h1/h2/h3 das fases anteriores.

### Riscos/pendências
- Nenhuma.
- **Informativo — referência PNG × JSON.** A imagem de referência foi feita com `zoom: 10` e, na metade de baixo deste cartão, fica até 0,19 px abaixo da geometria medida com `zoom: 100`. O gate está bem folgado aqui (blur 0,0). Nas seções seguintes, que ficam abaixo desta, pode sobrar um deslocamento parecido. Se um gate visual chegar a falhar só por isso, paro e pergunto (§7), sem mexer em posições.
- **Informativo — git.** As mudanças da F07 estão sem commit (último commit: `a3054fd`, fases 5–6). `test/home/failures/` (PNGs antigos, de antes da F05) continua não versionado.

✅ FASE 7 concluída — aguardando sua aprovação para iniciar a FASE 8.
