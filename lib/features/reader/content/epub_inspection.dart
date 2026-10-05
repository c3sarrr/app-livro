// G09.4 — primeiro tempo da importação de um EPUB (Anexo 03 §3, D-93): só o que a estante precisa para
// mostrar o livro já — metadados, capa e layout — sem abrir os capítulos (o índice vem no segundo tempo).
// Dart puro, para `Isolate.run`.
import 'dart:typed_data';

import 'epub_book.dart';
import 'epub_package.dart';

final class EpubInspection {
  const EpubInspection({
    required this.title,
    required this.authors,
    required this.fixedLayout,
    this.language,
    this.isbn13,
    this.cover,
  });

  final String title;
  final List<String> authors;
  final String? language;
  final String? isbn13;
  final bool fixedLayout;

  /// Imagem da capa que vem no arquivo (D-90), ou `null`.
  final Uint8List? cover;
}

/// Abre o EPUB em [path] (DRM → `ContentProtected`; quebrado → `ContentDamaged`) e lê o necessário.
EpubInspection inspectEpub(String path) {
  final book = EpubBook.open(path);
  try {
    final m = book.package.metadata;
    return EpubInspection(
      title: m.title,
      authors: m.authors,
      language: m.language,
      isbn13: m.isbn13,
      fixedLayout: book.package.layout == EpubLayout.fixed,
      cover: book.coverBytes(),
    );
  } finally {
    book.close();
  }
}
