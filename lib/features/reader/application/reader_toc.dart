// G15.2 — os dados da folha do sumário (telas 27/27b), vindos do banco e atualizados sozinhos, como o `ReaderChrome`:
// o índice (sumário com os numerais e as páginas) e o clube (D-149) são lidos uma vez, ao abrir a folha; as anotações
// e os marcadores, a cada escrita nas tabelas (a fita da 27b, um marcador sincronizado de outro aparelho). Guarda as
// marcas tiradas nesta abertura, para o cartão ficar com a fita vazia (D-152), e a fita pedida, que vale na hora (dois
// toques seguidos não se perdem) até as gravações dela terminarem e uma releitura posterior mostrar o banco (uma marca
// devolvida por outro aparelho nesse meio-tempo aparece); se a gravação falha, volta ao banco na hora. Falha ao ler:
// relatada, e a folha mostra o que já tinha (o clube que falha some com a faixa; o índice que falha não vira "sem
// sumário").
import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/annotation_daos.dart';
import '../../../core/data/database/daos/content_daos.dart';
import '../../../core/data/database/daos/reader_daos.dart';
import '../annotations/domain/annotation.dart';
import '../content/book_index.dart';
import '../domain/bookmark.dart';
import 'reader_club_source.dart';
import 'reader_document.dart' show ReaderMark;
import 'toc_view.dart';

/// Onde a pessoa está: a marca da página (o caractere ou a página do PDF) e a página de referência.
typedef TocPlace = ({ReaderMark mark, int refPage});

class ReaderToc extends ChangeNotifier {
  ReaderToc({
    required AppDatabase db,
    required this.userBookId,
    required this.bookTitle,
    required this.place,
    required this.owner,
    this.club = const NoReaderClub(),
    required this.now,
    this.utcOffsetAt = readerUtcOffset,
    this.onError,
  }) : _db = db {
    _updates = db
        .tableUpdates(
          TableUpdateQuery.onAllTables([db.bookmarks, db.annotations]),
        )
        .listen((_) => unawaited(_reload()), onError: _fail);
    unawaited(_open());
  }

  final AppDatabase _db;
  final String userBookId;
  final String bookTitle;
  final TocPlace Function() place;
  final Future<String> Function() owner;
  final ReaderClubSource club;
  final DateTime Function() now;
  final Duration Function(DateTime utc) utcOffsetAt;
  final void Function(Object error, StackTrace stack)? onError;
  late final StreamSubscription<Object?> _updates;

  BookIndex? _index;
  bool _indexFailed = false;
  ReaderClubGoal? _goal;
  List<Annotation> _notes = const [];
  List<Bookmark> _marks = const [];
  final Map<String, Bookmark> _removed = {};

  /// A fita pedida (marcada ou não), que vale até o banco mostrar o resultado das gravações dela.
  final Map<String, bool> _wanted = {};

  /// Gravações da fita ainda em curso, por marca.
  final Map<String, int> _pending = {};

  /// A releitura ([_gen]) em curso quando a última gravação de cada marca terminou: a próxima mostra o banco.
  final Map<String, int> _settledAt = {};
  bool _opened = false;
  bool _disposed = false;
  int _gen = 0;
  TocView? _view;

  /// O que a folha mostra; `null` antes da 1ª leitura (só a moldura e as abas).
  TocView? get view => _view;

  /// A fita do cartão de [b] foi tocada e uma gravação começou: vale na hora ([on] = marcada), até a gravação
  /// terminar ([settle]). Tirada, o cartão fica com a fita vazia até a folha fechar (D-152).
  void want(Bookmark b, {required bool on}) {
    if (_disposed) return;
    if (!on) _removed[b.id] = b;
    _wanted[b.id] = on;
    _pending[b.id] = (_pending[b.id] ?? 0) + 1;
    _settledAt.remove(b.id);
    if (_opened) _build();
  }

  /// Uma gravação da fita de [id] terminou. Sem outra em curso: gravou ([ok]) — a próxima releitura mostra o banco
  /// (e começa já); falhou — volta ao que o banco diz.
  void settle(String id, {required bool ok}) {
    if (_disposed) return;
    final left = (_pending[id] ?? 1) - 1;
    if (left > 0) {
      _pending[id] = left;
      return;
    }
    _pending.remove(id);
    if (ok) {
      _settledAt[id] = _gen;
      unawaited(_reload());
      return;
    }
    if (_wanted.remove(id) != null && _opened) _build();
  }

  Future<void> _open() async {
    try {
      _index = await BookContentIndexDao(_db).byBook(userBookId);
    } on Object catch (e, st) {
      _indexFailed = true;
      _fail(e, st);
    }
    try {
      _goal = await club.goalFor(await owner(), userBookId);
    } on Object catch (e, st) {
      _fail(e, st);
    }
    if (_disposed) return;
    _opened = true;
    await _reload();
  }

  Future<void> _reload() async {
    if (!_opened || _disposed) return;
    final gen = ++_gen;
    try {
      final marks = await BookmarksDao(_db).forBook(userBookId);
      final notes = await AnnotationsDao(_db).forBook(userBookId);
      if (_disposed || gen != _gen) return;
      _marks = marks;
      _notes = notes;
      // começou depois que as gravações da fita terminaram: o banco já tem o resultado, e o pedido sai
      _settledAt.removeWhere((id, at) {
        if (gen <= at) return false;
        _wanted.remove(id);
        return true;
      });
    } on Object catch (e, st) {
      _fail(e, st);
      if (_disposed || _view != null) return;
    }
    _build();
  }

  void _build() {
    final p = place();
    _view = buildTocView(
      bookTitle: bookTitle,
      index: _index,
      indexFailed: _indexFailed,
      at: p.mark,
      refPage: p.refPage,
      annotations: _notes,
      bookmarks: _marks,
      removed: [..._removed.values],
      wanted: {..._wanted},
      club: _goal,
      now: now(),
      utcOffsetAt: utcOffsetAt,
    );
    if (!_disposed) notifyListeners();
  }

  void _fail(Object e, StackTrace st) => onError?.call(e, st);

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(_updates.cancel());
    super.dispose();
  }
}
