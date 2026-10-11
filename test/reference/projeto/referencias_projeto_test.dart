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
  'T15': ['03', '39', '40', '41', '42', '69', '69b', '28', '28b', '28c', '28d'],
  'T16': [
    '35',
    '07',
    '08',
    '09',
    '09b',
    '10',
    '11',
    '12',
    '13',
    '13b',
    '14',
    '15',
    '16',
    '36a',
  ],
};

/// Os elementos de uma tela sem o prefixo ('sc03.sheet' → 'sheet').
Map<String, LeitorRefElement> _de(String tela) {
  final r = kRefProjeto[tela]!;
  return {for (final x in r.elements.entries) _sem(r.prefix, x.key): x.value};
}

/// Os ids de uma lista de seções (a própria seção e o que está dentro dela).
bool _em(String k, Iterable<String> secoes) =>
    secoes.any((s) => k == s || k.startsWith('$s.'));

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
      // cada fio de navalha = um risco do JSON, campo a campo e na ordem
      final k = kni[ref.slug] as Map<String, dynamic>;
      final riscos = [
        for (final e in k.entries)
          for (final r in (e.value as Map<String, dynamic>)['riscos'] as List)
            '${e.key}|${r['linha']}|${r['texto']}|${r['sobra']}|${r['estouroComProxima']}',
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

  // D-275: no projeto, a linha única quase cheia numa caixa de largura imposta também é fio de navalha. Na T14 a
  // citação da 17b (0,25 px de sobra: um fio mais larga, ela quebra e desce 34 ids); as outras linhas únicas cheias
  // são caixas do tamanho do texto (sobra 0), que crescem com ele. E, pela D-278, a fileira do autor da 17b: o
  // "E-book · 256 páginas" subiria para a 1ª fileira se fosse 0,47 px mais estreito (na 17 o "Físico" não cabe).
  test('fios de navalha da T14: a citação e a fileira do autor da 17b', () {
    final facas = [
      for (final t in _porEtapa['T14']!) ...kRefProjeto[t]!.knifeEdges,
    ];
    expect(facas.map((k) => k.id).toList(), [
      'd17b.highlights.quote.text',
      'd17b.meta',
    ]);
    expect(facas.first.line, 1);
    expect(facas.first.slack, closeTo(0.252, 1e-9));
    expect(facas.first.joinOverflow, isNull);
    expect(facas.last.line, 1);
    expect(facas.last.joinOverflow, closeTo(0.467, 1e-9));
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

  // R8 (T13): o texto que o app não desenha — o teclado numérico do sistema da 69/69b, o botão da Apple da 07 e o input
  // invisível do @ da 15 (D-277) — é só informativo: a referência Dart traz o mapa id → motivo, o mesmo do layout e do
  // índice. As outras reservas (o "≈" da 17b, a "→" da 28c) são do app.
  test('R8: o texto só informativo = o do índice, com o motivo', () {
    final esperado = <String, Map<String, String>>{};
    for (final p in indice.where((p) => telas.contains(p['tela']))) {
      final ref = kRefProjeto[p['tela']]!;
      final reserva = (p['reserva'] ?? <String, dynamic>{}) as Map;
      final inf = <String, String>{
        for (final e in reserva.entries)
          if ((e.value as Map)['informativo'] == true)
            '${ref.prefix}.${e.key}': (e.value as Map)['motivo'] as String,
      };
      if (inf.isNotEmpty) esperado[p['tela'] as String] = inf;
      final lay = _json('$_layout/layout_${ref.slug}.json');
      final doLayout = <String, String>{
        for (final e in (lay['elements'] as Map<String, dynamic>).entries)
          if ((e.value as Map<String, dynamic>).containsKey('informativo'))
            e.key: (e.value as Map<String, dynamic>)['informativo'] as String,
      };
      expect(doLayout, inf, reason: ref.slug);
    }
    expect(kInformativoProjeto, esperado);
    expect(kInformativoProjeto.keys, ['69', '69b', '07', '15']);
    // as 10 teclas, os 10 números e as letras de 2 a 9
    expect(kInformativo69.length, 28);
    expect(kInformativo69b.keys, [
      for (final k in kInformativo69.keys) k.replaceFirst('sc69.', 'sc69b.'),
    ]);
    expect(kInformativo07.keys, ['e07.sheet.buttons.apple']);
    expect(kInformativo15.keys, ['e15.username.field.input']);
  });

  // T13.5: a Busca põe o título e a lista de cada seção direto no <main>, sem contêiner — a caixa da seção é a união
  // das caixas de topo dela (build_layout.py, listadas no meta do layout). Em todas as outras telas a seção é um
  // elemento.
  test('seções sem contêiner = a união das caixas de topo', () {
    final semContainer = <String, Map<String, List<String>>>{
      '28': {
        'recent': ['recent.header', 'recent.list'],
        'mood': ['mood.header', 'mood.chips'],
        'genres': ['genres.header', 'genres.grid'],
        'trending': [
          'trending.header',
          'trending.subtitle',
          'trending.carousel',
        ],
      },
      '28b': {
        'books': ['books.header', 'books.list'],
        'clubs': ['clubs.header', 'clubs.list'],
        'highlights': ['highlights.header', 'highlights.list'],
      },
      '28c': {
        'actions': ['actions.scan', 'actions.manual'],
      },
      // T16: a dica do scanner fica dentro da linha da busca (o foco, o anel, a seta, "é aqui!" e o cartão); o título
      // das sugestões e a grade, o @ e a frase sobre você, e os confetes, soltos
      '13b': {
        'coach': [
          'coach.spotlight',
          'coach.ring',
          'coach.arrow',
          'coach.tag',
          'coach.card',
        ],
        'suggestions': ['suggestions.header', 'suggestions.grid'],
      },
      '14': {
        'suggestions': ['suggestions.header', 'suggestions.grid'],
      },
      '15': {
        'username': ['username.label', 'username.field', 'username.status'],
        'bio': ['bio.header', 'bio.field', 'bio.hint'],
      },
      '16': {
        'confetti': [
          for (var i = 1; i <= 6; i++) 'confetti.sparkle$i',
          'confetti.dotCoral',
          'confetti.dotCream',
          'confetti.dashGreen',
          'confetti.dashLavender',
        ],
      },
    };
    for (final tela in telas) {
      final ref = kRefProjeto[tela]!;
      final meta = _json('$_layout/layout_${ref.slug}.json')['meta'] as Map;
      final esperado = semContainer[tela] ?? const <String, List<String>>{};
      expect(meta['secoesSemElemento'] ?? <String, dynamic>{}, {
        for (final e in esperado.entries)
          '${ref.prefix}.${e.key}': [
            for (final k in e.value) '${ref.prefix}.$k',
          ],
      }, reason: ref.slug);
      for (final s in ref.sections.entries) {
        final curto = _sem(ref.prefix, s.key);
        if (!esperado.containsKey(curto)) {
          expect(ref.elements[s.key]?.rect, s.value, reason: s.key);
          continue;
        }
        expect(ref.elements.containsKey(s.key), isFalse, reason: s.key);
        final uniao = esperado[curto]!
            .map((k) => ref.elements['${ref.prefix}.$k']!.rect)
            .reduce((a, b) => a.expandToInclude(b));
        // a união é feita antes do arredondamento a 0,01 px do layout
        expect(uniao.left, closeTo(s.value.left, 0.02), reason: s.key);
        expect(uniao.top, closeTo(s.value.top, 0.02), reason: s.key);
        expect(uniao.right, closeTo(s.value.right, 0.02), reason: s.key);
        expect(uniao.bottom, closeTo(s.value.bottom, 0.02), reason: s.key);
      }
    }
  });

  // R4 (telas irmãs) — o Scanner: a câmera, a moldura e a barra do topo da 03 são as mesmas na 39, na 40 e na 42 (a
  // 40 com outro livro na câmera; a 39 ainda procurando o código, sem o realce); a 41 (sem câmera) guarda os cantos e
  // a barra; a aba Digitar (69, 69b) guarda a barra, com a ajuda no lugar da lanterna e o "Digitar" marcado.
  test('Scanner: a câmera, a moldura e a barra do topo nas 7 telas', () {
    final base = _de('03');
    const camera = [
      'camera',
      'dim',
      'detected',
      'corners',
      'status',
      'controls',
    ];
    void mesmos(
      String tela,
      List<String> secoes, {
      Set<String> falta = const {},
      Set<String> difere = const {},
    }) {
      final m = _de(tela);
      final ks = base.keys.where((k) => _em(k, secoes)).toList();
      expect(ks.where((k) => !m.containsKey(k)).toSet(), falta, reason: tela);
      for (final k in ks.where(m.containsKey)) {
        final a = base[k]!, b = m[k]!;
        if (difere.contains(k)) {
          expect(
            b.rect == a.rect &&
                _texts(b.lines).join('|') == _texts(a.lines).join('|'),
            isFalse,
            reason: '$tela $k',
          );
          continue;
        }
        expect(b.rect, a.rect, reason: '$tela $k');
        expect(_texts(b.lines), _texts(a.lines), reason: '$tela $k');
        expect(_texts(b.linesAll), _texts(a.linesAll), reason: '$tela $k');
      }
    }

    mesmos(
      '39',
      camera,
      falta: {
        'camera.book.ring',
        'detected',
        'detected.badge',
        'detected.badge.icon',
      },
      difere: {'status.chip', 'status.chip.badge', 'status.chip.badge.icon'},
    );
    mesmos(
      '40',
      camera,
      falta: {'camera.book.ring'},
      difere: {'camera.book.quote', 'camera.book.author', 'camera.label.isbn'},
    );
    mesmos('42', camera, falta: {'camera.book.ring'});
    mesmos('41', ['corners', 'controls']);
    for (final t in ['69', '69b']) {
      mesmos(
        t,
        ['controls'],
        falta: {'controls.torch', 'controls.torch.icon'},
        difere: {
          'controls.mode',
          'controls.mode.code',
          'controls.mode.code.icon',
          'controls.mode.type',
          'controls.mode.type.icon',
        },
      );
      expect(_de(t)['controls.help']!.rect, base['controls.torch']!.rect);
    }
    expect(_de('39')['scanLine'], isNotNull);
    expect(_de('41')['backdrop'], isNotNull);
  });

  // A folha que sobe de baixo (03, 39, 40, 41, 42): a mesma caixa presa ao fundo (10 da borda), de altura do que
  // diz; a alça e o topo (chip e ISBN) no mesmo lugar dentro dela. Na 40 o desenho com o texto é 20 mais baixo que o
  // livro da 03 (106 × 126): o resto sobe 20; na 42 a capa menor e a meta do dia sobem as ações e o rodapé 38,7.
  test('Scanner: a folha de baixo e o que muda dentro dela', () {
    Rect rel(LeitorRefElement e, Rect folha) => e.rect.shift(-folha.topLeft);
    // a diferença de duas coordenadas absolutas carrega ruído de ponto flutuante (~1e-13)
    void igual(Rect a, Rect b, String reason, {bool tamanho = true}) {
      expect(a.left, closeTo(b.left, 1e-6), reason: reason);
      expect(a.top, closeTo(b.top, 1e-6), reason: reason);
      if (!tamanho) return;
      expect(a.width, closeTo(b.width, 1e-6), reason: reason);
      expect(a.height, closeTo(b.height, 1e-6), reason: reason);
    }

    final base = _de('03');
    final f03 = base['sheet']!.rect;
    final alturas = <String, double>{};
    for (final t in ['03', '39', '40', '41', '42']) {
      final m = _de(t);
      final f = m['sheet']!.rect;
      expect(f.left, 10, reason: t);
      expect(f.width, 370, reason: t);
      expect(f.bottom, closeTo(834, 1e-9), reason: t);
      alturas[t] = f.height;
      igual(
        rel(m['sheet.handle']!, f),
        rel(base['sheet.handle']!, f03),
        '$t sheet.handle',
      );
      if (t == '39' || t == '41') continue;
      for (final k in ['sheet.top', 'sheet.isbn']) {
        igual(rel(m[k]!, f), rel(base[k]!, f03), '$t $k');
      }
      // o chip muda de texto (e de largura), não de lugar
      igual(
        rel(m['sheet.chip']!, f),
        rel(base['sheet.chip']!, f03),
        '$t sheet.chip',
        tamanho: false,
      );
    }
    const esperadas = {
      '03': 408.61,
      '39': 243.71,
      '40': 388.61,
      '41': 480.36,
      '42': 369.91,
    };
    esperadas.forEach((t, h) => expect(alturas[t], closeTo(h, 1e-9)));
    void sobe(
      String tela,
      Iterable<String> secoes,
      double dy, {
      Set<String> exceto = const {},
    }) {
      final m = _de(tela);
      final f = m['sheet']!.rect;
      final ks = base.keys.where(
        (k) => _em(k, secoes) && m.containsKey(k) && !exceto.contains(k),
      );
      expect(ks, isNotEmpty, reason: tela);
      for (final k in ks) {
        expect(
          rel(m[k]!, f).top,
          closeTo(rel(base[k]!, f03).top + dy, 1e-6),
          reason: '$tela $k',
        );
      }
    }

    sobe('40', ['sheet.saveAs', 'sheet.actions', 'sheet.footer'], -20);
    // o ícone de "Iniciar leitura" é 21 (o de "Adicionar" é 20): desce 0,5 a mais
    sobe(
      '42',
      ['sheet.actions', 'sheet.footer'],
      -38.7,
      exceto: {'sheet.actions.primary.icon'},
    );
    expect(
      rel(
        _de('42')['sheet.actions.primary.icon']!,
        _de('42')['sheet']!.rect,
      ).top,
      closeTo(rel(base['sheet.actions.primary.icon']!, f03).top - 39.2, 1e-6),
    );
  });

  // 69b × 69: a mesma tela de digitar depois de completar com o dígito errado — a etiqueta treme (as 2 marcas) e
  // ganha o aviso no lugar da dica, o "X" entra no lugar do cursor, "Colar" vira "Apagar tudo". O resto é igual.
  test('69b × 69: o que muda quando o ISBN não confere', () {
    final a = _de('69'), b = _de('69b');
    expect(a.keys.where((k) => !b.containsKey(k)).toSet(), {
      'sticker.card.digits.slot',
      'sticker.card.digits.slot.caret',
      'sticker.card.hint',
      'sticker.card.hint.key',
      'sticker.card.barcode.prefix',
      'toolbar.paste',
      'toolbar.paste.icon',
    });
    expect(b.keys.where((k) => !a.containsKey(k)).toSet(), {
      'sticker.shakeLeft',
      'sticker.shakeRight',
      'sticker.card.digits.check',
      'sticker.card.alert',
      'sticker.card.alert.icon',
      'sticker.card.alert.text',
      'toolbar.clearAll',
      'toolbar.clearAll.icon',
    });
    const difere = {
      'sticker',
      'sticker.tilt',
      'sticker.card',
      'sticker.card.count',
      'sticker.card.digits',
      'sticker.card.digits.number',
      'sticker.card.digits.number.dash1',
      'sticker.card.digits.number.dash2',
      'sticker.card.digits.dash3',
      'sticker.card.barcode',
      'sticker.card.barcode.bars',
      'sticker.notes',
      'sticker.notes.line',
      'sticker.notes.noIsbn',
      'sticker.notes.noIsbn.link',
      'toolbar.spacer',
    };
    var iguais = 0;
    for (final k in a.keys.where(b.containsKey)) {
      if (difere.contains(k)) {
        expect(a[k]!.rect == b[k]!.rect, isFalse, reason: k);
        continue;
      }
      expect(b[k]!.rect, a[k]!.rect, reason: k);
      expect(_texts(b[k]!.lines), _texts(a[k]!.lines), reason: k);
      iguais++;
    }
    expect(iguais, 59);
  });

  // Os fios de navalha da T15 (2+ linhas pela regra da G01, a linha única pela D-275; a linha que dá a largura da
  // caixa não conta, D-276): o título da capa do Brás Cubas na folha da 03 ("Póstumas de", 1,20 de sobra), o texto
  // ao lado do livro em branco da 40 (0,29 e 1,02), a meta do dia da 42 (0,98 na última linha) e, pela D-278, a 2ª
  // fileira de humores da 28 (o "Reflexivo" subiria para ela com 0,40 px a menos). O "dígito / final"
  // do X (69, 69b) dá a largura da caixa e saiu (D-276). E o "Quadrinhos" da 28 não cabe na caixa de 92 (max-width) e
  // passa 3,10 — no Flutter uma palavra que não cabe é quebrada no meio: armadilha para a T15.
  test('fios de navalha da T15 e o texto que estoura a caixa', () {
    final facas = [
      for (final t in _porEtapa['T15']!) ...kRefProjeto[t]!.knifeEdges,
    ];
    expect(facas.map((k) => '${k.id}:${k.line}').toList(), [
      'sc03.sheet.book.cover.title:2',
      'sc40.sheet.lead.body:1',
      'sc40.sheet.lead.body:2',
      'sc42.sheet.goal.text:2',
      'bu28.mood.chips:2',
    ]);
    const sobras = [1.201, 0.286, 1.023, 0.978, 104.244];
    for (var i = 0; i < facas.length; i++) {
      expect(facas[i].slack, closeTo(sobras[i], 1e-9), reason: facas[i].id);
    }
    expect(facas[3].joinOverflow, isNull);
    expect(facas.last.joinOverflow, closeTo(0.397, 1e-9));
    for (final t in ['69', '69b']) {
      expect(kRefProjeto[t]!.knifeEdges, isEmpty, reason: t);
    }

    final kni = _json('$_layout/knife_edges.json');
    final quadrinhos =
        (kni['028_busca_explorar'] as Map)['bu28.genres.tile8.label'] as Map;
    expect(quadrinhos['riscos'], isEmpty);
    final linha = (quadrinhos['linhas'] as List).single as Map;
    expect(linha['texto'], 'Quadrinhos');
    expect(linha['disponivel'], 92);
    expect(linha['sobra'], closeTo(-3.103, 1e-9));
    final label = kRefProjeto['28']!.elements['bu28.genres.tile8.label']!;
    expect(label.rect.width, 92);
    expect(_texts(label.lines), ['Quadrinhos']);
  });

  // A barra de busca: a mesma na 28, na 28b e na 28c; com texto (28b, 28c) entra o X de limpar, o campo encolhe e o
  // navegador encolhe também a lupa (o <svg> do flex: 20 → 16,78 de largura) — armadilha anotada para a T15.
  test('28 × 28b × 28c: a mesma barra de busca', () {
    final a = _de('28'), b = _de('28b'), c = _de('28c');
    final barra = b.keys.where((k) => _em(k, ['searchBar'])).toList();
    expect(barra.length, 10);
    for (final k in barra) {
      expect(c[k]!.rect, b[k]!.rect, reason: k);
    }
    expect(barra.where((k) => !a.containsKey(k)).toSet(), {
      'searchBar.field.clear',
      'searchBar.field.clear.icon',
    });
    for (final k in barra.where(a.containsKey)) {
      if (k == 'searchBar.field.icon' || k == 'searchBar.field.input') {
        continue;
      }
      expect(b[k]!.rect, a[k]!.rect, reason: k);
    }
    expect(a['searchBar.field.icon']!.rect.width, 20);
    expect(b['searchBar.field.icon']!.rect.width, closeTo(16.78, 1e-9));
    expect(b['searchBar.field.icon']!.rect.height, 20);
  });

  // D-278: as fileiras de flex-wrap do projeto que quase mudam (o `perturbar.js` mede o tamanho hipotético de cada
  // item, sem crescer nem encolher). As três do JSON (`fileiras: true`) batem com as caixas medidas: na 17b o selo
  // "E-book · 256 páginas" subiria para a fileira do autor com 0,47 px a menos (na 17 o "Livro físico", 21 px mais
  // largo, não sobe); na 28 o "Reflexivo" (1º da 3ª fileira) subiria para a 2ª com 0,40 a menos; na 13 o "Terror"
  // termina 0,97 antes da borda e desceria com um pouco mais. A entrada fica no contêiner (uma caixa, sem texto) e o
  // texto são os itens da fileira separados por " | ".
  test('D-278: as fileiras de flex-wrap que quase mudam', () {
    final kni = _json('$_layout/knife_edges.json');
    final fileiras = <String>[
      for (final t in kni.values)
        for (final k in (t as Map<String, dynamic>).entries)
          if ((k.value as Map<String, dynamic>)['fileiras'] == true) k.key,
    ];
    expect(fileiras, ['d17b.meta', 'bu28.mood.chips', 'e13.genres']);
    const telas = {
      'd17b.meta': '17b',
      'bu28.mood.chips': '28',
      'e13.genres': '13',
    };
    for (final id in fileiras) {
      final ref = kRefProjeto[telas[id]]!;
      final e = ref.elements[id]!;
      expect(e.kind, LeitorRefKind.box, reason: id);
      expect(e.lines, isEmpty, reason: id);
      final f = ref.knifeEdges.singleWhere((k) => k.id == id);
      expect(f.text.contains(' | '), isTrue, reason: id);
    }
    // a geometria: as caixas têm 2 casas, os fios 3
    LeitorKnifeEdge faca(String tela, String id) =>
        kRefProjeto[tela]!.knifeEdges.singleWhere((k) => k.id == id);

    final d = _de('17b'), d17 = _de('17');
    expect(
      d['meta.year']!.rect.right +
          10 +
          d['meta.format']!.rect.width -
          d['meta']!.rect.right,
      closeTo(faca('17b', 'd17b.meta').joinOverflow!, 0.01),
    );
    expect(
      d17['meta.year']!.rect.right +
          10 +
          d17['meta.format']!.rect.width -
          d17['meta']!.rect.right,
      greaterThan(20),
    );
    expect(
      kRefProjeto['17']!.knifeEdges.where((k) => k.id == 'd17.meta'),
      isEmpty,
    );
    final b = _de('28');
    expect(
      b['mood.chips.chip6']!.rect.top,
      greaterThan(b['mood.chips.chip5']!.rect.top),
    );
    expect(
      b['mood.chips.chip5']!.rect.right +
          8 +
          b['mood.chips.chip6']!.rect.width -
          b['mood.chips']!.rect.right,
      closeTo(faca('28', 'bu28.mood.chips').joinOverflow!, 0.01),
    );
    final g = _de('13');
    expect(g['genres.chip7']!.rect.top, g['genres.chip5']!.rect.top);
    expect(
      g['genres']!.rect.right - g['genres.chip7']!.rect.right,
      closeTo(faca('13', 'e13.genres').slack, 0.01),
    );
  });

  // Os fios de navalha da T16: dois de estouro (a próxima palavra caberia faltando < 1 px) — o aviso da senha
  // incorreta na 09b ("…entre com" + "um": 0,81) e o título do cartão do primeiro livro na 36a ("primeiro livro" +
  // "na": 0,95) — e, pela D-278, a 3ª fileira de gêneros da 13, cheia por 0,97 px. O "Código de 6 dígitos" da 10 é o
  // rótulo só para o leitor de tela (caixa de 1 px com clip, não é desenhado): as palavras vão uma por linha e
  // estouram a caixa, sem risco — no Flutter é Semantics, não texto.
  test('fios de navalha da T16 e o rótulo escondido do código', () {
    final facas = [
      for (final t in _porEtapa['T16']!) ...kRefProjeto[t]!.knifeEdges,
    ];
    expect(facas.map((k) => '${k.id}:${k.line}').toList(), [
      'e09b.sheet.form.alert.text:1',
      'e13.genres:3',
      'e36a.firstBook.title:2',
    ]);
    expect(facas[1].slack, closeTo(0.966, 1e-9));
    const estouros = {0: 0.808, 2: 0.951};
    for (final MapEntry(key: i, value: e) in estouros.entries) {
      expect(facas[i].joinOverflow, closeTo(e, 1e-9), reason: facas[i].id);
      expect(facas[i].slack, greaterThan(20), reason: facas[i].id);
    }

    final kni = _json('$_layout/knife_edges.json');
    final rotulo = (kni['010_codigo'] as Map)['e10.sheet.code.label'] as Map;
    expect(rotulo['riscos'], isEmpty);
    final linhas = (rotulo['linhas'] as List).cast<Map>();
    expect(linhas.map((l) => l['texto']).join(' '), 'Código de 6 dígitos');
    expect(linhas.every((l) => l['disponivel'] == 1), isTrue);
    expect(kRefProjeto['10']!.knifeEdges, isEmpty);
  });

  // R4 (telas irmãs) — a Entrada: as mesmas ondas no Login, no Cadastro, no Entrar (e com erro), no Código, na Nova
  // senha e na Carteirinha pronta; o mesmo voltar em todas as que voltam; a marca da Abertura é a do Login, 238 mais
  // abaixo.
  test('Entrada: as ondas, o voltar e a marca', () {
    final login = _de('07');
    for (final t in ['08', '09', '09b', '10', '11', '16']) {
      expect(_de(t)['waves']!.rect, login['waves']!.rect, reason: t);
    }
    final volta = _de('08');
    for (final t in ['09', '09b', '10', '11']) {
      for (final k in ['back', 'back.icon']) {
        expect(_de(t)[k]!.rect, volta[k]!.rect, reason: '$t $k');
      }
    }
    final abertura = _de('35');
    final marca = abertura.keys.where((k) => _em(k, ['wordmark'])).toList();
    expect(marca.length, 4);
    for (final k in marca) {
      final a = abertura[k]!.rect, b = login[k]!.rect;
      expect(b.left, a.left, reason: k);
      expect(b.width, closeTo(a.width, 1e-6), reason: k);
      expect(b.height, closeTo(a.height, 1e-6), reason: k);
      expect(b.top, closeTo(a.top - 238, 1e-9), reason: k);
      expect(_texts(login[k]!.lines), _texts(abertura[k]!.lines), reason: k);
    }
  });

  // 09b × 09: a senha errada pinta o campo (sem o cursor: os pontos ocupam o campo) e põe o aviso no formulário, que
  // cresce 47,8 — o resto do formulário e da folha desce junto; o "Criar conta" fica no pé da folha.
  test('09b × 09: o que muda com a senha incorreta', () {
    final a = _de('09'), b = _de('09b');
    expect(a.keys.where((k) => !b.containsKey(k)).toSet(), {
      'sheet.form.password.field.value',
      'sheet.form.password.field.caret',
    });
    expect(b.keys.where((k) => !a.containsKey(k)).toSet(), {
      'sheet.form.alert',
      'sheet.form.alert.badge',
      'sheet.form.alert.text',
    });
    const desce = {
      'sheet.form.submit',
      'sheet.form.submit.label',
      'sheet.form.submit.icon',
      'sheet.divider',
      'sheet.divider.lineLeft',
      'sheet.divider.label',
      'sheet.divider.lineRight',
      'sheet.code',
      'sheet.code.icon',
    };
    var iguais = 0;
    for (final k in a.keys.where(b.containsKey)) {
      final ra = a[k]!.rect, rb = b[k]!.rect;
      if (k == 'sheet.form') {
        expect(rb.height, closeTo(ra.height + 47.8, 1e-9));
      } else if (k == 'sheet.form.password.field.dots') {
        expect(_texts(b[k]!.lines), ['••••••••']);
        expect(rb.width, 260);
      } else if (desce.contains(k)) {
        expect(rb.top, closeTo(ra.top + 47.8, 1e-9), reason: k);
        expect(rb.size, ra.size, reason: k);
      } else {
        expect(rb, ra, reason: k);
        iguais++;
      }
    }
    expect(iguais, 22);
  });

  // O campo de senha é o mesmo no Cadastro, no Entrar e na Nova senha (com foco: os pontos e o cursor; o olho à
  // direita): muda só quantos pontos (10, 9 e 11) e, com eles, onde o cursor fica.
  test('o campo de senha do Cadastro, do Entrar e da Nova senha', () {
    Rect rel(Map<String, LeitorRefElement> m, String k) =>
        m[k]!.rect.shift(-m['sheet.form.password.field']!.rect.topLeft);
    final base = _de('08');
    const campo = 'sheet.form.password.field';
    final pontos = <String, int>{};
    for (final t in ['08', '09', '11']) {
      final m = _de(t);
      for (final k in [
        campo,
        '$campo.value',
        '$campo.input',
        '$campo.reveal',
        '$campo.reveal.icon',
      ]) {
        final a = rel(base, k), b = rel(m, k);
        expect(b.left, closeTo(a.left, 1e-6), reason: '$t $k');
        expect(b.top, closeTo(a.top, 1e-6), reason: '$t $k');
        expect(b.width, closeTo(a.width, 1e-6), reason: '$t $k');
        expect(b.height, closeTo(a.height, 1e-6), reason: '$t $k');
      }
      final dots = m['$campo.dots']!, caret = m['$campo.caret']!;
      pontos[t] = _texts(dots.lines).single.length;
      expect(caret.rect.left, closeTo(dots.rect.right + 2, 1e-6), reason: t);
    }
    expect(pontos, {'08': 10, '09': 9, '11': 11});
  });

  // O topo do onboarding: do 2º passo em diante (13, 13b, 14, 15) o mesmo voltar, o mesmo passo e a mesma barra — muda
  // o texto do passo e quanto a barra enche (50 %, 75 %; no 4º passo a barra é toda da cor, sem o preenchimento); o 1º
  // passo (12) não tem voltar.
  test('Onboarding: o topo dos passos', () {
    final a = _de('13');
    final topo = a.keys.where((k) => _em(k, ['top'])).toList();
    expect(topo.length, 8);
    for (final t in ['13b', '14', '15']) {
      final m = _de(t);
      for (final k in topo) {
        if (k.startsWith('top.progress.fill')) continue;
        expect(m[k]!.rect, a[k]!.rect, reason: '$t $k');
      }
    }
    expect(_texts(_de('14')['top.step']!.lines), ['3 de 4']);
    expect(
      _de('14')['top.progress.fill']!.rect.width,
      greaterThan(a['top.progress.fill']!.rect.width),
    );
    expect(_de('15').containsKey('top.progress.fill'), isFalse);
    expect(_de('12').containsKey('top.back'), isFalse);
  });

  // 13b × 14: a dica do scanner só se põe por cima — os 93 ids da 14 ficam idênticos e os 17 da dica são a mais.
  test('13b × 14: a dica do scanner por cima, sem mexer em nada', () {
    final a = _de('14'), b = _de('13b');
    expect(a.keys.every(b.containsKey), isTrue);
    for (final k in a.keys) {
      expect(b[k]!.rect, a[k]!.rect, reason: k);
      expect(_texts(b[k]!.lines), _texts(a[k]!.lines), reason: k);
    }
    expect(a.length, 93);
    final dica = b.keys.where((k) => !a.containsKey(k)).toList();
    expect(dica.length, 17);
    expect(dica.every((k) => _em(k, ['coach'])), isTrue);
  });

  // 36a × 36: a Início do primeiro acesso tem a navegação e o degradê da Biblioteca vazia (o mesmo quadro de 844); só
  // trocam de largura os rótulos de Início e Biblioteca (a aba marcada vai em negrito).
  test('36a × 36: a mesma navegação e o mesmo degradê', () {
    final a = _de('36'), b = _de('36a');
    final ks = a.keys.where((k) => _em(k, ['nav', 'bottomFade'])).toList();
    expect(ks.length, 18);
    for (final k in ks) {
      if (k == 'nav.home.label' || k == 'nav.library.label') {
        expect(b[k]!.rect.top, a[k]!.rect.top, reason: k);
        expect(b[k]!.rect.width == a[k]!.rect.width, isFalse, reason: k);
        continue;
      }
      expect(b[k]!.rect, a[k]!.rect, reason: k);
    }
  });
}
