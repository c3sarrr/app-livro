// G11.3 — virar página (D-22, D-107, D-113) com um livro de mentira de 5 páginas: toque nos terços (esquerdo
// volta, direito avança, centro chama o fechar), o toque num link vale antes dos terços, o arrasto completa
// com 1/4 da largura ou ≥ 300 px/s e volta abaixo disso, a animação leva 220 ms `easeOutCubic`, no começo e no
// fim do livro a página anda 1/3 do dedo e volta (batente), e a vizinha atrasada aparece quando chega. Revisão:
// a vizinha que não abre não é batente, a virada que falha não trava a página, pressão longa não faz nada
// (D-113), seguir um link segura os gestos, e o limite de 300 px/s vale dos dois lados.
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/annotations/domain/annotation.dart'
    show FillHeight, HighlightStyle;
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/application/annotation_anchors.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart'
    show PageDrawing;
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/application/reader_ink.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart'
    show ReaderTypography;
import 'package:app_leitura/features/reader/presentation/ink_painter.dart';
import 'package:app_leitura/features/reader/presentation/page_marks.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Página n: anota onde foi pintada (x da translação do canvas) e tem um link no canto de cima.
final class _Pagina implements DisplayPage, PageWithSpaces {
  _Pagina(this.n, {this.opaque = false, this.letra});

  final int n;

  /// G18: os espaços abertos da página (as notas à mão).
  @override
  List<PageSpace> spaces = const [];

  /// Uma "letra" (um quadrado cheio) dentro da marca da busca, para ler os pixels.
  final Color? letra;
  static const Rect caixaDaLetra = Rect.fromLTWH(45, 124, 8, 12);

  /// A imagem do PDF (fundo branco) cobre o que fica embaixo.
  @override
  final bool opaque;
  final pintadaEm = <double>[];

  static const Rect link = Rect.fromLTWH(150, 100, 90, 30);

  @override
  void paint(ui.Canvas canvas) {
    pintadaEm.add(canvas.getTransform()[12]);
    final l = letra;
    if (l != null) canvas.drawRect(caixaDaLetra, Paint()..color = l);
  }

  @override
  String get spokenText => 'página $n';

  @override
  LinkHit? linkAt(ui.Offset p) => link.contains(p)
      ? (target: 'OEBPS/n.xhtml#$n', spine: 0, offset: n)
      : null;

  @override
  bool get alive => true;

  /// Marca da busca (G12): um retângulo por trecho, na página dele.
  @override
  List<Rect> rectsOf(int unit, int from, int to) => [
    for (final b in boxesOf(unit, from, to)) b.rect,
  ];

  /// G13: o texto todo numa linha só; cada caractere i ocupa 1 px a partir de x = 30 (as letras de 120 a 140), com
  /// a linha de base em 149,6 e a área do texto de 122,41 a 152,85 (em 20,5).
  @override
  List<TextLineBox> boxesOf(int unit, int from, int to) =>
      unit == n && from < to
      ? [
          (
            rect: Rect.fromLTWH(30.0 + from, 120, (to - from).toDouble(), 20),
            baseline: 149.6,
            textTop: 122.41,
            textBottom: 152.85,
            em: 20.5,
          ),
        ]
      : const [];

  @override
  ReaderRange? get shown => (unit: n, from: 0, to: 400);

  @override
  ReaderSpot? spotAt(ui.Offset p) => null;

  @override
  ReaderRange? wordAround(ReaderSpot s) => null;

  @override
  ReaderRange? wordAt(ui.Offset p) => null;

  @override
  String textOf(int unit, int from, int to) => '';
}

final class _Livro implements ReaderDocument {
  _Livro({this.at = 2});

  @override
  AnnotationAnchors? get anchors => null;

  final int total = 5;
  int at;
  late final paginas = [for (var i = 0; i < total; i++) _Pagina(i)];
  final _changes = ValueNotifier<int>(0);
  final viradas = <PageDirection>[];

  /// Segura a vizinha (capítulo ainda sendo montado).
  Completer<void>? segura;

  /// A vizinha não abre (arquivo danificado): o peek dá erro.
  bool quebrada = false;

  ReaderMark? alfinete;

  int? _vizinha(PageDirection d) {
    final j = d == PageDirection.forward ? at + 1 : at - 1;
    return j < 0 || j >= total ? null : j;
  }

  @override
  String get title => 'Livro';

  @override
  DisplayPage get current => paginas[at];

  @override
  Listenable get changes => _changes;

  @override
  ReaderNumbersView get numbers => ReaderNumbersView(
    refPage: at + 1,
    refTotal: total,
    progression: at / total,
  );

  @override
  ReaderMark get mark => (spine: 0, offset: at);

  @override
  RefRange get shownRange => (fromRef: at + 1, toRef: at + 1);

  @override
  Future<DisplayPage?> peek(PageDirection d) async {
    final s = segura;
    if (s != null) await s.future;
    if (quebrada) throw StateError('capítulo vizinho danificado');
    final j = _vizinha(d);
    return j == null ? null : paginas[j];
  }

  @override
  Future<bool> turn(PageDirection d) async {
    final j = _vizinha(d);
    if (j == null) return false;
    viradas.add(d);
    at = j;
    _changes.value++;
    return true;
  }

  @override
  Future<bool> follow(LinkHit link) async => false;

  @override
  Future<void> goTo(ReaderMark m) async {}

  @override
  Future<void> goToRefPage(int refPage) async {}

  @override
  Future<void> flush() async {}

  @override
  Future<void> pin(ReaderMark? mark) async => alfinete = mark;

  @override
  void dispose() {}

  // ---- G12 (os controles não aparecem nestes testes da página) ----
  @override
  String get author => 'Autor';

  @override
  int get totalChars => total * 1500;

  @override
  bool get atEnd => at == total - 1;

  @override
  Stream<SearchGroup> search(String query) => const Stream.empty();

  @override
  ReaderMark markOfRefPage(int refPage) => (spine: 0, offset: refPage - 1);

  @override
  BookmarkDraft bookmarkHere() => throw UnimplementedError();

  @override
  Future<void> recolor(Color ink) async {}

  @override
  Future<void> retypeset(ReaderTypography t) async {}

  @override
  FoundRange? found;

  @override
  void showFound(FoundRange f) {
    found = f;
    _changes.value++;
  }
}

/// Grava o que o pintor desenha: a marca (`rrect`) e o texto (a página lê a translação ao se pintar).
final class _Tela implements ui.Canvas {
  final chamadas = <String>[];
  final marcas = <(RRect, Color)>[];
  final modos = <BlendMode>[];

  @override
  void drawRRect(RRect rrect, Paint paint) {
    chamadas.add('marca');
    marcas.add((rrect, paint.color));
    modos.add(paint.blendMode);
  }

  @override
  Float64List getTransform() {
    chamadas.add('texto');
    return Float64List(16);
  }

  /// O corte da faixa do grifo (o da tela inteira, do pintor, não conta).
  final cortes = <Rect>[];
  @override
  void clipRect(
    Rect rect, {
    ui.ClipOp clipOp = ui.ClipOp.intersect,
    bool doAntiAlias = true,
  }) {
    if (rect.size == const Size(390, 844)) return;
    chamadas.add('corte');
    cortes.add(rect);
  }

  /// O sublinhado.
  final retangulos = <(Rect, Color)>[];
  @override
  void drawRect(Rect rect, Paint paint) {
    chamadas.add('traço');
    retangulos.add((rect, paint.color));
  }

  /// G16: a mancha do grifo feito à mão (o modo de cada uma).
  final manchas = <BlendMode>[];
  @override
  void drawPath(Path path, Paint paint) {
    chamadas.add('mancha');
    manchas.add(paint.blendMode);
  }

  /// G16: a tinta (a `Picture` de cada página).
  final tintas = <ui.Picture>[];
  @override
  void drawPicture(ui.Picture picture) {
    chamadas.add('tinta');
    tintas.add(picture);
  }

  /// G17 (achado 17): nenhuma camada (a regra 12.4) — o Noite recorta os fundos que se cruzam.
  final camadas = <BlendMode>[];
  @override
  void saveLayer(Rect? bounds, Paint paint) {
    chamadas.add('camada');
    camadas.add(paint.blendMode);
  }

  @override
  Object? noSuchMethod(Invocation invocation) => null;
}

