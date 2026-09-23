# FASE 13 — QA final pixel a pixel e auditoria anti-simplificação

> Pré-requisito: FASE 12 aprovada.
> Resultado: prova objetiva de que a tela Início em Flutter é idêntica ao arquivo — na largura de referência (390) e no comportamento fluido (360 e 430) — e de que nada foi simplificado.

---

## Subfase 13.1 — Canvas completo 390 × 2390 (gate principal)

1. `expectGeometry(tester, kRefLayout.keys)` → **248/248** dentro da tolerância. Anexe a tabela dos 10 maiores desvios.
2. `expectTextLines` para **todos** os ids com linhas de texto (88 elementos em `kRefLayout`; capas rotacionadas só quebras; 2 com reticências).
3. Golden `inicio_canvas@3x.png` vs `inicio_canvas_390x2390@3x.png` com `--layout` (todas as seções, `--out build/visual_diff/F13/canvas`) → **todas** `PASSOU` (`blur_mismatch_% ≤ 0,5`) + canvas inteiro sem `--rect` → `blur_mismatch_% ≤ 0,5`.
4. Estilo: rode de novo todos os testes de estilo das fases 3–11 (devem continuar verdes).

## Subfase 13.2 — Primeira dobra num aparelho 390 × 844

- Golden `inicio_viewport@3x.png` (safe 47/34) vs `inicio_viewport_390x844_DERIVADA@3x.png` (`--out build/visual_diff/F13/viewport`) → `blur_mismatch_% ≤ 0,5`.
- Rolagem ao fim: rolagem máxima = 2355,16 − 844 = **1511,16**; a lista termina em y = **704** na tela → **19,5 px** acima do topo do FAB (723,5) e **40 px** acima da barra (744). Registre print.

## Subfase 13.3 — Comportamento fluido (validação secundária)

O CSS do arquivo é fluido: a mesma marcação renderizada com largura 360 e 430 gerou `referencia/png/inicio_w360x2390@2x.png`, `inicio_w430x2390@2x.png`, `referencia/layout/layout_w360.json` / `layout_w430.json` (com `meta`, `sections`, `elements`) e `reference_layout_w360.dart` / `reference_layout_w430.dart` (copiados para `test/reference/` na F00).
- Geometria: `setCanvasView(tester, logical: const Size(360, 2390), dpr: 2)` + `expectGeometryAgainst(tester, kRefLayoutW360)` → **248/248** com ±1,0 px (x, y, w, h); idem `Size(430, 2390)` + `kRefLayoutW430`.
- Golden @2x de cada largura (`inicio_w360@2x.png`, `inicio_w430@2x.png`) vs referência correspondente:
  `python3 tools/compare_images.py --flutter test/golden/goldens/inicio_w360@2x.png --ref design_handoff/referencia/png/inicio_w360x2390@2x.png --scale 2 --layout design_handoff/referencia/layout/layout_w360.json --out build/visual_diff/F13/w360 --name w360` → `blur_mismatch_% ≤ 0,5` por seção (idem 430 com `--out build/visual_diff/F13/w430`). Cada largura em **sua própria pasta**: no modo `--layout` as imagens de evidência têm o nome da seção e se sobrescreveriam.
- Casos que só aparecem em 360 e que o seu layout precisa reproduzir **sem código especial**: título "Dom Casmurro" quebrando em 2 linhas no hero; frase da meta em 3 linhas; chips da meta quebrando em 2 linhas (gap 6); flex-shrink das linhas da lista com 168 px disponíveis.
- Se algo só funcionar em 390, a implementação está "desenhando posições" em vez de reproduzir as regras do CSS → corrija.

## Subfase 13.4 — Auditoria anti-simplificação (execute e cole as saídas)

