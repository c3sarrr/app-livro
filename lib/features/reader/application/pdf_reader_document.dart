// G11.4 — o PDF aberto para a tela (D-109): cada página do PDF é pintada como imagem (PDFium pelo `pdfrx`, o
// mesmo da importação), na largura da tela menos 8 px de cada lado, centralizada entre o topo e o rodapé, sobre
// a cor do papel (a página em si não muda de cor — D-43). Virar é igual ao EPUB; "pág. X de Y" = páginas do PDF
// (D-89) e "%" = começo da página ÷ total. Ficam na memória só a imagem da página atual e das vizinhas.
// Zoom, texto selecionável, grifo e tinta no PDF ficam para as fases deles.
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart'
    show Listenable, ValueNotifier, visibleForTesting;
import 'package:pdfrx/pdfrx.dart';

import '../../library/domain/user_book.dart';
import '../content/content_failure.dart';
import '../content/ref_pages.dart' show refPageChars;
import 'book_search.dart';
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

/// A página [index] do PDF pronta para a tela. [text] é o texto da página como o PDFium dá (a busca conta as
/// posições nele) e [charRects] o retângulo de cada caractere em pontos do PDF (origem embaixo, à esquerda).
final class PdfDisplayPage implements DisplayPage {
  PdfDisplayPage(
    this.index,
    this.image,
    this.rect,
    this.text, {
    this.pageSize = ui.Size.zero,
    this.charRects = const [],
  });

  /// Sem imagem: só o texto e as medidas (teste das conversões).
  @visibleForTesting
  PdfDisplayPage.forTest({
    required this.index,
    required this.rect,
    required this.pageSize,
    required this.text,
    required this.charRects,
  }) : image = null;

  final int index;
  final ui.Image? image;
  final ui.Rect rect;
  final String text;
  final ui.Size pageSize;
  final List<PdfRect> charRects;
  bool _disposed = false;

  @override
  bool get alive => !_disposed;

  @override
  void paint(ui.Canvas canvas) {
    final img = image;
    if (_disposed || img == null) return;
    canvas.drawImageRect(
      img,
      ui.Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      rect,
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );
  }

  @override
  String get spokenText => text.trim();

  /// Links do PDF ficam para depois (D-109).
  @override
  LinkHit? linkAt(ui.Offset p) => null;

