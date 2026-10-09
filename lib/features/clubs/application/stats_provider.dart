// G21.6 — o publicador dos números do perfil (R10) no app: a sequência é a da Início (a mesma conta da tela — G08).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/database/local_database.dart';
import '../../home/application/home_providers.dart';
import '../../social/application/social_providers.dart';
import 'clubs_providers.dart';
import 'publishers.dart';

final statsPublisherProvider = Provider<StatsPublisher?>((ref) {
  final profiles = ref.watch(profileRepositoryProvider);
  if (profiles == null) return null;
  return StatsPublisher(
    profiles: profiles,
    cache: ref.watch(clubsCacheProvider),
    database: () => ref.read(localDatabaseProvider.future),
    streak: () async {
      final home = ref.read(homeRepositoryProvider);
      final now = ref.read(clockProvider);
      return (await home.watch(now).first).readingDay.streakDays;
    },
    now: ref.watch(clockProvider),
    isCurrent: (owner) => ref.read(socialOwnerProvider) == owner,
  );
});