/// Os grifos do livro de mentira (G13).
final class _Grifos extends ChangeNotifier implements HighlightSource {
  _Grifos(this.lista);
  List<PaintedHighlight> lista;

  void avisar() => notifyListeners();

  @override
  List<PaintedHighlight> highlightsIn(ReaderRange shown) => [
    for (final h in lista)
      if (h.range.unit == shown.unit) h,
  ];
}

/// A tinta do livro de mentira (G16): um traço em cada página pedida e os grifos feitos à mão.
final class _Tinta extends ChangeNotifier implements InkSource {
  _Tinta({
    this.aMao = const [],
    this.marcador = false,
    this.extra = const [],
    this.notas = const [],
  });

  /// G18: as notas à mão do livro (as da página são as dos espaços dela).
  final List<ReaderNote> notas;

  @override
  List<ReaderNote> notesOn(DisplayPage page) => [
    for (final s in spacesOf(page))
      for (final n in notas)
        if (n.id == s.id) n,
  ];

  List<PaintedHighlight> aMao;

  /// G17: um traço do marca-texto (a tinta translúcida — R22) junto do da caneta.
  final bool marcador;

  /// Traços a mais, depois desses (na ordem).
  final List<InkStroke> extra;
  final pedidas = <int>[];
  int _revisao = 0;

  void mudar() {
    _revisao++;
    notifyListeners();
  }

  @override
  int get revision => _revisao;

  @override
  List<PaintedHighlight> inkHighlightsIn(ReaderRange shown) => [
    for (final h in aMao)
      if (h.range.unit == shown.unit) h,
  ];

  @override
  List<PageDrawing> drawingsOn(DisplayPage page) {
    final n = (page as _Pagina).n;
    pedidas.add(n);
    return [
      (
        saved: (
          layerId: 'camada-$n',
          annotationId: 'desenho-$n',
          createdAt: DateTime.utc(2026, 10, 8),
          groupId: 'desenho-$n',
        ),
        range: (unit: n, from: 0, to: 10),
        strokes: [
          const InkStroke(
            tool: 1,
            tip: 0,
            argb: 0xFFFF552E,
            widthCentiMm: 120,
            points: [InkPoint(30, 140, 0.5, 0), InkPoint(60, 140, 0.5, 8)],
          ),
          if (marcador)
            const InkStroke(
              tool: 3,
              tip: 0,
              argb: 0xE6FED170,
              widthCentiMm: 870,
              points: [InkPoint(30, 160, 0.5, 0), InkPoint(90, 160, 0.5, 8)],
            ),
          ...extra,
        ],
      ),
    ];
  }
}

PaintedHighlight _grifo(
  String id,
  int from,
  int to, {
  Color color = const Color(0xFFFED170),
  HighlightStyle style = HighlightStyle.fill,
}) => PaintedHighlight(
  id: id,
  range: (unit: 2, from: from, to: to),
  color: color,
  style: style,
);

