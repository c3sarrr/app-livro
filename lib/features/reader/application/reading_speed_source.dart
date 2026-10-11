// G12.2 — a velocidade pessoal da conta (D-97) para o tempo restante do leitor ("≈ 2 h 10 min" — telas 20/26b):
// as sessões vivas, em ordem de início, cada uma com o tamanho médio da página de referência do livro dela (o
// mesmo cálculo da Início — G10.4). Sem sessão de 3 min ou mais, 1.000 caracteres por minuto.
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/codecs.dart';
import '../domain/reading_speed.dart';

Future<double> readingSpeedOf(AppDatabase db, String userId) async {
  final owner = [Variable.withString(userId)];
  // caracteres de cada livro com índice (itens lineares do `spine_json`)
  final chars = <String, int>{};
  for (final r
      in await db
          .customSelect(
            'SELECT i.user_book_id, i.spine_json FROM book_content_index i '
            'JOIN user_books b ON b.id = i.user_book_id '
            'WHERE b.user_id = ?1 AND b.deleted_at IS NULL',
            variables: owner,
          )
          .get()) {
    final n = _linearChars(r.read<String>('spine_json'));
    if (n != null) chars[r.read<String>('user_book_id')] = n;
  }
  final pages = <String, int?>{
    for (final r
        in await db
            .customSelect(
              'SELECT id, ref_pages_total FROM user_books WHERE user_id = ?1',
              variables: owner,
            )
            .get())
      r.read<String>('id'): r.readNullable<int>('ref_pages_total'),
  };
  final samples = <(DateTime, SpeedSample)>[];
  for (final r
      in await db
          .customSelect(
            'SELECT started_at, active_seconds, pages_viewed, user_book_id FROM reading_sessions '
            'WHERE user_id = ?1 AND deleted_at IS NULL',
            variables: owner,
          )
          .get()) {
    final DateTime start;
    try {
      start = parseInstant(r.read<String>('started_at'));
    } on FormatException {
      continue;
    }
    final book = r.read<String>('user_book_id');
    samples.add((
      start,
      (
        activeSeconds: r.read<int>('active_seconds'),
        pagesViewed: r.readNullable<int>('pages_viewed') ?? 0,
        charsPerRefPage: charsPerRefPage(
          totalChars: chars[book],
          refPagesTotal: pages[book],
        ),
      ),
    ));
  }
  // em ordem de início (o texto gravado pode vir em formatos diferentes: ordena pelo instante)
  samples.sort((a, b) => a.$1.compareTo(b.$1));
  return personalSpeed([for (final s in samples) s.$2]);
}

/// Caracteres dos itens lineares do `spine_json`; ilegível, PDF ou só imagens → `null` (conta pelas páginas).
int? _linearChars(String spineJson) {
  try {
    final items =
        (jsonDecode(spineJson) as Map<String, Object?>)['items']! as List;
    var total = 0;
    for (final i in items) {
      final m = i as Map<String, Object?>;
      if (m['linear']! as bool) total += m['chars']! as int;
    }
    return total > 0 ? total : null;
  } on Object {
    return null;
  }
}
