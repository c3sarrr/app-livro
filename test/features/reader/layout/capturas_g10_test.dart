// G10.5 — capturas das páginas (D-101) e medida das páginas por tamanho de letra. As páginas são pintadas pelo
// motor (`paintReaderPage`) sobre o papel creme, @3x, sem rodapé (o rodapé é da tela, G11):
// - começo do cap. I do Dom Casmurro (título, sem recuo no 1º parágrafo), no padrão e em 26;
// - um capítulo de fixture com título + subtítulo, citação, lista com subnível, imagem e quebra de cena.
// Com BOOKNEST_CAPTURAS=<pasta> os PNG são gravados lá (fora do git). Sem a pasta, o teste ainda confere que
// cada elemento aparece onde deve na página. A medida por tamanho de letra só roda com BOOKNEST_MEDIR=1.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/chapter_content.dart';
import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:app_leitura/features/reader/layout/chapter_layout.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/page_painter.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/epub_builder.dart';
import '../../../support/load_fonts.dart';
import '../../../support/medida.dart';

const String _domCasmurro = 'test/fixtures/livros/pg55752.epub';
const ui.Color _papel = ui.Color(0xFFF8F1E4);

/// Ilustração de fixture (PNG 600×360): moldura grossa e formas chapadas.
Future<Uint8List> _ilustracao() async {
  final rec = ui.PictureRecorder();
  final c = ui.Canvas(rec);
  final tinta = ui.Paint()..color = const ui.Color(0xFF1B1A17);
  c
    ..drawRect(const ui.Rect.fromLTWH(0, 0, 600, 360), tinta)
    ..drawRect(
      const ui.Rect.fromLTWH(12, 12, 576, 336),
      ui.Paint()..color = const ui.Color(0xFFE9C46A),
    )
    ..drawCircle(const ui.Offset(190, 180), 96, tinta)
    ..drawRect(
      const ui.Rect.fromLTWH(320, 96, 200, 168),
      ui.Paint()..color = const ui.Color(0xFFE76F51),
    );
  final img = await rec.endRecording().toImage(600, 360);
  final png = await img.toByteData(format: ui.ImageByteFormat.png);
  img.dispose();
  return png!.buffer.asUint8List();
}

Future<ui.Image> _decodificar(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  codec.dispose();
  return frame.image;
}

