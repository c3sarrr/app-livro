// G18.3 — o abridor do Espaço (tela 24, L24.1–L24.2): as peças nos lugares da prancha, o `role=status` "Abrindo
// espaço: N linhas" (o chip e o desenho fora da árvore), o chip "↕ 3 linhas" (Figtree 12,5/800 no papel sobre a
// tinta, raio 9) e a pintura: a hachura a 135° (4 lavanda · 5 papel), a costura e as bolinhas violeta, a bolinha do
// rastro e o dedo lavanda a 55 %, sem camada (regra 12.4). Noite (R14): o chip claro com letras na tinta.
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/features/reader/annotations/space/hand_note_layout.dart';
import 'package:app_leitura/features/reader/presentation/space_opener.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/reference_layout_24_abrindo_espaco.dart';
import '../../../support/load_fonts.dart';
import '../../../support/precache_svgs.dart';

Rect _ref(String id) => kRef24.elements['sp.page.spaceOpener$id']!.rect;

final Rect _area = _ref('.area');
final double _dedo = _area.left + 0.58 * _area.width;

Future<void> _montar(
  WidgetTester tester, {
  int linhas = 3,
  OpenerColors cores = OpenerColors.paper,
}) async {
  tester.view
    ..devicePixelRatio = 3
    ..physicalSize = const Size(390 * 3, 844 * 3);
  addTearDown(tester.view.reset);
  await precacheSvgs(tester, const [AppIconsLeitor.arrowsVertical]);
  await precacheSvgs(
    tester,
    const [AppIconsLeitor.arrowsVertical],
    colors: {AppColors.paper: AppColors.ink},
  );
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Positioned.fill(
            child: SpaceOpener(
              area: _area,
              lines: linhas,
              fingerX: _dedo,
              colors: cores,
            ),
          ),
        ],
      ),
    ),
  );
}

Finder _chave(String id) =>
    find.byKey(ValueKey<String>('ann.page.spaceOpener$id'));

/// Os pixels RGBA (sem pré-multiplicar) do abridor pintado sozinho em 3×, a partir de (20, 400).
Future<Uint8List> _pintar(OpenerColors cores) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)
    ..scale(3)
    ..translate(-20, -400);
  OpenerPainter(
    parts: openerLayout(_area, _dedo),
    colors: cores,
  ).paint(canvas, const Size(390, 844));
  final image = recorder.endRecording().toImageSync(350 * 3, 160 * 3);
  final data = await image.toByteData(
    format: ui.ImageByteFormat.rawStraightRgba,
  );
  image.dispose();
  return data!.buffer.asUint8List();
}

/// O pixel no ponto (x, y) da tela (o centro do pixel físico que o contém).
Color _em(Uint8List rgba, double x, double y) {
  final i = (((y - 400) * 3).floor() * 350 * 3 + ((x - 20) * 3).floor()) * 4;
  return Color.fromARGB(rgba[i + 3], rgba[i], rgba[i + 1], rgba[i + 2]);
}

Matcher _cor(Color c, {int tol = 2}) => predicate<Color>(
  (g) => [
    (g.a - c.a).abs(),
    (g.r - c.r).abs(),
    (g.g - c.g).abs(),
    (g.b - c.b).abs(),
  ].every((d) => d * 255 <= tol),
  '≈ $c',
);

