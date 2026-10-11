# G11 — Plano de implementação (tela 19, leitor limpo)

> **Para quem executa:** seguir tarefa por tarefa (`superpowers:executing-plans`), com TDD: teste que falha →
> código mínimo → teste verde → commit. Desenho aprovado: `docs/progresso/G11.md` (D-104…D-113).

**Objetivo:** abrir um livro da estante numa tela 19 idêntica à prancha, virar páginas (toque e arrasto), seguir
links internos, ler PDF básico — com posição, tempo e tela acesa ligados.

**Arquitetura:** um `ReaderDocument` (EPUB sobre o `BookPager` da G10; PDF sobre o `pdfrx`) entrega páginas
prontas para pintar (`DisplayPage`); um `ReaderSessionController` abre o livro pelo id da estante e liga
posição, tempo, tela acesa e links; a `ReaderScreen` só pinta, mede os gestos e mostra rodapé, sobreposições e
estados.

**Tecnologia:** Flutter 3.47.2 / Dart 3.13.2, Riverpod 3, go_router 18, drift, `dart:ui` (Paragraph), `pdfrx`
2.6.5, `wakelock_plus` (novo).

**Fluxo de trabalho (o mesmo das fases anteriores):**
- editar no espelho `/home/claude/g03/repo`;
- `./ciclo.sh <arquivos>` gera o zip; `device_commit_files` leva o zip a `tools\medicao\tmp\`;
- `ciclo.ps1 -Zip … -Nome … -Testes "…"` (formata, analisa, testa) e ler o `.log`/`.fim`;
- puxar de volta os arquivos que o `dart format` mudou (`device_stage_files` + `puxar.sh`);
- commit no Windows com `git commit -F tools/medicao/tmp/msg_*.txt`, mensagens em português `tipo(escopo): descrição` e as 2 linhas de coautoria.

---

## Mapa de arquivos

| Arquivo | Responsabilidade | Tarefa |
|---|---|---|
| `lib/core/design_system/tokens/app_colors.dart` (mod.) | cores dos 4 papéis e do rodapé | 1 |
| `lib/core/design_system/tokens/app_typography.dart` (mod.) | `AppTextStyles.readerFooter`, `AppFonts.figtreeReader` (w800 real, D-16) | 1 |
| `pubspec.yaml` (mod.) | Figtree/FigtreeExt w800 (`*-ExtraBold.ttf`, já em `assets/fonts/`) | 1 |
| `lib/features/reader/presentation/reader_palette.dart` | `ReaderPalette.of(ReaderPaper)` | 1 |
| `lib/features/reader/presentation/reader_insets.dart` | `ReaderInsets.of(viewPadding)` (D-112) | 1 |
| `lib/core/preferences/brand_preference.dart` | `BrandStore`, `KvBrandStore`, `brandProvider` (D-33) | 2 |
| `lib/features/home/application/home_providers.dart` (mod.) | `HomeTheme.brand` vem do `brandProvider` | 2 |
| `lib/features/reader/layout/display_page.dart` | `DisplayPage`, `LinkHit`, `PageDirection` | 3 |
| `lib/features/reader/layout/page_snapshot.dart` | `PageSnapshot` (EPUB): pintar, texto, `linkAt` | 3 |
| `lib/features/reader/application/book_pager.dart` (mod.) | `current`, `peek` | 4 |
| `lib/features/reader/application/reader_document.dart` | `ReaderDocument`, `ReaderNumbersView`, `ReaderMark` | 5 |
| `lib/features/reader/application/epub_reader_document.dart` | EPUB: abrir, virar, números, links, posição | 5–6 |
| `lib/features/reader/application/screen_awake.dart` | `ScreenAwake` + `WakelockScreenAwake` (D-111) | 7 |
| `lib/features/reader/application/reader_session_controller.dart` | estados, abrir, falhas, tempo, tela acesa, volta do link | 8–10 |
| `lib/features/reader/application/reader_providers.dart` | `readerDepsProvider`, `screenAwakeProvider`, `readerSystemUiProvider`, `layoutSchedulerProvider` | 8 |
| `lib/features/reader/presentation/reader_screen.dart` | rota, montagem, estados, ciclo de vida, barra de status, Voltar | 11, 14 |
| `lib/features/reader/presentation/reader_page_view.dart` | gestos, carrossel, pintura | 12 |
| `lib/features/reader/presentation/reader_footer.dart` | rodapé `r19.footer` | 11 |
| `lib/features/reader/presentation/reader_overlays.dart` | fechar provisório (D-106), pílula de voltar (D-108) | 13 |
| `lib/features/reader/presentation/reader_states.dart` | abrindo / erros (D-21) | 14 |
| `lib/app/router.dart` (mod.) | `/leitor/:bookId` real | 11 |
| `lib/features/reader/domain/locator.dart` (mod.) | `PdfLocator` | 15 |
| `lib/features/reader/application/pdf_position_keeper.dart` | posição de PDF | 15 |
| `lib/features/reader/application/pdf_reader_document.dart` | PDF: páginas como imagem, números, virar | 16 |
| `pubspec.yaml` (mod.), `docs/adr/ADR-005*.md` (mod.) | `wakelock_plus` + linha no ADR | 7 |
| `test/fixtures/telas/indice_t19.dart` | índice injetado (D-34) que dá 159/256/62 % | 17 |
| `test/features/reader/...` (novos) | testes de cada tarefa | todas |

---

## G11.1 — Tokens e áreas

### Tarefa 1: paleta dos papéis, estilo do rodapé e áreas

**Arquivos:** `app_colors.dart`, `app_typography.dart`, `reader_palette.dart`, `reader_insets.dart`;
teste `test/features/reader/presentation/reader_palette_test.dart`.

- [ ] **Passo 1 — teste que falha:**

```dart
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_insets.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('os 4 papéis: papel, texto e rodapé (Anexo 01, Anexo 03 §7.1, D-110)', () {
    String hex(Color c) => c.toARGB32().toRadixString(16).toUpperCase();
    final got = {
      for (final p in ReaderPaper.values)
        p: [ReaderPalette.of(p).paper, ReaderPalette.of(p).text, ReaderPalette.of(p).footer].map(hex).toList(),
    };
    expect(got, {
      ReaderPaper.creme: ['FFF8F1E4', 'FF2A2520', 'FFA89D8B'],
      ReaderPaper.branco: ['FFFFFDF8', 'FF1A1714', 'FFA9A6A2'],
      ReaderPaper.sepia: ['FFEEDDBF', 'FF4A3622', 'FFA08E74'],
      ReaderPaper.noite: ['FF1F1B17', 'FFE3D9C6', 'FF8A8073'],
    });
  });

  test('Figtree 800 real nas telas 19–27b (D-16, L00); a Início continua até 700 (D-14)', () {
    expect(AppFonts.figtreeReader(12.5, FontWeight.w800).fontWeight, FontWeight.w800);
    expect(() => AppFonts.figtree(12.5, FontWeight.w800), throwsAssertionError);
  });

  test('rodapé: Figtree 11,5/600 com números tabulares (L19 §4)', () {
    final s = AppTextStyles.readerFooter;
    expect((s.fontFamily, s.fontSize, s.fontWeight), ('Figtree', 11.5, FontWeight.w600));
    expect(s.fontFeatures, contains(const FontFeature.tabularFigures()));
  });

  test('áreas (D-112): canvas e iPhone dão 92/82/40; Android com barra alta empurra', () {
    final zero = ReaderInsets.of(EdgeInsets.zero);
    expect((zero.top, zero.bottom, zero.footerBottom), (92.0, 82.0, 40.0));
    final iphone = ReaderInsets.of(const EdgeInsets.only(top: 47, bottom: 34));
    expect((iphone.top, iphone.bottom, iphone.footerBottom), (92.0, 82.0, 40.0));
    final alto = ReaderInsets.of(const EdgeInsets.only(top: 59, bottom: 48));
    expect((alto.top, alto.bottom, alto.footerBottom), (104.0, 96.0, 54.0));
  });
}
```

- [ ] **Passo 2 — rodar:** `ciclo.ps1 … -Testes "test/features/reader/presentation/reader_palette_test.dart"` → falha de compilação (arquivos não existem).
- [ ] **Passo 3 — implementar:**

`app_colors.dart` (depois de `inkWarm`, seção nova):

```dart
  // Leitor (Anexo 01 §0, Anexo 03 §7.1, D-110)

  /// Papel Creme (tela 19) e texto do livro nele.
  static const Color paperCream = Color(0xFFF8F1E4);
  static const Color bookText = Color(0xFF2A2520);
  static const Color paperWhite = Color(0xFFFFFDF8);
  static const Color paperSepia = Color(0xFFEEDDBF);
  static const Color bookTextSepia = Color(0xFF4A3622);
  static const Color paperNight = Color(0xFF1F1B17);
  static const Color bookTextNight = Color(0xFFE3D9C6);

  /// "pág. X de Y · %": Creme (tela 19) e Noite (26b) medidos; Branco e Sépia com o contraste do Creme (D-110).
  static const Color readerFooter = Color(0xFFA89D8B);
  static const Color readerFooterWhite = Color(0xFFA9A6A2);
  static const Color readerFooterSepia = Color(0xFFA08E74);
  static const Color readerFooterNight = Color(0xFF8A8073);
