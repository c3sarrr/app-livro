# G13 — Plano de implementação (tela 21: seleção e grifos)

> **Para quem executa:** seguir tarefa por tarefa (`superpowers:executing-plans`), com TDD: teste que falha →
> código mínimo → teste verde → commit. Desenho aprovado: `docs/progresso/G13.md` (D-129…D-136 e as propostas
> D-23, D-32, D-39, D-45, D-47 aprovadas).

**Objetivo:** no EPUB, a pressão longa seleciona a palavra e as alças ajustam a seleção (por palavra; por letra com
a lupa), presa à página. A barra de ações da prancha 21 grifa, sublinha, anota, copia, compartilha e busca. Os grifos
do banco são pintados por trás do texto, no Creme e no Noite.

**Arquitetura:**
- **Camada de seleção** (`SelectionLayer`) dentro da `ReaderScreen`, entre a página e os controles. Ela tem as alças,
  a lupa e a barra.
- **Página** (`DisplayPage`/`PageSnapshot`): ganha "ponto e palavra sob o dedo" e as caixas por linha com a linha de
  base e a área do texto.
- **Grifos do livro** (`ReaderAnnotations`, aplicação): lê, acha o lugar (âncora), cria (D-32), troca, apaga com
  desfazer e guarda a nota.
- **Pintura:** o pintor da página pinta, na ordem, o fundo dos grifos, a seleção e a marca da busca, com recorte por
  prioridade. Depois vêm o texto e, por fim, o sublinhado.

**Tecnologia:** Flutter 3.47.2 / Dart 3.13.2, Riverpod 3, drift, `dart:ui` (`getPositionForOffset`,
`getWordBoundary`, `getBoxesForRange`), `share_plus` 13.3.1, `Clipboard` e `HapticFeedback` do Flutter.

**Fluxo de trabalho (o mesmo da G12):**
- **Editar:** no espelho `/home/claude/g03/repo`.
- **Levar ao Windows:** `./ciclo.sh <arquivos>` gera o zip, e o `device_commit_files` o leva a `tools\medicao\tmp\`.
- **Rodar:** `rodar.ps1 -Nome … -Cmd "expandir … && dart format lib test && flutter analyze && flutter test --timeout 120s <testes>"`, depois ler o `.log`/`.fim`.
- **Trazer de volta:** o que o `dart format` mudou (`device_stage_files` + `puxar.sh`).
- **Commit:** no Windows, com `git --no-optional-locks commit -F tools/medicao/tmp/msg_*.txt`.
  - Mensagens em português, no formato `tipo(escopo): descrição`, com as 2 linhas de coautoria.
- **Cuidados:**
  - nunca deixar `.dart` em `tools/medicao/tmp`;
  - mudou um asset → tocar o `pubspec.yaml`;
  - nada de `Opacity`, `saveLayer`, `BackdropFilter` ou `ColorFiltered` em `lib` (F12 12.4);
  - todo `CustomPainter` novo entra na lista do `performance_test`, com teste de repintura.

---

## Mapa de arquivos

| Arquivo | Responsabilidade | Tarefa |
|---|---|---|
| `lib/features/reader/layout/display_page.dart` (mod.) | `ReaderRange`, `ReaderSpot`, `TextLineBox`; `shown`, `spotAt`, `wordAround`, `wordAt`, `boxesOf`, `textOf` | 1 |
| `lib/features/reader/layout/text_geometry.dart` | `readerTextArea(em)`: a área do texto do CSS (ascent + descent da Literata) | 1 |
| `lib/features/reader/layout/page_snapshot.dart` (mod.) | as novidades da página no EPUB; `rectsOf` e `linkAt` sobre as caixas novas | 1 |
| `lib/features/reader/application/pdf_reader_document.dart` (mod.) | PDF sem seleção (D-134) | 1 |
| `lib/features/reader/application/reader_document.dart` (mod.) | `FoundRange = ReaderRange`; `anchors` | 1, 4 |
| `lib/features/reader/presentation/page_marks.dart` | `PaintedHighlight`, `HighlightSource`, faixas de fundo, recorte por prioridade, pintura (Creme/Noite) e sublinhado | 2 |
| `lib/features/reader/presentation/reader_page_view.dart` (mod.) | pintor com grifos e seleção; gestos da pressão longa; toque com seleção; precedência link → grifo → terços | 2, 7 |
| `lib/features/reader/annotations/domain/highlight_overlap.dart` | `planHighlight` (D-32, função pura) | 3 |
| `lib/features/reader/application/annotation_anchors.dart` | `AnnotationAnchors` (sha, texto do item, página e capítulo) | 4 |
| `lib/features/reader/application/epub_reader_document.dart` (mod.) | `anchors` do EPUB | 4 |
| `lib/features/reader/application/reader_annotations.dart` | `ReaderAnnotations` | 4 |
| `lib/core/design_system/tokens/app_colors.dart` (mod.) | `labelReader` `#6F665B` | 5 |
| `lib/features/reader/presentation/reader_chrome_palette.dart` (mod.) | `label` (rótulos "GRIFAR"/"NOTA") | 5 |
| `lib/core/design_system/tokens/app_icons_leitor.dart` (mod.) | `note`, `copy`, `share`, `plusTiny` | 5 |
| `lib/core/design_system/tokens/app_typography.dart` (mod.) | `AppFonts.literataBook`, estilos da barra e da folha | 5 |
| `lib/features/reader/presentation/selection_controller.dart` | `ReaderSelection`, `SelectionController`, `moveEdge`, `extendFrom` | 6 |
| `lib/features/reader/presentation/selection_layer.dart` | alças, lupa, âncora da barra, nó semântico, posição da barra | 8 |
| `lib/features/reader/presentation/highlight_toolbar.dart` | `HighlightToolbar` (L21b), `RainbowRingPainter`, `UnderlineIconPainter` | 9 |
| `lib/features/reader/presentation/note_sheet.dart` | `NoteSheet` (D-131) | 12 |
| `lib/features/reader/presentation/reader_overlays.dart` (mod.) | `ReaderUndoPill`, `readerUndoLife`, textos dos avisos | 11 |
| `lib/features/reader/presentation/reader_actions.dart` | `quoteForSharing`, `searchPrefill`, `readerShareProvider` | 11 |
| `lib/features/reader/presentation/reader_screen.dart` (mod.) | camada da seleção, grifos do livro, ações, folha da nota, Voltar, avisos fora dos controles | 10–12 |
| `test/support/dados_t21.dart`, `test/support/fase_l21.dart` | mundo da 21 e as conferências L21a/L21b | 13 |
| `test/features/reader/presentation/l21_test.dart`, `test/golden/leitor_21_test.dart`, `test/golden/capturas_g13_test.dart` | fases L e goldens | 13, 14 |

---

## G13.1 — Página: posição, palavra e pintura

### Tarefa 1: tipos, área do texto e as novidades da página

**Arquivos:** `display_page.dart`, `text_geometry.dart` (novo), `page_snapshot.dart`, `pdf_reader_document.dart`,
`reader_document.dart`; dublês em `test/features/reader/presentation/reader_page_view_test.dart`. Testes:
`test/features/reader/layout/page_text_geometry_test.dart` (novo), `pdf_reader_document_test.dart`.

- [ ] **Passo 1 — teste que falha** (`test/features/reader/layout/page_text_geometry_test.dart`):

```dart
// G13.1 — a página do EPUB sabe o que está sob o dedo e onde fica cada letra (tela 21): a área do texto do CSS
// (30,44 na Literata 20,5), as caixas por linha com a linha de base, o ponto e a palavra sob o dedo presos à
// página (D-47), o trecho mostrado e o texto canônico.
import 'package:app_leitura/features/reader/application/epub_reader_document.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/text_geometry.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/load_fonts.dart';
import '../../../support/reader_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  late EpubReaderDocument doc;
  setUp(() async {
    livro = await livroDaTela19();
    doc = await EpubReaderDocument.open(livro.deps());
  });
  tearDown(() async {
    doc.dispose();
    await livro.close();
  });

  PageSnapshot pagina() => doc.current as PageSnapshot;
  const selecao = 'como a vaga que se retira da praia, nos dias de ressaca.';

  test('área do texto da Literata 20,5 = 30,44 (o fundo de um span no Chromium — L21a)', () {
    expect(readerTextArea(20.5), moreOrLessEquals(30.44, epsilon: 0.05));
  });

  test('caixas por linha da seleção da 21: 3 linhas, área do texto, linha de base e as bordas das alças', () {
    final p = pagina();
    final a = p.item.text.indexOf(selecao);
    final caixas = p.boxesOf(p.spine, a, a + selecao.length);
    final linhas = {for (final c in caixas) c.textTop}.toList()..sort();
    expect(linhas, hasLength(3));
    // L21a nº 9: r21.page.text.selection = (0, 390,27, 327,57, 100,96) na página (28, 92)
    expect(linhas.first, moreOrLessEquals(92 + 390.27, epsilon: 0.5));
    expect(caixas.last.textBottom, moreOrLessEquals(92 + 390.27 + 100.96, epsilon: 0.5));
    expect(caixas.first.baseline, moreOrLessEquals(92 + 414.4, epsilon: 0.5));
    expect(caixas.first.em, moreOrLessEquals(20.5, epsilon: 0.01));
    // nº 6 e nº 10: onde ficam as alças (o começo de "como" e o fim de "ressaca.")
    expect(caixas.first.rect.left, moreOrLessEquals(28 + 258.87, epsilon: 1));
    expect(caixas.last.rect.right, moreOrLessEquals(28 + 147.93, epsilon: 1));
    // o espaço do fim da linha não entra (o Chromium não pinta o fundo dele)
    final daLinha12 = caixas.where((c) => c.textTop == linhas.first);
    expect(
      daLinha12.map((c) => c.rect.right).reduce((x, y) => x > y ? x : y),
      moreOrLessEquals(28 + 327.57, epsilon: 1),
    );
    expect(p.rectsOf(p.spine, a, a + selecao.length), [for (final c in caixas) c.rect]);
  });

  test('ponto e palavra sob o dedo: dentro da página, a palavra inteira, pontuação não é palavra', () {
    final p = pagina();
    final a = p.item.text.indexOf(selecao);
    final como = p.boxesOf(p.spine, a, a + 4).single.rect;
    expect(p.wordAt(como.center), (unit: p.spine, from: a, to: a + 4));
    // a metade direita da última letra ainda é a mesma palavra
    expect(p.wordAt(Offset(como.right - 1, como.center.dy)), (unit: p.spine, from: a, to: a + 4));
    final ponto = a + selecao.length - 1;
    final caixaDoPonto = p.boxesOf(p.spine, ponto, ponto + 1).single.rect;
    expect(p.wordAt(caixaDoPonto.center), isNull, reason: 'pontuação sozinha não seleciona');
    expect(
      p.wordAround(p.spotAt(caixaDoPonto.center)!),
      (unit: p.spine, from: ponto, to: ponto + 1),
      reason: 'arrastando a alça, a pontuação conta como palavra',
    );
    expect(p.wordAt(const Offset(8, 500)), isNull, reason: 'margem');
    final mostrado = p.shown!;
    expect(mostrado, (unit: p.spine, from: p.page.start, to: p.page.end));
    expect(p.spotAt(const Offset(195, 10)), (unit: p.spine, offset: mostrado.from));
    expect(p.spotAt(const Offset(195, 840))!.offset, lessThanOrEqualTo(mostrado.to));
    expect(p.spotAt(const Offset(195, 840))!.offset, greaterThan(mostrado.to - 3));
    expect(p.textOf(p.spine, a, a + selecao.length), selecao);
    expect(p.textOf(p.spine + 1, a, a + 4), '', reason: 'outro item');
  });
}
```

No `pdf_reader_document_test.dart`, acrescentar ao teste que já abre a amostra (depois de `final page = d.current`):

```dart
    // D-134: o PDF não tem seleção nem grifos na G13
    expect(page.shown, isNull);
    expect(page.spotAt(const Offset(100, 300)), isNull);
    expect(page.wordAt(const Offset(100, 300)), isNull);
    expect(page.boxesOf(0, 0, 10), isEmpty);
    expect(page.textOf(0, 0, 10), '');
```

- [ ] **Passo 2 — rodar e ver falhar** (`flutter test test/features/reader/layout/page_text_geometry_test.dart test/features/reader/application/pdf_reader_document_test.dart`): erro de compilação, porque `readerTextArea`, `boxesOf` e os demais ainda não existem.

- [ ] **Passo 3 — tipos** (`display_page.dart`, depois do `LinkHit`):

```dart
/// Um trecho do texto: [unit] = item do spine (EPUB) ou página (PDF); [from]…[to) no texto dele.
typedef ReaderRange = ({int unit, int from, int to});

/// Um ponto do texto, entre dois caracteres.
typedef ReaderSpot = ({int unit, int offset});

/// A parte de um trecho numa linha da página: [rect] = as letras na altura da linha inteira; [baseline]; a área
/// do texto do CSS ([textTop]…[textBottom]: ascent + descent da fonte, centrada na linha — onde o fundo de um
/// `span` é pintado); [em] = o tamanho da letra da linha.
typedef TextLineBox = ({
  ui.Rect rect,
  double baseline,
  double textTop,
  double textBottom,
  double em,
});
```

Novos membros de `DisplayPage`:

```dart
  /// O trecho de texto que a página mostra (o limite da seleção — D-47); `null` = sem texto selecionável (o PDF —
  /// D-134).
  ReaderRange? get shown;

  /// O ponto do texto mais perto de [p], sempre dentro de [shown]; `null` sem texto.
  ReaderSpot? spotAt(ui.Offset p);

  /// A palavra em volta de [s] (`getWordBoundary`: a pontuação é uma "palavra"); espaço = `null`.
  ReaderRange? wordAround(ReaderSpot s);

  /// A palavra para a pressão longa e o toque: só com o dedo sobre as letras dela e com letra ou número.
  ReaderRange? wordAt(ui.Offset p);

  /// As caixas por linha de [from]…[to) do texto de [unit] nesta página (sem o espaço do fim de linha).
  List<TextLineBox> boxesOf(int unit, int from, int to);

  /// O texto canônico de [from]…[to) de [unit], só a parte desta página.
  String textOf(int unit, int from, int to);
```

Em `reader_document.dart`, trocar o `typedef FoundRange = ({int unit, int from, int to});` por:

```dart
/// Um trecho achado pela busca (D-120) — o mesmo tipo de um trecho da página.
typedef FoundRange = ReaderRange;
```

- [ ] **Passo 4 — área do texto** (`lib/features/reader/layout/text_geometry.dart`):

```dart
// G13.1 — a área do texto de uma linha como no Chromium: o fundo de um `span` (grifo, seleção) cobre o ascent +
// descent da fonte, centrado na linha (30,44 px na Literata 20,5 com a entrelinha de 35,26 — L21a). Medida uma vez
// por tamanho, com a mesma Literata variável do livro.
import 'dart:ui' as ui;

import 'reader_typography.dart';

final Map<double, double> _areas = {};

/// ascent + descent da Literata do livro no tamanho [em] (sem a entrelinha).
double readerTextArea(double em) => _areas[em] ??= _measure(em);

double _measure(double em) {
  final b =
      ui.ParagraphBuilder(ui.ParagraphStyle(textDirection: ui.TextDirection.ltr))
        ..pushStyle(
          ui.TextStyle(
            fontFamily: readerFontFamily,
            fontFamilyFallback: readerFontFallback,
            fontSize: em,
            fontVariations: [
              ui.FontVariation('opsz', em),
              ui.FontVariation('wght', readerTextWeight),
            ],
          ),
        )
        ..addText('x');
  final p = b.build()..layout(const ui.ParagraphConstraints(width: 1e6));
  final m = p.computeLineMetrics().first;
  p.dispose();
  return m.ascent + m.descent;
}
```

- [ ] **Passo 5 — `PageSnapshot`**: o `_boxes` passa a devolver `TextLineBox`, sem o espaço do fim da linha. Entram
  as linhas mostradas e os membros novos. Substituir `rectsOf`, `linkAt` e `_boxes` e acrescentar:

