// T13.11 (R7) — os ícones novos da T18 · Cronômetro (telas 18, 18b), em `assets/icons/cronometro/` (D-284: a pasta da
// área da 1ª etapa que usa o desenho). Gerado por `tools/medicao/gen_classes_svg.py` do catálogo
// `docs/design/medicao/projeto/svg_catalogo.json` — não editar à mão. As cores já estão nos SVGs (cada variante de cor
// é um arquivo); o tamanho de uso entre parênteses, depois a descrição e os ids das pranchas. Os reusados (D-283: o
// mesmo desenho de um asset que já existia) continuam nas classes de antes: `AppIconsInicio.pauseInk`;
// `AppIconsInicio.sparklePreview`.
abstract final class AppIconsCronometro {
  static const _d = 'assets/icons/cronometro';

  /// (22) Câmera papel (`cr18.controls.photo.icon`, `cr18b.controls.photo.icon`).
  static const cameraPapel = '$_d/ic_camera_papel.svg';

  /// (22) Chevron para baixo papel (minimizar) (`cr18.top.minimize.icon`, `cr18b.top.minimize.icon`).
  static const chevronDownPapel = '$_d/ic_chevron_down_papel.svg';

  /// (16) Chama de contorno (chip, traço 2) (`cr18.chips.streak.icon`, `cr18b.chips.streak.icon`,
  /// `cr18b.sheet.stats.streak.icon.art`).
  static const flameChip = '$_d/ic_flame_chip.svg';

  /// (14) Cadeado cinza (dica da tela bloqueada) (`cr18.lockHint.icon`, `cr18b.lockHint.icon`).
  static const lockCinza = '$_d/ic_lock_cinza.svg';

  /// (15) Lápis sobre a linha, papel (nota) (`cr18.note.button.icon`, `cr18b.note.button.icon`).
  static const pencilNotePapel = '$_d/ic_pencil_note_papel.svg';

  /// (18) "+" creme da página seguinte (`cr18b.sheet.page.next.icon`).
  static const plusMetaCreme = '$_d/ic_plus_meta_creme.svg';

  /// (17) Nuvem com chuva (som ambiente) (`cr18.top.sound.icon`, `cr18b.top.sound.icon`).
  static const rainPapel = '$_d/ic_rain_papel.svg';

  /// (18) Brilho amarelo (`cr18b.confetti.sparkle3`).
  static const sparklePreviaRosa = '$_d/ic_sparkle_previa_rosa.svg';

  /// (16) Brilho amarelo (`cr18b.confetti.sparkle2`).
  static const sparklePreviaVerde = '$_d/ic_sparkle_previa_verde.svg';

  /// (18) Parar (quadrado papel) (`cr18.controls.end.icon`, `cr18b.controls.end.icon`).
  static const stopPapel = '$_d/ic_stop_papel.svg';

  /// (16) Cronômetro (16) (`cr18b.sheet.stats.session.icon.art`).
  static const stopwatchSmall = '$_d/ic_stopwatch_small.svg';

  /// (16) Alvo (meta) (`cr18.chips.goal.icon`, `cr18b.chips.goal.icon`).
  static const target = '$_d/ic_target.svg';

  static const all = <String>[
    cameraPapel,
    chevronDownPapel,
    flameChip,
    lockCinza,
    pencilNotePapel,
    plusMetaCreme,
    rainPapel,
    sparklePreviaRosa,
    sparklePreviaVerde,
    stopPapel,
    stopwatchSmall,
    target,
  ];
}
