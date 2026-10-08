# G18 — Espaço aberto e nota à mão (telas 24 e 24b): plano de implementação

> **Para quem executa:** execução inline (superpowers:executing-plans), uma tarefa por vez, TDD: o teste falha no
> Windows (RED), o código mínimo passa (GREEN), commit pequeno. Passos com `- [ ]`.

**Objetivo:** as telas 24 e 24b idênticas às pranchas e funcionando: o Espaço abre um lugar entre as linhas depois
da frase (D-181), em linhas inteiras (D-41), com o texto de baixo refeito sem recuo; a nota à mão nasce com a
Caneta (D-187), cresce pela alça até a tinta (D-186), recolhe numa faixa (D-184), apaga com Desfazer (D-185); o
Concluir grava a camada `space` e a anotação `handwriting` (sem as vazias — D-188); o leitor limpo mostra a caixa
(D-183) e repagina com os espaços.

**Arquitetura:**
- **Layout (G10):** o `SpaceCut` (âncora, altura, id) entra no `BlockLayouter` (o parágrafo vira segmentos na âncora;
  o seguinte sem recuo; o `LaidText` guarda os `gaps`) e no `ChapterPaginator` (a `SpaceSlice`, inteira ou na página
  seguinte). O `layoutPageFrom` e o `BookPager` recebem os cortes; o `PageBreaks` guarda a assinatura dos espaços de
  cada capítulo. A `DisplayPage` ganha `spaces` (id e retângulo de cada espaço da página).
- **Motor da nota (puro):** `lib/features/reader/annotations/space/` — `space_metrics.dart` (as alturas da D-182),
  `space_seam.dart` (a fresta e a âncora da R1), `note_ink.dart` (a tinta na unidade da nota: x 0–1, y em linhas de
  42 px) e `hand_note_layout.dart` (a geometria da caixa, da faixa e do abridor).
- **Sessão:** a `InkWorkingCopy` ganha as notas (`SessionNote`) e os comandos (`OpenNote`, `ChangeNote`,
  `DeleteNote`, `AddNoteStroke`); a `AnnotationSession` recebe uma `AnnotationPageSource` (a página do modo com os
  espaços e as áreas dos grifos), refaz a página a cada mudança de espaço e leva cada desenho junto com as palavras
  dele (uma translação por desenho, aplicada também à pilha do desfazer). O `InkChanges` passa ao formato 3 e o
  `InkRepository` grava as notas na transação.
- **Tela:** `space_opener.dart` (24), `hand_note.dart` (pintura da caixa e da faixa, os botões, a dica e a alça),
  o `AnnotationMode` (subtítulo pela ferramenta, as notas por cima do canvas, a pílula "Nota apagada"), o
  `ReaderScreen` (a fonte da página do modo, o `respace` depois do Concluir e do toque na faixa) e o
  `ReaderPagesPainter` (a caixa e a faixa no leitor limpo).

**Pilha:** Flutter/Dart, drift, flutter_svg, flutter_test, goldens @3x, `tools/compare_images.py`.

**Execução e ambiente (igual à G17):**
- Código escrito no espelho `/home/claude/g03/repo`, levado ao Windows por `ciclo.sh` + `expandir.ps1`; `dart
  format`, `dart analyze` e `flutter test <arquivo>` no Windows; os arquivos formatados voltam por `puxar.sh`.
- Commits pequenos (`tools/medicao/tmp/commits_g18<letra>.ps1` + `msg_g18_NN.txt`, `novo_commit18.sh`), mensagem
  `tipo(escopo): descrição` em português, com o rodapé `Co-Authored-By` e `Claude-Session`. Leituras do git com
  `git --no-optional-locks`; nenhum `index.lock` fica.
- Spec: `docs/progresso/G18.md` (D-181…D-189, regras R1…R15). As seções do desenho são citadas como §1…§6.

## Arquivos

| Arquivo | Responsabilidade | Tarefa |
|---|---|---|
| `lib/features/reader/annotations/space/space_metrics.dart` (novo) | alturas da D-182/D-184, n do arrasto, linhas mínimas | 1 |
| `lib/features/reader/layout/space_cut.dart` (novo) | `SpaceCut`, cortes de um bloco, assinatura | 1 |
| `lib/features/reader/layout/laid_block.dart` | segmentos na âncora, `LaidGap`, altura com os buracos | 2 |
| `lib/features/reader/layout/paginator.dart`, `page_painter.dart` | `SpaceSlice` (R12) | 3 |
| `lib/features/reader/layout/chapter_layout.dart` | cortes no job e no `layoutPageFrom` (página que começa no espaço, altura do modo) | 4 |
| `lib/core/data/database/daos/content_daos.dart`, `lib/features/reader/application/book_pager.dart` | assinatura no cache, `spaces`, `respace` | 5 |
| `lib/features/reader/layout/display_page.dart`, `page_snapshot.dart`, PDF e testes de apoio | `DisplayPage.spaces` | 6 |
| `lib/features/reader/annotations/space/space_seam.dart` (novo) | R1 e a frase da âncora (R13) | 7 |
| `lib/features/reader/annotations/space/note_ink.dart` (novo), `bnk1_codec.dart` (comentário) | unidade da nota (R6), linhas escritas (R7) | 8 |
| `lib/features/reader/annotations/ink/ink_commands.dart` | `SessionNote`, comandos das notas, `remap` | 9 |
| `lib/features/reader/application/annotation_session.dart`, `annotation_page_source.dart` (novo) | a página do modo, o Espaço, as notas, a tinta na nota | 10, 11 |
| `lib/features/reader/annotations/ink/ink_changes.dart` | `NoteRow`, formato 3 | 12 |
| `lib/features/reader/annotations/ink_repository.dart`, `annotation_daos.dart`, `test/support/fake_ink_repository.dart` | notas na transação, leitura, `setCollapsed` | 13 |
| `lib/features/reader/application/reader_ink.dart`, `epub_reader_document.dart`, `reader_document.dart` | notas no leitor, cortes, `respace` | 14 |
| `pubspec.yaml`, `app_icons_leitor.dart`, `lib/features/reader/presentation/space_opener.dart` (novo) | ícones e o abridor (L24.1–L24.2) | 15 |
| `lib/features/reader/presentation/annotation_mode.dart`, `annotation_canvas.dart`, `reader_screen.dart`, `annotation_session.dart` | o Espaço no modo, R4, a página do modo (L24.3) | 16 |
| `lib/features/reader/annotations/space/hand_note_layout.dart` (novo), `lib/features/reader/presentation/hand_note.dart` (novo) | geometria e pintura da caixa e da faixa (L24b.1, L24b.3) | 17 |
| `hand_note.dart`, `annotation_mode.dart` | botões, dica, alça, recolher, apagar (L24b.2, L24b.4) | 18 |
| `lib/features/reader/presentation/reader_page_view.dart`, `reader_screen.dart` | a nota no leitor limpo, toque na faixa, leitor de tela, Noite | 19 |
| `test/fixtures/tinta_do_mundo.dart`, `mundo_2026_09_20.dart`, `telas/t24b.dart`, `telas/instantaneo.dart`, `test/support/dados_t24.dart` (novo) | R15 e o mundo das telas 24 e 24b | 20 |
| `test/support/fase_l24.dart`, `pecas_l24.dart` (novos), `test/features/reader/presentation/l24_test.dart`, `l24b_test.dart`, `test/golden/leitor_24_test.dart` (novos) | fases e golden | 21 |
| `test/features/reader/presentation/reader_screen_g18_test.dart` (novo) | comportamento | 22 |
| `test/golden/capturas_g18_test.dart` (novo), docs | prova e relatório | 23 |

---

## G18.1 — Layout com espaços

### Tarefa 1: métricas da nota e o corte

**Arquivos:** criar `lib/features/reader/annotations/space/space_metrics.dart` e
`lib/features/reader/layout/space_cut.dart`; testes `test/features/reader/annotations/space/space_metrics_test.dart`
e `test/features/reader/layout/space_cut_test.dart`.

