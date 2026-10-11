// G12.2 — a velocidade pessoal da conta para o tempo restante do leitor (D-97): personalSpeed das sessões vivas
// da conta, em ordem de início, com o tamanho médio da página de referência de cada livro (sem índice: 1.500).
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/features/reader/application/reading_speed_source.dart';
import 'package:app_leitura/features/reader/domain/reading_speed.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';
import '../../../support/personal_builders.dart';
import '../../../support/reader_harness.dart';

void main() {
  test(
    'as sessões do mundo, sem índice gravado: 1.500 caracteres por página',
    () async {
      final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
      addTearDown(db.close);
      final m = mundoReferencia;
      await m.gravarEm(db);
      final amostras = [
        for (final s in [
          ...m.sessoes,
        ]..sort((a, b) => a.startedAt.compareTo(b.startedAt)))
          if (!s.meta.isDeleted && s.meta.userId == m.usuarioId)
            (
              activeSeconds: s.activeSeconds,
              pagesViewed: s.pagesViewed ?? 0,
              charsPerRefPage: 1500.0,
            ),
      ];
      expect(amostras, isNotEmpty);
      expect(
        await readingSpeedOf(db, m.usuarioId),
        closeTo(personalSpeed(amostras), 1e-9),
      );
      expect(await readingSpeedOf(db, 'ninguem'), defaultCharsPerMinute);
    },
  );

  test('livro com índice: caracteres ÷ páginas de referência; sessão apagada não conta; ordem pelo início', () async {
    final livro = await LivroNaEstante.domCasmurro();
    addTearDown(livro.close);
    final db = livro.db;
    final porPagina = livro.index.totalChars / livro.book.refPagesTotal!;
    final t = DateTime.utc(2026, 9, 1, 12);
    // a mais nova gravada primeiro: a média segue o instante, não a ordem de gravação
    await ReadingSessionsDao(db).upsert(
      sessaoTeste(
        2,
        livro: livro.userBookId,
        inicio: t.add(const Duration(days: 1)),
        segundos: 600,
      ),
    );
    await ReadingSessionsDao(
      db,
    ).upsert(sessaoTeste(1, livro: livro.userBookId, inicio: t, segundos: 300));
    final apagada = sessaoTeste(
      3,
      livro: livro.userBookId,
      inicio: t.add(const Duration(days: 2)),
      segundos: 900,
    );
    await ReadingSessionsDao(db).upsert(
      apagada.copyWith(
        meta: apagada.meta.deleted(
          t.add(const Duration(days: 3)),
          apagada.meta.version,
        ),
      ),
    );
    final esperado = personalSpeed([
      (activeSeconds: 300, pagesViewed: 9, charsPerRefPage: porPagina),
      (activeSeconds: 600, pagesViewed: 9, charsPerRefPage: porPagina),
    ]);
    expect(await readingSpeedOf(db, usuarioTeste), closeTo(esperado, 1e-9));
  });
}
