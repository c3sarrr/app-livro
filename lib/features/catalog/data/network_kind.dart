// Tipo de rede (o download grande do catálogo espera o Wi-Fi/cabo).
import 'package:connectivity_plus/connectivity_plus.dart';

import '../application/catalog_updater.dart' show NetworkKind;

NetworkKind networkKindOf(List<ConnectivityResult> r) {
  if (r.contains(ConnectivityResult.wifi) ||
      r.contains(ConnectivityResult.ethernet)) {
    return NetworkKind.unmetered;
  }
  if (r.isEmpty || r.every((x) => x == ConnectivityResult.none)) {
    return NetworkKind.none;
  }
  return NetworkKind.metered;
}

Future<NetworkKind> currentNetworkKind() async =>
    networkKindOf(await Connectivity().checkConnectivity());
