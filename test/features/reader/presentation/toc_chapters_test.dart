// G15.3 — a aba Capítulos (tela 27): a faixa do clube (D-149), as linhas (numeral, título, marcas, página, "lido"),
// o capítulo atual no cartão com o anel e "você está na pág. N", as partes (D-153), a lista sem sumário (D-21), a
// altura inicial (o atual a 378,4 do topo da lista; numa lista baixa, inteiro acima do esmaecido), o toque (D-151),
// a semântica e o Noite.
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/application/toc_view.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/toc_chapters.dart';
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

ScrollPosition _rolagem(WidgetTester tester) => tester
    .state<ScrollableState>(
      find.descendant(
        of: chave('toc.sheet.chapters'),
        matching: find.byType(Scrollable),
      ),
    )
    .position;

void main() {
  setUpAll(loadAppFonts);

  testWidgets('faixa do clube: os textos, a seta avisa; sem clube, sem faixa', (
    tester,
  ) async {
    final m = await montarSumario(tester);
    expect(
      _texto(tester, 'toc.sheet.club.kicker'),
      'LEITORAS DE CAPITU · QUI 24/9',
    );
    expect(_texto(tester, 'toc.sheet.club.goal'), 'Até o cap. L · faltam 18');
    expect(
      tester.getRect(chave('toc.sheet.club')),
      perto(const Rect.fromLTWH(25.5, 251.1, 339, 61)),
    );
    await tester.tap(chave('toc.sheet.club'));
    expect(m.clube, 1);
    // o leitor de tela: o nome como é e o dia por extenso, num link só
    final h = tester.ensureSemantics();
    expect(
      tester.getSemantics(chave('toc.sheet.club')),
      isSemantics(
        label: 'Leitoras de Capitu, quinta 24/9, Até o cap. L, faltam 18',
        isLink: true,
      ),
    );
    h.dispose();
    await montarSumario(tester, view: vista(clube: null));
    expect(chave('toc.sheet.club'), findsNothing);
    // sem a faixa, a lista começa 8 abaixo das abas
    expect(
      tester.getRect(chave('toc.sheet.chapters')).top,
      moreOrLessEquals(112 + 81.1 + 46 + 8, epsilon: 0.01),
    );
  });

  testWidgets(
    'linhas: numeral, título, página e "lido"; a linha sem lugar não é botão',
    (tester) async {
      final h = tester.ensureSemantics();
      await montarSumario(
        tester,
        view: vista(
          atual: null,
          linhas: [
            linha(
              0,
              numeral: 'XXV',
              titulo: 'No Passeio Público',
              pagina: 121,
              lido: true,
              marcas: marcasDoXxxii(),
            ),
            linha(
              1,
              numeral: 'XXVI',
              titulo: 'Sem lugar',
              pagina: null,
              tocavel: false,
            ),
          ],
        ),
      );
      expect(_texto(tester, 'toc.sheet.chapters.ch1.numeral'), 'XXV');
      expect(
        _texto(tester, 'toc.sheet.chapters.ch1.title'),
        'No Passeio Público',
      );
      expect(_texto(tester, 'toc.sheet.chapters.ch1.page'), '121');
      expect(_texto(tester, 'toc.sheet.chapters.ch1.marks.count'), '5');
      expect(chave('toc.sheet.chapters.ch1.read'), findsOneWidget);
      expect(chave('toc.sheet.chapters.ch2.read'), findsNothing);
      expect(chave('toc.sheet.chapters.ch2.status'), findsOneWidget);
      expect(chave('toc.sheet.chapters.ch1.marks.highlight'), findsOneWidget);
      expect(chave('toc.sheet.chapters.ch1.marks.ink'), findsOneWidget);
      expect(chave('toc.sheet.chapters.ch1.marks.handwritten'), findsOneWidget);
      expect(
        tester.getSemantics(chave('toc.sheet.chapters.ch1.link')),
        isSemantics(
          label: 'XXV, No Passeio Público, página 121, 5 marcas, lido',
          isButton: true,
        ),
      );
      expect(
        tester.getSemantics(chave('toc.sheet.chapters.ch2.link')),
        isSemantics(isButton: false),
      );
      h.dispose();
    },
  );

  testWidgets(
    'a linha da prancha: 51,2 de altura; numeral 52; título depois de 10; página 30; "lido" 18',
    (tester) async {
      await montarSumario(
        tester,
        view: vista(
          atual: null,
          clube: null,
          linhas: [
            linha(
              0,
              numeral: 'XXV',
              titulo: 'No Passeio Público',
              pagina: 121,
              lido: true,
            ),
          ],
        ),
      );
      final l = tester.getRect(chave('toc.sheet.chapters.ch1'));
      expect(l, perto(Rect.fromLTWH(25.5, l.top, 339, 51.2)));
      expect(
        tester.getRect(chave('toc.sheet.chapters.ch1.numeral')).left - l.left,
        moreOrLessEquals(10, epsilon: 0.01),
      );
      expect(
        tester.getRect(chave('toc.sheet.chapters.ch1.title')).left - l.left,
        moreOrLessEquals(72, epsilon: 0.01),
      );
      expect(tester.getRect(chave('toc.sheet.chapters.ch1.page')).width, 30);
      expect(
        tester.getRect(chave('toc.sheet.chapters.ch1.read')).size,
        const Size(18, 18),
      );
    },
  );

  testWidgets(
    'numeral e página largos transbordam no espaço ao lado, inteiros (D-157): o título não anda',
    (tester) async {
      await montarSumario(
        tester,
        view: vista(
          atual: null,
          clube: null,
          linhas: [
            linha(137, numeral: 'CXXXVIII', titulo: 'Fim', pagina: 1234),
            linha(
              87,
              numeral: 'LXXXVIII',
              titulo: 'Um pretexto honesto',
              pagina: 9999,
              atual: true,
              progresso: 0.5,
            ),
          ],
        ),
      );
      Rect texto(String id) => tester.getRect(
        find.descendant(
          of: chave(id),
          matching: find.byType(AppText),
          matchRoot: true,
        ),
      );
      for (final (ch, titulo) in [(138, 72.0), (88, 72.0)]) {
        final id = 'toc.sheet.chapters.ch$ch';
        final caixa = tester.getRect(chave('$id.numeral'));
        expect(caixa.width, moreOrLessEquals(52, epsilon: 0.01));
        final n = texto('$id.numeral');
        expect(n.left, moreOrLessEquals(caixa.left, epsilon: 0.01));
        expect(
          n.width,
          greaterThan(52),
          reason: 'o numeral inteiro, numa linha',
        );
        expect(
          n.right,
          lessThan(caixa.right + 10),
          reason: 'só no espaço de 10',
        );
        final pag = tester.getRect(chave('$id.page'));
        expect(pag.width, moreOrLessEquals(30, epsilon: 0.01));
        final p = texto('$id.page');
        expect(p.right, moreOrLessEquals(pag.right, epsilon: 0.01));
        expect(
          p.width,
          greaterThan(30),
          reason: 'a página inteira, alinhada à direita',
        );
        expect(p.left, greaterThan(pag.left - 10));
        final linhaRect = tester.getRect(chave(ch == 138 ? id : '$id.row'));
        expect(
          tester.getRect(chave('$id.title')).left - linhaRect.left,
          moreOrLessEquals(ch == 138 ? titulo : titulo - 10, epsilon: 0.01),
        );
      }
    },
  );

  testWidgets('sem numeral em nenhuma linha: a coluna do numeral some', (
    tester,
  ) async {
    await montarSumario(
      tester,
      view: vista(
        atual: null,
        linhas: [
          const TocRow(
            kind: TocRowKind.chapter,
            entry: 0,
            chapter: 0,
            title: 'Prefácio',
            page: 1,
            target: (spine: 0, offset: 0),
          ),
        ],
      ),
    );
    final l = tester.getRect(chave('toc.sheet.chapters.ch1'));
    expect(
      tester.getRect(chave('toc.sheet.chapters.ch1.title')).left - l.left,
      moreOrLessEquals(10, epsilon: 0.01),
    );
    expect(chave('toc.sheet.chapters.ch1.numeral'), findsNothing);
  });

  testWidgets(
    'capítulo atual: cartão com o anel, "você está na pág. 159" e as marcas',
    (tester) async {
      final h = tester.ensureSemantics();
      await montarSumario(
        tester,
        view: vista(
          atual: null,
          linhas: [
            linha(
              31,
              numeral: 'XXXII',
              titulo: 'Olhos de ressaca',
              pagina: 157,
              atual: true,
              progresso: 18 / 44,
              marcas: marcasDoXxxii(),
            ),
          ],
        ),
      );
      final cartao = tester.widget<NeoBox>(
        chave('toc.sheet.chapters.ch32.link'),
      );
      expect(cartao.shadow, const Offset(2, 2));
      expect(cartao.radius, BorderRadius.circular(16));
      expect(
        _texto(tester, 'toc.sheet.chapters.ch32.youAreHere.text'),
        'você está na pág. 159',
      );
      final anel = tester.widget<CustomPaint>(
        chave('toc.sheet.chapters.ch32.progressRing'),
      );
      expect((anel.painter! as TocProgressRingPainter).progress, 18 / 44);
      expect(
        tester.getSemantics(chave('toc.sheet.chapters.ch32.link')),
        isSemantics(
          label: 'XXXII, Olhos de ressaca, página 157, 5 marcas, lendo, você está na pág. 159',
          isButton: true,
        ),
      );
      h.dispose();
    },
  );

  testWidgets(
    'a parte: título pequeno em maiúsculas, sem página; tocar vai ao começo dela',
    (tester) async {
      final m = await montarSumario(
        tester,
        view: vista(
          atual: null,
          linhas: [
            const TocRow(
              kind: TocRowKind.part,
              entry: 0,
              title: 'Parte I',
              target: (spine: 0, offset: 0),
            ),
            linha(0),
          ],
        ),
      );
      expect(_texto(tester, 'toc.sheet.chapters.part0.title'), 'PARTE I');
      // o leitor de tela lê como no livro, não letra por letra
      final h = tester.ensureSemantics();
      expect(
        tester.getSemantics(chave('toc.sheet.chapters.part0')),
        isSemantics(label: 'Parte I', isHeader: true, isButton: true),
      );
      h.dispose();
      await tester.tap(chave('toc.sheet.chapters.part0'));
      expect(m.capitulos.single.kind, TocRowKind.part);
    },
  );

  testWidgets('sem sumário (D-21): "Este livro não tem sumário."', (
    tester,
  ) async {
    await montarSumario(
      tester,
      view: vista(linhas: const [], capitulos: null, clube: null),
    );
    expect(_texto(tester, 'toc.sheet.empty'), 'Este livro não tem sumário.');
    // o índice que não se leu: não diz que o livro não tem sumário (só a moldura)
    await montarSumario(
      tester,
      view: vista(
        linhas: const [],
        capitulos: null,
        clube: null,
        tocFalhou: true,
      ),
    );
    expect(chave('toc.sheet.empty'), findsNothing);
    expect(chave('toc.sheet.chapters'), findsOneWidget);
  });

  testWidgets('tocar numa linha pede o capítulo; a linha sem lugar não pede', (
    tester,
  ) async {
    final m = await montarSumario(
      tester,
      view: vista(atual: null, linhas: [linha(0), linha(1, tocavel: false)]),
    );
    await tester.tap(chave('toc.sheet.chapters.ch1'));
    await tester.tap(chave('toc.sheet.chapters.ch2'));
    expect(m.capitulos.map((r) => r.chapter), [0]);
  });

  testWidgets('altura inicial: o atual a 378,4 do topo da lista', (
    tester,
  ) async {
    await montarSumario(tester, view: vista(n: 30, atual: 12));
    final lista = tester.getRect(chave('toc.sheet.chapters.list'));
    final atual = tester.getRect(chave('toc.sheet.chapters.ch13.link'));
    expect(
      atual.top - lista.top,
      moreOrLessEquals(12 * 51.2 + 6, epsilon: 0.01),
    );
    expect(
      _rolagem(tester).pixels,
      moreOrLessEquals(12 * 51.2 + 6 - 378.4, epsilon: 0.01),
    );
    final topo = tester.getRect(chave('toc.sheet.chapters')).top;
    expect(atual.top - (topo - 6), moreOrLessEquals(378.4, epsilon: 0.01));
  });

  testWidgets(
    'altura inicial: perto do começo, a lista no topo; no fim, até o fim',
    (tester) async {
      await montarSumario(tester, view: vista(n: 30, atual: 2));
      expect(_rolagem(tester).pixels, 0);
      await montarSumario(tester, view: vista(n: 30, atual: 29));
      final p = _rolagem(tester);
      expect(p.pixels, p.maxScrollExtent);
    },
  );

  testWidgets(
    'altura inicial numa tela baixa: o cartão inteiro acima do esmaecido de 40',
    (tester) async {
      await montarSumario(
        tester,
        view: vista(n: 30, atual: 12),
        tela: const Size(390, 640),
      );
      final caixa = tester.getRect(chave('toc.sheet.chapters'));
      final atual = tester.getRect(chave('toc.sheet.chapters.ch13.link'));
      expect(atual.bottom, lessThanOrEqualTo(caixa.bottom - 40 + 0.01));
      expect(atual.top, greaterThanOrEqualTo(caixa.top + 22 - 0.01));
    },
  );

  testWidgets(
    'Noite: o cartão e as linhas nas cores das ilhas; o anel e a pílula nas cores dela',
    (tester) async {
      await montarSumario(tester, papel: ReaderPaper.noite);
      final cartao = tester.widget<NeoBox>(
        chave('toc.sheet.chapters.ch8.link'),
      );
      expect(cartao.color, AppColors.islandNight);
      expect(cartao.border!.color, AppColors.inkNight);
      expect(
        tester
            .widget<AppText>(
              find.descendant(
                of: chave('toc.sheet.chapters.ch9.title'),
                matching: find.byType(AppText),
              ),
            )
            .span
            .style!
            .color,
        AppColors.inkNight,
      );
      expect(
        tester.widget<NeoBox>(chave('toc.sheet.chapters.ch8.youAreHere')).color,
        AppColors.flame,
      );
    },
  );
}
