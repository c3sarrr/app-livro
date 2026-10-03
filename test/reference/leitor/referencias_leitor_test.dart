// G01.6 — as referências Dart do leitor batem com as medições em JSON (handoff_v2/referencia/layout/).
// Se este teste falhar, rode de novo `python3 tools/medicao/gen_reference_dart.py` (nunca edite à mão).
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'referencias_leitor.dart';

Map<String, dynamic> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Rect _rect(List<dynamic> a) => Rect.fromLTWH(
  (a[0] as num).toDouble(),
  (a[1] as num).toDouble(),
  (a[2] as num).toDouble(),
  (a[3] as num).toDouble(),
);

List<String> _texts(List<LeitorRefLine> ls) => ls.map((l) => l.text).toList();

List<String> _jsonTexts(dynamic ls) => ls == null
    ? const <String>[]
    : (ls as List<dynamic>)
          .map((l) => (l as Map<String, dynamic>)['text'] as String)
          .toList();

void main() {
  const telas = [
    '19',
    '20',
    '21',
    '22',
    '23',
    '23b',
    '24',
    '24b',
    '25',
    '26',
    '26b',
    '27',
    '27b',
  ];

  test('há uma referência para cada uma das 13 pranchas, na ordem do arquivo', () {
    expect(kRefLeitor.keys.toList(), telas);
  });

  for (final tela in telas) {
    final ref = kRefLeitor[tela]!;
    test('prancha $tela (${ref.slug}) = layout_${ref.slug}.json', () {
      final lay = _json(
        'handoff_v2/referencia/layout/layout_${ref.slug}.json',
      );
      final meta = lay['meta'] as Map<String, dynamic>;
      final canvas = meta['canvas'] as List<dynamic>;
      expect(
        ref.canvas,
        Size((canvas[0] as num).toDouble(), (canvas[1] as num).toDouble()),
      );
      expect(ref.prefix, meta['prefixo']);

      final secoes = lay['sections'] as Map<String, dynamic>;
      expect(ref.sections.keys.toList(), secoes.keys.toList());
      secoes.forEach((k, v) => expect(ref.sections[k], _rect(v as List)));

      final elems = (lay['elements'] as Map<String, dynamic>).entries
          .where((e) => (e.value as Map<String, dynamic>).containsKey('section'))
          .toList();
      expect(ref.elements.keys.toList(), elems.map((e) => e.key).toList());
      for (final e in elems) {
        final v = e.value as Map<String, dynamic>;
        final r = ref.elements[e.key]!;
        expect(r.section, v['section'], reason: e.key);
        expect(r.rect, _rect(v['abs'] as List), reason: e.key);
        expect(
          r.visual,
          v['vis'] == null ? null : _rect(v['vis'] as List),
          reason: e.key,
        );
        expect(_texts(r.lines), _jsonTexts(v['lines']), reason: e.key);
        expect(_texts(r.linesAll), _jsonTexts(v['linesAll']), reason: e.key);
        expect(e.key.startsWith('${ref.prefix}.'), isTrue, reason: e.key);
        expect(ref.sections.containsKey(r.section), isTrue, reason: e.key);
      }
    });
  }

  test('dependência de texto e fios de navalha batem com os JSON', () {
    final dep = _json('handoff_v2/referencia/layout/text_dependency.json');
    final kni = _json('handoff_v2/referencia/layout/knife_edges.json');
    for (final ref in kRefLeitor.values) {
      final d = dep[ref.slug] as Map<String, dynamic>;
      final x = d.entries
          .where((e) {
            final f = e.value as Map<String, dynamic>;
            return (f['x'] == true || f['w'] == true) &&
                ref.elements.containsKey(e.key);
          })
          .map((e) => e.key)
          .toSet();
      expect(ref.textDependentX, x, reason: ref.slug);
      final k = kni[ref.slug] as Map<String, dynamic>;
      final riscos = k.values
          .map((v) => ((v as Map<String, dynamic>)['riscos'] as List).length)
          .fold<int>(0, (a, b) => a + b);
      expect(ref.knifeEdges.length, riscos, reason: ref.slug);
    }
  });

  test('a linha 7 da página do leitor é fio de navalha (estouro 0,711 px)', () {
    final k = kRef19.knifeEdges.firstWhere((k) => k.line == 7);
    expect(k.text, 'que eles foram e me fizeram.');
    expect(k.joinOverflow, closeTo(0.711, 1e-9));
  });
}
