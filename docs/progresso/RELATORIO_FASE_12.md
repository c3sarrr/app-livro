## Relatório — FASE 12: Integração — toques, rotas, semântica, tema e desempenho

### Entregue
- **Toques e rotas** — `lib/features/home/presentation/home_screen.dart`: `HomeScreen` virou `ConsumerWidget` (lê o snapshot só no momento do toque, com `ref.read`, sem assistir nada) e liga os callbacks das seções
  às rotas-placeholder da F02: sino → `/notificacoes`; CTA → `/leitor/dom-casmurro`; destaques → `/livro/dom-casmurro/destaques`; cards de "Também lendo", "Para você" e textos de "Recém-chegados" → `/livro/<id>`;
  "Ver tudo" → `/para-voce`; CTA do clube → `/clube/leitoras-de-capitu/discussao` (todos por `push`); "Biblioteca" → `go('/biblioteca')` (troca de aba). "Mais opções" = `HomeScreen.onMoreOptions(Book)`,
  um no-op com `// TODO(produto)` (nenhuma UI inventada).
- **Tema (D-11)** — `lib/features/home/presentation/debug/design_system_screen.dart` (novo): `DesignSystemScreen` = `HomeThemeSelector` (4 opções de `brand` e 4 de `weekColor`, com `Pressable` + `Semantics(selected)`)
  + a galeria da F01; `lib/app/router.dart`: a rota `/_ds` (só `kDebugMode`) monta `DesignSystemScreen`.
- **Sistema** — `lib/app/app.dart`: `AnnotatedRegion<SystemUiOverlayStyle>(MainShell.overlayStyle)` na raiz do `App`, então o estilo (status bar transparente com ícones escuros, barra de navegação transparente
  sem scrim, D-13) vale em todas as rotas, não só dentro do shell.
- **Desempenho** — `lib/core/design_system/widgets/app_svg.dart`: `preloadAppIcons()` põe os 18 SVGs no cache do `flutter_svg`; `lib/main.dart` espera por ele antes do `runApp`. `RepaintBoundary` em
  `sections/reading_day_card.dart` (dial, `today.dial`) e `sections/for_you_section.dart` (carrossel, `forYou.carousel`).
- **Testes novos (63; suíte 465 → 528):** `touch_home_test.dart` (23), `semantics_home_test.dart` (10), `theme_selector_test.dart` (3), `golden_theme_test.dart` (2), `performance_test.dart` (16), `platform_test.dart` (9).
- **Goldens novos** em `test/golden/goldens/`: `ds_tema_seletor@3x.png`; `inicio_brand_{b6ace4,ffc1c6,abcf82,fed170}_{hero,nav}@3x.png` (8); `inicio_weekcolor_{b6ace4,ffb39e,f2a815,abcf82}@3x.png` (4).
  **`inicio_canvas@3x.png` e `inicio_viewport@3x.png` não foram regravados** (mesmo sha256 e mesmo mtime da F11).
- **Testes de fases anteriores ajustados (7), por exigência da própria F12** — cada um mantém todas as asserções estritas e só ganha o que a especificação nova acrescenta:
  - `app_test.dart` (F02): `main()` agora espera o pré-cache (E/S real) → roda em `tester.runAsync`, limpa o cache antes e prova que os 18 SVGs ficam em cache.
  - `geometry_for_you_test.dart` (F08): o carrossel é `RepaintBoundary > SingleChildScrollView`.
  - `semantics_club_test.dart` (F09) e `semantics_for_you_test.dart` (F08): os comentários diziam "callbacks ainda não ligados (F12)"; os links agora têm a ação `tap` (e a rolagem do carrossel).
  - `style_header_test.dart`, `style_hero_test.dart`, `style_also_reading_test.dart` (F03/F05/F06): soltar o dedo dentro do alvo agora navega; os testes voltam (`handlePopRoute`) antes de reler a escala.
- **Documentação:** `docs/progresso/FASE_12.md`, `F12_verificacao.txt`, `F12_comparacao.md` e este relatório. **Evidências** em `build/visual_diff/F12/` (heatmap, lado a lado, onion, `todas/`, `viewport/`).

