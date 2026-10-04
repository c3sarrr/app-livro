import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/home/application/formatters.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/sections/book_club_ticket.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/home_mock_repository.dart';
import '../reference/reference_layout.dart';
import '../support/canvas.dart';
import '../support/geometry.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';
import '../support/text_lines.dart';

/// Todos os textos da seção, na ordem da tabela "Linhas de texto" da F09 (`club.title.serif` é o trecho
/// inline da 2ª linha de `club.title`: mesma linha, conferida em `club.title`).
const _textIds = [
  'club.pill',
  'club.avatar0',
  'club.avatar1',
  'club.avatar2',
  'club.avatar3',
  'club.title',
  'club.subtitle',
  'club.youMarker',
  'club.groupLabel',
  'club.youLabel',
  'club.cta.label',
  'club.cta.badge',
  'club.stub.label',
  'club.stub.weekday',
  'club.stub.day',
  'club.stub.month',
  'club.stub.time',
];

/// Linhas da tabela da F09 (relativas à seção): texto, baseline, início, fim e largura.
const _tableLines = <String, List<(String, double, double, double, double)>>{
  'club.pill': [('Clube do livro', 37.4, 31, 107.38, 76.38)],
  'club.avatar0': [('A', 37.05, 169.57, 177.43, 7.86)],
  'club.avatar1': [('J', 37.05, 188.46, 194.54, 6.08)],
  'club.avatar2': [('L', 37.05, 206.55, 212.45, 5.9)],
  'club.avatar3': [('+8', 36.7, 221.28, 233.72, 12.44)],
  'club.title': [
    ('Leitoras de', 79.16, 19.5, 132.48, 112.98),
    ('Capitu', 112.24, 19.5, 105.91, 86.41),
  ],
  'club.subtitle': [
    ('Dom Casmurro · até o cap. 100', 135.45, 19.5, 199.51, 180.01),
  ],
  'club.youMarker': [('M', 162.33, 151.25, 161.79, 10.54)],
  'club.groupLabel': [('Grupo em 54%', 184.1, 19.5, 100.62, 81.12)],
  'club.youLabel': [('Você em 62%', 184.1, 165.62, 240.5, 74.88)],
  'club.cta.label': [('Abrir discussão', 229, 79.69, 178.31, 98.62)],
  'club.cta.badge': [('3', 227.95, 193.26, 199.37, 6.11)],
  'club.stub.label': [('ENCONTRO', 77.15, 270.94, 335.56, 64.62)],
  'club.stub.weekday': [('QUI', 103.05, 291.12, 315.38, 24.26)],
  'club.stub.day': [('24', 139.86, 279.13, 327.37, 48.24)],
  'club.stub.month': [('SET', 157.35, 291.13, 315.37, 24.24)],
  'club.stub.time': [('20h', 190.2, 291.57, 314.93, 23.36)],
};

Offset _sectionOrigin(WidgetTester tester) =>
    tester.getTopLeft(find.byKey(const ValueKey('club')));

List<AppText> _textWidgets(WidgetTester tester, String id) => tester
    .widgetList<AppText>(
      find.descendant(
        of: find.byKey(ValueKey<String>(id)),
        matching: find.byType(AppText),
        matchRoot: true,
      ),
    )
    .toList();

/// Texto puro do único `AppText` sob [id].
String _textOf(WidgetTester tester, String id) =>
    _textWidgets(tester, id).single.span.toPlainText();

List<RenderAppText> _rendersOf(WidgetTester tester, String id) => [
  for (final e
      in find
          .descendant(
            of: find.byKey(ValueKey<String>(id)),
            matching: find.byType(AppText),
            matchRoot: true,
          )
          .evaluate())
    e.renderObject! as RenderAppText,
];

/// Dados que a seção lê (o mesmo `homeSnapshotProvider` do app montado).
BookClub _clubData(WidgetTester tester) => ProviderScope.containerOf(
  tester.element(find.byType(BookClubTicket)),
  listen: false,
).read(homeSnapshotProvider).club;

String _f(double v) => v.toStringAsFixed(3);

