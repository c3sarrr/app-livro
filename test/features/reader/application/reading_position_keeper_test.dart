// G10.3 — posição de leitura (Anexo 03 §5.1, §6): o 1º caractere visível vira um EpubLocator (citação sem
// cortar palavra, página de referência, %), gravado com versão depois de 1 s parado (ou na hora, ao sair);
// reabrir volta à página que contém esse caractere — no mesmo arquivo pela posição, noutro pela citação.
import 'dart:io';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/features/reader/application/book_pager.dart';
import 'package:app_leitura/features/reader/application/reader_errors.dart';
import 'package:app_leitura/features/reader/application/reading_position_keeper.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/chapter_content.dart';
import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/layout/layout_scheduler.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart' show paragrafoDaPagina159;
import '../../../support/epub_builder.dart';
import '../../../support/load_fonts.dart';
import '../../../support/personal_builders.dart';

String _esc(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

/// Livro com 2 capítulos (itens 0 e 1 do spine) de vários parágrafos (mais de uma página cada).
List<int> _livro({String antes = ''}) => simpleEpub(
  chapters: [
    (
      file: 'c1.xhtml',
      title: 'I',
      body: '<h2>I</h2>${'<p>${_esc(paragrafoDaPagina159)}</p>' * 3}',
    ),
    (
      file: 'c2.xhtml',
      title: 'II',
      body: '<h2>II</h2>$antes${'<p>${_esc(paragrafoDaPagina159)}</p>' * 4}',
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);
  late Directory dir;
  late AppDatabase db;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('booknest_g10_pos_');
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
  });
  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  final livroId = idTeste(7);

  (BookIndex, EpubBook) abrir(String nome, List<int> bytes, String sha) {
    final path = writeTemp(dir, nome, bytes);
    final book = EpubBook.open(path);
    addTearDown(book.close);
    return (indexEpubFile(path, sha), book);
  }

  ReadingPositionKeeper guardiao(
    BookIndex index, {
    Duration delay = positionSaveDelay,
    Future<String> Function()? dono,
    ReaderErrorReporter? erro,
  }) {
    final k = ReadingPositionKeeper(
      db: db,
      versioning: LocalVersioning(db, HlcClock(deviceId: 'aparelhoA')),
      owner: dono ?? () async => usuarioTeste,
      onError: erro ?? (e, st) => fail('erro inesperado: $e'),
      userBookId: livroId,
      index: index,
      deviceId: 'aparelhoA',
      delay: delay,
    );
    addTearDown(k.dispose);
    return k;
  }

  BookPager paginador(BookIndex index, EpubBook book) {
    final p = BookPager(
      index: index,
      load: (spine) async => chapterOf(book, spine),
      typography: const ReaderTypography(),
      scheduler: LayoutScheduler(),
    );
    addTearDown(p.dispose);
    return p;
  }

  test(
    'locator do 1º caractere visível: citação sem cortar palavra, página e %',
    () {
      final (index, book) = abrir('a.epub', _livro(), 'a' * 64);
      final k = guardiao(index);
      final texto = book.parseItem(1).text;
      final at = texto.indexOf('Retórica', 10);
      final l = k.locatorAt(1, at, texto);
      expect((l.sha, l.spine, l.offset), ('a' * 64, 1, at));
      expect(l.quote!.exact, 'Retórica dos namorados, dá-me');
      expect(l.quote!.prefix, texto.substring(at - 32, at));
      expect(l.quote!.suffix.length, 32);
      final g = index.globalOffset(1, at)!;
      expect(
        l.progression,
        double.parse((g / index.totalChars).toStringAsFixed(5)),
      );
      expect(l.refPage, index.refPages.pageOf(g));
    },
  );

  test('grava depois de parar na página; a última vence; flush grava na hora; createdAt fica', () async {
    final (index, book) = abrir('a.epub', _livro(), 'a' * 64);
    final texto = book.parseItem(1).text;
    final k = guardiao(index, delay: const Duration(milliseconds: 40));
    k.pageShown(1, 10, texto);
    k.pageShown(1, 900, texto);
    expect(await k.saved(), isNull, reason: 'ainda não parou');
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final primeiro = (await k.saved())!;
    expect((primeiro.locator as EpubLocator).offset, 900);
    expect(primeiro.refPage, greaterThanOrEqualTo(1));
    expect(primeiro.deviceId, 'aparelhoA');
    expect(primeiro.meta.userId, usuarioTeste);
    k.pageShown(1, 1500, texto);
    await k.flush();
    final segundo = (await k.saved())!;
    expect((segundo.locator as EpubLocator).offset, 1500);
    expect(segundo.meta.createdAt, primeiro.meta.createdAt);
    expect(
      segundo.meta.version.compareTo(primeiro.meta.version),
      greaterThan(0),
    );
    await k.flush(); // nada pendente
  });

  test(
    'falha ao gravar vai para o relatório e não trava as próximas gravações',
    () async {
      final (index, book) = abrir('a.epub', _livro(), 'a' * 64);
      final texto = book.parseItem(1).text;
      var falhas = 1;
      final erros = <Object>[];
      final k = guardiao(
        index,
        dono: () async {
          if (falhas-- > 0) throw StateError('disco cheio');
          return usuarioTeste;
        },
        erro: (e, _) => erros.add(e),
      );
      k.pageShown(1, 10, texto);
      await k.flush();
      expect(erros, [isA<StateError>()]);
      expect(await k.saved(), isNull);
      k.pageShown(1, 20, texto);
      await k.flush();
      expect(((await k.saved())!.locator as EpubLocator).offset, 20);
      expect(erros, hasLength(1));
    },
  );

  test(
    'reabrir: mesma página no mesmo arquivo; noutra edição, pela citação',
    () async {
      final (index, book) = abrir('a.epub', _livro(), 'a' * 64);
      final p = paginador(index, book);
      final k = guardiao(index);
      await p.openAt(1, 2000);
      await p.next();
      final pos = p.position!;
      k.pageShown(pos.spine, pos.firstVisible, p.contentOf(1)!.item.text);
      await k.flush();
      final p2 = paginador(index, book);
      final reaberta = await reopen(p2, k);
      expect((reaberta.spine, reaberta.firstVisible), (1, pos.firstVisible));

      // outra edição do arquivo: um parágrafo novo antes, outro sha
      final (index2, book2) = abrir(
        'b.epub',
        _livro(antes: '<p>Nota da nova edição.</p>'),
        'b' * 64,
      );
      final k2 = guardiao(index2);
      final p3 = paginador(index2, book2);
      final noutra = await reopen(p3, k2);
      final texto2 = p3.contentOf(1)!.item.text;
      final alvo = (await k.saved())!.locator as EpubLocator;
      final achado = texto2.indexOf(alvo.quote!.exact, alvo.offset);
      expect(noutra.spine, 1);
      expect(noutra.firstVisible, lessThanOrEqualTo(achado));
      final layout = (await p3.settle())!;
      final i = p3.position!.pageIndex!;
      if (i + 1 < layout.pages.length) {
        expect(layout.pages[i + 1].start, greaterThan(achado));
      }
    },
  );

  test('noutra edição com um item a mais antes: a citação não está no item de mesmo número — vale a %', () async {
    // capítulos com textos diferentes (a citação de um não aparece no outro)
    List<int> livro({required bool comNota}) => simpleEpub(
      chapters: [
        if (comNota)
          (
            file: 'nota.xhtml',
            title: 'Nota',
            body: '<p>Nota da edição nova.</p>',
          ),
        (
          file: 'c1.xhtml',
          title: 'I',
          body: '<p>${'Primeiro capítulo, outra história. ' * 60}</p>',
        ),
        (
          file: 'c2.xhtml',
          title: 'II',
          body: '<p>${_esc(paragrafoDaPagina159)}</p>' * 3,
        ),
      ],
    );
    final (index, book) = abrir('a.epub', livro(comNota: false), 'a' * 64);
    final k = guardiao(index);
    final texto = book.parseItem(1).text;
    final at = texto.indexOf(
      'Retórica',
      texto.length ~/ 2,
    ); // longe das bordas do capítulo
    k.pageShown(1, at, texto);
    await k.flush();

    final (index2, book2) = abrir('b.epub', livro(comNota: true), 'b' * 64);
    final p = paginador(index2, book2);
    final pos = await reopen(p, guardiao(index2));
    // pela % guardada: no c2 da edição nova (item 2), perto do mesmo ponto
    expect(pos.spine, 2);
    final g = index2.globalOffset(2, pos.firstVisible)!;
    final esperado =
        ((await k.saved())!.locator as EpubLocator).progression *
        index2.totalChars;
    expect((g - esperado).abs(), lessThan(index2.totalChars * 0.05));
  });

  test('sem posição guardada: abre no começo do livro', () async {
    final (index, book) = abrir('a.epub', _livro(), 'a' * 64);
    final pos = await reopen(paginador(index, book), guardiao(index));
    expect(
      (pos.spine, pos.firstVisible),
      (index.spine.indexWhere((s) => s.linear), 0),
    );
  });
}
