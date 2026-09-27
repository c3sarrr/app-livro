import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout.dart';
import '../support/canvas.dart';
import '../support/geometry.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

Rect _rect(WidgetTester tester, String id) =>
    tester.getRect(find.byKey(ValueKey<String>(id)));

/// Retângulo relativo ao canto superior esquerdo da seção (as tabelas da F07 usam essa origem).
Rect _rel(WidgetTester tester, String id) =>
    _rect(tester, id).shift(-_rect(tester, 'today').topLeft);

/// Alturas e posições que somam alturas de texto carregam o ruído float32 do SkParagraph (±1e-3).
const _eps = 1e-3;

void _expectRect(Rect got, Rect exp, {String? reason, double eps = _eps}) {
  for (final (what, g, e) in [
    ('x', got.left, exp.left),
    ('y', got.top, exp.top),
    ('w', got.width, exp.width),
    ('h', got.height, exp.height),
  ]) {
    expect(g, moreOrLessEquals(e, epsilon: eps), reason: '$reason $what');
  }
}

T _parentOf<T extends Widget>(WidgetTester tester, String id) =>
    tester.widget<T>(
      find
          .ancestor(
            of: find.byKey(ValueKey<String>(id)),
            matching: find.byType(T),
          )
          .first,
    );

const _column = (280 - 6 * 8) / 7; // 33,142857…
const _barHeights = [43.0, 60.0, 40.0, 30.0, 51.0, 73.0, 24.0];

