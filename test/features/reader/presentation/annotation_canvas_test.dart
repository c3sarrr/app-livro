// G16.6 — o canvas do modo anotação (L22a): o dedo vira traço pela sessão (ao vivo e, ao soltar, na página, nas
// coordenadas do leitor limpo); a página é pintada 30 px abaixo e recortada na caixa `ann.page`; 2 dedos movem a
// página até o limite e, soltando além dele, ela volta em 220 ms (D-165); o indicador de toque só com o dedo, centrado
// nele, e só o anel na Borracha e no Laço (D-167 6); o Laço e a seleção tracejados; a borda de mesa no pé da tela,
// sem receber toque; o rótulo da página para o leitor de tela.
import 'dart:async';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/reader/annotations/ink/gesture_arbiter.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/application/annotation_anchors.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:app_leitura/features/reader/presentation/annotation_canvas.dart';
import 'package:app_leitura/features/reader/presentation/ink_latency_meter.dart';
import 'package:app_leitura/features/reader/presentation/ink_painter.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_ink_repository.dart';
import '../../../support/personal_builders.dart';

const _caixa = Rect.fromLTRB(28, 116, 362, 844);
const _papel = Color(0xFFF8F1E4);

/// Duas linhas: uma em cima (linha de base 130) e a última em 700 (a página pode subir 700 + 30 − 594 = 136).
InkPageGeometry _geometria() => const InkPageGeometry([
  InkLine(
    unit: 4,
    from: 0,
    to: 16,
    top: 104,
    bottom: 139.25,
    baseline: 130,
    em: 20.5,
    left: 28,
    right: 190,
    words: [
      (from: 0, to: 5, left: 28, right: 83),
      (from: 6, to: 8, left: 89, right: 109),
      (from: 9, to: 16, left: 115, right: 190),
    ],
  ),
  InkLine(
    unit: 4,
    from: 17,
    to: 27,
    top: 674,
    bottom: 709.25,
    baseline: 700,
    em: 20.5,
    left: 28,
    right: 133,
    words: [
      (from: 17, to: 18, left: 28, right: 39),
      (from: 19, to: 23, left: 45, right: 92),
      (from: 24, to: 27, left: 98, right: 133),
    ],
  ),
]);

final class _Anchors implements AnnotationAnchors {
  @override
  String get sha => shaTeste;
  @override
  String? textOf(int spine) =>
      spine == 4 ? 'Olhos de ressaca a vaga que' : null;
  @override
  ({int refPage, int chapterIndex}) placeOf(int spine, int offset) =>
      (refPage: 159, chapterIndex: 31);
}

/// A página: anota a translação e o recorte de cada pintura.
final class _Pagina implements DisplayPage {
  final ty = <double>[];
  final recortes = <Rect>[];

  @override
  void paint(ui.Canvas canvas) {
    ty.add(canvas.getTransform()[13]);
    recortes.add(canvas.getDestinationClipBounds());
  }

  @override
  bool get alive => true;
  @override
  bool get opaque => false;
  @override
  String get spokenText => '';
  @override
  LinkHit? linkAt(ui.Offset p) => null;
  @override
  List<Rect> rectsOf(int unit, int from, int to) => const [];
  @override
  ReaderRange? get shown => (unit: 4, from: 0, to: 27);
  @override
  ReaderSpot? spotAt(ui.Offset p) => null;
  @override
  ReaderRange? wordAround(ReaderSpot s) => null;
  @override
  ReaderRange? wordAt(ui.Offset p) => null;
  @override
  List<TextLineBox> boxesOf(int unit, int from, int to) => const [];
  @override
  String textOf(int unit, int from, int to) => '';
}

/// O relógio do rascunho parado (nenhum timer pendente no fim do teste).
final class _Parado implements Timer {
  @override
  void cancel() {}
  @override
  bool get isActive => false;
  @override
  int get tick => 0;
}

/// Grava os caminhos do pintor ao vivo.
final class _Tela implements ui.Canvas {
  final caminhos = <(Path, Paint)>[];

  @override
  void drawPath(Path path, Paint paint) => caminhos.add((path, paint));

  @override
  Object? noSuchMethod(Invocation invocation) => null;
}

AnnotationSession _sessao() => AnnotationSession(
  geometry: _geometria(),
  anchors: _Anchors(),
  drawings: const [],
  highlights: const [],
  presets: presetsTeste(),
  repository: FakeInkRepository(),
  owner: usuarioTeste,
  userBookId: idTeste(1),
  startTimer: (_, _) => _Parado(),
);

