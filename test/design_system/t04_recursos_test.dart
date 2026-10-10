// T04 — os recursos novos da 01b: o "play" tinta derivado (R9) e a moldura da capa da mini-barra (R10).
import 'dart:io';

import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_inicio.dart';
import 'package:app_leitura/core/design_system/tokens/app_radii.dart';
import 'package:app_leitura/features/home/presentation/covers/book_cover.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('R9: ic_play_tinta.svg é o ic_play.svg da prancha com fill="#1A1714" (o único derivado, 18 × 18)', () {
    expect(AppIconsInicio.derived, {AppIconsInicio.playInk});
    expect(AppIconsInicio.all, contains(AppIconsInicio.playInk));
    final play = File(AppIconsInicio.play).readAsStringSync();
    final tinta = File(AppIconsInicio.playInk).readAsStringSync();
    expect(play, contains('fill="#FED170"'));
    expect(tinta, play.replaceAll('fill="#FED170"', 'fill="#1A1714"'));
    expect(tinta, contains('width="18" height="18" viewBox="0 0 24 24"'));
    // o pausar tinta da mini-barra é o do catálogo (não derivado)
    expect(AppIconsInicio.derived, isNot(contains(AppIconsInicio.pauseInk)));
  });

  test('R10: a moldura da mini-barra — 32 × 48, borda 1,2 #F7F0E3, raio 2/5/5/2, sem sombra, sem lombada nem texto; as '
      'outras molduras continuam com a borda tinta', () {
    const s = CoverSlot.miniBar;
    expect((s.width, s.height, s.border), (32.0, 48.0, 1.2));
    expect(s.borderColor, AppColors.paper);
    expect(s.radius, AppRadii.coverXs);
    expect(
      AppRadii.coverXs,
      const BorderRadius.only(
        topLeft: Radius.circular(2),
        topRight: Radius.circular(5),
        bottomRight: Radius.circular(5),
        bottomLeft: Radius.circular(2),
      ),
    );
    expect((s.shadow, s.spineWidth, s.titleSize), (null, 0.0, null));
    for (final outro in [
      CoverSlot.hero,
      CoverSlot.alsoReading,
      CoverSlot.forYou,
      CoverSlot.recent,
    ]) {
      expect(outro.borderColor, AppColors.ink);
    }
  });
}
