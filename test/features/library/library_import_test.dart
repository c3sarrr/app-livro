// G09.5 — a importação ligada ao app (D-87): botão da Biblioteca (seletor), "Abrir com" (pendentes ao abrir e a
// cada aviso, inclusive o que chega no meio), índice em segundo plano, frases de cada resultado (D-21, D-92) e a
// troca para a aba Biblioteca quando o arquivo vem do sistema. As esperas vão até 15 s (a suíte inteira roda em
// paralelo e o isolate do índice disputa a CPU).
import 'dart:async';
import 'dart:io';

import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/app/routes.dart';
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/features/library/application/book_importer.dart';
import 'package:app_leitura/features/library/application/library_import.dart';
import 'package:app_leitura/features/library/data/book_picker.dart';
import 'package:app_leitura/features/library/data/incoming_files.dart';
import 'package:app_leitura/features/library/data/pdf_inspector.dart';
import 'package:app_leitura/features/library/domain/import_outcome.dart';
import 'package:app_leitura/features/library/presentation/incoming_books.dart';
import 'package:app_leitura/features/library/presentation/library_import_block.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../fixtures/overrides_do_mundo.dart';
import '../../support/app_text_finder.dart';
import '../../support/epub_builder.dart';
import '../../support/load_fonts.dart';
import '../../support/personal_builders.dart';
import '../../support/precache_svgs.dart';

final class _Seletor implements BookPicker {
  PickedBook? proximo;
  int vezes = 0;

  @override
  Future<PickedBook?> pick() async {
    vezes++;
    return proximo;
  }
}

final class _Recebidos implements IncomingFiles {
  final StreamController<void> avisos = StreamController<void>.broadcast();
  final List<IncomingFile> fila = [];

  @override
  Stream<void> get arrivals => avisos.stream;

  @override
  Future<List<IncomingFile>> take() async {
    final r = List.of(fila);
    fila.clear();
    return r;
  }
}

final class _SemPdf implements PdfInspector {
  @override
  Future<PdfInfo> inspect(String path) => throw StateError('sem PDF aqui');
}

Future<T> _aqui<T>(T Function() task) async => task();

