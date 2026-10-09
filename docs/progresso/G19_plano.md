# G19 — Grifos e notas (tela 25): plano de implementação

> **Para quem executa:** execução inline (superpowers:executing-plans), uma tarefa por vez, TDD: o teste falha no
> Windows (RED), o código mínimo passa (GREEN), commit pequeno. Passos com `- [ ]`.

**Objetivo:** a tela 25 idêntica à prancha e funcionando com dados reais:
- os cartões por `group_id` na ordem do livro, com separadores de página e "você parou aqui";
- as miniaturas de tinta;
- os filtros (tipo, cores, clube) e a busca FTS5;
- "Mais opções" e Exportar (D-192–D-194);
- o fim e os vazios (D-198) e os grifos sem lugar (D-199);
- a rota real `/livro/:bookId/destaques`, com os saltos para o leitor (D-195, R13).

**Arquitetura:**
- **Domínio** (`lib/features/highlights/domain/`, Dart puro):
  - `highlight_card.dart`: cartões, rótulo e rótulo do leitor de tela (R4);
  - `card_text.dart`: os trechos do cartão (D-49 + R3);
  - `card_filters.dart`: cor por item (R2), fileira (D-196), filtros (D-197);
  - `card_dates.dart`: R5;
  - `list_entries.dart`: separadores, "você parou aqui" (R6) e sem lugar;
  - `highlights_export.dart`: Markdown e CSV (R9).
- **Dados** (`lib/features/highlights/application/`):
  - `highlights_repository.dart`: observar, buscar, apagar o grupo e desfazer, trocar a cor, a nota;
  - `card_text_source.dart`: o texto dos capítulos num isolate, com cache, reancoramento e recuo;
  - `highlights_club_source.dart`;
  - `highlights_controller.dart`;
  - `highlights_providers.dart`.
- A regra da nota (D-131/D-138) sai do `ReaderAnnotations` para
  `lib/features/reader/annotations/domain/note_rules.dart`, usada pelos dois.
- **Tela** (`lib/features/highlights/presentation/`):
  - `highlights_screen.dart` (a `CustomScrollView`);
  - `highlights_top.dart` (L25a);
  - `highlight_filters.dart` (L25b);
  - `page_separator.dart` e `highlight_card.dart` (L25c);
  - `ink_thumbnail.dart` (R10);
  - `highlights_end.dart` (L25d, D-198);
  - `highlight_more_sheet.dart` (D-192);
  - `highlight_export_sheet.dart` (D-194);
  - `highlights_file_sink.dart` (gravar e compartilhar).
- **Leitor e rotas:**
  - `AppRoutes.destaques(bookId, {fromReader})` e `AppRoutes.leitor(bookId, {goTo})`;
  - o botão Grifos abre a 25 e espera o `HighlightsExit`;
  - o `ReaderScreen` aceita `goTo` (o `?ir=`).

**Pilha:** Flutter/Dart, drift (FTS5), flutter_riverpod, go_router, share_plus, path_provider, flutter_test, goldens @3x, `tools/compare_images.py`.

**Execução e ambiente (igual à G18):**
- Código escrito no espelho `/home/claude/g03/repo` e levado ao Windows por `ciclo.sh` + `expandir.ps1`.
- No Windows: `dart format`, `dart analyze` e `flutter test <arquivo>`. Os arquivos formatados voltam por `puxar.sh`.
- Commits pequenos (`tools/medicao/tmp/commits_g19<letra>.ps1` + `msg_g19_NN.txt`, gerados por `novo_commit19.sh`).
  - Mensagem `tipo(escopo): descrição` em português, com o rodapé `Co-Authored-By` e `Claude-Session`.
  - Leituras do git com `git --no-optional-locks`; nenhum `index.lock` fica.
- Spec: `docs/progresso/G19.md` (D-192…D-200, regras R1…R14). As seções do desenho são citadas como §1…§9.
- Branch `feat/g19-grifos-notas`, base `d541e11` (a spec é o `7a018e8`).

## Arquivos

| Arquivo | Responsabilidade | Tarefa |
|---|---|---|
| `lib/features/highlights/domain/highlight_card.dart` (novo) | `HighlightCard`, `buildCards`, R4 | 1 |
| `lib/features/highlights/domain/card_text.dart` (novo) | D-49 + R3, recuo pela âncora | 2 |
| `lib/features/highlights/domain/card_filters.dart` (novo) | R2, D-196, D-197, `TypeFilter` | 3 |
| `lib/features/highlights/domain/card_dates.dart`, `list_entries.dart` (novos) | R5, R6, D-199 | 4 |
| `lib/features/highlights/domain/highlights_export.dart` (novo), `lib/features/reader/application/toc_view.dart` | R9, `chapterLabels` | 5 |
| `lib/features/reader/annotations/domain/note_rules.dart` (novo), `reader_annotations.dart` | a regra da nota compartilhada | 6 |
| `lib/features/highlights/application/highlights_repository.dart` (novo) | observar, buscar, apagar/desfazer, cor, nota | 7 |
| `lib/features/highlights/application/card_text_source.dart`, `highlights_club_source.dart` (novos) | texto dos capítulos, sem lugar, clube | 8 |
| `lib/features/highlights/application/highlights_controller.dart`, `highlights_providers.dart` (novos) | estado da tela, busca, Desfazer, deps | 9 |
| `test/support/dados_t25.dart`, `fase_l25.dart` (novos) | o mundo da tela 25 e a abertura | 10 |
| `pubspec.yaml`, `app_typography.dart`, `app_icons_leitor.dart`, `app_colors.dart` | Literata 16,5, ícones, cores e estilos `hl*` | 11 |
| `lib/app/router.dart`, `routes.dart`, `highlights_screen.dart`, `highlights_top.dart` (novos) | rota real, a tela, topo e busca (L25a) | 12 |
| `lib/features/highlights/presentation/highlight_filters.dart` (novo) | L25b | 13 |
| `page_separator.dart`, `highlight_card.dart` (novos) | L25c.1–L25c.2 | 14 |
| `highlight_card.dart` | post-it e chip (L25c.3–L25c.4) | 15 |
| `ink_thumbnail.dart` (novo) | R10 e o cache (L25c.5) | 16 |
| `highlights_end.dart` (novo) | fim, vazios, sem lugar | 17 |
| `highlight_more_sheet.dart` (novo) | D-192, D-193, R11 | 18 |
| `highlight_export_sheet.dart`, `highlights_file_sink.dart` (novos) | D-194, R12 | 19 |
| `reader_screen.dart`, `routes.dart`, `router.dart` | R13, D-195, `?ir=`, Grifos | 20 |
| `test/features/highlights/presentation/l25a_test.dart` … `l25d_test.dart`, `test/golden/leitor_25_test.dart` (novos) | fases e golden | 21 |
| `test/features/highlights/presentation/highlights_screen_test.dart`, `highlights_performance_test.dart` (novos) | comportamento e desempenho | 22 |
| `test/golden/capturas_g19_test.dart` (novo), docs | prova e relatório | 23 |

---

## G19.1 — Domínio

### Tarefa 1: cartões e rótulo (R4)

**Arquivos:**
- criar `lib/features/highlights/domain/highlight_card.dart`;
- teste `test/features/highlights/domain/highlight_card_test.dart`;
- apoio `test/features/highlights/support/ordem_do_livro.dart`.

- [ ] **Passo 1 (RED):**

```dart
// G19.1 — os cartões da tela 25 (D-30) e o rótulo de cada um (R4), contra o mundo de referência.
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/features/highlights/domain/highlight_card.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';
import '../support/ordem_do_livro.dart';

void main() {
  final itens = naOrdemDoLivro(mundoReferencia.anotacoesDo(Slugs.domCasmurro));
  final cartoes = buildCards(itens);

  test('8 cartões, na ordem dos grupos do arquivo (cartoesDaTela25)', () {
    expect(cartoes.map((c) => c.groupId), [
      for (final c in mundoReferencia.cartoesDaTela25) c.grupoId,
    ]);
    expect(cartoes.map((c) => c.page), [3, 6, 41, 121, 152, 159, 159, 159]);
  });

  test('pílulas: GRIFO, GRIFO+NOTA, DESENHO+À MÃO, 2 DESENHOS', () {
    expect(cartoes[0].label, 'GRIFO');
    expect(cartoes[0].dot, '#FED170');
    expect(cartoes[1].hasNotePill, isTrue);
    expect(cartoes[6].label, 'DESENHO');
    expect(cartoes[6].dot, '#FF552E');
    expect(cartoes[6].hasHandPill, isTrue);
    expect(cartoes[7].label, '2 DESENHOS');
    expect(cartoes[5].freehand, isTrue);
  });

  test('rótulos do leitor de tela, como o arquivo', () {
    expect(cartoes.map(cardSemanticsLabel), [
      'Grifo amarelo, página 3',
      'Grifo rosa com nota, página 6',
      'Grifo verde, página 41',
      'Grifo amarelo, página 121',
      'Grifo lavanda com nota, compartilhado no clube, página 152',
      'Grifo à mão livre, página 159',
      'Desenho e nota à mão, página 159',
      'Dois desenhos, página 159',
    ]);
  });

  test('números por extenso até 10, depois algarismos; outra cor; só nota à mão', () {
    expect(drawingsWord(3), 'Três desenhos');
    expect(drawingsWord(10), 'Dez desenhos');
    expect(drawingsWord(11), '11 desenhos');
    final outra = itens.first.copyWith(color: const Nullable('#123456'));
    expect(cardSemanticsLabel(buildCards([outra]).single), 'Grifo de outra cor, página 3');
    final mao = itens.firstWhere((a) => a.kind == AnnotationKind.handwriting);
    final so = buildCards([mao.copyWith(groupId: mao.id)]).single;
    expect((so.label, so.dot, so.hasHandPill), ('À MÃO', null, false));
    expect(cardSemanticsLabel(so), 'Nota à mão, página 159');
  });

  test('data do cartão = a criação mais antiga do grupo', () {
    final c = cartoes[1];
    expect(c.createdAt, c.items.map((a) => a.meta.createdAt).reduce((a, b) => a.isBefore(b) ? a : b));
  });
}
```

`ordem_do_livro.dart`:

```dart
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';

/// A ordem do `AnnotationsDao.forBook`: página, início da âncora, criação, id.
List<Annotation> naOrdemDoLivro(Iterable<Annotation> xs) => [...xs]
  ..sort((a, b) {
    int start(Annotation x) => x.anchor is EpubAnchor ? (x.anchor as EpubAnchor).start : 0;
    for (final c in [
      a.refPage.compareTo(b.refPage),
      start(a).compareTo(start(b)),
      a.meta.createdAt.compareTo(b.meta.createdAt),
      a.id.compareTo(b.id),
    ]) {
      if (c != 0) return c;
    }
    return 0;
  });
```

- [ ] **Passo 2 (GREEN):**

