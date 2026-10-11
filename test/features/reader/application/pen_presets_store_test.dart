// G16.6 — o `pen_presets` do modo anotação: sem linha, o padrão das telas 22/23 (não gravado); a espessura grava
// com uma versão nova e vale na próxima leitura; uma linha apagada volta ao padrão.
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/application/pen_presets_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/personal_builders.dart';

void main() {
  late AppDatabase db;
  late PenPresetsStore store;
  final t = DateTime.utc(2026, 10, 8, 10);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    store = PenPresetsStore(
      db,
      LocalVersioning(
        db,
        HlcClock(deviceId: 'aparelhoA', nowMs: () => t.millisecondsSinceEpoch),
      ),
      now: () => t,
    );
  });
  tearDown(() => db.close());

  test('sem linha: o padrão das telas 22/23, sem gravar', () async {
    final p = await store.load(usuarioTeste);
    expect(p.id, usuarioTeste);
    expect(
      (p.penTip, p.penWidthMm, p.penColor, p.strokeSize),
      (PenTip.ballpoint, 1.2, '#FF552E', StrokeSize.medium),
    );
    expect(await PenPresetsDao(db).forUser(usuarioTeste), isNull);
  });

  test('a espessura grava com versão nova e vale na próxima leitura', () async {
    final p = await store.load(usuarioTeste);
    await store.save(p.copyWith(strokeSize: StrokeSize.thick));
    final lida = await store.load(usuarioTeste);
    expect(lida.strokeSize, StrokeSize.thick);
    expect(lida.meta.version.deviceId, 'aparelhoA');
    expect(lida.meta.version.ms, t.millisecondsSinceEpoch);
    expect(lida.meta.updatedAt, t);
    // de novo: a versão sobe
    await store.save(lida.copyWith(strokeSize: StrokeSize.thin));
    final outra = await store.load(usuarioTeste);
    expect(outra.strokeSize, StrokeSize.thin);
    expect(outra.meta.version.compareTo(lida.meta.version), greaterThan(0));
  });

  test('a linha apagada volta ao padrão', () async {
    await PenPresetsDao(db).upsert(
      PenPresets(
        id: usuarioTeste,
        meta: metaTeste(apagado: true),
        strokeSize: StrokeSize.thick,
      ),
    );
    expect((await store.load(usuarioTeste)).strokeSize, StrokeSize.medium);
  });
}
