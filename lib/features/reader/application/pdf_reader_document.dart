// G11.4 — o PDF aberto para a tela (D-109): cada página do PDF é pintada como imagem (PDFium pelo `pdfrx`, o
// mesmo da importação), na largura da tela menos 8 px de cada lado, centralizada entre o topo e o rodapé, sobre
// a cor do papel (a página em si não muda de cor — D-43). Virar é igual ao EPUB; "pág. X de Y" = páginas do PDF
// (D-89) e "%" = começo da página ÷ total. Ficam na memória só a imagem da página atual e das vizinhas.
// Zoom, texto selecionável, grifo e tinta no PDF ficam para as fases deles.
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show Listenable, ValueNotifier;
import 'package:pdfrx/pdfrx.dart';

import '../../library/domain/user_book.dart';
import '../content/content_failure.dart';
import 'pdf_position_keeper.dart';
import 'reader_document.dart';

/// Margem lateral da página do PDF (D-109).
const double pdfSideMargin = 8;

/// Folga entre a página e o rodapé.
const double pdfFooterGap = 8;

/// Altura da linha do rodapé (Figtree 11,5 — L19: 13,81).
const double readerFooterLine = 13.81;

/// Onde a página do PDF fica na tela: a maior possível dentro da faixa entre [top] (a área segura de cima) e
/// o rodapé, com [pdfSideMargin] dos lados, centralizada.
ui.Rect pdfPageRect({
  required ui.Size pageSize,
  required ui.Size viewport,
  required double top,
  required double footerBottom,
}) {
  final bottom =
      viewport.height - footerBottom - readerFooterLine - pdfFooterGap;
  final maxW = viewport.width - 2 * pdfSideMargin;
  final maxH = math.max(1.0, bottom - top);
  if (pageSize.width <= 0 || pageSize.height <= 0) {
    return ui.Rect.fromLTWH(pdfSideMargin, top, maxW, maxH);
  }
  final scale = math.min(maxW / pageSize.width, maxH / pageSize.height);
  final w = pageSize.width * scale;
  final h = pageSize.height * scale;
  return ui.Rect.fromLTWH((viewport.width - w) / 2, top + (maxH - h) / 2, w, h);
}

/// A página [index] do PDF pronta para a tela.
final class PdfDisplayPage implements DisplayPage {
  PdfDisplayPage(this.index, this.image, this.rect, this.text);

  final int index;
  final ui.Image image;
  final ui.Rect rect;
  final String text;
  bool _disposed = false;

  @override
  bool get alive => !_disposed;

  @override
  void paint(ui.Canvas canvas) {
    if (_disposed) return;
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      rect,
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );
  }

  @override
  String get spokenText => text;

  /// Links do PDF ficam para depois (D-109).
  @override
  LinkHit? linkAt(ui.Offset p) => null;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    image.dispose();
  }
}

final class PdfReaderDocument implements ReaderDocument {
  PdfReaderDocument._(
    this._book,
    this._doc,
    this._keeper,
    this._viewport,
    this._top,
    this._footerBottom,
    this._dpr,
  );

  /// Abre o PDF em [path] onde a pessoa parou. PDF com senha ou quebrado → [ContentDamaged].
  static Future<PdfReaderDocument> open({
    required UserBook book,
    required String path,
    required PdfPositionKeeper keeper,
    required ui.Size viewport,
    required double top,
    required double footerBottom,
    required double devicePixelRatio,
    Future<void> Function()? initialize,
  }) async {
    await (initialize ?? pdfrxFlutterInitialize)();
    final PdfDocument doc;
    try {
      doc = await PdfDocument.openFile(path);
    } on PdfException {
      throw const ContentDamaged('pdf');
    }
    final d = PdfReaderDocument._(
      book,
      doc,
      keeper,
      viewport,
      top,
      footerBottom,
      devicePixelRatio,
    );
    try {
      if (doc.pages.isEmpty) throw const ContentDamaged('pdf_sem_paginas');
      final start = await keeper.savedPage(doc.pages.length);
      d._pages[start] = await d._render(start);
      d._at = start;
      d._announce();
      d._prefetch();
      return d;
    } on Object {
      d.dispose();
      rethrow;
    }
  }

