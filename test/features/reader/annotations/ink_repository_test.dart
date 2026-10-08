// G16.4 — o repositório da tinta no banco (§4): o Concluir grava camadas e anotações numa transação, com HLC
// crescente; apaga camadas (com a anotação) e grifos à mão (com as notas; o de seleção fica — D-168); o que já não
// existe ou já está apagado, pula; aplicar duas vezes dá as mesmas linhas. Os desenhos do livro, o rascunho no `kv`
// e o rascunho gravado ao abrir (D-166), que, se falhar, deixa a chave e relata sem conteúdo.
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/ink_layer.dart';
import 'package:app_leitura/features/reader/annotations/ink/bnk1_codec.dart';
import 'package:app_leitura/features/reader/annotations/ink/drawing_anchor.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_changes.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/annotations/ink_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/personal_builders.dart';

final _t1 = DateTime.utc(2026, 10, 8, 9, 30);
final _livro = idTeste(1);

final _strokes = encodeStrokesB64(const [
  InkStroke(
    tool: 1,
    tip: 0,
    argb: 0xFFFF552E,
    widthCentiMm: 120,
    points: [InkPoint(0, 0, 0.5, 0), InkPoint(1.5, -0.4, 0.6, 8)],
  ),
], Bnk1Unit.em);

DrawingRow _row(
  int layer,
  int annotation, {
  int group = 0,
  int inicio = 300,
  String exato = 'Olhos de ressaca?',
  String strokesB64 = '',
  int tracos = 1,
  String cor = '#FF552E',
}) {
  final range = ancoraTeste(inicio: inicio, exato: exato);
  return DrawingRow(
    layerId: idTeste(layer),
    annotationId: idTeste(annotation),
    createdAt: _t1,
    anchor: inkLayerAnchor(range, 8.2213),
    range: range,
    refPage: 159,
    chapterIndex: 31,
    groupId: idTeste(group == 0 ? annotation : group),
    color: cor,
    strokesB64: strokesB64.isEmpty ? _strokes : strokesB64,
    strokeCount: tracos,
  );
}

