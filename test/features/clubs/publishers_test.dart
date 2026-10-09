// G21.6 — o que o aparelho publica sozinho (D-216): R9 a posição do livro de um clube ao sair do leitor (só se mudou;
// a fração e o cap. 32 do clube pela numeração do Dom Casmurro real) e o ticket refeito; R10 os 4 números uma vez por
// dia. Livro de fora de clube: nada vai.
import 'dart:convert';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/features/clubs/application/publishers.dart';
import 'package:app_leitura/features/clubs/data/clubs_cache.dart';
import 'package:app_leitura/features/clubs/data/clubs_repository.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/application/toc_view.dart'
    show chapterNumerals;
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/social/data/profile_repository.dart';
import 'package:app_leitura/features/social/domain/social_failure.dart';
import 'package:app_leitura/features/social/domain/social_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/personal_builders.dart';
import '../../support/reader_harness.dart' show domCasmurroEpub;
import 'club_models_test.dart' show fixture;

const _dona = usuarioTeste;
const _clube = '00000000-0000-7000-8000-00000c200001';
const _domEdicao = '00000000-0000-7000-8000-00000c0a0003';

final class _Clubes implements ClubsRepository {
  final publicados = <(String, double, int?)>[];
  SocialFailure? falha;

  /// O servidor grava (true) ou ignora a 2ª no mesmo minuto (false).
  bool gravou = true;

  @override
  Future<bool> publishProgress(
    String clubId, {
    required double ratio,
    required int? chapter,
  }) async {
    if (falha case final f?) throw f;
    publicados.add((clubId, ratio, chapter));
    return gravou;
  }

  @override
  Object? noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

final class _Perfil implements ProfileRepository {
  final publicados = <ProfileNumbers>[];
  SocialFailure? falha;
  bool gravou = true;

  @override
  Future<bool> publishStats(ProfileNumbers numbers) async {
    if (falha case final f?) throw f;
    publicados.add(numbers);
    return gravou;
  }

  @override
  Object? noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  late AppDatabase db;
  late ClubsCache cache;
  late _Clubes clubes;
  late ProgressPublisher progresso;

