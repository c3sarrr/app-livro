// G09.4 — PDF pelo PDFium de verdade (`pdfrx`; o binário vem pelo native asset do `pdfium_dart`): páginas,
// título/autor do Info sem enchimento, sumário, 1ª página como capa (PNG), senha → protegido, lixo → danificado.
// PDFs de fixture gerados por `tools/fixtures/gerar_pdfs_g09.py`.
import 'dart:io';
import 'dart:typed_data';

import 'package:app_leitura/features/library/data/pdf_inspector.dart';
import 'package:app_leitura/features/library/data/pdfrx_pdf_inspector.dart';
import 'package:app_leitura/features/library/data/png_encoder.dart';
import 'package:app_leitura/features/reader/content/content_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart' show pdfrxInitialize;

void main() {
  group('texto do Info (enchimento dos geradores some)', () {
    test(
      'valores vazios, "untitled", nome de arquivo e "Microsoft Word - "',
      () {
        expect(cleanPdfText(null), isNull);
        expect(cleanPdfText('  '), isNull);
        expect(cleanPdfText('untitled'), isNull);
        expect(cleanPdfText('Anonymous'), isNull);
        expect(cleanPdfText('relatorio_final.docx'), isNull);
        expect(cleanPdfText('Microsoft Word - Memórias.docx'), isNull);
        expect(
          cleanPdfText('Microsoft Word - Memórias póstumas'),
          'Memórias póstumas',
        );
        expect(cleanPdfText(' Contos\nde  Teste '), 'Contos de Teste');
      },
    );
  });

  test('PNG da capa: assinatura, IHDR e pixels (BGRA → RGBA) de volta', () {
    // 2×1: um pixel azul opaco e um vermelho meio transparente (BGRA)
    final bgra = Uint8List.fromList([255, 0, 0, 255, 0, 0, 255, 128]);
    final png = encodePngFromBgra(bgra, 2, 1);
    expect(png.sublist(0, 8), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
    final d = ByteData.sublistView(png);
    expect(String.fromCharCodes(png.sublist(12, 16)), 'IHDR');
    expect((d.getUint32(16), d.getUint32(20), png[24], png[25]), (2, 1, 8, 6));
    final idatLen = d.getUint32(33);
    expect(String.fromCharCodes(png.sublist(37, 41)), 'IDAT');
    final raw = ZLibDecoder().convert(png.sublist(41, 41 + idatLen));
    expect(raw, [0, 0, 0, 255, 255, 255, 0, 0, 128]);
    expect(
      String.fromCharCodes(png.sublist(png.length - 8, png.length - 4)),
      'IEND',
    );
    expect(() => encodePngFromBgra(bgra, 3, 1), throwsArgumentError);
  });

  group('PDFium (pdfrx)', () {
    late PdfrxPdfInspector inspetor;
    late Directory tmp;
    setUpAll(() {
      tmp = Directory.systemTemp.createTempSync('booknest_pdfrx_');
      inspetor = PdfrxPdfInspector(
        initialize: () => pdfrxInitialize(tmpPath: tmp.path),
      );
    });
    tearDownAll(() => tmp.deleteSync(recursive: true));

    test(
      'amostra: 3 páginas, título e autor, sumário, capa PNG da 1ª página',
      () async {
        final i = await inspetor.inspect('test/fixtures/livros/amostra.pdf');
        expect(i.pages, 3);
        expect(i.title, 'Contos de Teste');
        expect(i.author, 'Autora Exemplo');
        expect(i.outline.map((o) => (o.title, o.page, o.depth)), [
          ('Primeiro conto', 1, 0),
          ('Segundo conto', 3, 0),
        ]);
        final png = i.coverPng!;
        expect(png.sublist(1, 4), 'PNG'.codeUnits);
        final d = ByteData.sublistView(png);
        // A5 (420×595 pt) com 400 px de largura
        expect(d.getUint32(16), 400);
        expect(d.getUint32(20), inInclusiveRange(567, 568));
      },
    );

    test(
      'sem título de verdade ("untitled"/"anonymous" do gerador): nulos',
      () async {
        final i = await inspetor.inspect('test/fixtures/livros/sem_titulo.pdf');
        expect(i.pages, 1);
        expect(i.title, isNull);
        expect(i.author, isNull);
        expect(i.outline, isEmpty);
      },
    );

    test('com senha → protegido; lixo com cara de PDF → danificado', () async {
      await expectLater(
        inspetor.inspect('test/fixtures/livros/protegido.pdf'),
        throwsA(isA<ContentProtected>()),
      );
      final lixo = File('${tmp.path}${Platform.pathSeparator}lixo.pdf')
        ..writeAsStringSync('%PDF-1.7\nisto não é um PDF de verdade');
      await expectLater(
        inspetor.inspect(lixo.path),
        throwsA(isA<ContentDamaged>()),
      );
    });
  });
}
