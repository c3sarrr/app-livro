// G22.3 — o estado do Pro no app (docs/progresso/G22.md §3). A conta configura o RevenueCat com o id do Supabase
// (R1); a tela mostra o Pro da loja (rápido, com o cache do SDK) e o sync segue o do servidor (`my_account.pro`, G06).
// Quando a loja diz Pro e o servidor não, a ativação (R2) confere no servidor ("conferir agora", D-229) e espera
// com recuo até ele confirmar; confirmado, o resumo da conta é relido e o sync liga. Trocar de conta no meio para
// tudo o que era da conta antiga (D-68): as mudanças da conta e as ações na loja passam por uma fila só.
import 'dart:async';

import 'package:flutter/foundation.dart'
    show FlutterError, FlutterErrorDetails, immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/account_controller.dart';
import '../../home/application/home_providers.dart' show clockProvider;
import '../../social/domain/social_failure.dart' show SocialOffline;
import '../data/billing_gateway.dart';
import '../data/pro_server_api.dart' show ServerPro;
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

  /// A conta do app (nula = convidado).
  String? _user;

  /// A conta com que o RevenueCat está agora (nula = nenhuma: o Grátis que nunca comprou não fala com ele).
  String? _storeUser;

  /// O SDK já foi configurado nesta execução (depois, trocar de conta é `logIn`).
  bool _sdkConfigured = false;
  StreamSubscription<ProCustomer>? _updates;

  /// A ativação em andamento e de qual conta (a da conta anterior não segura a da nova).
  Future<void>? _activation;
  String? _activationUser;

  /// O resumo da conta já chegou: antes dele, o Pro do servidor é desconhecido e nada ativa (revisão, I1).
  bool _serverKnown = false;

  /// O último Pro do servidor que o resumo trouxe (a tela sai do "Configurando" com ele se a loja falhar).
  bool _lastServerPro = false;

  /// A ativação não confirmou: tenta de novo ao voltar ao app (R2).
  bool _retryOnResume = false;

  /// A conferência da volta ao app em andamento (D-236): uma por vez.
  Future<void>? _resumeCheck;

  /// Quantas ativações começaram (o restaurar não repete a que a conexão com a loja acabou de fazer).
  int _activationRuns = 0;

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
    _storeUser = null;
    _sdkConfigured = false;
    _activation = null;
    _activationUser = null;
    _serverKnown = false;
    _lastServerPro = false;
    _retryOnResume = false;
    _resumeCheck = null;
    _busy = false;
    if (gateway == null || server == null) return const ProUnavailable();
    ref.listen<AccountView>(accountControllerProvider, (_, next) {
      _enqueue(next, life);
    });
    final now = ref.read(accountControllerProvider);
    _enqueue(now, life);
    return now is MemberView ? const ProLoading() : const ProUnavailable();
  }

  /// A fila: as mudanças da conta e as ações na loja, uma de cada vez (sair no meio de um restaurar espera ele
  /// terminar e então tira a conta do RevenueCat — revisão, I4).
  Future<T> _serial<T>(Future<T> Function() run) {
    final done = Completer<T>();
    _queue = _queue.then((_) async {
      try {
        done.complete(await run());
      } on Object catch (e, st) {
        done.completeError(e, st);
      }
    });
    return done.future;
  }

  void _enqueue(AccountView view, _Life life) {
    unawaited(
      _serial(() async {
        if (!life.alive) return;
        try {
          await _onAccount(view, life);
        } on Object catch (e, st) {
          // sem rede ou a loja fora: a tela não fica presa em "Configurando" (revisão, m3); a próxima ação tenta de
          // novo
          if (e is! BillingFailure) {
            FlutterError.reportError(
              FlutterErrorDetails(exception: e, stack: st, library: 'pro'),
            );
          }
          if (life.alive && _user != null && state is ProLoading) {
            state = ProReady(
              customer: ProCustomer.none,
              serverPro: _lastServerPro,
            );
          }
        }
      }),
    );
  }

  BillingStoreMemory get _memory => ref.read(billingStoreMemoryProvider);

  Future<bool> _usedStore(String owner) async {
    try {
      return await _memory.used(owner);
    } on Object {
      return false;
    }
  }

  Future<void> _onAccount(AccountView view, _Life life) async {
    switch (view) {
      case MemberView(:final userId, :final summary):
        // sem o resumo (ainda carregando ou o servidor fora), o Pro do servidor é desconhecido (revisão, I1)
        final known = summary != null;
        if (known) _lastServerPro = summary.pro;
        if (userId != _user) {
          _user = userId;
          _retryOnResume = false;
          _serverKnown = known;
          if (!known) _lastServerPro = false;
          final serverPro = _lastServerPro;
          // R1 e G22.7: o RevenueCat entra com a conta Pro ou com a que já comprou ou restaurou neste aparelho;
          // o Grátis que nunca comprou só quando age (comprar, restaurar, a tela técnica)
          if (serverPro || await _usedStore(userId)) {
            await _connect(userId, serverPro, life, loading: true);
            return;
          }
          if (_storeUser != null) {
            // a conta anterior sai do RevenueCat
            _storeUser = null;
            await _gateway.logOut();
          }
          if (!life.alive || _user != userId) return;
          state = ProReady(customer: ProCustomer.none, serverPro: serverPro);
          return;
        }
        if (!known) return;
        _serverKnown = true;
        final serverPro = summary.pro;
        final s = state;
        if (s is ProReady && s.serverPro != serverPro) {
          state = s.copyWith(serverPro: serverPro);
        }
        // virou Pro (comprou em outro aparelho): o estado da loja chega à tela
        if (serverPro && _storeUser != userId) {
          await _connect(userId, serverPro, life);
          return;
        }
        _maybeActivate();
      case GuestView():
        final connected = _storeUser != null;
        _user = null;
        _storeUser = null;
        _retryOnResume = false;
        _serverKnown = false;
        state = const ProUnavailable();
        if (connected) await _gateway.logOut();
      case AccountLoading():
        break;
    }
  }

  /// O RevenueCat com a conta [userId]: a 1ª vez configura; depois, `logIn` (R1).
  Future<void> _connect(
    String userId,
    bool serverPro,
    _Life life, {
    bool loading = false,
  }) async {
    if (loading) state = const ProLoading();
    final gateway = _gateway;
    final ProCustomer customer;
    if (_sdkConfigured) {
      customer = await gateway.logIn(userId);
    } else {
      await gateway.configure(appUserId: userId);
      _sdkConfigured = true;
      customer = await gateway.customer();
    }
    _storeUser = userId;
    if (!life.alive || _user != userId) return;
    _updates ??= gateway.customerUpdates().listen(_onCustomer);
    final s = state;
    state = s is ProReady
        ? s.copyWith(customer: customer)
        : ProReady(customer: customer, serverPro: serverPro);
    _maybeActivate();
  }

  /// A conta comprou ou restaurou uma assinatura neste aparelho: daqui em diante o RevenueCat entra com ela ao abrir o
  /// app. Fechar a folha, uma compra que falha ou um restaurar sem nada não marcam (revisão, I3).
  Future<void> _remember(String user) async {
    try {
      await _memory.markUsed(user);
    } on Object {
      // sem o banco do aparelho: o RevenueCat entra de novo na próxima ação
    }
  }

  /// Uma ação da pessoa precisa da loja: o RevenueCat entra com a conta agora.
  Future<void> _ensureStore(String user) async {
    if (_storeUser == user) return;
    final s = state;
    await _connect(user, s is ProReady && s.serverPro, _life);
  }

  void _onCustomer(ProCustomer c) {
    final s = state;
    // um aviso que não é da conta de agora (o SDK ainda com a anterior) não entra (revisão, I4)
    if (s is! ProReady || _user == null || _storeUser != _user) return;
    state = s.copyWith(customer: c);
    _maybeActivate();
  }

  /// A loja diz Pro agora: ativa e dentro do período (ou da carência). O `CustomerInfo` guardado pode estar velho
  /// (revisão, I2).
  bool _storeSaysPro(ProCustomer c) {
    if (!c.active) return false;
    final until = c.activeUntil;
    if (until == null) return true;
    final now = ref.read(clockProvider)().toUtc();
    final grace = c.graceUntil;
    return until.isAfter(now) || (grace != null && grace.isAfter(now));
  }

  /// R2: a loja diz Pro e o servidor (sabido) não.
  void _maybeActivate() {
    final s = state;
    if (_serverKnown &&
        s is ProReady &&
        !s.serverPro &&
        _storeSaysPro(s.customer)) {
      unawaited(activate());
    }
  }

  /// A ativação (R2): o "conferir agora" e o `my_entitlement` com recuo. Uma por vez e por conta.
  Future<void> activate() {
    final user = _user;
    if (user == null) return Future.value();
    final running = _activation;
    if (running != null && _activationUser == user) return running;
    final f = _activate(user, _life);
    _activation = f;
    _activationUser = user;
    unawaited(
      f.whenComplete(() {
        if (identical(_activation, f)) {
          _activation = null;
          _activationUser = null;
        }
      }),
    );
    return f;
  }

  Future<void> _activate(String user, _Life life) async {
    _activationRuns++;
    bool current() => life.alive && _user == user;
    final s = state;
    if (s is! ProReady || !_storeSaysPro(s.customer)) return;
    _retryOnResume = false;
    state = s.copyWith(activating: true, notice: () => null);
    final server = ref.read(proServerApiProvider)!;
    final sleep = ref.read(billingSleepProvider);
    var confirmed = false;
    var synced = false; // o "conferir agora" já respondeu
    var storeRechecked = false;

    Future<void> syncNow() async {
      try {
        confirmed = (await server.syncNow()).pro;
        synced = true;
      } on Object {
        // o RevenueCat fora do ar, a cota ou sem rede: a próxima volta do recuo tenta de novo (revisão, m2)
      }
    }

    // a loja ainda diz Pro? (o servidor respondeu que não; o CustomerInfo guardado pode estar velho — revisão, I2)
    Future<bool> stillPro() async {
      final now = state;
      if (now is ProReady && !_storeSaysPro(now.customer)) return false;
      if (!synced || storeRechecked || _storeUser != user) return true;
      storeRechecked = true;
      try {
        final c = await _gateway.customer();
        if (!current()) return true;
        _setCustomer(user, c);
        return _storeSaysPro(c);
      } on Object {
        return true; // sem a loja: segue o recuo
      }
    }

    void stopQuietly() {
      final r = state;
      if (r is ProReady) state = r.copyWith(activating: false);
    }

    await syncNow();
    for (final seconds in activationBackoff) {
      if (confirmed || !current()) break;
      if (!await stillPro()) {
        if (current()) stopQuietly();
        return;
      }
      if (!current()) break;
      await sleep(Duration(seconds: seconds));
      if (!current()) break;
      if (!synced) {
        await syncNow();
        if (synced) continue;
      }
      try {
        confirmed = (await server.current()).pro;
      } on Object {
        // sem rede: a próxima espera tenta de novo
      }
    }
    if (!current()) return;
    if (confirmed) {
      try {
        await ref.read(accountControllerProvider.notifier).refresh();
      } on Object {
        // o resumo relido falhou: a próxima mudança da conta traz o Pro
      }
      if (!current()) return;
      final r = state;
      if (r is ProReady) state = r.copyWith(activating: false, serverPro: true);
      return;
    }
    if (!await stillPro()) {
      if (current()) stopQuietly();
      return;
    }
    if (!current()) return;
    _retryOnResume = true;
    final r = state;
    if (r is ProReady) {
      state = r.copyWith(activating: false, notice: () => notConfirmedNotice);
    }
  }

  // ------------------------------------------------------------------ as ações (R3, R5, R6)

  /// Uma ação por vez, só com conta (R1) e a loja pronta, na fila com as mudanças da conta.
  Future<void> _action(Future<void> Function(String user) run) {
    final user = _user;
    if (_busy || user == null || state is! ProReady) return Future.value();
    _busy = true;
    final life = _life;
    return _serial(() async {
      try {
        if (!life.alive || _user != user || state is! ProReady) return;
        await run(user);
      } on Object catch (e, st) {
        FlutterError.reportError(
          FlutterErrorDetails(exception: e, stack: st, library: 'pro'),
        );
        _notice(user, failedNotice);
      } finally {
        _busy = false;
      }
    });
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
      await _ensureStore(user);
      switch (await _gateway.purchase(package.id)) {
        case Purchased(:final customer):
          await _remember(user);
          _setCustomer(user, customer);
          _maybeActivate();
        case PurchaseCancelled():
          break;
        case PurchasePending():
          await _remember(user);
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
    final runs = _activationRuns;
    try {
      await _ensureStore(user);
      final c = await _gateway.restore();
      _setCustomer(user, c);
      if (c.active) {
        await _remember(user);
        // D-236: confere no servidor mesmo com o resumo dizendo Pro — o período pode ter vencido e a renovação ainda
        // não ter chegado pelo webhook. Se a conexão com a loja de agora já conferiu, não repete.
        if (_activationRuns == runs) unawaited(activate());
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
  Future<List<ProPackage>> packages() {
    final user = _user;
    if (user == null || state is! ProReady) return Future.value(const []);
    return _serial(() async {
      if (_user != user) return const <ProPackage>[];
      await _ensureStore(user);
      return _gateway.packages();
    });
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

  /// O app voltou ao primeiro plano. Se a loja dizia Pro (ou a ativação não confirmou), a loja é relida — o
  /// `CustomerInfo` guardado pode estar velho (revisão, I2) — e, com ela ainda dizendo Pro: a ativação pendente tenta
  /// de novo (R2), ou o servidor é conferido uma vez e, se o período dele venceu (a renovação ainda não chegou pelo
  /// webhook), ativa (D-236).
  void resumed() {
    final user = _user;
    final s = state;
    if (user == null || s is! ProReady || _resumeCheck != null) return;
    if (!_retryOnResume && !s.customer.active) return;
    final check = _checkOnResume(user, _life);
    _resumeCheck = check;
    unawaited(check.whenComplete(() => _resumeCheck = null));
  }

  Future<void> _checkOnResume(String user, _Life life) async {
    bool current() => life.alive && _user == user;
    if (_storeUser != user) return;
    final ProCustomer c;
    try {
      c = await _gateway.customer();
    } on Object {
      return; // sem a loja: a próxima volta confere de novo
    }
    if (!current() || _storeUser != user) return;
    _setCustomer(user, c);
    if (!_storeSaysPro(c)) {
      _retryOnResume = false;
      return;
    }
    if (_retryOnResume) {
      unawaited(activate());
      return;
    }
    final ServerPro r;
    try {
      r = await ref.read(proServerApiProvider)!.current();
    } on Object {
      return; // sem rede: a próxima volta confere de novo
    }
    final s = state;
    if (!current() || s is! ProReady) return;
    _serverKnown = true;
    if (r.pro) {
      if (!s.serverPro) state = s.copyWith(serverPro: true);
      return;
    }
    state = s.copyWith(serverPro: false);
    _maybeActivate();
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