```dart
// G19.1 — os cartões da tela 25: um por `group_id` (D-30, Anexo 02 §4.3), na ordem do 1º item (a do livro), e o
// rótulo de cada um (R4): a pílula principal com a bolinha, as pílulas NOTA e À MÃO e o rótulo do leitor de tela.
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show immutable, listEquals;

import '../../../core/design_system/color/color_names.dart';
import '../../reader/annotations/domain/annotation.dart';

enum CardKind { highlight, drawing, handwriting }

@immutable
final class HighlightCard {
  HighlightCard(this.groupId, List<Annotation> items)
    : assert(items.isNotEmpty),
      items = List.unmodifiable(items);

  final String groupId;

  /// Na ordem do livro.
  final List<Annotation> items;

  int get page => items.first.refPage;

  DateTime get createdAt => items
      .map((a) => a.meta.createdAt)
      .reduce((a, b) => a.isBefore(b) ? a : b);

  List<Annotation> _of(AnnotationKind k) => [
    for (final a in items)
      if (a.kind == k) a,
  ];

  Annotation? get highlight => _of(AnnotationKind.highlight).firstOrNull;
  List<Annotation> get notes => _of(AnnotationKind.note);
  List<Annotation> get drawings => _of(AnnotationKind.drawing);
  List<Annotation> get handwriting => _of(AnnotationKind.handwriting);
  String? get clubPostId =>
      items.map((a) => a.sharedClubPostId).nonNulls.firstOrNull;

  CardKind get kind => highlight != null
      ? CardKind.highlight
      : drawings.isNotEmpty
      ? CardKind.drawing
      : CardKind.handwriting;

  String get label => switch (kind) {
    CardKind.highlight => 'GRIFO',
    CardKind.drawing =>
      drawings.length == 1 ? 'DESENHO' : '${drawings.length} DESENHOS',
    CardKind.handwriting => 'À MÃO',
  };

  /// A cor da bolinha da pílula principal; `null` = sem bolinha (À MÃO).
  String? get dot => switch (kind) {
    CardKind.highlight => highlight!.color,
    CardKind.drawing => drawings.first.color,
    CardKind.handwriting => null,
  };

  bool get hasNotePill => notes.isNotEmpty;
  bool get hasHandPill =>
      kind != CardKind.handwriting && handwriting.isNotEmpty;
  bool get freehand => highlight?.source == AnnotationSource.ink;

  @override
  bool operator ==(Object other) =>
      other is HighlightCard &&
      other.groupId == groupId &&
      listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(groupId, Object.hashAll(items));
}

/// Os cartões de [inBookOrder] (vivos, na ordem do `forBook`), na ordem do 1º item de cada grupo.
List<HighlightCard> buildCards(Iterable<Annotation> inBookOrder) {
  final groups = <String, List<Annotation>>{};
  for (final a in inBookOrder) {
    (groups[a.groupId] ??= []).add(a);
  }
  return [for (final e in groups.entries) HighlightCard(e.key, e.value)];
}

const List<String> _numbers = [
  'Dois', 'Três', 'Quatro', 'Cinco', 'Seis', 'Sete', 'Oito', 'Nove', 'Dez',
];

/// "Desenho", "Dois desenhos"…"Dez desenhos", "11 desenhos".
String drawingsWord(int n) => n == 1
    ? 'Desenho'
    : n <= 10
    ? '${_numbers[n - 2]} desenhos'
    : '$n desenhos';

/// R4: o rótulo do cartão para o leitor de tela.
String cardSemanticsLabel(HighlightCard c) {
  final base = switch (c.kind) {
    CardKind.highlight when c.freehand => 'Grifo à mão livre',
    CardKind.highlight =>
      'Grifo ${markerColorName(c.highlight!.color!) ?? 'de outra cor'}',
    CardKind.drawing => drawingsWord(c.drawings.length),
    CardKind.handwriting => 'Nota à mão',
  };
  final extras = [
    if (c.hasNotePill) 'nota',
    if (c.hasHandPill) 'nota à mão',
  ];
  final joined = switch ((c.kind, extras)) {
    (_, []) => base,
    (CardKind.highlight, _) => '$base com ${extras.join(' e ')}',
    _ => '$base e ${extras.join(' e ')}',
  };
  final club = c.clubPostId == null ? '' : ', compartilhado no clube';
  return '$joined$club, página ${c.page}';
}
```

- [ ] **Passo 3:** verde (`flutter test test/features/highlights/domain/highlight_card_test.dart`). Commit
  `feat(grifos): os cartões da tela 25 por grupo e o rótulo de cada um (R4)`.

### Tarefa 2: o texto do cartão (D-49 + R3)

**Arquivos:** criar `lib/features/highlights/domain/card_text.dart`; teste
`test/features/highlights/domain/card_text_test.dart`.

- [ ] **Passo 1 (RED):**

```dart
import 'package:app_leitura/features/highlights/domain/card_text.dart';
import 'package:flutter_test/flutter_test.dart';

String plano(List<CardSpan> s) => s.map((x) => x.annotationId == null ? x.text : '[${x.text}]').join();

void main() {
  group('contexto (D-49)', () {
    test('a frase inteira cabe em 55: desde o começo dela, sem "…"', () {
      const t = 'Era noite. Traziam não sei que fluido misterioso e enérgico.';
      expect(contextBefore(t, t.indexOf('fluido')), 'Traziam não sei que ');
    });
    test('mais de 55: corta em palavra e começa com "…"', () {
      const t = 'Retórica dos namorados, dá-me uma comparação exata e poética para dizer o que foram aqueles olhos de Capitu.';
      final c = contextBefore(t, t.indexOf('olhos de Capitu'));
      expect(c.startsWith('…'), isTrue);
      expect(c.length - 1 <= 55, isTrue);
      expect(c.substring(1).startsWith(' '), isFalse);
      expect(c.endsWith('aqueles '), isTrue);
    });
    test('começo do parágrafo e começo do texto contam como começo de frase', () {
      const t = 'Fim de um.\nComeço do outro com o grifo';
      expect(contextBefore(t, t.indexOf('grifo')), 'Começo do outro com o ');
      expect(contextBefore('grifo', 0), '');
    });
    test('fim de frase com aspas ou parêntese que fecham', () {
      const t = '— Vá, de ressaca.” E então o grifo';
      expect(contextBefore(t, t.indexOf('o grifo')), 'E então ');
    });
  });

  group('depois do último trecho (R3)', () {
    test('o trecho já acaba a frase: nada', () {
      const t = 'que eu conheço de vista e de chapéu. Um dia, depois';
      expect(tailAfter(t, t.indexOf(' Um')), '');
    });
    test('ponto final logo depois fica', () {
      const t = 'o que foram aqueles olhos de Capitu. Outra frase';
      expect(tailAfter(t, t.indexOf('.')), '.');
    });
    test('vírgula vira "…"', () {
      const t = 'como a vaga que se retira da praia, nos dias de ressaca.';
      expect(tailAfter(t, t.indexOf(' da praia')), ' da praia…');
    });
    test('sem pontuação em 40: corta em palavra e põe "…"', () {
      const t = 'grifo e aqui vem um texto muito comprido sem pontuação nenhuma até o fim';
      final r = tailAfter(t, 5);
      expect(r.endsWith('…'), isTrue);
      expect(r.length - 1 <= 40, isTrue);
      expect(r.substring(0, r.length - 1).endsWith(' '), isFalse);
    });
    test('fim do parágrafo ou do texto: nada', () {
      expect(tailAfter('fim\nnovo', 3), '');
      expect(tailAfter('fim', 3), '');
    });
  });

  test('os trechos de um cartão com dois desenhos (o cartão 8)', () {
    const t = 'Traziam não sei que fluido misterioso e enérgico, uma força que arrastava para dentro, como a vaga que se retira da praia, nos dias de ressaca.';
    final a = t.indexOf('fluido misterioso');
    final b = t.indexOf('a vaga que se retira');
    final s = cardSpans(t, [
      (id: 'o', start: a, end: a + 'fluido misterioso'.length),
      (id: 'd', start: b, end: b + 'a vaga que se retira'.length),
    ]);
    expect(plano(s),
        'Traziam não sei que [fluido misterioso] e enérgico, uma força que arrastava para dentro, como [a vaga que se retira] da praia…');
    expect(s[1].annotationId, 'o');
  });

  test('marca de ponto (nota à mão) estende o trecho até ela, sem marcar', () {
    const t = 'Olhos de ressaca? Vá, de ressaca. O que eles tinham';
    final e = t.indexOf(' Vá');
    final fim = t.indexOf(' O que');
    final s = cardSpans(t, [(id: 'e', start: 0, end: e), (id: 'h', start: fim, end: fim)]);
    expect(plano(s), '[Olhos de ressaca?] Vá, de ressaca.');
  });

  test('sobreposição: o 2º começa onde o 1º acabou', () {
    const t = 'abc def ghi.';
    final s = cardSpans(t, [(id: '1', start: 0, end: 7), (id: '2', start: 4, end: 11)]);
    expect(plano(s), '[abc def][ ghi].');
  });

  test('recuo pela âncora (sem o arquivo): prefixo cortado em palavra com "…", exatos e o sufixo até a pontuação', () {
    final s = spansFromQuotes([
      (id: 'g', prefix: 'is longe, encontrei no trem da Cen', exact: 'tral um rapaz', suffix: ', que eu conheço'),
    ]);
    expect(plano(s), '…encontrei no trem da Cen[tral um rapaz]…');
  });
}
```

- [ ] **Passo 2 (GREEN):**

```dart
// G19.1 — o texto de um cartão da tela 25 (D-49 + R3). O cartão mostra um trecho contínuo do capítulo:
// - o contexto cinza, até 55 caracteres antes do 1º trecho, desde o começo da frase, cortado em palavra, com "…"
//   no começo quando cortado;
// - os trechos marcados e o texto entre eles;
// - depois do último: nada se ele já acaba a frase (ou o parágrafo); senão, até a próxima pontuação, em no máximo 40
//   caracteres (ponto final fica; vírgula, ponto e vírgula e dois-pontos viram "…"; sem pontuação, corte em palavra
//   e "…").
// Sem o arquivo do livro, o recuo usa a citação guardada na âncora (32 de cada lado). Dart puro.

/// Um pedaço do texto do cartão: de um item ([annotationId]) ou cinza/simples (`null`).
typedef CardSpan = ({String text, String? annotationId});

/// Um trecho marcado no texto do capítulo; `start == end` = um ponto (a nota à mão).
typedef CardMark = ({String id, int start, int end});

/// A citação guardada de um item (recuo).
typedef CardQuote = ({String id, String prefix, String exact, String suffix});

const int contextMax = 55;
const int tailMax = 40;
const String _ends = '.?!…';
const String _soft = ',;:';
const String _closers = '"”’»)]';

bool _isSpace(String c) => c == ' ' || c == ' ' || c == '\t';

/// O começo da frase que contém [at]: depois de fim de frase + branco, depois de "\n", ou 0.
int sentenceStart(String text, int at) {
  for (var i = at - 1; i >= 0; i--) {
    final c = text[i];
    if (c == '\n') return i + 1;
    if (_isSpace(c) && i > 0) {
      var j = i - 1;
      while (j > 0 && _closers.contains(text[j])) {
        j--;
      }
      if (_ends.contains(text[j])) {
        var s = i + 1;
        while (s < at && _isSpace(text[s])) {
          s++;
        }
        return s;
      }
    }
  }
  return 0;
}

String contextBefore(String text, int start) {
  final s = sentenceStart(text, start);
  if (start - s <= contextMax) return text.substring(s, start);
  final cut = start - contextMax;
  final k = text.indexOf(' ', cut);
  if (k < 0 || k >= start) return '…';
  return '…${text.substring(k + 1, start)}';
}

String tailAfter(String text, int end) {
  if (end >= text.length || text[end] == '\n') return '';
  var k = end - 1;
  while (k >= 0 && _closers.contains(text[k])) {
    k--;
  }
  if (k >= 0 && _ends.contains(text[k])) return '';
  final stop = end + tailMax < text.length ? end + tailMax : text.length;
  for (var i = end; i < stop; i++) {
    final c = text[i];
    if (c == '\n') return text.substring(end, i);
    if (_ends.contains(c)) {
      var j = i + 1;
      while (j < text.length && _closers.contains(text[j])) {
        j++;
      }
      return text.substring(end, j);
    }
    if (_soft.contains(c)) return '${text.substring(end, i)}…';
  }
  if (stop == text.length) return text.substring(end);
  final window = text.substring(end, stop);
  final w = window.lastIndexOf(' ');
  return '${w > 0 ? window.substring(0, w) : window}…';
}

/// Os trechos do cartão sobre o texto canônico [text] do item, com as [marks] (de qualquer ordem).
List<CardSpan> cardSpans(String text, List<CardMark> marks) {
  if (marks.isEmpty) return const [];
  final ms = [...marks]..sort((a, b) => a.start.compareTo(b.start));
  final out = <CardSpan>[];
  void add(String t, String? id) {
    if (t.isNotEmpty) out.add((text: t, annotationId: id));
  }

  add(contextBefore(text, ms.first.start), null);
  var pos = ms.first.start;
  for (final m in ms) {
    if (m.start > pos) add(text.substring(pos, m.start), null);
    final s = m.start > pos ? m.start : pos;
    if (m.end > s) add(text.substring(s, m.end), m.id);
    if (m.end > pos) pos = m.end;
  }
  add(tailAfter(text, pos), null);
  return out;
}

/// Recuo sem o texto: o contexto sai do prefixo do 1º item; os exatos, separados por " … "; o fim, do sufixo do último.
List<CardSpan> spansFromQuotes(List<CardQuote> quotes) {
  if (quotes.isEmpty) return const [];
  final out = <CardSpan>[];
  final p = quotes.first.prefix;
  final ctx = contextBefore(p, p.length);
  if (ctx.isNotEmpty) {
    out.add((text: ctx.startsWith('…') || sentenceStart(p, p.length) > 0 ? ctx : '…$ctx', annotationId: null));
  }
  for (var i = 0; i < quotes.length; i++) {
    if (i > 0) out.add((text: ' … ', annotationId: null));
    out.add((text: quotes[i].exact, annotationId: quotes[i].id));
  }
  final s = quotes.last.suffix;
  final exact = quotes.last.exact;
  final tail = tailAfter('$exact$s', exact.length);
  if (tail.isNotEmpty) out.add((text: tail, annotationId: null));
  return out;
}
```

