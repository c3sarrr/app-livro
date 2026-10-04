// G02 · S2 — o lado do app em Dart (Windows, offline): PowerSync SDK + drift sobre a MESMA conexão,
// tabelas próprias, fila só no Pro, payload do CrudEntry no formato da RPC, FTS5 e migração do drift.
// (O caminho servidor ↔ aparelho — upload, download, remoção de bucket — está nos cenários Node,
// que usam o mesmo núcleo Rust do PowerSync.)
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_sqlite_async/drift_sqlite_async.dart';
import 'package:path/path.dart' as p;
import 'package:powersync/powersync.dart';
import 'package:spike_s2_cliente/banco.dart';
import 'package:spike_s2_cliente/esquema_powersync.dart';
import 'package:test/test.dart';

final _resultado = <String, Object?>{};

String _hlc(int n) =>
    '${DateTime.now().millisecondsSinceEpoch.toString().padLeft(16, '0')}-${(n % 10000).toString().padLeft(4, '0')}-win';

String _agora() => DateTime.now().toUtc().toIso8601String();

Future<(PowerSyncDatabase, BancoSpike)> _abrir(
  String caminho, {
  int versao = 1,
}) async {
  final ps = PowerSyncDatabase(
    schema: esquemaPowerSync(extras: versao >= 2 ? ['lang'] : []),
    path: caminho,
  );
  await ps.initialize();
  final drift = BancoSpike(SqliteAsyncDriftConnection(ps), versao: versao);
  await drift.customSelect('select 1').get(); // dispara a migração do drift
  return (ps, drift);
}

Future<int> _fila(PowerSyncDatabase ps) async =>
    (await ps.get('select count(*) n from ps_crud'))['n'] as int;

Future<void> _gravar(
  BancoSpike d,
  int livros,
  int notas, {
  int base = 0,
}) async {
  await d.batch((b) {
    for (var i = 0; i < livros; i++) {
      b.insert(
        d.userBooks,
        UserBooksCompanion.insert(
          id: 'livro-${base + i}',
          userId: 'u1',
          title: 'Livro $i',
          authorDisplay: 'Machado de Assis',
          format: 'epub',
          status: 'reading',
          addedAt: _agora(),
          createdAt: _agora(),
          updatedAt: _agora(),
          versionHlc: _hlc(i),
        ),
      );
    }
    for (var i = 0; i < notas; i++) {
      b.insert(
        d.annotations,
        AnnotationsCompanion.insert(
          id: 'nota-${base + i}',
          userId: 'u1',
          userBookId: 'livro-${base + i % livros}',
          kind: 'note',
          groupId: 'g$i',
          source: 'selection',
          anchor: jsonEncode({'v': 1, 'start': i}),
          refPage: 1 + i % 256,
          chapterIndex: i % 148,
          noteText: Value('nota $i: aqueles olhos de Capitu, olhos de ressaca'),
          createdAt: _agora(),
          updatedAt: _agora(),
          versionHlc: _hlc(i),
        ),
      );
    }
  });
}

