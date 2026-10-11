// G03.2 — estante (user_books) e metas (reading_goals): Anexo 02 §4.1, CHECKs do SQL §4.
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/features/library/domain/reading_goals.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const usuario = '6f1c2a3b-4d5e-4f60-8a7b-9c0d1e2f3a4b';
  const livroId = '0199a7c4-2f00-7a10-8b20-000000000001';
  final t0 = DateTime.utc(2026, 9, 20, 23);
  final meta = RecordMeta(
    userId: usuario,
    createdAt: t0,
    updatedAt: t0,
    version: Hlc(t0.millisecondsSinceEpoch, 0, 'aparelhoA'),
  );

  UserBook livro({
    String title = 'Dom Casmurro',
    String? sha =
        'a3f1c2d4e5f60718293a4b5c6d7e8f90a1b2c3d4e5f60718293a4b5c6d7e8f90',
    int? rating,
    int? refPagesTotal = 256,
    int? chaptersTotal = 148,
    int? fileBytes = 222389,
    DateTime? addedAt,
  }) => UserBook(
    id: livroId,
    meta: meta,
    title: title,
    authorDisplay: 'Machado de Assis',
    format: BookFileFormat.epub,
    status: ShelfStatus.reading,
    contentSha256: sha,
    fileBytes: fileBytes,
    refPagesTotal: refPagesTotal,
    refPageVersion: 1,
    chaptersTotal: chaptersTotal,
    rating: rating,
    addedAt: addedAt ?? DateTime.utc(2026, 9, 1, 12),
  );

  group('UserBook', () {
    test('códigos do banco dos enums (CHECK do SQL)', () {
      expect(BookFileFormat.values.map((f) => f.code), [
        'epub',
        'pdf',
        'physical',
      ]);
      expect(ShelfStatus.values.map((s) => s.code), [
        'want_to_read',
        'reading',
        'finished',
        'abandoned',
      ]);
      expect(ShelfStatus.fromCode('want_to_read'), ShelfStatus.wantToRead);
      expect(BookFileFormat.fromCode('pdf'), BookFileFormat.pdf);
      expect(() => ShelfStatus.fromCode('lendo'), throwsFormatException);
    });

    test('CHECKs: título 1–500, sha256 hexa, nota 1–5, páginas e capítulos > 0, bytes ≥ 0', () {
      expect(livro().title, 'Dom Casmurro');
      expect(() => livro(title: ''), throwsArgumentError);
      expect(() => livro(title: 'x' * 501), throwsArgumentError);
      expect(() => livro(sha: 'xyz'), throwsArgumentError);
      expect(livro(sha: null).contentSha256, isNull);
      expect(() => livro(rating: 0), throwsArgumentError);
      expect(() => livro(rating: 6), throwsArgumentError);
      expect(livro(rating: 5).rating, 5);
      expect(() => livro(refPagesTotal: 0), throwsArgumentError);
      expect(() => livro(chaptersTotal: 0), throwsArgumentError);
      expect(() => livro(fileBytes: -1), throwsArgumentError);
      expect(() => livro(addedAt: DateTime(2026, 9, 1)), throwsArgumentError);
    });

    test('id é UUID', () {
      expect(
        () => UserBook(
          id: 'dom-casmurro',
          meta: meta,
          title: 'Dom Casmurro',
          authorDisplay: 'Machado de Assis',
          format: BookFileFormat.epub,
          status: ShelfStatus.reading,
          addedAt: t0,
        ),
        throwsArgumentError,
      );
    });

    test(
      'copyWith muda só o pedido; Nullable(null) limpa; igualdade por valor',
      () {
        final a = livro();
        final b = a.copyWith(
          status: ShelfStatus.finished,
          finishedAt: Nullable(DateTime.utc(2026, 9, 30)),
        );
        expect(b.status, ShelfStatus.finished);
        expect(b.finishedAt, DateTime.utc(2026, 9, 30));
        expect(b.title, a.title);
        expect(b.copyWith(finishedAt: const Nullable(null)).finishedAt, isNull);
        expect(a, livro());
        expect(a.hashCode, livro().hashCode);
        expect(a == b, isFalse);
        expect(a.copyWith(), a);
      },
    );
  });

  group('ReadingGoals', () {
    test('padrões do SQL: 30 min por dia, selo com 7 dias', () {
      final g = ReadingGoals(id: usuario, meta: meta);
      expect(g.dailyMinutes, 30);
      expect(g.badgeTargetDays, 7);
    });

    test('CHECKs: minutos 5–600, dias 1–365, id = dono', () {
      expect(
        () => ReadingGoals(id: usuario, meta: meta, dailyMinutes: 4),
        throwsArgumentError,
      );
      expect(
        () => ReadingGoals(id: usuario, meta: meta, dailyMinutes: 601),
        throwsArgumentError,
      );
      expect(
        () => ReadingGoals(id: usuario, meta: meta, badgeTargetDays: 0),
        throwsArgumentError,
      );
      expect(() => ReadingGoals(id: livroId, meta: meta), throwsArgumentError);
      final g = ReadingGoals(id: usuario, meta: meta, badgeTargetDays: 14);
      expect(g.copyWith(dailyMinutes: 45).dailyMinutes, 45);
      expect(g.copyWith(dailyMinutes: 45).badgeTargetDays, 14);
      expect(g, ReadingGoals(id: usuario, meta: meta, badgeTargetDays: 14));
    });
  });
}
