# G12 — Plano de implementação (telas 20 e 26b: controles, chip, marcador, tema Noite, busca)

> **Para quem executa:** seguir tarefa por tarefa (`superpowers:executing-plans`), com TDD: teste que falha →
> código mínimo → teste verde → commit. Desenho aprovado: `docs/progresso/G12.md` (D-117…D-124).

**Objetivo:** com o toque no centro, abrir sobre a página os controles das telas 20/26b idênticos às pranchas
(véu, ilha de cima, chip de tempo, ilha de baixo), com marcador, Tema (Creme ↔ Noite), barra de posição, busca no
livro e os avisos das próximas fases — no EPUB e no PDF.

**Arquitetura:** camadas dentro da `ReaderScreen` (página → controles → painel da busca). Um `ReaderChrome`
(aplicação) junta do banco o que as ilhas mostram e avisa quando muda. A sessão da G11 ganha salto, marcador e
Tema; o documento ganha salto por página, rascunho de marcador, troca da cor do texto, marca da busca e a busca.

**Tecnologia:** Flutter 3.47.2 / Dart 3.13.2, Riverpod 3, go_router 18, drift, `dart:ui`, `pdfrx` 2.6.5
(`PdfPageText.fullText`/`charRects`), `dart:isolate` (busca no EPUB), fonttools (subconjunto do "≈").

**Fluxo de trabalho (o mesmo das fases anteriores):**
- editar no espelho `/home/claude/g03/repo`;
- `./ciclo.sh <arquivos>` gera o zip; `device_commit_files` leva o zip a `tools\medicao\tmp\`;
- `rodar.ps1 -Nome … -Cmd "expandir … && dart format lib test && flutter analyze && flutter test <testes>"` e ler o `.log`/`.fim`;
- puxar de volta o que o `dart format` mudou (`device_stage_files` + `puxar.sh`);
- commit no Windows com `git commit -F tools/medicao/tmp/msg_*.txt`, mensagens em português `tipo(escopo): descrição` e as 2 linhas de coautoria;
- nunca deixar `.dart` em `tools/medicao/tmp` (o `flutter analyze` lê); mudou asset → tocar o `pubspec.yaml`.

---

## Mapa de arquivos

| Arquivo | Responsabilidade | Tarefa |
|---|---|---|
| `lib/core/design_system/widgets/neo_box.dart` (mod.) | `shadowColor` (sombra `#0B0A08` no Noite) | 1 |
| `lib/core/design_system/widgets/pressable.dart` (mod.) | `toggled` (fita) e `enabled` (Fonte no PDF) na semântica | 1 |
| `lib/core/design_system/widgets/app_svg.dart` (mod.) | `opacity` (esmaecer sem trocar as cores do ícone) | 1 |
| `lib/core/design_system/tokens/app_colors.dart` (mod.) | tokens medidos das ilhas (claros e Noite) | 2 |
| `lib/features/reader/presentation/reader_chrome_palette.dart` | `ReaderChromePalette.of/lerp/faded` | 2 |
| `pubspec.yaml` (mod.) | Bricolage 17, Literata 17/19 estáticas, `BookNestApprox` | 3 |
| `tools/fontes/gerar_aprox_inter.py` + `assets/fonts/BookNestApprox-Bold.ttf` + `assets/fonts/OFL-Inter.txt` | glifo "≈" da Inter Bold (D-54) | 3 |
| `lib/core/design_system/tokens/app_typography.dart` (mod.) | `bricolageOpsz` + 17, `AppFonts.literata`, fallback do "≈", estilos das ilhas | 3 |
| `lib/core/design_system/tokens/app_icons_leitor.dart` (mod.) + 2 SVGs `_extrapolado_ic_ribbon_empty(_noite).svg` | ícones da G12 | 4 |
| `lib/features/reader/layout/reader_typography.dart` (mod.) | `withInk` | 5 |
| `lib/features/reader/layout/display_page.dart` (mod.) | `rectsOf(unit, from, to)` | 5 |
| `lib/features/reader/layout/page_snapshot.dart` (mod.) | `rectsOf` (o cálculo do `linkAt` extraído) | 5 |
| `lib/features/reader/application/reader_document.dart` (mod.) | `author`, `totalChars`, `markOfRefPage`, `bookmarkHere`, `recolor`, `found`/`showFound`, `search` | 6, 16 |
| `lib/features/reader/application/epub_reader_document.dart` (mod.) | EPUB das novidades | 6, 16 |
| `lib/features/reader/application/pdf_reader_document.dart` (mod.) | PDF das novidades (texto e `charRects` da página) | 6, 16 |
| `lib/features/reader/application/reading_speed_source.dart` | `readingSpeedOf(db, userId)` (D-97) | 7 |
| `lib/features/reader/application/reader_chrome.dart` | `ReaderChrome`: marcador, contador, minutos, tempo restante | 7 |
| `lib/features/reader/application/reader_session_controller.dart` (mod.) | `physical`, `jumpTo`, `toggleBookmark`, `toggleTheme`, `paper`, `minutesToday`, `speed` | 8 |
| `lib/features/reader/presentation/reader_states.dart` (mod.) | texto do livro físico (D-123); cores do Noite | 8, 14 |
| `lib/features/home/domain/models.dart`, `data/local_home_repository.dart`, `presentation/home_screen.dart` (mod.) | "Continuar lendo" de livro físico → página do livro | 9 |
| `lib/features/reader/presentation/reader_page_view.dart` (mod.) | `controlsOpen`, `onDragStarted`, marca da busca | 10 |
| `lib/features/reader/presentation/reader_chrome_scope.dart` | paleta + esmaecimento das camadas (`InheritedWidget`) | 11 |
| `lib/features/reader/presentation/top_island.dart` | `r20.topIsland` | 11 |
| `lib/features/reader/presentation/time_chip.dart` | `r20.timeChip` | 11 |
| `lib/features/reader/presentation/scrubber.dart` | barra de posição (hachura, onda, botão, balão) | 12 |
| `lib/features/reader/presentation/bottom_island.dart` | `r20.bottomIsland` (barra, progresso, ferramentas, contador) | 13 |
| `lib/features/reader/presentation/reader_controls.dart` | camada dos controles (véu + ilhas + chip, 150 ms, posições D-124) | 14 |
| `lib/features/reader/presentation/reader_overlays.dart` (mod.) | sai o "Fechar" provisório; pílulas com as cores do tema; pílula "Chega numa próxima fase" | 14 |
| `lib/features/reader/presentation/reader_screen.dart` (mod.) | camadas, Voltar, Tema animado, barra de status, busca | 14, 17 |
| `lib/features/reader/application/book_search.dart` | dobrar sem acento/caixa, achar, trecho, `searchTexts`, busca do EPUB num isolate | 15, 16 |
| `lib/features/reader/presentation/book_search_panel.dart` | painel da busca (D-120) | 17 |
| `test/support/dados_t20.dart` | o Dom Casmurro do mundo com as sessões, marcadores e anotações do mundo (D-34) | 18 |
| `test/features/reader/presentation/l20_test.dart`, `l26b_test.dart`, `test/golden/leitor_20_test.dart`, `leitor_26b_test.dart`, `test/golden/capturas_g12_test.dart` | fases L e goldens | 18, 19 |

---

## G12.1 — Cores, letras e ícones

### Tarefa 1: `NeoBox.shadowColor`, `Pressable.toggled/enabled`, `AppSvg.opacity/height`

**Arquivos:** `neo_box.dart`, `pressable.dart`, `app_svg.dart`; teste `test/design_system/g12_primitivos_test.dart`.

- [ ] **Passo 1 — teste que falha:**

```dart
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pressable.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sombra dura com cor própria (Noite: #0B0A08); padrão continua a tinta', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: Column(children: [
        NeoBox(key: ValueKey('a'), width: 10, height: 10, shadow: Offset(3, 3)),
        NeoBox(key: ValueKey('b'), width: 10, height: 10, shadow: Offset(3, 3), shadowColor: Color(0xFF0B0A08)),
      ]),
    ));
    BoxShadow sombra(String k) => ((tester.widget<Container>(find.descendant(
          of: find.byKey(ValueKey(k)), matching: find.byType(Container))).decoration! as BoxDecoration)
        .boxShadow!).single;
    expect(sombra('a').color, AppColors.ink);
    expect(sombra('b').color, const Color(0xFF0B0A08));
    expect(sombra('b').blurRadius, 0);
  });

  testWidgets('Pressable: estado de alternância e desabilitado na semântica', (tester) async {
    final h = tester.ensureSemantics();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Column(children: [
        Pressable(key: const ValueKey('fita'), semanticsLabel: 'Página marcada', toggled: true, onTap: () {},
            child: const SizedBox(width: 44, height: 44)),
        const Pressable(key: ValueKey('fonte'), semanticsLabel: 'Fonte', enabled: false,
            child: SizedBox(width: 44, height: 44)),
      ]),
    ));
    expect(tester.getSemantics(find.byKey(const ValueKey('fita'))),
        isSemantics(label: 'Página marcada', isButton: true, hasToggledState: true, isToggled: true, hasTapAction: true));
    expect(tester.getSemantics(find.byKey(const ValueKey('fonte'))),
        isSemantics(label: 'Fonte', isButton: true, hasEnabledState: true, isEnabled: false, hasTapAction: false));
    h.dispose();
  });

  testWidgets('AppSvg.opacity esmaece sem trocar as cores (modulate com branco a alfa)', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: AppSvg('assets/icons/leitor/ic_arrow_left.svg', size: 20, opacity: 0.5),
    ));
    final f = tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter;
    expect(f, const ColorFilter.mode(Color.fromRGBO(255, 255, 255, 0.5), BlendMode.modulate));
  });
}
```

- [ ] **Passo 2 — rodar e ver falhar** (`shadowColor`, `toggled`, `enabled`, `opacity` não existem).

- [ ] **Passo 3 — código:**
  - `NeoBox`: `this.shadowColor = AppColors.ink` no construtor, `final Color shadowColor;` e `color: shadowColor` no `BoxShadow`.
  - `Pressable`: `this.toggled, this.enabled = true` (`final bool? toggled; final bool enabled;`); no `Semantics`:
    `toggled: widget.toggled, enabled: widget.enabled ? null : false, onTap: widget.enabled ? widget.onTap : null`;
    no `GestureDetector`: `onTap: widget.enabled ? widget.onTap : null` (e `onTapDown` só se `enabled`).
  - `AppSvg`: `this.opacity` (`final double? opacity;`) e `this.height` (ícone não quadrado: a fita 22×24 —
    `SizedBox(width: size, height: height ?? size)`). `color` continua com `srcIn`; sem `color` e com
    `opacity < 1`: `ColorFilter.mode(Color.fromRGBO(255, 255, 255, opacity), BlendMode.modulate)`.

