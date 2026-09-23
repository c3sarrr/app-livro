import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Proibições do prompt mestre (§3.2) aplicadas ao código do design system (F01 1.7):
/// nada de widgets Material/Cupertino de estilo, ripple, sombra com blur, `Text`/`RichText` crus,
/// `Opacity`, pacotes de fontes/ícones/escala.
void main() {
  final files = Directory('lib/core/design_system')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  /// Código sem comentários de linha (`//`, `///`), para as palavras dos comentários não contarem.
  String code(File f) => f
      .readAsLinesSync()
      .map((l) => l.replaceFirst(RegExp(r'//.*$'), ''))
      .join('\n');

  final forbidden = <String, RegExp>{
    'import material/cupertino': RegExp(
      r'package:flutter/(material|cupertino)\.dart',
    ),
    'pacote proibido': RegExp(
      r'google_fonts|flutter_screenutil|font_awesome|cupertino_icons',
    ),
    'widget Material de estilo': RegExp(
      r'\b(Card|Chip|InkWell|InkResponse|Ink|Material|Scaffold|ElevatedButton|FilledButton|TextButton|'
      r'OutlinedButton|IconButton|ListTile|BottomNavigationBar|NavigationBar|AppBar|FloatingActionButton|'
      r'Badge|LinearProgressIndicator|CircularProgressIndicator|Divider|PhysicalModel)\s*\(',
    ),
    'ícones de pacote': RegExp(r'\b(Icons|CupertinoIcons)\.'),
    'Text/RichText cru (use AppText)': RegExp(
      r'(?<![A-Za-z_])(Text|RichText)\s*\(',
    ),
    'Opacity (use cor com alpha)': RegExp(r'\bOpacity\s*\('),
    'elevation': RegExp(r'\belevation\s*:'),
    'sombra com blur': RegExp(r'blurRadius\s*:(?!\s*0\b)'),
    'escala da interface': RegExp(r'ScreenUtil|FittedBox|textScaleFactor'),
  };

  test('há código do design system para verificar', () {
    expect(files.length, greaterThanOrEqualTo(19));
  });

  for (final MapEntry(key: rule, value: pattern) in forbidden.entries) {
    test('nenhum arquivo de lib/core/design_system viola: $rule', () {
      final hits = [
        for (final f in files)
          for (final m in pattern.allMatches(code(f)))
            '${f.path}: "${m.group(0)}"',
      ];
      expect(hits, isEmpty, reason: hits.join('\n'));
    });
  }
}