```dart
  @override
  ReaderRange? get shown =>
      alive ? (unit: spine, from: page.start, to: page.end) : null;

  @override
  List<ui.Rect> rectsOf(int unit, int from, int to) => [
    for (final b in boxesOf(unit, from, to)) b.rect,
  ];

  @override
  List<TextLineBox> boxesOf(int unit, int from, int to) {
    if (!alive || unit != spine || from >= to) return const [];
    return [
      for (final s in page.slices)
        if (s is TextSlice)
          if (_blockOf(s.block) case final LaidText b) ..._boxes(b, s, from, to),
    ];
  }

  @override
  String textOf(int unit, int from, int to) {
    final r = shown;
    if (r == null || unit != spine) return '';
    final a = math.max(from, r.from);
    final z = math.min(to, r.to);
    return a < z ? item.text.substring(a, z) : '';
  }

  @override
  LinkHit? linkAt(ui.Offset p) {
    if (!alive) return null;
    for (final s in page.slices) {
      if (s is! TextSlice) continue;
      final b = _blockOf(s.block);
      if (b is! LaidText || b.source is! TextBlock) continue;
      for (final (a, z, target) in _links(b)) {
        for (final box in _boxes(b, s, a, z)) {
          if (box.rect.contains(p)) {
            return (
              target: target,
              spine: spine,
              offset: math.max(a, _lineStartAt(b, s, p.dy) ?? a),
            );
          }
        }
      }
    }
    return null;
  }

  @override
  ReaderSpot? spotAt(ui.Offset p) {
    final r = shown;
    if (r == null) return null;
    final lines = _shownLines().toList();
    if (lines.isEmpty) return null;
    if (p.dy < lines.first.top) return (unit: spine, offset: r.from);
    final last = lines.last;
    if (p.dy >= last.top + last.line.height) {
      return (unit: spine, offset: math.min(r.to, _visibleEnd(last.line)));
    }
    final l = lines.firstWhere(
      (l) => p.dy < l.top + l.line.height,
      orElse: () => last,
    );
    final piece = l.block.pieces[l.line.piece];
    final y = l.line.pieceBaseline - l.line.ascent + l.line.height / 2;
    final pos = piece.paragraph.getPositionForOffset(ui.Offset(p.dx - l.x0, y));
    final at = l.block
        .toCanonical(l.line.piece, pos.offset)
        .clamp(l.line.start, _visibleEnd(l.line));
    return (unit: spine, offset: at.clamp(r.from, r.to));
  }

  @override
  ReaderRange? wordAround(ReaderSpot s) {
    final r = shown;
    if (r == null || s.unit != spine) return null;
    for (final l in _shownLines()) {
      final line = l.line;
      if (s.offset < line.start || s.offset >= line.end) continue;
      final piece = l.block.pieces[line.piece];
      final inPiece = s.offset - l.block.start - piece.textOffset +
          (piece.placeholder ? 1 : 0);
      final w = piece.paragraph.getWordBoundary(ui.TextPosition(offset: inPiece));
      final from = l.block.toCanonical(line.piece, w.start);
      final to = l.block.toCanonical(line.piece, w.end);
      if (to <= from || item.text.substring(from, to).trim().isEmpty) return null;
      return (unit: spine, from: math.max(from, r.from), to: math.min(to, r.to));
    }
    return null;
  }

  static final RegExp _letter = RegExp(r'[\p{L}\p{N}]', unicode: true);

  @override
  ReaderRange? wordAt(ui.Offset p) {
    final s = spotAt(p);
    if (s == null) return null;
    // o dedo na metade direita da última letra cai depois dela: vale também a palavra da letra anterior
    for (final o in [s.offset, s.offset - 1]) {
      final w = wordAround((unit: spine, offset: o));
      if (w == null) continue;
      if (!_letter.hasMatch(item.text.substring(w.from, w.to))) continue;
      if (boxesOf(spine, w.from, w.to).any((b) => b.rect.inflate(4).contains(p))) {
        return w;
      }
    }
    return null;
  }

  /// As linhas de texto da página, de cima para baixo, com o topo e a margem esquerda na tela.
  Iterable<({LaidText block, LaidLine line, double top, double x0})>
  _shownLines() sync* {
    final t = typography;
    for (final s in page.slices) {
      if (s is! TextSlice) continue;
      final b = _blockOf(s.block);
      if (b is! LaidText) continue;
      final base = t.topInset + s.y - b.lines[s.firstLine].top;
      for (var i = s.firstLine; i <= s.lastLine; i++) {
        yield (
          block: b,
          line: b.lines[i],
          top: base + b.lines[i].top,
          x0: t.sideMargin + b.left,
        );
      }
    }
  }

  /// O fim da linha sem o espaço (ou a quebra) que fica pendurado nela.
  int _visibleEnd(LaidLine line) {
    var e = line.end;
    while (e > line.start) {
      final c = item.text.codeUnitAt(e - 1);
      if (c != 0x20 && c != 0x0A) break;
      e--;
    }
    return e;
  }

  /// As caixas das letras de [from]…[to) nas linhas da fatia [s] do bloco [b], na tela: a altura da linha
  /// inteira (o toque num link vale na linha inteira), a linha de base e a área do texto do CSS.
  Iterable<TextLineBox> _boxes(LaidText b, TextSlice s, int from, int to) sync* {
    final t = typography;
    final base = t.topInset + s.y - b.lines[s.firstLine].top;
    final x0 = t.sideMargin + b.left;
    for (var i = s.firstLine; i <= s.lastLine; i++) {
      final line = b.lines[i];
      final a = from < line.start ? line.start : from;
      final lineEnd = _visibleEnd(line);
      final z = to > lineEnd ? lineEnd : to;
      if (a >= z) continue;
      final (pa, pi) = b.toParagraph(a);
      final (pz, pj) = b.toParagraph(z);
      // cada linha está num pedaço só; o fim pode cair no começo do pedaço seguinte
      final end = pz == pa
          ? pj
          : b.pieces[pa].paragraph
                .getLineBoundary(ui.TextPosition(offset: pi))
                .end;
      final top = base + line.top;
      final em = line.height / t.lineSpacing;
      final area = readerTextArea(em);
      final textTop = top + (line.height - area) / 2;
      for (final box in b.pieces[pa].paragraph.getBoxesForRange(pi, end)) {
        yield (
          rect: ui.Rect.fromLTRB(
            x0 + box.left,
            top,
            x0 + box.right,
            top + line.height,
          ),
          baseline: top + line.ascent,
          textTop: textTop,
          textBottom: textTop + area,
          em: em,
        );
      }
    }
  }
```

Importar `text_geometry.dart`. No `PdfDisplayPage`, acrescentar:

```dart
  // D-134: seleção e grifos no PDF ficam para uma fase própria
  @override
  ReaderRange? get shown => null;

  @override
  ReaderSpot? spotAt(ui.Offset p) => null;

  @override
  ReaderRange? wordAround(ReaderSpot s) => null;

  @override
  ReaderRange? wordAt(ui.Offset p) => null;

  @override
  List<TextLineBox> boxesOf(int unit, int from, int to) => const [];

  @override
  String textOf(int unit, int from, int to) => '';
```

No dublê `_Pagina` de `reader_page_view_test.dart` (que implementa a interface à mão), acrescentar as mesmas seis
implementações por enquanto. A Tarefa 2 as troca por caixas de mentira.

- [ ] **Passo 6 — rodar:** os dois testes verdes; `test/features/reader` inteiro verde (o `rectsOf` mudou por dentro: a
  marca da busca e os links da G11/G12 continuam passando). Se a área do texto não der 30,44 ± 0,05, parar e ver as
  métricas (hhea × typo) antes de seguir.
- [ ] **Passo 7 — commit:** `feat(leitor): ponto, palavra e caixas por linha da página do EPUB (G13.1, D-47, D-134)`.

### Tarefa 2: pintura dos grifos, da seleção e do sublinhado

**Arquivos:** `lib/features/reader/presentation/page_marks.dart` (novo), `reader_page_view.dart` (pintor); testes
em `reader_page_view_test.dart` (pintor) e `test/home/performance_test.dart`.

- [ ] **Passo 1 — teste que falha.** No `reader_page_view_test.dart`:
  - o `_Pagina` ganha caixas de mentira: cada caractere `i` do item `n` ocupa `Rect.fromLTWH(30 + i, 120, 1, 35.26)`;
    a linha de base fica em 149,6; a área do texto vai de 122,41 a 152,85; o em é 20,5;
  - o `_Tela` passa a gravar também `clipRect` e `drawRect`.

```dart
  // _Pagina:
  @override
  ReaderRange? get shown => (unit: n, from: 0, to: 400);
  @override
  List<TextLineBox> boxesOf(int unit, int from, int to) => unit == n && from < to
      ? [
          (
            rect: Rect.fromLTWH(30.0 + from, 120, (to - from).toDouble(), 35.26),
            baseline: 149.6,
            textTop: 122.41,
            textBottom: 152.85,
            em: 20.5,
          ),
        ]
      : const [];
  // (rectsOf passa a ser [for (final b in boxesOf(...)) b.rect]; spotAt/wordAround/wordAt/textOf: Tarefa 7)

  // _Tela:
  final cortes = <Rect>[];
  final retangulos = <(Rect, Color)>[];
  @override
  void clipRect(Rect rect, {ClipOp clipOp = ClipOp.intersect, bool doAntiAlias = true}) {
    chamadas.add('corte');
    cortes.add(rect);
  }
  @override
  void drawRect(Rect rect, Paint paint) {
    chamadas.add('traço');
    retangulos.add((rect, paint.color));
  }
```

Testes novos (grupo `G13 — grifos e seleção na página`):

```dart
    final class _Grifos extends ChangeNotifier implements HighlightSource {
      _Grifos(this.lista);
      List<PaintedHighlight> lista;
      @override
      List<PaintedHighlight> highlightsIn(ReaderRange shown) => [
        for (final h in lista)
          if (h.range.unit == shown.unit) h,
      ];
    }

    test('fundo do grifo: faixa de 12–92 % da área do texto (corte), raio 3, cor a 85 %, por trás do texto', () {
      final l = _Livro();
      final grifos = _Grifos([
        PaintedHighlight(id: 'g', range: (unit: 2, from: 10, to: 50), color: const Color(0xFFFED170), style: HighlightStyle.fill),
      ]);
      final tela = _Tela();
      ReaderPagesPainter(document: l, dx: 0, dir: null, neighbor: null, highlights: grifos)
          .paint(tela, const Size(390, 844));
      expect(tela.chamadas, ['corte', 'marca', 'texto']);
      final (rr, cor) = tela.marcas.single;
      expect(rr.outerRect, const Rect.fromLTRB(40, 122.41, 80, 152.85));
      expect(rr.tlRadius, const Radius.circular(3));
      final area = 152.85 - 122.41;
      expect(tela.cortes.single.top, moreOrLessEquals(122.41 + .12 * area, epsilon: 1e-9));
      expect(tela.cortes.single.bottom, moreOrLessEquals(122.41 + .92 * area, epsilon: 1e-9));
      expect(cor.toARGB32(), const Color(0xFFFED170).withValues(alpha: .85).toARGB32());
    });

    test('seleção: área do texto inteira, raio 2, brand a 62 %, por trás do texto; ganha do grifo onde se cruzam', () {
      final l = _Livro();
      final grifos = _Grifos([
        PaintedHighlight(id: 'g', range: (unit: 2, from: 0, to: 100), color: const Color(0xFFFED170), style: HighlightStyle.fill),
      ]);
      final selecao = ValueNotifier<ReaderRange?>((unit: 2, from: 40, to: 60));
      final tela = _Tela();
      ReaderPagesPainter(
        document: l, dx: 0, dir: null, neighbor: null,
        highlights: grifos, selection: selecao, selectionColor: const Color(0xFFB6ACE4),
      ).paint(tela, const Size(390, 844));
      // o grifo vira 2 pedaços (30–70 e 90–130 na tela) e a seleção fica inteira (70–90)
      final rr = [for (final (r, _) in tela.marcas) r.outerRect];
      expect(rr, [
        const Rect.fromLTRB(30, 122.41, 70, 152.85),
        const Rect.fromLTRB(90, 122.41, 130, 152.85),
        const Rect.fromLTRB(70, 122.41, 90, 152.85),
      ]);
      expect(tela.marcas.last.$1.tlRadius, const Radius.circular(2));
      expect(tela.marcas.last.$2.toARGB32(), const Color(0xFFB6ACE4).withValues(alpha: .62).toARGB32());
      expect(tela.chamadas.last, 'texto');
    });

    test('sublinhado: retângulo de 4 px a partir de 3 px abaixo da linha de base, na cor viva, por cima do texto', () {
      final l = _Livro();
      final grifos = _Grifos([
        PaintedHighlight(id: 's', range: (unit: 2, from: 10, to: 20), color: const Color(0xFFFFC1C6), style: HighlightStyle.underline),
      ]);
      final tela = _Tela();
      ReaderPagesPainter(document: l, dx: 0, dir: null, neighbor: null, highlights: grifos)
          .paint(tela, const Size(390, 844));
      expect(tela.chamadas, ['texto', 'traço']);
      final (r, c) = tela.retangulos.single;
      expect(r, const Rect.fromLTRB(40, 152.6, 50, 156.6));
      expect(c.toARGB32(), 0xFFFFC1C6);
    });

    test('Noite (D-133): grifo e seleção na cor viva, por trás D − cor e por cima D em diferença', () {
      final l = _Livro();
      final grifos = _Grifos([
        PaintedHighlight(id: 'g', range: (unit: 2, from: 10, to: 30), color: const Color(0xFFFED170), style: HighlightStyle.fill),
      ]);
      final tela = _Tela();
      ReaderPagesPainter(
        document: l, dx: 0, dir: null, neighbor: null,
        highlights: grifos, foundLightText: const Color(0xFFE3D9C6),
      ).paint(tela, const Size(390, 844));
      expect(tela.chamadas, ['corte', 'marca', 'texto', 'corte', 'marca']);
      expect(tela.modos, [BlendMode.srcOver, BlendMode.difference]);
      // D = (máx(E3, FE), máx(D9, D1), máx(C6, 70)) = FED9C6; D − cor = 0008 56
      expect(tela.marcas.map((m) => m.$2.toARGB32()), [0xFF000856, 0xFFFED9C6]);
    });
```

Em `test/home/performance_test.dart`, no teste do `ReaderPagesPainter`, acrescentar ao mapa:

```dart
          'foundLightText': () => pintor(foundLightText: AppColors.bookTextNight),
          'highlights': () => pintor(highlights: _GrifosVazios()),
          'selection': () => pintor(selection: ValueNotifier<ReaderRange?>(null)),
          'selectionColor': () => pintor(selectionColor: AppColors.sun),
```

Os parâmetros de `pintor(...)` ganham os mesmos nomes. `_GrifosVazios` é um `ChangeNotifier` que implementa
`HighlightSource` e devolve `[]`.

- [ ] **Passo 2 — rodar e ver falhar** (`flutter test test/features/reader/presentation/reader_page_view_test.dart test/home/performance_test.dart`).

- [ ] **Passo 3 — `page_marks.dart`:**

```dart
// G13.1 — o que a página pinta além do texto do livro (Anexo 03 §9.2, prancha 21): por trás das letras, o fundo
// dos grifos, a seleção e a marca da busca; por cima, o sublinhado. Onde dois fundos se cruzam vale o de prioridade
// maior (seleção > busca > grifo): o outro é recortado naquela linha. Com letras claras (o Noite), todo fundo usa a
// técnica da D-127 (D-133). Nada de camada.
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import '../annotations/domain/annotation.dart' show HighlightStyle;
import '../layout/display_page.dart';

/// Um grifo pronto para pintar.
@immutable
final class PaintedHighlight {
  const PaintedHighlight({required this.id, required this.range, required this.color, required this.style});

  final String id;
  final ReaderRange range;
  final ui.Color color;
  final HighlightStyle style;

  @override
  bool operator ==(Object other) =>
      other is PaintedHighlight && other.id == id && other.range == range &&
      other.color == color && other.style == style;

  @override
  int get hashCode => Object.hash(id, range, color, style);
}

/// Quem sabe os grifos de um trecho mostrado (o `ReaderAnnotations`; nos testes, uma lista).
abstract interface class HighlightSource implements Listenable {
  List<PaintedHighlight> highlightsIn(ReaderRange shown);
}

/// Grifo de fundo (prancha 21): o degradê vai de 12 % a 92 % da área do texto, com raio 3, na cor a 85 %.
const double highlightBandTop = 0.12;
const double highlightBandBottom = 0.92;
const double highlightAlpha = 0.85;
const double highlightRadius = 3;

/// Seleção (L21a nº 9): a `brand` a 62 %, raio 2, na área do texto.
const double selectionAlpha = 0.62;
const double selectionRadius = 2;

/// Sublinhado (tela 23b, medido na prancha): 4 px, a partir de 3 px abaixo da linha de base.
const double underlineOffset = 3;
const double underlineThickness = 4;

/// Um fundo numa linha: o retângulo arredondado, o corte vertical opcional (a faixa do grifo), a cor e a
/// prioridade (0 = grifo, 1 = busca, 2 = seleção).
typedef MarkBand = ({
  double left,
  double right,
  double top,
  double bottom,
  double radius,
  double? clipTop,
  double? clipBottom,
  ui.Color color,
  int priority,
  double line,
});

/// Os fundos da página: grifos de fundo, marca da busca (a linha inteira + 1, raio 3 — G12) e seleção.
/// Com letras claras ([night]) as cores são opacas (a técnica da D-127 precisa da cor viva).
List<MarkBand> backgroundBands(
  DisplayPage page, {
  List<PaintedHighlight> highlights = const [],
  FoundRange? found,
  ui.Color? foundColor,
  ReaderRange? selection,
  ui.Color? selectionColor,
  bool night = false,
}) {
  ui.Color tone(ui.Color c, double a) => night ? c.withValues(alpha: 1) : c.withValues(alpha: a);
  final out = <MarkBand>[];
  for (final h in highlights) {
    if (h.style != HighlightStyle.fill) continue;
    for (final b in page.boxesOf(h.range.unit, h.range.from, h.range.to)) {
      final area = b.textBottom - b.textTop;
      out.add((
        left: b.rect.left, right: b.rect.right, top: b.textTop, bottom: b.textBottom,
        radius: highlightRadius,
        clipTop: b.textTop + highlightBandTop * area,
        clipBottom: b.textTop + highlightBandBottom * area,
        color: tone(h.color, highlightAlpha), priority: 0, line: b.rect.top,
      ));
    }
  }
  if (found != null && foundColor != null) {
    for (final b in page.boxesOf(found.unit, found.from, found.to)) {
      final r = b.rect.inflate(1);
      out.add((
        left: r.left, right: r.right, top: r.top, bottom: r.bottom, radius: 3,
        clipTop: null, clipBottom: null, color: foundColor, priority: 1, line: b.rect.top,
      ));
    }
  }
  if (selection != null && selectionColor != null) {
    for (final b in page.boxesOf(selection.unit, selection.from, selection.to)) {
      out.add((
        left: b.rect.left, right: b.rect.right, top: b.textTop, bottom: b.textBottom,
        radius: selectionRadius, clipTop: null, clipBottom: null,
        color: tone(selectionColor, selectionAlpha), priority: 2, line: b.rect.top,
      ));
    }
  }
  return cutBands(out);
}

/// Recorta cada fundo pelos de prioridade maior na mesma linha (a ordem dos que sobram é a de entrada).
List<MarkBand> cutBands(List<MarkBand> bands) {
  final out = <MarkBand>[];
  for (final b in bands) {
    var pieces = [(b.left, b.right)];
    for (final o in bands) {
      if (o.priority <= b.priority || (o.line - b.line).abs() > 0.5) continue;
      pieces = [
        for (final (l, r) in pieces) ...cutInterval(l, r, o.left, o.right),
      ];
    }
    for (final (l, r) in pieces) {
      if (r - l > 0.01) {
        out.add((
          left: l, right: r, top: b.top, bottom: b.bottom, radius: b.radius,
          clipTop: b.clipTop, clipBottom: b.clipBottom, color: b.color,
          priority: b.priority, line: b.line,
        ));
      }
    }
  }
  return out;
}

/// [l]…[r] sem [a]…[z].
List<(double, double)> cutInterval(double l, double r, double a, double z) {
  if (z <= l || a >= r) return [(l, r)];
  return [if (a > l) (l, a), if (z < r) (z, r)];
}

/// Pinta um fundo em [color] com [mode].
void paintBand(ui.Canvas canvas, MarkBand b, ui.Color color, [ui.BlendMode mode = ui.BlendMode.srcOver]) {
  final paint = ui.Paint()..color = color..blendMode = mode;
  final shape = ui.RRect.fromLTRBR(b.left, b.top, b.right, b.bottom, ui.Radius.circular(b.radius));
  final clip = b.clipTop != null;
  if (clip) {
    canvas
      ..save()
      ..clipRect(ui.Rect.fromLTRB(b.left, b.clipTop!, b.right, b.clipBottom!));
  }
  canvas.drawRRect(shape, paint);
  if (clip) canvas.restore();
}

/// Os sublinhados dos grifos, na cor viva, por cima do texto.
void paintUnderlines(ui.Canvas canvas, DisplayPage page, List<PaintedHighlight> highlights) {
  for (final h in highlights) {
    if (h.style != HighlightStyle.underline) continue;
    final paint = ui.Paint()..color = h.color.withValues(alpha: 1);
    for (final b in page.boxesOf(h.range.unit, h.range.from, h.range.to)) {
      canvas.drawRect(
        ui.Rect.fromLTRB(b.rect.left, b.baseline + underlineOffset, b.rect.right,
            b.baseline + underlineOffset + underlineThickness),
        paint,
      );
    }
  }
}

/// D-127/D-133: o maior de letra e cor em cada canal, e a diferença.
ui.Color channelMax(ui.Color a, ui.Color b) => ui.Color.from(
  alpha: 1, red: math.max(a.r, b.r), green: math.max(a.g, b.g), blue: math.max(a.b, b.b));

ui.Color channelMinus(ui.Color a, ui.Color b) =>
    ui.Color.from(alpha: 1, red: a.r - b.r, green: a.g - b.g, blue: a.b - b.b);
```