### Checklist (100%)
- [x] 12.1 Todos os toques da tabela navegam para a rota certa; voltar preserva a rolagem
  - evidência: `touch_home_test` (+23): as 13 linhas de `push` (rota, placeholder, shell fora de cena, volta na mesma rolagem — inclusive a horizontal do carrossel); "Biblioteca" troca a aba e a Início volta na mesma rolagem;
    alvos 48×48 / 243×54 / 54×54 / 221×46 / 44 respondem nos 4 lados e no centro e **não** respondem 4 px fora; ponto do sino, ícone, rótulos e badge não bloqueiam; sem `InkWell`/`InkResponse` (feedback = escala 0,97, D-04).
- [x] 12.1 "Mais opções" sem UI inventada
  - evidência: o teste prova ação de toque + rótulo e que tocar não muda a rota nem monta diálogo/folha/menu/barreira.
- [x] 12.2 Todos os rótulos semânticos do arquivo presentes; cabeçalhos marcados; decorativos fora da árvore
  - evidência: `semantics_home_test` (+10): 28 pares (rótulo, papel) → 24 rótulos distintos em nós próprios (as 4 exceções com exatamente 2 nós), nenhum nó funde 2 rótulos, 7 cabeçalhos h1/h2/h3,
    32 decorativos fora da árvore, "18" e "de 30 min" legíveis, `selected` só no Início, 5 botões + 17 links com a ação `tap`; árvore com 77 nós rotulados.
- [x] 12.2 Diretrizes de alvo de toque e contraste executadas e registradas
  - evidência: iOS 44×44 **passou** · rótulos **passou** · contraste **passou** (tema padrão + as 7 outras opções) · **Android 48×48 reprova exatamente os 3 "Mais opções" (44×44 no arquivo)** — visual não alterado (decisão 4 abaixo).
- [x] 12.3 `brand` e `weekColor` com as 4 opções cada; goldens por opção sem efeitos colaterais
  - evidência: `golden_theme_test` (+2) e `theme_selector_test` (+3): 8 opções comparadas pixel a pixel com o golden padrão → **0 pixels fora das regiões esperadas** em todas; as padrão = 0 diferenças
    (brand: ≈ 498,7 mil px no hero + ≈ 21,5 mil na pílula; weekColor: só as barras 0–5, a de "Hoje" 0 px).
- [x] 12.4 Otimizações aplicadas sem mudança de pixel (golden idêntico ao aprovado na F11)
  - evidência: `flutter test test/home/golden_canvas_test.dart test/home/golden_viewport_test.dart` **sem** `--update-goldens`: passou; sha256 dos dois PNGs iguais antes/depois (`F12_verificacao.txt`).
    Aplicado: dial + carrossel em `RepaintBoundary` (0 px de diferença, medido), pré-cache dos 18 SVGs, `select` por seção (brand → só hero, barra de progresso e a barra de navegação; weekColor → só o cartão do dia;
    rolar → nada), sem `Opacity`/`saveLayer` em `lib/`, `shouldRepaint` dos 6 pintores compara todos os campos.
- [x] 12.4 Perfil de rolagem — **pendência de ambiente registrada** (sem aparelho, sem AVD e sem JDK 17); comando exato abaixo.
- [x] 12.5 Comportamento de sistema testado — `platform_test` (+9): estilo enviado ao sistema (status bar transparente, ícones escuros; iOS: conteúdo escuro; barra de navegação transparente, `contrastEnforced: false`),
  o mesmo em todas as rotas, fade até a borda real da tela, toque na status bar do iOS (`handleScrollToTop` → `Scaffold` → rolagem 0), física Android (clamping + stretch) e iOS (bounce).
  **Prints de emulador/simulador — pendência de ambiente registrada**; comandos abaixo. A prova automática é o golden do viewport (F11), que continua idêntico.
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes — `Formatted 132 files (0 changed)` · `No issues found!` · `+528: All tests passed!` (3 execuções).
- [x] Relatório no modelo do prompt mestre — este arquivo.

### Verificação
- **Geometria:** a F12 não altera layout; o repouso é o mesmo da F11 (golden com sha256 idêntico) e os 18/18 ids da F11 (maior desvio `nav.library.label.w` = −0,016 px) continuam valendo, pois os testes de
  geometria das fases 2–11 seguem verdes. Novo: alvos de toque medidos e exercitados nos 4 lados e no centro (`touch_home_test`).
