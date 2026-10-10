// T03.8 — fase L01a3 ("Também lendo") contra a prancha 01 (`kRef01`) e as larguras 360/430: o Brás Cubas de papel
// sem página (a capa da cartola, o "play" sem ação e "Papel · 3h 40min") e o Orgulho e Preconceito de papel na
// pág. 344 (o anel de 81 % e "Papel · pág. 344") — D-252/D-253. A seção mudou no lugar: com dois e-books (os dados
// da v1) desenha a v1. Recorte do gate visual: y 554,96–776,77 (`docs/design/fases/L01a3_tambem_lendo.md`).
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/painters/ring_progress_painter.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_inicio.dart';
import 'package:app_leitura/core/design_system/tokens/app_radii.dart';
import 'package:app_leitura/core/design_system/tokens/app_shadows.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/circle_icon_button.dart';
import 'package:app_leitura/core/design_system/widgets/count_badge.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pill.dart';
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/home/presentation/sections/also_reading_section.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/home_mock_repository.dart';
import '../../fixtures/telas/inicio01.dart';
import '../../reference/inicio2/referencias_inicio2.dart';
import '../../reference/inicio2_larguras/referencias_inicio2_larguras.dart';
import '../../support/app_text_finder.dart';
import '../../support/fase_inicio.dart';
import '../../support/load_fonts.dart';

const _secoes = ['i01.alsoReading'];

/// A fixture `t01` com outros livros em "Também lendo" (os casos da D-253 fora da prancha).
final class _ComLivros implements SyncHomeRepository {
  const _ComLivros(this.livros);

  final List<AlsoReadingItem> livros;

  @override
  HomeSnapshot snapshot(DateTime now) {
    final s = TelaInicio01.snapshot(now);
    return HomeSnapshot(
      now: s.now,
      user: s.user,
      continueReading: s.continueReading,
      alsoReading: livros,
      readingDay: s.readingDay,
      dailyReview: s.dailyReview,
      forYou: s.forYou,
      club: s.club,
      recent: s.recent,
    );
  }

  @override
  Stream<HomeSnapshot> watch(DateTime Function() clock) => const Stream.empty();
}

AlsoReadingItem _item(
  int i, {
  required BookFormat format,
  int? paperPage,
  Duration? readTime,
}) {
  final base = TelaInicio01.tambemLendo[i];
  return AlsoReadingItem(
    book: base.book,
    progress: base.progress,
    format: format,
    paperPage: paperPage,
    readTime: readTime,
  );
}

Future<void> _abrir(
  WidgetTester tester, {
  LeitorRefPrancha prancha = kRef01,
  List<AlsoReadingItem>? livros,
}) => abrirInicio01(
  tester,
  prancha: prancha,
  repositorio: livros == null ? const HomeMockRepository() : _ComLivros(livros),
);

