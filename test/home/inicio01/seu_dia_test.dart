// T03.9 — fase L01a4 ("Seu dia de leitura") contra a prancha 01 (`kRef01`) e as larguras 360/430: o cartão da v1 com
// a coluna da meta nova — a frase, o "Ler agora" (sem ação até a T04, D-243 b) e as pílulas "2 sessões" e
// "2 destaques". Classe nova (TodaySection), que substituiu a da v1 na troca. Recorte do gate visual: y 752,27–1227,37
// (`docs/design/fases/L01a4_seu_dia.md`).
import 'package:app_leitura/core/design_system/painters/goal_dial_painter.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_inicio.dart';
import 'package:app_leitura/core/design_system/tokens/app_radii.dart';
import 'package:app_leitura/core/design_system/tokens/app_shadows.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pill.dart';
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/home/presentation/sections/today_section.dart';
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

const _secoes = ['i01.today'];

/// A fixture `t01` com outro dia (o singular "1 sessão").
final class _ComDia implements SyncHomeRepository {
  const _ComDia(this.sessoes);

  final int sessoes;

  @override
  HomeSnapshot snapshot(DateTime now) {
    final s = TelaInicio01.snapshot(now);
    final d = s.readingDay;
    return HomeSnapshot(
      now: s.now,
      user: s.user,
      continueReading: s.continueReading,
      alsoReading: s.alsoReading,
      readingDay: ReadingDay(
        goalMinutes: d.goalMinutes,
        readMinutes: d.readMinutes,
        streakDays: d.streakDays,
        highlightsToday: 1,
        sessionsToday: sessoes,
        week: d.week,
        badgeTargetDays: d.badgeTargetDays,
      ),
      dailyReview: s.dailyReview,
      forYou: s.forYou,
      club: s.club,
      recent: s.recent,
    );
  }

  @override
  Stream<HomeSnapshot> watch(DateTime Function() clock) => const Stream.empty();
}

Future<void> _abrir(
  WidgetTester tester, {
  LeitorRefPrancha prancha = kRef01,
  int? sessoes,
}) => abrirInicio01(
  tester,
  prancha: prancha,
  repositorio: sessoes == null ? const HomeMockRepository() : _ComDia(sessoes),
);

