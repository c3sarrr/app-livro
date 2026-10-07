// G15.4 — a aba Marcadas (tela 27b): os cartões ("pág. N", "cap. … · …", "você está aqui", o excerto em até 3 linhas,
// a data), a sombra só no da página atual, a fita que tira e devolve (D-152) com o leitor de tela, o toque que abre a
// página (D-151), a dica no fim (sozinha sem marcas) e o Noite.
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/load_fonts.dart';
import 'toc_support.dart';

String _texto(WidgetTester tester, String id) => tester
    .widget<AppText>(
      find
          .descendant(
            of: chave(id),
            matching: find.byType(AppText),
            matchRoot: true,
          )
          .first,
    )
    .span
    .toPlainText();

Future<MesaDoSumario> _marcadas(
  WidgetTester tester, {
  List<dynamic>? cartoes,
  ReaderPaper papel = ReaderPaper.creme,
}) async {
  final m = await montarSumario(
    tester,
    papel: papel,
    view: vista(
      cartoes: [
        ...?cartoes?.cast(),
        if (cartoes == null) ...[
          cartao(1, pagina: 3),
          cartao(
            2,
            pagina: 6,
            capitulo: 'cap. II · Do livro',
            excerto: 'Agora que expliquei o título, passo a escrever o livro…',
            data: 'marcada em 3 set',
          ),
          cartao(
            3,
            pagina: 159,
            aqui: true,
            capitulo: 'cap. XXXII · Olhos de ressaca',
            excerto:
                'Retórica dos namorados, dá-me uma comparação exata e poética…',
            data: 'marcada hoje',
          ),
        ],
      ],
    ),
  );
  await tester.tap(chave('toc.sheet.tabs.bookmarks'));
  await tester.pump();
  return m;
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'os 3 cartões: página, capítulo, excerto e data; "você está aqui" e a sombra só no da página atual',
    (tester) async {
      await _marcadas(tester);
      expect(
        _texto(tester, 'bm.sheet.bookmarks.item1.head.page.text'),
        'pág. 3',
      );
      expect(
        _texto(tester, 'bm.sheet.bookmarks.item1.head.chapter'),
        'cap. I · Do título',
      );
      expect(
        _texto(tester, 'bm.sheet.bookmarks.item2.date'),
        'marcada em 3 set',
      );
      expect(
        _texto(tester, 'bm.sheet.bookmarks.item3.head.here.text'),
        'você está aqui',
      );
      expect(chave('bm.sheet.bookmarks.item1.head.here'), findsNothing);
      expect(
        tester.widget<NeoBox>(chave('bm.sheet.bookmarks.item3.row')).shadow,
        const Offset(2, 2),
      );
      expect(
        tester.widget<NeoBox>(chave('bm.sheet.bookmarks.item1.row')).shadow,
        isNull,
      );
      expect(
        tester.getRect(chave('bm.sheet.bookmarks.item1.row')),
        perto(const Rect.fromLTWH(25.5, 112 + 139.1, 339, 154.56), tol: 0.5),
      );
      expect(
        tester.getRect(chave('bm.sheet.bookmarks.item1.ribbon')),
        perto(const Rect.fromLTWH(313, 112 + 146.6, 44, 44)),
      );
      // a pílula "você está aqui" quebra para a 2ª linha do cabeçalho
      expect(
        tester.getRect(chave('bm.sheet.bookmarks.item3.head.here')).top,
        moreOrLessEquals(
          tester.getRect(chave('bm.sheet.bookmarks.item3.head')).top + 34,
          epsilon: 0.5,
        ),
      );
    },
  );

  testWidgets('o excerto em até 3 linhas; sem excerto, sem a linha', (
    tester,
  ) async {
    await _marcadas(
      tester,
      cartoes: [
        cartao(
          1,
          excerto: 'Uma noite destas, vindo da cidade para o Engenho Novo, encontrei no trem da Central um rapaz aqui do bairro, que eu conheço de vista e de chapéu…',
        ),
        cartao(2, pagina: 6, excerto: null),
      ],
    );
    final e = tester.renderObject<RenderAppText>(
      chave('bm.sheet.bookmarks.item1.excerpt'),
    );
    expect(e.debugLines(), hasLength(3));
    expect(chave('bm.sheet.bookmarks.item2.excerpt'), findsNothing);
  });

  testWidgets(
    'a fita: tirar e devolver (D-152), com o leitor de tela; o cartão abre a página',
    (tester) async {
      final h = tester.ensureSemantics();
      final m = await _marcadas(
        tester,
        cartoes: [cartao(1, pagina: 3), cartao(2, pagina: 6, marcada: false)],
      );
      expect(
        tester.getSemantics(chave('bm.sheet.bookmarks.item1.ribbon')),
        isSemantics(
          label: 'Tirar a marca da página 3',
          isToggled: true,
          hasToggledState: true,
          isButton: true,
        ),
      );
      expect(
        tester.getSemantics(chave('bm.sheet.bookmarks.item2.ribbon')),
        isSemantics(
          label: 'Marcar a página 6',
          isToggled: false,
          hasToggledState: true,
        ),
      );
      expect(
        tester
            .widget<AppSvg>(chave('bm.sheet.bookmarks.item1.ribbon.icon'))
            .asset,
        AppIconsLeitor.ribbonCoral,
      );
      expect(
        tester
            .widget<AppSvg>(chave('bm.sheet.bookmarks.item2.ribbon.icon'))
            .asset,
        AppIconsLeitor.ribbonEmpty,
      );
      await tester.tap(chave('bm.sheet.bookmarks.item1.ribbon'));
      await tester.tap(chave('bm.sheet.bookmarks.item2.ribbon'));
      expect(m.fitas.map((c) => c.page), [3, 6]);
      expect(
        tester.getSemantics(chave('bm.sheet.bookmarks.item2.link')),
        isSemantics(label: 'Abrir na página 6', isButton: true),
      );
      await tester.tap(chave('bm.sheet.bookmarks.item2.link'));
      expect(m.abertos.single.page, 6);
      expect(m.fitas, hasLength(2), reason: 'abrir não mexe na fita');
      h.dispose();
    },
  );

  testWidgets('a dica no fim; sem marcas, só ela', (tester) async {
    await _marcadas(tester);
    expect(
      _texto(tester, 'bm.sheet.hint.text'),
      'Toque na fita no alto do leitor para marcar ou desmarcar.',
    );
    expect(
      tester.getRect(chave('bm.sheet.hint')).top -
          tester.getRect(chave('bm.sheet.bookmarks.list')).bottom,
      moreOrLessEquals(18, epsilon: 0.01),
    );
    await _marcadas(tester, cartoes: const []);
    expect(chave('bm.sheet.bookmarks.item1'), findsNothing);
    expect(chave('bm.sheet.hint'), findsOneWidget);
  });

  testWidgets(
    'Noite: os cartões nas cores das ilhas; a fita tirada é a do Noite',
    (tester) async {
      await _marcadas(
        tester,
        papel: ReaderPaper.noite,
        cartoes: [cartao(1), cartao(2, pagina: 6, marcada: false)],
      );
      final c = tester.widget<NeoBox>(chave('bm.sheet.bookmarks.item1.row'));
      expect(c.color, AppColors.islandNight);
      expect(c.border!.color, AppColors.inkNight);
      expect(
        tester
            .widget<AppSvg>(chave('bm.sheet.bookmarks.item2.ribbon.icon'))
            .asset,
        AppIconsLeitor.ribbonEmptyNight,
      );
    },
  );
}
