// Indicador discreto da sincronização do Pro (D-21: sem design ainda — uma linha de texto secundário
// no bloco da conta). Sem sincronização (Grátis) não aparece nada, a não ser o aviso de Pro encerrado.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/clock/server_clock.dart';
import '../../../core/sync/sync_engine.dart';
import '../../../core/sync/sync_providers.dart';
import 'account_widgets.dart';

/// O texto do indicador para o estado (null = nada a mostrar).
String? syncIndicatorText(SyncState s) {
  if (s.deviceAheadMs >= ServerClock.aheadWarningMs) {
    final min = (s.deviceAheadMs / 60000).round();
    return 'O relógio do aparelho está $min min adiantado. Acerte a hora nos ajustes do sistema.';
  }
  if (!s.pro) {
    return s.proLost
        ? 'O Pro terminou: a sincronização parou e seus dados continuam neste aparelho.'
        : null;
  }
  final progresso = s.uploadProgress;
  if (progresso != null && s.pending > 0) {
    return 'Enviando sua biblioteca para a nuvem… ${(progresso * 100).floor()}%';
  }
  final itens = s.pending == 1 ? '1 alteração' : '${s.pending} alterações';
  return switch (s.phase) {
    SyncPhase.off => null,
    SyncPhase.connecting => 'Conectando à nuvem…',
    SyncPhase.syncing => 'Sincronizando…',
    SyncPhase.synced => s.pending > 0 ? 'Sincronizando…' : 'Sincronizado',
    SyncPhase.offline =>
      s.pending > 0
          ? 'Sem conexão: $itens esperando para ir à nuvem.'
          : 'Sem conexão com a nuvem.',
  };
}

class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(syncStateProvider).value;
    final t = s == null ? null : syncIndicatorText(s);
    if (t == null) return const SizedBox.shrink();
    return Semantics(liveRegion: true, child: AccountText(t, muted: true));
  }
}
