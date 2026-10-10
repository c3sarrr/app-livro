// G16.6 — o canvas do modo anotação (L22a): o dedo vira traço pela sessão (ao vivo e, ao soltar, na página, nas
// coordenadas do leitor limpo); a página é pintada 30 px abaixo e recortada na caixa `ann.page`; 2 dedos movem a
// página até o limite e, soltando além dele, ela volta em 220 ms (D-165); o indicador de toque só com o dedo, centrado
// nele, e só o anel na Borracha e no Laço (D-167 6); o Laço e a seleção tracejados; a borda de mesa no pé da tela,
// sem receber toque; o rótulo da página para o leitor de tela. G17 (R26): no Noite, o marca-texto ao vivo vai na
// folha, por trás e por cima do texto (D-133), e a caneta ao vivo pela D-174.
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/painters/svg_dash_painter.dart'
    show dashedPath;
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

import '../../../support/capture.dart';
import '../../../support/fake_ink_repository.dart';
import '../../../support/personal_builders.dart';

const _caixa = Rect.fromLTRB(28, 116, 362, 844);
const _papel = Color(0xFFF8F1E4);

/// Duas linhas: uma em cima (linha de base 130) e a última em 700, com a base (o pé) em 709,25: a página pode subir
/// 709,25 + 30 − 594 = 145,25 (D-165: até a base da última linha passar do topo da borda de mesa).
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
  String get spokenText => 'Olhos de ressaca a vaga que';
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

  /// As camadas (o modo de cada uma) e quantos caminhos vieram antes de cada uma.
  final camadas = <(BlendMode, int)>[];
  @override
  void saveLayer(Rect? bounds, Paint paint) =>
      camadas.add((paint.blendMode, caminhos.length));

  @override
  Object? noSuchMethod(Invocation invocation) => null;
}

