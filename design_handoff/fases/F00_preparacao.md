# FASE 0 — Preparação do projeto e do laboratório de fidelidade

> Pré-requisito: nenhum. Leia antes o `00_PROMPT_MESTRE.md` inteiro.
> Resultado: projeto Flutter pronto, assets oficiais instalados, e um **laboratório de verificação** (fontes carregadas nos testes, geometria, golden, comparação de imagens) funcionando **antes** de qualquer pixel da tela.

---

## Objetivo

Deixar o terreno pronto para que cada fase seguinte possa provar objetivamente que ficou idêntica ao arquivo. Nesta fase **não** se desenha nenhum elemento da tela Início.

---

## Subfase 0.1 — Ambiente e projeto

1. Rode e registre no relatório: `flutter --version`, `dart --version`, `flutter doctor -v` (resumo).
2. Se o repositório **já** contém um app Flutter: não o recrie; analise `pubspec.yaml`, `lib/` e testes existentes e informe o que já existe antes de alterar. Se **não** contém: `flutter create --project-name app_leitura --platforms android,ios .` (o bundle id definitivo será confirmado com o usuário depois; não bloqueia).
3. Confirme que `design_handoff/` está na raiz e **não altere nada dentro dela**. Gere e guarde `docs/handoff_checksums.txt` (`sha256sum` de todos os arquivos de `design_handoff/`) para provar isso na F13.
4. Se houver git: crie o branch `feat/inicio-pixel-perfect`. Ao fim de cada fase aprovada: commit `feat(inicio): fase N — <título>`.

## Subfase 0.2 — Dependências

