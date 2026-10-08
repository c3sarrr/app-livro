// G17.4 (D-173, R23) — a mesa de grifos da sessão: o trecho do marca-texto passa pela D-32 com os grifos de seleção e
// os à mão do mesmo item; unidos ficam com o jeito do mais antigo; os pedaços cortados mantêm cor, estilo, altura,
// grupo e origem; os tirados deixam o destino das notas (em cadeia); a Borracha só tira os à mão; as contagens.
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/ink/highlight_desk.dart';
import 'package:flutter_test/flutter_test.dart';

final _antes = DateTime.utc(2026, 9, 1);
final _agora = DateTime.utc(2026, 10, 8, 10);

DeskHighlight _grifo(
  String id,
  int start,
  int end, {
  String cor = '#FED170',
  HighlightStyle estilo = HighlightStyle.fill,
  bool mao = false,
  int unit = 4,
}) => DeskHighlight(
  id: id,
  unit: unit,
  start: start,
  end: end,
  color: cor,
  style: estilo,
  height: estilo == HighlightStyle.fill ? FillHeight.medium : null,
  ink: mao,
  groupId: 'g-$id',
  createdAt: _antes,
);

void main() {
  var seq = 0;
  String novo() => 'novo-${++seq}';
  setUp(() => seq = 0);

  HighlightDesk marca(
    HighlightDesk d,
    int from,
    int to, {
    String cor = '#FED170',
    HighlightStyle estilo = HighlightStyle.fill,
    FillHeight altura = FillHeight.high,
  }) => d.mark(
    (unit: 4, from: from, to: to),
    color: cor,
    style: estilo,
    height: altura,
    id: 'traco',
    groupId: 'grupo-traco',
    at: _agora,
    newId: novo,
  );

  test('sem nada embaixo: um grifo novo à mão, com a cor, o estilo, a altura e o grupo do traço', () {
    final d = marca(HighlightDesk.empty, 10, 20);
    expect(
      d.items.single,
      DeskHighlight(
        id: 'traco',
        unit: 4,
        start: 10,
        end: 20,
        color: '#FED170',
        style: HighlightStyle.fill,
        height: FillHeight.high,
        ink: true,
        groupId: 'grupo-traco',
        createdAt: _agora,
      ),
    );
    // no sublinhado, sem altura
    expect(
      marca(
        HighlightDesk.empty,
        1,
        3,
        estilo: HighlightStyle.underline,
      ).items.single.height,
      isNull,
    );
  });

  test('mesma cor e estilo sobre um de seleção: viram um, com o id e o jeito do mais antigo (D-173)', () {
    final d = marca(HighlightDesk([_grifo('sel', 10, 20)]), 15, 30);
    expect(d.items, [_grifo('sel', 10, 30)]);
    expect(d.removed, isEmpty);
  });

  test('outra cor sobre um à mão: o novo inteiro; o antigo cortado em 2, o da direita novo com a origem dele', () {
    final d = marca(
      HighlightDesk([_grifo('mao', 10, 40, mao: true)]),
      20,
      30,
      cor: '#FFC1C6',
    );
    expect(d.items, hasLength(3));
    expect(d.byId('mao'), _grifo('mao', 10, 20, mao: true));
    expect(d.byId('traco')!.color, '#FFC1C6');
    final direita = d.byId('novo-1')!;
    expect(
      (
        direita.start,
        direita.end,
        direita.color,
        direita.ink,
        direita.groupId,
        direita.height,
      ),
      (30, 40, '#FED170', true, 'g-mao', FillHeight.medium),
    );
  });

  test('cobrindo todo um grifo de outra cor: ele sai e as notas vão para o novo; em cadeia, para o último', () {
    var d = marca(
      HighlightDesk([_grifo('sel', 12, 18)]),
      10,
      20,
      cor: '#ABCF82',
    );
    expect(d.byId('sel'), isNull);
    expect(d.removed, {'sel': 'traco'});
    // o "traco" agora é coberto por um rosa: as notas do "sel" seguem até o rosa
    d = d.mark(
      (unit: 4, from: 5, to: 25),
      color: '#FFC1C6',
      style: HighlightStyle.fill,
      height: FillHeight.medium,
      id: 'traco2',
      groupId: 'g2',
      at: _agora,
      newId: novo,
    );
    expect(d.targetOf('sel'), 'traco2');
    expect(d.targetOf('traco'), 'traco2');
    expect(d.targetOf('outro'), 'outro');
  });

  test('outro item não entra na conta', () {
    final d = marca(
      HighlightDesk([_grifo('outro', 10, 20, unit: 5)]),
      10,
      20,
      cor: '#FFC1C6',
    );
    expect(d.byId('outro'), _grifo('outro', 10, 20, unit: 5));
    expect(d.items, hasLength(2));
  });

  test('a Borracha só tira os à mão (D-168); as contagens por cor', () {
    final d = HighlightDesk([
      _grifo('sel', 1, 5),
      _grifo('mao', 10, 20, mao: true),
      _grifo('rosa', 30, 40, cor: '#FFC1C6', mao: true),
    ]);
    expect(d.counts(), {'#FED170': 2, '#FFC1C6': 1});
    final e = d.erase(['sel', 'mao']);
    expect(e.items.map((h) => h.id), ['sel', 'rosa']);
    expect(e.erased, {'mao'});
    expect(e.counts(), {'#FED170': 1, '#FFC1C6': 1});
    expect(identical(e.erase(['sel']), e), isTrue);
  });

  test('igualdade por valor (o desfazer compara mesas)', () {
    expect(
      HighlightDesk([_grifo('a', 1, 2)]),
      HighlightDesk([_grifo('a', 1, 2)]),
    );
    expect(
      HighlightDesk([_grifo('a', 1, 2)]) == HighlightDesk([_grifo('a', 1, 3)]),
      isFalse,
    );
  });
}
