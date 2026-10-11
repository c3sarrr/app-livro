// G19.1 — os cartões da tela 25 (D-30) e o rótulo de cada um (R4), contra o mundo de referência.
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/features/highlights/domain/highlight_card.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';
import '../../../support/personal_builders.dart';
import '../support/ordem_do_livro.dart';

void main() {
  final itens = itensDoMundo();
  final cartoes = buildCards(itens);

  test('8 cartões, na ordem dos grupos do arquivo (cartoesDaTela25)', () {
    expect(cartoes.map((c) => c.groupId), [
      for (final c in mundoReferencia.cartoesDaTela25) c.grupoId,
    ]);
    expect(cartoes.map((c) => c.page), [3, 6, 41, 121, 152, 159, 159, 159]);
    expect(cartoes.expand((c) => c.items).length, 12);
  });

  test('pílulas: GRIFO, GRIFO + NOTA, DESENHO + À MÃO, 2 DESENHOS', () {
    expect((cartoes[0].label, cartoes[0].dot), ('GRIFO', '#FED170'));
    expect(cartoes[0].hasNotePill, isFalse);
    expect(cartoes[1].hasNotePill, isTrue);
    expect(cartoes[1].kind, CardKind.highlight);
    expect((cartoes[6].label, cartoes[6].dot), ('DESENHO', '#FF552E'));
    expect(cartoes[6].hasHandPill, isTrue);
    expect(cartoes[6].kind, CardKind.drawing);
    expect(cartoes[7].label, '2 DESENHOS');
    expect(cartoes[7].hasHandPill, isFalse);
    expect(cartoes[5].freehand, isTrue);
    expect(cartoes[0].freehand, isFalse);
    expect(cartoes[4].clubPostId, mundoReferencia.clube.postCompartilhadoId);
    expect(cartoes[0].clubPostId, isNull);
  });

  test('os itens de cada tipo', () {
    expect(cartoes[1].highlight!.kind, AnnotationKind.highlight);
    expect(cartoes[1].notes.single.noteText, 'É o livro todo nessa frase.');
    expect(cartoes[6].drawings, hasLength(1));
    expect(cartoes[6].handwriting, hasLength(1));
    expect(cartoes[7].drawings, hasLength(2));
    expect(cartoes[7].highlight, isNull);
  });

  test('rótulos do leitor de tela, como o arquivo', () {
    expect(cartoes.map(cardSemanticsLabel), [
      'Grifo amarelo, página 3',
      'Grifo rosa com nota, página 6',
      'Grifo verde, página 41',
      'Grifo amarelo, página 121',
      'Grifo lavanda com nota, compartilhado no clube, página 152',
      'Grifo à mão livre, página 159',
      'Desenho e nota à mão, página 159',
      'Dois desenhos, página 159',
    ]);
  });

  test('números por extenso até 10, depois algarismos', () {
    expect(drawingsWord(1), 'Desenho');
    expect(drawingsWord(2), 'Dois desenhos');
    expect(drawingsWord(3), 'Três desenhos');
    expect(drawingsWord(10), 'Dez desenhos');
    expect(drawingsWord(11), '11 desenhos');
  });

  test(
    'grifo de outra cor; nota à mão sozinha; grifo com nota e nota à mão',
    () {
      final outra = itens.first.copyWith(color: const Nullable('#123456'));
      expect(
        cardSemanticsLabel(buildCards([outra]).single),
        'Grifo de outra cor, página 3',
      );
      final mao = itens.firstWhere((a) => a.kind == AnnotationKind.handwriting);
      final so = buildCards([mao.copyWith(groupId: mao.id)]).single;
      expect((so.label, so.dot, so.hasHandPill), ('À MÃO', null, false));
      expect(so.kind, CardKind.handwriting);
      expect(cardSemanticsLabel(so), 'Nota à mão, página 159');
      final p6 = cartoes[1].items;
      final misto = buildCards([
        ...p6,
        mao.copyWith(groupId: cartoes[1].groupId),
      ]).single;
      expect(
        cardSemanticsLabel(misto),
        'Grifo rosa com nota e nota à mão, página 6',
      );
      final doisDesenhos = buildCards([
        for (final d in cartoes[7].items) d,
        mao.copyWith(groupId: cartoes[7].groupId),
      ]).single;
      expect(
        cardSemanticsLabel(doisDesenhos),
        'Dois desenhos e nota à mão, página 159',
      );
    },
  );

  test('data do cartão = a criação mais antiga do grupo; igualdade', () {
    final c = cartoes[1];
    final mais = c.items
        .map((a) => a.meta.createdAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    expect(c.createdAt, mais);
    expect(c.createdAt, c.items.first.meta.createdAt);
    expect(buildCards(itens), cartoes);
    expect(buildCards(itens).first.hashCode, cartoes.first.hashCode);
    expect(cartoes[0] == cartoes[1], isFalse);
  });

  test('R11: o grifo da nota é o pai da 1ª nota (um cartão com dois grifos); sem nota, o 1º grifo', () {
    final h1 = grifoTeste(1, livro: idTeste(50), exato: 'um');
    final h2 = grifoTeste(
      2,
      livro: idTeste(50),
      inicio: 10,
      exato: 'dois',
    ).copyWith(groupId: h1.groupId);
    final n = notaTeste(3, livro: idTeste(50), pai: h2, texto: 'do 2º');
    expect(HighlightCard(h1.groupId, [h1, h2, n]).noteParent, h2);
    expect(HighlightCard(h1.groupId, [h1, h2]).noteParent, h1);
    expect(HighlightCard(h1.groupId, [n]).noteParent, isNull);
  });
}
