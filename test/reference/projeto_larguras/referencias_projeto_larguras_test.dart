// T13.9 (D-272) — as referências Dart das 41 telas do projeto a 360 e 430 px batem com as medições em JSON
// (docs/design/medicao/projeto_larguras/layout/) e têm os mesmos ids e seções das telas a 390. Se falhar, rode de novo
// `CONJUNTO=projeto_larguras bash tools/medicao/rodar_larguras.sh` no WSL (nunca edite as referências à mão).
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import '../projeto/referencias_projeto.dart'
    show kRefProjeto, kInformativoProjeto;
import 'referencias_projeto_larguras.dart';

const _layout = 'docs/design/medicao/projeto_larguras/layout';

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

/// A tela a 390 de uma entrada das larguras ('30bw360' → '30b').
String _base(String tela) => tela.substring(0, tela.lastIndexOf('w'));

void main() {
  final indice =
      (_json('tools/medicao/pranchas_projeto_larguras.json')['pranchas']
              as List)
          .cast<Map<String, dynamic>>();

  test('as 41 telas a 360 e 430, na ordem do índice', () {
    expect(kRefProjetoLarguras.keys.toList(), [
      for (final t in kRefProjeto.keys) ...['${t}w360', '${t}w430'],
    ]);
    expect(
      indice.map((p) => p['tela']).toList(),
      kRefProjetoLarguras.keys.toList(),
    );
  });

  for (final p in indice) {
    final tela = p['tela'] as String;
    final largura = (p['largura'] as num).toDouble();
    test(
      '$tela (${p['slug']}) = layout JSON, com os ids da ${_base(tela)}',
      () {
        final ref = kRefProjetoLarguras[tela]!;
        final b = kRefProjeto[_base(tela)]!;
        expect(p['base'], b.slug);
        expect(ref.slug, p['slug']);
        expect(ref.canvas, Size(largura, b.canvas.height));
        expect(ref.prefix, b.prefix);
        expect(ref.sections.keys.toList(), b.sections.keys.toList());
        expect(ref.elements.keys.toList(), b.elements.keys.toList());
        for (final MapEntry(key: id, value: e) in ref.elements.entries) {
          expect(e.section, b.elements[id]!.section, reason: id);
          expect(e.kind, b.elements[id]!.kind, reason: id);
        }

        final lay = _json('$_layout/layout_${ref.slug}.json');
        expect((lay['meta'] as Map)['canvas'], [
          largura.toInt(),
          b.canvas.height.toInt(),
        ]);
        // o quadro (sem seção) tem a largura trocada e a altura da tela a 390
        expect(
          _rect((lay['elements'] as Map)['${ref.prefix}.frame']['abs'] as List),
          Rect.fromLTWH(0, 0, largura, b.canvas.height),
        );
        final secoes = lay['sections'] as Map<String, dynamic>;
        expect(secoes.keys.toList(), ref.sections.keys.toList());
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
      },
    );
  }

  test('dependência de texto e fios de navalha batem com os JSON', () {
    final dep = _json('$_layout/text_dependency.json');
    final kni = _json('$_layout/knife_edges.json');
    for (final ref in kRefProjetoLarguras.values) {
      final d = dep[ref.slug] as Map<String, dynamic>;
      bool marca(MapEntry<String, dynamic> e, String a, String b) {
        final f = e.value as Map<String, dynamic>;
        return (f[a] == true || f[b] == true) &&
            ref.elements.containsKey(e.key);
      }

      expect(
        ref.textDependentX,
        d.entries.where((e) => marca(e, 'x', 'w')).map((e) => e.key).toSet(),
        reason: ref.slug,
      );
      expect(
        ref.textDependentY,
        d.entries.where((e) => marca(e, 'y', 'h')).map((e) => e.key).toSet(),
        reason: ref.slug,
      );
      // cada fio de navalha = um risco do JSON, campo a campo e na ordem (D-280: sobra null = a linha não quebra ao
      // crescer, double.infinity no Dart)
      final k = kni[ref.slug] as Map<String, dynamic>;
      final riscos = [
        for (final e in k.entries)
          for (final r in (e.value as Map<String, dynamic>)['riscos'] as List)
            '${e.key}|${r['linha']}|${r['texto']}|'
                '${(r['sobra'] as num?)?.toDouble() ?? double.infinity}|'
                '${(r['estouroComProxima'] as num?)?.toDouble()}',
      ];
      expect(
        ref.knifeEdges
            .map(
              (f) => '${f.id}|${f.line}|${f.text}|${f.slack}|${f.joinOverflow}',
            )
            .join('\n'),
        riscos.join('\n'),
        reason: ref.slug,
      );
    }
  });

  // R8: o texto em fonte de reserva é o mesmo em qualquer largura (o "≈" do tempo restante da 17b, a seta das dicas da
  // 28c e do não incomodar da 30b, os textos do sistema da 69, 69b, 07 e 15) — o índice das larguras copia a declaração
  // da tela a 390
  test('R8: as mesmas fontes de reserva da tela a 390', () {
    final base = {
      for (final q
          in (_json('tools/medicao/pranchas_projeto.json')['pranchas'] as List)
              .cast<Map<String, dynamic>>())
        q['slug']: q,
    };
    for (final p in indice) {
      expect(
        p['reserva'],
        base[p['base']]!['reserva'],
        reason: p['tela'] as String,
      );
    }
    expect(kInformativoProjetoLarguras, {
      for (final MapEntry(key: t, value: m) in kInformativoProjeto.entries)
        for (final l in [360, 430])
          '${t}w$l': {
            for (final MapEntry(key: id, value: motivo) in m.entries)
              id: motivo,
          },
    });
  });

  // T13.9: onde a tela deixa de ser fluida (tools/medicao/fluidez.py → fluidez.json, informação para a etapa de cada
  // tela). Cada item bate com as caixas das referências, na largura e a 390: o quanto passa, o quanto já passava, se é
  // novo e se o elemento tem largura fixa (a mesma nas três larguras); as reticências novas são exatamente as que
  // aparecem no `ellipsized` da largura e não no da tela a 390.
  test('fluidez: os itens batem com as referências', () {
    final flu = _json('docs/design/medicao/projeto_larguras/fluidez.json');
    final tol = (flu['TOL'] as num).toDouble();
    final telas = flu['telas'] as Map<String, dynamic>;
    expect(telas.keys.toList(), [
      for (final r in kRefProjetoLarguras.values) r.slug,
    ]);
    double fora(Rect r, Rect c, String eixo) => eixo == 'x'
        ? math.max(0, math.max(c.left - r.left, r.right - c.right))
        : math.max(0, math.max(c.top - r.top, r.bottom - c.bottom));
    double texto(LeitorRefElement e) => math.max(
      0,
      math.max(
        e.rect.left - e.lines.map((l) => l.left).reduce(math.min),
        e.lines.map((l) => l.right).reduce(math.max) - e.rect.right,
      ),
    );
    double sobre(Rect a, Rect b) =>
        math.min(a.bottom, b.bottom) - math.max(a.top, b.top) <= 1
        ? 0
        : math.max(0, math.min(a.right, b.right) - math.max(a.left, b.left));
    for (final ref in kRefProjetoLarguras.values) {
      final b = kRefProjeto[_base(ref.tela)]!;
      final irmas = [
        b,
        for (final l in [360, 430])
          kRefProjetoLarguras['${_base(ref.tela)}w$l']!,
      ];
      bool fixa(String id) {
        final ws = [for (final r in irmas) r.elements[id]!.rect.width];
        return ws.reduce(math.max) - ws.reduce(math.min) <= 0.01;
      }

      final quadro = Offset.zero & ref.canvas;
      final quadro0 = Rect.fromLTWH(0, 0, 390, ref.canvas.height);
      final itens = (telas[ref.slug] as List).cast<Map<String, dynamic>>();
      for (final it in itens) {
        final id = it['id'] as String, eixo = it['eixo'] as String;
        final e = ref.elements[id]!, e0 = b.elements[id]!;
        final (px, px0) = switch (it['tipo'] as String) {
          'sai do quadro' => (
            fora(e.rect, quadro, eixo),
            fora(e0.rect, quadro0, eixo),
          ),
          'passa do pai' => (
            fora(e.rect, ref.elements[it['pai']]!.rect, eixo),
            fora(e0.rect, b.elements[it['pai']]!.rect, eixo),
          ),
          'texto passa' => (texto(e), texto(e0)),
          'invade o vizinho' => (
            sobre(e.rect, ref.elements[it['vizinho']]!.rect),
            sobre(e0.rect, b.elements[it['vizinho']]!.rect),
          ),
          'reticências' => (0.0, 0.0),
          final t => throw StateError('tipo desconhecido: $t'),
        };
        final quem = '${ref.slug} $id ${it['tipo']} $eixo';
        expect(px, closeTo((it['px'] as num).toDouble(), 0.0051), reason: quem);
        expect(
          px0,
          closeTo((it['px390'] as num).toDouble(), 0.0051),
          reason: quem,
        );
        expect(it['novo'], px0 <= tol, reason: quem);
        expect(it['larguraFixa'], fixa(id), reason: quem);
        if (it['tipo'] == 'reticências') continue;
        expect(px, greaterThan(px0 + tol), reason: quem);
        if (it['tipo'] == 'invade o vizinho') {
          expect(px0, lessThanOrEqualTo(tol), reason: quem);
          expect(it['vizinhoLarguraFixa'], fixa(it['vizinho'] as String));
        }
        if (it['tipo'] == 'passa do pai') {
          expect(it['paiLarguraFixa'], fixa(it['pai'] as String));
        }
      }
      expect(
        {
          for (final it in itens)
            if (it['tipo'] == 'reticências') it['id'],
        },
        ref.ellipsized.difference(b.ellipsized),
        reason: ref.slug,
      );
    }
  });
}
