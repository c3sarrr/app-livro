// G21.5/G21.6 — o social se atualiza sozinho (D-225): ao abrir o app, ao voltar a ele e ao entrar na conta, os meus
// clubes (o ticket) e o sininho; e, uma vez por dia, os números do perfil (R10). Só com a conta confirmada pelo
// servidor (o que era do convidado já passou para ela). Sem conta, nada. Sem rede, o cache fica (a Início mostra o
// último dado). A conta trocou no meio de uma rodada: a nova ganha a sua logo depois.
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'clubs_providers.dart';
import 'stats_provider.dart';

class SocialAutoSync extends ConsumerStatefulWidget {
  const SocialAutoSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SocialAutoSync> createState() => _SocialAutoSyncState();
}

class _SocialAutoSyncState extends ConsumerState<SocialAutoSync> {
  AppLifecycleListener? _life;
  Future<void>? _running;
  bool _again = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_run()));
    _life = AppLifecycleListener(onResume: () => unawaited(_run()));
    // entrar na conta (ou trocar de conta) também atualiza
    ref.listenManual(socialConfirmedOwnerProvider, (prev, next) {
      if (next != null && next != prev) unawaited(_run());
    });
  }

  /// Uma rodada por vez; um pedido no meio dela (voltar ao app, trocar de conta) vira uma rodada logo depois.
  Future<void> _run() {
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    return _running = _loop().whenComplete(() => _running = null);
  }

  Future<void> _loop() async {
    do {
      _again = false;
      await _refresh();
    } while (_again && mounted);
  }

  Future<void> _refresh() async {
    final owner = ref.read(socialConfirmedOwnerProvider);
    if (owner == null) return;
    try {
      await ref.read(clubsSyncProvider)?.refresh(owner);
      await ref.read(statsPublisherProvider)?.publishIfDue(owner);
    } on Object catch (e, st) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: st, library: 'social'),
      );
    }
  }

  @override
  void dispose() {
    _life?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
