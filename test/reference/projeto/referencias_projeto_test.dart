// T13 — as referências Dart das telas do projeto batem com as medições em JSON (docs/design/medicao/projeto/layout/).
// Se este teste falhar, meça de novo a etapa (`bash tools/medicao/rodar_etapa.sh <telas>` no WSL) ou rode
// `CONJUNTO=projeto python3 tools/medicao/gen_reference_dart.py` (nunca edite as referências à mão).
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'referencias_projeto.dart';

const _layout = 'docs/design/medicao/projeto/layout';

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

/// O id sem o prefixo da tela ('d17b.cover.book' → 'cover.book').
String _sem(String prefixo, String id) => id.substring(prefixo.length + 1);

/// As telas medidas até agora, por etapa, na ordem do índice (tools/medicao/pranchas_projeto.json).
const _porEtapa = <String, List<String>>{
  'T14': ['02', '36', '17', '17b'],
};

void main() {
  final telas = [for (final t in _porEtapa.values) ...t];
  final indice =
      (_json('tools/medicao/pranchas_projeto.json')['pranchas'] as List)
          .cast<Map<String, dynamic>>();

  test('há uma referência para cada tela medida, na ordem do índice', () {
    final ordem = [
      for (final p in indice)
        if (telas.contains(p['tela'])) p['tela'] as String,
    ];
    expect(kRefProjeto.keys.toList(), ordem);
    for (final p in indice.where((p) => telas.contains(p['tela']))) {
      expect(
        _porEtapa[p['etapa']],
        contains(p['tela']),
        reason: p['tela'] as String,
      );
    }
  });

  for (final tela in telas) {
    final ref = kRefProjeto[tela]!;
    test('tela $tela (${ref.slug}) = layout_${ref.slug}.json', () {
      final lay = _json('$_layout/layout_${ref.slug}.json');
      final meta = lay['meta'] as Map<String, dynamic>;
      final canvas = meta['canvas'] as List<dynamic>;
      expect(
        ref.canvas,
        Size((canvas[0] as num).toDouble(), (canvas[1] as num).toDouble()),
      );
      expect(ref.prefix, meta['prefixo']);
      expect(meta['source'], startsWith('telas/'));

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
    for (final ref in kRefProjeto.values) {
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
      final k = kni[ref.slug] as Map<String, dynamic>;
      final riscos = k.values
          .map((v) => ((v as Map<String, dynamic>)['riscos'] as List).length)
          .fold<int>(0, (a, b) => a + b);
      expect(ref.knifeEdges.length, riscos, reason: ref.slug);
    }
  });

  // R8: só o que o índice declara cai em fonte de reserva (o build_layout.py falha com qualquer outra); a lista do
  // índice e a do layout são as mesmas.
  test('fontes de reserva = as declaradas no índice (R8)', () {
    for (final p in indice.where((p) => telas.contains(p['tela']))) {
      final ref = kRefProjeto[p['tela']]!;
      final lay = _json('$_layout/layout_${ref.slug}.json');
      final comReserva = (lay['elements'] as Map<String, dynamic>).entries
          .where(
            (e) => (e.value as Map<String, dynamic>).containsKey('fallback'),
          )
          .map((e) => _sem(ref.prefix, e.key))
          .toSet();
      final declaradas = ((p['reserva'] ?? <String, dynamic>{}) as Map).keys
          .toSet();
      expect(comReserva, declaradas, reason: ref.slug);
    }
  });

  // R4 (telas irmãs) — os Detalhes do e-book (17b) são os do livro físico (17) com o cartão do meio trocado (o
  // cronômetro vira o progresso salvo sozinho) e outro livro. Os ids comuns têm a mesma caixa — no mesmo lugar ou só
  // deslocados na vertical — salvo os que mudam com o texto ou o desenho, listados um a um (como a 01b × 01).
  test('17b × 17: os elementos comuns, os deslocamentos e o que difere', () {
    final f = kRefProjeto['17']!, e = kRefProjeto['17b']!;
    final de17 = {
      for (final x in f.elements.entries) _sem(f.prefix, x.key): x.value,
    };
    final de17b = {
      for (final x in e.elements.entries) _sem(e.prefix, x.key): x.value,
    };
    // só num dos dois: o cartão do meio e o que o físico e o e-book têm de próprio em "Seus grifos"
    final so17 = de17.keys.where((k) => !de17b.containsKey(k)).toSet();
    final so17b = de17b.keys.where((k) => !de17.containsKey(k)).toSet();
    expect(so17.where((k) => !k.startsWith('session')).toSet(), {
      'highlights.count',
      'highlights.quote.caption.icon',
      'highlights.photograph',
      'highlights.photograph.icon',
      'highlights.club.rank',
      'highlights.club.chevron',
    });
    expect(so17.where((k) => k.startsWith('session')).length, 16);
    expect(so17b.where((k) => !k.startsWith('progress')).toSet(), {
      'highlights.seeAll',
      'highlights.club.date',
      'highlights.club.date.weekday',
      'highlights.club.date.day',
      'highlights.club.date.monthTime',
    });
    expect(so17b.where((k) => k.startsWith('progress')).length, 19);

    // o que muda com o texto ou o desenho: "E-BOOK" × "PAPEL", o título maior (Dom Casmurro em 40/52 × 34/44), o ano
    // e o formato, os votos do clima (outros humores e porcentagens), a sinopse, a citação (1 linha × 3) e o cartão
    // do clube (o próximo encontro × a enquete)
    const difere = {
      'cover.formatTag',
      'title',
      'title.serif',
      'meta.year',
      'meta.format',
      'mood.voters',
      'mood.tag1',
      'mood.tag1.percent',
      'mood.tag2',
      'mood.tag2.percent',
      'mood.tag3',
      'mood.tag3.percent',
      'mood.tag4',
      'mood.tag4.percent',
      'mood.pace.medium.percent',
      'mood.splitLabels.characters',
      'mood.splitLabels.plot',
      'mood.split.fill',
      'mood.split.fill.edge',
      'synopsis',
      'synopsis.text',
      'synopsis.text.more',
      'highlights',
      'highlights.quote',
      'highlights.quote.text',
      'highlights.quote.text.mark',
      'highlights.club',
      'highlights.club.textBlock',
      'highlights.club.kicker',
      'highlights.club.title',
      'highlights.club.meta',
    };
    // os mesmos, deslocados: o título maior desce o resto 13,72; o cartão do progresso tem 30,86 a menos que o do
    // cronômetro (−17,14 do Clima em diante); a sinopse do e-book tem uma linha a menos (−41,94 da ficha em diante); a
    // citação de 1 linha sobe a legenda (−126,99)
    double desloc(String k) {
      if (const {'halo', 'header', 'cover'}.contains(k.split('.').first)) {
        return 0;
      }
      if (k.startsWith('meta') || k.startsWith('status')) return 13.72;
      if (k.startsWith('mood') ||
          k.startsWith('synopsis.header') ||
          k == 'synopsis.title') {
        return -17.14;
      }
      if (k == 'highlights.quote.caption') return -126.99;
      return -41.94;
    }

    // mesma caixa com outro texto: os valores da ficha e a legenda da citação (larguras iguais, por acaso do layout)
    const outroTexto = {
      'synopsis.fact1.value',
      'synopsis.fact2.value',
      'synopsis.fact3.value',
      'synopsis.fact4.label',
      'synopsis.fact4.value',
      'highlights.quote.caption',
    };
    var iguais = 0;
    for (final k in de17.keys.where(de17b.containsKey)) {
      final a = de17[k]!, b = de17b[k]!;
      if (difere.contains(k)) {
        expect(b.rect == a.rect, isFalse, reason: k);
        continue;
      }
      expect(b.rect.left, a.rect.left, reason: k);
      expect(b.rect.width, closeTo(a.rect.width, 1e-9), reason: k);
      expect(b.rect.height, closeTo(a.rect.height, 1e-9), reason: k);
      expect(b.rect.top, closeTo(a.rect.top + desloc(k), 1e-6), reason: k);
      if (outroTexto.contains(k)) {
        expect(_texts(b.lines), isNot(_texts(a.lines)), reason: k);
      } else {
        expect(_texts(b.lines), _texts(a.lines), reason: k);
        expect(_texts(b.linesAll), _texts(a.linesAll), reason: k);
      }
      iguais++;
    }
    expect(iguais, 90 - difere.length);
  });

  // D-275: no projeto, a linha única quase cheia numa caixa de largura imposta também é fio de navalha. Na T14 só a
  // citação da 17b (0,25 px de sobra: um fio mais larga, ela quebra e desce 34 ids); as outras linhas únicas cheias
  // são caixas do tamanho do texto (sobra 0), que crescem com ele.
  test('fios de navalha da T14: só a citação da 17b, de uma linha', () {
    final facas = [
      for (final t in _porEtapa['T14']!) ...kRefProjeto[t]!.knifeEdges,
    ];
    expect(facas.map((k) => k.id).toList(), ['d17b.highlights.quote.text']);
    expect(facas.single.line, 1);
    expect(facas.single.slack, closeTo(0.252, 1e-9));
    expect(facas.single.joinOverflow, isNull);
    expect(
      kRefProjeto['17b']!.textDependentY,
      contains('d17b.highlights.quote.text'),
    );
  });

  // A 36 (Biblioteca vazia) tem a mesma barra de navegação da 02, presa ao fundo do quadro (844 × 1640: −796); o
  // degradê de baixo é outro (130 de altura com o branco a 55 %, × 170 a 60 % na 02).
  test('36 × 02: a mesma navegação, presa ao fundo', () {
    final b = kRefProjeto['02']!, v = kRefProjeto['36']!;
    final navs = v.elements.entries.where((x) => x.value.section == 'b36.nav');
    expect(navs.length, 17);
    for (final x in navs) {
      final o = b.elements['b02.${_sem(v.prefix, x.key)}']!;
      expect(x.value.rect.left, o.rect.left, reason: x.key);
      expect(x.value.rect.size, o.rect.size, reason: x.key);
      expect(x.value.rect.top, closeTo(o.rect.top - 796, 1e-9), reason: x.key);
      expect(_texts(x.value.lines), _texts(o.lines), reason: x.key);
    }
    expect(v.elements['b36.bottomFade']!.rect.height, 130);
    expect(b.elements['b02.bottomFade']!.rect.height, 170);
  });
}