- [ ] **Passo 1 (RED):**

```dart
// G18 — as alturas das pranchas 24 e 24b (D-182, D-184) e o n do arrasto (D-41, R2).
import 'package:app_leitura/features/reader/annotations/space/space_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const l = 35.26; // a linha da tela 19 (20,5 × 1,72)
  test('abridor (24): área n·L − 2, margens 14/24 → 3 linhas = 103,78 e 141,78 no fluxo', () {
    expect(openerAreaHeight(3, l), closeTo(103.78, 1e-9));
    expect(openerFlowHeight(3, l), closeTo(141.78, 1e-9));
  });
  test('caixa (24b): 42·n + 24, margens 30/26 → 3 linhas = 150 e 206', () {
    expect(noteBoxHeight(3), 150);
    expect(noteFlowHeight(3), 206);
    expect(noteBoxHeight(1), 66);
    expect(noteBoxHeight(12), 528);
  });
  test('faixa recolhida (D-184): uma linha do texto, margens 10/10', () {
    expect(stripFlowHeight(l), closeTo(55.26, 1e-9));
  });
  test('n do arrasto: (y do dedo − topo da área + 2) ÷ L, arredondado, de 1 a 12 (D-41)', () {
    expect(linesOfDrag(103.78, l), 3); // o dedo na borda de baixo da 24
    expect(linesOfDrag(0, l), 1);
    expect(linesOfDrag(-40, l), 1);
    expect(linesOfDrag(52, l), 2); // 1,53 → 2
    expect(linesOfDrag(50, l), 1); // 1,47 → 1
    expect(linesOfDrag(2000, l), 12);
  });
  test('pautas a cada 42 a partir de 22: 64 e 106 com 3 linhas', () {
    expect(noteRulesY(3), [64, 106]);
    expect(noteRulesY(1), isEmpty);
  });
  test('linhas escritas (D-186): a menor caixa que contém a tinta', () {
    expect(linesForInk(0), 1);
    expect(linesForInk(64), 1); // até a 1ª pauta
    expect(linesForInk(64.5), 2);
    expect(linesForInk(103.2), 2); // a tinta da 24b
    expect(linesForInk(600), 12);
  });
}
```

`space_cut_test.dart`: `cutsIn([SpaceCut(at: 10…), SpaceCut(at: 40…)], start: 0, length: 40)` → só os dois (o fim do
bloco conta, o começo não: `at` em `(start, start + length]`); devolve a posição dentro do bloco; `spaceSignature` de
uma lista vazia é `''` e muda com a âncora e com a altura (2 casas).

- [ ] **Passo 2 (GREEN):**

```dart
// G18 — as medidas da nota à mão e do abridor (D-182, D-184, D-186; pranchas 24 e 24b).
import 'dart:math' as math;

/// A pauta da nota (24b): uma linha da nota = 42 px; a caixa = 42·n + 24; a 1ª pauta em 22 + 42.
const double noteLinePx = 42;
const double noteBoxExtra = 24;
const double noteFirstRuleTop = 22;
const double noteMarginTop = 30;
const double noteMarginBottom = 26;

/// O abridor (24): a área = n·L − 2, com margens 14/24.
const double openerMarginTop = 14;
const double openerMarginBottom = 24;

/// A faixa recolhida (D-184): uma linha do texto, margens 10/10.
const double stripMargin = 10;

/// D-41.
const int minSpaceLines = 1;
const int maxSpaceLines = 12;

double noteBoxHeight(int n) => noteLinePx * n + noteBoxExtra;
double noteFlowHeight(int n) =>
    noteMarginTop + noteBoxHeight(n) + noteMarginBottom;
double openerAreaHeight(int n, double lineHeight) => n * lineHeight - 2;
double openerFlowHeight(int n, double lineHeight) =>
    openerMarginTop + openerAreaHeight(n, lineHeight) + openerMarginBottom;
double stripFlowHeight(double lineHeight) => 2 * stripMargin + lineHeight;

/// R2: [dy] = do topo da área até o dedo.
int linesOfDrag(double dy, double lineHeight) =>
    ((dy + 2) / lineHeight).round().clamp(minSpaceLines, maxSpaceLines);

/// As pautas de uma caixa de [n] linhas (y a partir do topo da caixa).
List<double> noteRulesY(int n) => [
  for (var k = 1; k < n; k++) noteFirstRuleTop + noteLinePx * k,
];

/// D-186: as linhas da menor caixa que contém a tinta até [inkBottom] (px a partir do topo da caixa).
int linesForInk(double inkBottom) =>
    ((inkBottom - noteFirstRuleTop) / noteLinePx - 1e-9).ceil().clamp(
      minSpaceLines,
      maxSpaceLines,
    );
```

```dart
// G18 — um espaço aberto no fluxo do item (Anexo 03 §7.2, D-181): depois do caractere [at] (a âncora), um bloco
// de [height] px; [id] = a camada (ou o abridor).
final class SpaceCut {
  const SpaceCut({required this.at, required this.height, required this.id});
  final int at;
  final double height;
  final String id;
  // ==, hashCode, toString
}

/// Os cortes do bloco que começa em [start] com [length] caracteres, na posição dentro dele, em ordem.
List<({int at, double height, String id})> cutsIn(
  List<SpaceCut> cuts, {required int start, required int length}) => [
  for (final c in [...cuts]..sort((a, b) => a.at.compareTo(b.at)))
    if (c.at > start && c.at <= start + length)
      (at: c.at - start, height: c.height, id: c.id),
];

/// A assinatura dos espaços de um capítulo (o cache das páginas — §1).
String spaceSignature(List<SpaceCut> cuts) => ([...cuts]
      ..sort((a, b) => a.at.compareTo(b.at)))
    .map((c) => '${c.at}:${c.height.toStringAsFixed(2)}')
    .join(',');
```

- [ ] **Passo 3:** passa. Commit `feat(leitor): medidas da nota à mão e o corte de espaço (D-182, D-184)`.

### Tarefa 2: o parágrafo partido na âncora

**Arquivos:** `lib/features/reader/layout/laid_block.dart`; teste `test/features/reader/layout/laid_block_test.dart`.

- [ ] **Passo 1 (RED):** no grupo novo `espaço aberto (G18, D-181)`, com o `paragrafoDaPagina159` (com os trechos da
  D-160 em NBSP, como `trechosDaTela22`) e o corte logo depois de "Vá, de ressaca.":
  - o 1º segmento acaba na âncora: a última linha dele termina com "Vá, de ressaca." e o `end` dela é o começo de
    "É" (o branco fica na linha, como toda linha);
  - o 2º segmento começa em "É", **sem recuo** (o 1º pedaço dele não tem U+FFFC), e as linhas dele são as da
    `kRef24` `sp.page.textBelow` (`linesAll`: "É o que me dá ideia daquela feição", "nova. Traziam não sei que",
    "fluido misterioso e enérgico, uma"…);
  - `gaps == [LaidGap(afterLine: k, height: 141.78, id: 'abridor', at: âncora)]`, com k = a última linha do 1º
    segmento; `height` = linhas + `extraBottom` + soma dos buracos; os `top` das linhas não contam o buraco;
  - `toCanonical`/`toParagraph` e `lineAt` vão e voltam nos dois segmentos;
  - corte no fim do parágrafo: nada é partido (as linhas iguais às sem corte) e o buraco fica depois da última;
  - parágrafo longo (com `pieceChars: 200`): os segmentos continuam com as linhas do layout inteiro de cada um;
  - sem cortes: tudo igual ao de antes (os testes da G10 seguem verdes).
- [ ] **Passo 2 (GREEN):**
  - `final class LaidGap { const LaidGap({required this.afterLine, required this.height, required this.id, required
    this.at}); final int afterLine; final double height; final String id; final int at; }` (com `==`);
  - `LaidText` ganha `final List<LaidGap> gaps` (padrão `const []`); `height => (lines.isEmpty ? 0 :
    lines.last.bottom) + extraBottom + gaps.fold(0.0, (s, g) => s + g.height)`;
  - `BlockLayouter.layout/begin(..., List<SpaceCut> cuts = const [])` passa ao `_TextTask` os
    `cutsIn(cuts, start: start, length: b.text.length)`; imagem e quebra de cena ignoram;
  - no `_TextTask`, o segmento vai de `_pos` até `_segEnd` (o próximo corte ou o fim do texto):