- [ ] **Passo 4 — pintor.** No `ReaderPagesPainter`:
  - os campos novos `final HighlightSource? highlights; final ValueListenable<ReaderRange?>? selection; final Color? selectionColor;`;
  - `super(repaint: Listenable.merge(<Listenable?>[document.changes, highlights, selection]))`;
  - o corpo da página atual troca a marca da G12 por:

```dart
    final page = document.current;
    final light = foundLightText;
    if (page.opaque) {
      // a imagem do PDF cobriria a marca: ela vai por cima, multiplicada (G12)
      page.paint(canvas);
      final f = document.found;
      final color = foundColor;
      if (f != null && color != null) {
        final paint = Paint()..color = color..blendMode = BlendMode.multiply;
        for (final r in page.rectsOf(f.unit, f.from, f.to)) {
          canvas.drawRRect(RRect.fromRectAndRadius(r.inflate(1), const Radius.circular(3)), paint);
        }
      }
    } else {
      final shown = page.shown;
      final hs = shown == null ? const <PaintedHighlight>[] : highlights?.highlightsIn(shown) ?? const [];
      final bands = backgroundBands(
        page,
        highlights: hs,
        found: document.found,
        foundColor: foundColor,
        selection: selection?.value,
        selectionColor: selectionColor,
        night: light != null,
      );
      if (light == null) {
        for (final b in bands) {
          paintBand(canvas, b, b.color);
        }
        page.paint(canvas);
      } else {
        // letras claras (D-127/D-133): por trás D − cor, por cima D em diferença
        for (final b in bands) {
          paintBand(canvas, b, channelMinus(channelMax(light, b.color), b.color));
        }
        page.paint(canvas);
        for (final b in bands) {
          paintBand(canvas, b, channelMax(light, b.color), BlendMode.difference);
        }
      }
      paintUnderlines(canvas, page, hs);
    }
```

O `shouldRepaint` acrescenta `!identical(old.highlights, highlights) || !identical(old.selection, selection) ||
old.selectionColor != selectionColor`. Os `_channelMax/_channelMinus` privados da G12 saem; passam a valer os do
`page_marks.dart`. O `ReaderPageView` ganha `highlights`, `selection` e `selectionColor` e os repassa ao pintor.

- [ ] **Passo 5 — rodar:** os testes novos e os da G12 (a marca da busca: ordem, cor, `multiply` no PDF, D-127 nos
  pixels) verdes; `performance_test` verde.
- [ ] **Passo 6 — teste de pixels no Noite**, ao lado do da D-127 (`reader_page_view_test.dart`):
  - um grifo amarelo sobre a "letra" de mentira (o `_Pagina(letra:)` da G12);
  - o fundo da faixa fica exato `#FED170` (±1);
  - a letra fica escura (contraste > 4,5 com o amarelo);
  - fora da faixa nada muda.

  Rodar e ver verde.
- [ ] **Passo 7 — commit:** `feat(leitor): fundo dos grifos, seleção e sublinhado na pintura da página (G13.1, D-133)`.

---

## G13.2 — Grifos do livro

### Tarefa 3: sobreposição (D-32) como função pura

**Arquivos:** `lib/features/reader/annotations/domain/highlight_overlap.dart` (novo); teste
`test/features/reader/annotations/highlight_overlap_test.dart` (novo).

- [ ] **Passo 1 — teste que falha:**

```dart
// G13.2 — D-32/D-136: mesma cor e estilo se unem (cruzando ou encostando; fica o mais antigo e as notas dos outros
// vão para ele); cor ou estilo diferente: o novo entra inteiro e o antigo perde o trecho coberto (o pedaço da
// esquerda mantém a identidade; sobrando só o da direita, ele mantém; sumindo, as notas vão para o novo).
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/highlight_overlap.dart';
import 'package:flutter_test/flutter_test.dart';

HighlightSpan _g(String id, int a, int z, {String cor = '#FED170', HighlightStyle estilo = HighlightStyle.fill, int dia = 1}) =>
    (id: id, start: a, end: z, color: cor, style: estilo, createdAt: DateTime.utc(2026, 9, dia));

HighlightRequest _novo(int a, int z, {String cor = '#FED170', HighlightStyle estilo = HighlightStyle.fill}) =>
    (start: a, end: z, color: cor, style: estilo);

void main() {
  test('sem nenhum: o pedido como veio, sem reaproveitar', () {
    final p = planHighlight(const [], _novo(10, 20));
    expect((p.start, p.end, p.keepId), (10, 20, null));
    expect(p.resized, isEmpty);
    expect(p.added, isEmpty);
    expect(p.removed, isEmpty);
  });

  test('mesma cor por dentro, cruzando e encostando: um só, do menor início ao maior fim', () {
    expect(planHighlight([_g('a', 0, 50)], _novo(10, 20)).keepId, 'a');
    final cruza = planHighlight([_g('a', 0, 15)], _novo(10, 30));
    expect((cruza.start, cruza.end, cruza.keepId), (0, 30, 'a'));
    final encosta = planHighlight([_g('a', 0, 10)], _novo(10, 20));
    expect((encosta.start, encosta.end, encosta.keepId), (0, 20, 'a'));
  });

  test('mesma cor em dois: une os três, fica o mais antigo, o outro some e as notas dele passam', () {
    final p = planHighlight([_g('novo', 0, 10, dia: 5), _g('velho', 20, 30, dia: 2)], _novo(8, 22));
    expect((p.start, p.end, p.keepId), (0, 30, 'velho'));
    expect(p.removed, ['novo']);
    expect(p.notesTo, {'novo': 'velho'});
  });

  test('em cadeia: o novo encosta num que encosta noutro da mesma cor', () {
    final p = planHighlight([_g('a', 20, 30), _g('b', 30, 40, dia: 3)], _novo(10, 20));
    expect((p.start, p.end, p.keepId, p.removed), (10, 40, 'a', ['b']));
  });

  test('cor diferente no meio: o da esquerda mantém o id, o da direita é novo', () {
    final p = planHighlight([_g('a', 0, 100)], _novo(40, 60, cor: '#FFC1C6'));
    expect((p.start, p.end, p.keepId), (40, 60, null));
    expect(p.resized, [(id: 'a', start: 0, end: 40)]);
    expect(p.added, [(from: 'a', start: 60, end: 100)]);
    expect(p.removed, isEmpty);
  });

  test('cor diferente cobrindo o começo: sobra só a direita, que mantém o id', () {
    final p = planHighlight([_g('a', 10, 50)], _novo(0, 30, cor: '#ABCF82'));
    expect(p.resized, [(id: 'a', start: 30, end: 50)]);
    expect(p.added, isEmpty);
  });

  test('cor diferente cobrindo tudo: o antigo some e as notas vão para o novo', () {
    final p = planHighlight([_g('a', 10, 20)], _novo(0, 30, cor: '#B6ACE4'));
    expect(p.removed, ['a']);
    expect(p.notesTo, {'a': null});
  });

  test('cor diferente só encostando: nada muda', () {
    final p = planHighlight([_g('a', 0, 10)], _novo(10, 20, cor: '#FFC1C6'));
    expect((p.resized, p.added, p.removed), (isEmpty, isEmpty, isEmpty));
  });

  test('mesma cor e outro estilo conta como diferente (sublinhado sobre fundo)', () {
    final p = planHighlight([_g('a', 0, 100)], _novo(40, 60, estilo: HighlightStyle.underline));
    expect(p.keepId, isNull);
    expect(p.resized, [(id: 'a', start: 0, end: 40)]);
  });
}
```

- [ ] **Passo 2 — rodar e ver falhar.**
- [ ] **Passo 3 — implementação** (`highlight_overlap.dart`):

```dart
// G13.2 — grifos que se cruzam (D-32, D-136), numa função pura. Mesma cor e mesmo estilo: os que cruzam ou
// encostam no pedido viram um só (fica o mais antigo; as notas dos outros vão para ele). Cor ou estilo diferente:
// o pedido entra inteiro e cada antigo perde o trecho coberto, sobrando em até 2 pedaços (o da esquerda mantém a
// identidade, o grupo e as notas; sobrando só o da direita, ele mantém; sumindo todo, as notas vão para quem fica).
import 'annotation.dart' show HighlightStyle;

/// Um grifo vivo do mesmo item do spine, onde ele está agora.
typedef HighlightSpan = ({
  String id,
  int start,
  int end,
  String color,
  HighlightStyle style,
  DateTime createdAt,
});

/// O grifo pedido (seleção → cor, Sublinhar, Nota).
typedef HighlightRequest = ({int start, int end, String color, HighlightStyle style});

/// O que gravar. [start]…[end] = o grifo pedido já unido; [keepId] = o antigo que vira ele (senão é novo);
/// [resized] = antigos que encolhem; [added] = pedaços da direita (grifos novos com a cor, o estilo e o grupo de
/// `from`); [removed] = os que somem; [notesTo] = para quem vão as notas de cada um que some (`null` = o pedido).
final class OverlapPlan {
  const OverlapPlan({
    required this.start,
    required this.end,
    this.keepId,
    this.resized = const [],
    this.added = const [],
    this.removed = const [],
    this.notesTo = const {},
  });

  final int start;
  final int end;
  final String? keepId;
  final List<({String id, int start, int end})> resized;
  final List<({String from, int start, int end})> added;
  final List<String> removed;
  final Map<String, String?> notesTo;
}

OverlapPlan planHighlight(List<HighlightSpan> existing, HighlightRequest next) {
  bool same(HighlightSpan h) => h.color == next.color && h.style == next.style;
  var start = next.start;
  var end = next.end;
  final merged = <HighlightSpan>[];
  for (var grew = true; grew;) {
    grew = false;
    for (final h in existing) {
      if (!same(h) || merged.contains(h)) continue;
      if (h.start <= end && h.end >= start) {
        merged.add(h);
        if (h.start < start) start = h.start;
        if (h.end > end) end = h.end;
        grew = true;
      }
    }
  }
  merged.sort((a, b) {
    final c = a.createdAt.compareTo(b.createdAt);
    return c != 0 ? c : a.id.compareTo(b.id);
  });
  final keep = merged.isEmpty ? null : merged.first.id;
  final removed = <String>[for (final h in merged.skip(1)) h.id];
  final notesTo = <String, String?>{for (final id in removed) id: keep};
  final resized = <({String id, int start, int end})>[];
  final added = <({String from, int start, int end})>[];
  for (final h in existing) {
    if (merged.contains(h)) continue;
    if (h.end <= start || h.start >= end) continue; // encostar não corta
    final left = h.start < start ? (start: h.start, end: start) : null;
    final right = h.end > end ? (start: end, end: h.end) : null;
    if (left == null && right == null) {
      removed.add(h.id);
      notesTo[h.id] = keep;
      continue;
    }
    final kept = left ?? right!;
    resized.add((id: h.id, start: kept.start, end: kept.end));
    if (left != null && right != null) {
      added.add((from: h.id, start: right.start, end: right.end));
    }
  }
  return OverlapPlan(
    start: start, end: end, keepId: keep,
    resized: resized, added: added, removed: removed, notesTo: notesTo,
  );
}
```

- [ ] **Passo 4 — rodar:** verde.
- [ ] **Passo 5 — commit:** `feat(grifos): sobreposição de grifos como função pura (G13.2, D-32)`.

### Tarefa 4: `ReaderAnnotations` e as âncoras do EPUB

**Arquivos:** `annotation_anchors.dart` (novo), `reader_document.dart` (`anchors`), `epub_reader_document.dart`,
`pdf_reader_document.dart` (`anchors => null`), `reader_annotations.dart` (novo); dublês (`_Livro` em
`reader_page_view_test.dart`: `anchors => null`). Teste: `test/features/reader/application/reader_annotations_test.dart`
(novo).

- [ ] **Passo 1 — teste que falha** (com o Dom Casmurro do arnês e o documento EPUB de verdade):

