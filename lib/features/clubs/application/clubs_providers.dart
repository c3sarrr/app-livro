// G21.4 — as ligações dos clubes (Riverpod). Sem servidor configurado não há cliente do Supabase: o repositório, a
// atualização e o tempo real são `null`, e o que lê o cache (o ticket, a faixa, o chip, o sininho) mostra o que
// houver — nada, para o convidado.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/server_providers.dart';
import '../../../core/data/database/local_database.dart';
import '../../social/application/social_providers.dart';
import '../data/club_pings.dart';
import '../data/clubs_cache.dart';
import '../data/clubs_repository.dart';
import 'clubs_sync.dart';

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
  );
});

/// Como abrir o canal `club:<id>` (o tempo real); `null` sem servidor.
final clubChannelsProvider = Provider<ClubChannelOpener?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : supabaseClubChannels(client);
});
