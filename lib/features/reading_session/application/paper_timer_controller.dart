// T04 — o controlador da sessão do cronômetro do livro de papel (spec docs/progresso/T04.md §2). Carrega a sessão
// aberta do dono ativo ao abrir o app (acertada pelo relógio de parede; a de um livro que saiu da estante é descartada
// — R8) e recarrega quando o dono muda: a do dono que sai pausa (D-264) e as que perderam na adoção são gravadas
// (D-265). Começa (uma por vez — D-262), pausa, retoma (outro dia divide a sessão — R4), encerra (o writer grava — R7)
// e descarta; com o app aberto, o tique da mini-barra acerta o relógio que volta e as 24 h (R2). As mudanças entram em
// fila: cada uma vê a anterior, mesmo com toques seguidos.
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

  /// O dono do último carregamento (a instância do notifier vive entre as reconstruções): quando ele muda, a sessão
  /// dele pausa (D-264).
  String? _owner;

  /// O último instante em que a sessão que roda foi vista (o tique da mini-barra), só em memória: a marca do R2 até ir
  /// para o `kv` quando o app sai da frente. Vale só para a mesma sessão e o mesmo "desde".
  ({String id, DateTime since, DateTime at})? _seen;

  @override
  Future<PaperTimerState> build() async {
    // assiste o valor (não só o 1º): a conta que entra recarrega a sessão do dono novo
    ref.watch(paperTimerOwnerProvider);
    final owner = await ref.watch(paperTimerOwnerProvider.future);
    // uma vez por dono: a 1ª abertura reconstrói (o dono passa de carregando a valor) e os efeitos não se repetem
    final left = _owner;
    _owner = owner;
    final store = await ref.watch(paperTimerStoreProvider.future);
    final books = await ref.watch(paperBookSourceProvider.future);
    if (left != owner) {
      if (left != null) await _pauseLeaving(store, left);
      await _recordClosed(store, owner);
    }
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

  /// O toque no botão da sessão (o cartão do "Também lendo" e a mini-barra): [toggle] sem esperar; a falha (o kv fora
  /// do ar) vai para o relatório do cronômetro e o botão fica como estava.
  void toggleFromTap() => unawaited(toggle().catchError(reportPaperTimerError));

  /// D-263: abrir o leitor pausa a sessão que roda (o e-book conta sozinho; sem tempo em dobro). Entra na fila: a que
  /// ainda carrega ou a que um toque acabou de retomar também pausa.
  Future<void> pauseForReader() => pause();

  /// O tique da mini-barra (R2 com o app aberto): pausa nas 24 h e acerta o relógio que voltou para antes do último
  /// instante visto — o estado muda na hora (o tempo na tela não volta) e o `kv` grava na fila. Sem nada a acertar, só
  /// anota o instante (nem o estado nem o `kv` mudam).
  void tick() {
    final current = state.value;
    final s = current?.session;
    if (current == null || s == null || !s.isRunning) return;
    final now = _now();
    final marked = _marked(s);
    final settled = marked.settle(now);
    if (identical(settled, marked)) {
      final seen = _seen;
      if (seen == null || seen.id != s.id || now.isAfter(seen.at)) {
        _seen = (id: s.id, since: s.runningSince!, at: now);
      }
      return;
    }
    _seen = null;
    state = AsyncData(PaperTimerState(session: settled, book: current.book));
    unawaited(
      _serial(() async {
        if ((await future).session == settled) {
          await _save(await ref.read(paperTimerOwnerProvider.future), settled);
        }
      }).catchError(reportPaperTimerError),
    );
  }

  /// O app saiu da frente (R2): a marca do relógio vai ao `kv` com a sessão que roda — o relógio que voltar com o app
  /// fechado não desconta.
  void appHidden() => unawaited(
    _serial(() async {
      final current = await future;
      final s = current.session;
      if (s == null || !s.isRunning) return;
      final seen = _marked(s).observe(_now());
      if (seen != s) await _update(current, seen);
    }).catchError(reportPaperTimerError),
  );

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
          record: _marked(s).record(now),
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
    await _update(current, _marked(s).pause(_now()));
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

  /// [s] com a marca do tique (R2), se ela é desta sessão e deste "desde".
  OpenPaperSession _marked(OpenPaperSession s) {
    final seen = _seen;
    if (seen == null || seen.id != s.id || seen.since != s.runningSince) {
      return s;
    }
    return s.observe(seen.at);
  }

  /// D-264: a sessão do dono que saiu (sair da conta) pausa no instante da troca — o tempo fora não conta. Na adoção
  /// a chave do convidado já passou para a conta e não há o que pausar.
  Future<void> _pauseLeaving(PaperTimerStore store, String owner) async {
    try {
      final s = await store.load(owner);
      if (s == null || !s.isRunning) return;
      await store.save(owner, _marked(s).pause(_now()));
    } on Object catch (e, st) {
      reportPaperTimerError(e, st);
    }
  }

  /// D-265: as sessões que perderam na adoção (pausadas no instante da troca) são gravadas sem página, como a divisão
  /// do R4 (menos de 10 s não grava — R3; o livro que saiu da estante leva a sua). Outra falha fica no relatório e elas
  /// esperam a próxima abertura (gravar de novo é idempotente: o id é o mesmo).
  Future<void> _recordClosed(PaperTimerStore store, String owner) async {
    try {
      final closed = await store.closed(owner);
      if (closed.isEmpty) return;
      final writer = await ref.read(paperSessionWriterProvider.future);
      for (final s in closed) {
        final record = s.record(_now());
        if (record == null) continue;
        try {
          await writer.recordOnly(record);
        } on PaperBookGone {
          // o livro saiu da estante: não há onde gravar
        }
      }
      await store.clearClosed(owner);
    } on Object catch (e, st) {
      reportPaperTimerError(e, st);
    }
  }

  /// Uma mudança por vez, na ordem dos toques; a falha de uma não trava as seguintes.
  Future<T> _serial<T>(Future<T> Function() change) {
    final result = _queue.then((_) => change());
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }
}