```dart
// G13.2 — os grifos e as notas do livro aberto: criar (âncora com o sha, citação de 32, página e capítulo da 1ª
// letra, grupo próprio, altura média), achar o lugar (mesmo arquivo; reancoragem; sem lugar não pinta nem apaga —
// D-44), a sobreposição gravada (D-32) com as notas, trocar, apagar com desfazer, a nota (D-131) e a última cor.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  late EpubReaderDocument doc;
  late ReaderAnnotations g;
  final erros = <Object>[];
  setUp(() async {
    livro = await LivroNaEstante.domCasmurro();
    await livro.guardarPosicao(2, livro.index.spine[2].chars ~/ 2);
    doc = await EpubReaderDocument.open(livro.deps());
    g = ReaderAnnotations(
      db: livro.db, versioning: livro.versioning, owner: () async => livro.leitor,
      userBookId: livro.userBookId, anchors: doc.anchors!, onError: (e, _) => erros.add(e),
    );
    await g.load();
  });
  tearDown(() async {
    g.dispose();
    doc.dispose();
    await livro.close();
    expect(erros, isEmpty);
  });

  ReaderRange palavras(int n, {int depois = 0}) {
    final s = doc.current.shown!;
    final texto = doc.current.textOf(s.unit, s.from, s.to);
    final m = RegExp(r'\p{L}+', unicode: true).allMatches(texto).skip(depois).take(n).toList();
    return (unit: s.unit, from: s.from + m.first.start, to: s.from + m.last.end);
  }

  Future<List<Annotation>> vivos() => AnnotationsDao(livro.db).forBook(livro.userBookId);

  test('criar: linha do grifo com âncora, citação, página, capítulo, grupo próprio e altura média', () async {
    final r = palavras(3);
    final id = await g.addHighlight(r, color: '#FED170', style: HighlightStyle.fill);
    final a = (await vivos()).single;
    expect(a.id, id);
    expect((a.kind, a.source, a.groupId, a.color, a.style, a.fillHeight),
        (AnnotationKind.highlight, AnnotationSource.selection, id, '#FED170', HighlightStyle.fill, FillHeight.medium));
    final ancora = a.anchor as EpubAnchor;
    final texto = doc.anchors!.textOf(r.unit)!;
    expect((ancora.sha, ancora.spine, ancora.start, ancora.end), (doc.anchors!.sha, r.unit, r.from, r.to));
    expect(ancora.quote.exact, texto.substring(r.from, r.to));
    expect(ancora.quote.prefix, texto.substring(r.from - 32, r.from));
    final lugar = doc.anchors!.placeOf(r.unit, r.from);
    expect((a.refPage, a.chapterIndex, ancora.refPage), (lugar.refPage, lugar.chapterIndex, lugar.refPage));
    expect(a.meta.userId, livro.leitor);
    await pumpEventQueue();
    expect(g.highlightsIn(doc.current.shown!).single.range, r);
  });

  test('D-32 gravada: mesma cor une; cor diferente no meio divide (direita no mesmo grupo) e leva as notas', () async {
    final a = await g.addHighlight(palavras(4), color: '#FED170', style: HighlightStyle.fill);
    await g.saveNote(a!, 'primeira nota');
    await g.addHighlight(palavras(2, depois: 3), color: '#FED170', style: HighlightStyle.fill);
    var linhas = await vivos();
    expect(linhas.where((x) => x.kind == AnnotationKind.highlight), hasLength(1), reason: 'uniu');
    final unido = linhas.firstWhere((x) => x.id == a);
    expect((unido.anchor as EpubAnchor).end, palavras(5).to);
    await g.addHighlight(palavras(1, depois: 2), color: '#FFC1C6', style: HighlightStyle.fill);
    linhas = await vivos();
    final grifos = linhas.where((x) => x.kind == AnnotationKind.highlight).toList();
    expect(grifos, hasLength(3));
    final direita = grifos.firstWhere((x) => x.id != a && x.color == '#FED170');
    expect(direita.groupId, unido.groupId);
    final nota = linhas.singleWhere((x) => x.kind == AnnotationKind.note);
    expect(nota.parentId, a, reason: 'a nota fica com o pedaço da esquerda');
  });

  test('cor diferente cobrindo tudo: o antigo some e a nota passa para o novo', () async {
    final a = await g.addHighlight(palavras(1, depois: 1), color: '#FED170', style: HighlightStyle.fill);
    await g.saveNote(a!, 'vai junto');
    final b = await g.addHighlight(palavras(3), color: '#B6ACE4', style: HighlightStyle.fill);
    final linhas = await vivos();
    expect(linhas.where((x) => x.kind == AnnotationKind.highlight).single.id, b);
    final nota = linhas.singleWhere((x) => x.kind == AnnotationKind.note);
    expect((nota.parentId, nota.groupId), (b, b));
  });

  test('trocar cor e estilo; apagar com a nota e desfazer', () async {
    final a = await g.addHighlight(palavras(2), color: '#FED170', style: HighlightStyle.fill);
    await g.saveNote(a!, 'nota');
    await g.restyle(a, color: '#ABCF82', style: HighlightStyle.underline);
    var grifo = (await vivos()).firstWhere((x) => x.id == a);
    expect((grifo.color, grifo.style, grifo.fillHeight), ('#ABCF82', HighlightStyle.underline, null));
    final apagado = await g.remove(a);
    expect(await vivos(), isEmpty);
    await g.restore(apagado);
    final volta = await vivos();
    expect(volta.map((x) => x.kind), unorderedEquals([AnnotationKind.highlight, AnnotationKind.note]));
    grifo = volta.firstWhere((x) => x.id == a);
    expect(grifo.meta.deletedAt, isNull);
  });

  test('nota: cria, edita, apaga com texto vazio (o grifo fica)', () async {
    final a = await g.addHighlight(palavras(2), color: '#FED170', style: HighlightStyle.fill);
    await g.saveNote(a!, '  olhos  ');
    await pumpEventQueue();
    expect(g.noteOf(a), 'olhos');
    await g.saveNote(a, 'outra');
    await pumpEventQueue();
    expect(g.noteOf(a), 'outra');
    await g.saveNote(a, '   ');
    await pumpEventQueue();
    expect(g.noteOf(a), isNull);
    expect((await vivos()).single.kind, AnnotationKind.highlight);
  });

  test('outro arquivo: acha pela citação; sem a citação no texto, não pinta e não apaga (D-44)', () async {
    final r = palavras(3);
    final texto = doc.anchors!.textOf(r.unit)!;
    Annotation grifo(String id, String exato, int deslocado) => Annotation(
      id: id, meta: metaTeste(), userBookId: livro.userBookId, kind: AnnotationKind.highlight,
      groupId: id, anchor: EpubAnchor(sha: 'f' * 64, spine: r.unit, start: r.from + deslocado,
        end: r.to + deslocado, quote: TextQuote(exact: exato), refPage: 1),
      refPage: 1, chapterIndex: 0, color: '#FED170', style: HighlightStyle.fill,
    );
    await AnnotationsDao(livro.db).upsert(grifo(idTeste(1), texto.substring(r.from, r.to), 40));
    await AnnotationsDao(livro.db).upsert(grifo(idTeste(2), 'xyzzy não existe', 0));
    await pumpEventQueue();
    final pintados = g.highlightsIn(doc.current.shown!);
    expect(pintados.map((h) => h.range), [r]);
    expect(await vivos(), hasLength(2));
  });

  test('última cor: amarelo sem histórico; guarda a escolhida no aparelho', () async {
    expect(await g.lastColor(), '#FED170');
    await g.setLastColor('#FFC1C6');
    expect(await g.lastColor(), '#FFC1C6');
    expect(await KvDao(livro.db).get(lastHighlightColorKey), '#FFC1C6');
  });

  test('o grifo sob o dedo: o mais novo que contém o ponto', () async {
    final a = await g.addHighlight(palavras(3), color: '#FED170', style: HighlightStyle.fill);
    await pumpEventQueue();
    final r = palavras(3);
    expect(g.highlightAt((unit: r.unit, offset: r.from + 1))?.id, a);
    expect(g.highlightAt((unit: r.unit, offset: r.to + 5)), isNull);
  });
}
```

(`metaTeste()` e `idTeste(n)` vêm de `test/support/personal_builders.dart`. Se `idTeste` não existir lá, criar ao
lado de `metaTeste`, devolvendo um UUID v7 fixo por `n`.)

- [ ] **Passo 2 — rodar e ver falhar.**
- [ ] **Passo 3 — âncoras** (`annotation_anchors.dart`):

```dart
// G13.2 — o que os grifos precisam do livro aberto (EPUB): o sha do conteúdo (âncoras do mesmo arquivo usam
// início/fim), o texto de um item já aberto (citação e reancoragem — Anexo 03 §5) e a página de referência e o
// capítulo de uma posição (os mesmos do marcador — G12).
abstract interface class AnnotationAnchors {
  String get sha;
  String? textOf(int spine);
  ({int refPage, int chapterIndex}) placeOf(int spine, int offset);
}
```

Em `ReaderDocument`: `/// Os grifos do livro (EPUB); `null` no PDF (D-134). AnnotationAnchors? get anchors;`. No EPUB:

```dart
  @override
  late final AnnotationAnchors anchors = _EpubAnchors(this);
```

```dart
final class _EpubAnchors implements AnnotationAnchors {
  _EpubAnchors(this._d);

  final EpubReaderDocument _d;

  @override
  String get sha => _d._deps.index.contentSha256;

  @override
  String? textOf(int spine) => _d._pager.contentOf(spine)?.item.text;

  @override
  ({int refPage, int chapterIndex}) placeOf(int spine, int offset) {
    final n = numbersAt(_d._deps.index, spine, offset);
    return (refPage: n.refPage, chapterIndex: n.chapterIndex);
  }
}
```

No PDF: `@override AnnotationAnchors? get anchors => null;`.

- [ ] **Passo 4 — `reader_annotations.dart`:**

```dart
// G13.2 — os grifos e as notas do livro aberto (D-32, D-131, D-132, D-136). Lê do banco e acha o lugar de cada
// grifo: mesmo arquivo → início/fim; outro → reancoragem do Anexo 03 §5.3 com o texto do item, quando ele está
// aberto; sem lugar → não pinta e não apaga (D-44). Entrega ao pintor os grifos da página. Cria com a
// sobreposição da D-32, troca, apaga com desfazer e guarda a nota. Relê quando a tabela muda, sem consulta viva
// (G12). A última cor fica no aparelho (`kv`).
import 'dart:async';
import 'dart:ui' show Color;

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/foundation.dart';

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/annotation_daos.dart';
import '../../../core/data/database/daos/kv_dao.dart';
import '../../../core/data/database/versioning.dart';
import '../../../core/data/clock/hlc.dart';
import '../../../core/data/ids/uuid_v7.dart';
import '../../../core/data/model/nullable.dart';
import '../../../core/data/model/record_meta.dart';
import '../annotations/domain/annotation.dart';
import '../annotations/domain/highlight_overlap.dart';
import '../domain/anchoring.dart';
import '../domain/locator.dart';
import '../layout/display_page.dart';
import '../presentation/page_marks.dart' show HighlightSource, PaintedHighlight;
import 'annotation_anchors.dart';
import 'reader_errors.dart';

/// A última cor de grifo usada, no aparelho (D-130, D-131).
const String lastHighlightColorKey = 'pref.leitor.ultimaCor';

/// Amarelo, a 1ª cor da barra: a última cor quando ainda não há nenhuma.
const String defaultHighlightColor = '#FED170';

/// O que um "apagar" levou (o grifo e as notas dele), para o desfazer (D-132).
final class RemovedHighlight {
  const RemovedHighlight(this.rows);
  final List<Annotation> rows;
}

final class ReaderAnnotations extends ChangeNotifier implements HighlightSource {
  ReaderAnnotations({
    required this.db,
    required this.versioning,
    required this.owner,
    required this.userBookId,
    required this.anchors,
    required this.onError,
  });

  final AppDatabase db;
  final LocalVersioning versioning;
  final Future<String> Function() owner;
  final String userBookId;
  final AnnotationAnchors anchors;
  final ReaderErrorReporter onError;

  List<Annotation> _rows = const [];
  final Map<String, ReaderRange?> _places = {};
  StreamSubscription<Object?>? _sub;
  bool _disposed = false;

  Future<void> load() async {
    await _reload();
    _sub = db
        .tableUpdates(TableUpdateQuery.onAllTables([db.annotations]))
        .listen((_) => unawaited(_reload()));
  }

  Future<void> _reload() async {
    try {
      final rows = await AnnotationsDao(db).forBook(userBookId);
      if (_disposed) return;
      _rows = rows;
      _places.clear();
      notifyListeners();
    } on Object catch (e, st) {
      onError(e, st);
    }
  }

  Iterable<Annotation> get _highlights =>
      _rows.where((a) => a.kind == AnnotationKind.highlight);

  /// Onde o grifo [a] está agora; `null` = sem lugar (ou o item ainda não está aberto: tenta de novo depois).
  ReaderRange? placeOf(Annotation a) {
    if (_places.containsKey(a.id)) return _places[a.id];
    final anchor = a.anchor;
    if (anchor is! EpubAnchor) return _places[a.id] = null;
    if (anchor.sha == anchors.sha) {
      return _places[a.id] = (unit: anchor.spine, from: anchor.start, to: anchor.end);
    }
    final text = anchors.textOf(anchor.spine);
    if (text == null) return null;
    return _places[a.id] = switch (reanchor(anchor, text, currentSha: anchors.sha)) {
      Anchored(:final start, :final end) => (unit: anchor.spine, from: start, to: end),
      Orphaned() => null,
    };
  }

  @override
  List<PaintedHighlight> highlightsIn(ReaderRange shown) {
    final out = <(Annotation, ReaderRange)>[];
    for (final a in _highlights) {
      final r = placeOf(a);
      if (r == null || r.unit != shown.unit || r.from >= shown.to || r.to <= shown.from) continue;
      out.add((a, r));
    }
    out.sort((x, y) => x.$1.meta.createdAt.compareTo(y.$1.meta.createdAt));
    return [
      for (final (a, r) in out)
        PaintedHighlight(id: a.id, range: r, color: hexColor(a.color!), style: a.style!),
    ];
  }

  /// O grifo sob [s] (o mais novo, se houver mais de um).
  PaintedHighlight? highlightAt(ReaderSpot s) {
    final here = highlightsIn((unit: s.unit, from: s.offset, to: s.offset + 1))
        .where((h) => h.range.from <= s.offset && s.offset < h.range.to);
    return here.isEmpty ? null : here.last;
  }

  Annotation? byId(String id) => _rows.where((a) => a.id == id).firstOrNull;

  Annotation? _noteOfRow(String highlightId) => _rows
      .where((a) => a.kind == AnnotationKind.note && a.parentId == highlightId)
      .firstOrNull;

  String? noteOf(String highlightId) => _noteOfRow(highlightId)?.noteText;

  /// Cria o grifo de [r] (D-32) e devolve o id dele; `null` se o item não está aberto.
  Future<String?> addHighlight(ReaderRange r, {required String color, required HighlightStyle style}) async {
    final text = anchors.textOf(r.unit);
    if (text == null || r.from >= r.to) return null;
    try {
      final spans = <HighlightSpan>[
        for (final a in _highlights)
          if (placeOf(a) case final p? when p.unit == r.unit)
            (id: a.id, start: p.from, end: p.to, color: a.color!, style: a.style!, createdAt: a.meta.createdAt),
      ];
      final plan = planHighlight(spans, (start: r.from, end: r.to, color: color, style: style));
      final who = await owner();
      final rows = {for (final a in _rows) a.id: a};
      final id = plan.keepId ?? UuidV7Generator().next();
      final target = <String, String>{};
      await db.transaction(() async {
        final kept = rows[id];
        await _write(id, (v, at) => kept == null
            ? _newHighlight(id, who, at, v, r.unit, plan.start, plan.end, text, color, style, groupId: id)
            : _moved(kept, at, v, r.unit, plan.start, plan.end, text));
        for (final x in plan.resized) {
          await _write(x.id, (v, at) => _moved(rows[x.id]!, at, v, r.unit, x.start, x.end, text));
          target[x.id] = x.id;
        }
        for (final x in plan.added) {
          final from = rows[x.from]!;
          final nid = UuidV7Generator().next();
          await _write(nid, (v, at) => _newHighlight(nid, who, at, v, r.unit, x.start, x.end, text,
              from.color!, from.style!, groupId: from.groupId, fillHeight: from.fillHeight));
        }
        for (final gone in plan.removed) {
          await _write(gone, (v, at) => rows[gone]!.copyWith(meta: rows[gone]!.meta.deleted(at, v)));
          target[gone] = plan.notesTo[gone] ?? id;
        }
        target[id] = id;
        // as notas seguem quem ficou (e a âncora dele)
        final groups = {id: rows[id]?.groupId ?? id, for (final x in plan.resized) x.id: rows[x.id]!.groupId};
        for (final n in _rows.where((a) => a.kind == AnnotationKind.note)) {
          final to = target[n.parentId];
          if (to == null) continue;
          final parent = await AnnotationsDao(db).byId(to);
          if (parent == null) continue;
          await _write(n.id, (v, at) => n.copyWith(
            parentId: Nullable(to), groupId: groups[to] ?? parent.groupId, anchor: parent.anchor,
            refPage: parent.refPage, chapterIndex: parent.chapterIndex, meta: n.meta.edited(at, v)));
        }
      });
      return id;
    } on Object catch (e, st) {
      onError(e, st);
      return null;
    }
  }

  /// Troca a cor e o estilo de um grifo no lugar (D-132).
  Future<void> restyle(String id, {required String color, required HighlightStyle style}) async {
    final a = byId(id);
    if (a == null) return;
    try {
      await _write(id, (v, at) => a.copyWith(
        color: Nullable(color), style: Nullable(style),
        fillHeight: Nullable(style == HighlightStyle.fill ? (a.fillHeight ?? FillHeight.medium) : null),
        meta: a.meta.edited(at, v)));
    } on Object catch (e, st) {
      onError(e, st);
    }
  }

  /// Apaga o grifo e as notas dele (`deleted_at`) e devolve o que levou, para o desfazer.
  Future<RemovedHighlight> remove(String id) async {
    final rows = [
      for (final a in _rows)
        if (a.id == id || (a.kind == AnnotationKind.note && a.parentId == id)) a,
    ];
    try {
      await db.transaction(() async {
        for (final a in rows) {
          await _write(a.id, (v, at) => a.copyWith(meta: a.meta.deleted(at, v)));
        }
      });
    } on Object catch (e, st) {
      onError(e, st);
    }
    return RemovedHighlight(rows);
  }

  /// "Desfazer": regrava o que [r] levou, vivo e com versão nova.
  Future<void> restore(RemovedHighlight r) async {
    try {
      await db.transaction(() async {
        for (final a in r.rows) {
          await _write(a.id, (v, at) => a.copyWith(
            meta: a.meta.copyWith(deletedAt: const Nullable(null), updatedAt: at, version: v)));
        }
      });
    } on Object catch (e, st) {
      onError(e, st);
    }
  }

  /// A nota do grifo [highlightId] (D-131): cria, edita ou, vazia, apaga (o grifo fica).
  Future<void> saveNote(String highlightId, String text) async {
    final t = text.trim();
    final note = _noteOfRow(highlightId) ?? await _noteFromDb(highlightId);
    final parent = byId(highlightId) ?? await AnnotationsDao(db).byId(highlightId);
    if (parent == null) return;
    try {
      if (t.isEmpty) {
        if (note != null) {
          await _write(note.id, (v, at) => note.copyWith(meta: note.meta.deleted(at, v)));
        }
        return;
      }
      if (note != null) {
        await _write(note.id, (v, at) => note.copyWith(noteText: Nullable(t), meta: note.meta.edited(at, v)));
        return;
      }
      final who = await owner();
      final id = UuidV7Generator().next();
      await _write(id, (v, at) => Annotation(
        id: id,
        meta: RecordMeta(userId: who, createdAt: at, updatedAt: at, version: v),
        userBookId: userBookId, kind: AnnotationKind.note, parentId: highlightId,
        groupId: parent.groupId, anchor: parent.anchor, refPage: parent.refPage,
        chapterIndex: parent.chapterIndex, noteText: t));
    } on Object catch (e, st) {
      onError(e, st);
    }
  }

  Future<Annotation?> _noteFromDb(String highlightId) async => (await AnnotationsDao(db).forBook(userBookId))
      .where((a) => a.kind == AnnotationKind.note && a.parentId == highlightId)
      .firstOrNull;

  Future<String> lastColor() async {
    final c = await KvDao(db).get(lastHighlightColorKey);
    return c != null && RegExp(r'^#[0-9A-F]{6}$').hasMatch(c) ? c : defaultHighlightColor;
  }

  Future<void> setLastColor(String color) => KvDao(db).set(lastHighlightColorKey, color);

  Future<void> _write(String id, Annotation Function(Hlc v, DateTime at) row) =>
      versioning.write('annotations', id, (v) async {
        final at = DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true);
        await AnnotationsDao(db).upsert(row(v, at));
      });

  EpubAnchor _anchor(int unit, int from, int to, String text) => EpubAnchor(
    sha: anchors.sha, spine: unit, start: from, end: to,
    quote: quoteAt(text, from, to), refPage: anchors.placeOf(unit, from).refPage);

  Annotation _newHighlight(String id, String who, DateTime at, Hlc v, int unit, int from, int to, String text,
      String color, HighlightStyle style, {required String groupId, FillHeight? fillHeight}) {
    final place = anchors.placeOf(unit, from);
    return Annotation(
      id: id,
      meta: RecordMeta(userId: who, createdAt: at, updatedAt: at, version: v),
      userBookId: userBookId, kind: AnnotationKind.highlight, groupId: groupId,
      anchor: _anchor(unit, from, to, text), refPage: place.refPage, chapterIndex: place.chapterIndex,
      color: color, style: style,
      fillHeight: style == HighlightStyle.fill ? (fillHeight ?? FillHeight.medium) : null,
    );
  }

  Annotation _moved(Annotation a, DateTime at, Hlc v, int unit, int from, int to, String text) {
    final place = anchors.placeOf(unit, from);
    return a.copyWith(
      anchor: _anchor(unit, from, to, text), refPage: place.refPage,
      chapterIndex: place.chapterIndex, meta: a.meta.edited(at, v));
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_sub?.cancel());
    super.dispose();
  }
}

/// "#RRGGBB" → cor opaca.
Color hexColor(String hex) => Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));
```

