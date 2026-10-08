// G16.4 — lista branca do Grátis (§4.3.7) na tinta: uma sessão inteira do modo anotação pelo repositório de verdade
// (banco em memória, sem a fila do Pro) — abrir o livro com o rascunho de uma sessão que morreu (D-166), o
// `pen_presets` lido e a espessura gravada, desenhar, apagar, mover com o Laço, grifar com o marca-texto (G17), o
// rascunho a cada 5 s e no segundo plano, e o Concluir — não abre nenhuma conexão: qualquer `HttpClient` criado na
// zona é gravado e falha.
import 'dart:async';
import 'dart:io';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/annotations/ink/gesture_arbiter.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_changes.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/annotations/ink_repository.dart';
import 'package:app_leitura/features/reader/application/annotation_anchors.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/application/pen_presets_store.dart';
import 'package:app_leitura/features/reader/application/reader_annotations.dart';
import 'package:app_leitura/features/reader/application/reader_ink.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/personal_builders.dart';

const _text = 'Olhos de ressaca a vaga que';

InkPageGeometry _geometry() => const InkPageGeometry([
  InkLine(
    unit: 4,
    from: 0,
    to: 16,
    top: 74,
    bottom: 109.25,
    baseline: 100,
    em: 20.5,
    left: 28,
    right: 190,
    words: [
      (from: 0, to: 5, left: 28, right: 83),
      (from: 6, to: 8, left: 89, right: 109),
      (from: 9, to: 16, left: 115, right: 190),
    ],
  ),
  InkLine(
    unit: 4,
    from: 17,
    to: 27,
    top: 109.25,
    bottom: 144.5,
    baseline: 135.25,
    em: 20.5,
    left: 28,
    right: 133,
    words: [
      (from: 17, to: 18, left: 28, right: 39),
      (from: 19, to: 23, left: 45, right: 92),
      (from: 24, to: 27, left: 98, right: 133),
    ],
  ),
]);

final class _Anchors implements AnnotationAnchors {
  @override
  String get sha => shaTeste;

  @override
  String? textOf(int spine) => spine == 4 ? _text : null;

  @override
  ({int refPage, int chapterIndex}) placeOf(int spine, int offset) =>
      (refPage: 159, chapterIndex: 31);
}

/// Grava cada `HttpClient` pedido na zona — e falha: a tinta do Grátis não pode abrir nenhum.
final class _NoNetwork extends HttpOverrides {
  final List<String> created = [];

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    created.add('HttpClient');
    throw StateError('a tinta do Grátis não pode usar a rede');
  }
}

InkPointer _touch(int id, double x, double y, int t) =>
    (id: id, kind: InkPointerKind.touch, x: x, y: y, pressure: 1, tMs: t);

void main() {
  test('uma sessão inteira da tinta no Grátis: nenhuma conexão', () async {
    final net = _NoNetwork();
    await HttpOverrides.runZoned(() async {
      // a guarda vale na zona: abrir uma conexão aqui falha e fica gravado
      expect(HttpClient.new, throwsStateError);
      expect(net.created, hasLength(1));
      net.created.clear();
      final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
      addTearDown(db.close);
      final t = DateTime.utc(2026, 10, 8, 10);
      final versioning = LocalVersioning(
        db,
        HlcClock(deviceId: 'aparelhoA', nowMs: () => t.millisecondsSinceEpoch),
      );
      final repo = DriftInkRepository(db, versioning, now: () => t);
      // abrir o livro: o rascunho de uma sessão que morreu é gravado (D-166)
      await repo.saveDraft(
        usuarioTeste,
        idTeste(1),
        const InkChanges(deletedLayers: {'camada-que-nao-existe'}),
        session: 'morta',
      );
      Future<String> dona() async => usuarioTeste;
      final notes = ReaderAnnotations(
        db: db,
        versioning: versioning,
        owner: dona,
        userBookId: idTeste(1),
        anchors: _Anchors(),
        onError: (e, _) => fail('$e'),
      );
      addTearDown(notes.dispose);
      final ink = ReaderInk(
        db: db,
        repository: repo,
        owner: dona,
        userBookId: idTeste(1),
        anchors: _Anchors(),
        annotations: notes,
      );
      addTearDown(ink.dispose);
      await ink.load();
      expect(await repo.draftsOf(usuarioTeste, idTeste(1)), isEmpty);
      // o pen_presets da conta (o padrão, sem linha) e a espessura gravada na hora
      final store = PenPresetsStore(db, versioning, now: () => t);
      final timers = <void Function()>[];
      final s = AnnotationSession(
        geometry: _geometry(),
        anchors: _Anchors(),
        drawings: const [],
        highlights: const [],
        deskHighlights: notes.deskIn((unit: 4, from: 0, to: 27)),
        presets: await store.load(usuarioTeste),
        savePresets: store.save,
        repository: repo,
        owner: usuarioTeste,
        userBookId: idTeste(1),
        startTimer: (d, f) {
          timers.add(f);
          return Timer(Duration.zero, () {});
        },
        now: () => t,
      )..panLimit = 0;
      addTearDown(s.dispose);
      void draw(List<(double, double)> pts, int id) {
        s.pointerDown(_touch(id, pts.first.$1, pts.first.$2, 0));
        for (var i = 1; i < pts.length; i++) {
          s.pointerMove(_touch(id, pts[i].$1, pts[i].$2, 8 * i));
        }
        s.pointerUp(_touch(id, pts.last.$1, pts.last.$2, 8 * pts.length));
      }

      s.setStrokeSize(StrokeSize.thick);
      await pumpEventQueue();
      expect(
        (await PenPresetsDao(db).forUser(usuarioTeste))!.strokeSize,
        StrokeSize.thick,
      );
      // desenhar
      draw([(86, 105), (150, 98), (195, 108), (150, 135), (86, 128)], 1);
      draw([(28, 168), (130, 168)], 2);
      // o rascunho a cada 5 s
      timers.removeAt(0)();
      await pumpEventQueue();
      // apagar e mover com o Laço
      s.setTool(AnnotationTool.eraser);
      draw([(60, 160), (60, 175)], 3);
      s.setTool(AnnotationTool.lasso);
      draw([(80, 90), (200, 90), (200, 170), (80, 170)], 4);
      draw([(150, 130), (150, 190)], 5);
      // o marca-texto sobre "de ressaca" (a linha 1, 30 abaixo no modo)
      s.setTool(AnnotationTool.marker);
      draw([(90, 122), (188, 122)], 6);
      await s.toBackground();
      expect(await s.conclude(), isTrue);
      expect(
        await InkLayersDao(db).liveOverTextForBook(idTeste(1)),
        hasLength(1),
      );
      final grifos = [
        for (final a in await AnnotationsDao(db).forBook(idTeste(1)))
          if (a.kind == AnnotationKind.highlight) a,
      ];
      expect(
        (grifos.single.source, (grifos.single.anchor as EpubAnchor).start),
        (AnnotationSource.ink, 6),
      );
    }, createHttpClient: net.createHttpClient);
    expect(net.created, isEmpty);
  });
}
