// G12.5 — as fases L20a/L20b/L20c (tela 20, Creme) e L26b (Noite): a tela pela rota real, no mundo de referência
// (D-34), com os controles abertos, contra as medidas do arquivo:
// - geometria de todos os ids das seções da prancha (±0,5; ±1,0 em x/w nos que dependem do texto); os que o
//   arquivo desenha com `transform` (chip, ícone do chip, balão) pela caixa visual; o bico pelo quadrado sem giro;
// - texto: linhas, baselines e bordas do título, do autor, do chip, do balão, do progresso, dos rótulos, do "Aa" e
//   do contador;
// - estilo: cores do tema, bordas, raios, sombras duras, fontes e números tabulares;
// - semântica: os rótulos do arquivo, a fita marcada e o slider "página 159 de 256";
// - dados: 159/256/62 %, "18 min hoje · contando sozinho", o contador 12 e a fita, calculados das linhas do mundo.
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/domain/reading_speed.dart'
    show readerTimeLeftLabel;
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_screen.dart';
import 'package:app_leitura/features/reader/presentation/scrubber.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/telas/instantaneo.dart';
import '../reference/leitor/ref_tipos.dart';
import 'canvas.dart';
import 'dados_t20.dart';
import 'load_fonts.dart';
import 'pump_reader.dart';
import 'reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

/// A prancha usa os ids `r20.page*`/`r20.footer*`; a tela, os da 19 (é a mesma página).
String _chave(String id) => id
    .replaceFirst('r20.page', 'r19.page')
    .replaceFirst('r20.footer', 'r19.footer');

/// As seções da prancha conferidas.
const List<String> secoesL20 = [
  'r20.page',
  'r20.footer',
  'r20.fade',
  'r20.topIsland',
  'r20.timeChip',
  'r20.bottomIsland',
];

/// Abre a tela da prancha (o Dom Casmurro do mundo na pág. 159), toca no centro e espera os controles.
Future<LeitorNaTela> abrirTela20(
  WidgetTester tester,
  LivroNaEstante livro, {
  bool golden = false,
}) async {
  setCanvasView(tester, logical: const Size(390, 844));
  final t = await abrirLeitor(
    tester,
    livro,
    golden: golden,
    deps: (t) => depsDaTela20(t, livro),
  );
  await tester.tapAt(const Offset(195, 420));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  return t;
}

