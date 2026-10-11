// G21.4 — as ligações dos clubes (Riverpod). Sem servidor configurado não há cliente do Supabase: o repositório, a
// atualização e o tempo real são `null`, e o que lê o cache (o ticket, a faixa, o chip, o sininho) mostra o que
// houver — nada, para o convidado.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/server_providers.dart';
import '../../../core/data/database/local_database.dart';
import '../../account/application/account_controller.dart';
import '../../social/application/social_providers.dart';
import '../data/club_pings.dart';
import '../data/clubs_cache.dart';
import '../data/clubs_repository.dart';
import 'club_sources.dart';
import 'clubs_sync.dart';
import 'publishers.dart';

/// A conta com que o social fala: o id da conta entrada; convidado (ou carregando), `null`.
final socialOwnerProvider = Provider<String?>(
  (ref) => switch (ref.watch(accountControllerProvider)) {
    MemberView(:final userId) => userId,
    _ => null,
  },
);

/// A conta confirmada pelo servidor (o resumo chegou e o que era do convidado já passou para ela): só com ela o
/// social vai à rede sozinho (o ciclo do app). Antes disso, os números seriam os de uma estante vazia.
final socialConfirmedOwnerProvider = Provider<String?>(
  (ref) => switch (ref.watch(accountControllerProvider)) {
    MemberView(:final userId, summary: _?) => userId,
    _ => null,
  },
);

/// Se [owner] ainda é a conta da sessão (trocar de conta no meio: nada da antiga segue — D-68).
bool Function(String owner) _isCurrent(Ref ref) =>
    (owner) => ref.read(socialOwnerProvider) == owner;

final clubsRepositoryProvider = Provider<ClubsRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseClubsRepository(client);
});

final clubsCacheProvider = Provider<ClubsCache>(
  (ref) => ClubsCache(() => ref.read(localDatabaseProvider.future)),
);

final clubsSyncProvider = Provider<ClubsSync?>((ref) {
  final clubs = ref.watch(clubsRepositoryProvider);
  final notifications = ref.watch(notificationsRepositoryProvider);
  if (clubs == null || notifications == null) return null;
  return ClubsSync(
    clubs: clubs,
    notifications: notifications,
    cache: ref.watch(clubsCacheProvider),
    isCurrent: _isCurrent(ref),
  );
});

/// Como abrir o canal `club:<id>` (o tempo real); `null` sem servidor.
final clubChannelsProvider = Provider<ClubChannelOpener?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : supabaseClubChannels(client);
});

/// R9: a posição do livro de um clube ao sair do leitor; `null` sem servidor.
final progressPublisherProvider = Provider<ProgressPublisher?>((ref) {
  final clubs = ref.watch(clubsRepositoryProvider);
  if (clubs == null) return null;
  return ProgressPublisher(
    clubs: clubs,
    cache: ref.watch(clubsCacheProvider),
    database: () => ref.read(localDatabaseProvider.future),
    isCurrent: _isCurrent(ref),
  );
});

/// O chip ao vivo da 25; `null` sem servidor.
final clubChipUpdatesProvider = Provider<ClubsChipUpdates?>((ref) {
  final sync = ref.watch(clubsSyncProvider);
  if (sync == null) return null;
  return ClubsChipUpdates(
    owner: () async => ref.read(socialOwnerProvider),
    sync: sync,
    cache: ref.watch(clubsCacheProvider),
    channels: ref.watch(clubChannelsProvider),
  );
});

/// "Compartilhar no clube" da 25; `null` sem servidor.
final highlightsShareProvider = Provider<ClubsHighlightsShare?>((ref) {
  final clubs = ref.watch(clubsRepositoryProvider);
  final terms = ref.watch(termsRepositoryProvider);
  if (clubs == null || terms == null) return null;
  return ClubsHighlightsShare(
    owner: () async => ref.read(socialOwnerProvider),
    cache: ref.watch(clubsCacheProvider),
    clubs: clubs,
    terms: terms,
    database: () => ref.read(localDatabaseProvider.future),
  );
});