  /// Os caracteres [from]…[to] da página [unit], unidos por linha (mesma altura) e levados para a tela.
  @override
  List<ui.Rect> rectsOf(int unit, int from, int to) {
    if (_disposed || unit != index || pageSize.isEmpty) return const [];
    final a = from.clamp(0, charRects.length);
    final z = to.clamp(a, charRects.length);
    final sx = rect.width / pageSize.width;
    final sy = rect.height / pageSize.height;
    final out = <ui.Rect>[];
    PdfRect? run;
    void flush() {
      final r = run;
      if (r == null) return;
      out.add(
        ui.Rect.fromLTRB(
          rect.left + r.left * sx,
          rect.top + (pageSize.height - r.top) * sy,
          rect.left + r.right * sx,
          rect.top + (pageSize.height - r.bottom) * sy,
        ),
      );
      run = null;
    }

    for (var i = a; i < z; i++) {
      final c = charRects[i];
      if (c.right <= c.left) continue; // espaço sem largura, quebra de linha
      final r = run;
      if (r != null &&
          (r.top - c.top).abs() < 0.5 &&
          (r.bottom - c.bottom).abs() < 0.5) {
        run = PdfRect(
          math.min(r.left, c.left),
          math.max(r.top, c.top),
          math.max(r.right, c.right),
          math.min(r.bottom, c.bottom),
        );
      } else {
        flush();
        run = c;
      }
    }
    flush();
    return out;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    image?.dispose();
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
  String get author => _book.authorDisplay;

  /// D-122: as páginas do PDF × os 1.500 caracteres da página de referência (a mesma régua do EPUB).
  @override
  int get totalChars => pageCount * refPageChars;

  @override
  ReaderMark markOfRefPage(int refPage) =>
      (spine: 0, offset: (refPage - 1).clamp(0, math.max(0, pageCount - 1)));

  @override
  BookmarkDraft bookmarkHere() => (
    locator: _keeper.locatorAt(_at, pageCount),
    refPage: _at + 1,
    chapterIndex: 0,
    excerpt: bookmarkExcerpt(_pages[_at]?.text ?? ''),
  );

  /// A página do PDF não muda de cor (D-43): só o fundo e as ilhas mudam com o Tema (D-122).
  @override
  Future<void> recolor(ui.Color ink) async {}

  FoundRange? _found;

  @override
  FoundRange? get found => _found;

  @override
  void showFound(FoundRange f) {
    _found = f;
    _changes.value++;
  }

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

  /// Página vizinha que não renderiza dá o erro (não é o fim do PDF).
  @override
  Future<DisplayPage?> peek(PageDirection d) async {
    final j = _neighbor(d);
    if (j == null || _disposed) return null;
    return _page(j);
  }

  /// Viradas e saltos em fila: cada um parte da página onde o anterior parou.
  Future<void> _queue = Future<void>.value();

  Future<T> _serial<T>(Future<T> Function() f) {
    final run = _queue.then((_) => f());
    _queue = run.then<void>((_) {}, onError: (Object _) {});
    return run;
  }

  @override
  Future<bool> turn(PageDirection d) => _serial(() async {
    final j = _neighbor(d);
    if (j == null || _disposed) return false;
    await _show(j);
    return true;
  });

  @override
  Future<void> goTo(ReaderMark m) => _serial(() async {
    if (pageCount == 0 || _disposed) return;
    await _show(m.offset.clamp(0, pageCount - 1));
  });

  @override
  bool get atEnd => pageCount > 0 && _at == pageCount - 1;

  /// O texto de cada página pelo PDFium, uma página por vez (D-122); grupo "Pág. N".
  @override
  Stream<SearchGroup> search(String query) async* {
    var left = searchLimit + 1;
    for (var i = 0; i < pageCount && left > 0; i++) {
      if (_disposed) return;
      final text = (await _doc.pages[i].loadStructuredText()).fullText;
      for (final u in searchTexts([i], (_) => text, query, limit: left)) {
        left -= u.hits.length;
        yield (
          title: 'Pág. ${i + 1}',
          hits: [
            for (final h in u.hits)
              (
                at: (spine: 0, offset: i),
                found: (unit: i, from: h.start, to: h.end),
                refPage: i + 1,
                excerpt: h.excerpt,
                matchStart: h.matchStart,
                matchEnd: h.matchEnd,
              ),
          ],
        );
      }
      await Future<void>.delayed(Duration.zero);
    }
  }

  /// No PDF a página de referência é a do arquivo (D-122).
  @override
  Future<void> goToRefPage(int refPage) => goTo(markOfRefPage(refPage));

  int? _pinned;

  @override
  Future<void> pin(ReaderMark? mark) async {
    _pinned = mark?.offset;
    if (mark == null) {
      _announce();
      return;
    }
    _keeper.pageShown(mark.offset.clamp(0, pageCount - 1), pageCount);
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

  /// A página que está sendo aberta (a que chega tarde e não é ela, longe da atual, não fica na memória).
  int? _target;

  Future<void> _show(int page) async {
    _target = page;
    try {
      await _page(page);
    } finally {
      _target = null;
    }
    if (_disposed) return;
    _at = page;
    _found =
        null; // a marca da busca vale até a próxima virada ou salto (D-120)
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
      if (_neighbor(d) == null) continue;
      // a vizinha que não renderiza dá o erro quando a pessoa virar
      unawaited(peek(d).then((_) {}, onError: (Object _) {}));
    }
  }

  /// A página mostrada vai para a posição — a não ser que haja um alfinete (D-115).
  void _announce() {
    if (_pinned != null) return;
    _keeper.pageShown(_at, pageCount);
  }

  Future<PdfDisplayPage> _page(int index) {
    final have = _pages[index];
    if (have != null && have.alive) return Future.value(have);
    return _rendering[index] ??= _render(index)
        .then((p) {
          // fechou, ou é uma vizinha que chegou depois de a pessoa ir para longe dela
          if (_disposed || (index != _target && (index - _at).abs() > 1)) {
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
    var chars = const <PdfRect>[];
    try {
      final t = await page.loadStructuredText();
      text = t.fullText;
      chars = t.charRects;
    } on Object {
      // sem texto (página escaneada): o leitor de tela fica só com o rótulo
    }
    return PdfDisplayPage(
      index,
      image,
      rect,
      text,
      pageSize: ui.Size(page.width, page.height),
      charRects: chars,
    );
  }
}