```dart
int get _segEnd => _cut < _cuts.length ? _cuts[_cut].at : text.length;

/// O 1º caractere depois do branco que vem em [at] (o começo do segmento seguinte).
int _after(int at) {
  var i = at;
  while (i < text.length && (text.codeUnitAt(i) == 0x20 || text.codeUnitAt(i) == 0x0A)) {
    i++;
  }
  return i;
}

@override
bool step() {
  if (_result != null) return true;
  final segEnd = _segEnd;
  var end = _pos + _pieceChars;
  if (end >= segEnd) {
    end = segEnd;
  } else {
    // (o mesmo ajuste ao espaço de hoje, com `segEnd` no lugar de `text.length`)
  }
  final last = end >= segEnd;
  final first = _pos == 0;
  final placeholder = first && indent;
  // … o Paragraph, as métricas, `keep` e `starts` como hoje …
  for (var i = 0; i < keep; i++) {
    // … a linha de hoje, com o fim da última linha do segmento no começo do seguinte:
    final e = i + 1 < metrics.length
        ? canonical(starts[i + 1])
        : start + (segEnd == text.length ? text.length : _after(segEnd));
    // …
  }
  if (!last) {
    _pos += starts[keep] - (placeholder ? 1 : 0);
    return false;
  }
  if (_cut < _cuts.length) {
    final c = _cuts[_cut++];
    _gaps.add(LaidGap(afterLine: _lines.length - 1, height: c.height, id: c.id, at: start + c.at));
    if (c.at < text.length && _after(c.at) < text.length) {
      _pos = _after(c.at); // o próximo segmento: sem recuo (`_pos > 0`)
      return false;
    }
  }
  _finish();
  return true;
}
```

  `_finish` passa `gaps: List.unmodifiable(_gaps)`.
- [ ] **Passo 3:** passa (e `laid_block_test`, `page_rects_test`, `tela19_gate_test` seguem verdes). Commit
  `feat(leitor): o parágrafo partido na âncora do espaço, o resto sem recuo (D-181)`.

### Tarefa 3: a fatia do espaço no paginador (R12)

**Arquivos:** `lib/features/reader/layout/paginator.dart`, `page_painter.dart`; teste
`test/features/reader/layout/paginator_test.dart`.

- [ ] **Passo 1 (RED):** grupo `espaço (G18, R12)`:
  - o buraco que cabe: `TextSlice` das linhas de cima, `SpaceSlice(bloco, 0, y)` com o `y` depois delas, e as linhas
    de baixo começam em `y + altura`;
  - o buraco que não cabe no resto: a página fecha nas linhas de cima e a seguinte começa com a `SpaceSlice` em
    `y = 0`; a página seguinte tem `start` = a âncora e a anterior acaba no fim da linha de cima;
  - o buraco cabe e a linha de baixo não: o espaço fica no pé, a página seguinte começa na linha de baixo
    (`start` = o 1º caractere dela, diferente da âncora);
  - buraco no fim do parágrafo: entre os dois blocos; título com buraco é partido como texto comum;
  - `addFrom(b, firstLine, gap: 0)` começa a página com o espaço; `addFrom(b, firstLine)` sem ele;
  - sem buracos, as páginas iguais às de antes.
- [ ] **Passo 2 (GREEN):**

```dart
/// G18 — um espaço aberto (o buraco [gap] do bloco de texto [block]), inteiro.
final class SpaceSlice extends PageSlice {
  const SpaceSlice(super.block, this.gap, super.y);
  final int gap;
}
```

```dart
case LaidText(keepTogether: true) when b.height <= _limit && b.gaps.isEmpty:
  // (o de hoje)
case LaidText():
  _placeText(i, b, from: from, gapFirst: gapFirst);
```

```dart
void _placeText(int i, LaidText b, {required int from, int? gapFirst}) {
  final gaps = b.gaps;
  // buracos já postos em páginas anteriores ficam de fora
  var g = gapFirst ?? gaps.indexWhere((x) => x.afterLine >= from);
  if (g < 0) g = gaps.length;
  var l = from;
  while (true) {
    while (g < gaps.length && gaps[g].afterLine == l - 1) {
      _placeGap(i, g++, gaps[g - 1].height);
    }
    if (l >= b.lines.length) break;
    final stop = g < gaps.length ? gaps[g].afterLine + 1 : b.lines.length;
    l = _fillLines(i, b, l, stop);
  }
  if (b.extraBottom > 0) _y += b.extraBottom;
}

/// As linhas [from, stop) de [b], fechando as páginas que encherem (o de hoje, até [stop]).
int _fillLines(int i, LaidText b, int from, int stop) {
  var l = from;
  while (l < stop) {
    final first = l;
    final top = b.lines[l].top;
    while (l < stop && _y + (b.lines[l].bottom - top) <= _limit) {
      l++;
    }
    if (l == first) {
      if (_current.isEmpty) {
        l++;
      } else {
        _close();
        continue;
      }
    }
    _current.add(TextSlice(i, first, l - 1, _y));
    _y += b.lines[l - 1].bottom - top;
    if (l < stop) _close();
  }
  return l;
}

/// R12: o espaço inteiro aqui; se não cabe no resto, na página seguinte.
void _placeGap(int i, int g, double h) {
  if (_y > 0 && _y + h > _limit) _close();
  _current.add(SpaceSlice(i, g, _y));
  _y += h;
}
```

  `addFrom(LaidBlock b, int firstLine, {int? gap})` passa `gapFirst: gap`; `_startOf`/`_endOf` da `SpaceSlice` =
  `(_block(block) as LaidText).gaps[gap].at`. No `paintReaderPage`, a `SpaceSlice` não pinta nada (quem pinta é a
  tinta — §4/§5): o `default` já cobre; conferir os `switch` exaustivos com o `dart analyze`.
- [ ] **Passo 3:** passa. Commit `feat(leitor): o espaço como fatia da página, inteiro ou na seguinte (R12)`.

### Tarefa 4: os cortes no layout do capítulo e na página avulsa

**Arquivos:** `lib/features/reader/layout/chapter_layout.dart`; teste
`test/features/reader/layout/chapter_layout_test.dart`.

- [ ] **Passo 1 (RED):**
  - `ChapterLayoutJob(content, t, cuts: [corte])` pagina com a `SpaceSlice`; as páginas depois dela andam;
  - `layoutPageFrom(content, t, âncora, cuts: …)` monta a página que começa com o espaço; com o começo da linha de
    baixo, a que começa nela (os dois começos do Passo 1 da Tarefa 3);
  - `layoutPageFrom(…, contentHeight: h)` com `h` maior que o da tela: a página leva as linhas até `h` (a página do
    modo — §3, R3); o começo é o mesmo;
  - um início que não cai em linha nem em âncora → `null` (como hoje).
- [ ] **Passo 2 (GREEN):** o job guarda `cuts` e passa ao `begin` de cada bloco; o `layoutPageFrom(content, t,
  start, {List<SpaceCut> cuts = const [], double? contentHeight})` usa `ChapterPaginator(contentHeight ??
  t.contentHeight, firstBlock: k)`; no bloco `k` de texto, `final gi = b.gaps.indexWhere((g) => g.at == start)`: com
  `gi >= 0`, `paginator.addFrom(b, b.gaps[gi].afterLine + 1, gap: gi)`; senão a linha com `l.start == start`.
- [ ] **Passo 3:** passa. Commit `feat(leitor): cortes de espaço no layout do capítulo e na página avulsa`.

### Tarefa 5: o cache e o pager com os espaços