  final UserBook _book;
  final PdfDocument _doc;
  final PdfPositionKeeper _keeper;
  final ui.Size _viewport;
  final double _top;
  final double _footerBottom;
  final double _dpr;
  final Map<int, PdfDisplayPage> _pages = {};
  final Map<int, Future<PdfDisplayPage>> _rendering = {};
  final _changes = ValueNotifier<int>(0);
  int _at = 0;
  bool _disposed = false;

  int get pageCount => _doc.pages.length;

  @override
  String get title => _book.title;

  @override
  DisplayPage get current => _pages[_at]!;

  @override
  Listenable get changes => _changes;

  @override
  ReaderNumbersView get numbers => ReaderNumbersView(
    refPage: _at + 1,
    refTotal: pageCount,
    progression: pdfProgression(_at, pageCount),
  );

  @override
  ReaderMark get mark => (spine: 0, offset: _at);

  @override
  RefRange get shownRange => (fromRef: _at + 1, toRef: _at + 1);

  int? _neighbor(PageDirection d) {
    final j = d == PageDirection.forward ? _at + 1 : _at - 1;
    return j < 0 || j >= pageCount ? null : j;
  }

  @override
  Future<DisplayPage?> peek(PageDirection d) async {
    final j = _neighbor(d);
    if (j == null || _disposed) return null;
    try {
      return await _page(j);
    } on Object {
      return null; // o erro aparece ao virar
    }
  }

  @override
  Future<bool> turn(PageDirection d) async {
    final j = _neighbor(d);
    if (j == null || _disposed) return false;
    await _show(j);
    return true;
  }

  @override
  Future<void> goTo(ReaderMark m) async {
    if (pageCount == 0 || _disposed) return;
    await _show(m.offset.clamp(0, pageCount - 1));
  }

  @override
  Future<bool> follow(LinkHit link) async => false;

  @override
  Future<void> flush() => _keeper.flush();

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _keeper.dispose();
    for (final p in _pages.values) {
      p.dispose();
    }
    _pages.clear();
    _changes.dispose();
    unawaited(_doc.dispose());
  }

  Future<void> _show(int page) async {
    await _page(page);
    if (_disposed) return;
    _at = page;
    _evict();
    _announce();
    _changes.value++;
    _prefetch();
  }

  /// Só a atual e as vizinhas ficam na memória.
  void _evict() {
    for (final k in _pages.keys.toList()) {
      if ((k - _at).abs() > 1) _pages.remove(k)!.dispose();
    }
  }

  void _prefetch() {
    for (final d in PageDirection.values) {
      final j = _neighbor(d);
      if (j != null) unawaited(peek(d));
    }
  }

  void _announce() => _keeper.pageShown(_at, pageCount);

  Future<PdfDisplayPage> _page(int index) {
    final have = _pages[index];
    if (have != null && have.alive) return Future.value(have);
    return _rendering[index] ??= _render(index)
        .then((p) {
          if (_disposed) {
            p.dispose();
            return p;
          }
          // fica guardada; a próxima virada solta as que estão longe
          _pages[index]?.dispose();
          return _pages[index] = p;
        })
        .whenComplete(() {
          _rendering.remove(index);
        });
  }

  Future<PdfDisplayPage> _render(int index) async {
    final page = _doc.pages[index];
    final rect = pdfPageRect(
      pageSize: ui.Size(page.width, page.height),
      viewport: _viewport,
      top: _top,
      footerBottom: _footerBottom,
    );
    final w = math.max(1, (rect.width * _dpr).round());
    final h = math.max(1, (rect.height * _dpr).round());
    final img = await page.render(
      width: w,
      height: h,
      fullWidth: w.toDouble(),
      fullHeight: h.toDouble(),
      backgroundColor: 0xFFFFFFFF,
    );
    if (img == null) throw const ContentDamaged('pdf_pagina');
    final ui.Image image;
    try {
      image = await img.createImage();
    } finally {
      img.dispose();
    }
    var text = '';
    try {
      text = (await page.loadStructuredText()).fullText.trim();
    } on Object {
      // sem texto (página escaneada): o leitor de tela fica só com o rótulo
    }
    return PdfDisplayPage(index, image, rect, text);
  }
}
