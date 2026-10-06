// G11.3 — virar página (D-22, D-107, D-113) com um livro de mentira de 5 páginas: toque nos terços (esquerdo
// volta, direito avança, centro chama o fechar), o toque num link vale antes dos terços, o arrasto completa
// com 1/4 da largura ou ≥ 300 px/s e volta abaixo disso, a animação leva 220 ms `easeOutCubic`, no começo e no
// fim do livro a página anda 1/3 do dedo e volta (batente), e a vizinha atrasada aparece quando chega. Revisão:
// a vizinha que não abre não é batente, a virada que falha não trava a página, pressão longa não faz nada
// (D-113), seguir um link segura os gestos, e o limite de 300 px/s vale dos dois lados.
import 'dart:async';
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Página n: anota onde foi pintada (x da translação do canvas) e tem um link no canto de cima.
final class _Pagina implements DisplayPage {
  _Pagina(this.n);

  final int n;
  final pintadaEm = <double>[];

  static const Rect link = Rect.fromLTWH(150, 100, 90, 30);

  @override
  void paint(ui.Canvas canvas) => pintadaEm.add(canvas.getTransform()[12]);

  @override
  String get spokenText => 'página $n';

  @override
  LinkHit? linkAt(ui.Offset p) => link.contains(p)
      ? (target: 'OEBPS/n.xhtml#$n', spine: 0, offset: n)
      : null;

  @override
  bool get alive => true;
}

final class _Livro implements ReaderDocument {
  _Livro({this.at = 2});

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
  Future<void> flush() async {}

  @override
  Future<void> pin(ReaderMark? mark) async => alfinete = mark;

  @override
  void dispose() {}
}

void main() {
  late _Livro livro;
  late List<String> eventos;

  Future<void> montar(
    WidgetTester tester, {
    int at = 2,
    Future<bool> Function(PageDirection d)? virar,
    Future<void> Function(LinkHit h)? seguir,
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
}
