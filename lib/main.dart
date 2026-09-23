import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Licença SIL OFL 1.1 das fontes do arquivo (Bricolage Grotesque, Figtree,
/// Instrument Serif), distribuída junto das fontes em `assets/fonts/`.
const kFontLicenseAsset = 'assets/fonts/LICENCAS_FONTES_OFL.txt';

/// Famílias cobertas pela licença, como aparecem na tela de licenças do sistema.
const kFontLicensePackages = <String>[
  'Bricolage Grotesque',
  'Figtree',
  'Instrument Serif',
];

void main() {
  registerFontLicenses();
  // O App (lib/app/app.dart) entra na FASE 2; até lá nada é desenhado.
  runApp(const SizedBox.shrink());
}

/// Registra a licença OFL no [LicenseRegistry] (lida sob demanda do asset).
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString(kFontLicenseAsset);
    yield LicenseEntryWithLineBreaks(kFontLicensePackages, text);
  });
}
