// G09.4 — importar EPUB/PDF (Anexo 03 §3, D-87…D-93): cópia com SHA-256, tipo pelo conteúdo, mesmo arquivo não
// duplica, metadados e capa do arquivo, ISBN no catálogo (só aparelho e Worker), dois tempos (o índice do EPUB
// vem depois e é refeito se faltar), e nenhuma falha deixa arquivo ou linha pela metade.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/features/library/application/book_importer.dart';
import 'package:app_leitura/features/library/data/book_files.dart';
import 'package:app_leitura/features/library/data/pdf_inspector.dart';
import 'package:app_leitura/features/library/domain/import_outcome.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/content/content_failure.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/epub_builder.dart';
import '../../support/personal_builders.dart';

const _cap = (file: 'c1.xhtml', title: 'I', body: '<p>Uma noite destas.</p>');

final class _Pdf implements PdfInspector {
  _Pdf(this.resposta);

  FutureOr<PdfInfo> Function(String path) resposta;
  final List<String> pedidos = [];

  @override
  Future<PdfInfo> inspect(String path) async {
    pedidos.add(path);
    return resposta(path);
  }
}

final class _Catalogo implements IsbnLookup {
  _Catalogo(this.resposta);

  Future<IsbnMatch?> Function(String isbn) resposta;
  final List<String> pedidos = [];

  @override
  Future<IsbnMatch?> find(String isbn13) {
    pedidos.add(isbn13);
    return resposta(isbn13);
  }
}

Future<T> _aqui<T>(T Function() task) async => task();

