// G22.3 — o estado do Pro no app (docs/progresso/G22.md §3). A conta configura o RevenueCat com o id do Supabase
// (R1); a tela mostra o Pro da loja (rápido, com o cache do SDK) e o sync segue o do servidor (`my_account.pro`, G06).
// Quando a loja diz Pro e o servidor não, a ativação (R2) confere no servidor ("conferir agora", D-229) e espera
// com recuo até ele confirmar; confirmado, o resumo da conta é relido e o sync liga. Trocar de conta no meio para
// tudo o que era da conta antiga (D-68).
import 'dart:async';

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/account_controller.dart';
import '../../social/domain/social_failure.dart' show SocialOffline;
import '../data/billing_gateway.dart';
import '../domain/billing_models.dart';
import '../domain/billing_rules.dart';
import 'billing_providers.dart';

@immutable
sealed class ProView {
  const ProView();
}

/// Sem compra nesta versão (sem chave ou sem servidor) ou sem conta (R1).
final class ProUnavailable extends ProView {
  const ProUnavailable();
}

/// Configurando o RevenueCat para a conta.
final class ProLoading extends ProView {
  const ProLoading();
}

final class ProReady extends ProView {
  const ProReady({
    required this.customer,
    required this.serverPro,
    this.activating = false,
    this.notice,
  });

  /// O Pro da loja: é o que a tela mostra.
  final ProCustomer customer;

  /// O Pro do servidor: é o que liga o sync.
  final bool serverPro;

  /// "Ativando o Pro…" (R2).
  final bool activating;

  /// O aviso da última ação (a pílula); a tela o limpa depois de mostrar.
  final String? notice;

  /// O aviso é de falha (a tela o mostra como erro).
  bool get noticeIsError => notice == offlineNotice || notice == failedNotice;

  ProReady copyWith({
    ProCustomer? customer,
    bool? serverPro,
    bool? activating,
    String? Function()? notice,
  }) => ProReady(
    customer: customer ?? this.customer,
    serverPro: serverPro ?? this.serverPro,
    activating: activating ?? this.activating,
    notice: notice == null ? this.notice : notice(),
  );

  @override
  bool operator ==(Object other) =>
      other is ProReady &&
      other.customer == customer &&
      other.serverPro == serverPro &&
      other.activating == activating &&
      other.notice == notice;

  @override
  int get hashCode => Object.hash(customer, serverPro, activating, notice);
}

/// R2: as esperas entre as conferências no servidor (≈ 60 s ao todo).
const activationBackoff = [1, 2, 4, 8, 16, 29];

const offlineNotice = 'Sem conexão. Tente de novo.';
const failedNotice = 'Não deu certo. Tente de novo.';

const notConfirmedNotice =
    'O Pro ainda não chegou ao servidor. A sincronização liga assim que ele confirmar.';

final class _Life {
  bool alive = true;
}

class BillingController extends Notifier<ProView> {
  _Life _life = _Life();
  Future<void> _queue = Future.value();

  /// A conta configurada no RevenueCat (nula = nenhuma).
  String? _user;
  bool _configured = false;
  StreamSubscription<ProCustomer>? _updates;
  Future<void>? _activation;

  /// A ativação não confirmou: tenta de novo ao voltar ao app (R2).
  bool _retryOnResume = false;

  /// Uma compra, um restaurar ou um gerenciar em andamento.
  bool _busy = false;

  BillingGateway get _gateway => ref.read(billingGatewayProvider)!;

  @override
  ProView build() {
    final gateway = ref.watch(billingGatewayProvider);
    final server = ref.watch(proServerApiProvider);
    final life = _life = _Life();
    ref.onDispose(() {
      life.alive = false;
      unawaited(_updates?.cancel());
      _updates = null;
    });
    _user = null;
    _configured = false;
    _activation = null;
    _retryOnResume = false;
    _busy = false;
    if (gateway == null || server == null) return const ProUnavailable();
    ref.listen<AccountView>(accountControllerProvider, (_, next) {
      _enqueue(next, life);
    });
    final now = ref.read(accountControllerProvider);
    _enqueue(now, life);
    return now is MemberView ? const ProLoading() : const ProUnavailable();
  }

