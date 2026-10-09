// G22.2 — as regras da compra que são só contas e textos (docs/progresso/G22.md §3): R4 (a economia do anual e o
// teste grátis), os textos do estado no Perfil, R6 (onde gerenciar sem a página da loja) e R8 (a validade sem rede).
import 'package:flutter/foundation.dart' show TargetPlatform;

import 'billing_models.dart';

/// R4: quanto o anual economiza sobre 12 meses do mensal, em % arredondado para baixo. Nulo com moedas diferentes,
/// preço que não é positivo, pacotes trocados ou quando o anual não sai mais barato.
int? annualSavingsPercent(ProPackage month, ProPackage year) {
  if (month.period != ProPeriod.month || year.period != ProPeriod.year) {
    return null;
  }
  if (month.currencyCode != year.currencyCode) return null;
  // em centavos, para a conta não depender do arredondamento do double
  final m = (month.price * 100).round();
  final a = (year.price * 100).round();
  if (m <= 0 || a <= 0) return null;
  final pct = (12 * m - a) * 100 ~/ (12 * m);
  return pct > 0 ? pct : null;
}

/// R4: "7 dias grátis, depois R$ 9,99/mês" — só com teste (elegível).
String? trialLine(ProPackage p) {
  final dias = p.trialDays;
  if (dias == null || dias <= 0) return null;
  final unidade = dias == 1 ? 'dia' : 'dias';
  final periodo = p.period == ProPeriod.month ? 'mês' : 'ano';
  return '$dias $unidade grátis, depois ${p.priceString}/$periodo';
}

Duration _localOffset(DateTime utc) => utc.toLocal().timeZoneOffset;

String _two(int n) => n.toString().padLeft(2, '0');

/// Os textos do estado no Perfil (§3). As datas no fuso do aparelho.
String proStatusLine(
  ProCustomer c, {
  bool activating = false,
  Duration Function(DateTime utc)? utcOffsetAt,
}) {
  if (activating) return 'Ativando o Pro…';
  if (!c.active) return 'Plano: Grátis';
  final offset = utcOffsetAt ?? _localOffset;
  DateTime local(DateTime t) {
    final utc = t.toUtc();
    return utc.add(offset(utc));
  }

  final prazo = c.graceUntil ?? c.activeUntil;
  if (c.billingIssue && prazo != null) {
    final d = local(prazo);
    return 'Pro · problema no pagamento. Atualize na loja até '
        '${_two(d.day)}/${_two(d.month)}.';
  }
  final ate = c.activeUntil;
  if (ate == null) return 'Pro';
  final d = local(ate);
  final data = '${_two(d.day)}/${_two(d.month)}/${d.year}';
  return c.willRenew
      ? 'Pro até $data · renova automaticamente'
      : 'Pro até $data · renovação desligada';
}

/// R8: sem rede, o Pro que a loja informou vale para o que é local até a expiração + 3 dias.
bool localProValid(ProCustomer c, DateTime now) {
  if (!c.active) return false;
  final ate = c.activeUntil;
  if (ate == null) return true;
  return now.isBefore(ate.add(const Duration(days: 3)));
}

/// R6: onde gerenciar quando a loja não deu a página de gestão.
String? manageInstruction(TargetPlatform platform) => switch (platform) {
  TargetPlatform.android =>
    'Gerencie a assinatura em Play Store › Pagamentos e assinaturas',
  TargetPlatform.iOS =>
    'Gerencie a assinatura em Ajustes › seu nome › Assinaturas',
  _ => null,
};
