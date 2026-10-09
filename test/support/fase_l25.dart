// G19.9 — as fases L25a–L25d (a tela 25 pela rota real, no mundo de referência — D-34): abrir a tela com o Dom
// Casmurro do mundo no banco (as 12 anotações e as 4 camadas, a posição na pág. 159), os trechos literais dos cartões
// e o clube da fixture; e as medidas contra o `kRef25`:
// - geometria: o retângulo de LAYOUT de cada id (o post-it e a fita giram: mede-se a caixa sem o giro, como o
//   arquivo); `hl.list` é a união dos separadores e cartões (um sliver não tem caixa);
// - desvio (R10): as miniaturas de tinta dos desenhos saem dos traços salvos, não do `<svg>` estilizado do arquivo —
//   a tinta pintada fica dentro da caixa do arquivo com folga de 3 e cobre ao menos 90 % da largura dela;
// - texto: as quebras, as baselines e o começo e o fim de cada linha (no post-it, na caixa sem o giro).
import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/app/routes.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/features/highlights/application/highlights_controller.dart';
import 'package:app_leitura/features/highlights/application/highlights_providers.dart';
import 'package:app_leitura/features/highlights/presentation/highlight_card.dart';
import 'package:app_leitura/features/highlights/presentation/ink_thumbnail.dart';
import 'package:app_leitura/features/highlights/presentation/marked_quote.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/presentation/ink_painter.dart'
    show inkPath;
import 'package:app_leitura/features/scanner/presentation/scanner_camera.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/overrides_do_mundo.dart';
import '../reference/leitor/ref_tipos.dart';
import 'canvas.dart';
import 'dados_t25.dart';
import 'fake_scanner_camera.dart';
import 'precache_svgs.dart';
import 'pump_reader.dart' show routerOf;
import 'reader_harness.dart';

Finder hl(String id) => find.byKey(ValueKey<String>(id));

/// A tela da prancha: 390 × 2170.
const Size tela25 = Size(390, 2170);

/// O resultado do `push` da tela 25 (o que ela devolve ao sair — R13).
Future<Object?>? saidaDaTela25;

/// Monta o app com a tela 25 do [livro] (rota real) e espera a lista (ou o vazio) aparecer.
Future<void> abrirTela25(
  WidgetTester tester,
  LivroNaEstante livro, {
  bool golden = false,
  bool deLeitor = false,
  HighlightsDeps? deps,
  Size tela = tela25,
  double safeTop = 0,
  List<Override> overrides = const [],
}) async {
  setCanvasView(tester, logical: tela, safeTop: safeTop);
  await precacheAppIcons(tester);
  await precacheSvgs(tester, AppIconsLeitor.all);
  final d = deps ?? depsDaTela25(livro);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        relogioDoMundo,
        repositorioDoMundo,
        brandDoMundo,
        leitorDoMundo,
        scannerCameraProvider.overrideWithValue(FakeScannerCamera.new),
        highlightsDepsProvider.overrideWith((ref) async => d),
        ...overrides,
      ],
      child: golden
          ? const RepaintBoundary(key: goldenRootKey, child: App.forTests())
          : const App.forTests(),
    ),
  );
  await tester.pumpAndSettle();
  saidaDaTela25 = routerOf(
    tester,
  ).push<Object?>(AppRoutes.destaques(livro.userBookId, fromReader: deLeitor));
  await esperarTela25(tester);
}

