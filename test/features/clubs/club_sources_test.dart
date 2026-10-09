// G21.5 — os 4 pontos ligados aos clubes: a faixa do sumário (R1 + a semana atual), o chip do cache e ao vivo (uma ida
// e os canais dos clubes; cancelar fecha) e o compartilhar (o trecho, a cor, a página, o capítulo do clube pela
// numeração do Dom Casmurro real e a fração — a nota não vai; o chip aparece na hora).
import 'dart:convert';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/features/clubs/application/club_sources.dart';
import 'package:app_leitura/features/clubs/application/clubs_sync.dart';
import 'package:app_leitura/features/clubs/data/clubs_cache.dart';
import 'package:app_leitura/features/clubs/data/clubs_repository.dart';
import 'package:app_leitura/features/clubs/domain/club_models.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/application/toc_view.dart'
    show chapterNumerals;
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/social/data/community_repository.dart';
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
  final compartilhados = <(String, SharedQuote)>[];
  final pedidos = <List<String>>[];
  List<PostSummary> resumos = const [];
  SocialFailure? falha;

  @override
  Future<String> shareHighlight(String clubId, SharedQuote quote) async {
    if (falha case final f?) throw f;
    compartilhados.add((clubId, quote));
    return idTeste(990);
  }

  @override
  Future<List<PostSummary>> postSummaries(Iterable<String> postIds) async {
    if (falha case final f?) throw f;
    pedidos.add(postIds.toList()..sort());
    return resumos;
  }

  @override
  Object? noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

final class _Termos implements TermsRepository {
  final aceitos = <String>[];
  @override
  Future<TermsStatus> mine() async =>
      const TermsStatus(version: 'v1', accepted: false);
  @override
  Future<void> accept(String version) async => aceitos.add(version);
}

final class _Sininho implements NotificationsRepository {
  @override
  Future<int> unreadCount() async => 0;
  @override
  Future<void> markAllRead() async {}
}

/// Canais de mentira (o tempo real).
final class _Canais {
  final abertos = <String, void Function()>{};
  final fechados = <String>[];
  Future<void> Function() abrir(String topic, void Function() onPing) {
    abertos[topic] = onPing;
    return () async {
      abertos.remove(topic);
      fechados.add(topic);
    };
  }
}

