// G11 (D-114) — as imagens do EPUB aparecem na página: lidas do arquivo sob pedido da página que vai pintar,
// decodificadas na largura da caixa do texto × densidade (nunca maiores), a página repinta quando a imagem chega,
// a memória tem orçamento (as menos usadas saem), e a imagem quebrada fica como o espaço vazio da página.
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/application/epub_images.dart';
import 'package:app_leitura/features/reader/application/epub_reader_document.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:flutter/foundation.dart' show Listenable;
import 'package:flutter_test/flutter_test.dart';

import '../../../support/epub_builder.dart';
import '../../../support/load_fonts.dart';
import '../../../support/reader_harness.dart';

Future<Uint8List> _png(int w, int h, ui.Color cor) async {
  final rec = ui.PictureRecorder();
  ui.Canvas(rec).drawRect(
    ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
    ui.Paint()..color = cor,
  );
  final img = await rec.endRecording().toImage(w, h);
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  img.dispose();
  return data!.buffer.asUint8List();
}

/// Espera [changes] avisar (até 5 s).
Future<void> _aviso(Listenable changes) {
  final c = Completer<void>();
  void ouvir() {
    if (!c.isCompleted) c.complete();
  }

  changes.addListener(ouvir);
  return c.future
      .timeout(const Duration(seconds: 5))
      .whenComplete(() => changes.removeListener(ouvir));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  test('a imagem aparece na página: pedida ao pintar, na largura da caixa, e a página repinta quando chega', () async {
    const vermelho = ui.Color(0xFFD03020);
    final livro = await LivroNaEstante.epubDe(
      simpleEpub(
        chapters: [
          (
            file: 'c1.xhtml',
            title: 'Um',
            body: '<p>Antes da figura.</p><img src="fig.png" alt="figura"/><p>Depois.</p>',
          ),
        ],
        extra: {'OEBPS/fig.png': await _png(2000, 1000, vermelho)},
      ),
    );
    addTearDown(livro.close);
    final d = await EpubReaderDocument.open(livro.deps());
    addTearDown(d.dispose);
    final pagina = d.current as PageSnapshot;
    final slice = pagina.page.slices.whereType<ObjectSlice>().single;
    final figura = pagina.block(slice.block) as LaidImage;
    const t = ReaderTypography();
    expect(
      figura.drawWidth,
      closeTo(t.contentWidth, 0.01),
      reason: 'escalada para caber na largura',
    );

    Future<ui.Color> corNoMeio() async {
      final rec = ui.PictureRecorder();
      d.current.paint(ui.Canvas(rec));
      final img = await rec.endRecording().toImage(390, 844);
      final px = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      img.dispose();
      final x = (t.sideMargin + figura.left + figura.drawWidth / 2).round();
      final y = (t.topInset + slice.y + figura.drawTop + figura.drawHeight / 2)
          .round();
      final i = (y * 390 + x) * 4;
      return ui.Color.fromARGB(
        px.getUint8(i + 3),
        px.getUint8(i),
        px.getUint8(i + 1),
        px.getUint8(i + 2),
      );
    }

    final chegou = _aviso(d.changes);
    expect(
      (await corNoMeio()).a,
      0,
      reason: 'ainda não chegou: o lugar dela fica vazio',
    );
    await chegou;
    expect(await corNoMeio(), vermelho);
  });

  test(
    'decodifica na largura máxima em que pode aparecer (nunca amplia)',
    () async {
      final grande = await decodeImageForWidth(
        await _png(2000, 1000, const ui.Color(0xFF000000)),
        1002,
      );
      expect((grande.width, grande.height), (1002, 501));
      grande.dispose();
      final pequena = await decodeImageForWidth(
        await _png(300, 200, const ui.Color(0xFF000000)),
        1002,
      );
      expect((pequena.width, pequena.height), (300, 200));
      pequena.dispose();
    },
  );

  test('orçamento: as menos usadas saem; quebrada fica vazia e não é lida de novo; fechar solta tudo', () async {
    final png = await _png(
      100,
      100,
      const ui.Color(0xFF102030),
    ); // 40 kB decodificada
    final lidas = <String>[];
    final cache = EpubImageCache(
      load: (href) async {
        lidas.add(href);
        return href == 'quebrada.png' ? Uint8List.fromList([1, 2, 3]) : png;
      },
      maxWidth: 1000,
      budgetBytes: 90 * 1000, // cabem 2
    );
    for (final h in ['a.png', 'b.png', 'c.png']) {
      final veio = _aviso(cache.changes);
      expect(cache.imageOf(h), isNull);
      await veio;
      expect(cache.imageOf(h), isNotNull);
    }
    expect(cache.length, 2);
    expect(
      cache.imageOf('b.png'),
      isNotNull,
      reason: 'as 2 mais recentes ficam',
    );
    expect(
      cache.imageOf('a.png'),
      isNull,
      reason: 'a mais antiga saiu (e vai ser lida de novo)',
    );

    expect(cache.imageOf('quebrada.png'), isNull);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(cache.imageOf('quebrada.png'), isNull);
    expect(lidas.where((h) => h == 'quebrada.png'), hasLength(1));

    cache.dispose();
    expect(cache.length, 0);
    expect(cache.imageOf('c.png'), isNull);
    cache.dispose(); // de novo: nada
  });

  test('no app, a imagem é lida do arquivo num isolate; o que não está no arquivo = null', () async {
    final png = await _png(40, 20, const ui.Color(0xFF00AA00));
    final livro = await LivroNaEstante.epubDe(
      simpleEpub(
        chapters: [(file: 'c1.xhtml', title: 'Um', body: '<p>Texto.</p>')],
        extra: {'OEBPS/fig.png': png},
      ),
    );
    addTearDown(livro.close);
    final ler = isolateImageLoader(livro.path);
    expect(await ler('OEBPS/fig.png'), png);
    expect(await ler('OEBPS/nada.png'), isNull);
  });
}