void main() {
  setUpAll(loadAppFonts);

  testWidgets('as peças nos lugares da prancha 24', (tester) async {
    await _montar(tester);
    final falhas = <String>[];
    for (final id in [
      '',
      '.area',
      '.seam',
      '.seamDotLeft',
      '.seamDotRight',
      '.trail',
      '.finger',
      '.sizeChip',
      '.sizeChip.icon',
    ]) {
      final r = tester.getRect(_chave(id));
      final e = _ref(id);
      // o abridor e a área: n·L − 2 = 103,78 contra os 104 do arquivo (±0,5); o chip depende do texto (±1 em x/w)
      final tx = kRef24.textDependentX.contains('sp.page.spaceOpener$id')
          ? 1.0
          : 0.5;
      for (final (o, g, x, tol) in [
        ('x', r.left, e.left, tx),
        ('y', r.top, e.top, 0.5),
        ('w', r.width, e.width, tx),
        ('h', r.height, e.height, 0.5),
      ]) {
        if ((g - x).abs() > tol + 1e-6) {
          falhas.add(
            '$id.$o: ${g.toStringAsFixed(2)} ≠ ${x.toStringAsFixed(2)}',
          );
        }
      }
    }
    expect(falhas, isEmpty);
  });

  testWidgets(
    'o chip: "3 linhas" em Figtree 12,5/800 no papel, sobre a tinta, raio 9',
    (tester) async {
      await _montar(tester);
      final texto = tester.widget<AppText>(_chave('.sizeChip.text'));
      expect(texto.span.toPlainText(), '3 linhas');
      final estilo = texto.span.style!;
      expect(estilo.fontSize, AppTextStyles.annOpenerChip.fontSize);
      expect(estilo.fontWeight, FontWeight.w800);
      expect(estilo.color, AppColors.paper);
      final chip = tester.widget<Container>(_chave('.sizeChip'));
      final deco = chip.decoration! as BoxDecoration;
      expect(deco.color, AppColors.ink);
      expect(deco.borderRadius, BorderRadius.circular(9));
      final icone = tester.widget<AppSvg>(_chave('.sizeChip.icon'));
      expect(icone.asset, AppIconsLeitor.arrowsVertical);
      expect(icone.size, 14);
      expect(icone.colors, isNull); // o arquivo já vem no papel
      // a linha do texto na altura do arquivo (base 474,45)
      final t = tester.getRect(_chave('.sizeChip.text'));
      expect(t.left, closeTo(72, 1.0));
      expect(t.right, closeTo(115.7, 1.0));
    },
  );

  testWidgets(
    'leitor de tela: "Abrindo espaço: 3 linhas" (status), "1 linha" no singular',
    (tester) async {
      final semantica = tester.ensureSemantics();
      await _montar(tester);
      expect(
        tester.getSemantics(_chave('')),
        matchesSemantics(label: 'Abrindo espaço: 3 linhas', isLiveRegion: true),
      );
      // o chip e o desenho ficam fora da árvore (o rótulo já diz o tamanho)
      expect(find.bySemanticsLabel('3 linhas'), findsNothing);
      await _montar(tester, linhas: 1);
      expect(find.bySemanticsLabel('Abrindo espaço: 1 linha'), findsOneWidget);
      expect(
        tester.widget<AppText>(_chave('.sizeChip.text')).span.toPlainText(),
        '1 linha',
      );
      semantica.dispose();
    },
  );

  testWidgets('o abridor só mostra: o toque passa para o canvas por baixo', (
    tester,
  ) async {
    await _montar(tester);
    final ignora = tester.widget<IgnorePointer>(
      find
          .descendant(
            of: find.byType(SpaceOpener),
            matching: find.byType(IgnorePointer),
          )
          .first,
    );
    expect(ignora.ignoring, isTrue);
  });

  testWidgets('Noite (R14): o chip claro com letras e setas na tinta', (
    tester,
  ) async {
    await _montar(tester, cores: OpenerColors.night);
    final deco =
        tester.widget<Container>(_chave('.sizeChip')).decoration!
            as BoxDecoration;
    expect(deco.color, AppColors.inkNight);
    expect(
      tester.widget<AppText>(_chave('.sizeChip.text')).span.style!.color,
      AppColors.ink,
    );
    expect(tester.widget<AppSvg>(_chave('.sizeChip.icon')).colors, {
      AppColors.paper: AppColors.ink,
    });
  });

  test('as cores do papel e do Noite', () {
    const p = OpenerColors.paper;
    expect(p.line, AppColors.violet);
    expect(p.hatch, const Color(0x52B6ACE4));
    expect(p.hatchGap, const Color(0xE6FFFDF8));
    expect(p.finger, const Color(0x8CB6ACE4));
    expect(p.fingerDash, AppColors.ink);
    const n = OpenerColors.night;
    expect(n.line, AppColors.lavender);
    expect(n.hatchGap, const Color(0xE61F1B17));
    expect(n.fingerDash, AppColors.inkNight);
    expect(linesLabel(1), '1 linha');
    expect(linesLabel(2), '2 linhas');
    expect(linesLabel(12), '12 linhas');
  });

  group('a pintura', () {
    test('a costura, as bolinhas e a bolinha do rastro em violeta; o dedo lavanda a 55 %', () async {
      final px = await _pintar(OpenerColors.paper);
      final seam = _ref('.seam');
      expect(_em(px, seam.center.dx, 418.1), _cor(AppColors.violet));
      expect(
        _em(px, _ref('.seamDotLeft').center.dx, _ref('.seamDotLeft').center.dy),
        _cor(AppColors.violet),
      );
      expect(
        _em(
          px,
          _ref('.seamDotRight').center.dx,
          _ref('.seamDotRight').center.dy,
        ),
        _cor(AppColors.violet),
      );
      // a bolinha de 4 no começo do rastro (4 abaixo do topo dele)
      expect(_em(px, _dedo, _ref('.trail').top + 4), _cor(AppColors.violet));
      // o dedo, abaixo da área (sem a hachura por baixo)
      expect(_em(px, _dedo, _area.bottom + 12), _cor(const Color(0x8CB6ACE4)));
      // fora de tudo, nada
      expect(_em(px, 25, 540), _cor(const Color(0x00000000)));
    });

    test('a hachura a 135°: faixas "/" de 4 lavanda e 5 papel (9 · √2 na horizontal)', () async {
      final px = await _pintar(OpenerColors.paper);
      // a linha do meio da área, entre o chip (até 126) e o rastro (de 209)
      bool lavanda(double x, double y) => _em(px, x, y).a * 255 < 156;
      var iguaisBarra = 0, iguaisContra = 0, total = 0;
      final runs = <bool, List<int>>{true: [], false: []};
      bool? atual;
      var n = 0;
      for (var i = 0; i < 70 * 3; i++) {
        final x = 135 + i / 3 + 1 / 6;
        final l = lavanda(x, 470.2);
        if (l == atual) {
          n++;
        } else {
          if (atual != null && n > 0) runs[atual]!.add(n);
          atual = l;
          n = 1;
        }
        total++;
        if (l == lavanda(x - 3, 470.2 + 3)) iguaisBarra++;
        if (l == lavanda(x + 3, 470.2 + 3)) iguaisContra++;
      }
      // as faixas seguem a "/" (x + y constante) e não a "\"
      expect(iguaisBarra / total, greaterThan(0.95));
      expect(iguaisContra / total, lessThan(0.8));
      // descartadas as pontas (cortadas pela janela), as faixas têm 4√2 e 5√2 de largura (em pixels de 3×)
      double media(List<int> r) =>
          r.sublist(1, r.length - 1).reduce((a, b) => a + b) / (r.length - 2);
      expect(media(runs[true]!), closeTo(4 * 1.41421 * 3, 1.5));
      expect(media(runs[false]!), closeTo(5 * 1.41421 * 3, 1.5));
      // as duas cores do arquivo, no miolo das faixas
      final cores = [
        for (var x = 135.0; x < 205; x += 1 / 3) _em(px, x, 470.2),
      ];
      expect(cores, contains(_cor(const Color(0x52B6ACE4))));
      expect(cores, contains(_cor(const Color(0xE6FFFDF8))));
    });

    test(
      'a borda tracejada violeta de 1,5 por dentro da área, raio 14',
      () async {
        final px = await _pintar(OpenerColors.paper);
        // a coluna da borda da esquerda (28 a 29,5) tem traços violeta e vãos
        var violeta = 0, outros = 0;
        for (var y = _area.top + 16; y < _area.bottom - 16; y += 1 / 3) {
          final c = _em(px, 28.5, y);
          if ((c.r * 255 - 0x55).abs() < 6 &&
              (c.b * 255 - 0xB7).abs() < 6 &&
              c.a > 0.95) {
            violeta++;
          } else {
            outros++;
          }
        }
        expect(violeta, greaterThan(outros)); // traço 3 · vão 1,5
        expect(outros, greaterThan(0));
        // o canto é redondo: o ponto do canto fica de fora
        expect(_em(px, _area.left + 0.5, _area.bottom - 2).a, lessThan(0.05));
      },
    );

    test('sem camada (regra 12.4)', () {
      final canvas = TestRecordingCanvas();
      OpenerPainter(
        parts: openerLayout(_area, _dedo),
        colors: OpenerColors.paper,
      ).paint(canvas, const Size(390, 844));
      expect(
        canvas.invocations.where((c) => c.invocation.memberName == #saveLayer),
        isEmpty,
      );
    });

    test('repinta quando muda o tamanho ou a cor', () {
      final a = OpenerPainter(
        parts: openerLayout(_area, _dedo),
        colors: OpenerColors.paper,
      );
      expect(
        a.shouldRepaint(
          OpenerPainter(
            parts: openerLayout(_area, _dedo),
            colors: OpenerColors.paper,
          ),
        ),
        isFalse,
      );
      expect(
        a.shouldRepaint(
          OpenerPainter(
            parts: openerLayout(_area, _dedo + 1),
            colors: OpenerColors.paper,
          ),
        ),
        isTrue,
      );
      expect(
        a.shouldRepaint(
          OpenerPainter(
            parts: openerLayout(_area, _dedo),
            colors: OpenerColors.night,
          ),
        ),
        isTrue,
      );
    });
  });
}
