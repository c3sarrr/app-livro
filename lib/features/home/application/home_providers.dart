import 'dart:async';
import 'dart:ui' show Color, PlatformDispatcher;

import 'package:flutter/foundation.dart'
    show FlutterError, FlutterErrorDetails, immutable;
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/database/local_database.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/preferences/brand_preference.dart';
import '../../account/application/account_controller.dart';
import '../../account/application/account_providers.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../clubs/application/clubs_providers.dart';
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
    wakeups: appResumes,
  ),
);

/// Cada volta do app ao primeiro plano (o timer do relógio não anda com o aparelho dormindo).
Stream<void> appResumes() {
  late final StreamController<void> c;
  AppLifecycleListener? l;
  c = StreamController<void>(
    onListen: () => l = AppLifecycleListener(onResume: () => c.add(null)),
    onCancel: () => l?.dispose(),
  );
  return c.stream;
}

/// G21.5 (D-212): as notificações não lidas da conta, do cache do social (o ponto do sininho); sem conta, 0.
final homeUnreadNotificationsProvider = StreamProvider<int>((ref) {
  final owner = ref.watch(socialOwnerProvider);
  if (owner == null) return Stream.value(0);
  return ref.watch(clubsCacheProvider).watchNotifications(owner);
});

/// Cabeçalho da Início vindo da conta (D-84) — só para a fonte real: a fixture (fonte síncrona, D-09) traz o
/// usuário do arquivo no próprio instantâneo (`null` = não troca).
final homeAccountUserProvider = Provider<UserSummary?>((ref) {
  if (ref.watch(homeRepositoryProvider) is SyncHomeRepository) return null;
  return homeUserOf(
    ref.watch(accountControllerProvider),
    unread: ref.watch(homeUnreadNotificationsProvider).value ?? 0,
  );
});

/// Erro da fonte depois de já haver dados: a tela continua com os dados e o erro vai para o relatório de
/// falhas (D-85). Os testes trocam.
final homeErrorReporterProvider =
    Provider<void Function(Object error, StackTrace stack)>(
      (ref) =>
          (e, st) => FlutterError.reportError(
            FlutterErrorDetails(exception: e, stack: st, library: 'inicio'),
          ),
    );

/// Cabeçalho a partir da conta (D-84): primeiro nome do perfil e a inicial; sem conta (ou antes do perfil
/// chegar), convidado. [unread] = as notificações não lidas (G21, D-212: o ponto do sininho).
UserSummary homeUserOf(AccountView view, {int unread = 0}) {
  final name = switch (view) {
    MemberView(:final summary?) => summary.displayName.trim(),
    _ => '',
  };
  if (name.isEmpty) {
    return unread > 0
        ? UserSummary(unreadNotifications: unread)
        : LocalHomeRepository.guest;
  }
  final first = name.split(RegExp(r'\s+')).first;
  return UserSummary(
    firstName: first,
    initial: String.fromCharCode(first.runes.first).toUpperCase(),
    unreadNotifications: unread,
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
    final report = ref.watch(homeErrorReporterProvider);
    final sub = repo
        .watch(clock)
        .listen(
          (s) => state = AsyncData(s),
          // Com dados na tela, um erro não a troca pela tela de erro (a rolagem e o que se vê ficam).
          onError: (Object e, StackTrace st) {
            if (state.hasValue) {
              report(e, st);
            } else {
              state = AsyncError(e, st);
            }
          },
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
final homeSnapshotProvider = Provider<HomeSnapshot>((ref) {
  final s = ref.watch(homeStateProvider).requireValue;
  final user = ref.watch(homeAccountUserProvider);
  return user == null ? s : s.withUser(user);
});

/// Props do componente no arquivo (D-11): `brand` e `weekColor`, padrão `#B6ACE4`.
@immutable
class HomeTheme {
  const HomeTheme({
    this.brand = AppColors.lavender,
    this.weekColor = AppColors.lavender,
  });

  final Color brand;
  final Color weekColor;

  @override
  bool operator ==(Object other) =>
      other is HomeTheme &&
      other.brand == brand &&
      other.weekColor == weekColor;

  @override
  int get hashCode => Object.hash(brand, weekColor);
}

/// Só aceita as opções do arquivo (`AppColors.brandOptions` / `AppColors.weekColorOptions`). O `brand` é o
/// global do app (D-33, `brandProvider`); o `weekColor` é só da Início.
class HomeThemeController extends Notifier<HomeTheme> {
  Color _week = AppColors.lavender;

  @override
  HomeTheme build() =>
      HomeTheme(brand: ref.watch(brandProvider), weekColor: _week);

  void setBrand(Color c) {
    assert(AppColors.brandOptions.contains(c));
    // troca na hora (quem observa é avisado já); o global grava e reconstrói este com a mesma cor
    state = HomeTheme(brand: c, weekColor: _week);
    unawaited(ref.read(brandProvider.notifier).set(c));
  }

  void setWeekColor(Color c) {
    assert(AppColors.weekColorOptions.contains(c));
    _week = c;
    state = HomeTheme(brand: state.brand, weekColor: c);
  }
}

final homeThemeProvider = NotifierProvider<HomeThemeController, HomeTheme>(
  HomeThemeController.new,
);
