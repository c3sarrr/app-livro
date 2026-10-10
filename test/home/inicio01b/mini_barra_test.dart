// T04.7 — L01b.2–3: a mini-barra do cronômetro na prancha 01b (`kRef01b`, a `t01b` — D-241): os 11 ids de
// `i01b.miniBar` (358 × 66 em 16/648, a barrinha de 89 % da meta, a capa com asas girada −5°, "LENDO · PAPEL", "Brás
// Cubas", "08:42" e o pausar tinta), o estilo de cada parte e a semântica (o link com o rótulo da prancha e o botão
// "Pausar" dentro dele).
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_inicio.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_inicio.dart';
import 'package:app_leitura/core/design_system/tokens/app_radii.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/circle_icon_button.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/home/presentation/covers/bras_cubas_wings_cover.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/home_mock_repository.dart';
import '../../fixtures/paper_timer_fakes.dart';
import '../../reference/inicio2/referencias_inicio2.dart';
import '../../support/fase_inicio.dart';
import '../../support/load_fonts.dart';

const _secoes = ['i01b.miniBar'];

Future<void> _abrir(WidgetTester tester) => abrirInicio01(
  tester,
  prancha: kRef01b,
  safeTop: 47,
  safeBottom: 34,
  repositorio: const HomeMockRepository01b(),
  cronometro: overridesDa01b(),
);

