// T04 — o controlador da sessão do cronômetro do livro de papel (spec docs/progresso/T04.md §2). Carrega a sessão
// aberta do dono ativo ao abrir o app (acertada pelo relógio de parede; a de um livro que saiu da estante é descartada
// — R8) e recarrega quando o dono muda (a conta entra); começa (uma por vez — D-262), pausa, retoma (outro dia divide
// a sessão — R4), encerra (o writer grava — R7) e descarta. As mudanças entram em fila: cada uma vê a anterior, mesmo
// com toques seguidos.
import 'dart:async';

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/database/daos/kv_dao.dart';
import '../../../core/data/database/local_database.dart';
import '../../../core/data/database/local_sql.dart' show deviceIdKey;
import '../../../core/data/ids/uuid_v7.dart';
import '../../../core/sync/sync_providers.dart' show localVersioningProvider;
import '../../account/application/account_providers.dart'
    show localLibraryProvider;
import '../../catalog/application/catalog_providers.dart'
    show catalogUpdaterProvider;
import '../../home/application/home_providers.dart' show clockProvider;
import '../../reader/application/reader_club_source.dart' show readerUtcOffset;
import '../data/paper_book_source.dart';
import '../data/paper_session_writer.dart';
import '../data/paper_timer_store.dart';
import '../domain/open_paper_session.dart';
import '../domain/paper_timer_failure.dart';

/// O que a tela lê: a sessão aberta (`null` = nenhuma) e o livro dela.
@immutable
final class PaperTimerState {
  const PaperTimerState({this.session, this.book});

  final OpenPaperSession? session;
  final PaperBook? book;

  @override
  bool operator ==(Object other) =>
      other is PaperTimerState &&
      other.session == session &&
      other.book == book;

  @override
  int get hashCode => Object.hash(session, book);

  @override
  String toString() => 'PaperTimerState($session)';
}

/// O dono ativo (o convidado ou a conta): a sessão aberta é dele.
final paperTimerOwnerProvider = StreamProvider<String>((ref) async* {
  final library = await ref.watch(localLibraryProvider.future);
  yield* library
      .watchActiveOwnerId()
      .asyncMap((owner) async => owner ?? await library.guestOwnerId())
      .distinct();
});

final paperTimerStoreProvider = FutureProvider<PaperTimerStore>(
  (ref) async =>
      KvPaperTimerStore(await ref.watch(localDatabaseProvider.future)),
);

final paperSessionWriterProvider = FutureProvider<PaperSessionWriter>((
  ref,
) async {
  final db = await ref.watch(localDatabaseProvider.future);
  final library = await ref.watch(localLibraryProvider.future);
  return LocalPaperSessionWriter(
    db: db,
    versioning: await ref.watch(localVersioningProvider.future),
    owner: library.activeOwnerId,
    deviceId: await KvDao(db).get(deviceIdKey),
  );
});

final paperBookSourceProvider = FutureProvider<PaperBookSource>(
  (ref) async => LocalPaperBookSource(
    await ref.watch(localDatabaseProvider.future),
    catalog: () async =>
        (await ref.read(catalogUpdaterProvider.future))?.catalog(),
  ),
);

/// Os ids das sessões novas (UUIDv7 gerados no aparelho).
final paperTimerIdsProvider = Provider<String Function()>(
  (ref) => UuidV7Generator().next,
);

/// O fuso do usuário em cada instante (o dia de uma sessão — D-85).
final paperTimerUtcOffsetProvider = Provider<Duration Function(DateTime utc)>(
  (ref) => readerUtcOffset,
);

final paperTimerProvider =
    AsyncNotifierProvider<PaperTimerController, PaperTimerState>(
      PaperTimerController.new,
    );

class PaperTimerController extends AsyncNotifier<PaperTimerState> {
  Future<void> _queue = Future<void>.value();

  @override
  Future<PaperTimerState> build() async {
    // assiste o valor (não só o 1º): a conta que entra recarrega a sessão do dono novo
    ref.watch(paperTimerOwnerProvider);
    final owner = await ref.watch(paperTimerOwnerProvider.future);
    final store = await ref.watch(paperTimerStoreProvider.future);
    final books = await ref.watch(paperBookSourceProvider.future);
    final saved = await store.load(owner);
    if (saved == null) return const PaperTimerState();
    final book = await books.book(owner, saved.userBookId);
    if (book == null) {
      await store.clear(owner);
      return const PaperTimerState();
    }
    final settled = saved.settle(_now());
    if (settled != saved) await store.save(owner, settled);
    return PaperTimerState(session: settled, book: book);
  }

