import 'package:app_leitura/core/design_system/painters/chromium_dash.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/count_badge.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pill.dart';
import 'package:app_leitura/core/design_system/widgets/pressable.dart';
import 'package:app_leitura/features/home/presentation/sections/book_club_ticket.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/geometry.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

Rect _rect(WidgetTester tester, String id) =>
    tester.getRect(find.byKey(ValueKey<String>(id)));

/// Retângulo relativo ao canto superior esquerdo da seção (a tabela da F09 usa essa origem).
Rect _rel(WidgetTester tester, String id) =>
    _rect(tester, id).shift(-_rect(tester, 'club').topLeft);

/// Alturas e posições que somam alturas de texto carregam o ruído float32 do SkParagraph (±1e-3).
const _eps = 1e-3;

/// Larguras medidas de texto: as fontes estáticas foram validadas contra o navegador com desvio
/// ≤ 0,05 px (§6.1 do prompt mestre).
const _textW = 0.05;

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

/// Retângulo (relativo à seção) do `AppText` sem Key dentro do widget com a Key [id].
Rect _textIn(WidgetTester tester, String id) => tester
    .getRect(
      find.descendant(
        of: find.byKey(ValueKey<String>(id)),
        matching: find.byType(AppText),
      ),
    )
    .shift(-_rect(tester, 'club').topLeft);

/// Tabela "Especificação pixel a pixel" da F09 (x, y, w, h relativos à seção), na ordem do arquivo.
const _table = [
  ('club', 0.0, 0.0, 350.0, 266.6),
  ('club.ticket', 0.0, 0.0, 350.0, 266.6),
  ('club.body', 1.5, 1.5, 255.0, 263.6),
  ('club.topRow', 19.5, 19.5, 221.0, 27.4),
  ('club.pill', 19.5, 19.5, 99.38, 27.4),
  ('club.avatars', 160.5, 20.2, 80.0, 26.0),
  ('club.avatar0', 160.5, 20.2, 26.0, 26.0),
  ('club.avatar1', 178.5, 20.2, 26.0, 26.0),
  ('club.avatar2', 196.5, 20.2, 26.0, 26.0),
  ('club.avatar3', 214.5, 20.2, 26.0, 26.0),
  ('club.titleBlock', 19.5, 60.9, 221.0, 77.8),
  ('club.title', 19.5, 60.9, 221.0, 56.2),
  ('club.subtitle', 19.5, 123.1, 221.0, 15.6),
  ('club.progressBlock', 19.5, 152.7, 221.0, 34.4),
  ('club.progressTrack', 19.5, 152.7, 221.0, 12.0),
  ('club.progressBar', 19.5, 152.7, 221.0, 12.0),
  ('club.progressFill', 21.0, 154.2, 117.72, 9.0),
  ('club.youMarker', 144.52, 146.7, 24.0, 24.0),
  ('club.progressLabels', 19.5, 172.7, 221.0, 14.4),
  ('club.groupLabel', 19.5, 172.7, 81.12, 14.4),
  ('club.youLabel', 165.62, 172.7, 74.88, 14.4),
  ('club.cta', 19.5, 201.1, 221.0, 46.0),
  ('club.cta.icon', 53.69, 215.1, 18.0, 18.0),
  ('club.cta.label', 79.69, 215.7, 98.63, 16.8),
  ('club.cta.badge', 186.31, 214.1, 20.0, 20.0),
  ('club.stub', 256.5, 1.5, 92.0, 263.6),
  ('club.stub.label', 270.94, 67.65, 64.63, 12.0),
  ('club.stub.date', 279.13, 91.65, 48.24, 68.7),
  ('club.stub.weekday', 291.12, 91.65, 24.26, 14.4),
  ('club.stub.day', 279.13, 106.05, 48.24, 39.9),
  ('club.stub.month', 291.13, 145.95, 24.24, 14.4),
  ('club.stub.time', 280.07, 172.35, 46.36, 26.6),
  ('club.notchTop', 244.25, -13.0, 26.0, 26.0),
  ('club.notchBottom', 244.25, 253.6, 26.0, 26.0),
];

