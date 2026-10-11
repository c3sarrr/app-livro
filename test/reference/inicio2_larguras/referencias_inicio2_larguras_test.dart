// T03 — as referências Dart da prancha 01 a 360 e 430 px batem com as medições em JSON
// (docs/design/medicao/inicio2_larguras/layout/) e têm os mesmos ids e seções da 01 a 390. Se falhar, rode de novo
// `tools/medicao/rodar_larguras.sh` (nunca edite à mão).
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import '../inicio2/referencias_inicio2.dart' show kRef01;
import 'referencias_inicio2_larguras.dart';

const _layout = 'docs/design/medicao/inicio2_larguras/layout';

Map<String, dynamic> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Rect _rect(List<dynamic> a) => Rect.fromLTWH(
  (a[0] as num).toDouble(),
  (a[1] as num).toDouble(),
  (a[2] as num).toDouble(),
  (a[3] as num).toDouble(),
);

List<String> _jsonTexts(dynamic ls) => ls == null
    ? const <String>[]
    : (ls as List<dynamic>)
          .map((l) => (l as Map<String, dynamic>)['text'] as String)
          .toList();

void main() {
  test('as duas larguras da 01, na ordem do índice', () {
    expect(kRefInicio2Larguras.keys.toList(), ['01w360', '01w430']);
  });

  for (final (tela, largura) in [('01w360', 360.0), ('01w430', 430.0)]) {
    final ref = kRefInicio2Larguras[tela]!;
    test('$tela (${ref.slug}) = layout_${ref.slug}.json, com os ids da 01', () {
      expect(ref.canvas, Size(largura, kRef01.canvas.height));
      expect(ref.prefix, kRef01.prefix);
      expect(ref.sections.keys.toList(), kRef01.sections.keys.toList());
      expect(ref.elements.keys.toList(), kRef01.elements.keys.toList());
      for (final MapEntry(key: id, value: e) in ref.elements.entries) {
        expect(e.section, kRef01.elements[id]!.section, reason: id);
        expect(e.kind, kRef01.elements[id]!.kind, reason: id);
      }

      final lay = _json('$_layout/layout_${ref.slug}.json');
      final secoes = lay['sections'] as Map<String, dynamic>;
      secoes.forEach((k, v) => expect(ref.sections[k], _rect(v as List)));
      final elems = (lay['elements'] as Map<String, dynamic>).entries.where(
        (e) => (e.value as Map<String, dynamic>).containsKey('section'),
      );
      expect(ref.elements.keys.toList(), [for (final e in elems) e.key]);
      for (final e in elems) {
        final v = e.value as Map<String, dynamic>;
        final r = ref.elements[e.key]!;
        expect(r.rect, _rect(v['abs'] as List), reason: e.key);
        expect(
          r.visual,
          v['vis'] == null ? null : _rect(v['vis'] as List),
          reason: e.key,
        );
        expect(
          r.lines.map((l) => l.text).toList(),
          _jsonTexts(v['lines']),
          reason: e.key,
        );
        expect(
          r.linesAll.map((l) => l.text).toList(),
          _jsonTexts(v['linesAll']),
          reason: e.key,
        );
      }
      // a largura muda o conteúdo, não a moldura: a barra fica 16 de cada lado e 30 acima do fundo
      expect(
        ref.elements['i01.nav']!.rect,
        Rect.fromLTWH(16, 2550, largura - 32, 70),
      );
    });
  }

  // D-280 (T13.7): os fios de navalha, medidos no navegador, batem com o JSON. A frase da meta tem text-wrap: pretty
  // (o navegador escolhe as quebras olhando o parágrafo) e a 360 px fica quase num empate: estreitar a 1ª linha
  // 0,08 px (ou a 2ª 0,33) já leva o "para" para a 1ª linha, e alargar a 2ª 0,08 px muda a escolha. A estimativa da
  // G01 (cada linha contra a largura da caixa, com 57 e 23 px de folga) não via nada. A 430 px, nenhum fio.
  test('D-280: os fios de navalha das duas larguras', () {
    final kni = _json('$_layout/knife_edges.json');
    for (final ref in kRefInicio2Larguras.values) {
      final facas = [
        for (final e in (kni[ref.slug] as Map<String, dynamic>).entries)
          for (final r in ((e.value as Map)['riscos'] as List).cast<Map>())
            '${e.key}|${r['linha']}|${r['texto']}|'
                '${(r['sobra'] as num?)?.toDouble() ?? double.infinity}|'
                '${(r['estouroComProxima'] as num?)?.toDouble()}',
      ];
      expect(
        ref.knifeEdges
            .map(
              (k) => '${k.id}|${k.line}|${k.text}|${k.slack}|${k.joinOverflow}',
            )
            .toList(),
        facas,
        reason: ref.slug,
      );
    }
    expect(kRefInicio2Larguras['01w430']!.knifeEdges, isEmpty);
    final meta =
        (kni['001_inicio_w360'] as Map)['i01.today.goalText.sentence'] as Map;
    expect(meta['quebraPadrao'], 'pretty');
    expect((meta['linhas'] as List).map((l) => (l as Map)['texto']).toList(), [
      'Faltam 12 min',
      'para fechar a meta',
      'de hoje.',
    ]);
  });
}
