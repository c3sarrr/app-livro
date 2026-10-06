// G13.2 — D-32/D-136: mesma cor e estilo se unem (cruzando ou encostando; fica o mais antigo e as notas dos outros
// vão para ele); cor ou estilo diferente: o novo entra inteiro e o antigo perde o trecho coberto (o pedaço da
// esquerda mantém a identidade; sobrando só o da direita, ele mantém; sumindo, as notas vão para o novo).
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/highlight_overlap.dart';
import 'package:flutter_test/flutter_test.dart';

HighlightSpan _g(
  String id,
  int a,
  int z, {
  String cor = '#FED170',
  HighlightStyle estilo = HighlightStyle.fill,
  int dia = 1,
}) => (
  id: id,
  start: a,
  end: z,
  color: cor,
  style: estilo,
  createdAt: DateTime.utc(2026, 9, dia),
);

HighlightRequest _novo(
  int a,
  int z, {
  String cor = '#FED170',
  HighlightStyle estilo = HighlightStyle.fill,
}) => (start: a, end: z, color: cor, style: estilo);

void main() {
  test('sem nenhum: o pedido como veio, sem reaproveitar', () {
    final p = planHighlight(const [], _novo(10, 20));
    expect((p.start, p.end, p.keepId), (10, 20, null));
    expect(p.resized, isEmpty);
    expect(p.added, isEmpty);
    expect(p.removed, isEmpty);
    expect(p.notesTo, isEmpty);
  });

  test('mesma cor por dentro, cruzando e encostando: um só, do menor início ao maior fim', () {
    final dentro = planHighlight([_g('a', 0, 50)], _novo(10, 20));
    expect((dentro.start, dentro.end, dentro.keepId), (0, 50, 'a'));
    final cruza = planHighlight([_g('a', 0, 15)], _novo(10, 30));
    expect((cruza.start, cruza.end, cruza.keepId), (0, 30, 'a'));
    final encosta = planHighlight([_g('a', 0, 10)], _novo(10, 20));
    expect((encosta.start, encosta.end, encosta.keepId), (0, 20, 'a'));
    final encostaDepois = planHighlight([_g('a', 20, 30)], _novo(10, 20));
    expect(
      (encostaDepois.start, encostaDepois.end, encostaDepois.keepId),
      (10, 30, 'a'),
    );
    expect(encosta.removed, isEmpty);
    final longe = planHighlight([_g('a', 0, 9)], _novo(10, 20));
    expect((longe.start, longe.end, longe.keepId), (10, 20, null));
  });

  test('mesma cor em dois: une os três, fica o mais antigo, o outro some e as notas dele passam', () {
    final p = planHighlight([
      _g('novo', 0, 10, dia: 5),
      _g('velho', 20, 30, dia: 2),
    ], _novo(8, 22));
    expect((p.start, p.end, p.keepId), (0, 30, 'velho'));
    expect(p.removed, ['novo']);
    expect(p.notesTo, {'novo': 'velho'});
  });

  test('mesma idade: desempata pelo id', () {
    final p = planHighlight([_g('b', 0, 10), _g('a', 20, 30)], _novo(8, 22));
    expect(p.keepId, 'a');
    expect(p.removed, ['b']);
  });

  test('em cadeia: o novo encosta num que encosta noutro da mesma cor', () {
    final p = planHighlight([
      _g('a', 20, 30),
      _g('b', 30, 40, dia: 3),
    ], _novo(10, 20));
    expect((p.start, p.end, p.keepId), (10, 40, 'a'));
    expect(p.removed, ['b']);
  });

  test(
    'cor diferente no meio: o da esquerda mantém o id, o da direita é novo',
    () {
      final p = planHighlight([_g('a', 0, 100)], _novo(40, 60, cor: '#FFC1C6'));
      expect((p.start, p.end, p.keepId), (40, 60, null));
      expect(p.resized, [(id: 'a', start: 0, end: 40)]);
      expect(p.added, [(from: 'a', start: 60, end: 100)]);
      expect(p.removed, isEmpty);
    },
  );

  test(
    'cor diferente cobrindo o começo: sobra só a direita, que mantém o id',
    () {
      final p = planHighlight([_g('a', 10, 50)], _novo(0, 30, cor: '#ABCF82'));
      expect(p.resized, [(id: 'a', start: 30, end: 50)]);
      expect(p.added, isEmpty);
    },
  );

  test('cor diferente cobrindo o fim: sobra a esquerda', () {
    final p = planHighlight([_g('a', 10, 50)], _novo(30, 60, cor: '#ABCF82'));
    expect(p.resized, [(id: 'a', start: 10, end: 30)]);
    expect(p.added, isEmpty);
  });

  test(
    'cor diferente cobrindo tudo: o antigo some e as notas vão para o novo',
    () {
      final p = planHighlight([_g('a', 10, 20)], _novo(0, 30, cor: '#B6ACE4'));
      expect(p.removed, ['a']);
      expect(p.notesTo, {'a': null});
      expect(p.resized, isEmpty);
    },
  );

  test('cor diferente coberta junto com a união da mesma cor: as notas vão para o que fica', () {
    final p = planHighlight([
      _g('a', 0, 15),
      _g('x', 12, 20, cor: '#FFC1C6'),
    ], _novo(10, 30));
    expect((p.start, p.end, p.keepId), (0, 30, 'a'));
    expect(p.removed, ['x']);
    expect(p.notesTo, {'x': 'a'});
  });

  test('cor diferente só encostando: nada muda', () {
    final p = planHighlight([_g('a', 0, 10)], _novo(10, 20, cor: '#FFC1C6'));
    expect(p.resized, isEmpty);
    expect(p.added, isEmpty);
    expect(p.removed, isEmpty);
  });

  test(
    'mesma cor e outro estilo conta como diferente (sublinhado sobre fundo)',
    () {
      final p = planHighlight([
        _g('a', 0, 100),
      ], _novo(40, 60, estilo: HighlightStyle.underline));
      expect(p.keepId, isNull);
      expect(p.resized, [(id: 'a', start: 0, end: 40)]);
      expect(p.added, [(from: 'a', start: 60, end: 100)]);
    },
  );
}