  void _enqueue(AccountView view, _Life life) {
    _queue = _queue.then((_) async {
      if (!life.alive) return;
      try {
        await _onAccount(view, life);
      } on BillingFailure {
        // sem rede ou a loja fora: a tela fica como estava; a próxima mudança da conta tenta de novo
      }
    });
  }

  Future<void> _onAccount(AccountView view, _Life life) async {
    switch (view) {
      case MemberView(:final userId, :final summary):
        final serverPro = summary?.pro ?? false;
        if (userId != _user) {
          await _signIn(userId, serverPro, life);
          return;
        }
        final s = state;
        if (s is ProReady && s.serverPro != serverPro) {
          state = s.copyWith(serverPro: serverPro);
        }
      case GuestView():
        if (_user != null) {
          _user = null;
          _retryOnResume = false;
          state = const ProUnavailable();
          await _gateway.logOut();
        } else {
          state = const ProUnavailable();
        }
      case AccountLoading():
        break;
    }
  }

  Future<void> _signIn(String userId, bool serverPro, _Life life) async {
    _user = userId;
    _retryOnResume = false;
    state = const ProLoading();
    final gateway = _gateway;
    final ProCustomer customer;
    if (_configured) {
      customer = await gateway.logIn(userId);
    } else {
      await gateway.configure(appUserId: userId);
      _configured = true;
      customer = await gateway.customer();
    }
    if (!life.alive || _user != userId) return;
    _updates ??= gateway.customerUpdates().listen(_onCustomer);
    state = ProReady(customer: customer, serverPro: serverPro);
    _maybeActivate();
  }

  void _onCustomer(ProCustomer c) {
    final s = state;
    if (s is! ProReady) return;
    state = s.copyWith(customer: c);
    _maybeActivate();
  }

  /// R2: a loja diz Pro e o servidor não.
  void _maybeActivate() {
    final s = state;
    if (s is ProReady && s.customer.active && !s.serverPro) {
      unawaited(activate());
    }
  }

  /// A ativação (R2): o "conferir agora" e o `my_entitlement` com recuo. Uma por vez.
  Future<void> activate() {
    final user = _user;
    if (user == null) return Future.value();
    return _activation ??= _activate(
      user,
      _life,
    ).whenComplete(() => _activation = null);
  }

  Future<void> _activate(String user, _Life life) async {
    bool current() => life.alive && _user == user;
    final s = state;
    if (s is! ProReady) return;
    _retryOnResume = false;
    state = s.copyWith(activating: true, notice: () => null);
    final server = ref.read(proServerApiProvider)!;
    final sleep = ref.read(billingSleepProvider);
    var confirmed = false;
    try {
      confirmed = (await server.syncNow()).pro;
    } on Object {
      // o RevenueCat fora do ar ou o limite do dia: o webhook ainda pode chegar
    }
    for (final seconds in activationBackoff) {
      if (confirmed || !current()) break;
      await sleep(Duration(seconds: seconds));
      if (!current()) break;
      try {
        confirmed = (await server.current()).pro;
      } on Object {
        // sem rede: a próxima espera tenta de novo
      }
    }
    if (!current()) return;
    if (confirmed) {
      await ref.read(accountControllerProvider.notifier).refresh();
      if (!current()) return;
      final r = state;
      if (r is ProReady) state = r.copyWith(activating: false, serverPro: true);
      return;
    }
    _retryOnResume = true;
    final r = state;
    if (r is ProReady) {
      state = r.copyWith(activating: false, notice: () => notConfirmedNotice);
    }
  }

  // ------------------------------------------------------------------ as ações (R3, R5, R6)

  /// Uma ação por vez, só com conta (R1) e a loja pronta.
  Future<void> _action(Future<void> Function(String user) run) async {
    final user = _user;
    if (_busy || user == null || state is! ProReady) return;
    _busy = true;
    try {
      await run(user);
    } finally {
      _busy = false;
    }
  }