- [ ] **Passo 4 — verde** (este teste + `test/design_system/` + `test/home/` inteiros: as sombras da Início não mudam).

- [ ] **Passo 5 — commit:** `feat(design): sombra com cor, estado de alternância e esmaecer ícone (G12.1)`.

### Tarefa 2: tokens das ilhas e `ReaderChromePalette`

**Arquivos:** `app_colors.dart`, `reader_chrome_palette.dart`; teste `test/features/reader/presentation/reader_chrome_palette_test.dart`.

- [ ] **Passo 1 — teste que falha** (valores das tabelas da L20a/L20b/L26b):

```dart
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

String hex(Color c) => c.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0');

void main() {
  test('Creme (tela 20): ilhas, véu do papel a 62 %, hachura, balão, tracejado', () {
    final p = ReaderChromePalette.of(ReaderPaper.creme);
    expect(p.night, isFalse);
    expect((p.veil.r, p.veil.g, p.veil.b), (248 / 255, 241 / 255, 228 / 255));
    expect(p.veil.a, closeTo(0.62, 1e-9));
    expect([p.island, p.border, p.shadow, p.well, p.title, p.muted].map(hex),
        ['FFFFFAF1', 'FF1A1714', 'FF1A1714', 'FFF7F0E3', 'FF1A1714', 'FF5B544B']);
    expect([p.hatch, p.hatchBase, p.bubble, p.bubbleText, p.dash, p.disabled].map(hex),
        ['FFE9DFCC', 'FFFFFAF1', 'FF1A1714', 'FFF7F0E3', 'FFCFC3AE', 'FFA89D8B']);
  });

  test('Branco e Sépia: as ilhas da 20; véu e cinza do próprio papel', () {
    final b = ReaderChromePalette.of(ReaderPaper.branco);
    final s = ReaderChromePalette.of(ReaderPaper.sepia);
    expect(hex(b.veil.withValues(alpha: 1)), 'FFFFFDF8');
    expect(hex(s.veil.withValues(alpha: 1)), 'FFEEDDBF');
    expect((hex(b.disabled), hex(s.disabled)), ('FFA9A6A2', 'FFA08E74'));
    expect(hex(s.island), 'FFFFFAF1');
  });

  test('Noite (tela 26b): os tokens medidos, nada invertido', () {
    final p = ReaderChromePalette.of(ReaderPaper.noite);
    expect(p.night, isTrue);
    expect((p.veil.r, p.veil.g, p.veil.b), (20 / 255, 17 / 255, 14 / 255));
    expect(p.veil.a, closeTo(0.55, 1e-9));
    expect([p.island, p.border, p.shadow, p.well, p.title, p.muted].map(hex),
        ['FF2A2520', 'FFEDE3D1', 'FF0B0A08', 'FF1F1B17', 'FFEDE3D1', 'FFB5AA98']);
    expect([p.hatch, p.hatchBase, p.bubble, p.bubbleText, p.dash, p.disabled].map(hex),
        ['FF3A332B', 'FF2A2520', 'FFEDE3D1', 'FF1F1B17', 'FF4A433A', 'FF8A8073']);
  });

  test('lerp vai de uma paleta à outra (Tema em 220 ms) e faded multiplica o alfa', () {
    final a = ReaderChromePalette.of(ReaderPaper.creme);
    final b = ReaderChromePalette.of(ReaderPaper.noite);
    expect(ReaderChromePalette.lerp(a, b, 0), a);
    expect(ReaderChromePalette.lerp(a, b, 1), b);
    expect(ReaderChromePalette.lerp(a, b, 0.5).island, Color.lerp(a.island, b.island, 0.5));
    expect(a.faded(0.5).island.a, closeTo(0.5, 1e-9));
    expect(a.faded(0.5).veil.a, closeTo(0.31, 1e-9));
  });
}
```

- [ ] **Passo 2 — falha.**
- [ ] **Passo 3 — código.** Em `AppColors` (bloco "Leitor — ilhas, G12"): `hatchReader E9DFCC`, `dashReader CFC3AE`,
  `islandNight 2A2520`, `inkNight EDE3D1`, `shadowNight 0B0A08`, `mutedNight B5AA98`, `hatchNight 3A332B`,
  `dashNight 4A433A`, `veilNight 14110E`. `reader_chrome_palette.dart`:

```dart
// G12.1 — cores das ilhas do leitor (telas 20 e 26b): medidas no arquivo (L20a/L20b/L26b), nada calculado por
// inversão. Nos papéis claros as ilhas são as da tela 20 e o véu é o próprio papel a 62 %; no Noite, as da 26b.
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../domain/reader_settings.dart';
import 'reader_palette.dart';

@immutable
final class ReaderChromePalette {
  const ReaderChromePalette({
    required this.night,
    required this.veil,
    required this.island,
    required this.border,
    required this.shadow,
    required this.well,
    required this.title,
    required this.muted,
    required this.hatch,
    required this.hatchBase,
    required this.bubble,
    required this.bubbleText,
    required this.dash,
    required this.disabled,
  });

  factory ReaderChromePalette.of(ReaderPaper p) {
    if (p == ReaderPaper.noite) {
      return ReaderChromePalette(
        night: true,
        veil: AppColors.veilNight.withValues(alpha: 0.55),
        island: AppColors.islandNight,
        border: AppColors.inkNight,
        shadow: AppColors.shadowNight,
        well: AppColors.paperNight,
        title: AppColors.inkNight,
        muted: AppColors.mutedNight,
        hatch: AppColors.hatchNight,
        hatchBase: AppColors.islandNight,
        bubble: AppColors.inkNight,
        bubbleText: AppColors.paperNight,
        dash: AppColors.dashNight,
        disabled: AppColors.readerFooterNight,
      );
    }
    final paper = ReaderPalette.of(p);
    return ReaderChromePalette(
      night: false,
      veil: paper.paper.withValues(alpha: 0.62),
      island: AppColors.surface,
      border: AppColors.ink,
      shadow: AppColors.ink,
      well: AppColors.paper,
      title: AppColors.ink,
      muted: AppColors.inkMuted,
      hatch: AppColors.hatchReader,
      hatchBase: AppColors.surface,
      bubble: AppColors.ink,
      bubbleText: AppColors.paper,
      dash: AppColors.dashReader,
      disabled: paper.footer,
    );
  }

  final bool night;

  /// Véu da página (`r20.fade`).
  final Color veil;

  /// Fundo, borda e sombra dura das ilhas (e do botão da barra).
  final Color island, border, shadow;

  /// Fundo do círculo do fechar e das caixas das ferramentas.
  final Color well;

  /// Título, rótulos e o "62%" (destaque); [muted] = autor e linha de progresso.
  final Color title, muted;
  final Color hatch, hatchBase, bubble, bubbleText, dash;

  /// Ferramenta desabilitada (Fonte no PDF — D-122): a cor do rodapé do papel (D-110).
  final Color disabled;

  /// Todas as cores com o alfa multiplicado por [a] (abrir/fechar em 150 ms sem `Opacity`).
  ReaderChromePalette faded(double a) {
    Color f(Color c) => c.withValues(alpha: c.a * a);
    return ReaderChromePalette(
      night: night,
      veil: f(veil),
      island: f(island),
      border: f(border),
      shadow: f(shadow),
      well: f(well),
      title: f(title),
      muted: f(muted),
      hatch: f(hatch),
      hatchBase: f(hatchBase),
      bubble: f(bubble),
      bubbleText: f(bubbleText),
      dash: f(dash),
      disabled: f(disabled),
    );
  }

  static ReaderChromePalette lerp(ReaderChromePalette a, ReaderChromePalette b, double t) {
    if (t <= 0) return a;
    if (t >= 1) return b;
    Color l(Color x, Color y) => Color.lerp(x, y, t)!;
    return ReaderChromePalette(
      night: t < 0.5 ? a.night : b.night,
      veil: l(a.veil, b.veil),
      island: l(a.island, b.island),
      border: l(a.border, b.border),
      shadow: l(a.shadow, b.shadow),
      well: l(a.well, b.well),
      title: l(a.title, b.title),
      muted: l(a.muted, b.muted),
      hatch: l(a.hatch, b.hatch),
      hatchBase: l(a.hatchBase, b.hatchBase),
      bubble: l(a.bubble, b.bubble),
      bubbleText: l(a.bubbleText, b.bubbleText),
      dash: l(a.dash, b.dash),
      disabled: l(a.disabled, b.disabled),
    );
  }

  @override
  bool operator ==(Object o) =>
      o is ReaderChromePalette &&
      o.night == night && o.veil == veil && o.island == island && o.border == border &&
      o.shadow == shadow && o.well == well && o.title == title && o.muted == muted &&
      o.hatch == hatch && o.hatchBase == hatchBase && o.bubble == bubble &&
      o.bubbleText == bubbleText && o.dash == dash && o.disabled == disabled;

  @override
  int get hashCode => Object.hash(night, veil, island, border, shadow, well, title, muted, hatch,
      hatchBase, bubble, bubbleText, dash, disabled);
}
```

  Também `ReaderPalette.lerp(a, b, t)` (papel, texto, rodapé) em `reader_palette.dart`, com o mesmo padrão.
- [ ] **Passo 4 — verde.** **Passo 5 — commit:** `feat(leitor): cores das ilhas nos papéis claros e no Noite (G12.1)`.

### Tarefa 3: letras — Bricolage 17, Literata estática 17/19, "≈" da Inter Bold (D-54)

**Arquivos:** `tools/fontes/gerar_aprox_inter.py`, `assets/fonts/BookNestApprox-Bold.ttf`, `assets/fonts/OFL-Inter.txt`,
`pubspec.yaml`, `app_typography.dart`; teste `test/design_system/fontes_leitor_g12_test.dart`.

- [ ] **Passo 1 — gerar o subconjunto** (no container, fonttools): baixar a Inter 4.0 do repositório oficial
  (`github.com/rsms/inter`, release v4.0, `extras/ttf/Inter-Bold.ttf`, OFL), e rodar:

```python
# tools/fontes/gerar_aprox_inter.py — D-54: só o glifo "≈" (U+2248) da Inter Bold, numa família própria que a
# Figtree usa quando não tem o glifo. Reprodutível: mesmo arquivo de entrada → mesmos bytes (sem data no 'head').
import sys
from fontTools import subset
from fontTools.ttLib import TTFont

src, dst = sys.argv[1], sys.argv[2]
opts = subset.Options()
opts.unicodes = [0x2248]
opts.layout_features = []
opts.name_IDs = ['*']
opts.notdef_outline = True
opts.recalc_timestamp = False
font = TTFont(src)
subset.Subsetter(opts).populate(unicodes=opts.unicodes) or None
s = subset.Subsetter(opts)
s.populate(unicodes=opts.unicodes)
s.subset(font)
for rec in font['name'].names:
    if rec.nameID in (1, 4, 16):
        rec.string = 'BookNestApprox'
    elif rec.nameID == 6:
        rec.string = 'BookNestApprox-Bold'
font['head'].modified = font['head'].created
font.save(dst)
```

  Saída: `assets/fonts/BookNestApprox-Bold.ttf` + a licença `OFL-Inter.txt` ao lado + uma linha no
  `docs/fontes.md` (origem, versão e sha256 do arquivo de entrada).
- [ ] **Passo 2 — teste que falha** (medidas da prancha 20 com a fonte real; usa `loadAppFonts`):

```dart
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/load_fonts.dart';

double largura(String s, TextStyle st) {
  final p = TextPainter(text: TextSpan(text: s, style: st), textDirection: TextDirection.ltr)..layout();
  return p.width;
}

void main() {
  setUpAll(loadAppFonts);

  test('título da ilha: Bricolage 17/800 (opsz 17), "Dom Casmurro" = 122,31 ±1 (r20.topIsland.title)', () {
    expect(AppFonts.bricolageOpsz, contains(17));
    expect(largura('Dom Casmurro', AppTextStyles.readerIslandTitle), closeTo(122.31, 1.0));
  });

  test('"≈ 2 h 10 min" (Figtree 12,5/700 + "≈" da Inter Bold) = 72,08 ±1 (r20.bottomIsland.progressRow.timeLeft)', () {
    expect(AppTextStyles.readerProgress.fontFamilyFallback, contains('BookNestApprox'));
    expect(largura('≈ 2 h 10 min', AppTextStyles.readerProgress), closeTo(72.08, 1.0));
  });

  test('"Aa" na Literata estática 19/500 (D-104), não na variável', () {
    expect(AppTextStyles.readerToolAa.fontFamily, 'Literata19');
    expect(AppTextStyles.readerToolAa.fontWeight, FontWeight.w500);
  });
}
```

- [ ] **Passo 3 — falha.** **Passo 4 — código:**
  - `pubspec.yaml`: famílias `Bricolage17`, `Bricolage17Ext`, `Bricolage17Vi` (`*-ExtraBold.ttf`, `weight: 800`),
    `Literata17` (`Literata17-Regular.ttf` 400, `Literata17-Medium.ttf` 500) + `Ext`/`Vi`, `Literata19`
    (`Literata19-Medium.ttf` 500) + `Ext`/`Vi`, `BookNestApprox` (`BookNestApprox-Bold.ttf`, `weight: 700`, e o
    mesmo arquivo de novo com `weight: 800`).
  - `AppFonts.bricolageOpsz` ganha 17.
  - `AppFonts.figtreeReader`: `fontFamilyFallback: ['FigtreeExt', 'BookNestApprox']`.
  - `AppFonts.literata(double size, FontWeight weight, {double? height, Color color = AppColors.ink})`: família
    `'Literata${_nome(size)}'` (`17`, `19`; `15.5` → `15_5`), com `Ext`/`Vi` no fallback e um `assert` para os
    pares registrados ({17: 400/500, 19: 500}).
  - `AppTextStyles` (bloco "Leitor — controles, G12"):
    - `readerIslandTitle = AppFonts.bricolage(17, height: 1.1, letterSpacing: -0.3)`;
    - `readerIslandAuthor = AppFonts.figtreeReader(12.5, FontWeight.w600, color: AppColors.inkMuted)`;
    - `readerChip = AppFonts.figtreeReader(12.5, FontWeight.w800)`;
    - `readerBubble = AppFonts.figtreeReader(12.5, FontWeight.w800, color: AppColors.paper)`;
    - `readerProgress = AppFonts.figtreeReader(12.5, FontWeight.w700, color: AppColors.inkMuted).copyWith(fontFeatures: const [FontFeature.tabularFigures()])`;
    - `readerProgressStrong = readerProgress.copyWith(fontWeight: FontWeight.w800, color: AppColors.ink)`;
    - `readerToolLabel = AppFonts.figtreeReader(12, FontWeight.w700)`;
    - `readerToolAa = AppFonts.literata(19, FontWeight.w500)`;
    - `readerBadge = AppFonts.figtreeReader(11, FontWeight.w800)`;
    - `readerPill = AppFonts.figtreeReader(12.5, FontWeight.w800)`;
    - busca: `readerSearchField = AppFonts.figtreeReader(16, FontWeight.w500)`,
      `readerSearchCount = AppFonts.figtreeReader(12.5, FontWeight.w700, color: AppColors.inkMuted)`,
      `readerSearchGroup = AppFonts.figtreeReader(11.5, FontWeight.w800, color: AppColors.inkMuted)`,
      `readerSearchPage = AppFonts.figtreeReader(12, FontWeight.w700, color: AppColors.readerFooter)`,
      `readerSearchExcerpt = AppFonts.literata(17, FontWeight.w400, height: 1.45, color: AppColors.bookText)`.
    As cores são as da Creme; as telas trocam pela paleta com `copyWith(color: …)`.
- [ ] **Passo 5 — verde** (+ `test/design_system/`, `test/home/` — a Início não muda).
- [ ] **Passo 6 — commit:** `feat(design): Bricolage 17, Literata 17/19 estáticas e o "≈" da Inter Bold (G12.1, D-54)`.

### Tarefa 4: ícones da G12 e a fita desmarcada

**Arquivos:** `app_icons_leitor.dart`, `assets/icons/leitor/_extrapolado_ic_ribbon_empty.svg` e
`_extrapolado_ic_ribbon_empty_noite.svg`; teste `test/design_system/leitor_svgs_g12_test.dart`.

- [ ] **Passo 1 — SVGs** (a forma do `ic_ribbon_marked`, só o contorno):

```xml
<svg xmlns="http://www.w3.org/2000/svg" width="22" height="24" viewBox="0 0 22 24"><path d="M4 2h14v20l-7-5-7 5z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.8" stroke-linejoin="round"></path></svg>
```
  (Noite: `fill="#2A2520" stroke="#EDE3D1"`.)
- [ ] **Passo 2 — teste que falha:** todas as constantes novas existem no disco e abrem no `flutter_svg`
  (`SvgStringLoader` + `vg.loadPicture`), com o tamanho do arquivo; as variantes `_noite` têm traço `#EDE3D1`.
- [ ] **Passo 3 — código:** `AppIconsLeitor` ganha `arrowLeftNight`, `search`, `searchNight`, `ribbonMarked`,
  `ribbonMarkedNight`, `ribbonEmpty`, `ribbonEmptyNight`, `sun`, `moon`, `highlighter`, `highlighterNight`,
  `annotate`, `annotateNight`, `toc`, `tocNight`, `timer`, `close`; `all` com todos.
- [ ] **Passo 4 — verde.** **Passo 5 — commit:** `feat(leitor): ícones dos controles e a fita desmarcada (G12.1, D-124)`.

---

## G12.2 — Dados, marcador, Tema e livro físico

### Tarefa 5: `withInk`, retângulos de um trecho na página (`rectsOf`)

**Arquivos:** `reader_typography.dart`, `display_page.dart`, `page_snapshot.dart`, `pdf_reader_document.dart`
(`PdfDisplayPage`); teste `test/features/reader/layout/page_rects_test.dart`.

- [ ] **Passo 1 — teste que falha:**

```dart
// no EPUB real (Dom Casmurro, harness da G11), na página do cap. XXXII:
test('rectsOf: os retângulos das letras de "olhos de Capitu" na página, iguais aos do getBoxesForRange', () async {
  final livro = await LivroNaEstante.domCasmurro();
  addTearDown(livro.close);
  final d = await EpubReaderDocument.open(livro.deps());
  addTearDown(d.dispose);
  await d.goTo((spine: 32, offset: 0));
  final p = d.current as PageSnapshot;
  final texto = p.item.text;
  final a = texto.indexOf('olhos de Capitu');
  final r = p.rectsOf(32, a, a + 'olhos de Capitu'.length);
  expect(r, isNotEmpty);
  // a união fica numa linha só, dentro da caixa do texto
  final u = r.reduce((x, y) => x.expandToInclude(y));
  expect(u.left, greaterThanOrEqualTo(p.typography.sideMargin));
  expect(u.right, lessThanOrEqualTo(p.typography.sideMargin + p.typography.contentWidth + 0.01));
  expect(u.height, lessThan(p.typography.lineHeight + 0.01));
  // o linkAt continua igual (mesmo cálculo extraído)
  expect(p.rectsOf(31, a, a + 5), isEmpty, reason: 'outro item do spine');
  expect(p.rectsOf(32, p.page.end + 10, p.page.end + 20), isEmpty, reason: 'fora da página');
});

test('withInk troca só a cor: layoutKey igual', () {
  const t = ReaderTypography();
  final n = t.withInk(const Color(0xFFE3D9C6));
  expect(n.ink, const Color(0xFFE3D9C6));
  expect(n.layoutKey, t.layoutKey);
  expect((n.fontSize, n.sideMargin, n.topInset, n.bottomInset), (t.fontSize, t.sideMargin, t.topInset, t.bottomInset));
});

test('PDF: rectsOf converte os charRects do PDFium (origem embaixo) para a tela', () {
  final page = PdfDisplayPage.forTest(
    index: 2, rect: const Rect.fromLTWH(8, 100, 374, 529), pageSize: const Size(595, 842),
    text: 'ab', charRects: const [PdfRect(100, 742, 110, 730), PdfRect(110, 742, 120, 730)],
  );
  final r = page.rectsOf(2, 0, 2).single;
  expect(r.left, closeTo(8 + 100 / 595 * 374, 1e-6));
  expect(r.top, closeTo(100 + (842 - 742) / 842 * 529, 1e-6));
  expect(r.right, closeTo(8 + 120 / 595 * 374, 1e-6));
  expect(page.rectsOf(1, 0, 2), isEmpty);
});
```