**Arquivos:** `lib/core/data/database/daos/content_daos.dart` (`PageBreaks.spaces`),
`lib/features/reader/application/book_pager.dart`; testes `test/features/reader/layout/page_layout_cache_test.dart`,
`test/features/reader/application/book_pager_test.dart`.

- [ ] **Passo 1 (RED):**
  - `PageBreaks(sha:, chapters:, spaces: {3: '120:206.00'})` ida e volta; o blob antigo (sem `s`) é lido com
    `spaces` vazio;
  - pager com `spaces: (spine, t) => [corte]`: as páginas do capítulo 3 têm a `SpaceSlice`; o cache guarda a
    assinatura; reabrir com outra assinatura não usa os inícios guardados daquele capítulo (pagina de novo) e usa os
    dos outros;
  - `respace()` repagina e volta à página que contém o caractere que a pessoa está lendo (`anchor`).
- [ ] **Passo 2 (GREEN):**
  - `typedef SpaceCutsOf = List<SpaceCut> Function(int spine, ReaderTypography t);` em `space_cut.dart`;
  - `BookPager({…, SpaceCutsOf? spaces})` com o campo mutável `spaces`; `List<SpaceCut> _cutsOf(int spine) =>
    spaces?.call(spine, _t) ?? const []`; o `_ensureJob` e o `_quickPage` passam os cortes;
  - `_cachedStarts(spine)`: só vale se `(_breaks?.spaces[spine] ?? '') == spaceSignature(_cutsOf(spine))`;
  - `_saveStarts` grava `spaces: {...?_breaks?.spaces, spine: spaceSignature(_cutsOf(spine))}` (sem entrada quando
    `''`);
  - `Future<PagerPosition> respace() => relayout(_t);` (os outros capítulos voltam pelo cache, que continua valendo).
- [ ] **Passo 3:** passa. Commit `feat(leitor): o pager e o cache das páginas com os espaços de cada capítulo`.

### Tarefa 6: os espaços da página

**Arquivos:** `lib/features/reader/layout/display_page.dart`, `page_snapshot.dart`; as outras `DisplayPage`
(`pdf_page`, as de teste em `test/support/`); teste `test/features/reader/layout/page_snapshot_test.dart`.

- [ ] **Passo 1 (RED):** a página com a `SpaceSlice` dá `spaces == [(id: 'n1', rect: Rect.fromLTWH(28, 92 + y,
  334, 206))]` (lado e largura do texto, topo = `topInset + y`); `boxesOf`, `spotAt` e `wordAround` das linhas de
  baixo já vêm deslocados; `spokenText` não muda.
- [ ] **Passo 2 (GREEN):** `typedef PageSpace = ({String id, ui.Rect rect});` e `List<PageSpace> get spaces` na
  interface (padrão `const []` nas que não são EPUB); no `PageSnapshot`, a altura sai do `LaidGap`.
- [ ] **Passo 3:** passa. Commit `feat(leitor): a página diz onde estão os espaços dela`.

## G18.2 — Dados e sessão

### Tarefa 7: a costura e a âncora (R1)

**Arquivos:** criar `lib/features/reader/annotations/space/space_seam.dart`; teste
`test/features/reader/annotations/space/space_seam_test.dart`.

- [ ] **Passo 1 (RED):**

```dart
void main() {
  const t = 'Olhos de ressaca? Vá, de ressaca. É o que me dá ideia daquela feição nova.\nOutro parágrafo';
  test('o fim da última frase da linha (D-181)', () {
    final fim = t.indexOf('ressaca. ') + 'ressaca.'.length;
    expect(anchorAfterLine(t, 0, t.indexOf(' que')), fim);
  });
  test('aspas e parêntese que fecham entram na frase', () {
    const s = 'Ele disse: “Vá.” E saiu de casa.';
    expect(anchorAfterLine(s, 0, s.indexOf(' saiu')), s.indexOf('” E') + 1);
  });
  test('sem frase na linha: o fim da linha (o branco depois da última palavra)', () {
    expect(anchorAfterLine(t, 34, t.indexOf(' daquela')), t.indexOf(' daquela'));
  });
  test('linha partida no hífen: o último branco dela; sem branco, nada', () {
    const s = 'às outras partes agarrei-me depois';
    expect(anchorAfterLine(s, 0, s.indexOf('-me') + 1), s.indexOf(' agarrei'));
    const u = 'paralelepípedo-ônibus';
    expect(anchorAfterLine(u, 0, u.indexOf('-') + 1), isNull);
  });
  test('linha que fecha o parágrafo: o fim dele, sem partir', () {
    expect(anchorAfterLine(t, 34, t.indexOf('\n')), t.indexOf('\n'));
  });
  test('reticências e "!" fecham frase; ponto sem branco depois ("3.5") não', () {
    const s = 'Pensou… Depois saiu! Mediu 3.5 metros e';
    expect(anchorAfterLine(s, 0, s.indexOf(' saiu')), s.indexOf('…') + 1);
    expect(anchorAfterLine(s, 0, s.indexOf(' e')), s.indexOf('!') + 1);
  });
  test('a frase da âncora (R13)', () {
    expect(sentenceBefore(t, t.indexOf('ressaca. ') + 8), 'Vá, de ressaca.');
  });
}
```

  `seamAt(geometria, y, textOf)`: a fresta mais perto de `y` (a base de cada linha da página); `y` acima do topo
  da 1ª linha → `null` (R1: precisa de uma linha acima); sem linha → `null`; devolve `(unit, at, line, y)` com `y` =
  a base da linha de cima; na pág. 159 do mundo, a fresta abaixo da linha de "Vá, de ressaca." dá a âncora da
  fixture.
- [ ] **Passo 2 (GREEN):**

```dart
const String _enders = '.?!…';
const String _closers = '"\'”’»)]';

bool _blank(int c) => c == 0x20 || c == 0x0A || c == 0x09;

/// R1 (D-181): a âncora do espaço aberto depois da linha [from, to) do texto [text] (`to` = o fim da última
/// palavra dela). `null` = a linha não tem onde partir.
int? anchorAfterLine(String text, int from, int to) {
  int? last;
  for (var i = from; i < to; i++) {
    if (!_enders.contains(text[i])) continue;
    var j = i + 1;
    while (j < text.length && _closers.contains(text[j])) {
      j++;
    }
    if (j == text.length || _blank(text.codeUnitAt(j))) last = j;
  }
  if (last != null && last <= to) return last;
  // sem frase: o fim da linha, se ela quebra num branco (ou fecha o parágrafo)
  if (to >= text.length || _blank(text.codeUnitAt(to))) return to;
  // quebrada no meio de uma palavra (hífen): o último branco da linha
  for (var i = to - 1; i > from; i--) {
    if (_blank(text.codeUnitAt(i))) return i;
  }
  return null;
}

/// R13: a frase que termina em [at] (desde o fim da frase anterior ou o começo do parágrafo); sem frase, as
/// últimas palavras (até 6).
String sentenceBefore(String text, int at) {
  var start = 0;
  for (var i = at - 2; i > 0; i--) {
    final c = text.codeUnitAt(i);
    if (c == 0x0A) {
      start = i + 1;
      break;
    }
    if (!_blank(c)) continue;
    var k = i - 1;
    while (k >= 0 && _closers.contains(text[k])) {
      k--;
    }
    if (k >= 0 && _enders.contains(text[k])) {
      start = i + 1;
      break;
    }
  }
  final s = text.substring(start, at).trim();
  final last = s.isEmpty ? '' : s[s.length - 1];
  if (_enders.contains(last) || _closers.contains(last)) return s;
  final words = s.split(RegExp(r'\s+'));
  return words.length <= 6 ? s : words.sublist(words.length - 6).join(' ');
}

typedef SpaceSeam = ({int unit, int at, int line, double y});

/// R1: a fresta entre linhas mais perto de [y] (coordenadas da página) e a âncora dela.
SpaceSeam? seamAt(InkPageGeometry g, double y, String? Function(int unit) textOf) {
  final lines = g.lines;
  if (lines.isEmpty || y < lines.first.top) return null;
  var best = 0;
  for (var i = 1; i < lines.length; i++) {
    if ((lines[i].bottom - y).abs() < (lines[best].bottom - y).abs()) best = i;
  }
  final line = lines[best];
  final text = textOf(line.unit);
  final at = text == null ? null : anchorAfterLine(text, line.from, line.to);
  if (at == null) return null;
  return (unit: line.unit, at: at, line: best, y: line.bottom);
}
```

