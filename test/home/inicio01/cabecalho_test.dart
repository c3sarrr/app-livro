// T03.6 — fase L01a1 (cabeçalho e título) contra a prancha 01 (`kRef01`): a lupa nova ao lado do sino, sem ação
// (D-243 b), e o resto como na v1. Arnês: `test/support/fase_inicio.dart` (as seções na posição da prancha até a
// troca; o app depois). Recorte do gate visual: y 54–240,16 (`docs/design/fases/L01a1_cabecalho.md`).
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_inicio.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/home/presentation/sections/header_section.dart';
import 'package:app_leitura/features/home/presentation/sections/headline_section.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../reference/inicio2/referencias_inicio2.dart';
import '../../support/fase_inicio.dart';
import '../../support/load_fonts.dart';

const _secoes = ['i01.header', 'i01.headline'];

Future<void> _abrir(WidgetTester tester, {VoidCallback? onSearchTap}) =>
    abrirSecoes01(tester, {
      'i01.header': HeaderSection(
        onNotificationsTap: () {},
        onSearchTap: onSearchTap ?? HomeScreen.onSearch,
      ),
      'i01.headline': const HeadlineSection(),
    });

NeoBox _caixa(WidgetTester tester, String id) => tester.widget<NeoBox>(
  find.descendant(of: ini(id), matching: find.byType(NeoBox)).first,
);

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'L01a1 geometria: os 13 ids com widget (12 do cabeçalho + o título)',
    (tester) async {
      await _abrir(tester);
      expect(idsDasSecoes(kRef01, _secoes), hasLength(13));
      expect(geometria01(tester, _secoes), isEmpty);
    },
  );

  testWidgets(
    'L01a1 texto: "Boa noite," / "Marina" e o título em 2 linhas, com as baselines da prancha',
    (tester) async {
      await _abrir(tester);
      expect(texto01(tester, _secoes), isEmpty);
    },
  );

  testWidgets(
    'L01a1 estilo: a lupa é o círculo do sino — 48, #FFFAF1, borda 1,5 tinta — com o ícone novo 22',
    (tester) async {
      await _abrir(tester);
      final lupa = _caixa(tester, 'i01.header.search');
      final sino = _caixa(tester, 'i01.header.bell');
      for (final b in [lupa, sino]) {
        expect((b.width, b.height), (48.0, 48.0));
        expect(b.color, AppColors.surface);
        expect(b.border, const BorderSide(width: 1.5, color: AppColors.ink));
        expect(b.radius, BorderRadius.circular(24));
        expect(b.shadow, isNull);
      }
      final icone = tester.widget<AppSvg>(ini('i01.header.search.icon'));
      expect((icone.asset, icone.size), (AppIconsInicio.search, 22.0));
      expect(
        tester.widget<AppSvg>(ini('i01.header.bell.icon')).asset,
        AppIcons.bell,
      );
      // gap 8 entre os dois, o grupo encostado na direita
      expect(
        tester.getRect(ini('i01.header.bell')).left -
            tester.getRect(ini('i01.header.search')).right,
        8,
      );
    },
  );

  testWidgets(
    'L01a1 semântica: o link "Buscar livros" antes do sino; os ícones fora da árvore',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _abrir(tester);
      final lupa = tester.getSemantics(ini('i01.header.search'));
      expect(lupa.label, 'Buscar livros');
      expect(lupa.getSemanticsData().flagsCollection.isLink, isTrue);
      expect(lupa.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      final sino = tester.getSemantics(ini('i01.header.bell'));
      expect(sino.label, 'Notificações, 2 novas');
      // ordem do arquivo: a lupa vem antes do sino
      final ordem = <String>[];
      void visitar(SemanticsNode n) {
        if (n.label == 'Buscar livros' || n.label == 'Notificações, 2 novas') {
          ordem.add(n.label);
        }
        n.visitChildren((c) {
          visitar(c);
          return true;
        });
      }

      visitar(
        tester
            .binding
            .renderViews
            .first
            .owner!
            .semanticsOwner!
            .rootSemanticsNode!,
      );
      expect(ordem, ['Buscar livros', 'Notificações, 2 novas']);
      // o ícone não tem nó próprio
      expect(
        find.semantics.byPredicate((n) => n.label.contains('search')),
        findsNothing,
      );
      semantics.dispose();
    },
  );

  testWidgets(
    'L01a1 toque na lupa: chama o callback da seção; a Início passa o "sem ação" (D-243 b)',
    (tester) async {
      var toques = 0;
      await _abrir(tester, onSearchTap: () => toques++);
      await tester.tap(ini('i01.header.search'));
      await tester.pumpAndSettle();
      expect(toques, 1);
      // o da Início não faz nada (nem navega, nem lança): a busca não tem prancha (C14)
      expect(HomeScreen.onSearch, returnsNormally);
    },
  );

  testWidgets(
    'L01a1 captura: o cabeçalho e o título no canvas da prancha (gate visual fora do teste)',
    (tester) async {
      await _abrir(tester);
      final image = await capturar01(tester, 't03_L01a1');
      expect((image.width, image.height), (1170, 7950));
    },
  );
}
