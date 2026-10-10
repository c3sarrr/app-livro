// T02 — as referências Dart da Início e da revisão batem com as medições em JSON (docs/design/medicao/inicio2/layout/).
// Se este teste falhar, rode de novo `CONJUNTO=inicio2 python3 tools/medicao/gen_reference_dart.py` (nunca edite à mão).
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'referencias_inicio2.dart';

const _layout = 'docs/design/medicao/inicio2/layout';

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
  const telas = ['01', '01b', '60', '61', '62', '63'];

  test(
    'há uma referência para cada uma das 6 pranchas, na ordem do índice',
    () {
      expect(kRefInicio2.keys.toList(), telas);
    },
  );

  for (final tela in telas) {
    final ref = kRefInicio2[tela]!;
    test('prancha $tela (${ref.slug}) = layout_${ref.slug}.json', () {
      final lay = _json('$_layout/layout_${ref.slug}.json');
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
          .where(
            (e) => (e.value as Map<String, dynamic>).containsKey('section'),
          )
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
    final dep = _json('$_layout/text_dependency.json');
    final kni = _json('$_layout/knife_edges.json');
    for (final ref in kRefInicio2.values) {
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

  // A 60 é a 01 com `transform: translateY(-930px)` no <main>: o retângulo de LAYOUT (medido sem transform) é o
  // mesmo da 01; o visual sobe 930. A barra e o degradê ficam presos ao fundo do quadro (844 em vez de 2650).
  test('a 60 é a 01 com o <main> rolado 930 px', () {
    expect(kRef60.elements.length, kRef01.elements.length);
    const presosAoFundo = {'i01.nav', 'i01.bottomFade'};
    for (final e in kRef01.elements.entries) {
      final id60 = 'i60${e.key.substring('i01'.length)}';
      final r60 = kRef60.elements[id60];
      expect(r60, isNotNull, reason: id60);
      expect(r60!.rect.width, closeTo(e.value.rect.width, 1e-9), reason: id60);
      expect(r60.rect.height, closeTo(e.value.rect.height, 1e-9), reason: id60);
      expect(r60.rect.left, e.value.rect.left, reason: id60);
      if (presosAoFundo.contains(e.value.section)) {
        expect(
          r60.rect.top,
          closeTo(e.value.rect.top - (2650 - 844), 1e-6),
          reason: id60,
        );
      } else {
        final v01 = e.value.visual ?? e.value.rect;
        expect(r60.rect.top, e.value.rect.top, reason: id60);
        // os JSON guardam 2 casas: o topo visual da 60 é arredondado à parte (−660,96 × 269,05 − 930)
        expect(r60.visual, isNotNull, reason: id60);
        expect(r60.visual!.top, closeTo(v01.top - 930, 0.011), reason: id60);
        expect(r60.visual!.width, closeTo(v01.width, 1e-9), reason: id60);
        expect(r60.visual!.height, closeTo(v01.height, 1e-9), reason: id60);
      }
    }
  });

  // A 01b é a mesma página cortada em 844 (o PNG mostra só a tela). O que passa de 844 tem como referência visual o PNG
  // da 01: os elementos são os mesmos — mesma caixa e mesmo texto —, no mesmo lugar (o "Seu dia", acima do cartão da
  // revisão que a 01b não tem) ou 205,15 acima (tudo depois dele). As exceções são os dois livros que a 01b troca no
  // "Para você" (D-241: a divergência fica listada, uma a uma): Quincas Borba e O Cortiço no lugar de Memorial de Aires
  // e Casa de Pensão — o título de uma linha da capa do O Cortiço recentraliza o bloco (−181,75).
  test('a 01b abaixo de 844 é a 01 sem o cartão da revisão, salvo os dois livros trocados', () {
    const trocados = {
      'i01b.forYou.item2.cover.title': ['Quincas', 'Borba'],
      'i01b.forYou.item2.title': ['Quincas Borba'],
      'i01b.forYou.item3.cover.textBlock': <String>[],
      'i01b.forYou.item3.cover.title': ['O Cortiço'],
      'i01b.forYou.item3.title': ['O Cortiço'],
    };
    final abaixo = kRef01b.elements.entries.where(
      (e) => (e.value.visual ?? e.value.rect).bottom > 844,
    );
    expect(abaixo.length, 168);
    var iguais = 0;
    for (final e in abaixo) {
      final r01 = kRef01.elements['i01${e.key.substring('i01b'.length)}'];
      expect(r01, isNotNull, reason: e.key);
      final dy = e.value.rect.top - r01!.rect.top;
      if (trocados.containsKey(e.key)) {
        expect(_texts(e.value.lines), trocados[e.key], reason: e.key);
        if (e.value.lines.isEmpty) {
          // o bloco do título da capa: uma linha em vez de duas (37,21 × 60,61)
          expect(
            e.value.rect.height,
            isNot(closeTo(r01.rect.height, 1)),
            reason: e.key,
          );
        } else {
          expect(
            _texts(e.value.lines),
            isNot(_texts(r01.lines)),
            reason: e.key,
          );
        }
        continue;
      }
      expect(
        dy.abs() < 1e-9 || (dy + 205.15).abs() < 1e-6,
        isTrue,
        reason: '${e.key}: Δy $dy',
      );
      expect(e.value.rect.left, r01.rect.left, reason: e.key);
      expect(e.value.rect.width, closeTo(r01.rect.width, 1e-9), reason: e.key);
      expect(
        e.value.rect.height,
        closeTo(r01.rect.height, 1e-9),
        reason: e.key,
      );
      expect(_texts(e.value.lines), _texts(r01.lines), reason: e.key);
      expect(_texts(e.value.linesAll), _texts(r01.linesAll), reason: e.key);
      for (final (a, b) in [
        for (var i = 0; i < e.value.lines.length; i++)
          (e.value.lines[i], r01.lines[i]),
      ]) {
        expect(a.left, closeTo(b.left, 1e-9), reason: e.key);
        expect(a.right, closeTo(b.right, 1e-9), reason: e.key);
        expect(a.baseline, closeTo(b.baseline + dy, 1e-6), reason: e.key);
      }
      iguais++;
    }
    expect(iguais, 163);
  });

  test('os dois fios de navalha da 62 são os da nota nova', () {
    expect(kRef62.knifeEdges.map((k) => k.id).toList(), [
      'rv62.summary.newNote.quote',
      'rv62.summary.newNote.note.text',
    ]);
  });
}
