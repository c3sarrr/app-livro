import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/app/router.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/shell/presentation/bottom_fade.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';
import '../support/pump_app.dart';

const _ink = 0xFF1A1714;
const _paper = 0xFFF7F0E3;
const _surface = 0xFFFFFAF1;
const _muted = 0xFF5B544B;
const _lavender = 0xFFB6ACE4;
const _sun = 0xFFFED170;

/// Decoração do primeiro `DecoratedBox` sob [id] (ou do próprio, se a Key estiver nele).
BoxDecoration _decorationOf(WidgetTester tester, String id) =>
    tester
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byKey(ValueKey<String>(id)),
                    matching: find.byType(DecoratedBox),
                    matchRoot: true,
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

NeoBox _neoBoxIn(WidgetTester tester, String id) => tester.widget<NeoBox>(
  find
      .descendant(
        of: find.byKey(ValueKey<String>(id)),
        matching: find.byType(NeoBox),
        matchRoot: true,
      )
      .first,
);

/// Estilo do único `AppText` sob [id].
TextStyle _styleOf(WidgetTester tester, String id) =>
    (tester
                .widget<AppText>(
                  find.descendant(
                    of: find.byKey(ValueKey<String>(id)),
                    matching: find.byType(AppText),
                    matchRoot: true,
                  ),
                )
                .span
            as TextSpan)
        .style!;

/// Tipografia completa: Figtree 11, altura 1,2 (`line-height: normal`), sem espaçamento, "even".
void _expectLabel(
  TextStyle s, {
  required FontWeight weight,
  required int color,
  required String reason,
}) {
  expect(
    (s.fontFamily, s.fontSize, s.fontWeight, s.height, s.letterSpacing),
    ('Figtree', 11.0, weight, 1.2, 0.0),
    reason: reason,
  );
  expect(s.fontFamilyFallback, ['FigtreeExt'], reason: reason);
  expect(s.fontStyle, isNull, reason: reason);
  expect(s.color!.toARGB32(), color, reason: reason);
  expect(s.leadingDistribution, TextLeadingDistribution.even, reason: reason);
}

void _expectInk15(Border? border, {String? reason}) {
  expect(border, isNotNull, reason: reason);
  for (final side in [border!.top, border.right, border.bottom, border.left]) {
    expect(side.width, 1.5, reason: reason);
    expect(side.color.toARGB32(), _ink, reason: reason);
    expect(side.style, BorderStyle.solid, reason: reason);
  }
}

void _expectHardShadow(BoxDecoration d, {String? reason}) {
  expect(d.boxShadow, hasLength(1), reason: reason);
  final s = d.boxShadow!.single;
  expect(
    (s.color.toARGB32(), s.offset, s.blurRadius, s.spreadRadius),
    (_ink, const Offset(0, 4), 0.0, 0.0),
    reason: reason,
  );
}

/// Monta o app sob um RepaintBoundary (mesma captura do golden).
Future<void> _pumpCanvas(WidgetTester tester) async {
  await precacheAppIcons(tester);
  await tester.pumpWidget(
    const ProviderScope(
      child: RepaintBoundary(key: goldenRootKey, child: App.forTests()),
    ),
  );
  await tester.pumpAndSettle();
}

/// Cor ARGB do pixel @3x que contém o ponto LÓGICO (x, y).
int _argbAt(Uint8List rgba, int width, Offset p) {
  final i = ((p.dy * 3).floor() * width + (p.dx * 3).floor()) * 4;
  return (rgba[i + 3] << 24) |
      (rgba[i] << 16) |
      (rgba[i + 1] << 8) |
      rgba[i + 2];
}

String _hex(int argb) => '0x${argb.toRadixString(16).toUpperCase()}';

GoRouter _router(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(MainShell, skipOffstage: false)));

