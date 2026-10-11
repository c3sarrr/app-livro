// G09.5 — "Abrir com" / "Compartilhar" com o app aberto em qualquer aba (D-87): liga a importação do sistema
// quando o app sobe (`main`) e, quando chega um arquivo, pede a aba Biblioteca (onde o aviso aparece). A troca
// de aba é da `MainShell` (`LibraryTabSwitcher`), que está dentro do roteador.
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/library_import.dart';

class IncomingBooks extends ConsumerStatefulWidget {
  const IncomingBooks({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<IncomingBooks> createState() => _IncomingBooksState();
}

class _IncomingBooksState extends ConsumerState<IncomingBooks> {
  @override
  void initState() {
    super.initState();
    unawaited(ref.read(libraryImportProvider.notifier).start());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(libraryImportProvider, (previous, next) {
      if (next is ImportBusy && next.fromSystem && previous is! ImportBusy) {
        ref.read(libraryTabRequestProvider.notifier).request();
      }
    });
    return widget.child;
  }
}

/// Dentro da `MainShell`: troca para a Biblioteca quando pedido.
class LibraryTabSwitcher extends ConsumerWidget {
  const LibraryTabSwitcher({
    super.key,
    required this.onRequest,
    required this.child,
  });

  final VoidCallback onRequest;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(libraryTabRequestProvider, (_, _) => onRequest());
    return child;
  }
}
