// G16.4 — o repositório da tinta no banco (§4): o Concluir grava camadas e anotações numa transação, com HLC
// crescente; apaga camadas (com a anotação) e grifos à mão (com as notas; o de seleção fica — D-168); o que já não
// existe ou já está apagado, pula; aplicar duas vezes dá as mesmas linhas. Os desenhos do livro, o rascunho no `kv`
// e o rascunho gravado ao abrir (D-166), que, se falhar, deixa a chave e relata sem conteúdo. G17 (R24): os grifos
// do marca-texto — novos, movidos pela D-32 e tirados, com as notas levadas ao destino (ou apagadas junto, se o
// destino foi apagado).
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

HighlightRow _grifo(
  int n, {
  int group = 0,
  int inicio = 300,
  String exato = 'Olhos de ressaca?',
  AnnotationSource fonte = AnnotationSource.ink,
  HighlightStyle estilo = HighlightStyle.fill,
  FillHeight? altura = FillHeight.low,
  String cor = '#FFC1C6',
}) => HighlightRow(
  id: idTeste(n),
  createdAt: _t1,
  range: ancoraTeste(inicio: inicio, exato: exato, pagina: 160),
  refPage: 160,
  chapterIndex: 32,
  groupId: idTeste(group == 0 ? n : group),
  color: cor,
  style: estilo,
  fillHeight: altura,
  source: fonte,
);

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

  group('G17 (R24): os grifos do marca-texto', () {
    test('novos: o à mão e o pedaço cortado de um de seleção, com a origem, a altura, o grupo e o HLC', () async {
      final mao = _grifo(100);
      final pedaco = _grifo(
        101,
        group: 7,
        inicio: 900,
        exato: 'fluido misterioso',
        fonte: AnnotationSource.selection,
        estilo: HighlightStyle.underline,
        altura: null,
        cor: '#FED170',
      );
      await repo.commit(
        usuarioTeste,
        _livro,
        InkChanges(highlights: [mao, pedaco]),
      );
      final a = (await annotation(100))!;
      expect(
        (a.kind, a.source, a.userBookId, a.anchor, a.refPage, a.chapterIndex),
        (
          AnnotationKind.highlight,
          AnnotationSource.ink,
          _livro,
          mao.range,
          160,
          32,
        ),
      );
      expect(
        (a.color, a.style, a.fillHeight, a.groupId, a.parentId),
        ('#FFC1C6', HighlightStyle.fill, FillHeight.low, idTeste(100), null),
      );
      expect(a.meta.userId, usuarioTeste);
      expect(a.meta.createdAt, a.meta.updatedAt);
      expect(a.meta.updatedAt.millisecondsSinceEpoch, a.meta.version.ms);
      final b = (await annotation(101))!;
      expect(
        (b.source, b.style, b.fillHeight, b.groupId, b.color),
        (
          AnnotationSource.selection,
          HighlightStyle.underline,
          null,
          idTeste(7),
          '#FED170',
        ),
      );
      expect(b.meta.version > a.meta.version, isTrue);
    });

    test('movidos: a âncora, a página e o capítulo novos, com a criação e o grupo; o apagado ou o que não existe pulam', () async {
      final velho = grifoTeste(110, livro: _livro);
      final apagado = grifoTeste(112, livro: _livro, apagado: true);
      for (final a in [velho, apagado]) {
        await AnnotationsDao(db).upsert(a);
      }
      final novo = ancoraTeste(inicio: 0, exato: 'aqueles olhos', pagina: 158);
      await repo.commit(
        usuarioTeste,
        _livro,
        InkChanges(
          moved: [
            MovedHighlight(
              id: velho.id,
              range: novo,
              refPage: 158,
              chapterIndex: 30,
            ),
            MovedHighlight(
              id: apagado.id,
              range: novo,
              refPage: 158,
              chapterIndex: 30,
            ),
            MovedHighlight(
              id: idTeste(113),
              range: novo,
              refPage: 158,
              chapterIndex: 30,
            ),
          ],
        ),
      );
      final a = (await annotation(110))!;
      expect((a.anchor, a.refPage, a.chapterIndex), (novo, 158, 30));
      expect(
        (a.groupId, a.color, a.style, a.fillHeight),
        (velho.groupId, velho.color, velho.style, velho.fillHeight),
      );
      expect(a.meta.createdAt, velho.meta.createdAt);
      expect(a.meta.version > velho.meta.version, isTrue);
      expect(await annotation(112), apagado);
      expect(await annotation(113), isNull);
    });

    test('tirados: some e as notas vão para o destino (o grupo, a âncora, a página e o capítulo dele)', () async {
      final tirado = grifoTeste(
        120,
        livro: _livro,
        fonte: AnnotationSource.ink,
      );
      final nota = notaTeste(
        121,
        livro: _livro,
        pai: tirado,
        texto: 'Capitu e os olhos.',
      );
      // o destino é movido no mesmo Concluir: a nota fica com a âncora nova
      final destino = grifoTeste(122, livro: _livro, inicio: 40);
      for (final a in [tirado, nota, destino]) {
        await AnnotationsDao(db).upsert(a);
      }
      final novo = ancoraTeste(inicio: 0, exato: 'aqueles olhos de Capitu, x');
      await repo.commit(
        usuarioTeste,
        _livro,
        InkChanges(
          moved: [
            MovedHighlight(
              id: destino.id,
              range: novo,
              refPage: 157,
              chapterIndex: 29,
            ),
          ],
          removed: {tirado.id: destino.id},
        ),
      );
      expect((await annotation(120))!.meta.isDeleted, isTrue);
      final n = (await annotation(121))!;
      expect(n.meta.isDeleted, isFalse);
      expect(
        (n.parentId, n.groupId, n.anchor, n.refPage, n.chapterIndex),
        (destino.id, destino.groupId, novo, 157, 29),
      );
      expect(n.noteText, 'Capitu e os olhos.');
      expect(n.meta.createdAt, nota.meta.createdAt);
    });

    test(
      'tirado para um grifo novo do mesmo Concluir: a nota vai para ele',
      () async {
        final tirado = grifoTeste(130, livro: _livro);
        final nota = notaTeste(
          131,
          livro: _livro,
          pai: tirado,
          texto: 'Olhos.',
        );
        for (final a in [tirado, nota]) {
          await AnnotationsDao(db).upsert(a);
        }
        final novo = _grifo(132, group: 140);
        await repo.commit(
          usuarioTeste,
          _livro,
          InkChanges(highlights: [novo], removed: {tirado.id: novo.id}),
        );
        final n = (await annotation(131))!;
        expect(
          (n.parentId, n.groupId, n.anchor, n.refPage),
          (novo.id, idTeste(140), novo.range, 160),
        );
      },
    );

    test('tirado sem destino (o destino foi apagado pela Borracha): as notas vão junto (D-168)', () async {
      final tirado = grifoTeste(150, livro: _livro);
      final nota = notaTeste(151, livro: _livro, pai: tirado, texto: 'Olhos.');
      // tirado para um destino que não existe mais: a nota fica onde estava (como na tela 21)
      final outro = grifoTeste(152, livro: _livro, inicio: 80);
      final notaDoOutro = notaTeste(
        153,
        livro: _livro,
        pai: outro,
        texto: 'Fica.',
      );
      for (final a in [tirado, nota, outro, notaDoOutro]) {
        await AnnotationsDao(db).upsert(a);
      }
      await repo.commit(
        usuarioTeste,
        _livro,
        InkChanges(removed: {tirado.id: null, outro.id: idTeste(199)}),
      );
      expect((await annotation(150))!.meta.isDeleted, isTrue);
      expect((await annotation(151))!.meta.isDeleted, isTrue);
      expect((await annotation(152))!.meta.isDeleted, isTrue);
      expect(await annotation(153), notaDoOutro);
    });

    test(
      'aplicar duas vezes dá as mesmas linhas (o rascunho é idempotente)',
      () async {
        final velho = grifoTeste(160, livro: _livro);
        final tirado = grifoTeste(161, livro: _livro, inicio: 80);
        final nota = notaTeste(
          162,
          livro: _livro,
          pai: tirado,
          texto: 'Olhos.',
        );
        for (final a in [velho, tirado, nota]) {
          await AnnotationsDao(db).upsert(a);
        }
        final c = InkChanges(
          highlights: [_grifo(163)],
          moved: [
            MovedHighlight(
              id: velho.id,
              range: ancoraTeste(inicio: 0, exato: 'aqueles olhos'),
              refPage: 159,
              chapterIndex: 31,
            ),
          ],
          removed: {tirado.id: idTeste(163)},
        );
        await repo.commit(usuarioTeste, _livro, c);
        Future<List<Annotation?>> linhas() async => [
          for (final n in [160, 161, 162, 163]) await annotation(n),
        ];
        final first = await linhas();
        await repo.commit(usuarioTeste, _livro, c);
        expect(await linhas(), first);
      },
    );

    test(
      'o rascunho do formato 2 gravado ao abrir (D-166) grava os grifos',
      () async {
        await repo.saveDraft(
          usuarioTeste,
          _livro,
          InkChanges(highlights: [_grifo(170)]),
          session: 's1',
        );
        expect(await repo.recoverDraft(usuarioTeste, _livro), isTrue);
        expect((await annotation(170))!.source, AnnotationSource.ink);
        expect(await repo.draftsOf(usuarioTeste, _livro), isEmpty);
      },
    );
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

  test('o rascunho de ida e volta no kv, um por sessão; vazio e o clear apagam só o da sessão', () async {
    final c = InkChanges(layers: [_row(70, 71)], deletedLayers: {idTeste(72)});
    final d = InkChanges(deletedLayers: {idTeste(73)});
    await repo.saveDraft(usuarioTeste, _livro, c, session: 's1');
    await repo.saveDraft(usuarioTeste, _livro, d, session: 's2');
    expect(
      await KvDao(db).get(draftKey(usuarioTeste, _livro, 's1')),
      isNotNull,
    );
    expect(await repo.draftsOf(usuarioTeste, _livro), [c, d]);
    expect(await repo.draftsOf(usuarioTeste, idTeste(2)), isEmpty);
    await repo.saveDraft(
      usuarioTeste,
      _livro,
      const InkChanges(),
      session: 's1',
    );
    expect(await KvDao(db).get(draftKey(usuarioTeste, _livro, 's1')), isNull);
    expect(await repo.draftsOf(usuarioTeste, _livro), [d]);
    await repo.saveDraft(usuarioTeste, _livro, c, session: 's1');
    await repo.clearDraft(usuarioTeste, _livro, session: 's1');
    expect(await repo.draftsOf(usuarioTeste, _livro), [d]);
    // a chave de outro livro que começa igual não entra
    await KvDao(db).set('${draftKey(usuarioTeste, _livro)}x:s9', 'lixo');
    expect(await repo.draftsOf(usuarioTeste, _livro), [d]);
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
      session: 's1',
    );
    await repo.saveDraft(
      usuarioTeste,
      _livro,
      InkChanges(layers: [_row(82, 83)]),
      session: 's2',
    );
    expect(await repo.recoverDraft(usuarioTeste, _livro), isTrue);
    expect(await layer(80), isNotNull);
    expect(await annotation(81), isNotNull);
    expect(
      await layer(82),
      isNotNull,
      reason: 'os rascunhos de todas as sessões',
    );
    expect(await repo.draftsOf(usuarioTeste, _livro), isEmpty);
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
      await repo.saveDraft(
        usuarioTeste,
        _livro,
        InkChanges(layers: [bad]),
        session: 's1',
      );
      // o de outra sessão que dá certo grava mesmo assim
      await repo.saveDraft(
        usuarioTeste,
        _livro,
        InkChanges(layers: [_row(84, 85)]),
        session: 's2',
      );
      expect(await repo.recoverDraft(usuarioTeste, _livro), isFalse);
      expect(
        await KvDao(db).get(draftKey(usuarioTeste, _livro, 's1')),
        isNotNull,
      );
      expect(await KvDao(db).get(draftKey(usuarioTeste, _livro, 's2')), isNull);
      expect(await layer(84), isNotNull);
      expect(errors.single, isA<InkDraftNotRecovered>());
      expect('${errors.single}', isNot(contains('Olhos')));
      expect('${errors.single}', isNot(contains(_strokes)));
      // ilegível: também fica
      await KvDao(db).set(draftKey(usuarioTeste, _livro, 's1'), '{quebrado');
      expect(await repo.recoverDraft(usuarioTeste, _livro), isFalse);
      expect(
        await KvDao(db).get(draftKey(usuarioTeste, _livro, 's1')),
        '{quebrado',
      );
      expect(errors, hasLength(2));
    },
  );
}
