import 'package:app_leitura/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('licença OFL das fontes registrada no LicenseRegistry', () async {
    // Isola o registro: remove os coletores padrão do binding (NOTICES do engine).
    LicenseRegistry.reset();
    registerFontLicenses();

    final entries = await LicenseRegistry.licenses.toList();
    expect(entries, hasLength(1));
    final entry = entries.single;
    expect(entry.packages, kFontLicensePackages);
    final text = entry.paragraphs.map((p) => p.text).join('\n');
    expect(text, contains('SIL OPEN FONT LICENSE'));
    expect(text, contains('Version 1.1 - 26 February 2007'));
    expect(text, contains('Bricolage Grotesque'));
    expect(text, contains('Figtree'));
    expect(text, contains('Instrument Serif'));
    // G12 (D-54): o glifo "≈" da Inter Bold
    expect(text, contains('Inter — Copyright 2016 The Inter Project Authors'));
  });
}