Em `AnnotationsDao`, acrescentar (com teste em `annotation_daos_test.dart`: lê também uma linha apagada):

```dart
  /// A linha [id], viva ou não (a sobreposição e a nota leem o pai que acabou de mudar).
  Future<Annotation?> byId(String id) =>
      (_db.select(_db.annotations)..where((t) => t.id.equals(id))).map(_toEntity).getSingleOrNull();
```

- [ ] **Passo 5 — rodar:** `reader_annotations_test`, `annotation_daos_test` e `test/features/reader` verdes.
- [ ] **Passo 6 — commit:** `feat(grifos): grifos e notas do livro aberto, com âncoras, sobreposição e desfazer (G13.2, D-32, D-44, D-131)`.

---

## G13.3 — Seleção, alças, lupa e barra

### Tarefa 5: tokens, ícones e letras

**Arquivos:**
- código: `app_colors.dart`, `reader_chrome_palette.dart` (campo `label`), `app_icons_leitor.dart`,
  `app_typography.dart`;
- testes: `reader_chrome_palette_test.dart`, `test/design_system/leitor_svgs_test.dart` (catálogo),
  `test/design_system/g13_tipos_test.dart` (novo).

- [ ] **Passo 1 — teste que falha:**
  - `ReaderChromePalette.of(creme).label == Color(0xFF6F665B)` e `of(noite).label == AppColors.mutedNight`, e o
    `lerp/faded/==` com o campo novo;
  - estilos:
    - `AppTextStyles.readerToolbarLabel`: Figtree 11/800, ls 1,2, `height: 1`, `#6F665B`;
    - `readerToolbarAction`: 11,5/800, `height: 1.2`;
    - `readerNoteField`: Figtree 15/500, `height: 1.35`;
    - `readerNoteButton`: 14/800;
  - `AppFonts.literataBook(13)` → família `LiterataVF`, `fontVariations` `opsz 13` / `wght 400`;
  - `AppIconsLeitor.note/copy/share/plusTiny` existem em `assets/icons/leitor/` e estão em `AppIconsLeitor.all`.
- [ ] **Passo 2 — rodar e ver falhar.**
- [ ] **Passo 3 — implementação:**

```dart
// app_colors.dart
  /// Rótulos pequenos do leitor nos papéis claros ("GRIFAR", "NOTA" — L21b nº 3).
  static const Color labelReader = Color(0xFF6F665B);

// reader_chrome_palette.dart: campo `final Color label;` — claros: AppColors.labelReader; Noite:
// AppColors.mutedNight; incluído em faded/lerp/==/hashCode.

// app_icons_leitor.dart
  /// (20) Nota, Copiar, Compartilhar da barra de ações (`r21.toolbar.actions.*`); a Busca usa `search` em 20.
  static const note = '$_d/ic_note.svg';
  static const copy = '$_d/ic_copy.svg';
  static const share = '$_d/ic_share.svg';

  /// (8) "+" do miolo de "Escolher outra cor" (`r21.toolbar.colors.other.icon`).
  static const plusTiny = '$_d/ic_plus_tiny.svg';
  // (o `ic_underline` do arquivo tem <text>: o ícone do Sublinhar é pintado — `UnderlineIconPainter`, Tarefa 9)

// app_typography.dart — AppFonts
  /// A Literata variável do livro num tamanho de interface (o "a" do Sublinhar: 13 do SVG em 20/24 — L21b).
  static TextStyle literataBook(double opsz, {double? size, Color color = AppColors.ink}) => TextStyle(
    fontFamily: readerFontFamily,
    fontFamilyFallback: readerFontFallback,
    fontSize: size ?? opsz,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('opsz', opsz), const FontVariation('wght', 400)],
    color: color,
    height: 1,
  );

// AppTextStyles
  /// r21.toolbar.colors.label "GRIFAR" e o título da folha da nota: Figtree 11/800, ls 1,2, `line-height: 1`.
  static final TextStyle readerToolbarLabel = AppFonts.figtreeReader(11, FontWeight.w800,
      height: 1, letterSpacing: 1.2, color: AppColors.labelReader);

  /// r21.toolbar.actions.*: Figtree 11,5/800 (altura normal do botão — 13,81).
  static final TextStyle readerToolbarAction = AppFonts.figtreeReader(11.5, FontWeight.w800);

  /// Folha da nota (D-131, extrapolada): o campo e os botões.
  static final TextStyle readerNoteField = AppFonts.figtreeReader(15, FontWeight.w500, height: 1.35);
  static final TextStyle readerNoteButton = AppFonts.figtreeReader(14, FontWeight.w800);
```

  O `AppFonts` importa `readerFontFamily`/`readerFontFallback` de
  `lib/features/reader/layout/reader_typography.dart`. Se o teste de dependências proibir o `design_system`
  importar `features`, mover as duas constantes para `lib/core/design_system/tokens/reader_fonts.dart` e reexportá-las
  no `reader_typography.dart`.

- [ ] **Passo 4 — rodar:** verde (incluindo `leitor_svgs_test` e o `preloadAppIcons` do `main`, que já usa
  `AppIconsLeitor.all`).
- [ ] **Passo 5 — commit:** `feat(design): cor dos rótulos, ícones e letras da barra de ações (G13.3)`.

### Tarefa 6: estado e regras da seleção

**Arquivos:** `lib/features/reader/presentation/selection_controller.dart` (novo); teste
`test/features/reader/presentation/selection_controller_test.dart` (novo), com uma página de mentira em que cada
palavra de `'aa bb, cc dd ee'` tem caixas de 10 px por letra.

- [ ] **Passo 1 — teste que falha:**

```dart
// G13.3 — a seleção da tela 21: a palavra da pressão longa; arrastar sem soltar cresce a partir dela (para os dois
// lados); as alças movem as bordas por palavra ou, com a lupa, por letra (D-45); presa à página (D-47); a inicial
// nunca passa da final (pelo menos 1 letra); a barra de um grifo existente guarda o id dele (D-132).
void main() {
  final p = _PaginaDeTexto('aa bb, cc dd ee'); // letra i em x = 10·i…10·i + 10, uma linha só
  ReaderRange r(int a, int z) => (unit: 0, from: a, to: z);
  Offset em(int i) => Offset(10.0 * i + 5, 20);

  test('alça final por palavra: vai ao fim da palavra sob o dedo; pontuação conta', () {
    expect(moveEdge(p, r(0, 2), SelectionHandle.end, em(7), byChar: false), r(0, 9)); // "cc" → fim
    expect(moveEdge(p, r(0, 2), SelectionHandle.end, em(5), byChar: false), r(0, 6)); // ","
  });

  test('alça inicial por palavra: vai ao começo; por letra: o ponto entre as letras', () {
    expect(moveEdge(p, r(7, 9), SelectionHandle.start, em(4), byChar: false), r(3, 9));
    expect(moveEdge(p, r(7, 9), SelectionHandle.start, const Offset(44, 20), byChar: true), r(4, 9));
  });

  test('a inicial nunca passa da final e vice-versa (pelo menos 1 letra)', () {
    expect(moveEdge(p, r(3, 5), SelectionHandle.start, em(13), byChar: false), r(4, 5));
    expect(moveEdge(p, r(3, 5), SelectionHandle.end, em(0), byChar: false), r(3, 4));
  });

  test('presa à página (D-47): o dedo fora vira a borda da página', () {
    expect(moveEdge(p, r(0, 2), SelectionHandle.end, const Offset(900, 900), byChar: false), r(0, 15));
  });

  test('arrastar sem soltar cresce a partir da palavra, para os dois lados', () {
    expect(extendFrom(p, r(7, 9), em(13)), r(7, 15));
    expect(extendFrom(p, r(7, 9), em(0)), r(0, 9));
  });

  test('controlador: escolher, crescer, alça com lupa, grifo existente e limpar avisam', () {
    final c = SelectionController();
    var avisos = 0;
    c.addListener(() => avisos++);
    c.selectWord(r(3, 5));
    expect((c.value, c.selection!.anchor, c.selection!.highlightId), (r(3, 5), r(3, 5), null));
    c.setRange(r(3, 9));
    c.beginDrag(SelectionHandle.end, em(8));
    expect((c.selection!.dragging, c.selection!.byChar), (SelectionHandle.end, false));
    c.enterCharMode();
    expect(c.selection!.byChar, isTrue);
    c.dragTo(p, const Offset(134, 20));
    expect(c.value, r(3, 13));
    c.endDrag();
    expect((c.selection!.dragging, c.selection!.byChar, c.selection!.finger), (null, false, null));
    c.showHighlight('g', r(0, 2));
    expect((c.value, c.selection!.highlightId, c.selection!.anchor), (r(0, 2), 'g', null));
    c.clear();
    expect((c.value, c.active), (null, false));
    expect(avisos, 8);
  });
}
```

- [ ] **Passo 2 — rodar e ver falhar.**
- [ ] **Passo 3 — implementação:**

```dart
// G13.3 — o trecho selecionado (tela 21). Começa na pressão longa (a palavra), cresce arrastando sem soltar e as
// alças movem as bordas: por palavra; por letra depois de 300 ms parado, com a lupa (D-45). Fica dentro da página
// (D-47) e com pelo menos 1 letra. Na barra de um grifo existente, guarda o id dele (D-132).
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Offset;

import '../layout/display_page.dart';

enum SelectionHandle { start, end }

@immutable
final class ReaderSelection {
  const ReaderSelection({required this.range, this.highlightId, this.anchor, this.dragging, this.byChar = false, this.finger});

  final ReaderRange range;
  final String? highlightId;

  /// A palavra da pressão longa (arrastar sem soltar cresce a partir dela).
  final ReaderRange? anchor;
  final SelectionHandle? dragging;

  /// A lupa abriu: a alça anda por letra até soltar (D-45).
  final bool byChar;

  /// Onde está o dedo que arrasta a alça (a lupa).
  final Offset? finger;
}

final class SelectionController extends ChangeNotifier implements ValueListenable<ReaderRange?> {
  ReaderSelection? _s;

  ReaderSelection? get selection => _s;
  bool get active => _s != null;

  @override
  ReaderRange? get value => _s?.range;

  void _set(ReaderSelection? s) {
    _s = s;
    notifyListeners();
  }

  void selectWord(ReaderRange word) => _set(ReaderSelection(range: word, anchor: word));

  void showHighlight(String id, ReaderRange range) => _set(ReaderSelection(range: range, highlightId: id));

  void setRange(ReaderRange r) {
    final s = _s;
    if (s == null || s.range == r) return;
    _set(ReaderSelection(range: r, highlightId: s.highlightId, anchor: s.anchor,
        dragging: s.dragging, byChar: s.byChar, finger: s.finger));
  }

  void beginDrag(SelectionHandle h, Offset finger) {
    final s = _s;
    if (s == null) return;
    _set(ReaderSelection(range: s.range, highlightId: s.highlightId, dragging: h, finger: finger));
  }

  void enterCharMode() {
    final s = _s;
    if (s == null || s.dragging == null || s.byChar) return;
    _set(ReaderSelection(range: s.range, highlightId: s.highlightId, dragging: s.dragging, byChar: true, finger: s.finger));
  }

  void dragTo(DisplayPage page, Offset p) {
    final s = _s;
    final h = s?.dragging;
    if (s == null || h == null) return;
    _set(ReaderSelection(
      range: moveEdge(page, s.range, h, p, byChar: s.byChar),
      highlightId: s.highlightId, dragging: h, byChar: s.byChar, finger: p));
  }

  void endDrag() {
    final s = _s;
    if (s == null || s.dragging == null) return;
    _set(ReaderSelection(range: s.range, highlightId: s.highlightId));
  }

  void clear() {
    if (_s == null) return;
    _set(null);
  }
}

/// A seleção quando a alça [h] vai para [p] (D-45, D-47): por palavra, a borda vai ao fim (alça final) ou ao começo
/// (inicial) da palavra sob o dedo; por letra, ao ponto entre as letras. Sempre dentro da página e com pelo menos
/// 1 letra.
ReaderRange moveEdge(DisplayPage page, ReaderRange r, SelectionHandle h, Offset p, {required bool byChar}) {
  final s = page.spotAt(p);
  final shown = page.shown;
  if (s == null || shown == null || s.unit != r.unit) return r;
  var at = s.offset;
  if (!byChar) {
    final w = page.wordAround(s) ??
        (s.offset > shown.from ? page.wordAround((unit: s.unit, offset: s.offset - 1)) : null);
    if (w != null) at = h == SelectionHandle.end ? w.to : w.from;
  }
  at = at.clamp(shown.from, shown.to);
  return h == SelectionHandle.end
      ? (unit: r.unit, from: r.from, to: math.max(at, r.from + 1))
      : (unit: r.unit, from: math.min(at, r.to - 1), to: r.to);
}

/// Arrastar sem soltar depois da pressão longa: da palavra [anchor] até a palavra sob [p], para qualquer lado.
ReaderRange extendFrom(DisplayPage page, ReaderRange anchor, Offset p) {
  final s = page.spotAt(p);
  if (s == null || s.unit != anchor.unit) return anchor;
  final w = page.wordAround(s) ?? (unit: s.unit, from: s.offset, to: s.offset);
  return (unit: anchor.unit, from: math.min(anchor.from, w.from), to: math.max(anchor.to, w.to));
}
```

O `_PaginaDeTexto` do teste implementa `DisplayPage` com `shown = (0, 0, texto.length)`, `spotAt` pela coluna
(`(p.dx / 10).round().clamp(0, n)`), `wordAround` com `RegExp(r'\w+|[^\w\s]')` e `boxesOf` com 10 px por letra.

- [ ] **Passo 4 — rodar:** verde.
- [ ] **Passo 5 — commit:** `feat(leitor): estado e regras da seleção (G13.3, D-45, D-47)`.

### Tarefa 7: gestos na página

**Arquivos:** `reader_page_view.dart`; teste em `reader_page_view_test.dart`. Os dublês ganham `wordAt` (a palavra
`(unit: n, from: 10, to: 14)` em `Rect.fromLTWH(40, 120, 4, 35.26)`) e o restante da geometria de mentira.

- [ ] **Passo 1 — teste que falha** (grupo `G13 — gestos da seleção`):
  - **pressão longa:** `tester.longPressAt(const Offset(42, 130))`.
    - Chama `onLongPressStart` com a posição e o `onInteraction`.
    - Arrastar sem soltar (`startGesture` → espera `kLongPressTimeout` → `moveBy`) chama `onLongPressMove`.
    - Soltar chama `onLongPressEnd`.
    - Nada vira.
  - **com `selecting: true`:** o toque em qualquer terço chama `onTapSelecting(posição)` e não vira nem segue link.
  - **precedência:** o toque no link (`_Pagina.link`) segue o link mesmo com `onTapHighlight` devolvendo `true`;
    fora do link, `onTapHighlight` → `true` não vira; `false` → os terços valem.
  - **com os controles abertos:** a pressão longa chama `onLongPressStart` (quem fecha é a tela); o toque segue
    chamando só `onCenter`.
- [ ] **Passo 2 — rodar e ver falhar.**
- [ ] **Passo 3 — implementação:** campos novos no `ReaderPageView`:

```dart
    this.selecting = false,
    this.onTapSelecting,
    this.onTapHighlight,
    this.onLongPressStart,
    this.onLongPressMove,
    this.onLongPressEnd,
    this.highlights,
    this.selection,
    this.selectionColor,
```

```dart
  /// Há uma seleção na tela (G13): o toque vai para [onTapSelecting] (fechar ou não — D-136).
  final bool selecting;
  final ValueChanged<Offset>? onTapSelecting;

  /// Toque fora de link: `true` = era um grifo e a tela abriu a barra dele (D-132); senão valem os terços.
  final bool Function(Offset p)? onTapHighlight;

  /// Pressão longa (seleção — D-45), arrastar sem soltar e soltar.
  final ValueChanged<Offset>? onLongPressStart;
  final ValueChanged<Offset>? onLongPressMove;
  final VoidCallback? onLongPressEnd;

  /// Os grifos e a seleção que o pintor desenha (G13.1).
  final HighlightSource? highlights;
  final ValueListenable<ReaderRange?>? selection;
  final Color? selectionColor;
```

No `_tapUp`, depois do bloco dos controles abertos:

```dart
    if (widget.selecting) {
      widget.onTapSelecting?.call(d.localPosition);
      return;
    }
    final hit = widget.document.current.linkAt(d.localPosition);
    if (hit != null) {
      unawaited(_follow(hit));
      return;
    }
    if (widget.onTapHighlight?.call(d.localPosition) ?? false) return;
```

No `build`, trocar `onLongPress: () {}` por:

```dart
    // pressão longa: a seleção da tela 21 (D-45); segurar e soltar nunca vale como toque
    onLongPressStart: (d) {
      if (_busy) return;
      widget.onInteraction();
      widget.onLongPressStart?.call(d.localPosition);
    },
    onLongPressMoveUpdate: (d) => widget.onLongPressMove?.call(d.localPosition),
    onLongPressEnd: (_) => widget.onLongPressEnd?.call(),
```

Também repassar `highlights`, `selection` e `selectionColor` ao `ReaderPagesPainter`. No cabeçalho do arquivo, a
linha da D-113 vira "pressão longa: a seleção da G13 (D-45)".