void main() {
  late Directory raiz;
  late Directory livros;
  late Directory capas;
  late AppDatabase db;
  late _Pdf pdf;
  late _Catalogo catalogo;
  late BookImporter importador;
  var dono = usuarioTeste;
  final erros = <Object>[];

  BookImporter novo({BackgroundRunner? run}) => BookImporter(
    db: db,
    versioning: LocalVersioning(db, HlcClock(deviceId: 'aparelhoA')),
    owner: () async => dono,
    booksDir: () async => livros,
    fileCoversDir: () async => capas,
    pdf: pdf,
    catalog: catalogo,
    run: run ?? _aqui,
    onError: (e, _) => erros.add(e),
  );

  setUp(() {
    raiz = Directory.systemTemp.createTempSync('booknest_import_');
    livros = Directory('${raiz.path}${Platform.pathSeparator}livros');
    capas = Directory('${raiz.path}${Platform.pathSeparator}capas_arquivo');
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    pdf = _Pdf((_) => throw StateError('PDF não esperado'));
    catalogo = _Catalogo((_) async => null);
    dono = usuarioTeste;
    erros.clear();
    importador = novo();
  });
  tearDown(() async {
    await db.close();
    raiz.deleteSync(recursive: true);
  });

  Stream<List<int>> emPedacos(List<int> bytes) async* {
    for (var i = 0; i < bytes.length; i += 4096) {
      yield bytes.sublist(i, i + 4096 > bytes.length ? bytes.length : i + 4096);
    }
  }

  Future<List<UserBook>> estante() async => [
    for (final r in await db.select(db.userBooks).get())
      (await UserBooksDao(db).byId(r.id))!,
  ];

  List<String> arquivos() => livros.existsSync()
      ? (livros.listSync().map((f) => f.uri.pathSegments.last).toList()..sort())
      : const [];

  test('EPUB: estante com título, autores, sha, tamanho e capa do arquivo; índice no 2º tempo', () async {
    final bytes = simpleEpub(
      title: 'Dom Casmurro',
      authors: const ['Machado de Assis', 'Outra Pessoa'],
      chapters: const [_cap],
      manifestExtra: '<item id="capa" href="capa.jpg" media-type="image/jpeg" properties="cover-image"/>',
      extra: {'OEBPS/capa.jpg': tinyJpeg(200)},
    );
    final r = await importador.importStream(
      emPedacos(bytes),
      fileName: 'dom.epub',
    );
    expect(r, isA<Imported>());
    final ok = r as Imported;
    expect(ok.title, 'Dom Casmurro');
    expect(ok.fixedLayout, isFalse);
    final b = (await estante()).single;
    expect(b.id, ok.userBookId);
    expect(b.meta.userId, usuarioTeste);
    expect(b.title, 'Dom Casmurro');
    expect(b.authorDisplay, 'Machado de Assis · Outra Pessoa');
    expect(b.format, BookFileFormat.epub);
    expect(b.status, ShelfStatus.wantToRead);
    expect(b.contentSha256, sha256.convert(bytes).toString());
    expect(b.fileBytes, bytes.length);
    expect(b.refPagesTotal, isNull, reason: 'o índice é do 2º tempo');
    // arquivo no lugar da G06 e nenhuma sobra
    expect(arquivos(), ['${b.id}.epub']);
    final lf = (await LocalFilesDao(db).byBook(b.id))!;
    expect(File(lf.path).readAsBytesSync(), bytes);
    expect(lf.uploadState, 'none');
    expect(lf.sha256, b.contentSha256);
    // capa do arquivo (D-90)
    expect(
      File('${capas.path}${Platform.pathSeparator}${b.contentSha256}.img')
          .readAsBytesSync(),
      tinyJpeg(200),
    );

    expect(await importador.indexBook(b.id), isTrue);
    final idx = (await BookContentIndexDao(db).byBook(b.id))!;
    expect(idx.contentSha256, b.contentSha256);
    final depois = (await UserBooksDao(db).byId(b.id))!;
    expect(depois.refPagesTotal, 1);
    expect(depois.refPageVersion, 1);
    expect(depois.chaptersTotal, 1);
    expect(depois.meta.version.compareTo(b.meta.version), greaterThan(0));
    expect(
      await importador.indexBook(b.id),
      isFalse,
      reason: 'já indexado com este arquivo',
    );
    expect(erros, isEmpty);
  });

  test('o mesmo arquivo de novo: "já está na estante", nada duplicado (inclusive ao mesmo tempo)', () async {
    final bytes = simpleEpub(title: 'Senhora', chapters: const [_cap]);
    final a = await importador.importStream(
      Stream.value(bytes),
      fileName: 'a.epub',
    ) as Imported;
    final b = await importador.importStream(
      Stream.value(bytes),
      fileName: 'outro nome.epub',
    );
    expect(b, isA<AlreadyOnShelf>());
    expect((b as AlreadyOnShelf).userBookId, a.userBookId);
    expect(b.title, 'Senhora');
    // ao mesmo tempo por dois caminhos (cada importador com a sua fila): a 2ª confere de novo dentro da
    // transação e desiste
    final c = simpleEpub(title: 'Iracema', chapters: const [_cap]);
    final rs = await Future.wait([
      importador.importStream(Stream.value(c), fileName: 'c.epub'),
      novo().importStream(Stream.value(c), fileName: 'c.epub'),
    ]);
    expect(rs.whereType<Imported>(), hasLength(1));
    expect(rs.whereType<AlreadyOnShelf>(), hasLength(1));
    expect(await estante(), hasLength(2));
    expect(arquivos(), hasLength(2));
  });

  test('livro apagado da estante: importar de novo cria outro; outro dono não conta como repetido', () async {
    final bytes = simpleEpub(title: 'Iracema', chapters: const [_cap]);
    final a = await importador.importStream(
      Stream.value(bytes),
      fileName: 'i.epub',
    ) as Imported;
    final livro = (await UserBooksDao(db).byId(a.userBookId))!;
    await UserBooksDao(db).upsert(
      livro.copyWith(
        meta: metaTeste(apagado: true, em: DateTime.utc(2030, 1, 1)),
      ),
    );
    expect(
      await importador.importStream(Stream.value(bytes), fileName: 'i.epub'),
      isA<Imported>(),
    );
    dono = '0192c3d4-0000-7000-8000-00000000000b';
    expect(
      await importador.importStream(Stream.value(bytes), fileName: 'i.epub'),
      isA<Imported>(),
    );
  });

  group('falhas: nenhum arquivo nem linha pela metade', () {
    Future<void> falha(
      List<int> bytes,
      ImportError esperado, {
      String nome = 'x.epub',
    }) async {
      final r = await importador.importStream(
        Stream.value(bytes),
        fileName: nome,
      );
      expect(r, isA<ImportFailed>(), reason: nome);
      expect((r as ImportFailed).error, esperado, reason: nome);
      expect(await estante(), isEmpty);
      expect(arquivos(), isEmpty);
      expect(await db.select(db.localFiles).get(), isEmpty);
    }

    test(
      'nem EPUB nem PDF (texto, imagem, ZIP qualquer) → não suportado',
      () async {
        await falha(u('só texto'), ImportError.unsupported, nome: 'a.txt');
        await falha(tinyJpeg(), ImportError.unsupported, nome: 'b.epub');
        await falha(
          zipBytes([('a.txt', u('oi'))]),
          ImportError.unsupported,
          nome: 'c.zip',
        );
      },
    );

    test('protegido (Adobe) → protegido; quebrado → danificado; PDF com senha → protegido', () async {
      await falha(
        simpleEpub(
          chapters: const [_cap],
          metaInf: [('META-INF/rights.xml', u('<x/>'))],
        ),
        ImportError.protected,
      );
      await falha(
        zipBytes([
          ('mimetype', u('application/epub+zip')),
          ('META-INF/container.xml', u(containerXml)),
          ('OEBPS/content.opf', u('<package><quebrado')),
        ]),
        ImportError.damaged,
      );
      pdf.resposta = (_) => throw const ContentProtected('pdf_password');
      await falha(u('%PDF-1.7\n...'), ImportError.protected, nome: 'p.pdf');
    });

    test('falha no meio da cópia (arquivo de origem some) → falha inesperada, sem sobra', () async {
      final quebra = Stream<List<int>>.fromIterable([u('PK\x03\x04 começo')])
          .asyncExpand(
            (c) => Stream<List<int>>.fromFutures([
              Future.value(c),
              Future.error(const FileSystemException('origem sumiu')),
            ]),
          );
      final r = await importador.importStream(quebra, fileName: 'x.epub');
      expect((r as ImportFailed).error, ImportError.unexpected);
      expect(arquivos(), isEmpty);
      expect(erros, isNotEmpty);
    });
  });

  test('EPUB de páginas fixas entra com o aviso (D-92)', () async {
    final r = await importador.importStream(
      Stream.value(simpleEpub(chapters: const [_cap], fixedLayout: true)),
      fileName: 'quadrinho.epub',
    );
    expect((r as Imported).fixedLayout, isTrue);
  });

  group('título, autor e catálogo (D-91)', () {
    test('sem título no arquivo → nome do arquivo; sem autor → "Autoria desconhecida"', () async {
      final r = await importador.importStream(
        Stream.value(
          simpleEpub(
            chapters: const [_cap],
            metadata: '<dc:language>pt</dc:language>',
          ),
        ),
        fileName: 'O_cortiço_-_Aluísio.epub',
      );
      final b = (await UserBooksDao(db).byId((r as Imported).userBookId))!;
      expect(b.title, 'O cortiço - Aluísio');
      expect(b.authorDisplay, 'Autoria desconhecida');
      expect(catalogo.pedidos, isEmpty, reason: 'sem ISBN, sem consulta');
    });

    test('com ISBN: o catálogo preenche o que falta (autor, capa da fonte); o arquivo vale', () async {
      catalogo.resposta = (_) async => const IsbnMatch(
        title: 'Título do Catálogo',
        authors: ['José de Alencar'],
        coverRef: 'ol:123',
      );
      final r = await importador.importStream(
        Stream.value(
          simpleEpub(
            chapters: const [_cap],
            metadata: '<dc:title>Senhora</dc:title><dc:identifier>urn:isbn:9788535902778</dc:identifier>',
          ),
        ),
        fileName: 's.epub',
      );
      final b = (await UserBooksDao(db).byId((r as Imported).userBookId))!;
      expect(catalogo.pedidos, ['9788535902778']);
      expect(b.title, 'Senhora');
      expect(b.authorDisplay, 'José de Alencar');
      expect(b.coverRef, 'ol:123');
      expect(b.isbn13, '9788535902778');
    });

    test(
      'catálogo fora do ar ou lento: importa com o que está no arquivo',
      () async {
        catalogo.resposta = (_) =>
            Completer<IsbnMatch?>().future; // nunca responde
        final rapido = BookImporter(
          db: db,
          versioning: LocalVersioning(db, HlcClock(deviceId: 'aparelhoA')),
          owner: () async => dono,
          booksDir: () async => livros,
          fileCoversDir: () async => capas,
          pdf: pdf,
          catalog: catalogo,
          run: _aqui,
        );
        final sw = Stopwatch()..start();
        final r = await rapido.importStream(
          Stream.value(
            simpleEpub(
              title: 'Lucíola',
              chapters: const [_cap],
              identifier: 'urn:isbn:9788535902778',
            ),
          ),
          fileName: 'l.epub',
        );
        expect(r, isA<Imported>());
        expect(
          sw.elapsed,
          lessThan(BookImporter.catalogTimeout + const Duration(seconds: 2)),
        );
        catalogo.resposta = (_) async =>
            throw const SocketException('sem rede');
        expect(
          await rapido.importStream(
            Stream.value(
              simpleEpub(
                title: 'Diva',
                chapters: const [_cap],
                identifier: 'urn:isbn:9788535902778',
              ),
            ),
            fileName: 'd.epub',
          ),
          isA<Imported>(),
        );
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );
  });

  test('PDF: páginas = páginas de referência, título/autor do PDF, sumário e capa — já indexado', () async {
    final png = Uint8List.fromList([
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      1,
      2,
      3,
    ]);
    pdf.resposta = (_) => PdfInfo(
      pages: 3,
      title: 'Contos de Teste',
      author: 'Autora Exemplo',
      outline: const [
        PdfOutlineEntry(
          title: 'Primeiro conto',
          page: 1,
          depth: 0,
          hasChildren: false,
        ),
        PdfOutlineEntry(
          title: 'Segundo conto',
          page: 3,
          depth: 0,
          hasChildren: false,
        ),
      ],
      coverPng: png,
    );
    final bytes = u('%PDF-1.7\nconteúdo qualquer');
    final r = await importador.importStream(
      Stream.value(bytes),
      fileName: 'contos.pdf',
    ) as Imported;
    final b = (await UserBooksDao(db).byId(r.userBookId))!;
    expect(b.title, 'Contos de Teste');
    expect(b.authorDisplay, 'Autora Exemplo');
    expect(b.format, BookFileFormat.pdf);
    expect(b.refPagesTotal, 3);
    expect(b.refPageVersion, 1);
    expect(arquivos(), ['${b.id}.pdf']);
    expect(
      pdf.pedidos.single,
      endsWith('.part'),
      reason: 'inspeciona a cópia, antes de virar livro',
    );
    final idx = (await BookContentIndexDao(db).byBook(b.id))!;
    expect(idx.layout, 'pdf');
    expect(idx.refPages.kind, 'pdf');
    expect(idx.toc.map((t) => (t.title, t.offset)), [
      ('Primeiro conto', 0),
      ('Segundo conto', 2),
    ]);
    expect(
      File('${capas.path}${Platform.pathSeparator}${b.contentSha256}.img')
          .readAsBytesSync(),
      png,
    );
    expect(
      await importador.indexBook(b.id),
      isFalse,
      reason: 'PDF não tem 2º tempo',
    );
  });

  test('indexar o que ficou sem índice (o app fechou no meio): um por um, só uma vez', () async {
    final ids = <String>[];
    for (final t in ['Um', 'Dois']) {
      final r = await importador.importStream(
        Stream.value(simpleEpub(title: t, chapters: const [_cap])),
        fileName: '$t.epub',
      );
      ids.add((r as Imported).userBookId);
    }
    expect(await importador.indexPending(), 2);
    expect(await importador.indexPending(), 0);
    // arquivo trocado (outra versão): o índice antigo não vale mais
    final f = (await LocalFilesDao(db).byBook(ids.first))!;
    await LocalFilesDao(db).upsert(
      userBookId: f.userBookId,
      path: f.path,
      bytes: f.bytes,
      sha256: 'f' * 64,
      now: DateTime.utc(2026, 10, 5),
    );
    final livro = (await UserBooksDao(db).byId(ids.first))!;
    await UserBooksDao(db)
        .upsert(livro.copyWith(contentSha256: Nullable('f' * 64)));
    expect(await importador.indexPending(), 1);
  });

  test('2º tempo: um livro que falha não segura os outros; o que não abre não é tentado de novo', () async {
    final ids = <String>[];
    for (final t in ['A', 'B', 'C']) {
      final r = await importador.importStream(
        Stream.value(simpleEpub(title: t, chapters: const [_cap])),
        fileName: '$t.epub',
      );
      ids.add((r as Imported).userBookId);
    }
    var vezes = 0;
    final cuidadoso = novo(
      run: <T>(T Function() task) async {
        vezes++;
        // 1º livro da vez: conteúdo que não abre; 2º: erro que não é do conteúdo (banco, isolate)
        if (vezes == 1) throw const ContentDamaged('zip_crc');
        if (vezes == 2) throw StateError('isolate morreu');
        return task();
      },
    );
    expect(await cuidadoso.indexPending(), 1, reason: 'o 3º indexou');
    expect(erros, [isA<ContentDamaged>(), isA<StateError>()]);
    Future<List<bool>> comIndice() async => [
      for (final id in ids) await BookContentIndexDao(db).byBook(id) != null,
    ];
    expect((await comIndice()).where((x) => x), hasLength(1));
    erros.clear();
    // na próxima abertura: o do erro passageiro entra; o que não abre fica de fora (é o mesmo arquivo)
    expect(await importador.indexPending(), 1);
    expect(await importador.indexPending(), 0);
    expect(erros, isEmpty);
    final semIndice = [
      for (var i = 0; i < 3; i++)
        if (!(await comIndice())[i]) ids[i],
    ];
    expect(semIndice, hasLength(1));
    expect(
      File(
        '${livros.path}${Platform.pathSeparator}.sem-indice-${semIndice.single}',
      ).existsSync(),
      isTrue,
    );
  });

  test('arquivo guardado com o caminho de antes (a pasta do app mudou de lugar): acha pelo nome', () async {
    final r = await importador.importStream(
      Stream.value(simpleEpub(title: 'Mudou', chapters: const [_cap])),
      fileName: 'm.epub',
    ) as Imported;
    final f = (await LocalFilesDao(db).byBook(r.userBookId))!;
    final nome = f.path.split(RegExp(r'[/\\]')).last;
    await LocalFilesDao(db).upsert(
      userBookId: f.userBookId,
      path: '/var/mobile/Containers/Data/Application/ANTIGA/livros/$nome',
      bytes: f.bytes,
      sha256: f.sha256,
      now: DateTime.utc(2026, 10, 5),
    );
    expect(await importador.indexBook(r.userBookId), isTrue);
  });

  test('limpeza ao abrir: sobras antigas de importação e arquivos sem livro saem; o resto fica', () async {
    final r = await importador.importStream(
      Stream.value(simpleEpub(title: 'Fica', chapters: const [_cap])),
      fileName: 'f.epub',
    ) as Imported;
    final antigo = DateTime.now().subtract(const Duration(days: 2));
    File sobra(String nome, {bool velho = true}) {
      final f = File('${livros.path}${Platform.pathSeparator}$nome')
        ..writeAsBytesSync([1]);
      if (velho) f.setLastModifiedSync(antigo);
      return f;
    }

    final parte = sobra(
      '.importando-0192c3d4-0000-7000-8000-000000000001.part',
    );
    final orfao = sobra('0192c3d4-0000-7000-8000-000000000002.epub');
    final marca = sobra('.sem-indice-0192c3d4-0000-7000-8000-000000000003');
    final parteNova = sobra(
      '.importando-0192c3d4-0000-7000-8000-000000000004.part',
      velho: false,
    );
    final orfaoNovo = sobra(
      '0192c3d4-0000-7000-8000-000000000005.pdf',
      velho: false,
    );
    final download = sobra('0192c3d4-0000-7000-8000-000000000006.epub.parte');
    final outro = sobra('leia-me.txt');
    final doLivro = File((await LocalFilesDao(db).byBook(r.userBookId))!.path)
      ..setLastModifiedSync(antigo);
    expect(await importador.cleanUp(), 3);
    expect([parte, orfao, marca].map((f) => f.existsSync()), [
      false,
      false,
      false,
    ]);
    expect(
      [
        parteNova,
        orfaoNovo,
        download,
        outro,
        doLivro,
      ].map((f) => f.existsSync()),
      everyElement(isTrue),
    );
  });

  test('disco cheio também no banco (SQLITE_FULL) → "sem espaço"', () {
    expect(
      isNoSpace(
        SqliteException(
          extendedResultCode: 13,
          message: 'database or disk is full',
        ),
      ),
      isTrue,
    );
    expect(
      isNoSpace(SqliteException(extendedResultCode: 19, message: 'constraint')),
      isFalse,
    );
    expect(
      isNoSpace(
        const FileSystemException(
          'x',
          'y',
          OSError('No space left on device', 28),
        ),
      ),
      isTrue,
    );
    expect(isNoSpace(StateError('x')), isFalse);
  });

  test('isolate de verdade: o Dom Casmurro do Gutenberg entra e indexa (153 capítulos, 264 páginas)', () async {
    final real = novo(run: runInIsolate);
    final arquivo = File('test/fixtures/livros/pg55752.epub');
    final r = await real.importFile(arquivo) as Imported;
    expect(r.title, 'Dom Casmurro');
    expect(await real.indexBook(r.userBookId), isTrue);
    final b = (await UserBooksDao(db).byId(r.userBookId))!;
    expect(b.authorDisplay, 'Machado de Assis');
    expect(b.chaptersTotal, 153);
    expect(b.refPagesTotal, 264);
    expect(
      File('${capas.path}${Platform.pathSeparator}${b.contentSha256}.img')
          .lengthSync(),
      40980,
    );
  }, timeout: const Timeout(Duration(seconds: 60)));
}