- [ ] **Passo 3:** passa. Commit `feat(tinta): a costura do Espaço depois da frase (R1, D-181)`.

### Tarefa 8: a tinta na unidade da nota (R6, R7)

**Arquivos:** criar `lib/features/reader/annotations/space/note_ink.dart`; `bnk1_codec.dart` (só o comentário da
unidade `box`); teste `test/features/reader/annotations/space/note_ink_test.dart`.

- [ ] **Passo 1 (RED):**
  - `toNote(traço, caixa)`: x = (px − esquerda) ÷ largura; y = (py − topo) ÷ 42; `fromNote` volta (±1e-9);
  - ida e volta no BNK1 `box` (quantização 1/10000: ±0,5 · 334/10000 px em x, ±0,5 · 42/10000 em y);
  - `inkBottomPx(traços)` = o maior y + metade da largura (`strokeDp`); `minLinesFor(traços) =
    linesForInk(inkBottomPx)`;
  - `startsInside(ponto, caixa)` (R6: só o 1º ponto conta).
- [ ] **Passo 2 (GREEN):** funções puras sobre `InkStroke`/`InkPoint` (`copyWith(points: …)`), com `noteLinePx` da
  Tarefa 1. Comentário do `Bnk1Unit.box`: "`space`: x em 1/10000 da largura da caixa; y em 1/10000 de linha da nota
  (42 px) — Anexo 03 §9.5".
- [ ] **Passo 3:** passa. Commit `feat(tinta): a tinta da nota na unidade da caixa (R6)`.

### Tarefa 9: as notas na cópia de trabalho e a pilha (R5, R7–R9)

**Arquivos:** `lib/features/reader/annotations/ink/ink_commands.dart`; teste
`test/features/reader/annotations/ink/ink_commands_test.dart`.

- [ ] **Passo 1 (RED):**
  - `OpenNote(nota)` aplica e desfaz; `ChangeNote(antes, depois)` (n, recolhida) aplica e desfaz;
    `DeleteNote(id)` tira e devolve no mesmo lugar, com os traços; `AddNoteStroke(id, traço)` aplica e desfaz;
  - `Erase` com ids de traços da nota tira da nota (e devolve); `MoveStrokes` com traços da nota os move dentro dela
    (o alvo é a nota, não um desenho novo);
  - `remap`: a translação de cada desenho (por id) vale na cópia e nos estados guardados dos comandos (`AddStroke`,
    `Erase._before`, `MoveStrokes._before` e os traços movidos); desfazer e refazer depois do `remap` dão os traços
    transladados; as notas não mudam (a tinta delas é da caixa);
  - `MoveStrokes` guarda os traços movidos na 1ª aplicação e refaz com eles.
- [ ] **Passo 2 (GREEN):**

```dart
/// G18 — uma nota à mão da página: a camada `space` (o id), a âncora, as linhas, recolhida, os traços (na unidade
/// da nota — Tarefa 8) e o que ela já tinha no banco.
@immutable
final class SessionNote {
  const SessionNote({
    required this.id,
    required this.unit,
    required this.at,
    required this.lines,
    required this.collapsed,
    required this.strokes,
    required this.createdAt,
    this.saved,
  });
  final String id;
  final int unit;
  final int at;
  final int lines;
  final bool collapsed;
  final List<SessionStroke> strokes;
  final DateTime createdAt;
  final SavedDrawingRef? saved;
  SessionNote copyWith({int? lines, bool? collapsed, List<SessionStroke>? strokes}) => …;
  // ==, hashCode
}

/// A translação do desenho [drawingId] (a página do modo mudou — Tarefa 10); `null` = fica.
typedef InkShift = ({double dx, double dy})? Function(String drawingId, List<SessionStroke> strokes);
```

  `InkWorkingCopy` ganha `final List<SessionNote> _notes` (com `notes`, `note(id)`, `_putNote`, `_removeNote`,
  `noteOfStroke`); `sealed InkCommand` ganha `void remap(InkWorkingCopy w, InkShift shift) {}` (padrão nada) e os
  comandos de traço sobrescrevem; `InkWorkingCopy.remap(shift)` translada cada desenho pelo próprio id;
  `InkHistory.remap(shift)` passa a todos os comandos (feitos e desfeitos).
- [ ] **Passo 3:** passa. Commit `feat(tinta): notas à mão na cópia de trabalho e no desfazer`.

### Tarefa 10: a página do modo muda com as notas

**Arquivos:** criar `lib/features/reader/application/annotation_page_source.dart`; `annotation_session.dart`; teste
`test/features/reader/application/annotation_session_test.dart` (grupo `G18 · página do modo`).

- [ ] **Passo 1 (RED):** com uma `FakePageSource` (páginas montadas pelo `layoutPageFrom` sobre o
  `paragrafoDaPagina159`):
  - a sessão começa com a página e a geometria que recebeu; `notes` = as notas salvas da página;
  - abrir uma nota (pela API da Tarefa 11) refaz a página com o corte: a geometria das linhas de baixo desce, a
    elipse de "Olhos de ressaca?" (acima) fica, o ondulado de "fluido misterioso" (abaixo) desce junto com a palavra
    (`visibleStrokes` transladados), os grifos pintados seguem pelo texto, a seleção do Laço é solta;
  - desfazer a abertura: a página e a tinta voltam (±1e-9); o desenho salvo intocado não entra no `changes()`;
  - `revision` sobe a cada mudança da página.
- [ ] **Passo 2 (GREEN):**

```dart
/// G18 — a página do modo anotação com os espaços (o mesmo começo da página congelada; até o pé da tela — R3) e
/// as áreas dos grifos dela (a Borracha).
abstract interface class AnnotationPageSource {
  DisplayPage pageWith(List<SpaceCut> cuts);
  List<PageHighlight> highlightsOn(DisplayPage page);
  void dispose();
}
```

  Na sessão: `DisplayPage get page`, `InkPageGeometry get geometry` (agora mutáveis), `List<SessionNote> get notes`,
  `pageSource` (opcional: sem ela, o Espaço não abre — os testes da G16/G17 seguem como estão) e `otherCuts` (os
  espaços salvos do capítulo fora da página, para o layout de baixo). `_relayout()`:

```dart
void _relayout() {
  final source = pageSource;
  if (source == null) return;
  final next = source.pageWith([...otherCuts, ..._noteCuts()]);
  final old = geometry;
  final shifts = <String, ({double dx, double dy})?>{};
  ({double dx, double dy})? shift(String id, List<SessionStroke> strokes) =>
      shifts.putIfAbsent(id, () => _shiftOf(strokes, old, next));
  _copy.remap(shift);
  _history.remap(shift);
  for (final e in _initialStrokes.entries.toList()) {
    final s = shift(e.key, [for (final x in e.value) SessionStroke(-1, x)]);
    if (s != null) _initialStrokes[e.key] = [for (final x in e.value) x.translated(s.dx, s.dy)];
  }
  _page = next;
  _geometry = inkGeometryOf(next);
  _highlights = source.highlightsOn(next);
  selection.value = null;
  _repaint();
}

/// A translação de um desenho: o trecho dele na página velha (`placeDrawing`) e o mesmo trecho na nova
/// (`placedFrame` das caixas dele) — mesma letra, mesmo trecho: só anda.
({double dx, double dy})? _shiftOf(
  List<SessionStroke> strokes,
  InkPageGeometry old,
  DisplayPage next,
) {
  if (strokes.isEmpty) return null;
  final place = placeDrawing(drawingBox([for (final s in strokes) s.stroke]), old);
  if (place == null) return null;
  final unit = old.lines[place.line].unit;
  final frame = placedFrame([
    for (final b in next.boxesOf(unit, place.from, place.to))
      (left: b.rect.left, right: b.rect.right, baseline: b.baseline, em: b.em),
  ], place.frame.w);
  if (frame == null) return null;
  final dx = frame.x - place.frame.x;
  final dy = frame.baseline - place.frame.baseline;
  return dx == 0 && dy == 0 ? null : (dx: dx, dy: dy);
}
```

  (`_initialStrokes` usa o deslocamento calculado pelos traços salvos, o mesmo dos traços atuais quando o desenho não
  foi mexido — por isso o `changes()` continua sem regravar o que não mudou.) `_noteCuts()` = cada nota não apagada
  → `SpaceCut(at, collapsed ? stripFlowHeight(L) : noteFlowHeight(n), id)`, mais o abridor durante o arrasto
  (`openerFlowHeight`, id `'abridor'`).
