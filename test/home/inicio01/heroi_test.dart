// T03.7 — fase L01a2 (o herói "Continuar lendo") contra a prancha 01 (`kRef01`) e as larguras 360/430
// (`kRefInicio2Larguras`): a capa nova do Dom Casmurro (o olho e o mar, girada −3°), as pílulas "pág. 159 de 256" e
// "E-BOOK" no lugar do capítulo da v1 e o contador "12". Recorte do gate visual: y 240,16–538,96
// (`docs/design/fases/L01a2_heroi.md`). Formato e página: D-253/D-254.
import 'dart:math' as math;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_inicio.dart';
import 'package:app_leitura/core/design_system/tokens/app_radii.dart';
import 'package:app_leitura/core/design_system/tokens/app_shadows.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/circle_icon_button.dart';
import 'package:app_leitura/core/design_system/widgets/count_badge.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pill.dart';
import 'package:app_leitura/core/design_system/widgets/stadium_progress_bar.dart';
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/covers/dom_casmurro_eye_cover.dart';
import 'package:app_leitura/features/home/presentation/sections/hero_section.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/telas/inicio01.dart';
import '../../reference/inicio2/referencias_inicio2.dart';
import '../../reference/inicio2_larguras/referencias_inicio2_larguras.dart';
import '../../support/app_text_finder.dart';
import '../../support/fase_inicio.dart';
import '../../support/load_fonts.dart';

const _secoes = ['i01.hero'];

/// A fixture `t01` com outro herói (os outros casos da D-253/D-254).
final class _ComHeroi implements SyncHomeRepository {
  const _ComHeroi(this.heroi);

  final ContinueReading? heroi;

