// Ajuste da G10 (D-102/D-103) — a troca de cena pintada: um fio curto e grosso, centralizado na linha dele, na
// cor do texto; a linha decorativa colada num título não pinta nada (só o espaço).
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/content/content_blocks.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/page_painter.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/load_fonts.dart';

const ui.Color _papel = ui.Color(0xFFF8F1E4);

ParagraphBlock _p(String t) => ParagraphBlock([TextRun(t)], BlockStyle.none);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);
  const t = ReaderTypography();

  /// Pinta a 1ª página de [blocks] a 1× e devolve os pixels RGBA e o topo da faixa do bloco 1.
  Future<(Uint8List, double)> pintar(List<ContentBlock> blocks) async {
    final starts = <int>[];
    var at = 0;
    for (final b in blocks) {
      starts.add(at);
      at += b.text.length + 1;
    }
    final laid = BlockLayouter(t).layoutAll(blocks, starts);
    addTearDown(() {
      for (final b in laid) {
        b.dispose();
      }
    });
    final page = paginateChapter(laid, t.contentHeight).first;
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec)
      ..drawRect(
        ui.Rect.fromLTWH(0, 0, t.viewportWidth, t.viewportHeight),
        ui.Paint()..color = _papel,
      );
    paintReaderPage(c, page, (b) => laid[b], t);
    final img = await rec.endRecording().toImage(
      t.viewportWidth.toInt(),
      t.viewportHeight.toInt(),
    );
    final px = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    img.dispose();
    final s = page.slices.firstWhere((s) => s.block == 1);
    return (px.buffer.asUint8List(), t.topInset + s.y);
  }

  ui.Color cor(Uint8List px, double x, double y) {
    final i = (y.floor() * t.viewportWidth.toInt() + x.floor()) * 4;
    return ui.Color.fromARGB(px[i + 3], px[i], px[i + 1], px[i + 2]);
  }

  test('fio entre parágrafos: na cor do texto, centralizado, com a largura e a espessura do fio', () async {
    final (px, topo) = await pintar([
      _p('Antes.'),
      const SceneBreakBlock(),
      _p('Depois.'),
    ]);
    final meio = topo + t.lineHeight / 2;
    final centro = t.sideMargin + t.contentWidth / 2;
    final w = sceneRuleEms * t.fontSize;
    expect(cor(px, centro, meio), t.ink);
    expect(cor(px, centro - w / 2 + 1, meio), t.ink);
    expect(cor(px, centro + w / 2 - 1, meio), t.ink);
    // fora do fio: papel
    expect(cor(px, centro - w / 2 - 2, meio), _papel);
    expect(cor(px, centro, meio - sceneRuleThickness), _papel);
    expect(cor(px, centro, meio + sceneRuleThickness), _papel);
  });

  test(
    'linha decorativa colada num título: só o espaço, nada pintado',
    () async {
      final (px, topo) = await pintar([
        const HeadingBlock(5, [TextRun('PARIZ')], BlockStyle.none),
        const SceneBreakBlock(),
        _p('Indice'),
      ]);
      final meio = topo + t.lineHeight / 2;
      for (var x = t.sideMargin; x < t.sideMargin + t.contentWidth; x += 3) {
        expect(cor(px, x, meio), _papel, reason: 'x = $x');
      }
    },
  );
}