/// Voltar do sistema: fecha a rota do topo (de volta à Início).
Future<void> _voltar(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

/// A largura natural de [texto] no estilo do título dos cartões (Figtree 15/700).
double _largura(String texto) {
  final p =
      (ui.ParagraphBuilder(
              AppTextStyles.title15.getParagraphStyle(
                textHeightBehavior: const TextHeightBehavior(
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
            )
            ..pushStyle(AppTextStyles.title15.getTextStyle())
            ..addText(texto))
          .build()
        ..layout(const ui.ParagraphConstraints(width: double.infinity));
  final w = p.maxIntrinsicWidth;
  p.dispose();
  return w;
}

T _w<T extends Widget>(WidgetTester tester, String id) =>
    tester.widget<T>(ini(id));

/// A arte da capa (o filho do giro, `<id>#rot`): a NeoBox de fora.
NeoBox _capa(WidgetTester tester, String id) => tester.widget<NeoBox>(
  find
      .descendant(
        of: find.byKey(ValueKey('${keyDoId(id)}#rot')),
        matching: find.byType(NeoBox),
      )
      .first,
);

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'L01a3 geometria: os 33 ids (as capas giradas −4°/+3°: layout e caixa visual)',
    (tester) async {
      await _abrir(tester);
      expect(idsDasSecoes(kRef01, _secoes), hasLength(33));
      expect(geometria01(tester, _secoes), isEmpty);
    },
  );

  testWidgets('L01a3 texto: título, "3", "Brás / Cubas", "Orgulho e / Preconceito", "81%", títulos, autores e as '
      'pílulas "Papel · …" nas baselines da prancha', (tester) async {
    await _abrir(tester);
    expect(texto01(tester, _secoes), isEmpty);
  });

  for (final tela in ['01w360', '01w430']) {
    testWidgets(
      'L01a3 a ${tela.substring(3)} px: geometria e texto da prancha medida nessa largura',
      (tester) async {
        final ref = kRefInicio2Larguras[tela]!;
        await _abrir(tester, prancha: ref);
        expect(geometria01(tester, _secoes, prancha: ref), isEmpty);
        expect(texto01(tester, _secoes, prancha: ref), isEmpty);
      },
    );
  }

  for (final (prancha, largura, visivel) in [
    (kRef01, 138.0, 'Orgulho e Precon'),
    (kRefInicio2Larguras['01w360']!, 123.0, 'Orgulho e Preco'),
  ]) {
    testWidgets(
      'L01a3 reticências em $largura: "Orgulho e Preconceito" vira "$visivel…" — o maior prefixo com o "…" que '
      'cabe (a regra do text-overflow do navegador)',
      (tester) async {
        await _abrir(tester, prancha: prancha);
        final r = tester.renderObject<RenderAppText>(
          find.byKey(const ValueKey('alsoReading.card2.title')),
        );
        expect(r.size.width, largura);
        expect(r.debugDidExceedMaxLines, isTrue);
        final linha = r.debugLines().single;
        expect(linha.text, visivel);
        final pintada = linha.right - linha.left;
        expect(pintada, moreOrLessEquals(_largura('$visivel…'), epsilon: 0.01));
        expect(pintada, lessThanOrEqualTo(largura));
        final mais = 'Orgulho e Preconceito'.substring(0, visivel.length + 1);
        expect(_largura('$mais…'), greaterThan(largura));
        // os outros textos dos cartões cabem inteiros
        for (final k in [
          'alsoReading.card1.title',
          'alsoReading.card1.author',
          'alsoReading.card2.author',
        ]) {
          expect(
            tester
                .renderObject<RenderAppText>(find.byKey(ValueKey(k)))
                .debugDidExceedMaxLines,
            isFalse,
            reason: k,
          );
        }
      },
    );
  }

  testWidgets('L01a3 cabeçalho e cartões: Bricolage 18, contador tinta 22 com "3"; cartões #FFFAF1, borda 1,5, '
      'raio 22, padding 0/14/14, sem sombra', (tester) async {
    await _abrir(tester);
    expect(
      _w<AppText>(tester, 'i01.alsoReading.title').span.style,
      AppTextStyles.sectionTitleS,
    );
    final count = _w<CountBadge>(tester, 'i01.alsoReading.count');
    expect(count.label, '${TelaInicio01.tambemLendo.length}');
    expect(count.label, '3');
    expect(
      (count.minWidth, count.height, count.horizontalPadding),
      (22.0, 22.0, 7.0),
    );
    expect(
      (count.background, count.style),
      (AppColors.ink, AppTextStyles.count12OnInk),
    );
    for (final c in ['i01.alsoReading.card1', 'i01.alsoReading.card2']) {
      final card = _w<NeoBox>(tester, c);
      expect(card.color, AppColors.surface);
      expect(card.border, const BorderSide(width: 1.5, color: AppColors.ink));
      expect(card.radius, BorderRadius.circular(22));
      expect(card.padding, const EdgeInsets.fromLTRB(14, 0, 14, 14));
      expect(card.shadow, isNull);
      expect(card.clip, isFalse);
    }
  });

  testWidgets(
    'L01a3 capa do Brás Cubas: 54 × 81 #058CD7, raio 3/7/7/3, borda 1,5, sombra 2/2, −4°; lombada '
    '.18, copa 18 × 16 (raio 2/2/0/0), aba elíptica 28 × 5 e "Brás / Cubas" Instrument Serif 11 #FED170',
    (tester) async {
      await _abrir(tester);
      final capa = _capa(tester, 'i01.alsoReading.card1.cover');
      expect(
        (capa.width, capa.height, capa.color),
        (54.0, 81.0, AppColors.azure),
      );
      expect(AppColors.azure, const Color(0xFF058CD7));
      expect(capa.radius, AppRadii.coverS);
      expect(capa.border, const BorderSide(width: 1.5, color: AppColors.ink));
      expect((capa.shadow, capa.clip), (AppShadows.hard2, true));
      expect(
        _w<NeoBox>(tester, 'i01.alsoReading.card1.cover.spine').color,
        AppColors.spine18,
      );
      expect(AppColors.spine18, const Color(0x2E000000)); // rgba(0,0,0,.18)
      final copa = _w<NeoBox>(tester, 'i01.alsoReading.card1.cover.hat');
      expect(
        (copa.width, copa.height, copa.color),
        (18.0, 16.0, AppColors.ink),
      );
      expect(
        copa.radius,
        const BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
        ),
      );
      final aba = _w<NeoBox>(tester, 'i01.alsoReading.card1.cover.brim');
      expect((aba.width, aba.height, aba.color), (28.0, 5.0, AppColors.ink));
      expect(aba.radius, const BorderRadius.all(Radius.elliptical(14, 2.5)));
      final titulo = _w<AppText>(tester, 'i01.alsoReading.card1.cover.title');
      expect(titulo.span.toPlainText(), 'Brás\nCubas');
      final s = titulo.span.style!;
      expect(s, AppTextStyles.coverTitle11Sun);
      expect(
        (s.fontFamily, s.fontSize, s.height, s.color),
        ('InstrumentSerif', 11.0, 0.95, AppColors.sun),
      );
    },
  );

  testWidgets(
    'L01a3 capa do Orgulho (a da v1): #FFC1C6, +3°, lombada .12, círculo 20 e o título 9',
    (tester) async {
      await _abrir(tester);
      final capa = _capa(tester, 'i01.alsoReading.card2.cover');
      expect(
        (capa.width, capa.height, capa.color),
        (54.0, 81.0, AppColors.blush),
      );
      expect(
        _w<NeoBox>(tester, 'i01.alsoReading.card2.cover.spine').color,
        AppColors.spine12,
      );
      expect(
        _w<AppText>(tester, 'i01.alsoReading.card2.cover.title').span.style,
        AppTextStyles.coverTitle9,
      );
    },
  );

  testWidgets('L01a3 "play": círculo 46 tinta com borda 1,5 e o triângulo amarelo 18; anel 46 de 81 % com '
      '"81%" Figtree 11/800 → 700', (tester) async {
    await _abrir(tester);
    final play = _w<CircleIconButton>(tester, 'i01.alsoReading.card1.play');
    expect((play.size, play.color), (46.0, AppColors.ink));
    expect(play.border, const BorderSide(width: 1.5, color: AppColors.ink));
    final icone = _w<AppSvg>(tester, 'i01.alsoReading.card1.play.icon');
    expect((icone.asset, icone.size), (AppIconsInicio.play, 18.0));
    final anel = tester.widget<CustomPaint>(
      ini('i01.alsoReading.card2.ring.svg'),
    );
    expect(
      (anel.painter! as RingProgressPainter).progress,
      TelaInicio01.tambemLendo[1].progress,
    );
    expect(findAppText('81%'), findsOneWidget);
    expect(
      appText01(tester, 'i01.alsoReading.card2.ring.label').span.style,
      AppTextStyles.micro11Bold,
    );
  });

  testWidgets('L01a3 pílulas "Papel": #F7F0E3, borda 1,2 #E2D7C4, padding 3/8/3/6, livro de papel 12 + Figtree '
      '11,5/700 com gap 4', (tester) async {
    await _abrir(tester);
    for (final (c, texto) in [
      ('i01.alsoReading.card1.meta', 'Papel · 3h 40min'),
      ('i01.alsoReading.card2.meta', 'Papel · pág. 344'),
    ]) {
      final p = _w<Pill>(tester, c);
      expect(p.color, AppColors.paper);
      expect(
        p.border,
        const BorderSide(width: 1.2, color: AppColors.markerRowBorder),
      );
      expect(AppColors.markerRowBorder, const Color(0xFFE2D7C4));
      expect(p.padding, const EdgeInsets.fromLTRB(6, 3, 8, 3));
      final icone = _w<AppSvg>(tester, '$c.icon');
      expect((icone.asset, icone.size), (AppIconsInicio.bookPaper, 12.0));
      final t = appText01(tester, c, 'Papel');
      expect(t.span.toPlainText(), texto);
      final s = t.span.style!;
      expect(s, AppTextStyles.paperMeta);
      expect(
        (s.fontFamily, s.fontSize, s.fontWeight),
        ('Figtree', 11.5, FontWeight.w700),
      );
    }
  });

  testWidgets(
    'L01a3 dados: o tempo já lido do Brás Cubas e a página do Orgulho saem da fixture t01 (D-252/D-253)',
    (tester) async {
      final [bras, orgulho, dalloway] = TelaInicio01.tambemLendo;
      expect(
        (bras.format, bras.paperPage, bras.readTime),
        (BookFormat.physical, null, TelaInicio01.brasCubasJaLido),
      );
      expect((orgulho.format, orgulho.paperPage), (BookFormat.physical, 344));
      expect(dalloway.format, BookFormat.epub);
      expect(bras.book.title, 'Memórias Póstumas de Brás Cubas');
      expect(bras.book.shortTitle, 'Brás Cubas');
    },
  );

  testWidgets('D-253: e-book → anel sem pílula; papel com página → anel + "Papel · pág. N"; papel sem página e '
      'sem sessão → "play" + "Papel"', (tester) async {
    await _abrir(
      tester,
      livros: [
        _item(0, format: BookFormat.physical),
        _item(1, format: BookFormat.epub),
      ],
    );
    expect(
      find.byKey(const ValueKey('alsoReading.card1.play')),
      findsOneWidget,
    );
    expect(findAppText('Papel'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('alsoReading.card2.ring')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('alsoReading.card2.meta')), findsNothing);
    // a grade estica os dois cartões à altura do mais alto (display: grid)
    expect(
      tester.getSize(ini('i01.alsoReading.card1')).height,
      tester.getSize(ini('i01.alsoReading.card2')).height,
    );
    await _abrir(
      tester,
      livros: [
        _item(0, format: BookFormat.physical, paperPage: 12),
        _item(1, format: BookFormat.pdf),
      ],
    );
    expect(find.byKey(const ValueKey('alsoReading.card1.play')), findsNothing);
    expect(
      find.byKey(const ValueKey('alsoReading.card1.ring')),
      findsOneWidget,
    );
    expect(findAppText('Papel · pág. 12'), findsOneWidget);
    expect(find.byKey(const ValueKey('alsoReading.card2.meta')), findsNothing);
  });

  testWidgets(
    'D-253 com dois e-books (os dados da v1): o desenho da v1 — sem pílula, cartões de 123,6, os dois links',
    (tester) async {
      await _abrir(
        tester,
        livros: [
          _item(2, format: BookFormat.epub),
          _item(1, format: BookFormat.epub),
        ],
      );
      expect(
        find.descendant(
          of: ini('i01.alsoReading'),
          matching: find.byType(Pill),
        ),
        findsNothing,
      );
      expect(
        tester.getSize(ini('i01.alsoReading.card1')).height,
        closeTo(123.6, 1e-3),
      );
      expect(
        find.byKey(const ValueKey('alsoReading.card1.play')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'L01a3 semântica: a seção, o h3, a capa do Brás Cubas é o link "Memórias Póstumas de Brás Cubas", o '
    '"play" é o botão "Iniciar leitura de Brás Cubas", o cartão do Orgulho é link; ícones e anel fora',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _abrir(tester);
      expect(find.semantics.byLabel('Também lendo'), findsAtLeast(1));
      final capa = find.semantics.byLabel('Memórias Póstumas de Brás Cubas');
      expect(capa, findsOneWidget);
      final dCapa = capa.evaluate().single.getSemanticsData();
      expect(dCapa.flagsCollection.isLink, isTrue);
      expect(dCapa.hasAction(SemanticsAction.tap), isTrue);
      final play = noDe(
        tester,
        'i01.alsoReading.card1.play',
      ).getSemanticsData();
      expect(play.label, 'Iniciar leitura de Brás Cubas');
      expect(play.flagsCollection.isButton, isTrue);
      expect(play.hasAction(SemanticsAction.tap), isTrue);
      final card2 = noDe(tester, 'i01.alsoReading.card2').getSemanticsData();
      expect(card2.flagsCollection.isLink, isTrue);
      expect(card2.label, contains('Orgulho e Preconceito'));
      for (final id in [
        'i01.alsoReading.card1.play.icon',
        'i01.alsoReading.card1.meta.icon',
        'i01.alsoReading.card2.meta.icon',
      ]) {
        expect(
          find.descendant(of: ini(id), matching: find.byType(ExcludeSemantics)),
          findsAtLeast(1),
          reason: id,
        );
      }
      expect(
        find.ancestor(
          of: ini('i01.alsoReading.card2.ring.svg'),
          matching: find.byType(ExcludeSemantics),
        ),
        findsAtLeast(1),
      );
      semantics.dispose();
    },
  );

  testWidgets('L01a3 toques: a capa do Brás Cubas e o cartão do Orgulho abrem a página do livro; o "play" fica na '
      'Início (o cronômetro é da T04 — D-243 b)', (tester) async {
    await _abrir(tester);
    expect(
      tester
          .widget<AlsoReadingSection>(find.byType(AlsoReadingSection))
          .onStartReadingTap,
      HomeScreen.onStartReading,
    );
    expect(
      () => HomeScreen.onStartReading(TelaInicio01.brasCubas),
      returnsNormally,
    );
    await tocar01(tester, 'i01.alsoReading.card1.play');
    expect(rotaAtual(tester), '/inicio');
    await tocar01(tester, 'i01.alsoReading.card1.cover');
    expect(rotaAtual(tester), '/livro/memorias-postumas-de-bras-cubas');
    await _voltar(tester);
    await tocar01(tester, 'i01.alsoReading.card2');
    expect(rotaAtual(tester), '/livro/orgulho-e-preconceito');
  });

  testWidgets(
    'L01a3 captura: a seção no canvas da prancha (gate visual fora do teste)',
    (tester) async {
      await _abrir(tester);
      final image = await capturar01(tester, 't03_L01a3');
      expect((image.width, image.height), (1170, 7950));
    },
  );
}
