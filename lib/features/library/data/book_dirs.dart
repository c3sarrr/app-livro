// G09 — pastas do conteúdo dos livros no suporte do app (fora dos documentos da pessoa; sem backup — §4.4.4):
// `livros/` (arquivo do livro, `<user_book_id>.<formato>` — a mesma da nuvem do Pro, G06) e `capas_arquivo/`
// (capa que veio dentro do arquivo, `<sha256>.img` — D-90; nunca sai pela limpeza do cache de capas).
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<Directory> _sub(String name) async {
  final base = await getApplicationSupportDirectory();
  final dir = Directory('${base.path}${Platform.pathSeparator}$name');
  await dir.create(recursive: true);
  return dir;
}

Future<Directory> booksDirectory() => _sub('livros');

Future<Directory> fileCoversDirectory() => _sub('capas_arquivo');

/// Arquivo da capa do arquivo do livro com o conteúdo [sha256] em [dir].
File fileCoverIn(Directory dir, String sha256) =>
    File('${dir.path}${Platform.pathSeparator}$sha256.img');
