// R00.7 (D-267) — o que é do app normal na pasta de suporte do aparelho (o banco com os arquivos do SQLite ao lado e
// as pastas, com conteúdo), para os testes do modo demonstração provarem que o demo não toca em nada disso.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// O banco e as pastas do app normal, com bytes que o demo não pode mudar.
const Map<String, List<int>> doAppNormal = {
  'booknest.db': [1, 2, 3, 4],
  'booknest.db-wal': [5, 6],
  'livros/meu-livro.epub': [7, 8, 9],
  'capas/abc.img': [10],
  'capas_arquivo/def.img': [11],
  'catalogo/catalog.db': [12, 13],
};

/// Os nomes do app normal na raiz da pasta de suporte.
const Set<String> nomesDoAppNormal = {
  'booknest.db',
  'booknest.db-wal',
  'livros',
  'capas',
  'capas_arquivo',
  'catalogo',
};

/// [relativo] (com `/`) dentro de [base].
String caminhoEm(Directory base, String relativo) =>
    [base.path, ...relativo.split('/')].join(Platform.pathSeparator);

/// Uma pasta de suporte temporária com o app normal dentro (apagada no fim do teste; num `testWidgets`, chame também
/// [apagarPasta] dentro de `tester.runAsync` — o SQLite do PowerSync solta o arquivo depois de fechar).
Directory suporteComAppNormal() {
  final base = Directory.systemTemp.createTempSync('booknest_r00_suporte_');
  for (final MapEntry(key: relativo, value: bytes) in doAppNormal.entries) {
    File(caminhoEm(base, relativo))
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);
  }
  addTearDown(() {
    try {
      if (base.existsSync()) base.deleteSync(recursive: true);
    } on FileSystemException {
      // ainda presa pelo SQLite: é uma pasta temporária do sistema
    }
  });
  return base;
}

/// O app normal em [base] está byte a byte como foi criado.
void conferirAppNormal(Directory base) {
  for (final MapEntry(key: relativo, value: bytes) in doAppNormal.entries) {
    expect(
      File(caminhoEm(base, relativo)).readAsBytesSync(),
      bytes,
      reason: '$relativo é do app normal',
    );
  }
  expect(
    Directory(caminhoEm(base, 'livros')).listSync(),
    hasLength(1),
    reason: 'nenhum livro novo na pasta do app normal',
  );
}

/// Os nomes na raiz de [base].
Set<String> nomesNaRaiz(Directory base) => {
  for (final e in base.listSync())
    e.uri.pathSegments.where((s) => s.isNotEmpty).last,
};

/// Apaga [d], esperando o Windows soltar os arquivos do SQLite.
Future<void> apagarPasta(Directory d) async {
  for (var i = 0; i < 30; i++) {
    try {
      if (d.existsSync()) d.deleteSync(recursive: true);
      return;
    } on FileSystemException {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }
}
