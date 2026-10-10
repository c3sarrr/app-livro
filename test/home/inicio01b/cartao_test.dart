// T04.6 — L01b.1: o cartão do "Também lendo" com a sessão do cronômetro aberta (prancha 01b; R6, D-257). O botão da
// sessão é "um botão com dois estados" (mapa da G01.10) no lugar do play (ou do anel): rodando, o "pausar" amarelo 16;
// pausada, o "play" 18 — os dois com o aro coral de 3 (`box-shadow: 0 0 0 3px #FF552E`). A pílula não muda (D-252).
// Sessão de um livro fora da grade não muda nenhum cartão; com o cronômetro sem carregar (ou com falha), os cartões
// ficam os da 01.
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_inicio.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/circle_icon_button.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/sections/also_reading_section.dart';
import 'package:app_leitura/features/reading_session/data/paper_book_source.dart';
import 'package:app_leitura/features/reading_session/data/paper_timer_store.dart';
import 'package:app_leitura/features/reading_session/domain/open_paper_session.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/home_mock_repository.dart';
import '../../fixtures/paper_timer_fakes.dart';
import '../../fixtures/telas/inicio01.dart';
import '../../fixtures/telas/inicio01b.dart';
import '../../reference/inicio2/referencias_inicio2.dart';
import '../../support/app_text_finder.dart';
import '../../support/canvas.dart' show goldenRootKey;
import '../../support/capture.dart';
import '../../support/fase_inicio.dart';
import '../../support/load_fonts.dart';
import '../../support/pump_app.dart' show homeScrollPosition;

const _secoes = ['i01b.alsoReading'];

const _aro = BoxDecoration(
  shape: BoxShape.circle,
  boxShadow: [BoxShadow(color: AppColors.flame, spreadRadius: 3)],
);

/// Um livro de papel da estante que não está nos 2 cartões.
const PaperBook _cortico = PaperBook(
  book: Book(
    id: 'o-cortico',
    title: 'O Cortiço',
    author: 'Aluísio Azevedo',
    cover: PhotoCover(),
  ),
);

Future<void> _abrir(WidgetTester tester, {List<Override>? cronometro}) =>
    abrirInicio01(
      tester,
      prancha: kRef01b,
      safeTop: 47,
      safeBottom: 34,
      repositorio: const HomeMockRepository01b(),
      cronometro: cronometro ?? overridesDa01b(),
    );

/// O cronômetro com [sessao] aberta, na estante de papel da 01 (mais O Cortiço).
List<Override> _comSessao(OpenPaperSession sessao) => overridesDaSessao(
  store: MemoryPaperTimerStore({donoDaSessao: sessao}),
  livros: FixedPaperBookSource({
    ...estanteDePapel01().livros,
    _cortico.book.id: _cortico,
  }),
);

OpenPaperSession _sessaoDe(String livro) => OpenPaperSession.start(
  id: '01925a00-0000-7000-8000-0000000001b1',
  userBookId: livro,
  now: TelaInicio01b.agora.subtract(const Duration(minutes: 5)),
);

/// A loja da sessão que não abre (o kv ilegível de outro jeito): o cronômetro fica em erro.
final class _LojaQuebrada implements PaperTimerStore {
  @override
  Future<OpenPaperSession?> load(String owner) async =>
      throw StateError('kv fora do ar');

  @override
  Future<void> save(String owner, OpenPaperSession session) async {}

  @override
  Future<void> clear(String owner) async {}
}

T _w<T extends Widget>(WidgetTester tester, String id) =>
    tester.widget<T>(ini(id));

/// O aro em volta do botão [id] (o `DecoratedBox` logo acima dele), ou `null`.
BoxDecoration? _aroDe(WidgetTester tester, String id) {
  final aros = find.ancestor(
    of: ini(id),
    matching: find.byKey(ValueKey('${keyDoId(id)}.halo')),
  );
  if (aros.evaluate().isEmpty) return null;
  return tester.widget<DecoratedBox>(aros).decoration as BoxDecoration;
}