- [ ] **Passo 3:** passa. Commit `feat(tinta): a página do modo refeita com os espaços, a tinta junto das palavras`.

### Tarefa 11: o Espaço, a tinta na nota e os controles na sessão (R1–R9)

**Arquivos:** `annotation_session.dart`; testes `annotation_session_test.dart` (grupo `G18 · Espaço e notas`).

- [ ] **Passo 1 (RED):**
  - `setTool(space)` vale (sem o aviso da D-163; `inThisPhase` sai); o 2º toque no Espaço não abre painel; com um
    painel aberto, fecha o painel e fica no Espaço;
  - **arrasto (R2):** `pointerDown` com o Espaço entre as linhas 8 e 9 → `opening.value = (seam, n: 1, finger)`;
    `pointerMove` até 3 linhas → `n == 3` e a página refeita com o abridor (`openerFlowHeight(3, L)`); um toque sem
    mover (folga do árbitro) → nada; acima da 1ª linha → nada; na costura de uma nota que existe, ou dentro de uma
    caixa (R5) → nada;
  - **ao soltar (R4, D-187):** nasce a `SessionNote` aberta com n = 3, id novo, `createdAt` = a hora; um passo no
    Desfazer; `tool == pen`; `opening.value == null`;
  - **2 dedos durante o arrasto:** o arrasto some (a página volta), a página move;
  - **tinta (R6):** o traço da Caneta que começa na caixa vai para a nota (`AddNoteStroke`, na unidade dela) e não
    vira desenho; o que começa fora vira desenho; o Marca-texto na caixa vira tinta translúcida da nota (sem
    grifo); a Borracha apaga traço da nota; o Laço que começa na caixa só pega a tinta dela;
  - **alça (R7, D-186):** `dragNoteHandle(id, dy)` muda n em passos de 42 sem ficar abaixo de `minLinesFor`; a
    página acompanha; `endNoteHandle(id)` empilha um `ChangeNote` (nenhum, se n não mudou);
  - **recolher (R8):** `toggleNote(id)` → `collapsed` e um passo; a faixa no lugar (altura da faixa no corte);
  - **apagar (R9, D-185):** `deleteNote(id)` → some, um passo, `noteDeleted.value = id`; `undoNoteDeletion()`
    desfaz se o último passo é esse; outro passo depois → não faz nada;
  - `hiddenHighlights`, contagens e o resto da G17 seguem verdes.
- [ ] **Passo 2 (GREEN):** `ValueNotifier<SpaceOpening?> opening` (`typedef SpaceOpening = ({SpaceSeam seam, int
  lines, InkOffset finger})`), `ValueNotifier<String?> noteDeleted`; `_drawStart` com `case AnnotationTool.space:`
  (a costura pela `seamAt` com `anchors.textOf`), `_drawMove` (n pela `linesOfDrag` a partir do topo da área =
  `seam.y + openerMarginTop`; refaz a página só quando n muda), `_drawEnd` (empilha `OpenNote`, `setTool(pen)`),
  `_drawDiscard` (desfaz o abridor). Antes do `case pen/line/marker/eraser/lasso` de hoje, `_noteAt(at)` decide se
  o traço é da nota (o retângulo da caixa vem de `page.spaces`).
- [ ] **Passo 3:** passa. Commit `feat(tinta): o Espaço abre a nota; tinta, alça, recolher e apagar na sessão (R1–R9)`.

### Tarefa 12: o Concluir com as notas e o rascunho no formato 3 (R10)

**Arquivos:** `lib/features/reader/annotations/ink/ink_changes.dart`, `annotation_session.dart` (`changes()`);
testes `ink_changes_test.dart`, `annotation_session_test.dart`.

- [ ] **Passo 1 (RED):**
  - `NoteRow(layerId, annotationId, createdAt, anchor (7 chaves, vazia na costura), range, refPage, chapterIndex,
    groupId, lines, collapsed, strokesB64 (unidade `box`), strokeCount)` e `InkChanges.notes` / `deletedNotes`; ida
    e volta no JSON v3; o v2 e o v1 (texto fixo no teste) lidos com as listas vazias; v4 → `null`;
  - `changes()`: a nota nova com traços → `NoteRow` (o grupo pelo `cardGroup` com os cartões da página); a nova sem
    traço → nada (D-188); a salva intocada → nada; a salva com outra altura, recolhida ou com traço novo → `NoteRow`
    com a mesma camada, anotação, grupo e criação; a salva que ficou sem traço → `deletedNotes`; a apagada →
    `deletedNotes`.
- [ ] **Passo 2 (GREEN):** o tipo, o JSON (`inkDraftVersion = 3`; `decodeDraft` lê 1, 2 e 3) e o `changes()`.
- [ ] **Passo 3:** passa. Commit `feat(tinta): o Concluir leva as notas à mão; rascunho no formato 3 (R10, D-188)`.

### Tarefa 13: as notas no banco

**Arquivos:** `lib/features/reader/annotations/ink_repository.dart`, `lib/core/data/database/daos/annotation_daos.dart`,
`test/support/fake_ink_repository.dart`; testes `ink_repository_test.dart`, `test/core/data/database/daos_test.dart`,
`test/features/reader/annotations/ink_privacy_free_test.dart`.

- [ ] **Passo 1 (RED):**
  - `InkLayersDao.liveSpacesForBook(userBookId)` só traz as `space` vivas; `AnnotationsDao.handwritingOfLayers(ids)`;
  - `commit` com `notes`: grava a camada `space` (`spaceLines`, `collapsed`, `strokesB64`, `strokeCount`) e a
    anotação `handwriting` (`inkLayerId`, `groupId`, `refPage`, `chapterIndex`, a âncora, `createdAt` da nota), com a
    versão HLC; a nota mudada regrava as duas; `deletedNotes` apaga as duas (com a versão); tudo na mesma transação
    da tinta e dos grifos;
  - `notesOfBook(userBookId)` → `SavedNote(layer, annotation)`; `setCollapsed(owner, layerId, false)` grava só o
    `collapsed` (com a versão);
  - a recuperação do rascunho (D-166) grava as notas do v3;
  - Grátis: nenhuma linha na fila, nenhuma chamada de rede; Pro: as linhas na fila.
- [ ] **Passo 2 (GREEN):** `_writeNote` / `_deleteNote` no `InkRepository` (o `_writeLayer` de hoje fica só para
  `over_text`); o `FakeInkRepository` guarda as notas e o `setCollapsed`.
- [ ] **Passo 3:** passa. Commit `feat(tinta): as notas à mão gravadas na transação da tinta`.

### Tarefa 14: as notas no leitor e o respace

**Arquivos:** `lib/features/reader/application/reader_ink.dart`, `epub_reader_document.dart`, `reader_document.dart`
(o `respace` no contrato, nada no PDF); testes `reader_ink_test.dart`, `epub_reader_document_test.dart`.

