// G11.1 — a cor `brand` é uma preferência global do app (D-33), guardada no `kv` do aparelho (Anexo 02 §3.3);
// só as 4 opções do arquivo (D-11). A Início lê a mesma cor (o `weekColor` continua dela).
import 'dart:ui' show Color;

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/preferences/brand_preference.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'KvBrandStore: grava e lê só as 4 opções; valor estranho = nada',
    () async {
      final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
      addTearDown(db.close);
      final store = KvBrandStore(() async => db);
      expect(await store.load(), isNull);
      await store.save(AppColors.brandOptions[2]);
      expect(await KvDao(db).get(brandKey), 'FFABCF82');
      expect(await store.load(), AppColors.brandOptions[2]);
      await KvDao(db).set(brandKey, 'FF000000');
      expect(await store.load(), isNull);
      await KvDao(db).set(brandKey, 'lavanda');
      expect(await store.load(), isNull);
    },
  );

  test(
    'brandProvider: começa lavanda, carrega o guardado e grava a troca',
    () async {
      final store = MemoryBrandStore(AppColors.brandOptions[1]);
      final c = ProviderContainer(
        overrides: [brandStoreProvider.overrideWithValue(store)],
      );
      addTearDown(c.dispose);
      expect(c.read(brandProvider), AppColors.lavender);
      await pumpEventQueue();
      expect(c.read(brandProvider), AppColors.brandOptions[1]);
      await c.read(brandProvider.notifier).set(AppColors.brandOptions[3]);
      expect(store.value, AppColors.brandOptions[3]);
      expect(c.read(brandProvider), AppColors.brandOptions[3]);
    },
  );

  test(
    'a Início lê o brand global e troca por ele; o weekColor fica com ela',
    () async {
      final store = MemoryBrandStore();
      final c = ProviderContainer(
        overrides: [brandStoreProvider.overrideWithValue(store)],
      );
      addTearDown(c.dispose);
      expect(c.read(homeThemeProvider).brand, AppColors.lavender);
      c.read(homeThemeProvider.notifier).setWeekColor(AppColors.amber);
      c.read(homeThemeProvider.notifier).setBrand(AppColors.blush);
      await pumpEventQueue();
      final t = c.read(homeThemeProvider);
      expect((t.brand, t.weekColor), (AppColors.blush, AppColors.amber));
      expect(store.value, AppColors.blush);
    },
  );

  test('loja que falha: fica a lavanda e a troca vale na sessão', () async {
    final c = ProviderContainer(
      overrides: [brandStoreProvider.overrideWithValue(_Quebrada())],
    );
    addTearDown(c.dispose);
    expect(c.read(brandProvider), AppColors.lavender);
    await pumpEventQueue();
    expect(c.read(brandProvider), AppColors.lavender);
    await c.read(brandProvider.notifier).set(AppColors.sun);
    expect(c.read(brandProvider), AppColors.sun);
  });
}

final class _Quebrada implements BrandStore {
  @override
  Future<Color?> load() => Future.error(StateError('sem banco'));

  @override
  Future<void> save(Color c) => Future.error(StateError('sem banco'));
}
