// G03.4 — teste de contrato de colunas (Anexo 02 §3.2; PROMPT MESTRE §4.3.5: "esquema local ≡
// esquema personal.* do servidor"). Três fontes têm de concordar:
//   1. o SQL de referência (handoff_v2/sql/01_schema_booknest.sql — a G04 troca por migrations);
//   2. o information_schema de um Postgres com esse SQL aplicado (instantâneo gerado por
//      tools/contracts/gerar_contrato_personal.py, com o sha256 do SQL);
//   3. o esquema local (drift) e a lista de colunas sincronizadas (gatilhos e `put` do PowerSync).
import 'dart:convert';
import 'dart:io';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/local_sql.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tipo do SQLite que o aparelho usa para cada `data_type` do Postgres (Anexo 02 §3.2).
String tipoNoAparelho(String tipoPostgres) => switch (tipoPostgres) {
  'integer' || 'smallint' || 'bigint' || 'boolean' => 'INTEGER',
  'uuid' ||
  'text' ||
  'jsonb' ||
  'numeric' ||
  'timestamp with time zone' => 'TEXT',
  _ => throw StateError('tipo sem mapeamento no aparelho: $tipoPostgres'),
};

/// Colunas de cada `create table personal.X (…)` do SQL, com o tipo no nome do information_schema.
Map<String, List<(String, String)>> colunasDoSql(String sql) {
  final tabelas = <String, List<(String, String)>>{};
  final inicio = RegExp(r'^create table personal\.(\w+) \(', multiLine: true);
  for (final m in inicio.allMatches(sql)) {
    final colunas = <(String, String)>[];
    for (final bruta in sql.substring(m.end).split('\n').skip(1)) {
      final linha = bruta.trim();
      if (linha.startsWith(')')) break;
      if (linha.isEmpty || linha.startsWith('--')) continue;
      final partes = linha.split(RegExp(r'\s+'));
      if (const {
        'unique',
        'primary',
        'foreign',
        'check',
        'constraint',
      }.contains(partes[0])) {
        continue;
      }
      final tipo = partes[1].replaceAll(RegExp(r'[,(].*$'), '');
      colunas.add((
        partes[0],
        switch (tipo) {
          'timestamptz' => 'timestamp with time zone',
          final t => t,
        },
      ));
    }
    tabelas[m[1]!] = colunas;
  }
  return tabelas;
}

void main() {
  final sqlBytes = File('handoff_v2/sql/01_schema_booknest.sql')
      .readAsBytesSync();
  final contrato = jsonDecode(
    File('test/data/contracts/personal_columns.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final servidor = {
    for (final MapEntry(:key, :value)
        in (contrato['tabelas']! as Map<String, Object?>).entries)
      key: [
        for (final c in value! as List<Object?>)
          (
            (c! as List<Object?>)[0]! as String,
            (c as List<Object?>)[1]! as String,
          ),
      ],
  };

  test('o instantâneo do information_schema é do SQL atual (sha256)', () {
    expect(sha256.convert(sqlBytes).toString(), contrato['sha256_da_fonte']);
  });

  test('SQL de referência = information_schema (nomes, ordem e tipos)', () {
    final doSql = colunasDoSql(utf8.decode(sqlBytes));
    expect(doSql.keys.toSet(), servidor.keys.toSet());
    expect(doSql.keys.toSet(), personalSyncColumns.keys.toSet());
    for (final t in servidor.keys) {
      expect(doSql[t], servidor[t], reason: t);
    }
  });

  test('esquema local (drift) = servidor: mesmas colunas, tipo do SQLite, + `_extras`', () async {
    final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    addTearDown(db.close);
    var colunas = 0;
    for (final MapEntry(key: t, value: cols) in servidor.entries) {
      final info = await db.customSelect('PRAGMA table_info($t)').get();
      final local = {
        for (final r in info) r.read<String>('name'): r.read<String>('type'),
      };
      expect(local, {
        for (final (c, tipo) in cols) c: tipoNoAparelho(tipo),
        '_extras': 'TEXT',
      }, reason: t);
      colunas += cols.length - 1;
    }
    expect(
      colunas,
      126,
    ); // sem os 10 `id` (mesma conta do cenário 08 do spike S2)
  });

  test('colunas sincronizadas (gatilhos da fila e `put`) = servidor sem `id`, na ordem do SQL', () {
    for (final MapEntry(key: t, value: cols) in servidor.entries) {
      expect(cols.first.$1, 'id', reason: t);
      expect(personalSyncColumns[t], [
        for (final (c, _) in cols.skip(1)) c,
      ], reason: t);
    }
  });
}