void main() {
  late AppDatabase db;
  late DriftInkRepository repo;
  late List<Object> errors;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    errors = [];
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
      onError: (e, _) => errors.add(e),
    );
  });
  tearDown(() => db.close());

  Future<InkLayer?> layer(int n) async =>
      (await InkLayersDao(db).byIds([idTeste(n)])).firstOrNull;
  Future<Annotation?> annotation(int n) => AnnotationsDao(db).byId(idTeste(n));

  test('o Concluir grava camadas e anotações, com HLC crescente e updated_at = hora do HLC', () async {
    final r1 = _row(10, 11);
    final r2 = _row(12, 13, group: 11, inicio: 900, exato: 'fluido misterioso');
    await repo.commit(usuarioTeste, _livro, InkChanges(layers: [r1, r2]));
    final l = (await layer(10))!;
    expect(l.kind, InkLayerKind.overText);
    expect(l.userBookId, _livro);
    expect(l.anchor, r1.anchor);
    expect(l.strokesB64, _strokes);
    expect((l.strokeCount, l.codecVersion), (1, 1));
    expect(l.meta.userId, usuarioTeste);
    expect(l.meta.createdAt, l.meta.updatedAt);
    expect(l.meta.updatedAt.millisecondsSinceEpoch, l.meta.version.ms);
    expect(l.meta.isDeleted, isFalse);
    final a = (await annotation(13))!;
    expect(a.kind, AnnotationKind.drawing);
    expect(a.source, AnnotationSource.ink);
    expect(a.anchor, r2.range);
    expect((a.refPage, a.chapterIndex), (159, 31));
    expect(a.color, '#FF552E');
    expect(a.groupId, idTeste(11));
    expect(a.inkLayerId, idTeste(12));
    expect(a.meta.updatedAt.millisecondsSinceEpoch, a.meta.version.ms);
    // a ordem das escritas: camada, anotação, camada, anotação — cada versão maior que a anterior
    final versions = [
      (await layer(10))!.meta.version,
      (await annotation(11))!.meta.version,
      (await layer(12))!.meta.version,
      a.meta.version,
    ];
    for (var i = 1; i < versions.length; i++) {
      expect(versions[i] > versions[i - 1], isTrue, reason: 'escrita ${i + 1}');
    }
  });

  test(
    'desenho salvo mudado: fica a criação e o grupo; sem mudança, não regrava',
    () async {
      final camada = camadaSobreTextoTeste(
        20,
        livro: _livro,
        strokesB64: _strokes,
        tracos: 1,
      );
      final desenho = desenhoTeste(21, livro: _livro, camada: camada);
      await InkLayersDao(db).upsert(camada);
      await AnnotationsDao(db).upsert(desenho);
      final twoStrokes = encodeStrokesB64([
        ...decodeStrokesB64(_strokes, Bnk1Unit.em),
        ...decodeStrokesB64(_strokes, Bnk1Unit.em),
      ], Bnk1Unit.em);
      final r = _row(
        20,
        21,
        group: 77,
        strokesB64: twoStrokes,
        tracos: 2,
        cor: '#552CB7',
      );
      await repo.commit(usuarioTeste, _livro, InkChanges(layers: [r]));
      final l = (await layer(20))!;
      expect((l.strokesB64, l.strokeCount), (twoStrokes, 2));
      expect(l.anchor, r.anchor);
      expect(l.meta.createdAt, camada.meta.createdAt);
      expect(l.meta.version > camada.meta.version, isTrue);
      final a = (await annotation(21))!;
      expect(
        a.groupId,
        desenho.groupId,
        reason: 'grupos já gravados não mudam',
      );
      expect(a.color, '#552CB7');
      expect(a.meta.createdAt, desenho.meta.createdAt);
      // de novo, igual: nada muda (nem a versão)
      await repo.commit(usuarioTeste, _livro, InkChanges(layers: [r]));
      expect(await layer(20), l);
      expect(await annotation(21), a);
    },
  );

  test('apaga camadas (com a anotação) e grifos à mão (com as notas); o que não existe ou já foi apagado, pula', () async {
    final camada = camadaSobreTextoTeste(30, livro: _livro);
    final desenho = desenhoTeste(31, livro: _livro, camada: camada);
    final grifo = grifoTeste(32, livro: _livro, fonte: AnnotationSource.ink);
    final nota = notaTeste(
      33,
      livro: _livro,
      pai: grifo,
      texto: 'É o livro todo.',
    );
    final outroGrifo = grifoTeste(
      34,
      livro: _livro,
      apagado: true,
      fonte: AnnotationSource.ink,
    );
    final vizinho = grifoTeste(
      35,
      livro: _livro,
      inicio: 700,
      fonte: AnnotationSource.ink,
    );
    await InkLayersDao(db).upsert(camada);
    for (final a in [desenho, grifo, nota, outroGrifo, vizinho]) {
      await AnnotationsDao(db).upsert(a);
    }
    await repo.commit(
      usuarioTeste,
      _livro,
      InkChanges(
        deletedLayers: {camada.id, idTeste(99)},
        erasedHighlights: {grifo.id, outroGrifo.id, idTeste(98)},
      ),
    );
    expect((await layer(30))!.meta.isDeleted, isTrue);
    expect((await annotation(31))!.meta.isDeleted, isTrue);
    expect((await annotation(32))!.meta.isDeleted, isTrue);
    expect((await annotation(33))!.meta.isDeleted, isTrue);
    expect(await annotation(34), outroGrifo, reason: 'já estava apagado');
    expect(await annotation(35), vizinho);
    expect(await layer(99), isNull);
    expect(await annotation(98), isNull);
  });

  test(
    'a Borracha só apaga tinta (D-168): o grifo de seleção e a nota dele ficam',
    () async {
      final grifo = grifoTeste(36, livro: _livro);
      final nota = notaTeste(
        37,
        livro: _livro,
        pai: grifo,
        texto: 'Levar para o encontro.',
      );
      for (final a in [grifo, nota]) {
        await AnnotationsDao(db).upsert(a);
      }
      await repo.commit(
        usuarioTeste,
        _livro,
        InkChanges(erasedHighlights: {grifo.id}),
      );
      expect(await annotation(36), grifo);
      expect(await annotation(37), nota);
    },
  );

  test('um erro no meio não grava nada (transação)', () async {
    final camada = camadaSobreTextoTeste(40, livro: _livro);
    await InkLayersDao(db).upsert(camada);
    final bad = DrawingRow(
      layerId: idTeste(42),
      annotationId: 'não é um uuid',
      createdAt: _t1,
      anchor: _row(42, 43).anchor,
      range: _row(42, 43).range,
      refPage: 159,
      chapterIndex: 31,
      groupId: idTeste(43),
      color: '#FF552E',
      strokesB64: _strokes,
      strokeCount: 1,
    );
    await expectLater(
      repo.commit(
        usuarioTeste,
        _livro,
        InkChanges(layers: [_row(44, 45), bad], deletedLayers: {camada.id}),
      ),
      throwsArgumentError,
    );
    expect(await layer(44), isNull);
    expect(await annotation(45), isNull);
    expect(await layer(42), isNull);
    expect(await layer(40), camada);
  });

  test('aplicar duas vezes dá as mesmas linhas', () async {
    final grifo = grifoTeste(52, livro: _livro, fonte: AnnotationSource.ink);
    await AnnotationsDao(db).upsert(grifo);
    final c = InkChanges(layers: [_row(50, 51)], erasedHighlights: {grifo.id});
    await repo.commit(usuarioTeste, _livro, c);
    final first = (await layer(50), await annotation(51), await annotation(52));
    await repo.commit(usuarioTeste, _livro, c);
    expect((
      await layer(50),
      await annotation(51),
      await annotation(52),
    ), first);
  });

  test('os desenhos do livro: as camadas sobre o texto vivas, com a anotação drawing delas', () async {
    final viva = camadaSobreTextoTeste(60, livro: _livro);
    final apagada = camadaSobreTextoTeste(62, livro: _livro, apagada: true);
    final espaco = camadaTeste(64, livro: _livro);
    final outroLivro = camadaSobreTextoTeste(65, livro: idTeste(2));
    final semAnotacao = camadaSobreTextoTeste(67, livro: _livro);
    for (final l in [viva, apagada, espaco, outroLivro, semAnotacao]) {
      await InkLayersDao(db).upsert(l);
    }
    final d = desenhoTeste(61, livro: _livro, camada: viva);
    for (final a in [
      d,
      desenhoTeste(63, livro: _livro, camada: apagada),
      desenhoTeste(66, livro: idTeste(2), camada: outroLivro),
      desenhoTeste(68, livro: _livro, camada: semAnotacao, apagado: true),
    ]) {
      await AnnotationsDao(db).upsert(a);
    }
    expect(await repo.drawingsOfBook(_livro), [(layer: viva, annotation: d)]);
  });

  test('o rascunho de ida e volta no kv; vazio apaga a chave', () async {
    final c = InkChanges(layers: [_row(70, 71)], deletedLayers: {idTeste(72)});
    await repo.saveDraft(usuarioTeste, _livro, c);
    expect(await KvDao(db).get(draftKey(usuarioTeste, _livro)), isNotNull);
    expect(await repo.draftOf(usuarioTeste, _livro), c);
    expect(await repo.draftOf(usuarioTeste, idTeste(2)), isNull);
    await repo.saveDraft(usuarioTeste, _livro, const InkChanges());
    expect(await KvDao(db).get(draftKey(usuarioTeste, _livro)), isNull);
    await repo.saveDraft(usuarioTeste, _livro, c);
    await repo.clearDraft(usuarioTeste, _livro);
    expect(await repo.draftOf(usuarioTeste, _livro), isNull);
  });

  test('o rascunho gravado ao abrir (D-166): grava como um Concluir e apaga a chave', () async {
    expect(
      await repo.recoverDraft(usuarioTeste, _livro),
      isTrue,
      reason: 'sem rascunho',
    );
    await repo.saveDraft(
      usuarioTeste,
      _livro,
      InkChanges(layers: [_row(80, 81)]),
    );
    expect(await repo.recoverDraft(usuarioTeste, _livro), isTrue);
    expect(await layer(80), isNotNull);
    expect(await annotation(81), isNotNull);
    expect(await KvDao(db).get(draftKey(usuarioTeste, _livro)), isNull);
    expect(errors, isEmpty);
  });

  test(
    'o rascunho que falha fica e a falha vai ao relatório, sem conteúdo',
    () async {
      final bad = DrawingRow(
        layerId: idTeste(90),
        annotationId: 'x',
        createdAt: _t1,
        anchor: _row(90, 91).anchor,
        range: _row(90, 91).range,
        refPage: 159,
        chapterIndex: 31,
        groupId: idTeste(91),
        color: '#FF552E',
        strokesB64: _strokes,
        strokeCount: 1,
      );
      await repo.saveDraft(usuarioTeste, _livro, InkChanges(layers: [bad]));
      expect(await repo.recoverDraft(usuarioTeste, _livro), isFalse);
      expect(await KvDao(db).get(draftKey(usuarioTeste, _livro)), isNotNull);
      expect(errors.single, isA<InkDraftNotRecovered>());
      expect('${errors.single}', isNot(contains('Olhos')));
      expect('${errors.single}', isNot(contains(_strokes)));
      // ilegível: também fica
      await KvDao(db).set(draftKey(usuarioTeste, _livro), '{quebrado');
      expect(await repo.recoverDraft(usuarioTeste, _livro), isFalse);
      expect(await KvDao(db).get(draftKey(usuarioTeste, _livro)), '{quebrado');
      expect(errors, hasLength(2));
    },
  );
}
