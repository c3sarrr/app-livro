// G19.2 — onde está o arquivo de um livro neste aparelho: o caminho guardado, ou o mesmo nome na pasta dos livros de
// agora; sem arquivo, nenhum (o leitor e a tela 25).
import 'dart:io';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/features/reader/application/book_file.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/personal_builders.dart';

void main() {
  late Directory velha;
  late Directory nova;
  setUp(() {
    velha = Directory.systemTemp.createTempSync('booknest_g19_velha_');
    nova = Directory.systemTemp.createTempSync('booknest_g19_nova_');
  });
  tearDown(() {
    velha.deleteSync(recursive: true);
    nova.deleteSync(recursive: true);
  });
  String sep(Directory d, String n) => '${d.path}${Platform.pathSeparator}$n';

  test('o guardado existe: ele', () async {
    final f = File(sep(velha, 'a.epub'))..writeAsStringSync('x');
    expect(await existingBookFile(f.path, () async => nova), f.path);
  });

  test('a pasta mudou: o mesmo nome na de agora; nem lá: nenhum', () async {
    File(sep(nova, 'b.epub')).writeAsStringSync('x');
    expect(
      await existingBookFile(sep(velha, 'b.epub'), () async => nova),
      sep(nova, 'b.epub'),
    );
    expect(
      await existingBookFile(sep(velha, 'c.epub'), () async => nova),
      isNull,
    );
  });

  test('pelo banco: sem linha, nenhum; com linha, o arquivo', () async {
    final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    addTearDown(db.close);
    expect(await bookFilePath(db, () async => nova, idTeste(1)), isNull);
    final f = File(sep(velha, 'd.epub'))..writeAsStringSync('x');
    await LocalFilesDao(db).upsert(
      userBookId: idTeste(1),
      path: f.path,
      bytes: 1,
      sha256: shaTeste,
      now: t0Teste,
    );
    expect(await bookFilePath(db, () async => nova, idTeste(1)), f.path);
  });
}
