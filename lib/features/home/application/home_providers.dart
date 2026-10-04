import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../data/home_repository.dart';
import '../domain/models.dart';

/// Relógio da tela. Testes e o app de desenvolvimento injetam o "agora" de referência (D-09).
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Fonte dos dados da Início. Sem padrão em produção até a G08 (repositório real): os testes e o app
/// de desenvolvimento injetam a fixture do mundo de referência (D-34).
final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => throw UnimplementedError(
    'HomeRepository real chega na G08; até lá use a fixture do mundo de referência '
    '(test/fixtures/overrides_do_mundo.dart — D-34).',
  ),
);

/// Dados da tela. Widgets de seção leem só o recorte de que precisam:
/// `ref.watch(homeSnapshotProvider.select((s) => s.continueReading))`.
final homeSnapshotProvider = Provider<HomeSnapshot>(
  (ref) =>
      ref.watch(homeRepositoryProvider).snapshot(ref.watch(clockProvider)()),
);

/// Props do componente no arquivo (D-11): `brand` e `weekColor`, padrão `#B6ACE4`.
@immutable
class HomeTheme {
  const HomeTheme({
    this.brand = AppColors.lavender,
    this.weekColor = AppColors.lavender,
  });

  final Color brand;
  final Color weekColor;
}

/// Só aceita as opções do arquivo (`AppColors.brandOptions` / `AppColors.weekColorOptions`).
class HomeThemeController extends Notifier<HomeTheme> {
  @override
  HomeTheme build() => const HomeTheme();

  void setBrand(Color c) {
    assert(AppColors.brandOptions.contains(c));
    state = HomeTheme(brand: c, weekColor: state.weekColor);
  }

  void setWeekColor(Color c) {
    assert(AppColors.weekColorOptions.contains(c));
    state = HomeTheme(brand: state.brand, weekColor: c);
  }
}

final homeThemeProvider = NotifierProvider<HomeThemeController, HomeTheme>(
  HomeThemeController.new,
);