- [ ] **Passo 2 — falha.**
- [ ] **Passo 3 — código:**
  - `ReaderTypography.withInk(ui.Color ink) => ReaderTypography(fontSize: …, ink: ink)` (todos os campos).
  - `DisplayPage`: `List<ui.Rect> rectsOf(int unit, int from, int to);` — `unit` = item do spine (EPUB) ou página
    (PDF); intervalo no texto do `unit`; só a parte que está na página; coordenadas da tela.
  - `PageSnapshot.rectsOf`: o laço do `linkAt` extraído para `_lineBoxes(LaidText b, TextSlice s, int from, int to)`
    (devolve `(ui.Rect caixa, int linha)`), usado pelo `linkAt` (acerto do dedo) e pelo `rectsOf` (todas as caixas;
    `unit != spine` → vazio).
  - `PdfDisplayPage`: guarda `charRects` (lista de `PdfRect` do `loadStructuredText`, sem `trim` no texto — o
    `spokenText` faz o `trim`) e `pageSize`; `rectsOf` une os retângulos dos caracteres de cada linha
    (mesmo `top` arredondado a 0,5) e converte: `x = rect.left + r.left / w × rect.width`,
    `y = rect.top + (h − r.top) / h × rect.height`. Construtor `forTest` para o teste acima.
- [ ] **Passo 4 — verde** (+ `page_snapshot`/`reader_page_view`/`pdf_reader_document` tests da G11).
- [ ] **Passo 5 — commit:** `feat(leitor): retângulos de um trecho na página e cor do texto sem repaginar (G12.2)`.

### Tarefa 6: o documento ganha salto por página, rascunho do marcador, cor, marca da busca

**Arquivos:** `reader_document.dart`, `epub_reader_document.dart`, `pdf_reader_document.dart`; testes em
`epub_reader_document_test.dart` e `pdf_reader_document_test.dart` (grupo "G12").

Interface nova (`ReaderDocument`):

```dart
/// Autor do livro (ilha de cima).
String get author;

/// Caracteres do livro (tempo restante — D-97; PDF: páginas × 1.500 — D-122).
int get totalChars;

/// O começo da página de referência [refPage] (1…total): barra de posição (D-119).
ReaderMark markOfRefPage(int refPage);

/// O marcador da página mostrada: localizador, página de referência, capítulo e começo da página (D-49).
BookmarkDraft bookmarkHere();

/// Troca a cor do texto sem mudar quebras (Tema — D-121). PDF: nada.
Future<void> recolor(ui.Color ink);

/// A ocorrência da busca marcada na página (D-120) até a próxima virada ou salto.
FoundRange? get found;
void showFound(FoundRange f);
```

com `typedef BookmarkDraft = ({Locator locator, int refPage, int chapterIndex, String excerpt});` e
`typedef FoundRange = ({int unit, int from, int to});`, e o trecho do marcador:

```dart
/// D-49: o começo da página, até 90 caracteres, cortado em palavra, com "…" quando cortado.
String bookmarkExcerpt(String pageText) {
  final t = pageText.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (t.length <= 90) return t;
  final cut = t.lastIndexOf(' ', 90);
  return '${t.substring(0, cut > 40 ? cut : 90).trimRight()}…';
}
```

- [ ] **Passo 1 — testes que falham:**

```dart
group('G12', () {
  test('markOfRefPage: o começo da pág. de referência pelo mapa do índice; fora do intervalo → as pontas', () async {
    final livro = await LivroNaEstante.domCasmurro();
    addTearDown(livro.close);
    final d = await EpubReaderDocument.open(livro.deps());
    addTearDown(d.dispose);
    final idx = livro.index;
    final m = d.markOfRefPage(100);
    expect(idx.globalOffset(m.spine, m.offset), idx.refPages.starts[99]);
    await d.goTo(m);
    expect(d.numbers.refPage, 100);
    expect(d.markOfRefPage(0), d.markOfRefPage(1));
    expect(d.markOfRefPage(99999), d.markOfRefPage(idx.refPagesTotal));
  });

  test('bookmarkHere: localizador da 1ª letra, pág., capítulo e trecho (D-49)', () async {
    // abre no cap. XXXII; o rascunho tem o EpubLocator da posição, refPage = numbers.refPage,
    // chapterIndex = numbersAt(...).chapterIndex e o trecho começa por "Retórica dos namorados"
  });

  test('bookmarkExcerpt: até 90 caracteres cortados em palavra, com "…"', () {
    expect(bookmarkExcerpt('curto'), 'curto');
    final longo = 'palavra ' * 20;
    final e = bookmarkExcerpt(longo);
    expect(e.endsWith('…'), isTrue);
    expect(e.length, lessThanOrEqualTo(91));
    expect(e.contains('  '), isFalse);
  });

  test('recolor: mesma página, mesmo 1º caractere, texto na cor nova; a cor igual não faz nada', () async {
    // goTo(32, 0); antes = d.mark; await d.recolor(Color(0xFFE3D9C6));
    // expect(d.mark, antes); expect((d.current as PageSnapshot).typography.ink, Color(0xFFE3D9C6));
  });

  test('showFound marca até a próxima virada ou salto', () async {
    // d.showFound((unit: 32, from: 10, to: 20)); expect(d.found, isNotNull);
    // await d.turn(PageDirection.forward); expect(d.found, isNull);
    // d.showFound(...); await d.goTo(...); expect(d.found, isNull);
  });

  test('PDF: totalChars = páginas × 1.500; markOfRefPage = página − 1; recolor não faz nada', () async {
    // tamanhos.pdf (3 páginas): totalChars 4500; markOfRefPage(2) = (spine: 0, offset: 1); bookmarkHere:
    // PdfLocator da página, refPage = página + 1, chapterIndex 0, trecho do texto da página
  });
});
```

  (Os corpos com comentário viram código no mesmo padrão do primeiro teste: abrir, agir, conferir os valores
  ditos no comentário.)
- [ ] **Passo 2 — falha.**
- [ ] **Passo 3 — código:**
  - **EPUB:** `author => _deps.book.authorDisplay`; `totalChars => _deps.index.totalChars`;
    `markOfRefPage`: `page = refPage.clamp(1, total)`, `g = index.refPages.starts[page - 1]`,
    `index.spineAt(g)` → `(spine, offset)` (sem item linear → `(spine: _pager.firstSpine, offset: 0)`);
    `bookmarkHere`: `p = _pager.position!`, `text = _pager.contentOf(p.spine)!.item.text`,
    `locator = _deps.keeper.locatorAt(p.spine, p.firstVisible, text)`, `n = numbersAt(index, p.spine, p.firstVisible)`,
    `excerpt = bookmarkExcerpt(current.spokenText)`; `recolor(ink)`: se `ink == _pager.typography.ink` retorna; senão
    `await _pager.relayout(_pager.typography.withInk(ink))` (a página de agora continua pintável até a nova chegar —
    G10 A3; as quebras vêm do cache, porque a cor fica fora da `layoutKey`) e `_announce()`;
    `found`: campo `FoundRange? _found` + `ValueNotifier<int> _marks` somado ao `changes` (`Listenable.merge([pager.changes, images.changes, _marks])`);
    `turn`/`goTo`/`follow` zeram `_found` (e `_marks.value++` se havia).
  - **PDF:** `author => _book.authorDisplay`; `totalChars => pageCount * refPageChars`; `markOfRefPage =>
    (spine: 0, offset: (refPage - 1).clamp(0, pageCount - 1))`; `bookmarkHere`: `_keeper.locatorAt(_at, pageCount)`,
    `refPage: _at + 1`, `chapterIndex: 0`, `excerpt: bookmarkExcerpt(_pages[_at]!.text)`; `recolor`: nada;
    `found` igual ao EPUB (`_changes.value++`).
- [ ] **Passo 4 — verde.** **Passo 5 — commit:** `feat(leitor): salto por página, marcador, cor do texto e marca da busca no documento (G12.2)`.

### Tarefa 7: velocidade da conta e `ReaderChrome`

**Arquivos:** `reading_speed_source.dart`, `reader_chrome.dart`; testes `reading_speed_source_test.dart`,
`reader_chrome_test.dart`.

- [ ] **Passo 1 — testes que falham:**

```dart
test('readingSpeedOf = personalSpeed das sessões vivas da conta, em ordem de início (D-97)', () async {
  final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
  addTearDown(db.close);
  final m = mundoReferencia;
  await m.gravarEm(db); // sem índice gravado: cada livro usa os 1.500 caracteres por página
  final amostras = [
    for (final s in [...m.sessoes]..sort((a, b) => a.startedAt.compareTo(b.startedAt)))
      if (!s.meta.isDeleted && s.meta.userId == m.usuarioId)
        (activeSeconds: s.activeSeconds, pagesViewed: s.pagesViewed, charsPerRefPage: 1500.0),
  ];
  expect(await readingSpeedOf(db, m.usuarioId), closeTo(personalSpeed(amostras), 1e-9));
  expect(await readingSpeedOf(db, 'ninguem'), defaultCharsPerMinute);
});

test('ReaderChrome: fita, contador, minutos e tempo restante vêm do banco e mudam sozinhos', () async {
  // banco com o Dom Casmurro do mundo (dados_t20): marcadores 3/6/159, 12 anotações, sessões do dia
  final chrome = ReaderChrome(
    db: db, userBookId: id, refPage: () => 159, minutes: () async => 18,
    timeLeft: () => const Duration(minutes: 130),
    startTimer: relogio.start, // RelogioDePrazos (fake_reader.dart)
  );
  addTearDown(chrome.dispose);
  await chrome.ready;
  expect((chrome.marked, chrome.notes, chrome.minutesToday), (true, 12, 18));
  expect(chrome.timeLeftLabel, '≈ 2 h 10 min');
  // apagar o marcador da 159 no banco → marked = false (stream)
  // nova anotação viva → 13; 100 anotações → badge "99+" (chrome.badge)
  // refreshMinutes() a cada 60 s só enquanto [ticking] (controles abertos)
});

test('badge do contador: some com 0, "99+" acima de 99 (D-124)', () {
  expect(readerNotesBadge(0), isNull);
  expect(readerNotesBadge(12), '12');
  expect(readerNotesBadge(99), '99');
  expect(readerNotesBadge(100), '99+');
});
```

