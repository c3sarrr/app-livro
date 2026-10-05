// G09 — importação ligada ao app (Riverpod, D-87): o botão da Biblioteca (seletor), o "Abrir com" do sistema
// (lidos quando o app abre e a cada aviso) e o segundo tempo (índice) em segundo plano. Um controlador só, no
// nível do app — o "Abrir com" chega com qualquer aba aberta e leva à Biblioteca (`IncomingBooks`).
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/database/local_database.dart';
import '../../../core/sync/sync_providers.dart' show localVersioningProvider;
import '../../account/application/account_providers.dart'
    show localLibraryProvider;
import '../../catalog/application/catalog_providers.dart'
    show catalogUpdaterProvider, edgeCatalogApiProvider;
import '../../catalog/application/isbn_resolver.dart';
import '../../catalog/data/catalog_cache_dao.dart';
import '../../home/application/home_providers.dart' show clockProvider;
import '../data/book_dirs.dart';
import '../data/book_picker.dart';
import '../data/incoming_files.dart';
import '../data/pdf_inspector.dart';
import '../data/pdfrx_pdf_inspector.dart';
import '../domain/import_outcome.dart';
import 'book_importer.dart';

final booksDirProvider = Provider<Future<Directory> Function()>(
  (ref) => booksDirectory,
);

final fileCoversDirProvider = Provider<Future<Directory> Function()>(
  (ref) => fileCoversDirectory,
);

final pdfInspectorProvider = Provider<PdfInspector>(
  (ref) => PdfrxPdfInspector(),
);

final bookPickerProvider = Provider<BookPicker>(
  (ref) => const SystemBookPicker(),
);

final incomingFilesProvider = Provider<IncomingFiles>(
  (ref) => ChannelIncomingFiles(),
);

/// Falhas inesperadas da importação (sem dado da pessoa) → relatório de falhas. Os testes trocam.
final libraryErrorReporterProvider =
    Provider<void Function(Object error, StackTrace stack)>(
      (ref) =>
          (e, st) => FlutterError.reportError(
            FlutterErrorDetails(exception: e, stack: st, library: 'biblioteca'),
          ),
    );

final bookImporterProvider = FutureProvider<BookImporter>((ref) async {
  final db = await ref.watch(localDatabaseProvider.future);
  final library = await ref.watch(localLibraryProvider.future);
  final updater = await ref.watch(catalogUpdaterProvider.future);
  return BookImporter(
    db: db,
    versioning: await ref.watch(localVersioningProvider.future),
    owner: library.activeOwnerId,
    booksDir: ref.watch(booksDirProvider),
    fileCoversDir: ref.watch(fileCoversDirProvider),
    pdf: ref.watch(pdfInspectorProvider),
    // D-91: só o aparelho e o Worker (sem comunidade, sem consulta externa)
    catalog: ResolverIsbnLookup(
      IsbnResolver(
        cache: CatalogCacheDao(db),
        localCatalog: () async => updater?.catalog(),
        edge: ref.watch(edgeCatalogApiProvider),
        now: ref.watch(clockProvider),
      ),
    ),
    onError: ref.watch(libraryErrorReporterProvider),
  );
});

sealed class ImportView {
  const ImportView();
}

final class ImportIdle extends ImportView {
  const ImportIdle();
}

final class ImportBusy extends ImportView {
  const ImportBusy(this.fileName, {this.fromSystem = false});

  final String fileName;

  /// Veio do "Abrir com" / "Compartilhar" (o app vai para a Biblioteca).
  final bool fromSystem;
}

final class ImportFinished extends ImportView {
  const ImportFinished(this.outcome);

  final ImportOutcome outcome;
}

final libraryImportProvider =
    NotifierProvider<LibraryImportController, ImportView>(
      LibraryImportController.new,
    );

class LibraryImportController extends Notifier<ImportView> {
  /// Importações na fila (a que está rodando + as que esperam).
  int _active = 0;
  Future<void> _last = Future<void>.value();
  bool _started = false;
  bool _receiving = false;
  bool _again = false;

