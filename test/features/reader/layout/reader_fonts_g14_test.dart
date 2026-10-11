// G14.1 — o texto do livro nas 4 fontes da tela 26 (D-18): a família de cada uma; os eixos (opsz = tamanho e wght
// explícitos) com o Skia em 400, sem negrito sintético; a Atkinson, sem eixos, pelos arquivos de 400 e 700 (os
// títulos em 700); itálico e negrito vindos dos arquivos (a imagem é a do arquivo); as letras que a fonte não tem
// (o grego, as setas, as linhas ′ ″) vindas da Literata, a base primeiro; a chave do cache com a fonte; a área do
// texto (o fundo do grifo) de cada fonte. Revisão: o grego do negrito da Atkinson (o Skia em 700 para escolher o
// arquivo) é o da Literata em 700, sem negrito sintético por cima — a imagem prova.
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/content/content_blocks.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:app_leitura/features/reader/layout/text_geometry.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/load_fonts.dart';

ui.Paragraph _paragrafo(ui.TextStyle s, String texto) {
  final b =
      ui.ParagraphBuilder(
          ui.ParagraphStyle(textDirection: ui.TextDirection.ltr),
        )
        ..pushStyle(s)
        ..addText(texto);
  return b.build()..layout(const ui.ParagraphConstraints(width: 2000));
}

/// Os pixels de [texto] em [s] (para comparar com o arquivo pedido sozinho).
Future<Uint8List> _pixels(ui.TextStyle s, String texto) async {
  final p = _paragrafo(s, texto);
  final r = ui.PictureRecorder();
  ui.Canvas(r).drawParagraph(p, ui.Offset.zero);
  final img = await r.endRecording().toImage(
    p.maxIntrinsicWidth.ceil() + 4,
    p.height.ceil() + 4,
  );
  final bytes = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!
      .buffer
      .asUint8List();
  img.dispose();
  p.dispose();
  return bytes;
}

