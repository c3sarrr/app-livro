## Relatório — FASE 0: Preparação do projeto e do laboratório de fidelidade

### Entregue
- Projeto Flutter `app_leitura` (Android e iOS) criado com `flutter create`: `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `lib/main.dart` (licença OFL no `LicenseRegistry`; nada da tela é desenhado).
- `assets/fonts/` (36 TTFs + `LICENCAS_FONTES_OFL.txt`) e `assets/icons/` (18 SVGs), cópias byte a byte do pacote.
- Estrutura de pastas da §4.1 (`.gitkeep` só nas pastas vazias); `test/reference/reference_layout{,_w360,_w430}.dart` e `tools/compare_images.py`, cópias byte a byte.
- Laboratório de testes: `test/support/load_fonts.dart`, `precache_svgs.dart`, `canvas.dart`, `geometry.dart`, `golden_canvas_test_template.dart`.
- Testes: `test/design_system/fonts_smoke_test.dart` (0.6) e `test/design_system/font_license_test.dart` (0.3.3).
- `.gitattributes`: protege os arquivos que precisam ficar byte a byte iguais ao pacote contra a conversão LF→CRLF do Git for Windows.
- Documentação em `docs/`: `handoff_checksums.txt`, `progresso/FASE_00.md` (checklist com evidências), `F00_versoes.txt`, `F00_flutter_doctor.txt`, `F00_comparacao.md` (tabelas da 0.7) e `F00_verificacao.txt` (saídas literais).

### Checklist (100%)
- [x] 0.1 Versões registradas; projeto criado — evidência: Flutter 3.47.2 · Dart 3.13.2 · doctor com Android toolchain OK (`F00_versoes.txt`, `F00_flutter_doctor.txt`)
- [x] 0.1 `design_handoff/` intacto; checksums gerados — evidência: `sha256sum -c docs/handoff_checksums.txt` → 131/131 OK; também passa após commit + clone simulados
- [x] 0.1 Branch criado — evidência: repositório dedicado em `app_livros/`, branch `feat/inicio-pixel-perfect` (confirmado pelo usuário)
- [x] 0.2 Só `flutter_riverpod` 3.4.3, `go_router` 18.0.1, `flutter_svg` 2.3.0 em produção — evidência: `pubspec.yaml`/`pubspec.lock`; `cupertino_icons` removido
- [x] 0.2 `analysis_options.yaml` — evidência: `flutter_lints` + as 6 regras exigidas; `flutter analyze` → No issues found!
- [x] 0.3 36 TTFs + licença sem alteração — evidência: `diff -rq design_handoff/assets assets` vazio (37 arquivos de fonte/licença)
- [x] 0.3 18 SVGs sem alteração — evidência: o mesmo `diff -rq`, sha256 idênticos
- [x] 0.3 Bloco de fontes aplicado; assets declarados — evidência: bloco `fonts:` textualmente idêntico ao `pubspec_fonts.yaml` (28 famílias, 36 assets)
- [x] 0.3 Licença no `LicenseRegistry` — evidência: `font_license_test.dart` verde
- [x] 0.3 Build debug — evidência: `flutter build apk --debug` → `app-debug.apk` (exit 0)
- [x] 0.4 Estrutura + cópias de referência — evidência: `cmp` idêntico nas 4 cópias; `dart format --set-exit-if-changed test/reference` → 0 mudanças
- [x] 0.5 Arquivos de suporte criados e compilando — evidência: iguais ao código da 0.5, exceto crases num comentário de `geometry.dart:8` (lint `unintended_html_in_doc_comment`, comportamento idêntico); `flutter analyze` limpo
- [x] 0.6 Teste de fontes 8/8 — evidência: larguras Δ ≤ 0,043 (±0,10) e alturas Δ 0,000 (±0,01), saída colada em `FASE_00.md`. Altura medida por `ascent + descent` (opção A aprovada pelo usuário), porque o SkParagraph arredonda `paragraph.height` (`Run.h:483-485`), que agora é conferido contra `round(esperado)`
- [x] 0.7 Identidade — evidência: 10/10 regiões com `blur_mismatch_%` 0,0 e PASSOU
- [x] 0.7 Controle negativo (1 px) — evidência: 10/10 FALHOU (`blur_mismatch_%` 3,07 a 15,56)
- [x] format / analyze / test verdes — evidência: 0 mudanças · No issues found! · `+9: All tests passed!`
- [x] Relatório no modelo da seção 9 — este documento

### Verificação
- Geometria: não se aplica na F00 (nenhum elemento da tela); o harness `expectGeometry`/`layoutRect`/`expectGeometryAgainst` compila.
- Estilo: não se aplica na F00.
- Visual (ferramenta de comparação, Python 3.11.9 · Pillow 12.3.0 · numpy 2.4.4):

  | Região | Identidade (blur %) | Deslocada 1 px (blur %) |
  |---|---:|---:|
  | header | 0,0 PASSOU | 3,453 FALHOU |
  | headline | 0,0 PASSOU | 6,106 FALHOU |
  | hero | 0,0 PASSOU | 10,424 FALHOU |
  | alsoReading | 0,0 PASSOU | 7,288 FALHOU |
  | today | 0,0 PASSOU | 8,957 FALHOU |
  | forYou | 0,0 PASSOU | 7,533 FALHOU |
  | club | 0,0 PASSOU | 8,931 FALHOU |
  | recent | 0,0 PASSOU | 3,069 FALHOU |
  | bottomFade | 0,0 PASSOU | 8,381 FALHOU |
  | nav | 0,0 PASSOU | 15,564 FALHOU |

  Calibração extra (0,33 px): 10/10 PASSOU. Tabelas completas e comandos em `F00_comparacao.md`; PNGs em `build/visual_diff/F00/`, artefatos locais não versionados.
- Texto: 8/8 medidas de fonte dentro da tolerância (0.6).
- flutter analyze: 0 problemas · dart format: ok (11 arquivos, 0 mudanças) · flutter test: 9 passaram.

### Decisões fora do arquivo usadas nesta fase
- D-07: os 4 SVGs `_extrapolado_*` foram copiados junto com os ícones (só são usados na F11).
- Processo, aprovado pelo usuário: 0.6 com a altura medida por `ascent + descent` (opção A) e repositório git dedicado em `app_livros/`.
- Higiene do repositório: `.gitattributes` (`-text`) no handoff, nos assets e nas cópias de referência, para os checksums sobreviverem a checkouts com `core.autocrlf=true`.

### Riscos/pendências
- Nenhuma.
- Informativo, não é pendência: o bundle id segue o provisório do `flutter create` (`com.example.app_leitura` / `com.example.appLeitura`) até sua confirmação (F00 0.1.2). As observações técnicas para o `AppText` da F01 estão em `FASE_00.md`: a baseline é pintada arredondada e as alturas se acumulam em texto multilinha.

✅ FASE 0 concluída — aguardando sua aprovação para iniciar a FASE 1.
