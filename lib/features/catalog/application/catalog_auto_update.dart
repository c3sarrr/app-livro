// Atualiza o catálogo do aparelho sozinho: ao abrir o app e quando a rede vira Wi-Fi/cabo. Falha de
// rede é silenciosa (tenta de novo na próxima vez; o download retoma de onde parou).
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/network_kind.dart';
import '../domain/catalog_failure.dart';
import 'catalog_providers.dart';
import 'catalog_updater.dart';

/// Fluxo de mudanças de rede (testes trocam).
final networkChangesProvider = Provider<Stream<NetworkKind>>(
  (ref) => Connectivity().onConnectivityChanged.map(networkKindOf),
);

class CatalogAutoUpdate extends ConsumerStatefulWidget {
  const CatalogAutoUpdate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<CatalogAutoUpdate> createState() => _CatalogAutoUpdateState();
}

class _CatalogAutoUpdateState extends ConsumerState<CatalogAutoUpdate> {
  StreamSubscription<NetworkKind>? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_check()));
    _sub = ref.read(networkChangesProvider).listen((k) {
      if (k == NetworkKind.unmetered) unawaited(_check());
    });
  }

  Future<void> _check() async {
    try {
      final u = await ref.read(catalogUpdaterProvider.future);
      await u?.update();
    } on CatalogFailure {
      // sem rede, limite, arquivo corrompido (já descartado): tenta de novo depois
    } on Object catch (e, st) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: st, library: 'catalogo'),
      );
    }
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
