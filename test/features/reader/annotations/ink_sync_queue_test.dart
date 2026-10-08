// G16.4 — a tinta e a fila do Pro (§4), sobre a conexão do SDK do PowerSync (como no app): o rascunho nunca entra
// na fila (o `kv` não sincroniza); o Concluir põe um PUT por linha mudada (a camada e a anotação de cada desenho, as
// linhas apagadas); o mesmo Concluir de novo não põe nada. No Grátis, a fila continua vazia.
// (Arquivo temporário: o PowerSync abre várias conexões e não usa banco em memória.)
import 'dart:io';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/local_sql.dart';
import 'package:app_leitura/core/data/database/powersync_schema.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/ink/bnk1_codec.dart';
import 'package:app_leitura/features/reader/annotations/ink/drawing_anchor.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_changes.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/annotations/ink_repository.dart';
import 'package:drift_sqlite_async/drift_sqlite_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powersync/powersync.dart' hide Column;

import '../../../support/personal_builders.dart';

final _t1 = DateTime.utc(2026, 10, 8, 9, 30);
final _livro = idTeste(1);

DrawingRow _row(int layer, int annotation) {
  final range = ancoraTeste(inicio: 300, exato: 'Olhos de ressaca?');
  return DrawingRow(
    layerId: idTeste(layer),
    annotationId: idTeste(annotation),
    createdAt: _t1,
    anchor: inkLayerAnchor(range, 8.2213),
    range: range,
    refPage: 159,
    chapterIndex: 31,
    groupId: idTeste(annotation),
    color: '#FF552E',
    strokesB64: encodeStrokesB64(const [
      InkStroke(
        tool: 1,
        tip: 0,
        argb: 0xFFFF552E,
        widthCentiMm: 120,
        points: [InkPoint(0, 0, 0.5, 0), InkPoint(1, -0.5, 0.5, 8)],
      ),
    ], Bnk1Unit.em),
    strokeCount: 1,
  );
}

void main() {
  late Directory dir;
  late PowerSyncDatabase ps;
  late AppDatabase db;
  late DriftInkRepository repo;
  var n = 0;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('booknest_g16_');
    ps = PowerSyncDatabase(
      schema: buildPowerSyncSchema(),
      path: '${dir.path}${Platform.pathSeparator}app_${n++}.db',
    );
    await ps.initialize();
    db = AppDatabase(SqliteAsyncDriftConnection(ps));
    await db.customSelect('SELECT 1').get();
    repo = DriftInkRepository(
      db,
      LocalVersioning(
        db,
        HlcClock(
          deviceId: 'aparelhoA',
          nowMs: () => _t1.millisecondsSinceEpoch,
        ),
      ),
      now: () => _t1,
    );
  });

  tearDown(() async {
    await db.close();
    await ps.close();
    await dir.delete(recursive: true);
  });

  Future<List<(UpdateType, String, String)>> queue() async {
    final batch = await ps.getCrudBatch(limit: 500);
    return [
      for (final e in batch?.crud ?? const <CrudEntry>[]) (e.op, e.table, e.id),
    ];
  }

  test(
    'Pro: o rascunho não entra na fila; o Concluir põe um PUT por linha mudada',
    () async {
      await KvDao(db).set(syncModeKey, syncModePro);
      await KvDao(db).set(activeOwnerKey, usuarioTeste);
      // um grifo feito à mão: a Borracha só apaga tinta (D-168)
      final grifo = grifoTeste(20, livro: _livro, fonte: AnnotationSource.ink);
      await AnnotationsDao(db).upsert(grifo);
      final before = (await queue()).length;
      final c = InkChanges(
        layers: [_row(10, 11)],
        erasedHighlights: {grifo.id},
      );
      await repo.saveDraft(usuarioTeste, _livro, c);
      expect(await queue(), hasLength(before), reason: 'o rascunho fica no kv');
      await repo.commit(usuarioTeste, _livro, c);
      expect((await queue()).skip(before), [
        (UpdateType.put, 'ink_layers', idTeste(10)),
        (UpdateType.put, 'annotations', idTeste(11)),
        (UpdateType.put, 'annotations', grifo.id),
      ]);
      // o mesmo Concluir de novo (o rascunho gravado ao abrir, depois de um Concluir que deu certo): nada a mais
      expect(await repo.recoverDraft(usuarioTeste, _livro), isTrue);
      expect(await queue(), hasLength(before + 3));
      expect(await repo.draftOf(usuarioTeste, _livro), isNull);
    },
  );

  test('Grátis: desenhar, rascunhar e concluir não enchem a fila', () async {
    expect(await KvDao(db).get(syncModeKey), syncModeFree);
    final c = InkChanges(layers: [_row(10, 11)]);
    await repo.saveDraft(usuarioTeste, _livro, c);
    await repo.commit(usuarioTeste, _livro, c);
    await repo.commit(
      usuarioTeste,
      _livro,
      InkChanges(deletedLayers: {idTeste(10)}),
    );
    expect(await queue(), isEmpty);
  });
}
