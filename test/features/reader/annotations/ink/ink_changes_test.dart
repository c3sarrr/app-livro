// G16.4 — o que o Concluir grava (as linhas prontas: camada e anotação de cada desenho, as camadas apagadas e os
// grifos apagados) e o rascunho em JSON no `kv` (§4): ida e volta igual; versão desconhecida ou JSON quebrado não
// derrubam a abertura (`null`). G17 (R24): os grifos do marca-texto (novos, movidos e tirados com o destino das
// notas) no formato 2, que ainda lê o rascunho do formato 1 da G16.
import 'dart:convert';

import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
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

final _range2 = EpubAnchor(
  sha: 'b' * 64,
  spine: 4,
  start: 1221,
  end: 1228,
  quote: const TextQuote(exact: 'ressaca'),
  refPage: 159,
);

HighlightRow _grifo({
  String id = '66666666-6666-4666-8666-666666666666',
  AnnotationSource source = AnnotationSource.ink,
  HighlightStyle style = HighlightStyle.fill,
  FillHeight? height = FillHeight.low,
}) => HighlightRow(
  id: id,
  createdAt: DateTime.utc(2026, 10, 8, 9, 30),
  range: _range,
  refPage: 159,
  chapterIndex: 31,
  groupId: '77777777-7777-4777-8777-777777777777',
  color: '#FFC1C6',
  style: style,
  fillHeight: height,
  source: source,
);