/// F09 — camada 4 (texto) da seção `club`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F09 texto: quebras, baselines e extensões dos 17 textos da seção (título em 2 linhas: "Leitoras de" / "Capitu")',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final id in _textIds) {
        expectTextLines(tester, id);
        reportTextLines(tester, id);
      }
      // O trecho inline do itálico é a 2ª linha do título.
      final serif = kRefLayout['club.title']!.lines[1];
      expect(serif.text, 'Capitu');
      expect(serif.baseline, 1686.8);
      expect(kRefLayout['club.title']!.lines.first.baseline, 1653.72);
    },
  );

  testWidgets(
    'a tabela "Linhas de texto" da F09 (relativa à seção) é a mesma referência — e o Flutter fica a ≤ 0,05 px dela',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      // Origem da seção na especificação (x=20, y=1574,56) = retângulo `club` do JSON do arquivo.
      final refOrigin = kRefLayout['club']!.rect.topLeft;
      expect(refOrigin, const Offset(20, 1574.56));
      final origin = _sectionOrigin(tester);
      expect(origin.dx, 20);
      expect(origin.dy, moreOrLessEquals(1574.56, epsilon: 1e-3));
      expect(_tableLines.keys.toList(), _textIds);
      var worst = ('', 0.0);
      for (final MapEntry(key: id, value: lines) in _tableLines.entries) {
        final ref = kRefLayout[id]!.lines;
        final renders = _rendersOf(tester, id)
          ..sort(
            (a, b) => a
                .localToGlobal(Offset.zero)
                .dy
                .compareTo(b.localToGlobal(Offset.zero).dy),
          );
        final got = [for (final r in renders) ...r.debugLines()];
        expect(got, hasLength(lines.length), reason: id);
        expect(ref, hasLength(lines.length), reason: id);
        for (final (i, (text, baseline, left, right, width)) in lines.indexed) {
          // Tabela da fase = JSON do arquivo menos a origem da seção (2 casas decimais nos dois).
          expect(ref[i].text, text, reason: '$id L${i + 1}');
          expect(
            ref[i].baseline - refOrigin.dy,
            moreOrLessEquals(baseline, epsilon: 1e-6),
            reason: '$id L${i + 1} baseline (tabela)',
          );
          expect(
            ref[i].left - refOrigin.dx,
            moreOrLessEquals(left, epsilon: 1e-6),
            reason: '$id L${i + 1} início (tabela)',
          );
          expect(
            ref[i].right - refOrigin.dx,
            moreOrLessEquals(right, epsilon: 1e-6),
            reason: '$id L${i + 1} fim (tabela)',
          );
          // A tabela arredonda largura e extremos separadamente (ex.: "Abrir discussão" 98,62 × 178,31 − 79,69).
          expect(
            right - left,
            moreOrLessEquals(width, epsilon: 0.011),
            reason: '$id L${i + 1} largura (tabela)',
          );
          expect(got[i].text, text, reason: '$id L${i + 1}');
          final deltas = [
            ('baseline', got[i].baseline - origin.dy - baseline),
            ('início', got[i].left - origin.dx - left),
            ('fim', got[i].right - origin.dx - right),
            ('largura', got[i].right - got[i].left - (right - left)),
          ];
          debugPrint(
            '[tabela] $id L${i + 1} "$text": '
            '${deltas.map((d) => 'Δ ${d.$1} ${_f(d.$2)}').join(' | ')}',
          );
          for (final (what, d) in deltas) {
            if (d.abs() > worst.$2.abs()) worst = ('$id L${i + 1} $what', d);
            // O gate da §7 é ±0,5 (expectTextLines, 1º teste); aqui o desvio medido, bem menor.
            expect(
              d.abs(),
              lessThanOrEqualTo(0.05),
              reason: '$id L${i + 1} $what',
            );
          }
        }
      }
      debugPrint('[tabela] maior desvio: ${worst.$1} = ${_f(worst.$2)}');
    },
  );

  testWidgets(
    'strings exatas do arquivo, derivadas dos dados; um trecho por AppText, nada de "\\n", uma linha cada (o título são 2 AppText)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final club = _clubData(tester);
      final expected = {
        'club.pill': ['Clube do livro'],
        'club.avatar0': ['A'],
        'club.avatar1': ['J'],
        'club.avatar2': ['L'],
        'club.avatar3': ['+8'],
        'club.title': ['Leitoras de', 'Capitu'],
        'club.subtitle': ['Dom Casmurro · até o cap. 100'],
        'club.youMarker': ['M'],
        'club.groupLabel': ['Grupo em 54%'],
        'club.youLabel': ['Você em 62%'],
        'club.cta.label': ['Abrir discussão'],
        'club.cta.badge': ['3'],
        'club.stub.label': ['ENCONTRO'],
        'club.stub.weekday': ['QUI'],
        'club.stub.day': ['24'],
        'club.stub.month': ['SET'],
        'club.stub.time': ['20h'],
      };
      expect(expected.keys.toList(), _textIds);
      for (final MapEntry(key: id, value: texts) in expected.entries) {
        final widgets = _textWidgets(tester, id);
        expect(widgets, hasLength(texts.length), reason: id);
        for (final (i, w) in widgets.indexed) {
          final span = w.span as TextSpan;
          expect(span.children, isNull, reason: id);
          expect(span.text, texts[i], reason: id);
          expect(span.text!.contains('\n'), isFalse, reason: id);
          expect((w.maxLines, w.ellipsis), (null, false), reason: id);
        }
        for (final r in _rendersOf(tester, id)) {
          expect(r.debugLines(), hasLength(1), reason: id);
          expect(r.debugDidExceedMaxLines, isFalse, reason: id);
        }
      }
      expect(kEllipsized.where((id) => id.startsWith('club.')), isEmpty);

      // Derivados dos dados pelos formatadores (F02 / F09).
      final title = _textWidgets(tester, 'club.title');
      expect(title[0].span.toPlainText(), club.namePrefix);
      expect(title[1].span.toPlainText(), club.nameHighlight);
      expect(
        _textOf(tester, 'club.subtitle'),
        HomeFormatters.clubSubtitle(club.book, club.untilChapter),
      );
      for (final (i, p) in club.shownParticipants.indexed) {
        expect(_textOf(tester, 'club.avatar$i'), p.initial);
      }
      expect(
        _textOf(tester, 'club.avatar3'),
        HomeFormatters.participantsExtra(
          club.participantsCount,
          club.shownParticipants.length,
        ),
      );
      expect(_textOf(tester, 'club.youMarker'), club.userInitial);
      expect(
        _textOf(tester, 'club.groupLabel'),
        HomeFormatters.groupProgressLabel(club.groupProgress),
      );
      expect(
        _textOf(tester, 'club.youLabel'),
        HomeFormatters.userProgressLabel(club.userProgress),
      );
      expect(_textOf(tester, 'club.cta.badge'), '${club.unreadMessages}');
      expect(
        _textOf(tester, 'club.stub.weekday'),
        HomeFormatters.weekdayShort(club.nextMeeting),
      );
      expect(
        _textOf(tester, 'club.stub.day'),
        HomeFormatters.day(club.nextMeeting),
      );
      expect(
        _textOf(tester, 'club.stub.month'),
        HomeFormatters.monthShort(club.nextMeeting),
      );
      expect(
        _textOf(tester, 'club.stub.time'),
        HomeFormatters.hourLabel(club.nextMeeting),
      );
      // "·" = U+00B7 com espaços dos dois lados.
      final dot = String.fromCharCode(0x00B7);
      expect(_textOf(tester, 'club.subtitle'), contains(' $dot '));
    },
  );

  testWidgets(
    '9.3 nowrap: a pílula "Clube do livro" é diagramada sem limite de largura (filho não flexível da Row) — não há largura em que quebre',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final render = _rendersOf(tester, 'club.pill').single;
      expect(render.constraints.maxWidth, double.infinity);
      expect(render.constraints.hasTightWidth, isFalse);
      final line = render.debugLines().single;
      expect(line.text, 'Clube do livro');
      // O texto mede a largura natural inteira (76,38 no arquivo).
      expect(render.size.width, moreOrLessEquals(76.38, epsilon: 0.05));
      expect(render.getMaxIntrinsicWidth(double.infinity), render.size.width);
    },
  );

  testWidgets(
    'textos derivados dos dados: com outro clube mudam nome, subtítulo, avatares ("+N"), legendas, badge e o canhoto — visíveis e acessíveis; o preenchimento e o marcador seguem os percentuais',
    (tester) async {
      final semantics = tester.ensureSemantics();
      setCanvasView(tester);
      final base = const HomeMockRepository().snapshot(
        HomeMockRepository.referenceNow,
      );
      final club = BookClub(
        id: 'teste',
        namePrefix: 'Amigas de',
        nameHighlight: 'Rita',
        book: HomeMockRepository.senhora,
        untilChapter: 12,
        shownParticipants: const [
          ClubParticipant(initial: 'B', color: AppColors.sun),
          ClubParticipant(initial: 'C', color: AppColors.lavender),
          ClubParticipant(initial: 'D', color: AppColors.leaf),
        ],
        participantsCount: 5,
        groupProgress: 0.3,
        userProgress: 0.45,
        userInitial: 'R',
        unreadMessages: 12,
        // Sexta-feira, 2 de outubro, 19h30.
        nextMeeting: DateTime(2026, 10, 2, 19, 30),
      );
      await pumpApp(
        tester,
        overrides: [
          homeSnapshotProvider.overrideWithValue(
            HomeSnapshot(
              now: base.now,
              user: base.user,
              continueReading: base.continueReading,
              alsoReading: base.alsoReading,
              readingDay: base.readingDay,
              forYou: base.forYou,
              club: club,
              recent: base.recent,
            ),
          ),
        ],
      );
      expect(_clubData(tester), same(club));
      final title = _textWidgets(tester, 'club.title');
      expect(title.map((w) => w.span.toPlainText()), ['Amigas de', 'Rita']);
      expect(_textOf(tester, 'club.subtitle'), 'Senhora · até o cap. 12');
      expect(
        [for (var i = 0; i < 4; i++) _textOf(tester, 'club.avatar$i')],
        ['B', 'C', 'D', '+2'],
      );
      expect(
        [
          for (var i = 0; i < 4; i++)
            tester
                .widget<NeoBox>(find.byKey(ValueKey('club.avatar$i')))
                .color!
                .toARGB32(),
        ],
        [0xFFFED170, 0xFFB6ACE4, 0xFFABCF82, 0xFFFFFAF1],
      );
      expect(_textOf(tester, 'club.youMarker'), 'R');
      expect(_textOf(tester, 'club.groupLabel'), 'Grupo em 30%');
      expect(_textOf(tester, 'club.youLabel'), 'Você em 45%');
      expect(_textOf(tester, 'club.cta.badge'), '12');
      expect(_textOf(tester, 'club.stub.weekday'), 'SEX');
      expect(_textOf(tester, 'club.stub.day'), '2');
      expect(_textOf(tester, 'club.stub.month'), 'OUT');
      expect(_textOf(tester, 'club.stub.time'), '19h30');

      // Geometria que depende dos dados: 30 % de 218 e o centro do marcador em 45 % de 221.
      final track = tester.getRect(
        find.byKey(const ValueKey('club.progressTrack')),
      );
      final fill = tester.getRect(
        find.byKey(const ValueKey('club.progressFill')),
      );
      final marker = tester.getRect(
        find.byKey(const ValueKey('club.youMarker')),
      );
      expect(fill.width, moreOrLessEquals(0.3 * 218, epsilon: 1e-9));
      expect(
        marker.center.dx,
        moreOrLessEquals(track.left + 0.45 * 221, epsilon: 1e-9),
      );
      // "12" não cabe no mínimo de 20 com o padding 6: o badge cresce (min-width), continua centrado no CTA.
      final badge = tester.getRect(
        find.byKey(const ValueKey('club.cta.badge')),
      );
      expect(badge.width, greaterThan(20));
      expect(badge.height, 20);
      // A seção mantém a altura do arquivo (nada quebra linha).
      final section = tester.getRect(find.byKey(const ValueKey('club')));
      expect(section.height, moreOrLessEquals(266.6, epsilon: 1e-3));
      expectGeometry(tester, ['club.stub', 'club.cta', 'club.body']);

      // Os textos acessíveis também saem dos dados (nome do clube, participantes, progresso, mensagens e o
      // encontro), não do arquivo.
      SemanticsNode node(String id) =>
          tester.getSemantics(find.byKey(ValueKey<String>(id)));
      final heading = node('club.title');
      expect(heading.label, 'Amigas de Rita');
      expect(heading.flagsCollection.isHeader, isTrue);
      expect(node('club.avatars').label, '5 participantes');
      final bar = node('club.progressBar');
      expect((bar.label, bar.value), ('Progresso do grupo', '30%'));
      expect(node('club.youMarker').label, 'Você');
      expect(node('club.cta.badge').label, '12 mensagens novas');
      expect(
        node('club.stub.label').label,
        'Próximo encontro: sexta, 2 de outubro, às 19h30',
      );
      semantics.dispose();
    },
  );
}
