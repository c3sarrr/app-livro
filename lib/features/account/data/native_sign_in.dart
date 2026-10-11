// Login nativo com Google e Apple (D-67): o app obtém o idToken do provedor e o Supabase o confere
// (`signInWithIdToken`). Interfaces → dublês nos testes; as credenciais reais (cliente OAuth do Google,
// conta Apple Developer) entram quando houver projeto na nuvem.
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, immutable;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/config/app_env.dart';
import '../domain/account_failure.dart';
import '../domain/auth_status.dart';

@immutable
final class GoogleTokens {
  const GoogleTokens({required this.idToken, this.accessToken});
  final String idToken;
  final String? accessToken;
}

abstract interface class GoogleTokenSource {
  /// Abre o seletor de contas do Google. [SignInCancelled] se a pessoa fechar.
  Future<GoogleTokens> obtain();
}

abstract interface class AppleTokenSource {
  /// O login da Apple é nativo só no iOS; no Android o app usa o fluxo pelo navegador (deep link).
  bool get isNative;

  /// idToken da Apple para o nonce já em SHA-256 ([hashedNonce]).
  Future<String> identityToken({required String hashedNonce});
}

/// SHA-256 em hexadecimal (o nonce vai cifrado para o provedor e cru para o Supabase).
String sha256Hex(String raw) => sha256.convert(utf8.encode(raw)).toString();

/// [GoogleTokenSource] real (google_sign_in 7: Credential Manager no Android).
final class GoogleSignInTokenSource implements GoogleTokenSource {
  GoogleSignInTokenSource(this._env, [GoogleSignIn? signIn])
    : _signIn = signIn ?? GoogleSignIn.instance;

  final AppEnv _env;
  final GoogleSignIn _signIn;
  bool _initialized = false;

  static const _scopes = ['email', 'profile'];

  @override
  Future<GoogleTokens> obtain() async {
    if (!_env.hasGoogle) {
      throw const ProviderNotConfigured(SignInMethod.google);
    }
    try {
      if (!_initialized) {
        await _signIn.initialize(
          serverClientId: _env.googleWebClientId,
          clientId: _env.googleIosClientId.isEmpty
              ? null
              : _env.googleIosClientId,
        );
        _initialized = true;
      }
      final account = await _signIn.authenticate(scopeHint: _scopes);
      final idToken = account.authentication.idToken;
      if (idToken == null) throw const ServerFailure('google_sem_id_token');
      final authz = await account.authorizationClient.authorizationForScopes(
        _scopes,
      );
      return GoogleTokens(idToken: idToken, accessToken: authz?.accessToken);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const SignInCancelled();
      }
      throw ServerFailure('google_${e.code.name}');
    }
  }
}

/// [AppleTokenSource] real (sign_in_with_apple).
final class SignInWithAppleTokenSource implements AppleTokenSource {
  const SignInWithAppleTokenSource();

  @override
  bool get isNative =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Future<String> identityToken({required String hashedNonce}) async {
    try {
      final c = await SignInWithApple.getAppleIDCredential(
        scopes: const [AppleIDAuthorizationScopes.email],
        nonce: hashedNonce,
      );
      final token = c.identityToken;
      if (token == null) throw const ServerFailure('apple_sem_id_token');
      return token;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const SignInCancelled();
      }
      throw ServerFailure('apple_${e.code.name}');
    }
  }
}
