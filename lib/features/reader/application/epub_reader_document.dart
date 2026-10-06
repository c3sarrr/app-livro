// G11.2 — o livro EPUB aberto para a tela: o `BookPager` da G10 (páginas, vizinhas, virar), os números pela 1ª
// letra visível (`numbersAt`), a posição gravada pelo `ReadingPositionKeeper` a cada página mostrada, e os
// links internos do livro (`caminho#fragmento` → item do spine + caractere do `id` — D-108).
import 'dart:async';

import 'package:flutter/foundation.dart' show Listenable;

import '../../library/domain/user_book.dart';
import '../content/book_index.dart';
import '../content/chapter_content.dart';
import '../domain/reader_numbers.dart';
import '../layout/layout_scheduler.dart';
import '../layout/reader_typography.dart';
import 'book_pager.dart';
import 'reader_document.dart';
import 'reading_position_keeper.dart';

final class EpubDocumentDeps {
  const EpubDocumentDeps({
    required this.book,
    required this.index,
    required this.path,
    required this.typography,
    required this.scheduler,
    required this.keeper,
    this.cache,
    this.loader,
  });

  final UserBook book;
  final BookIndex index;

  /// Arquivo do livro no aparelho.
  final String path;
  final ReaderTypography typography;
  final LayoutScheduler scheduler;
  final ReadingPositionKeeper keeper;
  final PagerCacheKey? cache;

  /// Como ler os capítulos (padrão: num isolate). Os testes leem na hora.
  final ChapterLoader? loader;
}

final class EpubReaderDocument implements ReaderDocument {
  EpubReaderDocument._(this._deps, this._pager);

  /// Abre o livro onde a pessoa parou (a posição guardada, reencontrada no arquivo de agora — G10).
  static Future<EpubReaderDocument> open(EpubDocumentDeps d) async {
    final pager = BookPager(
      index: d.index,
      load: d.loader ?? isolateChapterLoader(d.path),
      typography: d.typography,
      scheduler: d.scheduler,
      cache: d.cache,
    );
    try {
      await reopen(pager, d.keeper);
    } on Object {
      pager.dispose();
      rethrow;
    }
    return EpubReaderDocument._(d, pager).._announce();
  }

  final EpubDocumentDeps _deps;
  final BookPager _pager;

  @override
  String get title => _deps.book.title;

  @override
  DisplayPage get current => _pager.current!;

  @override
  Listenable get changes => _pager.changes;

  @override
  ReaderNumbersView get numbers {
    final p = _pager.position!;
    final n = numbersAt(_deps.index, p.spine, p.firstVisible);
    return ReaderNumbersView(
      refPage: n.refPage,
      refTotal: n.refTotal,
      progression: n.progression,
    );
  }

  @override
  ReaderMark get mark {
    final p = _pager.position!;
    return (spine: p.spine, offset: p.firstVisible);
  }

  @override
  RefRange get shownRange {
    final p = _pager.position!;
    final last = p.page.end > p.page.start ? p.page.end - 1 : p.page.start;
    return (
      fromRef: numbersAt(_deps.index, p.spine, p.firstVisible).refPage,
      toRef: numbersAt(_deps.index, p.spine, last).refPage,
    );
  }

  @override
  Future<DisplayPage?> peek(PageDirection d) => _pager.peek(d);

  @override
  Future<bool> turn(PageDirection d) async {
    final ok = d == PageDirection.forward
        ? await _pager.next()
        : await _pager.previous();
    if (ok) _announce();
    return ok;
  }

  @override
  Future<void> goTo(ReaderMark m) async {
    await _pager.openAt(m.spine, m.offset);
    _announce();
  }

  @override
  Future<bool> follow(LinkHit link) async {
    final to = await resolveEpubLink(_deps.index, link.target, _pager.content);
    if (to == null) return false;
    await goTo(to);
    return true;
  }

  @override
  Future<void> flush() => _deps.keeper.flush();

  @override
  void dispose() {
    _deps.keeper.dispose();
    _pager.dispose();
  }

  /// Uma página apareceu: a posição grava depois de 1 s nela (G10).
  void _announce() {
    final p = _pager.position;
    if (p == null) return;
    final text = _pager.contentOf(p.spine)?.item.text ?? '';
    _deps.keeper.pageShown(p.spine, p.firstVisible, text);
  }
}

/// Destino de um link interno `caminho#fragmento` (G09): o item do spine com esse caminho e o caractere do `id`
/// (sem `id` conhecido, o começo do item). `null` = o caminho não está no livro.
Future<ReaderMark?> resolveEpubLink(
  BookIndex index,
  String target,
  Future<ChapterContent> Function(int spine) content,
) async {
  final hash = target.indexOf('#');
  final path = hash < 0 ? target : target.substring(0, hash);
  final frag = hash < 0 ? null : target.substring(hash + 1);
  final spine = index.spine.indexWhere((s) => s.path == path);
  if (spine < 0) return null;
  if (frag == null || frag.isEmpty) return (spine: spine, offset: 0);
  final c = await content(spine);
  return (spine: spine, offset: c.item.idOffsets[frag] ?? 0);
}
