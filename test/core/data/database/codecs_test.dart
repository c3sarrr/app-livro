// G03.3 — formato canônico dos valores no SQLite (ADR-002 §7).
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/codecs.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('data/hora', () {
    test('sempre 6 casas e "Z" (o que volta do servidor)', () {
      expect(
        formatInstant(DateTime.utc(2026, 10, 4, 2, 7, 53, 298, 28)),
        '2026-10-04T02:07:53.298028Z',
      );
      expect(
        formatInstant(DateTime.utc(2026, 9, 20, 23)),
        '2026-09-20T23:00:00.000000Z',
      );
      expect(() => formatInstant(DateTime(2026, 9, 20)), throwsArgumentError);
    });

    test('lê o canônico e as variações do servidor; exige fuso', () {
      final esperado = DateTime.utc(2026, 10, 4, 2, 7, 53, 298, 28);
      expect(parseInstant('2026-10-04T02:07:53.298028Z'), esperado);
      expect(parseInstant('2026-10-04 02:07:53.298028Z'), esperado);
      expect(parseInstant('2026-10-04T02:07:53.298028+00:00'), esperado);
      expect(parseInstant('2026-10-03T23:07:53.298028-03:00'), esperado);
      expect(parseInstant('2026-10-04T02:07:53.298028Z').isUtc, isTrue);
      expect(() => parseInstant('2026-10-04T02:07:53'), throwsFormatException);
      expect(() => parseInstant('ontem'), throwsFormatException);
    });

    test('o texto canônico ordena como o tempo', () {
      final a = formatInstant(DateTime.utc(2026, 9, 9, 23, 59, 59, 999, 999));
      final b = formatInstant(DateTime.utc(2026, 9, 10));
      expect(a.compareTo(b), lessThan(0));
    });
  });

  test('numeric como TEXT com casas fixas (sem perder precisão)', () {
    const p = DecimalTextConverter(5);
    expect(p.toSql(0.62113), '0.62113');
    expect(p.toSql(1), '1.00000');
    expect(p.fromSql('0.62113'), 0.62113);
    const mm = DecimalTextConverter(1);
    expect(mm.toSql(1.2), '1.2');
    expect(mm.fromSql('1.2'), 1.2);
  });

  test('HLC, enum, localizador, âncora e lista em JSON: ida e volta', () {
    final h = Hlc(1789945200000, 3, 'aparelhoA');
    expect(const HlcConverter().fromSql(const HlcConverter().toSql(h)), h);
    const c = CodeConverter(ShelfStatus.fromCode);
    expect(c.toSql(ShelfStatus.wantToRead), 'want_to_read');
    expect(c.fromSql('want_to_read'), ShelfStatus.wantToRead);
    final l = EpubLocator(
      sha: 'a' * 64,
      spine: 3,
      offset: 10,
      refPage: 2,
      progression: 0.5,
    );
    expect(
      const LocatorConverter().fromSql(const LocatorConverter().toSql(l)),
      l,
    );
    final a = EpubAnchor(
      sha: 'b' * 64,
      spine: 3,
      start: 1,
      end: 4,
      quote: const TextQuote(prefix: 'o', exact: 'lho', suffix: 's'),
      refPage: 2,
    );
    expect(
      const AnchorConverter().fromSql(const AnchorConverter().toSql(a)),
      a,
    );
    // o Postgres devolve JSON com espaços: a leitura compara o valor, não o texto
    expect(
      const AnchorConverter().fromSql(
        '{"v": 1, "sha": "${'b' * 64}", "spine": 3, "start": 1, "end": 4, '
        '"quote": {"prefix": "o", "exact": "lho", "suffix": "s"}, "refPage": 2}',
      ),
      a,
    );
    expect(const StringListConverter().toSql(['#FF552E']), '["#FF552E"]');
    expect(const StringListConverter().fromSql('["#FF552E", "#552CB7"]'), [
      '#FF552E',
      '#552CB7',
    ]);
  });
}
