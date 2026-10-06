// G10.1/G10.2 — paginação de um capítulo (Anexo 03 §7.2, D-96, D-98, D-100): linhas até a próxima não caber,
// parágrafo partido entre páginas, título nunca sozinho no pé (nem título + subtítulo), objetos inteiros,
// `page-break-before`, e as páginas cobrindo o texto do capítulo sem buraco.
import 'package:app_leitura/features/reader/content/content_blocks.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/load_fonts.dart';

const t = ReaderTypography();

ParagraphBlock _p(String t, {BlockStyle style = BlockStyle.none}) =>
    ParagraphBlock([TextRun(t)], style);

HeadingBlock _h(int level, String t) =>
    HeadingBlock(level, [TextRun(t)], BlockStyle.none);

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
  final laid = <LaidBlock>[];
  tearDown(() {
    for (final b in laid) {
      b.dispose();
    }
    laid.clear();
  });

  (List<LaidBlock>, List<ReaderPage>) paginar(List<ContentBlock> blocks) {
    final l = BlockLayouter(t).layoutAll(blocks, _starts(blocks));
    laid.addAll(l);
    return (l, paginateChapter(l, t.contentHeight));
  }

  /// Texto que ocupa exatamente [n] linhas (sem recuo: centralizado não recua; uma palavra por linha).
  String linhas(int n) => List.filled(n, 'palavra').join('\u2028');

  int linhasDe(ReaderPage p, List<LaidBlock> l) => p.slices.fold(
    0,
    (a, s) => a + (s is TextSlice ? s.lastLine - s.firstLine + 1 : 0),
  );

  test('19 linhas por página no padrão; parágrafo partido continua no topo da seguinte', () {
    final (l, pages) = paginar([_p(linhas(45))]);
    expect(pages.map((p) => linhasDe(p, l)), [19, 19, 7]);
    final b = l.single as LaidText;
    expect(pages.map((p) => p.start), [
      0,
      b.lines[19].start,
      b.lines[38].start,
    ]);
    expect(pages[1].slices.single.y, 0);
    // as páginas cobrem o texto sem buraco
    for (var i = 1; i < pages.length; i++) {
      expect(pages[i].start, pages[i - 1].end);
    }
    expect(pages.last.end, b.start + b.length);
  });

  test('título não fica sozinho no pé: vai para a página seguinte com a 1ª linha do texto (D-98)', () {
    // 17 linhas + título (2 linhas na grade) = 19: o título cabe, a 1ª linha do texto não
    final (l, pages) = paginar([
      _p(linhas(17)),
      _h(3, 'Capítulo'),
      _p('Começo do capítulo.'),
    ]);
    expect(pages, hasLength(2));
    expect(pages[0].slices.map((s) => s.block), [0]);
    expect(pages[1].slices.map((s) => s.block), [1, 2]);
    expect(pages[1].slices.first.y, 0);
    expect(pages[1].start, l[1].start);
    // com uma linha a menos antes, tudo cabe na 1ª página
    final (_, juntos) = paginar([
      _p(linhas(16)),
      _h(3, 'Capítulo'),
      _p('Começo do capítulo.'),
    ]);
    expect(juntos, hasLength(1));
  });

  test('título + subtítulo vão juntos para a página seguinte', () {
    final (_, pages) = paginar([
      _p(linhas(15)),
      _h(1, 'CAPÍTULO XXXII'),
      _h(2, 'Olhos de ressaca'),
      _p('Tudo era matar a minha ideia fixa.'),
    ]);
    expect(pages, hasLength(2));
    expect(pages[0].slices.map((s) => s.block), [0]);
    expect(pages[1].slices.map((s) => s.block), [1, 2, 3]);
  });

  test('título mais alto que a página: partido como texto, sem passar do pé nem deixar página vazia', () {
    final (l, pages) = paginar([
      _h(1, List.filled(80, 'CAPÍTULO').join(' ')), // mais alto que a página
      _p(linhas(19)),
    ]);
    expect((l[0] as LaidText).height, greaterThan(t.contentHeight));
    expect(pages.first.slices.single.block, 0);
    for (final p in pages) {
      expect(p.slices, isNotEmpty);
      for (final s in p.slices.whereType<TextSlice>()) {
        final b = l[s.block] as LaidText;
        final altura = b.lines[s.lastLine].bottom - b.lines[s.firstLine].top;
        expect(s.y + altura, lessThanOrEqualTo(t.contentHeight + 0.02));
      }
    }
    // o texto vem logo depois do fim do título
    final fimDoTitulo = pages.lastIndexWhere(
      (p) => p.slices.any((s) => s.block == 0),
    );
    expect(
      pages.indexWhere((p) => p.slices.any((s) => s.block == 1)),
      anyOf(fimDoTitulo, fimDoTitulo + 1),
    );
  });

  test('título + subtítulo que cabem só numa página vazia: ficam juntos no topo (não há página vazia)', () {
    final (_, pages) = paginar([
      _p(linhas(15)),
      _h(1, List.filled(12, 'CAPÍTULO').join(' ')),
      _h(2, 'Subtítulo'),
      _p(linhas(19)),
    ]);
    expect(pages.every((p) => p.slices.isNotEmpty), isTrue);
    expect(pages[1].slices.map((s) => s.block).take(2), [1, 2]);
  });

  test(
    'page-break-before do livro abre página; capítulo vazio não tem página',
    () {
      final (_, pages) = paginar([
        _p('Antes.'),
        _p('Depois.', style: const BlockStyle(pageBreakBefore: true)),
      ]);
      expect(pages.map((p) => p.slices.single.block), [0, 1]);
      final (_, vazio) = paginar([]);
      expect(vazio, isEmpty);
    },
  );

  test('imagem e quebra de cena: inteiras; imagem que não cabe vai para a próxima página', () {
    final (l, pages) = paginar([
      _p(linhas(14)),
      const ImageBlock(
        path: 'i.png',
        width: 1600,
        height: 1200,
      ), // 8 linhas na grade
      const SceneBreakBlock(),
      _p('Fim.'),
    ]);
    expect(pages, hasLength(2));
    expect(pages[0].slices.map((s) => s.block), [0]);
    expect(pages[1].slices.map((s) => (s.block, s.runtimeType)), [
      (1, ObjectSlice),
      (2, ObjectSlice),
      (3, TextSlice),
    ]);
    expect(pages[1].slices[1].y, closeTo(8 * t.lineHeight, 1e-4));
    expect(pages[1].slices[2].y, closeTo(9 * t.lineHeight, 1e-4));
    expect(pages[1].start, l[1].start);
    expect(pages[1].end, l[3].start + l[3].length);
  });

  test('incremental: blocos entregues aos poucos dão as mesmas páginas', () {
    final blocks = [_p(linhas(30)), _h(2, 'Parte'), _p(linhas(25))];
    final (l, inteiro) = paginar(blocks);
    final p = ChapterPaginator(t.contentHeight);
    for (final b in l) {
      p.add(b);
    }
    final aos = p.finish();
    expect(
      aos.map((x) => (x.start, x.end, x.slices.length)),
      inteiro.map((x) => (x.start, x.end, x.slices.length)),
    );
  });
}
