// G16.5 — a tinta salva para o leitor (§4, §5): o desenho aparece na página do começo do trecho (e não na seguinte),
// na moldura em em — com outra fonte, estica na horizontal para cobrir as mesmas palavras e fica em em na vertical
// (D-162) —; o desenho sem lugar não aparece e continua no banco (D-44, D-169); a tinta relê quando as tabelas
// mudam; o rascunho de uma sessão "morta" é gravado ao abrir o livro (D-166) e, se falhar, a chave fica e a falha
// vai ao relatório; os grifos feitos à mão saem pelo `inkHighlightsIn` (D-161) e os de seleção não.
import 'dart:ui' as ui;

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/ink_layer.dart';
import 'package:app_leitura/features/reader/annotations/ink/bnk1_codec.dart';
import 'package:app_leitura/features/reader/annotations/ink/drawing_anchor.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_changes.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/annotations/ink_repository.dart';
import 'package:app_leitura/features/reader/application/annotation_anchors.dart';
import 'package:app_leitura/features/reader/application/reader_annotations.dart';
import 'package:app_leitura/features/reader/application/reader_ink.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/personal_builders.dart';

const _text = 'Olhos de ressaca? Vá, de ressaca. É o que me dá ideia';
const _spine = 32;

/// Uma página de uma linha que mostra o item de [de] até [ate]: cada letra ocupa [letra] px a partir de x = 28; a
/// linha de base em y = 129,6; a letra [em] (com [emDoMeio], o que começa da letra 9 em diante tem outra — um
/// trecho em outro tamanho no meio da linha).
final class _Pagina implements DisplayPage {
  _Pagina({
    this.letra = 10,
    this.em = 20.5,
    this.de = 0,
    this.ate = _text.length,
    this.emDoMeio,
  });

  final double letra;
  final double em;
  final int de;
  final int ate;
  final double? emDoMeio;
  static const double x0 = 28;
  static const double base = 129.6;

  @override
  bool get alive => true;
  @override
  bool get opaque => false;
  @override
  String get spokenText => _text;
  @override
  LinkHit? linkAt(ui.Offset p) => null;
  @override
  void paint(ui.Canvas canvas) {}
  @override
  List<ui.Rect> rectsOf(int unit, int from, int to) => [
    for (final b in boxesOf(unit, from, to)) b.rect,
  ];
  @override
  ReaderRange? get shown => (unit: _spine, from: de, to: ate);
  @override
  ReaderSpot? spotAt(ui.Offset p) => null;
  @override
  ReaderRange? wordAround(ReaderSpot s) => null;
  @override
  ReaderRange? wordAt(ui.Offset p) => null;
  @override
  List<TextLineBox> boxesOf(int unit, int from, int to) {
    final a = from < de ? de : from;
    final b = to > ate ? ate : to;
    if (unit != _spine || a >= b) return const [];
    return [
      (
        rect: ui.Rect.fromLTRB(
          x0 + letra * a,
          base - 29.6,
          x0 + letra * b,
          base + 5.66,
        ),
        baseline: base,
        textTop: base - 27,
        textBottom: base + 3,
        em: a >= 9 ? emDoMeio ?? em : em,
      ),
    ];
  }

  @override
  String textOf(int unit, int from, int to) => _text.substring(from, to);
}

final class _Anchors implements AnnotationAnchors {
  @override
  String get sha => shaTeste;
  @override
  String? textOf(int spine) => spine == _spine ? _text : null;
  @override
  ({int refPage, int chapterIndex}) placeOf(int spine, int offset) =>
      (refPage: 159, chapterIndex: 31);
}

EpubAnchor _range(int from, int to, {String? sha, String? exato}) => EpubAnchor(
  sha: sha ?? shaTeste,
  spine: _spine,
  start: from,
  end: to,
  quote: TextQuote(exact: exato ?? _text.substring(from, to)),
  refPage: 159,
);

/// O traço do desenho, em em a partir do começo de "Olhos de ressaca?" (largura 170 px ÷ 20,5 na criação).
const _emStroke = InkStroke(
  tool: 1,
  tip: 0,
  argb: 0xFFFF552E,
  widthCentiMm: 125,
  points: [InkPoint(-0.5, -1.2, 0.5, 0), InkPoint(8.5, 0.4, 0.5, 8)],
);

final double _w = 170 / 20.5;

