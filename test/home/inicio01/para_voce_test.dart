// T03.11 — fase L01a6 ("Para você") contra a prancha 01 (`kRef01`) e as larguras 360/430: os mesmos três desenhos
// da v1 com os livros da 01 — Esaú e Jacó (a mancha, "Esaú / e Jacó" na serifada 22), Memorial de Aires (os traços)
// e Casa de Pensão (o arco). A seção mudou no lugar (só os dados e os textos das capas). Recorte do gate visual: y
// 1456,52–1811,62 (`docs/design/fases/L01a6_para_voce.md`).
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/tokens/app_radii.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pill.dart';
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/covers/casa_de_pensao_cover.dart';
import 'package:app_leitura/features/home/presentation/covers/esau_e_jaco_cover.dart';
import 'package:app_leitura/features/home/presentation/covers/memorial_de_aires_cover.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/mundo_2026_09_20.dart';
import '../../fixtures/telas/inicio01.dart';
import '../../reference/inicio2/referencias_inicio2.dart';
import '../../reference/inicio2_larguras/referencias_inicio2_larguras.dart';
import '../../support/fase_inicio.dart';
import '../../support/load_fonts.dart';

const _secoes = ['i01.forYou'];

Future<void> _abrir(WidgetTester tester, {LeitorRefPrancha prancha = kRef01}) =>
    abrirInicio01(tester, prancha: prancha);

/// A fixture `t01` com outro "Para você".
final class _ComParaVoce implements SyncHomeRepository {
  const _ComParaVoce(this.paraVoce);

  final ForYou paraVoce;

  @override
  HomeSnapshot snapshot(DateTime now) {
    final s = TelaInicio01.snapshot(now);
    return HomeSnapshot(
      now: s.now,
      user: s.user,
      continueReading: s.continueReading,
      alsoReading: s.alsoReading,
      readingDay: s.readingDay,
      dailyReview: s.dailyReview,
      forYou: paraVoce,
      club: s.club,
      recent: s.recent,
    );
  }

  @override
  Stream<HomeSnapshot> watch(DateTime Function() clock) => const Stream.empty();
}