  @override
  HomeSnapshot snapshot(DateTime now) {
    final s = TelaInicio01.snapshot(now);
    return HomeSnapshot(
      now: s.now,
      user: s.user,
      continueReading: heroi,
      alsoReading: s.alsoReading,
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

ContinueReading _heroi({
  BookFormat format = BookFormat.epub,
  int? refPage = 159,
  int? refPagesTotal = 256,
}) {
  final c = TelaInicio01.continuarLendo;
  return ContinueReading(
    book: c.book,
    progress: c.progress,
    timeLeft: c.timeLeft,
    highlightsCount: c.highlightsCount,
    format: format,
    refPage: refPage,
    refPagesTotal: refPagesTotal,
  );
}

Future<void> _abrir(
  WidgetTester tester, {
  LeitorRefPrancha prancha = kRef01,
  ContinueReading? heroi,
  bool trocar = false,
  VoidCallback? onContinueTap,
  VoidCallback? onHighlightsTap,
}) => abrirSecoes01(
  tester,
  {
    'i01.hero': HeroSection(
      onContinueTap: onContinueTap,
      onHighlightsTap: onHighlightsTap,
    ),
  },
  prancha: prancha,
  repositorio: trocar ? _ComHeroi(heroi) : const RepositorioT01(),
);

T _w<T extends Widget>(WidgetTester tester, String id) =>
    tester.widget<T>(ini(id));

NeoBox _caixa(WidgetTester tester, String id) => tester.widget<NeoBox>(
  find.descendant(of: ini(id), matching: find.byType(NeoBox)).first,
);

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'L01a2 geometria: os 28 ids do herói (a capa e o desenho girados: layout e caixa visual)',
    (tester) async {
      await _abrir(tester);
      expect(idsDasSecoes(kRef01, _secoes), hasLength(28));
      expect(geometria01(tester, _secoes), isEmpty);
    },
  );

  testWidgets(
    'L01a2 texto: as pílulas, o título, o autor, "62%", "~2h 10min", o CTA e o "12" nas baselines da prancha',
    (tester) async {
      await _abrir(tester);
      expect(texto01(tester, _secoes), isEmpty);
    },
  );

  for (final tela in ['01w360', '01w430']) {
    testWidgets(
      'L01a2 a ${tela.substring(3)} px: geometria e texto da prancha medida nessa largura',
      (tester) async {
        final ref = kRefInicio2Larguras[tela]!;
        await _abrir(tester, prancha: ref);
        expect(geometria01(tester, _secoes, prancha: ref), isEmpty);
        expect(texto01(tester, _secoes, prancha: ref), isEmpty);
      },
    );
  }

  testWidgets(
    'L01a2 a 430 px: as duas pílulas na mesma linha e o selo esticado à altura da linha (27,4)',
    (tester) async {
      await _abrir(tester, prancha: kRefInicio2Larguras['01w430']!);
      final pagina = tester.getRect(ini('i01.hero.pagePill'));
      final selo = tester.getRect(ini('i01.hero.formatPill'));
      expect(selo.top, pagina.top);
      expect(selo.height, closeTo(27.4, 1e-3));
      expect(selo.left - pagina.right, closeTo(6, 1e-3));
    },
  );

  testWidgets(
    'L01a2 estilo do cartão: brand, borda 1,5, raio 28, sombra dura 4/4, recorte; brilhos 30 e 14',
    (tester) async {
      await _abrir(tester);
      final c = _w<NeoBox>(tester, 'i01.hero');
      expect(c.color, AppColors.lavender);
      expect(c.border, const BorderSide(width: 1.5, color: AppColors.ink));
      expect(c.radius, BorderRadius.circular(28));
      expect(c.shadow, AppShadows.hard4);
      expect(c.clip, isTrue);
      final grande = _w<AppSvg>(tester, 'i01.hero.sparkleLarge');
      final pequeno = _w<AppSvg>(tester, 'i01.hero.sparkleSmall');
      expect((grande.asset, grande.size), (AppIcons.sparkleOutline, 30.0));
      expect((pequeno.asset, pequeno.size), (AppIcons.sparkleSolid, 14.0));
    },
  );

  testWidgets('L01a2 capa nova: 104 × 156 violeta, borda 1,5, raio 4/10/10/4, sombra 3/3, girada −3°; o desenho '
      'sem os textos em cover e a lombada de 7', (tester) async {
    await _abrir(tester);
    final capa = tester.widget<NeoBox>(
      find
          .descendant(of: ini('i01.hero.cover'), matching: find.byType(NeoBox))
          .first,
    );
    expect((capa.width, capa.height), (104.0, 156.0));
    expect(capa.color, AppColors.violet);
    expect(capa.border, const BorderSide(width: 1.5, color: AppColors.ink));
    expect(capa.radius, AppRadii.coverL);
    expect(
      capa.radius,
      const BorderRadius.only(
        topLeft: Radius.circular(4),
        bottomLeft: Radius.circular(4),
        topRight: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
    );
    expect(capa.shadow, AppShadows.hard3);
    expect(capa.clip, isTrue);
    // a convenção das capas giradas: o slot sem giro tem a Key do id; o filho do Transform, `<id>#rot`
    final giro = tester.widget<Transform>(
      find
          .descendant(
            of: ini('i01.hero.cover'),
            matching: find.byType(Transform),
          )
          .first,
    );
    expect(giro.child!.key, const ValueKey('hero.cover#rot'));
    final esperado = Matrix4.rotationZ(-3 * math.pi / 180);
    for (var i = 0; i < 16; i++) {
      expect(giro.transform.storage[i], closeTo(esperado.storage[i], 1e-12));
    }
    final arte = _w<AppSvg>(tester, 'i01.hero.cover.art');
    expect(arte.asset, AppIllustrationsInicio.coverDomCasmurro);
    expect((arte.size, arte.height, arte.fit), (101.0, 153.0, BoxFit.cover));
    expect(AppIllustrationsInicio.withText, contains(arte.asset));
    expect(_w<NeoBox>(tester, 'i01.hero.cover.spine').color, AppColors.spine22);
    expect(const Color(0x38000000), AppColors.spine22); // rgba(0,0,0,.22)
  });

  testWidgets(
    'L01a2 os textos da capa: "Dom" / "Casmurro" Instrument Serif 19 e "MACHADO DE ASSIS" Figtree 5,2/700 '
    'ls 0,9 × 1,0625, nas posições do viewBox (o slice: ×1,0625 e −0,5 em x)',
    (tester) async {
      await _abrir(tester);
      const s = 153 / 144;
      final arte = retanguloDeLayout(tester, 'i01.hero.cover.art');
      expect(DomCasmurroEyeCover.scale, s);
      expect(DomCasmurroEyeCover.dx, closeTo(-0.5, 1e-12));
      for (final (texto, x, y, estilo) in [
        ('Dom', 12.0, 24.0, AppTextStyles.coverEyeTitle),
        ('Casmurro', 12.0, 41.0, AppTextStyles.coverEyeTitle),
        ('MACHADO DE ASSIS', 12.5, 51.0, AppTextStyles.coverEyeAuthor),
      ]) {
        final l = linhas01(tester, 'i01.hero.cover', texto).single;
        expect(l.text, texto);
        expect(l.baseline, closeTo(arte.top + y * s, 1e-3), reason: texto);
        expect(l.left, closeTo(arte.left + x * s - 0.5, 1e-3), reason: texto);
        expect(appText01(tester, 'i01.hero.cover', texto).span.style, estilo);
      }
      final titulo = AppTextStyles.coverEyeTitle;
      expect(titulo.fontFamily, 'InstrumentSerif');
      expect(titulo.fontSize, 19 * s);
      expect(titulo.color, AppColors.sun);
      final autor = AppTextStyles.coverEyeAuthor;
      expect(autor.fontFamily, 'Figtree');
      expect((autor.fontSize, autor.fontWeight), (5.2 * s, FontWeight.w700));
      expect(autor.letterSpacing, 0.9 * s);
      expect(autor.color, AppColors.paper);
    },
  );

  testWidgets('L01a2 pílulas: "pág. 159 de 256" Figtree 12/700 em #FFFAF1 (5/10) e "E-BOOK" 11/900→700 ls 0,8 '
      'em #FED170 (5/8), ambas com borda 1,5 e raio 999', (tester) async {
    await _abrir(tester);
    final pagina = _w<Pill>(tester, 'i01.hero.pagePill');
    final selo = _w<Pill>(tester, 'i01.hero.formatPill');
    expect(pagina.color, AppColors.surface);
    expect(
      pagina.padding,
      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    );
    expect(selo.color, AppColors.sun);
    expect(
      selo.padding,
      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
    );
    for (final p in [pagina, selo]) {
      expect(p.border, const BorderSide(width: 1.5, color: AppColors.ink));
    }
    expect(
      appText01(tester, 'i01.hero.pagePill').span.style,
      AppTextStyles.label12Bold,
    );
    final badge = appText01(tester, 'i01.hero.formatPill').span.style!;
    expect(badge, AppTextStyles.formatBadge);
    expect(
      (badge.fontFamily, badge.fontSize, badge.fontWeight),
      ('Figtree', 11.0, FontWeight.w700),
    );
    expect(badge.letterSpacing, 0.8);
  });

  testWidgets(
    'L01a2 título, autor, percentual, tempo e barra: os estilos da v1 e a barra 10 em 62 %',
    (tester) async {
      await _abrir(tester);
      expect(
        appText01(tester, 'i01.hero.title').span.style,
        AppTextStyles.heroTitle,
      );
      expect(
        appText01(tester, 'i01.hero.author').span.style,
        AppTextStyles.body14Plum,
      );
      expect(
        appText01(tester, 'i01.hero.percent').span.style,
        AppTextStyles.heroPercent,
      );
      expect(
        appText01(tester, 'i01.hero.timeLeft').span.style,
        AppTextStyles.caption12Plum,
      );
      final barra = _w<StadiumProgressBar>(tester, 'i01.hero.progressBar');
      expect(barra.progress, TelaInicio01.continuarLendo.progress);
      expect(
        (barra.height, barra.background, barra.fillColor),
        (10.0, AppColors.surface, AppColors.ink),
      );
    },
  );

  testWidgets('L01a2 ações: CTA tinta 54 (livro aberto 20 + "Continuar lendo" 16/700) e o botão 54 dos destaques '
      'com o contador amarelo "12" (mín. 22, top/right −4)', (tester) async {
    await _abrir(tester);
    final cta = _w<NeoBox>(tester, 'i01.hero.cta');
    expect((cta.height, cta.color), (54.0, AppColors.ink));
    expect(cta.radius, BorderRadius.circular(AppRadii.pill));
    final icone = _w<AppSvg>(tester, 'i01.hero.cta.icon');
    expect((icone.asset, icone.size), (AppIcons.bookOpen, 20.0));
    expect(
      _w<AppText>(tester, 'i01.hero.cta.label').span.style,
      AppTextStyles.cta16OnInk,
    );
    final botao = _w<CircleIconButton>(tester, 'i01.hero.notesButton');
    expect((botao.size, botao.color), (54.0, AppColors.surface));
    expect(botao.border, const BorderSide(width: 1.5, color: AppColors.ink));
    final marca = _w<AppSvg>(tester, 'i01.hero.notesButton.icon');
    expect((marca.asset, marca.size), (AppIcons.highlighter, 22.0));
    final contador = _w<CountBadge>(tester, 'i01.hero.notesButton.badge');
    expect(contador.label, '12');
    expect(
      (contador.minWidth, contador.height, contador.horizontalPadding),
      (22.0, 22.0, 5.0),
    );
    expect(contador.background, AppColors.sun);
    expect(contador.style, AppTextStyles.micro11Bold);
    expect(
      _caixa(tester, 'i01.hero.notesButton').radius,
      BorderRadius.circular(27),
    ); // 50 %
  });

  testWidgets(
    'L01a2 dados: página, total e anotações da fixture t01 (o mundo do leitor — D-241)',
    (tester) async {
      await _abrir(tester);
      final c = TelaInicio01.continuarLendo;
      expect((c.refPage, c.refPagesTotal, c.highlightsCount), (159, 256, 12));
      expect(c.format, BookFormat.epub);
      expect(findAppText('pág. 159 de 256'), findsOneWidget);
      expect(findAppText('E-BOOK'), findsOneWidget);
      // a pílula de capítulo da v1 não existe mais na 01
      expect(find.byKey(const ValueKey('hero.chapterPill')), findsNothing);
    },
  );

  testWidgets(
    'D-254: PDF → "PDF"; papel → "PAPEL"; sem página de referência o selo fica sozinho (uma linha)',
    (tester) async {
      await _abrir(tester, trocar: true, heroi: _heroi(format: BookFormat.pdf));
      expect(findAppText('PDF'), findsOneWidget);
      await _abrir(
        tester,
        trocar: true,
        heroi: _heroi(format: BookFormat.physical),
      );
      expect(findAppText('PAPEL'), findsOneWidget);
      expect(findAppText('pág. 159 de 256'), findsOneWidget);
      for (final (page, total) in [(null, 256), (159, null), (null, null)]) {
        await _abrir(
          tester,
          trocar: true,
          heroi: _heroi(refPage: page, refPagesTotal: total),
        );
        expect(find.byKey(const ValueKey('hero.pagePill')), findsNothing);
        expect(
          tester.getSize(ini('i01.hero.pills')).height,
          closeTo(26.2, 1e-3),
        );
        expect(findAppText('E-BOOK'), findsOneWidget);
      }
    },
  );

  testWidgets(
    'sem livro em leitura: o convite da G08 no lugar do cartão (D-78/D-85)',
    (tester) async {
      await _abrir(tester, trocar: true);
      expect(find.byType(HeroInvitation), findsOneWidget);
      expect(findAppText('Nada em leitura agora'), findsOneWidget);
      expect(find.byKey(const ValueKey('hero.cover')), findsNothing);
    },
  );

  testWidgets(
    'L01a2 semântica: a seção "Continuar lendo", o h2, a barra 62 %, o link do CTA e o botão "(12)"',
    (tester) async {
      final semantics = tester.ensureSemantics();
      // a Início passa os dois toques (o leitor e a tela 25)
      await _abrir(tester, onContinueTap: () {}, onHighlightsTap: () {});
      expect(find.semantics.byLabel('Continuar lendo'), findsAtLeast(1));
      final cta = noDe(tester, 'i01.hero.cta').getSemanticsData();
      expect(cta.label, 'Continuar lendo');
      expect(cta.flagsCollection.isLink, isTrue);
      expect(cta.hasAction(SemanticsAction.tap), isTrue);
      final barra = noDe(tester, 'i01.hero.progressBar').getSemanticsData();
      expect((barra.label, barra.value), ('Progresso do livro', '62%'));
      final botao = noDe(tester, 'i01.hero.notesButton').getSemanticsData();
      expect(botao.label, 'Destaques e notas deste livro (12)');
      expect(botao.hasAction(SemanticsAction.tap), isTrue);
      final titulo = tester
          .getSemantics(ini('i01.hero.title'))
          .getSemanticsData();
      expect(titulo.flagsCollection.isHeader, isTrue);
      expect(titulo.headingLevel, 2);
      // o <svg> da capa não tem aria-hidden: os três <text> dele são lidos, como os textos da capa da v1
      for (final t in ['Dom', 'Casmurro', 'MACHADO DE ASSIS']) {
        expect(find.semantics.byLabel(t), findsOneWidget, reason: t);
      }
      // os brilhos e os ícones, não (aria-hidden: o AppSvg é um ExcludeSemantics)
      for (final id in [
        'i01.hero.sparkleLarge',
        'i01.hero.sparkleSmall',
        'i01.hero.cta.icon',
        'i01.hero.notesButton.icon',
      ]) {
        expect(
          find.descendant(of: ini(id), matching: find.byType(ExcludeSemantics)),
          findsAtLeast(1),
          reason: id,
        );
      }
      semantics.dispose();
    },
  );

  testWidgets(
    'L01a2 toques: o CTA e o botão dos destaques chamam os callbacks da seção',
    (tester) async {
      var (continuar, destaques) = (0, 0);
      await _abrir(
        tester,
        onContinueTap: () => continuar++,
        onHighlightsTap: () => destaques++,
      );
      await tester.tap(ini('i01.hero.cta'));
      await tester.tap(ini('i01.hero.notesButton'));
      await tester.pumpAndSettle();
      expect((continuar, destaques), (1, 1));
    },
  );

  testWidgets(
    'L01a2 captura: o herói no canvas da prancha (gate visual fora do teste)',
    (tester) async {
      await _abrir(tester);
      final image = await capturar01(tester, 't03_L01a2');
      expect((image.width, image.height), (1170, 7950));
    },
  );
}