- Produção: `flutter pub add flutter_riverpod go_router flutter_svg` (últimas estáveis; registre as versões resolvidas).
- Dev: `flutter_lints` (se o projeto não tiver um lint mais rígido).
- **Proibido** adicionar qualquer outra dependência sem perguntar (em especial `google_fonts`, `flutter_screenutil`, pacotes de ícones/UI).
- `analysis_options.yaml`: inclua `package:flutter_lints/flutter.yaml` e ative, no mínimo: `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `prefer_final_locals`, `avoid_print`, `always_declare_return_types`, `require_trailing_commas`.

## Subfase 0.3 — Assets oficiais

1. Copie **sem modificar**:
   - `design_handoff/assets/fonts/*.ttf` → `assets/fonts/` (36 arquivos) + `LICENCAS_FONTES_OFL.txt`.
   - `design_handoff/assets/icons/*.svg` → `assets/icons/` (18 arquivos; os 4 `_extrapolado_*` são da decisão D-07).
2. No `pubspec.yaml`:
   - cole o bloco de `design_handoff/ferramentas/pubspec_fonts.yaml` dentro de `flutter:` (declara as 36 fontes com peso/estilo corretos);
   - declare `assets: - assets/icons/` e `- assets/fonts/LICENCAS_FONTES_OFL.txt`.
3. Registre a licença OFL no app: em `main.dart`, `LicenseRegistry.addLicense` lendo `assets/fonts/LICENCAS_FONTES_OFL.txt` (para a tela de licenças do sistema).
4. Verificação: `flutter pub get` sem erros; compile **um alvo disponível na máquina**: `flutter build apk --debug` (se houver Android SDK) **ou** `flutter build ios --no-codesign --debug` (se macOS + Xcode). Se nenhum dos dois existir no ambiente, `flutter analyze` com **0 problemas** em `lib/` substitui a prova de compilação (nesta fase nenhum teste importa `lib/`, então `flutter test` não compila o app) e o build nativo vira **pendência de ambiente registrada no relatório** (com o comando exato) para o usuário validar — não instale SDKs sem perguntar.

> Por que estas fontes e não as do Google Fonts: o arquivo carrega subsets específicos da Bricolage Grotesque (variável: `opsz` 12–96, `wght` 200–800), Figtree (variável: `wght` 300–900) e Instrument Serif. Os TTFs do pacote foram gerados **desses mesmos binários** (instâncias estáticas com UPM 10000 para não perder precisão). Validação feita no Chromium: largura de texto com desvio máximo de **0,047 px** e rasterização praticamente idêntica. Qualquer outra fonte (inclusive "a mesma" baixada de outro lugar) pode ter versão/métricas diferentes.

## Subfase 0.4 — Estrutura de pastas

Crie a árvore da seção 4.1 do prompt mestre (pastas vazias com `.gitkeep` onde ainda não houver arquivo). Copie:
- `design_handoff/referencia/layout/reference_layout.dart` → `test/reference/reference_layout.dart`
- `design_handoff/referencia/layout/reference_layout_w360.dart` e `reference_layout_w430.dart` → `test/reference/` (usados só na F13)
- `design_handoff/ferramentas/compare_images.py` → `tools/compare_images.py`

Os três `.dart` gerados começam com `// dart format off`, mas o formatador só respeita esse comentário no estilo "tall", que ele escolhe pela **versão de linguagem do pacote** (`environment: sdk` ≥ 3.7 no `pubspec.yaml`), não pelo SDK instalado. Então confira logo após copiar: se `dart format --output=none --set-exit-if-changed test/reference` acusar mudança, rode **uma vez** `dart format test/reference/` — só muda quebras de linha, nunca valores — para que `dart format --set-exit-if-changed` fique verde nas fases seguintes. Nunca edite valores nesses arquivos.

## Subfase 0.5 — Laboratório de testes (código de referência)

Crie os arquivos abaixo. O código é a **referência obrigatória de comportamento**; se a API do seu SDK divergir, adapte mantendo exatamente o comportamento e explique no relatório.

### `test/support/load_fonts.dart`
```dart
import 'dart:convert';

import 'package:flutter/services.dart';

/// Carrega no ambiente de teste TODAS as fontes declaradas no pubspec.
/// Sem isto o flutter_test usa a fonte "Ahem" e nenhuma medida de texto vale.
/// Peso/estilo são lidos do próprio TTF (os arquivos do pacote têm usWeightClass
/// e flags de itálico corretos).
Future<void> loadAppFonts() async {
  final manifest = json.decode(await rootBundle.loadString('FontManifest.json')) as List<dynamic>;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(entry['family'] as String);
    for (final font in (entry['fonts'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}
```

### `test/support/precache_svgs.dart`
```dart
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// O flutter_svg carrega de forma assíncrona; sem pré-cache o golden sai sem ícones.
Future<void> precacheSvgs(WidgetTester tester, Iterable<String> assets) async {
  await tester.runAsync(() async {
    for (final asset in assets) {
      final loader = SvgAssetLoader(asset);
      await svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
    }
  });
}
```

### `test/support/canvas.dart`
```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Configura a "tela" do teste no tamanho LÓGICO do canvas do arquivo (390×2390)
/// com DPR 3, e safe areas zeradas (no canvas o inset de 62 px já é do layout).
void setCanvasView(WidgetTester tester, {Size logical = const Size(390, 2390), double dpr = 3,
    double safeTop = 0, double safeBottom = 0}) {
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = logical * dpr;
  tester.view.viewPadding = FakeViewPadding(top: safeTop * dpr, bottom: safeBottom * dpr);
  tester.view.padding = FakeViewPadding(top: safeTop * dpr, bottom: safeBottom * dpr);
  addTearDown(tester.view.reset);
}

/// Raiz capturada pelos goldens.
const goldenRootKey = ValueKey<String>('golden-root');
```

### `test/support/geometry.dart`
```dart
import 'package:flutter/widgets.dart'; // já exporta rendering.dart (importar os dois gera `unnecessary_import`)
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout.dart';

/// Capas com `transform: rotate(...)` no CSS. Convenção obrigatória:
///  - a Key do id (ex.: 'hero.cover') fica no SLOT de layout (widget SEM rotação, mesmo tamanho da capa);
///  - o filho direto do Transform.rotate leva a Key '<id>#rot'.
/// O retângulo de referência de qualquer descendente é medido no espaço LOCAL do conteúdo rotacionado
/// (o navegador também mede layout ignorando transforms).
const kRotated = {'hero.cover', 'alsoReading.card1.cover', 'alsoReading.card2.cover'};

Rect layoutRect(WidgetTester tester, String id) {
  final finder = find.byKey(ValueKey<String>(id));
  for (final c in kRotated) {
    if (id.startsWith('$c.')) {
      final slot = tester.getRect(find.byKey(ValueKey<String>(c)));
      final rotBox = tester.renderObject<RenderBox>(find.byKey(ValueKey<String>('$c#rot')));
      final box = tester.renderObject<RenderBox>(finder);
      final local = box.localToGlobal(Offset.zero, ancestor: rotBox);
      return (slot.topLeft + local) & box.size;
    }
  }
  return tester.getRect(finder);
}

/// Gate de geometria: compara o retângulo de layout de cada Key com a referência medida no HTML.
/// Vertical ±0,5 px sempre; horizontal ±0,5 px (±1,0 px para ids em kTextDependentX).
void expectGeometry(WidgetTester tester, Iterable<String> ids) {
  final failures = <String>[];
  for (final id in ids) {
    final ref = kRefLayout[id];
    if (ref == null) {
      failures.add('$id: id não existe na referência');
      continue;
    }
    final finder = find.byKey(ValueKey<String>(id));
    final count = finder.evaluate().length;
    if (count != 1) {
      failures.add('$id: esperado exatamente 1 widget com esta Key, encontrados $count');
      continue;
    }
    final r = layoutRect(tester, id);
    final tolX = kTextDependentX.contains(id) ? 1.0 : 0.5;
    void check(String what, double got, double exp, double tol) {
      if ((got - exp).abs() > tol + 1e-6) {
        failures.add('$id.$what: obtido ${got.toStringAsFixed(2)} | esperado ${exp.toStringAsFixed(2)} | tol ±$tol');
      }
    }
    check('x', r.left, ref.rect.left, tolX);
    check('w', r.width, ref.rect.width, tolX);
    check('y', r.top, ref.rect.top, 0.5);
    check('h', r.height, ref.rect.height, 0.5);
  }
  expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
}

/// Ids de uma seção (todos os não-inline), para usar nas fases.
Iterable<String> idsOfSection(String section) =>
    kRefLayout.entries.where((e) => e.value.section == section).map((e) => e.key);

/// Gate secundário da F13 (larguras 360 e 430): compara com um mapa id → Rect
/// (`kRefLayoutW360` / `kRefLayoutW430`), mesma tolerância em x, y, w e h.
void expectGeometryAgainst(WidgetTester tester, Map<String, Rect> ref, {double tol = 1.0}) {
  final failures = <String>[];
  ref.forEach((id, exp) {
    final count = find.byKey(ValueKey<String>(id)).evaluate().length;
    if (count != 1) {
      failures.add('$id: esperado exatamente 1 widget com esta Key, encontrados $count');
      return;
    }
    final r = layoutRect(tester, id);
    for (final (what, got, e) in [
      ('x', r.left, exp.left),
      ('y', r.top, exp.top),
      ('w', r.width, exp.width),
      ('h', r.height, exp.height),
    ]) {
      if ((got - e).abs() > tol + 1e-6) {
        failures.add('$id.$what: obtido ${got.toStringAsFixed(2)} | esperado ${e.toStringAsFixed(2)} | tol ±$tol');
      }
    }
  });
  expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
}
```
> A verificação de **linhas de texto** (quebras, baseline, início/fim) é adicionada na F01, junto do `AppText`.

### `test/support/golden_canvas_test_template.dart` (modelo usado a partir da F02)
```dart
// Modelo: na F02 crie test/home/golden_canvas_test.dart com este conteúdo (descomentado).
// Cada fase gera/atualiza o PNG do canvas inteiro (--update-goldens) e compara o retângulo
// da seção com a referência via tools/compare_images.py (ordem dos comandos: prompt mestre §7).
//
// testWidgets('golden canvas', (tester) async {
//   setCanvasView(tester);
//   await precacheSvgs(tester, AppIcons.all);
//   await tester.pumpWidget(const ProviderScope(child: RepaintBoundary(key: goldenRootKey, child: App.forTests())));
//   await tester.pumpAndSettle();
//   await expectLater(find.byKey(goldenRootKey), matchesGoldenFile('../golden/goldens/inicio_canvas@3x.png'));
// });
```

## Subfase 0.6 — Prova de fontes (teste que tem que passar AGORA)

Crie `test/design_system/fonts_smoke_test.dart`. Para cada caso abaixo, faça layout de um `ui.Paragraph` (via `ui.ParagraphBuilder`, **sem** `Text`/`TextPainter`) com largura infinita, `TextLeadingDistribution.even`, e confira `paragraph.maxIntrinsicWidth` e `paragraph.height`. Os valores esperados foram medidos no HTML original (largura inclui o letter-spacing após o último caractere, como no navegador).

| Texto | Família (asset) | Tamanho | Peso | letterSpacing | height | Largura esperada (±0,10) | Altura esperada (±0,01) |
|---|---|---|---|---|---|---|---|
| `Continuar lendo` | Figtree | 16 | w700 | 0 | 1.2 | 117.89 | 19.20 |
| `Boa noite,` | Figtree | 13 | w500 | 0 | 1.2 | 58.43 | 15.60 |
| `ENCONTRO` | Figtree | 10 | w700 | 1.0 | 1.2 | 64.63 | 12.00 |
| `Continue` | Bricolage42 | 42 | w800 | -1.4 | 0.98 | 170.69 | 41.16 |
| `18` | Bricolage34 | 34 | w800 | -1.0 | 1.0 | 31.86 | 34.00 |
| `Também lendo` | Bricolage18 | 18 | w800 | -0.3 | 1.2 | 126.54 | 21.60 |
| `sua história.` | InstrumentSerif (itálico) | 50 | w400 | -0.6 | 0.98 | 219.65 | 49.00 |
| `Capitu` | InstrumentSerif (itálico) | 36 | w400 | -0.4 | 0.95 | 86.41 | 34.20 |

Se algum caso falhar: **pare**. Não prossiga com fontes erradas (causas típicas: fonte não declarada, peso errado no pubspec, família da Bricolage errada para o tamanho, `loadAppFonts()` não chamado em `setUpAll`).

## Subfase 0.7 — Prova da ferramenta de comparação

1. `python3 -m pip install pillow numpy` (registre as versões).
2. Compare a referência com ela mesma:
   `python3 tools/compare_images.py --flutter design_handoff/referencia/png/inicio_canvas_390x2390@3x.png --ref design_handoff/referencia/png/inicio_canvas_390x2390@3x.png --scale 3 --layout design_handoff/referencia/layout/layout_inicio.json --out build/visual_diff/F00 --name identidade`
   → todas as regiões com `blur_mismatch_% = 0.0` e `PASSOU`.
3. Controle negativo: gere uma cópia da referência deslocada 3 px físicos para baixo (1 px lógico) e compare → **todas** as seções devem `FALHAR`. Anexe a tabela ao relatório (prova de que o gate detecta deslocamento de 1 px).

---

## Checklist de aceite da FASE 0

- [ ] 0.1 Versões do Flutter/Dart registradas; projeto criado ou existente analisado e relatado
- [ ] 0.1 `design_handoff/` intacto; `docs/handoff_checksums.txt` gerado
- [ ] 0.1 Branch criado (se houver git)
- [ ] 0.2 Somente `flutter_riverpod`, `go_router`, `flutter_svg` em produção; versões registradas
- [ ] 0.2 `analysis_options.yaml` com as regras exigidas
- [ ] 0.3 36 TTFs + licença OFL copiados sem alteração (checksums iguais aos do pacote)
- [ ] 0.3 18 SVGs copiados sem alteração
- [ ] 0.3 Bloco de fontes do `pubspec_fonts.yaml` aplicado; assets de ícones declarados
- [ ] 0.3 Licença OFL registrada no `LicenseRegistry`
- [ ] 0.3 Build debug de um alvo disponível compila — ou, sem Android SDK/Xcode no ambiente, `flutter analyze` 0 problemas + pendência de ambiente registrada
- [ ] 0.4 Estrutura de pastas criada; `reference_layout.dart`, `reference_layout_w360.dart`, `reference_layout_w430.dart` e `compare_images.py` copiados (e formatados uma vez, se o `dart format --set-exit-if-changed` acusar mudança)
- [ ] 0.5 `load_fonts.dart`, `precache_svgs.dart`, `canvas.dart`, `geometry.dart` (com `expectGeometry`, `layoutRect`, `idsOfSection`, `expectGeometryAgainst`) criados e compilando
- [ ] 0.6 Teste de fontes: 8/8 casos dentro da tolerância (colar a saída)
- [ ] 0.7 Comparação identidade = 0,0% em todas as regiões
- [ ] 0.7 Controle negativo (1 px) reprovado em todas as regiões
- [ ] `dart format` / `flutter analyze` (0 problemas) / `flutter test` verdes
- [ ] Relatório no modelo da seção 9 do prompt mestre

**Ao concluir: entregue o relatório e PARE.**
`✅ FASE 0 concluída — aguardando sua aprovação para iniciar a FASE 1.`