- [ ] **Passo 2 — falha.**
- [ ] **Passo 3 — código:**
  - `readingSpeedOf(AppDatabase db, String userId)`: as sessões vivas da conta (`started_at`, `active_seconds`,
    `pages_viewed`, `user_book_id`), os caracteres de cada livro indexado (`book_content_index.spine_json`, itens
    lineares) e `refPagesTotal` de cada livro → `SpeedSample`s em ordem de início → `personalSpeed`. É o mesmo
    cálculo do `LocalHomeRepository.read` (a Início não muda nesta fase).
  - `ReaderChrome extends ChangeNotifier`:
    - entradas: `db`, `userBookId`, `int Function() refPage`, `Future<int> Function() minutes`,
      `Duration? Function() timeLeft`, `Timer Function(Duration, void Function()) startTimer`;
    - assina `BookmarksDao.watchForBook` (guarda as páginas marcadas) e `AnnotationsDao.watchForBook`
      (`AnnotationStats.countByKind(...).all`);
    - `bool get marked => _pages.contains(refPage())`; `int get notes`; `String? get badge => readerNotesBadge(notes)`;
    - `int get minutesToday`; `String get chipLabel => '$minutesToday min hoje · contando sozinho'`;
    - `String? get timeLeftLabel` (`null` quando `timeLeft()` é `null`);
    - `set ticking(bool)`: liga/desliga o `refreshMinutes` a cada 60 s (controles abertos — D-124) e já atualiza ao ligar;
    - `pageChanged()` (a tela chama quando a página muda: `marked` e o tempo restante mudam).
- [ ] **Passo 4 — verde.** **Passo 5 — commit:** `feat(leitor): dados das ilhas do leitor vindos do banco (G12.2)`.

### Tarefa 8: sessão — livro físico, salto, marcador, Tema, minutos e tempo restante

**Arquivos:** `reader_session_controller.dart`, `reader_states.dart`; testes no `reader_session_controller_test.dart`
(grupo "G12").

- [ ] **Passo 1 — testes que falham:**

```dart
group('G12', () {
  test('livro físico → ReaderFailed(physical) com o texto da D-123', () async {
    // grava um UserBook format physical; open → state ReaderFailed(physical);
    expect(readerFailureText(ReaderFailure.physical), 'Este livro é físico: não tem arquivo para ler aqui.');
  });

  test('jumpTo guarda a volta como o link (D-119): pílula, alfinete (D-115), 6 s, 2 viradas; marca a ocorrência', () async {
    // abre; final antes = doc.numbers.refPage; await c.jumpTo(doc.markOfRefPage(200), found: (unit: s, from: a, to: b));
    // state.back.refPage == antes; doc.found == (unit: s, from: a, to: b); posição gravada = a de antes (flush)
    // relógio 6 s → back some; timed: false (leitor de tela) → não some com o tempo
  });

  test('jumpTo para a mesma página não guarda volta', () async {});

  test('toggleBookmark: grava com HLC, apaga com deleted_at (tombstone) e grava de novo', () async {
    // await c.toggleBookmark(); BookmarksDao.forBook → 1, refPage = doc.numbers.refPage, excerpt D-49;
    // await c.toggleBookmark(); forBook → 0 e a linha tem deleted_at; versão HLC maior que a anterior
  });

  test('toggleTheme: Creme → Noite → Creme; Sépia → Noite → Sépia (último claro no kv); mesma página e texto na cor nova', () async {
    // sem reader_settings: cria a linha (id = dono) com paper noite; kv 'pref.leitor.papelClaro' = 'creme'
    // c.palette == ReaderPalette.of(noite); (doc.current as PageSnapshot).typography.ink == E3D9C6; doc.mark igual
    // de volta: paper creme; com Sépia gravada antes, volta a Sépia
  });

  test('minutesToday soma a sessão aberta; timeLeft = restante ÷ velocidade, some na última página', () async {
    // mundo: now = agora do mundo; minutos = 18 + a sessão aberta
    // timeLeft = timeLeftFor(((1 - progression) * totalChars).round(), speed)
    // na última página de referência → null
  });
});
```

- [ ] **Passo 2 — falha.**
- [ ] **Passo 3 — código:**
  - `enum ReaderFailure { …, physical }`; `_open`: `BookFileFormat.physical → ReaderFailure.physical`;
    `readerFailureText(physical) = 'Este livro é físico: não tem arquivo para ler aqui.'`.
  - `ReaderPaper get paper` (o papel da última abertura ou do Tema).
  - `Future<bool> jumpTo(ReaderMark to, {FoundRange? found, bool timed = true})` — o miolo do `follow` vira
    `_jump(Future<bool> Function(ReaderDocument d) go, {bool timed, FoundRange? found})` e o `follow` passa a
    usá-lo. `jumpTo` não guarda volta se a página de referência de destino é a mesma de agora.
  - `Future<void> toggleBookmark()`: na fila de navegação; `draft = doc.bookmarkHere()`; procura marcador vivo
    da mesma `refPage` (`BookmarksDao.forBook`); se há → `versioning.write('bookmarks', id, (v) => upsert(b.copyWith(meta: b.meta.deleted(at, v))))`;
    senão → `Bookmark(id: UuidV7Generator().next(), meta: RecordMeta(userId: owner, createdAt: at, updatedAt: at, version: v), userBookId, locator: draft.locator, refPage: draft.refPage, chapterIndex: draft.chapterIndex, excerpt: draft.excerpt)`.
  - `Future<void> toggleTheme()`: `next = paper == noite ? (claro do kv ?? creme) : noite`; se o atual é claro,
    grava `kv['pref.leitor.papelClaro'] = paper.code`; grava `reader_settings` (`forUser(owner)` →
    `copyWith(paper: next, meta: meta.edited(at, v))` ou `ReaderSettings(id: owner, meta: …, paper: next)`) com
    `versioning.write('reader_settings', owner, …)`; `_palette = ReaderPalette.of(next)`; `_typography =
    _typography!.withInk(_palette.text)`; `notifyListeners()`; `await doc.recolor(_palette.text)`.
  - `Future<int> minutesToday()` → `minutesToday(deps.db, userId: owner, now: (deps.now ?? DateTime.now)(), open: _tracker)`.
  - velocidade lida uma vez ao abrir (`readingSpeedOf`), `Duration? timeLeft()`:
    `n = doc.numbers; if (n.refPage >= n.refTotal) return null; return timeLeftFor(((1 - n.progression) * doc.totalChars).round(), speed)`.
- [ ] **Passo 4 — verde.** **Passo 5 — commit:** `feat(leitor): salto com volta, marcador, Tema da conta e livro físico na sessão (G12.2, D-119, D-121, D-123)`.

### Tarefa 9: Início — "Continuar lendo" de livro físico vai à página do livro (D-123)

**Arquivos:** `home/domain/models.dart` (`ContinueReading.format`, padrão `BookFormat.epub`),
`local_home_repository.dart` (preenche pelo `user_books.format`), `home_screen.dart`; teste em
`test/home/home_screen_test.dart` (ou o de navegação da Início).

- [ ] **Passo 1 — teste que falha:** com o livro em leitura físico, tocar "Continuar lendo" empurra
  `AppRoutes.livro(id)`; com EPUB, `AppRoutes.leitor(id)`.
- [ ] **Passo 2 — falha.** **Passo 3 — código:** `onContinueTap: () => withReading((r) => push(r.format == BookFormat.physical ? AppRoutes.livro(r.book.id) : AppRoutes.leitor(r.book.id)))`.
- [ ] **Passo 4 — verde** (+ `test/home/` inteiro e os goldens da Início). **Passo 5 — commit:** `feat(inicio): livro físico abre a página do livro, não o leitor (G12.2, D-123)`.

---

## G12.3 — Controles

### Tarefa 10: a página com os controles abertos e a marca da busca

**Arquivo:** `reader_page_view.dart`; testes no `reader_page_view_test.dart` (grupo "G12").

- [ ] **Passo 1 — testes que falham:**
  - com `controlsOpen: true`, tocar nos terços e no link **não** vira nem segue: chama só `onCenter` (fecha — D-117);
  - com `controlsOpen: true`, o arrasto vira a página como sempre e chama `onDragStarted` no começo;
  - `foundColor` + `document.found` pintam um retângulo arredondado (raio 3) por caixa de `rectsOf`, **antes** do
    texto, na página atual (não na vizinha do arrasto) — conferir com `TestRecordingCanvas`: `drawRRect` com a cor
    `brand` vem antes dos `drawParagraph`;
  - `ReaderPagesPainter.shouldRepaint` muda com `foundColor`.
- [ ] **Passo 2 — falha.**
- [ ] **Passo 3 — código:** `ReaderPageView` ganha `this.controlsOpen = false`, `this.onDragStarted`,
  `this.foundColor`. Em `_tapUp`: `if (widget.controlsOpen) { widget.onCenter(); return; }` antes do link e dos
  terços. Em `_dragStart`: `widget.onDragStarted?.call()`. No pintor: antes de `document.current.paint`,

```dart
final f = document.found;
final color = foundColor;
if (f != null && color != null) {
  final paint = Paint()..color = color;
  for (final r in document.current.rectsOf(f.unit, f.from, f.to)) {
    canvas.drawRRect(RRect.fromRectAndRadius(r.inflate(1), const Radius.circular(3)), paint);
  }
}
```
- [ ] **Passo 4 — verde** (+ todos os testes da `reader_page_view` da G11). **Passo 5 — commit:**
  `feat(leitor): a página com os controles abertos e a marca da busca (G12.3, D-117, D-120)`.

### Tarefa 11: `ReaderChromeScope`, ilha de cima e chip

**Arquivos:** `reader_chrome_scope.dart`, `top_island.dart`, `time_chip.dart`; teste `test/features/reader/presentation/islands_test.dart`.

```dart
// reader_chrome_scope.dart — as cores da camada (já esmaecidas) e o esmaecimento [a] para os ícones.
class ReaderChromeScope extends InheritedWidget {
  const ReaderChromeScope({super.key, required this.palette, required this.brand, required this.a, required super.child});
  final ReaderChromePalette palette;
  final Color brand;
  final double a;
  Color tint(Color c) => c.withValues(alpha: c.a * a);
  static ReaderChromeScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ReaderChromeScope>()!;
  @override
  bool updateShouldNotify(ReaderChromeScope old) => old.palette != palette || old.brand != brand || old.a != a;
}
```

`TopIsland` (`r20.topIsland`, L20a — medidas relativas da tabela):

