// G09.4 — PDF pelo PDFium (`pdfrx`, Anexo 03 §2): páginas, Info (título/autor — pela API C, que o `pdfrx` não
// expõe), sumário e a 1ª página como capa. Senha → protegido; o PDFium recusou → danificado.
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:pdfium_dart/pdfium_dart.dart' as pdfium;
import 'package:pdfrx/pdfrx.dart';

import '../../reader/content/content_failure.dart';
import 'pdf_inspector.dart';
import 'png_encoder.dart';

final class PdfrxPdfInspector implements PdfInspector {
  PdfrxPdfInspector({
    Future<void> Function()? initialize,
    this.coverWidth = 400,
  }) : _initialize = initialize ?? pdfrxFlutterInitialize;

  final Future<void> Function() _initialize;

  /// Largura da capa tirada da 1ª página (px).
  final int coverWidth;

  @override
  Future<PdfInfo> inspect(String path) async {
    await _initialize();
    final PdfDocument doc;
    try {
      doc = await PdfDocument.openFile(path);
    } on PdfPasswordException {
      throw const ContentProtected('pdf_password');
    } on PdfException {
      throw const ContentDamaged('pdf');
    }
    try {
      final pages = doc.pages;
      if (pages.isEmpty) throw const ContentDamaged('pdf_sem_paginas');
      final (title, author) = await doc.useNativeDocumentHandle(
        (h) => (_meta(h, 'Title'), _meta(h, 'Author')),
      );
      final outline = <PdfOutlineEntry>[];
      void walk(List<PdfOutlineNode> nodes, int depth) {
        for (final n in nodes) {
          outline.add(
            PdfOutlineEntry(
              title: n.title.trim(),
              page: n.dest?.pageNumber,
              depth: depth,
              hasChildren: n.children.isNotEmpty,
            ),
          );
          walk(n.children, depth + 1);
        }
      }

      try {
        walk(await doc.loadOutline(), 0);
      } on PdfException {
        // sem sumário
      }
      return PdfInfo(
        pages: pages.length,
        title: cleanPdfText(title),
        author: cleanPdfText(author),
        outline: List.unmodifiable(outline),
        coverPng: await _cover(pages.first),
      );
    } on ContentFailure {
      rethrow;
    } on PdfException {
      throw const ContentDamaged('pdf');
    } finally {
      await doc.dispose();
    }
  }

  Future<Uint8List?> _cover(PdfPage page) async {
    if (page.width <= 0 || page.height <= 0) return null;
    final w = coverWidth;
    final h = (page.height / page.width * w).round().clamp(1, w * 4);
    final img = await page.render(
      width: w,
      height: h,
      fullWidth: w.toDouble(),
      fullHeight: h.toDouble(),
      backgroundColor: 0xFFFFFFFF,
    );
    if (img == null) return null;
    try {
      return encodePngFromBgra(img.pixels, img.width, img.height);
    } finally {
      img.dispose();
    }
  }

  /// Texto do dicionário Info (`FPDF_GetMetaText`, UTF-16LE terminado em dois zeros).
  static String? _meta(int handle, String tag) {
    final lib = pdfium.getPdfium(modulePath: Pdfrx.pdfiumModulePath);
    final doc = ffi.Pointer<pdfium.fpdf_document_t__>.fromAddress(handle);
    final t = tag.toNativeUtf8();
    try {
      final n = lib.FPDF_GetMetaText(doc, t.cast(), ffi.nullptr, 0);
      if (n <= 2) return null;
      final buf = calloc<ffi.Uint8>(n);
      try {
        lib.FPDF_GetMetaText(doc, t.cast(), buf.cast(), n);
        return String.fromCharCodes(
          buf.cast<ffi.Uint16>().asTypedList((n - 2) ~/ 2),
        );
      } finally {
        calloc.free(buf);
      }
    } finally {
      calloc.free(t);
    }
  }
}
