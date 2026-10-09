// G22.4 — o gancho da Início para os gatilhos do paywall (R7, D-230). Envolve a Início na rota, sem mudar a tela:
// - uma vez por montagem, com a conta Grátis, avalia os marcos;
// - ao ENTRAR na conta (do convidado, ou trocando de conta), avalia o 2º aparelho. Abrir o app com a sessão guardada
//   não é entrar;
// - na depuração abre a tela técnica com o motivo; no build de produção não faz nada, nem consulta o motor.
// Nunca no leitor nem na 25: o gancho só envolve a Início.
import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../account/application/account_controller.dart';
import '../../account/domain/account_summary.dart';
import '../../home/application/home_providers.dart' show clockProvider;
import '../application/billing_controller.dart';
import '../application/paywall_triggers.dart';
import '../domain/billing_rules.dart';

/// Os gatilhos aparecem (só a depuração até o paywall ter design — D-230).
final paywallDebugProvider = Provider<bool>((ref) => kDebugMode);

/// Mostra o gatilho: a tela técnica com o motivo.
final paywallPresenterProvider =
    Provider<void Function(BuildContext context, PaywallReason reason)>(
      (ref) =>
          (context, reason) => unawaited(
            GoRouter.of(context).push(AppRoutes.proTecnicoCom(reason.name)),
          ),
    );

class PaywallHomeHook extends ConsumerStatefulWidget {
  const PaywallHomeHook({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PaywallHomeHook> createState() => _PaywallHomeHookState();
}

class _PaywallHomeHookState extends ConsumerState<PaywallHomeHook> {
  bool _homeChecked = false;

  /// A conta que acabou de entrar, esperando o resumo do servidor.
  String? _signingIn;

  /// Uma avaliação por vez (a Início e a entrada podem chegar juntas).
  Future<void> _queue = Future.value();

  @override
  void initState() {
    super.initState();
    if (!ref.read(paywallDebugProvider)) return;
    ref.listenManual<AccountView>(accountControllerProvider, _onAccount);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _onAccount(null, ref.read(accountControllerProvider)),
    );
  }

  void _onAccount(AccountView? prev, AccountView next) {
    if (!mounted || next is! MemberView) return;
    if (prev is GuestView ||
        (prev is MemberView && prev.userId != next.userId)) {
      _signingIn = next.userId;
    }
    final summary = next.summary;
    if (summary == null) return;
    final owner = next.userId;
    if (!_homeChecked) {
      _homeChecked = true;
      _enqueue(() => _home(owner, summary));
    }
    if (_signingIn == owner) {
      _signingIn = null;
      _enqueue(() => _signedIn(owner, summary));
    }
  }

  void _enqueue(Future<void> Function() run) {
    _queue = _queue.then((_) async {
      try {
        await run();
      } on Object catch (e, st) {
        FlutterError.reportError(
          FlutterErrorDetails(exception: e, stack: st, library: 'pro'),
        );
      }
    });
  }

  /// Pro pelo servidor ou pela loja ainda válida sem rede (R8).
  bool _pro(AccountSummary summary) {
    if (summary.pro) return true;
    final b = ref.read(billingControllerProvider);
    return b is ProReady &&
        localProValid(b.customer, ref.read(clockProvider)().toUtc());
  }

  Future<void> _home(String owner, AccountSummary summary) async {
    if (_pro(summary)) return;
    final n = await ref.read(paywallCountsProvider)(owner);
    if (!mounted) return;
    final reason = await ref
        .read(paywallTriggersProvider)
        .onHomeShown(
          owner,
          books: n.books,
          highlights: n.highlights,
          streakDays: n.streakDays,
          pro: false,
        );
    if (reason != null) await _present(owner, reason);
  }

  Future<void> _signedIn(String owner, AccountSummary summary) async {
    final reason = await ref
        .read(paywallTriggersProvider)
        .onSignedIn(
          owner,
          otherSessions: summary.otherSessions,
          pro: _pro(summary),
        );
    if (reason != null) await _present(owner, reason);
  }

  Future<void> _present(String owner, PaywallReason reason) async {
    if (!mounted) return;
    await ref.read(paywallTriggersProvider).shown(owner, reason);
    if (!mounted) return;
    ref.read(paywallPresenterProvider)(context, reason);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