/// F09 — camada 1 (geometria) e construção da seção `club`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F09 geometria: os 34 ids da seção club dentro da tolerância (canvas 390×2390)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final ids = idsOfSection('club').toList();
      expect(ids, [for (final row in _table) row.$1]);
      expect(ids, hasLength(34));
      expectGeometry(tester, ids);
      reportGeometry(tester, ids);
    },
  );

  testWidgets(
    'posições da tabela da F09 relativas à seção (34 linhas, ≤ 0,05 px)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      var worst = ('', 0.0);
      for (final (id, x, y, w, h) in _table) {
        final got = _rel(tester, id);
        for (final (what, g, e) in [
          ('x', got.left, x),
          ('y', got.top, y),
          ('w', got.width, w),
          ('h', got.height, h),
        ]) {
          final d = (g - e).abs();
          if (d > worst.$2) worst = ('$id.$what', d);
          expect(g, moreOrLessEquals(e, epsilon: 0.05), reason: '$id.$what');
        }
      }
      debugPrint(
        '[tabela F09] 34 linhas; maior desvio ${worst.$1} = ${worst.$2.toStringAsFixed(4)}',
      );
    },
  );

  testWidgets(
    '9.1 construção: Semantics(seção) > ClipRRect(club, 28) > Stack(Clip.none)[ticket, entalhe de cima, entalhe de baixo]; ticket > IntrinsicHeight > Row(stretch)[Expanded(Padding(corpo 18 16 18 18) > Column(stretch, gap 14)), SizedBox(canhoto, 92)]',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final sectionFinder = find.byType(BookClubTicket);
      final section = tester.widget<Semantics>(
        find
            .descendant(of: sectionFinder, matching: find.byType(Semantics))
            .first,
      );
      // O Semantics da seção é a raiz do build de BookClubTicket (nada por fora dele).
      Widget? root;
      tester.element(sectionFinder).visitChildElements((e) => root = e.widget);
      expect(root, same(section));
      expect(section.container, isTrue);
      expect(section.explicitChildNodes, isTrue);
      expect(section.properties.label, 'Seu clube do livro');

      // A <section> só recorta: ClipRRect de raio 28 (sem borda nem fundo), suavizado.
      final clip = section.child! as ClipRRect;
      expect(clip.key, const ValueKey('club'));
      expect(clip.borderRadius, BorderRadius.circular(28));
      expect(clip.clipBehavior, Clip.antiAlias);
      expect(clip.clipper, isNull);
      final stack = clip.child! as Stack;
      // Os entalhes transbordam 13 px: sem Clip.none a Stack empilharia um recorte retangular sem suavização.
      expect(stack.clipBehavior, Clip.none);
      expect(stack.fit, StackFit.loose);
      expect(stack.children, hasLength(3));
      final ticket = stack.children[0] as NeoBox;
      expect(ticket.key, const ValueKey('club.ticket'));
      final notches = stack.children.skip(1).cast<Positioned>().toList();
      expect(
        [for (final n in notches) (n.left, n.top, n.right, n.bottom)],
        [(null, -13.0, 79.75, null), (null, null, 79.75, -13.0)],
      );
      expect(
        [for (final n in notches) (n.width, n.height)],
        [(null, null), (null, null)],
      );
      expect(
        [for (final n in notches) n.child.key],
        [const ValueKey('club.notchTop'), const ValueKey('club.notchBottom')],
      );

      final intrinsic = ticket.child! as IntrinsicHeight;
      final row = intrinsic.child! as Row;
      expect(row.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(row.mainAxisAlignment, MainAxisAlignment.start);
      expect(row.mainAxisSize, MainAxisSize.max);
      expect(row.spacing, 0);
      expect(row.children, hasLength(2));
      final expanded = row.children[0] as Expanded;
      expect(expanded.flex, 1);
      final body = expanded.child as Padding;
      expect(body.key, const ValueKey('club.body'));
      expect(body.padding, const EdgeInsets.fromLTRB(18, 18, 16, 18));
      final column = body.child! as Column;
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(column.mainAxisAlignment, MainAxisAlignment.start);
      expect(column.spacing, 14);
      expect(column.children, hasLength(4));
      final stub = row.children[1] as SizedBox;
      expect(stub.key, const ValueKey('club.stub'));
      expect((stub.width, stub.height), (92.0, null));

      // Na tela: dentro do padding lateral 20 (`_gutter`), 40 abaixo de "Para você".
      expect(_parentOf<Padding>(tester, 'club').padding.horizontal, 40);
      final forYou = _rect(tester, 'forYou');
      final club = _rect(tester, 'club');
      expect(club.top - forYou.bottom, moreOrLessEquals(40, epsilon: _eps));
      _expectRect(
        club,
        const Rect.fromLTWH(20, 1574.56, 350, 266.6),
        reason: 'seção',
      );
    },
  );

  testWidgets(
    '9.1 ticket 350 × 266,6 = 1,5 + 18 + 27,4 + 14 + 77,8 + 14 + 34,4 + 14 + 46 + 18 + 1,5; corpo 255 = 350 − 3 − 92; canhoto 92 esticado à altura do corpo',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final ticket = _rel(tester, 'club.ticket');
      final body = _rel(tester, 'club.body');
      final stub = _rel(tester, 'club.stub');
      expect(ticket, _rel(tester, 'club'));
      // Corpo e canhoto na padding box do ticket (borda 1,5), lado a lado.
      expect(body.topLeft, const Offset(1.5, 1.5));
      expect(body.width, 350 - 2 * 1.5 - 92);
      expect(stub.left, body.right);
      expect(stub.width, 92);
      expect(stub.right, 350 - 1.5);
      expect(stub.top, body.top);
      expect(stub.height, body.height);
      // A altura vem da soma das alturas de texto (IntrinsicHeight): ruído float32 do SkParagraph.
      expect(body.bottom, moreOrLessEquals(266.6 - 1.5, epsilon: _eps));
      expect(body.bottom, ticket.bottom - 1.5);
      // Alturas das 4 partes do corpo e o ritmo 18 + gaps 14 + 18.
      final parts = [
        _rel(tester, 'club.topRow'),
        _rel(tester, 'club.titleBlock'),
        _rel(tester, 'club.progressBlock'),
        _rel(tester, 'club.cta'),
      ];
      final heights = [for (final p in parts) p.height];
      for (final (i, h) in [27.4, 77.8, 34.4, 46.0].indexed) {
        expect(heights[i], moreOrLessEquals(h, epsilon: _eps), reason: '$i');
      }
      expect(parts.first.top - body.top, moreOrLessEquals(18, epsilon: 1e-9));
      for (var i = 1; i < parts.length; i++) {
        expect(
          parts[i].top - parts[i - 1].bottom,
          moreOrLessEquals(14, epsilon: 1e-9),
          reason: 'gap $i',
        );
      }
      expect(
        body.bottom - parts.last.bottom,
        moreOrLessEquals(18, epsilon: _eps),
      );
      for (final p in parts) {
        expect(p.left, body.left + 18);
        expect(p.width, body.width - 18 - 16);
      }
      final sum =
          1.5 + 18 + heights.reduce((a, b) => a + b) + 3 * 14 + 18 + 1.5;
      expect(ticket.height, moreOrLessEquals(sum, epsilon: 1e-9));
      expect(ticket.height, moreOrLessEquals(266.6, epsilon: _eps));
      debugPrint(
        '[ticket] altura ${ticket.height.toStringAsFixed(6)} = 1,5 + 18 + '
        '${heights.map((h) => h.toStringAsFixed(6)).join(' + ')} + 3 × 14 + 18 + 1,5 | corpo ${body.width} | canhoto ${stub.size}',
      );
    },
  );

  testWidgets(
    '9.2 perfuração: CustomPaint vertical 1,5 × 263,6 na borda esquerda do canhoto → 59 traços de 3, vão 1,4931; entalhes 26 com o centro sobre a perfuração (x = 350 − 92,75) e sobre as bordas de cima e de baixo',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final stub = _rel(tester, 'club.stub');
      final dash = find.byKey(const ValueKey('club.stub.perforation'));
      final dashRect = tester
          .getRect(dash)
          .shift(-_rect(tester, 'club').topLeft);
      _expectRect(
        dashRect,
        Rect.fromLTWH(stub.left, stub.top, 1.5, stub.height),
        eps: 1e-9,
        reason: 'perfuração',
      );
      final painter = tester.widget<CustomPaint>(dash).painter!;
      expect(painter, isA<ChromiumDashPainter>());
      expect((painter as ChromiumDashPainter).axis, Axis.vertical);
      final starts = chromiumDashStarts(
        length: dashRect.height,
        thickness: 1.5,
      );
      expect(starts, hasLength(59));
      final gap = starts[1] - starts[0] - 3;
      expect(gap, moreOrLessEquals(1.4931, epsilon: 1e-4));
      expect(starts.first, 0);
      expect(starts.last + 3, moreOrLessEquals(263.6, epsilon: _eps));
      // A outra contagem possível (58 traços) teria um vão mais distante do ideal 1,5.
      final gap58 = (263.6 - 58 * 3) / 57;
      expect((gap58 - 1.5).abs(), greaterThan((gap - 1.5).abs()));
      debugPrint(
        '[perfuração] 59 traços de 3 em ${dashRect.height.toStringAsFixed(6)}; vão ${gap.toStringAsFixed(5)} '
        '(58 traços daria ${gap58.toStringAsFixed(5)})',
      );

      final top = _rel(tester, 'club.notchTop');
      final bottom = _rel(tester, 'club.notchBottom');
      for (final n in [top, bottom]) {
        expect(n.size, const Size(26, 26));
        // right 79,75 → centro em x = 350 − 79,75 − 13 = 257,25 = meio da perfuração (256,5 + 0,75).
        expect(n.right, 350 - 79.75);
        expect(n.center.dx, moreOrLessEquals(350 - 92.75, epsilon: 1e-9));
        expect(n.center.dx, dashRect.center.dx);
      }
      expect(top.center.dy, 0);
      expect(bottom.center.dy, moreOrLessEquals(266.6, epsilon: _eps));
      expect(bottom.center.dy, _rel(tester, 'club').bottom);
    },
  );

  testWidgets(
    '9.3 linha superior (space-between, centro, gap 8): pílula 99,38 × 27,4 à esquerda (texto em x + 11,5); avatares 26 com passo 18 (margin-left −8) → grupo 80 × 26 à direita, centrado (y + 0,7)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final row = tester.widget<Row>(find.byKey(const ValueKey('club.topRow')));
      expect(row.mainAxisAlignment, MainAxisAlignment.spaceBetween);
      expect(row.crossAxisAlignment, CrossAxisAlignment.center);
      expect(row.spacing, 8);
      expect(row.children, hasLength(2));
      expect(row.children[0], isA<Pill>());
      expect(row.children[0].key, const ValueKey('club.pill'));

      final topRow = _rel(tester, 'club.topRow');
      final pill = _rel(tester, 'club.pill');
      final avatars = _rel(tester, 'club.avatars');
      expect(pill.left, topRow.left);
      expect(pill.width, moreOrLessEquals(99.38, epsilon: _textW));
      expect(pill.height, moreOrLessEquals(27.4, epsilon: _eps));
      expect(pill.top, topRow.top);
      final text = _textIn(tester, 'club.pill');
      // Padding 5 10 + borda 1,5.
      expect(text.left - pill.left, moreOrLessEquals(11.5, epsilon: 1e-9));
      expect(pill.right - text.right, moreOrLessEquals(11.5, epsilon: 1e-9));
      expect(text.top - pill.top, moreOrLessEquals(6.5, epsilon: 1e-9));
      expect(text.width, moreOrLessEquals(76.38, epsilon: _textW));
      expect(avatars.size, const Size(80, 26));
      expect(avatars.right, topRow.right);
      expect(
        avatars.top - topRow.top,
        moreOrLessEquals((27.4 - 26) / 2, epsilon: _eps),
      );
      // Espaço livre entre os dois ≥ gap 8.
      expect(avatars.left - pill.right, greaterThan(8));

      final group = tester.widget<SizedBox>(
        find.byKey(const ValueKey('club.avatars')),
      );
      expect((group.width, group.height), (80.0, 26.0));
      final stack = group.child! as Stack;
      expect(stack.children, hasLength(4));
      for (final (i, child) in stack.children.indexed) {
        final p = child as Positioned;
        expect(
          (p.left, p.top, p.right, p.bottom, p.width, p.height),
          (i * 18.0, null, null, null, null, null),
          reason: 'avatar $i',
        );
        // Ordem de pintura = ordem do arquivo: A, J, L e "+8" por cima dos anteriores.
        expect(p.child.key, ValueKey('club.avatar$i'));
        final a = _rel(tester, 'club.avatar$i');
        expect(a, Rect.fromLTWH(avatars.left + 18.0 * i, avatars.top, 26, 26));
        // Cada inicial centralizada no círculo.
        final t = _textIn(tester, 'club.avatar$i');
        expect(t.center.dx, moreOrLessEquals(a.center.dx, epsilon: 1e-9));
        expect(t.center.dy, moreOrLessEquals(a.center.dy, epsilon: 1e-9));
      }
      // Sobreposição de 8 entre vizinhos.
      expect(
        _rel(tester, 'club.avatar0').right - _rel(tester, 'club.avatar1').left,
        8,
      );
    },
  );

  testWidgets(
    '9.4 título = Column(club.title, stretch)[AppText 22, AppText 34,2] = 56,2 (baselines 18,26 e 51,34 a partir do topo); gap 6; subtítulo 15,6 → bloco 77,8',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final title = tester.widget<Column>(
        find.byKey(const ValueKey('club.title')),
      );
      expect(title.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(title.mainAxisSize, MainAxisSize.min);
      expect(title.spacing, 0);
      expect(title.children, hasLength(2));
      expect(title.children.every((w) => w is AppText), isTrue);
      final block = tester.widget<Column>(
        find.byKey(const ValueKey('club.titleBlock')),
      );
      expect(block.spacing, 6);
      expect(block.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(block.children, hasLength(2));
      expect(block.children[1].key, const ValueKey('club.subtitle'));

      final lines = [
        for (final e
            in find
                .descendant(
                  of: find.byKey(const ValueKey('club.title')),
                  matching: find.byType(AppText),
                )
                .evaluate())
          e.renderObject! as RenderAppText,
      ];
      expect(lines, hasLength(2));
      final origin = _rect(tester, 'club').topLeft;
      final r0 = (lines[0].localToGlobal(Offset.zero) - origin) & lines[0].size;
      final r1 = (lines[1].localToGlobal(Offset.zero) - origin) & lines[1].size;
      final t = _rel(tester, 'club.title');
      expect(r0.top, t.top);
      expect(r0.height, moreOrLessEquals(22, epsilon: _eps));
      expect(r1.top, moreOrLessEquals(r0.bottom, epsilon: 1e-9));
      expect(r1.height, moreOrLessEquals(34.2, epsilon: _eps));
      expect(t.height, moreOrLessEquals(56.2, epsilon: _eps));
      // As duas linhas esticadas à largura do bloco (221), como as caixas de linha do <h3>.
      expect((r0.width, r1.width), (221.0, 221.0));
      final b0 = lines[0].debugLines().single.baseline - origin.dy;
      final b1 = lines[1].debugLines().single.baseline - origin.dy;
      expect(b0 - t.top, moreOrLessEquals(18.26, epsilon: 0.01));
      expect(b1 - t.top, moreOrLessEquals(51.34, epsilon: 0.01));
      debugPrint(
        '[título] linhas ${r0.height.toStringAsFixed(6)} + ${r1.height.toStringAsFixed(6)} | '
        'baselines ${(b0 - t.top).toStringAsFixed(3)} e ${(b1 - t.top).toStringAsFixed(3)} a partir do topo',
      );
      final sub = _rel(tester, 'club.subtitle');
      expect(sub.top - t.bottom, moreOrLessEquals(6, epsilon: 1e-9));
      expect(sub.height, moreOrLessEquals(15.6, epsilon: _eps));
      expect(
        _rel(tester, 'club.titleBlock').height,
        moreOrLessEquals(77.8, epsilon: _eps),
      );
    },
  );

  testWidgets(
    '9.5 progresso: trilho 221 × 12; preenchimento = 54 % de 218 = 117,72 × 9 na padding box; marcador 24 com o centro em 62 % de 221 (x = 39,5 + 137,02 = 176,52 absoluto) e na metade da altura → 6 px acima e abaixo; legendas 8 abaixo, nas pontas',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final track = _rel(tester, 'club.progressTrack');
      final bar = _rel(tester, 'club.progressBar');
      final fill = _rel(tester, 'club.progressFill');
      final marker = _rel(tester, 'club.youMarker');
      expect(track.size, const Size(221, 12));
      expect(bar, track);
      expect(fill.topLeft, bar.topLeft + const Offset(1.5, 1.5));
      expect(fill.height, 12 - 3);
      expect(fill.width, moreOrLessEquals(0.54 * (221 - 3), epsilon: 1e-9));
      expect(fill.width, moreOrLessEquals(117.72, epsilon: 1e-9));
      // O marcador.
      expect(marker.size, const Size(24, 24));
      expect(
        marker.center.dx,
        moreOrLessEquals(track.left + 0.62 * 221, epsilon: 1e-9),
      );
      expect(
        _rect(tester, 'club.youMarker').center.dx,
        moreOrLessEquals(176.52, epsilon: 1e-9),
      );
      expect(marker.center.dy, track.center.dy);
      expect(track.top - marker.top, 6);
      expect(marker.bottom - track.bottom, 6);
      // Ele fica à direita do fim do preenchimento (62 % > 54 %), sobre a parte hachurada.
      expect(marker.left, greaterThan(fill.right));
      // "M" centrado.
      final m = _textIn(tester, 'club.youMarker');
      expect(m.center.dx, moreOrLessEquals(marker.center.dx, epsilon: 1e-9));
      expect(m.center.dy, moreOrLessEquals(marker.center.dy, epsilon: 1e-9));

      final layout = tester.widget<SizedBox>(
        find.byKey(const ValueKey('club.progressTrack')),
      );
      expect((layout.width, layout.height), (null, 12.0));
      expect(layout.child, isA<LayoutBuilder>());
      final labels = _rel(tester, 'club.progressLabels');
      final group = _rel(tester, 'club.groupLabel');
      final you = _rel(tester, 'club.youLabel');
      expect(labels.top - track.bottom, 8);
      expect(labels.size, Size(221, labels.height));
      expect(labels.height, moreOrLessEquals(14.4, epsilon: _eps));
      expect(group.left, labels.left);
      expect(you.right, labels.right);
      expect(group.width, moreOrLessEquals(81.12, epsilon: _textW));
      expect(you.width, moreOrLessEquals(74.88, epsilon: _textW));
      final row = tester.widget<Row>(
        find.byKey(const ValueKey('club.progressLabels')),
      );
      expect(row.mainAxisAlignment, MainAxisAlignment.spaceBetween);
      expect(
        _rel(tester, 'club.progressBlock').height,
        moreOrLessEquals(12 + 8 + 14.4, epsilon: _eps),
      );
    },
  );

  testWidgets(
    '9.6 CTA 221 × 46: balão 18 + 8 + "Abrir discussão" + 8 + badge 20 × 20, grupo centralizado nas duas direções',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final cta = _rel(tester, 'club.cta');
      final icon = _rel(tester, 'club.cta.icon');
      final label = _rel(tester, 'club.cta.label');
      final badge = _rel(tester, 'club.cta.badge');
      expect(cta.size, const Size(221, 46));
      expect(icon.size, const Size(18, 18));
      expect(badge.size, const Size(20, 20));
      expect(label.width, moreOrLessEquals(98.63, epsilon: _textW));
      expect(label.height, moreOrLessEquals(16.8, epsilon: _eps));
      expect(label.left - icon.right, moreOrLessEquals(8, epsilon: 1e-9));
      expect(badge.left - label.right, moreOrLessEquals(8, epsilon: 1e-9));
      expect(
        icon.left - cta.left,
        moreOrLessEquals(cta.right - badge.right, epsilon: 1e-9),
      );
      for (final (name, r) in [
        ('ícone', icon),
        ('rótulo', label),
        ('badge', badge),
      ]) {
        expect(
          r.center.dy,
          moreOrLessEquals(cta.center.dy, epsilon: 1e-9),
          reason: name,
        );
      }
      // O "3" (6,11 de largura) centralizado no mínimo de 20.
      final three = _textIn(tester, 'club.cta.badge');
      expect(three.center.dx, moreOrLessEquals(badge.center.dx, epsilon: 1e-9));
      expect(three.width, lessThan(20 - 12));

      // Estrutura: Pressable(link) > NeoBox(club.cta, 46) > Row(center, gap 8)[AppSvg, AppText, Semantics > CountBadge].
      final link = _parentOf<Pressable>(tester, 'club.cta');
      expect(link.isLink, isTrue);
      expect(link.semanticsLabel, isNull);
      final neo = tester.widget<NeoBox>(find.byKey(const ValueKey('club.cta')));
      expect(neo.height, 46);
      final row = neo.child! as Row;
      expect(row.mainAxisAlignment, MainAxisAlignment.center);
      expect(row.crossAxisAlignment, CrossAxisAlignment.center);
      expect(row.spacing, 8);
      expect(row.children, hasLength(3));
      expect(row.children[0], isA<AppSvg>());
      expect(row.children[1].key, const ValueKey('club.cta.label'));
      final badgeSemantics = row.children[2] as Semantics;
      expect(badgeSemantics.child, isA<CountBadge>());
      expect(badgeSemantics.child!.key, const ValueKey('club.cta.badge'));
    },
  );

  testWidgets(
    '9.7 canhoto: padding 18 8 + borda 1,5 → caixa 74,5 × 227,6; coluna gap 12 = 12 + 12 + 68,7 + 12 + 26,6 = 131,3 centrada (topo em 67,65) e cada item centrado em x = 303,25',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final stub = _rel(tester, 'club.stub');
      final label = _rel(tester, 'club.stub.label');
      final date = _rel(tester, 'club.stub.date');
      final time = _rel(tester, 'club.stub.time');
      // Caixa de conteúdo MEDIDA: o Center dentro do padding (borda 1,5 + 8 à esquerda, 8 à direita, 18 em
      // cima e embaixo).
      final content = tester
          .getRect(
            find.descendant(
              of: find.byKey(const ValueKey('club.stub')),
              matching: find.byType(Center),
            ),
          )
          .shift(-_rect(tester, 'club').topLeft);
      expect(content.left - stub.left, 1.5 + 8);
      expect(stub.right - content.right, 8);
      expect(content.top - stub.top, 18);
      expect(stub.bottom - content.bottom, moreOrLessEquals(18, epsilon: 1e-9));
      expect(content.width, 74.5);
      expect(content.height, moreOrLessEquals(227.6, epsilon: _eps));
      expect(content.center.dx, moreOrLessEquals(303.25, epsilon: 1e-9));
      final heights = [label.height, date.height, time.height];
      for (final (i, h) in [12.0, 68.7, 26.6].indexed) {
        expect(heights[i], moreOrLessEquals(h, epsilon: _eps), reason: '$i');
      }
      expect(date.top - label.bottom, moreOrLessEquals(12, epsilon: 1e-9));
      expect(time.top - date.bottom, moreOrLessEquals(12, epsilon: 1e-9));
      final block = time.bottom - label.top;
      expect(block, moreOrLessEquals(131.3, epsilon: _eps));
      // Centrado na vertical: sobra igual em cima e embaixo.
      expect(
        label.top - content.top,
        moreOrLessEquals(content.bottom - time.bottom, epsilon: 1e-9),
      );
      expect(label.top, moreOrLessEquals(67.65, epsilon: _eps));
      // Cada item (e cada linha da data) centrado na horizontal.
      for (final id in [
        'club.stub.label',
        'club.stub.date',
        'club.stub.weekday',
        'club.stub.day',
        'club.stub.month',
        'club.stub.time',
      ]) {
        expect(
          _rel(tester, id).center.dx,
          moreOrLessEquals(content.center.dx, epsilon: 1e-9),
          reason: id,
        );
      }
      // A data: coluna da largura do "24" (48,24), QUI · 24 · SET empilhados sem gap.
      final weekday = _rel(tester, 'club.stub.weekday');
      final day = _rel(tester, 'club.stub.day');
      final month = _rel(tester, 'club.stub.month');
      expect(date.width, day.width);
      expect(weekday.top, date.top);
      expect(day.top, moreOrLessEquals(weekday.bottom, epsilon: 1e-9));
      expect(month.top, moreOrLessEquals(day.bottom, epsilon: 1e-9));
      expect(month.bottom, moreOrLessEquals(date.bottom, epsilon: 1e-9));
      expect(day.height, moreOrLessEquals(42 * 0.95, epsilon: _eps));
      // Pílula "20h": texto + padding 10 + borda 1,5 dos dois lados.
      final hour = _textIn(tester, 'club.stub.time');
      expect(time.width - hour.width, moreOrLessEquals(23, epsilon: 1e-9));
      expect(time.height - hour.height, moreOrLessEquals(11, epsilon: 1e-9));
      expect(time.width, moreOrLessEquals(46.36, epsilon: _textW));

      // Estrutura: SizedBox(92) > Semantics > ColoredBox > Stack[Positioned(perfuração), Padding(9,5 18 8 18) >
      // Center > Column(min, gap 12, centro)].
      final padding = tester.widget<Padding>(
        find
            .ancestor(
              of: find.byKey(const ValueKey('club.stub.label')),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(padding.padding, const EdgeInsets.fromLTRB(9.5, 18, 8, 18));
      final center = padding.child! as Center;
      final column = center.child! as Column;
      expect(column.mainAxisSize, MainAxisSize.min);
      expect(column.spacing, 12);
      expect(column.crossAxisAlignment, CrossAxisAlignment.center);
      expect(column.children.map((w) => w.key), [
        const ValueKey('club.stub.label'),
        const ValueKey('club.stub.date'),
        const ValueKey('club.stub.time'),
      ]);
    },
  );
}
