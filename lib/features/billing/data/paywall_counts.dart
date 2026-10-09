// G22.4 — os números dos marcos de valor (R7), contados no banco do aparelho (nada sai dele): os livros da conta na
// estante, os grifos (um por grupo: o grifo que atravessa páginas conta uma vez) e a sequência da Início.
import 'package:drift/drift.dart' show Variable;

import '../../../core/data/database/app_database.dart';

typedef PaywallNumbers = ({int books, int highlights, int streakDays});

final class PaywallCounts {
  PaywallCounts({required this.database, required this.streak});

  final Future<AppDatabase> Function() database;

  /// A sequência da Início (G08).
  final Future<int> Function() streak;

  Future<PaywallNumbers> of(String owner) async {
    final db = await database();
    Future<int> count(String sql) async =>
        (await db
                .customSelect(sql, variables: [Variable.withString(owner)])
                .getSingle())
            .read<int>('n');
    final books = await count(
      'SELECT COUNT(*) AS n FROM user_books '
      'WHERE user_id = ?1 AND deleted_at IS NULL',
    );
    final highlights = await count(
      'SELECT COUNT(DISTINCT group_id) AS n FROM annotations '
      "WHERE user_id = ?1 AND kind = 'highlight' AND deleted_at IS NULL",
    );
    return (books: books, highlights: highlights, streakDays: await streak());
  }
}
