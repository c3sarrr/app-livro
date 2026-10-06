// G11.1 — a cor `brand` é uma preferência global do app (D-33): Início, Leitor e tela 25 usam a mesma. Fica
// guardada no `kv` do aparelho (Anexo 02 §3.3) e aceita só as 4 opções do arquivo (D-11).
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../data/database/daos/kv_dao.dart';
import '../data/database/local_database.dart';
import '../design_system/tokens/app_colors.dart';

/// Chave do `kv` (valor = ARGB em hexadecimal, ex.: `FFB6ACE4`).
const String brandKey = 'pref.brand';

abstract interface class BrandStore {
  /// A cor guardada, se for uma das opções do arquivo.
  Future<Color?> load();

  Future<void> save(Color c);
}

final class KvBrandStore implements BrandStore {
  KvBrandStore(this._db);

  final Future<AppDatabase> Function() _db;

  @override
  Future<Color?> load() async {
    final v = await KvDao(await _db()).get(brandKey);
    final n = v == null ? null : int.tryParse(v, radix: 16);
    if (n == null) return null;
    final c = Color(n);
    return AppColors.brandOptions.contains(c) ? c : null;
  }

  @override
  Future<void> save(Color c) async => KvDao(
    await _db(),
  ).set(brandKey, c.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0'));
}

/// Guarda na memória (testes e fixtures, que não abrem banco).
final class MemoryBrandStore implements BrandStore {
  MemoryBrandStore([this.value]);

  Color? value;

  @override
  Future<Color?> load() async => value;

  @override
  Future<void> save(Color c) async => value = c;
}

final brandStoreProvider = Provider<BrandStore>(
  (ref) => KvBrandStore(() => ref.read(localDatabaseProvider.future)),
);

/// A cor `brand` de agora: começa na lavanda do arquivo e passa à guardada assim que ela é lida.
final brandProvider = NotifierProvider<BrandController, Color>(
  BrandController.new,
);

class BrandController extends Notifier<Color> {
  bool _chosen = false;

  @override
  Color build() {
    _load();
    return AppColors.lavender;
  }

  Future<void> _load() async {
    try {
      final c = await ref.read(brandStoreProvider).load();
      // uma troca feita enquanto o banco era lido vale mais que o guardado
      if (c != null && ref.mounted && !_chosen) state = c;
    } on Object {
      // preferência é só conforto: sem ela, fica a lavanda do arquivo
    }
  }

  /// Troca na hora e grava em seguida.
  Future<void> set(Color c) {
    assert(AppColors.brandOptions.contains(c));
    _chosen = true;
    state = c;
    return _save(c);
  }

  Future<void> _save(Color c) async {
    try {
      await ref.read(brandStoreProvider).save(c);
    } on Object {
      // vale nesta sessão; a próxima abertura volta à cor guardada
    }
  }
}
