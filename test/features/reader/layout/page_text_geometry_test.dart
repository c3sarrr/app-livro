// G13.1 — a página do EPUB sabe o que está sob o dedo e onde fica cada letra (tela 21): a área do texto do CSS
// (30,44 na Literata 20,5), as caixas por linha com a linha de base, o ponto e a palavra sob o dedo presos à
// página (D-47), o trecho mostrado e o texto canônico.
import 'package:app_leitura/features/reader/application/epub_reader_document.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:app_leitura/features/reader/layout/text_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/load_fonts.dart';
import '../../../support/reader_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  late EpubReaderDocument doc;
  setUp(() async {
    livro = await livroDaTela19();
    doc = await EpubReaderDocument.open(livro.deps());
  });
  tearDown(() async {
    doc.dispose();
    await livro.close();
  });

  PageSnapshot pagina() => doc.current as PageSnapshot;
  const selecao = 'como a vaga que se retira da praia, nos dias de ressaca.';

  test('área do texto da Literata 20,5 = 30,44 (o fundo de um span no Chromium — L21a)', () {
    expect(readerTextArea(20.5), moreOrLessEquals(30.44, epsilon: 0.05));
  });

  test('caixas por linha da seleção da 21: 3 linhas, área do texto, linha de base e as bordas das alças', () {
    final p = pagina();
    final a = p.item.text.indexOf(selecao);
    expect(a, greaterThanOrEqualTo(p.page.start));
    final caixas = p.boxesOf(p.spine, a, a + selecao.length);
    final linhas = {for (final c in caixas) c.textTop}.toList()..sort();
    expect(linhas, hasLength(3));
    // L21a nº 9: r21.page.text.selection = (0, 390,27, 327,57, 100,96) na página (28, 92)
    expect(linhas.first, moreOrLessEquals(92 + 390.27, epsilon: 0.5));
    expect(
      caixas.last.textBottom,
      moreOrLessEquals(92 + 390.27 + 100.96, epsilon: 0.5),
    );
    expect(caixas.first.baseline, moreOrLessEquals(92 + 414.4, epsilon: 0.5));
    expect(caixas.first.em, moreOrLessEquals(20.5, epsilon: 0.01));
    // nº 6 e nº 10: onde ficam as alças (o começo de "como" e o fim de "ressaca.")
    expect(caixas.first.rect.left, moreOrLessEquals(28 + 258.87, epsilon: 1));
    expect(caixas.last.rect.right, moreOrLessEquals(28 + 147.93, epsilon: 1));
    // o espaço do fim da linha não entra (o Chromium não pinta o fundo dele)
    final daLinha1 = caixas.where((c) => c.textTop == linhas.first);
    expect(
      daLinha1.map((c) => c.rect.right).reduce((x, y) => x > y ? x : y),
      moreOrLessEquals(28 + 327.57, epsilon: 1),
    );
    expect(p.rectsOf(p.spine, a, a + selecao.length), [
      for (final c in caixas) c.rect,
    ]);
  });

  test('ponto e palavra sob o dedo: dentro da página, a palavra inteira, pontuação não é palavra', () {
    final p = pagina();
    final a = p.item.text.indexOf(selecao);
    final como = p.boxesOf(p.spine, a, a + 4).single.rect;
    expect(p.wordAt(como.center), (unit: p.spine, from: a, to: a + 4));
    // a metade direita da última letra ainda é a mesma palavra
    expect(p.wordAt(Offset(como.right - 1, como.center.dy)), (
      unit: p.spine,
      from: a,
      to: a + 4,
    ));
    final ponto = a + selecao.length - 1;
    final caixaDoPonto = p.boxesOf(p.spine, ponto, ponto + 1).single.rect;
    expect(
      p.wordAt(caixaDoPonto.center),
      isNull,
      reason: 'pontuação sozinha não seleciona',
    );
    // o ponto sob o dedo fica antes ou depois do "." (metade da letra); a palavra é a da letra depois do ponto
    expect(p.spotAt(caixaDoPonto.center)!.offset, anyOf(ponto, ponto + 1));
    expect(p.wordAround((unit: p.spine, offset: ponto)), (
      unit: p.spine,
      from: ponto,
      to: ponto + 1,
    ), reason: 'arrastando a alça, a pontuação conta como palavra');
    expect(
      p.wordAround((unit: p.spine, offset: a + 4)),
      isNull,
      reason: 'espaço',
    );
    expect(p.wordAt(const Offset(8, 500)), isNull, reason: 'margem');
    final mostrado = p.shown!;
    expect(mostrado, (unit: p.spine, from: p.page.start, to: p.page.end));
    expect(p.spotAt(const Offset(195, 10)), (
      unit: p.spine,
      offset: mostrado.from,
    ));
    expect(
      p.spotAt(const Offset(195, 840))!.offset,
      lessThanOrEqualTo(mostrado.to),
    );
    expect(
      p.spotAt(const Offset(195, 840))!.offset,
      greaterThan(mostrado.to - 3),
    );
    expect(p.textOf(p.spine, a, a + selecao.length), selecao);
    expect(p.textOf(p.spine + 1, a, a + 4), '', reason: 'outro item');
  });

  test(
    'G14: na Lora, as caixas da página usam a área do texto da Lora',
    () async {
      final lora = await EpubReaderDocument.open(
        livro.deps(t: const ReaderTypography(font: ReaderFontFamily.lora)),
      );
      addTearDown(lora.dispose);
      final p = lora.current as PageSnapshot;
      final de = p.shown!.from;
      final caixa = p.boxesOf(p.spine, de, de + 5).first;
      expect(
        caixa.textBottom - caixa.textTop,
        moreOrLessEquals(
          readerTextArea(20.5, ReaderFontFamily.lora),
          epsilon: 1e-6,
        ),
      );
      expect(
        readerTextArea(20.5, ReaderFontFamily.lora),
        isNot(moreOrLessEquals(readerTextArea(20.5), epsilon: 1)),
      );
    },
  );
}
