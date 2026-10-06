// G12.1 — cores das ilhas do leitor (L20a/L20b/L26b): nos papéis claros, as da tela 20 com o véu do próprio papel
// a 62 %; no Noite, as medidas da 26b (nada invertido). `lerp` faz o Tema em 220 ms (D-121) e `faded` o abrir/
// fechar em 150 ms sem `Opacity` (D-124).
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

String hex(Color c) =>
    c.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0');

void main() {
  test(
    'Creme (tela 20): ilhas, véu do papel a 62 %, hachura, balão, tracejado',
    () {
      final p = ReaderChromePalette.of(ReaderPaper.creme);
      expect(p.night, isFalse);
      expect(hex(p.veil.withValues(alpha: 1)), 'FFF8F1E4');
      expect(p.veil.a, closeTo(0.62, 1e-6));
      expect(
        [p.island, p.border, p.shadow, p.well, p.title, p.muted].map(hex),
        [
          'FFFFFAF1',
          'FF1A1714',
          'FF1A1714',
          'FFF7F0E3',
          'FF1A1714',
          'FF5B544B',
        ],
      );
      expect(
        [
          p.hatch,
          p.hatchBase,
          p.bubble,
          p.bubbleText,
          p.dash,
          p.disabled,
        ].map(hex),
        [
          'FFE9DFCC',
          'FFFFFAF1',
          'FF1A1714',
          'FFF7F0E3',
          'FFCFC3AE',
          'FFA89D8B',
        ],
      );
    },
  );

  test(
    'Branco e Sépia: as ilhas da 20; véu e cinza do próprio papel (D-110)',
    () {
      final b = ReaderChromePalette.of(ReaderPaper.branco);
      final s = ReaderChromePalette.of(ReaderPaper.sepia);
      expect(hex(b.veil.withValues(alpha: 1)), 'FFFFFDF8');
      expect(hex(s.veil.withValues(alpha: 1)), 'FFEEDDBF');
      expect((hex(b.disabled), hex(s.disabled)), ('FFA9A6A2', 'FFA08E74'));
      expect((hex(b.island), hex(s.island)), ('FFFFFAF1', 'FFFFFAF1'));
    },
  );

  test('Noite (tela 26b): os tokens medidos', () {
    final p = ReaderChromePalette.of(ReaderPaper.noite);
    expect(p.night, isTrue);
    expect(hex(p.veil.withValues(alpha: 1)), 'FF14110E');
    expect(p.veil.a, closeTo(0.55, 1e-6));
    expect([p.island, p.border, p.shadow, p.well, p.title, p.muted].map(hex), [
      'FF2A2520',
      'FFEDE3D1',
      'FF0B0A08',
      'FF1F1B17',
      'FFEDE3D1',
      'FFB5AA98',
    ]);
    expect(
      [
        p.hatch,
        p.hatchBase,
        p.bubble,
        p.bubbleText,
        p.dash,
        p.disabled,
      ].map(hex),
      ['FF3A332B', 'FF2A2520', 'FFEDE3D1', 'FF1F1B17', 'FF4A433A', 'FF8A8073'],
    );
  });

  test('lerp vai de uma paleta à outra (Tema) e faded multiplica o alfa (abrir/fechar)', () {
    final a = ReaderChromePalette.of(ReaderPaper.creme);
    final b = ReaderChromePalette.of(ReaderPaper.noite);
    expect(ReaderChromePalette.lerp(a, b, 0), a);
    expect(ReaderChromePalette.lerp(a, b, 1), b);
    final meio = ReaderChromePalette.lerp(a, b, 0.5);
    expect(meio.island, Color.lerp(a.island, b.island, 0.5));
    expect(
      meio.night,
      isTrue,
      reason: 'da metade em diante, os ícones do Noite',
    );
    expect(ReaderChromePalette.lerp(a, b, 0.49).night, isFalse);
    expect(a.faded(0.5).island.a, closeTo(0.5, 1e-6));
    expect(a.faded(0.5).veil.a, closeTo(0.31, 1e-6));
    expect(a.faded(1), a);
    expect(a.faded(0.5).label.a, closeTo(0.5, 1e-6), reason: 'G13: rótulos');
  });

  test('ReaderPalette.lerp (papel, texto e rodapé do Tema)', () {
    final a = ReaderPalette.of(ReaderPaper.sepia);
    final b = ReaderPalette.of(ReaderPaper.noite);
    expect(ReaderPalette.lerp(a, b, 0).paper, a.paper);
    expect(ReaderPalette.lerp(a, b, 1).text, b.text);
    expect(
      ReaderPalette.lerp(a, b, 0.5).footer,
      Color.lerp(a.footer, b.footer, 0.5),
    );
  });

  test('igualdade e hash por valor (o Tema compara a paleta de destino)', () {
    for (final p in ReaderPaper.values) {
      final a = ReaderChromePalette.of(p);
      final b = ReaderChromePalette.of(p);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      final c = ReaderPalette.of(p);
      expect(c, ReaderPalette.of(p));
      expect(c.hashCode, ReaderPalette.of(p).hashCode);
    }
    expect(
      ReaderChromePalette.of(ReaderPaper.creme).hashCode,
      isNot(ReaderChromePalette.of(ReaderPaper.noite).hashCode),
    );
    expect(
      ReaderPalette.of(ReaderPaper.creme).hashCode,
      isNot(ReaderPalette.of(ReaderPaper.noite).hashCode),
    );
  });
}
