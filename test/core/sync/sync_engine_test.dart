// G06.2 — modo Pro ⇄ Grátis e troca de dono: virar Pro reenfileira tudo e conecta (com progresso);
// perder o Pro (servidor, consulta ou fim previsto sem confirmação) desconecta SEM apagar nada;
// voltar reenfileira; trocar de dono esvazia a fila antes de mexer nos dados.
import 'dart:async';

import 'package:app_leitura/core/data/clock/server_clock.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/local_sql.dart';
import 'package:app_leitura/core/sync/booknest_connector.dart';
import 'package:app_leitura/core/sync/sync_backend.dart';
import 'package:app_leitura/core/sync/sync_engine.dart';
import 'package:app_leitura/core/sync/sync_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powersync/powersync.dart'
    show PowerSyncBackendConnector, PowerSyncDatabase;

import '../../support/personal_builders.dart';
import 'support/sync_fakes.dart';

const int minuto = 60 * 1000;

/// Conexão que não vai à rede: grava as chamadas e limpa a fila de verdade.
final class FakeConnection implements SyncConnection {
  FakeConnection(this._ps);

  final PowerSyncDatabase _ps;
  final List<String> chamadas = [];
  final status = StreamController<LinkStatus>.broadcast(sync: true);
  PowerSyncBackendConnector? conector;

  @override
  Future<void> connect(PowerSyncBackendConnector connector) async {
    chamadas.add('conectar');
    conector = connector;
  }

  @override
  Future<void> disconnectAndClear() async {
    chamadas.add('desconectar_e_limpar');
    conector = null;
    await _ps.disconnectAndClear(clearLocal: false);
  }

  @override
  Future<void> disconnect() async {
    chamadas.add('desconectar');
    conector = null;
  }

  @override
  Stream<LinkStatus> get statusStream => status.stream;
}

/// Timer que só dispara quando o teste manda.
final class TimerTeste implements Timer {
  TimerTeste(this.duracao, this.f);
  final Duration duracao;
  final void Function() f;
  bool cancelado = false;

  @override
  void cancel() => cancelado = true;

  @override
  bool get isActive => !cancelado;

  @override
  int get tick => 0;
}