void main() {
  late AppDatabase db;
  late ClubsCache cache;
  late _Clubes clubes;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    cache = ClubsCache(() async => db);
    clubes = _Clubes();
    await cache.saveClubs(_dona, jsonEncode(fixture('my_clubs')));
  });
  tearDown(() => db.close());

  Future<void> livroDoClube({int n = 1, String? edicao = _domEdicao}) =>
      UserBooksDao(db)
          .upsert(livroTeste(n).copyWith(editionId: Nullable(edicao)));

  group('a faixa do sumário (27)', () {
    test('o livro do clube: o nome, o encontro e a meta da semana atual (até o cap. 50)', () async {
      await livroDoClube();
      final g = await ClubsReaderClubSource(cache).goalFor(_dona, idTeste(1));
      expect(
        (g!.name, g.goalChapter, g.goalLabel),
        ('Leitoras de Capitu', 50, null),
      );
      expect(g.nextMeeting, DateTime.utc(2026, 10, 13, 23));
    });

    test(
      'outro livro, outra conta ou livro fora da estante: a faixa some',
      () async {
        await livroDoClube(edicao: idTeste(700));
        final s = ClubsReaderClubSource(cache);
        expect(await s.goalFor(_dona, idTeste(1)), isNull);
        expect(await s.goalFor('outra', idTeste(1)), isNull);
        expect(await s.goalFor(_dona, idTeste(2)), isNull);
      },
    );
  });

  group('o chip da 25', () {
    const resumo = PostSummary(
      id: 'p1',
      clubId: _clube,
      clubName: 'Leitoras de Capitu',
      replies: 3,
    );

    test('do cache da conta; sem conta, nenhum', () async {
      await cache.addPost(_dona, resumo);
      expect(
        await ClubsHighlightsClubSource(
          owner: () async => _dona,
          cache: cache,
        ).clubOf('p1'),
        (clubId: _clube, name: 'Leitoras de Capitu', replies: 3),
      );
      expect(
        await ClubsHighlightsClubSource(
          owner: () async => _dona,
          cache: cache,
        ).clubOf('p9'),
        isNull,
      );
      expect(
        await ClubsHighlightsClubSource(
          owner: () async => null,
          cache: cache,
        ).clubOf('p1'),
        isNull,
      );
    });

    test('ao vivo: uma ida, os canais dos clubes dos posts; um aviso relê; cancelar fecha', () async {
      final canais = _Canais();
      clubes.resumos = const [resumo];
      final aoVivo = ClubsChipUpdates(
        owner: () async => _dona,
        sync: ClubsSync(clubs: clubes, notifications: _Sininho(), cache: cache),
        cache: cache,
        channels: canais.abrir,
        settle: Duration.zero,
      );
      var eventos = 0;
      final sub = aoVivo.follow({'p1'}).listen((_) => eventos++);
      Future<void> ate(bool Function() ok) async {
        for (var i = 0; i < 100 && !ok(); i++) {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }
      }

      await ate(() => canais.abertos.isNotEmpty);
      expect(clubes.pedidos, [
        ['p1'],
      ]);
      expect(eventos, 1);
      expect(canais.abertos.keys, ['club:$_clube']);

      clubes.resumos = const [
        PostSummary(
          id: 'p1',
          clubId: _clube,
          clubName: 'Leitoras de Capitu',
          replies: 4,
        ),
      ];
      canais.abertos['club:$_clube']!();
      await ate(() => eventos == 2);
      expect(eventos, 2);
      expect((await cache.posts(_dona))['p1']!.replies, 4);

      await sub.cancel();
      expect(canais.abertos, isEmpty);
      expect(canais.fechados, ['club:$_clube']);
    });

    test('ao vivo sem conta: nada vai e nada abre', () async {
      final canais = _Canais();
      final aoVivo = ClubsChipUpdates(
        owner: () async => null,
        sync: ClubsSync(clubs: clubes, notifications: _Sininho(), cache: cache),
        cache: cache,
        channels: canais.abrir,
      );
      final sub = aoVivo.follow({'p1'}).listen((_) {});
      await pumpEventQueue();
      await sub.cancel();
      expect(clubes.pedidos, isEmpty);
      expect(canais.abertos, isEmpty);
    });
  });

  group('compartilhar no clube (D-217, D-218)', () {
    late Annotation grifo;
    late BookIndex index;

    setUp(() async {
      index = indexEpubFile(domCasmurroEpub, 'a' * 64);
      final xxxii = chapterNumerals(index).indexOf('XXXII');
      await livroDoClube();
      await BookContentIndexDao(db)
          .upsert(idTeste(1), index, builtAt: DateTime.utc(2026, 9, 20));
      grifo = grifoTeste(
        10,
        livro: idTeste(1),
        exato: 'Olhos de ressaca.',
        pagina: 160,
      ).copyWith(chapterIndex: xxxii);
    });

    ClubsHighlightsShare compartilhar({String? dono = _dona}) =>
        ClubsHighlightsShare(
          owner: () async => dono,
          cache: cache,
          clubs: clubes,
          terms: _Termos(),
          database: () async => db,
        );

    test('os clubes que leem o livro (R1), com o nome e a cor', () async {
      expect(await compartilhar().clubsFor(idTeste(1)), [
        (id: _clube, name: 'Leitoras de Capitu', color: '#FFC1C6'),
      ]);
      expect(await compartilhar().clubsFor(idTeste(2)), isEmpty);
      await expectLater(
        compartilhar(dono: null).clubsFor(idTeste(1)),
        throwsA(isA<SocialNeedsAccount>()),
      );
    });

    test('vai o trecho, a cor, a página, o cap. 32 do clube e a fração 160/256 — a nota não', () async {
      final id = await compartilhar().share((
        id: _clube,
        name: 'Leitoras de Capitu',
        color: '#FFC1C6',
      ), grifo);
      expect(id, idTeste(990));
      final (clubId, q) = clubes.compartilhados.single;
      expect(clubId, _clube);
      expect(
        (q.text, q.color, q.page, q.chapter),
        ('Olhos de ressaca.', '#FED170', 160, 32),
      );
      expect(q.ratio, closeTo(160 / 256, 1e-9));
      // o chip aparece sem esperar a rede
      expect(
        (await cache.posts(_dona))[idTeste(990)],
        PostSummary(
          id: idTeste(990),
          clubId: _clube,
          clubName: 'Leitoras de Capitu',
          replies: 0,
        ),
      );
    });

    test('grifo antes do 1º capítulo numerado (a folha do título): vai como o cap. 1 do clube', () async {
      final antes = grifo.copyWith(chapterIndex: 0);
      await compartilhar().share((
        id: _clube,
        name: 'Leitoras de Capitu',
        color: '#FFC1C6',
      ), antes);
      expect(clubes.compartilhados.single.$2.chapter, 1);
    });

    test('os termos: a versão e o aceite passam pelo repositório', () async {
      final termos = _Termos();
      final s = ClubsHighlightsShare(
        owner: () async => _dona,
        cache: cache,
        clubs: clubes,
        terms: termos,
        database: () async => db,
      );
      expect(await s.terms(), (version: 'v1', accepted: false));
      await s.acceptTerms('v1');
      expect(termos.aceitos, ['v1']);
    });

    test(
      'a falha do servidor passa (a 25 mostra a pílula) e o chip não aparece',
      () async {
        clubes.falha = const SocialOffline();
        await expectLater(
          compartilhar().share((
            id: _clube,
            name: 'Leitoras de Capitu',
            color: '#FFC1C6',
          ), grifo),
          throwsA(isA<SocialOffline>()),
        );
        expect(await cache.posts(_dona), isEmpty);
      },
    );
  });
}
