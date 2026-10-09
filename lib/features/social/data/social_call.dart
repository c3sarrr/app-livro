// G21.3 — toda chamada do social passa por aqui: exige a sessão, limita o tempo e troca os erros do Supabase pelas
// falhas tipadas (o padrão do `community_catalog_api.dart` da G07). Tudo do social precisa de rede: nada fica numa
// fila (D-211; `pending_social_ops` continua sem uso).
import 'dart:async';
import 'dart:io' show IOException;

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart'
    show
        AuthException,
        AuthRetryableFetchException,
        PostgrestException,
        SupabaseClient;

import '../domain/social_failure.dart';

const Duration socialTimeout = Duration(seconds: 8);

/// O id da conta da sessão; sem sessão, [SocialNeedsAccount].
String socialUserId(SupabaseClient client) {
  final id = client.auth.currentUser?.id;
  if (client.auth.currentSession == null || id == null) {
    throw const SocialNeedsAccount();
  }
  return id;
}

/// Roda [run] com a sessão conferida; os erros viram [SocialFailure].
Future<T> socialCall<T>(
  SupabaseClient client,
  Future<T> Function() run, {
  Duration timeout = socialTimeout,
}) async {
  socialUserId(client);
  try {
    return await run().timeout(timeout);
  } on SocialFailure {
    rethrow;
  } on PostgrestException catch (e) {
    throw socialFailureOf(e.code, e.message);
  } on AuthRetryableFetchException {
    // a renovação do login (antes do pedido) não alcançou o servidor
    throw const SocialOffline();
  } on AuthException {
    // o login foi recusado (revogado, vencido sem volta)
    throw const SocialNeedsAccount();
  } on TimeoutException {
    throw const SocialOffline();
  } on IOException {
    throw const SocialOffline();
  } on http.ClientException {
    throw const SocialOffline();
  } on Object {
    throw const SocialUnexpected('resposta');
  }
}
