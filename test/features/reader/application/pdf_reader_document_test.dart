// G11.4 — o PDF básico (D-109) com o PDFium de verdade (`pdfrx`): a página encaixa na largura da tela − 8 px de
// cada lado, centralizada entre o topo e o rodapé (e pela altura quando a página é alta demais); "pág. X de
// Y" = páginas do PDF e "%" = começo da página ÷ total; virar até o fim e o batente; a posição vira um
// `PdfLocator`, gravada e reaberta (página fora do total → a última). Fixture: `amostra.pdf` (3 páginas A5:
// "Primeiro conto", "continua", "Segundo conto" — `tools/fixtures/gerar_pdfs_g09.py`).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/application/pdf_position_keeper.dart';
import 'package:app_leitura/features/reader/application/pdf_reader_document.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/content/content_failure.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart' show pdfrxInitialize;

import '../../../support/personal_builders.dart';

const String _amostra = 'test/fixtures/livros/amostra.pdf';
const ui.Size _tela = ui.Size(390, 844);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('encaixe da página (D-109)', () {
    test('A4 em pé: largura − 8 de cada lado, centralizada entre o topo e o rodapé', () {
      final r = pdfPageRect(
        pageSize: const ui.Size(595, 842),
        viewport: _tela,
        top: 0,
        footerBottom: 40,
      );
      const faixa = 844 - 40 - 13.81 - 8; // até 8 px acima do rodapé
      expect(r.left, closeTo(8, 1e-9));
      expect(r.width, closeTo(374, 1e-9));
      expect(r.height, closeTo(374 * 842 / 595, 1e-9));
      expect(r.center.dy, closeTo(faixa / 2, 1e-9));
    });

    test('com a área segura de cima, a faixa começa nela', () {
      final r = pdfPageRect(
        pageSize: const ui.Size(595, 842),
        viewport: _tela,
        top: 47,
        footerBottom: 40,
      );
      expect(r.center.dy, closeTo((47 + 844 - 40 - 13.81 - 8) / 2, 1e-9));
    });

    test('paisagem fica pela largura; página alta demais fica pela altura, centralizada', () {
      final deitada = pdfPageRect(
        pageSize: const ui.Size(842, 595),
        viewport: _tela,
        top: 0,
        footerBottom: 40,
      );
      expect(deitada.width, closeTo(374, 1e-9));
      final alta = pdfPageRect(
        pageSize: const ui.Size(100, 1000),
        viewport: _tela,
        top: 0,
        footerBottom: 40,
      );
      expect(alta.height, closeTo(844 - 40 - 13.81 - 8, 1e-9));
      expect(alta.center.dx, closeTo(195, 1e-9));
      expect(alta.width, closeTo(alta.height / 10, 1e-9));
    });

    test('% do PDF = começo da página ÷ total, 5 casas', () {
      expect(pdfProgression(0, 3), 0);
      expect(pdfProgression(1, 3), 0.33333);
      expect(pdfProgression(2, 3), 0.66667);
      expect(pdfProgression(5, 3), 1);
      expect(pdfProgression(0, 0), 0);
    });
  });

  group('PDF aberto (PDFium)', () {
    late Directory tmp;
    late AppDatabase db;
    late LocalVersioning versioning;
    final livro = livroTeste(8).copyWith(format: BookFileFormat.pdf);
    setUpAll(
      () => tmp = Directory.systemTemp.createTempSync('booknest_g11_pdf_'),
    );
    tearDownAll(() => tmp.deleteSync(recursive: true));
    setUp(() {
      db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
      versioning = LocalVersioning(db, HlcClock(deviceId: 'aparelhoA'));
    });
    tearDown(() => db.close());

    PdfPositionKeeper guardiao({String sha = shaTeste}) => PdfPositionKeeper(
      db: db,
      versioning: versioning,
      owner: () async => usuarioTeste,
      userBookId: livro.id,
      sha: sha,
      deviceId: 'aparelhoA',
      delay: Duration.zero,
      onError: (e, _) => fail('erro: $e'),
    );

    Future<PdfReaderDocument> abrir({String path = _amostra}) async {
      final d = await PdfReaderDocument.open(
        book: livro,
        path: path,
        keeper: guardiao(),
        viewport: _tela,
        top: 0,
        footerBottom: 40,
        devicePixelRatio: 1,
        initialize: () => pdfrxInitialize(tmpPath: tmp.path),
      );
      addTearDown(d.dispose);
      return d;
    }

    test(
      'abre na 1ª página: pág. 1 de 3 · 0%, com o texto da página',
      () async {
        final d = await abrir();
        expect(d.title, 'Dom Casmurro');
        expect(d.numbers.pageLabel, 'pág. 1 de 3');
        expect(d.numbers.percentLabel, '0%');
        expect(d.current.spokenText, 'Primeiro conto');
        expect(d.current.linkAt(const ui.Offset(100, 100)), isNull);
        expect(await d.peek(PageDirection.backward), isNull);
        expect(await d.turn(PageDirection.backward), isFalse);
      },
    );

    test(
      'virar até o fim: números, vizinha sem virar, batente e aviso à tela',
      () async {
        final d = await abrir();
        var avisos = 0;
        d.changes.addListener(() => avisos++);
        final vizinha = (await d.peek(PageDirection.forward))!;
        expect(vizinha.spokenText, 'continua');
        expect(await d.turn(PageDirection.forward), isTrue);
        expect(
          (d.numbers.pageLabel, d.numbers.percentLabel),
          ('pág. 2 de 3', '33%'),
        );
        expect(d.shownRange, (fromRef: 2, toRef: 2));
        expect(await d.turn(PageDirection.forward), isTrue);
        expect((d.numbers.refPage, d.numbers.percentLabel), (3, '67%'));
        expect(await d.peek(PageDirection.forward), isNull);
        expect(await d.turn(PageDirection.forward), isFalse);
        expect(avisos, 2);
      },
    );

    test('a página é pintada no retângulo do encaixe (fundo branco do PDF) e só nele', () async {
      final d = await abrir();
      final rec = ui.PictureRecorder();
      d.current.paint(ui.Canvas(rec));
      final img = await rec.endRecording().toImage(390, 844);
      final px = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      img.dispose();
      int alfa(double x, double y) =>
          px.getUint8(((y.toInt() * 390) + x.toInt()) * 4 + 3);
      final r = pdfPageRect(
        pageSize: const ui.Size(419.5276, 595.2756),
        viewport: _tela,
        top: 0,
        footerBottom: 40,
      );
      expect(alfa(r.center.dx, r.center.dy), 255);
      expect(alfa(r.left + 2, r.top + 2), 255);
      expect(
        alfa(4, r.center.dy),
        0,
        reason: 'fora da página: o papel é da tela',
      );
      expect(alfa(r.center.dx, r.top - 3), 0);
    });

    test('posição: grava PdfLocator ao virar; reabre na página; fora do total → a última', () async {
      final d = await abrir();
      await d.turn(PageDirection.forward);
      await d.turn(PageDirection.forward);
      await d.flush();
      final pos = await ReadingPositionsDao(db).forBook(livro.id);
      expect(
        pos!.locator,
        PdfLocator(sha: shaTeste, page: 2, refPage: 3, progression: 0.66667),
      );
      expect((pos.refPage, pos.progression, pos.chapterIndex), (3, 0.66667, 0));
      d.dispose();
      final d2 = await abrir();
      expect(d2.numbers.refPage, 3);
      // posição de outra versão do arquivo com mais páginas
      final k = guardiao()..pageShown(7, 10);
      await k.flush();
      d2.dispose();
      final d3 = await abrir();
      expect(d3.numbers.refPage, 3, reason: 'a última');
      await d3.goTo((spine: 0, offset: 0));
      expect(d3.numbers.refPage, 1);
    });

    test('páginas de tamanhos diferentes (A4, carta, A4 deitada): cada uma no seu encaixe', () async {
      final d = await abrir(path: 'test/fixtures/livros/tamanhos.pdf');
      const tamanhos = [
        ui.Size(595.2756, 841.8898),
        ui.Size(612, 792),
        ui.Size(841.8898, 595.2756),
      ];
      const textos = ['A4 em pe', 'Carta', 'A4 deitada'];
      for (var i = 0; i < 3; i++) {
        final pagina = d.current as PdfDisplayPage;
        final esperado = pdfPageRect(
          pageSize: tamanhos[i],
          viewport: _tela,
          top: 0,
          footerBottom: 40,
        );
        expect(
          pagina.rect.left,
          closeTo(esperado.left, 0.01),
          reason: textos[i],
        );
        expect(pagina.rect.top, closeTo(esperado.top, 0.01), reason: textos[i]);
        expect(
          pagina.rect.width,
          closeTo(esperado.width, 0.01),
          reason: textos[i],
        );
        expect(
          pagina.rect.height,
          closeTo(esperado.height, 0.01),
          reason: textos[i],
        );
        expect(
          (pagina.image!.width, pagina.image!.height),
          (esperado.width.round(), esperado.height.round()),
          reason: 'imagem na largura da tela − 16 (dpr 1)',
        );
        expect(pagina.spokenText, textos[i]);
        if (i < 2) await d.turn(PageDirection.forward);
      }
    });

    test(
      'viradas em fila: duas seguidas partem uma de onde a outra parou',
      () async {
        final d = await abrir();
        final a = d.turn(PageDirection.forward);
        final b = d.turn(PageDirection.forward);
        expect((await a, await b), (true, true));
        expect(d.numbers.refPage, 3);
      },
    );

    test(
      'posição de outro arquivo (o PDF foi trocado): vale a % guardada',
      () async {
        final k = guardiao(sha: 'f' * 64)
          ..pageShown(4, 10); // 40 % de outro PDF de 10 páginas
        await k.flush();
        final d = await abrir();
        expect(
          d.numbers.refPage,
          2,
          reason: '40 % de 3 páginas → a 2ª (não a última)',
        );
      },
    );

    test('alfinete (D-115): com ele, a posição gravada é a dele; solto, a página mostrada', () async {
      final d = await abrir();
      await d.pin((spine: 0, offset: 0));
      await d.turn(PageDirection.forward);
      await d.turn(PageDirection.forward);
      await d.flush();
      var pos = await ReadingPositionsDao(db).forBook(livro.id);
      expect((pos!.locator as PdfLocator).page, 0);
      await d.pin(null);
      await d.flush();
      pos = await ReadingPositionsDao(db).forBook(livro.id);
      expect((pos!.locator as PdfLocator).page, 2);
    });

    test('PDF quebrado → danificado', () async {
      final ruim = File('${tmp.path}/ruim.pdf')
        ..writeAsStringSync('%PDF-1.4 lixo');
      await expectLater(abrir(path: ruim.path), throwsA(isA<ContentDamaged>()));
    });

    test(
      'PdfLocator ida e volta pelo JSON; outro formato continua RawLocator',
      () {
        final l = PdfLocator(
          sha: shaTeste,
          page: 4,
          refPage: 5,
          progression: 0.4,
        );
        expect(l.toJson(), {
          'v': 1,
          'sha': shaTeste,
          'page': 4,
          'refPage': 5,
          'progression': 0.4,
        });
        expect(Locator.fromJson(l.toJson()), l);
        expect(
          Locator.fromJson({...l.toJson(), 'quads': const []}),
          isA<RawLocator>(),
        );
        expect(
          Locator.fromJson({...l.toJson(), 'page': -1}),
          isA<RawLocator>(),
        );
        expect(
          () => PdfLocator(sha: shaTeste, page: 0, refPage: 0, progression: 0),
          throwsArgumentError,
        );
      },
    );

    group('G12', () {
      test('autor; régua = páginas × 1.500 (D-122); salto por página; Tema não mexe na página (D-43)', () async {
        final d = await abrir();
        expect(d.author, 'Machado de Assis');
        expect(d.totalChars, 3 * 1500);
        expect(d.markOfRefPage(2), (spine: 0, offset: 1));
        expect(d.markOfRefPage(0), (spine: 0, offset: 0));
        expect(d.markOfRefPage(99), (spine: 0, offset: 2));
        final antes = d.current;
        await d.recolor(const ui.Color(0xFFE3D9C6));
        expect(identical(d.current, antes), isTrue);
      });

      test('marcador da página: PdfLocator, pág. = página + 1, capítulo 0, o começo do texto (D-49)', () async {
        final d = await abrir();
        await d.goTo(d.markOfRefPage(3));
        final m = d.bookmarkHere();
        expect(m.locator, isA<PdfLocator>());
        expect((m.locator as PdfLocator).page, 2);
        expect((m.refPage, m.chapterIndex), (3, 0));
        expect(m.excerpt, 'Segundo conto');
      });

      test('a marca da busca vale até a próxima virada ou salto', () async {
        final d = await abrir();
        var avisos = 0;
        d.changes.addListener(() => avisos++);
        d.showFound((unit: 0, from: 0, to: 8));
        expect(d.found, (unit: 0, from: 0, to: 8));
        expect(avisos, 1);
        await d.turn(PageDirection.forward);
        expect(d.found, isNull);
        d.showFound((unit: 1, from: 0, to: 3));
        await d.goTo((spine: 0, offset: 0));
        expect(d.found, isNull);
      });

      test('busca no texto das páginas (D-120, D-122): grupo "Pág. N", salto e marca na página', () async {
        final d = await abrir();
        final grupos = await d.search('CONTO').toList();
        expect(grupos.map((g) => g.title), ['Pág. 1', 'Pág. 3']);
        expect(grupos.every((g) => g.byPage), isTrue);
        final h = grupos.last.hits.single;
        expect(h.at, (spine: 0, offset: 2));
        expect((h.found.unit, h.refPage), (2, 3));
        expect(h.excerpt, 'Segundo conto');
        expect(h.excerpt.substring(h.matchStart, h.matchEnd), 'conto');
        expect(await d.search('x').toList(), isEmpty);
        expect(await d.search('nada disso').toList(), isEmpty);
      });

      test('goToRefPage = a página do arquivo; atEnd só na última', () async {
        final d = await abrir();
        expect(d.atEnd, isFalse);
        await d.goToRefPage(2);
        expect((d.numbers.refPage, d.atEnd), (2, false));
        await d.goToRefPage(3);
        expect((d.numbers.refPage, d.atEnd), (3, true));
        await d.goToRefPage(99);
        expect(d.numbers.refPage, 3);
      });
    });
  });
}
