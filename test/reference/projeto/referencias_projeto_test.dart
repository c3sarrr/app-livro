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
  'T17': ['05', '64', '65', '06', '58', '59', '56', '30', '30b', '30c'],
  'T18': ['18', '18b'],
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
    // D-280: o limiar de quebra medido no navegador (0,252 pela diferença das larguras na G01)
    expect(facas.first.slack, closeTo(0.253, 1e-9));
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
      // T17: as duas listas da 30 (o título com o traço e a lista) e o texto de "tudo em dia" da 30c, soltos no <main>
      '30': {
        'today': ['today.label', 'today.list'],
        'week': ['week.label', 'week.list'],
      },
      '30c': {
        'empty': ['empty.title', 'empty.body', 'empty.cta'],
      },
      // T18: os confetes da 18b, soltos no quadro (como os da 16)
      '18b': {
        'confetti': [
          for (var i = 1; i <= 3; i++) 'confetti.sparkle$i',
          'confetti.dashLavender',
          'confetti.dotCoral',
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
      'bu28c.tips.tip3:1',
    ]);
    const sobras = [1.201, 0.286, 1.023, 0.978, 104.244, 42.57];
    for (var i = 0; i < facas.length; i++) {
      expect(facas[i].slack, closeTo(sobras[i], 1e-9), reason: facas[i].id);
    }
    expect(facas[3].joinOverflow, isNull);
    expect(facas[4].joinOverflow, closeTo(0.397, 1e-9));
    expect(facas[5].joinOverflow, closeTo(0.453, 1e-9));
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
    // D-280: uma palavra só não quebra ao crescer (sobra null); passa da caixa por largura − disponível
    expect(linha['sobra'], isNull);
    expect(linha['largura'] - linha['disponivel'], closeTo(3.103, 1e-9));
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

  // Os fios de navalha da T17 (medidos no navegador, D-280): três de sobra (a linha cabe com menos de 1,5 px de
  // folga) — o "da Estrela" da capinha de 21 px da troca de livro (2ª linha, depois da quebra imposta do <br>, 0,64) e
  // duas descrições da Privacidade (0,42 e 0,50). As outras oito telas não têm nenhum, nem fileira de flex-wrap
  // (D-278). A estimativa da G01 marcava mais dois no Perfil, que não existem (ver o teste da D-280).
  test('fios de navalha da T17', () {
    final facas = [
      for (final t in _porEtapa['T17']!) ...kRefProjeto[t]!.knifeEdges,
    ];
    expect(
      facas
          .map(
            (k) => '${k.id}:${k.line}:${k.text}:${k.slack}:${k.joinOverflow}',
          )
          .toList(),
      [
        'p65.sheet.options.option2.thumb.cover.title:2:da Estrela:0.638:null',
        'aj56.visibility.list.highlights.body:1:Padrão: só você. Dá para abrir:'
            '0.424:29.255',
        'aj56.people.list.findByEmail.body:1:Quem tem seu e-mail encontra você:'
            '0.503:16.01',
      ],
    );
    for (final t in ['05', '64', '06', '58', '59', '30', '30b', '30c']) {
      expect(kRefProjeto[t]!.knifeEdges, isEmpty, reason: t);
    }

    final kni = _json('$_layout/knife_edges.json');
    Map<String, dynamic> entrada(String slug, String id) =>
        (kni[slug] as Map<String, dynamic>)[id] as Map<String, dynamic>;
    final capa = entrada(
      '065_editar_perfil_trocar',
      'p65.sheet.options.option2.thumb.cover.title',
    );
    expect(capa['quebrasImpostas'], [1]);
    expect((capa['linhas'] as List).first['texto'], 'A Hora');
    expect((capa['linhas'] as List).first['disponivel'], 21);
    for (final slug in [
      for (final t in _porEtapa['T17']!) kRefProjeto[t]!.slug,
    ]) {
      final porTela = (kni[slug] as Map<String, dynamic>?) ?? {};
      expect(
        porTela.values.where((v) => (v as Map)['fileiras'] == true),
        isEmpty,
        reason: slug,
      );
    }
  });

  // D-280: o fio de navalha medido no navegador. Os casos em que a estimativa da G01 errava, amarrados às caixas
  // medidas: (a) a 3ª dica da 28c é um <li> flex com a seta como outro item — a linha vai da seta (33,5) ao fim do "de"
  // (313,93): 280,43 dos 323 do <li>, e o "barras" passaria 0,45; (b) a meta da 42 tem um <strong> em 700 no texto em
  // 600 — a linha 1 tem 258,75 dos 260,4 da caixa (sobra 1,65, fora do limite; a estimativa dava 3,44); (c) a linha
  // de números do Perfil dá a largura da própria caixa (o <span> cresce com ela) e "Mrs.<br>Dalloway" tem a quebra
  // imposta: nenhum dos dois é fio. Em toda entrada de texto, disponível = largura + sobra.
  test('D-280: o fio de navalha medido no navegador', () {
    final kni = _json('$_layout/knife_edges.json');
    Map<String, dynamic> entrada(String slug, String id) =>
        (kni[slug] as Map<String, dynamic>)[id] as Map<String, dynamic>;

    final dica = kRefProjeto['28c']!.elements['bu28c.tips.tip3']!;
    final seta = kRefProjeto['28c']!.elements['bu28c.tips.tip3.arrow']!;
    final l1 =
        (entrada('028c_busca_nada_encontrado', 'bu28c.tips.tip3')['linhas']
                    as List)
                .first
            as Map;
    expect(
      l1['largura'],
      closeTo(dica.lines.first.right - seta.rect.left, 0.006),
    );
    expect(l1['disponivel'], closeTo(dica.rect.width, 0.006));
    expect(l1['estouroComProxima'], closeTo(0.453, 1e-9));

    final meta = kRefProjeto['42']!.elements['sc42.sheet.goal.text']!;
    final m = entrada('042_scanner_na_estante', 'sc42.sheet.goal.text');
    expect(m['composto'], isTrue);
    final m1 = (m['linhas'] as List).first as Map;
    expect(
      m1['largura'],
      closeTo(meta.linesAll.first.right - meta.rect.left, 0.006),
    );
    expect(m1['sobra'], closeTo(meta.rect.width - m1['largura'], 0.006));
    expect(m1['sobra'], greaterThan(1.5));
    expect((m['riscos'] as List).map((r) => (r as Map)['linha']).toList(), [2]);

    final perfil = (kni['005_perfil'] as Map<String, dynamic>?) ?? {};
    expect(perfil, isEmpty);
    final stats = kRefProjeto['05']!.elements['p05.hero.stats.text']!;
    final linha1 = stats.linesAll.first;
    expect(linha1.right - linha1.left, closeTo(stats.rect.width, 0.006));
    expect(
      _texts(
        kRefProjeto['05']!
            .elements['p05.reading.grid.book2.cover.title']!
            .lines,
      ),
      ['Mrs.', 'Dalloway'],
    );

    for (final s in kni.entries) {
      for (final e in (s.value as Map<String, dynamic>).entries) {
        final v = e.value as Map<String, dynamic>;
        if (v['fileiras'] == true) continue;
        for (final l in (v['linhas'] as List).cast<Map>()) {
          if (l['sobra'] == null) continue;
          expect(
            l['disponivel'],
            closeTo(l['largura'] + l['sobra'], 0.0015),
            reason: '${e.key}:${l['linha']}',
          );
        }
      }
    }
  });

  // R4 (telas irmãs) — as Notificações: a 30c tem o topo e o título da 30 no mesmo lugar ("marcar tudo como lido" só
  // fica apagado: opacidade 0,35, que a referência não guarda); os Lembretes e avisos (30b) têm só o voltar.
  test('Notificações: o topo e o título da 30 na 30c e o voltar na 30b', () {
    final a = _de('30'), c = _de('30c'), b = _de('30b');
    final topo = a.keys.where((k) => _em(k, ['top'])).toList();
    expect(topo.length, 8);
    for (final k in [...topo, 'headline', 'headline.serif']) {
      expect(c[k]!.rect, a[k]!.rect, reason: k);
    }
    expect(_texts(c['headline.serif']!.lines), ['por aqui.']);
    expect(b.keys.where((k) => _em(k, ['top'])).toList(), [
      'top',
      'top.back',
      'top.back.icon',
    ]);
    for (final k in ['top', 'top.back', 'top.back.icon']) {
      expect(b[k]!.rect, a[k]!.rect, reason: k);
    }
  });

  // A Conta, a Excluir conta e a Privacidade têm o mesmo voltar (num <header>); o da 06 (num <div> dentro do <main>)
  // fica no mesmo lugar. Nas Notificações o voltar fica 4 mais à esquerda e 4 mais acima (16, 54).
  test('Ajustes: o voltar da 58, 59 e 56', () {
    final a = _de('58');
    for (final t in ['59', '56']) {
      for (final k in ['top', 'top.back', 'top.back.icon']) {
        expect(_de(t)[k]!.rect, a[k]!.rect, reason: '$t $k');
      }
    }
    expect(_de('06')['top.back']!.rect, a['top.back']!.rect);
    expect(
      _de('30')['top.back']!.rect,
      a['top.back']!.rect.shift(const Offset(-4, -4)),
    );
  });

  // 06 × 05: a navegação e o degradê com a aba Perfil marcada são os mesmos, presos ao fundo (2400 × 2510: −110).
  test('06 × 05: a mesma navegação, presa ao fundo', () {
    final a = _de('05'), b = _de('06');
    final ks = a.keys.where((k) => _em(k, ['nav', 'bottomFade'])).toList();
    expect(ks.length, 18);
    for (final k in ks) {
      expect(b[k]!.rect, a[k]!.rect.shift(const Offset(0, -110)), reason: k);
      expect(_texts(b[k]!.lines), _texts(a[k]!.lines), reason: k);
    }
  });

  // 65 × 64: a troca de um dos 4 livros abre por cima da edição — o topo e a prévia ao vivo ficam iguais; o
  // escurecido cobre o quadro inteiro e a folha começa 150 abaixo do topo.
  test('65 × 64: o topo e a prévia iguais embaixo da folha', () {
    final a = _de('64'), b = _de('65');
    final ks = a.keys.where((k) => _em(k, ['top', 'preview'])).toList();
    expect(ks.length, 19);
    for (final k in ks) {
      expect(b[k]!.rect, a[k]!.rect, reason: k);
      expect(_texts(b[k]!.lines), _texts(a[k]!.lines), reason: k);
    }
    expect(b['scrim']!.rect, const Rect.fromLTWH(0, 0, 390, 844));
    expect(b['sheet']!.rect.top, 150);
    expect(b['sheet']!.rect.left, 10);
    expect(b['sheet']!.rect.right, 380);
  });

  // As chaves liga/desliga têm dois desenhos no projeto: nos Lembretes (30b) e nos Ajustes (06), 54 × 32 com a
  // bolinha de 24 (ligada à direita, com o visto); na Conta (58) e na Privacidade (56), 52 × 32 com a bolinha de 23
  // (ligada à direita, sem visto: o trilho fica preto e a bolinha na cor da marca) — armadilha para a T17.
  test('as chaves: dois desenhos', () {
    const chaves = <String, Map<String, bool>>{
      '30b': {
        'reading.head': true,
        'reading.smart': true,
        'topics.club': true,
        'topics.polls': true,
        'topics.achievements': true,
        'topics.streak': false,
        'topics.social': false,
        'quiet.head': true,
      },
      '06': {
        'reading.screenOn': true,
        'goals.reminder': true,
        'goals.streak': true,
      },
      '58': {'sync.list.offline': true},
      '56': {'people.list.findByEmail': false},
    };
    for (final t in chaves.keys) {
      final m = _de(t);
      final todas = m.keys.where((k) => k.endsWith('.switch')).toSet();
      expect(todas, {for (final k in chaves[t]!.keys) '$k.switch'}, reason: t);
      final grande = t == '30b' || t == '06';
      for (final e in chaves[t]!.entries) {
        final sw = m['${e.key}.switch']!.rect;
        final th = m['${e.key}.switch.thumb']!.rect;
        final r = '$t ${e.key}';
        expect(sw.width, closeTo(grande ? 54 : 52, 1e-6), reason: r);
        expect(sw.height, closeTo(32, 1e-6), reason: r);
        expect(th.width, closeTo(grande ? 24 : 23, 1e-6), reason: r);
        expect(th.height, closeTo(grande ? 24 : 23, 1e-6), reason: r);
        final dx = e.value ? (grande ? 26.0 : 24.5) : (grande ? 4.0 : 4.5);
        expect(th.left - sw.left, closeTo(dx, 1e-9), reason: r);
        expect(th.top - sw.top, closeTo(grande ? 4 : 4.5, 1e-9), reason: r);
        expect(
          m.containsKey('${e.key}.switch.thumb.icon'),
          grande && e.value,
          reason: r,
        );
      }
    }
  });

  // Os avisos da 30: os dois de hoje que pedem ação vêm em cartão (borda de 1,5 e margem de 10 acima), os outros em
  // lista; o ícone é sempre 44 × 44 e o texto começa 12 depois dele. A margem do cartão atravessa o <li> (colapsa):
  // o cartão começa junto com o item, os 10 ficam entre um item e outro, e no 1º se juntam aos 10 de baixo do
  // rótulo "Hoje" (10, não 20).
  test('30: os avisos em cartão e em lista', () {
    final m = _de('30');
    final itens = [
      for (var i = 1; i <= 4; i++) 'today.list.item$i',
      for (var i = 1; i <= 3; i++) 'week.list.item$i',
    ];
    for (final it in itens) {
      final card = m['$it.card']!.rect, icon = m['$it.icon']!.rect;
      final cartao = it == 'today.list.item1' || it == 'today.list.item2';
      expect(icon.size, const Size(44, 44), reason: it);
      expect(icon.left - card.left, cartao ? 13.5 : 12, reason: it);
      expect(icon.top - card.top, cartao ? 13.5 : 12, reason: it);
      expect(m['$it.textBlock']!.rect.left, icon.right + 12, reason: it);
      expect(card.top, m[it]!.rect.top, reason: it);
    }
    for (var i = 1; i < itens.length; i++) {
      if (itens[i].startsWith('week') != itens[i - 1].startsWith('week')) {
        continue;
      }
      expect(
        m[itens[i]]!.rect.top - m[itens[i - 1]]!.rect.bottom,
        closeTo(itens[i] == 'today.list.item2' ? 10 : 0, 1e-6),
        reason: itens[i],
      );
    }
    for (final sec in ['today', 'week']) {
      expect(
        m['$sec.list']!.rect.top - m['$sec.label']!.rect.bottom,
        closeTo(10, 1e-6),
        reason: sec,
      );
      expect(m['$sec.list']!.rect.top, m['$sec.list.item1']!.rect.top);
    }
    expect(m.containsKey('today.list.item1.time.unread'), isTrue);
    expect(m.containsKey('today.list.item2.time.unread'), isTrue);
    expect(m.keys.where((k) => k.endsWith('.time.unread')).length, 2);
  });

  // 05 · a estante do ano: 24 lombadas e 6 vagas tracejadas, todas da mesma largura (flex 1 1 0: os 311 menos 4 + 4
  // de recuo e 29 vãos de 2, divididos por 30 = 8,1667) e apoiadas na tábua; as alturas são as da prancha. O JSON
  // guarda duas casas, então cada borda tem até 0,005 de arredondamento.
  test('05: a estante de 2026', () {
    final m = _de('05');
    const alturas = [
      44,
      39,
      47,
      41,
      45,
      38,
      46,
      42,
      40,
      47,
      43,
      39,
      45,
      41,
      46,
      38,
      44,
      42,
      47,
      40,
      43,
      45,
      39,
      46,
    ];
    final livros = [
      for (var i = 1; i <= 24; i++) m['year.shelf.books.book$i']!.rect,
    ];
    final vagas = [
      for (var i = 1; i <= 6; i++) m['year.shelf.books.slot$i']!.rect,
    ];
    final todos = [...livros, ...vagas];
    final fileira = m['year.shelf.books']!.rect;
    final largura = (fileira.width - 8 - 29 * 2) / 30;
    for (var i = 0; i < todos.length; i++) {
      expect(todos[i].width, closeTo(largura, 0.0051), reason: '$i');
      expect(
        todos[i].left,
        closeTo(fileira.left + 4 + i * (largura + 2), 0.0051),
        reason: '$i',
      );
      expect(todos[i].bottom, closeTo(todos.first.bottom, 1e-6), reason: '$i');
    }
    expect([for (final r in livros) r.height], alturas);
    expect(vagas.every((r) => r.height == 44), isTrue);
    // as lombadas apoiadas no fundo da fileira (align-items: flex-end) e a tábua subindo 1,2 por cima delas
    expect(todos.first.bottom, closeTo(fileira.bottom, 1e-6));
    expect(
      m['year.shelf.plank']!.rect.top,
      closeTo(fileira.bottom - 1.2, 1e-6),
    );
  });

  // 18: o cronômetro é uma coluna centrada em x = 195 — o relógio de 300 com o anel e o miolo do mesmo tamanho, o
  // estado, o tempo, o "Hoje", as etiquetas, o anotar e o aviso; o "SESSÃO 7" fica no meio do vão entre os dois
  // botões do topo. De cima para baixo, 18 entre o topo, o livro, o relógio e as etiquetas; os controles descem para
  // perto do fundo, com 14 até o anotar e até o aviso, que termina 34 acima do fundo. Os três controles se alinham
  // pelo topo, com 40 entre eles: o grupo tem 86 de largura, o botão é de 58 (o do meio, de 86), o ícone fica no centro
  // do botão e o rótulo 8 abaixo.
  test('18: o relógio, as etiquetas e os três controles', () {
    final m = _de('18');
    expect(m['timer']!.rect, const Rect.fromLTWH(45, 211, 300, 300));
    expect(m['timer.ring']!.rect, m['timer']!.rect);
    expect(m['timer.center']!.rect, m['timer']!.rect);
    for (final k in [
      'timer.status',
      'timer.time',
      'timer.today',
      'chips',
      'note',
      'lockHint',
    ]) {
      expect(m[k]!.rect.center.dx, closeTo(195, 0.01), reason: k);
    }
    expect(
      m['top.session']!.rect.center.dx,
      closeTo(
        (m['top.minimize']!.rect.right + m['top.sound']!.rect.left) / 2,
        0.01,
      ),
    );
    final ordem = ['top', 'book', 'timer', 'chips'];
    for (var i = 1; i < ordem.length; i++) {
      expect(
        m[ordem[i]]!.rect.top - m[ordem[i - 1]]!.rect.bottom,
        closeTo(18, 1e-6),
        reason: ordem[i],
      );
    }
    final fundo = ['controls', 'note', 'lockHint'];
    for (var i = 1; i < fundo.length; i++) {
      expect(
        m[fundo[i]]!.rect.top - m[fundo[i - 1]]!.rect.bottom,
        closeTo(14, 0.011),
        reason: fundo[i],
      );
    }
    expect(m['lockHint']!.rect.bottom, closeTo(844 - 34, 1e-6));

    const botoes = {'photo': 58.0, 'pause': 86.0, 'end': 58.0};
    final nomes = botoes.keys.toList();
    final linha = m['controls']!.rect;
    for (var i = 0; i < nomes.length; i++) {
      final n = nomes[i];
      final g = m['controls.$n']!.rect, b = m['controls.$n.button']!.rect;
      final ic = m['controls.$n.icon']!.rect, l = m['controls.$n.label']!.rect;
      expect(g.width, 86, reason: n);
      expect(g.top, linha.top, reason: n);
      if (i > 0) {
        expect(
          g.left - m['controls.${nomes[i - 1]}']!.rect.right,
          closeTo(40, 1e-9),
          reason: n,
        );
      }
      expect(b.size, Size(botoes[n]!, botoes[n]!), reason: n);
      expect(b.top, g.top, reason: n);
      expect(b.center.dx, closeTo(g.center.dx, 1e-9), reason: n);
      expect(ic.center.dx, closeTo(b.center.dx, 1e-9), reason: n);
      expect(ic.center.dy, closeTo(b.center.dy, 1e-6), reason: n);
      expect(l.top, closeTo(b.bottom + 8, 1e-6), reason: n);
      expect(l.center.dx, closeTo(g.center.dx, 0.01), reason: n);
      expect(g.bottom, closeTo(l.bottom, 1e-6), reason: n);
    }
    // o do meio no centro da tela e o conjunto centrado nos 350: 6 de cada lado
    expect(m['controls.pause']!.rect.center.dx, 195);
    expect(m['controls.photo']!.rect.left - linha.left, closeTo(6, 1e-9));
    expect(linha.right - m['controls.end']!.rect.right, closeTo(6, 1e-9));
  });

  // 18b × 18: o fim da sessão abre por cima do cronômetro, que fica igual por baixo do escurecido — os mesmos 43 ids,
  // caixas e textos; só mudam o tempo (08:42 → 12:31) e os minutos de hoje (26 → 30: o "30" é 0,54 mais largo e a
  // linha "Hoje: 30 de 30 min" cresce o mesmo, continuando centrada). Nada muda de altura com o texto e não há fio de
  // navalha nas duas.
  test('18b × 18: o cronômetro igual por baixo da folha', () {
    final a = _de('18'), b = _de('18b');
    const secoes = [
      'top',
      'book',
      'timer',
      'chips',
      'controls',
      'note',
      'lockHint',
    ];
    final ks = a.keys.toList();
    expect(ks.length, 43);
    expect(b.keys.where((k) => _em(k, secoes)).toList(), ks);
    final ra = kRefProjeto['18']!, rb = kRefProjeto['18b']!;
    expect(
      [for (final s in secoes) rb.sections['${rb.prefix}.$s']],
      [for (final s in secoes) ra.sections['${ra.prefix}.$s']],
    );
    const mudam = {'timer.today', 'timer.today.minutes'};
    for (final k in ks) {
      if (!mudam.contains(k)) expect(b[k]!.rect, a[k]!.rect, reason: k);
      expect(b[k]!.visual, a[k]!.visual, reason: k);
      if (k != 'timer.time' && k != 'timer.today.minutes') {
        expect(_texts(b[k]!.lines), _texts(a[k]!.lines), reason: k);
      }
    }
    expect(_texts(a['timer.time']!.lines), ['08:42']);
    expect(_texts(b['timer.time']!.lines), ['12:31']);
    expect(_texts(a['timer.today.minutes']!.lines), ['26']);
    expect(_texts(b['timer.today.minutes']!.lines), ['30']);
    for (final m in [a, b]) {
      expect(m['timer.today']!.rect.top, 403.5);
      expect(m['timer.today']!.rect.center.dx, closeTo(195, 0.01));
    }
    final cresce =
        b['timer.today.minutes']!.rect.width -
        a['timer.today.minutes']!.rect.width;
    expect(cresce, closeTo(0.54, 1e-6));
    expect(
      b['timer.today']!.rect.width - a['timer.today']!.rect.width,
      closeTo(cresce, 0.011),
    );
    for (final r in [ra, rb]) {
      expect(r.textDependentY, isEmpty, reason: r.slug);
      expect(r.knifeEdges, isEmpty, reason: r.slug);
    }
    // na 18b dependem do texto os mesmos 24 da 18 e mais 7 da folha
    Set<String> dep(LeitorRefPrancha r, List<String> onde) => {
      for (final id in r.textDependentX)
        if (_em(_sem(r.prefix, id), onde)) _sem(r.prefix, id),
    };
    expect(dep(ra, secoes).length, 24);
    expect(dep(rb, secoes), dep(ra, secoes));
    expect(dep(rb, ['sheet']), {
      'sheet.title.serif',
      'sheet.pageHeader.label',
      'sheet.pageHeader.optional',
      'sheet.page.field.prefix',
      'sheet.page.field.value',
      'sheet.progress.added',
      'sheet.save.label',
    });
  });

  // 18b: o escurecido cobre o quadro; a folha vai de ponta a ponta até o fundo, com a alça de 44 × 5 centrada 13,5
  // abaixo da borda e o conteúdo com 20 de margem. O selo da meta (104 × 104, girado em volta do centro) passa da
  // borda da folha para cima. Os três números têm a mesma largura, com 8 entre eles: o ícone redondo de 30 a 11,5 e
  // 13,5 da borda (o desenho de 16 no centro), o valor 6 abaixo e o rótulo 6 abaixo do valor. A página fica entre os
  // dois botões de 52, com 10 de cada lado e os três centrados na altura do campo (64); "pág." e o número centrados
  // juntos no campo, 8 entre eles. O input escondido é de 1 px, mas o navegador dá a ele a borda e o recuo padrão
  // (9 × 7) e, absoluto num flex sem posição, o põe no centro do campo — não segue o número. O salvar (54) e o pular
  // (44) embaixo, 6 entre eles, e o pular termina 34 acima do fundo.
  test('18b: o escurecido, a folha e os três números', () {
    final m = _de('18b');
    expect(m['scrim']!.rect, const Rect.fromLTWH(0, 0, 390, 844));
    final folha = m['sheet']!.rect;
    expect(folha.left, 0);
    expect(folha.right, 390);
    expect(folha.bottom, closeTo(844, 1e-9));
    final alca = m['sheet.handle']!.rect;
    expect(alca.size, const Size(44, 5));
    expect(alca.center.dx, 195);
    expect(alca.top - folha.top, closeTo(13.5, 1e-6));
    final selo = m['sheet.stamp']!;
    expect(selo.rect.size, const Size(104, 104));
    expect(selo.rect.top, lessThan(folha.top));
    expect(selo.visual!.width, greaterThan(104));
    expect(selo.visual!.center.dx, closeTo(selo.rect.center.dx, 0.011));
    expect(selo.visual!.center.dy, closeTo(selo.rect.center.dy, 0.011));
    for (final k in [
      'sheet.label',
      'sheet.title',
      'sheet.stats',
      'sheet.pageHeader',
      'sheet.page',
      'sheet.progress',
      'sheet.save',
      'sheet.skip',
    ]) {
      expect(m[k]!.rect.left, 20, reason: k);
      expect(m[k]!.rect.right, 370, reason: k);
    }

    final stats = m['sheet.stats']!.rect;
    const largura = (350 - 2 * 8) / 3;
    const numeros = ['session', 'today', 'streak'];
    for (var i = 0; i < numeros.length; i++) {
      final p = 'sheet.stats.${numeros[i]}';
      final c = m[p]!.rect, ic = m['$p.icon']!.rect;
      final art = m['$p.icon.art']!.rect;
      final v = m['$p.value']!.rect, l = m['$p.label']!.rect;
      expect(c.width, closeTo(largura, 0.0051), reason: p);
      expect(c.left, closeTo(20 + i * (largura + 8), 0.0051), reason: p);
      expect(c.top, stats.top, reason: p);
      expect(c.height, stats.height, reason: p);
      expect(ic.size, const Size(30, 30), reason: p);
      expect(ic.left - c.left, closeTo(11.5, 1e-6), reason: p);
      expect(ic.top - c.top, closeTo(13.5, 1e-6), reason: p);
      expect(art.size, const Size(16, 16), reason: p);
      expect(art.center.dx, closeTo(ic.center.dx, 1e-6), reason: p);
      expect(art.center.dy, closeTo(ic.center.dy, 1e-6), reason: p);
      for (final t in [v, l]) {
        expect(t.left, ic.left, reason: p);
        expect(t.width, closeTo(c.width - 23, 0.0051), reason: p);
      }
      expect(v.top, closeTo(ic.bottom + 6, 1e-6), reason: p);
      expect(l.top, closeTo(v.bottom + 6, 1e-6), reason: p);
    }
    expect(
      [for (final n in numeros) _texts(m['sheet.stats.$n.value']!.lines)],
      [
        ['12:31'],
        ['30/30'],
        ['12 dias'],
      ],
    );

    final ant = m['sheet.page.prev']!.rect, prox = m['sheet.page.next']!.rect;
    final campo = m['sheet.page.field']!.rect;
    expect(ant.size, const Size(52, 52));
    expect(prox.size, const Size(52, 52));
    expect(campo.height, 64);
    expect(campo.left - ant.right, closeTo(10, 1e-9));
    expect(prox.left - campo.right, closeTo(10, 1e-9));
    for (final r in [ant, prox]) {
      expect(r.center.dy, closeTo(campo.center.dy, 1e-6));
    }
    for (final k in ['prev', 'next']) {
      final ic = m['sheet.page.$k.icon']!.rect, b = m['sheet.page.$k']!.rect;
      expect(ic.size, const Size(18, 18), reason: k);
      expect(ic.center.dx, closeTo(b.center.dx, 1e-6), reason: k);
      expect(ic.center.dy, closeTo(b.center.dy, 1e-6), reason: k);
    }
    final pre = m['sheet.page.field.prefix']!.rect;
    final numero = m['sheet.page.field.value']!.rect;
    expect((pre.left + numero.right) / 2, closeTo(campo.center.dx, 0.011));
    expect(numero.left - pre.right, closeTo(8, 0.011));
    final input = m['sheet.page.field.input']!.rect;
    expect(input.size, const Size(9, 7));
    expect(input.center.dx, closeTo(campo.center.dx, 1e-6));
    expect(input.center.dy, closeTo(campo.center.dy, 1e-6));

    final salvar = m['sheet.save']!.rect, pular = m['sheet.skip']!.rect;
    expect(salvar.height, 54);
    expect(pular.height, 44);
    expect(pular.top - salvar.bottom, closeTo(6, 1e-9));
    expect(pular.bottom, closeTo(844 - 34, 1e-9));
    expect(m['sheet.save.label']!.rect.center.dx, closeTo(195, 0.011));
    expect(_texts(m['sheet.skip']!.lines), ['Pular a página']);
  });
}
