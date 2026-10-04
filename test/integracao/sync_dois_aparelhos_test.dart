// G06.3 — sincronização do Pro de ponta a ponta: dois aparelhos simulados (dois bancos do PowerSync
// no mesmo processo), o serviço PowerSync LOCAL (D-71) e o Supabase local. Pelo motor real do app
// (SyncEngine → BookNestConnector → sync_apply_changes / Sync Streams).
//
//   virar Pro sobe tudo → o 2º aparelho baixa igual · offline com edições cruzadas e apagar × editar →
//   estados iguais · relógio 10 min adiantado (versão corrigida aceita; HLC cru recusado) · perder o
//   Pro não apaga nada (nem no aparelho que recebe a remoção do bucket) · voltar sobe tudo de novo.
//
// Roda só quando pedido (Supabase local + `bash tools/powersync/subir_local.sh` no WSL):
//   $env:BOOKNEST_SUPABASE_URL = 'http://127.0.0.1:54321'
//   $env:BOOKNEST_SUPABASE_PUBLISHABLE_KEY = '<a chave pública LOCAL de `supabase status`>'
//   flutter test --tags integracao test/integracao/sync_dois_aparelhos_test.dart
@Tags(['integracao'])
library;

import 'dart:convert';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/clock/server_clock.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/database/local_sql.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/core/sync/sync_backend.dart';
import 'package:app_leitura/core/sync/sync_engine.dart';
import 'package:app_leitura/core/sync/sync_store.dart';
import 'package:app_leitura/features/account/data/secure_session_storage.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/highlight_label.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powersync/powersync.dart' show SyncOptions;
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthClientOptions, OtpType, SupabaseClient;

import '../core/sync/support/sync_fakes.dart' show DbTeste;
import '../features/account/support/fake_backend.dart' show MemorySecureStore;
import '../support/personal_builders.dart';
import 'support/local.dart';

const int minuto = 60 * 1000;
const SyncOptions opcoes = SyncOptions(
  retryDelay: Duration(milliseconds: 500),
  crudThrottleTime: Duration(milliseconds: 50),
);

SupabaseClient novoCliente() => SupabaseClient(
  supabaseUrlLocal!,
  supabaseChaveLocal!,
  authOptions: AuthClientOptions(
    autoRefreshToken: false,
    pkceAsyncStorage: SecurePkceStorage(MemorySecureStore()),
  ),
);

/// Um aparelho: o banco, o motor real e o relógio (que pode estar adiantado).
final class Aparelho {
  Aparelho._(this.nome, this.client, this.t, this.motor, this.relogio, this.v);

  static Future<Aparelho> abrir(
    String nome,
    SupabaseClient client, {
    int adiantadoMs = 0,
  }) async {
    final t = await DbTeste.abrir();
    final relogio = ServerClock(
      deviceNowMs: () => DateTime.now().millisecondsSinceEpoch + adiantadoMs,
    );
    final motor = SyncEngine(
      connection: PowerSyncConnection(t.ps, options: opcoes),
      store: SyncStore(t.db),
      backend: SupabaseSyncBackend(client),
      endpoint: powersyncUrlLocal,
      clock: relogio,
    );
    await KvDao(t.db).set(activeOwnerKey, client.auth.currentUser!.id);
    final v = await LocalVersioning.open(
      t.db,
      deviceId: nome,
      nowMs: relogio.nowMs,
    );
    return Aparelho._(nome, client, t, motor, relogio, v);
  }

  final String nome;
  final SupabaseClient client;
  final DbTeste t;
  final SyncEngine motor;
  final ServerClock relogio;
  final LocalVersioning v;

  String get uid => client.auth.currentUser!.id;

  /// Meta de uma edição local com a versão certa (receive da versão gravada antes do send).
  Future<RecordMeta> editado(
    RecordMeta m,
    String tabela,
    String id, {
    bool apagar = false,
  }) async {
    final h = await v.next(tabela, id);
    final em = DateTime.fromMillisecondsSinceEpoch(h.ms, isUtc: true);
    return apagar ? m.deleted(em, h) : m.edited(em, h);
  }

  Future<UserBook> livro(String id) async =>
      (await UserBooksDao(t.db).byId(id))!;

  /// Grifo ativo (para editar).
  Future<Annotation> grifo(String livro, String id) async =>
      (await AnnotationsDao(t.db).forBook(livro)).firstWhere((a) => a.id == id);

  /// A linha do grifo como está gravada (inclusive apagada).
  Future<Map<String, Object?>> linhaGrifo(String id) async =>
      Map.of(await t.ps.get('SELECT * FROM annotations WHERE id = ?', [id]));