- **Estilo:** `golden_theme_test` — 8 opções de tema contra o golden padrão, 0 pixels fora das regiões esperadas; `performance_test` — 16 asserts (`select`, rolagem sem reconstrução, PictureLayers estáveis,
  sem `saveLayer`, `shouldRepaint`); `platform_test` — 9 asserts (overlay, fade, física).
- **Visual** (`compare_images.py`, idêntico à F11; `blur_mismatch_%` 0,0 em todas):

  | Região | raw_mismatch_% | mean_abs | max | Resultado |
  |---|---:|---:|---:|---|
  | F12_nav_fade, canvas (0, 2230, 390, 160) | 0,1255 | 0,258 | 99 | PASSOU |
  | header / headline / hero / alsoReading | 0,4113 / 1,3126 / 0,6195 / 0,8922 | 0,53 / 1,306 / 0,687 / 0,982 | 142 / 221 / 128 / 189 | PASSOU |
  | today / forYou / club / recent | 1,3001 / 2,1986 / 2,2549 / 0,8938 | 1,139 / 1,77 / 2,02 / 0,976 | 228 / 229 / 229 / 189 | PASSOU |
  | bottomFade / nav | 0,1288 / 0,2545 | 0,264 / 0,512 | 99 / 99 | PASSOU |
  | Viewport 390×844 × derivada (0, 0, 390, 844) | 0,5499 | 0,648 | 221 | PASSOU |
  | Viewport, faixa inferior (0, 694, 390, 150) | 0,1502 | 0,473 | 108 | PASSOU |

  PNGs de evidência: `build/visual_diff/F12/` (`F12_nav_fade_*`, `todas/`, `viewport/`) e os 12 recortes de tema + `ds_tema_seletor@3x.png` em `test/golden/goldens/`.
- **Texto:** nenhuma string nova no app (o seletor existe só na rota de debug `/_ds`); as strings e quebras das fases anteriores seguem cobertas pelos testes `text_*` (todos verdes).
- **Qualidade:** flutter analyze com 0 problemas · dart format ok (132 arquivos, 0 mudanças) · flutter test com 528 passando (465 + 63) · `design_handoff/` intacto (git limpo; `handoff_checksums.txt`: 131 arquivos OK).
- **Estabilidade:** 3 execuções completas da suíte (+528 nas três), nenhuma "did not complete".

### Decisões fora do arquivo usadas nesta fase
- Nenhuma decisão D-xx nova. Usadas: D-01/D-02 (barra e fade fixos, insets), D-04 (`Pressable`, feedback 0,97, sem ripple), D-08 (Scanner por push; aba ativa inalterada), D-09 (dados mock; o id lido no toque
  vem do snapshot), D-11 (`brand`/`weekColor` configuráveis, seletor de debug), D-13 (status bar transparente com ícones escuros; Android edge-to-edge) e D-15 (rótulos semânticos = `aria-label` do arquivo).
- Detalhes de construção além do texto da fase, todos neutros no repouso:
  - `HomeScreen` passou a `ConsumerWidget` e `main()` espera o pré-cache dos SVGs (E/S real) — por isso os ajustes de teste listados em "Entregue";
  - o seletor de tema vive na rota de debug `/_ds` (a F12 pede "seletor de debug") para não aparecer em release;
  - "Biblioteca" usa `go` (troca de aba) e as demais rotas usam `push` (voltar devolve à Início na mesma rolagem).

### Riscos/pendências
Pendências de ambiente previstas na fase (12.4 e 12.5) — a máquina não tem aparelho/AVD e o JDK 17 configurado no Flutter não existe mais (`flutter doctor` marca o Android toolchain com `!`; `JAVA_HOME` aponta para uma
pasta inexistente; só há o Java 8 da Oracle no PATH). Não instalei nada sem você pedir.