/// Voltar do sistema: fecha a rota do topo (de volta à Início).
Future<void> _voltar(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

String _texto(WidgetTester tester, String key) =>
    tester.widget<AppText>(find.byKey(ValueKey(key))).span.toPlainText();

TextStyle _estilo(WidgetTester tester, String key) =>
    tester.widget<AppText>(find.byKey(ValueKey(key))).span.style!;

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'L01a6 geometria: os 41 ids (o carrossel de 0 a 390, o 3º item cortado em 390)',
    (tester) async {
      await _abrir(tester);
      expect(idsDasSecoes(kRef01, _secoes), hasLength(41));
      expect(geometria01(tester, _secoes), isEmpty);
    },
  );

  testWidgets(
    'L01a6 texto: título, "Ver tudo", o motivo, as capas ("Esaú / e Jacó", "Memorial / de Aires", '
    '"Casa de / Pensão" e os autores) e os títulos e autores dos itens nas baselines da prancha',
    (tester) async {
      await _abrir(tester);
      expect(texto01(tester, _secoes), isEmpty);
    },
  );

  for (final tela in ['01w360', '01w430']) {
    testWidgets(
      'L01a6 a ${tela.substring(3)} px: geometria e texto da prancha medida nessa largura',
      (tester) async {
        final ref = kRefInicio2Larguras[tela]!;
        await _abrir(tester, prancha: ref);
        expect(geometria01(tester, _secoes, prancha: ref), isEmpty);
        expect(texto01(tester, _secoes, prancha: ref), isEmpty);
      },
    );
  }

  testWidgets(
    'L01a6 capas: os desenhos da v1 (coral com a mancha, azul com os traços, verde com o arco) com os '
    'textos da 01 — "Esaú / e Jacó" Instrument Serif 22 lh 0,95 tinta, os outros 26 creme',
    (tester) async {
      await _abrir(tester);
      expect(find.byType(EsauEJacoCover), findsOneWidget);
      expect(find.byType(MemorialDeAiresCover), findsOneWidget);
      expect(find.byType(CasaDePensaoCover), findsOneWidget);
      for (final (i, cor) in [
        (1, AppColors.flame),
        (2, AppColors.azure),
        (3, AppColors.emerald),
      ]) {
        final c = tester.widget<NeoBox>(
          find.byKey(ValueKey('forYou.item$i.cover')),
        );
        expect((c.width, c.height, c.color), (116.0, 174.0, cor));
        expect(c.radius, AppRadii.coverL);
        expect(c.border, const BorderSide(width: 1.5, color: AppColors.ink));
        expect((c.shadow, c.clip), (null, true));
      }
      expect(AppColors.emerald, const Color(0xFF00995E));
      expect(_texto(tester, 'forYou.item1.cover.title'), 'Esaú\ne Jacó');
      final s1 = _estilo(tester, 'forYou.item1.cover.title');
      expect(s1, AppTextStyles.coverTitle22Ink);
      expect(
        (s1.fontFamily, s1.fontSize, s1.height, s1.color),
        ('InstrumentSerif', 22.0, 0.95, AppColors.ink),
      );
      expect(_texto(tester, 'forYou.item2.cover.title'), 'Memorial\nde Aires');
      expect(_texto(tester, 'forYou.item3.cover.title'), 'Casa de\nPensão');
      for (final i in [2, 3]) {
        expect(
          _estilo(tester, 'forYou.item$i.cover.title'),
          AppTextStyles.coverTitle26,
        );
      }
      expect(_texto(tester, 'forYou.item1.cover.author'), 'MACHADO DE ASSIS');
      expect(
        _estilo(tester, 'forYou.item1.cover.author'),
        AppTextStyles.coverAuthorFlame,
      );
      expect(_texto(tester, 'forYou.item2.cover.author'), 'MACHADO DE ASSIS');
      expect(_texto(tester, 'forYou.item3.cover.author'), 'ALUÍSIO AZEVEDO');
    },
  );

  testWidgets('L01a6 cabeçalho, motivo e itens: os estilos da v1 (Bricolage 24, "Ver tudo" 14/700 + seta 18, '
      'pílula do motivo, título 14/700 e autor 13/500)', (tester) async {
    await _abrir(tester);
    expect(_estilo(tester, 'forYou.title'), AppTextStyles.sectionTitleL);
    expect(
      tester
          .widget<AppSvg>(find.byKey(const ValueKey('forYou.seeAll.icon')))
          .asset,
      AppIcons.arrowRight,
    );
    final chip = tester.widget<Pill>(
      find.byKey(const ValueKey('forYou.reasonChip')),
    );
    expect(
      (chip.color, chip.padding),
      (AppColors.surface, const EdgeInsets.fromLTRB(10, 7, 12, 7)),
    );
    expect(
      appText01(tester, 'i01.forYou.reasonChip').span.toPlainText(),
      'Porque você lê Machado de Assis',
    );
    for (final i in [1, 2, 3]) {
      expect(_estilo(tester, 'forYou.item$i.title'), AppTextStyles.label14Bold);
      expect(
        _estilo(tester, 'forYou.item$i.author'),
        AppTextStyles.body13Muted,
      );
    }
    // só o 1º título tem nowrap + ellipsis no arquivo
    final t1 = tester.widget<AppText>(
      find.byKey(const ValueKey('forYou.item1.title')),
    );
    expect((t1.maxLines, t1.ellipsis), (1, true));
  });

  testWidgets(
    'L01a6 dados: os livros e o motivo do mundo de referência (D-241); o 3º de outro autor',
    (tester) async {
      await _abrir(tester);
      final para = TelaInicio01.snapshot(TelaInicio01.agora).forYou!;
      expect(para.reasonAuthor, mundoReferencia.paraVoceAutor);
      expect(para.items.map((b) => b.title), [
        'Esaú e Jacó',
        'Memorial de Aires',
        'Casa de Pensão',
      ]);
      expect(para.items.map((b) => b.author), [
        'Machado de Assis',
        'Machado de Assis',
        'Aluísio Azevedo',
      ]);
      expect(para.items.map((b) => (b.cover as DesignedCover).art), [
        CoverArt.esauEJaco,
        CoverArt.memorialDeAires,
        CoverArt.casaDePensao,
      ]);
      for (final (i, b) in para.items.indexed) {
        expect(_texto(tester, 'forYou.item${i + 1}.title'), b.title);
        expect(_texto(tester, 'forYou.item${i + 1}.author'), b.author);
      }
    },
  );

  testWidgets(
    'as capas desenhadas são só os trios do arquivo: desenho e foto misturados disparam o assert da seção',
    (tester) async {
      final [esau, memorial, _] = TelaInicio01.paraVoce.items;
      await abrirInicio01(
        tester,
        repositorio: _ComParaVoce(
          ForYou(
            reasonAuthor: 'Machado de Assis',
            items: [
              esau,
              memorial,
              const Book(
                id: '9788535914849',
                title: 'Dom Casmurro',
                author: 'Machado de Assis',
                cover: PhotoCover(isbn13: '9788535914849'),
              ),
            ],
          ),
        ),
      );
      expect(
        tester.takeException(),
        isA<AssertionError>().having(
          (e) => '${e.message}',
          'mensagem',
          contains('Esaú e Jacó, Memorial de Aires e Casa de Pensão'),
        ),
      );
    },
  );

  testWidgets(
    'L01a6 semântica: a seção, o h3, os 3 itens e "Ver tudo" como links; o brilho do motivo fora',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _abrir(tester);
      expect(find.semantics.byLabel('Para você'), findsAtLeast(1));
      final links = linksDaSecao('Para você').map((n) => n.label).toList();
      expect(links, hasLength(4));
      expect(links.where((l) => l.contains('Esaú e Jacó')), hasLength(1));
      expect(links, contains('Ver tudo'));
      expect(
        find.descendant(
          of: ini('i01.forYou.reasonChip.icon'),
          matching: find.byType(ExcludeSemantics),
        ),
        findsAtLeast(1),
      );
      semantics.dispose();
    },
  );

  testWidgets(
    'L01a6 toques: os itens abrem a página do livro e "Ver tudo", a lista "Para você"',
    (tester) async {
      await _abrir(tester);
      for (final (i, slug) in [
        (1, 'esau-e-jaco'),
        (2, 'memorial-de-aires'),
        (3, 'casa-de-pensao'),
      ]) {
        await tocar01(tester, 'i01.forYou.item$i');
        expect(rotaAtual(tester), '/livro/$slug');
        await _voltar(tester);
      }
      await tocar01(tester, 'i01.forYou.seeAll');
      expect(rotaAtual(tester), '/para-voce');
    },
  );

  testWidgets(
    'L01a6 captura: a seção no canvas da prancha (gate visual fora do teste)',
    (tester) async {
      await _abrir(tester);
      final image = await capturar01(tester, 't03_L01a6');
      expect((image.width, image.height), (1170, 7950));
    },
  );
}