void main() {
  late AppDatabase db;
  late LocalVersioning versioning;
  late DriftInkRepository repo;
  late ReaderAnnotations annotations;
  late ReaderInk ink;
  late List<Object> errors;
  final t = DateTime.utc(2026, 10, 8, 10);

  Future<String> owner() async => usuarioTeste;

  Future<void> saveDrawing(int n, EpubAnchor range, {double? w}) async {
    final layer = InkLayer(
      id: idTeste(n),
      meta: metaTeste(),
      userBookId: idTeste(1),
      kind: InkLayerKind.overText,
      anchor: inkLayerAnchor(range, w ?? _w),
      strokesB64: encodeStrokesB64(const [_emStroke], Bnk1Unit.em),
      strokeCount: 1,
    );
    await InkLayersDao(db).upsert(layer);
    await AnnotationsDao(db).upsert(
      Annotation(
        id: idTeste(n + 1),
        meta: metaTeste(),
        userBookId: idTeste(1),
        kind: AnnotationKind.drawing,
        groupId: idTeste(n + 1),
        source: AnnotationSource.ink,
        anchor: range,
        refPage: 159,
        chapterIndex: 31,
        color: '#FF552E',
        inkLayerId: layer.id,
      ),
    );
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    versioning = LocalVersioning(
      db,
      HlcClock(deviceId: 'aparelhoA', nowMs: () => t.millisecondsSinceEpoch),
    );
    errors = [];
    repo = DriftInkRepository(
      db,
      versioning,
      now: () => t,
      onError: (e, _) => errors.add(e),
    );
    annotations = ReaderAnnotations(
      db: db,
      versioning: versioning,
      owner: owner,
      userBookId: idTeste(1),
      anchors: _Anchors(),
      onError: (e, _) => errors.add(e),
    );
    ink = ReaderInk(
      db: db,
      repository: repo,
      owner: owner,
      userBookId: idTeste(1),
      anchors: _Anchors(),
      annotations: annotations,
      onError: (e, _) => errors.add(e),
    );
  });
  tearDown(() async {
    ink.dispose();
    annotations.dispose();
    await db.close();
  });

  test('o desenho aparece na página do começo do trecho, na moldura em em (k = 1 na fonte da criação)', () async {
    await saveDrawing(10, _range(0, 17));
    await annotations.load();
    await ink.load();
    final d = ink.drawingsOn(_Pagina()).single;
    expect(d.saved.layerId, idTeste(10));
    expect(d.saved.annotationId, idTeste(11));
    expect(d.saved.groupId, idTeste(11));
    expect(d.saved.createdAt, metaTeste().createdAt);
    expect(d.range, (unit: _spine, from: 0, to: 17));
    final p = d.strokes.single.points;
    // a largura do trecho vai à âncora com 4 casas (k ≈ 1 − 1e-5): uma fração de px na horizontal
    expect(p.first.x, closeTo(28 - 0.5 * 20.5, 1e-3));
    expect(p.first.y, closeTo(129.6 - 1.2 * 20.5, 1e-9));
    expect(p.last.x, closeTo(28 + 8.5 * 20.5, 1e-3));
    expect(d.strokes.single.widthCentiMm, 125);
    // a página seguinte (o trecho começa antes dela) não pinta o desenho
    expect(ink.drawingsOn(_Pagina(de: 18)), isEmpty);
  });

  test('outra fonte: estica na horizontal (as mesmas palavras) e fica em em na vertical (D-162)', () async {
    await saveDrawing(10, _range(0, 17));
    await ink.load();
    final d = ink.drawingsOn(_Pagina(letra: 12, em: 24)).single;
    final k = (17 * 12 / 24) / _w;
    final p = d.strokes.single.points;
    // (a largura vai à âncora com 4 casas: 1e-3 px na horizontal)
    expect(p.first.x, closeTo(28 - 0.5 * 24 * k, 1e-3));
    expect(p.first.y, closeTo(129.6 - 1.2 * 24, 1e-9));
    expect(p.last.x, closeTo(28 + 8.5 * 24 * k, 1e-3));
    // k ≠ 1 de verdade: 12/24 por letra contra 10/20,5 na criação
    expect(k, closeTo(1.0250, 1e-3));
  });

  test('o trecho que passou para a página seguinte não estica sobre o pedaço que ficou (k = 1, Anexo 03 §9.5)', () async {
    await saveDrawing(10, _range(0, 17));
    await ink.load();
    // a página acaba no meio de "ressaca?" (o trecho segue na próxima)
    final d = ink.drawingsOn(_Pagina(ate: 10)).single;
    final p = d.strokes.single.points;
    expect(p.first.x, closeTo(28 - 0.5 * 20.5, 1e-9));
    expect(p.last.x, closeTo(28 + 8.5 * 20.5, 1e-9));
  });

  test('a moldura usa o em da linha, como na criação: um trecho em outro tamanho não estica na vertical', () async {
    // "ressaca?" (9…17) com a letra menor; a linha tem a letra de 20,5 (a 1ª caixa dela)
    await saveDrawing(10, _range(9, 17), w: 80 / 20.5);
    await ink.load();
    final d = ink.drawingsOn(_Pagina(emDoMeio: 15)).single;
    final p = d.strokes.single.points;
    expect(p.first.y, closeTo(129.6 - 1.2 * 20.5, 1e-9));
    expect(p.last.y, closeTo(129.6 + 0.4 * 20.5, 1e-9));
    // na horizontal o k compensa: as mesmas palavras
    expect(p.first.x, closeTo(28 + 90 - 0.5 * 20.5, 1e-3));
  });

  test('outro arquivo: reancora pelo trecho; sem lugar, não aparece e continua no banco (D-44, D-169)', () async {
    await saveDrawing(
      10,
      _range(40, 57, sha: shaDoLivroTeste(2), exato: 'Olhos de ressaca?'),
    );
    await saveDrawing(
      20,
      _range(
        0,
        17,
        sha: shaDoLivroTeste(2),
        exato: '‹antes da sessão de hoje›',
      ),
    );
    await ink.load();
    final shown = ink.drawingsOn(_Pagina());
    expect(shown.single.saved.layerId, idTeste(10));
    expect(shown.single.range, (unit: _spine, from: 0, to: 17));
    expect(await repo.drawingsOfBook(idTeste(1)), hasLength(2));
  });

  test(
    'relê quando a tinta muda no banco; a revisão sobe e avisa o pintor',
    () async {
      await ink.load();
      var avisos = 0;
      ink.addListener(() => avisos++);
      final r0 = ink.revision;
      expect(ink.drawingsOn(_Pagina()), isEmpty);
      await saveDrawing(10, _range(0, 17));
      await pumpEventQueue();
      expect(ink.revision, greaterThan(r0));
      expect(avisos, greaterThan(0));
      expect(ink.drawingsOn(_Pagina()), hasLength(1));
    },
  );

  test('o rascunho de uma sessão que morreu é gravado ao abrir o livro e a chave some (D-166)', () async {
    final range = _range(0, 17);
    await repo.saveDraft(
      usuarioTeste,
      idTeste(1),
      InkChanges(
        layers: [
          DrawingRow(
            layerId: idTeste(30),
            annotationId: idTeste(31),
            createdAt: t,
            anchor: inkLayerAnchor(range, _w),
            range: range,
            refPage: 159,
            chapterIndex: 31,
            groupId: idTeste(31),
            color: '#FF552E',
            strokesB64: encodeStrokesB64(const [_emStroke], Bnk1Unit.em),
            strokeCount: 1,
          ),
        ],
      ),
      session: 's1',
    );
    await ink.load();
    expect(
      await KvDao(db).get(draftKey(usuarioTeste, idTeste(1), 's1')),
      isNull,
    );
    expect(ink.drawingsOn(_Pagina()).single.saved.layerId, idTeste(30));
  });

  test('o rascunho que não grava fica no kv e a falha vai ao relatório, sem conteúdo', () async {
    await KvDao(db).set(draftKey(usuarioTeste, idTeste(1), 's1'), 'lixo');
    await ink.load();
    expect(
      await KvDao(db).get(draftKey(usuarioTeste, idTeste(1), 's1')),
      'lixo',
    );
    expect(errors.single, isA<InkDraftNotRecovered>());
  });

  test('os grifos feitos à mão saem pelo inkHighlightsIn (D-161); os de seleção, só pelo highlightsIn', () async {
    final aMao = grifoTeste(
      40,
      livro: idTeste(1),
      exato: 'Olhos de ressaca?',
      fonte: AnnotationSource.ink,
    ).copyWith(anchor: _range(0, 17));
    final deSelecao = grifoTeste(
      42,
      livro: idTeste(1),
      exato: 'o que me dá',
    ).copyWith(anchor: _range(37, 48));
    await AnnotationsDao(db).upsert(aMao);
    await AnnotationsDao(db).upsert(deSelecao);
    await annotations.load();
    await ink.load();
    const shown = (unit: _spine, from: 0, to: _text.length);
    expect([for (final h in ink.inkHighlightsIn(shown)) h.id], [aMao.id]);
    expect(
      [for (final h in annotations.highlightsIn(shown)) h.id],
      [deSelecao.id],
    );
    expect(ink.inkHighlightsIn(shown).single.range, (
      unit: _spine,
      from: 0,
      to: 17,
    ));
  });

  test('a camada com BNK1 quebrado não derruba a página: some e a falha vai ao relatório', () async {
    await saveDrawing(10, _range(0, 17));
    final l = (await InkLayersDao(db).byIds([idTeste(10)])).single;
    await InkLayersDao(db).upsert(
      l.copyWith(
        strokesB64: 'Qk5LMQIA',
        meta: RecordMeta(
          userId: usuarioTeste,
          createdAt: l.meta.createdAt,
          updatedAt: l.meta.updatedAt,
          version: Hlc(l.meta.version.ms + 1, 0, 'aparelhoA'),
        ),
      ),
    );
    await ink.load();
    expect(ink.drawingsOn(_Pagina()), isEmpty);
    expect(errors.single, isA<Bnk1Failure>());
  });
}