/// F11 — camada 2 (estilo, sem tolerância) da navegação, do FAB e do fade.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '11.2 barra: NeoBox #FFFAF1, borda 1,5 tinta, raio 28, sombra dura (0, 4, 0, 0), padding 8, sem recorte',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final neo = _neoBoxIn(tester, 'nav');
      expect(neo.color, AppColors.surface);
      expect(neo.border, const BorderSide(width: 1.5, color: AppColors.ink));
      expect(neo.radius, BorderRadius.circular(28));
      expect(neo.shadow, const Offset(0, 4));
      expect(neo.padding, const EdgeInsets.all(8));
      expect(neo.clip, isFalse);
      final d = _decorationOf(tester, 'nav');
      expect(d.color!.toARGB32(), _surface);
      expect(d.borderRadius, BorderRadius.circular(28));
      expect(d.shape, BoxShape.rectangle);
      expect(d.gradient, isNull);
      _expectInk15(d.border as Border?);
      _expectHardShadow(d);
    },
  );

  testWidgets(
    '11.3 item ativo (Início): brand #B6ACE4 + borda 1,5 tinta + raio 20, sem sombra; os 4 inativos não têm fundo, borda nem sombra',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final home = _decorationOf(tester, 'nav.home');
      expect(home.color!.toARGB32(), _lavender);
      expect(home.borderRadius, BorderRadius.circular(20));
      expect(home.gradient, isNull);
      expect(home.boxShadow, isNull);
      _expectInk15(home.border as Border?);
      // Só o item ativo tem NeoBox; no Scanner e nos outros não há caixa nenhuma sob a Key.
      for (final id in [
        'nav.library',
        'nav.scanner',
        'nav.clubs',
        'nav.profile',
      ]) {
        expect(
          find.descendant(
            of: find.byKey(ValueKey(id)),
            matching: find.byType(DecoratedBox),
          ),
          findsNothing,
          reason: id,
        );
        expect(
          find.descendant(
            of: find.byKey(ValueKey(id)),
            matching: find.byType(NeoBox),
          ),
          findsNothing,
          reason: id,
        );
      }
      // A pílula do ativo usa a cor do tema (padrão #B6ACE4).
      expect(
        ProviderScope.containerOf(tester.element(find.byType(MainShell)))
            .read(homeThemeProvider)
            .brand
            .toARGB32(),
        _lavender,
      );
    },
  );

  testWidgets(
    '11.4 FAB: círculo 60×60 #FED170, borda 1,5 tinta, raio 999 (normalizado → círculo), sombra (0, 4, 0, 0); ícone 28 dentro e centrado',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final neo = _neoBoxIn(tester, 'nav.scanner.fab');
      expect((neo.width, neo.height), (60.0, 60.0));
      expect(neo.color, AppColors.sun);
      expect(neo.border, const BorderSide(width: 1.5, color: AppColors.ink));
      expect(neo.radius, BorderRadius.circular(999));
      expect(neo.shadow, const Offset(0, 4));
      expect(neo.clip, isFalse);
      final d = _decorationOf(tester, 'nav.scanner.fab');
      expect(d.color!.toARGB32(), _sun);
      expect(d.shape, BoxShape.rectangle);
      expect(d.borderRadius, BorderRadius.circular(999));
      _expectInk15(d.border as Border?);
      _expectHardShadow(d);
      // 999 num quadrado de 60 → raio efetivo 30 (como o `border-radius: 50%` do arquivo).
      final render = tester.renderObject<RenderBox>(
        find
            .descendant(
              of: find.byKey(const ValueKey('nav.scanner.fab')),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(render.size, const Size(60, 60));
    },
  );

  testWidgets(
    '11.1 fade: DecoratedBox com LinearGradient(topCenter → bottomCenter, [#F7F0E300, #F7F0E3], stops [0, 0.55]); IgnorePointer; fora da árvore semântica',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final fade = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byKey(const ValueKey('bottomFade')),
          matching: find.byType(DecoratedBox),
          matchRoot: true,
        ),
      );
      final d = fade.decoration as BoxDecoration;
      expect(d.color, isNull);
      expect(d.border, isNull);
      expect(d.borderRadius, isNull);
      expect(d.boxShadow, isNull);
      final g = d.gradient! as LinearGradient;
      expect(g.begin, Alignment.topCenter);
      expect(g.end, Alignment.bottomCenter);
      expect(g.colors.map((c) => c.toARGB32()), [0x00F7F0E3, _paper]);
      expect(g.stops, [0.0, 0.55]);
      expect(g.tileMode, TileMode.clamp);
      expect(g.transform, isNull);
      // A cor de partida tem o MESMO RGB do papel (alpha 0), como `rgba(247,240,227,0)`.
      expect(g.colors.first.toARGB32() & 0xFFFFFF, _paper & 0xFFFFFF);
      expect(g.colors.first.a, 0);
      // `pointer-events: none` e `aria-hidden`.
      final ignore = tester.widget<IgnorePointer>(
        find
            .ancestor(
              of: find.byType(BottomFade),
              matching: find.byType(IgnorePointer),
            )
            .first,
      );
      expect(ignore.ignoring, isTrue);
      expect(
        find.descendant(
          of: find.byType(BottomFade),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'tipografia dos 5 rótulos: Figtree 11, altura 1,2 — "Início" 700 tinta (CSS 800 → 700, D-14); Biblioteca/Clubes/Perfil 600 #5B544B; "Scanner" 700 tinta',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      _expectLabel(
        _styleOf(tester, 'nav.home.label'),
        weight: FontWeight.w700,
        color: _ink,
        reason: 'nav.home.label',
      );
      for (final id in [
        'nav.library.label',
        'nav.clubs.label',
        'nav.profile.label',
      ]) {
        _expectLabel(
          _styleOf(tester, id),
          weight: FontWeight.w600,
          color: _muted,
          reason: id,
        );
        expect(_styleOf(tester, id), same(AppTextStyles.navLabel), reason: id);
      }
      _expectLabel(
        _styleOf(tester, 'nav.scanner.label'),
        weight: FontWeight.w700,
        color: _ink,
        reason: 'nav.scanner.label',
      );
      expect(
        _styleOf(tester, 'nav.home.label'),
        same(AppTextStyles.micro11Bold),
      );
      expect(
        _styleOf(tester, 'nav.scanner.label'),
        same(AppTextStyles.micro11Bold),
      );
    },
  );

  testWidgets(
    'ícones: SVGs exatos do arquivo (casa preenchida no ativo, só traço nos inativos, código de barras 28 com traço 1,9), sem colorFilter; Column(center, gap 3) por item, Scanner alinhado embaixo',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final expected = {
        'nav.home.icon': (AppIcons.navHomeActive, 22.0),
        'nav.library.icon': (AppIcons.navLibrary, 22.0),
        'nav.scanner.icon': (AppIcons.navScanner, 28.0),
        'nav.clubs.icon': (AppIcons.navClubs, 22.0),
        'nav.profile.icon': (AppIcons.navProfile, 22.0),
      };
      for (final MapEntry(key: id, value: (asset, size)) in expected.entries) {
        final icon = tester.widget<AppSvg>(find.byKey(ValueKey(id)));
        expect((icon.asset, icon.size), (asset, size), reason: id);
        final picture = tester.widget<SvgPicture>(
          find.descendant(
            of: find.byKey(ValueKey(id)),
            matching: find.byType(SvgPicture),
          ),
        );
        expect(picture.colorFilter, isNull, reason: id);
        expect((picture.width, picture.height), (size, size), reason: id);
      }
      final sources = {
        for (final asset in [
          AppIcons.navHomeActive,
          AppIcons.navLibrary,
          AppIcons.navScanner,
          AppIcons.navClubs,
          AppIcons.navProfile,
        ])
          asset: (await tester.runAsync(() => rootBundle.loadString(asset)))!,
      };
      String attr(String source, String name) =>
          RegExp('$name="([^"]*)"').firstMatch(source)!.group(1)!;
      // `<svg ... fill=... stroke=... stroke-width=...>` do HTML literal da fase.
      expect(attr(sources[AppIcons.navHomeActive]!, 'fill'), '#FFFAF1');
      for (final asset in [
        AppIcons.navLibrary,
        AppIcons.navClubs,
        AppIcons.navProfile,
        AppIcons.navScanner,
      ]) {
        expect(attr(sources[asset]!, 'fill'), 'none', reason: asset);
      }
      for (final asset in sources.keys) {
        expect(attr(sources[asset]!, 'stroke'), '#1A1714', reason: asset);
        expect(attr(sources[asset]!, 'viewBox'), '0 0 24 24', reason: asset);
        expect(
          attr(sources[asset]!, 'stroke-width'),
          asset == AppIcons.navScanner ? '1.9' : '1.8',
          reason: asset,
        );
      }
      // Coluna de cada item: gap 3; centralizada (Scanner: embaixo).
      for (final id in [
        'nav.home',
        'nav.library',
        'nav.clubs',
        'nav.profile',
      ]) {
        final column = tester.widget<Column>(
          find
              .descendant(
                of: find.byKey(ValueKey(id)),
                matching: find.byType(Column),
              )
              .first,
        );
        expect(column.mainAxisAlignment, MainAxisAlignment.center, reason: id);
        expect(column.spacing, 3, reason: id);
        expect(column.children, hasLength(2), reason: id); // ícone + rótulo
      }
      final scanner = tester.widget<Column>(
        find
            .descendant(
              of: find.byKey(const ValueKey('nav.scanner')),
              matching: find.byType(Column),
            )
            .first,
      );
      expect(scanner.mainAxisAlignment, MainAxisAlignment.end);
      expect(scanner.spacing, 3);
      expect(scanner.children, hasLength(1)); // só o rótulo: o círculo é do FAB
    },
  );

  testWidgets(
    'tema: o `brand` colore o item ativo junto com o hero (as 4 opções do arquivo)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MainShell)),
      );
      for (final brand in AppColors.brandOptions) {
        container.read(homeThemeProvider.notifier).setBrand(brand);
        await tester.pumpAndSettle();
        expect(
          _decorationOf(tester, 'nav.home').color,
          brand,
          reason: '#${brand.toARGB32().toRadixString(16)}',
        );
        expect(_decorationOf(tester, 'hero').color, brand);
      }
      // A cor do FAB e da barra não dependem do tema.
      expect(_decorationOf(tester, 'nav.scanner.fab').color!.toARGB32(), _sun);
      expect(_decorationOf(tester, 'nav').color!.toARGB32(), _surface);
    },
  );

  testWidgets(
    'D-07 (aba ativa ≠ Início): a pílula, o ícone preenchido e o rótulo 700 tinta passam para a aba; a Início volta ao estilo de repouso (ícone só traço, 600 #5B544B)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final active = {
        AppRoutes.biblioteca: ('nav.library', AppIcons.navLibraryActive),
        AppRoutes.clubes: ('nav.clubs', AppIcons.navClubsActive),
        AppRoutes.perfil: ('nav.profile', AppIcons.navProfileActive),
      };
      final ids = ['nav.home', 'nav.library', 'nav.clubs', 'nav.profile'];
      final rest = {
        'nav.home': AppIcons.navHome,
        'nav.library': AppIcons.navLibrary,
        'nav.clubs': AppIcons.navClubs,
        'nav.profile': AppIcons.navProfile,
      };
      for (final MapEntry(key: path, value: (activeId, activeIcon))
          in active.entries) {
        _router(tester).go(path);
        await tester.pumpAndSettle();
        for (final id in ids) {
          final icon = tester.widget<AppSvg>(find.byKey(ValueKey('$id.icon')));
          if (id == activeId) {
            final d = _decorationOf(tester, id);
            expect(d.color!.toARGB32(), _lavender, reason: '$path $id');
            expect(
              d.borderRadius,
              BorderRadius.circular(20),
              reason: '$path $id',
            );
            _expectInk15(d.border as Border?, reason: '$path $id');
            expect(icon.asset, activeIcon, reason: '$path $id');
            _expectLabel(
              _styleOf(tester, '$id.label'),
              weight: FontWeight.w700,
              color: _ink,
              reason: '$path $id',
            );
          } else {
            expect(
              find.descendant(
                of: find.byKey(ValueKey(id)),
                matching: find.byType(DecoratedBox),
              ),
              findsNothing,
              reason: '$path $id',
            );
            expect(icon.asset, rest[id], reason: '$path $id');
            _expectLabel(
              _styleOf(tester, '$id.label'),
              weight: FontWeight.w600,
              color: _muted,
              reason: '$path $id',
            );
          }
        }
        // O Scanner nunca muda de aspecto (não é aba).
        _expectLabel(
          _styleOf(tester, 'nav.scanner.label'),
          weight: FontWeight.w700,
          color: _ink,
          reason: 'scanner em $path',
        );
      }
    },
  );

  testWidgets(
    'pixels @3x no canvas: fundo da barra, borda 1,5, cantos de raio 28, sombra (0, 4) só embaixo, pílula ativa com borda e canto de raio 20, itens inativos sem fundo, FAB (cor, borda, sombra, por cima da borda da barra) e fade invisível sobre o papel',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final image = await captureAt(tester, find.byKey(goldenRootKey));
      expect((image.width, image.height), (390 * 3, 2390 * 3));
      final rgba = await rgbaOf(tester, image);
      final w = image.width;
      final failures = <String>[];
      // [tol] por canal: só para papel dentro da rampa do fade (y < 2322,5), onde "papel com alpha t sobre papel"
      // passa por um blend de 8 bits que pode errar em 1 unidade. Fora da rampa a comparação é exata.
      void expectPixel(
        String what,
        double x,
        double y,
        int want, {
        int tol = 0,
      }) {
        final got = _argbAt(rgba, w, Offset(x, y));
        final exp = 0xFF000000 | want;
        final off = [
          for (final shift in [16, 8, 0])
            ((got >> shift) & 0xFF) - ((exp >> shift) & 0xFF),
        ];
        if ((got >> 24) != 0xFF || off.any((d) => d.abs() > tol)) {
          failures.add(
            '$what em ($x, $y): obtido ${_hex(got)} | esperado ${_hex(exp)}',
          );
        }
      }

      // Barra (358×70 em (16; 2290)).
      expectPixel(
        'fundo da barra (vão entre Início e Biblioteca)',
        92,
        2320,
        _surface,
      );
      expectPixel(
        'fundo da barra (vão entre Clubes e Perfil)',
        297.9,
        2320,
        _surface,
      );
      expectPixel('borda esquerda', 16.75, 2325, _ink);
      expectPixel('borda direita', 373.25, 2325, _ink);
      expectPixel('borda superior', 100, 2290.75, _ink);
      expectPixel('borda inferior', 100, 2359.25, _ink);
      expectPixel('sombra (0, 4) abaixo', 100, 2362, _ink);
      expectPixel('sombra: última linha', 100, 2363.75, _ink);
      expectPixel('abaixo da sombra', 100, 2364.5, _paper);
      expectPixel('sem sombra à esquerda', 15.5, 2325, _paper);
      expectPixel('sem sombra à direita', 374.5, 2325, _paper);
      expectPixel(
        'canto de raio 28 (fora do arco)',
        16.5,
        2290.5,
        _paper,
        tol: 1,
      );
      expectPixel('canto de raio 28 (na borda, 45°)', 24.77, 2298.77, _ink);
      expectPixel('canto de raio 28 (fora, 45°)', 23.5, 2297.5, _paper, tol: 1);
      expectPixel('canto de raio 28 (dentro, 45°)', 27.0, 2301.5, _surface);
      // O fade pinta ANTES da barra: se pintasse depois, a barra clarearia ~97% em direção ao papel.
      expectPixel(
        'fade abaixo da barra (a barra continua #FFFAF1)',
        100,
        2300,
        _surface,
      );
      expectPixel(
        'fade abaixo da barra (borda continua tinta)',
        120,
        2290.75,
        _ink,
      );

      // Item ativo (Início): 64,6×51 em (25,5; 2299,5), brand, borda 1,5, raio 20.
      expectPixel('pílula ativa (brand)', 30, 2320, _lavender);
      expectPixel('pílula ativa (brand, à direita)', 85, 2320, _lavender);
      expectPixel('pílula ativa: borda esquerda', 26.25, 2325, _ink);
      expectPixel('pílula ativa: borda superior', 60, 2300.25, _ink);
      expectPixel('pílula ativa: borda inferior', 60, 2349.75, _ink);
      expectPixel('pílula ativa: borda direita', 89.35, 2325, _ink);
      expectPixel(
        'pílula ativa: canto raio 20 (na borda, 45°)',
        31.89,
        2305.89,
        _ink,
      );
      expectPixel(
        'pílula ativa: canto raio 20 (fora, 45°)',
        30.3,
        2304.3,
        _surface,
      );
      expectPixel('pílula ativa: sem sombra (abaixo)', 60, 2351.5, _surface);
      // Itens inativos: sem fundo e sem borda.
      expectPixel('Biblioteca: sem borda (esquerda)', 94.6, 2325, _surface);
      expectPixel('Biblioteca: sem borda (topo)', 120, 2299.75, _surface);
      expectPixel('Clubes: sem borda', 231.8, 2325, _surface);
      expectPixel('Perfil: sem borda', 300.4, 2325, _surface);

      // FAB (60×60 em (165; 2269,5)): círculo, borda, sombra e ordem de pintura.
      expectPixel('FAB acima da barra (cor)', 195, 2275, _sun);
      expectPixel('FAB à esquerda do ícone', 170, 2299.5, _sun);
      expectPixel(
        'FAB por cima da borda superior da barra',
        195,
        2290.75,
        _sun,
      );
      expectPixel(
        'FAB por cima da borda superior da barra (lado)',
        177,
        2290.75,
        _sun,
      );
      expectPixel('FAB: borda superior', 195, 2270.25, _ink);
      expectPixel('FAB: borda inferior', 195, 2328.75, _ink);
      expectPixel('FAB: borda esquerda', 165.75, 2299.5, _ink);
      expectPixel('FAB: borda direita', 224.25, 2299.5, _ink);
      expectPixel('FAB: sombra (0, 4)', 195, 2331.5, _ink);
      expectPixel('FAB: sombra, última linha', 195, 2333.25, _ink);
      expectPixel('abaixo da sombra do FAB (barra)', 195, 2334, _surface);
      expectPixel('FAB: sem sombra à esquerda', 164.5, 2299.5, _surface);
      expectPixel(
        'FAB: canto do quadrado fora do círculo (acima da barra)',
        166,
        2270.5,
        _paper,
        tol: 1,
      );
      expectPixel(
        'FAB: borda da barra volta fora do círculo',
        150,
        2290.75,
        _ink,
      );

      expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
    },
  );

  testWidgets(
    'fade sobre fundo preto (150 px): alpha 0 no topo, rampa linear até 55% (82,5 px) e papel opaco dali até o fim — mesma curva do CSS',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 400));
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: goldenRootKey,
            child: Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: Color(0xFF000000))),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 150,
                  child: IgnorePointer(child: BottomFade()),
                ),
              ],
            ),
          ),
        ),
      );
      final image = await captureAt(tester, find.byKey(goldenRootKey));
      final rgba = await rgbaOf(tester, image);
      final w = image.width;
      // Pixel físico (linha) → posição do CENTRO do pixel dentro do fade, em px lógicos.
      const fadeTop = 250.0;
      int channel(int row, int c) => rgba[(row * w + 195 * 3) * 4 + c];
      for (final rel in [0.0, 10.0, 20.0, 41.25, 60.0, 75.0, 82.0]) {
        final row = ((fadeTop + rel) * 3).round();
        final center = (row + 0.5) / 3 - fadeTop;
        final t = (center / 82.5).clamp(0.0, 1.0);
        for (final (c, full) in [(0, 247), (1, 240), (2, 227)]) {
          expect(
            channel(row, c),
            closeTo(full * t, 2.0),
            reason:
                'rel $rel (centro $center, t ${t.toStringAsFixed(3)}) canal $c',
          );
        }
        expect(rgba[(row * w + 195 * 3) * 4 + 3], 255);
      }
      // Topo: praticamente preto; a partir de 82,5 px: papel exato até o fim.
      expect(channel((fadeTop * 3).round(), 0), lessThanOrEqualTo(2));
      for (final rel in [82.5, 83.0, 100.0, 125.0, 149.8]) {
        final row = ((fadeTop + rel) * 3).round().clamp(0, 400 * 3 - 1);
        expect(
          (channel(row, 0), channel(row, 1), channel(row, 2)),
          (247, 240, 227),
          reason: 'rel $rel',
        );
      }
      // Acima do fade (y < 250): preto.
      expect(channel(249 * 3, 0), 0);
    },
  );
}
