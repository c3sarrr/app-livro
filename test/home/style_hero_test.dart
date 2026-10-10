import 'dart:typed_data';

import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/tokens/app_radii.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/overrides_do_mundo.dart';
import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';
import '../support/pump_app.dart';

BoxDecoration _decorationOf(WidgetTester tester, String id) =>
    tester
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byKey(ValueKey<String>(id)),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

ClipRRect _clipOf(WidgetTester tester, String id) => tester.widget<ClipRRect>(
  find
      .descendant(
        of: find.byKey(ValueKey<String>(id)),
        matching: find.byType(ClipRRect),
      )
      .first,
);

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

void _expectHardShadow(BoxDecoration d, Offset offset) {
  expect(d.boxShadow, hasLength(1));
  final s = d.boxShadow!.single;
  expect(s.offset, offset);
  expect(s.blurRadius, 0);
  expect(s.spreadRadius, 0);
  expect(s.color.toARGB32(), 0xFF1A1714);
  expect(s.blurStyle, BlurStyle.normal);
}

void _expectInkBorder(BoxDecoration d, {double width = 1.5}) {
  expect(d.border, Border.all(width: width, color: AppColors.ink));
  expect((d.border! as Border).top.color.toARGB32(), 0xFF1A1714);
}

/// Monta o app sob um RepaintBoundary (mesma captura do golden).
Future<void> _pumpCanvas(WidgetTester tester) async {
  await precacheAppIcons(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overridesDoMundo,
      child: const RepaintBoundary(key: goldenRootKey, child: App.forTests()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<(Uint8List, int)> _capture(WidgetTester tester) async {
  final image = await captureAt(tester, find.byKey(goldenRootKey));
  return (await rgbaOf(tester, image), image.width);
}

/// Cor ARGB do pixel @3x que contém o ponto LÓGICO (x, y).
int _argbAt(Uint8List rgba, int width, Offset p) {
  final i = ((p.dy * 3).floor() * width + (p.dx * 3).floor()) * 4;
  return (rgba[i + 3] << 24) |
      (rgba[i] << 16) |
      (rgba[i + 1] << 8) |
      rgba[i + 2];
}

/// Ponto da arte da capa (coordenadas locais da borda EXTERNA, sem giro) levado ao canvas (com o giro −3°).
Offset _coverPoint(WidgetTester tester, Offset local) => tester
    .renderObject<RenderBox>(find.byKey(const ValueKey('hero.cover#rot')))
    .localToGlobal(local);

/// F05 — camada 2 (estilo, sem tolerância) da seção `hero`; desde a T03 o `HeroSection` da prancha 01 (L01a2): o
/// cartão cresce a 282,8 (as pílulas "pág. 159 de 256" e "E-BOOK" em 2 linhas) e a capa é a nova (o olho e o mar, em
/// SVG) — a estrutura e os textos dela são exatos em `test/home/inicio01/heroi_test.dart`; aqui ficam o cartão, os
/// brilhos, as pílulas, os textos, a barra, as ações, os pixels e o tema.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '5.1 cartão: brand #B6ACE4, borda 1,5 #1A1714, raio 28, sombra dura (4,4) blur 0; recorte interno raio 26,5',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final d = _decorationOf(tester, 'hero');
      expect(d.color!.toARGB32(), 0xFFB6ACE4);
      expect(d.color, AppColors.lavender);
      _expectInkBorder(d);
      expect(d.borderRadius, BorderRadius.circular(28));
      expect(AppRadii.card, 28);
      _expectHardShadow(d, const Offset(4, 4));
      expect(d.gradient, isNull);
      // overflow: hidden → filhos recortados na padding box com raio 28 − 1,5.
      final clip = _clipOf(tester, 'hero');
      expect(clip.borderRadius, BorderRadius.circular(26.5));
      expect(clip.clipBehavior, Clip.antiAlias);
      expect(
        tester.getSize(
          find
              .descendant(
                of: find.byKey(const ValueKey('hero')),
                matching: find.byType(ClipRRect),
              )
              .first,
        ),
        isA<Size>()
            .having((z) => z.width, 'largura', 347)
            // 282,8 − 2 × 1,5; a altura vem do texto (float32 do SkParagraph) → ±1e-3
            .having(
              (z) => z.height,
              'altura',
              moreOrLessEquals(279.8, epsilon: 1e-3),
            ),
      );
    },
  );

  testWidgets(
    '5.1 brilhos: ic_sparkle_outline 30 (#FFFAF1, traço tinta) e ic_sparkle_solid 14 (tinta), fora da árvore semântica',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final large = tester.widget<AppSvg>(
        find.byKey(const ValueKey('hero.sparkleLarge')),
      );
      final small = tester.widget<AppSvg>(
        find.byKey(const ValueKey('hero.sparkleSmall')),
      );
      expect((large.asset, large.size), (AppIcons.sparkleOutline, 30.0));
      expect(large.asset, 'assets/icons/ic_sparkle_outline.svg');
      expect((small.asset, small.size), (AppIcons.sparkleSolid, 14.0));
      expect(small.asset, 'assets/icons/ic_sparkle_solid.svg');
    },
  );

  testWidgets(
    '5.3 pílulas #FFFAF1 ("pág. 159 de 256") e #FED170 ("E-BOOK") borda 1,5 raio 999 (→ metade da altura); título Bricolage24 24/1,05 ls −0,6; autor Figtree 14/500 #2F2A40',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final (id, cor) in [
        ('hero.pagePill', 0xFFFFFAF1),
        ('hero.formatPill', 0xFFFED170),
      ]) {
        final pill = _decorationOf(tester, id);
        expect(pill.color!.toARGB32(), cor, reason: id);
        _expectInkBorder(pill);
        expect(pill.borderRadius, BorderRadius.circular(999), reason: id);
        expect(pill.boxShadow, isNull, reason: id);
        final rect = tester.getRect(find.byKey(ValueKey(id)));
        final rrect = BorderRadius.circular(999).toRRect(rect).scaleRadii();
        expect(
          rrect.tlRadiusX,
          moreOrLessEquals(rect.height / 2, epsilon: 1e-9),
          reason: id,
        );
      }
      final label = _styleOf(tester, 'hero.pagePill');
      expect(label, same(AppTextStyles.label12Bold));
      expect(
        (label.fontFamily, label.fontSize, label.fontWeight, label.height),
        ('Figtree', 12.0, FontWeight.w700, 1.2),
      );
      expect(label.color!.toARGB32(), 0xFF1A1714);

      final title = _styleOf(tester, 'hero.title');
      expect(title, same(AppTextStyles.heroTitle));
      expect(
        (title.fontFamily, title.fontSize, title.fontWeight, title.height),
        ('Bricolage24', 24.0, FontWeight.w800, 1.05),
      );
      expect(title.letterSpacing, -0.6);
      expect(title.fontFamilyFallback, ['Bricolage24Ext', 'Bricolage24Vi']);
      expect(title.color!.toARGB32(), 0xFF1A1714);
      final author = _styleOf(tester, 'hero.author');
      expect(author, same(AppTextStyles.body14Plum));
      expect(
        (author.fontFamily, author.fontSize, author.fontWeight, author.height),
        ('Figtree', 14.0, FontWeight.w500, 1.2),
      );
      expect(author.color!.toARGB32(), 0xFF2F2A40); // não é o cinza #5B544B
      for (final s in [label, title, author]) {
        expect(s.leadingDistribution, TextLeadingDistribution.even);
      }
    },
  );

  testWidgets(
    '5.4 "62%" Bricolage26 26 ls −0,6; "~2h 10min" Figtree 12/600 #2F2A40; barra #FFFAF1 borda 1,5 raio 999 recortada; preenchimento tinta raio 999',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final percent = _styleOf(tester, 'hero.percent');
      expect(percent, same(AppTextStyles.heroPercent));
      expect(
        (
          percent.fontFamily,
          percent.fontSize,
          percent.fontWeight,
          percent.height,
          percent.letterSpacing,
        ),
        ('Bricolage26', 26.0, FontWeight.w800, 1.2, -0.6),
      );
      expect(percent.color!.toARGB32(), 0xFF1A1714);
      final time = _styleOf(tester, 'hero.timeLeft');
      expect(time, same(AppTextStyles.caption12Plum));
      expect(
        (time.fontFamily, time.fontSize, time.fontWeight, time.height),
        ('Figtree', 12.0, FontWeight.w600, 1.2),
      );
      expect(time.color!.toARGB32(), 0xFF2F2A40);

      final bar = _decorationOf(tester, 'hero.progressBar');
      expect(bar.color!.toARGB32(), 0xFFFFFAF1);
      _expectInkBorder(bar);
      expect(bar.borderRadius, BorderRadius.circular(999));
      expect(bar.boxShadow, isNull);
      expect(
        _clipOf(tester, 'hero.progressBar').borderRadius,
        BorderRadius.circular(997.5),
      );
      final fill = _decorationOf(tester, 'hero.progressFill');
      expect(fill.color!.toARGB32(), 0xFF1A1714);
      expect(fill.borderRadius, BorderRadius.circular(999));
      expect((fill.border, fill.boxShadow), (null, null));
    },
  );

  testWidgets(
    '5.5 CTA tinta raio 999 sem borda/sombra, ícone ic_book_open 20, rótulo Figtree 16/700 #F7F0E3; botão 54 #FFFAF1 borda 1,5, ícone ic_highlighter 22; badge #FED170 borda 1,5 com 11/700 tinta',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final cta = _decorationOf(tester, 'hero.cta');
      expect(cta.color!.toARGB32(), 0xFF1A1714);
      expect(cta.borderRadius, BorderRadius.circular(999));
      expect((cta.border, cta.boxShadow), (null, null));
      final ctaIcon = tester.widget<AppSvg>(
        find.byKey(const ValueKey('hero.cta.icon')),
      );
      expect((ctaIcon.asset, ctaIcon.size), (AppIcons.bookOpen, 20.0));
      expect(ctaIcon.asset, 'assets/icons/ic_book_open.svg');
      final label = _styleOf(tester, 'hero.cta.label');
      expect(label, same(AppTextStyles.cta16OnInk));
      expect(
        (label.fontFamily, label.fontSize, label.fontWeight, label.height),
        ('Figtree', 16.0, FontWeight.w700, 1.2),
      );
      expect(label.color!.toARGB32(), 0xFFF7F0E3);

      final button = _decorationOf(tester, 'hero.notesButton');
      expect(button.color!.toARGB32(), 0xFFFFFAF1);
      _expectInkBorder(button);
      expect(button.borderRadius, BorderRadius.circular(27));
      expect(button.boxShadow, isNull);
      final icon = tester.widget<AppSvg>(
        find.byKey(const ValueKey('hero.notesButton.icon')),
      );
      expect((icon.asset, icon.size), (AppIcons.highlighter, 22.0));
      expect(icon.asset, 'assets/icons/ic_highlighter.svg');

      final badge = _decorationOf(tester, 'hero.notesButton.badge');
      expect(badge.color!.toARGB32(), 0xFFFED170);
      _expectInkBorder(badge);
      expect(badge.borderRadius, BorderRadius.circular(999));
      expect(badge.boxShadow, isNull);
      final count = _styleOf(tester, 'hero.notesButton.badge');
      expect(count, same(AppTextStyles.micro11Bold));
      expect(
        (count.fontFamily, count.fontSize, count.fontWeight, count.height),
        // CSS 800 → renderizado 700 (D-14).
        ('Figtree', 11.0, FontWeight.w700, 1.2),
      );
      expect(count.color!.toARGB32(), 0xFF1A1714);
    },
  );

  testWidgets(
    'pixels @3x: fundo brand, sombras duras do cartão e da capa girada, brilhos, barra, CTA, botão e badge',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final (rgba, width) = await _capture(tester);
      int at(Offset p) => _argbAt(rgba, width, p);
      Rect r(String id) => tester.getRect(find.byKey(ValueKey(id)));
      final hero = r('hero'), bar = r('hero.progressBar'), cta = r('hero.cta');
      final button = r('hero.notesButton'), badge = r('hero.notesButton.badge');
      final checks = <String, (Offset, int)>{
        // a linha da capa termina em 185,8 e as ações começam em 205,8 (padding 20, gap 20)
        'fundo brand entre a linha e as ações': (
          hero.topLeft + const Offset(10, 195.8),
          0xFFB6ACE4,
        ),
        'borda esquerda do cartão': (
          Offset(hero.left + 0.5, hero.top + 150),
          0xFF1A1714,
        ),
        'sombra do cartão (4 px à direita)': (
          Offset(hero.right + 2, hero.top + 150),
          0xFF1A1714,
        ),
        'sombra do cartão (4 px abaixo)': (
          Offset(hero.center.dx, hero.bottom + 2),
          0xFF1A1714,
        ),
        'papel além da sombra': (
          Offset(hero.right + 5, hero.top + 150),
          0xFFF7F0E3,
        ),
        // A capa (−3°): a sombra dura 3/3 e o brand depois dela (a arte é SVG — o desenho está no gate visual).
        'capa: sombra girada à direita': (
          _coverPoint(tester, const Offset(105.5, 78)),
          0xFF1A1714,
        ),
        'capa: sombra girada embaixo': (
          _coverPoint(tester, const Offset(52, 157.5)),
          0xFF1A1714,
        ),
        'capa: brand além da sombra girada': (
          _coverPoint(tester, const Offset(108.5, 78)),
          0xFFB6ACE4,
        ),
        'capa: borda esquerda tinta': (
          _coverPoint(tester, const Offset(0.75, 78)),
          0xFF1A1714,
        ),
        // Os brilhos (presos ao canto de cima, à direita): os miolos.
        'brilho grande: miolo #FFFAF1': (
          hero.topLeft + const Offset(315.5, 34.5),
          0xFFFFFAF1,
        ),
        'brilho pequeno: miolo tinta': (
          hero.topLeft + const Offset(291.5, 62.5),
          0xFF1A1714,
        ),
        'barra: preenchimento': (
          Offset(bar.left + bar.width * 0.3, bar.center.dy),
          0xFF1A1714,
        ),
        'barra: trilho após 62 %': (
          Offset(bar.left + bar.width * 0.85, bar.center.dy),
          0xFFFFFAF1,
        ),
        'CTA: fundo tinta': (Offset(cta.left + 12, cta.center.dy), 0xFF1A1714),
        'botão: fundo claro (fora do ícone)': (
          button.center + const Offset(15, 0),
          0xFFFFFAF1,
        ),
        'badge: fundo amarelo': (
          Offset(badge.left + 3.5, badge.center.dy),
          0xFFFED170,
        ),
      };
      final failures = <String>[];
      checks.forEach((what, check) {
        final got = at(check.$1);
        debugPrint(
          '[pixels] $what em ${check.$1}: 0x${got.toRadixString(16).toUpperCase()}',
        );
        if (got != check.$2) {
          failures.add(
            '$what: 0x${got.toRadixString(16).toUpperCase()} ≠ 0x${check.$2.toRadixString(16).toUpperCase()}',
          );
        }
      });
      expect(failures, isEmpty, reason: failures.join('\n'));
    },
  );

  testWidgets(
    'Tema: cada opção de brand (AppColors.brandOptions) muda só o fundo do cartão e, desde a F11, o item ativo da navegação',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final (base, width) = await _capture(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      final hero = tester.getRect(find.byKey(const ValueKey('hero')));
      // F11: o item ativo da barra (Início) usa o mesmo `brand` do hero — única região fora do cartão que muda.
      final navItem = tester.getRect(find.byKey(const ValueKey('nav.home')));
      expect(AppColors.brandOptions, hasLength(4));
      for (final brand in AppColors.brandOptions) {
        container.read(homeThemeProvider.notifier).setBrand(brand);
        await tester.pumpAndSettle();
        expect(_decorationOf(tester, 'hero').color, brand);
        final (rgba, _) = await _capture(tester);
        var changed = 0, outside = 0, inNavItem = 0;
        for (var i = 0; i < rgba.length; i += 4) {
          if (rgba[i] == base[i] &&
              rgba[i + 1] == base[i + 1] &&
              rgba[i + 2] == base[i + 2] &&
              rgba[i + 3] == base[i + 3]) {
            continue;
          }
          changed++;
          final px = (i ~/ 4) % width, py = (i ~/ 4) ~/ width;
          // O pixel @3x cobre [px/3, (px+1)/3) × [py/3, (py+1)/3): precisa tocar o retângulo do cartão.
          final touches =
              (px + 1) / 3 > hero.left &&
              px / 3 < hero.right &&
              (py + 1) / 3 > hero.top &&
              py / 3 < hero.bottom;
          // O pixel @3x cobre [px/3, (px+1)/3) × [py/3, (py+1)/3): precisa tocar o item ativo da navegação.
          final touchesNav =
              (px + 1) / 3 > navItem.left &&
              px / 3 < navItem.right &&
              (py + 1) / 3 > navItem.top &&
              py / 3 < navItem.bottom;
          if (touchesNav) inNavItem++;
          if (!touches && !touchesNav) outside++;
        }
        final bg = _argbAt(rgba, width, hero.topLeft + const Offset(10, 195.8));
        debugPrint(
          '[tema] brand 0x${brand.toARGB32().toRadixString(16).toUpperCase()}: '
          '$changed pixels mudaram, $inNavItem no item ativo da navegação, $outside fora do cartão e do item; '
          'fundo 0x${bg.toRadixString(16).toUpperCase()}',
        );
        expect(outside, 0);
        expect(bg, brand.toARGB32());
        // O fundo da pílula ativa (pixel dentro dela, longe do ícone e do rótulo) acompanha o hero.
        expect(
          _argbAt(rgba, width, navItem.topLeft + const Offset(4.5, 20.5)),
          brand.toARGB32(),
        );
        if (brand == AppColors.lavender) {
          expect(changed, 0); // é o padrão
          expect(inNavItem, 0);
        } else {
          expect(changed, greaterThan(300000));
          expect(inNavItem, greaterThan(5000)); // o preenchimento da pílula (≈ 21.500 px @3x, sem borda, ícone e rótulo) muda de cor
        }
      }
    },
  );

  testWidgets(
    'sem ripple: nenhum InkWell/InkResponse/Material no cartão; CTA e botão só escalam 0,97 (D-04)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final hero = find.byKey(const ValueKey('hero'));
      expect(
        find.descendant(
          of: hero,
          matching: find.byWidgetPredicate(
            (w) =>
                w is InkWell || w is InkResponse || w is Material || w is Ink,
          ),
        ),
        findsNothing,
      );
      // O Pressable do CTA envolve o NeoBox `hero.cta`; o do botão fica dentro do CircleIconButton.
      final scales = {
        'hero.cta': find.ancestor(
          of: find.byKey(const ValueKey('hero.cta')),
          matching: find.byType(AnimatedScale),
        ),
        'hero.notesButton': find.descendant(
          of: find.byKey(const ValueKey('hero.notesButton')),
          matching: find.byType(AnimatedScale),
        ),
      };
      for (final MapEntry(key: id, value: scale) in scales.entries) {
        expect(scale, findsOneWidget, reason: id);
        expect(
          tester.widget<AnimatedScale>(scale.first).scale,
          1.0,
          reason: id,
        );
        final gesture = await tester.startGesture(
          tester.getCenter(find.byKey(ValueKey<String>(id))),
        );
        await tester.pump();
        expect(
          tester.widget<AnimatedScale>(scale.first).scale,
          0.97,
          reason: id,
        );
        await gesture.up();
        await tester.pumpAndSettle();
        // F12: soltar dentro do alvo agora navega (o callback está ligado): voltar devolve a Início.
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(
          tester.widget<AnimatedScale>(scale.first).scale,
          1.0,
          reason: id,
        );
      }
    },
  );
}
