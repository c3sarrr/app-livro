// G16.6 — os recursos da tela 22: a Bricolage 15,5 registrada (o título da pílula do modo) e as letras da 22 contra as
// medidas da prancha (L22b/L22d, "Linhas de texto"); os ícones (lápis, ✓, desfazer, refazer) e as 8 ilustrações da
// prateleira existem e abrem; a troca de cor no SVG (`#B6ACE4` → brand, `#FF552E` → tinta) só mexe nas duas cores e
// é igual por conteúdo (a chave do cache); o anel cônico com o miolo de 13,5 e o aro de 2,5 `#FFFAF1` do poço de cor.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/painters/conic_ring_painter.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_leitor.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/load_fonts.dart';

double _de(String t, TextStyle s) {
  final p = TextPainter(
    text: TextSpan(text: t, style: s),
    textDirection: TextDirection.ltr,
  )..layout();
  final w = p.width;
  p.dispose();
  return w;
}

/// Grava os círculos pintados.
final class _Circulos implements ui.Canvas {
  final circles = <({Offset center, double radius, Paint paint})>[];

  @override
  void drawCircle(Offset c, double radius, Paint paint) =>
      circles.add((center: c, radius: radius, paint: paint));

  @override
  Object? noSuchMethod(Invocation invocation) => null;
}

const _brand = Color(0xFF058CD7);
const _tinta = Color(0xFF00995E);

Future<ByteData> _pixels(String svgText, {ColorMapper? mapper}) async {
  final info = await vg.loadPicture(
    SvgStringLoader(svgText, colorMapper: mapper),
    null,
  );
  final img = await info.picture.toImage(
    info.size.width.round(),
    info.size.height.round(),
  );
  info.picture.dispose();
  final b = (await img.toByteData())!;
  img.dispose();
  return b;
}