- [ ] **Passo 1 (RED):**
  - `ReaderInk` lê as notas do livro (`notesOfBook`), decodifica na unidade `box` e entrega `notesOn(page)` (as da
    página, pelo `page.spaces`) e `cutsOf(spine, t)` (`SpaceCut` com `noteFlowHeight`/`stripFlowHeight(t.lineHeight)`;
    a âncora pela `_placeOf` de hoje; sem lugar, fora);
  - mudar a altura ou recolher no banco → `revision` sobe e `cutsOf` muda;
  - `expand(id)` grava `collapsed = false`;
  - `EpubReaderDocument.respace()` chama o `BookPager.respace()` e a página atual ganha a `SpaceSlice`;
    `pageWithSpaces(page, cuts, contentHeight)` monta a página do modo (o mesmo começo).
- [ ] **Passo 2 (GREEN):** `ReaderNote(id, annotationId, unit, at, lines, collapsed, strokes, createdAt, groupId)`;
  o documento recebe `spaces` (do `ReaderInk`) e expõe `respace()` e `pageWithSpaces`.
- [ ] **Passo 3:** passa. Commit `feat(leitor): as notas à mão no leitor e a repaginação com os espaços`.

## G18.3 — Abridor (tela 24)

### Tarefa 15: os ícones e o abridor (L24.1, L24.2)

**Arquivos:** `pubspec.yaml` (os 4 SVGs da G01 em `assets/icons/leitor/`), `app_icons_leitor.dart`
(`arrowsVertical`, `trash`, `chevronUp`, `pencilBold`), criar `lib/features/reader/presentation/space_opener.dart`;
testes `test/design_system/g18_recursos_test.dart`, `test/features/reader/presentation/space_opener_test.dart`.

- [ ] **Passo 1 (RED):** os 4 ícones carregam e batem com o hash da G01; o `SpaceOpener(opening, rect, lightText)`
  com 3 linhas:
  - `ann.page.spaceOpener` (28, topo da área, 334 × 103,78), `role=status` "Abrindo espaço: 3 linhas" ("1 linha"
    no singular);
  - área: raio 14, tracejado 1,5 `#552CB7`, hachura a 135° (4 px `rgba(182,172,228,.32)` · 5 px
    `rgba(255,253,248,.9)`) — pelos pixels;
  - costura 2,5 (4 para dentro, 1 acima), bolinhas de 10 nas pontas; rastro pontilhado do topo até o dedo, com as
    setas e a bolinha de 4 (`rastro_arrasto_espaco.svg`); dedo 42 lavanda a 55 % com tracejado 1,5, centrado no x
    do dedo, na borda de baixo;
  - chip: 28 de altura, raio 9, `#1A1714`, a 14 da esquerda, no meio da área; `ic_arrows_vertical` 14 e "3 linhas"
    (Figtree 12,5/800 `#F7F0E3`);
  - Noite (R14): hachura sobre o papel do Noite, costura e rastro na `brand`, chip `#EDE3D1` com letras `#1A1714`.
- [ ] **Passo 2 (GREEN):** widget com `CustomPaint` (área, costura, rastro, dedo — `drawPath` com tracejado próprio,
  sem `saveLayer`) e o chip (`NeoBox` + `AppSvg` + `AppText`); chaves `ann.page.spaceOpener.*` (as da `kRef24` com o
  prefixo `ann.`).
- [ ] **Passo 3:** passa. Commit `feat(leitor): o abridor do Espaço — área, costura, rastro, dedo e chip (L24.1, L24.2)`.

### Tarefa 16: o Espaço no modo (L24.3, R3, R4)

**Arquivos:** `annotation_mode.dart` (subtítulo, abridor sobre a página, a página da sessão),
`annotation_canvas.dart` (pinta `session.page`), `reader_screen.dart` (a `AnnotationPageSource` do documento: a
página do modo com `contentHeight = viewport − topInset − 30 + L`; as áreas dos grifos; descartar as páginas
velhas), `annotation_session.dart` (`setTool`); testes `annotation_mode_test.dart`, `reader_screen_g18_test.dart`
(começa aqui).

- [ ] **Passo 1 (RED):**
  - subtítulo "Arraste entre as linhas" com o Espaço; "2 dedos movem a página" com as outras (R4);
  - tocar no Espaço não mostra o aviso; ele fica ativo (`ann.toolShelf.space` sobe 12; rótulo "Espaço" na ilha);
  - na tela, arrastar 3 linhas a partir da fresta abaixo de "Vá, de ressaca.": o abridor aparece; "É o que me dá
    ideia…" sai sem recuo, a 546,08 (±0,5) na tela; as linhas que passam do pé da tela ficam escondidas; soltar →
    a caixa da 24b e a Caneta ativa; Concluir sem escrever → nada gravado (D-188).
- [ ] **Passo 2 (GREEN):** o `AnnotationMode` usa `session.page` (e não mais o `page` fixo); a página do modo sai da
  fonte só quando há espaço na página (sem espaço, a de hoje — as telas 22 e 23 não mudam).
- [ ] **Passo 3:** passa (e os goldens da 22, 23 e 23b seguem). Commit `feat(leitor): o Espaço no modo anotação — o
  texto de baixo desce e a Caneta volta (L24.3, R3, R4)`.

## G18.4 — Caixa da nota (tela 24b)

### Tarefa 17: a geometria e a pintura da caixa e da faixa (L24b.1, L24b.3)

**Arquivos:** criar `lib/features/reader/annotations/space/hand_note_layout.dart` e
`lib/features/reader/presentation/hand_note.dart`; testes `hand_note_layout_test.dart` e `hand_note_test.dart`.

- [ ] **Passo 1 (RED):** `handNoteLayout(Rect bloco, int n)` para 3 linhas no bloco (28, 404,08, 334, 206):
  - caixa (28, 434,08, 334, 150); etiqueta (42, 421,08, w, 24); pautas (40, 498,08 e 540,08, 310, 1,5); botões
    (264 e 310, 414,08, 40, 40); dica (42, base em 576,08); alça (169, 574,08, 52, 22) com as barras 20 ×
    1,6 a 3 uma da outra — os números da `kRef24b`;
  - `stripLayout(bloco, L)`: a faixa (28, topo + 10, 334, L), a etiqueta no meio da altura, o botão de 32 a 6 da
    direita;
  - `paintHandNote` (fundo `#FFFDF8`, tracejado 1,5 `#1A1714`, raio 18, pautas `#EFE5D3`, etiqueta `#FED170` com
    borda e `ic_pencil_bold`, a tinta recortada na caixa) e `paintNoteStrip` — pelos pixels; Noite (R14): fundo
    `#2A2520`, tracejado `#EDE3D1`, pautas `#4A433A`, etiqueta amarela; a tinta preta pela D-174; sem `saveLayer`
    (`performance_test`).
- [ ] **Passo 2 (GREEN):** a geometria pura (dart:ui `Rect`); a pintura com o tracejado da Tarefa 15, a etiqueta
  (`ui.Paragraph` Figtree 11,5/800 e o ícone pelo `PictureInfo` do SVG em cache), a tinta pela `paintInk` da G16 em
  coordenadas da caixa (`fromNote`).
- [ ] **Passo 3:** passa. Commit `feat(leitor): a caixa da nota à mão e a faixa recolhida (L24b.1, L24b.3, R8)`.

### Tarefa 18: botões, dica, alça, recolher e apagar no modo (L24b.2, L24b.4, R7–R9)

**Arquivos:** `hand_note.dart` (`HandNoteControls`), `annotation_mode.dart` (as notas por cima do canvas, irmãs
dele — o toque nos botões não chega ao `Listener` da tinta; a `UndoPill` "Nota apagada"); testes
`hand_note_test.dart`, `annotation_mode_test.dart`, `reader_screen_g18_test.dart`.

