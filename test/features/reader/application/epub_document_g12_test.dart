// G12.2 — o EPUB aberto ganha o que os controles pedem: autor e régua de caracteres (tempo restante — D-97); o
// começo de cada página de referência (barra de posição — D-119); o rascunho do marcador da página mostrada
// (D-49); a cor do texto sem mudar as quebras (Tema — D-121); e a marca da busca até a próxima virada ou salto.
import 'dart:ui';

import 'package:app_leitura/features/reader/application/epub_reader_document.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reader_numbers.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/load_fonts.dart';
import '../../../support/reader_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  late EpubReaderDocument d;
  setUp(() async {
    // o Dom Casmurro do mundo (um capítulo por item; o cap. XXXII é o item 32) com o índice da tela 19
    livro = await livroDaTela19();
    d = await EpubReaderDocument.open(livro.deps());
  });
  tearDown(() async {
    d.dispose();
    await livro.close();
  });

  test('autor e régua de caracteres do livro', () {
    expect(d.author, 'Machado de Assis');
    expect(d.totalChars, livro.index.totalChars);
  });

  test('markOfRefPage: o começo da pág. de referência pelo mapa do índice; fora do intervalo → as pontas', () async {
    final idx = livro.index;
    final m = d.markOfRefPage(100);
    expect(idx.globalOffset(m.spine, m.offset), idx.refPages.starts[99]);
    expect(d.markOfRefPage(0), d.markOfRefPage(1));
    expect(d.markOfRefPage(99999), d.markOfRefPage(idx.refPagesTotal));
  });

  // O índice da tela 19 tem contagens de um livro inteiro sobre um EPUB curto: para pular por página e chegar ao
  // fim, o Dom Casmurro do Projeto Gutenberg (índice de verdade).
  Future<(EpubReaderDocument, BookIndex)> real() async {
    final r = await LivroNaEstante.domCasmurro();
    addTearDown(r.close);
    final doc = await EpubReaderDocument.open(r.deps());
    addTearDown(doc.dispose);
    return (doc, r.index);
  }

  test(
    'goToRefPage: a 1ª página da tela que começa na pág. N (o rodapé mostra N)',
    () async {
      final (r, idx) = await real();
      expect(idx.refPagesTotal, greaterThan(200));
      for (final n in [100, 2, 159, 200, 1]) {
        await r.goToRefPage(n);
        expect(r.numbers.refPage, n, reason: 'pág. $n');
        final p = r.mark;
        expect(
          idx.globalOffset(p.spine, p.offset),
          greaterThanOrEqualTo(idx.refPages.starts[n - 1]),
          reason: 'a página da tela começa na pág. $n',
        );
      }
    },
  );

  test('goToRefPage na última: se nenhuma página da tela começa nela (curta), a que contém o começo dela', () async {
    final (r, idx) = await real();
    final ultima = idx.refPagesTotal;
    await r.goToRefPage(99999);
    final p = (r.current as PageSnapshot).page;
    final mark = r.mark;
    final inicio = idx.globalOffset(mark.spine, p.start)!;
    final fim = idx.globalOffset(mark.spine, p.end)!;
    final s = idx.refPages.starts[ultima - 1];
    expect(
      r.numbers.refPage == ultima || (inicio <= s && s < fim),
      isTrue,
      reason: 'pág. ${r.numbers.refPage} de $ultima',
    );
  });

  test('atEnd: só na última página do livro', () async {
    final (r, idx) = await real();
    await r.goToRefPage(idx.refPagesTotal);
    while (await r.turn(PageDirection.forward)) {}
    expect(r.atEnd, isTrue);
    expect(await r.turn(PageDirection.backward), isTrue);
    expect(r.atEnd, isFalse);
    await r.goToRefPage(1);
    expect(r.atEnd, isFalse);
  });

  test('goTo (busca): a página que contém o lugar, mesmo que comece na página anterior', () async {
    final (r, _) = await real();
    final m = r.markOfRefPage(100);
    await r.goTo(m);
    final p = (r.current as PageSnapshot).page;
    expect(r.mark.spine, m.spine);
    expect(m.offset, inInclusiveRange(p.start, p.end - 1));
  });

  test('bookmarkHere: localizador da 1ª letra, pág., capítulo e o começo da página (D-49)', () async {
    await d.goTo((spine: 32, offset: 0));
    final m = d.bookmarkHere();
    final p = d.mark;
    expect(m.locator, isA<EpubLocator>());
    final l = m.locator as EpubLocator;
    expect((l.spine, l.offset), (p.spine, p.offset));
    final n = numbersAt(livro.index, p.spine, p.offset);
    expect((m.refPage, m.chapterIndex), (n.refPage, n.chapterIndex));
    expect(m.refPage, d.numbers.refPage);
    expect(m.excerpt, isNotEmpty);
    expect(m.excerpt.length, lessThanOrEqualTo(91));
    expect(
      d.current.spokenText
          .replaceAll(RegExp(r'\s+'), ' ')
          .startsWith(m.excerpt.replaceAll('…', '')),
      isTrue,
    );
  });

  test('bookmarkExcerpt: até 90 caracteres cortados em palavra, com "…"', () {
    expect(bookmarkExcerpt('  curto \n texto '), 'curto texto');
    final longo = 'palavra ' * 20;
    final e = bookmarkExcerpt(longo);
    expect(e.endsWith('…'), isTrue);
    expect(e.length, lessThanOrEqualTo(91));
    expect(e.substring(0, e.length - 1).endsWith('palavra'), isTrue);
    expect(bookmarkExcerpt('x' * 120), '${'x' * 90}…');
  });

  test('recolor: mesma página, mesmo 1º caractere, texto na cor nova; a mesma cor não repagina', () async {
    await d.goTo((spine: 32, offset: 0));
    final antes = d.mark;
    final paginaAntes = (d.current as PageSnapshot).page;
    await d.recolor(const Color(0xFFE3D9C6));
    final p = d.current as PageSnapshot;
    expect(d.mark, antes);
    expect((p.page.start, p.page.end), (paginaAntes.start, paginaAntes.end));
    expect(p.typography.ink, const Color(0xFFE3D9C6));
    var avisos = 0;
    d.changes.addListener(() => avisos++);
    await d.recolor(const Color(0xFFE3D9C6));
    expect(avisos, 0, reason: 'a mesma cor não monta a página de novo');
  });

  test('showFound avisa a tela e vale até a próxima virada ou salto', () async {
    await d.goTo((spine: 32, offset: 0));
    var avisos = 0;
    d.changes.addListener(() => avisos++);
    d.showFound((unit: 32, from: 10, to: 20));
    expect(d.found, (unit: 32, from: 10, to: 20));
    expect(avisos, greaterThanOrEqualTo(1));
    expect(await d.turn(PageDirection.forward), isTrue);
    expect(d.found, isNull);
    d.showFound((unit: 32, from: 10, to: 20));
    await d.goTo((spine: 32, offset: 0));
    expect(d.found, isNull);
    d.showFound((unit: 32, from: 10, to: 20));
    await d.goToRefPage(10);
    expect(d.found, isNull);
  });
}
