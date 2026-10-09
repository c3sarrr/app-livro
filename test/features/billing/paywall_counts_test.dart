// G22.4 — os números dos marcos (R7), contados no banco do aparelho: os livros da conta na estante, os grifos (um por
// grupo) e a sequência da Início.
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/features/billing/data/paywall_counts.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/personal_builders.dart';

void main() {
  late AppDatabase db;
  const outra = '0199a7c4-2f00-7a10-8b20-0000000000ff';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    final livros = UserBooksDao(db);
    await livros.upsert(livroTeste(1));
    await livros.upsert(livroTeste(2).copyWith(status: ShelfStatus.wantToRead));
    await livros.upsert(livroTeste(3).copyWith(status: ShelfStatus.finished));
    await livros.upsert(livroTeste(4, apagado: true));
    await livros.upsert(livroTeste(5, dono: outra));

    final anotacoes = AnnotationsDao(db);
    final livro = idTeste(1);
    final g1 = grifoTeste(10, livro: livro);
    await anotacoes.upsert(g1);
    // o mesmo grifo continuando na página seguinte (o mesmo grupo)
    await anotacoes.upsert(
      grifoTeste(11, livro: livro, pagina: 160).copyWith(groupId: g1.groupId),
    );
    await anotacoes.upsert(grifoTeste(12, livro: livro, inicio: 40));
    await anotacoes.upsert(grifoTeste(13, livro: livro, apagado: true));
    await anotacoes.upsert(grifoTeste(14, livro: livro, dono: outra));
    await anotacoes.upsert(
      notaTeste(15, livro: livro, pai: g1, texto: 'Olhos de ressaca'),
    );
  });
  tearDown(() => db.close());

  test('os livros da conta na estante (lidos ou não), os grifos por grupo e a sequência', () async {
    final contas = PaywallCounts(
      database: () async => db,
      streak: () async => 12,
    );
    final n = await contas.of(usuarioTeste);
    expect((n.books, n.highlights, n.streakDays), (3, 2, 12));
  });

  test('outra conta só vê o que é dela', () async {
    final contas = PaywallCounts(
      database: () async => db,
      streak: () async => 0,
    );
    final n = await contas.of(outra);
    expect((n.books, n.highlights), (1, 1));
  });
}
