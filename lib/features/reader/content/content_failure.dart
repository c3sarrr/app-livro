// G09 — falhas ao abrir o conteúdo de um livro (D-21: cada uma tem a sua frase na Biblioteca).
// Toda exceção de arquivo malformado vira uma destas — nunca uma exceção solta de ZIP/XML/PDF.

sealed class ContentFailure implements Exception {
  const ContentFailure(this.reason);

  /// Motivo técnico curto (vai para o log, sem dado da pessoa).
  final String reason;

  @override
  String toString() => '$runtimeType($reason)';
}

/// O arquivo está quebrado: não é ZIP/PDF de verdade, falta o pacote, CRC errado, limites passados.
final class ContentDamaged extends ContentFailure {
  const ContentDamaged(super.reason);
}

/// DRM ou senha: `adobe`, `lcp`, `encrypted` (EPUB) ou `pdf_password`.
final class ContentProtected extends ContentFailure {
  const ContentProtected(super.reason);
}

/// Formato que o app não lê (nem EPUB nem PDF, ou compressão desconhecida dentro do ZIP).
final class ContentUnsupported extends ContentFailure {
  const ContentUnsupported(super.reason);
}