/// Uma família de teste só com o arquivo [asset] (o que o Skia pinta quando pede esse arquivo).
Future<String> _soEsse(String asset) async {
  final nome = 'G14_${asset.split('/').last}';
  await (FontLoader(nome)..addFont(rootBundle.load(asset))).load();
  return nome;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  test('famílias e versão das fontes', () {
    expect(
      [for (final f in ReaderFontFamily.values) readerFamilyOf(f)],
      ['LiterataVF', 'LoraBook', 'FigtreeBook', 'AtkinsonBook'],
    );
    expect(readerFontsVersion, 2);
  });

  test('estilo por família: eixos e Skia em 400; reserva na Literata (a base antes dos subconjuntos nas outras); '
      'Atkinson pelos arquivos (títulos e negrito em 700)', () {
    const reserva = ['LiterataVF', ...readerFontFallback];
    for (final f in [
      ReaderFontFamily.literata,
      ReaderFontFamily.lora,
      ReaderFontFamily.figtree,
    ]) {
      final t = ReaderTypography(font: f);
      final s = t.spec(RunStyle.plain);
      expect((s.family, s.skiaWeight), (readerFamilyOf(f), ui.FontWeight.w400));
      expect(
        s.fallback,
        f == ReaderFontFamily.literata ? readerFontFallback : reserva,
        reason: '$f',
      );
      expect(s.variations.map((v) => (v.axis, v.value)), [
        ('opsz', 20.5),
        ('wght', 400.0),
      ]);
      expect(t.spec(RunStyle.plain, weight: readerHeadingWeight).wght, 600);
      final negrito = t.spec(const RunStyle(bold: true));
      expect(
        (negrito.wght, negrito.skiaWeight),
        (700.0, ui.FontWeight.w400),
        reason: 'sem negrito sintético',
      );
    }
    const a = ReaderTypography(font: ReaderFontFamily.atkinson);
    final texto = a.spec(RunStyle.plain);
    expect(
      (texto.family, texto.wght, texto.skiaWeight),
      ('AtkinsonBook', 400.0, ui.FontWeight.w400),
    );
    expect(texto.fallback, reserva);
    final titulo = a.spec(
      RunStyle.plain,
      size: 26.65,
      weight: readerHeadingWeight,
    );
    expect((titulo.wght, titulo.skiaWeight), (700.0, ui.FontWeight.w700));
    final negrito = a.spec(const RunStyle(bold: true));
    expect(
      (negrito.family, negrito.wght, negrito.skiaWeight),
      ('AtkinsonBook', 700.0, ui.FontWeight.w700),
    );
    expect(negrito.fallback, reserva);
    expect(a.spec(const RunStyle(italic: true)).italic, isTrue);
    expect(a.runStyle(RunStyle.plain), isA<ui.TextStyle>());
  });

  test('itálico e negrito saem dos arquivos (a imagem é a do arquivo pedido sozinho)', () async {
    const texto = 'Retórica dos namorados';
    // o mesmo estilo do livro, só com a família trocada por uma que tem um arquivo só: se a família do livro
    // escolhesse outro arquivo (ou inclinasse/engrossasse o regular), a imagem mudaria
    Future<void> confere(ReaderFontFamily f, RunStyle r, String asset) async {
      final s = ReaderTypography(
        font: f,
        ink: const ui.Color(0xFF000000),
      ).spec(r);
      final so = await _soEsse(asset);
      ui.TextStyle estilo(String familia) => ui.TextStyle(
        color: s.ink,
        fontFamily: familia,
        fontSize: s.size,
        fontWeight: s.skiaWeight,
        fontStyle: s.italic ? ui.FontStyle.italic : ui.FontStyle.normal,
        height: s.lineSpacing,
        leadingDistribution: ui.TextLeadingDistribution.even,
        fontVariations: s.variations,
      );
      expect(
        await _pixels(estilo(s.family), texto),
        await _pixels(estilo(so), texto),
        reason: asset,
      );
    }

    await confere(
      ReaderFontFamily.lora,
      const RunStyle(italic: true),
      'assets/fonts/livro/Lora-Italic-Wght.ttf',
    );
    await confere(
      ReaderFontFamily.figtree,
      const RunStyle(italic: true),
      'assets/fonts/livro/Figtree-Italic-Wght.ttf',
    );
    await confere(
      ReaderFontFamily.atkinson,
      const RunStyle(italic: true),
      'assets/fonts/livro/AtkinsonHyperlegible-Italic.ttf',
    );
    await confere(
      ReaderFontFamily.atkinson,
      const RunStyle(bold: true),
      'assets/fonts/livro/AtkinsonHyperlegible-Bold.ttf',
    );
    await confere(
      ReaderFontFamily.atkinson,
      const RunStyle(bold: true, italic: true),
      'assets/fonts/livro/AtkinsonHyperlegible-BoldItalic.ttf',
    );
  });

  test(
    'o grego vem da Literata em todas as fontes (mesma largura da Literata)',
    () {
      // sem espaço: o espaço sai da própria fonte
      const grego = 'λόγοςκαὶἦθος';
      final literata = _paragrafo(
        const ReaderTypography().runStyle(RunStyle.plain),
        grego,
      ).maxIntrinsicWidth;
      for (final f in [
        ReaderFontFamily.lora,
        ReaderFontFamily.figtree,
        ReaderFontFamily.atkinson,
      ]) {
        final w = _paragrafo(
          ReaderTypography(font: f).runStyle(RunStyle.plain),
          grego,
        ).maxIntrinsicWidth;
        expect(w, moreOrLessEquals(literata, epsilon: 0.01), reason: '$f');
      }
    },
  );

  test('o grego em negrito na Atkinson é o da Literata em 700 (sem negrito sintético por cima do eixo)', () async {
    const grego = 'λόγοςκαὶἦθος';
    const preto = ui.Color(0xFF000000);
    const negrito = RunStyle(bold: true);
    final atkinson = await _pixels(
      const ReaderTypography(
        font: ReaderFontFamily.atkinson,
        ink: preto,
      ).runStyle(negrito),
      grego,
    );
    expect(
      atkinson,
      await _pixels(
        const ReaderTypography(ink: preto).runStyle(negrito),
        grego,
      ),
    );
    // a imagem mostra o peso (não é a mesma caixa vazia nos dois): o regular é outro
    expect(
      atkinson,
      isNot(
        await _pixels(
          const ReaderTypography(ink: preto).runStyle(RunStyle.plain),
          grego,
        ),
      ),
    );
  });

  test('setas e linhas (′ ″) que a fonte não tem vêm da Literata base: mesma largura da Literata', () {
    double largura(ReaderFontFamily f, String t) => _paragrafo(
      ReaderTypography(font: f).runStyle(RunStyle.plain),
      t,
    ).maxIntrinsicWidth;
    for (final (f, t) in const [
      (ReaderFontFamily.lora, '↑↓'),
      (ReaderFontFamily.figtree, '′″'),
      (ReaderFontFamily.atkinson, '′″↑↓'),
    ]) {
      expect(
        largura(f, t),
        moreOrLessEquals(largura(ReaderFontFamily.literata, t), epsilon: 0.01),
        reason: '$f',
      );
    }
  });

  test('fromLook: a fonte entra; layoutKey muda com a fonte; a cor não muda o layout', () {
    ReaderTypography de(ReaderLook l) =>
        ReaderTypography.fromLook(l, viewportWidth: 390, viewportHeight: 844);
    const base = ReaderLook();
    expect(de(base).font, ReaderFontFamily.literata);
    expect(de(base).layoutKey, const ReaderTypography().layoutKey);
    final keys = {
      for (final f in ReaderFontFamily.values)
        de(base.copyWith(fontFamily: f)).layoutKey,
    };
    expect(keys, hasLength(4));
    final lora = de(base.copyWith(fontFamily: ReaderFontFamily.lora));
    expect(lora.layoutKey, contains('LoraBook'));
    final noite = lora.withInk(const ui.Color(0xFFE3D9C6));
    expect(
      (noite.font, noite.layoutKey),
      (ReaderFontFamily.lora, lora.layoutKey),
    );
  });

  test(
    'área do texto (o fundo do grifo) por fonte: ascent + descent de cada uma',
    () {
      expect(readerTextArea(20.5), moreOrLessEquals(30.44, epsilon: 0.05));
      expect(
        readerTextArea(20.5, ReaderFontFamily.literata),
        readerTextArea(20.5),
      );
      // hhea: Lora 1006/−274, Figtree 950/−250, Atkinson 950/−290 (por 1000)
      expect(
        readerTextArea(20.5, ReaderFontFamily.lora),
        moreOrLessEquals(1.28 * 20.5, epsilon: 0.05),
      );
      expect(
        readerTextArea(20.5, ReaderFontFamily.figtree),
        moreOrLessEquals(1.2 * 20.5, epsilon: 0.05),
      );
      expect(
        readerTextArea(20.5, ReaderFontFamily.atkinson),
        moreOrLessEquals(1.24 * 20.5, epsilon: 0.05),
      );
    },
  );
}