  /// Começa a sessão de [userBookId]. Com outra aberta → [PaperSessionAlreadyOpen] (a tela abre a folha dela —
  /// D-262); livro fora da estante → [PaperBookGone].
  Future<void> start(String userBookId) => _serial(() async {
    final current = await future;
    if (current.session != null) throw const PaperSessionAlreadyOpen();
    final owner = await ref.read(paperTimerOwnerProvider.future);
    final books = await ref.read(paperBookSourceProvider.future);
    final book = await books.book(owner, userBookId);
    if (book == null) throw const PaperBookGone();
    final session = OpenPaperSession.start(
      id: ref.read(paperTimerIdsProvider)(),
      userBookId: userBookId,
      now: _now(),
    );
    await _save(owner, session);
    state = AsyncData(PaperTimerState(session: session, book: book));
  });

  Future<void> pause() => _serial(_pause);

  Future<void> resume() => _serial(_resume);

  /// O botão da sessão: pausa a que roda, retoma a pausada.
  Future<void> toggle() => _serial(() async {
    final s = (await future).session;
    if (s == null) return;
    return s.isRunning ? _pause() : _resume();
  });

  /// D-263: abrir o leitor pausa a sessão que roda (o e-book conta sozinho; sem tempo em dobro).
  Future<void> pauseForReader() => pause();

  /// Encerra (D-256): o writer grava a sessão (ou nada, com menos de 10 s — R3), a página e o total. Página recusada →
  /// o erro volta e a sessão continua aberta; livro fora da estante → a sessão sai e a falha volta.
  Future<void> end({int? page, int? pagesTotal}) => _serial(() async {
    final s = (await future).session;
    if (s == null) return;
    final owner = await ref.read(paperTimerOwnerProvider.future);
    final writer = await ref.read(paperSessionWriterProvider.future);
    final now = _now();
    try {
      await writer.end(
        PaperSessionEnd(
          userBookId: s.userBookId,
          record: s.record(now),
          at: now,
          page: page,
          pagesTotal: pagesTotal,
        ),
      );
    } on PaperBookGone {
      await _clear(owner);
      rethrow;
    }
    await _clear(owner);
  });

  /// Descarta (D-256): nada é gravado.
  Future<void> discard() => _serial(() async {
    if ((await future).session == null) return;
    await _clear(await ref.read(paperTimerOwnerProvider.future));
  });

  // ------------------------------------------------------------------------------------------------------

  Future<void> _pause() async {
    final current = await future;
    final s = current.session;
    if (s == null || !s.isRunning) return;
    await _update(current, s.pause(_now()));
  }

  Future<void> _resume() async {
    final current = await future;
    final s = current.session;
    if (s == null || s.isRunning) return;
    final r = s.resumeOnAnotherDay(
      _now(),
      ref.read(paperTimerUtcOffsetProvider),
      ref.read(paperTimerIdsProvider)(),
    );
    final closed = r.closed;
    if (closed != null) {
      final writer = await ref.read(paperSessionWriterProvider.future);
      try {
        await writer.recordOnly(closed);
      } on PaperBookGone {
        await _clear(await ref.read(paperTimerOwnerProvider.future));
        return;
      }
    }
    await _update(current, r.next);
  }

  Future<void> _update(PaperTimerState current, OpenPaperSession next) async {
    await _save(await ref.read(paperTimerOwnerProvider.future), next);
    state = AsyncData(PaperTimerState(session: next, book: current.book));
  }

  Future<void> _save(String owner, OpenPaperSession s) async =>
      (await ref.read(paperTimerStoreProvider.future)).save(owner, s);

  Future<void> _clear(String owner) async {
    await (await ref.read(paperTimerStoreProvider.future)).clear(owner);
    state = const AsyncData(PaperTimerState());
  }

  DateTime _now() => ref.read(clockProvider)().toUtc();

  /// Uma mudança por vez, na ordem dos toques; a falha de uma não trava as seguintes.
  Future<T> _serial<T>(Future<T> Function() change) {
    final result = _queue.then((_) => change());
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }
}
