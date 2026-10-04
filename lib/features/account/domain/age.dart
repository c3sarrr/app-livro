// Idade mínima e faixas (D-66 — ECA Digital, Lei 15.211/2025): o sinal de idade da loja (Google Play
// Age Signals / Apple Declared Age Range) é a fonte principal; a data de nascimento é o apoio quando a
// loja não informa. O servidor guarda só a FAIXA e a FONTE — nunca a data.
import 'package:flutter/foundation.dart' show immutable;

/// Faixas do Google Play (0–12, 13–15, 16–17, 18+), também usadas com a Apple (portões 13, 16 e 18).
enum AgeBand {
  under13('under_13'),
  from13to15('13_15'),
  from16to17('16_17'),
  adult('18_plus');

  const AgeBand(this.code);

  /// Código do servidor (`private.account_age.band`).
  final String code;

  bool get isMinor => this != adult;

  static AgeBand? fromCode(String? code) {
    for (final b in values) {
      if (b.code == code) return b;
    }
    return null;
  }

  /// Faixa de uma idade em anos completos.
  static AgeBand forAge(int years) => years >= 18
      ? adult
      : years >= 16
      ? from16to17
      : years >= 13
      ? from13to15
      : under13;

  /// Faixa de um intervalo informado pela loja. `lower` nulo = sem veredito.
  static AgeBand? fromRange(int? lower, int? upper) {
    if (lower == null) return null;
    if (upper != null && upper < 13) return under13;
    return forAge(lower);
  }
}

/// Portões passados ao plugin das lojas (iOS aceita até 3, com 2 anos de distância — 13/16/18 batem
/// com as faixas do Google Play).
const List<int> ageGates = [13, 16, 18];

/// De onde veio a faixa.
enum AgeSource {
  playSignal('play_signal'),
  appleSignal('apple_signal'),
  birthdate('birthdate');

  const AgeSource(this.code);
  final String code;
}

@immutable
final class AgeCheck {
  const AgeCheck(this.band, this.source);
  final AgeBand band;
  final AgeSource source;

  bool get allowed => band != AgeBand.under13;

  @override
  bool operator ==(Object other) =>
      other is AgeCheck && other.band == band && other.source == source;

  @override
  int get hashCode => Object.hash(band, source);

  @override
  String toString() => 'AgeCheck(${band.code}, ${source.code})';
}

/// Anos completos em [today] de quem nasceu em [birth] (datas de calendário; hora ignorada).
int fullYears(DateTime birth, DateTime today) {
  var years = today.year - birth.year;
  if (today.month < birth.month ||
      (today.month == birth.month && today.day < birth.day)) {
    years--;
  }
  return years;
}

/// Faixa pela data de nascimento. Data no futuro ou absurda (mais de 120 anos) → `null` (pedir de novo).
AgeBand? bandFromBirthDate(DateTime birth, DateTime today) {
  final years = fullYears(birth, today);
  if (years < 0 || years > 120) return null;
  return AgeBand.forAge(years);
}

/// Data de nascimento digitada como DD/MM/AAAA (ou com "-" ou "."). Data inexistente → `null`.
DateTime? parseBirthDate(String raw) {
  final m = RegExp(r'^\s*(\d{1,2})[/.-](\d{1,2})[/.-](\d{4})\s*$')
      .firstMatch(raw);
  if (m == null) return null;
  final d = int.parse(m[1]!), mo = int.parse(m[2]!), y = int.parse(m[3]!);
  final date = DateTime(y, mo, d);
  if (date.year != y || date.month != mo || date.day != d) return null;
  return date;
}