void main() {
  late Directory raiz;
  late AppDatabase db;
  late _Seletor seletor;
  late _Recebidos recebidos;
  late BookImporter importador;
  final erros = <Object>[];

  setUp(() {
    raiz = Directory.systemTemp.createTempSync('booknest_bib_');
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    seletor = _Seletor();
    recebidos = _Recebidos();
    erros.clear();
    importador = BookImporter(
      db: db,
      versioning: LocalVersioning(db, HlcClock(deviceId: 'aparelhoA')),
      owner: () async => usuarioTeste,
      booksDir: () async =>
          Directory('${raiz.path}${Platform.pathSeparator}livros'),
      fileCoversDir: () async =>
          Directory('${raiz.path}${Platform.pathSeparator}capas'),
      pdf: _SemPdf(),
      run: _aqui,
    );
  });
  tearDown(() async {
    await db.close();
    raiz.deleteSync(recursive: true);
  });

  List<Override> overrides() => [
    bookImporterProvider.overrideWith((ref) async => importador),
    bookPickerProvider.overrideWithValue(seletor),
    incomingFilesProvider.overrideWithValue(recebidos),
    libraryErrorReporterProvider.overrideWithValue((e, _) => erros.add(e)),
  ];

  String recebido(String nome, List<int> bytes) {
    final f = File('${raiz.path}${Platform.pathSeparator}recebido-$nome')
      ..writeAsBytesSync(bytes);
    return f.path;
  }

  Future<void> ate(bool Function() ok) async {
    for (var i = 0; i < 1500 && !ok(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  group('controlador', () {
    test('botão: seletor → "Importando…" → resultado; o índice vem em segundo plano', () async {
      final c = ProviderContainer.test(overrides: overrides());
      final vistos = <ImportView>[];
      c.listen(
        libraryImportProvider,
        (_, v) => vistos.add(v),
        fireImmediately: true,
      );
      seletor.proximo = PickedBook(
        name: 'Senhora.epub',
        bytes: Stream.value(
          simpleEpub(
            title: 'Senhora',
            chapters: const [(file: 'c.xhtml', title: 'I', body: '<p>Oi.</p>')],
          ),
        ),
      );
      await c.read(libraryImportProvider.notifier).pick();
      expect(vistos[0], isA<ImportIdle>());
      expect((vistos[1] as ImportBusy).fileName, 'Senhora.epub');
      expect((vistos[1] as ImportBusy).fromSystem, isFalse);
      final fim = vistos.last as ImportFinished;
      final ok = fim.outcome as Imported;
      expect(ok.title, 'Senhora');
      for (
        var i = 0;
        i < 1500 && await BookContentIndexDao(db).byBook(ok.userBookId) == null;
        i++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(await BookContentIndexDao(db).byBook(ok.userBookId), isNotNull);
      expect(erros, isEmpty);
    });

    test('a pessoa cancelou o seletor: nada muda', () async {
      final c = ProviderContainer.test(overrides: overrides());
      await c.read(libraryImportProvider.notifier).pick();
      expect(seletor.vezes, 1);
      expect(c.read(libraryImportProvider), isA<ImportIdle>());
    });

    test('"Abrir com": pendentes ao abrir, o aviso traz os novos (inclusive no meio), e a cópia recebida some', () async {
      final c = ProviderContainer.test(overrides: overrides());
      final vistos = <ImportView>[];
      c.listen(libraryImportProvider, (_, v) => vistos.add(v));
      final a = recebido(
        'a',
        simpleEpub(
          title: 'Iracema',
          chapters: const [(file: 'c.xhtml', title: 'I', body: '<p>Oi.</p>')],
        ),
      );
      recebidos.fila.add(IncomingFile(path: a, name: 'Iracema.epub'));
      await c.read(libraryImportProvider.notifier).start();
      expect(vistos.whereType<ImportBusy>().single.fromSystem, isTrue);
      expect(
        ((vistos.last as ImportFinished).outcome as Imported).title,
        'Iracema',
      );
      expect(File(a).existsSync(), isFalse);
      // chegaram dois de uma vez, e um terceiro no meio da importação
      vistos.clear();
      for (final t in ['Lucíola', 'Diva']) {
        recebidos.fila.add(
          IncomingFile(
            path: recebido(
              t,
              simpleEpub(
                title: t,
                chapters: const [
                  (file: 'c.xhtml', title: 'I', body: '<p>Oi.</p>'),
                ],
              ),
            ),
            name: '$t.epub',
          ),
        );
      }
      recebidos.avisos.add(null);
      await ate(() => vistos.whereType<ImportBusy>().isNotEmpty);
      recebidos.fila.add(
        IncomingFile(
          path: recebido(
            '5',
            simpleEpub(
              title: 'Ubirajara',
              chapters: const [
                (file: 'c.xhtml', title: 'I', body: '<p>Oi.</p>'),
              ],
            ),
          ),
          name: 'Ubirajara.epub',
        ),
      );
      recebidos.avisos.add(null);
      await ate(() => vistos.whereType<ImportFinished>().length >= 3);
      expect(
        [
          for (final v in vistos.whereType<ImportFinished>())
            (v.outcome as Imported).title,
        ],
        ['Lucíola', 'Diva', 'Ubirajara'],
      );
      expect(erros, isEmpty);
    });

    test('ao abrir: indexa o que ficou sem índice; ligar duas vezes não duplica nada', () async {
      final r = await importador.importStream(
        Stream.value(
          simpleEpub(
            title: 'Sem índice',
            chapters: const [(file: 'c.xhtml', title: 'I', body: '<p>Oi.</p>')],
          ),
        ),
        fileName: 's.epub',
      ) as Imported;
      expect(await BookContentIndexDao(db).byBook(r.userBookId), isNull);
      // sobra de uma importação de quando o app morreu no meio (antiga)
      final livros = Directory('${raiz.path}${Platform.pathSeparator}livros');
      final sobra =
          File('${livros.path}${Platform.pathSeparator}.importando-x.part')
            ..writeAsBytesSync([1, 2, 3])
            ..setLastModifiedSync(
              DateTime.now().subtract(const Duration(days: 1)),
            );
      // e um arquivo do "Abrir com" esperando
      recebidos.fila.add(
        IncomingFile(
          path: recebido(
            'u',
            simpleEpub(
              title: 'Ubirajara',
              chapters: const [
                (file: 'c.xhtml', title: 'I', body: '<p>Oi.</p>'),
              ],
            ),
          ),
          name: 'Ubirajara.epub',
        ),
      );
      final c = ProviderContainer.test(overrides: overrides());
      final vistos = <ImportView>[];
      c.listen(libraryImportProvider, (_, v) => vistos.add(v));
      await Future.wait([
        c.read(libraryImportProvider.notifier).start(),
        c.read(libraryImportProvider.notifier).start(),
      ]);
      await c.read(libraryImportProvider.notifier).start();
      expect(await BookContentIndexDao(db).byBook(r.userBookId), isNotNull);
      expect(vistos.whereType<ImportFinished>(), hasLength(1));
      final livrosNoBanco = await db
          .customSelect('SELECT COUNT(*) AS n FROM user_books')
          .getSingle();
      expect(livrosNoBanco.read<int>('n'), 2);
      expect(sobra.existsSync(), isFalse);
      expect(erros, isEmpty);
    });

    test('botão e "Abrir com" ao mesmo tempo: um de cada vez, cada um com o seu aviso, na ordem', () async {
      final c = ProviderContainer.test(overrides: overrides());
      final vistos = <ImportView>[];
      c.listen(libraryImportProvider, (_, v) => vistos.add(v));
      await c.read(libraryImportProvider.notifier).start();
      final trava = Completer<void>();
      seletor.proximo = PickedBook(
        name: 'Senhora.epub',
        bytes: (() async* {
          await trava.future;
          yield simpleEpub(
            title: 'Senhora',
            chapters: const [(file: 'c.xhtml', title: 'I', body: '<p>Oi.</p>')],
          );
        })(),
      );
      final escolher = c.read(libraryImportProvider.notifier).pick();
      await ate(() => vistos.whereType<ImportBusy>().isNotEmpty);
      recebidos.fila.add(
        IncomingFile(
          path: recebido(
            'i',
            simpleEpub(
              title: 'Iracema',
              chapters: const [
                (file: 'c.xhtml', title: 'I', body: '<p>Oi.</p>'),
              ],
            ),
          ),
          name: 'Iracema.epub',
        ),
      );
      recebidos.avisos.add(null);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      // o do sistema espera: o aviso na tela continua sendo o do botão
      expect(c.read(libraryImportProvider), isA<ImportBusy>());
      expect(
        (c.read(libraryImportProvider) as ImportBusy).fileName,
        'Senhora.epub',
      );
      // e o botão continua desligado
      await c.read(libraryImportProvider.notifier).pick();
      expect(seletor.vezes, 1);
      trava.complete();
      await escolher;
      await ate(() => vistos.whereType<ImportFinished>().length >= 2);
      expect(
        [
          for (final v in vistos)
            switch (v) {
              ImportBusy(:final fileName, :final fromSystem) =>
                'importando $fileName${fromSystem ? ' (sistema)' : ''}',
              ImportFinished(:final outcome) =>
                'pronto ${(outcome as Imported).title}',
              ImportIdle() => 'parado',
            },
        ],
        [
          'importando Senhora.epub',
          'pronto Senhora',
          'importando Iracema.epub (sistema)',
          'pronto Iracema',
        ],
      );
      expect(erros, isEmpty);
    });

    test(
      'o app fechou no meio (contêiner descartado): nada estoura depois',
      () async {
        // o importador só fica pronto depois do fim (banco ainda abrindo quando o app fecha)
        final pronto = Completer<BookImporter>();
        var pedido = false;
        final c = ProviderContainer(
          overrides: [
            bookPickerProvider.overrideWithValue(seletor),
            incomingFilesProvider.overrideWithValue(recebidos),
            libraryErrorReporterProvider.overrideWithValue(
              (e, _) => erros.add(e),
            ),
            bookImporterProvider.overrideWith((ref) {
              pedido = true;
              return pronto.future;
            }),
          ],
        );
        final ligar = c.read(libraryImportProvider.notifier).start();
        await ate(() => pedido);
        c.dispose();
        pronto.completeError(StateError('banco fechado'));
        await expectLater(ligar, completes);

        // e no meio de uma importação: o resultado chega com o app já fechado
        final trava = Completer<void>();
        final c2 = ProviderContainer(overrides: overrides());
        seletor.proximo = PickedBook(
          name: 'Senhora.epub',
          bytes: (() async* {
            await trava.future;
            yield simpleEpub(
              title: 'Senhora',
              chapters: const [
                (file: 'c.xhtml', title: 'I', body: '<p>Oi.</p>'),
              ],
            );
          })(),
        );
        final escolher = c2.read(libraryImportProvider.notifier).pick();
        await ate(() => c2.read(libraryImportProvider) is ImportBusy);
        c2.dispose();
        trava.complete();
        await expectLater(escolher, completes);
        expect(erros, isEmpty);
      },
    );
  });

  group('frases (D-21, D-87, D-92, Anexo 03 §2)', () {
    test('uma por resultado; erro em vermelho, confirmação em verde', () {
      expect(
        importMessage(const Imported(userBookId: 'x', title: 'Senhora')),
        '«Senhora» está na sua estante.',
      );
      expect(
        importMessage(
          const Imported(userBookId: 'x', title: 'Q', fixedLayout: true),
        ),
        'Este livro tem páginas fixas; a leitura dele ainda não está pronta no BookNest.',
      );
      expect(
        importMessage(const AlreadyOnShelf(userBookId: 'x', title: 'Q')),
        'Esse livro já está na sua estante.',
      );
      expect(
        importMessage(const ImportFailed(ImportError.unsupported)),
        'Esse arquivo não é um EPUB nem um PDF.',
      );
      expect(
        importMessage(const ImportFailed(ImportError.damaged)),
        'Não deu para abrir esse arquivo. Ele pode estar danificado.',
      );
      expect(
        importMessage(const ImportFailed(ImportError.protected)),
        'Este arquivo tem proteção e não pode ser aberto.',
      );
      expect(
        importMessage(const ImportFailed(ImportError.noSpace)),
        'Não há espaço no aparelho para guardar este livro.',
      );
      expect(
        importMessage(const ImportFailed(ImportError.unexpected)),
        'Não deu para importar agora. Tente de novo.',
      );
      expect(
        importIsError(const Imported(userBookId: 'x', title: 'Q')),
        isFalse,
      );
      expect(
        importIsError(const AlreadyOnShelf(userBookId: 'x', title: 'Q')),
        isFalse,
      );
      expect(
        importIsError(
          const Imported(userBookId: 'x', title: 'Q', fixedLayout: true),
        ),
        isTrue,
      );
      expect(importIsError(const ImportFailed(ImportError.damaged)), isTrue);
    });
  });

  group('tela', () {
    setUpAll(loadAppFonts);

    testWidgets(
      'Biblioteca: texto, botão e o aviso depois de importar; botão desligado enquanto importa',
      (tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(
            ProviderScope(
              overrides: overrides(),
              child: const Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: SizedBox(width: 360, child: LibraryImportBlock()),
                ),
              ),
            ),
          );
          expect(
            findAppText('Traga seus livros em EPUB ou PDF.'),
            findsOneWidget,
          );
          expect(findAppText('Importar livro (EPUB ou PDF)'), findsOneWidget);
          final trava = Completer<void>();
          seletor.proximo = PickedBook(
            name: 'Senhora.epub',
            bytes: (() async* {
              await trava.future;
              yield simpleEpub(
                title: 'Senhora',
                chapters: const [
                  (file: 'c.xhtml', title: 'I', body: '<p>Oi.</p>'),
                ],
              );
            })(),
          );
          await tester.tap(findAppText('Importar livro (EPUB ou PDF)'));
          await tester.pump();
          expect(findAppText('Importando «Senhora.epub»…'), findsOneWidget);
          await tester.tap(findAppText('Importar livro (EPUB ou PDF)'));
          expect(seletor.vezes, 1, reason: 'desligado enquanto importa');
          trava.complete();
          for (var i = 0; i < 1500; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 10));
            await tester.pump();
            if (findAppText('«Senhora» está na sua estante.')
                .evaluate()
                .isNotEmpty) {
              break;
            }
          }
          expect(findAppText('«Senhora» está na sua estante.'), findsOneWidget);
        });
      },
    );

    testWidgets(
      '"Abrir com" com a Início aberta: o app vai para a Biblioteca e mostra o resultado',
      (tester) async {
        tester.view.physicalSize = const Size(1170, 2532);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        await precacheAppIcons(tester);
        await tester.runAsync(() async {
          recebidos.fila.add(
            IncomingFile(
              path: recebido(
                'i',
                simpleEpub(
                  title: 'Iracema',
                  chapters: const [
                    (file: 'c.xhtml', title: 'I', body: '<p>Oi.</p>'),
                  ],
                ),
              ),
              name: 'Iracema.epub',
            ),
          );
          await tester.pumpWidget(
            ProviderScope(
              overrides: [...overridesDoMundo, ...overrides()],
              child: const IncomingBooks(child: App.forTests()),
            ),
          );
          for (var i = 0; i < 1500; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 10));
            await tester.pump();
            if (findAppText('«Iracema» está na sua estante.')
                .evaluate()
                .isNotEmpty) {
              break;
            }
          }
          final router = GoRouter.of(
            tester.element(find.byType(LibraryImportBlock)),
          );
          expect(router.state.uri.path, AppRoutes.biblioteca);
          expect(findAppText('«Iracema» está na sua estante.'), findsOneWidget);
        });
      },
    );
  });
}
