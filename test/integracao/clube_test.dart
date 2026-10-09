// G21.8 — os clubes de ponta a ponta no Supabase LOCAL (WSL), com o mundo das pranchas carregado pelo psql
// (supabase/tests/database/_mundo_clube.psql): a Marina entra; o ticket, a faixa do sumário e o chip da 25 com os
// números do mundo; compartilhar um grifo e ver a resposta de outra leitora chegar pelo tempo real; o termo exigido;
// o bloqueio que esconde nos dois sentidos.
//
// Roda só quando pedido:
//   $env:BOOKNEST_SUPABASE_URL = 'http://127.0.0.1:54321'
//   $env:BOOKNEST_SUPABASE_PUBLISHABLE_KEY = '<a chave pública LOCAL de `supabase status`>'
//   flutter test --tags integracao test/integracao/clube_test.dart
@Tags(['integracao'])
library;

import 'dart:io';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/features/account/data/secure_session_storage.dart';
import 'package:app_leitura/features/clubs/application/club_sources.dart';
import 'package:app_leitura/features/clubs/application/clubs_sync.dart';
import 'package:app_leitura/features/clubs/data/club_pings.dart';
import 'package:app_leitura/features/clubs/data/clubs_cache.dart';
import 'package:app_leitura/features/clubs/data/clubs_repository.dart';
import 'package:app_leitura/features/home/data/cached_club_ticket_source.dart';
import 'package:app_leitura/features/reader/application/toc_view.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/social/data/community_repository.dart';
import 'package:app_leitura/features/social/data/follow_repository.dart';
import 'package:app_leitura/features/social/domain/social_failure.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthClientOptions, OtpType, SupabaseClient;

import '../features/account/support/fake_backend.dart' show MemorySecureStore;
import '../support/personal_builders.dart';
import '../support/reader_harness.dart' show domCasmurroEpub;
import 'support/local.dart';

const _clube = '00000000-0000-7000-8000-00000c200001';
const _edicao = '00000000-0000-7000-8000-00000c0a0003';
const _postDaMarina = '00000000-0000-7000-8000-00000c600008';
const _perguntaDaSemana = '00000000-0000-7000-8000-00000c500002';
String _leitora(int n) =>
    '00000000-0000-7000-8000-00000c10${n.toString().padLeft(4, '0')}';