> Na prova do recuo, o prefixo de 32 caracteres sem começo de frase vira "…" + o que vem depois do 1º branco
> (`contextBefore` já corta: 32 < 55, então a regra de "…" sai do teste `sentenceStart(p, p.length) > 0`: sem
> começo de frase dentro do prefixo, o texto foi cortado). O teste fixa o caso.

- [ ] **Passo 3:** verde. Commit `feat(grifos): o texto do cartão com o contexto da D-49 e o fim até a pontuação (R3)`.

### Tarefa 3: cor por item, fileira de cores e filtros (R2, D-196, D-197, R1)

**Arquivos:** criar `lib/features/highlights/domain/card_filters.dart`; teste
`test/features/highlights/domain/card_filters_test.dart`.

- [ ] **Passo 1 (RED):** contra o mundo (Dom Casmurro, 12 itens):
  - **R2:**
    - `itemColor(p6nota)` = `#FFC1C6` (a do pai);
    - desenho = `#FF552E`;
    - nota à mão = `null`;
    - grifo minúsculo `#fed170` → `#FED170`.
  - **D-196:**
    - `colorRow(itens)` = 5 escolhas, chaves `yellow, pink, green, lavender, coral`, rótulos `Amarelo, Rosa, Verde,
      Lavanda, Tinta coral`;
    - com um desenho `#552CB7` criado depois: 6ª `c552cb7` "Tinta roxa";
    - com um grifo `#123456`: "Outra cor";
    - livro sem itens: só as 4.
  - **D-197:**
    - Tudo, sem cor, sem clube e sem busca: os 8 cartões;
    - Notas: os cartões 2 e 5 (inteiros);
    - Desenhos: 7 e 8;
    - À mão: 7;
    - Grifos: 1–6;
    - cor Rosa: só o 2 (a nota herda);
    - cor coral: 7 e 8;
    - Rosa + coral: 2, 7, 8;
    - Notas + Amarelo: nenhum (as notas são rosa e lavanda);
    - "Só do clube": o 5;
    - busca com acertos `{p159ondulado.id}`: o 8;
    - busca com acertos vazios: nenhum;
    - `hits == null`: sem busca;
    - nota à mão sozinha num cartão com cor marcada: some.
  - **R1:** `kindCounts(itens)` = (6, 2, 1, 3) e `all` = 12, sem reagir a filtros (a função não recebe filtros).
- [ ] **Passo 2 (GREEN):**

```dart
// G19.1 — a cor de cada item (R2), a fileira COR (D-196), os filtros da tela 25 (D-197) e as contagens (R1).
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show immutable, setEquals;

import '../../../core/design_system/color/color_names.dart';
import '../../reader/annotations/domain/annotation.dart';
import '../../reader/annotations/domain/annotation_stats.dart';
import 'highlight_card.dart';

enum TypeFilter { all, highlights, notes, handwriting, drawings }

AnnotationKind? kindOfFilter(TypeFilter t) => switch (t) {
  TypeFilter.all => null,
  TypeFilter.highlights => AnnotationKind.highlight,
  TypeFilter.notes => AnnotationKind.note,
  TypeFilter.handwriting => AnnotationKind.handwriting,
  TypeFilter.drawings => AnnotationKind.drawing,
};

@immutable
final class HighlightFilters {
  const HighlightFilters({
    this.type = TypeFilter.all,
    this.colors = const {},
    this.clubOnly = false,
    this.query = '',
  });

  final TypeFilter type;

  /// `#RRGGBB` maiúsculo.
  final Set<String> colors;
  final bool clubOnly;
  final String query;

  bool get isDefault =>
      type == TypeFilter.all && colors.isEmpty && !clubOnly && query.trim().isEmpty;

  HighlightFilters copyWith({TypeFilter? type, Set<String>? colors, bool? clubOnly, String? query}) =>
      HighlightFilters(
        type: type ?? this.type,
        colors: colors ?? this.colors,
        clubOnly: clubOnly ?? this.clubOnly,
        query: query ?? this.query,
      );

  @override
  bool operator ==(Object other) =>
      other is HighlightFilters &&
      other.type == type &&
      setEquals(other.colors, colors) &&
      other.clubOnly == clubOnly &&
      other.query == query;

  @override
  int get hashCode => Object.hash(type, Object.hashAllUnordered(colors), clubOnly, query);
}

/// R2: a cor do item — a própria; a nota, a do grifo pai; a nota à mão, nenhuma.
String? itemColor(Annotation a, Map<String, Annotation> byId) => switch (a.kind) {
  AnnotationKind.note => byId[a.parentId]?.color?.toUpperCase(),
  AnnotationKind.handwriting => null,
  _ => a.color?.toUpperCase(),
};

bool itemPasses(Annotation a, HighlightFilters f, Map<String, Annotation> byId, Set<String>? hits) {
  final k = kindOfFilter(f.type);
  if (k != null && a.kind != k) return false;
  if (f.colors.isNotEmpty && !f.colors.contains(itemColor(a, byId))) return false;
  if (f.clubOnly && a.sharedClubPostId == null) return false;
  if (hits != null && !hits.contains(a.id)) return false;
  return true;
}

/// D-197: os cartões em que algum item passa; [hits] = os ids da busca (`null` = sem busca).
List<HighlightCard> filterCards(
  List<HighlightCard> cards,
  HighlightFilters f, {
  Set<String>? hits,
}) {
  final byId = {for (final c in cards) for (final a in c.items) a.id: a};
  return [
    for (final c in cards)
      if (c.items.any((a) => itemPasses(a, f, byId, hits))) c,
  ];
}

typedef ColorChoice = ({String hex, String key, String label});

const List<ColorChoice> _fixed = [
  (hex: '#FED170', key: 'yellow', label: 'Amarelo'),
  (hex: '#FFC1C6', key: 'pink', label: 'Rosa'),
  (hex: '#ABCF82', key: 'green', label: 'Verde'),
  (hex: '#B6ACE4', key: 'lavender', label: 'Lavanda'),
];

const Map<String, String> _inkLabels = {
  '#FF552E': 'Tinta coral',
  '#552CB7': 'Tinta roxa',
  '#058CD7': 'Tinta azul',
  '#00995E': 'Tinta verde',
  '#F2A815': 'Tinta dourada',
  '#1A1714': 'Tinta preta',
};

/// D-196: as 4 do marca-texto e as outras cores do livro, na ordem do primeiro uso.
List<ColorChoice> colorRow(Iterable<Annotation> items) {
  final byId = {for (final a in items) a.id: a};
  final extra = <String>[];
  final byCreation = [...items]..sort((a, b) => a.meta.createdAt.compareTo(b.meta.createdAt));
  for (final a in byCreation) {
    final c = itemColor(a, byId);
    if (c == null || _fixed.any((f) => f.hex == c) || extra.contains(c)) continue;
    extra.add(c);
  }
  return [
    ..._fixed,
    for (final c in extra)
      (
        hex: c,
        key: c == '#FF552E' ? 'coral' : 'c${c.substring(1).toLowerCase()}',
        label: _inkLabels[c] ?? 'Outra cor',
      ),
  ];
}

/// R1: os totais do livro por tipo (os chips).
AnnotationKindCounts kindCounts(List<Annotation> items) => AnnotationStats.countByKind(
  items,
  userBookId: items.firstOrNull?.userBookId ?? '',
);
```

> Se `countByKind` exigir um `userBookId` válido com a lista vazia, devolver `AnnotationKindCounts` zerado direto.
> O teste do livro vazio cobre isso.

- [ ] **Passo 3:** verde. Commit `feat(grifos): a cor de cada item, a fileira de cores e os filtros sobre cartões (D-196, D-197)`.

### Tarefa 4: datas e entradas da lista (R5, R6, D-199)

**Arquivos:** criar `lib/features/highlights/domain/card_dates.dart` e `list_entries.dart`; testes
`card_dates_test.dart` e `list_entries_test.dart` em `test/features/highlights/domain/`.

- [ ] **Passo 1 (RED):**
  - **R5** (fuso −3 h, agora = 20/09/2026 20:00 SP):
    - 20/09 19:41 SP → "hoje";
    - 19/09 23:59 SP → "ontem";
    - 02/09 → "2 set";
    - 15/12/2025 → "15 dez 2025";
    - 21/09 01:00 UTC (= 20/09 22:00 SP) → "hoje";
    - `withYear: true` → "2 set 2026" (sempre com o ano, para a exportação).
  - **R6:**
    - `listEntries(cartões do mundo, herePage: 159)`: `[Page(3,1), Card(1), Page(6,2), Card(2), Page(41,3), Card(3),
      Page(121,4), Card(4), Page(152,5), Card(5), Page(159,6,here), Card(6), Card(7), Card(8)]`;
    - `herePage: 140` (sem cartão): `Page(140, here)` sozinha entre a 121 e a 152, com os números dos separadores
      seguintes recontados (sep6 = 152);
    - `herePage: 300`: no fim;
    - `herePage: 1`: no começo;
    - `herePage: null`: nenhum here;
    - lista vazia: `[]`.
  - **D-199:** `orphanGroups: {grupo do cartão 4}` → o cartão 4 sai da sequência normal e vai para depois de
    `OrphanMark()`, com `orphan: true`; o separador da 121 some se não sobra cartão nela.
- [ ] **Passo 2 (GREEN):**

```dart
// G19.1 — as datas dos cartões (R5), no fuso do aparelho: "hoje", "ontem", "2 set", "2 set 2025".
const List<String> _months = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

DateTime _local(DateTime t, Duration Function(DateTime utc) offsetAt) {
  final u = t.toUtc();
  return u.add(offsetAt(u));
}

String cardDate(
  DateTime at, {
  required DateTime now,
  required Duration Function(DateTime utc) offsetAt,
  bool withYear = false,
}) {
  final d = _local(at, offsetAt);
  final today = _local(now, offsetAt);
  final day = DateTime.utc(d.year, d.month, d.day);
  final t0 = DateTime.utc(today.year, today.month, today.day);
  if (!withYear) {
    if (day == t0) return 'hoje';
    if (day == t0.subtract(const Duration(days: 1))) return 'ontem';
  }
  final base = '${d.day} ${_months[d.month - 1]}';
  return withYear || d.year != today.year ? '$base ${d.year}' : base;
}
```

```dart
// G19.1 — as entradas da lista da tela 25: o separador de cada página (o da posição atual vira "você parou aqui" —
// R6, sozinho quando a página não tem cartão), os cartões e, no fim, os sem lugar (D-199).
import 'package:flutter/foundation.dart' show immutable;

import 'highlight_card.dart';

sealed class ListEntry {
  const ListEntry();
}

@immutable
final class PageMark extends ListEntry {
  const PageMark(this.page, this.n, {this.here = false});
  final int page;

  /// 1, 2, 3… (`hl.list.sep<n>`).
  final int n;
  final bool here;
  @override
  bool operator ==(Object o) => o is PageMark && o.page == page && o.n == n && o.here == here;
  @override
  int get hashCode => Object.hash(page, n, here);
}

@immutable
final class CardItem extends ListEntry {
  const CardItem(this.card, this.n, {this.orphan = false});
  final HighlightCard card;

  /// 1, 2, 3… (`hl.list.card<n>`).
  final int n;
  final bool orphan;
  @override
  bool operator ==(Object o) => o is CardItem && o.card == card && o.n == n && o.orphan == orphan;
  @override
  int get hashCode => Object.hash(card, n, orphan);
}

final class OrphanMark extends ListEntry {
  const OrphanMark();
  @override
  bool operator ==(Object o) => o is OrphanMark;
  @override
  int get hashCode => 0;
}