- [ ] **Passo 1 (RED):**
  - botões 40 com `ic_chevron_up`/`ic_trash` 18, fundo `#FFFAF1`, borda 1,5; rótulos "Recolher a nota" e "Apagar
    a nota"; na faixa, "Abrir a nota" (chevron virado, 32);
  - dica "puxe a alça para aumentar" (Figtree 11/700 `#A89D8B`); alça 52 × 22, sombra 2/2, rótulo "Arrastar para
    mudar a altura do espaço";
  - grupo "Nota à mão, depois de “Vá, de ressaca.”"; tinta `role=img` "Nota à mão, 20 de setembro" (D-31);
  - recolher → faixa e o texto sobe; abrir → volta; arrastar a alça 2 pautas para cima com a tinta da 24b → para em
    2 linhas; para baixo → cresce; apagar → some e a pílula "Nota apagada · Desfazer" por 4 s; Desfazer → volta;
  - os controles acompanham o deslocamento (`pan`, a entrada de 30 px) e não aparecem fora do modo.
- [ ] **Passo 2 (GREEN):** `HandNoteControls(session, note, rect)` posicionado pela `handNoteLayout`; a pílula pela
  `UndoPill` da D-132 com o temporizador de 4 s da D-175.
- [ ] **Passo 3:** passa. Commit `feat(leitor): botões, alça e dica da nota; recolher e apagar com Desfazer (R7–R9)`.

## G18.5 — Leitor limpo

### Tarefa 19: a nota no leitor limpo (R11, R13, R14)

**Arquivos:** `reader_page_view.dart` (`paintTextPage` pinta as notas da página pelo `page.spaces` e pelo
`InkSource.notesOn`), `reader_screen.dart` (toque na faixa antes das zonas de virar; o `respace` quando os cortes do
`ReaderInk` mudam; a semântica das notas sobre a página); testes `reader_page_view_test.dart`,
`reader_screen_g18_test.dart`.

- [ ] **Passo 1 (RED):**
  - a página com a nota aberta pinta a caixa, a etiqueta, as pautas e a tinta, sem botões, alça e dica (D-183);
    recolhida, a faixa com a etiqueta;
  - um toque na faixa abre a nota e grava `collapsed = false` (Grátis: sem rede); o capítulo repagina e a caixa
    aparece; um toque na caixa aberta vira a página (o de sempre);
  - a nota que não cabe no resto da página vai inteira para a seguinte (R12) e a página atual acaba no texto de cima;
  - leitor de tela: o grupo "Nota à mão, depois de “…”", a tinta "Nota à mão, ‹data›" e o botão "Abrir a nota à
    mão" na faixa;
  - Noite (R14) e a tinta preta (D-174) pelos pixels; sem `saveLayer`.
- [ ] **Passo 2 (GREEN):** o `InkSource` ganha `notesOn(DisplayPage)`; a pintura reaproveita `paintHandNote`/
  `paintNoteStrip` com `controls: false`; o `respace` só quando a assinatura dos cortes do livro muda.
- [ ] **Passo 3:** passa. Commit `feat(leitor): a nota à mão no leitor limpo e a faixa que abre com um toque (R11–R14)`.

## G18.6 — Prova

### Tarefa 20: o mundo das telas 24 e 24b (R15)

**Arquivos:** `test/fixtures/tinta_do_mundo.dart` (`desenhoDaNotaAMao`: as polilinhas de `nota_mao_ressaca.svg` na
caixa 334 × 150, o olho, a íris (espiral de traços de 2,2 até o centro) e as ondas; coral, 2,2 px; unidade da nota),
`mundo_2026_09_20.dart` (a camada `espaco` com `strokesB64`/`strokeCount`), `telas/t24b.dart`
(`ferramenta: caneta`), `test/fixtures/mundo_de_referencia_test.dart`, criar `test/support/dados_t24.dart`
(`livroDaTela24({papel})` = o mundo da 23; `livroDaTela24b({papel})` = o `mundoReferencia` com os trechos da D-160;
`abrirTela24(tester, livro, {golden})` = Anotar, Espaço, o dedo parado 3 linhas abaixo da fresta de "Vá, de
ressaca." no x de 58 % da caixa; `abrirTela24b` = Anotar e a Caneta).

- [ ] **Passo 1 (RED):** a camada do mundo decodifica em N traços coral cujo desenho bate com o SVG (±0,5 px) e
  `minLinesFor` = 2; `t24b.ferramenta == caneta`; `abrirTela24` chega com `opening.lines == 3` e `abrirTela24b` com
  a nota de 3 linhas e a Caneta.
- [ ] **Passo 2 (GREEN):** o conversor (com `Z` no `amostrarCaminho`) e os dados.
- [ ] **Passo 3:** passa. Commit `test(fixture): a tinta da nota à mão e o mundo das telas 24 e 24b (R15)`.

### Tarefa 21: fases L24 e L24b e o golden

**Arquivos:** criar `test/support/fase_l24.dart`, `pecas_l24.dart`, `test/features/reader/presentation/l24_test.dart`,
`l24b_test.dart`, `test/golden/leitor_24_test.dart`.

- [ ] **Passo 1:** as fases pela rota real, contra a `kRef24` (`sp.page`, 18 ids) e a `kRef24b` (`hn.page`, 24 ids):
  geometria (±0,5; ±1,0 em x/w nos `textDependentX`); texto (as linhas de cima e as de baixo, com as escondidas fora);
  estilo (cores, bordas 1,5, raios 14/18/9/999, sombra 2/2 da alça, fontes); semântica (as tabelas das fases, D-31);
  dados (a camada `space` e a anotação `handwriting` no banco). Golden @3x no recorte y 108–844 contra
  `24_abrindo_espaco_390x844@3x.png` e `24b_nota_mao_390x844@3x.png`, limite 0,5 %.
- [ ] **Passo 2:** o que faltar volta às Tarefas 15–18 (com teste). Commit `test(leitor): fases L24 e L24b e os
  goldens das telas 24 e 24b`.

### Tarefa 22: comportamento da tela

**Arquivos:** `test/features/reader/presentation/reader_screen_g18_test.dart`.

- [ ] **Passo 1:** a rota inteira: abrir arrastando; o texto desce; Caneta ao soltar; escrever na caixa; a alça para
  na tinta; recolher e abrir; apagar com Desfazer; Concluir grava (camada e anotação), e o leitor limpo mostra a
  caixa; a faixa abre com um toque; a nota que não cabe vai para a página seguinte; Voltar = Concluir (D-42); o
  rascunho recuperado (D-166) traz a nota; Noite; leitor de tela; Grátis sem rede.
- [ ] **Passo 2:** commit `test(leitor): o Espaço e a nota à mão pela tela inteira`.

### Tarefa 23: verificação, capturas e relatório

- [ ] `dart format`, `flutter analyze` (0), `flutter test` com cobertura (≥ 90 % nos arquivos de `lib/` da fase:
  `git diff --name-only 54d3b67 -- lib`).
- [ ] Revisão independente (agente que não escreveu o código) e as correções com teste.
- [ ] Mutação (`tools/medicao/tmp/mut/g18/gerar_g18.py`): as regras numéricas (42, 24, 30/26, 14/24, −2, 10/10,
  1–12, o arredondamento do arrasto, as pautas, as linhas da tinta), a R1 (frase, fechamento, sem frase, hífen,
  parágrafo), a R5, a R6 (só o 1º ponto, recorte), a R12 (não cabe → seguinte), a assinatura do cache, o sem recuo,
  a D-187, a D-188, a D-186, o Desfazer da D-185, a R4 e cada correção da revisão.
- [ ] gitleaks nos commits da fase e nas pastas tocadas.
- [ ] Capturas (`capturas_g18_test.dart`, `BOOKNEST_CAPTURAS`): 24 e 24b em Creme e Noite, a faixa no modo e no
  leitor, a página do leitor com a nota, a nota que passou para a página seguinte, a pílula "Nota apagada", o lado a
  lado com as pranchas.
- [ ] `G18.md` (Resultados, Revisão, Desvios, Pendências, Capturas, checklist), `RELATORIO_G18.md`, o projeto
  (`handoff_app_completo/relatorios/RELATORIO_G18.md` e `05_DECISOES_E_PERGUNTAS.md` com D-181…D-189). Fim:
  "✅ FASE G18 concluída — aguardando sua aprovação para iniciar a FASE G19."
