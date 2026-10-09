// G21.3 — as ligações do social (Riverpod). Sem servidor configurado não há cliente do Supabase e cada
// repositório é `null` (o app é só convidado — D-64); sem sessão, o próprio repositório recusa sem ir à rede.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/server_providers.dart';
import '../data/community_repository.dart';
import '../data/follow_repository.dart';
import '../data/post_repository.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseProfileRepository(client);
});

final followRepositoryProvider = Provider<FollowRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseFollowRepository(client);
});

final blockRepositoryProvider = Provider<BlockRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseBlockRepository(client);
});

final postRepositoryProvider = Provider<PostRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabasePostRepository(client);
});

final reportRepositoryProvider = Provider<ReportRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseReportRepository(client);
});

final termsRepositoryProvider = Provider<TermsRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseTermsRepository(client);
});

final notificationsRepositoryProvider = Provider<NotificationsRepository?>((
  ref,
) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseNotificationsRepository(client);
});
