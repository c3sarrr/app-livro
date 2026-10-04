// G06 — relógio do aparelho medido pela hora do servidor (a RPC recusa HLC > 5 min no futuro).
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/clock/server_clock.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const int minuto = 60 * 1000;

void main() {
  group('measureClockOffset', () {
    test('servidor − meio da ida e volta', () {
      expect(
        measureClockOffset(
          sentAtMs: 1000,
          receivedAtMs: 1200,
          serverTimeMs: 1100 - 10 * minuto,
        ),
        -10 * minuto,
      );
      expect(
        measureClockOffset(
          sentAtMs: 1000,
          receivedAtMs: 1000,
          serverTimeMs: 4000,
        ),
        3000,
      );
    });

    test(
      'ida e volta longa demais (ou relógio que voltou no meio) não vale',
      () {
        expect(
          measureClockOffset(
            sentAtMs: 0,
            receivedAtMs: 10001,
            serverTimeMs: 5000,
          ),
          isNull,
        );
        expect(
          measureClockOffset(sentAtMs: 10, receivedAtMs: 5, serverTimeMs: 5),
          isNull,
        );
      },
    );
  });

  group('ServerClock', () {
    test(
      'diferença pequena (rede) é ignorada; grande corrige o relógio dos HLC',
      () {
        var device = 100 * minuto;
        final c = ServerClock(deviceNowMs: () => device, offsetMs: -30 * 1000);
        expect(c.nowMs(), device);
        c.offsetMs = -10 * minuto; // aparelho 10 min adiantado
        expect(c.nowMs(), 90 * minuto);
        expect(c.deviceAheadMs, 10 * minuto);
        device += minuto;
        expect(c.nowMs(), 91 * minuto);
        c.offsetMs =
            3 * minuto; // atrasado: corrige também, mas não "adiantado"
        expect(c.nowMs(), device + 3 * minuto);
        expect(c.deviceAheadMs, 0);
      },
    );

    test('LocalVersioning com o relógio corrigido: versão nova fica dentro da janela da RPC', () async {
      final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
      addTearDown(db.close);
      const servidor = 1789945200000;
      final aparelho = servidor + 10 * minuto; // adiantado 10 min
      final c = ServerClock(
        deviceNowMs: () => aparelho,
        offsetMs: servidor - aparelho,
      );
      final v = await LocalVersioning.open(
        db,
        deviceId: 'aparelhoA',
        nowMs: c.nowMs,
      );
      final h = v.clock.send();
      expect(h.ms, servidor);
      expect(h.ms <= servidor + LocalVersioning.maxFutureMs, isTrue);
      // sem a correção a RPC recusaria (invalid_hlc)
      final semCorrecao = HlcClock(
        deviceId: 'aparelhoA',
        nowMs: () => aparelho,
      ).send();
      expect(semCorrecao.ms > servidor + LocalVersioning.maxFutureMs, isTrue);
    });
  });
}