  @override
  ImportView build() => const ImportIdle();

  /// Liga o "Abrir com" e o segundo tempo pendente — chamado uma vez pelo app (`IncomingBooks`, no `main`);
  /// nos testes de tela nada disso roda sozinho.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    final sub = ref
        .read(incomingFilesProvider)
        .arrivals
        .listen((_) => unawaited(receive()));
    ref.onDispose(sub.cancel);
    // sobras de quando o app morreu no meio, o que chegou pelo sistema antes do app subir e o que ficou sem
    // índice
    await _guard(
      () async => (await ref.read(bookImporterProvider.future)).cleanUp(),
    );
    if (!ref.mounted) return;
    await receive();
    if (!ref.mounted) return;
    await _guard(
      () async => (await ref.read(bookImporterProvider.future)).indexPending(),
    );
  }

  /// Botão "Importar livro (EPUB ou PDF)".
  Future<void> pick() async {
    if (_active > 0) return;
    final picked = await _guard(() => ref.read(bookPickerProvider).pick());
    if (picked == null || !ref.mounted) return;
    await _run(
      picked.name,
      false,
      (i) => i.importStream(picked.bytes, fileName: picked.name),
    );
  }

  /// Arquivos do "Abrir com" / "Compartilhar" (o que chegar no meio entra na mesma volta).
  Future<void> receive() async {
    if (_receiving) {
      _again = true;
      return;
    }
    _receiving = true;
    try {
      do {
        _again = false;
        final files =
            await _guard(() => ref.read(incomingFilesProvider).take()) ??
            const [];
        for (final f in files) {
          if (!ref.mounted) return;
          await _run(
            f.name,
            true,
            (i) => i.importFile(File(f.path), fileName: f.name),
          );
          try {
            await File(f.path).delete();
          } on FileSystemException {
            // a pasta temporária é limpa pelo sistema
          }
        }
      } while (_again);
    } finally {
      _receiving = false;
    }
  }

  /// Uma importação de cada vez, na ordem em que chegaram (o botão e o "Abrir com" dividem a fila): cada uma
  /// mostra o "Importando…" e o resultado dela.
  Future<void> _run(
    String name,
    bool fromSystem,
    Future<ImportOutcome> Function(BookImporter) work,
  ) async {
    _active++;
    final before = _last;
    final done = Completer<void>();
    _last = done.future;
    try {
      await before;
      if (!ref.mounted) return;
      await _runOne(name, fromSystem, work);
    } finally {
      _active--;
      done.complete();
    }
  }

  Future<void> _runOne(
    String name,
    bool fromSystem,
    Future<ImportOutcome> Function(BookImporter) work,
  ) async {
    state = ImportBusy(name, fromSystem: fromSystem);
    try {
      final importer = await ref.read(bookImporterProvider.future);
      final outcome = await work(importer);
      // o app fechou no meio: o livro ficou na estante; o índice sai no próximo `start`
      if (!ref.mounted) return;
      state = ImportFinished(outcome);
      if (outcome is Imported) {
        unawaited(_guard(() => importer.indexBook(outcome.userBookId)));
      }
    } on Object catch (e, st) {
      if (!ref.mounted) return;
      ref.read(libraryErrorReporterProvider)(e, st);
      state = const ImportFinished(ImportFailed(ImportError.unexpected));
    }
  }

  Future<T?> _guard<T>(Future<T> Function() f) async {
    try {
      return await f();
    } on Object catch (e, st) {
      // depois do fim do app não há a quem contar (nem como): o erro morre aqui
      if (ref.mounted) ref.read(libraryErrorReporterProvider)(e, st);
      return null;
    }
  }
}

/// Pedido de ir à aba Biblioteca (o "Abrir com" chegou com outra aba aberta). A navegação mora na `MainShell`.
final libraryTabRequestProvider = NotifierProvider<LibraryTabRequest, int>(
  LibraryTabRequest.new,
);

class LibraryTabRequest extends Notifier<int> {
  @override
  int build() => 0;

  void request() => state++;
}