void main() {
  late _Livro livro;
  late List<String> eventos;

  Future<void> montar(
    WidgetTester tester, {
    int at = 2,
    Future<bool> Function(PageDirection d)? virar,
    Future<void> Function(LinkHit h)? seguir,
    bool controlsOpen = false,
    Color? foundColor,
    bool selecting = false,
    bool Function(Offset p)? grifo,
    bool Function(Offset p)? nota,
    bool pressaoLonga = false,
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    livro = _Livro(at: at);
    eventos = [];
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ReaderPageView(
          document: livro,
          onTurn: (d) async {
            eventos.add('virar ${d.name}');
            return virar == null ? livro.turn(d) : virar(d);
          },
          onCenter: () => eventos.add('centro'),
          onLink: (h) async {
            eventos.add('link ${h.target}');
            await seguir?.call(h);
          },
          onInteraction: () => eventos.add('toque'),
          controlsOpen: controlsOpen,
          onDragStarted: () => eventos.add('arrasto'),
          foundColor: foundColor,
          selecting: selecting,
          onTapSelecting: (p) => eventos.add('toque na seleção $p'),
          onTapHighlight: grifo,
          onTapNote: nota,
          onLongPressStart: pressaoLonga
              ? (p) => eventos.add('pressão $p')
              : null,
          onLongPressMove: pressaoLonga
              ? (p) => eventos.add('arrastando $p')
              : null,
          onLongPressEnd: pressaoLonga ? () => eventos.add('soltou') : null,
        ),
      ),
    );
  }

  /// Onde a página [n] foi pintada por último (x).
  double x(int n) => livro.paginas[n].pintadaEm.last;

  testWidgets(
    'toque: terço direito avança, esquerdo volta, centro chama o fechar',
    (tester) async {
      await montar(tester);
      await tester.tapAt(const Offset(350, 400));
      await tester.pumpAndSettle();
      expect(livro.at, 3);
      expect(livro.viradas, [PageDirection.forward]);
      await tester.tapAt(const Offset(40, 400));
      await tester.pumpAndSettle();
      expect(livro.at, 2);
      await tester.tapAt(const Offset(195, 400));
      await tester.pumpAndSettle();
      expect(livro.at, 2);
      expect(eventos.where((e) => e != 'toque'), [
        'virar forward',
        'virar backward',
        'centro',
      ]);
      expect(eventos.where((e) => e == 'toque'), hasLength(3));
    },
  );

  testWidgets(
    'limites dos terços: 129 px volta, 131 px é centro, 261 px avança',
    (tester) async {
      await montar(tester);
      await tester.tapAt(const Offset(129, 600));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(131, 600));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(261, 600));
      await tester.pumpAndSettle();
      expect(eventos.where((e) => e != 'toque'), [
        'virar backward',
        'centro',
        'virar forward',
      ]);
    },
  );

  testWidgets(
    'toque num link vale antes dos terços (o link fica no terço do meio e no direito)',
    (tester) async {
      await montar(tester);
      await tester.tapAt(
        const Offset(230, 110),
      ); // dentro do link, no terço direito
      await tester.pumpAndSettle();
      expect(eventos, ['toque', 'link OEBPS/n.xhtml#2']);
      expect(livro.viradas, isEmpty);
    },
  );

  testWidgets(
    'toque: 220 ms easeOutCubic — na metade do tempo a página andou easeOutCubic(0,5)',
    (tester) async {
      await montar(tester);
      await tester.tapAt(const Offset(350, 400));
      // anda de 1 em 1 ms até a página começar a se mover (o 1º quadro da animação)
      var ms = 0;
      while (x(2) == 0 && ms < 100) {
        await tester.pump(const Duration(milliseconds: 1));
        ms++;
      }
      expect(x(2), lessThan(0));
      await tester.pump(const Duration(milliseconds: 109));
      final meio = -390 * Curves.easeOutCubic.transform(0.5);
      expect(x(2), closeTo(meio, 4), reason: '110 ms de 220');
      expect(x(3), closeTo(x(2) + 390, 0.001), reason: 'a vizinha encostada');
      await tester.pumpAndSettle();
      expect(livro.at, 3);
      expect(x(3), 0);
    },
  );

  testWidgets('arrasto curto e lento volta; até 1/4 da largura completa', (
    tester,
  ) async {
    await montar(tester);
    final g = await tester.startGesture(const Offset(300, 400));
    await g.moveBy(const Offset(-40, 0));
    await tester.pump();
    await g.moveBy(const Offset(-50, 0));
    await tester.pump();
    expect(x(2), closeTo(-90, 0.5), reason: 'a página segue o dedo');
    expect(x(3), closeTo(-90 + 390, 0.5), reason: 'a vizinha vem junto');
    await tester.pump(
      const Duration(seconds: 1),
    ); // parado: solta sem velocidade
    await g.up();
    await tester.pumpAndSettle();
    expect(livro.viradas, isEmpty, reason: '90 px < 97,5 (1/4)');
    expect(x(2), 0);

    final g2 = await tester.startGesture(const Offset(300, 400));
    await g2.moveBy(const Offset(-40, 0));
    await tester.pump();
    await g2.moveBy(const Offset(-60, 0));
    await tester.pump(const Duration(seconds: 1));
    await g2.up();
    await tester.pumpAndSettle();
    expect(livro.viradas, [PageDirection.forward], reason: '100 px ≥ 97,5');
  });

  testWidgets(
    'arrasto rápido completa mesmo curto; rápido no sentido contrário volta',
    (tester) async {
      await montar(tester);
      // 40 px em 50 ms, a 60 Hz (800 px/s) — como um dedo de verdade (o `flingFrom` manda 50 eventos em 50 ms
      // e o medidor de velocidade do Flutter, que guarda só os 20 últimos, vê 15 px e devolve velocidade 0)
      const curto = Duration(milliseconds: 50);
      await tester.timedDragFrom(
        const Offset(300, 400),
        const Offset(-40, 0),
        curto,
      );
      await tester.pumpAndSettle();
      expect(livro.viradas, [PageDirection.forward]);
      await tester.timedDragFrom(
        const Offset(100, 400),
        const Offset(40, 0),
        curto,
      );
      await tester.pumpAndSettle();
      expect(livro.viradas, [PageDirection.forward, PageDirection.backward]);
      // vai 60 px devagar para a esquerda e solta rápido para a direita (+20 px em 20 ms = 1000 px/s): volta
      final g = await tester.startGesture(const Offset(300, 400));
      for (var t = 1; t <= 3; t++) {
        await g.moveBy(
          const Offset(-20, 0),
          timeStamp: Duration(milliseconds: 100 * t),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
      await g.moveBy(
        const Offset(10, 0),
        timeStamp: const Duration(milliseconds: 310),
      );
      await g.moveBy(
        const Offset(10, 0),
        timeStamp: const Duration(milliseconds: 320),
      );
      await g.up(timeStamp: const Duration(milliseconds: 320));
      await tester.pumpAndSettle();
      expect(livro.viradas, hasLength(2));
    },
  );

  testWidgets(
    'batente no fim do livro: anda 1/3 do dedo, volta e não vira; toque na lateral não faz nada',
    (tester) async {
      await montar(tester, at: 4);
      final g = await tester.startGesture(const Offset(300, 400));
      await g.moveBy(const Offset(-30, 0));
      await tester.pump();
      await g.moveBy(const Offset(-120, 0));
      await tester.pump();
      expect(x(4), closeTo(-150 / 3, 0.5));
      await g.up();
      await tester.pumpAndSettle();
      expect(livro.viradas, isEmpty);
      expect(x(4), 0);
      await tester.tapAt(const Offset(350, 400));
      await tester.pumpAndSettle();
      expect(livro.viradas, isEmpty);
      expect(
        eventos.where((e) => e.startsWith('virar')),
        isEmpty,
        reason: 'no fim, o toque na lateral não tenta virar nem desliza',
      );
      expect(livro.paginas[4].pintadaEm.where((v) => v < -51), isEmpty);
      expect(x(4), 0);
    },
  );

  testWidgets('batente no começo do livro, para trás', (tester) async {
    await montar(tester, at: 0);
    await tester.timedDragFrom(
      const Offset(100, 400),
      const Offset(120, 0),
      const Duration(milliseconds: 130),
    );
    await tester.pumpAndSettle();
    expect(livro.viradas, isEmpty);
    expect(x(0), 0);
  });

  testWidgets(
    'vizinha atrasada: desliza o papel e a página aparece quando chega',
    (tester) async {
      await montar(tester);
      livro.segura = Completer<void>();
      await tester.tapAt(const Offset(350, 400));
      await tester.pump(
        const Duration(milliseconds: 60),
      ); // passou a espera curta: desliza sem ela
      await tester.pump(const Duration(milliseconds: 110));
      expect(x(2), lessThan(0), reason: 'deslizando');
      expect(livro.paginas[3].pintadaEm, isEmpty, reason: 'ainda não chegou');
      livro.segura!.complete();
      await tester.pumpAndSettle();
      expect(livro.at, 3);
      expect(x(3), 0);
    },
  );

  testWidgets('um gesto de cada vez: toque durante a virada é ignorado', (
    tester,
  ) async {
    await montar(tester);
    await tester.tapAt(const Offset(350, 400));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tapAt(const Offset(350, 400));
    await tester.pumpAndSettle();
    expect(livro.viradas, [PageDirection.forward]);
  });

  testWidgets(
    'vizinha que não abre não é batente: o toque e o arrasto pedem a virada (a sessão mostra o aviso)',
    (tester) async {
      await montar(
        tester,
        virar: (_) async => false,
      ); // a sessão não virou: mostrou o aviso
      livro.quebrada = true;
      await tester.tapAt(const Offset(350, 400));
      await tester.pumpAndSettle();
      expect(eventos.where((e) => e.startsWith('virar')), ['virar forward']);
      await tester.timedDragFrom(
        const Offset(300, 400),
        const Offset(-150, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();
      expect(
        eventos.where((e) => e.startsWith('virar')),
        ['virar forward', 'virar forward'],
        reason: 'o arrasto acompanha o dedo inteiro (não é o 1/3 do batente) e pede a virada',
      );
      expect(x(2), 0, reason: 'não virou: a página voltou');
    },
  );

  testWidgets('a virada que lança erro não trava a página', (tester) async {
    var falhar = true;
    await montar(
      tester,
      virar: (d) async {
        if (falhar) throw StateError('falhou ao virar');
        return livro.turn(d);
      },
    );
    await tester.tapAt(const Offset(350, 400));
    await tester.pumpAndSettle();
    expect(
      tester.takeException(),
      isA<StateError>(),
      reason: 'relatado (relatório de falhas)',
    );
    expect((livro.at, x(2)), (2, 0.0));
    falhar = false;
    await tester.tapAt(const Offset(350, 400));
    await tester.pumpAndSettle();
    expect(livro.at, 3, reason: 'a página aceitou o gesto seguinte');
  });

  testWidgets(
    'pressão longa não faz nada (D-113): nem virar, nem link, nem o fechar',
    (tester) async {
      await montar(tester);
      for (final p in const [
        Offset(350, 400),
        Offset(195, 400),
        Offset(230, 110),
      ]) {
        final g = await tester.startGesture(p);
        await tester.pump(const Duration(seconds: 1));
        await g.up();
        await tester.pumpAndSettle();
      }
      expect(eventos, isEmpty);
      expect(livro.viradas, isEmpty);
    },
  );

  testWidgets('seguir um link segura os gestos até ele terminar', (
    tester,
  ) async {
    final chegou = Completer<void>();
    await montar(tester, seguir: (_) => chegou.future);
    await tester.tapAt(const Offset(230, 110));
    await tester.pump();
    await tester.tapAt(const Offset(350, 400));
    await tester.pumpAndSettle();
    expect(livro.viradas, isEmpty, reason: 'o toque durante o link é ignorado');
    chegou.complete();
    await tester.pump();
    await tester.tapAt(const Offset(350, 400));
    await tester.pumpAndSettle();
    expect(livro.viradas, [PageDirection.forward]);
  });

  testWidgets(
    'limite de 300 px/s dos dois lados: 50 px a ~250 px/s volta; a ~350 px/s completa',
    (tester) async {
      await montar(tester);
      await tester.timedDragFrom(
        const Offset(300, 400),
        const Offset(-50, 0),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();
      expect(livro.viradas, isEmpty, reason: '~250 px/s < 300 e 50 px < 1/4');
      await tester.timedDragFrom(
        const Offset(300, 400),
        const Offset(-50, 0),
        const Duration(milliseconds: 140),
      );
      await tester.pumpAndSettle();
      expect(livro.viradas, [PageDirection.forward], reason: '~350 px/s ≥ 300');
    },
  );

  testWidgets(
    'o gesto da página fica fora do leitor de tela (as ações estão no nó r19.page)',
    (tester) async {
      final h = tester.ensureSemantics();
      await montar(tester);
      expect(
        tester.getSemantics(find.byType(ReaderPageView)),
        isNot(isSemantics(hasTapAction: true)),
      );
      h.dispose();
    },
  );

  group('G12 — controles abertos e a marca da busca (D-117, D-120)', () {
    testWidgets(
      'com os controles abertos, o toque nos terços e no centro só fecha (onCenter)',
      (tester) async {
        await montar(tester, controlsOpen: true);
        for (final x in [40.0, 195.0, 350.0]) {
          await tester.tapAt(Offset(x, 600));
          await tester.pumpAndSettle();
        }
        expect(livro.viradas, isEmpty);
        expect(livro.at, 2);
        expect(eventos, [
          'toque',
          'centro',
          'toque',
          'centro',
          'toque',
          'centro',
        ]);
      },
    );

    testWidgets('com os controles abertos, o toque no link não segue: fecha', (
      tester,
    ) async {
      await montar(tester, controlsOpen: true);
      await tester.tapAt(const Offset(230, 110));
      await tester.pumpAndSettle();
      expect(eventos, ['toque', 'centro']);
    });

    testWidgets(
      'com os controles abertos, o arrasto vira como sempre e avisa no começo',
      (tester) async {
        await montar(tester, controlsOpen: true);
        final g = await tester.startGesture(const Offset(300, 400));
        await g.moveBy(const Offset(-40, 0));
        await tester.pump();
        expect(eventos, contains('arrasto'));
        expect(eventos.where((e) => e == 'arrasto'), hasLength(1));
        await g.moveBy(const Offset(-100, 0));
        await tester.pump();
        await g.up();
        await tester.pumpAndSettle();
        expect(livro.viradas, [PageDirection.forward]);
        expect(eventos.where((e) => e == 'centro'), isEmpty);
      },
    );

    testWidgets('fechados, o arrasto também avisa (a tela decide)', (
      tester,
    ) async {
      await montar(tester);
      await tester.dragFrom(const Offset(300, 400), const Offset(-150, 0));
      await tester.pumpAndSettle();
      expect(eventos.where((e) => e == 'arrasto'), hasLength(1));
      expect(livro.viradas, [PageDirection.forward]);
    });

    testWidgets('a cor da marca chega ao pintor', (tester) async {
      const brand = Color(0xFFE85D3A);
      await montar(tester, foundColor: brand);
      final p = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((c) => c.painter)
          .whereType<ReaderPagesPainter>()
          .single;
      expect(p.foundColor, brand);
    });

    test('a marca é pintada antes do texto, um retângulo arredondado (raio 3) por caixa, 1 px maior', () {
      const brand = Color(0xFFE85D3A);
      final l = _Livro()..found = (unit: 2, from: 10, to: 50);
      final tela = _Tela();
      ReaderPagesPainter(
        document: l,
        dx: 0,
        dir: null,
        neighbor: null,
        foundColor: brand,
      ).paint(tela, const Size(390, 844));
      expect(tela.chamadas, ['marca', 'texto']);
      final (rr, cor) = tela.marcas.single;
      expect(rr.outerRect, const Rect.fromLTWH(39, 119, 42, 22));
      expect(rr.tlRadius, const Radius.circular(3));
      expect(rr.brRadius, const Radius.circular(3));
      expect(cor.toARGB32(), brand.toARGB32());
    });

    test('página opaca (a imagem do PDF): a marca vai por cima, multiplicada (senão a imagem a cobriria)', () {
      final l = _Livro()..found = (unit: 2, from: 10, to: 50);
      l.paginas[2] = _Pagina(2, opaque: true);
      final tela = _Tela();
      ReaderPagesPainter(
        document: l,
        dx: 0,
        dir: null,
        neighbor: null,
        foundColor: const Color(0xFFB6ACE4),
      ).paint(tela, const Size(390, 844));
      expect(tela.chamadas, ['texto', 'marca']);
      expect(tela.modos, [BlendMode.multiply]);
      final texto = _Tela();
      ReaderPagesPainter(
        document: _Livro()..found = (unit: 2, from: 10, to: 50),
        dx: 0,
        dir: null,
        neighbor: null,
        foundColor: const Color(0xFFB6ACE4),
      ).paint(texto, const Size(390, 844));
      expect(texto.modos, [
        BlendMode.srcOver,
      ], reason: 'texto do EPUB: por trás das letras');
    });

    test('Noite (D-127): por trás vai D − marca; por cima, D em diferença (D = o maior canal de letra e marca)', () {
      const brand = Color(0xFFB6ACE4);
      const letra = Color(0xFFE3D9C6);
      final l = _Livro()..found = (unit: 2, from: 10, to: 50);
      final tela = _Tela();
      ReaderPagesPainter(
        document: l,
        dx: 0,
        dir: null,
        neighbor: null,
        foundColor: brand,
        foundLightText: letra,
      ).paint(tela, const Size(390, 844));
      expect(tela.chamadas, ['marca', 'texto', 'marca']);
      expect(tela.modos, [BlendMode.srcOver, BlendMode.difference]);
      expect(tela.camadas, isEmpty);
      expect(tela.marcas.map((m) => m.$2.toARGB32()), [0xFF2D2D00, 0xFFE3D9E4]);
      expect(tela.marcas[0].$1, tela.marcas[1].$1, reason: 'a mesma caixa');
      // a imagem do PDF não tem letras claras: continua multiplicada
      l.paginas[2] = _Pagina(2, opaque: true);
      final pdf = _Tela();
      ReaderPagesPainter(
        document: l,
        dx: 0,
        dir: null,
        neighbor: null,
        foundColor: brand,
        foundLightText: letra,
      ).paint(pdf, const Size(390, 844));
      expect(pdf.modos, [BlendMode.multiply]);
    });

    test('Noite (D-127), nos pixels: o fundo da marca é a cor exata, a palavra fica escura, fora nada muda', () async {
      const papel = Color(0xFF1F1B17);
      const letra = Color(0xFFE3D9C6);
      for (final brand in const [Color(0xFFB6ACE4), Color(0xFFE85D3A)]) {
        final l = _Livro()..found = (unit: 2, from: 10, to: 50);
        l.paginas[2] = _Pagina(2, letra: letra);
        final gravador = ui.PictureRecorder();
        final canvas = Canvas(gravador)
          ..drawRect(
            const Rect.fromLTWH(0, 0, 120, 160),
            Paint()..color = papel,
          );
        ReaderPagesPainter(
          document: l,
          dx: 0,
          dir: null,
          neighbor: null,
          foundColor: brand,
          foundLightText: letra,
        ).paint(canvas, const Size(120, 160));
        final img = await gravador.endRecording().toImage(120, 160);
        final bytes = (await img.toByteData())!;
        img.dispose();
        Color px(int x, int y) {
          final i = (y * 120 + x) * 4;
          return Color.fromARGB(
            bytes.getUint8(i + 3),
            bytes.getUint8(i),
            bytes.getUint8(i + 1),
            bytes.getUint8(i + 2),
          );
        }

        void quase(Color a, Color b, String r) {
          for (final (x, y) in [(a.r, b.r), (a.g, b.g), (a.b, b.b)]) {
            expect((x - y).abs() * 255, lessThanOrEqualTo(1), reason: r);
          }
        }

        quase(px(70, 130), brand, 'o fundo da marca');
        quase(px(10, 10), papel, 'fora da marca');
        final palavra = px(48, 130);
        final contraste =
            (brand.computeLuminance() + 0.05) /
            (palavra.computeLuminance() + 0.05);
        expect(contraste, greaterThan(4.5), reason: 'a palavra escura');
        // sem a cor clara (papéis claros): a marca por trás e a letra por cima, como antes
        final claro = ui.PictureRecorder();
        ReaderPagesPainter(
          document: l,
          dx: 0,
          dir: null,
          neighbor: null,
          foundColor: brand,
        ).paint(Canvas(claro), const Size(120, 160));
        final img2 = await claro.endRecording().toImage(120, 160);
        final b2 = (await img2.toByteData())!;
        img2.dispose();
        final i = (130 * 120 + 48) * 4;
        expect(
          [b2.getUint8(i), b2.getUint8(i + 1), b2.getUint8(i + 2)],
          [0xE3, 0xD9, 0xC6],
        );
      }
    });

    test('sem cor, ou a marca noutro capítulo: só o texto', () {
      final l = _Livro()..found = (unit: 2, from: 10, to: 50);
      final semCor = _Tela();
      ReaderPagesPainter(
        document: l,
        dx: 0,
        dir: null,
        neighbor: null,
      ).paint(semCor, const Size(390, 844));
      expect(semCor.chamadas, ['texto']);
      l.found = (unit: 3, from: 10, to: 50);
      final outra = _Tela();
      ReaderPagesPainter(
        document: l,
        dx: 0,
        dir: null,
        neighbor: null,
        foundColor: const Color(0xFFE85D3A),
      ).paint(outra, const Size(390, 844));
      expect(outra.chamadas, ['texto']);
    });

    test('trocar a cor repinta', () {
      final l = _Livro();
      ReaderPagesPainter pintor(Color? c) => ReaderPagesPainter(
        document: l,
        dx: 0,
        dir: null,
        neighbor: null,
        foundColor: c,
      );
      expect(
        pintor(const Color(0xFFE85D3A))
            .shouldRepaint(pintor(const Color(0xFFE85D3A))),
        isFalse,
      );
      expect(
        pintor(null).shouldRepaint(pintor(const Color(0xFFE85D3A))),
        isTrue,
      );
      ReaderPagesPainter noite(Color? luz) => ReaderPagesPainter(
        document: l,
        dx: 0,
        dir: null,
        neighbor: null,
        foundColor: const Color(0xFFE85D3A),
        foundLightText: luz,
      );
      expect(
        noite(const Color(0xFFE3D9C6))
            .shouldRepaint(noite(const Color(0xFFE3D9C6))),
        isFalse,
      );
      expect(noite(null).shouldRepaint(noite(const Color(0xFFE3D9C6))), isTrue);
    });
  });

  group('G13 — gestos da seleção (D-45, D-132, D-136)', () {
    testWidgets(
      'pressão longa: começa, arrasta sem soltar e solta, sem virar',
      (tester) async {
        await montar(tester, pressaoLonga: true);
        final g = await tester.startGesture(const Offset(42, 130));
        await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
        await g.moveBy(const Offset(30, 0));
        await tester.pump();
        await g.moveBy(const Offset(0, 40));
        await tester.pump();
        await g.up();
        await tester.pumpAndSettle();
        expect(eventos, [
          'toque',
          'pressão Offset(42.0, 130.0)',
          'arrastando Offset(72.0, 130.0)',
          'arrastando Offset(72.0, 170.0)',
          'soltou',
        ]);
        expect(livro.viradas, isEmpty);
        expect(livro.at, 2);
      },
    );

    testWidgets(
      'com os controles abertos a pressão longa também chega (quem fecha é a tela); o toque só fecha',
      (tester) async {
        await montar(tester, pressaoLonga: true, controlsOpen: true);
        await tester.longPressAt(const Offset(195, 400));
        await tester.pumpAndSettle();
        expect(eventos, ['toque', 'pressão Offset(195.0, 400.0)', 'soltou']);
        eventos.clear();
        await tester.tapAt(const Offset(350, 400));
        await tester.pumpAndSettle();
        expect(eventos, ['toque', 'centro']);
      },
    );

    testWidgets(
      'com uma seleção na tela, o toque em qualquer lugar vai para ela: não vira nem segue link',
      (tester) async {
        await montar(tester, selecting: true);
        for (final p in const [
          Offset(350, 400),
          Offset(20, 400),
          Offset(195, 400),
          Offset(195, 115),
        ]) {
          await tester.tapAt(p);
          await tester.pumpAndSettle();
        }
        expect(eventos, [
          'toque',
          'toque na seleção Offset(350.0, 400.0)',
          'toque',
          'toque na seleção Offset(20.0, 400.0)',
          'toque',
          'toque na seleção Offset(195.0, 400.0)',
          'toque',
          'toque na seleção Offset(195.0, 115.0)',
        ]);
        expect(livro.viradas, isEmpty);
      },
    );

    testWidgets('precedência sem seleção: link → grifo → terços', (
      tester,
    ) async {
      final tocados = <Offset>[];
      var ehGrifo = true;
      await montar(
        tester,
        grifo: (p) {
          tocados.add(p);
          return ehGrifo;
        },
      );
      // o link vale mesmo com um grifo embaixo
      await tester.tapAt(const Offset(195, 115));
      await tester.pumpAndSettle();
      expect(eventos, ['toque', 'link OEBPS/n.xhtml#2']);
      expect(tocados, isEmpty);
      // fora do link, o grifo: não vira
      eventos.clear();
      await tester.tapAt(const Offset(350, 400));
      await tester.pumpAndSettle();
      expect(eventos, ['toque']);
      expect(tocados, [const Offset(350, 400)]);
      expect(livro.viradas, isEmpty);
      // não era grifo: os terços
      ehGrifo = false;
      await tester.tapAt(const Offset(350, 400));
      await tester.pumpAndSettle();
      expect(livro.viradas, [PageDirection.forward]);
    });

    testWidgets(
      'G18 (R11, D-184): a faixa recolhida vem depois do grifo e antes dos terços',
      (tester) async {
        final notas = <Offset>[];
        var ehFaixa = true;
        await montar(
          tester,
          grifo: (_) => false,
          nota: (p) {
            notas.add(p);
            return ehFaixa;
          },
        );
        await tester.tapAt(const Offset(350, 400));
        await tester.pumpAndSettle();
        expect(notas, [const Offset(350, 400)]);
        expect(livro.viradas, isEmpty);
        ehFaixa = false;
        await tester.tapAt(const Offset(350, 400));
        await tester.pumpAndSettle();
        expect(livro.viradas, [PageDirection.forward]);
        // o link continua primeiro
        await tester.tapAt(const Offset(195, 115));
        await tester.pumpAndSettle();
        expect(notas, hasLength(2));
      },
    );
  });

  group('G13 — grifos e seleção na página (D-133)', () {
    test('fundo do grifo: faixa de 12–92 % da área do texto (corte), raio 3, cor a 85 %, por trás do texto', () {
      final tela = _Tela();
      ReaderPagesPainter(
        document: _Livro(),
        dx: 0,
        dir: null,
        neighbor: null,
        highlights: _Grifos([_grifo('g', 10, 50)]),
      ).paint(tela, const Size(390, 844));
      expect(tela.chamadas, ['corte', 'marca', 'texto']);
      final (rr, cor) = tela.marcas.single;
      expect(rr.outerRect, const Rect.fromLTRB(40, 122.41, 80, 152.85));
      expect(rr.tlRadius, const Radius.circular(3));
      expect(rr.brRadius, const Radius.circular(3));
      const area = 152.85 - 122.41;
      expect(
        tela.cortes.single.top,
        moreOrLessEquals(122.41 + .12 * area, epsilon: 1e-9),
      );
      expect(
        tela.cortes.single.bottom,
        moreOrLessEquals(122.41 + .92 * area, epsilon: 1e-9),
      );
      expect(tela.cortes.single.left, 40);
      expect(tela.cortes.single.right, 80);
      expect(
        cor.toARGB32(),
        const Color(0xFFFED170).withValues(alpha: .85).toARGB32(),
      );
    });

    test('grifo noutro item da página: só o texto', () {
      final tela = _Tela();
      ReaderPagesPainter(
        document: _Livro(),
        dx: 0,
        dir: null,
        neighbor: null,
        highlights: _Grifos([
          const PaintedHighlight(
            id: 'x',
            range: (unit: 3, from: 10, to: 50),
            color: Color(0xFFFED170),
            style: HighlightStyle.fill,
          ),
        ]),
      ).paint(tela, const Size(390, 844));
      expect(tela.chamadas, ['texto']);
    });

    test('seleção: área do texto inteira, raio 2, brand a 62 %, por trás do texto; ganha do grifo onde se cruzam', () {
      final selecao = ValueNotifier<ReaderRange?>((unit: 2, from: 40, to: 60));
      final tela = _Tela();
      ReaderPagesPainter(
        document: _Livro(),
        dx: 0,
        dir: null,
        neighbor: null,
        highlights: _Grifos([_grifo('g', 0, 100)]),
        selection: selecao,
        selectionColor: const Color(0xFFB6ACE4),
      ).paint(tela, const Size(390, 844));
      // o grifo vira 2 pedaços (30–70 e 90–130 na tela) e a seleção fica inteira (70–90)
      expect(
        [for (final (r, _) in tela.marcas) r.outerRect],
        [
          const Rect.fromLTRB(30, 122.41, 70, 152.85),
          const Rect.fromLTRB(90, 122.41, 130, 152.85),
          const Rect.fromLTRB(70, 122.41, 90, 152.85),
        ],
      );
      expect(tela.marcas.last.$1.tlRadius, const Radius.circular(2));
      expect(
        tela.marcas.last.$2.toARGB32(),
        const Color(0xFFB6ACE4).withValues(alpha: .62).toARGB32(),
      );
      expect(tela.chamadas.last, 'texto');
      // sem cor da seleção, nada de seleção
      final semCor = _Tela();
      ReaderPagesPainter(
        document: _Livro(),
        dx: 0,
        dir: null,
        neighbor: null,
        selection: selecao,
      ).paint(semCor, const Size(390, 844));
      expect(semCor.chamadas, ['texto']);
    });

    test('a marca da busca ganha do grifo e perde da seleção', () {
      final l = _Livro()..found = (unit: 2, from: 20, to: 60);
      final tela = _Tela();
      ReaderPagesPainter(
        document: l,
        dx: 0,
        dir: null,
        neighbor: null,
        foundColor: const Color(0xFFE85D3A),
        highlights: _Grifos([_grifo('g', 0, 40)]),
        selection: ValueNotifier<ReaderRange?>((unit: 2, from: 50, to: 70)),
        selectionColor: const Color(0xFFB6ACE4),
      ).paint(tela, const Size(390, 844));
      expect(
        [for (final (r, _) in tela.marcas) r.outerRect],
        [
          const Rect.fromLTRB(
            30,
            122.41,
            49,
            152.85,
          ), // grifo até a marca (inflada 1 px)
          const Rect.fromLTRB(49, 119, 80, 141), // marca até a seleção
          const Rect.fromLTRB(80, 122.41, 100, 152.85), // seleção inteira
        ],
      );
    });

    test('sublinhado: retângulo de 4 px a partir de 3 px abaixo da linha de base, na cor viva, por cima do texto', () {
      final tela = _Tela();
      ReaderPagesPainter(
        document: _Livro(),
        dx: 0,
        dir: null,
        neighbor: null,
        highlights: _Grifos([
          _grifo(
            's',
            10,
            20,
            color: const Color(0xFFFFC1C6),
            style: HighlightStyle.underline,
          ),
        ]),
      ).paint(tela, const Size(390, 844));
      expect(tela.chamadas, ['texto', 'traço']);
      final (r, c) = tela.retangulos.single;
      expect(r, const Rect.fromLTRB(40, 152.6, 50, 156.6));
      expect(c.toARGB32(), 0xFFFFC1C6);
    });

    test('Noite (D-133): grifo na cor viva, por trás D − cor e por cima D em diferença', () {
      final tela = _Tela();
      ReaderPagesPainter(
        document: _Livro(),
        dx: 0,
        dir: null,
        neighbor: null,
        highlights: _Grifos([_grifo('g', 10, 30)]),
        foundLightText: const Color(0xFFE3D9C6),
      ).paint(tela, const Size(390, 844));
      expect(tela.chamadas, ['corte', 'marca', 'texto', 'corte', 'marca']);
      expect(tela.modos, [BlendMode.srcOver, BlendMode.difference]);
      expect(tela.camadas, isEmpty);
      // D = (máx(E3, FE), máx(D9, D1), máx(C6, 70)) = FED9C6; D − cor = 00 08 56
      expect(tela.marcas.map((m) => m.$2.toARGB32()), [0xFF000856, 0xFFFED9C6]);
    });

    test('Noite (D-133), nos pixels: o fundo do grifo é a cor exata, a palavra fica escura, fora da faixa nada muda', () async {
      const papel = Color(0xFF1F1B17);
      const letra = Color(0xFFE3D9C6);
      const amarelo = Color(0xFFFED170);
      final l = _Livro();
      l.paginas[2] = _Pagina(2, letra: letra);
      final gravador = ui.PictureRecorder();
      final canvas = Canvas(gravador)
        ..drawRect(const Rect.fromLTWH(0, 0, 120, 160), Paint()..color = papel);
      ReaderPagesPainter(
        document: l,
        dx: 0,
        dir: null,
        neighbor: null,
        highlights: _Grifos([_grifo('g', 10, 50)]),
        foundLightText: letra,
      ).paint(canvas, const Size(120, 160));
      final img = await gravador.endRecording().toImage(120, 160);
      final bytes = (await img.toByteData())!;
      img.dispose();
      Color px(int x, int y) {
        final i = (y * 120 + x) * 4;
        return Color.fromARGB(
          bytes.getUint8(i + 3),
          bytes.getUint8(i),
          bytes.getUint8(i + 1),
          bytes.getUint8(i + 2),
        );
      }

      void quase(Color a, Color b, String r) {
        for (final (x, y) in [(a.r, b.r), (a.g, b.g), (a.b, b.b)]) {
          expect((x - y).abs() * 255, lessThanOrEqualTo(1), reason: r);
        }
      }

      quase(px(70, 130), amarelo, 'o fundo do grifo');
      quase(px(70, 124), papel, 'acima da faixa (12 %)');
      quase(px(70, 151), papel, 'abaixo da faixa (92 %)');
      quase(px(10, 10), papel, 'fora do grifo');
      final palavra = px(48, 130);
      final contraste =
          (amarelo.computeLuminance() + 0.05) /
          (palavra.computeLuminance() + 0.05);
      expect(contraste, greaterThan(4.5), reason: 'a palavra escura');
    });

    test('a vizinha que chega no arrasto vem com os grifos dela; a seleção e a marca da busca são só da atual', () {
      final l = _Livro()..found = (unit: 3, from: 0, to: 8);
      final tela = _Tela();
      ReaderPagesPainter(
        document: l,
        dx: -100,
        dir: PageDirection.forward,
        neighbor: l.paginas[3],
        foundColor: const Color(0xFFE85D3A),
        highlights: _Grifos([
          _grifo('g', 0, 10),
          const PaintedHighlight(
            id: 'v',
            range: (unit: 3, from: 10, to: 50),
            color: Color(0xFFABCF82),
            style: HighlightStyle.fill,
          ),
          const PaintedHighlight(
            id: 's',
            range: (unit: 3, from: 60, to: 70),
            color: Color(0xFFFFC1C6),
            style: HighlightStyle.underline,
          ),
        ]),
        selection: ValueNotifier<ReaderRange?>((unit: 3, from: 0, to: 5)),
        selectionColor: const Color(0xFFB6ACE4),
      ).paint(tela, const Size(390, 844));
      expect(tela.chamadas, [
        'corte', 'marca', 'texto', // a atual: o grifo dela
        'corte',
        'marca',
        'texto',
        'traço', // a vizinha: o fundo e o sublinhado dela
      ]);
      expect(
        [for (final (r, c) in tela.marcas) (r.outerRect, c.toARGB32())],
        [
          (
            const Rect.fromLTRB(30, 122.41, 40, 152.85),
            const Color(0xFFFED170).withValues(alpha: .85).toARGB32(),
          ),
          (
            const Rect.fromLTRB(40, 122.41, 80, 152.85),
            const Color(0xFFABCF82).withValues(alpha: .85).toARGB32(),
          ),
        ],
      );
      expect(l.paginas[3].pintadaEm, hasLength(1));
      // a vizinha opaca (a imagem do PDF): só ela
      final pdf = _Livro();
      pdf.paginas[3] = _Pagina(3, opaque: true);
      final t2 = _Tela();
      ReaderPagesPainter(
        document: pdf,
        dx: -100,
        dir: PageDirection.forward,
        neighbor: pdf.paginas[3],
        highlights: _Grifos([
          const PaintedHighlight(
            id: 'v',
            range: (unit: 3, from: 10, to: 50),
            color: Color(0xFFABCF82),
            style: HighlightStyle.fill,
          ),
        ]),
      ).paint(t2, const Size(390, 844));
      expect(t2.chamadas, ['texto', 'texto']);
    });

    test('Noite (D-133), nos pixels: o fundo da seleção é a brand exata e a palavra fica escura', () async {
      const papel = Color(0xFF1F1B17);
      const letra = Color(0xFFE3D9C6);
      const brand = Color(0xFFB6ACE4);
      final l = _Livro();
      l.paginas[2] = _Pagina(2, letra: letra);
      final gravador = ui.PictureRecorder();
      final canvas = Canvas(gravador)
        ..drawRect(const Rect.fromLTWH(0, 0, 120, 160), Paint()..color = papel);
      ReaderPagesPainter(
        document: l,
        dx: 0,
        dir: null,
        neighbor: null,
        selection: ValueNotifier<ReaderRange?>((unit: 2, from: 10, to: 50)),
        selectionColor: brand,
        foundLightText: letra,
      ).paint(canvas, const Size(120, 160));
      final img = await gravador.endRecording().toImage(120, 160);
      final bytes = (await img.toByteData())!;
      img.dispose();
      Color px(int x, int y) {
        final i = (y * 120 + x) * 4;
        return Color.fromARGB(
          bytes.getUint8(i + 3),
          bytes.getUint8(i),
          bytes.getUint8(i + 1),
          bytes.getUint8(i + 2),
        );
      }

      void quase(Color a, Color b, String r) {
        for (final (x, y) in [(a.r, b.r), (a.g, b.g), (a.b, b.b)]) {
          expect((x - y).abs() * 255, lessThanOrEqualTo(1), reason: r);
        }
      }

      quase(px(70, 124), brand, 'a área do texto inteira');
      quase(px(70, 150), brand, 'até o fim da área');
      quase(px(70, 121), papel, 'acima da área');
      quase(px(10, 130), papel, 'fora da seleção');
      final palavra = px(48, 130);
      final contraste =
          (brand.computeLuminance() + 0.05) /
          (palavra.computeLuminance() + 0.05);
      expect(contraste, greaterThan(4.5), reason: 'a palavra escura');
    });

    test('grifos e seleção que mudam por dentro repintam; trocar fonte ou cor repinta', () {
      final l = _Livro();
      final grifos = _Grifos([]);
      final selecao = ValueNotifier<ReaderRange?>(null);
      ReaderPagesPainter pintor({
        HighlightSource? h,
        ValueListenable<ReaderRange?>? s,
        Color? c,
      }) => ReaderPagesPainter(
        document: l,
        dx: 0,
        dir: null,
        neighbor: null,
        highlights: h ?? grifos,
        selection: s ?? selecao,
        selectionColor: c ?? const Color(0xFFB6ACE4),
      );
      var avisos = 0;
      pintor().addListener(() => avisos++);
      grifos.avisar();
      selecao.value = (unit: 2, from: 1, to: 3);
      expect(avisos, 2);
      expect(pintor().shouldRepaint(pintor()), isFalse);
      expect(pintor(h: _Grifos([])).shouldRepaint(pintor()), isTrue);
      expect(
        pintor(s: ValueNotifier<ReaderRange?>(null)).shouldRepaint(pintor()),
        isTrue,
      );
      expect(
        pintor(c: const Color(0xFFE85D3A)).shouldRepaint(pintor()),
        isTrue,
      );
    });
  });

  group('G16 — a tinta salva e a mancha do grifo feito à mão (D-59, D-161)', () {
    late InkPictureCache cache;
    setUp(() => cache = InkPictureCache());
    tearDown(() => cache.dispose());

    PaintedHighlight aMao(int from, int to) => PaintedHighlight(
      id: 'a-mao',
      range: (unit: 2, from: from, to: to),
      color: const Color(0xFFFED170),
      style: HighlightStyle.fill,
    );

    test('G18 (R11, D-183): as notas da página antes do texto — o fundo da caixa, as pautas e a etiqueta', () {
      final livro = _Livro();
      livro.paginas[2].spaces = [
        (id: 'n', rect: const Rect.fromLTWH(28, 300, 334, 206)),
        (id: 'abridor', rect: const Rect.fromLTWH(28, 600, 334, 40)),
      ];
      final tela = _Tela();
      ReaderPagesPainter(
        document: livro,
        dx: 0,
        dir: null,
        neighbor: null,
        ink: _Tinta(
          notas: [
            (
              id: 'n',
              annotationId: 'n-a',
              unit: 2,
              at: 40,
              lines: 3,
              collapsed: false,
              strokes: const [],
              createdAt: DateTime(2026, 9, 20),
              groupId: 'n-a',
            ),
          ],
        ),
        inkPictures: cache,
      ).paint(tela, const Size(390, 844));
      final fundos = [
        for (final (r, c) in tela.marcas)
          if (c.toARGB32() == const Color(0xFFFFFDF8).toARGB32()) r.outerRect,
      ];
      expect(fundos, [const Rect.fromLTWH(28, 330, 334, 150)]);
      expect(
        tela.marcas.where((m) => m.$2.toARGB32() == 0xFFFED170),
        hasLength(1),
        reason: 'a etiqueta',
      );
      expect(
        tela.chamadas.indexOf('marca'),
        lessThan(tela.chamadas.indexOf('texto')),
      );
    });

    test(
      'ordem: fundos → texto → sublinhado → mancha (multiplicada) → tinta',
      () {
        final tela = _Tela();
        ReaderPagesPainter(
          document: _Livro(),
          dx: 0,
          dir: null,
          neighbor: null,
          highlights: _Grifos([
            _grifo('g', 0, 10),
            _grifo('s', 60, 70, style: HighlightStyle.underline),
          ]),
          ink: _Tinta(aMao: [aMao(20, 40)]),
          inkPictures: cache,
        ).paint(tela, const Size(390, 844));
        expect(tela.chamadas, [
          'corte',
          'marca',
          'texto',
          'traço',
          'mancha',
          'tinta',
        ]);
        expect(tela.manchas, [BlendMode.multiply]);
      },
    );

    test('G17 (R25): o sublinhado e o ondulado à mão pintam como os da tela 21, por cima do texto, sem mancha', () {
      final tela = _Tela();
      ReaderPagesPainter(
        document: _Livro(),
        dx: 0,
        dir: null,
        neighbor: null,
        ink: _Tinta(
          aMao: const [
            PaintedHighlight(
              id: 'sub',
              range: (unit: 2, from: 20, to: 40),
              color: Color(0xFFFFC1C6),
              style: HighlightStyle.underline,
            ),
            PaintedHighlight(
              id: 'onda',
              range: (unit: 2, from: 50, to: 60),
              color: Color(0xFFB6ACE4),
              style: HighlightStyle.wavy,
            ),
          ],
        ),
        inkPictures: cache,
      ).paint(tela, const Size(390, 844));
      // o ondulado é um caminho (a "mancha" do registro), na cor viva e sem multiplicar
      expect(tela.chamadas, ['texto', 'traço', 'mancha', 'tinta']);
      expect(tela.manchas, [BlendMode.srcOver]);
      expect(tela.retangulos.single.$2.toARGB32(), 0xFFFFC1C6);
    });

    test('Noite (D-133): a mancha por trás (D − cor) e por cima (D em diferença); a tinta por último, na cor dela', () {
      final tela = _Tela();
      ReaderPagesPainter(
        document: _Livro(),
        dx: 0,
        dir: null,
        neighbor: null,
        foundLightText: const Color(0xFFE3D9C6),
        ink: _Tinta(aMao: [aMao(20, 40)]),
        inkPictures: cache,
      ).paint(tela, const Size(390, 844));
      expect(tela.chamadas, ['mancha', 'texto', 'mancha', 'tinta']);
      expect(tela.manchas, [BlendMode.srcOver, BlendMode.difference]);
      expect(tela.camadas, isEmpty);
    });

    test('G17 (R26): no Noite, o marca-texto também vai por trás do texto (D-133); sem ele, ou no Creme, só por cima', () {
      ReaderPagesPainter pintor({Color? letras, bool marcador = true}) =>
          ReaderPagesPainter(
            document: _Livro(),
            dx: 0,
            dir: null,
            neighbor: null,
            foundLightText: letras,
            ink: _Tinta(marcador: marcador),
            inkPictures: cache,
          );
      final noite = _Tela();
      pintor(letras: const Color(0xFFE3D9C6))
          .paint(noite, const Size(390, 844));
      // por trás, o marca-texto (D − cor); por cima, ele (D em diferença) e, por último, a caneta
      expect(noite.chamadas, ['tinta', 'texto', 'tinta', 'tinta']);
      expect(noite.tintas.toSet(), hasLength(3));
      expect(noite.camadas, isEmpty);
      final semMarcador = _Tela();
      pintor(
        letras: const Color(0xFFE3D9C6),
        marcador: false,
      ).paint(semMarcador, const Size(390, 844));
      expect(semMarcador.chamadas, ['texto', 'tinta']);
      final creme = _Tela();
      pintor().paint(creme, const Size(390, 844));
      expect(creme.chamadas, ['texto', 'tinta']);
    });

    group('achado 17 (Noite): os fundos que se cruzam valem uma vez (o de cima), com a conta da D-133 feita uma vez', () {
      const papel = Color(0xFF1F1B17);
      const letra = Color(0xFFE3D9C6);
      const amarelo = Color(0xFFFED170);
      const rosa = Color(0xFFFFC1C6);
      const coral = Color(0xFFFF552E);

      /// A página no Noite pintada numa imagem de 120×240; devolve a cor de cada pixel.
      Future<Color Function(int, int)> noite({
        List<PaintedHighlight> grifos = const [],
        List<PaintedHighlight> aMao = const [],
        List<InkStroke> tinta = const [],
      }) async {
        final l = _Livro();
        l.paginas[2] = _Pagina(2, letra: letra);
        final gravador = ui.PictureRecorder();
        final canvas = Canvas(gravador)
          ..drawRect(
            const Rect.fromLTWH(0, 0, 120, 240),
            Paint()..color = papel,
          );
        ReaderPagesPainter(
          document: l,
          dx: 0,
          dir: null,
          neighbor: null,
          highlights: _Grifos(grifos),
          foundLightText: letra,
          ink: _Tinta(aMao: aMao, extra: tinta),
          inkPictures: cache,
        ).paint(canvas, const Size(120, 240));
        final img = await gravador.endRecording().toImage(120, 240);
        final bytes = (await img.toByteData())!;
        img.dispose();
        return (x, y) {
          final i = (y * 120 + x) * 4;
          return Color.fromARGB(
            bytes.getUint8(i + 3),
            bytes.getUint8(i),
            bytes.getUint8(i + 1),
            bytes.getUint8(i + 2),
          );
        };
      }

      void quase(Color a, Color b, String r) {
        for (final (x, y) in [(a.r, b.r), (a.g, b.g), (a.b, b.b)]) {
          expect((x - y).abs() * 255, lessThanOrEqualTo(1), reason: r);
        }
      }

      PaintedHighlight mao(
        String id,
        int from,
        int to,
        Color cor, {
        FillHeight altura = FillHeight.medium,
      }) => PaintedHighlight(
        id: id,
        range: (unit: 2, from: from, to: to),
        color: cor,
        style: HighlightStyle.fill,
        height: altura,
      );

      InkStroke marca(List<(double, double)> pts, {int argb = 0xE6FED170}) =>
          InkStroke(
            tool: 3,
            tip: 0,
            argb: argb,
            widthCentiMm: 870,
            points: [for (final (x, y) in pts) InkPoint(x, y, 0.5, 0)],
          );

      test('a mancha à mão sobre o fundo de seleção: a mancha onde se cruzam; o fundo fora dela', () async {
        final px = await noite(
          grifos: [_grifo('g', 0, 60)],
          aMao: [mao('rosa', 20, 40, rosa)],
        );
        quase(px(62, 134), rosa, 'onde os dois se cruzam: a mancha');
        quase(px(35, 134), amarelo, 'o grifo de seleção fora da mancha');
        quase(px(85, 134), amarelo, 'depois da mancha');
      });

      test(
        'a mancha Baixa sobre o fundo de seleção: acima dela o fundo continua',
        () async {
          final px = await noite(
            grifos: [_grifo('g', 0, 60)],
            aMao: [mao('rosa', 20, 40, rosa, altura: FillHeight.low)],
          );
          quase(px(62, 130), amarelo, 'acima da mancha Baixa');
          quase(px(62, 146), rosa, 'na mancha Baixa');
        },
      );

      test(
        'duas manchas à mão que se cruzam: a de cima, sem a conta dobrada',
        () async {
          final px = await noite(
            aMao: [mao('amarelo', 10, 50, amarelo), mao('rosa', 30, 40, rosa)],
          );
          // (a linha da caneta do livro de mentira passa em y = 140)
          quase(px(65, 145), rosa, 'onde as duas se cruzam');
          quase(px(40, 145), amarelo, 'só a de baixo');
        },
      );

      test(
        'dois traços do marca-texto que se cruzam: a cor dele, uma vez',
        () async {
          final px = await noite(
            tinta: [
              marca([(30, 200), (90, 200)]),
              marca([(60, 180), (60, 225)]),
            ],
          );
          quase(px(60, 200), amarelo, 'no cruzamento');
          quase(px(40, 200), amarelo, 'num traço só');
        },
      );

      test('o marca-texto que cruza uma mancha ou um fundo fica por baixo dele, sem a conta dobrada', () async {
        final px = await noite(
          grifos: [_grifo('g', 0, 20)],
          aMao: [mao('rosa', 30, 40, rosa)],
          tinta: [
            marca([(65, 100), (65, 200)]),
            marca([(40, 100), (40, 200)], argb: 0xE6FFC1C6),
          ],
        );
        quase(px(65, 145), rosa, 'a mancha sobre o marca-texto');
        quase(px(65, 185), amarelo, 'o marca-texto fora da mancha');
        quase(px(40, 130), amarelo, 'o fundo amarelo sobre o marca-texto rosa');
        quase(px(40, 185), rosa, 'o marca-texto rosa fora do fundo');
      });

      test('a caneta fica por cima do marca-texto feito depois', () async {
        final px = await noite(
          tinta: [
            const InkStroke(
              tool: 1,
              tip: 0,
              argb: 0xFFFF552E,
              widthCentiMm: 120,
              points: [InkPoint(30, 200, 0.5, 0), InkPoint(90, 200, 0.5, 8)],
            ),
            marca([(60, 180), (60, 225)]),
          ],
        );
        quase(px(60, 200), coral, 'a caneta no cruzamento');
        quase(px(60, 215), amarelo, 'o marca-texto fora da caneta');
      });
    });

    test('a vizinha que chega no arrasto vem com a tinta dela; a imagem do PDF não pede tinta', () {
      final l = _Livro();
      final tinta = _Tinta();
      final tela = _Tela();
      ReaderPagesPainter(
        document: l,
        dx: -100,
        dir: PageDirection.forward,
        neighbor: l.paginas[3],
        ink: tinta,
        inkPictures: cache,
      ).paint(tela, const Size(390, 844));
      expect(tela.chamadas, ['texto', 'tinta', 'texto', 'tinta']);
      expect(tinta.pedidas, [2, 3]);
      expect(tela.tintas.first, isNot(same(tela.tintas.last)));
      // a imagem do PDF (sem texto) não tem tinta nesta fase (D-164)
      final pdf = _Livro();
      pdf.paginas[2] = _Pagina(2, opaque: true);
      final t2 = _Tela();
      final semTinta = _Tinta();
      ReaderPagesPainter(
        document: pdf,
        dx: 0,
        dir: null,
        neighbor: null,
        ink: semTinta,
        inkPictures: cache,
      ).paint(t2, const Size(390, 844));
      expect(t2.chamadas, ['texto']);
      expect(semTinta.pedidas, isEmpty);
    });

    test('a mesma revisão reusa a Picture da página; a tinta que muda repinta e grava outra', () {
      final l = _Livro();
      final tinta = _Tinta();
      ReaderPagesPainter pintor({InkSource? ink}) => ReaderPagesPainter(
        document: l,
        dx: 0,
        dir: null,
        neighbor: null,
        ink: ink ?? tinta,
        inkPictures: cache,
      );
      final tela = _Tela();
      pintor().paint(tela, const Size(390, 844));
      pintor().paint(tela, const Size(390, 844));
      expect(tela.tintas[1], same(tela.tintas[0]));
      expect(tinta.pedidas, [2]);
      var avisos = 0;
      pintor().addListener(() => avisos++);
      tinta.mudar();
      expect(avisos, 1);
      pintor().paint(tela, const Size(390, 844));
      expect(tela.tintas[2], isNot(same(tela.tintas[0])));
      expect(tinta.pedidas, [2, 2]);
      expect(pintor().shouldRepaint(pintor()), isFalse);
      expect(pintor(ink: _Tinta()).shouldRepaint(pintor()), isTrue);
    });

    testWidgets('a página leva a tinta ao pintor, com o cache dela', (
      tester,
    ) async {
      final tinta = _Tinta();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ReaderPageView(
            document: _Livro(),
            onTurn: (_) async => false,
            onCenter: () {},
            onLink: (_) async {},
            onInteraction: () {},
            ink: tinta,
          ),
        ),
      );
      final pintor =
          tester
                  .widget<CustomPaint>(
                    find.byKey(const ValueKey('leitor.paginas')),
                  )
                  .painter!
              as ReaderPagesPainter;
      expect(pintor.ink, same(tinta));
      expect(pintor.inkPictures, isNotNull);
      expect(tinta.pedidas, [2]);
    });
  });
}
