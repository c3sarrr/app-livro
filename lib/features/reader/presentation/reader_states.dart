// G11.3 — estados do leitor que o arquivo não desenha (D-21, D-113): "Abrindo o livro…" (ou "Preparando o
// livro…", quando indexa ao abrir) só depois de 300 ms, e os erros com o bloco mínimo da Biblioteca/Perfil
// (os mesmos primitivos da D-69) e "Voltar" — mais "Tentar de novo" na falha inesperada.
import 'package:flutter/widgets.dart';

import '../../account/presentation/account_widgets.dart';
import '../application/reader_session_controller.dart';

/// Antes disso, só o papel (abrir costuma ser mais rápido que isso).
const Duration readerOpeningDelay = Duration(milliseconds: 300);

/// Texto de cada falha (G11 §3; páginas fixas = D-92).
String readerFailureText(ReaderFailure f) => switch (f) {
  ReaderFailure.notOnShelf => 'Este livro não está mais na sua estante.',
  ReaderFailure.fileMissing =>
    'O arquivo deste livro não está mais no aparelho.',
  ReaderFailure.damaged =>
    'Não deu para abrir este livro. O arquivo pode estar danificado.',
  ReaderFailure.fixedLayout => 'Este livro tem páginas fixas; a leitura dele ainda não está pronta no BookNest.',
  ReaderFailure.unexpected => 'Não deu para abrir o livro agora.',
};

class ReaderOpeningView extends StatelessWidget {
  const ReaderOpeningView({
    super.key,
    required this.visible,
    this.preparing = false,
  });

  final bool visible;
  final bool preparing;

  @override
  Widget build(BuildContext context) => Center(
    child: visible
        ? AccountText(
            preparing ? 'Preparando o livro…' : 'Abrindo o livro…',
            key: const ValueKey('leitor.abrindo'),
            muted: true,
          )
        : const SizedBox.shrink(),
  );
}

class ReaderFailureView extends StatelessWidget {
  const ReaderFailureView({
    super.key,
    required this.failure,
    required this.onBack,
    this.onRetry,
  });

  final ReaderFailure failure;
  final VoidCallback onBack;

  /// Só na falha inesperada.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: AccountColumn(
          key: const ValueKey('leitor.erro'),
          children: [
            AccountNotice(readerFailureText(failure), error: true),
            if (failure == ReaderFailure.unexpected && onRetry != null)
              AccountButton(
                'Tentar de novo',
                tone: AccountButtonTone.primary,
                onTap: onRetry,
              ),
            AccountButton('Voltar', onTap: onBack),
          ],
        ),
      ),
    ),
  );
}
