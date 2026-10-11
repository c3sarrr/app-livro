// G09.5 — Biblioteca mínima até o design (D-87, D-21): abaixo do título da aba, o botão de importar e os avisos
// (os mesmos primitivos do bloco da conta no Perfil, D-69). Sem lista de livros: ela espera o design.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/presentation/account_widgets.dart';
import '../application/library_import.dart';
import '../domain/import_outcome.dart';

/// Frase de cada resultado (D-87, D-92, Anexo 03 §2).
String importMessage(ImportOutcome o) => switch (o) {
  Imported(fixedLayout: true) => 'Este livro tem páginas fixas; a leitura dele ainda não está pronta no BookNest.',
  Imported(:final title) => '«$title» está na sua estante.',
  AlreadyOnShelf() => 'Esse livro já está na sua estante.',
  ImportFailed(error: ImportError.unsupported) =>
    'Esse arquivo não é um EPUB nem um PDF.',
  ImportFailed(error: ImportError.damaged) =>
    'Não deu para abrir esse arquivo. Ele pode estar danificado.',
  ImportFailed(error: ImportError.protected) =>
    'Este arquivo tem proteção e não pode ser aberto.',
  ImportFailed(error: ImportError.noSpace) =>
    'Não há espaço no aparelho para guardar este livro.',
  ImportFailed(error: ImportError.unexpected) =>
    'Não deu para importar agora. Tente de novo.',
};

/// Erro (vermelho) ou confirmação (verde).
bool importIsError(ImportOutcome o) =>
    o is ImportFailed || (o is Imported && o.fixedLayout);

class LibraryImportBlock extends ConsumerWidget {
  const LibraryImportBlock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(libraryImportProvider);
    final busy = view is ImportBusy;
    return AccountColumn(
      children: [
        const AccountText('Traga seus livros em EPUB ou PDF.'),
        AccountButton(
          'Importar livro (EPUB ou PDF)',
          tone: AccountButtonTone.primary,
          onTap: busy
              ? null
              : () => ref.read(libraryImportProvider.notifier).pick(),
        ),
        ...switch (view) {
          ImportIdle() => const <Widget>[],
          ImportBusy(:final fileName) => [
            AccountText('Importando «$fileName»…', muted: true),
          ],
          ImportFinished(:final outcome) => [
            AccountNotice(
              importMessage(outcome),
              error: importIsError(outcome),
            ),
          ],
        },
      ],
    );
  }
}
