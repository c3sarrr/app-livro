// G06 — relógio do aparelho medido pela hora do servidor (a RPC recusa HLC > 5 min no futuro).
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/clock/server_clock.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/personal_builders.dart';

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
    test('sem medida nesta sessão: vale só a correção para TRÁS guardada (aparelho adiantado ≥ 1 min)', () {
      var device = 100 * minuto;
      final c = ServerClock(deviceNowMs: () => device, offsetMs: -30 * 1000);
      expect(c.measured, isFalse);
      expect(c.nowMs(), device, reason: 'diferença pequena = rede');
      c.offsetMs = -10 * minuto; // aparelho 10 min adiantado
      expect(c.nowMs(), 90 * minuto);
      expect(c.deviceAheadMs, 10 * minuto);
      device += minuto;
      expect(c.nowMs(), 91 * minuto);
      // atrasado: sem medida nesta sessão não adianta (se o relógio já foi acertado, a versão iria
      // para o futuro e a RPC recusaria); a versão no passado é aceita
      c.offsetMs = 3 * minuto;
      expect(c.nowMs(), device);
      expect(c.deviceAheadMs, 0);
    });

    test('com medida: a hora vem da âncora monotônica — acertar o relógio do aparelho depois não muda nada', () {
      var device = 100 * minuto;
      var mono = 5000;
      final c = ServerClock(
        deviceNowMs: () => device,
        monotonicMs: () => mono,
        offsetMs: -10 * minuto, // guardada de outra sessão
      );
      c.record(3 * minuto); // servidor 3 min à frente (aparelho atrasado)
      expect(c.measured, isTrue);
      expect(c.offsetMs, 3 * minuto);
      expect(c.nowMs(), 103 * minuto);
      mono += 2 * minuto;
      device += 2 * minuto;
      expect(c.nowMs(), 105 * minuto);
      device = 500 * minuto; // a pessoa acertou (ou bagunçou) o relógio
      expect(c.nowMs(), 105 * minuto);
      mono += 1000;
      expect(c.nowMs(), 105 * minuto + 1000);
      expect(c.deviceNowMs(), 500 * minuto);
    });

    test('medida com diferença pequena (rede): a hora fica a do aparelho, ancorada no momento da medida', () {
      var device = 100 * minuto;
      var mono = 0;
      final c = ServerClock(deviceNowMs: () => device, monotonicMs: () => mono);
      c.record(-20 * 1000);
      expect(c.measured, isTrue);
      expect(c.offsetMs, -20 * 1000);
      expect(c.deviceAheadMs, 20 * 1000);
      expect(c.nowMs(), 100 * minuto, reason: 'sem correção');
      mono += 5;
      device = 300 * minuto; // relógio mexido depois da medida
      expect(c.nowMs(), 100 * minuto + 5);
    });

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

    test('linha com versão muito no futuro: a versão nova dela é maior, mas o relógio do aparelho não vai junto', () async {
      final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
      addTearDown(db.close);
      const agora = 1789945200000;
      final v = await LocalVersioning.open(
        db,
        deviceId: 'aparelhoA',
        nowMs: () => agora,
      );
      final longe = Hlc(agora + 60 * minuto, 7, 'aparelhoB');
      final livro = livroTeste(1);
      await UserBooksDao(db)
          .upsert(livro.copyWith(meta: livro.meta.copyWith(version: longe)));
      final id = livro.id;
      final daLinha = await v.next('user_books', id);
      expect(daLinha > longe, isTrue, reason: 'LWW da linha preservado');
      final outra = await v.next('user_books', 'nao-existe');
      expect(outra.ms, agora, reason: 'as outras escritas seguem no presente');
      expect(
        Hlc.parse((await KvDao(db).get(LocalVersioning.lastHlcKey))!).ms,
        agora,
        reason: 'o relógio guardado não foi para o futuro',
      );
    });
  });
}
