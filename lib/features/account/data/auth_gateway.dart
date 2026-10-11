// Login (Supabase Auth — D-67): e-mail com código de 6 dígitos (OTP, sem link), Google (idToken
// nativo) e Apple (nativo no iOS; pelo navegador com deep link no Android). Erros do servidor viram
// [AccountFailure]; nenhum token nem e-mail vai para log.
import 'dart:async';
import 'dart:io' show SocketException;

import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/account_failure.dart';
import '../domain/auth_status.dart';
import 'native_sign_in.dart';

abstract interface class AuthGateway {
  AuthStatus get current;

  /// Emite a cada mudança (entrou, saiu, sessão vencida).
  Stream<AuthStatus> watch();

  /// Envia o código de 6 dígitos por e-mail (cria a conta se não existir).
  Future<void> sendEmailCode(String email);
  Future<void> verifyEmailCode(String email, String code);
  Future<void> signInWithGoogle();

  /// Apple: no iOS conclui aqui; no Android abre o navegador e a sessão chega pelo deep link
  /// (acompanhe por [watch]).
  Future<void> signInWithApple();

  /// Encerra a sessão NESTE aparelho.
  Future<void> signOut();
}

final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Normaliza e confere o formato do e-mail (o servidor confere de novo).
String? normalizeEmail(String raw) {
  final e = raw.trim().toLowerCase();
  return _email.hasMatch(e) && e.length <= 254 ? e : null;
}

/// Traduz exceções do cliente Supabase para [AccountFailure] (reaproveitado pela [AccountApi]).
AccountFailure accountFailureOf(Object e) => switch (e) {
  final AccountFailure f => f,
  // sem resposta (rede) → offline; resposta 5xx do servidor → falha do servidor
  AuthRetryableFetchException(statusCode: null) => const OfflineFailure(),
  AuthRetryableFetchException(:final statusCode) => ServerFailure(
    'auth_$statusCode',
  ),
  AuthException(:final code)
      when code == 'otp_expired' || code == 'invalid_credentials' =>
    const InvalidCode(),
  AuthException(:final code, :final statusCode)
      when code == 'over_email_send_rate_limit' ||
          code == 'over_request_rate_limit' ||
          statusCode == '429' =>
    const TooManyAttempts(),
  AuthException(:final code, :final statusCode)
      when code == 'email_address_invalid' ||
          code == 'validation_failed' ||
          (code == null && statusCode == '422') =>
    const InvalidEmail(),
  AuthException(:final code) => ServerFailure('auth_${code ?? 'desconhecido'}'),
  SocketException() ||
  TimeoutException() ||
  ClientException() => const OfflineFailure(),
  _ => ServerFailure(e.runtimeType.toString()),
};

/// [AuthGateway] sobre o cliente do Supabase.
final class SupabaseAuthGateway implements AuthGateway {
  SupabaseAuthGateway(
    this._client, {
    required this._google,
    required this._apple,
    required this._redirect,
  });

  final SupabaseClient _client;
  final GoogleTokenSource _google;
  final AppleTokenSource _apple;
  final String _redirect;

  GoTrueClient get _auth => _client.auth;

  static AuthStatus _statusOf(Session? s) => s == null
      ? const SignedOut()
      : SignedIn(userId: s.user.id, email: s.user.email);

  @override
  AuthStatus get current => _statusOf(_auth.currentSession);

  @override
  Stream<AuthStatus> watch() =>
      _auth.onAuthStateChange.map((e) => _statusOf(e.session)).distinct();

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } catch (e) {
      throw accountFailureOf(e);
    }
  }

  @override
  Future<void> sendEmailCode(String email) async {
    final e = normalizeEmail(email);
    if (e == null) throw const InvalidEmail();
    await _guard(() => _auth.signInWithOtp(email: e, shouldCreateUser: true));
  }

  @override
  Future<void> verifyEmailCode(String email, String code) async {
    final e = normalizeEmail(email);
    final c = code.replaceAll(RegExp(r'\s'), '');
    if (e == null) throw const InvalidEmail();
    if (!RegExp(r'^\d{6}$').hasMatch(c)) throw const InvalidCode();
    await _guard(
      () => _auth.verifyOTP(email: e, token: c, type: OtpType.email),
    );
  }

  @override
  Future<void> signInWithGoogle() => _guard(() async {
    final t = await _google.obtain();
    await _auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: t.idToken,
      accessToken: t.accessToken,
    );
  });

  @override
  Future<void> signInWithApple() => _guard(() async {
    if (!_apple.isNative) {
      // Android: fluxo pelo navegador; a sessão volta pelo deep link (supabase_flutter + app_links).
      await _auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: _redirect,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      return;
    }
    final rawNonce = _auth.generateRawNonce();
    final idToken = await _apple.identityToken(
      hashedNonce: sha256Hex(rawNonce),
    );
    await _auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
  });

  @override
  Future<void> signOut() => _guard(() => _auth.signOut());
}