/// Uma página que não pinta nada (para o registro de caminhos).
final class _PaginaMuda implements DisplayPage {
  @override
  void paint(ui.Canvas canvas) {}
  @override
  ReaderRange? get shown => (unit: 4, from: 0, to: 27);
  @override
  List<TextLineBox> boxesOf(int unit, int from, int to) => const [];
  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
      expect(sessao.panLimit, 145.25);
      // a tinta da sessão nas 3 passadas do Noite (por trás, com os fundos e por cima) sem uma tirar a outra da cache
      final folha =
          tester.widget<CustomPaint>(chave('ann.canvas.page')).painter!
              as AnnotationPagePainter;
      expect(folha.pictures.capacity, 3);
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
      expect(sessao.panOffset, -145.25);
      expect(pagina.ty.last, antes, reason: 'a volta começa de onde estava');
      await tester.pump(const Duration(milliseconds: 110));
      expect(pagina.ty.last, allOf(lessThan(30 - 145.25), greaterThan(antes)));
      await tester.pump(const Duration(milliseconds: 120));
      expect(pagina.ty.last, 30 - 145.25);
      // nenhum traço ficou dos 2 dedos
      expect(sessao.visibleStrokes, isEmpty);
    },
  );

  testWidgets(
    'tocar durante a volta do batente leva a página ao lugar final na hora: o traço sai sob o dedo (D-165)',
    (tester) async {
      await montar(tester);
      final limite = sessao.panLimit;
      final a = await tester.startGesture(const Offset(100, 400));
      final b = await tester.startGesture(const Offset(200, 400));
      await a.moveBy(Offset(0, -(limite + 90)));
      await b.moveBy(Offset(0, -(limite + 90)));
      await tester.pump();
      await a.up();
      await b.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(pagina.ty.last, lessThan(30 - limite - 1), reason: 'voltando');
      final g = await tester.startGesture(const Offset(150, 300));
      await tester.pump();
      expect(pagina.ty.last, moreOrLessEquals(30 - limite, epsilon: 1e-9));
      await g.moveTo(const Offset(190, 300));
      await g.up();
      await tester.pump();
      expect(
        sessao.visibleStrokes.single.points.first.y,
        moreOrLessEquals(300 - 30 + limite, epsilon: 1e-9),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(pagina.ty.last, moreOrLessEquals(30 - limite, epsilon: 1e-9));
    },
  );

  testWidgets(
    'o dedo andando não repinta a página (o traço ao vivo e o indicador ficam nas camadas deles); soltar repinta 1 vez',
    (tester) async {
      await montar(tester);
      final g = await tester.startGesture(const Offset(60, 300));
      await tester.pump();
      final antes = pagina.ty.length;
      for (var i = 1; i <= 5; i++) {
        await g.moveTo(
          Offset(60 + 10.0 * i, 300 + (i.isEven ? 2 : 0)),
          timeStamp: Duration(milliseconds: 16 * i),
        );
        await tester.pump();
      }
      expect(pagina.ty.length, antes, reason: 'a página não repinta');
      await g.up(timeStamp: const Duration(milliseconds: 100));
      await tester.pump();
      expect(pagina.ty.length, antes + 1, reason: 'o traço entra na página');
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

  group('G17 — o Noite ao vivo (R26, D-174)', () {
    const letra = AppColors.bookTextNight;
    InkPointer p(double x, double y, int t) =>
        (id: 1, kind: InkPointerKind.touch, x: x, y: y, pressure: 1, tMs: t);

    test('o marca-texto ao vivo: no Creme, a camada viva multiplica; no Noite, vai na folha, por trás e por cima do texto', () {
      final s = _sessao()..setTool(AnnotationTool.marker);
      addTearDown(s.dispose);
      final pan = ValueNotifier<double>(0);
      // sobre "de ressaca" (a linha de cima, 30 abaixo no modo)
      s
        ..pointerDown(p(90, 152, 0))
        ..pointerMove(p(180, 152, 16));
      expect(s.live.value, isA<LiveMarker>());
      final creme = _Tela();
      AnnotationLivePainter(
        session: s,
        pageBox: _caixa,
        pan: pan,
      ).paint(creme, const Size(390, 844));
      expect(creme.caminhos.single.$2.blendMode, BlendMode.multiply);
      final viva = _Tela();
      AnnotationLivePainter(
        session: s,
        pageBox: _caixa,
        pan: pan,
        lightText: letra,
      ).paint(viva, const Size(390, 844));
      expect(viva.caminhos, isEmpty);
      final fotos = InkPictureCache();
      addTearDown(fotos.dispose);
      AnnotationPagePainter folha() => AnnotationPagePainter(
        session: s,
        page: _PaginaMuda(),
        pageBox: _caixa,
        paper: AppColors.paperNight,
        pan: pan,
        pictures: fotos,
        lightText: letra,
      );
      final tela = _Tela();
      folha().paint(tela, const Size(390, 844));
      // por trás D − cor; por cima D em diferença — sem camada (a regra 12.4)
      expect(
        [for (final (_, paint) in tela.caminhos) paint.blendMode],
        [BlendMode.srcOver, BlendMode.difference],
      );
      expect(tela.camadas, isEmpty);
      // a folha do Noite repinta com o traço ao vivo
      var avisos = 0;
      folha().addListener(() => avisos++);
      s.pointerMove(p(200, 152, 32));
      expect(avisos, 1);
      s.pointerUp(p(200, 152, 48));
    });

    test(
      'achado 17: no Noite, o Marca-texto ao vivo de outra cor por cima de um salvo — vale o ao vivo, com a conta da '
      'D-133 uma vez (o salvo é recortado fora dele só onde ele o toca)',
      () async {
        final s = _sessao()..setTool(AnnotationTool.marker);
        addTearDown(s.dispose);
        final pan = ValueNotifier<double>(0);
        // o salvo, deitado fora do texto (no texto, o Marca-texto vira grifo — G17)
        s
          ..pointerDown(p(40, 330, 0))
          ..pointerMove(p(120, 330, 16))
          ..pointerMove(p(180, 330, 32))
          ..pointerUp(p(180, 330, 48));
        final salvo = s.visibleStrokes.single;
        s.setHighlighterColor('#FFC1C6');
        // o ao vivo, em pé, cruzando o salvo
        s
          ..pointerDown(p(110, 290, 100))
          ..pointerMove(p(110, 330, 116))
          ..pointerMove(p(110, 370, 132));
        final vivo = s.liveMarker.value!;
        expect(vivo.argb, isNot(salvo.argb));
        final fotos = InkPictureCache();
        addTearDown(fotos.dispose);
        final gravador = ui.PictureRecorder();
        AnnotationPagePainter(
          session: s,
          page: _PaginaMuda(),
          pageBox: _caixa,
          paper: AppColors.paperNight,
          pan: pan,
          pictures: fotos,
          lightText: letra,
        ).paint(Canvas(gravador), const Size(390, 844));
        final img = await gravador.endRecording().toImage(390, 844);
        final bytes = (await img.toByteData())!;
        img.dispose();
        void cor(double x, double y, int argb, String onde) {
          final i = ((y + s.textShift).round() * 390 + x.round()) * 4;
          final esperada = Color(argb | 0xFF000000);
          for (final (k, c) in [
            (0, esperada.r),
            (1, esperada.g),
            (2, esperada.b),
          ]) {
            expect(
              (bytes.getUint8(i + k) - c * 255).abs(),
              lessThanOrEqualTo(1),
              reason: '$onde, canal $k',
            );
          }
        }

        final y = salvo.points.first.y;
        final x = vivo.points.first.x;
        cor(60, y, salvo.argb, 'só o salvo');
        cor(x, y, vivo.argb, 'o ao vivo por cima do salvo');
        cor(x, vivo.points.last.y, vivo.argb, 'só o ao vivo');
        s.pointerUp(p(110, 370, 148));
      },
    );

    test('no Noite, a folha repinta só com o Marca-texto ao vivo (a Caneta e o Laço ficam na camada viva)', () {
      final s = _sessao();
      addTearDown(s.dispose);
      final fotos = InkPictureCache(capacity: 2);
      addTearDown(fotos.dispose);
      var avisos = 0;
      s.pointerDown(p(60, 300, 0));
      AnnotationPagePainter(
        session: s,
        page: _PaginaMuda(),
        pageBox: _caixa,
        paper: AppColors.paperNight,
        pan: ValueNotifier<double>(0),
        pictures: fotos,
        lightText: letra,
      ).addListener(() => avisos++);
      s
        ..pointerMove(p(120, 302, 16))
        ..pointerMove(p(160, 304, 32));
      expect(s.live.value, isA<LiveStroke>());
      expect(s.liveMarker.value, isNull);
      expect(avisos, 0);
      s
        ..pointerUp(p(160, 304, 48))
        ..setTool(AnnotationTool.marker)
        ..pointerDown(p(90, 152, 64));
      avisos = 0;
      s.pointerMove(p(180, 152, 80));
      expect(s.liveMarker.value, (s.live.value! as LiveMarker).stroke);
      expect(avisos, 1);
      s.pointerUp(p(180, 152, 96));
      expect(s.liveMarker.value, isNull);
    });

    test(
      'D-174: a caneta quase preta ao vivo sai na cor das letras do Noite',
      () {
        final s = _sessao()..setPenColor('#1A1714');
        addTearDown(s.dispose);
        s
          ..pointerDown(p(60, 300, 0))
          ..pointerMove(p(120, 302, 16));
        final noite = _Tela();
        AnnotationLivePainter(
          session: s,
          pageBox: _caixa,
          pan: ValueNotifier<double>(0),
          lightText: letra,
        ).paint(noite, const Size(390, 844));
        expect(noite.caminhos.single.$2.color.toARGB32(), 0xFFE3D9C6);
        s.pointerUp(p(120, 302, 32));
      },
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
      // o texto da página também, como no leitor limpo (o `<article>` do arquivo)
      expect(
        tester.getSemantics(
          find.bySemanticsLabel(
            'Dom Casmurro, página 159 de 256 — modo anotação',
          ),
        ),
        isSemantics(
          label: 'Dom Casmurro, página 159 de 256 — modo anotação',
          value: 'Olhos de ressaca a vaga que',
        ),
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
  });

  testWidgets(
    'T01 — o anel do toque: o tracejado em tinta por cima do miolo lavanda a 42 % (no CSS a borda fica sobre o fundo)',
    (tester) async {
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      const chaveDaArte = ValueKey('arte');
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: chaveDaArte,
              child: ColoredBox(
                color: _papel,
                child: SizedBox.square(
                  dimension: 60,
                  child: TouchIndicator(
                    at: Offset(30, 30),
                    ink: AppColors.flame,
                    dot: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final imagem = await captureAt(tester, find.byKey(chaveDaArte));
      final px = await rgbaOf(tester, imagem);
      // o meio do traço (raio 19 − 0,75), volta inteira: o pixel mais escuro é a tinta, não a tinta sob a lavanda
      var escuro = 255 * 3;
      for (var a = 0; a < 360; a++) {
        final p =
            const Offset(30, 30) +
            Offset.fromDirection(a * math.pi / 180, 19 - 0.75);
        final i = ((p.dy * 3).floor() * imagem.width + (p.dx * 3).floor()) * 4;
        final soma = px[i] + px[i + 1] + px[i + 2];
        if (soma < escuro) escuro = soma;
      }
      final tinta = (AppColors.ink.r + AppColors.ink.g + AppColors.ink.b) * 255;
      expect(escuro, lessThanOrEqualTo(tinta + 12));
    },
  );
}
