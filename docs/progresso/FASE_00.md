# FASE 0 — Preparação do projeto e do laboratório de fidelidade

Checklist da fase (`design_handoff/fases/F00_preparacao.md`), item por item. Um item só é marcado com evidência.
Saídas literais dos comandos: `F00_verificacao.txt` · tabelas da 0.7: `F00_comparacao.md` · versões: `F00_versoes.txt` · doctor: `F00_flutter_doctor.txt`.

- [x] 0.1 Versões do Flutter/Dart registradas; projeto criado ou existente analisado e relatado
  — Flutter 3.47.2 (stable, engine a804b26164) · Dart 3.13.2 (`F00_versoes.txt`); `flutter doctor -v` em `F00_flutter_doctor.txt` (Android toolchain OK, SDK 37). O diretório só tinha `design_handoff/` → `flutter create --project-name app_leitura --platforms android,ios .`. Bundle id provisório do `flutter create` (Android `com.example.app_leitura`, iOS `com.example.appLeitura`); o definitivo será confirmado com o usuário (F00 0.1.2, não bloqueia).
- [x] 0.1 `design_handoff/` intacto; `docs/handoff_checksums.txt` gerado
  — 131 arquivos (= `find design_handoff -type f`); `sha256sum -c --quiet docs/handoff_checksums.txt` → OK. `.gitattributes` marca `design_handoff/**`, `assets/**`, `test/reference/*.dart`, `tools/compare_images.py` e o próprio `handoff_checksums.txt` como `-text`: com o `core.autocrlf=true` do Git for Windows, sem isso um checkout trocaria LF por CRLF e quebraria os checksums (simulado: commit + clone → checksums 131/131 OK, assets e cópias idênticos).
- [x] 0.1 Branch criado (se houver git)
  — repositório dedicado (confirmado pelo usuário em 23/09/2026) em `app_livros/`, branch `feat/inicio-pixel-perfect` (sem commits até a aprovação da fase). O git que envolvia a pasta era o da pasta pessoal (`C:/Users/T-Gamer`, branch `feature/navigation-and-state`, outro projeto em andamento) — criar o branch lá mexeria nele.
- [x] 0.2 Somente `flutter_riverpod`, `go_router`, `flutter_svg` em produção; versões registradas
  — `pubspec.yaml`/`pubspec.lock`: flutter_riverpod 3.4.3 · go_router 18.0.1 · flutter_svg 2.3.0 (produção); flutter_test (SDK) · flutter_lints 6.0.0 (dev). `cupertino_icons` (padrão do `flutter create`) removido, com o comentário órfão dele.
