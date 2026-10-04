import 'dart:ui' show Color;

import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/home/application/formatters.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/home_mock_repository.dart';
import '../fixtures/overrides_do_mundo.dart';

/// Repositório falso: prova que o snapshot vem do repositório injetado.
class _FakeRepository implements HomeRepository {
  const _FakeRepository(this.firstName);
  final String firstName;

  @override
  HomeSnapshot snapshot(DateTime now) {
    final base = const HomeMockRepository().snapshot(now);
    return HomeSnapshot(
      now: now,
      user: UserSummary(
        firstName: firstName,
        initial: 'X',
        unreadNotifications: 0,
      ),
      continueReading: base.continueReading,
      alsoReading: base.alsoReading,
      readingDay: base.readingDay,
      forYou: base.forYou,
      club: base.club,
      recent: base.recent,
    );
  }
}

void main() {
  group('2.4 clock / homeRepository / homeSnapshot', () {
    test('padrões de produção (G03, D-34): relógio do sistema e nenhum dado de usuário no código '
        '(o repositório real chega na G08)', () {
      final container = ProviderContainer.test();
      final antes = DateTime.now();
      final agora = container.read(clockProvider)();
      expect(agora.isBefore(antes), isFalse);
      expect(agora.difference(antes).inSeconds, lessThan(5));
      expect(() => container.read(homeRepositoryProvider), throwsA(anything));
    });

    test('com a fixture do mundo de referência: relógio = agora de referência; repositório = mock; snapshot = mock nesse agora', () {
      final container = ProviderContainer.test(overrides: overridesDoMundo);
      expect(container.read(clockProvider)(), HomeMockRepository.referenceNow);
      expect(container.read(homeRepositoryProvider), isA<HomeMockRepository>());
      final snap = container.read(homeSnapshotProvider);
      expect(snap.now, DateTime(2026, 9, 20, 20));
      expect(HomeFormatters.greeting(snap.now), 'Boa noite,');
      expect(snap.user.firstName, 'Marina');
      // Mesmos dados do mock (as partes constantes são as mesmas instâncias canônicas).
      final mock = const HomeMockRepository().snapshot(snap.now);
      expect(snap.continueReading, same(mock.continueReading));
      expect(snap.alsoReading, same(mock.alsoReading));
      expect(snap.forYou, same(mock.forYou));
      expect(snap.recent, same(mock.recent));
    });

    test(
      'o relógio injetado chega ao snapshot (saudação derivada do "agora")',
      () {
        final container = ProviderContainer.test(
          overrides: [
            clockProvider.overrideWithValue(() => DateTime(2026, 9, 20, 9)),
            repositorioDoMundo,
          ],
        );
        final snap = container.read(homeSnapshotProvider);
        expect(snap.now, DateTime(2026, 9, 20, 9));
        expect(HomeFormatters.greeting(snap.now), 'Bom dia,');
      },
    );

    test('o repositório injetado é a fonte do snapshot', () {
      final container = ProviderContainer.test(
        overrides: [
          homeRepositoryProvider.overrideWithValue(
            const _FakeRepository('Ana'),
          ),
        ],
      );
      expect(container.read(homeSnapshotProvider).user.firstName, 'Ana');
    });

    test('seções leem só o recorte com select', () {
      final container = ProviderContainer.test(overrides: overridesDoMundo);
      final slice = container.read(
        homeSnapshotProvider.select((s) => s.continueReading),
      );
      expect(slice.book.title, 'Dom Casmurro');
      expect(slice.chapter, 92);
    });
  });

  group('2.4 HomeThemeController (só aceita as opções do arquivo)', () {
    test('padrão: brand e weekColor = #B6ACE4', () {
      final container = ProviderContainer.test();
      final theme = container.read(homeThemeProvider);
      expect(theme.brand.toARGB32(), 0xFFB6ACE4);
      expect(theme.weekColor.toARGB32(), 0xFFB6ACE4);
    });

    test('aceita cada uma das 4 opções de brand e preserva weekColor', () {
      final container = ProviderContainer.test();
      final controller = container.read(homeThemeProvider.notifier);
      controller.setWeekColor(const Color(0xFFABCF82));
      for (final c in AppColors.brandOptions) {
        controller.setBrand(c);
        expect(container.read(homeThemeProvider).brand, c);
        expect(
          container.read(homeThemeProvider).weekColor.toARGB32(),
          0xFFABCF82,
        );
      }
      expect(AppColors.brandOptions.map((c) => c.toARGB32()), [
        0xFFB6ACE4,
        0xFFFFC1C6,
        0xFFABCF82,
        0xFFFED170,
      ]);
    });

    test('aceita cada uma das 4 opções de weekColor e preserva brand', () {
      final container = ProviderContainer.test();
      final controller = container.read(homeThemeProvider.notifier);
      controller.setBrand(const Color(0xFFFED170));
      for (final c in AppColors.weekColorOptions) {
        controller.setWeekColor(c);
        expect(container.read(homeThemeProvider).weekColor, c);
        expect(container.read(homeThemeProvider).brand.toARGB32(), 0xFFFED170);
      }
      expect(AppColors.weekColorOptions.map((c) => c.toARGB32()), [
        0xFFB6ACE4,
        0xFFFFB39E,
        0xFFF2A815,
        0xFFABCF82,
      ]);
    });

    test('recusa brand fora das opções (inclusive opções só de weekColor) sem mudar o estado', () {
      final container = ProviderContainer.test();
      final controller = container.read(homeThemeProvider.notifier);
      for (final bad in const [
        Color(0xFFFFB39E), // opção de weekColor, não de brand
        Color(0xFFF2A815), // opção de weekColor, não de brand
        AppColors.flame,
        Color(0xFFB6ACE5), // 1 unidade fora do lavanda
      ]) {
        expect(() => controller.setBrand(bad), throwsA(isA<AssertionError>()));
        expect(container.read(homeThemeProvider).brand, AppColors.lavender);
      }
    });

    test('recusa weekColor fora das opções (inclusive opções só de brand) sem mudar o estado', () {
      final container = ProviderContainer.test();
      final controller = container.read(homeThemeProvider.notifier);
      for (final bad in const [
        Color(0xFFFFC1C6), // opção de brand, não de weekColor
        Color(0xFFFED170), // opção de brand, não de weekColor
        AppColors.ink,
      ]) {
        expect(
          () => controller.setWeekColor(bad),
          throwsA(isA<AssertionError>()),
        );
        expect(container.read(homeThemeProvider).weekColor, AppColors.lavender);
      }
    });

    test('mudança de tema notifica quem observa', () {
      final container = ProviderContainer.test();
      final seen = <int>[];
      container.listen<HomeTheme>(
        homeThemeProvider,
        (_, next) => seen.add(next.brand.toARGB32()),
      );
      container.read(homeThemeProvider.notifier).setBrand(AppColors.blush);
      expect(seen, [0xFFFFC1C6]);
    });
  });
}
