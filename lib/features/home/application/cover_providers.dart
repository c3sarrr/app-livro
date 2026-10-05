// Fotos de capa no aparelho (G08, D-79): pasta de suporte do app, cliente HTTP compartilhado e as capas dos
// livros da estante (nunca saem do cache). Os testes trocam [coverImagesProvider].
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/local_database.dart';
import '../../catalog/application/catalog_providers.dart'
    show catalogHttpClientProvider;
import '../data/cover_store.dart';
import '../domain/models.dart';

final coverImagesProvider = Provider<CoverImages>(
  (ref) => CoverStore(
    dir: () async {
      final base = await getApplicationSupportDirectory();
      return Directory('${base.path}${Platform.pathSeparator}capas');
    },
    client: ref.watch(catalogHttpClientProvider),
    pinned: () async =>
        shelfCoverUrls(await ref.read(localDatabaseProvider.future)),
  ),
);

/// A foto de uma capa (do aparelho ou da rede); `null` = sem foto agora (capa gerada).
final coverFileProvider = FutureProvider.family<File?, PhotoCover>(
  (ref, cover) => ref.watch(coverImagesProvider).resolve(cover),
);

/// Endereços das capas de todos os livros guardados no aparelho (qualquer dono — D-68: a conta que voltar
/// encontra as capas).
Future<Set<Uri>> shelfCoverUrls(AppDatabase db) async {
  final rows = await db
      .customSelect(
        'SELECT cover_ref, isbn13 FROM user_books WHERE deleted_at IS NULL',
      )
      .get();
  return {
    for (final r in rows)
      ...coverCandidates(
        PhotoCover(
          ref: r.readNullable<String>('cover_ref'),
          isbn13: r.readNullable<String>('isbn13'),
        ),
      ),
  };
}
