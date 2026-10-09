// G20 (R9, R10) — os fluxos do leitor que os orçamentos do Anexo 03 §12 medem: abrir um livro já indexado até a 1ª
// página, virar páginas, paginar um capítulo, traçar no modo anotação e importar um EPUB até poder ler. Aqui nada é
// medido (quem chama mede: o teste de aparelho, em `integration_test`, e a prévia do PC). O livro é gerado com
// semente fixa: o aparelho não tem os arquivos de teste do repositório.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/features/library/application/book_importer.dart';
import 'package:app_leitura/features/library/data/pdf_inspector.dart';
import 'package:app_leitura/features/library/domain/import_outcome.dart';
import 'package:app_leitura/features/reader/content/chapter_content.dart';
import 'package:app_leitura/features/reader/layout/chapter_layout.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/epub_builder.dart';
import '../support/personal_builders.dart';
import '../support/pump_reader.dart';
import '../support/reader_harness.dart';

const List<String> _silabas = [
  'ca',
  'pi',
  'tu',
  'ma',
  'no',
  'el',
  'de',
  'sa',
  'ro',
  'lha',
  'ção',
  'ves',
  'qui',
  'nho',
  'ra',
  'ti',
  'gu',
  'bem', //
  'os',
  'lu',
  'mi',
  'par',
  'con',
  'dor',
  'fe',
  'xa',
  'ze',
  'vi',
  'ar',
  'pen',
  'so',
  'tre',
  'mar',
  'vol',
  'ex',
  'im',
];

/// Um parágrafo de texto pseudoaleatório (palavras de 1 a 4 sílabas, frases de 6 a 22 palavras).
String _paragrafo(math.Random r, int alvo) {
  final b = StringBuffer();
  while (b.length < alvo) {
    final palavras = 6 + r.nextInt(17);
    for (var w = 0; w < palavras; w++) {
      final s = 1 + r.nextInt(4);
      final p = StringBuffer();
      for (var i = 0; i < s; i++) {
        p.write(_silabas[r.nextInt(_silabas.length)]);
      }
      var palavra = p.toString();
      if (w == 0) palavra = palavra[0].toUpperCase() + palavra.substring(1);
      b
        ..write(palavra)
        ..write(w == palavras - 1 ? '. ' : (r.nextInt(9) == 0 ? ', ' : ' '));
    }
  }
  return b.toString().trim();
}

/// Um EPUB gerado (semente fixa): [capitulos] capítulos de ~[caracteres] caracteres cada, em parágrafos de ~600.
Uint8List epubGerado({
  int capitulos = 12,
  int caracteres = 60000,
  int semente = 20,
}) {
  final r = math.Random(semente);
  return simpleEpub(
    title: 'Livro de medida',
    chapters: [
      for (var c = 0; c < capitulos; c++)
        (
          file: 'c$c.xhtml',
          title: 'Capítulo ${c + 1}',
          body:
              '<h2>Capítulo ${c + 1}</h2>${[for (var p = 0; p < caracteres ~/ 600; p++) '<p>${_paragrafo(r, 600)}</p>'].join()}',
        ),
    ],
  );
}

/// O EPUB de ~2 MB da importação (Anexo 03 §12): ~3,2 milhões de caracteres em 40 capítulos.
Uint8List epubDe2MB() => epubGerado(capitulos: 40, caracteres: 80000);

/// O livro gerado na estante de um banco em memória, já indexado, com a posição no meio do capítulo [capitulo].
Future<LivroNaEstante> livroGerado({int capitulo = 3}) async {
  final livro = await LivroNaEstante.epubDe(
    epubGerado(),
    title: 'Livro de medida',
  );
  final item = livro.index.spine.indexWhere((s) => s.linear) + capitulo;
  await livro.guardarPosicao(item, livro.index.spine[item].chars ~/ 2);
  return livro;
}

/// Abre o leitor do [livro] (já indexado) e espera a 1ª página.
Future<LeitorNaTela> abrirLivroIndexado(
  WidgetTester tester,
  LivroNaEstante livro,
) => abrirLeitor(tester, livro);

/// Vira [n] páginas para a frente (o terço da direita), um quadro por vez até cada virada assentar.
Future<void> virarPaginas(
  WidgetTester tester,
  int n, {
  Size tela = const Size(390, 844),
}) async {
  for (var i = 0; i < n; i++) {
    await tester.tapAt(Offset(tela.width * 0.92, tela.height / 2));
    for (var q = 0; q < 20; q++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }
}

/// Pagina o capítulo [spine] do [livro] inteiro, passo a passo: as páginas, o tempo total e a maior fatia (µs).
({int paginas, Duration total, int maiorPassoMicros}) paginarCapitulo(
  LivroNaEstante livro,
  int spine, {
  ReaderTypography t = const ReaderTypography(),
}) {
  final sw = Stopwatch()..start();
  final job = ChapterLayoutJob(chapterOf(livro.epub, spine), t);
  while (!job.step()) {}
  sw.stop();
  final r = (
    paginas: job.result.pages.length,
    total: sw.elapsed,
    maiorPassoMicros: job.maxStepMicros,
  );
  job.dispose();
  return r;
}

/// [n] traços de caneta na página do modo anotação (já aberto), cada um com [pontos] pontos a cada 8 ms.
Future<void> tracar(WidgetTester tester, int n, {int pontos = 24}) async {
  for (var i = 0; i < n; i++) {
    final y = 260.0 + 18 * (i % 20);
    final g = await tester.startGesture(Offset(60, y));
    for (var p = 1; p <= pontos; p++) {
      await g.moveTo(
        Offset(60 + 10.0 * p, y + 4 * math.sin(p / 2)),
        timeStamp: Duration(milliseconds: 8 * p),
      );
      await tester.pump(const Duration(milliseconds: 8));
    }
    await g.up();
    await tester.pump(const Duration(milliseconds: 16));
  }
}

final class _SemPdf implements PdfInspector {
  @override
  Future<PdfInfo> inspect(String path) async =>
      throw StateError('sem PDF aqui');
}

/// Importa os [bytes] de um EPUB num banco novo até poder ler (a cópia, a linha da estante e o índice): o tempo e o
/// resultado. A pasta temporária some no fim.
Future<({Duration ate, ImportOutcome resultado})> importarEpub(
  Uint8List bytes,
) async {
  final raiz = Directory.systemTemp.createTempSync('booknest_g20_import_');
  final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
  try {
    final importador = BookImporter(
      db: db,
      versioning: LocalVersioning(db, HlcClock(deviceId: 'aparelhoA')),
      owner: () async => usuarioTeste,
      booksDir: () async =>
          Directory('${raiz.path}${Platform.pathSeparator}livros'),
      fileCoversDir: () async =>
          Directory('${raiz.path}${Platform.pathSeparator}capas'),
      pdf: _SemPdf(),
      run: <T>(T Function() task) async => task(),
    );
    final sw = Stopwatch()..start();
    final r = await importador.importStream(
      Stream.value(bytes),
      fileName: 'livro_de_medida.epub',
    );
    // poder ler = a linha da estante e o índice completo (o 2º passo da importação, em segundo plano no app)
    if (r is Imported) await importador.indexBook(r.userBookId);
    sw.stop();
    return (ate: sw.elapsed, resultado: r);
  } finally {
    await db.close();
    raiz.deleteSync(recursive: true);
  }
}