  void _notice(String user, String text) {
    final s = state;
    if (_user == user && s is ProReady) state = s.copyWith(notice: () => text);
  }

  void _setCustomer(String user, ProCustomer c) {
    final s = state;
    if (_user == user && s is ProReady) state = s.copyWith(customer: c);
  }

  /// R3: comprou → a ativação (R2); fechou a folha → nada; pendente, sem rede ou outra falha → o aviso; a loja diz
  /// que já assina → restaura (R5).
  Future<void> purchase(ProPackage package) => _action((user) async {
    try {
      switch (await _gateway.purchase(package.id)) {
        case Purchased(:final customer):
          _setCustomer(user, customer);
          _maybeActivate();
        case PurchaseCancelled():
          break;
        case PurchasePending():
          _notice(
            user,
            'Pagamento em análise. O Pro liga quando a loja aprovar.',
          );
      }
    } on AlreadySubscribed {
      await _restore(user);
    } on BillingOffline {
      _notice(user, offlineNotice);
    } on BillingFailure {
      _notice(user, failedNotice);
    }
  });

  /// R5: as compras da conta da loja; uma que era de outra conta do app passa para esta pelo servidor.
  Future<void> restore() => _action(_restore);

  Future<void> _restore(String user) async {
    try {
      final c = await _gateway.restore();
      _setCustomer(user, c);
      if (c.active) {
        _maybeActivate();
        _notice(user, 'Compras restauradas.');
      } else {
        _notice(user, 'Nenhuma assinatura encontrada nesta conta da loja.');
      }
    } on BillingOffline {
      _notice(user, offlineNotice);
    } on BillingFailure {
      _notice(user, failedNotice);
    }
  }

  /// R6: a página de gestão da loja, fora do app; sem ela (ou se não abrir), onde gerenciar.
  Future<void> manage() => _action((user) async {
    final url = (state as ProReady).customer.managementUrl;
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri != null) {
      var opened = false;
      try {
        opened = await ref.read(billingLauncherProvider)(uri);
      } on Object {
        opened = false;
      }
      if (opened) return;
    }
    _notice(
      user,
      manageInstruction(ref.read(billingPlatformProvider)) ?? failedNotice,
    );
  });

  /// Os pacotes da offering `default` (a tela técnica). Sem conta ou sem a loja: nenhum.
  Future<List<ProPackage>> packages() async {
    if (_user == null || state is! ProReady) return const [];
    return _gateway.packages();
  }

  /// "Conferir agora" da tela técnica: o servidor busca o estado da conta no RevenueCat (D-229); se o Pro do servidor
  /// mudou, o resumo da conta é relido (o sync segue pela G06).
  Future<void> checkNow() => _action((user) async {
    final server = ref.read(proServerApiProvider)!;
    try {
      final r = await server.syncNow();
      final s = state;
      if (_user != user || s is! ProReady) return;
      if (r.pro != s.serverPro) {
        await ref.read(accountControllerProvider.notifier).refresh();
        final now = state;
        if (_user == user && now is ProReady) {
          state = now.copyWith(serverPro: r.pro);
        }
      }
      _notice(
        user,
        r.pro
            ? 'O servidor confirmou o Pro.'
            : 'O servidor não tem o Pro desta conta.',
      );
    } on SocialOffline {
      _notice(user, offlineNotice);
    } on Object {
      _notice(user, failedNotice);
    }
  });

  /// O app voltou ao primeiro plano: a ativação que não confirmou tenta de novo (R2).
  void resumed() {
    if (_retryOnResume && _user != null) unawaited(activate());
  }

  /// A tela mostrou o aviso.
  void clearNotice() {
    final s = state;
    if (s is ProReady && s.notice != null) {
      state = s.copyWith(notice: () => null);
    }
  }
}

final billingControllerProvider = NotifierProvider<BillingController, ProView>(
  BillingController.new,
);
