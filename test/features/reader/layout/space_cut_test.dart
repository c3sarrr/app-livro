// G18.1 — o corte de espaço no fluxo de um item (Anexo 03 §7.2, D-181): os cortes de um bloco e a assinatura do
// cache das páginas.
import 'package:app_leitura/features/reader/layout/space_cut.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const a = SpaceCut(at: 10, height: 206, id: 'a');
  const b = SpaceCut(at: 40, height: 55.26, id: 'b');
  const c = SpaceCut(at: 0, height: 206, id: 'c');
  const d = SpaceCut(at: 41, height: 206, id: 'd');

  test('os cortes do bloco: depois do começo até o fim inclusive, na posição dentro dele, em ordem', () {
    expect(cutsIn([b, d, c, a], start: 0, length: 40), [
      (at: 10, height: 206.0, id: 'a'),
      (at: 40, height: 55.26, id: 'b'),
    ]);
    expect(cutsIn([a, b], start: 10, length: 30), [
      (at: 30, height: 55.26, id: 'b'),
    ]);
    expect(cutsIn(const [], start: 0, length: 40), isEmpty);
  });

  test('assinatura: vazia sem cortes; muda com a âncora e com a altura (2 casas); não com a ordem', () {
    expect(spaceSignature(const []), '');
    expect(spaceSignature([b, a]), '10:206.00,40:55.26');
    expect(spaceSignature([a, b]), spaceSignature([b, a]));
    expect(
      spaceSignature(const [SpaceCut(at: 11, height: 206, id: 'a')]),
      isNot(spaceSignature(const [a])),
    );
    expect(
      spaceSignature(const [SpaceCut(at: 10, height: 206.5, id: 'a')]),
      isNot(spaceSignature(const [a])),
    );
    // o id não muda o layout
    expect(
      spaceSignature(const [SpaceCut(at: 10, height: 206, id: 'z')]),
      spaceSignature(const [a]),
    );
  });

  test('igualdade por valor', () {
    expect(const SpaceCut(at: 10, height: 206, id: 'a'), a);
    expect(a == b, isFalse);
    expect(a.hashCode, const SpaceCut(at: 10, height: 206, id: 'a').hashCode);
    expect(a.toString(), 'SpaceCut(10, 206.0, a)');
  });
}
