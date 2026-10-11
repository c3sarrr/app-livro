// G15.2 — os dados da folha do sumário vêm do banco e mudam sozinhos (como o `ReaderChrome`): o índice e o clube lidos
// uma vez; as anotações e os marcadores relidos a cada escrita; a marca tirada nesta abertura fica com a fita vazia
// (D-152); falhas relatadas sem derrubar a folha.
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/features/reader/application/reader_club_source.dart';
import 'package:app_leitura/features/reader/application/reader_toc.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/ref_pages.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/personal_builders.dart';

Future<void> _ate(bool Function() ok) async {
  for (var i = 0; i < 200 && !ok(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(ok(), isTrue);
}

final class _Clube implements ReaderClubSource {
  _Clube(this.resposta);

  final Future<ReaderClubGoal?> Function() resposta;
  final pedidos = <(String, String)>[];

  @override
  Future<ReaderClubGoal?> goalFor(String owner, String userBookId) {
    pedidos.add((owner, userBookId));
    return resposta();
  }
}

BookIndex _indice() => BookIndex(
  contentSha256: 'a' * 64,
  layout: 'reflowable',
  spine: const [
    SpineInfo(path: 'a', linear: true, chars: 3000),
    SpineInfo(path: 'b', linear: true, chars: 3000),
  ],
  toc: const [
    TocPoint(title: 'I. Um', spine: 0, offset: 0, depth: 0, leaf: true),
    TocPoint(title: 'II. Dois', spine: 1, offset: 0, depth: 0, leaf: true),
  ],
  refPages: RefPageMap.synthetic(const [0, 1500, 3000, 4500]),
);

void main() {
  late AppDatabase db;
  final livro = idTeste(7);
  setUp(() => db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false));
  tearDown(() => db.close());

  ReaderToc toc({
    ReaderClubSource club = const NoReaderClub(),
    List<Object>? erros,
  }) {
    final t = ReaderToc(
      db: db,
      userBookId: livro,
      bookTitle: 'Dom Casmurro',
      place: () => (mark: (spine: 1, offset: 300), end: null, refPage: 3),
      owner: () async => usuarioTeste,
      club: club,
      now: () => DateTime.utc(2026, 9, 20, 23),
      utcOffsetAt: (_) => const Duration(hours: -3),
      onError: erros == null ? null : (e, _) => erros.add(e),
    );
    addTearDown(t.dispose);
    return t;
  }

  test(
    'lê o índice, as anotações e os marcadores; relê a cada escrita',
    () async {
      await BookContentIndexDao(db)
          .upsert(livro, _indice(), builtAt: DateTime.utc(2026, 9, 20));
      await BookmarksDao(db).upsert(marcadorTeste(1, livro: livro, pagina: 1));
      await AnnotationsDao(db).upsert(grifoTeste(10, livro: livro));
      final t = toc();
      expect(t.view, isNull, reason: 'antes da 1ª leitura');
      await _ate(() => t.view != null);
      final v = t.view!;
      expect(v.subtitle, 'Dom Casmurro · 2 capítulos');
      expect(v.rows.map((r) => (r.numeral, r.current)), [
        ('I', false),
        ('II', true),
      ]);
      expect(v.rows[0].read, isTrue);
      expect(v.refPage, 3);
      expect(v.cards.single.page, 1);
      expect(v.bookmarks, 1);
      var avisos = 0;
      t.addListener(() => avisos++);
      await BookmarksDao(db).upsert(marcadorTeste(2, livro: livro, pagina: 3));
      await _ate(() => t.view!.cards.length == 2);
      expect(avisos, greaterThan(0));
      expect(t.view!.cards.last.here, isTrue);
    },
  );

  test('a marca tirada nesta abertura fica com a fita vazia; devolvida, volta a marcada', () async {
    await BookContentIndexDao(db)
        .upsert(livro, _indice(), builtAt: DateTime.utc(2026, 9, 20));
    final m = marcadorTeste(1, livro: livro, pagina: 1);
    await BookmarksDao(db).upsert(m);
    final t = toc();
    await _ate(() => t.view != null);
    t.want(m, on: false);
    final at = DateTime.utc(2026, 9, 21);
    await BookmarksDao(db).upsert(
      m.copyWith(
        meta: m.meta.deleted(
          at,
          Hlc(at.millisecondsSinceEpoch, 0, 'aparelhoA'),
        ),
      ),
    );
    t.settle(m.id, ok: true);
    await _ate(() => t.view!.bookmarks == 0);
    expect(t.view!.cards.single.marked, isFalse);
    final depois = DateTime.utc(2026, 9, 22);
    await BookmarksDao(db).upsert(
      m.copyWith(
        meta: m.meta.restored(
          depois,
          Hlc(depois.millisecondsSinceEpoch, 0, 'aparelhoA'),
        ),
      ),
    );
    await _ate(() => t.view!.bookmarks == 1);
    expect(t.view!.cards.single.marked, isTrue);
    expect(t.view!.cards, hasLength(1));
  });

  test('a fita pedida vale na hora (dois toques seguidos); a falha volta ao banco; depois de gravar, a releitura mostra o banco', () async {
    await BookContentIndexDao(db)
        .upsert(livro, _indice(), builtAt: DateTime.utc(2026, 9, 20));
    final m = marcadorTeste(1, livro: livro, pagina: 1);
    await BookmarksDao(db).upsert(m);
    final t = toc();
    await _ate(() => t.view != null);
    var avisos = 0;
    t.addListener(() => avisos++);
    // 1º toque: tira na hora, sem esperar o banco
    t.want(m, on: false);
    expect(avisos, 1);
    expect(t.view!.cards.single.marked, isFalse);
    expect(t.view!.bookmarks, 0);
    // 2º toque antes do banco responder: devolve na hora
    t.want(m, on: true);
    expect(t.view!.cards.single.marked, isTrue);
    expect(t.view!.bookmarks, 1);
    // a 1ª gravação termina com a 2ª em curso: nada muda; a 2ª falha: volta ao banco (viva)
    t.settle(m.id, ok: true);
    expect(t.view!.cards.single.marked, isTrue);
    t.settle(m.id, ok: false);
    expect(t.view!.cards.single.marked, isTrue);
    // tirar e a gravação falhar: volta na hora ao que o banco diz (viva), e o cartão fica
    t.want(m, on: false);
    expect(t.view!.cards.single.marked, isFalse);
    t.settle(m.id, ok: false);
    expect(t.view!.cards.single.marked, isTrue);
    expect(t.view!.cards, hasLength(1));
    // tirar e gravar; outro aparelho devolve antes da releitura: a releitura depois da gravação mostra o banco
    t.want(m, on: false);
    final at = DateTime.utc(2026, 9, 21);
    await BookmarksDao(db).upsert(
      m.copyWith(
        meta: m.meta.deleted(
          at,
          Hlc(at.millisecondsSinceEpoch, 0, 'aparelhoA'),
        ),
      ),
    );
    final depois = DateTime.utc(2026, 9, 22);
    await BookmarksDao(db).upsert(
      m.copyWith(
        meta: m.meta.restored(
          depois,
          Hlc(depois.millisecondsSinceEpoch, 0, 'aparelhoB'),
        ),
      ),
    );
    // as releituras dessas escritas terminam antes da gravação acabar: a fita continua a pedida
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(t.view!.cards.single.marked, isFalse, reason: 'ainda a pedida');
    // a gravação termina: a releitura que começa agora mostra o banco
    t.settle(m.id, ok: true);
    await _ate(() => t.view!.bookmarks == 1);
    expect(t.view!.cards.single.marked, isTrue);
  });

  test('o índice que não se lê: relatado, e a folha não diz que o livro não tem sumário', () async {
    await BookContentIndexDao(db)
        .upsert(livro, _indice(), builtAt: DateTime.utc(2026, 9, 20));
    await db.customStatement(
      "UPDATE book_content_index SET toc_json = 'x' WHERE user_book_id = ?",
      [livro],
    );
    await BookmarksDao(db).upsert(marcadorTeste(1, livro: livro, pagina: 1));
    final erros = <Object>[];
    final t = toc(erros: erros);
    await _ate(() => t.view != null);
    expect(erros, isNotEmpty);
    expect(t.view!.tocFailed, isTrue);
    expect(t.view!.rows, isEmpty);
    expect(t.view!.cards, hasLength(1), reason: 'as Marcadas continuam');
  });

  test('o clube da conta e do livro vai para a faixa; a fonte que falha some com a faixa e relata', () async {
    await BookContentIndexDao(db)
        .upsert(livro, _indice(), builtAt: DateTime.utc(2026, 9, 20));
    final clube = _Clube(
      () async => (
        name: 'Leitoras de Capitu',
        nextMeeting: null,
        goalChapter: 2,
        goalLabel: null,
      ),
    );
    final t = toc(club: clube);
    await _ate(() => t.view?.club != null);
    expect(t.view!.club!.goal, 'Até o cap. II');
    expect(clube.pedidos, [(usuarioTeste, livro)]);
    final erros = <Object>[];
    final u = toc(
      club: _Clube(() async => throw StateError('sem rede')),
      erros: erros,
    );
    await _ate(() => u.view != null);
    expect(u.view!.club, isNull);
    expect(erros.single, isA<StateError>());
  });

  test(
    'sem índice gravado: a folha sem sumário; depois de dispose não lê mais',
    () async {
      await BookmarksDao(db).upsert(marcadorTeste(1, livro: livro, pagina: 1));
      final erros = <Object>[];
      final t = toc(erros: erros);
      await _ate(() => t.view != null);
      expect(t.view!.rows, isEmpty);
      expect(t.view!.chapters, isNull);
      expect(t.view!.cards, hasLength(1));
      var avisos = 0;
      t.addListener(() => avisos++);
      t.dispose();
      await BookmarksDao(db).upsert(marcadorTeste(2, livro: livro, pagina: 2));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(avisos, 0);
      expect(erros, isEmpty);
    },
  );
}