/// F07 — camada 1 (geometria) e construção da seção `today`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F07 geometria: os 49 ids da seção today dentro da tolerância (canvas 390×2390)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final ids = idsOfSection('today').toList();
      expect(ids, [
        'today',
        'today.decoCircleLarge',
        'today.decoCircleSmall',
        'today.header',
        'today.title',
        'today.streakPill',
        'today.streakPill.icon',
        'today.goalRow',
        'today.dial',
        'today.dial.svg',
        'today.dial.center',
        'today.dial.value',
        'today.dial.caption',
        'today.goalText',
        'today.goalText.sentence',
        'today.chips',
        'today.chip.pages',
        'today.chip.highlights',
        'today.week',
        'today.week.header',
        'today.week.title',
        'today.week.total',
        'today.week.chart',
        'today.week.goalLine',
        for (var i = 0; i < 7; i++) ...[
          'today.week.bar$i',
          'today.week.bar$i.fill',
        ],
        'today.week.labels',
        for (var i = 0; i < 7; i++) 'today.week.label$i',
        'today.footer',
        'today.footer.icon',
        'today.footer.text',
      ]);
      expect(ids, hasLength(49));
      reportGeometry(tester, ids);
      expectGeometry(tester, ids);
    },
  );

  testWidgets(
    '7.1 cartão 350 × 400,8 = 1,5 + 18 + 32 + 16 + 112 + 16 + 153,8 + 16 + 16 + 18 + 1,5; círculos 153/101 em −46/−46 e −20/−20 da padding box',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final section = _parentOf<Semantics>(tester, 'today');
      expect(section.child!.key, const ValueKey('today'));
      expect(section.container, isTrue);
      expect(section.explicitChildNodes, isTrue);
      expect(section.properties.label, 'Seu dia de leitura');

      final card = _rect(tester, 'today');
      expect(card.left, 20);
      expect(card.width, 350);
      expect(card.top, moreOrLessEquals(766.76, epsilon: _eps));
      expect(
        card.height,
        moreOrLessEquals(
          1.5 + 18 + 32 + 16 + 112 + 16 + 153.8 + 16 + 16 + 18 + 1.5,
          epsilon: _eps,
        ),
      );
      // Blocos da coluna: 32, 112, 153,8, 16 com gap 16, a 19,5 (= 1,5 + 18) das bordas.
      final blocks = [
        ('today.header', 32.0),
        ('today.goalRow', 112.0),
        ('today.week', 153.8),
        ('today.footer', 16.0),
      ];
      var y = 19.5;
      for (final (id, h) in blocks) {
        _expectRect(
          _rel(tester, id),
          Rect.fromLTWH(19.5, y, 311, h),
          reason: id,
        );
        y += h + 16;
      }
      expect(y - 16 + 19.5, moreOrLessEquals(400.8, epsilon: _eps));

      // content-box: 150 + 3 e 98 + 3. right/top medidos a partir da padding box (1,5 dentro da borda).
      _expectRect(
        _rel(tester, 'today.decoCircleLarge'),
        const Rect.fromLTWH(1.5 + 347 + 46 - 153, 1.5 - 46, 153, 153),
        reason: 'decoCircleLarge',
        eps: 1e-9,
      );
      _expectRect(
        _rel(tester, 'today.decoCircleSmall'),
        const Rect.fromLTWH(1.5 + 347 + 20 - 101, 1.5 - 20, 101, 101),
        reason: 'decoCircleSmall',
        eps: 1e-9,
      );
      // Concêntricos em (318; 32) da seção.
      expect(
        _rel(tester, 'today.decoCircleLarge').center,
        const Offset(318, 32),
      );
      expect(
        _rel(tester, 'today.decoCircleSmall').center,
        const Offset(318, 32),
      );
    },
  );

  testWidgets(
    '7.2 cabeçalho 311 × 32 (space-between, centro): título 156,76 × 29,9 a y + 1,05; pílula 84,23 × 32 na direita (8 + 17 + 5 + texto + 11)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final header = _rel(tester, 'today.header');
      final title = _rel(tester, 'today.title');
      final pill = _rel(tester, 'today.streakPill');
      final icon = _rel(tester, 'today.streakPill.icon');
      expect(title.left, header.left);
      expect(title.width, moreOrLessEquals(156.76, epsilon: 0.02));
      // A linha mista mede 29,9: a serifada 23/1,3 define ascendente e descendente.
      expect(title.height, moreOrLessEquals(29.9, epsilon: _eps));
      expect(title.top - header.top, moreOrLessEquals(1.05, epsilon: _eps));
      expect(pill.right, moreOrLessEquals(header.right, epsilon: 1e-9));
      expect(pill.height, 32);
      expect(pill.top, header.top);
      // Borda 1,5 + padding-left 8; chama 17 centrada nos 29 internos (+6 → 7,5 da borda externa).
      expect(icon.left - pill.left, moreOrLessEquals(9.5, epsilon: 1e-9));
      expect(icon.top - pill.top, moreOrLessEquals(7.5, epsilon: 1e-9));
      expect(icon.size, const Size(17, 17));
      final text = tester.getRect(
        find.descendant(
          of: find.byKey(const ValueKey('today.streakPill')),
          matching: find.byType(AppText),
        ),
      );
      expect(text.left - _rect(tester, 'today.streakPill.icon').right, 5);
      expect(
        _rect(tester, 'today.streakPill').right - text.right,
        moreOrLessEquals(11 + 1.5, epsilon: 1e-9),
      );
      expect(
        pill.width,
        moreOrLessEquals(
          1.5 + 8 + 17 + 5 + text.width + 11 + 1.5,
          epsilon: 1e-9,
        ),
      );
      expect(pill.width, moreOrLessEquals(84.23, epsilon: 0.01));
    },
  );

  testWidgets(
    '7.3 linha da meta 311 × 112 (gap 18, centro): dial 112 com svg e centro do mesmo tamanho; "18" + "de 30 min" (47,2) a y + 32,4',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final row = _rel(tester, 'today.goalRow');
      final dial = _rel(tester, 'today.dial');
      expect(dial, Rect.fromLTWH(row.left, row.top, 112, 112));
      // O CustomPaint e a coluna central medem os mesmos 112 × 112 (Positioned.fill).
      expect(_rel(tester, 'today.dial.svg'), dial);
      expect(_rel(tester, 'today.dial.center'), dial);
      final value = _rel(tester, 'today.dial.value');
      final caption = _rel(tester, 'today.dial.caption');
      expect(
        value.height,
        moreOrLessEquals(34, epsilon: _eps),
      ); // line-height 1
      expect(caption.height, moreOrLessEquals(13.2, epsilon: _eps));
      // Bloco 34 + 13,2 = 47,2 centrado nos 112: começa em (112 − 47,2)/2 = 32,4.
      expect(value.top - dial.top, moreOrLessEquals(32.4, epsilon: _eps));
      expect(caption.top, moreOrLessEquals(value.bottom, epsilon: _eps));
      // Centralizados na horizontal.
      expect(value.center.dx, moreOrLessEquals(dial.center.dx, epsilon: 1e-9));
      expect(
        caption.center.dx,
        moreOrLessEquals(dial.center.dx, epsilon: 1e-9),
      );
      final row0 = tester.widget<Row>(
        find.byKey(const ValueKey('today.goalRow')),
      );
      expect(row0.spacing, 18);
      expect(row0.crossAxisAlignment, CrossAxisAlignment.center);
    },
  );

  testWidgets(
    '7.4 coluna 181 × 75,8 (gap 10) centrada a y + 18,1: frase 181 × 39 (2 × 19,5); chips 26,8 com gap 6',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final row = _rel(tester, 'today.goalRow');
      final goal = _rel(tester, 'today.goalText');
      expect(goal.left, row.left + 112 + 18);
      expect(goal.width, 311 - 112 - 18);
      expect(goal.height, moreOrLessEquals(39 + 10 + 26.8, epsilon: _eps));
      expect(
        goal.top - row.top,
        moreOrLessEquals((112 - 75.8) / 2, epsilon: _eps),
      );
      final sentence = _rel(tester, 'today.goalText.sentence');
      expect(sentence.width, 181);
      expect(sentence.height, moreOrLessEquals(2 * 19.5, epsilon: _eps));
      final chips = _rel(tester, 'today.chips');
      expect(chips.top - sentence.bottom, moreOrLessEquals(10, epsilon: _eps));
      expect(chips.width, 181);
      final pages = _rel(tester, 'today.chip.pages');
      final highlights = _rel(tester, 'today.chip.highlights');
      // 1,2 + 5 + 14,4 + 5 + 1,2 = 26,8 e 1,2 + 9 + texto + 9 + 1,2.
      for (final (id, r, w) in [
        ('pages', pages, 60.11),
        ('highlights', highlights, 66.45),
      ]) {
        expect(r.height, moreOrLessEquals(26.8, epsilon: _eps), reason: id);
        expect(
          r.width,
          moreOrLessEquals(2.4 + 18 + w, epsilon: 0.01),
          reason: id,
        );
      }
      expect(pages.left, chips.left);
      expect(highlights.left - pages.right, moreOrLessEquals(6, epsilon: 1e-9));
      expect(highlights.top, pages.top);
    },
  );

  testWidgets(
    '7.4 flex-wrap: numa largura em que os dois chips não cabem (canvas 360), o segundo desce com gap 6 e volta à esquerda',
    (tester) async {
      setCanvasView(tester, logical: const Size(360, 2390));
      await pumpApp(tester);
      final chips = _rect(tester, 'today.chips');
      final pages = _rect(tester, 'today.chip.pages');
      final highlights = _rect(tester, 'today.chip.highlights');
      // 281 − 112 − 18 = 151 < 80,51 + 6 + 86,86 = 173,37.
      expect(chips.width, 151);
      expect(highlights.left, pages.left);
      expect(highlights.top - pages.bottom, moreOrLessEquals(6, epsilon: 1e-9));
      expect(chips.height, moreOrLessEquals(2 * 26.8 + 6, epsilon: _eps));
      debugPrint(
        '[geometria 360] chips ${chips.width.toStringAsFixed(2)} × ${chips.height.toStringAsFixed(2)}; '
        'highlights em (${highlights.left.toStringAsFixed(2)}; ${highlights.top.toStringAsFixed(2)})',
      );
    },
  );

  testWidgets(
    '7.5 cartão da semana 311 × 153,8 = 1,5 + 14 + 15,6 + 8 + 80 + 8 + 13,2 + 12 + 1,5; cabeçalho por baseline (total 0,95 abaixo)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final week = _rel(tester, 'today.week');
      expect(
        week.height,
        moreOrLessEquals(
          1.5 + 14 + 15.6 + 8 + 80 + 8 + 13.2 + 12 + 1.5,
          epsilon: _eps,
        ),
      );
      final header = _rel(tester, 'today.week.header');
      _expectRect(
        header,
        Rect.fromLTWH(week.left + 15.5, week.top + 15.5, 280, 15.6),
        reason: 'week.header',
      );
      final chart = _rel(tester, 'today.week.chart');
      _expectRect(
        chart,
        Rect.fromLTWH(header.left, header.bottom + 8, 280, 80),
        reason: 'week.chart',
      );
      final labels = _rel(tester, 'today.week.labels');
      _expectRect(
        labels,
        Rect.fromLTWH(header.left, chart.bottom + 8, 280, 13.2),
        reason: 'week.labels',
      );
      expect(
        week.bottom - labels.bottom,
        moreOrLessEquals(12 + 1.5, epsilon: _eps),
      );
      final title = _rel(tester, 'today.week.title');
      final total = _rel(tester, 'today.week.total');
      expect(title.topLeft, header.topLeft);
      expect(total.right, moreOrLessEquals(header.right, epsilon: 1e-9));
      expect(total.top - title.top, moreOrLessEquals(0.95, epsilon: 0.01));
      // Mesma baseline: ascendentes 12,35 (Figtree 13) e 11,40 (Figtree 12).
      final titleText = tester.renderObject<RenderAppText>(
        find.byKey(const ValueKey('today.week.title')),
      );
      final totalText = tester.renderObject<RenderAppText>(
        find.byKey(const ValueKey('today.week.total')),
      );
      expect(
        titleText.debugLines().single.baseline,
        moreOrLessEquals(totalText.debugLines().single.baseline, epsilon: 1e-9),
      );
    },
  );

  testWidgets(
    '7.6 gráfico: 7 colunas de 33,143 com gap 8; trilhos 80 alinhados embaixo; preenchimentos na base, com as alturas do arquivo',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final chart = _rect(tester, 'today.week.chart');
      for (var i = 0; i < 7; i++) {
        final bar = _rect(tester, 'today.week.bar$i');
        final bw = i == 6 ? 1.5 : 1.2;
        expect(
          bar.left - chart.left,
          moreOrLessEquals(i * (_column + 8), epsilon: 1e-9),
        );
        expect(bar.width, moreOrLessEquals(_column, epsilon: 1e-9));
        expect(bar.height, moreOrLessEquals(80, epsilon: 1e-9));
        expect(bar.bottom, moreOrLessEquals(chart.bottom, epsilon: 1e-9));
        final fill = _rect(tester, 'today.week.bar$i.fill');
        expect(fill.left - bar.left, moreOrLessEquals(bw, epsilon: 1e-9));
        expect(fill.width, moreOrLessEquals(_column - 2 * bw, epsilon: 1e-9));
        expect(fill.height, moreOrLessEquals(_barHeights[i], epsilon: 1e-9));
        expect(bar.bottom - fill.bottom, moreOrLessEquals(bw, epsilon: 1e-9));
      }
      expect(
        _rect(tester, 'today.week.bar6').right,
        moreOrLessEquals(chart.right, epsilon: 1e-9),
      );
    },
  );

  testWidgets(
    '7.7 linha da meta 288 × 1,5 (left/right −4, bottom 38); rótulos nas mesmas colunas, 13,2 de altura, texto centralizado',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final chart = _rect(tester, 'today.week.chart');
      final line = _rect(tester, 'today.week.goalLine');
      expect(line.left, chart.left - 4);
      expect(line.right, chart.right + 4);
      expect(line.size, const Size(288, 1.5));
      expect(chart.bottom - line.bottom, moreOrLessEquals(38, epsilon: 1e-9));
      for (var i = 0; i < 7; i++) {
        final label = _rect(tester, 'today.week.label$i');
        final bar = _rect(tester, 'today.week.bar$i');
        expect(label.left, moreOrLessEquals(bar.left, epsilon: 1e-9));
        expect(label.width, moreOrLessEquals(bar.width, epsilon: 1e-9));
        expect(label.height, moreOrLessEquals(13.2, epsilon: _eps));
        final text = tester
            .renderObject<RenderAppText>(
              find.byKey(ValueKey('today.week.label$i')),
            )
            .debugLines()
            .single;
        // text-align: center → o trecho de glifos fica centrado na coluna.
        expect(
          (text.left + text.right) / 2,
          moreOrLessEquals(label.center.dx, epsilon: 1e-3),
          reason: 'label$i',
        );
      }
    },
  );

  testWidgets(
    '7.8 rodapé 311 × 16 (gap 8, centro): brilho 16 à esquerda; frase a 8 dele, 15,6 centrada (y + 0,2)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final footer = _rel(tester, 'today.footer');
      final icon = _rel(tester, 'today.footer.icon');
      final text = _rel(tester, 'today.footer.text');
      expect(icon, Rect.fromLTWH(footer.left, footer.top, 16, 16));
      expect(text.left - icon.right, 8);
      expect(text.height, moreOrLessEquals(15.6, epsilon: _eps));
      expect(text.top - footer.top, moreOrLessEquals(0.2, epsilon: _eps));
      expect(text.width, moreOrLessEquals(193.65, epsilon: 0.05));
      // Rodapé encostado no padding de baixo do cartão: 18 + 1,5.
      expect(
        _rel(tester, 'today').bottom - footer.bottom,
        moreOrLessEquals(19.5, epsilon: _eps),
      );
      // Todos os textos da seção têm referência de linha no arquivo.
      for (final id in [
        'today.footer.text',
        'today.title',
        'today.goalText.sentence',
      ]) {
        expect(kRefLayout[id]!.lines, isNotEmpty, reason: id);
      }
    },
  );
}