void main() {
  late Directory dir;
  setUpAll(() => dir = Directory.systemTemp.createTempSync('s2dart'));
  tearDownAll(() {
    Directory('../dados').createSync(recursive: true);
    File('../dados/resultado_s2_dart.json').writeAsStringSync(
      '${const JsonEncoder.withIndent(' ').convert(_resultado)}\n',
    );
  });

  test('núcleo do PowerSync no Dart tem o que o plano A\' precisa', () async {
    final (ps, d) = await _abrir(p.join(dir.path, 'nucleo.db'));
    final v = await ps.get(
      'select powersync_rs_version() v, sqlite_version() s, powersync_in_sync_operation() emSync',
    );
    expect(v['emSync'], 0);
    _resultado['nucleo'] = {'powersync_core': v['v'], 'sqlite': v['s']};
    await d.close();
    await ps.close();
  });

  test('Grátis: 10 mil linhas pelo drift, fila zero', () async {
    final (ps, d) = await _abrir(p.join(dir.path, 'gratis.db'));
    final sw = Stopwatch()..start();
    await _gravar(d, 60, 9940);
    final ms = sw.elapsedMilliseconds;
    expect(await _fila(ps), 0);
    expect(await d.annotations.count().getSingle(), 9940);
    _resultado['gratis'] = {
      'linhas': 10000,
      'gravacao_drift_ms': ms,
      'fila': 0,
    };
    await d.close();
    await ps.close();
  });

  test(
    'Pro: gatilhos enfileiram PUT com a linha inteira (formato da RPC)',
    () async {
      final (ps, d) = await _abrir(p.join(dir.path, 'pro.db'));
      await d.customStatement(
        "UPDATE app_kv SET valor = 'pro' WHERE chave = 'sync'",
      );
      final sw = Stopwatch()..start();
      await _gravar(d, 60, 9940);
      final ms = sw.elapsedMilliseconds;
      expect(await _fila(ps), 10000);
      // edição pelo drift também entra (PUT com a linha inteira — sem PATCH: robusto depois do purge)
      await (d.update(
        d.annotations,
      )..where((a) => a.id.equals('nota-7'))).write(
        AnnotationsCompanion(
          noteText: const Value('editada'),
          versionHlc: Value(_hlc(99)),
        ),
      );
      var lotes = 0;
      CrudEntry? exemplo;
      CrudEntry? edicao;
      for (;;) {
        final lote = await ps.getCrudBatch(limit: 500);
        if (lote == null) break;
        lotes++;
        exemplo ??= lote.crud.firstWhere(
          (e) => e.table == 'annotations',
          orElse: () => lote.crud.first,
        );
        for (final e in lote.crud) {
          if (e.id == 'nota-7' && e.opData?['note_text'] == 'editada') {
            edicao = e;
          }
        }
        await lote.complete();
      }
      expect(lotes, 21);
      expect(edicao, isNotNull);
      expect(edicao!.op, UpdateType.put);
      final op = {
        'table': exemplo!.table,
        'op': exemplo.op.toJson(),
        'id': exemplo.id,
        'data': exemplo.opData,
        'hlc': exemplo.opData!['version_hlc'],
      };
      expect(op['op'], 'PUT');
      expect(
        (op['data'] as Map).keys.toSet(),
        colunasSync[op['table']]!.toSet(),
      );
      _resultado['pro'] = {
        'linhas': 10000,
        'gravacao_com_gatilhos_ms': ms,
        'lotes_de_500': lotes,
        'operacao_para_a_rpc': op,
      };
      await d.close();
      await ps.close();
    },
  );

  test('FTS5 sem acentos pelo drift', () async {
    final (ps, d) = await _abrir(p.join(dir.path, 'fts.db'));
    await _gravar(d, 60, 9940);
    final sw = Stopwatch()..start();
    final r = await d
        .customSelect(
          'select count(*) n from annotations_fts where annotations_fts match ?',
          variables: [Variable.withString('capítu')],
        )
        .getSingle();
    final ms = sw.elapsedMicroseconds / 1000;
    expect(r.read<int>('n'), 9940);
    _resultado['fts5'] = {'achados': 9940, 'consulta_ms': ms};
    await d.close();
    await ps.close();
  });

  test('migração do drift (v1 → v2, coluna nova sincronizada) sem perder dados', () async {
    final caminho = p.join(dir.path, 'migra.db');
    var (ps, d) = await _abrir(caminho);
    await _gravar(d, 10, 500);
    // como se o servidor já tivesse mandado `lang` antes de o app conhecer a coluna (put com "Rest")
    await d.customStatement(
      "UPDATE annotations SET _extras = '{\"lang\":\"en\"}' WHERE id = 'nota-2'",
    );
    await d.close();
    await ps.close();
    (ps, d) = await _abrir(caminho, versao: 2);
    expect(await d.annotations.count().getSingle(), 500);
    final recuperado = await ps.get(
      "select lang from annotations where id = 'nota-2'",
    );
    expect(
      recuperado['lang'],
      'en',
      reason: 'migração preencheu a coluna nova a partir de _extras',
    );
    await d.customStatement(
      "UPDATE app_kv SET valor = 'pro' WHERE chave = 'sync'",
    );
    await d.customStatement(
      "UPDATE annotations SET lang = 'pt-BR', version_hlc = '${_hlc(1)}' WHERE id = 'nota-1'",
    );
    final lote = await ps.getCrudBatch();
    expect(
      lote!.crud.single.opData!['lang'],
      'pt-BR',
      reason: 'gatilho recriado com a coluna nova',
    );
    final versao = await ps.get('pragma user_version');
    _resultado['migracao'] = {
      'linhas_preservadas': 500,
      'user_version': versao.values.first,
      'coluna_nova_no_payload': true,
      'recuperado_de_extras': true,
    };
    await d.close();
    await ps.close();
  });
}
