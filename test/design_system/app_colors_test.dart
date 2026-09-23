import 'dart:ui';

import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:flutter_test/flutter_test.dart';

/// Subfase 1.1 — cada constante contra a lista do arquivo (protege contra digitação).
void main() {
  test('AppColors: as 32 constantes têm os hex exatos do arquivo', () {
    final expected = <String, (Color, int)>{
      // Base
      'paper': (AppColors.paper, 0xFFF7F0E3),
      'ink': (AppColors.ink, 0xFF1A1714),
      'surface': (AppColors.surface, 0xFFFFFAF1),
      'inkMuted': (AppColors.inkMuted, 0xFF5B544B),
      'inkPlum': (AppColors.inkPlum, 0xFF2F2A40),
      'inkWarm': (AppColors.inkWarm, 0xFF4A4238),
      // Paleta
      'lavender': (AppColors.lavender, 0xFFB6ACE4),
      'sun': (AppColors.sun, 0xFFFED170),
      'flame': (AppColors.flame, 0xFFFF552E),
      'leaf': (AppColors.leaf, 0xFFABCF82),
      'blush': (AppColors.blush, 0xFFFFC1C6),
      'violet': (AppColors.violet, 0xFF552CB7),
      'azure': (AppColors.azure, 0xFF058CD7),
      'emerald': (AppColors.emerald, 0xFF00995E),
      'amber': (AppColors.amber, 0xFFF2A815),
      'ringTrack': (AppColors.ringTrack, 0xFFEAE1CF),
      'hatch': (AppColors.hatch, 0xFFEFE6D4),
      'hatchToday': (AppColors.hatchToday, 0xFFFDE2B2),
      'stubLabel': (AppColors.stubLabel, 0xFF4A2F33),
      'divider': (AppColors.divider, 0xFFE9E1D2),
      'tagLavenderBg': (AppColors.tagLavenderBg, 0xFFECE7FA),
      'tagLavenderFg': (AppColors.tagLavenderFg, 0xFF3B2D86),
      'tagSandBg': (AppColors.tagSandBg, 0xFFEFE7D7),
      // Translúcidas
      'spine22': (AppColors.spine22, 0x38000000),
      'spine18': (AppColors.spine18, 0x2E000000),
      'spine15': (AppColors.spine15, 0x26000000),
      'spine12': (AppColors.spine12, 0x1F000000),
      'decoRing': (AppColors.decoRing, 0x241A1714),
      'chipGlass': (AppColors.chipGlass, 0xB3FFFAF1),
      'goalLine': (AppColors.goalLine, 0x731A1714),
      'dialTick': (AppColors.dialTick, 0x591A1714),
      'paperTransparent': (AppColors.paperTransparent, 0x00F7F0E3),
    };
    expect(expected, hasLength(32));
    for (final MapEntry(key: name, value: (color, argb)) in expected.entries) {
      expect(
        color.toARGB32(),
        argb,
        reason: '$name: 0x${color.toARGB32().toRadixString(16).toUpperCase()}',
      );
    }
  });

  test('AppColors: alphas das translúcidas = round(a × 255) do CSS', () {
    int alpha(double a) => (a * 255).round();
    expect(AppColors.spine22.toARGB32() >>> 24, alpha(.22));
    expect(AppColors.spine18.toARGB32() >>> 24, alpha(.18));
    expect(AppColors.spine15.toARGB32() >>> 24, alpha(.15));
    expect(AppColors.spine12.toARGB32() >>> 24, alpha(.12));
    expect(AppColors.decoRing.toARGB32() >>> 24, alpha(.14));
    expect(AppColors.chipGlass.toARGB32() >>> 24, alpha(.7));
    expect(AppColors.goalLine.toARGB32() >>> 24, alpha(.45));
    expect(AppColors.dialTick.toARGB32() >>> 24, alpha(.35));
  });

  test('AppColors: as 2 listas de opções de tema (props do componente)', () {
    expect(AppColors.brandOptions.map((c) => c.toARGB32()).toList(), [
      0xFFB6ACE4,
      0xFFFFC1C6,
      0xFFABCF82,
      0xFFFED170,
    ]);
    expect(AppColors.weekColorOptions.map((c) => c.toARGB32()).toList(), [
      0xFFB6ACE4,
      0xFFFFB39E,
      0xFFF2A815,
      0xFFABCF82,
    ]);
  });
}
