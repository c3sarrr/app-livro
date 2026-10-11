// G03.2 — metadados comuns das 10 tabelas pessoais (dono, datas UTC, tombstone, version_hlc).
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/model/checks.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const usuario = '6f1c2a3b-4d5e-4f60-8a7b-9c0d1e2f3a4b';
  final t0 = DateTime.utc(2026, 9, 20, 23);
  final v0 = Hlc(t0.millisecondsSinceEpoch, 0, 'aparelhoA');

  RecordMeta meta0() =>
      RecordMeta(userId: usuario, createdAt: t0, updatedAt: t0, version: v0);

  test('datas precisam estar em UTC (o banco guarda ISO-8601 UTC)', () {
    expect(
      () => RecordMeta(
        userId: usuario,
        createdAt: DateTime(2026, 9, 20, 20),
        updatedAt: t0,
        version: v0,
      ),
      throwsArgumentError,
    );
    expect(
      () => meta0().copyWith(deletedAt: Nullable(DateTime(2026, 9, 21))),
      throwsArgumentError,
    );
  });

  test('dono precisa ser um UUID', () {
    expect(
      () => RecordMeta(
        userId: 'marina',
        createdAt: t0,
        updatedAt: t0,
        version: v0,
      ),
      throwsArgumentError,
    );
  });

  test(
    'edited: nova versão e updated_at; created_at e deleted_at mantidos',
    () {
      final t1 = t0.add(const Duration(minutes: 5));
      final v1 = Hlc(t1.millisecondsSinceEpoch, 0, 'aparelhoA');
      final m = meta0().edited(t1, v1);
      expect(m.updatedAt, t1);
      expect(m.version, v1);
      expect(m.createdAt, t0);
      expect(m.deletedAt, isNull);
      expect(m.isDeleted, isFalse);
    },
  );

  test('deleted: tombstone com deleted_at = updated_at e versão nova', () {
    final t1 = t0.add(const Duration(days: 1));
    final v1 = Hlc(t1.millisecondsSinceEpoch, 3, 'aparelhoB');
    final m = meta0().deleted(t1, v1);
    expect(m.deletedAt, t1);
    expect(m.updatedAt, t1);
    expect(m.version, v1);
    expect(m.isDeleted, isTrue);
  });

  test(
    'G15 restored: volta da exclusão com versão nova; created_at igual (D-152)',
    () {
      final t1 = t0.add(const Duration(days: 1));
      final t2 = t1.add(const Duration(minutes: 2));
      final v2 = Hlc(t2.millisecondsSinceEpoch, 1, 'aparelhoA');
      final m = meta0()
          .deleted(t1, Hlc(t1.millisecondsSinceEpoch, 0, 'aparelhoA'))
          .restored(t2, v2);
      expect(m.deletedAt, isNull);
      expect(m.isDeleted, isFalse);
      expect(m.updatedAt, t2);
      expect(m.version, v2);
      expect(m.createdAt, t0);
      expect(m.userId, usuario);
    },
  );

  test('copyWith: Nullable(null) limpa, ausente mantém', () {
    final apagado = meta0().deleted(t0, v0);
    expect(apagado.copyWith().deletedAt, t0);
    expect(apagado.copyWith(deletedAt: const Nullable(null)).deletedAt, isNull);
  });

  test('igualdade por valor', () {
    expect(meta0(), meta0());
    expect(meta0().hashCode, meta0().hashCode);
    expect(meta0() == meta0().edited(t0, Hlc(1, 0, 'x')), isFalse);
  });

  group('Check', () {
    test('texto conta caracteres (como char_length do Postgres), não unidades UTF-16', () {
      expect(Check.text('😀' * 24, max: 24, name: 't'), hasLength(48));
      expect(
        () => Check.text('😀' * 25, max: 24, name: 't'),
        throwsArgumentError,
      );
      expect(
        () => Check.text('', min: 1, max: 24, name: 't'),
        throwsArgumentError,
      );
    });

    test(
      'cor em #RRGGBB maiúsculo, sha256 em hexa minúsculo, UUID minúsculo',
      () {
        expect(Check.hexColor('#FED170', 'c'), '#FED170');
        expect(() => Check.hexColor('#fed170', 'c'), throwsArgumentError);
        expect(() => Check.hexColor('FED170', 'c'), throwsArgumentError);
        expect(Check.sha256OrNull(null, 's'), isNull);
        expect(() => Check.sha256OrNull('ABC', 's'), throwsArgumentError);
        expect(
          () => Check.uuid('6F1C2A3B-4D5E-4F60-8A7B-9C0D1E2F3A4B', 'u'),
          throwsArgumentError,
        );
      },
    );

    test('faixas inclusivas', () {
      expect(Check.range(1, 1, 5, 'r'), 1);
      expect(Check.range(5, 1, 5, 'r'), 5);
      expect(() => Check.range(6, 1, 5, 'r'), throwsArgumentError);
      expect(Check.rangeOrNull(null, 1, 5, 'r'), isNull);
    });
  });
}