void faseL20({
  required String nome,
  required LeitorRefPrancha ref,
  required ReaderPaper papel,
  required InstantaneoDoLeitor instantaneo,
}) {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela20(papel: papel));
  tearDown(() async => livro.close());

  final cores = ReaderChromePalette.of(papel);
  final pagina = ReaderPalette.of(papel);

  PageSnapshot snapshot(WidgetTester tester) =>
      tester
              .widget<ReaderPageView>(find.byType(ReaderPageView))
              .document
              .current
          as PageSnapshot;

  /// O retângulo medido na tela para o id da prancha (o texto da página: o parágrafo inteiro, como na L19).
  Rect medido(WidgetTester tester, String id) {
    if (id == 'r20.page.text') {
      final p = snapshot(tester);
      final s = p.page.slices.first as TextSlice;
      final b = p.block(s.block) as LaidText;
      final t = p.typography;
      return Rect.fromLTWH(
        t.sideMargin + b.left,
        t.topInset + s.y,
        b.width,
        b.lines.last.bottom,
      );
    }
    return tester.getRect(_key(_chave(id)));
  }

  /// Onde o arquivo desenha o elemento: a caixa visual quando há `transform`; o bico (girado) pelo quadrado sem
  /// giro, deslocado como o balão.
  Rect esperado(String id) {
    final e = ref.elements[id]!;
    if (id == 'r20.bottomIsland.scrubber.bubble.tail') {
      final b = ref.elements['r20.bottomIsland.scrubber.bubble']!;
      return e.rect.shift(Offset(b.visual!.left - b.rect.left, 0));
    }
    return e.visual ?? e.rect;
  }

  testWidgets('$nome — geometria: todos os ids das seções', (tester) async {
    await abrirTela20(tester, livro);
    final ids = [for (final s in secoesL20) ...ref.idsOfSection(s)];
    expect(ids, hasLength(45));
    final falhas = <String>[];
    for (final id in ids) {
      final m = medido(tester, id);
      final r = esperado(id);
      final tolX = ref.textDependentX.contains(id) ? 1.0 : 0.5;
      void confere(String o, double g, double e, double tol) {
        if ((g - e).abs() > tol + 1e-6) {
          falhas.add(
            '$id.$o: ${g.toStringAsFixed(2)} ≠ ${e.toStringAsFixed(2)}',
          );
        }
      }

      confere('x', m.left, r.left, tolX);
      confere('y', m.top, r.top, 0.5);
      confere('w', m.width, r.width, tolX);
      confere('h', m.height, r.height, 0.5);
    }
    expect(falhas, isEmpty, reason: falhas.join('\n'));
  });

  testWidgets('$nome — texto: linhas, baselines e bordas', (tester) async {
    await abrirTela20(tester, livro);
    void linhas(String id, {Finder? onde, bool composto = false}) {
      final e = ref.elements[id]!;
      final esperadas = composto ? e.linesAll : e.lines;
      final dx = (e.visual?.left ?? e.rect.left) - e.rect.left;
      final r = tester.renderObject<RenderAppText>(
        (onde ??
                find.descendant(
                  of: _key(id),
                  matching: find.byType(AppText),
                  matchRoot: true,
                ))
            .last,
      );
      final got = r.debugLines();
      expect(got.map((l) => l.text), esperadas.map((l) => l.text), reason: id);
      for (var i = 0; i < got.length; i++) {
        expect(
          got[i].baseline,
          moreOrLessEquals(esperadas[i].baseline, epsilon: 0.5),
          reason: '$id baseline',
        );
        expect(
          got[i].left,
          moreOrLessEquals(esperadas[i].left + dx, epsilon: 1),
          reason: '$id início',
        );
        expect(
          got[i].right,
          moreOrLessEquals(esperadas[i].right + dx, epsilon: 1),
          reason: '$id fim',
        );
      }
    }

    for (final id in const [
      'r20.topIsland.title',
      'r20.topIsland.author',
      'r20.timeChip',
      'r20.bottomIsland.scrubber.bubble',
      'r20.bottomIsland.progressRow.timeLeft',
      'r20.bottomIsland.tools.font',
      'r20.bottomIsland.tools.font.circle',
      'r20.bottomIsland.tools.theme',
      'r20.bottomIsland.tools.notes',
      'r20.bottomIsland.tools.notes.badge',
      'r20.bottomIsland.tools.annotate',
      'r20.bottomIsland.tools.toc',
      'r20.footer.pageLabel',
      'r20.footer.percent',
    ]) {
      linhas(
        id,
        onde: id.startsWith('r20.footer')
            ? find.byKey(ValueKey<String>(_chave(id)))
            : null,
      );
    }
    linhas('r20.bottomIsland.progressRow.position', composto: true);
    // a página é a mesma da tela 19 (as linhas conferidas na L19)
    final p = snapshot(tester);
    final s = p.page.slices.first as TextSlice;
    final b = p.block(s.block) as LaidText;
    final ref19 = ref.elements['r20.page.text']!.lines;
    for (var l = s.firstLine; l <= s.lastLine; l++) {
      final line = b.lines[l];
      expect(
        p.item.text.substring(line.start, line.end).trimRight(),
        ref19[l].text,
      );
    }
  });

  testWidgets(
    '$nome — estilo: cores do tema, bordas, raios, sombras e letras',
    (tester) async {
      await abrirTela20(tester, livro);
      // papel e véu
      final fundo = tester.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(ReaderScreen),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(fundo.color, pagina.paper);
      final veu = tester.widget<ColoredBox>(_key('r20.fade')).color;
      expect(veu.toARGB32(), cores.veil.toARGB32());
      // ilhas
      for (final (id, raio) in const [
        ('r20.topIsland', 31.0),
        ('r20.bottomIsland', 28.0),
      ]) {
        final n = tester.widget<NeoBox>(_key(id));
        expect(n.color, cores.island, reason: id);
        expect(
          n.border,
          BorderSide(width: 1.5, color: cores.border),
          reason: id,
        );
        expect((n.shadow, n.shadowColor), (const Offset(3, 3), cores.shadow));
        expect(n.radius, BorderRadius.circular(raio));
      }
      final fechar = tester.widget<NeoBox>(
        find.descendant(
          of: _key('r20.topIsland.close'),
          matching: find.byType(NeoBox),
        ),
      );
      expect((fechar.color, fechar.border!.width), (cores.well, 1.5));
      TextStyle estilo(String id) => tester
          .widget<AppText>(
            find
                .descendant(
                  of: _key(id),
                  matching: find.byType(AppText),
                  matchRoot: true,
                )
                .last,
          )
          .span
          .style!;
      final titulo = estilo('r20.topIsland.title');
      expect(
        (titulo.fontFamily, titulo.fontSize, titulo.fontWeight, titulo.color),
        ('Bricolage17', 17.0, FontWeight.w800, cores.title),
      );
      final autor = estilo('r20.topIsland.author');
      expect(
        (autor.fontFamily, autor.fontSize, autor.fontWeight, autor.color),
        ('Figtree', 12.5, FontWeight.w600, cores.muted),
      );
      // chip e contador: amarelo com tinta nos dois temas
      final chip = tester.widget<NeoBox>(
        find.descendant(
          of: _key('r20.timeChip'),
          matching: find.byType(NeoBox),
        ),
      );
      expect(
        (chip.color, chip.border),
        (AppColors.sun, const BorderSide(width: 1.5, color: AppColors.ink)),
      );
      final textoChip = estilo('r20.timeChip');
      expect(
        (textoChip.fontSize, textoChip.fontWeight, textoChip.color),
        (12.5, FontWeight.w800, AppColors.ink),
      );
      final badge = tester.widget<NeoBox>(
        find.descendant(
          of: _key('r20.bottomIsland.tools.notes.badge'),
          matching: find.byType(NeoBox),
        ),
      );
      expect(
        (badge.color, badge.border!.color, badge.radius),
        (AppColors.sun, AppColors.ink, BorderRadius.circular(999)),
      );
      expect(estilo('r20.bottomIsland.tools.notes.badge').fontSize, 11);
      // barra
      final botao = tester.widget<NeoBox>(
        _key('r20.bottomIsland.scrubber.knob'),
      );
      expect(
        (botao.color, botao.border, botao.shadow, botao.shadowColor),
        (
          cores.island,
          BorderSide(width: 2, color: cores.border),
          const Offset(2, 2),
          cores.shadow,
        ),
      );
      final balao = tester.widget<NeoBox>(
        _key('r20.bottomIsland.scrubber.bubble'),
      );
      expect(
        (balao.color, balao.radius),
        (cores.bubble, BorderRadius.circular(10)),
      );
      expect(
        estilo('r20.bottomIsland.scrubber.bubble').color,
        cores.bubbleText,
      );
      final onda =
          tester
                  .widget<CustomPaint>(
                    _key('r20.bottomIsland.scrubber.fill.wave'),
                  )
                  .painter!
              as FillWavePainter;
      expect(
        (onda.fill, onda.stroke),
        (instantaneoBrand(instantaneo), cores.border),
      );
      // progresso
      final pos = tester.widget<AppText>(
        _key('r20.bottomIsland.progressRow.position'),
      );
      final partes = (pos.span as TextSpan).children!.cast<TextSpan>();
      expect(
        (partes[0].style!.fontWeight, partes[0].style!.color),
        (FontWeight.w800, cores.title),
      );
      expect(
        (partes[1].style!.fontWeight, partes[1].style!.color),
        (FontWeight.w700, cores.muted),
      );
      expect(
        partes[1].style!.fontFeatures,
        contains(const ui.FontFeature.tabularFigures()),
      );
      // ferramentas
      for (final t in const ['font', 'theme', 'notes', 'annotate', 'toc']) {
        final caixa = tester.widget<NeoBox>(
          _key('r20.bottomIsland.tools.$t.circle'),
        );
        expect(
          (caixa.color, caixa.border, caixa.radius),
          (
            cores.well,
            BorderSide(width: 1.5, color: cores.title),
            BorderRadius.circular(16),
          ),
          reason: t,
        );
        final rotulo = estilo('r20.bottomIsland.tools.$t');
        expect(
          (rotulo.fontSize, rotulo.fontWeight, rotulo.color),
          (12.0, FontWeight.w700, cores.title),
        );
      }
      final aa = estilo('r20.bottomIsland.tools.font.circle');
      expect(
        (aa.fontFamily, aa.fontSize, aa.fontWeight),
        ('Literata19', 19.0, FontWeight.w500),
      );
      // ícones do tema
      final noite = papel == ReaderPaper.noite;
      String icone(String id) => tester.widget<AppSvg>(_key(id)).asset;
      expect(
        icone('r20.bottomIsland.tools.theme.icon'),
        noite ? AppIconsLeitor.moon : AppIconsLeitor.sun,
      );
      expect(
        icone('r20.topIsland.bookmark.icon'),
        noite ? AppIconsLeitor.ribbonMarkedNight : AppIconsLeitor.ribbonMarked,
      );
      expect(
        icone('r20.topIsland.search.icon'),
        noite ? AppIconsLeitor.searchNight : AppIconsLeitor.search,
      );
      // barra de status: no Noite, ícones claros
      final barra = tester
          .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
            _key('leitor.barraDeStatus'),
          )
          .value;
      expect(
        barra.statusBarIconBrightness,
        noite ? Brightness.light : Brightness.dark,
      );
    },
  );

  testWidgets('$nome — semântica: rótulos do arquivo, a fita e o slider', (
    tester,
  ) async {
    final h = tester.ensureSemantics();
    await abrirTela20(tester, livro);
    expect(
      tester.getSemantics(_key('r20.topIsland.close')),
      isSemantics(label: 'Fechar o livro', isButton: true),
    );
    expect(
      tester.getSemantics(_key('r20.topIsland.search')),
      isSemantics(label: 'Buscar no livro', isButton: true),
    );
    expect(
      tester.getSemantics(_key('r20.topIsland.bookmark')),
      isSemantics(
        label: 'Página marcada',
        hasToggledState: true,
        isToggled: true,
      ),
    );
    expect(
      tester.getSemantics(_key('r20.bottomIsland.scrubber.track')),
      isSemantics(
        label: 'Posição no livro',
        value: 'página 159 de 256',
        isSlider: true,
      ),
    );
    for (final (t, rotulo) in const [
      ('font', 'Fonte'),
      ('theme', 'Tema'),
      ('notes', 'Grifos, 12 marcas'),
      ('annotate', 'Anotar à mão'),
      ('toc', 'Sumário'),
    ]) {
      expect(
        tester.getSemantics(_key('r20.bottomIsland.tools.$t')),
        isSemantics(label: rotulo, isButton: true),
      );
    }
    expect(find.bySemanticsLabel('Controles de leitura'), findsOneWidget);
    expect(
      tester.getSemantics(_key('r20.timeChip')),
      isSemantics(label: '18 min hoje · contando sozinho'),
    );
    h.dispose();
  });

  testWidgets('$nome — dados: tudo calculado das linhas do mundo', (
    tester,
  ) async {
    await abrirTela20(tester, livro);
    String texto(String id) => tester
        .widget<AppText>(
          find
              .descendant(
                of: _key(id),
                matching: find.byType(AppText),
                matchRoot: true,
              )
              .last,
        )
        .span
        .toPlainText();
    final i = instantaneo;
    expect(i.pagina, 159);
    expect(texto('r20.bottomIsland.scrubber.bubble'), 'pág. ${i.pagina}');
    expect(
      texto('r20.bottomIsland.progressRow.position'),
      '${i.porcentagem}% do livro · ${i.totalDePaginas} pág.',
    );
    expect(
      texto('r20.bottomIsland.progressRow.timeLeft'),
      readerTimeLeftLabel(i.tempoRestante),
    );
    expect(
      texto('r20.timeChip'),
      '${i.minutosHoje} min hoje · contando sozinho',
    );
    expect(texto('r20.bottomIsland.tools.notes.badge'), '${i.contagens.all}');
    expect(i.paginaMarcada, isTrue);
    expect(texto('r20.topIsland.title'), i.livro.title);
    expect(texto('r20.topIsland.author'), i.livro.authorDisplay);
    expect(
      texto('r19.footer.pageLabel'),
      'pág. ${i.pagina} de ${i.totalDePaginas}',
    );
  });
}

/// A cor `brand` da prancha (prop do arquivo, padrão #B6ACE4 — D-33).
Color instantaneoBrand(InstantaneoDoLeitor i) =>
    Color(int.parse('FF${i.brand.substring(1)}', radix: 16));
