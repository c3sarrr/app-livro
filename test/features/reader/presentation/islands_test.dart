// G12.3 — ilha de cima e chip de tempo (telas 20/26b, L20a e L20c) montados sozinhos nas posições do arquivo
// (ilha em 14/54, chip 76 abaixo, centralizado), contra as medidas da prancha: o fechar, o bloco do título, a
// lupa e a fita (±0,5), o título e o autor (linha, baseline e bordas ±0,5), o chip e o ícone dele (caixa visual).
// Fita: o estado vai para o leitor de tela e o ícone muda nos 4 casos (marcada/desmarcada × claro/Noite). No
// Noite, as cores da 26b. Esmaecer (`a`) muda o alfa das cores e dos ícones, sem `Opacity`.
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_scope.dart';
import 'package:app_leitura/features/reader/presentation/time_chip.dart';
import 'package:app_leitura/features/reader/presentation/top_island.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/ref_tipos.dart';
import '../../../reference/leitor/reference_layout_20_leitor_controles.dart';
import '../../../support/load_fonts.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

void main() {
  setUpAll(loadAppFonts);

  late List<String> eventos;

  Future<void> montar(
    WidgetTester tester, {
    ReaderPaper papel = ReaderPaper.creme,
    double a = 1,
    bool marcada = true,
    String titulo = 'Dom Casmurro',
    String chip = '18 min hoje · contando sozinho',
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    eventos = [];
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ReaderChromeScope(
          palette: ReaderChromePalette.of(papel).faded(a),
          brand: AppColors.lavender,
          a: a,
          child: Stack(
            children: [
              Positioned(
                left: 14,
                right: 14,
                top: 54,
                child: TopIsland(
                  title: titulo,
                  author: 'Machado de Assis',
                  marked: marcada,
                  onClose: () => eventos.add('fechar'),
                  onSearch: () => eventos.add('buscar'),
                  onBookmark: () => eventos.add('fita'),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 130,
                child: Center(child: TimeChip(label: chip)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void confere(WidgetTester tester, String id, {bool visual = false}) {
    final e = kRef20.elements[id]!;
    final ref = visual ? (e.visual ?? e.rect) : e.rect;
    final got = tester.getRect(_key(id));
    final tolX = kRef20.textDependentX.contains(id) ? 1.0 : 0.5;
    expect(
      got.left,
      moreOrLessEquals(ref.left, epsilon: tolX),
      reason: '$id x',
    );
    expect(got.top, moreOrLessEquals(ref.top, epsilon: 0.5), reason: '$id y');
    expect(
      got.width,
      moreOrLessEquals(ref.width, epsilon: tolX),
      reason: '$id w',
    );
    expect(
      got.height,
      moreOrLessEquals(ref.height, epsilon: 0.5),
      reason: '$id h',
    );
  }

  void confereLinhas(WidgetTester tester, String id) {
    final e = kRef20.elements[id]!;
    final r = tester.renderObject<RenderAppText>(_key(id));
    final linhas = r.debugLines();
    expect(linhas.map((l) => l.text), e.lines.map((l) => l.text), reason: id);
    for (var i = 0; i < linhas.length; i++) {
      final (got, ref) = (linhas[i], e.lines[i]);
      expect(got.baseline, moreOrLessEquals(ref.baseline, epsilon: 0.5));
      expect(got.left, moreOrLessEquals(ref.left, epsilon: 0.5));
      expect(got.right, moreOrLessEquals(ref.right, epsilon: 1.0));
    }
  }

  testWidgets('ilha de cima nas medidas da L20a', (tester) async {
    await montar(tester);
    for (final id in const [
      'r20.topIsland',
      'r20.topIsland.close',
      'r20.topIsland.close.icon',
      'r20.topIsland.titleBlock',
      'r20.topIsland.search',
      'r20.topIsland.search.icon',
      'r20.topIsland.bookmark',
      'r20.topIsland.bookmark.icon',
    ]) {
      if (id == 'r20.topIsland.titleBlock') {
        // o bloco do título ocupa o que sobra (181) e centraliza as duas linhas
        final got = tester.getRect(_key(id));
        final ref = kRef20.elements[id]!.rect;
        expect(got.left, moreOrLessEquals(ref.left, epsilon: 0.5));
        expect(got.top, moreOrLessEquals(ref.top, epsilon: 0.5));
        expect(got.width, moreOrLessEquals(ref.width, epsilon: 0.5));
        expect(got.height, moreOrLessEquals(ref.height, epsilon: 0.5));
        continue;
      }
      confere(tester, id);
    }
    confereLinhas(tester, 'r20.topIsland.title');
    confereLinhas(tester, 'r20.topIsland.author');
  });

  testWidgets('cores claras: ilha branca, borda e sombra de tinta, raio 31', (
    tester,
  ) async {
    await montar(tester);
    final ilha = tester.widget<NeoBox>(_key('r20.topIsland'));
    expect(ilha.color, AppColors.surface);
    expect(ilha.border, const BorderSide(width: 1.5, color: AppColors.ink));
    expect(ilha.shadowColor, AppColors.ink);
    expect(ilha.shadow, const Offset(3, 3));
    expect(ilha.radius, BorderRadius.circular(31));
    final fechar = tester.widget<NeoBox>(
      find.descendant(
        of: _key('r20.topIsland.close'),
        matching: find.byType(NeoBox),
      ),
    );
    expect(fechar.color, AppColors.paper);
    expect(
      tester.widget<AppSvg>(_key('r20.topIsland.close.icon')).asset,
      AppIconsLeitor.arrowLeft,
    );
    expect(
      tester.widget<AppSvg>(_key('r20.topIsland.search.icon')).asset,
      AppIconsLeitor.search,
    );
  });

  testWidgets('título longo vira "…" numa linha só', (tester) async {
    await montar(
      tester,
      titulo: 'Memórias Póstumas de Brás Cubas, edição comentada e anotada',
    );
    final r = tester.renderObject<RenderAppText>(_key('r20.topIsland.title'));
    expect(r.debugLines(), hasLength(1));
    expect(r.debugDidExceedMaxLines, isTrue);
    expect(
      tester.getRect(_key('r20.topIsland.search')).left,
      moreOrLessEquals(268.5, epsilon: 0.5),
      reason: 'a lupa não sai do lugar',
    );
  });

  testWidgets('fita: estado para o leitor de tela e o ícone nos 4 casos', (
    tester,
  ) async {
    final h = tester.ensureSemantics();
    for (final (papel, marcada, icone) in [
      (ReaderPaper.creme, true, AppIconsLeitor.ribbonMarked),
      (ReaderPaper.creme, false, AppIconsLeitor.ribbonEmpty),
      (ReaderPaper.noite, true, AppIconsLeitor.ribbonMarkedNight),
      (ReaderPaper.noite, false, AppIconsLeitor.ribbonEmptyNight),
    ]) {
      await montar(tester, papel: papel, marcada: marcada);
      expect(
        tester.widget<AppSvg>(_key('r20.topIsland.bookmark.icon')).asset,
        icone,
      );
      expect(
        tester.getSemantics(_key('r20.topIsland.bookmark')),
        isSemantics(
          label: 'Página marcada',
          isButton: true,
          hasToggledState: true,
          isToggled: marcada,
          hasTapAction: true,
        ),
      );
    }
    h.dispose();
  });

  testWidgets('os três botões chamam a ação e têm nome', (tester) async {
    final h = tester.ensureSemantics();
    await montar(tester);
    expect(
      tester.getSemantics(_key('r20.topIsland.close')),
      isSemantics(label: 'Fechar o livro', isButton: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(_key('r20.topIsland.search')),
      isSemantics(label: 'Buscar no livro', isButton: true, hasTapAction: true),
    );
    await tester.tap(_key('r20.topIsland.close'));
    await tester.tap(_key('r20.topIsland.search'));
    await tester.tap(_key('r20.topIsland.bookmark'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(eventos, ['fechar', 'buscar', 'fita']);
    h.dispose();
  });

  testWidgets(
    'Noite (26b): ilha #2A2520, borda #EDE3D1, sombra #0B0A08, ícones _noite',
    (tester) async {
      await montar(tester, papel: ReaderPaper.noite);
      final ilha = tester.widget<NeoBox>(_key('r20.topIsland'));
      expect(ilha.color, AppColors.islandNight);
      expect(ilha.border!.color, AppColors.inkNight);
      expect(ilha.shadowColor, AppColors.shadowNight);
      expect(
        tester.widget<AppSvg>(_key('r20.topIsland.close.icon')).asset,
        AppIconsLeitor.arrowLeftNight,
      );
      expect(
        tester.widget<AppSvg>(_key('r20.topIsland.search.icon')).asset,
        AppIconsLeitor.searchNight,
      );
      final titulo = tester.widget<AppText>(_key('r20.topIsland.title'));
      expect(titulo.span.style!.color, AppColors.inkNight);
      final autor = tester.widget<AppText>(_key('r20.topIsland.author'));
      expect(autor.span.style!.color, AppColors.mutedNight);
      // chip igual nos dois temas (G12 §cores)
      final chip = tester.widget<NeoBox>(
        find.descendant(
          of: _key('r20.timeChip'),
          matching: find.byType(NeoBox),
        ),
      );
      expect(chip.color, AppColors.sun);
      expect(chip.border, const BorderSide(width: 1.5, color: AppColors.ink));
    },
  );

  testWidgets(
    'chip nas medidas da L20c: 30 de altura, centralizado, ícone 15',
    (tester) async {
      final h = tester.ensureSemantics();
      await montar(tester);
      confere(tester, 'r20.timeChip', visual: true);
      confere(tester, 'r20.timeChip.icon', visual: true);
      final texto = tester.widget<AppText>(
        find.descendant(
          of: _key('r20.timeChip'),
          matching: find.byType(AppText),
        ),
      );
      expect(texto.span.toPlainText(), '18 min hoje · contando sozinho');
      final e = kRef20.elements['r20.timeChip']!;
      final linha = tester
          .renderObject<RenderAppText>(
            find.descendant(
              of: _key('r20.timeChip'),
              matching: find.byType(AppText),
            ),
          )
          .debugLines()
          .single;
      final dx =
          e.visual!.left - e.rect.left; // o arquivo centraliza com translate
      expect(
        linha.left,
        moreOrLessEquals(e.lines.single.left + dx, epsilon: 1.0),
      );
      expect(
        linha.baseline,
        moreOrLessEquals(e.lines.single.baseline, epsilon: 0.5),
      );
      expect(
        tester.getSemantics(_key('r20.timeChip')),
        isSemantics(label: '18 min hoje · contando sozinho'),
      );
      h.dispose();
    },
  );

  testWidgets('esmaecer: a = 0,5 dá metade do alfa nas cores e nos ícones', (
    tester,
  ) async {
    await montar(tester, a: 0.5);
    final ilha = tester.widget<NeoBox>(_key('r20.topIsland'));
    expect(ilha.color!.a, moreOrLessEquals(0.5, epsilon: 0.01));
    expect(ilha.border!.color.a, moreOrLessEquals(0.5, epsilon: 0.01));
    expect(ilha.shadowColor.a, moreOrLessEquals(0.5, epsilon: 0.01));
    for (final id in const [
      'r20.topIsland.close.icon',
      'r20.topIsland.search.icon',
      'r20.topIsland.bookmark.icon',
      'r20.timeChip.icon',
    ]) {
      expect(tester.widget<AppSvg>(_key(id)).opacity, 0.5, reason: id);
    }
    final chip = tester.widget<NeoBox>(
      find.descendant(of: _key('r20.timeChip'), matching: find.byType(NeoBox)),
    );
    expect(chip.color!.a, moreOrLessEquals(0.5, epsilon: 0.01));
    expect(chip.border!.color.a, moreOrLessEquals(0.5, epsilon: 0.01));
  });

  test('o escopo avisa quando muda a paleta, a brand ou o esmaecimento', () {
    final p = ReaderChromePalette.of(ReaderPaper.creme);
    ReaderChromeScope s(ReaderChromePalette pal, Color b, double a) =>
        ReaderChromeScope(
          palette: pal,
          brand: b,
          a: a,
          child: const SizedBox(),
        );
    final base = s(p, AppColors.lavender, 1);
    expect(base.updateShouldNotify(s(p, AppColors.lavender, 1)), isFalse);
    expect(
      base.updateShouldNotify(s(p.faded(0.5), AppColors.lavender, 1)),
      isTrue,
    );
    expect(base.updateShouldNotify(s(p, AppColors.ink, 1)), isTrue);
    expect(base.updateShouldNotify(s(p, AppColors.lavender, 0.5)), isTrue);
    expect(
      s(p, AppColors.lavender, 0.5).tint(AppColors.sun).a,
      moreOrLessEquals(0.5, epsilon: 0.01),
    );
  });

  test('a referência da prancha 20 tem os ids desta tarefa', () {
    for (final id in const ['r20.topIsland.title', 'r20.timeChip.icon']) {
      expect(kRef20.elements[id], isA<LeitorRefElement>());
    }
  });
}