final _marca = InkChanges(
  highlights: [
    _grifo(),
    _grifo(
      id: '88888888-8888-4888-8888-888888888888',
      source: AnnotationSource.selection,
      style: HighlightStyle.wavy,
      height: null,
    ),
  ],
  moved: [
    MovedHighlight(
      id: '99999999-9999-4999-8999-999999999999',
      range: _range2,
      refPage: 160,
      chapterIndex: 32,
    ),
  ],
  removed: const {
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa':
        '66666666-6666-4666-8666-666666666666',
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb': null,
  },
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
    expect(InkChanges(highlights: [_grifo()]).isEmpty, isFalse);
    expect(
      InkChanges(
        moved: [
          MovedHighlight(id: 'x', range: _range, refPage: 1, chapterIndex: 0),
        ],
      ).isEmpty,
      isFalse,
    );
    expect(const InkChanges(removed: {'x': null}).isEmpty, isFalse);
  });

  test('G17 (R24): os grifos de ida e volta no formato 2', () {
    final json = encodeDraft(_marca, at: at);
    expect(jsonDecode(json), containsPair('v', 2));
    final back = decodeDraft(json)!;
    expect(back.changes, _marca);
    expect(back.changes.highlights[1].fillHeight, isNull);
    expect(
      back.changes.removed,
      containsPair('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', null),
    );
    final tudo = InkChanges(
      layers: _changes.layers,
      deletedLayers: _changes.deletedLayers,
      erasedHighlights: _changes.erasedHighlights,
      highlights: _marca.highlights,
      moved: _marca.moved,
      removed: _marca.removed,
    );
    expect(decodeDraft(encodeDraft(tudo, at: at))!.changes, tudo);
  });

  test('G17: o rascunho do formato 1 (G16) ainda é lido, sem grifos; o formato 3 não', () {
    final v1 = jsonEncode({
      'v': 1,
      'at': '2026-10-08T09:31:05.000Z',
      'layers': [_row().toJson()],
      'deletedLayers': ['44444444-4444-4444-8444-444444444444'],
      'erasedHighlights': ['55555555-5555-4555-8555-555555555555'],
    });
    final back = decodeDraft(v1)!;
    expect(back.at, at);
    expect(
      back.changes,
      InkChanges(
        layers: [_row()],
        deletedLayers: const {'44444444-4444-4444-8444-444444444444'},
        erasedHighlights: const {'55555555-5555-4555-8555-555555555555'},
      ),
    );
    final map = jsonDecode(encodeDraft(_marca, at: at)) as Map<String, dynamic>;
    expect(decodeDraft(jsonEncode({...map, 'v': 3})), isNull);
    // o formato 2 sem as listas dos grifos, ou com elas erradas: ilegível
    expect(decodeDraft(jsonEncode({...map}..remove('highlights'))), isNull);
    expect(
      decodeDraft(
        jsonEncode({
          ...map,
          'removed': ['x'],
        }),
      ),
      isNull,
    );
    expect(
      decodeDraft(
        jsonEncode({
          ...map,
          'removed': {'x': 7},
        }),
      ),
      isNull,
    );
    expect(decodeDraft(jsonEncode({...map, 'moved': 'x'})), isNull);
    final grifo = (map['highlights'] as List).first as Map<String, dynamic>;
    final movido = (map['moved'] as List).first as Map<String, dynamic>;
    for (final (chave, quebrado) in [
      ('highlights', {...grifo, 'style': 'pontilhado'}),
      ('highlights', {...grifo, 'fillHeight': 'altíssima'}),
      ('highlights', {...grifo, 'source': 'voz'}),
      ('highlights', {...grifo, 'refPage': '159'}),
      ('highlights', {...grifo, 'createdAt': 'ontem'}),
      (
        'highlights',
        {
          ...grifo,
          'range': {'page': 1},
        },
      ),
      ('highlights', ({...grifo}..remove('color'))),
      ('moved', {...movido, 'chapterIndex': null}),
      ('moved', {...movido, 'range': 'âncora'}),
    ]) {
      expect(
        decodeDraft(
          jsonEncode({
            ...map,
            chave: [quebrado],
          }),
        ),
        isNull,
        reason: '$chave $quebrado',
      );
    }
  });

  test('G17: as linhas dos grifos são valores', () {
    expect(_grifo(), _grifo());
    expect(_grifo().hashCode, _grifo().hashCode);
    expect(_grifo(), isNot(_grifo(height: FillHeight.high)));
    expect(_grifo(), isNot(_grifo(source: AnnotationSource.selection)));
    final m = MovedHighlight(
      id: 'x',
      range: _range,
      refPage: 1,
      chapterIndex: 0,
    );
    expect(
      m,
      MovedHighlight(id: 'x', range: _range, refPage: 1, chapterIndex: 0),
    );
    expect(
      m,
      isNot(
        MovedHighlight(id: 'x', range: _range2, refPage: 1, chapterIndex: 0),
      ),
    );
    expect(
      m.hashCode,
      MovedHighlight(
        id: 'x',
        range: _range,
        refPage: 1,
        chapterIndex: 0,
      ).hashCode,
    );
    expect(_marca, isNot(InkChanges(highlights: _marca.highlights)));
    expect(
      const InkChanges(removed: {'a': 'b'}),
      isNot(const InkChanges(removed: {'a': null})),
    );
    expect(
      const InkChanges(removed: {'a': 'b', 'c': null}).hashCode,
      const InkChanges(removed: {'c': null, 'a': 'b'}).hashCode,
    );
  });

  test('o rascunho de ida e volta é igual', () {
    final json = encodeDraft(_changes, at: at);
    expect(jsonDecode(json), containsPair('v', 2));
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
    expect(decodeDraft(jsonEncode({...map, 'v': 0})), isNull);
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

  test('as linhas e as mudanças são valores: iguais pelo conteúdo e com o mesmo hash', () {
    expect(_row(), _row());
    expect(_row().hashCode, _row().hashCode);
    expect(_row(), isNot(_row(layer: 'outra')));
    final iguais = InkChanges(
      layers: [
        _row(),
        _row(layer: '33333333-3333-4333-8333-333333333333'),
      ],
      deletedLayers: const {'44444444-4444-4444-8444-444444444444'},
      erasedHighlights: const {'55555555-5555-4555-8555-555555555555'},
    );
    expect(iguais, _changes);
    expect(iguais.hashCode, _changes.hashCode);
    expect(
      const InkChanges(deletedLayers: {'a', 'b'}).hashCode,
      const InkChanges(deletedLayers: {'b', 'a'}).hashCode,
    );
    expect(_changes, isNot(const InkChanges()));
  });
}
