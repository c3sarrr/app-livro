import 'dart:convert';

import 'package:flutter/services.dart';

/// Carrega no ambiente de teste TODAS as fontes declaradas no pubspec.
/// Sem isto o flutter_test usa a fonte "Ahem" e nenhuma medida de texto vale.
/// Peso/estilo são lidos do próprio TTF (os arquivos do pacote têm usWeightClass
/// e flags de itálico corretos).
Future<void> loadAppFonts() async {
  final manifest = json.decode(
    await rootBundle.loadString('FontManifest.json'),
  ) as List<dynamic>;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(entry['family'] as String);
    for (final font
        in (entry['fonts'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}
