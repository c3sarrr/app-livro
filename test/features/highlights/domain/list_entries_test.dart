// G19.1 — as entradas da lista da tela 25: separadores por página, "você parou aqui" (R6) e os sem lugar (D-199).
import 'package:app_leitura/features/highlights/domain/highlight_card.dart';
import 'package:app_leitura/features/highlights/domain/list_entries.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/ordem_do_livro.dart';

void main() {
  final cartoes = buildCards(itensDoMundo());

  /// "p3", "p159*" (aqui), "c1", "~" (sem lugar), "c4~" (cartão sem lugar).
  List<String> curto(List<ListEntry> es) => [
    for (final e in es)
      switch (e) {
        PageMark(:final page, :final here, :final n) =>
          'p$page${here ? '*' : ''}#$n',
        CardItem(:final n, :final orphan, :final card) =>
          'c$n${orphan ? '~' : ''}=${cartoes.indexOf(card) + 1}',
        OrphanMark() => '~',
      },
  ];

  test('o mundo: 6 separadores, o da 159 é "você parou aqui"', () {
    expect(curto(listEntries(cartoes, herePage: 159)), [
      'p3#1',
      'c1=1',
      'p6#2',
      'c2=2',
      'p41#3',
      'c3=3',
      'p121#4',
      'c4=4',
      'p152#5',
      'c5=5',
      'p159*#6',
      'c6=6',
      'c7=7',
      'c8=8',
    ]);
  });

  test('a página atual sem cartão: a pílula sozinha no lugar dela', () {
    expect(curto(listEntries(cartoes, herePage: 140)), [
      'p3#1',
      'c1=1',
      'p6#2',
      'c2=2',
      'p41#3',
      'c3=3',
      'p121#4',
      'c4=4',
      'p140*#5',
      'p152#6',
      'c5=5',
      'p159#7',
      'c6=6',
      'c7=7',
      'c8=8',
    ]);
    expect(curto(listEntries(cartoes, herePage: 300)).last, 'p300*#7');
    expect(curto(listEntries(cartoes, herePage: 1)).take(2), ['p1*#1', 'p3#2']);
  });

  test('sem posição: nenhum aqui; lista vazia: nada', () {
    expect(curto(listEntries(cartoes)).where((s) => s.contains('*')), isEmpty);
    expect(listEntries(const [], herePage: 159), isEmpty);
  });

  test('filtrada (Notas): os números recontados e a 159 sozinha', () {
    expect(curto(listEntries([cartoes[1], cartoes[4]], herePage: 159)), [
      'p6#1',
      'c1=2',
      'p152#2',
      'c2=5',
      'p159*#3',
    ]);
  });

  test(
    'sem lugar: saem da sequência e vão para o fim, depois do separador',
    () {
      expect(
        curto(
          listEntries(
            cartoes,
            herePage: 159,
            orphanGroups: {cartoes[3].groupId},
          ),
        ),
        [
          'p3#1',
          'c1=1',
          'p6#2',
          'c2=2',
          'p41#3',
          'c3=3',
          'p152#4',
          'c4=5',
          'p159*#5',
          'c5=6',
          'c6=7',
          'c7=8',
          '~',
          'c8~=4',
        ],
      );
    },
  );

  test('igualdade das entradas', () {
    expect(const PageMark(3, 1), const PageMark(3, 1));
    expect(const PageMark(3, 1).hashCode, const PageMark(3, 1).hashCode);
    expect(const PageMark(3, 1) == const PageMark(3, 1, here: true), isFalse);
    expect(CardItem(cartoes[0], 1), CardItem(cartoes[0], 1));
    expect(CardItem(cartoes[0], 1).hashCode, CardItem(cartoes[0], 1).hashCode);
    expect(
      CardItem(cartoes[0], 1) == CardItem(cartoes[0], 1, orphan: true),
      isFalse,
    );
    expect(const OrphanMark(), const OrphanMark());
    expect(const OrphanMark().hashCode, const OrphanMark().hashCode);
  });
}
