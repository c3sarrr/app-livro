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

    PdfPositionKeeper guardiao() => PdfPositionKeeper(
      db: db,
      versioning: versioning,
      owner: () async => usuarioTeste,
      userBookId: livro.id,
      sha: shaTeste,
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
  });
}
