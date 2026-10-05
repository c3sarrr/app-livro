import 'dart:async';
import 'dart:ui' show Color, PlatformDispatcher;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/database/local_database.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../account/application/account_controller.dart';
import '../../account/application/account_providers.dart';
import '../../catalog/application/catalog_providers.dart';
import '../data/cached_club_ticket_source.dart';
import '../data/catalog_for_you_source.dart';
import '../data/home_repository.dart';
import '../data/local_home_repository.dart';
import '../domain/models.dart';

/// Relógio da tela. Testes e o app de desenvolvimento injetam o "agora" de referência (D-09).
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Fonte dos dados da Início: o banco do aparelho (G08, D-85 — substitui a D-61). Os testes de fidelidade e o
/// app de desenvolvimento injetam a fixture do mundo de referência (D-34). Nada é aberto antes de a tela
/// pedir (as dependências são lidas na hora).
final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => LocalHomeRepository(
    database: () => ref.read(localDatabaseProvider.future),
    owner: () async =>
        (await ref.read(localLibraryProvider.future)).activeOwnerId(),
    forYou: CatalogForYouSource(
      () async => (await ref.read(catalogUpdaterProvider.future))?.catalog(),
      language: catalogLanguageOf(
        PlatformDispatcher.instance.locale.languageCode,
      ),
    ),
    club: CachedClubTicketSource(() => ref.read(localDatabaseProvider.future)),
    users: () => ref.read(homeUsersProvider)(),
  ),
);

/// Usuário do cabeçalho a cada mudança da conta, começando pelo atual (D-84). Só é montado quando a fonte real
/// passa a assistir a Início.
final homeUsersProvider = Provider<Stream<UserSummary> Function()>((ref) {
  var user = homeUserOf(ref.read(accountControllerProvider));
  final changes = StreamController<UserSummary>.broadcast();
  ref.listen(accountControllerProvider, (_, view) {
    user = homeUserOf(view);
    changes.add(user);
  });
  ref.onDispose(changes.close);
  return () async* {
    yield user;
    yield* changes.stream;
  };
});

/// Cabeçalho a partir da conta (D-84): primeiro nome do perfil e a inicial; sem conta (ou antes do perfil
/// chegar), convidado. Notificações chegam na G21.
UserSummary homeUserOf(AccountView view) {
  final name = switch (view) {
    MemberView(:final summary?) => summary.displayName.trim(),
    _ => '',
  };
  if (name.isEmpty) return LocalHomeRepository.guest;
  final first = name.split(RegExp(r'\s+')).first;
  return UserSummary(
    firstName: first,
    initial: String.fromCharCode(first.runes.first).toUpperCase(),
    unreadNotifications: 0,
  );
}

/// Estado da Início (D-85): carregando → dados → (erro). Fonte síncrona (a fixture — D-09) começa já com os
/// dados; a do banco começa carregando e segue o `stream`.
final homeStateProvider =
    NotifierProvider<HomeStateController, AsyncValue<HomeSnapshot>>(
      HomeStateController.new,
    );

class HomeStateController extends Notifier<AsyncValue<HomeSnapshot>> {
  @override
  AsyncValue<HomeSnapshot> build() {
    final repo = ref.watch(homeRepositoryProvider);
    final clock = ref.watch(clockProvider);
    final sub = repo
        .watch(clock)
        .listen(
          (s) => state = AsyncData(s),
          onError: (Object e, StackTrace st) => state = AsyncError(e, st),
        );
    ref.onDispose(sub.cancel);
    return switch (repo) {
      final SyncHomeRepository sync => AsyncData(sync.snapshot(clock())),
      _ => const AsyncLoading(),
    };
  }

  /// "Tentar de novo" (D-85): refaz a leitura do começo.
  void retry() => ref.invalidateSelf();
}

/// Dados da tela (só existem no estado "dados" — a tela não monta as seções antes). Widgets de seção leem só o
/// recorte de que precisam: `ref.watch(homeSnapshotProvider.select((s) => s.continueReading))`.
final homeSnapshotProvider = Provider<HomeSnapshot>(
  (ref) => ref.watch(homeStateProvider).requireValue,
);

/// Props do componente no arquivo (D-11): `brand` e `weekColor`, padrão `#B6ACE4`.
@immutable
class HomeTheme {
  const HomeTheme({
    this.brand = AppColors.lavender,
    this.weekColor = AppColors.lavender,
  });

  final Color brand;
  final Color weekColor;
}

/// Só aceita as opções do arquivo (`AppColors.brandOptions` / `AppColors.weekColorOptions`).
class HomeThemeController extends Notifier<HomeTheme> {
  @override
  HomeTheme build() => const HomeTheme();

  void setBrand(Color c) {
    assert(AppColors.brandOptions.contains(c));
    state = HomeTheme(brand: c, weekColor: state.weekColor);
  }

  void setWeekColor(Color c) {
    assert(AppColors.weekColorOptions.contains(c));
    state = HomeTheme(brand: state.brand, weekColor: c);
  }
}

final homeThemeProvider = NotifierProvider<HomeThemeController, HomeTheme>(
  HomeThemeController.new,
);
