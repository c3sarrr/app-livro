// T03.14 — fase L01a9 (o degradê inferior e a barra de navegação, Início ativo) contra a prancha 01 (`kRef01`) e as
// larguras 360/430: iguais à v1 (F11), presos pelo `MainShell` ao pé da página de 2650 (no app, fora da área que
// rola). Recorte do gate visual: y 2492–2650
// (`docs/design/fases/L01a9_barra.md`).
import 'dart:ui' show Tristate;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_shadows.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/shell/presentation/bottom_fade.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../reference/inicio2/referencias_inicio2.dart';
import '../../reference/inicio2_larguras/referencias_inicio2_larguras.dart';
import '../../support/fase_inicio.dart';
import '../../support/load_fonts.dart';

const _secoes = ['i01.bottomFade', 'i01.nav'];

Future<void> _abrir(WidgetTester tester, {LeitorRefPrancha prancha = kRef01}) =>
    abrirInicio01(tester, prancha: prancha);

/// Voltar do sistema: fecha a rota do topo.
Future<void> _voltar(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

NeoBox _neo(WidgetTester tester, String key) => tester.widget<NeoBox>(
  find
      .descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(NeoBox),
        matchRoot: true,
      )
      .first,
);

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'L01a9 geometria: os 18 ids (o degradê e os 17 da barra, com o FAB 20,5 acima dela)',
    (tester) async {
      await _abrir(tester);
      expect(idsDasSecoes(kRef01, _secoes), hasLength(18));
      expect(geometria01(tester, _secoes), isEmpty);
    },
  );

  testWidgets(
    'L01a9 texto: "Início", "Biblioteca", "Scanner", "Clubes" e "Perfil" nas baselines da prancha',
    (tester) async {
      await _abrir(tester);
      expect(texto01(tester, _secoes), isEmpty);
    },
  );

  for (final tela in ['01w360', '01w430']) {
    testWidgets(
      'L01a9 a ${tela.substring(3)} px: geometria e texto da prancha medida nessa largura (o FAB no centro)',
      (tester) async {
        final ref = kRefInicio2Larguras[tela]!;
        await _abrir(tester, prancha: ref);
        expect(geometria01(tester, _secoes, prancha: ref), isEmpty);
        expect(texto01(tester, _secoes, prancha: ref), isEmpty);
      },
    );
  }

  testWidgets(
    'L01a9 degradê: papel transparente → papel opaco a 55 % em 150 px, fora da árvore e sem toque',
    (tester) async {
      await _abrir(tester);
      final d =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(
                      of: find.byType(BottomFade),
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .decoration
              as BoxDecoration;
      final g = d.gradient! as LinearGradient;
      expect((g.begin, g.end), (Alignment.topCenter, Alignment.bottomCenter));
      expect(g.colors, [AppColors.paperTransparent, AppColors.paper]);
      expect(g.stops, [0.0, 0.55]);
      expect(AppColors.paper, const Color(0xFFF7F0E3));
      expect(AppColors.paperTransparent, const Color(0x00F7F0E3));
      // o pai mais próximo é o `IgnorePointer` do shell (`pointer-events: none`)
      final pai = tester.widget<IgnorePointer>(
        find
            .ancestor(
              of: find.byType(BottomFade),
              matching: find.byType(IgnorePointer),
            )
            .first,
      );
      expect(pai.ignoring, isTrue);
    },
  );

  testWidgets(
    'L01a9 barra: #FFFAF1, borda 1,5 tinta, raio 28, sombra 0/4, padding 8; Início ativo com o brand padrão '
    '#B6ACE4 (raio 20, borda 1,5); FAB 60 sol com sombra 0/4',
    (tester) async {
      await _abrir(tester);
      final nav = _neo(tester, 'nav');
      expect(
        (nav.color, nav.border, nav.radius, nav.shadow, nav.padding),
        (
          AppColors.surface,
          const BorderSide(width: 1.5, color: AppColors.ink),
          BorderRadius.circular(28),
          AppShadows.drop4,
          const EdgeInsets.all(8),
        ),
      );
      final home = _neo(tester, 'nav.home');
      expect(
        (home.color, home.border, home.radius),
        (
          const Color(0xFFB6ACE4),
          const BorderSide(width: 1.5, color: AppColors.ink),
          BorderRadius.circular(20),
        ),
      );
      for (final id in ['nav.library', 'nav.clubs', 'nav.profile']) {
        expect(
          find.descendant(
            of: find.byKey(ValueKey(id)),
            matching: find.byType(NeoBox),
          ),
          findsNothing,
          reason: id,
        );
      }
      final fab = _neo(tester, 'nav.scanner.fab');
      expect(
        (fab.width, fab.height, fab.color, fab.shadow),
        (60.0, 60.0, AppColors.sun, AppShadows.drop4),
      );
      expect(AppColors.sun, const Color(0xFFFED170));
    },
  );

  testWidgets('L01a9 rótulos: "Início" 11/800 → 700 (a 01 declara a Figtree até 700, D-246), os inativos 11/600 #5B544B, '
      '"Scanner" 11/700', (tester) async {
    await _abrir(tester);
    TextStyle s(String key) =>
        tester.widget<AppText>(find.byKey(ValueKey(key))).span.style!;
    expect(s('nav.home.label'), AppTextStyles.micro11Bold);
    expect(
      (s('nav.home.label').fontSize, s('nav.home.label').fontWeight),
      (11.0, FontWeight.w700),
    );
    for (final id in ['library', 'clubs', 'profile']) {
      expect(s('nav.$id.label'), AppTextStyles.navLabel, reason: id);
    }
    expect(AppTextStyles.navLabel.fontWeight, FontWeight.w600);
    expect(AppTextStyles.navLabel.color, const Color(0xFF5B544B));
    expect(
      appText01(tester, 'i01.nav.scanner.label').span.style,
      AppTextStyles.micro11Bold,
    );
  });

  testWidgets('L01a9 semântica: "Navegação principal" com os 5 links (Início selecionado, o Scanner pelo aria-label); '
      'o FAB e o degradê fora', (tester) async {
    final semantics = tester.ensureSemantics();
    await _abrir(tester);
    expect(find.semantics.byLabel('Navegação principal'), findsOneWidget);
    final links = linksDaSecao('Navegação principal');
    expect(links.map((n) => n.label), [
      'Início',
      'Biblioteca',
      'Scanner: escanear livro ou página',
      'Clubes',
      'Perfil',
    ]);
    expect(
      links.first.getSemanticsData().flagsCollection.isSelected,
      Tristate.isTrue,
    );
    for (final n in links.skip(1)) {
      expect(
        n.getSemanticsData().flagsCollection.isSelected,
        isNot(Tristate.isTrue),
        reason: n.label,
      );
    }
    for (final w in [find.byType(BottomFade), ini('i01.nav.scanner.fab')]) {
      expect(
        find.descendant(
          of: w,
          matching: find.byType(ExcludeSemantics),
          matchRoot: true,
        ),
        findsAtLeast(1),
      );
    }
    semantics.dispose();
  });

  testWidgets('L01a9 toques: as abas trocam de ramo; o item e o círculo do Scanner (até a borda de cima) abrem o scanner por '
      'cima (D-08)', (tester) async {
    await _abrir(tester);
    for (final (id, rota) in [
      ('library', '/biblioteca'),
      ('clubs', '/clubes'),
      ('profile', '/perfil'),
      ('home', '/inicio'),
    ]) {
      await tocar01(tester, 'i01.nav.$id');
      expect(rotaAtual(tester), rota, reason: id);
    }
    await tocar01(tester, 'i01.nav.scanner.label');
    expect(rotaAtual(tester), '/scanner');
    await _voltar(tester);
    expect(rotaAtual(tester), '/inicio');
    // a 4 px do topo do círculo (2529,5): fora da barra, ainda no FAB
    await tester.tapAt(const Offset(195, 2533.5));
    await tester.pumpAndSettle();
    expect(rotaAtual(tester), '/scanner');
  });

  testWidgets(
    'L01a9 captura: a barra e o degradê no canvas da prancha (gate visual fora do teste)',
    (tester) async {
      await _abrir(tester);
      final image = await capturar01(tester, 't03_L01a9');
      expect((image.width, image.height), (1170, 7950));
    },
  );
}
