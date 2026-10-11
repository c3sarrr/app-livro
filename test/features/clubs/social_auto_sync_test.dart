// G21.5/G21.6 (D-225) — o social se atualiza sozinho: no 1º quadro e ao voltar ao app, com conta, os clubes e o
// sininho; os números do perfil uma vez por dia; ao entrar na conta, na hora. Convidado: nada.
import 'dart:async';
import 'dart:convert';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/features/clubs/application/clubs_providers.dart';
import 'package:app_leitura/features/clubs/application/clubs_sync.dart';
import 'package:app_leitura/features/clubs/application/publishers.dart';
import 'package:app_leitura/features/clubs/application/social_auto_sync.dart';
import 'package:app_leitura/features/clubs/application/stats_provider.dart';
import 'package:app_leitura/features/clubs/data/clubs_cache.dart';
import 'package:app_leitura/features/clubs/data/clubs_repository.dart';
import 'package:app_leitura/features/clubs/domain/club_models.dart';
import 'package:app_leitura/features/social/data/community_repository.dart';
import 'package:app_leitura/features/social/data/profile_repository.dart';
import 'package:app_leitura/features/social/domain/social_models.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'club_models_test.dart' show fixture;

final class _Clubes implements ClubsRepository {
  int idas = 0;

  /// Segura a próxima ida até completar (a rodada "no ar").
  Completer<void>? segurar;

  @override
  Future<MyClubs> myClubs() async {
    idas++;
    final s = segurar;
    if (s != null) {
      segurar = null;
      await s.future;
    }
    final f = fixture('my_clubs');
    return (cards: clubCardsFromJson(f), json: jsonEncode(f));
  }

  @override
  Object? noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

final class _Sininho implements NotificationsRepository {
  @override
  Future<int> unreadCount() async => 2;
  @override
  Future<void> markAllRead() async {}
}

final class _Perfil implements ProfileRepository {
  int publicados = 0;
  @override
  Future<bool> publishStats(ProfileNumbers numbers) async {
    publicados++;
    return true;
  }

  @override
  Object? noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

final class _Dono extends Notifier<String?> {
  @override
  String? build() => null;
  void entrar(String id) => state = id;
}

final _dono = NotifierProvider<_Dono, String?>(_Dono.new);

void main() {
  late AppDatabase db;
  late _Clubes clubes;
  late _Perfil perfil;
  late ClubsCache cache;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    clubes = _Clubes();
    perfil = _Perfil();
    cache = ClubsCache(
      () async => db,
      now: () => DateTime.utc(2026, 10, 9, 12),
    );
  });
  tearDown(() => db.close());

  Future<ProviderContainer> montar(WidgetTester t, {String? dono}) async {
    final c = ProviderContainer(
      overrides: [
        // o social roda com a conta confirmada (o resumo chegou e o convidado já passou para ela)
        socialConfirmedOwnerProvider.overrideWith((ref) => ref.watch(_dono)),
        clubsSyncProvider.overrideWithValue(
          ClubsSync(clubs: clubes, notifications: _Sininho(), cache: cache),
        ),
        statsPublisherProvider.overrideWithValue(
          StatsPublisher(
            profiles: perfil,
            cache: cache,
            database: () async => db,
            streak: () async => 0,
            now: () => DateTime.utc(2026, 10, 9, 12),
          ),
        ),
      ],
    );
    addTearDown(c.dispose);
    if (dono != null) c.read(_dono.notifier).entrar(dono);
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const SocialAutoSync(child: SizedBox()),
      ),
    );
    return c;
  }

  Future<void> esperar(WidgetTester t) =>
      t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));

  testWidgets(
    'com conta: no 1º quadro, os clubes, o sininho e os números; ao voltar ao app, os clubes de novo',
    (t) async {
      await montar(t, dono: 'dona');
      await t.pump();
      await esperar(t);
      expect((clubes.idas, perfil.publicados), (1, 1));
      expect(await t.runAsync(() => cache.notifications('dona')), 2);

      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await t.pump();
      await esperar(t);
      expect(clubes.idas, 2);
      expect(perfil.publicados, 1, reason: 'os números, uma vez por dia');
    },
  );

  testWidgets('convidado: nada; entrar na conta atualiza na hora', (t) async {
    final c = await montar(t);
    await t.pump();
    await esperar(t);
    expect((clubes.idas, perfil.publicados), (0, 0));
    c.read(_dono.notifier).entrar('dona');
    await t.pump();
    await esperar(t);
    expect(clubes.idas, 1);
  });

  testWidgets(
    'a conta trocou durante a rodada: outra rodada para a nova, logo depois',
    (t) async {
      final c = await montar(t);
      final porta = Completer<void>();
      clubes.segurar = porta;
      c.read(_dono.notifier).entrar('ana');
      await t.pump();
      await esperar(t);
      expect(clubes.idas, 1, reason: 'a rodada da Ana está no ar');
      c.read(_dono.notifier).entrar('bia');
      await t.pump();
      await esperar(t);
      expect(clubes.idas, 1, reason: 'uma rodada por vez');
      porta.complete();
      await t.runAsync(() async {
        for (var i = 0; i < 50 && clubes.idas < 2; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      });
      expect(clubes.idas, 2, reason: 'a Bia ganha a sua rodada');
    },
  );
}
