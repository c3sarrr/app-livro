// G16.4 — o que o Concluir grava (as linhas prontas: camada e anotação de cada desenho, as camadas apagadas e os
// grifos apagados) e o rascunho em JSON no `kv` (§4): ida e volta igual; versão desconhecida ou JSON quebrado não
// derrubam a abertura (`null`).
import 'dart:convert';

import 'package:app_leitura/features/reader/annotations/ink/drawing_anchor.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_changes.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:flutter_test/flutter_test.dart';

final _range = EpubAnchor(
  sha: 'b' * 64,
  spine: 4,
  start: 1200,
  end: 1217,
  quote: const TextQuote(
    prefix: 'que eles foram e me fizeram. ',
    exact: 'Olhos de ressaca?',
    suffix: ' Vá, de ressaca.',
  ),
  refPage: 159,
);

DrawingRow _row({String layer = '11111111-1111-4111-8111-111111111111'}) =>
    DrawingRow(
      layerId: layer,
      annotationId: '22222222-2222-4222-8222-222222222222',
      createdAt: DateTime.utc(2026, 10, 8, 9, 30),
      anchor: inkLayerAnchor(_range, 8.2213),
      range: _range,
      refPage: 159,
      chapterIndex: 31,
      groupId: '22222222-2222-4222-8222-222222222222',
      color: '#FF552E',
      strokesB64: 'Qk5LMQEA',
      strokeCount: 2,
    );

final _changes = InkChanges(
  layers: [
    _row(),
    _row(layer: '33333333-3333-4333-8333-333333333333'),
  ],
  deletedLayers: const {'44444444-4444-4444-8444-444444444444'},
  erasedHighlights: const {'55555555-5555-4555-8555-555555555555'},
);

void main() {
  final at = DateTime.utc(2026, 10, 8, 9, 31, 5);

  test('a chave do rascunho: ink_draft:<dono>:<livro>', () {
    expect(draftKey('dona', 'livro-7'), 'ink_draft:dona:livro-7');
    expect(draftKey('dona', 'livro-7', 's1'), 'ink_draft:dona:livro-7:s1');
  });

  test('vazio', () {
    expect(const InkChanges().isEmpty, isTrue);
    expect(_changes.isEmpty, isFalse);
    expect(const InkChanges(erasedHighlights: {'x'}).isEmpty, isFalse);
    expect(const InkChanges(deletedLayers: {'x'}).isEmpty, isFalse);
  });

  test('o rascunho de ida e volta é igual', () {
    final json = encodeDraft(_changes, at: at);
    expect(jsonDecode(json), containsPair('v', 1));
    final back = decodeDraft(json)!;
    expect(back.at, at);
    expect(back.changes, _changes);
    expect(back.changes.layers.first.anchor.toJson()['ink'], {'w': 8.2213});
    final empty = decodeDraft(encodeDraft(const InkChanges(), at: at))!;
    expect(empty.changes.isEmpty, isTrue);
  });

  test('a hora de criação fica em UTC', () {
    final local = DrawingRow(
      layerId: 'a',
      annotationId: 'b',
      createdAt: DateTime.utc(2026, 10, 8, 12).toLocal(),
      anchor: _range,
      range: _range,
      refPage: 1,
      chapterIndex: 0,
      groupId: 'b',
      color: '#000000',
      strokesB64: '',
      strokeCount: 0,
    );
    expect(local.createdAt.isUtc, isTrue);
    expect(local.createdAt, DateTime.utc(2026, 10, 8, 12));
  });

  test('versão desconhecida, JSON quebrado ou campos errados: null (não derruba a abertura)', () {
    final json = encodeDraft(_changes, at: at);
    final map = jsonDecode(json) as Map<String, dynamic>;
    expect(decodeDraft(jsonEncode({...map, 'v': 2})), isNull);
    expect(decodeDraft(json.substring(0, json.length ~/ 2)), isNull);
    expect(decodeDraft(''), isNull);
    expect(decodeDraft('[]'), isNull);
    expect(decodeDraft(jsonEncode({...map, 'at': 'ontem'})), isNull);
    expect(decodeDraft(jsonEncode({...map, 'deletedLayers': 'x'})), isNull);
    final layer = (map['layers'] as List).first as Map<String, dynamic>;
    for (final broken in [
      {...layer, 'refPage': '159'},
      {
        ...layer,
        'range': {'page': 1},
      },
      {...layer, 'anchor': 'âncora'},
      ({...layer}..remove('strokesB64')),
    ]) {
      expect(
        decodeDraft(
          jsonEncode({
            ...map,
            'layers': [broken],
          }),
        ),
        isNull,
        reason: '$broken',
      );
    }
  });
}