```bash
grep -rnE "(^|[^A-Za-z_])(Icons|CupertinoIcons)\." lib/    # esperado: 0 (AppIcons.* é permitido)
grep -rnE "\b(Card|Chip|ElevatedButton|FilledButton|TextButton|OutlinedButton|ListTile|BottomNavigationBar|NavigationBar|AppBar|FloatingActionButton|Badge|LinearProgressIndicator|CircularProgressIndicator|InkWell|InkResponse|Divider)\(" lib/   # esperado: 0
grep -rnE "google_fonts|screenutil" pubspec.yaml lib/     # esperado: 0
grep -rnE "(^|[^A-Za-z])(Text|RichText)(\(|\.rich\()" lib/features lib/core/design_system/widgets   # esperado: 0 (só AppText)
grep -rnE "elevation:|blurRadius: *[1-9]|Opacity\(" lib/  # esperado: 0
grep -rn "BoxShape.circle" lib/features/home/presentation/covers/memorias_postumas_cover.dart   # esperado: 0 (é elipse)
grep -rn "FontWeight.w800" lib/ | grep -v app_typography  # esperado: 0 (Figtree nunca 800)
sha256sum -c docs/handoff_checksums.txt                   # esperado: todos OK (design_handoff intacto)
```
Checklist manual (marque com evidência — print do trecho):
- [ ] 18 SVGs do pacote usados; nenhum ícone redesenhado
- [ ] 36 TTFs do pacote; famílias Bricolage por tamanho; Figtree ≤ 700
- [ ] Todas as sombras duras presentes (hero 4/4, dia 4/4, capa DC 3/3, capas TL 2/2, nav 0/4, FAB 0/4) e **nenhuma outra**
- [ ] Todas as rotações (−3°, −4°, +3°) presentes
- [ ] Todas as decorações: 2 brilhos do hero, brilho do selo, brilho do chip, 2 círculos do dia, 7 hachuras, linha tracejada, perfuração, 2 entalhes, 9 artes de capa completas, lombadas
- [ ] Bordas 1,2 onde o arquivo usa 1,2 (chips do dia, trilhos 0–5, mini-capas) e 1 px nos divisores
- [ ] Quebras especiais: "MACHADO DE / ASSIS" (capa DC), "Memórias / Póstumas de / Brás Cubas", "Faltam 12 min para fechar / a meta de hoje.", "Machado de Assis · / PDF", "Quero / ler"
- [ ] Reticências: "Orgulho e Precon…", "Memórias Póstu…"
- [ ] Decisões fora do arquivo usadas = somente D-01…D-15

## Subfase 13.5 — Revisão de designer (você mesmo, com os olhos)

Gere `build/visual_diff/F13/canvas_lado_a_lado.png` e percorra seção por seção, ampliando 300% em: capas (bordas, lombadas, textos minúsculos 6,5 px), meia-lua das barras, direção das hachuras, tracejados, entalhes, badges sobrepostos, sombra do FAB sobre a barra. Liste qualquer diferença residual com a causa (ex.: suavização de borda do motor) — se a causa não for exclusivamente de rasterização, **corrija** antes de concluir.

## Subfase 13.6 — Entrega final

Relatório final contendo:
1. Tabela por seção: geometria (ids OK / maior desvio), visual (`blur_mismatch_%`), texto (OK), estilo (OK).
2. Resultados de 360/430.
3. Saídas da auditoria 13.4.
4. Evidências (caminhos dos PNGs de lado-a-lado/heatmap/onion).
5. Como regenerar fontes (`design_handoff/ferramentas/build_fonts.py`) se surgir um tamanho novo da Bricolage.
6. Como adicionar as próximas telas (Biblioteca, Clubes, Perfil, Scanner) quando houver arquivos de design: mesmo pacote de referência + mesmas fases por seção.

---

## Checklist de aceite da FASE 13

- [ ] 13.1 Geometria 248/248 no canvas 390×2390
- [ ] 13.1 Texto: todas as linhas/quebras/reticências conferidas
- [ ] 13.1 Visual: todas as seções e o canvas inteiro ≤ 0,5%
- [ ] 13.2 Viewport 390×844 ≤ 0,5% + rolagem ao fim registrada
- [ ] 13.3 360 e 430: geometria ±1,0 e visual ≤ 0,5% por seção
- [ ] 13.4 Auditoria automática: todas as buscas com o resultado esperado; checksums OK
- [ ] 13.4 Checklist manual anti-simplificação 100% com evidência
- [ ] 13.5 Revisão de designer registrada (nenhuma diferença que não seja de rasterização)
- [ ] 13.6 Relatório final completo
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes

**Ao concluir: entregue o relatório final e PARE.**
`✅ FASE 13 concluída — tela Início entregue idêntica ao arquivo. Aguardando próximos arquivos de design.`