/// Pinta [page] do capítulo [layout] @3x no papel; grava em `BOOKNEST_CAPTURAS/<nome>.png` quando há pasta.
Future<int> _capturar(
  String nome,
  ChapterLayout layout,
  ReaderPage page,
  ReaderTypography t, {
  ReaderImageOf? imageOf,
}) async {
  const escala = 3.0;
  final w = t.viewportWidth;
  final h = t.viewportHeight;
  final rec = ui.PictureRecorder();
  final c = ui.Canvas(rec)
    ..scale(escala)
    ..drawRect(ui.Rect.fromLTWH(0, 0, w, h), ui.Paint()..color = _papel);
  paintReaderPage(c, page, (b) => layout.blocks[b], t, imageOf: imageOf);
  final img = await rec.endRecording().toImage(
    (w * escala).round(),
    (h * escala).round(),
  );
  final png = await img.toByteData(format: ui.ImageByteFormat.png);
  img.dispose();
  final pasta = Platform.environment['BOOKNEST_CAPTURAS'];
  if (pasta != null) {
    Directory(pasta).createSync(recursive: true);
    File('$pasta${Platform.pathSeparator}$nome.png')
        .writeAsBytesSync(png!.buffer.asUint8List());
  }
  return png!.lengthInBytes;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);
  late EpubBook livro;
  setUpAll(() => livro = EpubBook.open(_domCasmurro));
  tearDownAll(() => livro.close());

  test(
    'Dom Casmurro: começo do cap. I ("Do titulo."), no padrão e em 26',
    () async {
      // os capítulos do Gutenberg ficam no meio dos itens: a página é a que contém o começo do capítulo
      final index = indexEpubFile(_domCasmurro, 'e' * 64);
      final cap = index.toc.firstWhere(
        (t) => t.title.trim().toLowerCase().startsWith('do titulo'),
      );
      for (final (t, nome) in const [
        (ReaderTypography(), 'g10_dom_casmurro_capitulo_I_20.5'),
        (ReaderTypography(fontSize: 26), 'g10_dom_casmurro_capitulo_I_26'),
      ]) {
        final layout = ChapterLayoutJob(
          chapterOf(livro, cap.spine!),
          t,
        ).runAll();
        addTearDown(layout.dispose);
        final page = layout.pages[layout.pageAt(cap.offset ?? 0)];
        // o título do capítulo está na página e o parágrafo logo depois dele não tem recuo (D-96)
        final blocos = [for (final s in page.slices) layout.blocks[s.block]];
        final titulo = blocos.indexWhere((b) => b is LaidText && b.isHeading);
        expect(titulo, greaterThanOrEqualTo(0));
        final depois = blocos
            .skip(titulo + 1)
            .whereType<LaidText>()
            .firstWhere((b) => !b.isHeading);
        expect(depois.pieces.first.placeholder, isFalse);
        expect(await _capturar(nome, layout, page, t), greaterThan(10000));
      }
    },
  );

  test('título, subtítulo, citação, lista, imagem e quebra de cena', () async {
    final dir = Directory.systemTemp.createTempSync('booknest_g10_cap_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final png = await _ilustracao();
    const corpo =
        '<h1>Capítulo Primeiro</h1>'
        '<h2>Em que se conta como a casa mudou de dono</h2>'
        '<p>Era uma casa antiga, de janelas largas e soalho que estalava a cada passo. Ninguém se lembrava '
        'de quem a construíra, mas todos sabiam o nome de quem a deixara cair.</p>'
        '<p>Na primeira noite, a nova dona contou as portas e achou uma a mais do que a planta dizia.</p>'
        '<blockquote><p>Uma casa é a soma das histórias que ninguém contou em voz alta.</p></blockquote>'
        '<p>Na manhã seguinte, fez uma lista do que precisava:</p>'
        '<ul><li>trocar as dobradiças da porta da cozinha;</li>'
        '<li>descobrir a porta que sobrava<ul><li>e para onde ela dava;</li></ul></li>'
        '<li>dormir.</li></ul>'
        '<img src="img/casa.png" alt="A casa"/>'
        '<p>Não dormiu. A porta que sobrava dava para um quarto sem janelas e com uma cadeira no meio.</p>'
        '<hr/>'
        '<p>Três dias depois, a cadeira tinha mudado de lugar.</p>';
    final book = EpubBook.open(
      writeTemp(
        dir,
        'elementos.epub',
        simpleEpub(
          chapters: const [(file: 'c1.xhtml', title: 'I', body: corpo)],
          extra: {'OEBPS/img/casa.png': png},
        ),
      ),
    );
    addTearDown(book.close);
    const t = ReaderTypography();
    final content = chapterOf(book, 0);
    expect(content.imageSizes.values.single, (600, 360));
    final layout = ChapterLayoutJob(content, t).runAll();
    addTearDown(layout.dispose);
    final imagem = await _decodificar(png);
    addTearDown(imagem.dispose);

    // cada elemento está em alguma página, inteiro
    final tipos = <String>{};
    for (final p in layout.pages) {
      for (final s in p.slices) {
        final b = layout.blocks[s.block];
        tipos.add(switch (b) {
          LaidText(isHeading: true) => 'título',
          LaidText(bullet: ui.Paragraph()) => 'lista',
          LaidText(left: final l) when l > 0 => 'citação',
          LaidText() => 'parágrafo',
          LaidImage() => 'imagem',
          LaidSceneBreak() => 'cena',
        });
      }
    }
    expect(
      tipos,
      containsAll([
        'título',
        'citação',
        'lista',
        'imagem',
        'cena',
        'parágrafo',
      ]),
    );
    final img = layout.blocks.whereType<LaidImage>().single;
    expect(img.drawWidth, lessThanOrEqualTo(t.contentWidth));
    expect(img.drawHeight, closeTo(img.drawWidth * 360 / 600, 0.01));

    for (var i = 0; i < layout.pages.length; i++) {
      expect(
        await _capturar(
          'g10_elementos_pagina_${i + 1}',
          layout,
          layout.pages[i],
          t,
          imageOf: (path) => path.endsWith('casa.png') ? imagem : null,
        ),
        greaterThan(10000),
      );
    }
  });

  test('páginas do Dom Casmurro por tamanho de letra (medida)', () {
    final index = indexEpubFile(_domCasmurro, 'e' * 64);
    final linhas = <String>[];
    for (final size in readerFontSizes) {
      final t = ReaderTypography(fontSize: size);
      final sw = Stopwatch()..start();
      var paginas = 0;
      for (var i = 0; i < index.spine.length; i++) {
        if (!index.spine[i].linear) continue;
        final layout = ChapterLayoutJob(chapterOf(livro, i), t).runAll();
        paginas += layout.pages.length;
        layout.dispose();
      }
      linhas.add('$size: $paginas páginas em ${sw.elapsedMilliseconds} ms');
    }
    // ignore: avoid_print
    print(
      'G10.5 páginas por tamanho de letra (Dom Casmurro, ${index.refPagesTotal} págs. de referência):\n'
      '  ${linhas.join('\n  ')}',
    );
    expect(linhas, hasLength(readerFontSizes.length));
  }, skip: medindo ? false : 'só na rodada de medida (BOOKNEST_MEDIR=1)');
}