void main() {
  late DbTeste t;
  late FakeSyncBackend servidor;
  late FakeConnection conexao;
  late ServerClock relogio;
  late List<TimerTeste> timers;
  late SyncEngine motor;
  late List<SyncState> estados;
  const aparelho = 1789945200000;

  setUp(() async {
    t = await DbTeste.abrir();
    servidor = FakeSyncBackend(userId: usuarioTeste);
    conexao = FakeConnection(t.ps);
    relogio = ServerClock(deviceNowMs: () => aparelho);
    timers = [];
    motor = SyncEngine(
      connection: conexao,
      store: SyncStore(t.db),
      backend: servidor,
      endpoint: 'http://powersync.teste',
      clock: relogio,
      backoffFor: (_) => Duration.zero,
      timer: (d, f) {
        final x = TimerTeste(d, f);
        timers.add(x);
        return x;
      },
    );
    estados = [];
    motor.states.listen(estados.add);
    await KvDao(t.db).set(activeOwnerKey, usuarioTeste);
  });
  tearDown(() async {
    await motor.dispose();
    await t.fechar();
  });

  Future<void> livros(int n) async {
    for (var i = 1; i <= n; i++) {
      await UserBooksDao(t.db).upsert(livroTeste(i));
    }
  }

  Future<bool> modoPro() async =>
      await KvDao(t.db).get(syncModeKey) == syncModePro;

  BookNestConnector conector() => conexao.conector! as BookNestConnector;

  test('virar Pro: reenfileira tudo do dono, conecta uma vez e mostra o progresso do envio', () async {
    await livros(4);
    expect(await t.fila(), 0, reason: 'no Grátis a fila não cresce');
    await motor.onAccountConfirmed(usuarioTeste, pro: true);
    expect(await modoPro(), isTrue);
    expect(await t.fila(), 4);
    expect(conexao.chamadas, ['conectar']);
    expect(motor.state.pro, isTrue);
    expect(motor.state.uploadTotal, 4);
    expect(motor.state.uploadProgress, 0);

    await conector().uploadData(t.ps);
    await motor.settled();
    expect(motor.state.pending, 0);
    expect(motor.state.uploadTotal, isNull, reason: 'terminou o envio inicial');

    await motor.onAccountConfirmed(usuarioTeste, pro: true);
    expect(conexao.chamadas, ['conectar'], reason: 'já conectado: nada muda');
  });

  test('o servidor diz que não é mais Pro: desconecta, volta ao Grátis e NADA local é apagado', () async {
    await livros(3);
    await motor.onAccountConfirmed(usuarioTeste, pro: true);
    await motor.onAccountConfirmed(usuarioTeste, pro: false);
    expect(conexao.chamadas, ['conectar', 'desconectar_e_limpar']);
    expect(await modoPro(), isFalse);
    expect(await t.fila(), 0);
    expect(await t.conta('SELECT count(*) FROM user_books'), 3);
    expect(motor.state.proLost, isTrue);
    expect(motor.state.pro, isFalse);
    await UserBooksDao(t.db).upsert(livroTeste(9));
    expect(await t.fila(), 0, reason: 'Grátis: escrever não enche a fila');

    // voltar ao Pro (antes ou depois do purge): reenfileira tudo de novo
    await motor.onAccountConfirmed(usuarioTeste, pro: true);
    expect(await t.fila(), 4);
    expect(motor.state.proLost, isFalse);
  });

  test(
    'pro_required no upload: o conector avisa e o motor desliga sem apagar',
    () async {
      await livros(2);
      await motor.onAccountConfirmed(usuarioTeste, pro: true);
      servidor.falhasDaRpc.add(const ProRequired());
      await expectLater(
        conector().uploadData(t.ps),
        throwsA(isA<ProRequired>()),
      );
      await motor.settled();
      expect(await modoPro(), isFalse);
      expect(conexao.chamadas.last, 'desconectar_e_limpar');
      expect(await t.conta('SELECT count(*) FROM user_books'), 2);
    },
  );

  test('credencial pedida e o servidor diz que não é Pro: desliga', () async {
    await motor.onAccountConfirmed(usuarioTeste, pro: true);
    servidor.entitlementAtual = const Entitlement(
      pro: false,
      activeUntil: null,
      serverTimeMs: null,
    );
    expect(await conector().fetchCredentials(), isNull);
    await motor.settled();
    expect(await modoPro(), isFalse);
  });

  test('trocar de dono: desconecta e esvazia a fila ANTES; as linhas ficam; sem aviso de Pro perdido', () async {
    await livros(2);
    await motor.onAccountConfirmed(usuarioTeste, pro: true);
    await motor.beforeOwnerChange();
    expect(conexao.chamadas, ['conectar', 'desconectar_e_limpar']);
    expect(await t.fila(), 0);
    expect(await modoPro(), isFalse);
    expect(await t.conta('SELECT count(*) FROM user_books'), 2);
    expect(motor.state.proLost, isFalse);
  });

  test('app reaberto: a mesma conta no Pro reconecta sem esperar o servidor; no Grátis, não', () async {
    await motor.resume(usuarioTeste);
    expect(conexao.chamadas, isEmpty);
    await t.modoPro(usuarioTeste);
    await motor.resume('outra-conta');
    expect(conexao.chamadas, isEmpty);
    await motor.resume(usuarioTeste);
    expect(conexao.chamadas, ['conectar']);
  });

  group('hora do servidor e fim previsto do Pro', () {
    Entitlement pro({required int servidorMs, DateTime? ate}) =>
        Entitlement(pro: true, activeUntil: ate, serverTimeMs: servidorMs);

    test(
      'aparelho 10 min adiantado: a defasagem é guardada e aparece no estado',
      () async {
        await motor.onAccountConfirmed(usuarioTeste, pro: true);
        servidor.entitlementAtual = pro(servidorMs: aparelho - 10 * minuto);
        await conector().fetchCredentials();
        await motor.settled();
        expect(relogio.deviceAheadMs, closeTo(10 * minuto, 1000));
        expect(motor.state.deviceAheadMs, relogio.deviceAheadMs);
        expect(
          int.parse((await KvDao(t.db).get(ServerClock.offsetKey))!),
          relogio.offsetMs,
        );
        expect(
          (relogio.nowMs() - (aparelho - 10 * minuto)).abs() < 1000,
          isTrue,
        );
      },
    );

    test('chegou o fim previsto: renovado → continua; sem resposta → vale o previsto (Grátis)', () async {
      await motor.onAccountConfirmed(usuarioTeste, pro: true);
      final fim = DateTime.fromMillisecondsSinceEpoch(
        aparelho + 30 * minuto,
        isUtc: true,
      );
      servidor.entitlementAtual = pro(servidorMs: aparelho, ate: fim);
      await conector().fetchCredentials();
      final t1 = timers.last;
      expect(t1.duracao, const Duration(minutes: 30, seconds: 1));

      // renovou: a checagem confirma e agenda o novo fim
      servidor.entitlementAtual = pro(
        servidorMs: aparelho + 30 * minuto,
        ate: fim.add(const Duration(days: 30)),
      );
      t1.f();
      await motor.settled();
      expect(await modoPro(), isTrue);
      final t2 = timers.last;
      expect(t2, isNot(same(t1)));

      // no fim seguinte, sem internet: vale o previsto
      servidor.falhasDoPro.add(const SyncTransient('rede'));
      t2.f();
      await motor.settled();
      expect(await modoPro(), isFalse);
      expect(motor.state.proLost, isTrue);
    });

    test('Pro com versão no futuro recusada: volta à fila quando a hora do servidor alcança', () async {
      await motor.onAccountConfirmed(usuarioTeste, pro: true);
      await conector().uploadData(t.ps);
      final futuro = DateTime.fromMillisecondsSinceEpoch(
        aparelho + 10 * minuto,
        isUtc: true,
      );
      await UserBooksDao(t.db)
          .upsert(livroTeste(1).copyWith(meta: metaTeste(em: futuro)));
      servidor.recusar[idTeste(1)] = ('invalid_hlc', '22023');
      await conector().uploadData(t.ps);
      servidor.recusar.clear();
      await motor.settled();
      expect(await t.fila(), 0);
      servidor.entitlementAtual = pro(servidorMs: aparelho + 6 * minuto);
      await conector().fetchCredentials();
      await motor.settled();
      expect(await t.fila(), 1);
    });
  });

  test('estado do link: sincronizando, sincronizado, sem conexão', () async {
    await motor.onAccountConfirmed(usuarioTeste, pro: true);
    conexao.status.add(const LinkStatus(connected: true, downloading: true));
    expect(motor.state.phase, SyncPhase.syncing);
    final quando = DateTime.utc(2026, 10, 4, 12);
    conexao.status.add(LinkStatus(connected: true, lastSyncedAt: quando));
    expect(motor.state.phase, SyncPhase.synced);
    expect(motor.state.lastSyncedAt, quando);
    conexao.status.add(const LinkStatus());
    expect(motor.state.phase, SyncPhase.offline);
    await motor.settled();
  });
}