  /// A conta da sessão agora (trocar de conta no meio: nada da antiga segue — D-68).
  var daVez = _dona;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    cache = ClubsCache(() async => db);
    clubes = _Clubes();
    daVez = _dona;
    progresso = ProgressPublisher(
      clubs: clubes,
      cache: cache,
      database: () async => db,
      isCurrent: (o) => o == daVez,
    );
    await cache.saveClubs(_dona, jsonEncode(fixture('my_clubs')));
  });
  tearDown(() => db.close());

  group('R9: a posição ao sair do leitor', () {
    late int xxxii;

    Future<void> livro({
      String? edicao = _domEdicao,
      double fracao = 0.62113,
      int? capitulo,
    }) async {
      await UserBooksDao(db)
          .upsert(livroTeste(1).copyWith(editionId: Nullable(edicao)));
      final index = indexEpubFile(domCasmurroEpub, 'a' * 64);
      xxxii = chapterNumerals(index).indexOf('XXXII');
      await BookContentIndexDao(db)
          .upsert(idTeste(1), index, builtAt: DateTime.utc(2026, 9, 20));
      await ReadingPositionsDao(db).upsert(
        posicaoTeste(idTeste(1))
            .copyWith(chapterIndex: capitulo ?? xxxii, progression: fracao),
      );
    }

    test('livro do clube: a fração (4 casas) e o cap. 32 do clube; a mesma posição não vai de novo', () async {
      await livro();
      expect(await progresso.publish(_dona, idTeste(1)), 1);
      expect(clubes.publicados, [(_clube, 0.6211, 32)]);
      expect(await cache.publishedProgress(_dona, _clube), (
        ratio: 0.6211,
        chapter: 32,
      ));

      expect(
        await progresso.publish(_dona, idTeste(1)),
        0,
        reason: 'nada mudou',
      );
      await ReadingPositionsDao(db).upsert(
        posicaoTeste(idTeste(1))
            .copyWith(chapterIndex: xxxii + 1, progression: 0.64),
      );
      expect(await progresso.publish(_dona, idTeste(1)), 1);
      expect(clubes.publicados.last, (_clube, 0.64, 33));
    });

    test('o servidor ignorou (2ª no mesmo minuto): não marca, e a próxima saída manda de novo', () async {
      await livro();
      clubes.gravou = false;
      expect(await progresso.publish(_dona, idTeste(1)), 0);
      expect(await cache.publishedProgress(_dona, _clube), isNull);
      clubes.gravou = true;
      expect(await progresso.publish(_dona, idTeste(1)), 1);
      expect(clubes.publicados, hasLength(2));
    });

    test(
      'a conta mudou antes de publicar: nada vai pela sessão da outra (D-68)',
      () async {
        await livro();
        daVez = 'outra';
        expect(await progresso.publish(_dona, idTeste(1)), 0);
        expect(clubes.publicados, isEmpty);
      },
    );

    test(
      'livro de fora de clube: nada vai (a estante não sai do aparelho)',
      () async {
        await livro(edicao: idTeste(700));
        expect(await progresso.publish(_dona, idTeste(1)), 0);
        expect(clubes.publicados, isEmpty);
      },
    );

    test(
      'sem rede: nada é marcado como publicado (a próxima saída tenta de novo)',
      () async {
        await livro();
        clubes.falha = const SocialOffline();
        expect(await progresso.publish(_dona, idTeste(1)), 0);
        expect(await cache.publishedProgress(_dona, _clube), isNull);
        clubes.falha = null;
        expect(await progresso.publish(_dona, idTeste(1)), 1);
      },
    );

    test('sair do leitor refaz o ticket (o herói pode ter mudado)', () async {
      await livro();
      await db.delete(db.socialCache).go();
      await db
          .into(db.socialCache)
          .insert(
            SocialCacheCompanion.insert(
              key: ClubsCache.clubsKey(_dona),
              payload: jsonEncode(fixture('my_clubs')),
              updatedAt: DateTime.utc(2026, 10, 9),
            ),
          );
      await progresso.publish(_dona, idTeste(1));
      final ticket =
          await (db.select(db.socialCache)
                ..where((t) => t.key.equals(ClubsCache.ticketKey(_dona))))
              .getSingleOrNull();
      expect(ticket, isNotNull);
    });
  });

  group('R10: os números do perfil', () {
    late _Perfil perfil;
    var agora = DateTime.utc(2026, 10, 9, 12);

    StatsPublisher numeros() => StatsPublisher(
      profiles: perfil,
      cache: cache,
      database: () async => db,
      streak: () async => 6,
      now: () => agora,
      utcOffsetAt: (_) => const Duration(hours: -3),
      isCurrent: (o) => o == daVez,
    );

    setUp(() async {
      perfil = _Perfil();
      agora = DateTime.utc(2026, 10, 9, 12);
      final dao = UserBooksDao(db);
      // 2 lidos em 2026 (um na virada, ainda 2025 em São Paulo), 1 em 2025, 1 lendo, 1 quero ler, 1 apagado
      await dao.upsert(
        livroTeste(1).copyWith(
          status: ShelfStatus.finished,
          finishedAt: Nullable(DateTime.utc(2026, 3, 1)),
        ),
      );
      await dao.upsert(
        livroTeste(2).copyWith(
          status: ShelfStatus.finished,
          finishedAt: Nullable(DateTime.utc(2026, 1, 1, 2)),
        ),
      );
      await dao.upsert(
        livroTeste(3).copyWith(
          status: ShelfStatus.finished,
          finishedAt: Nullable(DateTime.utc(2026, 8, 20)),
        ),
      );
      await dao.upsert(
        livroTeste(4).copyWith(
          status: ShelfStatus.finished,
          finishedAt: Nullable(DateTime.utc(2025, 6, 1)),
        ),
      );
      await dao.upsert(livroTeste(5));
      await dao.upsert(livroTeste(6).copyWith(status: ShelfStatus.wantToRead));
      await dao.upsert(
        livroTeste(7, apagado: true).copyWith(
          status: ShelfStatus.finished,
          finishedAt: Nullable(DateTime.utc(2026, 5, 1)),
        ),
      );
      await dao.upsert(
        livroTeste(8, dono: '0199a7c4-2f00-7a10-8b20-0000000000ff').copyWith(
          status: ShelfStatus.finished,
          finishedAt: Nullable(DateTime.utc(2026, 5, 1)),
        ),
      );
    });

    test('contados no aparelho: lidos no total e no ano (no fuso), lendo agora e a sequência da Início', () async {
      expect(
        await numeros().numbersOf(_dona),
        const ProfileNumbers(
          booksReadTotal: 4,
          booksReadYear: 2,
          readingNow: 1,
          streakDays: 6,
        ),
      );
    });

    test('uma vez por dia: publica, e só de novo depois de 24 h', () async {
      expect(await numeros().publishIfDue(_dona), isTrue);
      expect(perfil.publicados, hasLength(1));
      agora = agora.add(const Duration(hours: 23));
      expect(await numeros().publishIfDue(_dona), isFalse);
      agora = agora.add(const Duration(hours: 1));
      expect(await numeros().publishIfDue(_dona), isTrue);
      expect(perfil.publicados, hasLength(2));
    });

    test('o servidor ignorou (conta nova, menos de 1 min): não marca; a conta mudou: nada vai', () async {
      perfil.gravou = false;
      expect(await numeros().publishIfDue(_dona), isFalse);
      expect(await cache.statsPublishedAt(_dona), isNull);
      perfil.gravou = true;
      daVez = 'outra';
      expect(await numeros().publishIfDue(_dona), isFalse);
      expect(perfil.publicados, hasLength(1), reason: 'só a ignorada');
    });

    test('sem rede: não marca, e tenta na próxima abertura', () async {
      perfil.falha = const SocialOffline();
      expect(await numeros().publishIfDue(_dona), isFalse);
      expect(await cache.statsPublishedAt(_dona), isNull);
    });
  });
}
