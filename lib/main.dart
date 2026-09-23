import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

/// Licença SIL OFL 1.1 das fontes do arquivo (Bricolage Grotesque, Figtree,
/// Instrument Serif), distribuída junto das fontes em `assets/fonts/`.
const kFontLicenseAsset = 'assets/fonts/LICENCAS_FONTES_OFL.txt';

/// Famílias cobertas pela licença, como aparecem na tela de licenças do sistema.
const kFontLicensePackages = <String>[
  'Bricolage Grotesque',
  'Figtree',
  'Instrument Serif',
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();
  await configureSystemUi();
  runApp(const ProviderScope(child: App()));
}

/// D-13: Android edge-to-edge (o conteúdo passa sob as barras do sistema).
/// D-06: somente retrato.
Future<void> configureSystemUi() async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
}

/// Registra a licença OFL no [LicenseRegistry] (lida sob demanda do asset).
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString(kFontLicenseAsset);
    yield LicenseEntryWithLineBreaks(kFontLicensePackages, text);
  });
}