- [ ] **Passo 4 — rodar:** o teste novo e todo o `reader_page_view_test` da G11/G12 verdes. O da pressão longa da G11
  ("segurar e soltar não faz nada") continua passando sem callbacks.
- [ ] **Passo 5 — commit:** `feat(leitor): pressão longa e toque com a seleção na página (G13.3, D-136)`.

### Tarefa 8: camada da seleção (alças, lupa, âncora, semântica, posição da barra)

**Arquivos:** `lib/features/reader/presentation/selection_layer.dart` (novo); teste
`test/features/reader/presentation/selection_layer_test.dart` (novo).

- [ ] **Passo 1 — teste que falha:**
  - **`toolbarPlacement`** (função pura):
    - em cima quando cabe: topo = fim da 1ª linha − 162;
    - embaixo quando não cabe: topo = fundo da bolinha final + 7,4;
    - presa em `seguro + 8` quando não cabe nos dois.
  - **Alças** (camada montada sobre o `_PaginaDeTexto`, com uma linha de base em 149,6 e em 20,5):
    - haste `Rect.fromLTWH(x − 1, base − 0,8·em − 2, 2, em + 8)` e bolinha inicial `(x − 7, topo − 13, 12, 12)`;
    - bolinha final `(x − 6, fundo + 5, 12, 12)`, com as keys `r21.page.text.handleStart(.stem/.knob)` e
      `handleEnd`;
    - âncora `r21.page.text.toolbarAnchor` com largura 0 na área do texto da 1ª linha.
  - **Arrastar a alça final** (`tester.drag` da bolinha):
    - chama `controller.dragTo` e a barra some durante o arrasto;
    - parado 300 ms → `byChar` e a lupa aparece (`find.byKey('leitor.lupa')`);
    - soltar → a lupa some e a barra volta.
  - **Semântica:** um único nó "Trecho selecionado" com o texto como valor (D-57).
  - **`MagnifierPainter`:**
    - desenha a sombra 3/3, o papel, a página ampliada 1,25× e a borda 1,5 (canvas de gravação);
    - repinta só quando o foco, o centro, as cores ou o pintor da página mudam;
    - entra na lista do `performance_test`.
- [ ] **Passo 2 — rodar e ver falhar.**
- [ ] **Passo 3 — implementação:**

```dart
// G13.3 — a camada da seleção (tela 21): as alças (`#552CB7`, medidas da caixa de 1 em do arquivo), a âncora da
// barra, o nó "Trecho selecionado" (D-57), a lupa do app (D-135: sem camada, a página pintada de novo 1,25×) e a
// barra no lugar da D-136 (em cima, embaixo ou presa). A barra some enquanto uma alça é arrastada; parada 300 ms, a
// alça passa a andar por letra e a lupa aparece (D-45).
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../layout/display_page.dart';
import 'reader_chrome_palette.dart';
import 'reader_page_view.dart' show ReaderPagesPainter;
import 'selection_controller.dart';

/// Altura da barra de ações (L21b): 116,5.
const double highlightToolbarHeight = 116.5;

/// Quanto o dedo fica parado na alça até a lupa aparecer (D-45).
const Duration selectionCharDelay = Duration(milliseconds: 300);

/// Lupa (D-135, extrapolada): 132 × 48, raio 14, centro 60 acima da linha, 1,25×.
const Size magnifierSize = Size(132, 48);
const double magnifierZoom = 1.25;
const double magnifierLift = 60;

enum ToolbarPlace { above, below, pinned }

/// Onde a barra fica (D-136): em cima (como o arquivo: topo = fim da 1ª linha − 162); senão embaixo (a 7,4 do fundo
/// da bolinha final, a folga do arquivo); senão presa em [minTop].
({double top, ToolbarPlace place}) toolbarPlacement({
  required double firstLineBottom,
  required double endKnobBottom,
  required double minTop,
  required double maxBottom,
}) {
  final above = firstLineBottom - 162;
  if (above >= minTop) return (top: above, place: ToolbarPlace.above);
  final below = endKnobBottom + 7.4;
  if (below + highlightToolbarHeight <= maxBottom) return (top: below, place: ToolbarPlace.below);
  return (top: minTop, place: ToolbarPlace.pinned);
}

/// As medidas de uma alça no ponto [x] de uma linha com [baseline] e [em] (a caixa de 1 em com
/// `vertical-align: −0,2em`): a haste e a bolinha (em cima na inicial, embaixo na final).
({Rect stem, Rect knob}) handleGeometry(SelectionHandle h, double x, double baseline, double em) {
  final top = baseline - 0.8 * em;
  final bottom = baseline + 0.2 * em;
  return (
    stem: Rect.fromLTWH(x - 1, top - 2, 2, em + 8),
    knob: h == SelectionHandle.start
        ? Rect.fromLTWH(x - 7, top - 13, 12, 12)
        : Rect.fromLTWH(x - 6, bottom + 5, 12, 12),
  );
}

class SelectionLayer extends StatefulWidget {
  const SelectionLayer({
    super.key,
    required this.page,
    required this.controller,
    required this.palette,
    required this.paper,
    required this.sideMargin,
    required this.contentWidth,
    required this.safeTop,
    required this.safeBottom,
    required this.pages,
    required this.toolbar,
    required this.startTimer,
  });

  final DisplayPage page;
  final SelectionController controller;
  final ReaderChromePalette palette;

  /// O papel (o fundo da lupa).
  final Color paper;
  final double sideMargin;
  final double contentWidth;
  final double safeTop;
  final double safeBottom;

  /// O pintor da página (a lupa o usa ampliado).
  final ReaderPagesPainter Function() pages;
  final Widget toolbar;
  final Timer Function(Duration, void Function()) startTimer;

  @override
  State<SelectionLayer> createState() => _SelectionLayerState();
}

class _SelectionLayerState extends State<SelectionLayer> {
  Timer? _still;

  @override
  void dispose() {
    _still?.cancel();
    super.dispose();
  }

  void _armStill() {
    _still?.cancel();
    _still = widget.startTimer(selectionCharDelay, widget.controller.enterCharMode);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final s = widget.controller.selection;
      if (s == null) return const SizedBox.shrink();
      final r = s.range;
      final boxes = widget.page.boxesOf(r.unit, r.from, r.to);
      if (boxes.isEmpty) return const SizedBox.shrink();
      final first = boxes.first;
      final last = boxes.last;
      final start = handleGeometry(SelectionHandle.start, first.rect.left, first.baseline, first.em);
      final end = handleGeometry(SelectionHandle.end, last.rect.right, last.baseline, last.em);
      final size = MediaQuery.sizeOf(context);
      final at = toolbarPlacement(
        firstLineBottom: first.rect.bottom,
        endKnobBottom: end.knob.bottom,
        minTop: widget.safeTop + 8,
        maxBottom: size.height - widget.safeBottom - 8,
      );
      final union = boxes.map((b) => b.rect).reduce((a, b) => a.expandToInclude(b));
      Widget handle(SelectionHandle h, ({Rect stem, Rect knob}) g, TextLineBox line, String key) => Positioned(
        key: ValueKey(key),
        left: h == SelectionHandle.start ? line.rect.left : line.rect.right,
        top: line.baseline - 0.8 * line.em,
        width: 0,
        height: line.em,
        child: const SizedBox.shrink(),
      );
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fromRect(
            rect: union,
            child: Semantics(
              key: const ValueKey('r21.page.text.selection'),
              container: true,
              label: 'Trecho selecionado',
              value: widget.page.textOf(r.unit, r.from, r.to),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            key: const ValueKey('r21.page.text.toolbarAnchor'),
            left: first.rect.left,
            top: first.textTop,
            width: 0,
            height: first.textBottom - first.textTop,
            child: const SizedBox.shrink(),
          ),
          handle(SelectionHandle.start, start, first, 'r21.page.text.handleStart'),
          handle(SelectionHandle.end, end, last, 'r21.page.text.handleEnd'),
          for (final (k, g) in [('r21.page.text.handleStart', start), ('r21.page.text.handleEnd', end)]) ...[
            Positioned.fromRect(
              key: ValueKey('$k.stem'),
              rect: g.stem,
              child: const ExcludeSemantics(child: ColoredBox(color: AppColors.violet)),
            ),
            Positioned.fromRect(
              key: ValueKey('$k.knob'),
              rect: g.knob,
              child: const ExcludeSemantics(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.violet, shape: BoxShape.circle),
                ),
              ),
            ),
          ],
          if (s.dragging == null)
            Positioned(
              left: widget.sideMargin - 6,
              top: at.top,
              width: widget.contentWidth + 12,
              child: widget.toolbar,
            ),
          if (s.byChar && s.finger != null) _magnifier(s, boxes, size),
          for (final (h, g) in [(SelectionHandle.start, start), (SelectionHandle.end, end)])
            Positioned.fromRect(
              rect: Rect.fromCenter(center: g.knob.center, width: 44, height: 44),
              child: GestureDetector(
                key: ValueKey('leitor.selecao.alca.${h.name}'),
                behavior: HitTestBehavior.opaque,
                excludeFromSemantics: true,
                onPanStart: (d) {
                  widget.controller.beginDrag(h, d.globalPosition);
                  _armStill();
                },
                onPanUpdate: (d) {
                  widget.controller.dragTo(widget.page, d.globalPosition);
                  if (!(widget.controller.selection?.byChar ?? false)) _armStill();
                },
                onPanEnd: (_) {
                  _still?.cancel();
                  widget.controller.endDrag();
                },
              ),
            ),
        ],
      );
    },
  );

  Widget _magnifier(ReaderSelection s, List<TextLineBox> boxes, Size screen) {
    final line = s.dragging == SelectionHandle.start ? boxes.first : boxes.last;
    final focus = Offset(s.finger!.dx, (line.textTop + line.textBottom) / 2);
    final cx = focus.dx.clamp(magnifierSize.width / 2 + 8, screen.width - magnifierSize.width / 2 - 8);
    final box = Rect.fromCenter(
      center: Offset(cx, focus.dy - magnifierLift),
      width: magnifierSize.width,
      height: magnifierSize.height,
    );
    return Positioned.fromRect(
      key: const ValueKey('leitor.lupa'),
      rect: box.inflate(3),
      child: ExcludeSemantics(
        child: CustomPaint(
          painter: MagnifierPainter(
            pages: widget.pages(),
            focus: focus,
            paper: widget.paper,
            border: widget.palette.border,
            shadow: widget.palette.shadow,
            screen: screen,
          ),
        ),
      ),
    );
  }
}

/// A lupa (D-135): sombra dura 3/3, o papel e a página ampliada 1,25× em volta de [focus], recortados na caixa
/// arredondada (raio 14), e a borda 1,5. Sem camada.
class MagnifierPainter extends CustomPainter {
  const MagnifierPainter({
    required this.pages,
    required this.focus,
    required this.paper,
    required this.border,
    required this.shadow,
    required this.screen,
  });

  final ReaderPagesPainter pages;
  final Offset focus;
  final Color paper;
  final Color border;
  final Color shadow;
  final Size screen;

  @override
  void paint(Canvas canvas, Size size) {
    // a caixa fica 3 px para dentro (a área do widget tem a sombra em volta)
    final box = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 3, magnifierSize.width, magnifierSize.height),
      const Radius.circular(14),
    );
    canvas
      ..drawRRect(box.shift(AppShadows.hard3), Paint()..color = shadow)
      ..save()
      ..clipRRect(box)
      ..drawRRect(box, Paint()..color = paper)
      ..translate(box.center.dx, box.center.dy)
      ..scale(magnifierZoom)
      ..translate(-focus.dx, -focus.dy);
    pages.paint(canvas, screen);
    canvas
      ..restore()
      ..drawRRect(
        box.deflate(AppStrokes.regular / 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppStrokes.regular
          ..color = border,
      );
  }

  @override
  bool shouldRepaint(MagnifierPainter old) =>
      old.focus != focus || old.paper != paper || old.border != border ||
      old.shadow != shadow || old.screen != screen || !identical(old.pages, pages);
}
```

**Coordenadas:** a camada ocupa a tela inteira (`Positioned.fill` na `ReaderScreen`), então as posições locais e
globais coincidem. O `dragTo` usa `d.globalPosition`. Se o teste mostrar diferença, trocar por
`(context.findRenderObject() as RenderBox).globalToLocal(...)`.

- [ ] **Passo 4 — rodar:** verde; incluir `MagnifierPainter` no conjunto do `performance_test`, com o teste de
  repintura.
- [ ] **Passo 5 — commit:** `feat(leitor): alças, lupa e lugar da barra da seleção (G13.3, D-45, D-135, D-136)`.

### Tarefa 9: a barra de ações (L21b)

**Arquivos:** `lib/features/reader/presentation/highlight_toolbar.dart` (novo); teste
`test/features/reader/presentation/highlight_toolbar_test.dart` (novo).

- [ ] **Passo 1 — teste que falha** (a barra montada sozinha em 346 de largura, Creme e Noite):
  - **Medidas da L21b, relativas à barra:**
    - `r21.toolbar`: 346 × 116,5;
    - `.colors`: (11,5, 11,5, 323, 43,5);
    - os círculos de 34 em x 93,5/134,5/175,5/216,5/257,5/298,5 (y 11,5);
    - `.other.center` (267,5, 21,5, 14, 14) e `.other.icon` (270,5, 24,5, 8, 8);
    - `.underline.icon` (305,5, 18,5, 20, 20);
    - `.actions` (11,5, 59, 323, 50) e as 4 ações de 80,75 com os ícones em y 65,09.
  - **Estilo:**
    - caixa `#FFFAF1`, borda 1,5 `#1A1714`, raio 22, sombra 3/3;
    - círculos com as 4 cores e borda 1,5;
    - "GRIFAR" em Figtree 11/800, ls 1,2, `#6F665B`;
    - rótulos das ações em Figtree 11,5/800 `#1A1714`;
    - tracejado `ChromiumDashPainter` em `#CFC3AE` no pé da linha das cores.
  - **Semântica:** "Ações para o trecho selecionado" e os 6 rótulos do arquivo, mais Nota, Copiar, Compartilhar e
    Buscar.
  - **Grifo existente marcado:** amarelo de fundo → anel `r21.toolbar.colors.yellow.marked` 40 × 40 com borda 1,5
    `#1A1714` e `selected` na semântica; sublinhado → o anel vai para `.underline`.
  - **Toques:** cada botão chama o seu callback (cor com o hex).
  - **Noite:**
    - caixa `#2A2520`, borda `#EDE3D1`, sombra `#0B0A08`;
    - "GRIFAR" em `#B5AA98`;
    - ícones tingidos com `#EDE3D1`;
    - tracejado `#4A433A`.
  - **`RainbowRingPainter`/`UnderlineIconPainter`:** gravam o gradiente cônico (10 cores, começando no topo), as
    bordas e o "a" + o ondulado. Repintam só quando as cores mudam. Entram no `performance_test`.
- [ ] **Passo 2 — rodar e ver falhar.**
- [ ] **Passo 3 — implementação:**