Color _px(ByteData b, int w, int x, int y) {
  final i = (y * w + x) * 4;
  return Color.fromARGB(
    b.getUint8(i + 3),
    b.getUint8(i),
    b.getUint8(i + 1),
    b.getUint8(i + 2),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  group('Bricolage 15,5 e as letras da tela 22', () {
    test('as famílias Bricolage15_5 (+Ext, Vi) no pubspec; o tamanho fracionário escolhe a instância dele', () async {
      final manifest = (json.decode(
        await rootBundle.loadString('FontManifest.json'),
      ) as List).cast<Map<String, dynamic>>();
      final familias = {for (final m in manifest) m['family'] as String};
      for (final f in [
        'Bricolage15_5',
        'Bricolage15_5Ext',
        'Bricolage15_5Vi',
      ]) {
        expect(familias, contains(f));
      }
      final s = AppFonts.bricolage(15.5, height: 1.1);
      expect(s.fontFamily, 'Bricolage15_5');
      expect(s.fontFamilyFallback, ['Bricolage15_5Ext', 'Bricolage15_5Vi']);
      expect(s.fontSize, 15.5);
      // os inteiros continuam como antes
      expect(AppFonts.bricolage(17, height: 1.1).fontFamily, 'Bricolage17');
      expect(AppFonts.bricolage(11, height: 1.2).fontFamily, 'Bricolage12');
    });

    test('L22b: "Modo anotação", o subtítulo e "Concluir"', () {
      final t = AppTextStyles.annModeTitle;
      expect(t.fontFamily, 'Bricolage15_5');
      expect((t.height, t.letterSpacing), (1.1, -0.2));
      expect(_de('Modo anotação', t), closeTo(116.25, 1.0));
      final s = AppTextStyles.annModeSubtitle;
      expect(
        (s.fontSize, s.fontWeight, s.color),
        (11.5, FontWeight.w600, AppColors.inkMuted),
      );
      expect(_de('2 dedos movem a página', s), closeTo(129.48, 1.0));
      final d = AppTextStyles.annDone;
      expect((d.fontSize, d.fontWeight), (15.0, FontWeight.w800));
      expect(_de('Concluir', d), closeTo(59.02, 1.0));
    });

    test('L22d: os rótulos (Figtree 10/700 #6F665B; o ativo 10/800)', () {
      final l = AppTextStyles.annLabel;
      expect(
        (l.fontSize, l.fontWeight, l.color),
        (10.0, FontWeight.w700, AppColors.labelReader),
      );
      expect(AppTextStyles.annLabelActive.fontWeight, FontWeight.w800);
      expect(_de('Caneta', AppTextStyles.annLabelActive), closeTo(33.42, 1.0));
      for (final (t, w) in [
        ('Marcador', 44.03),
        ('Borracha', 41.32),
        ('Laço', 21.98),
        ('Reta', 21.24),
        ('Espaço', 33.16),
      ]) {
        expect(_de(t, l), closeTo(w, 1.0), reason: t);
      }
    });
  });

  test(
    'ícones e ilustrações da 22 existem, abrem e estão nas listas de pré-cache',
    () async {
      final icones = [
        AppIconsLeitor.pencil,
        AppIconsLeitor.check,
        AppIconsLeitor.undo,
        AppIconsLeitor.redo,
      ];
      expect(AppIconsLeitor.all, containsAll(icones));
      expect(AppIllustrationsLeitor.all, hasLength(8));
      expect(AppIllustrationsLeitor.all.toSet(), hasLength(8));
      for (final a in [...icones, ...AppIllustrationsLeitor.all]) {
        final f = File(a);
        expect(f.existsSync(), isTrue, reason: a);
        final info = await vg.loadPicture(
          SvgStringLoader(f.readAsStringSync()),
          null,
        );
        expect(info.size.width, greaterThan(0), reason: a);
        info.picture.dispose();
      }
      // a pasta das ilustrações vai para o pacote
      expect(
        File('pubspec.yaml').readAsStringSync(),
        contains('- assets/illustrations/leitor/'),
      );
    },
  );

  group('troca de cor no SVG (G16)', () {
    test('só as cores exatas do mapa: a lavanda translúcida do laço e as outras ficam', () {
      final m = SvgColorSwap({
        AppColors.lavender: _brand,
        AppColors.flame: _tinta,
      });
      expect(m.substitute(null, 'rect', 'fill', AppColors.lavender), _brand);
      expect(m.substitute(null, 'path', 'fill', AppColors.flame), _tinta);
      for (final c in const [
        Color(0x59B6ACE4),
        AppColors.ink,
        AppColors.surface,
      ]) {
        expect(m.substitute(null, 'path', 'fill', c), c);
      }
    });

    test('igual por conteúdo (a chave do cache do flutter_svg)', () {
      SvgColorSwap m() =>
          SvgColorSwap({AppColors.lavender: _brand, AppColors.flame: _tinta});
      expect(m(), m());
      expect(m().hashCode, m().hashCode);
      expect(
        m(),
        isNot(
          SvgColorSwap({AppColors.lavender: _brand, AppColors.flame: _brand}),
        ),
      );
      expect(
        appSvgLoader(
          AppIllustrationsLeitor.toolPenActive,
          colors: {AppColors.lavender: _brand},
        ).cacheKey(null),
        appSvgLoader(
          AppIllustrationsLeitor.toolPenActive,
          colors: {AppColors.lavender: _brand},
        ).cacheKey(null),
      );
    });

    test('nos pixels: a caneta ativa com o corpo na brand, a faixa e a ponta na tinta; o resto igual', () async {
      final svgText = File(AppIllustrationsLeitor.toolPenActive)
          .readAsStringSync();
      final b = await _pixels(
        svgText,
        mapper: SvgColorSwap({
          AppColors.lavender: _brand,
          AppColors.flame: _tinta,
        }),
      );
      expect(_px(b, 50, 25, 55), _brand, reason: 'o corpo');
      expect(_px(b, 50, 25, 34), _tinta, reason: 'a faixa');
      expect(_px(b, 50, 25, 5), _tinta, reason: 'a ponta');
      expect(_px(b, 50, 25, 18), AppColors.surface, reason: 'o cone');
    });

    testWidgets('o AppSvg leva o mapa ao SvgPicture', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: AppSvg(
            AppIllustrationsLeitor.toolPen,
            size: 50,
            height: 70,
            colors: {AppColors.flame: _tinta},
          ),
        ),
      );
      final pic = tester.widget<SvgPicture>(find.byType(SvgPicture));
      final loader = pic.bytesLoader as SvgAssetLoader;
      expect(loader.colorMapper, SvgColorSwap({AppColors.flame: _tinta}));
      // sem mapa, como antes
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: AppSvg(AppIconsLeitor.pencil, size: 19),
        ),
      );
      final semMapa = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect((semMapa.bytesLoader as SvgAssetLoader).colorMapper, isNull);
    });
  });

  group('ConicRingPainter', () {
    test('o poço de cor (L22d nº 11–12): disco cônico, borda, aro #FFFAF1 de 2,5, miolo de 13,5 com borda', () {
      final tela = _Circulos();
      const ConicRingPainter(
        border: AppColors.ink,
        center: AppColors.flame,
        centerRadius: 13.5,
        halo: (color: AppColors.surface, width: 2.5),
      ).paint(tela, const Size(42, 42));
      final circulos = tela.circles;
      expect(circulos, hasLength(5));
      expect(
        (circulos[0].center, circulos[0].radius),
        (const Offset(21, 21), 21.0),
      );
      expect(circulos[0].paint.shader, isNotNull);
      expect(
        (
          circulos[1].radius,
          circulos[1].paint.style,
          circulos[1].paint.strokeWidth,
        ),
        (20.25, PaintingStyle.stroke, 1.5),
      );
      expect(
        (
          circulos[2].radius,
          circulos[2].paint.style,
          circulos[2].paint.color.toARGB32(),
        ),
        (16.0, PaintingStyle.fill, AppColors.surface.toARGB32()),
      );
      expect(
        (circulos[3].radius, circulos[3].paint.color.toARGB32()),
        (13.5, AppColors.flame.toARGB32()),
      );
      expect(
        (
          circulos[4].radius,
          circulos[4].paint.style,
          circulos[4].paint.strokeWidth,
        ),
        (12.75, PaintingStyle.stroke, 1.5),
      );
    });

    test('nos pixels: o aro claro entre o miolo e o arco-íris', () async {
      final g = ui.PictureRecorder();
      const ConicRingPainter(
        border: AppColors.ink,
        center: AppColors.flame,
        centerRadius: 13.5,
        halo: (color: AppColors.surface, width: 2.5),
      ).paint(Canvas(g), const Size(42, 42));
      final img = await g.endRecording().toImage(42, 42);
      final b = (await img.toByteData())!;
      img.dispose();
      expect(_px(b, 42, 21, 21), AppColors.flame, reason: 'o miolo');
      // de 13,5 a 16 do centro: o aro (x = 21 + 14,75)
      final aro = _px(b, 42, 36, 21);
      for (final (x, y) in [
        (aro.r, AppColors.surface.r),
        (aro.g, AppColors.surface.g),
        (aro.b, AppColors.surface.b),
      ]) {
        expect((x - y).abs() * 255, lessThanOrEqualTo(3), reason: 'o aro');
      }
    });

    test('repinta só quando muda', () {
      const a = ConicRingPainter(
        border: AppColors.ink,
        center: AppColors.flame,
        centerRadius: 13.5,
        halo: (color: AppColors.surface, width: 2.5),
      );
      expect(
        a.shouldRepaint(
          const ConicRingPainter(
            border: AppColors.ink,
            center: AppColors.flame,
            centerRadius: 13.5,
            halo: (color: AppColors.surface, width: 2.5),
          ),
        ),
        isFalse,
      );
      for (final b in const [
        ConicRingPainter(
          border: AppColors.inkNight,
          center: AppColors.flame,
          centerRadius: 13.5,
          halo: (color: AppColors.surface, width: 2.5),
        ),
        ConicRingPainter(
          border: AppColors.ink,
          center: AppColors.sun,
          centerRadius: 13.5,
          halo: (color: AppColors.surface, width: 2.5),
        ),
        ConicRingPainter(
          border: AppColors.ink,
          center: AppColors.flame,
          centerRadius: 7,
          halo: (color: AppColors.surface, width: 2.5),
        ),
        ConicRingPainter(
          border: AppColors.ink,
          center: AppColors.flame,
          centerRadius: 13.5,
        ),
      ]) {
        expect(a.shouldRepaint(b), isTrue);
      }
    });
  });
}