```dart
class TopIsland extends StatelessWidget {
  const TopIsland({super.key, required this.title, required this.author, required this.marked,
      required this.onClose, required this.onSearch, required this.onBookmark});
  final String title, author;
  final bool marked;
  final VoidCallback onClose, onSearch, onBookmark;

  @override
  Widget build(BuildContext context) {
    final s = ReaderChromeScope.of(context);
    final p = s.palette;
    final night = p.night;
    final side = BorderSide(width: AppStrokes.regular, color: p.border);
    return NeoBox(
      key: const ValueKey('r20.topIsland'),
      height: 62,
      color: p.island,
      border: side,
      radius: BorderRadius.circular(31),
      shadow: AppShadows.hard3,
      shadowColor: p.shadow,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(spacing: 10, children: [
        CircleIconButton(
          key: const ValueKey('r20.topIsland.close'),
          size: 44, color: p.well, border: side,
          icon: AppSvg(night ? AppIconsLeitor.arrowLeftNight : AppIconsLeitor.arrowLeft,
              key: const ValueKey('r20.topIsland.close.icon'), size: 20, opacity: s.a),
          semanticsLabel: 'Fechar o livro', onTap: onClose,
        ),
        Expanded(
          child: Column(
            key: const ValueKey('r20.topIsland.titleBlock'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(title, key: const ValueKey('r20.topIsland.title'),
                  style: AppTextStyles.readerIslandTitle.copyWith(color: p.title), maxLines: 1, ellipsis: true),
              const SizedBox(height: 1),
              AppText(author, key: const ValueKey('r20.topIsland.author'),
                  style: AppTextStyles.readerIslandAuthor.copyWith(color: p.muted), maxLines: 1, ellipsis: true),
            ],
          ),
        ),
        Pressable(
          key: const ValueKey('r20.topIsland.search'),
          semanticsLabel: 'Buscar no livro', onTap: onSearch,
          child: SizedBox.square(dimension: 44, child: Center(child: AppSvg(
              night ? AppIconsLeitor.searchNight : AppIconsLeitor.search,
              key: const ValueKey('r20.topIsland.search.icon'), size: 21, opacity: s.a))),
        ),
        Pressable(
          key: const ValueKey('r20.topIsland.bookmark'),
          semanticsLabel: 'Página marcada', toggled: marked, onTap: onBookmark,
          child: SizedBox.square(dimension: 44, child: Center(child: AppSvg(
              switch ((marked, night)) {
                (true, false) => AppIconsLeitor.ribbonMarked,
                (true, true) => AppIconsLeitor.ribbonMarkedNight,
                (false, false) => AppIconsLeitor.ribbonEmpty,
                (false, true) => AppIconsLeitor.ribbonEmptyNight,
              },
              key: const ValueKey('r20.topIsland.bookmark.icon'), size: 22, height: 24, opacity: s.a))),
        ),
      ]),
    );
  }
}
```

`TimeChip` (`r20.timeChip`, L20c): `Pill(padding: EdgeInsets.fromLTRB(9, 0, 12, 0), color: s.tint(AppColors.sun),
border: BorderSide(width: 1.5, color: s.tint(AppColors.ink)))` com `SizedBox(height: 27)` dentro (30 − 2 × 1,5) e
`Row(mainAxisSize: min, spacing: 6, [AppSvg(AppIconsLeitor.timer, key: 'r20.timeChip.icon', size: 15, opacity: s.a),
AppText(label, style: readerChip.copyWith(color: s.tint(AppColors.ink)))])`; chave `r20.timeChip` no `Pill`;
`ExcludeSemantics` não — o chip é lido ("18 min hoje · contando sozinho").

- [ ] **Passo 1 — testes que falham** (montados sozinhos num `Directionality` + `ReaderChromeScope`, 390 de largura,
  com as fontes do app): medidas relativas da L20a/L20c (`close` em 9,5/9, `titleBlock` 63,5/13,64 × 181, busca
  254,5, fita 308,5; chip 30 de altura, ícone em 10,5/7,5); título longo vira "…" numa linha; fita com
  `isToggled` e o ícone certo nos 4 casos; no Noite as cores da 26b; `a = 0.5` dá alfa 0,5 no fundo da ilha e
  `opacity: 0.5` nos ícones.
- [ ] **Passo 2 — falha.** **Passo 3 — código** (acima). **Passo 4 — verde.**
- [ ] **Passo 5 — commit:** `feat(leitor): ilha de cima e chip de tempo (G12.3, L20a, L20c)`.

### Tarefa 12: barra de posição (`Scrubber`)

**Arquivo:** `scrubber.dart`; teste `test/features/reader/presentation/scrubber_test.dart`.

Geometria (L20b, dentro da ilha): caixa 327 × 26; trilho 16 de altura centralizado, borda 1,5, raio 999, hachura;
preenchimento = `fração × (327 − 3)` a partir da borda interna, altura 13, terminando na onda (10 × 13, `right −5`);
botão 28 com centro em `fração × 327` (borda 2, sombra dura 2/2); balão 28 de altura, centrado no botão, com a
base 30 acima da base da caixa, bico 10 × 10 girado 45° centrado 5 abaixo da base do balão.

```dart
/// Onda do fim do preenchimento: o caminho do arquivo no viewBox 10×15, esticado na altura; traço 1,5 sem escala.
class FillWavePainter extends CustomPainter {
  FillWavePainter({required this.fill, required this.stroke});
  final Color fill, stroke;
  @override
  void paint(Canvas canvas, Size size) {
    final sy = size.height / 15;
    Path p(bool close) {
      final path = Path()..moveTo(close ? 0 : 5, 0);
      if (close) path.lineTo(5, 0);
      path
        ..quadraticBezierTo(9.5, 2.5 * sy, 5, 5 * sy)
        ..quadraticBezierTo(0.5, 7.5 * sy, 5, 10 * sy)
        ..quadraticBezierTo(9.5, 12.5 * sy, 5, 15 * sy);
      if (close) path..lineTo(0, 15 * sy)..close();
      return path;
    }
    canvas
      ..drawPath(p(true), Paint()..color = fill)
      ..drawPath(p(false), Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
  }
  @override
  bool shouldRepaint(FillWavePainter o) => o.fill != fill || o.stroke != stroke;
}

class Scrubber extends StatefulWidget {
  const Scrubber({super.key, required this.page, required this.total, required this.progression, required this.onJump});
  final int page, total;
  final double progression;
  final ValueChanged<int> onJump; // a página de referência ao soltar ou tocar (D-22, D-119)
  ...
}
```

Estado: `_drag` (`double?` fração sob o dedo); `GestureDetector(onHorizontalDragStart/Update/End, onTapUp)`:
fração = `((x) / 327).clamp(0, 1)`; página sob o dedo = `1 + (fração × (total − 1)).round()`; durante o arrasto o
balão mostra "pág. N" dessa página e o preenchimento/botão andam; ao soltar (ou tocar) chama `onJump(N)` se
`N != page` e zera `_drag`. Semântica (Anexo 03 §11, D-124): `Semantics(slider: true, label: 'Posição no livro',
value: 'página $page de $total', increasedValue: …, decreasedValue: …, onIncrease: () => onJump(min(total, page + step)),
onDecrease: () => onJump(max(1, page - step)))` com `step = max(1, (total / 100).round())`; o botão e o balão
ficam fora da semântica (`aria-hidden`). Chaves: `r20.bottomIsland.scrubber`, `.track`, `.fill`, `.fill.wave`,
`.knob`, `.bubble`, `.bubble.tail`.

- [ ] **Passo 1 — testes que falham:** geometria relativa da L20b com `progression 0.62` (os números da tabela:
  trilho 17,5/36,5 × 327 × 16; preenchimento 19/38 × 200,88 × 13; onda 214,88; botão 206,24/30,5; balão com
  centro em 254,28 da ilha (234,24 + 68,09/2 − 14 → a caixa visual 200,2 − 14), base em 27,5; bico); arrastar
  mostra "pág. N" sem chamar `onJump`; soltar chama uma vez com N; tocar no trilho chama; arrastar e voltar à
  mesma página não chama; semântica com valor "página 159 de 256", aumentar/diminuir com passo de 1 % (≥ 1).
- [ ] **Passo 2 — falha.** **Passo 3 — código.** **Passo 4 — verde.**
- [ ] **Passo 5 — commit:** `feat(leitor): barra de posição com balão, salto ao soltar (G12.3, L20b, D-22, D-119)`.

### Tarefa 13: ilha de baixo — progresso, ferramentas e contador

**Arquivo:** `bottom_island.dart`; teste `test/features/reader/presentation/bottom_island_test.dart`.

`BottomIsland(numbers, timeLeftLabel, badge, isPdf, onJump, onTool)` com `enum ReaderTool { font, theme, notes, annotate, toc }`:

- `NeoBox(key: 'r20.bottomIsland', color: island, border 1,5, radius 28, shadow hard3/shadowColor, padding: EdgeInsets.fromLTRB(16, 30, 16, 14))` dentro de `Semantics(container: true, explicitChildNodes: true, label: 'Controles de leitura')`;
- `Column`: `Scrubber` (altura 26) · `SizedBox(8)` · `ProgressRow` · `SizedBox(14)` · `ToolsRow`;
- `ProgressRow` (`r20.bottomIsland.progressRow`): `Row(spaceBetween)` com
  `AppText.rich(TextSpan(children: [TextSpan(text: '62%', style: readerProgressStrong), TextSpan(text: ' do livro · ${total} pág.')]), key: '.position')`
  e `AppText(timeLeftLabel, key: '.timeLeft')` (some quando `null`);
- `ToolsRow` (`r20.bottomIsland.tools`): borda de cima tracejada 1,5 na cor `dash` (pintor `DashedTopBorderPainter`:
  traços 3/3 como o `dashed` do Chromium para 1,5 px — conferido no golden), `padding-top 12`, `Row` de 5
  `Expanded`; cada ferramenta: `Pressable(semanticsLabel: rótulo, enabled: …, onTap: () => onTool(t))` →
  `Column(spacing: 5, [NeoBox(52×44, raio 16, well, borda 1,5, ícone 21 ou "Aa"), AppText(rótulo, readerToolLabel)])`;
- contador: `Positioned(top: -8, right: -8)` dentro de um `Stack(clipBehavior: none)` medido da borda interna
  (−8 − 1,5 do lado de fora da borda), `Pill` 22 de altura, `min-width 22`, `padding 0 5`, `sun`, borda 1,5 tinta,
  `readerBadge`; o rótulo semântico de Grifos vira "Grifos, 12 marcas" (o número lido junto; sem contador: "Grifos");
