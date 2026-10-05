// G06.5 — o texto do indicador discreto da sincronização (D-21) para cada estado.
import 'package:app_leitura/core/sync/sync_engine.dart';
import 'package:app_leitura/features/account/presentation/sync_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Grátis: nada; Pro encerrado: avisa que os dados ficaram no aparelho',
    () {
      expect(syncIndicatorText(const SyncState()), isNull);
      expect(
        syncIndicatorText(const SyncState(proLost: true)),
        'O Pro terminou: a sincronização parou e seus dados continuam neste aparelho.',
      );
    },
  );

  test('virar Pro: progresso do envio inicial', () {
    expect(
      syncIndicatorText(
        const SyncState(
          pro: true,
          phase: SyncPhase.syncing,
          pending: 750,
          uploadTotal: 1000,
        ),
      ),
      'Enviando sua biblioteca para a nuvem… 25%',
    );
  });

  test('fases do link', () {
    String? t(SyncPhase p, [int pend = 0]) =>
        syncIndicatorText(SyncState(pro: true, phase: p, pending: pend));
    expect(t(SyncPhase.off), isNull);
    expect(t(SyncPhase.connecting), 'Conectando à nuvem…');
    expect(t(SyncPhase.syncing), 'Sincronizando…');
    expect(t(SyncPhase.synced), 'Sincronizado');
    expect(t(SyncPhase.synced, 2), 'Sincronizando…');
    expect(t(SyncPhase.offline), 'Sem conexão com a nuvem.');
    expect(
      t(SyncPhase.offline, 1),
      'Sem conexão: 1 alteração esperando para ir à nuvem.',
    );
  });

  test('relógio adiantado (≥ 5 min) vem primeiro', () {
    expect(
      syncIndicatorText(
        const SyncState(
          pro: true,
          phase: SyncPhase.synced,
          deviceAheadMs: 10 * 60 * 1000,
        ),
      ),
      'O relógio do aparelho está 10 min adiantado. Acerte a hora nos ajustes do sistema.',
    );
    expect(
      syncIndicatorText(
        const SyncState(
          pro: true,
          phase: SyncPhase.synced,
          deviceAheadMs: 4 * 60 * 1000,
        ),
      ),
      'Sincronizado',
    );
  });
}