List<ListEntry> listEntries(
  List<HighlightCard> visible, {
  int? herePage,
  Set<String> orphanGroups = const {},
}) {
  final placed = [for (final c in visible) if (!orphanGroups.contains(c.groupId)) c];
  final orphans = [for (final c in visible) if (orphanGroups.contains(c.groupId)) c];
  final out = <ListEntry>[];
  var sep = 0;
  var card = 0;
  int? last;
  var hereDone = herePage == null || visible.isEmpty;
  for (final c in placed) {
    if (!hereDone && herePage! < c.page) {
      out.add(PageMark(herePage, ++sep, here: true));
      hereDone = true;
    }
    if (c.page != last) {
      final here = c.page == herePage;
      if (here) hereDone = true;
      out.add(PageMark(c.page, ++sep, here: here));
      last = c.page;
    }
    out.add(CardItem(c, ++card));
  }
  if (!hereDone) out.add(PageMark(herePage!, ++sep, here: true));
  if (orphans.isNotEmpty) {
    out.add(const OrphanMark());
    for (final c in orphans) {
      out.add(CardItem(c, ++card, orphan: true));
    }
  }
  return out;
}
```

- [ ] **Passo 3:** verde. Commit `feat(grifos): datas dos cartões, separadores e "você parou aqui" (R5, R6, D-199)`.

### Tarefa 5: Markdown e CSV (R9) e os rótulos dos capítulos

**Arquivos:**
- criar `lib/features/highlights/domain/highlights_export.dart`;
- `lib/features/reader/application/toc_view.dart`: a função pública
  `List<String?> chapterLabels(BookIndex? index)`, o rótulo de cada capítulo pelo índice, com `_chapterLabel` sobre
  as linhas de capítulo do `buildTocView`;
- testes `test/features/highlights/domain/highlights_export_test.dart` e um caso novo em `toc_view_test.dart`.

- [ ] **Passo 1 (RED):**
  - **`exportFileName`:** "Dom Casmurro" → `dom-casmurro-grifos-e-notas.md`; "Memórias Póstumas de Brás Cubas" →
    `memorias-postumas-de-bras-cubas-grifos-e-notas.csv`; título vazio → `livro-grifos-e-notas.md`.
  - **`exportableCount(itens do mundo)`** = 8 (6 grifos + 2 notas).
  - **`markdownOf`** (mundo, agora = 09/10/2026 12:00 SP) começa com:

    ```
    # Dom Casmurro — grifos e notas
    Machado de Assis · exportado em 09/10/2026

    ## pág. 3
    > que eu conheço de vista e de chapéu.

    Grifo amarelo · 2 set 2026
    ```

    - a pág. 6 traz `**Nota:** É o livro todo nessa frase.` logo depois da linha do grifo;
    - a pág. 159 traz só o grifo à mão livre: "Grifo à mão livre · 20 set 2026", sem desenhos nem a nota à mão;
    - termina com uma linha em branco.
  - **`csvOf`:**
    - começa com `﻿`;
    - cabeçalho `pagina;capitulo;tipo;cor;trecho;nota;criado_em`;
    - 6 linhas, todas terminando em `\r\n`;
    - a da pág. 6: `6;cap. II · …;grifo;rosa;O meu fim evidente…;É o livro todo nessa frase.;2026-09-03 20:00`;
    - trecho com `;` ou `"` vai entre aspas, com as aspas dobradas;
    - duas notas no mesmo grifo: `a | b`.
  - **`chapterLabels`:** com o índice de teste, o capítulo 31 é `cap. XXXII · Olhos de ressaca`; sem índice, lista
    vazia.
- [ ] **Passo 2 (GREEN):**

```dart
// G19.1 — a exportação da tela 25 (D-194, R9): grifos e notas de texto, do livro todo, em Markdown e em CSV
// (UTF-8 com BOM, `;`, CRLF — abre direto no Excel brasileiro). Desenhos e notas à mão ficam de fora (o PDF é Pro).
import '../../../core/design_system/color/color_names.dart';
import '../../reader/annotations/domain/annotation.dart';
import '../../reader/domain/locator.dart';
import 'card_dates.dart';

typedef ExportBook = ({String title, String? author});

String exportFileName(String title, String ext) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  final b = StringBuffer();
  for (final ch in title.toLowerCase().split('')) {
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  final slug = b.toString().replaceAll(RegExp('[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
  return '${slug.isEmpty ? 'livro' : slug}-grifos-e-notas.$ext';
}

bool _exportable(Annotation a) => a.kind == AnnotationKind.highlight || a.kind == AnnotationKind.note;

int exportableCount(Iterable<Annotation> items) => items.where(_exportable).length;

String _exact(Annotation a) => switch (a.anchor) {
  EpubAnchor(:final quote) => quote.exact,
  _ => '',
};

String _kindWord(Annotation h) => h.source == AnnotationSource.ink
    ? 'Grifo à mão livre'
    : 'Grifo ${markerColorName(h.color ?? '') ?? 'de outra cor'}';

String _colorWord(Annotation h) => markerColorName(h.color ?? '') ?? (h.color ?? '');

Map<String, List<Annotation>> _notesByParent(Iterable<Annotation> items) {
  final m = <String, List<Annotation>>{};
  for (final a in items) {
    if (a.kind == AnnotationKind.note && a.parentId != null) (m[a.parentId!] ??= []).add(a);
  }
  return m;
}

String markdownOf(
  ExportBook book,
  List<Annotation> inBookOrder, {
  required DateTime now,
  required Duration Function(DateTime utc) offsetAt,
}) {
  final d = now.toUtc().add(offsetAt(now.toUtc()));
  String two(int x) => x.toString().padLeft(2, '0');
  final b = StringBuffer()
    ..writeln('# ${book.title} — grifos e notas')
    ..writeln([
      if (book.author != null && book.author!.isNotEmpty) book.author,
      'exportado em ${two(d.day)}/${two(d.month)}/${d.year}',
    ].join(' · '));
  final notes = _notesByParent(inBookOrder);
  int? page;
  for (final h in inBookOrder.where((a) => a.kind == AnnotationKind.highlight)) {
    if (h.refPage != page) {
      b
        ..writeln()
        ..writeln('## pág. ${h.refPage}');
      page = h.refPage;
    }
    b
      ..writeln('> ${_exact(h)}')
      ..writeln()
      ..writeln('${_kindWord(h)} · ${cardDate(h.meta.createdAt, now: now, offsetAt: offsetAt, withYear: true)}');
    for (final n in notes[h.id] ?? const <Annotation>[]) {
      b.writeln('**Nota:** ${n.noteText}');
    }
  }
  b.writeln();
  return b.toString();
}

String _csvField(String s) =>
    s.contains(RegExp('[;"\r\n]')) ? '"${s.replaceAll('"', '""')}"' : s;

String csvOf(
  List<Annotation> inBookOrder, {
  required List<String?> chapterLabels,
  required Duration Function(DateTime utc) offsetAt,
}) {
  String two(int x) => x.toString().padLeft(2, '0');
  final notes = _notesByParent(inBookOrder);
  final rows = <List<String>>[
    ['pagina', 'capitulo', 'tipo', 'cor', 'trecho', 'nota', 'criado_em'],
  ];
  for (final h in inBookOrder.where((a) => a.kind == AnnotationKind.highlight)) {
    final t = h.meta.createdAt.toUtc().add(offsetAt(h.meta.createdAt.toUtc()));
    rows.add([
      '${h.refPage}',
      h.chapterIndex < chapterLabels.length ? chapterLabels[h.chapterIndex] ?? '' : '',
      h.source == AnnotationSource.ink ? 'grifo à mão livre' : 'grifo',
      _colorWord(h),
      _exact(h),
      [for (final n in notes[h.id] ?? const <Annotation>[]) n.noteText!].join(' | '),
      '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}',
    ]);
  }
  return '﻿${rows.map((r) => r.map(_csvField).join(';')).join('\r\n')}\r\n';
}
```

- [ ] **Passo 3:** verde. Commit `feat(grifos): a exportação em Markdown e CSV e os rótulos dos capítulos (R9)`.

## G19.2 — Dados

### Tarefa 6: a regra da nota compartilhada (D-131/D-138)

**Arquivos:**
- criar `lib/features/reader/annotations/domain/note_rules.dart`;
- `lib/features/reader/application/reader_annotations.dart`: o `_saveNote` e o `_firstNote` passam a chamar a
  função;
- teste `test/features/reader/annotations/domain/note_rules_test.dart`.

- [ ] **Passo 1 (RED):** `planNote(rows, highlightId, text)` devolve o que fazer:
  - `NoteCreate` quando o grifo não tem nota e o texto não é vazio;
  - `NoteEdit(nota mais antiga)` com texto;
  - `NoteDelete(nota mais antiga)` com texto vazio;
  - `null` quando não há nota e o texto é vazio, ou o grifo não existe ou está apagado;
  - "mais antiga" = a ordem `_older` de hoje (criação, depois id). O teste usa duas notas no mesmo grifo.
- [ ] **Passo 2 (GREEN):**

```dart
// G19.2 — a regra da nota de um grifo (D-131/D-138), usada pelo leitor (G13) e pela tela 25: com texto, edita a
// nota mais antiga do grifo ou cria uma; vazia, apaga a mais antiga (o grifo fica). Dart puro.
import 'annotation.dart';

sealed class NotePlan {
  const NotePlan();
}

final class NoteCreate extends NotePlan {
  const NoteCreate(this.parent, this.text);
  final Annotation parent;
  final String text;
}

final class NoteEdit extends NotePlan {
  const NoteEdit(this.note, this.text);
  final Annotation note;
  final String text;
}

final class NoteDelete extends NotePlan {
  const NoteDelete(this.note);
  final Annotation note;
}

int olderFirst(Annotation a, Annotation b) {
  final c = a.meta.createdAt.compareTo(b.meta.createdAt);
  return c != 0 ? c : a.id.compareTo(b.id);
}

/// A nota mais antiga de algum dos [parents].
Annotation? firstNoteOf(Iterable<Annotation> rows, Set<String> parents) {
  Annotation? first;
  for (final a in rows) {
    if (a.kind != AnnotationKind.note || !parents.contains(a.parentId)) continue;
    if (first == null || olderFirst(a, first) < 0) first = a;
  }
  return first;
}

NotePlan? planNote(Iterable<Annotation> rows, Annotation? parent, String text) {
  if (parent == null || parent.meta.isDeleted) return null;
  final t = text.trim();
  final note = firstNoteOf(rows, {parent.id});
  if (t.isEmpty) return note == null ? null : NoteDelete(note);
  return note == null ? NoteCreate(parent, t) : NoteEdit(note, t);
}
```

- No `ReaderAnnotations._saveNote`, um `switch (planNote(...))` grava cada caso com o `_write` de hoje.
- O `_firstNote` e o `_older` passam a usar `firstNoteOf`/`olderFirst`.
- [ ] **Passo 3:** verdes os testes novos e os da G13
  (`test/features/reader/application/reader_annotations_test.dart` e os de nota). Commit
  `refactor(leitor): a regra da nota numa função compartilhada (D-131/D-138)`.

### Tarefa 7: o repositório da tela 25

**Arquivos:** criar `lib/features/highlights/application/highlights_repository.dart`; teste
`test/features/highlights/application/highlights_repository_test.dart` (banco em memória, como o
`reader_annotations_test`).

