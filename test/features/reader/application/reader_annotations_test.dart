// G13.2 — os grifos e as notas do livro aberto: criar (âncora com o sha, citação de 32, página e capítulo da 1ª
// letra, grupo próprio, altura média), achar o lugar (mesmo arquivo; reancoragem; sem lugar não pinta nem apaga —
// D-44), a sobreposição gravada (D-32) com as notas, trocar (também pela D-32), apagar com desfazer, a nota
// (D-131), a nota que vai ficar (D-138), a última cor, os avisos ao pintor e as falhas do banco.
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/application/epub_reader_document.dart';
import 'package:app_leitura/features/reader/application/reader_annotations.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_test/flutter_test.dart';

import '../../../support/load_fonts.dart';
import '../../../support/personal_builders.dart';
import '../../../support/reader_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  late EpubReaderDocument doc;
  late ReaderAnnotations g;
  late List<Object> erros;
  setUp(() async {
    erros = [];
    livro = await LivroNaEstante.domCasmurro();
    await livro.guardarPosicao(2, livro.index.spine[2].chars ~/ 2);
    doc = await EpubReaderDocument.open(livro.deps());
    g = ReaderAnnotations(
      db: livro.db,
      versioning: livro.versioning,
      owner: () async => livro.leitor,
      userBookId: livro.userBookId,
      anchors: doc.anchors,
      onError: (e, _) => erros.add(e),
    );
    await g.load();
  });
  tearDown(() async {
    g.dispose();
    doc.dispose();
    await livro.close();
    expect(erros, isEmpty);
  });

  /// [n] palavras seguidas da página mostrada, pulando as [depois] primeiras.
  ReaderRange palavras(int n, {int depois = 0}) {
    final s = doc.current.shown!;
    final texto = doc.current.textOf(s.unit, s.from, s.to);
    final m = RegExp(
      r'\p{L}+',
      unicode: true,
    ).allMatches(texto).skip(depois).take(n).toList();
    return (
      unit: s.unit,
      from: s.from + m.first.start,
      to: s.from + m.last.end,
    );
  }

  Future<List<Annotation>> vivos() =>
      AnnotationsDao(livro.db).forBook(livro.userBookId);

  test(
    'o PDF não tem âncoras de grifo (D-134); o EPUB tem o sha do índice',
    () {
      expect(doc.anchors.sha, livro.index.contentSha256);
      expect(doc.anchors.textOf(doc.current.shown!.unit), isNotEmpty);
      expect(
        doc.anchors.textOf(9999),
        isNull,
        reason: 'item que não está aberto',
      );
    },
  );

  test('criar: linha do grifo com âncora, citação, página, capítulo, grupo próprio e altura média', () async {
    final r = palavras(3, depois: 6);
    final id = await g.addHighlight(
      r,
      color: '#FED170',
      style: HighlightStyle.fill,
    );
    final a = (await vivos()).single;
    expect(a.id, id);
    expect(
      (a.kind, a.source, a.groupId, a.color, a.style, a.fillHeight),
      (
        AnnotationKind.highlight,
        AnnotationSource.selection,
        id,
        '#FED170',
        HighlightStyle.fill,
        FillHeight.medium,
      ),
    );
    final ancora = a.anchor as EpubAnchor;
    final texto = doc.anchors.textOf(r.unit)!;
    expect(
      (ancora.sha, ancora.spine, ancora.start, ancora.end),
      (doc.anchors.sha, r.unit, r.from, r.to),
    );
    expect(ancora.quote.exact, texto.substring(r.from, r.to));
    expect(ancora.quote.prefix, texto.substring(r.from - 32, r.from));
    expect(ancora.quote.suffix, texto.substring(r.to, r.to + 32));
    final lugar = doc.anchors.placeOf(r.unit, r.from);
    expect(
      (a.refPage, a.chapterIndex, ancora.refPage),
      (lugar.refPage, lugar.chapterIndex, lugar.refPage),
    );
    expect(a.meta.userId, livro.leitor);
    // já relido quando o futuro termina (a barra mostra o grifo novo na hora)
    final pintado = g.highlightsIn(doc.current.shown!).single;
    expect(
      (pintado.id, pintado.range, pintado.color, pintado.style),
      (id, r, const Color(0xFFFED170), HighlightStyle.fill),
    );
  });

  test('trecho vazio ou item que não está aberto: nada', () async {
    final r = palavras(1);
    expect(
      await g.addHighlight(
        (unit: r.unit, from: r.from, to: r.from),
        color: '#FED170',
        style: HighlightStyle.fill,
      ),
      isNull,
    );
    expect(
      await g.addHighlight(
        (unit: 9999, from: 0, to: 4),
        color: '#FED170',
        style: HighlightStyle.fill,
      ),
      isNull,
    );
    expect(await vivos(), isEmpty);
  });

  test('D-32 gravada: mesma cor une; cor diferente no meio divide (direita no mesmo grupo) e leva as notas', () async {
    final a = await g.addHighlight(
      palavras(4),
      color: '#FED170',
      style: HighlightStyle.fill,
    );
    await g.saveNote(a!, 'primeira nota');
    await g.addHighlight(
      palavras(2, depois: 3),
      color: '#FED170',
      style: HighlightStyle.fill,
    );
    var linhas = await vivos();
    expect(
      linhas.where((x) => x.kind == AnnotationKind.highlight),
      hasLength(1),
      reason: 'uniu',
    );
    final unido = linhas.firstWhere((x) => x.id == a);
    expect((unido.anchor as EpubAnchor).end, palavras(5).to);
    await g.addHighlight(
      palavras(1, depois: 2),
      color: '#FFC1C6',
      style: HighlightStyle.fill,
    );
    linhas = await vivos();
    final grifos = linhas
        .where((x) => x.kind == AnnotationKind.highlight)
        .toList();
    expect(grifos, hasLength(3));
    final esquerda = grifos.firstWhere((x) => x.id == a);
    expect((esquerda.anchor as EpubAnchor).end, palavras(1, depois: 2).from);
    final direita = grifos.firstWhere((x) => x.id != a && x.color == '#FED170');
    expect(direita.groupId, unido.groupId);
    expect((direita.anchor as EpubAnchor).start, palavras(1, depois: 2).to);
    expect(direita.fillHeight, FillHeight.medium);
    final nota = linhas.singleWhere((x) => x.kind == AnnotationKind.note);
    expect(nota.parentId, a, reason: 'a nota fica com o pedaço da esquerda');
    expect(nota.anchor, esquerda.anchor, reason: 'e anda com ele');
    // o pintor recebe os 3 na ordem de criação
    expect(g.highlightsIn(doc.current.shown!).map((h) => h.color), [
      const Color(0xFFFED170),
      const Color(0xFFFFC1C6),
      const Color(0xFFFED170),
    ]);
  });

  test('mesma cor unindo dois: o mais novo some e a nota dele vai para o mais antigo', () async {
    final velho = await g.addHighlight(
      palavras(1),
      color: '#FED170',
      style: HighlightStyle.fill,
    );
    final novo = await g.addHighlight(
      palavras(1, depois: 3),
      color: '#FED170',
      style: HighlightStyle.fill,
    );
    await g.saveNote(novo!, 'do novo');
    await g.addHighlight(
      palavras(4),
      color: '#FED170',
      style: HighlightStyle.fill,
    );
    final linhas = await vivos();
    final grifo = linhas.singleWhere((x) => x.kind == AnnotationKind.highlight);
    expect(grifo.id, velho);
    expect((grifo.anchor as EpubAnchor).end, palavras(4).to);
    final nota = linhas.singleWhere((x) => x.kind == AnnotationKind.note);
    expect((nota.parentId, nota.groupId), (velho, velho));
  });

  test(
    'cor diferente cobrindo tudo: o antigo some e a nota passa para o novo',
    () async {
      final a = await g.addHighlight(
        palavras(1, depois: 1),
        color: '#FED170',
        style: HighlightStyle.fill,
      );
      await g.saveNote(a!, 'vai junto');
      final b = await g.addHighlight(
        palavras(3),
        color: '#B6ACE4',
        style: HighlightStyle.fill,
      );
      final linhas = await vivos();
      expect(
        linhas.where((x) => x.kind == AnnotationKind.highlight).single.id,
        b,
      );
      final nota = linhas.singleWhere((x) => x.kind == AnnotationKind.note);
      expect((nota.parentId, nota.groupId), (b, b));
    },
  );

  test('trocar cor e estilo; apagar com a nota e desfazer', () async {
    final a = await g.addHighlight(
      palavras(2),
      color: '#FED170',
      style: HighlightStyle.fill,
    );
    await g.saveNote(a!, 'nota');
    expect(
      await g.restyle(a, color: '#ABCF82', style: HighlightStyle.underline),
      a,
    );
    var grifo = (await vivos()).firstWhere((x) => x.id == a);
    expect(
      (grifo.color, grifo.style, grifo.fillHeight),
      ('#ABCF82', HighlightStyle.underline, null),
    );
    await g.restyle(a, color: '#ABCF82', style: HighlightStyle.fill);
    grifo = (await vivos()).firstWhere((x) => x.id == a);
    expect(grifo.fillHeight, FillHeight.medium);
    final apagado = await g.remove(a);
    expect(await vivos(), isEmpty);
    expect(await g.remove(a), isNull, reason: 'já foi: nada a desfazer');
    expect(
      await g.restyle(a, color: '#FED170', style: HighlightStyle.fill),
      isNull,
    );
    expect(g.highlightsIn(doc.current.shown!), isEmpty);
    expect(g.noteOf(a), isNull);
    await g.restore(apagado!);
    final volta = await vivos();
    expect(
      volta.map((x) => x.kind),
      unorderedEquals([AnnotationKind.highlight, AnnotationKind.note]),
    );
    grifo = volta.firstWhere((x) => x.id == a);
    expect(grifo.meta.deletedAt, isNull);
    expect(grifo.color, '#ABCF82', reason: 'volta como estava ao apagar');
    expect(g.noteOf(a), 'nota');
  });

  test('nota: cria, edita, apaga com texto vazio (o grifo fica)', () async {
    final a = await g.addHighlight(
      palavras(2),
      color: '#FED170',
      style: HighlightStyle.fill,
    );
    await g.saveNote(a!, '  olhos  ');
    expect(g.noteOf(a), 'olhos');
    final nota = (await vivos()).singleWhere(
      (x) => x.kind == AnnotationKind.note,
    );
    final grifo = (await vivos()).singleWhere(
      (x) => x.kind == AnnotationKind.highlight,
    );
    expect(
      (nota.parentId, nota.groupId, nota.anchor, nota.refPage),
      (a, grifo.groupId, grifo.anchor, grifo.refPage),
    );
    await g.saveNote(a, 'outra');
    expect(g.noteOf(a), 'outra');
    expect(
      (await vivos()).where((x) => x.kind == AnnotationKind.note),
      hasLength(1),
      reason: 'edita a mesma',
    );
    await g.saveNote(a, '   ');
    expect(g.noteOf(a), isNull);
    expect((await vivos()).single.kind, AnnotationKind.highlight);
    await g.saveNote(idTeste(99), 'sem grifo');
    expect((await vivos()), hasLength(1), reason: 'grifo que não existe: nada');
  });

  test('outro arquivo: acha pela citação; sem a citação no texto, não pinta e não apaga (D-44)', () async {
    final r = palavras(3);
    final texto = doc.anchors.textOf(r.unit)!;
    Annotation grifo(String id, String exato, int deslocado) => Annotation(
      id: id,
      meta: metaTeste(),
      userBookId: livro.userBookId,
      kind: AnnotationKind.highlight,
      groupId: id,
      anchor: EpubAnchor(
        sha: 'f' * 64,
        spine: r.unit,
        start: r.from + deslocado,
        end: r.to + deslocado,
        quote: TextQuote(exact: exato),
        refPage: 1,
      ),
      refPage: 1,
      chapterIndex: 0,
      color: '#FED170',
      style: HighlightStyle.fill,
    );
    await AnnotationsDao(livro.db)
        .upsert(grifo(idTeste(1), texto.substring(r.from, r.to), 40));
    await AnnotationsDao(livro.db)
        .upsert(grifo(idTeste(2), 'xyzzy não existe', 0));
    await pumpEventQueue();
    final pintados = g.highlightsIn(doc.current.shown!);
    expect(pintados.map((h) => h.range), [r]);
    expect(await vivos(), hasLength(2));
  });

  test(
    'última cor: amarelo sem histórico; guarda a escolhida no aparelho',
    () async {
      expect(await g.lastColor(), '#FED170');
      await g.setLastColor('#FFC1C6');
      expect(await g.lastColor(), '#FFC1C6');
      expect(await KvDao(livro.db).get(lastHighlightColorKey), '#FFC1C6');
      await KvDao(livro.db).set(lastHighlightColorKey, 'lixo');
      expect(await g.lastColor(), '#FED170', reason: 'valor estranho');
    },
  );

  test('o grifo sob o dedo: o mais novo que contém o ponto', () async {
    final r = palavras(3);
    final a = await g.addHighlight(
      r,
      color: '#FED170',
      style: HighlightStyle.fill,
    );
    expect(g.highlightAt((unit: r.unit, offset: r.from))?.id, a);
    expect(g.highlightAt((unit: r.unit, offset: r.to - 1))?.id, a);
    expect(g.highlightAt((unit: r.unit, offset: r.to)), isNull);
    expect(g.highlightAt((unit: r.unit + 1, offset: r.from)), isNull);
    expect(g.byId(a!)?.color, '#FED170');
  });

  test(
    'mudança vinda de fora (outro aparelho) relê e avisa o pintor',
    () async {
      var avisos = 0;
      g.addListener(() => avisos++);
      final r = palavras(2);
      await AnnotationsDao(livro.db).upsert(
        Annotation(
          id: idTeste(3),
          meta: metaTeste(),
          userBookId: livro.userBookId,
          kind: AnnotationKind.highlight,
          groupId: idTeste(3),
          anchor: EpubAnchor(
            sha: livro.index.contentSha256,
            spine: r.unit,
            start: r.from,
            end: r.to,
            quote: const TextQuote(exact: 'x'),
            refPage: 1,
          ),
          refPage: 1,
          chapterIndex: 0,
          color: '#ABCF82',
          style: HighlightStyle.underline,
        ),
      );
      await pumpEventQueue();
      expect(avisos, greaterThanOrEqualTo(1));
      expect(
        g.highlightsIn(doc.current.shown!).single.style,
        HighlightStyle.underline,
      );
    },
  );

  test('trocar passa pela D-32: encostando num da cor nova, viram um (fica o mais antigo) e a nota vai junto', () async {
    final r1 = palavras(2);
    final r2 = (unit: r1.unit, from: r1.to, to: palavras(2, depois: 2).to);
    final a = await g.addHighlight(
      r1,
      color: '#FED170',
      style: HighlightStyle.fill,
    );
    final b = await g.addHighlight(
      r2,
      color: '#FFC1C6',
      style: HighlightStyle.fill,
    );
    await g.saveNote(b!, 'do rosa');
    expect(
      (await vivos()).where((x) => x.kind == AnnotationKind.highlight),
      hasLength(2),
    );
    expect(
      await g.restyle(b, color: '#FED170', style: HighlightStyle.fill),
      a,
      reason: 'b encosta em a e vira amarelo: fica a, o mais antigo',
    );
    final linhas = await vivos();
    final grifo = linhas.singleWhere((x) => x.kind == AnnotationKind.highlight);
    final ancora = grifo.anchor as EpubAnchor;
    expect((grifo.id, ancora.start, ancora.end), (a, r1.from, r2.to));
    final nota = linhas.singleWhere((x) => x.kind == AnnotationKind.note);
    expect((nota.parentId, nota.anchor), (a, grifo.anchor));
    // virar sublinhado não une com nada: só ele, no lugar
    expect(
      await g.restyle(a!, color: '#FED170', style: HighlightStyle.underline),
      a,
    );
    final sub = (await vivos()).singleWhere(
      (x) => x.kind == AnnotationKind.highlight,
    );
    expect(
      (sub.style, sub.fillHeight, (sub.anchor as EpubAnchor).end),
      (HighlightStyle.underline, null, r2.to),
    );
  });

  test('D-138: a nota que vai ficar no grifo novo é a mais antiga dos que ele une ou cobre inteiros', () async {
    const amarelo = '#FED170';
    const fundo = HighlightStyle.fill;
    expect(
      await g.notePreview(palavras(4), color: amarelo, style: fundo),
      isNull,
      reason: 'sem grifos',
    );
    final a = await g.addHighlight(palavras(1), color: amarelo, style: fundo);
    final b = await g.addHighlight(
      palavras(1, depois: 2),
      color: amarelo,
      style: fundo,
    );
    await g.saveNote(b!, 'de b');
    await g.saveNote(a!, 'de a');
    expect(
      await g.notePreview(palavras(4), color: amarelo, style: fundo),
      'de b',
      reason: 'une a e b: a nota mais antiga',
    );
    expect(
      await g.notePreview(palavras(4), color: '#B6ACE4', style: fundo),
      'de b',
      reason: 'outra cor cobrindo os dois inteiros: as notas vêm para o novo',
    );
    final pa = palavras(1);
    expect(
      await g.notePreview(
        (unit: pa.unit, from: pa.from + 1, to: pa.to),
        color: '#B6ACE4',
        style: fundo,
      ),
      isNull,
      reason: 'a só encolhe: fica com a sua',
    );
    expect(
      await g.notePreview(
        (unit: pa.unit, from: pa.from, to: pa.from),
        color: amarelo,
        style: fundo,
      ),
      isNull,
      reason: 'trecho vazio',
    );
    expect(
      await g.notePreview(
        (unit: 9999, from: 0, to: 4),
        color: amarelo,
        style: fundo,
      ),
      isNull,
      reason: 'item que não está aberto',
    );
    // Salvar: grifa (une em a) e edita a nota que a folha mostrou
    final id = await g.addHighlight(palavras(4), color: amarelo, style: fundo);
    expect(id, a);
    expect(g.noteOf(a), 'de b', reason: 'a mais antiga das duas');
    expect(await g.saveNote(id!, 'editada'), isTrue);
    expect(g.noteOf(a), 'editada');
    expect(
      (await vivos())
          .where((x) => x.kind == AnnotationKind.note)
          .map((x) => x.noteText),
      unorderedEquals(['editada', 'de a']),
    );
  });

  test('um grifo de outro item do livro não pinta nesta página', () async {
    final r = palavras(2);
    await AnnotationsDao(livro.db).upsert(
      Annotation(
        id: idTeste(5),
        meta: metaTeste(),
        userBookId: livro.userBookId,
        kind: AnnotationKind.highlight,
        groupId: idTeste(5),
        anchor: EpubAnchor(
          sha: livro.index.contentSha256,
          spine: r.unit + 1,
          start: r.from,
          end: r.to,
          quote: const TextQuote(exact: 'x'),
          refPage: 1,
        ),
        refPage: 1,
        chapterIndex: 0,
        color: '#FED170',
        style: HighlightStyle.fill,
      ),
    );
    await pumpEventQueue();
    expect(g.highlightsIn(doc.current.shown!), isEmpty);
    expect(g.highlightAt((unit: r.unit, offset: r.from)), isNull);
  });

  test('grifos que se cruzam (de outro aparelho): o pintor recebe na ordem de criação; o toque pega o mais novo', () async {
    final r = palavras(3);
    Annotation grifo(int n, int segundos, int de, String cor) => Annotation(
      id: idTeste(n),
      meta: metaTeste(em: t0Teste.add(Duration(seconds: segundos))),
      userBookId: livro.userBookId,
      kind: AnnotationKind.highlight,
      groupId: idTeste(n),
      anchor: EpubAnchor(
        sha: livro.index.contentSha256,
        spine: r.unit,
        start: r.from + de,
        end: r.to,
        quote: const TextQuote(exact: 'x'),
        refPage: 1,
      ),
      refPage: 1,
      chapterIndex: 0,
      color: cor,
      style: HighlightStyle.fill,
    );
    final dao = AnnotationsDao(livro.db);
    await dao.upsert(grifo(2, 0, 2, '#FED170'));
    await dao.upsert(grifo(1, 1, 0, '#FFC1C6'));
    // mesma hora: o id desempata
    await dao.upsert(grifo(4, 2, 1, '#ABCF82'));
    await dao.upsert(grifo(3, 2, 3, '#B6ACE4'));
    await pumpEventQueue();
    expect(g.highlightsIn(doc.current.shown!).map((h) => h.id), [
      idTeste(2),
      idTeste(1),
      idTeste(3),
      idTeste(4),
    ]);
    expect(g.highlightAt((unit: r.unit, offset: r.from + 3))?.id, idTeste(4));
    expect(g.highlightAt((unit: r.unit, offset: r.from))?.id, idTeste(1));
  });

  test('só avisa o pintor quando as linhas mudam; os grifos do trecho ficam guardados até lá', () async {
    final a = await g.addHighlight(
      palavras(2),
      color: '#FED170',
      style: HighlightStyle.fill,
    );
    final shown = doc.current.shown!;
    final antes = g.highlightsIn(shown);
    expect(identical(g.highlightsIn(shown), antes), isTrue, reason: 'guardado');
    var avisos = 0;
    g.addListener(() => avisos++);
    expect(await g.saveNote(idTeste(99), 'sem grifo'), isTrue);
    expect(avisos, 0, reason: 'releu e nada mudou');
    expect(identical(g.highlightsIn(shown), antes), isTrue);
    await g.restyle(a!, color: '#FFC1C6', style: HighlightStyle.fill);
    expect(avisos, greaterThanOrEqualTo(1));
    final depois = g.highlightsIn(shown);
    expect(identical(depois, antes), isFalse);
    expect(depois.single.color, const Color(0xFFFFC1C6));
  });

  test('falhas do banco: relatadas, sem quebrar a leitura', () async {
    final r = palavras(2);
    // um banco que não abre: toda consulta falha
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    addTearDown(
      () => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false,
    );
    final morto = AppDatabase(
      NativeDatabase.memory(setup: (_) => throw StateError('sem banco')),
      withSyncQueue: false,
    );
    addTearDown(morto.close);
    final falhas = <Object>[];
    final h = ReaderAnnotations(
      db: morto,
      versioning: LocalVersioning(morto, HlcClock(deviceId: 'aparelhoA')),
      owner: () async => livro.leitor,
      userBookId: livro.userBookId,
      anchors: doc.anchors,
      onError: (e, _) => falhas.add(e),
    );
    Future<T> relata<T>(Future<T> Function() f) async {
      final n = falhas.length;
      final v = await f();
      expect(falhas.length, greaterThan(n));
      return v;
    }

    expect(await relata(h.lastColor), '#FED170', reason: 'amarelo');
    await relata(() => h.setLastColor('#FFC1C6'));
    expect(
      await relata(
        () => h.addHighlight(r, color: '#FED170', style: HighlightStyle.fill),
      ),
      isNull,
    );
    expect(
      await relata(
        () =>
            h.restyle(idTeste(1), color: '#FED170', style: HighlightStyle.fill),
      ),
      isNull,
    );
    expect(await relata(() => h.remove(idTeste(1))), isNull);
    expect(await relata(() => h.saveNote(idTeste(1), 'x')), isFalse);
    expect(
      await relata(
        () => h.notePreview(r, color: '#FED170', style: HighlightStyle.fill),
      ),
      isNull,
    );
    await relata(h.load);
    h.dispose();
  });

  test('hexColor: "#RRGGBB" vira a cor opaca', () {
    expect(hexColor('#FED170'), const Color(0xFFFED170));
    expect(hexColor('#1F1B17'), const Color(0xFF1F1B17));
  });
}