/// Anda os quadros (com o banco de verdade) até o fim da lista aparecer e a entrada da rota terminar.
/// [assentar] = `false` com o leitor por baixo (o relógio dos controles não deixa assentar): anda 30 quadros.
Future<void> esperarTela25(
  WidgetTester tester, {
  int voltas = 80,
  bool assentar = true,
}) async {
  for (var i = 0; i < voltas; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(const Duration(milliseconds: 16));
    // a lista (ou o fim, no livro vazio) apareceu — numa tela baixa o fim fica fora do que se monta
    if (hl('hl.end').evaluate().isNotEmpty ||
        hl('hl.list.sep1').evaluate().isNotEmpty) {
      if (assentar) {
        await tester.pumpAndSettle();
      } else {
        for (var q = 0; q < 30; q++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
      }
      return;
    }
  }
  fail('a tela 25 não abriu em $voltas voltas');
}

/// Espera o banco depois de uma ação (filtro, apagar, desfazer).
Future<void> banco25(WidgetTester tester, {int voltas = 8}) async {
  for (var i = 0; i < voltas; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Os ids dos desenhos, medidos pela tinta (R10 — desvio).
const Set<String> tintaDosDesenhos = {
  'hl.list.card7.body.quote.ink.ellipse',
  'hl.list.card8.body.quote.ink1.wave',
  'hl.list.card8.body.quote.ink2.line1',
  'hl.list.card8.body.quote.ink2.line2',
};

/// O id do giro de [id] (o post-it e a fita), ou `null`.
String? _giroDe(String id) {
  final m = RegExp(r'^(hl\.list\.card\d+\.body\.note)(\..*)?$').firstMatch(id);
  if (m == null) return null;
  return id == m.group(1) ? null : m.group(1);
}

/// O retângulo de layout de [id] dentro do giro [giro] (a caixa sem o giro).
Rect _semGiro(WidgetTester tester, String id, String giro) {
  final t = tester.renderObject<RenderProxyBox>(hl(giro));
  final base = tester.getRect(hl(giro));
  final box = tester.renderObject<RenderBox>(hl(id));
  final at = box.localToGlobal(Offset.zero, ancestor: t.child);
  return (base.topLeft + at) & box.size;
}

RenderMarkedQuote _citacao(WidgetTester tester, String card) =>
    tester.renderObject<RenderMarkedQuote>(
      find.descendant(of: hl(card), matching: find.byType(MarkedQuote)),
    );

/// A tinta pintada do desenho [mark] (na ordem dos desenhos do cartão), por traço.
List<Rect> tintaDoDesenho(WidgetTester tester, String card, int mark) {
  final q = _citacao(tester, card);
  final view = tester.widget<HighlightCardView>(
    find.byWidgetPredicate((w) => w is HighlightCardView && w.id == card),
  );
  final desenhos = [
    for (final a in view.card.items)
      if (a.kind == AnnotationKind.drawing) a,
  ];
  final layer = view.layers[desenhos[mark].inkLayerId]!;
  final caixas = q.boxes()[mark];
  final origem = q.localToGlobal(Offset.zero);
  final tracos = drawingInCard(layer, [
    for (final b in caixas)
      (left: b.left, right: b.right, baseline: b.baseline, em: quoteEm),
  ])!;
  return [for (final s in tracos) inkPath(s).getBounds().shift(origem)];
}

Rect _uniao(Iterable<Rect> rs) => rs.reduce((a, b) => a.expandToInclude(b));

/// O retângulo medido na tela para o id da prancha.
Rect medido25(WidgetTester tester, String id) {
  if (id == 'hl.list') {
    final rs = <Rect>[];
    for (final e
        in find
            .byWidgetPredicate(
              (w) =>
                  w.key is ValueKey<String> &&
                  RegExp(r'^hl\.list\.(sep|card)\d+$')
                      .hasMatch((w.key! as ValueKey<String>).value),
            )
            .evaluate()) {
      rs.add(tester.getRect(find.byWidget(e.widget)));
    }
    return _uniao(rs);
  }
  if (id == 'hl.list.card6.body.quote.ink.stroke') {
    final q = _citacao(tester, 'hl.list.card6');
    final b = q.boxes().single.single;
    return freehandRect(
      b,
      quoteContentHeight(),
    ).shift(q.localToGlobal(Offset.zero));
  }
  switch (id) {
    case 'hl.list.card7.body.quote.ink.ellipse':
      return _uniao(tintaDoDesenho(tester, 'hl.list.card7', 0));
    case 'hl.list.card8.body.quote.ink1.wave':
      return _uniao(tintaDoDesenho(tester, 'hl.list.card8', 0));
    case 'hl.list.card8.body.quote.ink2.line1':
    case 'hl.list.card8.body.quote.ink2.line2':
      final linhas = tintaDoDesenho(tester, 'hl.list.card8', 1)
        ..sort((a, b) => a.top.compareTo(b.top));
      return id.endsWith('line1') ? linhas.first : linhas.last;
  }
  final giro = _giroDe(id);
  if (giro != null) return _semGiro(tester, id, giro);
  return tester.getRect(hl(id));
}

/// Confere a geometria dos ids das [secoes]; devolve as falhas.
List<String> geometria25(
  WidgetTester tester,
  LeitorRefPrancha ref,
  List<String> secoes,
) {
  final falhas = <String>[];
  for (final s in secoes) {
    for (final id in ref.idsOfSection(s)) {
      final e = ref.elements[id]!;
      if (e.kind == LeitorRefKind.inline) continue;
      final r = e.rect;
      if (id != 'hl.list' &&
          !tintaDosDesenhos.contains(id) &&
          id != 'hl.list.card6.body.quote.ink.stroke' &&
          hl(id).evaluate().isEmpty) {
        falhas.add('$id: não está na tela');
        continue;
      }
      final m = medido25(tester, id);
      if (tintaDosDesenhos.contains(id)) {
        final folga = r.inflate(3);
        if (!(folga.contains(m.topLeft) && folga.contains(m.bottomRight)) ||
            m.width < 0.9 * r.width) {
          falhas.add('$id (tinta): $m fora de $r (±3) ou estreita');
        }
        continue;
      }
      final tolX = ref.textDependentX.contains(id) ? 1.0 : 0.5;
      void confere(String o, double g, double x, double tol) {
        if ((g - x).abs() > tol + 1e-6) {
          falhas.add(
            '$id.$o: ${g.toStringAsFixed(2)} ≠ ${x.toStringAsFixed(2)}',
          );
        }
      }

      confere('x', m.left, r.left, tolX);
      confere('y', m.top, r.top, 0.5);
      confere('w', m.width, r.width, tolX);
      confere('h', m.height, r.height, 0.5);
    }
  }
  return falhas;
}

Element _elemento25(WidgetTester tester, String id, String primeira) {
  for (final e
      in find
          .descendant(
            of: hl(id),
            matching: find.byType(AppText),
            matchRoot: true,
          )
          .evaluate()) {
    final w = e.widget as AppText;
    if (w.span.toPlainText().startsWith(primeira)) return e;
  }
  throw StateError('sem AppText "$primeira" em $id');
}

/// O AppText (render) de [id] cujo texto começa por [primeira].
RenderAppText texto25(WidgetTester tester, String id, String primeira) =>
    _elemento25(tester, id, primeira).renderObject! as RenderAppText;

/// O AppText (widget) de [id] cujo texto começa por [primeira].
AppText appText25(WidgetTester tester, String id, String primeira) =>
    _elemento25(tester, id, primeira).widget as AppText;

/// As linhas de [id] (em coordenadas da prancha: no post-it, sem o giro).
List<AppTextLine> linhas25(WidgetTester tester, String id, String primeira) {
  final r = texto25(tester, id, primeira);
  final got = r.debugLines();
  final giro = _giroDe(id);
  if (giro == null) return got;
  final origem = r.localToGlobal(Offset.zero);
  final caixa = _semGiro(tester, id, giro);
  return [
    for (final l in got)
      (
        text: l.text,
        left: caixa.left + (l.left - origem.dx),
        right: caixa.left + (l.right - origem.dx),
        baseline: caixa.top + (l.baseline - origem.dy),
      ),
  ];
}

/// Confere as linhas de texto dos ids das [secoes] (as `hidden` existem e ficam fora do recorte); devolve as falhas.
List<String> texto25Secoes(
  WidgetTester tester,
  LeitorRefPrancha ref,
  List<String> secoes,
) {
  final falhas = <String>[];
  for (final s in secoes) {
    for (final id in ref.idsOfSection(s)) {
      final e = ref.elements[id]!;
      if (e.kind == LeitorRefKind.inline) continue;
      final esperadas = e.linesAll.isNotEmpty ? e.linesAll : e.lines;
      if (esperadas.isEmpty) continue;
      final List<AppTextLine> got;
      try {
        got = linhas25(tester, id, esperadas.first.text);
      } on StateError catch (e) {
        falhas.add('$id: ${e.message}');
        continue;
      }
      if (got.map((l) => l.text).join('|') !=
          esperadas.map((l) => l.text).join('|')) {
        falhas.add(
          '$id: ${got.map((l) => l.text).toList()} ≠ ${esperadas.map((l) => l.text).toList()}',
        );
        continue;
      }
      for (var i = 0; i < got.length; i++) {
        final x = esperadas[i];
        if ((got[i].baseline - x.baseline).abs() > 0.5 ||
            (got[i].left - x.left).abs() > 1 ||
            (got[i].right - x.right).abs() > 1) {
          falhas.add(
            '$id[$i] "${x.text}": baseline ${got[i].baseline.toStringAsFixed(2)}/${x.baseline}, '
            '${got[i].left.toStringAsFixed(2)}–${got[i].right.toStringAsFixed(2)} ≠ ${x.left}–${x.right}',
          );
        }
      }
    }
  }
  return falhas;
}

/// O 1º nó de semântica que passa em [f], ou `null`.
SemanticsNode? no25(WidgetTester tester, bool Function(SemanticsData d) f) =>
    find.semantics
        .byPredicate((n) => f(n.getSemanticsData()))
        .evaluate()
        .firstOrNull;

/// Os cartões na tela, na ordem (o `HighlightCardView` de cada um).
List<HighlightCardView> cartoes25(WidgetTester tester) => tester
    .widgetList<HighlightCardView>(find.byType(HighlightCardView))
    .toList();

/// O cache das miniaturas da tela.
InkThumbnailCache cache25(WidgetTester tester) => cartoes25(tester).first.cache;

/// O endereço da rota de cima agora.
String routerOf25(WidgetTester tester) => routerOf(tester).state.uri.toString();