void main() {
  final pronto = supabaseUrlLocal != null && supabaseChaveLocal != null;
  final pular = pronto
      ? false
      : 'defina BOOKNEST_SUPABASE_URL e BOOKNEST_SUPABASE_PUBLISHABLE_KEY';
  const tempo = Timeout(Duration(minutes: 2));

  late SupabaseClient client;
  late AppDatabase db;
  late ClubsCache cache;
  late SupabaseClubsRepository clubes;
  late ClubsSync sync;
  final marina = _leitora(3);

  setUpAll(() async {
    if (!pronto) return;
    // o mundo de novo (as execuções anteriores saem: as leitoras levam o clube junto)
    // o clube sai antes: apagar a dona passaria o clube para uma herdeira que sai no mesmo comando
    await sqlLocal('''
delete from public.clubs where owner_id in (select id from auth.users where email like '%@mundo.clube');
delete from auth.users where email like '%@mundo.clube';
delete from catalog.editions where id in ('$_edicao', '00000000-0000-7000-8000-00000c0a0004');
delete from catalog.work_authors where work_id = '00000000-0000-7000-8000-00000c0a0002';
delete from catalog.works where id = '00000000-0000-7000-8000-00000c0a0002';
delete from catalog.authors where id = '00000000-0000-7000-8000-00000c0a0001';
''');
    await sqlLocal(
      File('supabase/tests/database/_mundo_clube.psql').readAsStringSync(),
    );
    // as leitoras do mundo entram pelo código do e-mail como qualquer conta (o seed cria só o essencial)
    await sqlLocal('''
update auth.users set aud = 'authenticated', role = 'authenticated',
       instance_id = '00000000-0000-0000-0000-000000000000', email_confirmed_at = now(),
       confirmation_token = '', recovery_token = '', email_change_token_new = '', email_change = '',
       email_change_token_current = '', reauthentication_token = '', phone_change = '', phone_change_token = '',
       raw_app_meta_data = '{"provider": "email", "providers": ["email"]}', raw_user_meta_data = '{}',
       encrypted_password = '', created_at = now(), updated_at = now()
 where email like '%@mundo.clube';
''');
    client = SupabaseClient(
      supabaseUrlLocal!,
      supabaseChaveLocal!,
      authOptions: AuthClientOptions(
        autoRefreshToken: false,
        pkceAsyncStorage: SecurePkceStorage(MemorySecureStore()),
      ),
    );
    final antes = DateTime.now().toUtc().subtract(const Duration(seconds: 5));
    await client.auth.signInWithOtp(
      email: 'marina@mundo.clube',
      shouldCreateUser: false,
    );
    await client.auth.verifyOTP(
      email: 'marina@mundo.clube',
      token: await codigoNoMailpit('marina@mundo.clube', depoisDe: antes),
      type: OtpType.email,
    );
    expect(client.auth.currentUser!.id, marina);

    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    cache = ClubsCache(() async => db);
    clubes = SupabaseClubsRepository(client);
    sync = ClubsSync(
      clubs: clubes,
      notifications: SupabaseNotificationsRepository(client),
      cache: cache,
    );
    // o Dom Casmurro da Marina, no XXXII (o índice real)
    final index = indexEpubFile(domCasmurroEpub, 'a' * 64);
    final xxxii = chapterNumerals(index).indexOf('XXXII');
    await UserBooksDao(db).upsert(
      livroTeste(1, dono: marina).copyWith(editionId: const Nullable(_edicao)),
    );
    await BookContentIndexDao(db)
        .upsert(idTeste(1), index, builtAt: DateTime.utc(2026, 9, 20));
    await ReadingPositionsDao(db).upsert(
      posicaoTeste(
        idTeste(1),
        dono: marina,
      ).copyWith(chapterIndex: xxxii, progression: 0.62),
    );
  });

  tearDownAll(() async {
    if (!pronto) return;
    await client.dispose();
    await db.close();
  });

  test(
    'o ticket, a faixa e o chip com os números do mundo',
    () async {
      expect(await sync.refresh(marina), isNull);
      final t = await CachedClubTicketSource(() async => db).current(marina);
      expect(
        (t!.namePrefix, t.nameHighlight, t.untilChapter, t.participantsCount),
        ('Leitoras de', 'Capitu', 50, 11),
      );
      expect(
        (t.groupProgress, t.userProgress, t.userInitial, t.unreadMessages),
        (0.5373, 0.62, 'M', 3),
      );
      expect(t.shownParticipants.map((p) => p.initial).join(), 'AJL');

      final g = await ClubsReaderClubSource(cache).goalFor(marina, idTeste(1));
      final index = indexEpubFile(domCasmurroEpub, 'a' * 64);
      final c = chapterNumerals(index).indexOf('XXXII');
      final p = index.toc.where((x) => x.leaf).elementAt(c);
      final v = buildTocView(
        bookTitle: 'Dom Casmurro',
        index: index,
        at: (spine: p.spine!, offset: p.offset!),
        refPage: 159,
        annotations: const [],
        bookmarks: const [],
        club: g,
        now: DateTime.now().toUtc(),
        utcOffsetAt: (_) => const Duration(hours: -3),
      );
      expect(v.club!.goal, 'Até o cap. L · faltam 18');

      expect(await sync.refreshPosts(marina, [_postDaMarina]), isNull);
      final chip = await ClubsHighlightsClubSource(
        owner: () async => marina,
        cache: cache,
      ).clubOf(_postDaMarina);
      expect(chip, (clubId: _clube, name: 'Leitoras de Capitu', replies: 3));
    },
    skip: pular,
    timeout: tempo,
  );

  test(
    'compartilhar um grifo; a resposta de outra leitora chega pelo tempo real',
    () async {
      await sync.refresh(marina);
      final grifo = grifoTeste(
        10,
        livro: idTeste(1),
        dono: marina,
        exato: 'Olhos de ressaca? Vá, de ressaca.',
        pagina: 159,
      );
      final share = ClubsHighlightsShare(
        owner: () async => marina,
        cache: cache,
        clubs: clubes,
        terms: SupabaseTermsRepository(client),
        database: () async => db,
      );
      final post = await share.share((
        id: _clube,
        name: 'Leitoras de Capitu',
        color: '#FFC1C6',
      ), grifo);
      final nota = await sqlLocal(
        "select coalesce(body, '') || '|' || quote_text from public.club_posts where id = '$post'",
      );
      expect(
        nota,
        '|Olhos de ressaca? Vá, de ressaca.',
        reason: 'vai o trecho; a nota não',
      );

      final aoVivo = ClubsChipUpdates(
        owner: () async => marina,
        sync: sync,
        cache: cache,
        channels: supabaseClubChannels(client),
        settle: const Duration(milliseconds: 300),
      );
      var eventos = 0;
      final sub = aoVivo.follow({post}).listen((_) => eventos++);
      addTearDown(sub.cancel);
      for (var i = 0; i < 50 && eventos == 0; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      // o canal assina; a Ana responde (pelo banco, como o app dela faria)
      await Future<void>.delayed(const Duration(seconds: 2));
      await sqlLocal(
        "insert into public.club_post_replies (post_id, author_id, body) values ('$post', '${_leitora(1)}', 'Que trecho!')",
      );
      for (
        var i = 0;
        i < 100 && (await cache.posts(marina))[post]?.replies != 1;
        i++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      expect((await cache.posts(marina))[post]!.replies, 1);
    },
    skip: pular,
    timeout: tempo,
  );

  test(
    'o termo exigido: sem aceitar, não publica; aceitando, publica',
    () async {
      await sqlLocal(
        "delete from private.terms_acceptances where user_id = '$marina'",
      );
      await expectLater(
        clubes.suggestQuestion(_clube, 2, 'Capitu traiu ou não?'),
        throwsA(isA<SocialTermsRequired>()),
      );
      final termos = SupabaseTermsRepository(client);
      final t = await termos.mine();
      expect(t.accepted, isFalse);
      await termos.accept(t.version);
      expect((await termos.mine()).accepted, isTrue);
      expect(
        await clubes.suggestQuestion(_clube, 2, 'Capitu traiu ou não?'),
        isNotEmpty,
      );
    },
    skip: pular,
    timeout: tempo,
  );

  test(
    'o bloqueio esconde nos dois sentidos, e as contagens descem junto',
    () async {
      final antes = await clubes.weekThread(_clube, 2, limit: 50);
      expect(antes.replies.any((r) => r.author.initial == 'R'), isTrue);
      final bloqueio = SupabaseBlockRepository(client);
      await bloqueio.block(_leitora(5)); // a Rafa
      addTearDown(() => bloqueio.unblock(_leitora(5)));
      final depois = await clubes.weekThread(_clube, 2, limit: 50);
      expect(depois.replies.any((r) => r.author.initial == 'R'), isFalse);
      expect(depois.question!.replies, antes.question!.replies - 1);
      // a Rafa também não vê a Marina: a pergunta da semana dela some para a Rafa (pelo banco, como a Rafa)
      // numa transação: o set_config local e o "set local role" valem até o commit (fora dela, o psql os ignora)
      final vistoPelaRafa = await sqlLocal('''
begin;
select set_config('request.jwt.claims', '{"sub": "${_leitora(5)}", "role": "authenticated"}', true);
set local role authenticated;
select count(*) from public.club_post_replies where post_id = '$_perguntaDaSemana' and author_id = '$marina';
commit;
''');
      expect(vistoPelaRafa.split('\n').last.trim(), '0');
      await bloqueio.unblock(_leitora(5));
      expect(
        (await clubes.weekThread(_clube, 2, limit: 50)).question!.replies,
        antes.question!.replies,
      );
    },
    skip: pular,
    timeout: tempo,
  );
}
