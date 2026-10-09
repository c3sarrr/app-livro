// G21.3 — as falhas do social e dos clubes (erros tipados — §4.5): o que a tela precisa para responder (a pílula, a
// folha dos termos, o paywall do 2º clube). Vêm dos códigos que o servidor levanta (`raise exception '<código>'`),
// da sessão e da rede. docs/progresso/G21.md §3.
import 'package:flutter/foundation.dart' show immutable;

@immutable
sealed class SocialFailure implements Exception {
  const SocialFailure(this.code);

  /// Código curto, sem conteúdo (telemetria e testes).
  final String code;

  @override
  String toString() => 'SocialFailure($code)';
}

/// Sem rede ou tempo esgotado: tudo do social precisa de conexão ("Sem conexão. Tente de novo.").
final class SocialOffline extends SocialFailure {
  const SocialOffline() : super('rede');
}

/// Sem conta (ou a sessão acabou).
final class SocialNeedsAccount extends SocialFailure {
  const SocialNeedsAccount() : super('sem_conta');
}

/// A faixa etária não foi registrada (D-72).
final class SocialNeedsAge extends SocialFailure {
  const SocialNeedsAge() : super('faixa');
}

/// Os termos da versão atual não foram aceitos (D-222): a folha "Antes de publicar".
final class SocialTermsRequired extends SocialFailure {
  const SocialTermsRequired() : super('termos');
}

/// O Grátis cria 1 clube.
final class SocialFreeClubLimit extends SocialFailure {
  const SocialFreeClubLimit() : super('limite_gratis');
}

/// Convite que não existe, venceu, foi desativado ou lotou.
final class SocialInvalidInvite extends SocialFailure {
  const SocialInvalidInvite() : super('convite');
}

/// Bloqueio entre as duas pessoas (D-223).
final class SocialBlocked extends SocialFailure {
  const SocialBlocked() : super('bloqueio');
}

/// Não é do clube, não é a anfitriã, ou a política do banco não deixou.
final class SocialNotAllowed extends SocialFailure {
  const SocialNotAllowed() : super('sem_permissao');
}

/// O que se pediu não existe mais (ou não é visível para mim): o post, o alvo da curtida, o clube público.
final class SocialNotFound extends SocialFailure {
  const SocialNotFound() : super('nao_encontrado');
}

/// O texto tem um termo proibido pelas regras da comunidade.
final class SocialContentBlocked extends SocialFailure {
  const SocialContentBlocked() : super('termo_proibido');
}

/// Qualquer outro: o código do servidor (ou "resposta" para um formato que o app não entende).
final class SocialUnexpected extends SocialFailure {
  const SocialUnexpected(super.code);
}

/// A falha de um erro do PostgREST ([code], [message] = o código que o banco levantou).
SocialFailure socialFailureOf(String? code, String message) => switch ((
  code,
  message,
)) {
  // a versão mudou entre ler e aceitar: a folha volta com a nova
  (_, 'terms_required' || 'stale_terms') => const SocialTermsRequired(),
  (_, 'free_club_limit') => const SocialFreeClubLimit(),
  (_, 'invalid_invite') => const SocialInvalidInvite(),
  (_, 'blocked') => const SocialBlocked(),
  (_, 'age_required') => const SocialNeedsAge(),
  (_, 'content_blocked') => const SocialContentBlocked(),
  (_, 'not_member' || 'not_allowed' || 'content_moderated') =>
    const SocialNotAllowed(),
  (
    _,
    'post_not_found' || 'target_not_found' || 'club_not_public' || 'not_found',
  ) =>
    const SocialNotFound(),
  ('PGRST116', _) => const SocialNotFound(),
  ('28000' || 'PGRST301' || 'PGRST303', _) => const SocialNeedsAccount(),
  ('42501', _) => const SocialNotAllowed(),
  (_, final m) when RegExp(r'^[a-z_]{3,40}$').hasMatch(m) => SocialUnexpected(
    m,
  ),
  (final c, _) => SocialUnexpected('pg_${c ?? 'desconhecido'}'),
};
