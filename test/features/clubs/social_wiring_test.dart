// G21.3–G21.6 — as ligações do social no app (Riverpod): sem servidor, nada do social existe (o app é só convidado —
// D-64); com o cliente do Supabase, cada repositório é o de verdade. Os números do perfil (R10) contam a sequência
// da Início (a mesma da tela — G08) e só vão pela conta da sessão (D-68).
import 'package:app_leitura/core/config/server_providers.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/local_database.dart';
import 'package:app_leitura/features/clubs/application/clubs_providers.dart';
import 'package:app_leitura/features/clubs/application/stats_provider.dart';
import 'package:app_leitura/features/clubs/data/clubs_repository.dart';
import 'package:app_leitura/features/social/application/social_providers.dart';
import 'package:app_leitura/features/social/data/community_repository.dart';
import 'package:app_leitura/features/social/data/follow_repository.dart';
import 'package:app_leitura/features/social/data/post_repository.dart';
import 'package:app_leitura/features/social/data/profile_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../fixtures/overrides_do_mundo.dart'
    show relogioDoMundo, repositorioDoMundo;

void main() {
  test('sem servidor: nenhum repositório do social, nem a atualização, nem os números', () {
    final c = ProviderContainer(
      overrides: [supabaseClientProvider.overrideWithValue(null)],
    );
    addTearDown(c.dispose);
    expect([
      c.read(profileRepositoryProvider),
      c.read(followRepositoryProvider),
      c.read(blockRepositoryProvider),
      c.read(postRepositoryProvider),
      c.read(reportRepositoryProvider),
      c.read(termsRepositoryProvider),
      c.read(notificationsRepositoryProvider),
      c.read(clubsRepositoryProvider),
      c.read(clubsSyncProvider),
      c.read(statsPublisherProvider),
    ], everyElement(isNull));
  });

  group('com o cliente do Supabase', () {
    late SupabaseClient client;
    late AppDatabase db;
    late ProviderContainer c;

    setUp(() {
      // nada vai à rede nestes testes: o endereço não responde
      client = SupabaseClient('http://127.0.0.1:9', 'chave-publica-de-teste');
      db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
      c = ProviderContainer(
        overrides: [
          supabaseClientProvider.overrideWithValue(client),
          localDatabaseProvider.overrideWith((ref) async => db),
          socialOwnerProvider.overrideWithValue('dona'),
          relogioDoMundo,
          repositorioDoMundo,
        ],
      );
    });
    tearDown(() async {
      c.dispose();
      await db.close();
      await client.dispose();
    });

    test('cada repositório é o de verdade', () {
      expect(
        c.read(profileRepositoryProvider),
        isA<SupabaseProfileRepository>(),
      );
      expect(c.read(followRepositoryProvider), isA<SupabaseFollowRepository>());
      expect(c.read(blockRepositoryProvider), isA<SupabaseBlockRepository>());
      expect(c.read(postRepositoryProvider), isA<SupabasePostRepository>());
      expect(c.read(reportRepositoryProvider), isA<SupabaseReportRepository>());
      expect(c.read(termsRepositoryProvider), isA<SupabaseTermsRepository>());
      expect(
        c.read(notificationsRepositoryProvider),
        isA<SupabaseNotificationsRepository>(),
      );
      expect(c.read(clubsRepositoryProvider), isA<SupabaseClubsRepository>());
      expect(c.read(clubsSyncProvider), isNotNull);
    });

    test('os números do perfil: a sequência é a da Início; a conta de fora da sessão não publica', () async {
      final numeros = c.read(statsPublisherProvider)!;
      expect((await numeros.numbersOf('dona')).streakDays, 12);
      expect(await numeros.publishIfDue('outra'), isFalse);
    });
  });
}
