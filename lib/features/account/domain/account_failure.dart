// Falhas tipadas da conta (§4.5): a tela mostra o texto; nada de mensagem crua do servidor.
import 'auth_status.dart';

sealed class AccountFailure implements Exception {
  const AccountFailure();

  /// Texto curto para a pessoa (D-21: sem design ainda — Figtree simples).
  String get message;

  @override
  String toString() => '$runtimeType';
}

/// E-mail mal escrito.
final class InvalidEmail extends AccountFailure {
  const InvalidEmail();
  @override
  String get message => 'Confira o e-mail digitado.';
}

/// Código errado ou vencido.
final class InvalidCode extends AccountFailure {
  const InvalidCode();
  @override
  String get message => 'Código inválido ou vencido. Peça um novo.';
}

/// Muitos pedidos seguidos (limite do servidor).
final class TooManyAttempts extends AccountFailure {
  const TooManyAttempts();
  @override
  String get message => 'Muitas tentativas. Espere um pouco e tente de novo.';
}

/// A pessoa fechou a janela do Google/Apple.
final class SignInCancelled extends AccountFailure {
  const SignInCancelled();
  @override
  String get message => 'Login cancelado.';
}

/// Provedor sem credencial nesta versão (D-67: Google/Apple ligam com o projeto na nuvem).
final class ProviderNotConfigured extends AccountFailure {
  const ProviderNotConfigured(this.method);
  final SignInMethod method;
  @override
  String get message => switch (method) {
    SignInMethod.google => 'Entrar com Google ainda não está disponível.',
    SignInMethod.apple => 'Entrar com Apple ainda não está disponível.',
    SignInMethod.emailCode => 'Entrar com e-mail não está disponível.',
  };
}

/// Sem servidor configurado nesta versão (só convidado).
final class ServerNotConfigured extends AccountFailure {
  const ServerNotConfigured();
  @override
  String get message => 'Conta indisponível nesta versão do app.';
}

/// Sem internet.
final class OfflineFailure extends AccountFailure {
  const OfflineFailure();
  @override
  String get message => 'Sem conexão. Tente de novo quando estiver online.';
}

/// Menor de 13 (D-66).
final class Underage extends AccountFailure {
  const Underage();
  @override
  String get message => 'O BookNest é para pessoas de 13 anos ou mais.';
}

/// Login pedido sem passar pela checagem de idade (D-66).
final class AgeCheckRequired extends AccountFailure {
  const AgeCheckRequired();
  @override
  String get message => 'Antes de entrar, confirme sua idade.';
}

/// @ já em uso.
final class HandleTaken extends AccountFailure {
  const HandleTaken();
  @override
  String get message => 'Esse @ já está em uso.';
}

/// @ fora da regra (3–30 caracteres: letras minúsculas, números, ponto e _) ou reservado.
final class HandleInvalid extends AccountFailure {
  const HandleInvalid();
  @override
  String get message =>
      'Use de 3 a 30 caracteres: letras minúsculas, números, ponto e _.';
}

/// Texto com termo proibido pelas regras da comunidade.
final class ContentBlocked extends AccountFailure {
  const ContentBlocked();
  @override
  String get message => 'Esse texto tem um termo que não é permitido.';
}

/// Limite diário de exportações (3 por dia).
final class ExportLimitReached extends AccountFailure {
  const ExportLimitReached();
  @override
  String get message => 'Você já exportou 3 vezes hoje. Tente amanhã.';
}

/// Precisa de conta para isso.
final class NotSignedIn extends AccountFailure {
  const NotSignedIn();
  @override
  String get message => 'Entre na sua conta para continuar.';
}

/// A conta não existe mais (excluída pela página web ou em outro aparelho) — a sessão ainda era válida.
final class AccountGone extends AccountFailure {
  const AccountGone();
  @override
  String get message => 'Esta conta foi excluída.';
}

/// Erro inesperado do servidor ([code] = código técnico, só para diagnóstico — sem dado pessoal).
final class ServerFailure extends AccountFailure {
  const ServerFailure(this.code);
  final String code;
  @override
  String get message => 'Algo deu errado. Tente de novo.';

  @override
  String toString() => 'ServerFailure($code)';
}