- **12.4 — perfil de rolagem (0 frames > 16 ms em aparelho médio).** Precisa de um aparelho físico (o modo profile não roda em simulador iOS):
  ```bash
  flutter devices
  flutter run --profile -d <id-do-aparelho>
  ```
  No DevTools → Performance, gravar a rolagem do topo ao fim da Início, contar os frames > 16 ms e anotar o tempo médio de build/raster.
- **12.5 — prints de emulador/simulador (Android).** Primeiro o JDK, depois um AVD 390×844 (@3x = 1170×2532):
  ```bash
  winget install EclipseAdoptium.Temurin.17.JDK
  flutter config --jdk-dir "<pasta do JDK 17>"
  flutter doctor
  avdmanager create avd -n app_leitura_390x844 -k "system-images;android-37.0;google_apis_playstore_ps16k" -d pixel_6
  ```
  Em `~/.android/avd/app_leitura_390x844.avd/config.ini` definir `hw.lcd.width=1170`, `hw.lcd.height=2532`, `hw.lcd.density=480`; depois:
  ```bash
  emulator -avd app_leitura_390x844
  flutter run -d emulator-5554
  adb exec-out screencap -p > build/visual_diff/F12/android_390x844.png
  python3 tools/compare_images.py --flutter build/visual_diff/F12/android_390x844.png --ref design_handoff/referencia/png/inicio_viewport_390x844_DERIVADA@3x.png --scale 3 --rect 0,0,390,844 --out build/visual_diff/F12/android --name F12_android
  ```
  (a comparação é informativa: a barra de status e a barra de gestos reais do emulador diferem da derivada).
- **12.5 — simulador iOS (só em macOS):** `xcrun simctl io booted screenshot build/visual_diff/F12/ios_390x844.png`.

**Decisões para você (nada disso foi alterado — o repouso ficou idêntico):**
1. **`RepaintBoundary` nas capas e no gráfico semanal.** O arquivo da fase pede boundaries em "dial, gráfico semanal, cada capa, carrossel" **e** o golden idêntico; as duas exigências conflitam. Medi uma a uma
   (diferença contra o golden aprovado, só em bordas curvas, Δ ≤ 12/255): dial 0 px · carrossel 0 px · capa do hero 3 px · 2 capas de "Também lendo" 34 px · 3 capas de "Para você" 12 px ·
   3 mini-capas de "Recém-chegados" 89 px · gráfico semanal 40 px · todas juntas 178 px de 8,4 M. Mantive só as duas neutras. **Se você aceitar ≤ 12/255 em ≤ 0,002 % dos pixels**, ligo as outras seis e
   regenero os dois goldens (tabela e pontos exatos em `F12_comparacao.md`); caso contrário, fica como está.
2. **Ordem de travessia do leitor de tela × ordem do HTML.** A árvore segue o DOM, mas o Flutter percorre por geometria: 14 das 77 posições rotuladas diferem (hero, "Seu dia", clube; registrado desde a F09 e fixado em
   `semantics_club_test.dart`). Recomendo `OrdinalSortKey` nesses grupos; muda a ordem de leitura, não o visual.
3. **Toque nas partes que vazam / cantos fora da curva.** A capa de "Também lendo" que sai acima do card não é tocável (no HTML o `<a>` inteiro é); os cantos fora do círculo do FAB e das pílulas do CTA são
   tocáveis (no navegador não). Não alterei.
4. **Alvo de toque Android 48×48:** os 3 botões "Mais opções" têm 44×44 no arquivo e reprovam a diretriz do Android (passam na do iOS). Ampliar a área de toque sem mexer no visual é possível se você quiser.

**Resíduos que não consegui remover (o ambiente negou os comandos de remoção; nenhum afeta o app, o analyze ou os testes):**
- apague `lib/tmp_rb.dart` e `test/tmp_probe_diff_test.dart` (só comentário / `void main() {}`, da investigação das `RepaintBoundary`);
- `test/home/failures/inicio_canvas@3x_*.png` (versionados) foram sobrescritos por uma execução de golden que falhou durante essa investigação: `git restore test/home/failures`;
- um `flutter_tester.exe` órfão pode ter ficado da execução travada que parei por `TaskStop` (o `tasklist` não listou nenhum agora; se aparecer, encerre).

✅ FASE 12 concluída — aguardando sua aprovação para iniciar a FASE 13.
