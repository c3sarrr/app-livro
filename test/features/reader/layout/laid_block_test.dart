// G10.1 — layout dos blocos do livro (ADR-004, ADR-005, D-94, D-96, D-98, D-99): estilo do texto em dados,
// altura de linha exata, recuo pelo `PlaceholderSpan` com a conversão de posições, layout em pedaços com as
// mesmas linhas do inteiro, regras do estilo BookNest (recuo, alinhamento, citação, lista), títulos e objetos
// na grade de linhas.
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/content/content_blocks.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart' show paragrafoDaPagina159;
import '../../../support/load_fonts.dart';
import '../../../support/personal_builders.dart';

ParagraphBlock _p(String t, {BlockStyle style = BlockStyle.none}) =>
    ParagraphBlock([TextRun(t)], style);

HeadingBlock _h(int level, String t) =>
    HeadingBlock(level, [TextRun(t)], BlockStyle.none);

/// Inícios dos blocos no texto canônico (`\n` entre eles).
List<int> _starts(List<ContentBlock> blocks) {
  final out = <int>[];
  var at = 0;
  for (final b in blocks) {
    out.add(at);
    at += b.text.length + 1;
  }
  return out;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);
  const t = ReaderTypography();
  final laid = <LaidBlock>[];
  tearDown(() {
    for (final b in laid) {
      b.dispose();
    }
    laid.clear();
  });

  List<LaidBlock> montar(List<ContentBlock> blocks, {BlockLayouter? com}) {
    final r = (com ?? BlockLayouter(t)).layoutAll(blocks, _starts(blocks));
    laid.addAll(r);
    return r;
  }

  group('tipografia (ADR-004, D-20, D-94)', () {
    test('padrão = tela 19: 20,5 · 1,72 · margem 28 → linha 35,26, caixa 334 × 670, recuo 26,65', () {
      expect(t.lineHeight, closeTo(35.26, 1e-4));
      expect(t.contentWidth, 334);
      expect(t.contentHeight, 670);
      expect(t.indent, closeTo(26.65, 1e-4));
    });

    test('os ajustes da pessoa: 7 tamanhos, 3 entrelinhas, 3 margens', () {
      ReaderTypography de(int passo, ReaderLineSpacing e, ReaderMargins m) =>
          ReaderTypography.fromSettings(
            ReaderSettings(
              id: usuarioTeste,
              meta: metaTeste(),
              fontStep: passo,
              lineSpacing: e,
              margins: m,
            ),
            viewportWidth: 390,
            viewportHeight: 844,
          );
      expect(
        [
          for (var i = 1; i <= 7; i++)
            de(i, ReaderLineSpacing.medio, ReaderMargins.media).fontSize,
        ],
        [16, 17.5, 19, 20.5, 22, 24, 26],
      );
      final justo = de(1, ReaderLineSpacing.justo, ReaderMargins.estreita);
      expect((justo.lineHeight, justo.contentWidth), (24.0, 350.0));
      final solto = de(7, ReaderLineSpacing.solto, ReaderMargins.larga);
      expect(solto.lineHeight, closeTo(50.7, 1e-4));
      expect(solto.contentWidth, 310);
      expect(solto.layoutKey, isNot(t.layoutKey));
      // a cor do papel não muda o layout
      expect(
        const ReaderTypography(ink: ui.Color(0xFFE3D9C6)).layoutKey,
        t.layoutKey,
      );
    });

    test('estilo em dados: opsz = tamanho sempre, wght explícito, Skia em 400 (sem negrito sintético)', () {
      for (final size in readerFontSizes) {
        final s = ReaderTypography(fontSize: size).spec(RunStyle.plain);
        expect(s.variations.map((v) => (v.axis, v.value)), [
          ('opsz', size),
          ('wght', 400.0),
        ]);
        expect(s.skiaWeight, ui.FontWeight.w400);
        expect(s.family, 'LiterataVF');
        expect(s.fallback.first, 'LiterataVFExt');
      }
      final negrito = t.spec(const RunStyle(bold: true));
      expect(negrito.wght, 700);
      final titulo = t.spec(
        RunStyle.plain,
        size: 26.65,
        weight: readerHeadingWeight,
      );
      expect(titulo.variations.first.value, 26.65);
      expect(titulo.wght, 600);
      final tudo = t.spec(
        const RunStyle(italic: true, smallCaps: true, superscript: true),
        link: true,
      );
      expect(tudo.italic, isTrue);
      expect(tudo.features, ['smcp', 'sups']);
      expect(tudo.link, isTrue);
      expect(t.spec(const RunStyle(subscript: true)).features, ['subs']);
    });
  });

  group('texto', () {
    test('altura de linha exata: topo da linha n = n × 35,26 (o SkParagraph sozinho daria 35,00)', () {
      final b = montar([_p(paragrafoDaPagina159)]).single as LaidText;
      expect(b.lines.length, greaterThan(19));
      for (var i = 0; i < b.lines.length; i++) {
        expect(b.lines[i].top, closeTo(i * 35.26, 1e-4));
      }
      expect(b.height, closeTo(b.lines.length * 35.26, 1e-4));
    });

    test('recuo = U+FFFC no Paragraph: as posições do parágrafo e do texto canônico se convertem', () {
      final blocks = [_p('Antes.'), _p('Olhos de ressaca? Vá, de ressaca.')];
      final b = montar(blocks)[1] as LaidText;
      expect(b.pieces.single.placeholder, isTrue);
      expect(b.start, 7);
      expect(b.toParagraph(7), (0, 1));
      expect(b.toCanonical(0, 1), 7);
      expect(b.toCanonical(0, 0), 7, reason: 'o recuo não é texto');
      for (var c = 7; c <= 7 + b.length; c++) {
        final (piece, i) = b.toParagraph(c);
        expect(b.toCanonical(piece, i), c);
      }
      expect(b.lines.first.start, 7);
      expect(b.lines.last.end, 7 + b.length);
      expect(b.lineAt(7), 0);
      expect(b.lineAt(7 + b.length - 1), b.lines.length - 1);
    });

    test('parágrafo longo em pedaços: as mesmas linhas do layout inteiro (ADR-005)', () {
      final longo = '$paragrafoDaPagina159 ' * 3;
      final inteiro =
          montar([_p(longo)], com: BlockLayouter(t, pieceChars: 1 << 30)).single
              as LaidText;
      final emPedacos =
          montar([_p(longo)], com: BlockLayouter(t, pieceChars: 400)).single
              as LaidText;
      expect(inteiro.pieces, hasLength(1));
      expect(emPedacos.pieces.length, greaterThan(3));
      expect(
        emPedacos.lines.map((l) => (l.start, l.end)),
        inteiro.lines.map((l) => (l.start, l.end)),
      );
      for (var i = 0; i < inteiro.lines.length; i++) {
        expect(emPedacos.lines[i].top, closeTo(inteiro.lines[i].top, 1e-4));
      }
      // conversão de posições atravessa os pedaços
      for (var c = 0; c <= longo.length; c += 97) {
        final (piece, i) = emPedacos.toParagraph(c);
        expect(emPedacos.toCanonical(piece, i), c);
      }
      // o padrão (1.200) também parte
      final padrao = montar([_p(longo)]).single as LaidText;
      expect(padrao.pieces.length, greaterThan(1));
    });

    test('palavra maior que o pedaço: vai inteira num pedaço só', () {
      final b =
          montar([_p('x' * 900)], com: BlockLayouter(t, pieceChars: 100)).single
              as LaidText;
      expect(b.pieces, hasLength(1));
      expect(b.lines.last.end, 900);
    });

    test('<br> (U+2028) quebra a linha dentro do bloco', () {
      final b =
          montar([_p('Primeiro verso\u2028segundo verso')]).single as LaidText;
      expect(b.lines, hasLength(2));
      expect(b.lines[1].start, 'Primeiro verso\u2028'.length);
    });
  });

  group('estilo BookNest (D-96)', () {
    bool recua(List<ContentBlock> blocks, int i) =>
        (montar(blocks)[i] as LaidText).pieces.first.placeholder;

    test('recuo: parágrafo depois de parágrafo e no começo do item; nunca depois de título, imagem ou cena', () {
      expect(recua([_p('Continuação do capítulo.')], 0), isTrue);
      expect(recua([_p('a'), _p('b')], 1), isTrue);
      expect(recua([_h(1, 'CAPÍTULO I'), _p('Começo.')], 1), isFalse);
      expect(
        recua([
          const ImageBlock(path: 'i.png', width: 10, height: 10),
          _p('x'),
        ], 1),
        isFalse,
      );
      expect(recua([const SceneBreakBlock(), _p('x')], 1), isFalse);
      expect(
        recua([
          _p('a'),
          _p('Centro', style: const BlockStyle(align: BlockAlign.center)),
        ], 1),
        isFalse,
      );
      // recuo do editor é ignorado: 0 no CSS continua com o recuo do BookNest
      expect(
        recua([_p('a'), _p('b', style: const BlockStyle(indentEm: 0))], 1),
        isTrue,
      );
    });

    test('do CSS ficam centralizado e à direita; justificado e margens do editor não', () {
      double x(BlockAlign? a) {
        final b =
            montar([_p('Fim.', style: BlockStyle(align: a, marginTopEm: 3))])
                    .single
                as LaidText;
        return b.pieces.single.paragraph.getBoxesForRange(1, 2).first.left;
      }

      final esquerda = x(BlockAlign.justify);
      expect(
        esquerda,
        closeTo(t.indent, 0.01),
        reason: 'justificado vira à esquerda (com recuo)',
      );
      expect(x(BlockAlign.center), greaterThan(100));
      expect(x(BlockAlign.right), greaterThan(250));
      final b = montar([
        _p('a', style: const BlockStyle(marginTopEm: 3, marginBottomEm: 2)),
      ]).single;
      expect(
        b.height,
        closeTo(t.lineHeight, 1e-4),
        reason: 'sem espaço entre parágrafos',
      );
    });

    test(
      'citação e lista: recuo de 1,3 em por nível; lista com "•" na margem',
      () {
        final c =
            montar([_p('Citado.', style: const BlockStyle(quoteDepth: 2))])
                    .single
                as LaidText;
        expect(c.left, closeTo(2 * t.indent, 1e-4));
        expect(c.width, closeTo(t.contentWidth - 2 * t.indent, 1e-4));
        final l =
            montar([
                  const ListItemBlock([
                    TextRun('item'),
                  ], BlockStyle(listDepth: 1, quoteDepth: 1)),
                ]).single
                as LaidText;
        expect(l.left, closeTo(2 * t.indent, 1e-4));
        expect(l.bullet, isNotNull);
        expect(l.bulletCenter, closeTo(1.5 * t.indent, 1e-4));
        expect(l.pieces.single.placeholder, isFalse);
      },
    );
  });

  group('títulos (D-98) e objetos na grade de linhas', () {
    test('h1 1,3×, h2 1,15×, h3 1× em seminegrito; altura do título + 1 linha arredondada para a grade', () {
      final blocks = [
        _h(1, 'CAPÍTULO XXXII'),
        _h(2, 'Olhos de ressaca'),
        _h(3, 'Nota'),
        _p('Texto.'),
      ];
      final b = montar(blocks);
      final h1 = b[0] as LaidText;
      final h2 = b[1] as LaidText;
      final h3 = b[2] as LaidText;
      expect(h1.lines.single.height, closeTo(20.5 * 1.3 * 1.72, 1e-4));
      expect(h2.lines.single.height, closeTo(20.5 * 1.15 * 1.72, 1e-4));
      expect(h3.lines.single.height, closeTo(20.5 * 1.72, 1e-4));
      for (final h in [h1, h2, h3]) {
        expect(h.keepTogether, isTrue);
        final linhas = h.height / t.lineHeight;
        expect(
          linhas,
          closeTo(linhas.roundToDouble(), 1e-4),
          reason: 'na grade',
        );
      }
      // h1 seguido de outro título: sem o espaço; h3 seguido de texto: + 1 linha
      expect(h1.height, closeTo(2 * t.lineHeight, 1e-4));
      expect(h3.height, closeTo(2 * t.lineHeight, 1e-4));
    });

    test('quebra de cena: uma linha, "* * *" centralizado, 1 caractere no texto (D-99)', () {
      final b = montar([_p('a'), const SceneBreakBlock(), _p('b')]);
      final s = b[1] as LaidSceneBreak;
      expect(s.height, closeTo(t.lineHeight, 1e-4));
      expect(s.length, 1);
      expect(s.start, 2);
      expect(s.mark.maxIntrinsicWidth, greaterThan(10));
    });

    test('imagem: cabe na largura e na altura, nunca amplia, centralizada, faixa na grade', () {
      LaidImage img(int w, int h, {int quote = 0}) =>
          montar([
                ImageBlock(
                  path: 'i.png',
                  width: w,
                  height: h,
                  style: BlockStyle(quoteDepth: quote),
                ),
              ]).single
              as LaidImage;
      final larga = img(1600, 1200);
      expect(larga.drawWidth, closeTo(334, 1e-4));
      expect(larga.drawHeight, closeTo(250.5, 1e-4));
      expect(larga.slotHeight, closeTo(8 * t.lineHeight, 1e-4));
      expect(larga.drawTop, closeTo((8 * t.lineHeight - 250.5) / 2, 1e-4));
      final alta = img(400, 4000);
      expect(alta.drawHeight, closeTo(19 * t.lineHeight, 1e-4));
      expect(alta.slotHeight, closeTo(19 * t.lineHeight, 1e-4));
      final pequena = img(60, 30);
      expect((pequena.drawWidth, pequena.drawHeight), (60.0, 30.0));
      expect(pequena.left, closeTo((334 - 60) / 2, 1e-4));
      expect(pequena.slotHeight, closeTo(t.lineHeight, 1e-4));
      final citada = img(1000, 100, quote: 1);
      expect(citada.drawWidth, closeTo(334 - t.indent, 1e-4));
      // tamanho desconhecido: não ocupa espaço (o caractere continua no texto)
      final sem = montar([const ImageBlock(path: 'x.png')]).single as LaidImage;
      expect((sem.height, sem.length), (0.0, 1));
      // tamanho vindo do arquivo (lido no isolate — G10.2) vence os atributos
      final lida =
          BlockLayouter(t, imageSize: (_) => const ui.Size(334, 100)).layout(
            const ImageBlock(path: 'y.png', width: 10, height: 10),
            start: 0,
          ) as LaidImage;
      laid.add(lida);
      expect(lida.drawHeight, 100);
    });
  });
}
