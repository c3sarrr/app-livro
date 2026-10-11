// Estado da sessão (Supabase Auth). O convidado (D-64) é `SignedOut`: o app funciona inteiro no aparelho.
import 'package:flutter/foundation.dart' show immutable;

/// Como a pessoa entrou.
enum SignInMethod { emailCode, google, apple }

@immutable
sealed class AuthStatus {
  const AuthStatus();
}

/// Sem sessão: convidado.
final class SignedOut extends AuthStatus {
  const SignedOut();

  @override
  bool operator ==(Object other) => other is SignedOut;

  @override
  int get hashCode => (SignedOut).hashCode;
}

/// Com sessão válida.
final class SignedIn extends AuthStatus {
  const SignedIn({required this.userId, this.email});

  /// `auth.uid()` — também é o dono dos dados locais da conta (D-68).
  final String userId;

  /// Só para mostrar na tela; nunca vai para log (§4.4.5).
  final String? email;

  @override
  bool operator ==(Object other) =>
      other is SignedIn && other.userId == userId && other.email == email;

  @override
  int get hashCode => Object.hash(userId, email);

  @override
  String toString() => 'SignedIn($userId)';
}