T _w<T extends Widget>(WidgetTester tester, String id) =>
    tester.widget<T>(ini(id));

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'L01b.2 geometria: os 11 ids (a barra 358 × 66 em 16/648, a barrinha 315,95 = 89 % de 355, a capa e a arte '
    'giradas −5°, os textos em 73,5, o tempo 63,05 e o pausar 44)',
    (tester) async {
      await _abrir(tester);
      expect(idsDasSecoes(kRef01b, _secoes), hasLength(11));
      expect(geometria01(tester, _secoes, prancha: kRef01b), isEmpty);
    },
  );

  testWidgets(
    'L01b.2 texto: "LENDO · PAPEL", "Brás Cubas" e "08:42" nas baselines da prancha',
    (tester) async {
      await _abrir(tester);
      expect(texto01(tester, _secoes, prancha: kRef01b), isEmpty);
    },
  );

  testWidgets(
    'L01b.2 estilo: tinta com borda 1,5, raio 22, sombra 0/4 rgba(26,23,20,.35) dura, recorte; barrinha {{brand}} '
    'raio 0/4/4/0; ponto 7 #FF552E; kicker #B9AE9C Figtree 10,5/700 ls 1,4; título 15/700 #F7F0E3 com '
    'reticências; tempo Bricolage 24/800 ls −0,6 tabular; botão 44 #F7F0E3 com o pausar tinta 18',
    (tester) async {
      await _abrir(tester);
      final barra = _w<NeoBox>(tester, 'i01b.miniBar');
      expect((barra.height, barra.color), (66.0, AppColors.ink));
      expect(barra.border, const BorderSide(width: 1.5, color: AppColors.ink));
      expect(barra.radius, BorderRadius.circular(22));
      expect(
        (barra.shadow, barra.shadowColor, barra.clip),
        (const Offset(0, 4), AppColors.miniBarShadow, true),
      );
      expect(AppColors.miniBarShadow, const Color(0x591A1714));
      final progresso = _w<NeoBox>(tester, 'i01b.miniBar.progress');
      expect(progresso.color, AppColors.lavender); // o brand padrão do mundo
      expect(
        progresso.radius,
        const BorderRadius.horizontal(right: Radius.circular(4)),
      );
      final ponto = _w<NeoBox>(tester, 'i01b.miniBar.kicker.dot');
      expect(
        (ponto.color, ponto.radius),
        (AppColors.flame, BorderRadius.circular(3.5)),
      );
      final kicker = appText01(tester, 'i01b.miniBar.kicker');
      expect(kicker.span.style, AppTextStyles.miniBarKicker);
      final k = kicker.span.style!;
      expect(
        (k.fontFamily, k.fontSize, k.fontWeight, k.letterSpacing, k.color),
        ('Figtree', 10.5, FontWeight.w700, 1.4, const Color(0xFFB9AE9C)),
      );
      final titulo = _w<AppText>(tester, 'i01b.miniBar.title');
      expect(titulo.span.style, AppTextStyles.miniBarTitle);
      expect((titulo.maxLines, titulo.ellipsis), (1, true));
      final t = titulo.span.style!;
      expect(
        (t.fontFamily, t.fontSize, t.fontWeight, t.height, t.color),
        ('Figtree', 15.0, FontWeight.w700, 1.2, AppColors.paper),
      );
      final tempo = _w<AppText>(tester, 'i01b.miniBar.time');
      final s = tempo.span.style!;
      expect(s, AppTextStyles.miniBarTime);
      expect(
        (s.fontFamily, s.fontSize, s.fontWeight, s.letterSpacing, s.color),
        ('Bricolage24', 24.0, FontWeight.w800, -0.6, AppColors.paper),
      );
      expect(s.fontFeatures, const [FontFeature.tabularFigures()]);
      final botao = _w<CircleIconButton>(tester, 'i01b.miniBar.pause');
      expect(
        (botao.size, botao.color, botao.border),
        (44.0, AppColors.paper, null),
      );
      final icone = _w<AppSvg>(tester, 'i01b.miniBar.pause.icon');
      expect((icone.asset, icone.size), (AppIconsInicio.pauseInk, 18.0));
    },
  );

  testWidgets(
    'R10 a capa da fixture: com asas, 32 × 48 #058CD7, borda 1,2 #F7F0E3, raio 2/5/5/2, sem sombra, recortada; '
    'o desenho sem os <text> e os 3 textos em AppText (× 45,6/144)',
    (tester) async {
      await _abrir(tester);
      expect(find.byType(BrasCubasWingsCover), findsOneWidget);
      final capa = tester.widget<NeoBox>(
        find
            .descendant(
              of: find.byType(BrasCubasWingsCover),
              matching: find.byType(NeoBox),
            )
            .first,
      );
      expect(
        (capa.width, capa.height, capa.color),
        (32.0, 48.0, AppColors.azure),
      );
      expect(capa.border, const BorderSide(width: 1.2, color: AppColors.paper));
      expect(capa.radius, AppRadii.coverXs);
      expect((capa.shadow, capa.clip), (null, true));
      final arte = _w<AppSvg>(tester, 'i01b.miniBar.cover.art');
      expect(arte.asset, AppIllustrationsInicio.coverBrasCubasWings);
      expect(
        AppIllustrationsInicio.withText,
        contains(AppIllustrationsInicio.coverBrasCubasWings),
      );
      final textos = tester
          .widgetList<AppText>(
            find.descendant(
              of: find.byType(BrasCubasWingsCover),
              matching: find.byType(AppText),
            ),
          )
          .map((a) => (a.span.toPlainText(), a.span.style))
          .toList();
      expect(textos, [
        ('MEMÓRIAS PÓSTUMAS DE', AppTextStyles.coverWingsKicker),
        ('Brás Cubas', AppTextStyles.coverWingsTitle),
        ('MACHADO DE ASSIS', AppTextStyles.coverWingsAuthor),
      ]);
      expect(
        AppTextStyles.coverWingsTitle.fontSize,
        closeTo(17.5 * 45.6 / 144, 1e-9),
      );
    },
  );

  testWidgets(
    'R12 semântica: o link "Sessão em andamento: Brás Cubas, 8 minutos e 42 segundos. Abrir cronômetro" sem região '
    'ao vivo, com o botão "Pausar" dentro; a capa, a barrinha, os textos e os ícones fora da árvore',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _abrir(tester);
      final link = find.semantics.byLabel(
        'Sessão em andamento: Brás Cubas, 8 minutos e 42 segundos. Abrir cronômetro',
      );
      expect(link, findsOneWidget);
      final no = link.evaluate().single;
      final d = no.getSemanticsData();
      expect(d.flagsCollection.isLink, isTrue);
      expect(d.flagsCollection.isLiveRegion, isFalse);
      final filhos = <SemanticsNode>[];
      no.visitChildren((c) {
        filhos.add(c);
        return true;
      });
      expect(filhos, hasLength(1));
      final botao = filhos.single.getSemanticsData();
      expect(botao.label, 'Pausar');
      expect(botao.flagsCollection.isButton, isTrue);
      expect(botao.hasAction(SemanticsAction.tap), isTrue);
      for (final id in [
        'i01b.miniBar.cover',
        'i01b.miniBar.progress',
        'i01b.miniBar.texts',
        'i01b.miniBar.time',
      ]) {
        // em volta do id ou logo dentro dele (a capa: o slot sem giro e, dentro, o giro excluído)
        final fora = [
          find.ancestor(of: ini(id), matching: find.byType(ExcludeSemantics)),
          find.descendant(of: ini(id), matching: find.byType(ExcludeSemantics)),
        ].expand((f) => f.evaluate());
        expect(fora, isNotEmpty, reason: id);
      }
      // e nenhum outro nó dentro do link além do botão (o ícone do botão também fica fora)
      expect(
        find.descendant(
          of: ini('i01b.miniBar.pause'),
          matching: find.byType(ExcludeSemantics),
        ),
        findsAtLeast(1),
      );
      semantics.dispose();
    },
  );
}