```dart
// G13.3 — a barra de ações da tela 21 (L21b): "GRIFAR" + 4 cores + "outra cor" (anel arco-íris) + Sublinhar, e
// Nota · Copiar · Compartilhar · Buscar. No grifo existente, a cor dele (ou o Sublinhar) ganha um anel (D-132). No
// Noite, as cores das ilhas. O "a" do Sublinhar é pintado com a Literata do app (o <text> do SVG usaria a fonte do
// sistema — armadilha da L21b).
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../../../core/design_system/painters/chromium_dash.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../annotations/domain/annotation.dart' show HighlightStyle;
import 'reader_chrome_palette.dart';

/// As 4 cores da barra (iguais às opções de `brand` — L21b): a key, o hex e o rótulo do arquivo.
const List<({String key, String hex, String label})> highlightPalette = [
  (key: 'yellow', hex: '#FED170', label: 'Grifar em amarelo'),
  (key: 'pink', hex: '#FFC1C6', label: 'Grifar em rosa'),
  (key: 'green', hex: '#ABCF82', label: 'Grifar em verde'),
  (key: 'lavender', hex: '#B6ACE4', label: 'Grifar em lavanda'),
];

/// O grifo existente (D-132): a cor e o estilo dele.
typedef ToolbarMark = ({String color, HighlightStyle style});

class HighlightToolbar extends StatelessWidget {
  const HighlightToolbar({
    super.key,
    required this.palette,
    this.marked,
    required this.onColor,
    required this.onOtherColor,
    required this.onUnderline,
    required this.onNote,
    required this.onCopy,
    required this.onShare,
    required this.onSearch,
  });

  final ReaderChromePalette palette;
  final ToolbarMark? marked;
  final ValueChanged<String> onColor;
  final VoidCallback onOtherColor;
  final VoidCallback onUnderline;
  final VoidCallback onNote;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    Widget ring(String key, bool on, Widget child) => Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (on)
          Positioned(
            key: ValueKey('$key.marked'),
            left: -3, top: -3, width: 40, height: 40,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.fromBorderSide(line)),
              ),
            ),
          ),
      ],
    );
    Widget circle(String key, String label, bool on, VoidCallback onTap, Widget body) => Semantics(
      selected: on,
      child: Pressable(
        key: ValueKey(key),
        semanticsLabel: label,
        onTap: onTap,
        child: ring(key, on, SizedBox(width: 34, height: 34, child: body)),
      ),
    );
    final m = marked;
    final colors = [
      for (final c in highlightPalette)
        circle(
          'r21.toolbar.colors.${c.key}', c.label,
          m != null && m.style == HighlightStyle.fill && m.color == c.hex,
          () => onColor(c.hex),
          NeoBox(color: _hex(c.hex), border: line, radius: BorderRadius.circular(999)),
        ),
      circle(
        'r21.toolbar.colors.other', 'Escolher outra cor', false, onOtherColor,
        CustomPaint(
          painter: RainbowRingPainter(border: p.border, center: p.island),
          child: Center(
            child: SizedBox(
              key: const ValueKey('r21.toolbar.colors.other.center'),
              width: 14, height: 14,
              child: Center(
                child: AppSvg(
                  AppIconsLeitor.plusTiny,
                  key: const ValueKey('r21.toolbar.colors.other.icon'),
                  size: 8,
                  color: p.night ? p.border : null,
                ),
              ),
            ),
          ),
        ),
      ),
      circle(
        'r21.toolbar.colors.underline', 'Sublinhar',
        m != null && m.style == HighlightStyle.underline,
        onUnderline,
        NeoBox(
          color: p.island, border: line, radius: BorderRadius.circular(999),
          child: Center(
            child: SizedBox(
              key: const ValueKey('r21.toolbar.colors.underline.icon'),
              width: 20, height: 20,
              child: CustomPaint(painter: UnderlineIconPainter(letter: p.title)),
            ),
          ),
        ),
      ),
    ];
    Widget action(String key, String icon, String label, VoidCallback onTap) => Expanded(
      child: Pressable(
        key: ValueKey('r21.toolbar.actions.$key'),
        semanticsLabel: label,
        onTap: onTap,
        child: SizedBox(
          height: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              AppSvg(icon, key: ValueKey('r21.toolbar.actions.$key.icon'), size: 20, color: p.night ? p.title : null),
              AppText(label, style: AppTextStyles.readerToolbarAction.copyWith(color: p.title), maxLines: 1),
            ],
          ),
        ),
      ),
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Ações para o trecho selecionado',
      child: NeoBox(
        key: const ValueKey('r21.toolbar'),
        color: p.island,
        border: line,
        radius: BorderRadius.circular(22),
        shadow: AppShadows.hard3,
        shadowColor: p.shadow,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              key: const ValueKey('r21.toolbar.colors'),
              height: 43.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ExcludeSemantics(
                          child: AppText(
                            'GRIFAR',
                            key: const ValueKey('r21.toolbar.colors.label'),
                            style: AppTextStyles.readerToolbarLabel.copyWith(color: p.label),
                            maxLines: 1,
                          ),
                        ),
                        Row(
                          key: const ValueKey('r21.toolbar.colors.swatches'),
                          mainAxisSize: MainAxisSize.min,
                          spacing: 7,
                          children: colors,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: AppStrokes.regular,
                    child: CustomPaint(painter: ChromiumDashPainter(axis: Axis.horizontal, color: p.dash)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              key: const ValueKey('r21.toolbar.actions'),
              children: [
                action('note', AppIconsLeitor.note, 'Nota', onNote),
                action('copy', AppIconsLeitor.copy, 'Copiar', onCopy),
                action('share', AppIconsLeitor.share, 'Compartilhar', onShare),
                action('search', AppIconsLeitor.search, 'Buscar', onSearch),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Color _hex(String hex) => Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));

/// "Escolher outra cor" (L21b nº 9 e 10): o anel cônico arco-íris (começa no topo, como o CSS), a borda 1,5 e o
/// miolo de 14 com borda 1,5.
class RainbowRingPainter extends CustomPainter {
  const RainbowRingPainter({required this.border, required this.center});

  final Color border;
  final Color center;

  static const List<Color> colors = [
    AppColors.flame, AppColors.amber, AppColors.sun, AppColors.leaf, AppColors.emerald,
    AppColors.azure, AppColors.lavender, AppColors.violet, AppColors.blush, AppColors.flame,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas
      ..drawCircle(
        c, r,
        Paint()
          ..shader = const SweepGradient(colors: colors, transform: GradientRotation(-math.pi / 2))
              .createShader(Rect.fromCircle(center: c, radius: r)),
      )
      ..drawCircle(c, r - AppStrokes.regular / 2,
          Paint()..style = PaintingStyle.stroke..strokeWidth = AppStrokes.regular..color = border)
      ..drawCircle(c, 7, Paint()..color = center)
      ..drawCircle(c, 7 - AppStrokes.regular / 2,
          Paint()..style = PaintingStyle.stroke..strokeWidth = AppStrokes.regular..color = border);
  }

  @override
  bool shouldRepaint(RainbowRingPainter old) => old.border != border || old.center != center;
}

/// O ícone do Sublinhar (L21b nº 13): o ondulado coral do SVG (`M4 19q2-2 4 0t4 0 4 0 4 0`, traço 2, em 20/24) e o
/// "a" em Literata 13 do SVG (10,83 px na caixa de 20), centrado em x 10, linha de base em 12,08.
class UnderlineIconPainter extends CustomPainter {
  const UnderlineIconPainter({required this.letter});

  final Color letter;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final wave = Path()
      ..moveTo(4 * k, 19 * k)
      ..relativeQuadraticBezierTo(2 * k, -2 * k, 4 * k, 0)
      ..relativeQuadraticBezierTo(2 * k, 2 * k, 4 * k, 0)
      ..relativeQuadraticBezierTo(2 * k, -2 * k, 4 * k, 0)
      ..relativeQuadraticBezierTo(2 * k, 2 * k, 4 * k, 0);
    canvas.drawPath(
      wave,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * k
        ..strokeCap = StrokeCap.round
        ..color = AppColors.flame,
    );
    final style = AppFonts.literataBook(13, size: 13 * k, color: letter);
    final b = ui.ParagraphBuilder(ui.ParagraphStyle(textDirection: TextDirection.ltr))
      ..pushStyle(style.getTextStyle())
      ..addText('a');
    final p = b.build()..layout(const ui.ParagraphConstraints(width: 100));
    final m = p.computeLineMetrics().first;
    canvas.drawParagraph(p, Offset(12 * k - p.longestLine / 2, 14.5 * k - m.ascent));
    p.dispose();
  }

  @override
  bool shouldRepaint(UnderlineIconPainter old) => old.letter != letter;
}
```

**Sobre o ondulado:** `t4 0 4 0 4 0` no SVG repete o espelho do controle anterior. Os 4 trechos acima alternam
−2/+2 no controle relativo, que é o que o `t` faz. O golden da L21b confere o desenho.

- [ ] **Passo 4 — rodar:** verde. A geometria da barra sozinha bate com a L21b (as fases L da Tarefa 13 conferem de
  novo dentro da tela).
- [ ] **Passo 5 — commit:** `feat(leitor): barra de ações da seleção (G13.3, L21b, D-132)`.

### Tarefa 10: a seleção na tela do leitor

**Arquivos:** `reader_screen.dart`; teste `test/features/reader/presentation/reader_screen_g13_test.dart` (novo),
com o Dom Casmurro do arnês (`abrirLeitor`).

- [ ] **Passo 1 — teste que falha:**
  - **Pressão longa numa palavra:**
    - a seleção aparece com as alças e a barra (`r21.toolbar`);
    - o `HapticFeedback.selectionClick` foi chamado (`SystemChannels.platform` com `HapticFeedback.vibrate`);
    - o pintor tem `selection.value` = a palavra.
  - **Sem palavra:** pressão longa na margem ou no espaço entre linhas → nada.
  - **Controles abertos** → a pressão longa só fecha os controles.
  - **Com seleção:**
    - tocar fora → fecha; tocar dentro → fica;
    - arrastar a página → fecha e vira;
    - Voltar → fecha a seleção (e não o livro);
    - virar a página por outro caminho → a seleção some.
  - **Grifo existente** (gravado no banco antes de abrir):
    - tocar nele abre a barra com a cor marcada (`r21.toolbar.colors.yellow.marked`);
    - tocar fora de grifo vira a página como antes.
  - **PDF (amostra):** pressão longa não seleciona (D-134).
- [ ] **Passo 2 — rodar e ver falhar.**
- [ ] **Passo 3 — implementação** na `ReaderScreen`:
  - **Campos:**
    - `final SelectionController _selection = SelectionController();`, com `dispose` no `dispose`;
    - `ReaderAnnotations? _annotations;`, criado em `_ensureChrome(doc)` quando `doc.anchors != null`, com
      `ReaderAnnotations(db: c.deps.db, versioning: c.deps.versioning, owner: c.deps.owner, userBookId:
      widget.bookId, anchors: doc.anchors!, onError: c.deps.onError)..load()`; o anterior é descartado;
    - `ReaderRange? _note…` fica para a Tarefa 12.
  - **`_changed`:** se `_selection.value` não está dentro de `doc.current.shown`, `_selection.clear()` (a página
    mudou).
  - **Callbacks:**

```dart
  void _longPressStart(Offset p) {
    if (_controls) {
      _setControls(false);
      return;
    }
    final doc = _doc;
    final w = doc?.current.wordAt(p);
    if (w == null) return;
    unawaited(HapticFeedback.selectionClick());
    _selection.selectWord(w);
  }

  void _longPressMove(Offset p) {
    final s = _selection.selection;
    final doc = _doc;
    if (s == null || s.anchor == null || doc == null) return;
    _selection.setRange(extendFrom(doc.current, s.anchor!, p));
  }

  void _tapSelecting(Offset p) {
    final r = _selection.value;
    final doc = _doc;
    if (r == null || doc == null) return;
    final inside = doc.current.boxesOf(r.unit, r.from, r.to).any((b) => b.rect.contains(p));
    if (!inside) _selection.clear();
  }

  bool _tapHighlight(Offset p) {
    final notes = _annotations;
    final doc = _doc;
    final s = doc?.current.spotAt(p);
    if (notes == null || doc == null || s == null) return false;
    for (final o in [s.offset, s.offset - 1]) {
      final h = notes.highlightAt((unit: s.unit, offset: o));
      if (h == null) continue;
      final over = doc.current.boxesOf(h.range.unit, h.range.from, h.range.to).any((b) => b.rect.contains(p));
      if (!over) continue;
      _selection.showHighlight(h.id, h.range);
      return true;
    }
    return false;
  }
```

  (`_doc` = `(_c?.state as ReaderReady?)?.document` — um getter privado.)
  - **No `ReaderPageView`:**
    - `selecting: _selection.active`, `onTapSelecting: _tapSelecting`, `onTapHighlight: _tapHighlight`;
    - `onLongPressStart`/`Move`, com `onLongPressEnd: () {}`;
    - `onDragStarted: () { _setControls(false); _selection.clear(); }`;
    - `highlights: _annotations`, `selection: _selection`, `selectionColor: brand`;
    - o widget fica dentro de um `ListenableBuilder(listenable: _selection, …)`, para o `selecting` acompanhar.
  - **No `Stack`, depois do `ReaderFooterGap` e antes dos controles:**

```dart
          Positioned.fill(
            child: SelectionLayer(
              page: doc.current,
              controller: _selection,
              palette: islands,
              paper: palette.paper,
              sideMargin: t.sideMargin,
              contentWidth: t.contentWidth,
              safeTop: MediaQuery.viewPaddingOf(context).top,
              safeBottom: MediaQuery.viewPaddingOf(context).bottom,
              startTimer: c.deps.startTimer,
              pages: () => ReaderPagesPainter(
                document: doc, dx: 0, dir: null, neighbor: null,
                foundColor: brand, foundLightText: c.palette.lightText,
                highlights: _annotations, selection: _selection, selectionColor: brand,
              ),
              toolbar: _toolbar(islands),
            ),
          ),
```

  - **`_toolbar(islands)`** monta a `HighlightToolbar`:
    - `marked` com a cor e o estilo do `_annotations.byId(id)` quando `_selection.selection?.highlightId != null`;
    - os callbacks da Tarefa 11 (nesta tarefa, todos `() {}`).
  - **`PopScope`:** a ordem fica `_note` (Tarefa 12) → `_search` → `_controls` → `_selection.active` (limpa) →
    `_leave`.
- [ ] **Passo 4 — rodar:** o teste novo verde, mais `reader_screen_test`, `reader_screen_g12_test` e
  `book_search_panel_test`.
- [ ] **Passo 5 — commit:** `feat(leitor): seleção e grifos na tela do leitor (G13.3, D-117, D-132, D-136)`.

---

## G13.4 — Ações

### Tarefa 11: cores, Sublinhar, Outra cor, Copiar, Compartilhar, Buscar, grifo existente e desfazer

**Arquivos:**
- código: `reader_actions.dart` (novo), `reader_overlays.dart` (`ReaderUndoPill`, `readerUndoLife`, textos),
  `reader_screen.dart`;
- testes: `test/features/reader/presentation/reader_actions_test.dart` (novo), `reader_screen_g13_test.dart`.

- [ ] **Passo 1 — teste que falha:**
  - **Funções puras:**
    - `quoteForSharing(excerpt: 'como a  vaga\n', author: 'Machado de Assis', title: 'Dom Casmurro', refPage: 159)`
      → `'“como a vaga”\n— Machado de Assis, Dom Casmurro (pág. 159)'`. O U+FFFC sai.
    - `searchPrefill`: até 100 caracteres, cortado na palavra, espaços normalizados.
  - **Na tela** (`reader_screen_g13_test`):
    - **amarelo** → 1 grifo de fundo no banco com a cor e a altura média; a seleção fecha; a última cor vira
      `#FED170`; a página pinta o grifo;
    - **Sublinhar** com a última cor rosa → grifo `underline` rosa;
    - **Outra cor** → "Chega numa próxima fase" (`leitor.aviso`) por 2 s, e a seleção fica;
    - **Copiar:**
      - `Clipboard.setData` com o texto da D-39 (canal `SystemChannels.platform`, `Clipboard.setData`);
      - "Trecho copiado" por 2 s, 12 acima do rodapé;
      - a seleção fecha;
    - **Compartilhar** → o `readerShareProvider` (sobrescrito no teste) recebe o mesmo texto;
    - **Buscar** → o painel da busca abre com o campo preenchido (`leitor.busca.campo`) e a seleção fecha;
    - **grifo existente amarelo:**
      - rosa → vira fundo rosa;
      - Sublinhar → vira sublinhado rosa;
      - a cor marcada → apaga, com "Grifo apagado · Desfazer" por 4 s (`leitor.desfazer`);
      - "Desfazer" → volta com a nota;
      - sem tocar, some em 4 s.
- [ ] **Passo 2 — rodar e ver falhar.**
- [ ] **Passo 3 — `reader_actions.dart`:**

```dart
// G13.4 — o texto de Copiar e Compartilhar (D-39, D-136), o trecho que vai para a busca e o compartilhar do sistema
// (sobrescrito nos testes).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// `“trecho”` + quebra + `— Autor, Título (pág. N)`.
String quoteForSharing({required String excerpt, required String author, required String title, required int refPage}) =>
    '“${_clean(excerpt)}”\n— $author, $title (pág. $refPage)';

/// O trecho no campo da busca: até 100 caracteres, cortado na palavra.
String searchPrefill(String text) {
  final t = _clean(text);
  if (t.length <= 100) return t;
  final cut = t.lastIndexOf(' ', 100);
  return t.substring(0, cut > 0 ? cut : 100);
}

String _clean(String s) => s.replaceAll('￼', '').replaceAll(RegExp(r'\s+'), ' ').trim();

/// Abre a folha de compartilhar do sistema com [text].
final readerShareProvider = Provider<Future<void> Function(String text)>(
  (ref) => (text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  },
);
```

- [ ] **Passo 4 — `reader_overlays.dart`:**

```dart
/// Quanto dura "Grifo apagado · Desfazer" (D-132).
const Duration readerUndoLife = Duration(seconds: 4);

const String readerCopiedText = 'Trecho copiado';
const String readerRemovedText = 'Grifo apagado';

/// "Grifo apagado · Desfazer" (D-132): a pílula dos avisos com o botão.
class ReaderUndoPill extends StatelessWidget {
  const ReaderUndoPill({super.key, required this.text, required this.onUndo});

  final String text;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final s = ReaderChromeScope.of(context);
    final style = AppTextStyles.readerPill.copyWith(color: s.palette.title);
    return Semantics(
      container: true,
      child: _PillBox(
        key: const ValueKey('leitor.desfazer'),
        palette: s.palette,
        padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
        children: [
          AppText(text, style: style, maxLines: 1),
          Pressable(
            key: const ValueKey('leitor.desfazer.botao'),
            semanticsLabel: 'Desfazer',
            onTap: onUndo,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: AppText(
                'Desfazer',
                style: AppTextStyles.readerPill.copyWith(
                  fontSize: 13, color: s.palette.title,
                  decoration: TextDecoration.underline, decorationColor: s.palette.title),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Passo 5 — na tela:**
  - **Avisos com os controles fechados:**
    - `_toast` e o novo `_undo`, do tipo `({RemovedHighlight token, Timer timer})?`;
    - entram num `Positioned(left: 14, right: 14, bottom: insets.footerBottom + 13.81 + 12, child:
      ReaderChromeScope(palette: islands, brand: brand, a: 1, child: Center(...)))` quando `!_controls`;
    - com os controles abertos, o aviso continua no lugar da G12;
    - o `_setControls(false)` deixa de limpar o aviso que nasceu com eles fechados: só limpa se ele foi mostrado com
      os controles abertos (`_toastWithControls`).
  - **Ações:**

```dart
  Future<void> _color(String hex) async {
    final notes = _annotations;
    final s = _selection.selection;
    if (notes == null || s == null) return;
    final id = s.highlightId;
    if (id != null) {
      final a = notes.byId(id);
      if (a == null) return;
      if (a.style == HighlightStyle.fill && a.color == hex) {
        await _remove(id);
        return;
      }
      await notes.restyle(id, color: hex, style: HighlightStyle.fill);
    } else {
      await notes.addHighlight(s.range, color: hex, style: HighlightStyle.fill);
    }
    await notes.setLastColor(hex);
    _selection.clear();
  }

  Future<void> _underline() async {
    final notes = _annotations;
    final s = _selection.selection;
    if (notes == null || s == null) return;
    final id = s.highlightId;
    if (id != null) {
      final a = notes.byId(id);
      if (a == null) return;
      if (a.style == HighlightStyle.underline) {
        await _remove(id);
        return;
      }
      await notes.restyle(id, color: a.color!, style: HighlightStyle.underline);
    } else {
      await notes.addHighlight(s.range, color: await notes.lastColor(), style: HighlightStyle.underline);
    }
    _selection.clear();
  }

  Future<void> _remove(String id) async {
    final notes = _annotations!;
    final token = await notes.remove(id);
    _selection.clear();
    _undoTimer?.cancel();
    setState(() => _undo = token);
    _undoTimer = _c!.deps.startTimer(readerUndoLife, () {
      if (mounted) setState(() => _undo = null);
    });
    _announce(readerRemovedText);
  }

  Future<void> _undoRemove() async {
    final token = _undo;
    if (token == null) return;
    _undoTimer?.cancel();
    setState(() => _undo = null);
    await _annotations?.restore(token);
  }

  String _selectedText() {
    final r = _selection.value!;
    return _doc!.current.textOf(r.unit, r.from, r.to);
  }

  String _quote() {
    final r = _selection.value!;
    final doc = _doc!;
    return quoteForSharing(
      excerpt: _selectedText(), author: doc.author, title: doc.title,
      refPage: doc.anchors!.placeOf(r.unit, r.from).refPage);
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _quote()));
    _selection.clear();
    _showToast(readerCopiedText);
  }

  Future<void> _share() async {
    final text = _quote();
    _selection.clear();
    await ref.read(readerShareProvider)(text);
  }

  void _searchSelection() {
    final q = searchPrefill(_selectedText());
    _selection.clear();
    _searchSession?.type(q);
    _openSearch();
  }
