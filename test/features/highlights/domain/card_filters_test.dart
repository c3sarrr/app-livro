// G19.1 — a cor de cada item (R2), a fileira COR (D-196), os filtros sobre cartões (D-197) e as contagens (R1).
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/features/highlights/domain/card_filters.dart';
import 'package:app_leitura/features/highlights/domain/highlight_card.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';
import '../support/ordem_do_livro.dart';

void main() {
  final itens = itensDoMundo();
  final porId = {for (final a in itens) a.id: a};
  final cartoes = buildCards(itens);
  List<int> visiveis(
    HighlightFilters f, {
    Set<String>? hits,
    List<HighlightCard>? de,
  }) => [
    for (final c in filterCards(de ?? cartoes, f, hits: hits))
      cartoes.indexWhere((x) => x.groupId == c.groupId) + 1,
  ];

  /// O mesmo item, criado [minutos] depois do último do mundo.
  Annotation depois(Annotation a, int minutos, {String? cor, String? id}) {
    final em = itens
        .map((x) => x.meta.createdAt)
        .reduce((x, y) => x.isAfter(y) ? x : y)
        .add(Duration(minutes: minutos));
    return a.copyWith(
      meta: RecordMeta(
        userId: a.meta.userId,
        createdAt: em,
        updatedAt: em,
        version: a.meta.version,
      ),
      color: cor == null ? null : Nullable(cor),
    );
  }

  group('R2: a cor de cada item', () {
    test(
      'a nota herda a do grifo pai; desenho, a da tinta; nota à mão, nenhuma',
      () {
        expect(
          itemColor(itemDoMundo(6, AnnotationKind.note), porId),
          '#FFC1C6',
        );
        expect(
          itemColor(itemDoMundo(152, AnnotationKind.note), porId),
          '#B6ACE4',
        );
        expect(
          itemColor(itemDoMundo(159, AnnotationKind.drawing), porId),
          '#FF552E',
        );
        expect(
          itemColor(itemDoMundo(159, AnnotationKind.handwriting), porId),
          isNull,
        );
        expect(
          itemColor(itemDoMundo(3, AnnotationKind.highlight), porId),
          '#FED170',
        );
      },
    );

    test('nota sem o pai no mapa: nenhuma', () {
      expect(itemColor(itemDoMundo(6, AnnotationKind.note), const {}), isNull);
    });
  });

  group('D-196: a fileira COR', () {
    test('no mundo: as 4 do marca-texto e a tinta coral, como o arquivo', () {
      final r = colorRow(itens);
      expect(r.map((c) => c.key), [
        'yellow',
        'pink',
        'green',
        'lavender',
        'coral',
      ]);
      expect(r.map((c) => c.label), [
        'Amarelo',
        'Rosa',
        'Verde',
        'Lavanda',
        'Tinta coral',
      ]);
      expect(r.map((c) => c.hex), [
        '#FED170',
        '#FFC1C6',
        '#ABCF82',
        '#B6ACE4',
        '#FF552E',
      ]);
    });

    test('outras cores na ordem do primeiro uso, com o nome da caneta ou "Outra cor"', () {
      final roxo = depois(
        itemDoMundo(159, AnnotationKind.drawing),
        1,
        cor: '#552CB7',
      );
      final outra = depois(
        itemDoMundo(3, AnnotationKind.highlight),
        2,
        cor: '#123456',
      );
      final r = colorRow([...itens, outra, roxo]);
      expect(r.skip(4).map((c) => (c.key, c.label)), [
        ('coral', 'Tinta coral'),
        ('c552cb7', 'Tinta roxa'),
        ('c123456', 'Outra cor'),
      ]);
    });

    test('livro sem itens, ou só com as 4: só as 4', () {
      expect(colorRow(const []).map((c) => c.key), [
        'yellow',
        'pink',
        'green',
        'lavender',
      ]);
      expect(
        colorRow([
          for (final a in itens)
            if (a.kind == AnnotationKind.highlight) a,
        ]).length,
        4,
      );
    });
  });

  group('D-197: filtros sobre cartões', () {
    test('o padrão mostra os 8', () {
      expect(const HighlightFilters().isDefault, isTrue);
      expect(visiveis(const HighlightFilters()), [1, 2, 3, 4, 5, 6, 7, 8]);
    });

    test('por tipo: o cartão inteiro', () {
      expect(visiveis(const HighlightFilters(type: TypeFilter.notes)), [2, 5]);
      expect(visiveis(const HighlightFilters(type: TypeFilter.drawings)), [
        7,
        8,
      ]);
      expect(visiveis(const HighlightFilters(type: TypeFilter.handwriting)), [
        7,
      ]);
      expect(visiveis(const HighlightFilters(type: TypeFilter.highlights)), [
        1,
        2,
        3,
        4,
        5,
        6,
      ]);
    });

    test('por cor: várias marcadas somam; a nota herda', () {
      expect(visiveis(const HighlightFilters(colors: {'#FFC1C6'})), [2]);
      expect(visiveis(const HighlightFilters(colors: {'#FF552E'})), [7, 8]);
      expect(visiveis(const HighlightFilters(colors: {'#FFC1C6', '#FF552E'})), [
        2,
        7,
        8,
      ]);
      expect(visiveis(const HighlightFilters(colors: {'#FED170'})), [1, 4, 6]);
    });

    test('tipo e cor no mesmo item', () {
      expect(
        visiveis(
          const HighlightFilters(type: TypeFilter.notes, colors: {'#FED170'}),
        ),
        isEmpty,
      );
      expect(
        visiveis(
          const HighlightFilters(type: TypeFilter.notes, colors: {'#B6ACE4'}),
        ),
        [5],
      );
    });

    test('só do clube', () {
      expect(visiveis(const HighlightFilters(clubOnly: true)), [5]);
    });

    test('busca: os acertos; sem acerto, nada; null = sem busca', () {
      final ondulado = itemDoMundo(159, AnnotationKind.drawing, nth: 1);
      expect(visiveis(const HighlightFilters(), hits: {ondulado.id}), [8]);
      expect(visiveis(const HighlightFilters(), hits: {}), isEmpty);
      expect(visiveis(const HighlightFilters(), hits: null), hasLength(8));
    });

    test('a nota à mão sozinha some com uma cor marcada', () {
      final mao = itemDoMundo(159, AnnotationKind.handwriting);
      final so = buildCards([mao.copyWith(groupId: mao.id)]);
      expect(filterCards(so, const HighlightFilters()), hasLength(1));
      expect(
        filterCards(so, const HighlightFilters(colors: {'#FF552E'})),
        isEmpty,
      );
    });

    test('igualdade e copyWith', () {
      const f = HighlightFilters(colors: {'#FED170'}, query: 'x');
      expect(f, const HighlightFilters(colors: {'#FED170'}, query: 'x'));
      expect(
        f.hashCode,
        const HighlightFilters(colors: {'#FED170'}, query: 'x').hashCode,
      );
      expect(f == const HighlightFilters(colors: {'#FED170'}), isFalse);
      expect(f.isDefault, isFalse);
      expect(const HighlightFilters(query: '  ').isDefault, isTrue);
      expect(const HighlightFilters(clubOnly: true).isDefault, isFalse);
      final g = f.copyWith(type: TypeFilter.notes, clubOnly: true);
      expect((g.type, g.clubOnly, g.query), (TypeFilter.notes, true, 'x'));
      expect(g.colors, {'#FED170'});
      expect(f.copyWith(colors: {}, query: '').isDefault, isTrue);
    });

    test('o tipo do chip', () {
      expect(TypeFilter.values.map(kindOfFilter), [
        null,
        AnnotationKind.highlight,
        AnnotationKind.note,
        AnnotationKind.handwriting,
        AnnotationKind.drawing,
      ]);
    });
  });

  group('R1: as contagens dos chips', () {
    test('os totais do livro: 6 + 2 + 1 + 3 = 12', () {
      final c = kindCounts(itens);
      expect(
        (c.highlights, c.notes, c.handwriting, c.drawings, c.all),
        (6, 2, 1, 3, 12),
      );
      expect(mundoReferencia.domCasmurro.id, itens.first.userBookId);
    });

    test('livro vazio: zero', () {
      expect(kindCounts(const []).all, 0);
    });
  });
}