- [ ] **Passo 1 (RED):**
  - **`watch(livro)`:** emite as anotações vivas na ordem do livro e as camadas vivas delas; reemite depois de uma
    escrita em `annotations` e em `ink_layers`.
  - **`search(livro, 'ressaca')`:** os ids da elipse e da nota à mão (o trecho "Olhos de ressaca?" e "Vá, de
    ressaca."). `search(livro, 'É O LIVRO')` acha a nota da pág. 6 (sem acento e sem caixa). `search(livro, '  ')` =
    `null` (sem busca).
  - **`deleteGroup(grupo do cartão 7)`:**
    - numa transação, a elipse, a nota à mão e as duas camadas (`elipse`, `espaco`) ficam com `deleted_at` e versão
      nova;
    - o `watch` não traz mais o grupo;
    - devolve `RemovedCard` com as 2 anotações e as 2 camadas.
  - **`restore(removido)`:** tudo vivo de novo, com versão maior que a do apagar (`RecordMeta.restored`).
  - **`recolor(p3, '#B6ACE4')`:** só a cor muda, com versão nova; um grifo apagado devolve `false`.
  - **`saveNote(p3, 'nova')`** cria a nota no grupo do p3; `saveNote(p6, '')` apaga a nota da pág. 6 (pela
    `planNote`).
  - **Pro:** com a fila ligada, cada escrita entra na fila (`LocalVersioning`), como no leitor.
- [ ] **Passo 2 (GREEN):**

```dart
// G19.2 — o que a tela 25 lê e grava no banco: as anotações vivas do livro e as camadas delas (relidas a cada
// escrita), a busca FTS5, apagar o cartão inteiro com as camadas (D-193) e desfazer, trocar a cor (no lugar) e a nota
// (D-131/D-138). Cada escrita leva versão (`LocalVersioning`): no Pro, entra na fila; no Grátis, fica no aparelho.
import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/annotation_daos.dart';
import '../../../core/data/model/nullable.dart';
import '../../../core/sync/local_versioning.dart';
import '../../reader/annotations/domain/annotation.dart';
import '../../reader/annotations/domain/ink_layer.dart';
import '../../reader/annotations/domain/note_rules.dart';
// + os imports de Hlc, RecordMeta e do gerador de ids (UuidV7Generator), como no reader_annotations.dart

typedef BookItems = ({List<Annotation> items, Map<String, InkLayer> layers});

final class RemovedCard {
  const RemovedCard(this.annotations, this.layers);
  final List<Annotation> annotations;
  final List<InkLayer> layers;
}

final class HighlightsRepository {
  HighlightsRepository({required this.db, required this.versioning, required this.owner});

  final AppDatabase db;
  final LocalVersioning versioning;
  final Future<String> Function() owner;
  final UuidV7Generator _ids = UuidV7Generator();

  AnnotationsDao get _dao => AnnotationsDao(db);
  InkLayersDao get _layers => InkLayersDao(db);

  Future<BookItems> read(String userBookId) async {
    final items = await _dao.forBook(userBookId);
    final ids = {for (final a in items) if (a.inkLayerId != null) a.inkLayerId!};
    final layers = await _layers.byIds(ids);
    return (items: items, layers: {for (final l in layers) if (!l.meta.isDeleted) l.id: l});
  }

  /// Lê agora e de novo a cada escrita em `annotations` ou `ink_layers`.
  Stream<BookItems> watch(String userBookId) async* {
    yield await read(userBookId);
    await for (final _ in db.tableUpdates(
      TableUpdateQuery.onAllTables([db.annotations, db.inkLayers]),
    )) {
      yield await read(userBookId);
    }
  }

  /// Os ids que a busca acha; `null` = sem busca (só brancos).
  Future<Set<String>?> search(String userBookId, String query) async {
    if (AnnotationsDao.ftsQuery(query) == null) return null;
    return {for (final a in await _dao.search(userBookId, query)) a.id};
  }

  Future<RemovedCard?> deleteGroup(String userBookId, String groupId) async {
    final rows = [for (final a in await _dao.forBook(userBookId)) if (a.groupId == groupId) a];
    if (rows.isEmpty) return null;
    final layerIds = {
      for (final a in rows)
        if ((a.kind == AnnotationKind.drawing || a.kind == AnnotationKind.handwriting) && a.inkLayerId != null)
          a.inkLayerId!,
    };
    final layers = [for (final l in await _layers.byIds(layerIds)) if (!l.meta.isDeleted) l];
    await db.transaction(() async {
      for (final a in rows) {
        await _write('annotations', a.id, (v, at) => _dao.upsert(a.copyWith(meta: a.meta.deleted(at, v))));
      }
      for (final l in layers) {
        await _write('ink_layers', l.id, (v, at) => _layers.upsert(l.copyWith(meta: l.meta.deleted(at, v))));
      }
    });
    return RemovedCard(rows, layers);
  }

  Future<void> restore(RemovedCard r) => db.transaction(() async {
    for (final l in r.layers) {
      await _write('ink_layers', l.id, (v, at) => _layers.upsert(l.copyWith(meta: l.meta.restored(at, v))));
    }
    for (final a in r.annotations) {
      await _write('annotations', a.id, (v, at) => _dao.upsert(a.copyWith(meta: a.meta.restored(at, v))));
    }
  });

  /// Troca a cor no lugar; `false` se o grifo não existe mais.
  Future<bool> recolor(String highlightId, String color) async {
    final a = await _dao.byId(highlightId);
    if (a == null || a.meta.isDeleted || a.kind != AnnotationKind.highlight) return false;
    await _write(
      'annotations',
      a.id,
      (v, at) => _dao.upsert(a.copyWith(color: Nullable(color), meta: a.meta.edited(at, v))),
    );
    return true;
  }

  Future<void> saveNote(String userBookId, String highlightId, String text) async {
    final plan = planNote(await _dao.forBook(userBookId), await _dao.byId(highlightId), text);
    switch (plan) {
      case null:
        return;
      case NoteDelete(:final note):
        await _write('annotations', note.id, (v, at) => _dao.upsert(note.copyWith(meta: note.meta.deleted(at, v))));
      case NoteEdit(:final note, :final text):
        await _write(
          'annotations',
          note.id,
          (v, at) => _dao.upsert(note.copyWith(noteText: Nullable(text), meta: note.meta.edited(at, v))),
        );
      case NoteCreate(:final parent, :final text):
        final who = await owner();
        final id = _ids.next();
        await _write(
          'annotations',
          id,
          (v, at) => _dao.upsert(Annotation(
            id: id,
            meta: RecordMeta(userId: who, createdAt: at, updatedAt: at, version: v),
            userBookId: parent.userBookId,
            kind: AnnotationKind.note,
            parentId: parent.id,
            groupId: parent.groupId,
            anchor: parent.anchor,
            refPage: parent.refPage,
            chapterIndex: parent.chapterIndex,
            noteText: text,
          )),
        );
    }
  }

  Future<void> _write(String table, String id, Future<void> Function(Hlc v, DateTime at) save) =>
      versioning.write(table, id, (v) => save(v, DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true)));
}
```

> Se a tabela de camadas no drift tiver outro nome (`db.inkLayers`), use o que o `InkLayersDao` usa. O mesmo vale
> para o nome da tabela no `versioning.write` (o `InkRepository._writeLayer` mostra qual é).

- [ ] **Passo 3:** verde. Commit
  `feat(grifos): o repositório da tela 25 — observar, buscar, apagar o cartão e desfazer, cor e nota`.

### Tarefa 8: a fonte do texto dos cartões e o clube

**Arquivos:**
- criar `lib/features/highlights/application/card_text_source.dart` e `highlights_club_source.dart`;
- testes `test/features/highlights/application/card_text_source_test.dart` (com o EPUB do mundo,
  `mundoEpub(Slugs.domCasmurro, completo: true)`, e com um caminho que não existe).

- [ ] **Passo 1 (RED):**
  - **`EpubCardTextSource.textsFor(...)`:**
    - devolve, para cada cartão, os `CardSpan` derivados do texto do capítulo (o cartão 8 termina em "da praia…" e
      começa em "Traziam não sei que ");
    - `orphans` vazio;
    - com uma âncora de outro arquivo (`sha` diferente) cujo `exact` não existe no texto: o grupo entra em
      `orphans`, e o texto do cartão sai do recuo (`spansFromQuotes`);
    - abre o EPUB uma vez só por chamada (contador no `opener` injetado);
    - a 2ª chamada com os mesmos itens não abre de novo (cache);
  - **`AnchorOnlyCardTextSource`:** só o recuo, `orphans` vazio;
  - **arquivo que não existe:** o `EpubCardTextSource` cai no recuo, sem erro;
  - **`NoHighlightsClub().clubOf('x')`** = `null`.
- [ ] **Passo 2 (GREEN):**

```dart
// G19.2 — de onde vem o texto dos cartões da tela 25 (R3) e quem está sem lugar (D-199): o texto canônico dos
// itens do EPUB que têm anotação, lido num isolate (como a busca da G12) e guardado enquanto a tela vive; cada âncora
// é reancorada como no leitor (G13). Sem o arquivo, o recuo pela citação da âncora — e ninguém fica "sem lugar".
import 'dart:isolate';

import '../../reader/annotations/domain/annotation.dart';
import '../../reader/content/chapter_content.dart';
import '../../reader/content/epub_book.dart';
import '../../reader/domain/anchoring.dart';
import '../../reader/domain/locator.dart';
import '../domain/card_text.dart';
import '../domain/highlight_card.dart';

final class CardTexts {
  const CardTexts(this.byGroup, this.orphans);
  final Map<String, List<CardSpan>> byGroup;
  final Set<String> orphans;
}

abstract interface class CardTextSource {
  Future<CardTexts> textsFor(List<HighlightCard> cards);
}

/// Os itens marcados de um cartão: grifos, desenhos e notas à mão (as notas de texto ficam embaixo, no post-it).
Iterable<Annotation> markedItems(HighlightCard c) =>
    c.items.where((a) => a.kind != AnnotationKind.note);

List<CardQuote> _quotes(HighlightCard c) => [
  for (final a in markedItems(c))
    if (a.anchor case EpubAnchor(:final quote) when quote.exact.isNotEmpty)
      (id: a.id, prefix: quote.prefix, exact: quote.exact, suffix: quote.suffix),
];

final class AnchorOnlyCardTextSource implements CardTextSource {
  const AnchorOnlyCardTextSource();
  @override
  Future<CardTexts> textsFor(List<HighlightCard> cards) async =>
      CardTexts({for (final c in cards) c.groupId: spansFromQuotes(_quotes(c))}, const {});
}

typedef SpineTexts = Future<Map<int, String>> Function(String path, List<int> spines);

/// Padrão: abre o EPUB num isolate e lê o texto canônico de cada item pedido.
Future<Map<int, String>> isolateSpineTexts(String path, List<int> spines) => Isolate.run(() {
  final book = EpubBook.open(path);
  try {
    return {for (final s in spines) s: chapterOf(book, s).item.text};
  } finally {
    book.close();
  }
});

final class EpubCardTextSource implements CardTextSource {
  EpubCardTextSource({required this.path, required this.sha, this.spineTexts = isolateSpineTexts});

  /// O arquivo do livro (`null` = não está no aparelho) e o sha de agora.
  final String? path;
  final String sha;
  final SpineTexts spineTexts;
  final Map<int, String> _cache = {};

  @override
  Future<CardTexts> textsFor(List<HighlightCard> cards) async {
    final p = path;
    if (p == null) return const AnchorOnlyCardTextSource().textsFor(cards);
    final need = {
      for (final c in cards)
        for (final a in markedItems(c))
          if (a.anchor case EpubAnchor(:final spine) when !_cache.containsKey(spine)) spine,
    };
    if (need.isNotEmpty) {
      try {
        _cache.addAll(await spineTexts(p, need.toList()..sort()));
      } on Object {
        return const AnchorOnlyCardTextSource().textsFor(cards);
      }
    }
    final byGroup = <String, List<CardSpan>>{};
    final orphans = <String>{};
    for (final c in cards) {
      final marks = <CardMark>[];
      String? text;
      var lost = false;
      for (final a in markedItems(c)) {
        final anchor = a.anchor;
        if (anchor is! EpubAnchor) continue;
        final t = _cache[anchor.spine];
        if (t == null || (text != null && !identical(t, text))) continue; // um cartão = um item do livro
        text = t;
        switch (reanchor(anchor, t, currentSha: sha)) {
          case Anchored(:final start, :final end):
            marks.add((id: a.id, start: start, end: end));
          case Orphaned():
            lost = true;
        }
      }
      if (text == null || marks.isEmpty) {
        byGroup[c.groupId] = spansFromQuotes(_quotes(c));
        if (lost) orphans.add(c.groupId);
        continue;
      }
      byGroup[c.groupId] = cardSpans(text, marks);
    }
    return CardTexts(byGroup, orphans);
  }
}
```

```dart
// G19.2 — o clube de um item compartilhado (o chip da tela 25): nome e número de respostas. A G21 liga aos clubes;
// até lá, nenhum (o chip não aparece — R8).
typedef ClubChip = ({String clubId, String name, int replies});

abstract interface class HighlightsClubSource {
  Future<ClubChip?> clubOf(String sharedClubPostId);
}

final class NoHighlightsClub implements HighlightsClubSource {
  const NoHighlightsClub();
  @override
  Future<ClubChip?> clubOf(String sharedClubPostId) async => null;
}
```

> O teste do "sem lugar" usa uma âncora com `sha` diferente e um `exact` que não está no texto (o `reanchor` devolve
> `Orphaned`). Âncora do mesmo arquivo sempre volta (`sameFile`), como no leitor.

- [ ] **Passo 3:** verde. Commit `feat(grifos): o texto dos cartões a partir do livro e os grifos sem lugar (R3, D-199)`.

### Tarefa 9: o controlador e as dependências

**Arquivos:** criar `lib/features/highlights/application/highlights_controller.dart` e `highlights_providers.dart`;
teste `test/features/highlights/application/highlights_controller_test.dart` (o mundo no banco, `FakeAsync` para a
espera da busca).

- [ ] **Passo 1 (RED):**
  - **`load()`:**
    - o estado traz o título curto e o autor, `herePage = 159`, `counts = (6,2,1,3)`, a fileira de 5 cores e as
      entradas da lista (14, como a Tarefa 4);
    - os textos dos cartões vêm da fonte injetada;
  - **`setType(notes)`:** entradas = sep(6), card2, sep(152), card5 (os `n` recontados: sep1/sep2, card1/card2), sem
    a 159 "aqui" (a página atual sem cartão visível entra sozinha: `PageMark(159, 3, here)`);
  - **`toggleColor('#FF552E')`, `setClubOnly(true)`:** combinam;
  - **`clearFilters()`:** volta ao padrão;
  - **busca:**
    - `setQuery('ressaca')` não busca antes de 200 ms;
    - depois de 200 ms, só o cartão 7;
    - uma tecla nova no meio cancela a anterior;
    - `setQuery('')` volta a todos;
  - **apagar:**
    - `deleteCard(card7)` → o cartão sai e `pendingUndo` traz "Cartão apagado";
    - `undo()` → volta;
    - `dismissUndo()` limpa;
  - **erro do banco:** com `onError`, o estado fica com a última lista boa;
  - **ciclo de vida:** `dispose` para de ouvir o banco.
- [ ] **Passo 2 (GREEN):** a forma do controlador:

```dart
// G19.2 — o estado da tela 25: o livro, a posição, os itens (do repositório, relidos a cada escrita), os filtros e a
// busca (200 ms — R7), as entradas prontas da lista, as contagens (R1), a fileira de cores (D-196), os textos dos
// cartões e os sem lugar, o chip do clube e o Desfazer pendente (D-193).
final class HighlightsState {
  const HighlightsState({
    required this.loading,
    required this.title,
    required this.author,
    required this.herePage,
    required this.items,
    required this.layers,
    required this.cards,
    required this.entries,
    required this.counts,
    required this.colors,
    required this.filters,
    required this.texts,
    required this.orphans,
    required this.clubs,
    required this.undo,
  });
  final bool loading;
  final String title; // o título curto da prancha ("Dom Casmurro")
  final String? author;
  final int? herePage;
  final List<Annotation> items;
  final Map<String, InkLayer> layers;
  final List<HighlightCard> cards; // todos
  final List<ListEntry> entries; // os visíveis, com os separadores
  final AnnotationKindCounts counts;
  final List<ColorChoice> colors;
  final HighlightFilters filters;
  final Map<String, List<CardSpan>> texts;
  final Set<String> orphans;
  final Map<String, ClubChip> clubs; // por shared_club_post_id
  final RemovedCard? undo;
  bool get empty => !loading && items.isEmpty;
  int get visibleCards => entries.whereType<CardItem>().length;
}

final class HighlightsController extends ChangeNotifier {
  HighlightsController({required this.deps, required this.userBookId});
  final HighlightsDeps deps;
  final String userBookId;
  Future<void> load();
  void setType(TypeFilter t);
  void toggleColor(String hex);
  void setClubOnly(bool on);
  void setQuery(String q); // espera 200 ms (Timer), cancela a anterior
  void clearFilters();
  Future<void> deleteCard(HighlightCard c);
  Future<void> undo();
  void dismissUndo();
  Future<bool> recolor(HighlightCard c, String hex); // todos os grifos do cartão (R11)
  Future<void> saveNote(HighlightCard c, String text);
  Future<String?> exportText(ExportFormat f); // markdown/csv; null = nada para exportar (R12)
  @override
  void dispose();
}
```

  - **Dependências:**

```dart
final class HighlightsDeps {
  const HighlightsDeps({
    required this.db,
    required this.repository,
    required this.textSource,
    required this.club,
    required this.now,
    required this.utcOffsetAt,
    required this.files,
    required this.onError,
  });
  final AppDatabase db;
  final HighlightsRepository repository;
  final Future<CardTextSource> Function(UserBook book) textSource;
  final HighlightsClubSource club;
  final DateTime Function() now;
  final Duration Function(DateTime utc) utcOffsetAt;
  final HighlightsFileSink files;
  final void Function(Object error, StackTrace stack) onError;
}
```

  - **`highlightsDepsProvider`** (`FutureProvider.family<HighlightsDeps, String>` pelo id do livro): banco,
    versionamento e dono como no `readerDepsProvider`. O caminho do livro vem do `LocalFilesDao` (mesmo `_existing`
    do controlador do leitor, extraído para `bookFilePath(db, booksDir, id)` em
    `lib/features/reader/application/book_file.dart`, usado pelos dois); o sha vem do `UserBook.contentSha256`.
  - **Leitura:** `load()` lê o livro (`UserBooksDao`), a posição (`ReadingPositionsDao.forBook` → `refPage`) e o
    índice (`BookContentIndexDao` → `chapterLabels`), e assina o `repository.watch`. A cada lista nova, refaz cartões,
    textos (fonte), clubes e entradas.
- [ ] **Passo 3:** verde. Commit `feat(grifos): o controlador da tela 25 — filtros, busca com espera, Desfazer e deps`.

## G19.3–G19.8 — Tela

### Tarefa 10: o mundo da tela 25 nos testes

**Arquivos:** criar `test/support/dados_t25.dart` e `test/support/fase_l25.dart`.

- [ ] **Passo 1:** `dados_t25.dart`:
  - `livroDaTela25()`: o `mundoReferencia` inteiro (com a tinta de hoje — a tela 25 mostra), o EPUB do mundo, o
    índice da tela 19 e a posição na pág. 159, como o `livroDaTela20` mas com o `mundoReferencia`;
  - `FixtureCardTexts`: um `CardTextSource` que devolve os `cartoesDaTela25` literais (D-34/D-49), sem órfãos;
  - `ClubeDaTela25`: um `HighlightsClubSource` com `(clubId: mundoReferencia.clube.id, name: 'Leitoras de Capitu',
    replies: mundoReferencia.clube.respostasDoPost)` para o `postCompartilhadoId`;
  - `depsDaTela25(livro, {files})`: o relógio e o fuso do mundo, as fontes de fixture e um `FakeFileSink` (guarda o
    nome, o conteúdo e o tipo).
- [ ] **Passo 2:** `fase_l25.dart`:
  - `abrirTela25(tester, livro, {golden, deLeitor})`:
    - `setCanvasView(tester, logical: const Size(390, 2170))`, sem áreas seguras;
    - o `App.forTests` com o `highlightsDepsProvider` sobrescrito;
    - `routerOf(tester).push(AppRoutes.destaques(id))`;
    - espera o banco (o laço `_banco` da L27);
  - os achadores `hl(String id)` e o leitor de linhas (`text_lines.dart`) para as fases L25a–d.
- [ ] **Passo 3:** um teste de fumaça em `test/features/highlights/presentation/tela25_smoke_test.dart`: a tela abre
  e mostra "Grifos", 8 cartões e "Continuar lendo · pág. 159". Falha até a Tarefa 12 (RED); passa no fim dela.
  Commit junto com a Tarefa 12.

### Tarefa 11: fontes, ícones, cores e estilos

**Arquivos:**
- **`pubspec.yaml`:** as famílias `Literata16_5`, `Literata16_5Ext` e `Literata16_5Vi`, peso 400, com os arquivos
  que o `tools/fonts/build_fonts.py` já gera (`assets/fonts/Literata16_5{,Ext,Vi}-Regular.ttf`). Se faltarem no
  Windows, rodar `python3 tools/fonts/build_fonts.py` e conferir com `validar_fontes.py`.
- **`app_typography.dart`:**
  - `literataStatic` ganha `16.5: {400}`;
  - estilos `hl*`, como a G15 fez com os `readerToc*`:
    - `hlTitle` (Bricolage 34, lh .98, ls −1) e `hlTitleSerif` (serif 42 itálico, lh .98);
    - `hlSubtitle` (Figtree 14/600 `#5B544B`);
    - `hlSearch` (Figtree do placeholder da L25a);
    - `hlChip` (13,5/800) e `hlChipCount` (13,5/700);
    - `hlColorLabel` ("COR");
    - `hlSep` (12,5/800 com `tnum`);
    - `hlPill` (10,5/800, ls .9);
    - `hlDate` (12/700 `#8A8073`);
    - `hlQuote` (Literata 16,5, lh 1,6, `#2A2520`);
    - `hlNoteLabel`, `hlNoteText`, `hlClub`, `hlHandTag` (os valores das tabelas da L25c);
    - `hlEnd` (serif itálico 22, lh 1,15) e `hlEndCta` (15,5/800 `#F7F0E3`);
    - `hlSheetTitle`, `hlSheetItem` (folhas: os mesmos do `NoteSheet`).
- **`app_icons_leitor.dart`:** `share` (`ic_share`), `starDeco`, `searchGray` (`ic_search_cinza`), `people`,
  `moreDots`, `peopleChip`, `pencilHeavy` (o `ribbonHint` já é o `ic_ribbon`); todos no `all`.
- **`app_colors.dart`:** só as cores que ainda não existem (as da nota amarela e do chip rosa, pelas tabelas da
  L25c).
- **Teste** `test/design_system/fontes_leitor_g19_test.dart`:
  - as famílias no `FontManifest.json`;
  - a largura de "que eu conheço de vista e de chapéu." em Literata 16,5 contra a L25c (`lines` do `card1.body`),
    dentro de 0,05;
  - os ícones carregam.

- [ ] RED → GREEN (`tocar.ps1` depois do `pubspec`) → commit `feat(design): Literata 16,5, ícones, cores e estilos da tela 25 (G19)`.

### Tarefa 12: a rota real, a tela e o topo com a busca (L25a)

**Arquivos:**
- criar `lib/features/highlights/presentation/highlights_screen.dart` e `highlights_top.dart`;
- `lib/app/routes.dart`: `destaques(bookId, {bool fromReader = false})` → `'/livro/$bookId/destaques'` + `?de=leitor`;
- `lib/app/router.dart`: a rota com `HighlightsScreen(bookId:, fromReader: state.uri.queryParameters['de'] == 'leitor')`,
  pelo `_page`, no navegador da raiz;
- teste `test/features/highlights/presentation/highlights_top_test.dart`.

- [ ] **Passo 1 (RED):** pela `abrirTela25`:
  - **topo:**
    - `hl.topBar.back` 48×48 em (16, 54) com "Voltar ao livro" (botão);
    - `hl.topBar.export` com "Exportar grifos e notas";
    - `hl.sparkle` 22 em (318,128), sem semântica;
    - o topo começa em `max(54, viewPadding.top + 7)`: com `viewPadding.top = 60`, em 67 (R14);
  - **título:** "Grifos" + "e notas" com as baselines da `kRef25` (`hl.title`, `linesAll`);
  - **subtítulo:** "Dom Casmurro · na ordem do livro", com "Dom Casmurro" em 700;
  - **busca:**
    - `hl.search` 358×48, `hl.search.input` com "Buscar nos grifos e notas" (campo de texto);
    - digitar "ressaca" mostra o × ("Limpar busca"); o × limpa e some;
    - a ação do teclado é "Buscar".
- [ ] **Passo 2 (GREEN):**
  - **`HighlightsScreen`** (`ConsumerStatefulWidget`):
    - cria o `HighlightsController` com as deps;
    - `Scaffold` sem `AppBar`, fundo `AppColors.paper`;
    - `ReaderChromeScope(palette: ReaderChromePalette.of(ReaderPaper.creme), brand: ref.watch(brandProvider), a: 1)`
      por fora, para as pílulas (D-118/D-132);
    - `CustomScrollView` com `SliverPadding(top: max(54, viewPadding.top + 7))`;
    - `SliverToBoxAdapter(HighlightsTop)`, depois os filtros (Tarefa 13), a lista (`SliverList` com
      `SliverChildBuilderDelegate` sobre `state.entries`) e o fim (Tarefa 17);
    - as pílulas por cima, num `Stack`.
  - **`HighlightsTop`:** a `Row` do topo (`CircleIconButton` ou `Pressable` + `NeoBox` de 48), o título
    (`AppText.rich`), a estrela (`Positioned` num `Stack` do título) e a pílula de busca com um `TextField` sem borda
    (estilo `hlSearch`, `textInputAction: TextInputAction.search`, `onChanged → controller.setQuery`).
  - **Voltar:** `Navigator.maybePop(context)` (D-195).
- [ ] **Passo 3:** verdes este teste e o de fumaça (com as Tarefas 13–17 ainda sem a lista, o de fumaça espera os
  cartões: ele fica marcado `skip` até a Tarefa 14 e volta a valer lá). Commit
  `feat(grifos): a tela 25 na rota real, o topo e a busca (L25a)`.

### Tarefa 13: os filtros (L25b)

**Arquivos:** criar `lib/features/highlights/presentation/highlight_filters.dart`; teste
`test/features/highlights/presentation/highlight_filters_test.dart`.

- [ ] **Passo 1 (RED):**
  - **tipos:**
    - `hl.types` `radiogroup` "Tipo", em (0, 261,96, 390, 44) com a lista rolando na horizontal;
    - os 5 chips `hl.types.all|highlights|notes|handwritten|drawings` com "Tudo 12", "Grifos 6", "Notas 2", "À mão
      1", "Desenhos 3";
    - o ativo com a `brand` e a sombra 2/2; o número `#1A1714` no ativo e `#8A8073` nos outros;
    - tocar em "Notas" marca (`checked`) e chama `setType`;
    - a máscara: o último chip corta (o pixel em x 385 é mais claro que em x 300, no golden);
  - **cores:**
    - `hl.filters.colors` `group` "Filtrar por cor", com o "COR";
    - caixas `checkbox` de 28 (`yellow`…`coral`) com os rótulos do arquivo;
    - tocar marca a cor (`checked`) e chama `toggleColor`;
    - com 7 cores, a fileira rola;
  - **clube:** `hl.filters.clubOnly` `switch`, com `ic_people` 15 escondido do leitor de tela; tocar liga.
- [ ] **Passo 2 (GREEN):**
  - **chips:** `ShaderMask` com o `LinearGradient` (preto 85 % → transparente) na faixa dos tipos, e uma `ListView`
    horizontal com padding 16;
  - **cada chip:** `Pressable(checked:)` + `NeoBox` (pílula 40, borda 1,5, padding 0/14, gap 6);
  - **caixas de cor:** `Pressable(checked:)` + `NeoBox` circular 28, com o desenho de marcada da L25b;
  - **interruptor:** `Semantics(toggled:)` com o desenho da L25b;
  - todos os valores vêm das tabelas da L25b.
- [ ] **Passo 3:** verde. Commit `feat(grifos): os filtros por tipo, cor e clube (L25b, D-196)`.

### Tarefa 14: separadores e o cartão de grifo (L25c.1–L25c.2)

**Arquivos:** criar `lib/features/highlights/presentation/page_separator.dart` e `highlight_card.dart`; teste
`test/features/highlights/presentation/highlight_card_test.dart`.

- [ ] **Passo 1 (RED):** pela `abrirTela25`, contra a `kRef25`:
  - **separadores:**
    - `hl.list.sep1` (pílula "pág. 3", 28, `tnum`, e a linha tracejada 1,5 `#CFC3AE` escondida do leitor de tela);
    - `hl.list.sep6` coral 30 com sombra 2/2, a fita `ic_ribbon` 12×15 e "pág. 159 · você parou aqui";
  - **cartão 1:**
    - `hl.list.card1` (raio 20, borda 1,5, sombra 3/3, `#FFFAF1`);
    - `head.highlight` com a bolinha amarela e "GRIFO";
    - `head.date` "2 set";
    - `head.more` 36×36 com o ícone 20 ("Mais opções", botão);
    - `body.quote` com o contexto cinza e o trecho marcado, nas linhas e baselines da tabela;
    - o fundo do `mark` no gradiente 14 %–92 % a .9 (pixels);
  - **semântica:**
    - o cartão é um nó com "Grifo amarelo, página 3" + o texto e a ação de tocar ("Abrir no livro");
    - `head.more` é outro nó.
- [ ] **Passo 2 (GREEN):**
  - **`PageSeparator(page, n, here)`:** `Row` com a pílula e a linha tracejada (`CustomPainter`, traços do
    `border-top: dashed` do Chromium, como as linhas tracejadas já usadas no sumário).
  - **`HighlightCardView(card, n, spans, date, club, onOpen, onMore)`:**
    - `NeoBox` + `Column`: o cabeçalho (`Row` com as pílulas, o `Spacer` como `head.sep`, a data e o "•••");
    - a citação `AppText.rich` com os `TextSpan` dos `CardSpan`;
    - o fundo dos trechos de grifo de fundo por um pintor por trás do texto: as caixas dos trechos (`TextPainter`
      `getBoxesForSelection`), 14 %–92 % da altura da linha, raio 3, com o `box-decoration-break: clone`;
    - os outros trechos (tinta) ficam para a Tarefa 16.
  - **chaves:** `hl.list.sep<n>` e `hl.list.card<n>` (com os sub-ids da `kRef25`).
- [ ] **Passo 3:** verde; tirar o `skip` do teste de fumaça. Commit
  `feat(grifos): separadores de página e o cartão de grifo (L25c.1–L25c.2)`.

### Tarefa 15: o post-it da nota e o chip do clube (L25c.3–L25c.4)

**Arquivos:** `highlight_card.dart`; teste no mesmo `highlight_card_test.dart`.

- [ ] **Passo 1 (RED):**
  - **cartão 2:**
    - `body.note` em (33,5, 776,86, 323, 61,91), girado −0,6° (a matriz do `Transform`);
    - `note.tape` 46×16 girada −3°, `#FFFAF1` a .85, escondida do leitor de tela;
    - `note.label` "NOTA" e `note.text` "É o livro todo nessa frase.", nas baselines da tabela;
  - **cartão 5:**
    - `body.club.chip` 230,45×32, com `ic_people_chip` 17;
    - "Leitoras de Capitu · 3 respostas" (o `replies` em `chip.replies`);
    - tocar vai a `/clube/<id>/discussao`;
  - **sem clube na fonte** (`NoHighlightsClub`): o cartão 5 sem chip, e o rótulo continua "…compartilhado no clube…";
  - **singular:** "1 resposta".
- [ ] **Passo 2 (GREEN):**
  - o post-it: `Transform.rotate` + `NeoBox`, com a fita num `Positioned` fora da caixa e `Transform.rotate` −3°;
  - o chip: `Pressable` + `NeoBox` pílula rosa, com o ícone e o texto;
  - os valores vêm das tabelas da L25c.
- [ ] **Passo 3:** verde. Commit `feat(grifos): a nota em post-it e o chip do clube (L25c.3–L25c.4)`.

### Tarefa 16: a tinta nos cartões e o cache (R10, L25c.5)

**Arquivos:** criar `lib/features/highlights/presentation/ink_thumbnail.dart`; testes
`test/features/highlights/presentation/ink_thumbnail_test.dart`.

- [ ] **Passo 1 (RED):**
  - **`placeDrawingInCard(frame: (w), span: InkPiece, em)`** devolve a `PlacedFrame` da D-162: o `k` do trecho numa
    linha e `k = 1` quando ele quebra. Testar com o `w` da elipse e a largura de "Olhos de ressaca?" em Literata
    16,5.
  - **cartão 7:**
    - a elipse coral passa da caixa do trecho como `body.quote.ink.ellipse` (25,5, 1746,43, 151,76×34,5), dentro de
      ±1,5 px nas bordas da tinta pintada (pixels);
    - a miniatura da nota (`body.handNote`) com a etiqueta "À MÃO" e `ic_pencil_heavy` 11, as pautas `rule1`/`rule2`
      e a tinta dentro de `handNote.ink` (320×96);
    - o rótulo `img` "Nota à mão, 20 set" (D-31; a data pela R5 — no mundo, "hoje" vira "Nota à mão, hoje");
  - **cartão 8:** o ondulado sob "fluido misterioso" e o duplo sob "a vaga que se retira";
  - **cartão 6:** a mancha da D-161 atrás de "olhos de Capitu", multiplicada;
  - **cache:**
    - `InkThumbnailCache` guarda até 64 imagens;
    - a 65ª tira a mais antiga;
    - a chave muda com a versão da camada;
    - na rolagem, nenhum `paint` novo do pintor da tinta (contador) depois da 1ª pintura;
    - enquanto a imagem não fica pronta, pinta direto.
- [ ] **Passo 2 (GREEN):**
  - **desenhos:**
    - o pintor reaproveita o `paintInkStrokes` do `ink_painter.dart` (G16) com os traços decodificados do BNK1
      (`bnk1_codec.dart`);
    - a moldura vem da `inkLayerAnchor`/`inkAnchorOf` (`w` da camada) e da caixa do trecho no `TextPainter` do
      cartão;
  - **mancha:** a da D-161 (`paintFreehandHighlight` ou o nome que o `ink_painter.dart` usa), na caixa de cada linha
    do trecho;
  - **nota à mão:**
    - a caixa de referência é `Rect.fromLTWH(0, 0, 334, noteBoxHeight(n))`, a da 24b em 390;
    - `fromNote(stroke, ref)`, depois a escala `96 / noteBoxHeight(n)`, alinhada à esquerda e ao meio (o
      `xMinYMid meet` da miniatura do arquivo);
    - as pautas nas posições medidas da L25c;
  - **cache:**
    - `InkThumbnailCache` (LRU por `LinkedHashMap`) com chave `(layerId, version, size, dpr)`;
    - o `PictureRecorder` → `toImage` roda fora do quadro (`SchedulerBinding.scheduleTask`);
    - enquanto a imagem não fica pronta, o `CustomPainter` pinta os traços direto.
- [ ] **Passo 3:** verde. Commit `feat(grifos): a tinta nos cartões a partir dos traços salvos, com cache em imagem (R10)`.

### Tarefa 17: o fim, os vazios e os sem lugar (L25d, D-198, D-199)

**Arquivos:** criar `lib/features/highlights/presentation/highlights_end.dart`; teste
`test/features/highlights/presentation/highlights_end_test.dart`.

- [ ] **Passo 1 (RED):**
  - **`hl.end`:**
    - em (16, 2117,98, 358, 153,6), tracejado 1,5 raio 22;
    - "Daqui para frente, / as margens ainda estão em branco." com as duas linhas e as baselines da L25d;
    - `hl.end.cta` 323×52 preto, "Continuar lendo · pág. 159" (geometria; o rótulo recortado da prancha não
      aparece no golden — D-56);
  - **livro sem anotações:**
    - sem busca e sem filtros;
    - "Nenhum grifo ainda. / As margens estão em branco." + o botão;
  - **filtro sem resultado** (Desenhos + Rosa):
    - "Nada com esses filtros." + "Limpar filtros", que volta ao padrão;
    - o cartão de fim continua embaixo;
  - **sem lugar:**
    - com a fonte que diz o grupo do cartão 4 sem lugar: o separador cinza "sem lugar no texto" depois do cartão
      8;
    - o cartão 4 lá, com "pág. 121" na linha da data;
    - o separador da 121 some;
  - **sem posição:** "Continuar lendo" sem a página.
- [ ] **Passo 2 (GREEN):**
  - o cartão tracejado é um pintor de borda tracejada com raio (o mesmo da Tarefa 14, em retângulo);
  - os textos saem do estado (`herePage`, vazio, filtros);
  - os vazios reusam o mesmo widget, com outros textos e outro botão.
- [ ] **Passo 3:** verde. Commit `feat(grifos): o cartão do fim, os vazios e os grifos sem lugar (L25d, D-198, D-199)`.

### Tarefa 18: Mais opções (D-192, D-193, R11)

**Arquivos:** criar `lib/features/highlights/presentation/highlight_more_sheet.dart`; teste
`test/features/highlights/presentation/highlight_more_sheet_test.dart`.

- [ ] **Passo 1 (RED):**
  - **cartão 2:**
    - "•••" abre a folha com "pág. 6 · GRIFO + NOTA" e o começo do trecho com "…";
    - Editar nota, Trocar cor (4 bolinhas, a rosa com o anel), Compartilhar no clube, Apagar e Fechar;
  - **cartão 8:** só Compartilhar no clube, Apagar e Fechar;
  - **cartão 1:** "Escrever nota";
  - **Editar nota:** abre a `NoteSheet` com "É o livro todo nessa frase."; Salvar com outro texto grava (banco) e o
    post-it muda;
  - **Trocar cor:** amarela → o banco muda, a folha fecha e o cartão repinta; tocar na rosa marcada não faz nada;
  - **Compartilhar no clube:** a folha fecha e "Chega numa próxima fase" aparece por 2 s;
  - **Apagar no cartão 7:**
    - a folha fecha e o cartão some;
    - "Cartão apagado · Desfazer" por 4 s;
    - Desfazer traz o cartão e as camadas de volta;
    - com `accessibleNavigation`, a pílula fica até a próxima ação (D-139);
  - **Fechar, o véu e o Voltar do sistema:** fecham sem mudar nada.
- [ ] **Passo 2 (GREEN):**
  - a folha no padrão da `NoteSheet` (cartão a 14 das bordas, raio, borda 1,5, sombra dura, sobre o véu), aberta por
    um `showGeneralDialog`, ou o mesmo mecanismo da `NoteSheet` no `reader_screen.dart`;
  - as bolinhas são as da barra da tela 21 (`markerColors`, "Grifar em …");
  - as pílulas são a `ReaderToastPill` e a `ReaderUndoPill`, dentro do `ReaderChromeScope` da tela.
- [ ] **Passo 3:** verde. Commit `feat(grifos): a folha Mais opções com nota, cor, clube e apagar com Desfazer (D-192, D-193)`.

### Tarefa 19: Exportar (D-194, R12)

**Arquivos:** criar `lib/features/highlights/presentation/highlight_export_sheet.dart` e
`lib/features/highlights/application/highlights_file_sink.dart`; teste
`test/features/highlights/presentation/highlight_export_sheet_test.dart`.

- [ ] **Passo 1 (RED):**
  - **abrir:** "Exportar" abre a folha com "Exportar grifos e notas", "Dom Casmurro · 8 grifos e notas de texto" e o
    `radiogroup` "Formato" (Markdown marcado, CSV, "PDF com desenhos" com PRO);
  - **PDF:** "Chega numa próxima fase" por 2 s, e a escolha continua Markdown;
  - **Markdown:**
    - Exportar entrega `dom-casmurro-grifos-e-notas.md`, `text/markdown`, com o conteúdo do `markdownOf` (o
      `FakeFileSink` guarda);
    - a folha fecha;
  - **CSV:** `.csv`, `text/csv`, começa com o BOM;
  - **erro do sink:** "Não deu para exportar" por 2 s, e a folha fica aberta;
  - **R12:** livro só com tinta → "Nada para exportar em Markdown ou CSV ainda" e o Exportar a .38, "indisponível".
- [ ] **Passo 2 (GREEN):**

```dart
// G19.7 — a entrega dos arquivos da exportação (D-194): grava num temporário do app e abre a folha de compartilhar
// do sistema (salvar em Arquivos, mandar por e-mail…). Nada sobe para o servidor.
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class HighlightsFileSink {
  Future<void> share({required String fileName, required String content, required String mimeType});
}

final class ShareHighlightsFileSink implements HighlightsFileSink {
  const ShareHighlightsFileSink();

  @override
  Future<void> share({required String fileName, required String content, required String mimeType}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(utf8.encode(content), flush: true);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: mimeType)], subject: 'Grifos e notas'),
    );
  }
}
```

  - O controlador ganha `ExportFormat { markdown, csv }` e o `exportText` (Tarefa 9) usa `markdownOf`/`csvOf` com
    todos os itens do livro (D-194: sem filtros).
- [ ] **Passo 3:** verde. Commit `feat(grifos): Exportar em Markdown e CSV pela folha de compartilhar (D-194, R12)`.

### Tarefa 20: navegação com o leitor e a Início (R13, D-195)

**Arquivos:**
- `lib/app/routes.dart`: `leitor(bookId, {String? goTo})` → `/leitor/$bookId` + `?ir=<id>`;
- `lib/app/router.dart`: `ReaderScreen(bookId:, goTo: state.uri.queryParameters['ir'])`;
- `lib/features/highlights/domain/highlights_exit.dart` (novo):

  ```dart
  sealed class HighlightsExit { const HighlightsExit(); }
  final class OpenAt extends HighlightsExit {
    const OpenAt(this.annotationId, {required this.refPage, this.orphan = false});
    final String annotationId; final int refPage; final bool orphan;
  }
  final class ContinueReading extends HighlightsExit { const ContinueReading(); }
  ```

- `highlights_screen.dart`:
  - tocar num cartão: `fromReader` → `Navigator.pop(OpenAt(...))`; senão → `context.pushReplacement(AppRoutes.leitor(id, goTo: ...))`;
  - "Continuar lendo": `fromReader` → `pop(const ContinueReading())`; senão → `pushReplacement(leitor)` (livro
    físico: `AppRoutes.livro`, D-123);
- `reader_screen.dart`:
  - o `ReaderTool.notes` vira `_openHighlights()`:
    - fecha os controles;
    - `final exit = await context.push<HighlightsExit>(AppRoutes.destaques(id, fromReader: true))`;
    - com `OpenAt`, `_jumpToAnnotation(exit)`;
  - o `widget.goTo`, quando o leitor fica pronto pela 1ª vez, faz o mesmo salto uma vez;
- `_jumpToAnnotation`:
  - lê a anotação (`AnnotationsDao.byId`);
  - `final r = _annotations?.placeOf(a)`;
  - com `r`, `c.jumpTo((spine: r.unit, offset: r.from), timed:)` — a pílula "← Voltar à pág. N" pelas regras da
    D-151;
  - sem `r` ou `orphan`, `c.jumpToPage(a.refPage)` e a pílula "Esse trecho não está mais aqui" por 2 s (D-199);
- teste `test/features/reader/presentation/reader_screen_g19_test.dart`.

- [ ] **Passo 1 (RED):**
  - **pelo leitor:**
    - tela 20 → Grifos abre a 25 (`hl.title`) em vez do aviso da D-118;
    - Voltar fecha a 25 e o leitor continua na pág. 159 com os controles fechados;
    - tocar no cartão 4 (pág. 121) fecha a 25, e o leitor mostra a pág. 121 com "← Voltar à pág. 159";
    - tocar na pílula volta à 159;
    - "Continuar lendo" volta sem salto;
    - um cartão sem lugar abre a página original com o aviso;
  - **pela Início:**
    - Destaques abre a 25; Voltar volta à Início (D-195);
    - tocar no cartão 4 troca a 25 pelo leitor, que abre na 159 e salta para a 121 com a pílula;
    - "Continuar lendo" abre o leitor na 159;
  - **o teste antigo do aviso do Grifos (G12, D-118)** passa a esperar a tela 25. Atualizar o teste e citar a D-118
    cumprida.
- [ ] **Passo 2 (GREEN):** o código acima, com o `goTo` guardado em `_pendingGoTo` e consumido no 1º `ReaderReady`.
- [ ] **Passo 3:** verde. Commit `feat(leitor): o botão Grifos abre a tela 25 e o toque num cartão salta para o trecho (R13, D-195)`.

## G19.9 — Prova

### Tarefa 21: fases L25a–L25d e o golden

**Arquivos:** criar `test/features/highlights/presentation/l25a_test.dart`, `l25b_test.dart`, `l25c_test.dart`,
`l25d_test.dart` e `test/golden/leitor_25_test.dart`.

- [ ] **Passo 1:** pela `abrirTela25`, contra a `kRef25`, com as tolerâncias da v1 (±0,5; ±1,0 em x/w nos
  `textDependentX`):
  - **geometria**, por seção (sem os inline):
    - topo 5, estrela 1, título 1, subtítulo 1, busca 3;
    - tipos 11, filtros 11;
    - lista 126;
    - fim 4;
  - **texto:** `lines`/`linesAll` com as baselines; a linha `hidden` do botão do fim fora;
  - **estilo:**
    - cores, bordas 1,5/1,3/1,2, raios 20/22/12/999, sombras 3/3 e 2/2, blur 0;
    - as fontes (Bricolage 34, serif 42/22, Figtree 10,5–15,5, Literata 16,5) e os pesos;
    - o `tnum`;
  - **semântica:** as tabelas das quatro fases, com a D-51 d (a nota à mão genérica);
  - **dados:** os textos saem do `t25`, das contas e da fixture (`cartoesDaTela25`), sem literal da prancha no teste.
- [ ] **Passo 2:** o golden @3x da tela inteira (1170×6510) e `tools/compare_images.py` contra
  `25_grifos_notas_390x2170@3x.png`, limite 0,5 %, nos recortes:
  - L25a: y 46–257,96;
  - L25b: y 253,96–367,96;
  - L25c: y 377,96–2099,98;
  - L25d: y 2109,98–2170.
- [ ] **Passo 3:** o que faltar volta às Tarefas 12–17, com teste. Commit
  `test(grifos): fases L25a–L25d e o golden da tela 25`.

### Tarefa 22: comportamento e desempenho

**Arquivos:** `test/features/highlights/presentation/highlights_screen_test.dart` e
`highlights_performance_test.dart`.

- [ ] **Passo 1 — comportamento:**
  - filtros e busca refazem a lista; "N cartões" é anunciado (`SemanticsService`/`liveRegion`);
  - "Limpar filtros";
  - a lista se refaz depois de uma escrita vinda de fora (outra aba gravando no banco);
  - Apagar + Desfazer;
  - Editar nota;
  - Trocar cor;
  - Exportar (os dois formatos);
  - o PDF com o aviso;
  - o vazio;
  - o leitor de tela: a ordem dos nós (topo, busca, tipos, cores, clube, separador, cartão, "Mais opções"…).
- [ ] **Passo 2 — desempenho:**
  - **lista longa:** 2.000 itens em 200 páginas (gerados com os construtores de teste); a tela abre em menos de 1 s
    de relógio do teste;
  - **construção preguiçosa:** só os cartões visíveis (+ o `cacheExtent`) são construídos (contador de `build` no
    `HighlightCardView`);
  - **rolagem:** 3 telas para baixo sem `build` de cartões já vistos fora do `cacheExtent`, e sem repintar a
    miniatura em cache.
- [ ] **Passo 3:** commit `test(grifos): a tela 25 inteira — filtros, busca, folhas, exportar, vazio e lista longa`.

### Tarefa 23: verificação, capturas e relatório

- [ ] `dart format`, `flutter analyze` (0), `flutter test` com cobertura: ≥ 90 % nos arquivos de `lib/` da fase
  (`python tools\coverage\resumo.py --minimo 90 @(git diff --name-only d541e11 -- lib)`).
- [ ] Revisão independente (agente que não escreveu o código) e as correções com teste.
- [ ] **Mutação** (`tools/medicao/tmp/mut/g19/gerar_g19.py`, no padrão da G18):
  - a R3 (55, 40, frase, aspas, vírgula → "…", fim do parágrafo, sobreposição, ponto);
  - a R4 (os casos e os números);
  - a R2 (nota herda, nota à mão sem cor);
  - a D-196 (ordem, chaves, rótulos);
  - a D-197 (cada condição);
  - a R1;
  - a R5 (hoje, ontem, ano);
  - a R6 (aqui sozinho, começo, fim);
  - a D-199;
  - a R9 (BOM, `;`, aspas, CRLF, notas juntas, sem tinta);
  - o repositório (as camadas no apagar, a versão do desfazer);
  - a espera de 200 ms;
  - a R12;
  - os saltos (`OpenAt`, órfão, `ContinueReading`);
  - cada correção da revisão.
- [ ] gitleaks nos commits da fase e nas pastas tocadas.
- [ ] **Capturas** (`capturas_g19_test.dart`, `BOOKNEST_CAPTURAS`):
  - a 25 inteira e o lado a lado com a prancha;
  - Notas; coral; busca "ressaca";
  - os dois vazios;
  - Mais opções;
  - Exportar (com o Markdown gerado num arquivo ao lado);
  - "Cartão apagado";
  - o salto com "← Voltar à pág. 159" no leitor.
- [ ] **Documentos:**
  - `G19.md`: Resultados, Revisão, Desvios (a cor sem a D-32 aqui; o que mais aparecer), Pendências, Capturas e o
    checklist;
  - `RELATORIO_G19.md`;
  - o projeto: `handoff_app_completo/relatorios/RELATORIO_G19.md` e `05_DECISOES_E_PERGUNTAS.md`.
- [ ] Fim: "✅ FASE G19 concluída — aguardando sua aprovação para iniciar a FASE G20."