```

  O "Outra cor" chama `_showToast(readerSoonText)` (D-129). O `_announce` é o `SemanticsService.sendAnnouncement`
  do `_showToast`, extraído. `_undoTimer` é cancelado no `dispose`.
- [ ] **Passo 6 — rodar:** verde.
- [ ] **Passo 7 — commit:** `feat(leitor): ações da barra — cores, sublinhar, copiar, compartilhar, buscar, apagar com desfazer (G13.4, D-39, D-129, D-130, D-132)`.

### Tarefa 12: a folha da nota (D-131)

**Arquivos:** `lib/features/reader/presentation/note_sheet.dart` (novo), `reader_screen.dart`; testes
`test/features/reader/presentation/note_sheet_test.dart` (novo) e `reader_screen_g13_test.dart`.

- [ ] **Passo 1 — teste que falha:**
  - **A folha sozinha, Creme:**
    - cartão `leitor.nota` a 14 das bordas e 14 acima do teclado (`MediaQuery.viewInsets.bottom = 300`);
    - raio 28, borda 1,5, sombra 3/3;
    - "NOTA" em Figtree 11/800 ls 1,2 `#6F665B`;
    - trecho entre aspas em Literata 17 (o `readerSearchExcerpt`), no máximo 2 linhas, com "…";
    - campo `leitor.nota.campo` focado, com a dica "Escreva sua nota…";
    - "Salvar" (`leitor.nota.salvar`) desabilitado com o campo vazio ou só com espaços; habilitado com texto;
    - "Cancelar" e "Salvar" chamam os callbacks; o Salvar recebe o texto.
  - **A folha no Noite:** as cores das ilhas.
  - **Na tela, seleção nova:**
    - Nota → folha; escrever e Salvar → no banco, 1 grifo de fundo na última cor + 1 nota ligada (mesmo grupo); a
      seleção fecha;
    - Cancelar ou Voltar → a folha fecha e a seleção continua; nada no banco.
  - **Na tela, grifo existente com nota:**
    - Nota abre com o texto dela;
    - Salvar vazio apaga só a nota.
- [ ] **Passo 2 — rodar e ver falhar.**
- [ ] **Passo 3 — `note_sheet.dart`:**

```dart
// G13.4 — a folha da nota (D-131, D-23: não desenhada; extrapolada com os tokens das ilhas): um cartão que sobe
// com o teclado — "NOTA", o trecho citado, o campo e Cancelar/Salvar. Salvar fica desabilitado com o campo vazio.
import 'package:flutter/material.dart' show InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import 'reader_chrome_palette.dart';
import 'reader_palette.dart';

class NoteSheet extends StatefulWidget {
  const NoteSheet({
    super.key,
    required this.excerpt,
    required this.initial,
    required this.palette,
    required this.paper,
    required this.brand,
    required this.onCancel,
    required this.onSave,
  });

  final String excerpt;
  final String initial;
  final ReaderChromePalette palette;
  final ReaderPalette paper;
  final Color brand;
  final VoidCallback onCancel;
  final ValueChanged<String> onSave;

  @override
  State<NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<NoteSheet> {
  late final TextEditingController _field = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    final empty = _field.text.trim().isEmpty;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    Widget button(String key, String label, Color fill, Offset? shadow, VoidCallback? onTap) => Expanded(
      child: Pressable(
        key: ValueKey(key),
        semanticsLabel: label,
        enabled: onTap != null,
        onTap: onTap,
        child: NeoBox(
          height: 44,
          color: fill,
          border: line,
          radius: BorderRadius.circular(999),
          shadow: shadow,
          shadowColor: p.shadow,
          child: Center(
            child: AppText(
              label,
              style: AppTextStyles.readerNoteButton.copyWith(color: onTap == null ? p.disabled : p.title),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: p.veil)),
        Positioned(
          left: 14,
          right: 14,
          bottom: keyboard + 14,
          child: NeoBox(
            key: const ValueKey('leitor.nota'),
            color: p.island,
            border: line,
            radius: BorderRadius.circular(28),
            shadow: AppShadows.hard3,
            shadowColor: p.shadow,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText('NOTA', style: AppTextStyles.readerToolbarLabel.copyWith(color: p.label), maxLines: 1),
                const SizedBox(height: 8),
                AppText(
                  '“${widget.excerpt}”',
                  style: AppTextStyles.readerSearchExcerpt.copyWith(color: widget.paper.text),
                  maxLines: 2,
                  ellipsis: true,
                ),
                const SizedBox(height: 12),
                NeoBox(
                  color: p.well,
                  border: line,
                  radius: BorderRadius.circular(16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Material(
                    type: MaterialType.transparency,
                    child: TextField(
                      key: const ValueKey('leitor.nota.campo'),
                      controller: _field,
                      autofocus: true,
                      minLines: 3,
                      maxLines: 8,
                      inputFormatters: [LengthLimitingTextInputFormatter(10000)],
                      onChanged: (_) => setState(() {}),
                      style: AppTextStyles.readerNoteField.copyWith(color: p.title),
                      cursorColor: p.title,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Escreva sua nota…',
                        hintStyle: AppTextStyles.readerNoteField.copyWith(color: p.muted),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  spacing: 10,
                  children: [
                    button('leitor.nota.cancelar', 'Cancelar', p.island, null, widget.onCancel),
                    button('leitor.nota.salvar', 'Salvar', widget.brand, AppShadows.hard2,
                        empty ? null : () => widget.onSave(_field.text)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Passo 4 — na tela:**
  - **Estado:** `({ReaderRange range, String? highlightId, String initial})? _note`. O "Nota" da barra preenche
    com o trecho, o id do grifo existente (se houver) e o `noteOf(id) ?? ''`.
  - **Camada:** acima dos controles e abaixo da busca, `if (_note != null) Positioned.fill(BlockSemantics(NoteSheet(...)))`.
  - **Salvar:**

```dart
  Future<void> _saveNote(String text) async {
    final n = _note;
    final notes = _annotations;
    if (n == null || notes == null) return;
    var id = n.highlightId;
    if (id == null) {
      id = await notes.addHighlight(n.range, color: await notes.lastColor(), style: HighlightStyle.fill);
      if (id == null) return;
    }
    await notes.saveNote(id, text);
    setState(() => _note = null);
    _selection.clear();
  }
```

  - **Cancelar e Voltar:** `setState(() => _note = null)`. A seleção fica.
  - **`PopScope`:** `_note` vem primeiro.
- [ ] **Passo 5 — rodar:** verde.
- [ ] **Passo 6 — commit:** `feat(leitor): folha da nota com o grifo na última cor (G13.4, D-23, D-131)`.

---

## G13.5 — Prova

### Tarefa 13: o mundo da 21 e as fases L21a e L21b

**Arquivos:** `test/support/dados_t21.dart`, `test/support/fase_l21.dart`,
`test/features/reader/presentation/l21_test.dart` (novos).

- [ ] **Passo 1 — `dados_t21.dart`:**

```dart
// G13.5 — o mundo da tela 21 no banco do leitor (D-34): o Dom Casmurro do mundo na pág. 159 e as anotações do
// mundo da 21 (o grifo de seleção amarelo em "aqueles olhos de Capitu"; sem tinta). A seleção da prancha é feita
// com os gestos de verdade (pressão longa em "como" e a alça final arrastada até o ponto de "ressaca.").
Future<LivroNaEstante> livroDaTela21({ReaderPaper papel = ReaderPaper.creme}) async {
  final m = mundoDaTela21;
  final livro = await LivroNaEstante.epubDe(
    mundoEpub(Slugs.domCasmurro, completo: true),
    livro: m.domCasmurro,
    leitor: m.usuarioId,
  );
  await livro.usarIndice(indiceDaTela19(livro.index));
  await livro.guardarPosicao(itemDaPagina159, 0);
  for (final a in m.anotacoes) {
    await AnnotationsDao(livro.db).upsert(a);
  }
  await ReaderSettingsDao(livro.db).upsert(m.ajustes.copyWith(paper: papel));
  return livro;
}

/// Abre a tela 21: o leitor na pág. 159 e a seleção de `t21.selecao` feita com os gestos.
Future<LeitorNaTela> abrirTela21(WidgetTester tester, LivroNaEstante livro, {bool golden = false}) async {
  setCanvasView(tester, logical: const Size(390, 844));
  final t = await abrirLeitor(tester, livro, golden: golden, deps: (t) => depsDaTela20(t, livro));
  final p = tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document.current as PageSnapshot;
  final a = p.item.text.indexOf(t21.selecao!.texto);
  final z = a + t21.selecao!.texto.length;
  await tester.longPressAt(p.boxesOf(p.spine, a, a + 4).first.rect.center);
  await tester.pump(const Duration(milliseconds: 50));
  final alca = tester.getCenter(find.byKey(const ValueKey('r21.page.text.handleEnd.knob')));
  final ponto = p.boxesOf(p.spine, z - 1, z).single.rect.center;
  final g = await tester.startGesture(alca);
  await g.moveTo(Offset(ponto.dx, ponto.dy));
  await tester.pump();
  await g.up();
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  return t;
}
```

  O arrasto vai do centro da bolinha até o centro do ponto. Como a alça fica na bolinha, o dedo tem um desvio: o
  `moveTo` leva o ponto do dedo até o ponto do ".", e o `dragTo` usa a posição do dedo. Se a seleção não terminar
  exatamente em `z`, o teste de dados da L21 mostra; nesse caso, ajustar o alvo do arrasto (centro do "." menos o
  desvio entre a bolinha e a linha).
- [ ] **Passo 2 — `fase_l21.dart`**, no molde do `fase_l20.dart`, com
  `faseL21({required String nome, required LeitorRefPrancha ref, required InstantaneoDoLeitor instantaneo})`:
  - **Seções:** `r21.page`, `r21.footer` e `r21.toolbar`. Os ids vêm de `ref.idsOfSection(s)` (sem inline).
  - **Chaves:**
    - `r21.page` → `r19.page`;
    - `r21.page.text` → o retângulo do `LaidText` da 1ª fatia, como na L20;
    - `r21.footer*` → `r19.footer*`;
    - `r21.page.text.handle*`, `toolbarAnchor` e `r21.toolbar*` → as próprias keys;
    - o `orphanLabel` não existe (D-57) e fica fora da lista com comentário.
  - **Testes:**
    - **geometria** (±0,5; ±1 em x/w para os `textDependentX`);
    - **texto:** as 19 linhas da página e as 5 da barra, com as baselines (`RenderAppText.debugLines()`);
    - **estilo:**
      - alças `#552CB7`;
      - fundo do grifo: o pintor pinta `#FED170@.85` na faixa de 12–92 %, conferido com o canvas de gravação sobre
        o pintor da tela;
      - seleção `#B6ACE4@.62`;
      - barra como no teste da Tarefa 9;
    - **semântica:** um só "Trecho selecionado" com o texto; os rótulos da barra; as alças fora da árvore;
    - **dados:** a seleção = `t21.selecao.texto`; o grifo pintado = o trecho do `mundoDaTela21` ("aqueles olhos de
      Capitu").
- [ ] **Passo 3 — `l21_test.dart`:** `void main() => faseL21(nome: 'L21', ref: kRef21, instantaneo: t21);`.
- [ ] **Passo 4 — rodar:** verde. Se a geometria de um id falhar, conferir o lado a lado antes de mexer: o desenho
  corrigido (D-55) só esconde as linhas 20–22.
- [ ] **Passo 5 — commit:** `test(leitor): fases L21a e L21b contra as medidas do arquivo (G13.5)`.

### Tarefa 14: goldens e capturas

**Arquivos:** `test/golden/leitor_21_test.dart`, `test/golden/capturas_g13_test.dart` (novos).

- [ ] **Passo 1 — golden** (molde do `leitor_20_test.dart`): `abrirTela21(tester, livro, golden: true)`, depois
  `captureAt(find.byKey(goldenRootKey))` em 1170 × 2532 e `matchesGoldenFile('goldens/leitor_21@3x.png')`. Gerar
  com `--update-goldens`.
- [ ] **Passo 2 — comparar com a prancha corrigida:**
  - `python3 tools/compare_images.py --flutter test/golden/goldens/leitor_21@3x.png --ref handoff_v2/referencia/png/21_selecao_texto_corrigida_390x844@3x.png --scale 3 --rect 0,84,390,760 --out build/visual_diff_g13 --name tela21_pagina`;
  - o mesmo com `--rect 0,345.12,390,132.5 --name tela21_barra`;
  - os dois com `blur_mismatch_% ≤ 0,5`;
  - inspecionar o lado a lado e o heatmap.
- [ ] **Passo 3 — capturas** (`BOOKNEST_CAPTURAS`):
  - `g13_tela21_creme` e `g13_tela21_noite`;
  - `g13_lupa` (alça parada 300 ms);
  - `g13_barra_embaixo` (seleção na 1ª linha da página);
  - `g13_nota` (folha aberta com texto, teclado simulado por `viewInsets`);
  - `g13_grifo_existente` (barra do grifo com o anel);
  - `g13_desfazer` (o aviso "Grifo apagado · Desfazer").
- [ ] **Passo 4 — commit:** `test(leitor): golden da tela 21 e capturas da G13 (G13.5)`.

### Tarefa 15: verificação e relatório

- [ ] **Suíte completa com cobertura** (`suite.ps1`):
  - `flutter analyze` com 0 problemas e todos os testes verdes;
  - cobertura ≥ 90 % nos arquivos de `lib/` mexidos na fase (`git diff --name-only 31c31af..HEAD -- lib`).
- [ ] **Mutação** (`tools/medicao/tmp/mut/g13/`, gerador `/home/claude/g03/mut/gerar_g13.py`, no molde do
  `gerar_g12.py`). Uma troca por regra, e cada uma precisa reprovar os testes indicados:
  - **área do texto e página:**
    - área = linha inteira (sem o `(height − area)/2`);
    - espaço do fim de linha incluído nas caixas;
    - `wordAt` sem a letra anterior;
    - pontuação vale como palavra na pressão longa;
    - `spotAt` fora da página (sem o `clamp`);
  - **pintura:**
    - faixa de 0–100 % em vez de 12–92 %;
    - grifo a 100 % no Creme;
    - seleção a 85 %;
    - seleção por cima do texto;
    - sublinhado na linha de base (offset 0);
    - sublinhado por trás do texto;
    - sem recorte por prioridade;
    - Noite sem a diferença (D-133);
  - **D-32:**
    - encostar não une;
    - mantém o mais novo;
    - pedaço da direita sem o grupo;
    - notas não passam;
    - estilo ignorado na comparação;
  - **grifos do livro:**
    - âncora sem a citação;
    - página da última letra;
    - grupo novo para o pedaço da direita;
    - desfazer sem as notas;
    - nota vazia não apaga;
    - última cor sem padrão;
    - reancoragem desligada;
  - **seleção (D-45, D-47):**
    - alça final vai ao começo da palavra;
    - por letra sem os 300 ms (0 ms);
    - 3000 ms;
    - sem o `clamp` da página;
    - inicial passa da final;
    - arrastar sem soltar só para a direita;
  - **gestos:**
    - pressão longa abre com os controles abertos;
    - toque com seleção vira;
    - grifo antes do link;
    - arrasto não fecha a seleção;
    - Voltar fecha o livro com seleção;
  - **barra:**
    - −150 em vez de −162;
    - sem a posição embaixo;
    - sem presa no topo;
    - não some no arrasto;
    - anel no lugar errado (o Sublinhar marcado num grifo de fundo);
  - **ações:**
    - cor não vira a última;
    - Sublinhar sempre amarelo;
    - Outra cor sem aviso;
    - Copiar sem a página;
    - Compartilhar sem as aspas;
    - Buscar sem o trecho;
    - a cor marcada não apaga;
    - desfazer em 2 s;
    - Nota cria sem grifo;
    - cancelar a nota fecha a seleção;
  - **lupa:**
    - zoom 1;
    - sem recorte;
    - acima de 30 em vez de 60.
- [ ] **Revisão independente** por um agente que não escreveu o código. Corrigir com teste o que for técnico;
  perguntar o que for de produto.
- [ ] **gitleaks** nos commits da fase (`31c31af^..HEAD`) e em `lib/features/reader`, `test` e `docs/progresso`.
- [ ] **`docs/progresso/G13.md`:** resultados, revisão, desvios, pendências e o checklist com os commits.
- [ ] **`docs/progresso/RELATORIO_G13.md`:** termina em "✅ FASE G13 concluída — aguardando sua aprovação para
  iniciar a FASE G14.". Vai também ao projeto (`handoff_app_completo/relatorios/RELATORIO_G13.md`).
- [ ] **Capturas** mandadas na conversa.
- [ ] **Commit:** `docs(g13): resultados, revisão independente e relatório da fase`.