void main() {
  final vivas = <AnnotationSession>[];
  late AnnotationSession sessao;
  late _Pagina pagina;

  Future<void> montar(WidgetTester tester, {InkLatencyMeter? medidor}) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    final velhas = [...vivas];
    sessao = _sessao();
    vivas.add(sessao);
    pagina = _Pagina();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: AnnotationCanvas(
            session: sessao,
            page: pagina,
            pageBox: _caixa,
            paper: _papel,
            semanticsLabel: 'Dom Casmurro, página 159 de 256 — modo anotação',
            meter: medidor,
          ),
        ),
      ),
    );
    for (final v in velhas) {
      vivas.remove(v);
      v.dispose();
    }
  }

  Finder chave(String k) => find.byKey(ValueKey<String>(k));

  tearDown(() {
    for (final v in vivas) {
      v.dispose();
    }
    vivas.clear();
  });

  testWidgets(
    'com o medidor de latência do S4 (--dart-define), vão a ele os eventos que mudam a tela (não o dedo parado)',
    (tester) async {
      final m = InkLatencyMeter(
        addTimings: (_) {},
        removeTimings: (_) {},
        log: (_) {},
      );
      await montar(tester, medidor: m);
      final g = await tester.startGesture(const Offset(60, 300));
      await g.moveTo(
        const Offset(80, 302),
        timeStamp: const Duration(milliseconds: 16),
      );
      // o mesmo ponto de novo (a caneta só mudando a pressão): nada a pintar
      await g.moveTo(
        const Offset(80, 302),
        timeStamp: const Duration(milliseconds: 24),
      );
      await g.moveTo(
        const Offset(100, 304),
        timeStamp: const Duration(milliseconds: 32),
      );
      await g.up(timeStamp: const Duration(milliseconds: 40));
      await tester.pump();
      expect(m.eventsUs, [0, 16000, 32000]);
    },
  );

  testWidgets(
    'a página 30 px abaixo, recortada na caixa ann.page; o limite dos 2 dedos (D-165)',
    (tester) async {
      await montar(tester);
      expect(pagina.ty.last, 30);
      expect(pagina.recortes.last, _caixa);
      expect(tester.getRect(chave('ann.page')), _caixa);
      expect(sessao.panLimit, 136);
    },
  );

  testWidgets(
    'o dedo desenha pela sessão: ao vivo, com o indicador; ao soltar, na página (sem os 30 px)',
    (tester) async {
      await montar(tester);
      final g = await tester.startGesture(const Offset(60, 200));
      await g.moveTo(
        const Offset(90, 204),
        timeStamp: const Duration(milliseconds: 16),
      );
      await g.moveTo(
        const Offset(140, 210),
        timeStamp: const Duration(milliseconds: 32),
      );
      await tester.pump();
      expect(sessao.live.value, isA<LiveStroke>());
      expect(
        tester.getRect(chave('ann.page.text.wavy.touchRing')),
        Rect.fromCircle(center: const Offset(140, 210), radius: 19),
      );
      expect(
        tester.getRect(chave('ann.page.text.wavy.touchDot')),
        Rect.fromCircle(center: const Offset(140, 210), radius: 6),
      );
      await g.up();
      await tester.pump();
      expect(sessao.live.value, isNull);
      expect(chave('ann.page.text.wavy.touchRing'), findsNothing);
      final t = sessao.visibleStrokes.single;
      expect((t.points.first.x, t.points.first.y), (60.0, 170.0));
    },
  );

  testWidgets(
    'o indicador: nada com a caneta do aparelho; na Borracha e no Laço, só o anel',
    (tester) async {
      await montar(tester);
      final caneta = await tester.startGesture(
        const Offset(60, 300),
        kind: PointerDeviceKind.stylus,
      );
      await caneta.moveTo(
        const Offset(90, 300),
        timeStamp: const Duration(milliseconds: 16),
      );
      await tester.pump();
      expect(chave('ann.page.text.wavy.touchRing'), findsNothing);
      await caneta.up();
      await tester.pump();
      // depois da caneta, só ela desenha (rejeição de palma): sessão nova para o dedo
      await montar(tester);
      for (final f in [AnnotationTool.eraser, AnnotationTool.lasso]) {
        sessao.setTool(f);
        final g = await tester.startGesture(const Offset(100, 400));
        await g.moveTo(
          const Offset(120, 420),
          timeStamp: const Duration(milliseconds: 16),
        );
        await tester.pump();
        expect(
          chave('ann.page.text.wavy.touchRing'),
          findsOneWidget,
          reason: '$f',
        );
        expect(
          chave('ann.page.text.wavy.touchDot'),
          findsNothing,
          reason: '$f',
        );
        await g.up();
        await tester.pump();
      }
    },
  );

  testWidgets(
    '2 dedos movem a página; soltando além do limite, ela volta em 220 ms (D-165)',
    (tester) async {
      await montar(tester);
      final a = await tester.startGesture(const Offset(100, 400));
      final b = await tester.startGesture(const Offset(200, 400));
      await a.moveBy(const Offset(0, -40));
      await b.moveBy(const Offset(0, -40));
      await tester.pump();
      expect(sessao.panOffset, -40);
      expect(pagina.ty.last, 30 - 40);
      await a.moveBy(const Offset(0, -300));
      await b.moveBy(const Offset(0, -300));
      await tester.pump();
      expect(
        sessao.panOffset,
        greaterThan(-340),
        reason: 'mola além do limite',
      );
      final antes = pagina.ty.last;
      await a.up();
      await b.up();
      await tester.pump();
      expect(sessao.panOffset, -136);
      expect(pagina.ty.last, antes, reason: 'a volta começa de onde estava');
      await tester.pump(const Duration(milliseconds: 110));
      expect(pagina.ty.last, allOf(lessThan(30 - 136), greaterThan(antes)));
      await tester.pump(const Duration(milliseconds: 120));
      expect(pagina.ty.last, 30 - 136);
      // nenhum traço ficou dos 2 dedos
      expect(sessao.visibleStrokes, isEmpty);
    },
  );

  test('o Laço ao vivo e a seleção: lavanda a 35 % e o traço #1A1714 de 1,7 tracejado 4/3', () {
    final s = _sessao()..setTool(AnnotationTool.lasso);
    addTearDown(s.dispose);
    final pan = ValueNotifier<double>(0);
    InkPointer p(double x, double y, int t) =>
        (id: 1, kind: InkPointerKind.touch, x: x, y: y, pressure: 1, tMs: t);
    s
      ..pointerDown(p(40, 150, 0))
      ..pointerMove(p(200, 150, 16))
      ..pointerMove(p(200, 260, 32))
      ..pointerMove(p(40, 260, 48));
    final tela = _Tela();
    AnnotationLivePainter(
      session: s,
      pageBox: _caixa,
      pan: pan,
    ).paint(tela, const Size(390, 844));
    expect(tela.caminhos, hasLength(2));
    final (forma, fundo) = tela.caminhos.first;
    expect(fundo.color.toARGB32(), 0x59B6ACE4);
    expect(forma.getBounds(), const Rect.fromLTRB(40, 120, 200, 230));
    final (tracos, linha) = tela.caminhos.last;
    expect(linha.style, PaintingStyle.stroke);
    expect(linha.strokeWidth, closeTo(1.7, 1e-6));
    expect(linha.color.toARGB32(), AppColors.ink.toARGB32());
    expect(
      tracos.computeMetrics().length,
      greaterThan(20),
      reason: 'tracejado',
    );
  });

  test('dashedPath: traços de 4 com vãos de 3', () {
    final d = dashedPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(23, 0),
      4,
      3,
    );
    expect(
      [for (final m in d.computeMetrics()) (m.length * 1000).round() / 1000],
      [4, 4, 4, 2],
    );
  });

  testWidgets(
    'a borda de mesa: 250 no pé, o papel opaco nos 135 de baixo; o toque passa para a página',
    (tester) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      var toques = 0;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => toques++,
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DeskEdge(paper: _papel),
              ),
            ],
          ),
        ),
      );
      expect(
        tester.getRect(chave('ann.deskEdge')),
        const Rect.fromLTWH(0, 594, 390, 250),
      );
      final g =
          (tester.widget<DecoratedBox>(chave('ann.deskEdge')).decoration
                      as BoxDecoration)
                  .gradient!
              as LinearGradient;
      expect(g.colors, [_papel, _papel, _papel.withValues(alpha: 0)]);
      expect(g.stops, [0, 135 / 250, 1]);
      expect((g.begin, g.end), (Alignment.bottomCenter, Alignment.topCenter));
      await tester.tapAt(const Offset(195, 800));
      expect(toques, 1);
    },
  );

  testWidgets(
    'semântica: a página diz "‹Título›, página X de Y — modo anotação"',
    (tester) async {
      await montar(tester);
      final h = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(
          'Dom Casmurro, página 159 de 256 — modo anotação',
        ),
        findsOneWidget,
      );
      h.dispose();
    },
  );

  test('o tipo do ponteiro e a pressão para o árbitro', () {
    expect(inkPointerKind(PointerDeviceKind.touch), InkPointerKind.touch);
    expect(inkPointerKind(PointerDeviceKind.mouse), InkPointerKind.touch);
    expect(inkPointerKind(PointerDeviceKind.stylus), InkPointerKind.stylus);
    expect(
      inkPointerKind(PointerDeviceKind.invertedStylus),
      InkPointerKind.ignored,
    );
    expect(
      inkPressure(
        const PointerDownEvent(pressure: 3, pressureMin: 1, pressureMax: 5),
      ),
      0.5,
    );
    expect(inkPressure(const PointerDownEvent(pressure: 0.7)), 0.7);
    // a cache da tinta da sessão é a do pintor da página
    expect(InkPictureCache(capacity: 1).capacity, 1);
  });
}
