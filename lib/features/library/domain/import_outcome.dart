// G09.4 — resultado de importar um arquivo (D-87, D-93): cada caso tem a sua frase na Biblioteca (D-21).

sealed class ImportOutcome {
  const ImportOutcome();
}

/// Entrou na estante ("«Título» está na sua estante." — ou o aviso de páginas fixas, D-92).
final class Imported extends ImportOutcome {
  const Imported({
    required this.userBookId,
    required this.title,
    this.fixedLayout = false,
  });

  final String userBookId;
  final String title;
  final bool fixedLayout;
}

/// O mesmo arquivo (sha256) já está na estante: nada foi criado.
final class AlreadyOnShelf extends ImportOutcome {
  const AlreadyOnShelf({required this.userBookId, required this.title});

  final String userBookId;
  final String title;
}

enum ImportError {
  /// Nem EPUB nem PDF.
  unsupported,

  /// Arquivo quebrado.
  damaged,

  /// DRM ou senha.
  protected,

  /// Sem espaço no aparelho.
  noSpace,

  /// Qualquer outra falha (vai para o relatório de falhas, sem dado da pessoa).
  unexpected,
}

final class ImportFailed extends ImportOutcome {
  const ImportFailed(this.error);

  final ImportError error;
}
