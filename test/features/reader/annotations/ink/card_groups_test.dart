// G16.2 — os cartões dos desenhos (Anexo 02 §4.3): um desenho novo entra no grupo do desenho da mesma página cuja
// linha de âncora está a até 2 linhas; mais de um, o mais perto; empate, o mais antigo; senão, o próprio id.
import 'package:app_leitura/features/reader/annotations/ink/card_groups.dart';
import 'package:flutter_test/flutter_test.dart';

final _t0 = DateTime.utc(2026, 9, 20, 10);
final _t1 = DateTime.utc(2026, 10, 8, 9);
final _t2 = DateTime.utc(2026, 10, 8, 9, 1);

void main() {
  test('a 22: o sublinhado duplo (linha 13) e a onda (linha 11) no mesmo grupo; a elipse (linha 8) no dela', () {
    final ellipse = (id: 'elipse', group: 'elipse', line: 7, createdAt: _t0);
    // o duplo é feito primeiro (Reta): a elipse fica a 5 linhas
    final duplo = cardGroup(id: 'duplo', line: 12, others: [ellipse]);
    expect(duplo, 'duplo');
    // a onda: a elipse a 3 linhas não conta; o duplo a 2 conta
    final onda = cardGroup(
      id: 'onda',
      line: 10,
      others: [ellipse, (id: 'duplo', group: duplo, line: 12, createdAt: _t1)],
    );
    expect(onda, 'duplo');
  });

  test('mais de um a até 2 linhas: o mais perto', () {
    expect(
      cardGroup(
        id: 'novo',
        line: 10,
        others: [
          (id: 'a', group: 'ga', line: 12, createdAt: _t0),
          (id: 'b', group: 'gb', line: 9, createdAt: _t2),
        ],
      ),
      'gb',
    );
  });

  test(
    'empate de distância: o mais antigo (e no mesmo instante, o menor id)',
    () {
      expect(
        cardGroup(
          id: 'novo',
          line: 10,
          others: [
            (id: 'a', group: 'ga', line: 12, createdAt: _t2),
            (id: 'b', group: 'gb', line: 8, createdAt: _t1),
          ],
        ),
        'gb',
      );
      expect(
        cardGroup(
          id: 'novo',
          line: 10,
          others: [
            (id: 'b', group: 'gb', line: 12, createdAt: _t1),
            (id: 'a', group: 'ga', line: 8, createdAt: _t1),
          ],
        ),
        'ga',
      );
    },
  );

  test(
    'a 3 linhas ou mais: o próprio id; a lista não conta o próprio desenho',
    () {
      expect(
        cardGroup(
          id: 'novo',
          line: 10,
          others: [(id: 'a', group: 'ga', line: 13, createdAt: _t0)],
        ),
        'novo',
      );
      expect(
        cardGroup(
          id: 'novo',
          line: 10,
          others: [(id: 'novo', group: 'outro', line: 10, createdAt: _t0)],
        ),
        'novo',
      );
      expect(cardGroup(id: 'novo', line: 0, others: const []), 'novo');
    },
  );
}
