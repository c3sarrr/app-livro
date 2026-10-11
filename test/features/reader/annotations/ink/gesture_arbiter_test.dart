// G16.3 — o árbitro de dedos e caneta (§3, D-167 4 e 5): 1 dedo (ou a caneta) desenha; o 2º dedo até 150 ms descarta
// o traço, depois disso o termina, e a página passa a mover pelo centro dos dedos (sem salto quando um dedo sai ou
// entra; o 3º é ignorado); depois da caneta do aparelho, só ela desenha e o dedo durante o traço é palma.
import 'package:app_leitura/features/reader/annotations/ink/gesture_arbiter.dart';
import 'package:flutter_test/flutter_test.dart';

InkPointer _touch(int id, double y, int t, {double x = 100}) =>
    (id: id, kind: InkPointerKind.touch, x: x, y: y, pressure: 0.5, tMs: t);

InkPointer _pen(int id, double y, int t, {double pressure = 0.8}) => (
  id: id,
  kind: InkPointerKind.stylus,
  x: 100,
  y: y,
  pressure: pressure,
  tMs: t,
);

void main() {
  late InkGestureArbiter a;
  setUp(() => a = InkGestureArbiter());

  test('1 dedo desenha', () {
    final p = _touch(1, 100, 0);
    expect(a.down(p), [DrawStart(p)]);
    final q = _touch(1, 110, 8);
    expect(a.move(q), [DrawMove(q)]);
    expect(a.up(q), [const DrawEnd()]);
    expect(a.stylusSeen, isFalse);
    // e o próximo dedo desenha de novo
    final r = _touch(2, 300, 900);
    expect(a.down(r), [DrawStart(r)]);
  });

  test(
    '2º dedo até 150 ms do 1º: o traço é descartado e a página passa a mover',
    () {
      a.down(_touch(1, 100, 1000));
      expect(a.down(_touch(2, 200, 1150)), [
        const DrawDiscard(),
        const PanStart(),
      ]);
      expect(a.move(_touch(1, 110, 1160)), [const PanMove(5)]);
    },
  );

  test('2º dedo depois de 150 ms: o traço termina ali', () {
    a.down(_touch(1, 100, 1000));
    a.move(_touch(1, 130, 1100));
    expect(a.down(_touch(2, 200, 1151)), [const DrawEnd(), const PanStart()]);
  });

  test('a página move pelo centro dos dedos, sem salto quando um dedo sai ou entra', () {
    a.down(_touch(1, 100, 0));
    a.down(_touch(2, 200, 10)); // centro 150
    expect(a.move(_touch(1, 110, 20)), [const PanMove(5)]); // centro 155
    expect(a.move(_touch(2, 220, 30)), [const PanMove(10)]); // centro 165
    expect(
      a.move(_touch(2, 220, 31, x: 300)),
      isEmpty,
      reason: 'só na vertical',
    );
    // o 2º sai: o dedo que sobrou (110) vira a referência, sem salto
    expect(a.up(_touch(2, 220, 40)), isEmpty);
    // o dedo que sobrou continua movendo
    expect(a.move(_touch(1, 130, 50)), [const PanMove(20)]);
    // um dedo entra: o centro novo (315) vira a referência, sem salto
    expect(a.down(_touch(3, 500, 60)), isEmpty);
    expect(a.move(_touch(3, 510, 70)), [const PanMove(5)]);
    expect(a.up(_touch(1, 130, 80)), isEmpty);
    expect(a.up(_touch(3, 510, 90)), [const PanEnd()]);
    // com os dedos fora, o próximo desenha
    final p = _touch(4, 700, 200);
    expect(a.down(p), [DrawStart(p)]);
  });

  test('o 3º dedo é ignorado', () {
    a.down(_touch(1, 100, 0));
    a.down(_touch(2, 200, 10));
    expect(a.down(_touch(3, 400, 20)), isEmpty);
    expect(a.move(_touch(3, 450, 30)), isEmpty);
    expect(a.move(_touch(1, 120, 40)), [const PanMove(10)]);
    expect(a.up(_touch(3, 450, 50)), isEmpty);
    expect(a.up(_touch(1, 120, 60)), isEmpty);
    expect(a.up(_touch(2, 200, 70)), [const PanEnd()]);
  });

  test('a caneta do aparelho: depois dela, só ela desenha e 1 ou 2 dedos movem a página', () {
    final p = _pen(9, 100, 0);
    expect(a.down(p), [DrawStart(p)]);
    expect(a.stylusSeen, isTrue);
    final q = _pen(9, 140, 8, pressure: 0.3);
    expect(a.move(q), [DrawMove(q)]);
    expect(a.up(q), [const DrawEnd()]);
    // 1 dedo move
    expect(a.down(_touch(1, 300, 100)), [const PanStart()]);
    expect(a.move(_touch(1, 320, 110)), [const PanMove(20)]);
    // 2 dedos também
    expect(a.down(_touch(2, 500, 120)), isEmpty);
    expect(a.move(_touch(2, 520, 130)), [const PanMove(10)]);
    expect(a.up(_touch(1, 320, 140)), isEmpty);
    expect(a.up(_touch(2, 520, 150)), [const PanEnd()]);
    // e a caneta desenha de novo
    final r = _pen(9, 600, 300);
    expect(a.down(r), [DrawStart(r)]);
  });

  test('dedo durante o traço da caneta é palma: ignorado até sair', () {
    final p = _pen(9, 100, 0);
    a.down(p);
    expect(a.down(_touch(1, 500, 10)), isEmpty);
    expect(a.move(_touch(1, 520, 20)), isEmpty);
    final q = _pen(9, 110, 30);
    expect(a.move(q), [DrawMove(q)]);
    expect(a.up(q), [const DrawEnd()]);
    expect(a.move(_touch(1, 540, 40)), isEmpty, reason: 'até sair');
    expect(a.up(_touch(1, 540, 50)), isEmpty);
    expect(a.down(_touch(1, 300, 60)), [const PanStart()]);
  });

  test('a caneta chegando com um dedo desenhando: o traço do dedo termina e a caneta começa', () {
    a.down(_touch(1, 100, 0));
    final p = _pen(9, 300, 400);
    expect(a.down(p), [const DrawEnd(), DrawStart(p)]);
    expect(a.move(_touch(1, 130, 410)), isEmpty, reason: 'o dedo virou palma');
    expect(a.up(_touch(1, 130, 420)), isEmpty);
    final q = _pen(9, 310, 430);
    expect(a.move(q), [DrawMove(q)]);
  });

  test(
    'a caneta chegando com a página movendo: a página para e a caneta desenha',
    () {
      a.down(_touch(1, 100, 0));
      a.down(_touch(2, 200, 10));
      final p = _pen(9, 300, 400);
      expect(a.down(p), [const PanEnd(), DrawStart(p)]);
      expect(a.move(_touch(1, 150, 410)), isEmpty);
      expect(a.up(_touch(1, 150, 420)), isEmpty);
      expect(a.up(_touch(2, 200, 430)), isEmpty);
    },
  );

  test('o cancel do traço o descarta; o da página a termina', () {
    a.down(_touch(1, 100, 0));
    expect(a.cancel(_touch(1, 100, 10)), [const DrawDiscard()]);
    a.down(_touch(1, 100, 100));
    a.down(_touch(2, 200, 110));
    expect(a.cancel(_touch(1, 100, 120)), isEmpty);
    expect(a.cancel(_touch(2, 200, 130)), [const PanEnd()]);
  });

  test('a ponta de borracha da caneta (fora da G16) e o que não é dedo nem caneta: ignorados', () {
    final p = (
      id: 5,
      kind: InkPointerKind.ignored,
      x: 1.0,
      y: 2.0,
      pressure: 1.0,
      tMs: 0,
    );
    expect(a.down(p), isEmpty);
    expect(a.move(p), isEmpty);
    expect(a.up(p), isEmpty);
    expect(a.stylusSeen, isFalse);
    // ponteiro que nunca desceu
    expect(a.move(_touch(7, 1, 1)), isEmpty);
    expect(a.up(_touch(7, 1, 1)), isEmpty);
  });

  test('a janela do descarte é de 150 ms', () {
    expect(InkGestureArbiter.discardWindowMs, 150);
  });

  test(
    'uma 2ª ponta de caneta durante o traço da caneta é ignorada até sair',
    () {
      final p = _pen(1, 100, 0);
      a.down(p);
      expect(a.down(_pen(2, 300, 20)), isEmpty);
      expect(a.move(_pen(2, 320, 28)), isEmpty);
      expect(a.up(_pen(2, 320, 36)), isEmpty);
      final q = _pen(1, 120, 40);
      expect(a.move(q), [DrawMove(q)]);
    },
  );

  test('os gestos são valores: iguais pelo conteúdo, com o hash e o texto de cada um', () {
    final p = _touch(1, 100, 0);
    final pares = <(InkGesture, InkGesture, InkGesture?)>[
      (DrawStart(p), DrawStart(p), DrawStart(_touch(1, 101, 0))),
      (DrawMove(p), DrawMove(p), DrawMove(_touch(2, 100, 0))),
      (const DrawEnd(), const DrawEnd(), null),
      (const DrawDiscard(), const DrawDiscard(), null),
      (const PanStart(), const PanStart(), null),
      (const PanMove(4), const PanMove(4), const PanMove(5)),
      (const PanEnd(), const PanEnd(), null),
    ];
    for (final (x, y, outro) in pares) {
      expect(x, y);
      expect(x.hashCode, y.hashCode);
      expect('$x', '$y');
      expect('$x', isNot(contains('Instance of')));
      if (outro != null) expect(x, isNot(outro));
    }
    expect(const DrawEnd(), isNot(const PanEnd()));
  });
}