- rótulos e ícones: Fonte ("Aa" Literata 19/500), Tema (`sun` nos claros, `moon` no Noite), Grifos (`highlighter`),
  "Anotar" com `semanticsLabel: 'Anotar à mão'` (`annotate`), Sumário (`toc`); as variantes `_noite` no Noite;
- PDF (D-122): Fonte com `enabled: false`, borda/"Aa"/rótulo na cor `disabled`.

- [ ] **Passo 1 — testes que falham:** geometria relativa da L20b (`progressRow` 17,5/65,5; `tools` 17,5/94,74 × 76,9;
  as 5 colunas a cada 65,4; caixas 52 × 44 em 24,2/89,6/155/220,4/285,8; contador 189,35/101,74 × 24,15 × 22);
  linhas "62% do livro · 256 pág." (com o "62%" em 800 e tinta) e "≈ 2 h 10 min"; contador some com `badge null`;
  "99+"; `onTool` com cada ferramenta; PDF: Fonte sem ação e `isEnabled: false`; Noite: lua e cores da 26b.
- [ ] **Passo 2 — falha.** **Passo 3 — código.** **Passo 4 — verde.**
- [ ] **Passo 5 — commit:** `feat(leitor): ilha de baixo com progresso, ferramentas e contador (G12.3, L20b, D-118, D-122)`.

### Tarefa 14: camada dos controles na tela

**Arquivos:** `reader_controls.dart`, `reader_overlays.dart`, `reader_states.dart`, `reader_screen.dart`; testes no
`reader_screen_test.dart` (grupo "G12 — controles").

`ReaderControls` (camada 1): `Stack` com
- `Positioned.fill(IgnorePointer(child: ColoredBox(key: 'r20.fade', color: palette.veil)))` (o véu não pega toque:
  quem fecha é a página, Tarefa 10);
- ilha de cima em `left/right 14`, `top: max(54, padding.top + 7)`;
- chip centralizado em `top: topo da ilha + 76`;
- ilha de baixo em `left/right 14`, `bottom: max(30, padding.bottom − 4)`.

Abre e fecha com `TweenAnimationBuilder<double>(tween: Tween(end: open ? 1 : 0), duration: readerFade)`: com
`a = 0` nada é montado; enquanto fecha, `IgnorePointer`. O `ReaderChromeScope` recebe `palette.faded(a)` e `a`.

Na `ReaderScreen`:
- estado `_controls` (bool) e `_search` (bool); `onCenter` → `_controls = !_controls` (sai o `ReaderCloseButton` e o
  `_toggleClose` — D-106 substituída pela D-117); `onDragStarted` → fecha; `ReaderPageView(controlsOpen: _controls,
  foundColor: brand)`;
- `PopScope.onPopInvokedWithResult`: busca aberta → fecha a busca; controles abertos → fecha os controles; senão `_leave()` (D-42);
- barra de status: `_systemUi(immersive: ready && !_controls && !_search)` (D-105) e um
  `AnnotatedRegion<SystemUiOverlayStyle>` com ícones claros no Noite (`MainShell.overlayStyle.copyWith(statusBarIconBrightness: Brightness.light, statusBarBrightness: Brightness.dark)`);
- Tema animado: o fundo usa `TweenAnimationBuilder<ReaderPalette>` (220 ms, `ReaderPalette.lerp`) e a camada usa
  `ReaderChromePalette.lerp` (o texto troca de cor quando a página nova chega — Tarefa 6);
- `ReaderChrome` criado no `ReaderReady` (com `c.minutesToday`, `c.timeLeft`, `() => doc.numbers.refPage`) e
  `ticking = _controls`; `c.addListener` → `chrome.pageChanged()`;
- ferramentas: Tema → `c.toggleTheme()`; Fonte/Grifos/Anotar/Sumário → `_toast('Chega numa próxima fase')`
  (D-118): `ReaderToastPill` (estilo da pílula do link, com as cores da ilha do tema) centralizada 12 acima da ilha de
  baixo, por 2 s (`deps.startTimer`), anunciada com `SemanticsService.sendAnnouncement` quando
  `accessibleNavigation`;
- barra: `onJump: (n) => c.jumpTo(doc.markOfRefPage(n), timed: !accessibleNavigation)`;
- fita: `c.toggleBookmark()`; lupa: `_search = true` (Tarefa 17);
- página para o leitor de tela: a ação "Mostrar os controles" (o centro não é tocável pelo leitor de tela — mesma
  ideia da D-116 para o "Fechar o livro");
- `BackToPagePill` e `ReaderOpeningView`/`ReaderFailureView` com as cores do tema (Noite: ilha `#2A2520`, borda e
  texto `#EDE3D1`).

- [ ] **Passo 1 — testes que falham** (livro do mundo na tela, relógio controlado):
  - toque no centro abre (véu, ilhas e chip na tela; o "Fechar" provisório não existe mais); 150 ms; tocar fora fecha;
    toque nos terços com controles abertos não vira; arrastar vira e fecha;
  - Voltar com controles abertos fecha só os controles; de novo fecha o livro gravando;
  - barra de status: `imersivo` → `padrão` ao abrir, `imersivo` ao fechar; no Noite o `AnnotatedRegion` tem ícones claros;
  - posições D-124 com `viewPadding` de iPhone (47/34 → 54/130/30) e de Android (24/0 → 54/130/30) e um aparelho com
    área de cima 59 (→ 66/142);
  - Tema: tocar "Tema" troca o papel em 220 ms (meio do caminho = `lerp` 0,5), grava (Tarefa 8), o texto muda de cor
    e a página e o rodapé continuam iguais;
  - Fonte/Grifos/Anotar/Sumário: a pílula "Chega numa próxima fase" aparece e some em 2 s; com o leitor de tela é
    anunciada;
  - fita: tocar liga e desliga (banco e `isToggled`);
  - barra: arrastar e soltar salta e mostra a pílula de voltar (que fica coberta pela ilha enquanto os controles
    estão abertos e aparece ao fechar);
  - PDF: Fonte desabilitada; Tema escurece o fundo e as ilhas, e a imagem da página do PDF é a mesma.
- [ ] **Passo 2 — falha.** **Passo 3 — código.** **Passo 4 — verde** (+ todos os testes de tela da G11).
- [ ] **Passo 5 — commits:** `feat(leitor): controles por cima da página com Voltar e barra de status (G12.3, D-117)` e
  `feat(leitor): Tema, fita, barra e avisos das próximas fases na tela (G12.3, D-118, D-119, D-121, D-122)`.

---

## G12.4 — Busca no livro (D-120)

### Tarefa 15: o núcleo da busca

**Arquivo:** `book_search.dart`; teste `test/features/reader/application/book_search_test.dart`.

```dart
/// Texto dobrado para busca (sem acento, sem maiúsculas) e, para cada unidade dobrada, a posição no original.
typedef FoldedText = ({String text, List<int> map});

FoldedText foldForSearch(String s) {
  final out = StringBuffer();
  final map = <int>[];
  for (var i = 0; i < s.length; i++) {
    final c = s.codeUnitAt(i);
    if (c >= 0x0300 && c <= 0x036F) continue; // marcas combinantes (texto decomposto)
    final f = _fold(c);
    out.writeCharCode(f);
    map.add(i);
  }
  return (text: out.toString(), map: map);
}

/// Uma letra: sem acento (tabela Latin-1 + Latin Extended-A) e em caixa baixa; o resto, em caixa baixa.
int _fold(int c) { final b = _base[c]; final x = b ?? c; return String.fromCharCode(x).toLowerCase().codeUnitAt(0); }

/// Ocorrências de [query] em [text] (intervalos no texto original), até [limit].
List<(int, int)> findAll(String text, String query, {int limit = 1 << 30}) {
  final q = foldForSearch(query.trim()).text;
  if (q.length < searchMinChars) return const [];
  final t = foldForSearch(text);
  final out = <(int, int)>[];
  var at = t.text.indexOf(q);
  while (at >= 0 && out.length < limit) {
    out.add((t.map[at], t.map[at + q.length - 1] + 1));
    at = t.text.indexOf(q, at + q.length);
  }
  return out;
}

/// Trecho do resultado (D-120): até 40 caracteres antes e 60 depois, cortados em palavra, com "…";
/// objetos (U+FFFC) e quebras viram espaço. [match] = onde a palavra ficou no trecho.
({String text, int matchStart, int matchEnd}) excerptAround(String text, int start, int end) { … }

const int searchMinChars = 2;
const int searchLimit = 500;
```

`searchTexts(Iterable<int> units, String Function(int unit) textOf, String query, {int limit = searchLimit + 1})`
devolve `Iterable<UnitHits>` (`typedef UnitHits = ({int unit, List<FoundText> hits})`, `typedef FoundText = ({int
start, int end, String excerpt, int matchStart, int matchEnd})`), parando quando o total chega a `limit`.

- [ ] **Passo 1 — testes que falham:**
  - `findAll('Ação e AÇÃO; acao.', 'acao')` → `[(0, 4), (7, 11), (13, 17)]`; `'ç'` acha `'Ç'`; `'olhos de capitu'`
    acha "olhos de Capitu"; texto com `'é'` (decomposto) acha `'e'` com o intervalo cobrindo a marca;
  - 1 letra → nada (mínimo 2); `limit` corta;
  - `excerptAround`: 40 antes/60 depois cortados em palavra, "…" dos dois lados quando corta, `\n` e U+FFFC viram
    espaço, e `matchStart/matchEnd` apontam a palavra no trecho;
  - `searchTexts` para em `limit` somando unidades e mantém a ordem das unidades.
- [ ] **Passo 2 — falha.** **Passo 3 — código.** **Passo 4 — verde.**
- [ ] **Passo 5 — commit:** `feat(leitor): núcleo da busca sem acento e sem maiúsculas, com trecho (G12.4, D-120)`.

### Tarefa 16: busca no documento (EPUB num isolate, PDF por página)

**Arquivos:** `book_search.dart` (runner do isolate), `reader_document.dart`, `epub_reader_document.dart`,
`pdf_reader_document.dart`, `reader_session_controller.dart` (`ReaderDeps.searchRunner`), `reader_harness.dart`;
testes `book_search_document_test.dart`.

```dart
/// Um resultado pronto para a lista e para o salto.
typedef SearchHit = ({ReaderMark at, FoundRange found, int refPage, String excerpt, int matchStart, int matchEnd});
typedef SearchGroup = ({String title, List<SearchHit> hits});

// ReaderDocument:
/// Os resultados de [query] por capítulo (EPUB) ou por página (PDF), à medida que saem; cancelar a assinatura
/// para a busca (D-120).
Stream<SearchGroup> search(String query);
```

