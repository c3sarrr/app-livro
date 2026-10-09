// Dublês da compra (G22): a loja, o servidor do Pro e a conta, sem plataforma e sem rede.
import 'dart:async';
import 'dart:collection';

import 'package:app_leitura/features/account/application/account_controller.dart';
import 'package:app_leitura/features/account/domain/account_summary.dart';
import 'package:app_leitura/features/billing/data/billing_gateway.dart';
import 'package:app_leitura/features/billing/data/pro_server_api.dart';
import 'package:app_leitura/features/billing/domain/billing_models.dart';

const contaA = '0199a7c4-2f00-7a10-8b20-0000000000aa';
const contaB = '0199a7c4-2f00-7a10-8b20-0000000000bb';

final proAte = DateTime.utc(2026, 11, 12, 15);
final proDaLoja = ProCustomer(
  active: true,
  activeUntil: proAte,
  willRenew: true,
  managementUrl: 'https://loja.teste/gerir',
  store: 'testStore',
  sandbox: true,
);

const mensal = ProPackage(
  id: r'$rc_monthly',
  period: ProPeriod.month,
  priceString: r'R$ 9,99',
  price: 9.99,
  currencyCode: 'BRL',
  trialDays: 7,
);
const anual = ProPackage(
  id: r'$rc_annual',
  period: ProPeriod.year,
  priceString: r'R$ 79,99',
  price: 79.99,
  currencyCode: 'BRL',
  trialDays: 7,
);

/// A loja de mentira: grava as chamadas; a compra e o restaurar devolvem o que for programado.
final class LojaFalsa implements BillingGateway {
  final chamadas = <String>[];
  ProCustomer cliente = ProCustomer.none;
  List<ProPackage> pacotes = const [mensal, anual];

  /// O resultado da próxima compra (ou a falha a lançar).
  Object compra = const PurchaseCancelled();

  /// A falha do próximo restaurar (nulo = devolve [cliente]).
  BillingFailure? falhaAoRestaurar;

  /// Segura a compra até completar (o toque duplo).
  Completer<void>? segurarCompra;

  final _mudancas = StreamController<ProCustomer>.broadcast(sync: true);

  void avisar(ProCustomer c) {
    cliente = c;
    _mudancas.add(c);
  }

  @override
  Future<void> configure({required String appUserId}) async =>
      chamadas.add('configure:$appUserId');

  @override
  Future<ProCustomer> logIn(String appUserId) async {
    chamadas.add('logIn:$appUserId');
    return cliente;
  }

  @override
  Future<void> logOut() async => chamadas.add('logOut');

  @override
  Future<List<ProPackage>> packages() async {
    chamadas.add('packages');
    return pacotes;
  }

  @override
  Future<PurchaseOutcome> purchase(String packageId) async {
    chamadas.add('purchase:$packageId');
    await segurarCompra?.future;
    final r = compra;
    if (r is BillingFailure) throw r;
    if (r is Purchased) cliente = r.customer;
    return r as PurchaseOutcome;
  }

  @override
  Future<ProCustomer> restore() async {
    chamadas.add('restore');
    final f = falhaAoRestaurar;
    if (f != null) throw f;
    return cliente;
  }

  @override
  Future<ProCustomer> customer() async {
    chamadas.add('customer');
    return cliente;
  }

  @override
  Stream<ProCustomer> customerUpdates() => _mudancas.stream;
}

/// O servidor do Pro de mentira: as respostas de `current` em fila (a última se repete).
final class ServidorProFalso implements ProServerApi {
  final chamadas = <String>[];
  ServerPro aoConferir = (pro: false, activeUntil: null);
  Object? falhaAoConferir;
  final respostas = Queue<ServerPro>();
  ServerPro ultima = (pro: false, activeUntil: null);

  @override
  Future<ServerPro> syncNow() async {
    chamadas.add('syncNow');
    final f = falhaAoConferir;
    if (f != null) throw f;
    return aoConferir;
  }

  @override
  Future<ServerPro> current() async {
    chamadas.add('current');
    if (respostas.isNotEmpty) ultima = respostas.removeFirst();
    return ultima;
  }
}

AccountSummary resumo(String id, {bool pro = false}) => AccountSummary(
  id: id,
  handle: 'leitora',
  displayName: 'Leitora',
  isPrivate: false,
  handleProvisional: false,
  ageBand: null,
  pro: pro,
);

/// A conta de mentira: o estado é o que o teste põe; `refresh` relê o resumo com o Pro do "servidor".
final class ContaFalsa extends AccountController {
  ContaFalsa(this.inicial);
  final AccountView inicial;
  int releituras = 0;

  /// O que o servidor diria do Pro na próxima releitura.
  bool proNoServidor = false;

  @override
  AccountView build() => inicial;

  void mudar(AccountView v) => state = v;

  @override
  Future<void> refresh() async {
    releituras++;
    final s = state;
    if (s is MemberView) {
      state = MemberView(
        userId: s.userId,
        summary: resumo(s.userId, pro: proNoServidor),
      );
    }
  }
}

MemberView membro(String id, {bool pro = false}) => MemberView(
  userId: id,
  summary: resumo(id, pro: pro),
);