/// O retângulo a menos de 1e-3 de [r] (as posições somam frações da prancha em float32).
Matcher _perto(Rect r) => predicate<Rect>(
  (x) => [
    x.left - r.left,
    x.top - r.top,
    x.width - r.width,
    x.height - r.height,
  ].every((d) => d.abs() < 1e-3),
  '$r',
);

/// Rola a Início de [dy] (a mini-barra e o degradê da 01b cobrem o fim da tela).
Future<void> _rolar(WidgetTester tester, double dy) async {
  homeScrollPosition(tester).jumpTo(dy);
  await tester.pumpAndSettle();
}

/// Os nomes dos links da seção "Também lendo", em ordem.
List<String> _links() =>
    linksDaSecao('Também lendo').map((n) => n.label).toList();

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'L01b.1 geometria: os 33 ids da prancha (o botão da sessão 46 × 46 no lugar do play; a pausa 16 centrada)',
    (tester) async {
      await _abrir(tester);
      expect(idsDasSecoes(kRef01b, _secoes), hasLength(33));
      expect(geometria01(tester, _secoes, prancha: kRef01b), isEmpty);
    },
  );

  testWidgets(
    'L01b.1 texto: "Também lendo", "3", as capas, os títulos, os autores, "81%" e as pílulas nas baselines',
    (tester) async {
      await _abrir(tester);
      expect(texto01(tester, _secoes, prancha: kRef01b), isEmpty);
    },
  );

  testWidgets(
    'L01b.1 rodando: círculo 46 tinta com borda 1,5, o "pausar" amarelo 16 e o aro #FF552E de 3 (sombra '
    'dura, sem deslocamento); a pílula continua "Papel · 3h 40min" (D-252)',
    (tester) async {
      await _abrir(tester);
      const id = 'i01b.alsoReading.card1.play';
      final b = _w<CircleIconButton>(tester, id);
      expect((b.size, b.color), (46.0, AppColors.ink));
      expect(b.border, const BorderSide(width: 1.5, color: AppColors.ink));
      final icone = _w<AppSvg>(tester, '$id.icon');
      expect((icone.asset, icone.size), (AppIconsInicio.pause, 16.0));
      expect(_aroDe(tester, id), _aro);
      final sombra = _aro.boxShadow!.single;
      expect(AppColors.flame, const Color(0xFFFF552E));
      expect(
        (sombra.offset, sombra.blurRadius, sombra.spreadRadius),
        (Offset.zero, 0.0, 3.0),
      );
      expect(
        appText01(
          tester,
          'i01b.alsoReading.card1.meta',
          'Papel',
        ).span.toPlainText(),
        'Papel · 3h 40min',
      );
      // o anel do Orgulho (que não está em sessão) fica como na 01
      expect(ini('i01b.alsoReading.card2.ring'), findsOneWidget);
      expect(_aroDe(tester, 'i01b.alsoReading.card2.ring'), isNull);
    },
  );

  testWidgets(
    'L01b.1 o aro nos pixels: coral de 23 a 26 do centro, tinta dentro e o fundo do cartão fora',
    (tester) async {
      await _abrir(tester);
      final antes = tester.getCenter(ini('i01b.alsoReading.card1.play'));
      expect(antes.dx, closeTo(150.5, 1e-3));
      expect(antes.dy, closeTo(652.46, 1e-3));
      // na 01b a mini-barra (y ≥ 648) e o degradê cobrem o botão: o aro é conferido com a Início rolada
      await _rolar(tester, 200);
      final rgba = await rgbaOf(
        tester,
        await captureAt(tester, find.byKey(goldenRootKey)),
      );
      final largura = (kRef01b.canvas.width * 3).round();
      final centro = tester.getCenter(ini('i01b.alsoReading.card1.play'));
      expect(centro.dy, closeTo(452.46, 1e-3));
      Color cor(double dx, double dy) {
        final x = ((centro.dx + dx) * 3).floor();
        final y = ((centro.dy + dy) * 3).floor();
        final i = (y * largura + x) * 4;
        return Color.fromARGB(rgba[i + 3], rgba[i], rgba[i + 1], rgba[i + 2]);
      }

      for (final (dx, dy) in [
        (24.5, 0.0),
        (-24.5, 0.0),
        (0.0, 24.5),
        (0.0, -24.5),
      ]) {
        expect(cor(dx, dy), AppColors.flame, reason: 'aro em ($dx, $dy)');
        expect(
          cor(dx * 20 / 24.5, dy * 20 / 24.5),
          AppColors.ink,
          reason: 'botão em ($dx, $dy)',
        );
        expect(
          cor(dx * 28 / 24.5, dy * 28 / 24.5),
          AppColors.surface,
          reason: 'cartão em ($dx, $dy)',
        );
      }
    },
  );

  testWidgets(
    'D-257 pausada: o mesmo botão com o "play" amarelo 18, o mesmo aro e "Retomar leitura de Brás Cubas"',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _abrir(
        tester,
        cronometro: _comSessao(TelaInicio01b.sessao.pause(TelaInicio01b.agora)),
      );
      const id = 'i01b.alsoReading.card1.play';
      final icone = _w<AppSvg>(tester, '$id.icon');
      expect((icone.asset, icone.size), (AppIconsInicio.play, 18.0));
      expect(_aroDe(tester, id), _aro);
      final b = noDe(tester, id).getSemanticsData();
      expect(b.label, 'Retomar leitura de Brás Cubas');
      expect(b.flagsCollection.isButton, isTrue);
      expect(b.hasAction(SemanticsAction.tap), isTrue);
      semantics.dispose();
    },
  );

  testWidgets(
    'L01b.1 semântica rodando: a capa é o link "Memórias Póstumas de Brás Cubas", o botão é "Pausar leitura de '
    'Brás Cubas", o ícone e o aro ficam fora; o cartão do Orgulho continua link',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _abrir(tester);
      final b = noDe(tester, 'i01b.alsoReading.card1.play').getSemanticsData();
      expect(b.label, 'Pausar leitura de Brás Cubas');
      expect(b.flagsCollection.isButton, isTrue);
      expect(b.hasAction(SemanticsAction.tap), isTrue);
      final links = _links();
      expect(links.first, 'Memórias Póstumas de Brás Cubas');
      expect(links, hasLength(2));
      expect(links.last, contains('Orgulho e Preconceito'));
      expect(
        find.descendant(
          of: ini('i01b.alsoReading.card1.play.icon'),
          matching: find.byType(ExcludeSemantics),
        ),
        findsAtLeast(1),
      );
      semantics.dispose();
    },
  );

  testWidgets(
    'R6 sessão do Orgulho (papel com página): o botão entra no lugar do anel (a mesma caixa 46), o cartão vira '
    '<div> (a capa é o link, o botão "Pausar leitura de Orgulho e Preconceito") e a pílula fica "Papel · pág. 344"',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _abrir(
        tester,
        cronometro: _comSessao(_sessaoDe(TelaInicio01.orgulho.id)),
      );
      const id = 'i01b.alsoReading.card2.play';
      expect(ini('i01b.alsoReading.card2.ring'), findsNothing);
      expect(
        retanguloDeLayout(tester, id),
        _perto(kRef01b.elements['i01b.alsoReading.card2.ring']!.rect),
      );
      final icone = _w<AppSvg>(tester, '$id.icon');
      expect((icone.asset, icone.size), (AppIconsInicio.pause, 16.0));
      expect(
        tester.getRect(ini('$id.icon')),
        _perto(const Rect.fromLTWH(323.5, 644.46, 16, 16)),
      );
      expect(_aroDe(tester, id), _aro);
      expect(
        tester.getSize(ini('i01b.alsoReading.card2')).height,
        closeTo(kRef01b.elements['i01b.alsoReading.card2']!.rect.height, 0.01),
      );
      expect(findAppText('Papel · pág. 344'), findsOneWidget);
      // o Brás Cubas sem sessão volta ao "play" da 01
      final play = _w<AppSvg>(tester, 'i01b.alsoReading.card1.play.icon');
      expect((play.asset, play.size), (AppIconsInicio.play, 18.0));
      expect(_aroDe(tester, 'i01b.alsoReading.card1.play'), isNull);
      expect(_links(), [
        'Memórias Póstumas de Brás Cubas',
        'Orgulho e Preconceito',
      ]);
      expect(
        noDe(tester, id).getSemanticsData().label,
        'Pausar leitura de Orgulho e Preconceito',
      );
      semantics.dispose();
    },
  );

  for (final (caso, cronometro) in [
    (
      'sessão de um livro fora da grade (O Cortiço)',
      () => _comSessao(_sessaoDe(_cortico.book.id)),
    ),
    (
      'cronômetro com falha ao carregar',
      () =>
          overridesDaSessao(store: _LojaQuebrada(), livros: estanteDePapel01()),
    ),
    ('nenhuma sessão', () => overridesDaSessao(livros: estanteDePapel01())),
  ]) {
    testWidgets(
      'R6 $caso: os cartões ficam os da 01 — o "play" 18 sem aro e o anel do Orgulho',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await _abrir(tester, cronometro: cronometro());
        const id = 'i01b.alsoReading.card1.play';
        final icone = _w<AppSvg>(tester, '$id.icon');
        expect((icone.asset, icone.size), (AppIconsInicio.play, 18.0));
        expect(_aroDe(tester, id), isNull);
        expect(
          noDe(tester, id).getSemanticsData().label,
          'Iniciar leitura de Brás Cubas',
        );
        expect(ini('i01b.alsoReading.card2.ring'), findsOneWidget);
        expect(ini('i01b.alsoReading.card2.play'), findsNothing);
        // a geometria é a da 01b, menos o ícone: o "play" 18 da 01 no lugar do "pausar" 16
        expect(
          geometria01(tester, _secoes, prancha: kRef01b),
          everyElement(startsWith('i01b.alsoReading.card1.play.icon.')),
        );
        expect(
          tester.getRect(ini('$id.icon')),
          _perto(const Rect.fromLTWH(141.5, 643.46, 18, 18)),
        );
        semantics.dispose();
      },
    );
  }

  testWidgets(
    'L01b.1 o cartão em sessão não muda de tamanho: 169 × 153,81 como na 01',
    (tester) async {
      await _abrir(tester);
      final r = kRef01b.elements['i01b.alsoReading.card1']!.rect;
      expect(r.width, 169);
      expect(r.height, closeTo(153.81, 1e-9));
      final cartao = tester.getSize(ini('i01b.alsoReading.card1'));
      expect(cartao.width, r.width);
      expect(cartao.height, closeTo(r.height, 0.01));
      expect(
        tester.renderObject<RenderBox>(ini('i01b.alsoReading.card1.play')).size,
        const Size(46, 46),
      );
    },
  );

  testWidgets(
    'D-257 o botão pausa a sessão que roda e retoma a pausada (o tempo parado fica gravado na sessão)',
    (tester) async {
      final loja = MemoryPaperTimerStore({donoDaSessao: TelaInicio01b.sessao});
      await _abrir(
        tester,
        cronometro: overridesDaSessao(store: loja, livros: estanteDePapel01()),
      );
      const id = 'i01b.alsoReading.card1.play';
      expect(
        tester
            .widget<AlsoReadingSection>(find.byType(AlsoReadingSection))
            .onSessionTap,
        isNotNull,
      );
      await _rolar(
        tester,
        200,
      ); // o centro do botão fica sob a mini-barra na 01b
      await tocar01(tester, id);
      final pausada = loja.sessoes[donoDaSessao]!;
      expect(pausada.isRunning, isFalse);
      expect(pausada.activeSeconds, TelaInicio01b.tempoDaSessao.inSeconds);
      expect(_w<AppSvg>(tester, '$id.icon').asset, AppIconsInicio.play);
      expect(_aroDe(tester, id), _aro);
      await tocar01(tester, id);
      expect(loja.sessoes[donoDaSessao]!.isRunning, isTrue);
      expect(_w<AppSvg>(tester, '$id.icon').asset, AppIconsInicio.pause);
      expect(rotaAtual(tester), '/inicio');
    },
  );
}