- **EPUB:** `EpubSearchRunner = Stream<UnitHits> Function(String path, List<int> spines, String query)`; o padrão
  `isolateEpubSearch` abre um `Isolate.spawn` que abre o EPUB uma vez, roda `searchTexts` com
  `textOf: (s) => chapterOf(book, s).item.text` e manda cada `UnitHits` por `SendPort`; cancelar a assinatura mata o
  isolate. O documento converte cada `UnitHits` em grupos pelo capítulo do sumário (`chapterIndexAt` + título da
  folha; antes da 1ª folha: "Começo do livro"), com `refPage` de `numbersAt` e `at = (spine, start)`; resultados
  seguidos no mesmo capítulo vão no mesmo grupo.
- **PDF:** página a página com `loadStructuredText().fullText`, `searchTexts` numa página por vez com `await
  Future<void>.delayed(Duration.zero)` entre elas; grupo "Pág. N" (o resultado não repete o "pág. N").
- **Harness:** `readerDeps(...)` passa um runner sem isolate (`searchTexts` com `chapterOf(epub, s)`), como o
  `chapterLoader`.

- [ ] **Passo 1 — testes que falham:**
  - Dom Casmurro real: "ressaca" → grupos na ordem do livro; o do cap. XXXII tem os resultados da pág. da posição;
    cada `at` + `found` aponta o texto achado (`chapterOf(epub, at.spine).item.text.substring(found.from, found.to)`
    dobrado == "ressaca");
  - "capitu" acha "Capitu" e "CAPITU"; mais de 500 → para em 501 (a tela mostra 500 e o aviso);
  - cancelar no meio não entrega mais nada (EPUB: runner de teste que espera entre capítulos);
  - o runner do isolate dá o mesmo resultado que o de teste num EPUB pequeno (`simpleEpub`);
  - PDF `tamanhos.pdf`: o texto de uma página achado, grupo "Pág. 2", `found` com `unit` = página.
- [ ] **Passo 2 — falha.** **Passo 3 — código.** **Passo 4 — verde.**
- [ ] **Passo 5 — commit:** `feat(leitor): busca no EPUB num isolate e no texto do PDF (G12.4, D-120)`.

### Tarefa 17: painel da busca

**Arquivos:** `book_search_panel.dart`, `reader_screen.dart`; teste `test/features/reader/presentation/book_search_panel_test.dart`.

`BookSearchPanel(document, palette, initial, onClose, onPick)` (camada 2, tela inteira na cor do papel):
- ilha do campo igual à de cima (`left/right 14`, topo da D-124, 62, raio 31…): ← (`CircleIconButton` "Fechar a
  busca"), `Expanded(TextField)` sem decoração (`readerSearchField`, cursor da cor do título, ajuda "Buscar no livro",
  `autofocus`, `textInputAction: search`), × ("Limpar a busca", só com texto);
- abaixo da ilha (`top + 62 + 16`), `CustomScrollView` com `SliverList`: a contagem ("7 resultados" / "1 resultado" /
  "Mais de 500 resultados. Refine a busca." / "Nada encontrado para “x”." / "Buscando…" depois de 300 ms); por grupo,
  o título em maiúsculas; por resultado, `Pressable` com "pág. N" e o trecho (`AppText.rich`: a palavra com fundo
  `brand` — `TextSpan(style: readerSearchExcerpt.copyWith(background: Paint()..color = brand))`), tracejado entre
  resultados (o pintor da Tarefa 13);
- digitação: espera 250 ms parado; menos de 2 letras limpa; nova busca cancela a anterior (`StreamSubscription.cancel`);
- `initial` = a última busca e os resultados (guardados na tela enquanto o livro está aberto);
- tocar num resultado → `onPick(hit)`: a tela fecha o painel e os controles e chama
  `c.jumpTo(hit.at, found: hit.found, timed: !accessibleNavigation)`.

- [ ] **Passo 1 — testes que falham:** abrir pela lupa; teclado/foco no campo; digitar "re" e esperar 249 ms → nada;
  250 ms → resultados; "Buscando…" só depois de 300 ms; contagem no singular/plural; "Nada encontrado para “xyz”.";
  501 → "Mais de 500…" com 500 itens; × limpa; ← e Voltar fecham o painel (os controles continuam abertos); reabrir
  mostra a última busca; tocar num resultado → página do resultado, a palavra marcada (Tarefa 10), pílula de voltar,
  controles fechados; virar apaga a marca; no Noite o painel usa as cores da 26b.
- [ ] **Passo 2 — falha.** **Passo 3 — código.** **Passo 4 — verde.**
- [ ] **Passo 5 — commit:** `feat(leitor): painel da busca no livro (G12.4, D-120)`.

---

## G12.5 — Fases L20/L26b, verificação e relatório

### Tarefa 18: o mundo da tela 20 no banco e as fases L20a, L20b, L20c e L26b

**Arquivos:** `test/support/dados_t20.dart`, `test/features/reader/presentation/l20_test.dart`, `l26b_test.dart`.

- `livroDaTela20({ReaderPaper papel = ReaderPaper.creme})`: o `livroDaTela19()` + as linhas do mundo no banco do
  harness, com os ids do harness no lugar dos do mundo (dono `usuarioTeste`, livro `livro.userBookId`):
  sessões da conta (para os 18 min de hoje), marcadores do Dom Casmurro (3, 6, 159), anotações e camadas de tinta do
  Dom Casmurro (12 = 6 + 2 + 1 + 3) e `reader_settings` com o papel; o relógio do teste = `mundoReferencia.agora`.
- A velocidade injetada (desvio registrado no `G12.md`): `restantes / 130` caracteres por minuto, para a conta dar o
  "≈ 2 h 10 min" que a prancha escreve à mão (pela velocidade real o mundo dá ~1 h 10 min — G10).
- Os testes abrem pela rota real, tocam no centro e esperam os 150 ms:
  - **geometria:** todos os ids de `kRef20.idsOfSection(...)` das seções `r20.page`, `r20.footer`, `r20.fade`,
    `r20.topIsland`, `r20.bottomIsland`, `r20.timeChip` (±0,5; ±1,0 em x/w nos `textDependentX`); elementos com
    `visual` comparam com o `visual` (chip, ícone do chip, balão); o bico compara com o `rect` deslocado como o balão;
  - **texto:** linhas e baselines (`lines`/`linesAll`) do título, autor, chip, balão, progresso e rótulos;
  - **estilo:** cores, bordas (1,5/2), raios (31/28/16/10/999), sombras duras (3/3, 2/2; cor da tinta ou `#0B0A08`),
    fontes (Bricolage 17/800, Figtree 12,5/800·700·600, 12/700, 11/800, Literata 19/500) e `tnum`;
  - **semântica:** os rótulos do arquivo, a fita `toggled`, o `slider` "página 159 de 256", o véu fora;
  - **dados:** 159/256/62 %, "18 min hoje · contando sozinho", contador 12, fita marcada — tudo dos cálculos.
  - **L26b:** os mesmos com `kRef26b` e o papel Noite.
- [ ] **Passo 1 — testes que falham** → **Passo 2** ajustar o que a medida apontar → **Passo 3 — verde.**
- [ ] **Passo 4 — commit:** `test(leitor): fases L20a, L20b, L20c e L26b contra as medidas do arquivo (G12.5)`.

### Tarefa 19: goldens e capturas

**Arquivos:** `test/golden/leitor_20_test.dart`, `leitor_26b_test.dart`, `capturas_g12_test.dart`.

- [ ] Golden @3x de cada prancha (1170 × 2532), `matchesGoldenFile('goldens/leitor_20@3x.png')`/`leitor_26b@3x.png`,
  e no Windows: `python tools/compare_images.py --flutter <png> --ref handoff_v2/referencia/png/20_leitor_controles_390x844@3x.png --scale 3 --rect 0,46,390,798`
  (e o mesmo para a 26b) → `blur_mismatch_% ≤ 0,5`; lado a lado e heatmap inspecionados em `build/visual_diff_g12/`.
- [ ] Capturas com `BOOKNEST_CAPTURAS`: tela 20 em Creme, Branco e Sépia; 26b; a barra arrastando (balão em outra
  página); o painel da busca com resultados; a palavra marcada na página com a pílula; o PDF com controles (Fonte
  cinza) — mandadas na conversa.
- [ ] **Commit:** `test(leitor): goldens das telas 20 e 26b e capturas da G12 (G12.5)`.

### Tarefa 20: verificação e relatório

- [ ] Suíte completa com cobertura (`suite.ps1`): `flutter analyze` 0 e todos verdes; cobertura ≥ 90 % nos arquivos
  de `lib/` mexidos na fase (`git diff --name-only d0a0aa8..HEAD -- lib`).
- [ ] Mutação (`tools/medicao/tmp/mut/g12/`, gerador `gerar_g12.py`): uma troca por regra nova — D-117 (toque com
  controles abertos vira; arrasto não fecha; Voltar fecha o livro direto), D-118 (aviso some em 20 s; sem aviso),
  D-119 (salto sem volta; volta sem alfinete), D-120 (busca com acento; mínimo 1; sem limite; 0 ms de espera;
  marca não some ao virar), D-121 (Tema não grava; último claro esquecido; repagina), D-122 (Fonte ativa no PDF;
  tempo do PDF por caracteres do texto), D-123 (físico abre o leitor), D-124 (ilha sem a área segura; véu 50 %;
  contador com 0; "100" em vez de "99+"; minutos sem atualizar; passo da barra 1 página) e as cores/medidas
  (sombra da tinta no Noite; Bricolage 18 no título; onda sem traço). Cada uma precisa reprovar os testes.
- [ ] Revisão independente por um agente que não escreveu o código; corrigir o que for real, com teste.
- [ ] gitleaks nos commits da fase e em `lib/features/reader`, `test` e `docs/progresso`.
- [ ] `docs/progresso/G12.md`: resultados, revisão, desvios, pendências e checklist com os commits;
  `docs/progresso/RELATORIO_G12.md` terminando em "✅ FASE G12 concluída — aguardando sua aprovação para iniciar a
  FASE G13."; o relatório também no projeto (`handoff_app_completo/relatorios/RELATORIO_G12.md`).
- [ ] **Commit:** `docs(g12): resultados, revisão independente e relatório da fase`.
