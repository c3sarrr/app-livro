// G09.4 — o que a importação precisa de um PDF (D-93): páginas (= páginas de referência, D-89), título e
// autor do dicionário Info (sem os valores de enchimento que os geradores põem), sumário e a 1ª página como
// capa (D-90). Interface com implementação real (`pdfrx`, PDFium) e falsa nos testes.
import 'dart:typed_data';

final class PdfOutlineEntry {
  const PdfOutlineEntry({
    required this.title,
    required this.depth,
    required this.hasChildren,
    this.page,
  });

  final String title;

  /// Página (1…n) do destino; `null` = sem destino.
  final int? page;
  final int depth;
  final bool hasChildren;
}

final class PdfInfo {
  const PdfInfo({
    required this.pages,
    this.title,
    this.author,
    this.outline = const [],
    this.coverPng,
  });

  final int pages;
  final String? title;
  final String? author;
  final List<PdfOutlineEntry> outline;
  final Uint8List? coverPng;
}

abstract interface class PdfInspector {
  /// Lê o PDF em [path]. Senha → `ContentProtected('pdf_password')`; quebrado → `ContentDamaged`.
  Future<PdfInfo> inspect(String path);
}

/// Título/autor do Info que não dizem nada (enchimento dos geradores) → `null`.
String? cleanPdfText(String? raw) {
  if (raw == null) return null;
  var t = raw
      .replaceAll(RegExp(r'[\x00-\x1F]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  t = t.replaceFirst(
    RegExp(r'^Microsoft (Word|PowerPoint) - ', caseSensitive: false),
    '',
  );
  if (RegExp(
    r'\.(docx?|pdf|odt|rtf|pptx?|txt|indd|tex)$',
    caseSensitive: false,
  ).hasMatch(t)) {
    return null;
  }
  const filler = {
    '',
    'untitled',
    'unknown',
    'anonymous',
    'sem título',
    'none',
    'null',
    'title',
    'author',
    'admin',
    'user',
  };
  return filler.contains(t.toLowerCase()) ? null : t;
}