- [x] 0.2 `analysis_options.yaml` com as regras exigidas
  — `include: package:flutter_lints/flutter.yaml` + `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `prefer_final_locals`, `avoid_print`, `always_declare_return_types`, `require_trailing_commas` = true; `flutter analyze` → No issues found.
- [x] 0.3 36 TTFs + licença OFL copiados sem alteração (checksums iguais aos do pacote)
  — `diff -rq design_handoff/assets assets` sem saída; `assets/fonts/`: 36 `.ttf` + `LICENCAS_FONTES_OFL.txt` = 37 arquivos, sha256 idênticos.
- [x] 0.3 18 SVGs copiados sem alteração
  — `assets/icons/`: 18 `.svg` (14 + 4 `_extrapolado_*` da D-07), sha256 idênticos (mesmo `diff -rq`).
- [x] 0.3 Bloco de fontes do `pubspec_fonts.yaml` aplicado; assets de ícones declarados
  — bloco `fonts:` textualmente idêntico ao de `design_handoff/ferramentas/pubspec_fonts.yaml` (28 famílias, 36 assets, todos existentes); `assets: [assets/icons/, assets/fonts/LICENCAS_FONTES_OFL.txt]`.
- [x] 0.3 Licença OFL registrada no `LicenseRegistry`
  — `lib/main.dart` (`registerFontLicenses`, lê `assets/fonts/LICENCAS_FONTES_OFL.txt`); `test/design_system/font_license_test.dart` verde.
- [x] 0.3 Build debug de um alvo disponível compila
  — `flutter build apk --debug` (exit 0) → `build/app/outputs/flutter-apk/app-debug.apk`; recompilado após a limpeza do `pubspec.yaml`.
- [x] 0.4 Estrutura de pastas criada; `reference_layout.dart`, `reference_layout_w360.dart`, `reference_layout_w430.dart` e `compare_images.py` copiados (e formatados uma vez, se o `dart format --set-exit-if-changed` acusar mudança)
  — árvore da §4.1 com `.gitkeep` só nas pastas vazias (12 em `lib/`, `test/home/`, `test/golden/goldens/`); as 4 cópias são byte a byte iguais ao pacote (`cmp`); `dart format --output=none --set-exit-if-changed test/reference` → 0 mudanças, então não foi preciso formatar.
- [x] 0.5 `load_fonts.dart`, `precache_svgs.dart`, `canvas.dart`, `geometry.dart` (com `expectGeometry`, `layoutRect`, `idsOfSection`, `expectGeometryAgainst`) criados e compilando
  — + `golden_canvas_test_template.dart`. Comparados com o código da Subfase 0.5: iguais após `dart format`, exceto crases no doc comment de `geometry.dart:8` (`'<id>#rot'`), exigidas pelo lint `unintended_html_in_doc_comment`; comportamento idêntico. `flutter analyze` → No issues found.
- [x] 0.6 Teste de fontes: 8/8 casos dentro da tolerância (colar a saída)
  — 8/8: larguras dentro de ±0,10 (maior Δ 0,043) e alturas dentro de ±0,01 (Δ 0,000 em todas). **Decisão do usuário (opção A, 23/09/2026):** a altura é medida por `ascent + descent` de `computeLineMetrics()` (altura exata da caixa de linha do CSS), mantendo ±0,01; `paragraph.height` é conferido contra `round(esperado)`. Motivo: o SkParagraph arredonda a altura de linha para pixel inteiro (`skia/modules/skparagraph/src/Run.h:483-485`, Skia 8df24be6 do Flutter 3.47.2), sem opção pública para desligar — confirmado por 3 verificadores independentes (código-fonte, hipótese alternativa, consequência). Com a medida literal (`paragraph.height` ±0,01) eram 3/8. Desvio do texto literal da F00 ("confira `paragraph.height`"), aprovado pelo usuário. Saída do teste:
  ```
  [fonts_smoke] "Continuar lendo" (Figtree 16 w700 ls 0.0 h 1.2): largura 117.933 (esperado 117.89 ±0.1, Δ 0.043) | altura ascent+descent 19.200 (esperado 19.20 ±0.01, Δ -0.000) | paragraph.height 19.000 (round(esperado) = 19)
  [fonts_smoke] "Boa noite," (Figtree 13 w500 ls 0.0 h 1.2): largura 58.445 (esperado 58.43 ±0.1, Δ 0.015) | altura ascent+descent 15.600 (esperado 15.60 ±0.01, Δ 0.000) | paragraph.height 16.000 (round(esperado) = 16)
  [fonts_smoke] "ENCONTRO" (Figtree 10 w700 ls 1.0 h 1.2): largura 64.640 (esperado 64.63 ±0.1, Δ 0.010) | altura ascent+descent 12.000 (esperado 12.00 ±0.01, Δ 0.000) | paragraph.height 12.000 (round(esperado) = 12)
  [fonts_smoke] "Continue" (Bricolage42 42 w800 ls -1.4 h 0.98): largura 170.715 (esperado 170.69 ±0.1, Δ 0.025) | altura ascent+descent 41.160 (esperado 41.16 ±0.01, Δ 0.000) | paragraph.height 41.000 (round(esperado) = 41)
  [fonts_smoke] "18" (Bricolage34 34 w800 ls -1.0 h 1.0): largura 31.847 (esperado 31.86 ±0.1, Δ -0.013) | altura ascent+descent 34.000 (esperado 34.00 ±0.01, Δ -0.000) | paragraph.height 34.000 (round(esperado) = 34)
  [fonts_smoke] "Também lendo" (Bricolage18 18 w800 ls -0.3 h 1.2): largura 126.535 (esperado 126.54 ±0.1, Δ -0.005) | altura ascent+descent 21.600 (esperado 21.60 ±0.01, Δ -0.000) | paragraph.height 22.000 (round(esperado) = 22)
  [fonts_smoke] "sua história." (InstrumentSerif 50 w400 itálico ls -0.6 h 0.98): largura 219.650 (esperado 219.65 ±0.1, Δ -0.000) | altura ascent+descent 49.000 (esperado 49.00 ±0.01, Δ 0.000) | paragraph.height 49.000 (round(esperado) = 49)
  [fonts_smoke] "Capitu" (InstrumentSerif 36 w400 itálico ls -0.4 h 0.95): largura 86.412 (esperado 86.41 ±0.1, Δ 0.002) | altura ascent+descent 34.200 (esperado 34.20 ±0.01, Δ 0.000) | paragraph.height 34.000 (round(esperado) = 34)
  ```
- [x] 0.7 Comparação identidade = 0,0% em todas as regiões
  — 10/10 regiões com `blur_mismatch_%` = 0,0 e PASSOU (tabela em `F00_comparacao.md`); Python 3.11.9 · Pillow 12.3.0 · numpy 2.4.4.
- [x] 0.7 Controle negativo (1 px) reprovado em todas as regiões
  — cópia deslocada 3 px físicos (1 px lógico) para baixo: 10/10 FALHOU, `blur_mismatch_%` de 3,07 a 15,56 (tabela e comando em `F00_comparacao.md`). Calibração extra: deslocamento de 0,33 px → 10/10 PASSOU.
- [x] `dart format` / `flutter analyze` (0 problemas) / `flutter test` verdes
  — `dart format --set-exit-if-changed lib test` → 11 arquivos, 0 mudanças; `flutter analyze` → No issues found!; `flutter test` → **+9: All tests passed!** (8 fontes + licença). Saídas literais em `F00_verificacao.txt`.
- [x] Relatório no modelo da seção 9 do prompt mestre
  — `RELATORIO_FASE_00.md` (mesmo texto entregue no chat).

## Observações técnicas para a F01 (não são pendências da F00)

Levantadas pelos verificadores do 0.6; valem para o `AppText` qualquer que seja a decisão A/B:
- Só `LineMetrics.ascent`, `LineMetrics.descent` e `Paragraph.alphabeticBaseline` são exatos. `LineMetrics.height` e `LineMetrics.baseline` herdam a altura arredondada (ex.: baseline de "Boa noite," = 12,75 contra 12,35 no CSS).
- Em texto de várias linhas o Skia acumula as alturas arredondadas: "Boa noite," × 4 linhas → 64 contra 62,4 no CSS (+0,4 px por linha).
- Os glifos são pintados na baseline arredondada ao pixel lógico inteiro (`floor(baseline + 0,5)`, `TextLine.cpp:374/381`): desvio medido de −0,44 a +0,50 px. O deslocamento passado ao `drawParagraph` não é arredondado, então a F01 pode compensar.