```

`app_typography.dart` (em `AppTextStyles`):

```dart
  /// r19.footer.pageLabel / percent — `tabular-nums` (a cor vem do papel: ReaderPalette.footer).
  static final TextStyle readerFooter = AppFonts.figtree(
    11.5,
    FontWeight.w600,
    color: AppColors.readerFooter,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
```

`AppFonts.figtreeReader` (mesmo corpo do `figtree`, aceitando 400–800) e no `pubspec.yaml`, nas famílias
`Figtree` e `FigtreeExt`, o peso 800 (`Figtree-ExtraBold.ttf`, `FigtreeExt-ExtraBold.ttf`):

```dart
  /// Figtree das telas 19–27b: o 800 é real (D-16, L00). A Início continua com [figtree] (até 700, D-14).
  static TextStyle figtreeReader(
    double size,
    FontWeight weight, {
    double height = 1.2,
    double letterSpacing = 0,
    Color color = AppColors.ink,
  }) {
    assert(weight.value >= 400 && weight.value <= 800);
    return TextStyle(
      fontFamily: 'Figtree',
      fontFamilyFallback: const ['FigtreeExt'],
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }
```

`reader_palette.dart`:

```dart
// G11.1 — cores de cada papel do leitor (Anexo 01 §0, Anexo 03 §7.1, D-110).
import 'package:flutter/painting.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../domain/reader_settings.dart';

@immutable
final class ReaderPalette {
  const ReaderPalette({required this.paper, required this.text, required this.footer});

  final Color paper;
  final Color text;
  final Color footer;

  static ReaderPalette of(ReaderPaper p) => switch (p) {
    ReaderPaper.creme => const ReaderPalette(paper: AppColors.paperCream, text: AppColors.bookText, footer: AppColors.readerFooter),
    ReaderPaper.branco => const ReaderPalette(paper: AppColors.paperWhite, text: AppColors.ink, footer: AppColors.readerFooterWhite),
    ReaderPaper.sepia => const ReaderPalette(paper: AppColors.paperSepia, text: AppColors.bookTextSepia, footer: AppColors.readerFooterSepia),
    ReaderPaper.noite => const ReaderPalette(paper: AppColors.paperNight, text: AppColors.bookTextNight, footer: AppColors.readerFooterNight),
  };
}
```

`reader_insets.dart`:

```dart
// G11.1 — áreas do leitor com as áreas seguras do aparelho (D-112, como a D-02 da v1): no canvas (sem área
// segura) e num iPhone 390×844 (47/34) dá exatamente o arquivo: topo 92, base 82, rodapé 40.
import 'dart:math' as math;

import 'package:flutter/painting.dart';

@immutable
final class ReaderInsets {
  const ReaderInsets({required this.top, required this.bottom, required this.footerBottom});

  factory ReaderInsets.of(EdgeInsets viewPadding) => ReaderInsets(
    top: math.max(92, viewPadding.top + 45),
    bottom: math.max(82, viewPadding.bottom + 48),
    footerBottom: math.max(40, viewPadding.bottom + 6),
  );

  final double top;
  final double bottom;
  final double footerBottom;
}
```

- [ ] **Passo 4 — rodar o teste e a suíte do design system** (`test/design_system test/features/reader/presentation`) → verdes. Se um teste antigo contar as cores de `AppColors` ("só as cores do arquivo"), acrescentar as novas com a origem (prancha 19/26b/Anexo 01/D-110).
- [ ] **Passo 5 — commit:** `feat(leitor): cores dos 4 papéis, Figtree 800, estilo do rodapé e áreas do aparelho (G11.1, D-16, D-110, D-112)`.

### Tarefa 2: `brand` global guardado no aparelho (D-33)

**Arquivos:** `lib/core/preferences/brand_preference.dart`; `home_providers.dart`; `test/fixtures/overrides_do_mundo.dart`;
teste `test/core/preferences/brand_preference_test.dart`.

- [ ] **Passo 1 — teste que falha:**

```dart
void main() {
  test('KvBrandStore: grava e lê só as 4 opções; valor estranho = nada', () async {
    final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    addTearDown(db.close);
    final store = KvBrandStore(() async => db);
    expect(await store.load(), isNull);
    await store.save(AppColors.brandOptions[2]);
    expect(await store.load(), AppColors.brandOptions[2]);
    await KvDao(db).set(brandKey, 'FF000000');
    expect(await store.load(), isNull);
  });

  test('brandProvider: começa lavanda, carrega o guardado e grava a troca', () async {
    final store = MemoryBrandStore(AppColors.brandOptions[1]);
    final c = ProviderContainer(overrides: [brandStoreProvider.overrideWithValue(store)]);
    addTearDown(c.dispose);
    expect(c.read(brandProvider), AppColors.lavender);
    await pumpEventQueue();
    expect(c.read(brandProvider), AppColors.brandOptions[1]);
    await c.read(brandProvider.notifier).set(AppColors.brandOptions[3]);
    expect(store.value, AppColors.brandOptions[3]);
    expect(c.read(homeThemeProvider).brand, AppColors.brandOptions[3]);
  });
}
```

- [ ] **Passo 2 — rodar** → falha (não existe).
- [ ] **Passo 3 — implementar** `brand_preference.dart`:

```dart
// G11.1 — a cor `brand` é uma preferência global do app (D-33): Início, Leitor e tela 25. Guardada no `kv`
// do aparelho (Anexo 02 §3.3); só as 4 opções do arquivo (D-11).
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../data/database/daos/kv_dao.dart';
import '../data/database/local_database.dart';
import '../design_system/tokens/app_colors.dart';

const String brandKey = 'pref.brand';

abstract interface class BrandStore {
  Future<Color?> load();
  Future<void> save(Color c);
}

final class KvBrandStore implements BrandStore {
  KvBrandStore(this._db);
  final Future<AppDatabase> Function() _db;

  @override
  Future<Color?> load() async {
    final v = await KvDao(await _db()).get(brandKey);
    final n = v == null ? null : int.tryParse(v, radix: 16);
    if (n == null) return null;
    final c = Color(n);
    return AppColors.brandOptions.contains(c) ? c : null;
  }

  @override
  Future<void> save(Color c) async => KvDao(await _db()).set(
    brandKey,
    c.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0'),
  );
}

/// Só para testes e fixtures: guarda na memória.
final class MemoryBrandStore implements BrandStore {
  MemoryBrandStore([this.value]);
  Color? value;
  @override
  Future<Color?> load() async => value;
  @override
  Future<void> save(Color c) async => value = c;
}

final brandStoreProvider = Provider<BrandStore>(
  (ref) => KvBrandStore(() => ref.read(localDatabaseProvider.future)),
);

final brandProvider = NotifierProvider<BrandController, Color>(BrandController.new);

class BrandController extends Notifier<Color> {
  @override
  Color build() {
    _load();
    return AppColors.lavender;
  }

  Future<void> _load() async {
    try {
      final c = await ref.read(brandStoreProvider).load();
      if (c != null && ref.mounted) state = c;
    } on Object {
      // preferência é só conforto: sem ela, fica a lavanda do arquivo
    }
  }

  Future<void> set(Color c) async {
    assert(AppColors.brandOptions.contains(c));
    state = c;
    try {
      await ref.read(brandStoreProvider).save(c);
    } on Object {
      // vale para esta sessão; a próxima abertura volta ao guardado
    }
  }
}
```

`home_providers.dart` — o tema da Início passa a ler o `brand` global (o `weekColor` continua dele):

```dart
class HomeThemeController extends Notifier<HomeTheme> {
  Color _week = AppColors.lavender;

  @override
  HomeTheme build() => HomeTheme(brand: ref.watch(brandProvider), weekColor: _week);

  void setBrand(Color c) => ref.read(brandProvider.notifier).set(c);

  void setWeekColor(Color c) {
    assert(AppColors.weekColorOptions.contains(c));
    _week = c;
    state = HomeTheme(brand: state.brand, weekColor: c);
  }
}
```

`overrides_do_mundo.dart`: acrescentar `brandStoreProvider.overrideWithValue(MemoryBrandStore())` (os testes da
Início não abrem banco).

- [ ] **Passo 4 — rodar** `test/core/preferences test/home` → verdes (os testes de tema da Início continuam
  passando: `setBrand` troca na hora, pelo `state` do `brandProvider`).
- [ ] **Passo 5 — commit:** `feat(app): brand global guardado no aparelho (G11.1, D-33)`.

---

## G11.2 — Documento e sessão de leitura

### Tarefa 3: `DisplayPage` e `PageSnapshot` (pintar, texto, link no desenho das letras)

**Arquivos:** `display_page.dart`, `page_snapshot.dart`; teste `test/features/reader/layout/page_snapshot_test.dart`.

- [ ] **Passo 1 — teste que falha** (EPUB com link `<a href="c2.xhtml#n1">nota</a>` no meio de um parágrafo):

```dart
test('linkAt: toque no desenho do link acha o destino; ao lado, nada', () {
  final item = parse('<p>Antes do <a href="c2.xhtml#n1">link aqui</a> e depois.</p>');
  final blocks = BlockLayouter(t).layoutAll(item.blocks, item.blockStarts);
  final page = paginateChapter(blocks, t.contentHeight).first;
  final snap = PageSnapshot(spine: 0, page: page, blockOf: (b) => blocks[b], typography: t, item: item);
  final b = blocks.single as LaidText;
  final a = item.text.indexOf('link aqui');
  final (pa, pi) = b.toParagraph(a + 2);
  final box = b.pieces[pa].paragraph.getBoxesForRange(pi, pi + 1).single;
  final centro = Offset(t.sideMargin + b.left + (box.left + box.right) / 2, t.topInset + (box.top + box.bottom) / 2);
  expect(snap.linkAt(centro)?.target, 'OEBPS/c2.xhtml#n1');
  final antes = b.pieces[pa].paragraph.getBoxesForRange(0, 1).single;
  expect(snap.linkAt(Offset(t.sideMargin + b.left + antes.left + 1, centro.dy)), isNull);
  expect(snap.linkAt(Offset(centro.dx, t.topInset + 300)), isNull);
});

test('texto da página para o leitor de tela = o trecho canônico da página', () {
  final item = parse('<p>Primeiro.</p><p>Segundo.</p>');
  final blocks = BlockLayouter(t).layoutAll(item.blocks, item.blockStarts);
  final page = paginateChapter(blocks, t.contentHeight).first;
  final snap = PageSnapshot(spine: 0, page: page, blockOf: (b) => blocks[b], typography: t, item: item);
  expect(snap.spokenText, 'Primeiro.\nSegundo.');
});
```

(`parse` = `EpubBook.open(writeTemp(dir, 'l.epub', simpleEpub(chapters: [(file: 'c1.xhtml', title: 'I', body: corpo), (file: 'c2.xhtml', title: 'II', body: '<p id="n1">Nota.</p>')]))).parseItem(0)`; o prefixo do caminho no ZIP é o que o `simpleEpub` usa — conferir com `item.blocks` antes de fixar a string esperada.)

- [ ] **Passo 2 — rodar** → falha.
- [ ] **Passo 3 — implementar:**

`display_page.dart`:

```dart
// G11.2 — uma página pronta para a tela (EPUB ou PDF): a tela só pinta, lê o texto e pergunta por links.
import 'dart:ui' as ui;

/// Toque num link interno: [target] = `caminho#fragmento` (G09); [spine]/[offset] = onde estava o toque.
typedef LinkHit = ({String target, int spine, int offset});

enum PageDirection { forward, backward }

abstract interface class DisplayPage {
  /// Pinta o conteúdo da página (sem o papel e o rodapé). As coordenadas são as da tela.
  void paint(ui.Canvas canvas);

  /// O texto da página para o leitor de tela (Anexo 03 §11).
  String get spokenText;

  /// O link interno sob [p] (coordenadas da tela), conferido no retângulo das letras.
  LinkHit? linkAt(ui.Offset p);

  /// `false` quando o que a página usa já foi descartado (repaginação, capítulo fora): não pintar.
  bool get alive;
}
```

`page_snapshot.dart` (o laço de linhas é o mesmo do `paintTextLines`):

```dart
// G11.2 — página do EPUB pronta para a tela: pinta pelo motor da G10 (D-94), dá o texto da página e acha o link
// sob o dedo no desenho das letras (getBoxesForRange), não só a palavra mais próxima.
import 'dart:ui' as ui;

import '../content/content_blocks.dart';
import 'display_page.dart';
import 'laid_block.dart';
import 'page_painter.dart';
import 'paginator.dart';
import 'reader_typography.dart';

final class PageSnapshot implements DisplayPage {
  PageSnapshot({
    required this.spine,
    required this.page,
    required LaidBlock Function(int block) blockOf,
    required this.typography,
    required this.item,
    bool Function()? alive,
    this.imageOf,
  }) : _blockOf = blockOf,
       _alive = alive;

  final int spine;
  final ReaderPage page;
  final ReaderTypography typography;
  final ParsedItem item;
  final ReaderImageOf? imageOf;
  final LaidBlock Function(int) _blockOf;
  final bool Function()? _alive;

  @override
  bool get alive => _alive?.call() ?? true;

  @override
  void paint(ui.Canvas canvas) {
    if (!alive) return;
    paintReaderPage(canvas, page, _blockOf, typography, imageOf: imageOf);
  }

  @override
  String get spokenText {
    final end = page.end.clamp(page.start, item.text.length);
    return item.text.substring(page.start, end).replaceAll(objectChar, '').trim();
  }

  @override
  LinkHit? linkAt(ui.Offset p) {
    if (!alive) return null;
    final t = typography;
    for (final s in page.slices) {
      if (s is! TextSlice) continue;
      final b = _blockOf(s.block);
      if (b is! LaidText || b.source is! TextBlock) continue;
      final base = t.topInset + s.y - b.lines[s.firstLine].top;
      final x0 = t.sideMargin + b.left;
      for (var i = s.firstLine; i <= s.lastLine; i++) {
        final line = b.lines[i];
        final top = base + line.top;
        if (p.dy < top || p.dy >= top + line.height) continue;
        for (final (a, z, target) in _links(b)) {
          final from = a < line.start ? line.start : a;
          final to = z > line.end ? line.end : z;
          if (from >= to) continue;
          final (pa, pi) = b.toParagraph(from);
          final (pz, pj) = b.toParagraph(to);
          if (pa != pz) continue; // o link atravessa pedaços: cada linha está num pedaço só
          final dy = base + line.baseline - line.pieceBaseline;
          for (final box in b.pieces[pa].paragraph.getBoxesForRange(pi, pj)) {
            final r = ui.Rect.fromLTRB(x0 + box.left, top, x0 + box.right, top + line.height);
            if (r.contains(p)) return (target: target, spine: spine, offset: from);
          }
          assert(dy.isFinite);
        }
      }
    }
    return null;
  }

  /// Trechos com link do bloco, em offsets canônicos: (início, fim, destino).
  static Iterable<(int, int, String)> _links(LaidText b) sync* {
    var at = b.start;
    for (final r in (b.source as TextBlock).runs) {
      final end = at + r.text.length;
      if (r.link case final l?) yield (at, end, l);
      at = end;
    }
  }
}
```

- [ ] **Passo 4 — rodar** → verde. Conferir a premissa de que os `runs` somados dão o texto do bloco no texto
  canônico (se o leitor de XHTML colapsar espaços entre runs, o teste do link pega).
- [ ] **Passo 5 — commit:** `feat(leitor): página pronta para a tela com texto e link no desenho das letras (G11.2)`.

### Tarefa 4: `BookPager.current` e `peek` (vizinha sem virar)

**Arquivos:** `book_pager.dart`; teste em `test/features/reader/application/book_pager_test.dart` (grupo novo).

- [ ] **Passo 1 — testes que falham** (no Dom Casmurro real, como os da G10):

```dart
group('vizinha sem virar (G11.2)', () {
  test('peek(forward) = a página que next() mostra; nada muda até virar', () async {
    final pager = abrir(); // helper do arquivo: BookPager do Dom Casmurro com LayoutScheduler()
    await pager.openAt(capI, 0);
    final antes = pager.current!;
    final vizinha = (await pager.peek(PageDirection.forward))!;
    expect(pager.current!.page.start, antes.page.start);
    expect(await pager.next(), isTrue);
    expect(pager.current!.page.start, vizinha.page.start);
    expect(pager.current!.spine, vizinha.spine);
  });

  test('peek atravessa capítulos e devolve null no começo e no fim do livro', () async {
    final pager = abrir();
    await pager.openAt(pager.firstSpine, 0);
    expect(await pager.peek(PageDirection.backward), isNull);
    // última página de um capítulo → a 1ª do seguinte
    final ch = await pager.settle();
    await pager.openAt(capI, ch!.pages.last.start);
    final prox = (await pager.peek(PageDirection.forward))!;
    expect(prox.spine, greaterThan(capI));
    expect(prox.page.start, 0);
  });

  test('a página vista deixa de valer quando os ajustes mudam', () async {
    final pager = abrir();
    await pager.openAt(capI, 0);
    final vizinha = (await pager.peek(PageDirection.forward))!;
    expect(vizinha.alive, isTrue);
    await pager.relayout(const ReaderTypography(fontSize: 26));
    expect(vizinha.alive, isFalse);
  });
});
```

- [ ] **Passo 2 — rodar** → falha.
- [ ] **Passo 3 — implementar** em `book_pager.dart`:

```dart
  /// A página mostrada, pronta para a tela (substitui o `paintCurrent`).  (PageDirection vem de display_page.dart)
  PageSnapshot? get current {
    final s = _shown;
    return s == null ? null : _snapshot(s.pos.spine, s.pos.page, s.pos.pageIndex, s.ch, s.t);
  }

  /// A página vizinha **sem virar** (para pintar a página que vem atrás do dedo). `null` = começo/fim do livro,
  /// ou uma abertura mais nova passou na frente.
  Future<PageSnapshot?> peek(PageDirection d) async {
    if (_disposed) return null;
    final open = _pendingOpen;
    if (open != null) {
      try {
        await open;
      } on Object {
        return null;
      }
    }
    await _turning;
    final gen = _gen;
    final pos = await _settled(gen);
    if (pos == null || gen != _gen) return null;
    final ch = _shown!.ch;
    final i = pos.pageIndex!;
    if (d == PageDirection.backward) {
      if (i > 0) return _snapshot(pos.spine, ch.pages[i - 1], i - 1, ch, _t);
      return _peekCross(pos.spine, -1, gen);
    }
    final job = ch.job;
    if (job == null) return null;
    await _scheduler.waitFor(
      () => gen != _gen || job.done || ch.error != null || job.pagesSoFar.length > i + 1,
    );
    if (gen != _gen) return null;
    if (job.pagesSoFar.length > i + 1) {
      return _snapshot(pos.spine, job.pagesSoFar[i + 1], i + 1, ch, _t);
    }
    if (!job.done) return null;
    return _peekCross(pos.spine, 1, gen);
  }

  Future<PageSnapshot?> _peekCross(int from, int step, int gen) async {
    var s = from;
    while (true) {
      final n = _neighbor(s, step);
      if (n == null) return null;
      final _Chapter nc;
      try {
        nc = await _chapter(n);
      } on Object {
        return null; // o erro aparece quando a pessoa virar de verdade
      }
      if (gen != _gen) return null;
      final job = _ensureJob(nc, step > 0 ? _nextPriority : _previousPriority);
      if (step > 0) {
        await _scheduler.waitFor(
          () => gen != _gen || job.done || nc.error != null || job.pagesSoFar.isNotEmpty,
        );
        if (gen != _gen) return null;
        if (job.pagesSoFar.isNotEmpty) return _snapshot(n, job.pagesSoFar.first, 0, nc, _t);
      } else {
        final ChapterLayout layout;
        try {
          layout = await _scheduler.run(job, priority: _previousPriority, urgent: true);
        } on LayoutCancelled {
          return null;
        }
        if (gen != _gen) return null;
        if (layout.pages.isNotEmpty) {
          return _snapshot(n, layout.pages.last, layout.pages.length - 1, nc, _t);
        }
      }
      if (nc.error != null) return null;
      s = n;
    }
  }

  PageSnapshot _snapshot(int spine, ReaderPage page, int? pageIndex, _Chapter ch, ReaderTypography t) {
    final q = ch.quick;
    final job = ch.job;
    final layoutGen = _layoutGen;
    return PageSnapshot(
      spine: spine,
      page: page,
      typography: t,
      item: ch.content.item,
      blockOf: (b) => pageIndex == null && q != null ? q.blocks[b - q.firstBlock] : job!.blocksSoFar[b],
      alive: () =>
          !_disposed &&
          (identical(_chapters[spine], ch) || _retired.contains(ch)) &&
          (layoutGen == _layoutGen || identical(_shown?.ch, ch)),
    );
  }
```

Trocar os usos de `paintCurrent` (testes e capturas da G10) por `pager.current!.paint(c)` e apagar o
`paintCurrent`. As prioridades `_nextPriority`/`_previousPriority` já existem.

- [ ] **Passo 4 — rodar** `test/features/reader` → verde (os testes de concorrência da G10 continuam).
- [ ] **Passo 5 — commit:** `feat(leitor): página atual e vizinha sem virar no livro aberto (G11.2)`.

### Tarefa 5: `ReaderDocument` e o documento EPUB (abrir, virar, números)

**Arquivos:** `reader_document.dart`, `epub_reader_document.dart`; teste `test/features/reader/application/epub_reader_document_test.dart`.

- [ ] **Passo 1 — testes que falham:**

```dart
test('abre na posição guardada; números pela 1ª letra visível; virar avisa a posição e o tempo', () async {
  final h = await DocHarness.domCasmurro(); // banco em memória + EPUB real + índice + posição no cap. XXXII
  final doc = await EpubReaderDocument.open(h.deps);
  expect(doc.title, 'Dom Casmurro');
  final n0 = doc.numbers;
  expect(n0.refPage, h.numerosEsperados.refPage);
  expect(n0.pageLabel, 'pág. ${n0.refPage} de ${n0.refTotal}');
  final shown = <(int, int)>[];
  doc.pageShown.listen((r) => shown.add((r.fromRef, r.toRef)));
  expect(await doc.turn(PageDirection.forward), isTrue);
  await pumpEventQueue();
  expect(shown, isNotEmpty);
  await doc.flush();
  final pos = await ReadingPositionsDao(h.db).forBook(h.userBookId);
  expect((pos!.locator as EpubLocator).offset, doc.mark.offset);
});

test('turn no fim do livro = false e nada muda', () async { /* abrir na última página; turn(forward) == false */ });
```

(`DocHarness` em `test/features/reader/application/reader_harness.dart`: cria `AppDatabase(NativeDatabase.memory(), withSyncQueue: false)`, `LocalVersioning`, grava `UserBook` + `local_files` + índice (`indexEpubFile`) do `test/fixtures/livros/pg55752.epub` e uma posição; monta `EpubDocumentDeps`.)

- [ ] **Passo 2 — rodar** → falha.
- [ ] **Passo 3 — implementar:**

`reader_document.dart`:

```dart
// G11.2 — o que a tela precisa de um livro aberto, igual para EPUB e PDF (desenho G11 §2).
import '../layout/display_page.dart';
import '../domain/reader_numbers.dart';

export '../layout/display_page.dart';

/// "pág. 159 de 256" e "62%" (D-19/D-89).
final class ReaderNumbersView {
  const ReaderNumbersView({required this.refPage, required this.refTotal, required this.progression});
  final int refPage;
  final int refTotal;
  final double progression;
  String get pageLabel => 'pág. $refPage de $refTotal';
  String get percentLabel => percentOf(progression);
}

/// Onde a pessoa está (para a volta do link): [spine]/[offset] no EPUB; no PDF, spine 0 e offset = página.
typedef ReaderMark = ({int spine, int offset});

/// Páginas de referência que a página mostrada cobre (tempo: "páginas lidas" — D-95).
typedef RefRange = ({int fromRef, int toRef});

abstract interface class ReaderDocument {
  String get title;
  DisplayPage get current;
  ReaderNumbersView get numbers;
  ReaderMark get mark;
  Stream<RefRange> get pageShown;
  Future<DisplayPage?> peek(PageDirection d);
  Future<bool> turn(PageDirection d);
  Future<bool> follow(LinkHit link);
  Future<void> goTo(ReaderMark m);
  Future<void> flush();
  void dispose();
}
```

`epub_reader_document.dart` — pontos-chave:

```dart
final class EpubDocumentDeps {
  const EpubDocumentDeps({
    required this.book, required this.index, required this.path, required this.typography,
    required this.scheduler, required this.keeper, this.cache, this.loader,
  });
  final UserBook book;
  final BookIndex index;
  final String path;
  final ReaderTypography typography;
  final LayoutScheduler scheduler;
  final ReadingPositionKeeper keeper;
  final PagerCacheKey? cache;
  final ChapterLoader? loader; // testes: carregar sem isolate
}

final class EpubReaderDocument implements ReaderDocument {
  EpubReaderDocument._(this._deps, this._pager);

  static Future<EpubReaderDocument> open(EpubDocumentDeps d) async {
    final pager = BookPager(
      index: d.index,
      load: d.loader ?? isolateChapterLoader(d.path),
      typography: d.typography,
      scheduler: d.scheduler,
      cache: d.cache,
    );
    final doc = EpubReaderDocument._(d, pager);
    try {
      await reopen(pager, d.keeper);
    } on Object {
      pager.dispose();
      rethrow;
    }
    doc._announce();
    return doc;
  }

  final EpubDocumentDeps _deps;
  final BookPager _pager;
  final _shown = StreamController<RefRange>.broadcast();

  @override
  String get title => _deps.book.title;

  @override
  DisplayPage get current => _pager.current!;

  @override
  ReaderNumbersView get numbers {
    final p = _pager.position!;
    final n = numbersAt(_deps.index, p.spine, p.firstVisible);
    return ReaderNumbersView(refPage: n.refPage, refTotal: n.refTotal, progression: n.progression);
  }

  @override
  ReaderMark get mark {
    final p = _pager.position!;
    return (spine: p.spine, offset: p.firstVisible);
  }

  @override
  Stream<RefRange> get pageShown => _shown.stream;

  @override
  Future<DisplayPage?> peek(PageDirection d) => _pager.peek(d);

  @override
  Future<bool> turn(PageDirection d) async {
    final ok = d == PageDirection.forward ? await _pager.next() : await _pager.previous();
    if (ok) _announce();
    return ok;
  }

  @override
  Future<void> goTo(ReaderMark m) async {
    await _pager.openAt(m.spine, m.offset);
    _announce();
  }

  @override
  Future<bool> follow(LinkHit link) async {
    final to = await resolveEpubLink(_deps.index, link.target, _pager.content);
    if (to == null) return false;
    await goTo(to);
    return true;
  }

  @override
  Future<void> flush() => _deps.keeper.flush();

  @override
  void dispose() {
    _deps.keeper.dispose();
    _pager.dispose();
    unawaited(_shown.close());
  }

  void _announce() {
    final p = _pager.position!;
    final text = _pager.contentOf(p.spine)?.item.text ?? '';
    _deps.keeper.pageShown(p.spine, p.firstVisible, text);
    final last = p.page.end > p.page.start ? p.page.end - 1 : p.page.start;
    _shown.add((
      fromRef: numbersAt(_deps.index, p.spine, p.firstVisible).refPage,
      toRef: numbersAt(_deps.index, p.spine, last).refPage,
    ));
  }
}
```

- [ ] **Passo 4 — rodar** → verde.
- [ ] **Passo 5 — commit:** `feat(leitor): documento EPUB aberto na posição, com números e virada (G11.2)`.

### Tarefa 6: links internos do EPUB

**Arquivos:** `epub_reader_document.dart` (função `resolveEpubLink`); teste no mesmo arquivo de teste.

- [ ] **Passo 1 — testes que falham:**

```dart
test('resolveEpubLink: caminho do spine + fragmento → (item, caractere); sem fragmento → começo; desconhecido → null', () async {
  final index = BookIndex(contentSha256: 's', layout: 'reflowable',
    spine: const [SpineInfo(path: 'OEBPS/a.xhtml', linear: true, chars: 10), SpineInfo(path: 'OEBPS/n.xhtml', linear: false, chars: 50)],
    toc: const [], refPages: RefPageMap.synthetic(const [0]));
  Future<ChapterContent> conteudo(int s) async => ChapterContent(spineIndex: s,
    item: ParsedItem(blocks: const [], text: 'x' * 50, blockStarts: const [], idOffsets: const {'n7': 31}), imageSizes: const {});
  expect(await resolveEpubLink(index, 'OEBPS/n.xhtml#n7', conteudo), (spine: 1, offset: 31));
  expect(await resolveEpubLink(index, 'OEBPS/n.xhtml', conteudo), (spine: 1, offset: 0));
  expect(await resolveEpubLink(index, 'OEBPS/n.xhtml#sumiu', conteudo), (spine: 1, offset: 0));
  expect(await resolveEpubLink(index, 'OEBPS/fora.xhtml#x', conteudo), isNull);
});

test('Dom Casmurro real: o "Indice" da folha de rosto leva ao índice no fim', () async {
  final h = await DocHarness.domCasmurro(posicao: (spine: h.rosto, offset: 0));
  final doc = await EpubReaderDocument.open(h.deps);
  final hit = h.linkDoIndice(doc.current); // acha o retângulo do "Indice" pela página e toca no centro
  expect(await doc.follow(hit!), isTrue);
  expect(doc.mark.spine, greaterThan(h.ultimoCapitulo));
});
```

- [ ] **Passo 2 — rodar** → falha.
- [ ] **Passo 3 — implementar:**

```dart
/// Destino de um link interno `caminho#fragmento` (G09): o item do spine com esse caminho e o caractere do
/// `id` (sem `id` conhecido, o começo do item). `null` = o caminho não está no livro.
Future<ReaderMark?> resolveEpubLink(
  BookIndex index,
  String target,
  Future<ChapterContent> Function(int spine) content,
) async {
  final hash = target.indexOf('#');
  final path = hash < 0 ? target : target.substring(0, hash);
  final frag = hash < 0 ? null : target.substring(hash + 1);
  final spine = index.spine.indexWhere((s) => s.path == path);
  if (spine < 0) return null;
  if (frag == null || frag.isEmpty) return (spine: spine, offset: 0);
  final c = await content(spine);
  return (spine: spine, offset: c.item.idOffsets[frag] ?? 0);
}
```

- [ ] **Passo 4 — rodar** → verde. **Passo 5 — commit:** `feat(leitor): links internos do livro levam ao destino (G11.2, D-108)`.

### Tarefa 7: tela acesa (D-111) e dependência `wakelock_plus`

**Arquivos:** `pubspec.yaml`, `screen_awake.dart`, `docs/adr/` (linha da dependência); teste `test/features/reader/application/screen_awake_test.dart`.

- [ ] **Passo 1:** conferir no pub.dev a versão estável de `wakelock_plus` compatível com Flutter 3.47.2 e
  acrescentar com versão fixa (como `pdfrx: 2.6.5`); `flutter pub get` pelo `ciclo.ps1`.
- [ ] **Passo 2 — teste que falha** (`KeepAwake` com relógio controlado — `fakeAsync`):

```dart
test('liga na interação, desliga 120 s depois da última, e ao parar', () {
  fakeAsync((fa) {
    final s = RecordingScreenAwake();
    final k = KeepAwake(s);
    k.touch();
    expect(s.log, ['on']);
    fa.elapse(const Duration(seconds: 100));
    k.touch();
    fa.elapse(const Duration(seconds: 119));
    expect(s.log, ['on']);
    fa.elapse(const Duration(seconds: 1));
    expect(s.log, ['on', 'off']);
    k.touch();
    k.stop();
    expect(s.log, ['on', 'off', 'on', 'off']);
  });
});
```

- [ ] **Passo 3 — implementar:**

```dart
// G11.2 — tela acesa enquanto se lê (D-111): liga a cada interação e desliga [readingIdleLimit] depois da
// última (a mesma regra do tempo automático, D-95), em segundo plano e ao sair.
abstract interface class ScreenAwake {
  Future<void> enable();
  Future<void> disable();
}

final class WakelockScreenAwake implements ScreenAwake {
  const WakelockScreenAwake();
  @override
  Future<void> enable() => WakelockPlus.enable();
  @override
  Future<void> disable() => WakelockPlus.disable();
}

final class KeepAwake {
  KeepAwake(this._screen, {this.idle = readingIdleLimit, ReaderErrorReporter onError = reportReaderError})
    : _onError = onError;
  final ScreenAwake _screen;
  final Duration idle;
  final ReaderErrorReporter _onError;
  Timer? _timer;
  bool _on = false;

  void touch() {
    _timer?.cancel();
    _timer = Timer(idle, stop);
    if (!_on) {
      _on = true;
      _call(_screen.enable);
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    if (_on) {
      _on = false;
      _call(_screen.disable);
    }
  }

  void _call(Future<void> Function() f) => unawaited(f().catchError((Object e, StackTrace st) => _onError(e, st)));
}
```

`RecordingScreenAwake` (em `test/support/fake_reader.dart`) guarda `'on'`/`'off'` numa lista.
Linha no ADR do leitor (ADR-005): "`wakelock_plus` — manter a tela acesa durante a leitura (D-111)".

- [ ] **Passo 4 — rodar** → verde. **Passo 5 — commit:** `feat(leitor): tela acesa enquanto se lê (G11.2, D-111)`.

### Tarefa 8: `ReaderSessionController` — abrir e falhas

**Arquivos:** `reader_session_controller.dart`, `reader_providers.dart`; teste `test/features/reader/application/reader_session_controller_test.dart`.

- [ ] **Passo 1 — testes que falham** (uma linha por falha + o caminho feliz):

```dart
test('abre: Opening → Ready com o documento e os números', () async {
  final h = await SessionHarness.domCasmurro();
  final c = h.controller();
  final states = <ReaderState>[];
  c.addListener(() => states.add(c.state));
  await c.open(h.viewport);
  expect(states.first, isA<ReaderOpening>());
  expect(c.state, isA<ReaderReady>());
});

for (final (nome, preparar, falha) in [
  ('id desconhecido', (SessionHarness h) => h.apagarLivro(), ReaderFailure.notOnShelf),
  ('livro de outra conta', (SessionHarness h) => h.trocarDono(), ReaderFailure.notOnShelf),
  ('arquivo fora do aparelho', (SessionHarness h) => h.apagarArquivo(), ReaderFailure.fileMissing),
  ('arquivo danificado', (SessionHarness h) => h.estragarArquivo(), ReaderFailure.damaged),
  ('páginas fixas (D-92)', (SessionHarness h) => h.marcarPaginasFixas(), ReaderFailure.fixedLayout),
]) {
  test('falha: $nome', () async {
    final h = await SessionHarness.domCasmurro();
    await preparar(h);
    final c = h.controller();
    await c.open(h.viewport);
    expect((c.state as ReaderFailed).failure, falha);
  });
}

test('sem índice: "Preparando o livro…" e indexa ao abrir', () async {
  final h = await SessionHarness.domCasmurro(semIndice: true);
  final c = h.controller();
  final preparing = <bool>[];
  c.addListener(() { if (c.state case ReaderOpening(:final preparing)) preparing.add(preparing); });
  await c.open(h.viewport);
  expect(preparing, contains(true));
  expect(h.indexados, [h.userBookId]);
  expect(c.state, isA<ReaderReady>());
});

test('falha inesperada: reportada uma vez e "Tentar de novo" reabre', () async { /* deps.indexBook lança StateError; retry() com o índice ok → Ready */ });
```

- [ ] **Passo 2 — rodar** → falha.
- [ ] **Passo 3 — implementar** (núcleo):

```dart
enum ReaderFailure { notOnShelf, fileMissing, damaged, fixedLayout, unexpected }

sealed class ReaderState { const ReaderState(); }
final class ReaderOpening extends ReaderState { const ReaderOpening({this.preparing = false}); final bool preparing; }
final class ReaderReady extends ReaderState {
  const ReaderReady(this.document, {this.back});
  final ReaderDocument document;
  final BackLink? back;
}
final class ReaderFailed extends ReaderState { const ReaderFailed(this.failure); final ReaderFailure failure; }

/// Volta de um link (D-108): de onde se saiu e a pág. dela.
typedef BackLink = ({ReaderMark mark, int refPage});

/// Tamanho da tela e áreas seguras: a tipografia sai daqui + ajustes + paleta.
typedef ReaderViewport = ({double width, double height, EdgeInsets padding, double devicePixelRatio});

final class ReaderDeps {
  const ReaderDeps({
    required this.db, required this.versioning, required this.owner, required this.booksDir,
    required this.indexBook, required this.scheduler, required this.screenAwake, this.deviceId,
    this.now = DateTime.now, this.elapsed, this.chapterLoader, this.onError = reportReaderError,
  });
  final AppDatabase db;
  final LocalVersioning versioning;
  final Future<String> Function() owner;
  final Future<Directory> Function() booksDir;
  final Future<bool> Function(String userBookId) indexBook;
  final LayoutScheduler scheduler;
  final ScreenAwake screenAwake;
  final String? deviceId;
  final DateTime Function() now;
  final Duration Function()? elapsed;
  final ChapterLoader Function(String path)? chapterLoader;
  final ReaderErrorReporter onError;
}

class ReaderSessionController extends ChangeNotifier {
  ReaderSessionController({required this.userBookId, required this.deps});
  final String userBookId;
  final ReaderDeps deps;
  ReaderState _state = const ReaderOpening();
  ReaderState get state => _state;
  ReaderPalette palette = ReaderPalette.of(ReaderPaper.creme);

  Future<void> open(ReaderViewport v) async {
    _set(const ReaderOpening());
    try {
      final owner = await deps.owner();
      final book = await UserBooksDao(deps.db).byId(userBookId);
      if (book == null || book.meta.isDeleted || book.meta.userId != owner) return _fail(ReaderFailure.notOnShelf);
      final file = await LocalFilesDao(deps.db).byBook(userBookId);
      final path = file == null ? null : await _existing(file.path);
      if (path == null || book.format == BookFileFormat.physical) return _fail(ReaderFailure.fileMissing);
      final settings = await ReaderSettingsDao(deps.db).forUser(owner);
      palette = ReaderPalette.of(settings?.paper ?? ReaderPaper.creme);
      final doc = book.format == BookFileFormat.pdf
          ? await _openPdf(book, path, v)
          : await _openEpub(book, path, file!.sha256, settings, owner, v);
      if (doc == null) return; // _fail já foi chamado
      _attach(doc, owner);
      _set(ReaderReady(doc));
    } on ContentFailure catch (_) {
      _fail(ReaderFailure.damaged);
    } on Object catch (e, st) {
      deps.onError(e, st);
      _fail(ReaderFailure.unexpected);
    }
  }
  // _openEpub: índice (BookContentIndexDao.byBook) velho/ausente → _set(ReaderOpening(preparing: true)),
  //   deps.indexBook(id), relê; ainda sem índice → damaged; index.layout == 'fixed' → fixedLayout;
  //   tipografia = ReaderTypography.fromSettings(settings ?? padrão, viewportWidth: v.width, viewportHeight: v.height,
  //   topInset: insets.top, bottomInset: insets.bottom, ink: palette.text); EpubReaderDocument.open(...).
  // _existing: o caminho guardado ou o mesmo nome na pasta dos livros de agora (como o BookImporter._localPath).
}
```

`reader_providers.dart`:

```dart
final layoutSchedulerProvider = Provider<LayoutScheduler>((ref) => LayoutScheduler());
final screenAwakeProvider = Provider<ScreenAwake>((ref) => const WakelockScreenAwake());
final readerSystemUiProvider = Provider<ReaderSystemUi>((ref) => const PlatformReaderSystemUi());
final readerDepsProvider = FutureProvider<ReaderDeps>((ref) async {
  final db = await ref.watch(localDatabaseProvider.future);
  final library = await ref.watch(localLibraryProvider.future);
  final versioning = await ref.watch(localVersioningProvider.future);
  return ReaderDeps(
    db: db,
    versioning: versioning,
    owner: library.activeOwnerId,
    booksDir: ref.watch(booksDirProvider),
    indexBook: (id) async => (await ref.read(bookImporterProvider.future)).indexBook(id),
    scheduler: ref.watch(layoutSchedulerProvider),
    screenAwake: ref.watch(screenAwakeProvider),
    deviceId: await KvDao(db).get(deviceIdKey),
    now: ref.watch(clockProvider),
  );
});
```

- [ ] **Passo 4 — rodar** → verde. **Passo 5 — commit:** `feat(leitor): sessão de leitura abre o livro da estante com as falhas da D-21 (G11.2)`.

### Tarefa 9: tempo, posição e tela acesa ligados à sessão

**Arquivos:** `reader_session_controller.dart`; testes no mesmo arquivo.

- [ ] **Passo 1 — testes que falham** (relógio monótono falso no `ReadingSessionTracker`, `RecordingScreenAwake`):

```dart
test('pronto e visível: o tempo conta; interação liga a tela; segundo plano pausa, grava e desliga', () async {
  final h = await SessionHarness.domCasmurro();
  final c = h.controller();
  await c.open(h.viewport);
  c.setVisible(true);
  c.interaction();
  expect(h.awake.log, ['on']);
  h.passa(const Duration(seconds: 30));
  await c.lifecycle(AppLifecycleState.paused);
  expect(h.awake.log, ['on', 'off']);
  expect(await h.posicaoGravada(), isNotNull);
  await c.lifecycle(AppLifecycleState.resumed);
  await c.close();
  expect(await h.segundosDeHoje(), 30);
});

test('virar: páginas de referência chegam ao tempo (≥ 3 s)', () async { /* turn; passa 3 s; turn; close → pagesRead ≥ 1 */ });
```

- [ ] **Passo 2 — rodar** → falha.
- [ ] **Passo 3 — implementar** em `_attach(doc, owner)`:

```dart
    _tracker = ReadingSessionTracker(
      db: deps.db, versioning: deps.versioning, owner: deps.owner, userBookId: userBookId,
      deviceId: deps.deviceId, now: deps.now, elapsed: deps.elapsed, onError: deps.onError,
    );
    _awake = KeepAwake(deps.screenAwake, onError: deps.onError);
    _pages = doc.pageShown.listen((r) => unawaited(_tracker!.pageShown(r.fromRef, r.toRef)));
```

e os métodos públicos:

```dart
  void setVisible(bool v) => unawaited(_tracker?.setVisible(v));
  void interaction() { unawaited(_tracker?.interaction()); _awake?.touch(); }
  Future<void> lifecycle(AppLifecycleState s) async {
    final fg = s == AppLifecycleState.resumed;
    await _tracker?.setForeground(fg);
    if (!fg) { _awake?.stop(); await _document?.flush(); }
  }
  Future<void> close() async {
    _awake?.stop();
    await _document?.flush();
    await _tracker?.close();
  }
  @override
  void dispose() { _pages?.cancel(); _tracker?.dispose(); _document?.dispose(); super.dispose(); }
```

- [ ] **Passo 4 — rodar** → verde. **Passo 5 — commit:** `feat(leitor): tempo automático, posição e tela acesa ligados à sessão (G11.2, D-95, D-111)`.

### Tarefa 10: virar, seguir link e voltar (D-108) no controlador

- [ ] **Passo 1 — testes que falham** (`fakeAsync` para os 6 s):

```dart
test('link: vai, guarda a volta com a pág. de onde saiu; some em 6 s ou em 2 viradas; voltar = caractere exato', () async {
  final h = await SessionHarness.domCasmurro(posicao: rosto);
  final c = h.controller();
  await c.open(h.viewport);
  final origem = (c.state as ReaderReady).document.mark;
  final pagOrigem = (c.state as ReaderReady).document.numbers.refPage;
  expect(await c.follow(h.hitDoIndice(c)), isTrue);
  expect((c.state as ReaderReady).back, (mark: origem, refPage: pagOrigem));
  await c.turn(PageDirection.forward);
  expect((c.state as ReaderReady).back, isNotNull);
  await c.turn(PageDirection.forward);
  expect((c.state as ReaderReady).back, isNull);
  // de novo, e voltar
  await c.goTo(origem);
  await c.follow(h.hitDoIndice(c));
  await c.back();
  expect((c.state as ReaderReady).document.mark, origem);
  expect((c.state as ReaderReady).back, isNull);
});
```

(teste separado com `fakeAsync`: a volta some depois de 6 s.)

- [ ] **Passo 3 — implementar:** `turn(dir)` (chama `document.turn`, conta as viradas da volta, `interaction()`),
  `follow(hit)` (guarda `(mark, numbers.refPage)`, `document.follow`, `Timer(6 s)`), `back()`, `goTo(mark)`;
  cada mudança chama `notifyListeners()` com `ReaderReady(doc, back: _back)`.
- [ ] **Passo 4 — rodar** → verde. **Passo 5 — commit:** `feat(leitor): volta do link por 6 s ou 2 viradas (G11.2, D-108)`.

---

## G11.3 — Tela 19

### Tarefa 11: rota, página e rodapé (estado pronto, sem gestos)

**Arquivos:** `reader_screen.dart`, `reader_footer.dart`, `router.dart`; teste `test/features/reader/presentation/reader_screen_test.dart`.

- [ ] **Passo 1 — testes que falham:**

```dart
testWidgets('rota /leitor/:id abre a tela 19 com página e rodapé nos lugares do arquivo', (tester) async {
  setCanvasView(tester, logical: const Size(390, 844));
  final h = await tester.runAsync(SessionHarness.tela19);
  await pumpReader(tester, h); // ProviderScope com readerDepsProvider → h.deps; App.forTests em /leitor/<id>
  await settleReader(tester);  // runAsync para o isolate/agenda + pump
  expect(tester.getRect(find.byKey(const ValueKey('r19.page'))), const Rect.fromLTWH(28, 92, 334, 670));
  expect(tester.getRect(find.byKey(const ValueKey('r19.footer'))), rectCloseTo(const Rect.fromLTWH(28, 790.19, 334, 13.81), 0.5));
  expect(find.text('pág. 159 de 256'), findsOneWidget);
  expect(find.text('62%'), findsOneWidget);
});
```

- [ ] **Passo 3 — implementar:**
  - `router.dart`: trocar `fullScreen('/leitor/:bookId', 'Leitor')` por
    `GoRoute(path: '/leitor/:bookId', parentNavigatorKey: rootNavigatorKey, pageBuilder: (c, s) => _page(s, ReaderScreen(bookId: s.pathParameters['bookId']!)))`;
  - `ReaderScreen` (`ConsumerStatefulWidget`): no 1º `didChangeDependencies`, lê `MediaQuery` (tamanho, `viewPadding`, dpr), espera `readerDepsProvider`, cria o controlador e chama `open`; `build` = `ColoredBox(palette.paper)` + `Stack` com `ReaderPageView` (tarefa 12; por ora `CustomPaint` com `document.current.paint`), `Positioned(left: margem, top: insets.top, width: contentWidth, height: contentHeight, child: Semantics(... , child: SizedBox(key: ValueKey('r19.page'))))`, e `ReaderFooter`;
  - `ReaderFooter`: `Positioned(left: 28, right: 28, bottom: insets.footerBottom)` com `Row(spaceBetween)` de dois `Text` (`r19.footer.pageLabel`, `r19.footer.percent`) no `AppTextStyles.readerFooter.copyWith(color: palette.footer)`, `ExcludeSemantics`.
- [ ] **Passo 4 — rodar** → verde. **Passo 5 — commit:** `feat(leitor): rota real e tela 19 com página e rodapé (G11.3)`.

### Tarefa 12: gestos e carrossel (D-107, D-113)

**Arquivo:** `reader_page_view.dart`; teste `test/features/reader/presentation/reader_page_view_test.dart` (com um `FakeDocument` de páginas numeradas que pinta um retângulo com o número).

- [ ] **Passo 1 — testes que falham:**

```dart
testWidgets('toque no terço direito avança, esquerdo volta, centro chama onCenter', ...);
testWidgets('arrasto < 1/4 e lento volta; ≥ 1/4 completa; rápido (≥ 300 px/s) completa mesmo curto', ...);
testWidgets('animação de 220 ms easeOutCubic: na metade do tempo a página andou easeOutCubic(0,5) da distância', (tester) async {
  // tap à direita; pump(110 ms); o deslocamento pintado = -390 × Curves.easeOutCubic.transform(0.5) (±0,5)
});
testWidgets('batente: no fim do livro a página anda 1/3 do dedo e volta; turn não é chamado', ...);
testWidgets('vizinha atrasada: completa com o papel e a página aparece quando chega', ...);
testWidgets('toque num link chama onLink e não vira', ...);
```

- [ ] **Passo 3 — implementar:** `ReaderPageView({required ReaderDocument document, required ReaderPalette palette, required VoidCallback onCenter, required ValueChanged<LinkHit> onLink, required Future<bool> Function(PageDirection) onTurn, required VoidCallback onInteraction})`:
  - `GestureDetector(onTapUp, onHorizontalDragStart/Update/End)`;
  - estado `_dx`, `_neighbor` (`DisplayPage?`), `_dir`, `_edge` (batente);
  - no começo do arrasto (ou no toque nos terços), `document.peek(dir)` → `_neighbor` (null = batente);
  - `AnimationController(duration: 220 ms)` + `CurvedAnimation(Curves.easeOutCubic)` de `_dx` ao alvo (`0` ou `∓largura`);
  - ao completar: `await onTurn(dir)`, depois `_dx = 0`, `_neighbor = null`;
  - `CustomPaint(painter: _PagesPainter(current, neighbor, dx, width))`: `canvas.save(); translate(dx, 0); current.paint(c); restore();` e a vizinha em `dx ± largura`;
  - limites: `threshold = width / 4`, `flingVelocity = 300`, `edgeFactor = 1/3` como constantes públicas (`readerTurnThreshold` etc.) para os testes.
- [ ] **Passo 4 — rodar** → verde. **Passo 5 — commit:** `feat(leitor): virar página por toque e arrasto em carrossel (G11.3, D-107)`.

### Tarefa 13: fechar provisório (D-106) e pílula de voltar (D-108)

**Arquivo:** `reader_overlays.dart`; testes em `reader_screen_test.dart`.

- [ ] **Passo 1 — testes que falham:** toque no centro mostra `Key('r19.close')` em (23,5, 63, 44×44) com rótulo
  "Fechar o livro"; some com outro toque e depois de 4 s; tocar fecha (rota sai e a posição foi gravada); depois
  de um link, a pílula "Voltar à pág. N" aparece entre o rótulo e a % e some depois de 6 s.
- [ ] **Passo 3 — implementar:**

```dart
class ReaderCloseButton extends StatelessWidget {
  const ReaderCloseButton({super.key, required this.visible, required this.onTap});
  final bool visible;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Positioned(
    left: 23.5, top: 63,
    child: IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        child: CircleIconButton(
          key: const ValueKey('r19.close'),
          size: 44,
          color: AppColors.paper,
          border: const BorderSide(color: AppColors.ink, width: 1.5),
          icon: const AppSvg(AppIcons.arrowLeft, size: 20),
          semanticsLabel: 'Fechar o livro',
          onTap: onTap,
        ),
      ),
    ),
  );
}

class BackToPagePill extends StatelessWidget {
  const BackToPagePill({super.key, required this.refPage, required this.onTap});
  final int refPage;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Pressable(
    semanticsLabel: 'Voltar à pág. $refPage',
    onTap: onTap,
    child: NeoBox(
      color: AppColors.surface,
      border: const BorderSide(color: AppColors.ink, width: 1.5),
      radius: BorderRadius.circular(999),
      shadow: const Offset(2, 2),
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
      child: Row(mainAxisSize: MainAxisSize.min, spacing: 6, children: [
        const AppSvg(AppIcons.arrowLeft, size: 16),
        Text('Voltar à pág. $refPage', style: AppFonts.figtreeReader(12.5, FontWeight.w800)),
      ]),
    ),
  );
}
```

Conferir o nome da constante do ícone em `AppIcons` (`ic_arrow_left.svg`).

- [ ] **Passo 4 — rodar** → verde. **Passo 5 — commit:** `feat(leitor): fechar provisório e pílula de voltar do link (G11.3, D-106, D-108)`.

### Tarefa 14: estados, barra de status, Voltar do Android, ciclo de vida e semântica

**Arquivos:** `reader_states.dart`, `reader_screen.dart`, `reader_providers.dart` (`ReaderSystemUi`); testes em `reader_screen_test.dart`.

- [ ] **Passo 1 — testes que falham:**
  - "Abrindo o livro…" só aparece depois de 300 ms (antes: só o papel);
  - cada falha mostra o texto da tabela da G11 §3 e o botão "Voltar"; `unexpected` mostra também "Tentar de novo";
  - `RecordingSystemUi`: pronto → `immersive`; erro/abrindo → `edgeToEdge`; sair → `edgeToEdge`;
  - Voltar do Android (`tester.binding.handlePopRoute()`) fecha e grava a posição;
  - `AppLifecycleState.paused` → tempo pausa, posição grava, tela acesa desliga (`RecordingScreenAwake`);
  - semântica: `r19.page` com rótulo "Dom Casmurro, página 159 de 256", valor = texto da página, ações
    `CustomSemanticsAction(label: 'Próxima página')` e `'Página anterior'`.
- [ ] **Passo 3 — implementar:**

```dart
abstract interface class ReaderSystemUi {
  Future<void> immersive();
  Future<void> edgeToEdge();
}

final class PlatformReaderSystemUi implements ReaderSystemUi {
  const PlatformReaderSystemUi();
  @override
  Future<void> immersive() => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  @override
  Future<void> edgeToEdge() => SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}
```

`ReaderStateView` com `AccountColumn`/`AccountText`/`AccountNotice`/`AccountButton` (textos da G11 §3);
`ReaderScreen` com `PopScope(onPopInvokedWithResult: (didPop, _) { if (didPop) unawaited(_c.close()); })`,
`AppLifecycleListener(onStateChange: _c.lifecycle)` e `Timer(300 ms)` para o "abrindo".
- [ ] **Passo 4 — rodar** → verde. **Passo 5 — commit:** `feat(leitor): estados, barra de status, Voltar e ciclo de vida da tela (G11.3, D-21, D-105)`.

---

## G11.4 — PDF básico

### Tarefa 15: `PdfLocator` e posição de PDF

**Arquivos:** `locator.dart`, `pdf_position_keeper.dart`; testes `test/features/reader/domain/locator_test.dart` (novo caso) e `test/features/reader/application/pdf_position_keeper_test.dart`.

- [ ] **Passo 1 — testes que falham:**

```dart
test('PdfLocator ida e volta pelo JSON; outro formato continua RawLocator', () {
  final l = PdfLocator(sha: 'a' * 64, page: 4, refPage: 5, progression: 0.4);
  expect(Locator.fromJson(l.toJson()), l);
  expect(l.toJson(), {'v': 1, 'sha': 'a' * 64, 'page': 4, 'refPage': 5, 'progression': 0.4});
  expect(Locator.fromJson({'v': 9}), isA<RawLocator>());
});

test('PdfPositionKeeper grava pág. 5 de 10 = 40 % (D-109) depois de 1 s; reabre na página; fora do total → a última', ...);
```

- [ ] **Passo 3 — implementar:** `PdfLocator` com `_tryFromJson` (exige `v == 1`, `sha` texto, `page` inteiro ≥ 0, sem
  `spine`), encadeado no `Locator.fromJson` (`EpubLocator._tryFromJson(json) ?? PdfLocator._tryFromJson(json) ?? RawLocator(json)`);
  `PdfPositionKeeper` com `pageShown(int page)`, `flush()`, `savedPage(int pageCount)` (o mesmo `_versioning.write`
  do `ReadingPositionKeeper`, `chapterIndex: 0`, `progression = page / pageCount` com 5 casas, `refPage = page + 1`).
- [ ] **Passo 4 — rodar** → verde. **Passo 5 — commit:** `feat(leitor): localizador e posição de PDF (G11.4, D-109)`.

### Tarefa 16: documento PDF (páginas como imagem, encaixe, números, virar)

**Arquivos:** `pdf_reader_document.dart`, `reader_session_controller.dart` (`_openPdf`); fixture
`test/fixtures/livros/tres_paginas.pdf` (gerado uma vez por script em `tools/fixtures/` com tamanhos A4, carta e
paisagem); teste `test/features/reader/application/pdf_reader_document_test.dart` (PDFium de verdade).

- [ ] **Passo 1 — testes que falham:**

```dart
test('encaixe (D-109): largura − 8 de cada lado, centralizada entre o topo e o rodapé', () {
  final r = pdfPageRect(pageSize: const Size(595, 842), viewport: const Size(390, 844), insets: ReaderInsets.of(EdgeInsets.zero));
  expect(r.left, 8);
  expect(r.width, 374);
  expect(r.height, closeTo(374 * 842 / 595, 1e-9));
  expect(r.center.dy, closeTo((0 + (844 - 40 - 13.81)) / 2, 0.5)); // faixa: do topo da tela ao topo do rodapé
});
test('paisagem baixa fica pela largura; página alta demais fica pela altura', ...);
test('números: pág. 1 de 3 = 0 %; pág. 3 de 3 = 67 %; virar até o fim e batente', ...);
test('abre na página salva e grava ao virar', ...);
```

- [ ] **Passo 3 — implementar:**
  - `Rect pdfPageRect({required Size pageSize, required Size viewport, required ReaderInsets insets})`: faixa
    vertical = `[0, viewport.height − insets.footerBottom − 13,81 − 8]`, largura máx. = `viewport.width − 16`;
    escala = `min(largura máx./w, altura da faixa/h)`; centralizado;
  - `PdfReaderDocument.open(...)`: `PdfDocument.openFile(path)`; `PdfPasswordException`/`PdfException` →
    `ContentDamaged('pdf')`; página inicial = `keeper.savedPage(count)`;
  - `PdfDisplayPage implements DisplayPage`: guarda o `ui.Image` (render com `page.render(width: px, height: px,
    fullWidth: px, fullHeight: px, backgroundColor: 0xFFFFFFFF)` → `ui.Image` por `decodeImageFromPixels` em BGRA
    ou pelo auxiliar do `pdfrx`), pinta com `drawImageRect` no retângulo do encaixe, `spokenText` = texto da página
    pelo `pdfrx` (`page.loadText()`), `linkAt` = `null`;
  - cache das imagens da atual e das 2 vizinhas (as outras são descartadas com `dispose`);
  - `numbers`: `ReaderNumbersView(refPage: i + 1, refTotal: n, progression: i / n)`;
  - `pageShown` emite `(fromRef: i + 1, toRef: i + 1)`.
- [ ] **Passo 4 — rodar** → verde. **Passo 5 — commit:** `feat(leitor): PDF básico com página inteira, números e virada (G11.4, D-109)`.

---

## G11.5 — Verificação

### Tarefa 17: testes da L19 (geometria, texto, estilo, semântica, dados)

**Arquivos:** `test/fixtures/telas/indice_t19.dart`, `test/features/reader/presentation/l19_test.dart`.

- [ ] **Passo 1:** `indice_t19.dart` monta o índice injetado (D-34) para o EPUB do mundo (`mundoEpub(Slugs.domCasmurro)`):
  itens com a contagem de caracteres escolhida para que o 1º caractere do cap. XXXII (item 32, onde está o
  parágrafo da tela 19) caia na pág. 159 de 256 pela regra de 1.500 caracteres (D-89) e em 62 % do total —
  por exemplo, 237.893 caracteres antes do item 32 e 383.000 no total. As páginas sintéticas são calculadas pelo
  mesmo código da G09 (não à mão).
- [ ] **Passo 2 — testes:**
  - geometria dos 5 ids da `kRef19` (as chaves dos widgets; `r19.page.text` pelo retângulo do parágrafo no layout)
    com ±0,5 e ±1,0 em x/w nos `textDependentX`;
  - as 19 linhas da página mostrada (texto, baseline e borda direita) = `kRef19` (±0,5);
  - estilo: papel, cor do texto, rodapé (família, tamanho, peso, cor, `tnum`);
  - semântica (rótulo, valor, ações);
  - dados: 159, 256 e 62 % vêm do `numbersAt` com o índice injetado (o teste lê `numbersAt` e compara com o rodapé).
- [ ] **Passo 3 — rodar** → verde (corrigir a tela, nunca a referência). **Passo 4 — commit:** `test(leitor): tela 19 contra as medidas da L19 (G11.5)`.

### Tarefa 18: golden contra a prancha (≤ 0,5 %)

- [ ] **Passo 1:** `test/golden/leitor_19_test.dart`: 390×844 @3x, `viewPadding` 0, `captureAt` → `matchesGoldenFile('goldens/leitor_19@3x.png')`; com `BOOKNEST_CAPTURAS` grava também a captura.
- [ ] **Passo 2:** gerar o golden (`flutter test --update-goldens test/golden/leitor_19_test.dart`) e comparar com a referência no recorte y 84–844:
  `python tools/compare_images.py handoff_v2/referencia/png/19_leitor_limpo_390x844@3x.png test/golden/goldens/leitor_19@3x.png --crop 0,252,1170,2532` → `blur_mismatch_% ≤ 0,5`; inspecionar o lado a lado e o heatmap.
- [ ] **Passo 3 — commit:** `test(leitor): golden da tela 19 contra a prancha (G11.5)`.

### Tarefa 19: revisão independente, mutação, cobertura, gitleaks, capturas e relatório

- [ ] Suíte inteira (`suite.ps1`): `dart format`, `flutter analyze` (0), `flutter test --coverage` verdes.
- [ ] Revisão independente por um agente que não escreveu o código (concorrência do carrossel com `peek`/`turn`, ciclo de vida, falhas, PDF, vazamento de `ui.Image`); corrigir com teste.
- [ ] Mutação (`/home/claude/g03/mut/gerar_g11.py`): limites 1/4, 300 px/s, 1/3, 220 ms, 300 ms, 4 s, 6 s, 2 viradas, 120 s da tela acesa, D-112 (+45/+48/+6), encaixe do PDF (8 px), % do PDF, `linkAt` no retângulo, cada correção da revisão.
- [ ] Cobertura ≥ 90 % nos módulos da fase.
- [ ] gitleaks nos commits da fase e nas pastas tocadas.
- [ ] Capturas (Creme, Branco, Sépia, Noite, link com a pílula, PDF) mandadas na conversa.
- [ ] `docs/progresso/G11.md` (Resultados, Revisão, Desvios, Pendências, checklist com hashes) e `docs/progresso/RELATORIO_G11.md` terminando com "✅ FASE G11 concluída — aguardando sua aprovação para iniciar a FASE G12."; enviar o relatório ao projeto (`handoff_app_completo/relatorios/RELATORIO_G11.md`).
- [ ] Commit: `docs(g11): checklist com as provas, revisão, desvios e relatório da fase (G11.5)`.
