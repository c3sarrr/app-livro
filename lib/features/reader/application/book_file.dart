// G19.2 — onde está o arquivo de um livro neste aparelho (o leitor e a tela 25): o caminho guardado, ou o mesmo nome na
// pasta dos livros de agora (a pasta do app muda entre instalações — G09); `null` = o arquivo não está aqui.
import 'dart:io';

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/content_daos.dart';

/// O caminho guardado [stored], se existe; senão o mesmo nome na pasta [booksDir]; senão `null`.
Future<String?> existingBookFile(
  String stored,
  Future<Directory> Function() booksDir,
) async {
  if (File(stored).existsSync()) return stored;
  final name = stored.split(RegExp(r'[/\\]')).last;
  final moved = '${(await booksDir()).path}${Platform.pathSeparator}$name';
  return File(moved).existsSync() ? moved : null;
}

/// O arquivo do livro [userBookId] neste aparelho; `null` = não há (físico, removido, em outro aparelho).
Future<String?> bookFilePath(
  AppDatabase db,
  Future<Directory> Function() booksDir,
  String userBookId,
) async {
  final file = await LocalFilesDao(db).byBook(userBookId);
  return file == null ? null : existingBookFile(file.path, booksDir);
}
