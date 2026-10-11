// Resumo da conta que o servidor devolve depois do login (`public.my_account()`), e a regra do @.
import 'package:flutter/foundation.dart' show immutable;

import 'age.dart';

@immutable
final class AccountSummary {
  const AccountSummary({
    required this.id,
    required this.handle,
    required this.displayName,
    required this.isPrivate,
    required this.handleProvisional,
    required this.ageBand,
    required this.pro,
    this.otherSessions = 0,
  });

  factory AccountSummary.fromJson(Map<String, Object?> j) => AccountSummary(
    id: j['id']! as String,
    handle: j['handle']! as String,
    displayName: j['display_name']! as String,
    isPrivate: j['visibility'] == 'private',
    handleProvisional: j['handle_provisional'] == true,
    ageBand: AgeBand.fromCode(j['age_band'] as String?),
    pro: j['pro'] == true,
    otherSessions: (j['other_sessions'] as num?)?.toInt() ?? 0,
  );

  final String id;
  final String handle;
  final String displayName;
  final bool isPrivate;

  /// O @ ainda é o provisório do cadastro ("leitor_…") → o app pede a escolha (onboarding).
  final bool handleProvisional;
  final AgeBand? ageBand;
  final bool pro;

  /// G22 (R7): quantas OUTRAS sessões ativas a conta tem (o sinal do 2º aparelho). Nenhum dado delas.
  final int otherSessions;

  @override
  bool operator ==(Object other) =>
      other is AccountSummary &&
      other.id == id &&
      other.handle == handle &&
      other.displayName == displayName &&
      other.isPrivate == isPrivate &&
      other.handleProvisional == handleProvisional &&
      other.ageBand == ageBand &&
      other.pro == pro &&
      other.otherSessions == otherSessions;

  @override
  int get hashCode => Object.hash(
    id,
    handle,
    displayName,
    isPrivate,
    handleProvisional,
    ageBand,
    pro,
    otherSessions,
  );
}

/// Regra do @ (CHECK de `public.profiles.handle`): 3–30 caracteres em `a–z 0–9 . _`, guardado
/// minúsculo; o formato "leitor_…" é reservado ao servidor. Devolve o @ normalizado ou `null`.
String? normalizeHandle(String raw) {
  var h = raw.trim().toLowerCase();
  if (h.startsWith('@')) h = h.substring(1);
  if (!RegExp(r'^[a-z0-9_.]{3,30}$').hasMatch(h)) return null;
  if (h.startsWith('leitor_')) return null;
  return h;
}
