// G10.2/G10.3 — as páginas do livro aberto, com o Dom Casmurro real: abre na página que contém a posição,
// vira página atravessando capítulos (para frente e para trás), repagina mantendo o 1º caractere visível
// quando os ajustes ou a tela mudam, e com o cache de páginas a página da posição aparece antes do resto do
// capítulo — igual à do layout completo. Mede o tempo até a 1ª página (Anexo 03 §12: < 600 ms). Revisão da
// G10: aberturas, viradas e mudanças de ajustes que se cruzam no tempo (com a carga dos capítulos na ordem que
// o teste quer) — a mais nova vale, nada fica esperando para sempre e a página na tela continua pintável.
import 'dart:async';
import 'dart:ui' as ui;

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/features/reader/application/book_pager.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/chapter_content.dart';
import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:app_leitura/features/reader/layout/chapter_layout.dart';
import 'package:app_leitura/features/reader/layout/layout_scheduler.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/load_fonts.dart';
import '../../../support/medida.dart';
import '../../../support/personal_builders.dart';

const String _arquivo = 'test/fixtures/livros/pg55752.epub';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);
  late BookIndex index;
  setUpAll(() => index = indexEpubFile(_arquivo, 'e' * 64));
  // a 1ª vez que o Skia usa a fonte custa dezenas de ms: aquece antes de medir
  setUpAll(() {
    final livro = EpubBook.open(_arquivo);
    ChapterLayoutJob(
      chapterOf(livro, 4),
      const ReaderTypography(),
    ).runAll().dispose();
    livro.close();
  });

  BookPager novo({
    ReaderTypography t = const ReaderTypography(),
    PagerCacheKey? cache,
  }) {
    final p = BookPager(
      index: index,
      load: isolateChapterLoader(_arquivo),
      typography: t,
      scheduler: LayoutScheduler(),
      cache: cache,
    );
    addTearDown(p.dispose);
    return p;
  }

  /// A página atual contém o caractere [offset]: começa nele ou antes, e a seguinte começa depois.
  Future<void> contem(BookPager p, int offset) async {
    final pos = p.position!;
    expect(pos.page.start, lessThanOrEqualTo(offset));
    final layout = await p.settle();
    final i = p.position!.pageIndex!;
    if (i + 1 < layout!.pages.length) {
      final ps = layout.pages;
      expect(
        ps[i + 1].start,
        greaterThan(offset),
        reason:
            'página $i (${pos.pageIndex}) ${pos.page.start}-${pos.page.end} · '
            'no layout: ${[for (var k = i - 1; k <= i + 2 && k < ps.length; k++)
              if (k >= 0) '$k:${ps[k].start}-${ps[k].end}'].join(' ')} · '
            'pageAt = ${layout.pageAt(offset)}',
      );
    }
  }

  test('abre na página da posição; mede o tempo até a 1ª página', () async {
    final p = novo();
    final alvo = index.spine[2].chars ~/ 2;
    final sw = Stopwatch()..start();
    final pos = await p.openAt(2, alvo);
    final ms = sw.elapsedMilliseconds;
    expect(pos.spine, 2);
    await contem(p, alvo);
    // ignore: avoid_print
    print(
      'G10.2 abrir o Dom Casmurro no meio do item 2 até a 1ª página: $ms ms (sem cache)',
    );
    expect(ms, lessThan(orcamento(600, folga: 3000)), reason: 'Anexo 03 §12');
  });

  test('virar página: para frente atravessa para o capítulo seguinte; para trás, para a última do anterior', () async {
    final p = novo();
    await p.openAt(1, index.spine[1].chars - 1); // última página do item 1
    final ultima = (await p.settle())!;
    expect(p.position!.pageIndex, ultima.pages.length - 1);
    expect(await p.next(), isTrue);
    expect(
      (p.position!.spine, p.position!.pageIndex, p.position!.firstVisible),
      (2, 0, 0),
    );
    expect(await p.next(), isTrue);
    expect(p.position!.pageIndex, 1);
    expect(await p.previous(), isTrue);
    expect(await p.previous(), isTrue);
    expect(
      (p.position!.spine, p.position!.pageIndex),
      (1, ultima.pages.length - 1),
    );
    // começo e fim do livro
    await p.openAt(p.firstSpine, 0);
    expect(await p.previous(), isFalse);
    final ultimo = index.spine.lastIndexWhere((s) => s.linear);
    await p.openAt(ultimo, index.spine[ultimo].chars);
    await p.settle();
    expect(await p.next(), isFalse);
  });

  test(
    'ajustes e tela mudam: repagina e o mesmo 1º caractere continua na página',
    () async {
      final p = novo();
      final pos = await p.openAt(2, 30000);
      await p.settle();
      final primeiro = p.position!.firstVisible;
      expect(primeiro, lessThanOrEqualTo(30000));
      // como ao reabrir na posição guardada: o 1º caractere visível
      await p.openAt(2, primeiro);
      expect(p.anchor, (spine: 2, offset: primeiro));
      final original = p.position!.page;
      // várias mudanças seguidas: volta sempre ao mesmo caractere (não ao começo da página anterior, que
      // andaria para trás a cada mudança)
      for (final t in const [
        ReaderTypography(fontSize: 26),
        ReaderTypography(fontSize: 16, lineSpacing: 1.5, sideMargin: 20),
        ReaderTypography(viewportWidth: 360, viewportHeight: 780),
        ReaderTypography(fontSize: 26),
      ]) {
        final novoPos = await p.relayout(t);
        expect(novoPos.spine, pos.spine);
        await contem(p, primeiro);
        expect(p.anchor, (spine: 2, offset: primeiro));
      }
      // de volta aos ajustes do começo: a mesma página
      await p.relayout(const ReaderTypography());
      expect(
        (p.position!.page.start, p.position!.page.end),
        (original.start, original.end),
      );

      // virar a página muda o caractere que a pessoa está lendo
      expect(await p.next(), isTrue);
      final virada = p.position!.firstVisible;
      expect(p.anchor, (spine: 2, offset: virada));
      await p.relayout(const ReaderTypography(fontSize: 26));
      await contem(p, virada);
    },
  );

  test('cache de páginas: a página da posição sai sozinha, igual à do layout completo', () async {
    final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    addTearDown(db.close);
    final chave = PagerCacheKey(
      userBookId: idTeste(1),
      devicePixelRatio: 3,
      dao: PageLayoutCacheDao(db),
    );
    expect(viewportKey(const ReaderTypography(), 3), '390x844@3');
    final primeiro = novo(cache: chave);
    final alvo = index.spine[3].chars ~/ 3;
    await primeiro.openAt(3, alvo);
    final layout = (await primeiro.settle())!;
    final esperado = primeiro.position!;
    // o cache foi gravado depois que o capítulo terminou
    for (
      var i = 0;
      i < 50 &&
          (await chave.dao.get(
                userBookId: idTeste(1),
                settingsHash: primeiro.settingsHash,
                viewport: viewportKey(const ReaderTypography(), 3),
                fontsVersion: readerFontsVersion,
              )) ==
              null;
      i++
    ) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    final gravado = (await chave.dao.get(
      userBookId: idTeste(1),
      settingsHash: primeiro.settingsHash,
      viewport: viewportKey(const ReaderTypography(), 3),
      fontsVersion: readerFontsVersion,
    ))!;
    expect(gravado.chapters[3], layout.pageStarts);
    expect(gravado.sha, 'e' * 64);

    final segundo = novo(cache: chave);
    final sw = Stopwatch()..start();
    final rapida = await segundo.openAt(3, alvo);
    final ms = sw.elapsedMilliseconds;
    expect(
      rapida.pageIndex,
      isNull,
      reason: 'veio do cache, antes do resto do capítulo',
    );
    expect(
      (rapida.page.start, rapida.page.end),
      (esperado.page.start, esperado.page.end),
    );
    await segundo.settle();
    expect(segundo.position!.pageIndex, esperado.pageIndex);
    // ignore: avoid_print
    print('G10.2 abrir com o cache de páginas até a 1ª página: $ms ms');

    // outro arquivo (sha diferente): o cache não vale
    final outroIndex = indexEpubFile(_arquivo, 'f' * 64);
    final terceiro = BookPager(
      index: outroIndex,
      load: isolateChapterLoader(_arquivo),
      typography: const ReaderTypography(),
      scheduler: LayoutScheduler(),
      cache: chave,
    );
    addTearDown(terceiro.dispose);
    expect((await terceiro.openAt(3, alvo)).pageIndex, isNotNull);
  });

  group('concorrência (revisão da G10)', () {
    late EpubBook livro;
    setUp(() {
      livro = EpubBook.open(_arquivo);
      addTearDown(livro.close);
    });

    /// Livro cuja carga de capítulos o teste solta na ordem que quiser.
    ({BookPager p, LayoutScheduler s, void Function(int) solta}) controlado() {
      final pendentes = <int, Completer<ChapterContent>>{};
      final s = LayoutScheduler();
      final p = BookPager(
        index: index,
        load: (spine) =>
            (pendentes[spine] = Completer<ChapterContent>()).future,
        typography: const ReaderTypography(),
        scheduler: s,
      );
      addTearDown(p.dispose);
      void solta(int spine) {
        final c = pendentes[spine];
        if (c != null && !c.isCompleted) c.complete(chapterOf(livro, spine));
      }

      return (p: p, s: s, solta: solta);
    }

    void pinta(BookPager p) {
      final rec = ui.PictureRecorder();
      p.paintCurrent(ui.Canvas(rec));
      rec.endRecording().dispose();
    }

    test('abertura atrasada não troca a página de uma mais nova', () async {
      final (:p, :s, :solta) = controlado();
      final antiga = p.openAt(3, 0);
      final nova = p.openAt(1, 0);
      solta(1);
      expect((await nova).spine, 1);
      solta(3);
      expect((await antiga).spine, 1, reason: 'a superada devolve a mais nova');
      expect((p.position!.spine, p.anchor!.spine), (1, 1));
      pinta(p);
    });

    test('abrir longe enquanto a anterior espera a página: o capítulo descartado não vira "vazio"', () async {
      final (:p, :s, :solta) = controlado();
      final a = p.openAt(
        1,
        index.spine[1].chars - 1,
      ); // a última página: muitas fatias
      solta(1);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final b = p.openAt(4, 0);
      solta(4);
      expect((await b).spine, 4);
      expect((await a).spine, 4);
      expect(p.position!.spine, 4);
      pinta(p);
    });

    test('virar para trás atravessando capítulo e mudar a letra no meio: a virada termina', () async {
      final p = novo();
      await p.openAt(2, 0);
      final virada = p.previous(); // pagina o item 1 inteiro para mostrar a última página dele
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final r = p.relayout(const ReaderTypography(fontSize: 26));
      expect(await virada.timeout(const Duration(seconds: 20)), isA<bool>());
      expect((await r).spine, anyOf(1, 2));
    });

    test(
      'mudar a letra: a página de antes continua pintável até a nova chegar',
      () async {
        final p = novo();
        await p.openAt(2, 30000);
        final f = p.relayout(const ReaderTypography(fontSize: 26));
        var fim = false;
        unawaited(f.then((_) => fim = true));
        var vezes = 0;
        while (!fim) {
          pinta(p);
          vezes++;
          await Future<void>.delayed(const Duration(milliseconds: 1));
        }
        expect(vezes, greaterThan(1));
        pinta(p);
        expect(p.position!.page.start, lessThanOrEqualTo(30000));
      },
    );

    test('duas viradas rápidas = duas páginas', () async {
      final p = novo();
      await p.openAt(2, 0);
      final a = p.next();
      final b = p.next();
      expect((await a, await b), (true, true));
      expect((p.position!.spine, p.position!.pageIndex), (2, 2));
    });

    test(
      'abrir outro capítulo não espera o anterior terminar de paginar',
      () async {
        final s = LayoutScheduler();
        final p = BookPager(
          index: index,
          load: isolateChapterLoader(_arquivo),
          typography: const ReaderTypography(),
          scheduler: s,
        );
        addTearDown(p.dispose);
        await p.openAt(
          1,
          0,
        ); // a 1ª página chega logo; o resto do item 1 (309 páginas) continua
        await p.content(4); // carregado antes: mede só o layout
        final antes = s.slices;
        await p.openAt(4, 0);
        expect(s.slices - antes, lessThan(15));
      },
    );

    test('fechar com uma abertura em andamento: ela termina com PagerClosed e nada mais roda', () async {
      final (:p, :s, :solta) = controlado();
      final f = p.openAt(3, 0);
      p.dispose();
      solta(3);
      await expectLater(f, throwsA(isA<PagerClosed>()));
      await pumpEventQueue();
      expect(s.idle, isTrue);
      await expectLater(p.openAt(3, 0), throwsA(isA<PagerClosed>()));
      expect(await p.next(), isFalse);
    });

    test('cache com início de página velho: a página mostrada ainda contém a posição', () async {
      final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
      addTearDown(db.close);
      final chave = PagerCacheKey(
        userBookId: idTeste(2),
        devicePixelRatio: 3,
        dao: PageLayoutCacheDao(db),
      );
      final p = novo(cache: chave);
      await chave.dao.put(
        userBookId: idTeste(2),
        settingsHash: p.settingsHash,
        viewport: viewportKey(const ReaderTypography(), 3),
        fontsVersion: readerFontsVersion,
        breaks: PageBreaks(
          sha: 'e' * 64,
          chapters: {
            3: [0],
          },
        ),
        now: DateTime.utc(2026, 10, 5),
      );
      final alvo = index.spine[3].chars ~/ 2;
      final pos = await p.openAt(3, alvo);
      expect(
        pos.pageIndex,
        isNotNull,
        reason: 'a página do cache não contém o alvo: abre pelo layout',
      );
      await contem(p, alvo);
    });

    test(
      'cache: a chave da tela vem dos ajustes (outra tela grava noutra chave)',
      () async {
        final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
        addTearDown(db.close);
        final chave = PagerCacheKey(
          userBookId: idTeste(3),
          devicePixelRatio: 3,
          dao: PageLayoutCacheDao(db),
        );
        final p = novo(cache: chave);
        await p.openAt(4, 0);
        const t = ReaderTypography(viewportWidth: 360, viewportHeight: 780);
        await p.relayout(t);
        final layout = (await p.settle())!;
        PageBreaks? gravado;
        for (var i = 0; i < 100 && gravado == null; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          gravado = await chave.dao.get(
            userBookId: idTeste(3),
            settingsHash: p.settingsHash,
            viewport: '360x780@3',
            fontsVersion: readerFontsVersion,
          );
        }
        expect(gravado!.chapters[4], layout.pageStarts);
      },
    );
  });
}
