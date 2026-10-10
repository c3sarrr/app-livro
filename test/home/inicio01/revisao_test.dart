// T03.10 — fase L01a5 (a seção nova "Seus grifos de hoje") contra a prancha 01 (`kRef01`) e as larguras 360/430: o
// cartão com os três cartõezinhos de grifo girados, o sobretítulo do baralho do dia, "Seus grifos *de hoje*", de onde
// vêm os grifos e o "Revisar" (sem ação até a T05, D-243 b). Com dados reais `dailyReview` é `null` e a seção some
// (D-247). Recorte do gate visual: y 1251,37–1432,52 (`docs/design/fases/L01a5_revisao.md`).
import 'dart:math' as math;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_inicio.dart';
import 'package:app_leitura/core/design_system/tokens/app_radii.dart';
import 'package:app_leitura/core/design_system/tokens/app_shadows.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/home/presentation/sections/review_section.dart';
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

const _secoes = ['i01.review'];

/// A fixture `t01` com outra revisão (`null` = dados reais até a T05).
final class _ComRevisao implements SyncHomeRepository {
  const _ComRevisao(this.revisao);

  final DailyReview? revisao;

  @override
  HomeSnapshot snapshot(DateTime now) {
    final s = TelaInicio01.snapshot(now);
    return HomeSnapshot(
      now: s.now,
      user: s.user,
      continueReading: s.continueReading,
      alsoReading: s.alsoReading,
      readingDay: s.readingDay,
      dailyReview: revisao,
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
  bool trocar = false,
  DailyReview? revisao,
}) => abrirInicio01(
  tester,
  prancha: prancha,
  repositorio: trocar ? _ComRevisao(revisao) : const HomeMockRepository(),
);

T _w<T extends Widget>(WidgetTester tester, String id) =>
    tester.widget<T>(ini(id));

void main() {
  setUpAll(loadAppFonts);

  testWidgets('L01a5 geometria: os 25 ids (os cartõezinhos girados −12°/+8°/−2° e os traços: layout e caixa '
      'visual)', (tester) async {
    await _abrir(tester);
    expect(idsDasSecoes(kRef01, _secoes), hasLength(25));
    expect(geometria01(tester, _secoes), isEmpty);
  });

  testWidgets('L01a5 texto: o sobretítulo, "Seus grifos de hoje", o subtítulo em 2 linhas e "Revisar" nas '
      'baselines da prancha', (tester) async {
    await _abrir(tester);
    expect(texto01(tester, _secoes), isEmpty);
  });

  for (final tela in ['01w360', '01w430']) {
    testWidgets(
      'L01a5 a ${tela.substring(3)} px: geometria e texto da prancha medida nessa largura',
      (tester) async {
        final ref = kRefInicio2Larguras[tela]!;
        await _abrir(tester, prancha: ref);
        expect(geometria01(tester, _secoes, prancha: ref), isEmpty);
        expect(texto01(tester, _secoes, prancha: ref), isEmpty);
      },
    );
  }

  testWidgets(
    'L01a5 cartão: #FFFAF1, borda 1,5, raio 28, sombra 4/4, padding 16, sem recorte',
    (tester) async {
      await _abrir(tester);
      final c = _w<NeoBox>(tester, 'i01.review');
      expect(c.color, AppColors.surface);
      expect(c.border, const BorderSide(width: 1.5, color: AppColors.ink));
      expect(c.radius, BorderRadius.circular(AppRadii.card));
      expect(
        (c.shadow, c.padding, c.clip),
        (AppShadows.hard4, const EdgeInsets.all(16), false),
      );
    },
  );

  testWidgets(
    'L01a5 arte: os 3 cartõezinhos (raio 10, borda 1,5, sombra 2/2, padding 10/8) girados, os traços 5 '
    '(raio 3) em 90/70/82/55 % — a cor do grifo e #E4DACA — e o brilho amarelo 26',
    (tester) async {
      await _abrir(tester);
      for (final (id, graus, cor) in [
        ('review.art.card1', -12.0, AppColors.leaf),
        ('review.art.card2', 8.0, AppColors.blush),
        ('review.art.card3', -2.0, AppColors.lavender),
      ]) {
        final giro = tester.widget<Transform>(
          find
              .descendant(
                of: find.byKey(ValueKey(id)),
                matching: find.byType(Transform),
              )
              .first,
        );
        expect(giro.child!.key, ValueKey('$id#rot'));
        final m = Matrix4.rotationZ(graus * math.pi / 180);
        for (var i = 0; i < 16; i++) {
          expect(
            giro.transform.storage[i],
            closeTo(m.storage[i], 1e-12),
            reason: id,
          );
        }
        final card = tester.widget<NeoBox>(
          find
              .descendant(
                of: find.byKey(ValueKey('$id#rot')),
                matching: find.byType(NeoBox),
              )
              .first,
        );
        expect(card.color, AppColors.surface);
        expect(card.border, const BorderSide(width: 1.5, color: AppColors.ink));
        expect(
          (card.radius, card.shadow),
          (BorderRadius.circular(10), AppShadows.hard2),
        );
        expect(
          card.padding,
          const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        );
        for (var i = 0; i < 4; i++) {
          final l = tester.widget<NeoBox>(find.byKey(ValueKey('$id.line$i')));
          expect((l.height, l.radius), (5.0, BorderRadius.circular(3)));
          expect(
            l.color,
            i < 2 ? cor : AppColors.reviewLineNeutral,
            reason: '$id.line$i',
          );
        }
      }
      expect(AppColors.reviewLineNeutral, const Color(0xFFE4DACA));
      expect(
        (AppColors.leaf, AppColors.blush, AppColors.lavender),
        (
          const Color(0xFFABCF82),
          const Color(0xFFFFC1C6),
          const Color(0xFFB6ACE4),
        ),
      );
      final brilho = _w<AppSvg>(tester, 'i01.review.art.sparkle');
      expect((brilho.asset, brilho.size), (AppIconsInicio.sparkleYellow, 26.0));
    },
  );

  testWidgets(
    'L01a5 textos: sobretítulo Figtree 11/800 → 700 ls 1 #6F665B; "Seus grifos" Bricolage 20 lh 1,05 ls '
    '−0,5 + "de hoje" Instrument Serif itálico 24; subtítulo 12,5/600 lh 1,35 #5B544B',
    (tester) async {
      await _abrir(tester);
      final k = _w<AppText>(tester, 'i01.review.kicker');
      expect(k.span.toPlainText(), 'REVISÃO · 5 GRIFOS · 2 MIN');
      final ks = k.span.style!;
      expect(ks, AppTextStyles.reviewKicker);
      expect(
        (ks.fontFamily, ks.fontSize, ks.fontWeight, ks.letterSpacing, ks.color),
        ('Figtree', 11.0, FontWeight.w700, 1.0, const Color(0xFF6F665B)),
      );
      final t = _w<AppText>(tester, 'i01.review.title').span as TextSpan;
      expect(t.toPlainText(), 'Seus grifos de hoje');
      expect(t.style, AppTextStyles.reviewTitle);
      final ts = t.style!;
      expect(
        (ts.fontFamily, ts.fontSize, ts.height, ts.letterSpacing),
        ('Bricolage20', 20.0, 1.05, -0.5),
      );
      final serif = (t.children!.single as TextSpan).style!;
      expect(serif, AppTextStyles.reviewTitleSerif);
      expect(
        (
          serif.fontFamily,
          serif.fontSize,
          serif.fontStyle,
          serif.letterSpacing,
        ),
        ('InstrumentSerif', 24.0, FontStyle.italic, -0.5),
      );
      final s = _w<AppText>(tester, 'i01.review.subtitle');
      expect(s.span.toPlainText(), 'De Dom Casmurro, Quincas Borba e Iracema.');
      final ss = s.span.style!;
      expect(ss, AppTextStyles.reviewSubtitle);
      expect(
        (ss.fontSize, ss.fontWeight, ss.height, ss.color),
        (12.5, FontWeight.w600, 1.35, AppColors.inkMuted),
      );
    },
  );

  testWidgets('L01a5 "Revisar": pílula tinta 40, padding 0/16/0/12, raio 999, brilho amarelo 15 + Figtree 14/800 '
      '→ 700 #F7F0E3, gap 7', (tester) async {
    await _abrir(tester);
    final b = _w<NeoBox>(tester, 'i01.review.cta');
    expect((b.height, b.color, b.border), (40.0, AppColors.ink, null));
    expect(b.radius, BorderRadius.circular(AppRadii.pill));
    expect(b.padding, const EdgeInsets.fromLTRB(12, 0, 16, 0));
    final i = _w<AppSvg>(tester, 'i01.review.cta.icon');
    expect((i.asset, i.size), (AppIconsInicio.sparkleSolidYellow, 15.0));
    expect(
      _w<AppText>(tester, 'i01.review.cta.label').span.style,
      AppTextStyles.cta14OnInk,
    );
  });

  testWidgets(
    'dados (D-247): os números e os livros saem do baralho do dia da fixture; com dados reais (null) a '
    'seção some com o seu gap (o "Para você" sobe 205,15 e fica a 40 do "Seu dia"); 1 grifo no singular',
    (tester) async {
      expect(
        TelaInicio01.snapshot(TelaInicio01.agora).dailyReview,
        TelaInicio01.revisao,
      );
      await _abrir(tester, trocar: true);
      expect(find.byKey(const ValueKey('review')), findsNothing);
      expect(find.byType(ReviewSection), findsNothing);
      final hoje = retanguloDeLayout(tester, 'i01.today');
      final paraVoce = retanguloDeLayout(tester, 'i01.forYou');
      expect(paraVoce.top - hoje.bottom, closeTo(40, 1e-3));
      expect(
        paraVoce.top,
        closeTo(kRef01.sections['i01.forYou']!.top - 165.15 - 40, 0.02),
      );
      await _abrir(
        tester,
        trocar: true,
        revisao: const DailyReview(
          highlights: 1,
          minutes: 1,
          bookTitles: ['Iracema'],
        ),
      );
      expect(findAppText('REVISÃO · 1 GRIFO · 1 MIN'), findsOneWidget);
      expect(findAppText('De Iracema.'), findsOneWidget);
    },
  );

  testWidgets(
    'L01a5 semântica: a seção "Seus grifos de hoje", o link "Revisar"; a arte e o ícone fora',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _abrir(tester);
      expect(find.semantics.byLabel('Seus grifos de hoje'), findsAtLeast(1));
      final cta = find.semantics
          .byLabel('Revisar')
          .evaluate()
          .single
          .getSemanticsData();
      expect(cta.flagsCollection.isLink, isTrue);
      expect(cta.hasAction(SemanticsAction.tap), isTrue);
      expect(
        find.ancestor(
          of: ini('i01.review.art'),
          matching: find.byType(ExcludeSemantics),
        ),
        findsAtLeast(1),
      );
      expect(
        find.descendant(
          of: ini('i01.review.cta.icon'),
          matching: find.byType(ExcludeSemantics),
        ),
        findsAtLeast(1),
      );
      semantics.dispose();
    },
  );

  testWidgets(
    'L01a5 toques no "Revisar" e no cartão: ficam na Início (a revisão é da T05 — D-243 b)',
    (tester) async {
      await _abrir(tester);
      expect(
        tester.widget<ReviewSection>(find.byType(ReviewSection)).onReviewTap,
        HomeScreen.onReview,
      );
      expect(HomeScreen.onReview, returnsNormally);
      await tocar01(tester, 'i01.review.cta');
      expect(rotaAtual(tester), '/inicio');
      await tocar01(tester, 'i01.review.art');
      expect(rotaAtual(tester), '/inicio');
    },
  );

  testWidgets('L01a5 captura: a seção no canvas da prancha (o recorte não alcança as vizinhas; gate visual fora do '
      'teste)', (tester) async {
    await _abrir(tester);
    final image = await capturar01(tester, 't03_L01a5');
    expect((image.width, image.height), (1170, 7950));
  });
}