  /// Tudo do dono, como o servidor vê (JSON normalizado; sem `_extras`).
  Future<Map<String, List<Map<String, Object?>>>> estado() async => {
    for (final tab in personalSyncColumns.keys)
      tab: [
        for (final r in await t.ps.getAll(
          'SELECT * FROM $tab WHERE user_id = ? ORDER BY id',
          [uid],
        ))
          {
            for (final e in r.entries)
              if (e.key != '_extras') e.key: _normal(e.value),
          },
      ],
  };

  static Object? _normal(Object? v) =>
      v is String && (v.startsWith('{') || v.startsWith('['))
      ? jsonDecode(v)
      : v;

  Future<void> desconectar() => t.ps.disconnect();

  Future<void> reconectar() =>
      t.ps.connect(connector: motor.connector!, options: opcoes);

  Future<void> fechar() async {
    await motor.dispose();
    await t.fechar();
  }
}

Future<void> esperar(
  String oque,
  Future<bool> Function() pronto, {
  Duration ate = const Duration(seconds: 60),
}) async {
  final fim = DateTime.now().add(ate);
  while (DateTime.now().isBefore(fim)) {
    if (await pronto()) return;
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  fail('não aconteceu em ${ate.inSeconds} s: $oque');
}

void main() {
  final pronto = supabaseUrlLocal != null && supabaseChaveLocal != null;
  late SupabaseClient clienteA;
  late SupabaseClient clienteB;
  late Aparelho a;
  late Aparelho b;
  late String uid;
  final abertos = <Aparelho>[];

  Future<void> pro(bool sim) => sqlLocal(
    sim
        ? '''
insert into billing.entitlements (user_id, entitlement, active_until) values ('$uid', 'pro', now() + interval '30 days')
  on conflict (user_id, entitlement) do update set active_until = excluded.active_until;
insert into billing.sync_access (user_id, granted) values ('$uid', true)
  on conflict (user_id) do update set granted = true, updated_at = now();'''
        : '''
update billing.entitlements set active_until = now() - interval '1 minute' where user_id = '$uid';
update billing.sync_access set granted = false, updated_at = now() where user_id = '$uid';''',
  );

  Future<int> noServidor(String tabela) async => int.parse(
    await sqlLocal(
      "select count(*) from personal.$tabela where user_id = '$uid'",
    ),
  );

  setUpAll(() async {
    if (!pronto) return;
    // contas de execuções anteriores (o id das linhas de teste é fixo e é chave no servidor)
    await sqlLocal(
      "delete from auth.users where email like 'g06-%@exemplo.test'",
    );
    final email =
        'g06-${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}@exemplo.test';
    clienteA = novoCliente();
    final antes = DateTime.now().toUtc().subtract(const Duration(seconds: 5));
    await clienteA.auth.signInWithOtp(email: email, shouldCreateUser: true);
    await clienteA.auth.verifyOTP(
      email: email,
      token: await codigoNoMailpit(email, depoisDe: antes),
      type: OtpType.email,
    );
    uid = clienteA.auth.currentUser!.id;
    // o 2º aparelho entra na mesma conta (sessão própria a partir da do 1º)
    clienteB = novoCliente();
    await clienteB.auth.setSession(clienteA.auth.currentSession!.refreshToken!);
    a = await Aparelho.abrir('aparelhoA', clienteA);
    b = await Aparelho.abrir('aparelhoB', clienteB);
    abertos.addAll([a, b]);
  });

  tearDownAll(() async {
    if (!pronto) return;
    for (final x in abertos) {
      await x.fechar();
    }
    await sqlLocal("delete from auth.users where id = '$uid'");
    await clienteA.dispose();
    await clienteB.dispose();
  });

  final pular = pronto
      ? false
      : 'defina BOOKNEST_SUPABASE_URL e BOOKNEST_SUPABASE_PUBLISHABLE_KEY';
  const tempo = Timeout(Duration(minutes: 3));

  test(
    'virar Pro sobe tudo do aparelho A; o B baixa e fica igual',
    () async {
      // A usou o app no Grátis: nada na fila, nada no servidor
      await UserBooksDao(a.t.db).upsert(livroTeste(1, dono: uid));
      await UserBooksDao(a.t.db).upsert(livroTeste(2, dono: uid));
      await UserBooksDao(a.t.db).upsert(livroTeste(3, dono: uid));
      await UserBooksDao(a.t.db)
          .upsert(livroTeste(4, dono: uid, apagado: true));
      final g10 = grifoTeste(10, livro: idTeste(1), dono: uid);
      await AnnotationsDao(a.t.db).upsert(g10);
      await AnnotationsDao(a.t.db)
          .upsert(grifoTeste(11, livro: idTeste(1), dono: uid));
      await BookmarksDao(a.t.db)
          .upsert(marcadorTeste(12, livro: idTeste(2), dono: uid));
      await ReadingSessionsDao(
        a.t.db,
      ).upsert(sessaoTeste(13, livro: idTeste(1), inicio: t0Teste, dono: uid));
      await ReadingPositionsDao(a.t.db)
          .upsert(posicaoTeste(idTeste(1), dono: uid));
      await ReaderSettingsDao(a.t.db).upsert(
        ReaderSettings(
          id: uid,
          meta: metaTeste(userId: uid),
        ),
      );
      await HighlightLabelsDao(a.t.db).upsert(
        HighlightLabel(
          id: idTeste(14),
          meta: metaTeste(userId: uid),
          color: '#FED170',
          label: 'lindo',
        ),
      );
      expect(await a.t.fila(), 0);
      expect(await noServidor('user_books'), 0);

      await pro(true);
      await a.motor.onAccountConfirmed(uid, pro: true);
      expect(a.motor.state.uploadTotal, 11);
      await esperar(
        'A sobe tudo',
        () async =>
            await a.t.fila() == 0 && await noServidor('user_books') == 4,
      );
      expect(await noServidor('annotations'), 2);
      expect(await noServidor('reading_sessions'), 1);
      expect(await noServidor('reader_settings'), 1);

      await b.motor.onAccountConfirmed(uid, pro: true);
      await esperar(
        'B baixa tudo e fica igual a A',
        () async =>
            jsonEncode(await b.estado()) == jsonEncode(await a.estado()),
      );
      expect((await b.estado())['user_books'], hasLength(4));
      await esperar(
        'B mostra "sincronizado"',
        () async => b.motor.state.phase == SyncPhase.synced,
      );
    },
    skip: pular,
    timeout: tempo,
  );

  test(
    'offline nos dois, edições cruzadas e apagar × editar → estados iguais (maior versão vence)',
    () async {
      await a.desconectar();
      await b.desconectar();

      // livros diferentes: as duas edições ficam
      final l1 = await a.livro(idTeste(1));
      await UserBooksDao(a.t.db).upsert(
        l1.copyWith(
          title: 'Editado em A',
          meta: await a.editado(l1.meta, 'user_books', l1.id),
        ),
      );
      final l2 = await b.livro(idTeste(2));
      await UserBooksDao(b.t.db).upsert(
        l2.copyWith(
          status: ShelfStatus.finished,
          meta: await b.editado(l2.meta, 'user_books', l2.id),
        ),
      );
      // o mesmo livro nos dois: a edição mais nova (B, depois) vence
      final l3a = await a.livro(idTeste(3));
      await UserBooksDao(a.t.db).upsert(
        l3a.copyWith(
          title: 'A mexeu',
          meta: await a.editado(l3a.meta, 'user_books', l3a.id),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final l3b = await b.livro(idTeste(3));
      await UserBooksDao(b.t.db).upsert(
        l3b.copyWith(
          title: 'B mexeu depois',
          meta: await b.editado(l3b.meta, 'user_books', l3b.id),
        ),
      );
      // grifo 10: B edita, A apaga DEPOIS → apagado nos dois
      final x = await b.grifo(idTeste(1), idTeste(10));
      await AnnotationsDao(b.t.db).upsert(
        x.copyWith(
          color: const Nullable('#C7B8FF'),
          meta: await b.editado(x.meta, 'annotations', x.id),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final xa = await a.grifo(idTeste(1), idTeste(10));
      await AnnotationsDao(a.t.db).upsert(
        xa.copyWith(
          meta: await a.editado(xa.meta, 'annotations', xa.id, apagar: true),
        ),
      );
      // grifo 11: A apaga, B edita DEPOIS → a edição vence (LWW da linha inteira)
      final y = await a.grifo(idTeste(1), idTeste(11));
      await AnnotationsDao(a.t.db).upsert(
        y.copyWith(
          meta: await a.editado(y.meta, 'annotations', y.id, apagar: true),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final yb = await b.grifo(idTeste(1), idTeste(11));
      await AnnotationsDao(b.t.db).upsert(
        yb.copyWith(
          color: const Nullable('#9BE3C5'),
          meta: await b.editado(yb.meta, 'annotations', yb.id),
        ),
      );
      expect(await a.t.fila(), 4);
      expect(await b.t.fila(), 4);

      await a.reconectar();
      await b.reconectar();
      await esperar(
        'os dois convergem',
        () async =>
            await a.t.fila() == 0 &&
            await b.t.fila() == 0 &&
            jsonEncode(await a.estado()) == jsonEncode(await b.estado()) &&
            (await a.livro(idTeste(2))).status == ShelfStatus.finished &&
            (await b.livro(idTeste(1))).title == 'Editado em A',
      );
      for (final x in [a, b]) {
        expect((await x.livro(idTeste(1))).title, 'Editado em A');
        expect((await x.livro(idTeste(2))).status, ShelfStatus.finished);
        expect((await x.livro(idTeste(3))).title, 'B mexeu depois');
        expect((await x.linhaGrifo(idTeste(10)))['deleted_at'], isNotNull);
        final y2 = await x.linhaGrifo(idTeste(11));
        expect(y2['deleted_at'], isNull);
        expect(y2['color'], '#9BE3C5');
      }
      expect(await a.t.conta('SELECT count(*) FROM sync_rejections'), 0);
      expect(await b.t.conta('SELECT count(*) FROM sync_rejections'), 0);
    },
    skip: pular,
    timeout: tempo,
  );

  test(
    'relógio 10 min adiantado: a versão sai corrigida e é aceita; HLC cru no futuro é recusado',
    () async {
      final c = await Aparelho.abrir(
        'aparelhoC',
        clienteA,
        adiantadoMs: 10 * minuto,
      );
      abertos.add(c);
      await c.motor.onAccountConfirmed(uid, pro: true);
      await esperar(
        'C baixa',
        () async => (await c.estado())['user_books']!.length == 4,
      );
      expect(c.relogio.deviceAheadMs, closeTo(10 * minuto, 5000));
      expect(c.motor.state.deviceAheadMs, c.relogio.deviceAheadMs);

      final l = await c.livro(idTeste(2));
      final m = await c.editado(l.meta, 'user_books', l.id);
      expect(
        m.version.ms <
            DateTime.now().millisecondsSinceEpoch + LocalVersioning.maxFutureMs,
        isTrue,
      );
      await UserBooksDao(c.t.db)
          .upsert(l.copyWith(rating: const Nullable(5), meta: m));
      await esperar(
        'A recebe a edição de C',
        () async => (await a.livro(idTeste(2))).rating == 5,
      );

      // sem a correção (HLC do relógio do aparelho): a RPC recusa e a linha fica no aparelho
      final l4 = await c.livro(idTeste(3));
      final cru = DateTime.now().toUtc().add(const Duration(minutes: 10));
      await UserBooksDao(c.t.db).upsert(
        l4.copyWith(
          title: 'versão no futuro',
          meta: l4.meta.edited(
            cru,
            Hlc(cru.millisecondsSinceEpoch, 0, 'aparelhoC'),
          ),
        ),
      );
      await esperar(
        'recusa invalid_hlc',
        () async =>
            await c.t.conta(
              "SELECT count(*) FROM sync_rejections WHERE reason = 'invalid_hlc'",
            ) ==
            1,
      );
      expect((await c.livro(idTeste(3))).title, 'versão no futuro');
      expect((await a.livro(idTeste(3))).title, 'B mexeu depois');
    },
    skip: pular,
    timeout: tempo,
  );

  test(
    'perder o Pro não apaga nada (nem no aparelho que recebe a remoção); voltar sobe tudo',
    () async {
      await pro(false);
      // A escreve: o servidor recusa (pro_required) → A volta ao Grátis sem apagar nada
      final l = await a.livro(idTeste(1));
      await UserBooksDao(a.t.db).upsert(
        l.copyWith(
          title: 'Escrito sem Pro',
          meta: await a.editado(l.meta, 'user_books', l.id),
        ),
      );
      await esperar('A desliga', () async => !a.motor.state.pro);
      expect(a.motor.state.proLost, isTrue);
      expect((await a.estado())['user_books'], hasLength(4));
      expect(await a.t.fila(), 0);

      // B continua conectado: o serviço tira o bucket — no aparelho, nada some (só registra)
      await esperar(
        'B recebe a remoção do bucket',
        () async =>
            await b.t.conta('SELECT count(*) FROM sync_ignored_deletes') > 0,
        ate: const Duration(seconds: 90),
      );
      expect((await b.estado())['user_books'], hasLength(4));
      expect((await b.estado())['annotations'], hasLength(2));

      // voltar ao Pro: reenfileira tudo e o que foi escrito no Grátis chega ao servidor
      await pro(true);
      await a.motor.onAccountConfirmed(uid, pro: true);
      await esperar(
        'A sobe de novo',
        () async =>
            await a.t.fila() == 0 &&
            await sqlLocal(
                  "select title from personal.user_books where id = '${idTeste(1)}'",
                ) ==
                'Escrito sem Pro',
      );
    },
    skip: pular,
    timeout: tempo,
  );
}