T _w<T extends Widget>(WidgetTester tester, String id) =>
    tester.widget<T>(ini(id));

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'L01a4 geometria: os 52 ids com widget (os 3 trechos inline entram pelas linhas)',
    (tester) async {
      await _abrir(tester);
      expect(idsDasSecoes(kRef01, _secoes), hasLength(52));
      expect(geometria01(tester, _secoes), isEmpty);
    },
  );

  testWidgets(
    'L01a4 texto: "Seu dia de leitura", "12 dias", "18", "de 30 min", a frase em 2 linhas (pretty), '
    '"Ler agora", as pílulas, a semana e o rodapé nas baselines da prancha',
    (tester) async {
      await _abrir(tester);
      expect(texto01(tester, _secoes), isEmpty);
    },
  );

  for (final tela in ['01w360', '01w430']) {
    testWidgets(
      'L01a4 a ${tela.substring(3)} px: geometria e texto da prancha medida nessa largura',
      (tester) async {
        final ref = kRefInicio2Larguras[tela]!;
        await _abrir(tester, prancha: ref);
        expect(geometria01(tester, _secoes, prancha: ref), isEmpty);
        expect(texto01(tester, _secoes, prancha: ref), isEmpty);
      },
    );
  }

  testWidgets('L01a4 cartão: #FED170, borda 1,5, raio 28, sombra 4/4, recorte; os círculos 153 e 101 com borda '
      '1,5 rgba(26,23,20,.14) atrás do conteúdo', (tester) async {
    await _abrir(tester);
    final c = _w<NeoBox>(tester, 'i01.today');
    expect(c.color, AppColors.sun);
    expect(c.border, const BorderSide(width: 1.5, color: AppColors.ink));
    expect(c.radius, BorderRadius.circular(AppRadii.card));
    expect((c.shadow, c.clip), (AppShadows.hard4, true));
    for (final (id, s) in [
      ('i01.today.decoCircleLarge', 153.0),
      ('i01.today.decoCircleSmall', 101.0),
    ]) {
      final d = _w<NeoBox>(tester, id);
      expect((d.width, d.height, d.color), (s, s, null));
      expect(d.border, const BorderSide(width: 1.5, color: AppColors.decoRing));
      expect(AppColors.decoRing, const Color(0x241A1714));
    }
  });

  testWidgets('L01a4 "Ler agora": pílula tinta 40, padding 0/14/0/11, raio 999, cronômetro 17 amarelo e '
      'Figtree 14/800 → 700 #F7F0E3 com gap 7', (tester) async {
    await _abrir(tester);
    final b = _w<NeoBox>(tester, 'i01.today.readNow');
    expect((b.height, b.color), (40.0, AppColors.ink));
    expect(b.radius, BorderRadius.circular(AppRadii.pill));
    expect(b.padding, const EdgeInsets.fromLTRB(11, 0, 14, 0));
    expect(b.border, isNull);
    final i = _w<AppSvg>(tester, 'i01.today.readNow.icon');
    expect((i.asset, i.size), (AppIconsInicio.stopwatch, 17.0));
    final s = _w<AppText>(tester, 'i01.today.readNow.label').span.style!;
    expect(s, AppTextStyles.cta14OnInk);
    expect(
      (s.fontFamily, s.fontSize, s.fontWeight, s.color),
      ('Figtree', 14.0, FontWeight.w700, AppColors.paper),
    );
  });

  testWidgets('L01a4 pílulas "2 sessões" e "2 destaques": Figtree 12/700, padding 5/9, fundo rgba(255,250,241,.7) e '
      'borda 1,2; a de páginas da v1 não existe mais', (tester) async {
    await _abrir(tester);
    for (final (id, texto) in [
      ('i01.today.chip.sessions', '2 sessões'),
      ('i01.today.chip.highlights', '2 destaques'),
    ]) {
      final p = _w<Pill>(tester, id);
      expect(p.color, AppColors.chipGlass);
      expect(AppColors.chipGlass, const Color(0xB3FFFAF1));
      expect(p.border, const BorderSide(width: 1.2, color: AppColors.ink));
      expect(p.padding, const EdgeInsets.symmetric(vertical: 5, horizontal: 9));
      final t = appText01(tester, id);
      expect(
        (t.span.toPlainText(), t.span.style),
        (texto, AppTextStyles.label12Bold),
      );
    }
    expect(find.byKey(const ValueKey('today.chip.pages')), findsNothing);
  });

  testWidgets('L01a4 o resto é a v1: cabeçalho, mostrador (18 de 30 → 60 %), semana com as barras da fixture e o '
      'rodapé do selo', (tester) async {
    await _abrir(tester);
    final dia = TelaInicio01.diaDeLeitura();
    expect(
      _w<AppText>(tester, 'i01.today.title').span.toPlainText(),
      'Seu dia de leitura',
    );
    expect(findAppText('12 dias'), findsOneWidget);
    expect(
      _w<AppSvg>(tester, 'i01.today.streakPill.icon').asset,
      AppIcons.flame,
    );
    final dial = tester.widget<CustomPaint>(ini('i01.today.dial.svg'));
    expect(
      (dial.painter! as GoalDialPainter).progress,
      dia.readMinutes / dia.goalMinutes,
    );
    expect((dia.readMinutes, dia.goalMinutes), (18, 30));
    for (var i = 0; i < 7; i++) {
      expect(
        tester.getSize(find.byKey(ValueKey('today.week.bar$i.fill'))).height,
        dia.week[i].barHeightPx,
      );
    }
    expect(
      _w<AppSvg>(tester, 'i01.today.footer.icon').asset,
      AppIcons.sparkleSolid,
    );
    expect(
      _w<AppText>(tester, 'i01.today.footer.text').span.toPlainText(),
      'Mais 2 dias para o selo de 14 dias',
    );
  });

  testWidgets(
    'dados: "N sessões" = sessões de hoje (o singular "1 sessão"); "N destaques" = grifos de hoje',
    (tester) async {
      expect(
        TelaInicio01.diaDeLeitura().sessionsToday,
        TelaInicio01.sessoesHojeNaPrancha,
      );
      expect(
        TelaInicio01.diaDeLeitura().highlightsToday,
        TelaInicio01.grifosHojeNaPrancha,
      );
      await _abrir(tester, sessoes: 1);
      expect(findAppText('1 sessão'), findsOneWidget);
      expect(findAppText('1 destaque'), findsOneWidget);
    },
  );

  testWidgets('L01a4 semântica: a seção, o h3, o link "Iniciar leitura (cronômetro)", o gráfico rotulado; os '
      'decorativos e os ícones fora', (tester) async {
    final semantics = tester.ensureSemantics();
    await _abrir(tester);
    expect(find.semantics.byLabel('Seu dia de leitura'), findsAtLeast(1));
    final titulo = tester
        .getSemantics(ini('i01.today.title'))
        .getSemanticsData();
    expect((titulo.flagsCollection.isHeader, titulo.headingLevel), (true, 3));
    final ler = noDe(tester, 'i01.today.readNow').getSemanticsData();
    expect(ler.label, 'Iniciar leitura (cronômetro)');
    expect(ler.flagsCollection.isLink, isTrue);
    expect(ler.hasAction(SemanticsAction.tap), isTrue);
    expect(
      noDe(tester, 'i01.today.week.chart').label,
      'Minutos lidos por dia: segunda 32, terça 45, quarta 30, quinta 22, sexta 38, sábado 55, hoje 18 de 30',
    );
    for (final id in [
      'i01.today.decoCircleLarge',
      'i01.today.decoCircleSmall',
      'i01.today.dial.svg',
    ]) {
      expect(
        find.ancestor(of: ini(id), matching: find.byType(ExcludeSemantics)),
        findsAtLeast(1),
        reason: id,
      );
    }
    for (final id in [
      'i01.today.streakPill.icon',
      'i01.today.readNow.icon',
      'i01.today.footer.icon',
    ]) {
      expect(
        find.descendant(of: ini(id), matching: find.byType(ExcludeSemantics)),
        findsAtLeast(1),
        reason: id,
      );
    }
    semantics.dispose();
  });

  testWidgets(
    'L01a4 toque no "Ler agora": fica na Início (o cronômetro é da T04 — D-243 b)',
    (tester) async {
      await _abrir(tester);
      expect(
        tester.widget<TodaySection>(find.byType(TodaySection)).onReadNowTap,
        HomeScreen.onReadNow,
      );
      expect(HomeScreen.onReadNow, returnsNormally);
      await tocar01(tester, 'i01.today.readNow');
      expect(rotaAtual(tester), '/inicio');
    },
  );

  testWidgets('L01a4 captura: a página no canvas da prancha (o recorte pega o fim dos cartões do "Também lendo"; '
      'gate visual fora do teste)', (tester) async {
    await _abrir(tester);
    final image = await capturar01(tester, 't03_L01a4');
    expect((image.width, image.height), (1170, 7950));
  });
}
