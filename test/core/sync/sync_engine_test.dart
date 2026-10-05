// G06.2 — modo Pro ⇄ Grátis e troca de dono: virar Pro reenfileira tudo e conecta (com progresso);
// perder o Pro (servidor, consulta ou fim previsto sem confirmação) desconecta SEM apagar nada;
// voltar reenfileira; trocar de dono esvazia a fila antes de mexer nos dados.
import 'dart:async';

import 'package:app_leitura/core/data/clock/server_clock.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/local_sql.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
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

  /// O modo gravado no aparelho na hora de limpar a fila (o Grátis tem de vir ANTES).
  final List<String?> modoAoLimpar = [];
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
    modoAoLimpar.add(
      (await _ps.getOptional('SELECT value FROM kv WHERE key = ?', [
            syncModeKey,
          ]))?['value']
          as String?,
    );
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

  test(
    'conta Grátis confirmada: não conecta e escrever não enche a fila',
    () async {
      await motor.onAccountConfirmed(usuarioTeste, pro: false);
      await livros(2);
      expect(conexao.chamadas, isEmpty);
      expect(await modoPro(), isFalse);
      expect(await t.fila(), 0);
      expect(motor.state.pro, isFalse);
    },
  );

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

  group('revisão da G06', () {
    test('perder o Pro: o modo Grátis é gravado ANTES de limpar a fila (um corte no meio nunca deixa Pro com a fila vazia)', () async {
      await livros(1);
      await motor.onAccountConfirmed(usuarioTeste, pro: true);
      await motor.onAccountConfirmed(usuarioTeste, pro: false);
      expect(conexao.modoAoLimpar, [syncModeFree]);
      await motor.onAccountConfirmed(usuarioTeste, pro: true);
      await motor.beforeOwnerChange();
      expect(conexao.modoAoLimpar, [syncModeFree, syncModeFree]);
    });

    test('a confirmação chega depois que outra conta entrou: não liga o Pro da anterior', () async {
      await livros(2);
      servidor.userId = 'outra-conta';
      await motor.onAccountConfirmed(usuarioTeste, pro: true);
      await motor.resume(usuarioTeste);
      expect(conexao.chamadas, isEmpty);
      expect(await modoPro(), isFalse);
      expect(await t.fila(), 0);
    });

    test('perdeu o Pro antes de a tarefa atrasada do lote rodar: ela não mexe em nada', () async {
      await livros(2);
      await t.ps.execute(
        'UPDATE user_books SET content_sha256 = ? WHERE id = ?',
        [shaDoLivroTeste(1), idTeste(2)],
      );
      await motor.onAccountConfirmed(usuarioTeste, pro: true);
      const dup = SyncRejection(
        table: 'user_books',
        id: '0199a7c4-2f00-7a10-8b20-000000000002',
        error: 'duplicate key value',
        code: '23505',
      );
      await SyncStore(t.db).recordRejections(
        [dup],
        [
          {'op': 'PUT', 'table': dup.table, 'id': dup.id, 'hlc': 'v'},
        ],
      );
      // a perda do Pro entra na fila antes da tarefa do lote
      final perder = motor.onAccountConfirmed(usuarioTeste, pro: false);
      motor.batchUploaded(
        const ApplyResult(applied: 0, skipped: 0, rejected: [dup]),
      );
      await perder;
      await motor.settled();
      expect(await modoPro(), isFalse);
      expect(
        await t.conta('SELECT count(*) FROM user_books'),
        2,
        reason: 'nenhuma junção fora do Pro',
      );
    });

    test('hora do servidor medida: versão no futuro recusada é reemitida na hora (não espera)', () async {
      final t2 = await DbTeste.abrir();
      addTearDown(t2.fechar);
      final c2 = FakeConnection(t2.ps);
      // aparelho 10 min adiantado
      final rel = ServerClock(deviceNowMs: () => aparelho);
      final m2 = SyncEngine(
        connection: c2,
        store: SyncStore(
          t2.db,
          versioning: await LocalVersioning.open(
            t2.db,
            deviceId: 'aparelhoA',
            nowMs: rel.nowMs,
          ),
        ),
        backend: servidor,
        endpoint: 'http://powersync.teste',
        clock: rel,
        backoffFor: (_) => Duration.zero,
        timer: (d, f) => TimerTeste(d, f),
      );
      addTearDown(m2.dispose);
      await KvDao(t2.db).set(activeOwnerKey, usuarioTeste);
      await UserBooksDao(t2.db).upsert(
        livroTeste(1).copyWith(
          meta: metaTeste(
            em: DateTime.fromMillisecondsSinceEpoch(aparelho, isUtc: true),
          ),
        ),
      );
      await m2.onAccountConfirmed(usuarioTeste, pro: true);
      final con = c2.conector! as BookNestConnector;
      servidor.recusar[idTeste(1)] = ('invalid_hlc', '22023');
      await con.uploadData(t2.ps);
      servidor.recusar.clear();
      await m2.settled();
      expect(await t2.fila(), 0);

      servidor.entitlementAtual = const Entitlement(
        pro: true,
        activeUntil: null,
        serverTimeMs: aparelho - 10 * minuto,
      );
      await con.fetchCredentials();
      await m2.settled();
      expect(await t2.fila(), 1);
      final v = (await UserBooksDao(t2.db).byId(idTeste(1)))!.meta.version;
      expect((v.ms - (aparelho - 10 * minuto)).abs() < 2000, isTrue);
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
