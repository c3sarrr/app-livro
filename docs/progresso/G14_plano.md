# G14 — Plano de implementação (tela 26: ajustes de leitura "Aa")

> **Para quem executa:** seguir tarefa por tarefa (`superpowers:executing-plans`), com TDD: teste que falha →
> código mínimo → teste verde → commit. Desenho aprovado: `docs/progresso/G14.md` (D-18 e D-20 aprovadas; D-141 a
> D-144 respondidas em 06/10/2026).

**Objetivo:** a ferramenta "Aa Fonte" abre a folha da tela 26 com a página viva em cima. Cada toque (tamanho,
fonte, papel, entrelinha, margens) grava o ajuste da conta e repagina o livro no caractere que a pessoa lia. As 4
fontes do livro (Literata, Lora, Figtree, Atkinson Hyperlegible) entram completas, com itálico e negrito reais.

**Arquitetura:**
- **Fontes do livro:** `ReaderTypography` ganha a fonte (`ReaderFontFamily`). O estilo de cada trecho sai por família:
  - Literata, Lora e Figtree pelos eixos;
  - Atkinson pelos arquivos de 400 e 700;
  - as letras que faltam vêm dos subconjuntos da Literata.
  A chave do cache e a área do texto passam a depender da fonte.
- **Ajustes da sessão:** `ReaderLook` (domínio) é o que a folha mostra e muda. `ReaderSessionController.applySettings`
  aplica a mudança na fila, grava com versão e chama `ReaderDocument.retypeset(t)`. Esse método é o
  `BookPager.relayout` da G10, que mantém o caractere. O Tema da G12 passa pelo mesmo caminho.
- **Folha:** `ReaderSettingsSheet` é uma camada da `ReaderScreen` acima dos controles. Ela tem:
  - um `CustomMultiChildLayout` que põe a folha embaixo, o papel que cobre a página abaixo do corte, o nó
    "Prévia da página" e a pílula;
  - a abertura e o fechamento em 150 ms;
  - o arrasto pela alça e o toque fora, que fecham.

**Tecnologia:** Flutter 3.47.2 / Dart 3.13.2, Riverpod 3, drift, `dart:ui` (`FontVariation`, `ParagraphBuilder`),
fontes OFL do google/fonts.

**Fluxo de trabalho (o mesmo da G13):**
- **Editar:** no espelho `/home/claude/g03/repo`.
- **Levar ao Windows:** `./ciclo.sh <arquivos>` gera o zip, e o `device_commit_files` o leva a `tools\medicao\tmp\`.
- **Rodar:** `rodar.ps1 -Nome … -Cmd "…"`, depois ler o `.log`/`.fim`.
  - Primeiro o VERMELHO: expandir só os testes e rodar.
  - Depois o VERDE: expandir o código e rodar `dart format lib test && flutter analyze && flutter test --timeout 120s <testes>`.
- **Trazer de volta:** o que o `dart format` mudou (`device_stage_files` + `puxar.sh`).
- **Commit:** no Windows, com `git --no-optional-locks commit -F tools/medicao/tmp/msg_g14_NN.txt`. O `.ps1` é
  gravado com BOM.
  - Mensagens em português, no formato `tipo(escopo): descrição`, com as 2 linhas de coautoria.
- **Cuidados:**
  - nunca deixar `.dart` em `tools/medicao/tmp`;
  - mudou um asset → tocar o `pubspec.yaml`;
  - nada de `Opacity`, `saveLayer`, `BackdropFilter` ou `ColorFiltered` em `lib` (F12 12.4);
  - todo `CustomPainter` novo entra na lista do `performance_test`, com teste de repintura;
  - não mexer em `design_handoff/` nem em `handoff_v2/`.

**Ajuste de forma do desenho (registrado na Tarefa 0):** o desenho escreveu
`applySettings(ReaderSettings Function(ReaderSettings) change)`. O plano usa `ReaderLook`, os 5 ajustes sem a
linha do banco, porque a folha precisa dos valores mesmo quando a conta ainda não tem linha (padrões da tela 26). A
regra é a mesma.

---

## Mapa de arquivos

| Arquivo | Responsabilidade | Tarefa |
|---|---|---|
| `assets/fonts/livro/*.ttf` (novos) | Lora e Figtree variáveis com itálico; Atkinson Hyperlegible 400/700 com itálico (google/fonts, sem modificação) | 1 |
| `pubspec.yaml` (mod.) | `LoraBook`, `FigtreeBook`, `AtkinsonBook`; da interface: `Bricolage23`, `Literata15/18/25/26` | 1, 8 |
| `assets/fonts/LICENCAS_FONTES_OFL.txt` (mod.) | os arquivos novos na lista da licença | 1 |
| `lib/features/reader/domain/reader_settings.dart` (mod.) | `ReaderLook`, `ReaderLookChange`, `ReaderSettings.look/withLook` | 2 |
| `lib/core/design_system/tokens/reader_fonts.dart` (mod.) | nomes das famílias do livro | 3 |
| `lib/features/reader/layout/reader_typography.dart` (mod.) | fonte na tipografia, `fromLook`, `readerFamilyOf`, estilo por família, `layoutKey`, `readerFontsVersion` 2 | 3 |
| `lib/features/reader/layout/text_geometry.dart`, `page_snapshot.dart` (mod.) | área do texto por (fonte, tamanho) | 4 |
| `lib/features/reader/application/reader_document.dart`, `epub_reader_document.dart`, `pdf_reader_document.dart` (mod.) | `retypeset(t)` | 5 |
| `lib/features/reader/application/reader_session_controller.dart` (mod.) | `look`, `applySettings`, `_applyLook`, `_save`; o Tema pelo mesmo caminho | 6 |
| `lib/core/design_system/tokens/app_colors.dart`, `app_typography.dart`, `app_icons_leitor.dart` (mod.) | cores, estilos e ícones da folha | 7, 8 |
| `lib/features/reader/presentation/reader_chrome_palette.dart` (mod.) | `caption` (legenda dos cartões de fonte) | 7 |
| `lib/core/design_system/painters/dashed_stadium_painter.dart` (novo) | o trilho tracejado do tamanho | 9 |
| `lib/core/design_system/widgets/pressable.dart` (mod.) | `checked`: opção de grupo (radio) | 9 |
| `lib/features/reader/presentation/reader_settings_sheet.dart` (novo) | `ReaderSettingsSheet` (L26) | 10–12 |
| `lib/features/reader/presentation/reader_screen.dart` (mod.) | "Aa" abre, fechar volta aos controles, Voltar, barra de status, prazo da pílula | 13 |
| `test/support/fase_l26.dart`, `test/features/reader/presentation/l26_test.dart` | fase L26 | 15 |
| `test/golden/leitor_26_test.dart`, `test/golden/capturas_g14_test.dart` | golden e capturas | 16 |

---

## Tarefa 0: o plano e o ajuste de forma no desenho

**Arquivos:** `docs/progresso/G14_plano.md` (este), `docs/progresso/G14.md` (§2).

- [ ] **Passo 1:** em `G14.md` §2, trocar `applySettings(ReaderSettings Function(ReaderSettings) change)` por
  `applySettings(ReaderLookChange change)` e acrescentar: "(`ReaderLook` = os 5 ajustes sem a linha do banco; sem
  linha, os padrões da tela 26)".
- [ ] **Passo 2:** em `G14.md` "Fora da G14", acrescentar: "decodificar as imagens do livro de novo ao trocar a
  margem: elas ficam na largura da abertura, e a Estreita as amplia até 5 % (fase de desempenho)".
- [ ] **Passo 3 — commit:** `docs(g14): plano de implementação e ajuste de forma do desenho`.

---

## G14.1 — Fontes do livro

### Tarefa 1: arquivos, registro e licença

**Arquivos:**
- novos: `assets/fonts/livro/{Lora-Wght,Lora-Italic-Wght,Figtree-Wght,Figtree-Italic-Wght}.ttf` e
  `assets/fonts/livro/AtkinsonHyperlegible-{Regular,Italic,Bold,BoldItalic}.ttf`;
- mudam: `pubspec.yaml` e `assets/fonts/LICENCAS_FONTES_OFL.txt`;
- teste novo: `test/design_system/fontes_livro_g14_test.dart`; muda o `test/design_system/font_license_test.dart`.

Origem: `https://raw.githubusercontent.com/google/fonts/main/ofl/` +
- `lora/Lora%5Bwght%5D.ttf` (→ `Lora-Wght.ttf`) e `lora/Lora-Italic%5Bwght%5D.ttf` (→ `Lora-Italic-Wght.ttf`);
- `figtree/Figtree%5Bwght%5D.ttf` (→ `Figtree-Wght.ttf`) e `figtree/Figtree-Italic%5Bwght%5D.ttf`
  (→ `Figtree-Italic-Wght.ttf`);
- `atkinsonhyperlegible/AtkinsonHyperlegible-{Regular,Italic,Bold,BoldItalic}.ttf`.

Os nomes dos arquivos perdem os colchetes: o `[` atrapalha os caminhos dos assets. Os dados não mudam, o que a
Reserved Font Name da Lora exige. A pasta `livro/` separa estes arquivos dos subconjuntos da G01, que têm nomes
iguais (`AtkinsonHyperlegible-Regular.ttf`).

- [ ] **Passo 1 — teste que falha** (`test/design_system/fontes_livro_g14_test.dart`):

```dart
// G14.1 (D-18) — as 4 fontes do texto do livro entram completas, do google/fonts e sem modificação (a Lora tem
// Reserved Font Name): os arquivos byte a byte, as famílias no pubspec com os estilos certos e a licença.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// sha256 dos arquivos do google/fonts (baixados em 06/10/2026).
const Map<String, String> _hashes = {
  'Lora-Wght.ttf':
      '822a6621ccbe8d97d20ac88c1c41f5615c9c2c202eaa75f272cd452aac6475a7',
  'Lora-Italic-Wght.ttf':
      '22d8d8854b53807aa664ca34f2031a9ed57a1d0dea296b8b96cdd3aad937a2b3',
  'Figtree-Wght.ttf':
      '26ad3db9b31ff7dde67a91ff515d022d2f495cd506590699cf264f0bfe6fb714',
  'Figtree-Italic-Wght.ttf':
      '94dec1f18b9275d69e8b4a91b6514bdc18199048347e1c36e1285b11b0b87653',
  'AtkinsonHyperlegible-Regular.ttf':
      '7fb917c89019896d0b52ee84b7cbb3304c18cb90b19a62f5e32712bd23e97669',
  'AtkinsonHyperlegible-Italic.ttf':
      '021beda4d3c6edfc78872e436d74009f9a1bcb294331908fe5747c61d3dcc514',
  'AtkinsonHyperlegible-Bold.ttf':
      '5a3b0c8cc8ca545155150b4512a1fa248298df121c50d6557e651e61fbdab92f',
  'AtkinsonHyperlegible-BoldItalic.ttf':
      '7a46f1b0ef2f64b61065c1a6b5a11fcb9b019b44062d88ba121a083cc39e86bf',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('os 8 arquivos do livro são os do google/fonts, byte a byte', () {
    for (final e in _hashes.entries) {
      final f = File('assets/fonts/livro/${e.key}');
      expect(f.existsSync(), isTrue, reason: e.key);
      expect(sha256.convert(f.readAsBytesSync()).toString(), e.value, reason: e.key);
    }
  });

  test('pubspec: LoraBook e FigtreeBook (variáveis + itálico), AtkinsonBook (400/700 + itálicos)', () async {
    final manifest = (json.decode(await rootBundle.loadString('FontManifest.json')) as List)
        .cast<Map<String, dynamic>>();
    List<(String, int?, String?)> de(String family) => [
      for (final f in (manifest.singleWhere((m) => m['family'] == family)['fonts'] as List)
          .cast<Map<String, dynamic>>())
        ((f['asset'] as String).split('/').last, f['weight'] as int?, f['style'] as String?),
    ];
    expect(de('LoraBook'), [('Lora-Wght.ttf', null, null), ('Lora-Italic-Wght.ttf', null, 'italic')]);
    expect(de('FigtreeBook'), [
      ('Figtree-Wght.ttf', null, null),
      ('Figtree-Italic-Wght.ttf', null, 'italic'),
    ]);
    expect(de('AtkinsonBook'), [
      ('AtkinsonHyperlegible-Regular.ttf', 400, null),
      ('AtkinsonHyperlegible-Italic.ttf', 400, 'italic'),
      ('AtkinsonHyperlegible-Bold.ttf', 700, null),
      ('AtkinsonHyperlegible-BoldItalic.ttf', 700, 'italic'),
    ]);
  });

  test('licença: os arquivos do livro listados, a Lora sem modificação', () {
    final t = File('assets/fonts/LICENCAS_FONTES_OFL.txt').readAsStringSync();
    expect(t, contains('livro/Lora{,-Italic}-Wght.ttf'));
    expect(t, contains('livro/Figtree{,-Italic}-Wght.ttf'));
    expect(t, contains('livro/AtkinsonHyperlegible-{Regular,Italic,Bold,BoldItalic}.ttf'));
    expect(t, contains('google/fonts'));
  });
}
```

Se o `crypto` não for dependência direta, usar o `package:crypto` que o `book_pager.dart` já importa (o `sha256`
do cache). Conferir com `grep crypto pubspec.yaml`.

- [ ] **Passo 2 — rodar e ver falhar:** os arquivos e as famílias ainda não existem.
- [ ] **Passo 3 — os arquivos:** copiar os 8 `.ttf` já baixados e conferidos (scratchpad
  `fontes_g14/`, mesmos sha256) para `/home/claude/g03/repo/assets/fonts/livro/`.
- [ ] **Passo 4 — `pubspec.yaml`:** no fim do bloco `fonts:`:

```yaml
    # G14 (D-18): o texto do livro nas 4 fontes da tela 26 — arquivos completos do google/fonts, SEM modificação
    # (a Lora tem Reserved Font Name). Lora e Figtree variáveis (eixo wght) com itálico; Atkinson em 4 estáticas.
    - family: LoraBook
      fonts:
        - asset: assets/fonts/livro/Lora-Wght.ttf
        - asset: assets/fonts/livro/Lora-Italic-Wght.ttf
          style: italic
    - family: FigtreeBook
      fonts:
        - asset: assets/fonts/livro/Figtree-Wght.ttf
        - asset: assets/fonts/livro/Figtree-Italic-Wght.ttf
          style: italic
    - family: AtkinsonBook
      fonts:
        - asset: assets/fonts/livro/AtkinsonHyperlegible-Regular.ttf
          weight: 400
        - asset: assets/fonts/livro/AtkinsonHyperlegible-Italic.ttf
          weight: 400
          style: italic
        - asset: assets/fonts/livro/AtkinsonHyperlegible-Bold.ttf
          weight: 700
        - asset: assets/fonts/livro/AtkinsonHyperlegible-BoldItalic.ttf
          weight: 700
          style: italic
```

- [ ] **Passo 5 — licença:** em `LICENCAS_FONTES_OFL.txt`, logo antes de "Modificações", um item novo:

```
- Texto do livro (G14, D-18) — arquivos completos do google/fonts (https://github.com/google/fonts), SEM
  modificação (só os nomes dos arquivos, sem colchetes):
  livro/Lora{,-Italic}-Wght.ttf (Lora, Reserved Font Name "Lora"),
  livro/Figtree{,-Italic}-Wght.ttf (Figtree) e
  livro/AtkinsonHyperlegible-{Regular,Italic,Bold,BoldItalic}.ttf (Atkinson Hyperlegible).
```

- [ ] **Passo 6 — `font_license_test.dart`:** acrescentar `expect(text, contains('Atkinson Hyperlegible'));` e
  `expect(text, contains('Reserved Font Name "Lora"'));`.
- [ ] **Passo 7 — rodar:** `flutter test test/design_system/fontes_livro_g14_test.dart test/design_system/font_license_test.dart test/design_system/fonts_smoke_test.dart`
  → verde.
- [ ] **Passo 8 — commit:** `feat(fontes): Lora, Figtree e Atkinson completas para o texto do livro (D-18, G14.1)`.

### Tarefa 2: `ReaderLook`, os ajustes sem a linha do banco

**Arquivos:** `lib/features/reader/domain/reader_settings.dart`; teste
`test/features/reader/domain/reader_domain_test.dart` (um grupo novo).

- [ ] **Passo 1 — teste que falha** (no fim do `main` de `reader_domain_test.dart`):

```dart
  group('ReaderLook (G14)', () {
    test('padrões = tela 26; copyWith; igualdade por valor', () {
      const l = ReaderLook();
      expect(
        (l.fontStep, l.fontFamily, l.paper, l.lineSpacing, l.margins),
        (4, ReaderFontFamily.literata, ReaderPaper.creme, ReaderLineSpacing.medio, ReaderMargins.media),
      );
      expect(l.copyWith(fontStep: 7), const ReaderLook(fontStep: 7));
      expect(l.copyWith(fontStep: 7), isNot(l));
      expect(l.copyWith(paper: ReaderPaper.noite).hashCode, const ReaderLook(paper: ReaderPaper.noite).hashCode);
    });

    test('sameLayout: o papel não muda as quebras; tamanho, fonte, entrelinha e margens mudam', () {
      const l = ReaderLook();
      expect(l.sameLayout(l.copyWith(paper: ReaderPaper.sepia)), isTrue);
      for (final o in [
        l.copyWith(fontStep: 5),
        l.copyWith(fontFamily: ReaderFontFamily.lora),
        l.copyWith(lineSpacing: ReaderLineSpacing.solto),
        l.copyWith(margins: ReaderMargins.larga),
      ]) {
        expect(l.sameLayout(o), isFalse, reason: '$o');
      }
    });

    test('ReaderSettings.look e withLook: os 5 ajustes vão e voltam; id e meta ficam', () {
      final s = ReaderSettings(id: usuario, meta: meta, fontStep: 2, paper: ReaderPaper.sepia);
      expect(s.look, const ReaderLook(fontStep: 2, paper: ReaderPaper.sepia));
      const outro = ReaderLook(
        fontStep: 6,
        fontFamily: ReaderFontFamily.atkinson,
        paper: ReaderPaper.noite,
        lineSpacing: ReaderLineSpacing.justo,
        margins: ReaderMargins.estreita,
      );
      final t = s.withLook(outro);
      expect((t.id, t.meta, t.look), (s.id, s.meta, outro));
      final m2 = meta.edited(meta.updatedAt.add(const Duration(seconds: 1)), meta.version);
      expect(s.withLook(outro, meta: m2).meta, m2);
      expect(() => s.withLook(const ReaderLook().copyWith(fontStep: 9)), throwsA(anything));
    });
  });
```

`usuario` e `meta` são os nomes que o arquivo já usa (linhas 230–280). Conferir antes e ajustar se forem outros.

- [ ] **Passo 2 — rodar e ver falhar:** `ReaderLook` não existe.
- [ ] **Passo 3 — código** (em `reader_settings.dart`, depois de `ReaderMargins`):

```dart
/// Uma mudança de ajuste pedida pela folha (tela 26): aplicada sobre os ajustes de agora, na fila da sessão —
/// toques rápidos somam (D-144).
typedef ReaderLookChange = ReaderLook Function(ReaderLook look);

/// Os ajustes de leitura que a folha mostra e muda (tela 26), sem a linha do banco. Padrões = tela 26 (e o SQL):
/// sem linha na conta, a folha mostra estes.
@immutable
final class ReaderLook {
  const ReaderLook({
    this.fontStep = 4,
    this.fontFamily = ReaderFontFamily.literata,
    this.paper = ReaderPaper.creme,
    this.lineSpacing = ReaderLineSpacing.medio,
    this.margins = ReaderMargins.media,
  });

  final int fontStep;
  final ReaderFontFamily fontFamily;
  final ReaderPaper paper;
  final ReaderLineSpacing lineSpacing;
  final ReaderMargins margins;

  /// As mesmas quebras de linha e de página: só o papel mudou (ou nada).
  bool sameLayout(ReaderLook o) =>
      o.fontStep == fontStep &&
      o.fontFamily == fontFamily &&
      o.lineSpacing == lineSpacing &&
      o.margins == margins;

  ReaderLook copyWith({
    int? fontStep,
    ReaderFontFamily? fontFamily,
    ReaderPaper? paper,
    ReaderLineSpacing? lineSpacing,
    ReaderMargins? margins,
  }) => ReaderLook(
    fontStep: fontStep ?? this.fontStep,
    fontFamily: fontFamily ?? this.fontFamily,
    paper: paper ?? this.paper,
    lineSpacing: lineSpacing ?? this.lineSpacing,
    margins: margins ?? this.margins,
  );

  @override
  bool operator ==(Object other) =>
      other is ReaderLook &&
      other.fontStep == fontStep &&
      other.fontFamily == fontFamily &&
      other.paper == paper &&
      other.lineSpacing == lineSpacing &&
      other.margins == margins;

  @override
  int get hashCode => Object.hash(fontStep, fontFamily, paper, lineSpacing, margins);

  @override
  String toString() =>
      'ReaderLook($fontStep, ${fontFamily.code}, ${paper.code}, ${lineSpacing.code}, ${margins.code})';
}
```

E em `ReaderSettings`, depois de `copyWith`:

```dart
  /// Os 5 ajustes, sem a linha.
  ReaderLook get look => ReaderLook(
    fontStep: fontStep,
    fontFamily: fontFamily,
    paper: paper,
    lineSpacing: lineSpacing,
    margins: margins,
  );

  /// A mesma linha com os ajustes de [l] (e a [meta] nova de uma edição). O passo é conferido (1–7).
  ReaderSettings withLook(ReaderLook l, {RecordMeta? meta}) => copyWith(
    meta: meta,
    fontStep: l.fontStep,
    fontFamily: l.fontFamily,
    paper: l.paper,
    lineSpacing: l.lineSpacing,
    margins: l.margins,
  );
```

- [ ] **Passo 4 — rodar:** `flutter test test/features/reader/domain/reader_domain_test.dart` → verde.
- [ ] **Passo 5 — commit:** `feat(leitor): ReaderLook, os ajustes da folha sem a linha do banco (G14.1)`.

### Tarefa 3: a tipografia com a fonte escolhida

**Arquivos:** `lib/core/design_system/tokens/reader_fonts.dart`,
`lib/features/reader/layout/reader_typography.dart`; teste novo
`test/features/reader/layout/reader_fonts_g14_test.dart`.

- [ ] **Passo 1 — teste que falha** (`reader_fonts_g14_test.dart`):

```dart
// G14.1 — o texto do livro nas 4 fontes da tela 26 (D-18): a família de cada uma; os eixos (opsz = tamanho e wght
// explícitos) com o Skia em 400, sem negrito sintético; a Atkinson, sem eixos, pelos arquivos de 400 e 700 (os
// títulos em 700); itálico e negrito vindos dos arquivos (a imagem é a do arquivo); as letras que a fonte não tem
// (o grego) vindas da Literata; a chave do cache com a fonte.
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/content/content_blocks.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/load_fonts.dart';

ui.Paragraph _paragrafo(ui.TextStyle s, String texto) {
  final b = ui.ParagraphBuilder(ui.ParagraphStyle(textDirection: ui.TextDirection.ltr))
    ..pushStyle(s)
    ..addText(texto);
  return b.build()..layout(const ui.ParagraphConstraints(width: 2000));
}

/// Os pixels de [texto] em [s] (para comparar com o arquivo pedido sozinho).
Future<Uint8List> _pixels(ui.TextStyle s, String texto) async {
  final p = _paragrafo(s, texto);
  final r = ui.PictureRecorder();
  ui.Canvas(r).drawParagraph(p, ui.Offset.zero);
  final img = await r.endRecording().toImage(p.maxIntrinsicWidth.ceil() + 4, p.height.ceil() + 4);
  final bytes = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
  img.dispose();
  p.dispose();
  return bytes;
}

/// Uma família de teste só com o arquivo [asset] (o que o Skia pinta quando pede esse arquivo).
Future<String> _soEsse(String asset) async {
  final nome = 'G14_${asset.split('/').last}';
  await (FontLoader(nome)..addFont(rootBundle.load(asset))).load();
  return nome;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  test('famílias e versão das fontes', () {
    expect(
      [for (final f in ReaderFontFamily.values) readerFamilyOf(f)],
      ['LiterataVF', 'LoraBook', 'FigtreeBook', 'AtkinsonBook'],
    );
    expect(readerFontsVersion, 2);
  });

  test('estilo por família: eixos e Skia em 400; Atkinson pelos arquivos (títulos e negrito em 700)', () {
    for (final f in [ReaderFontFamily.literata, ReaderFontFamily.lora, ReaderFontFamily.figtree]) {
      final t = ReaderTypography(font: f);
      final s = t.spec(RunStyle.plain);
      expect((s.family, s.fallback.first, s.skiaWeight), (readerFamilyOf(f), 'LiterataVFExt', ui.FontWeight.w400));
      expect(s.variations.map((v) => (v.axis, v.value)), [('opsz', 20.5), ('wght', 400.0)]);
      expect(t.spec(RunStyle.plain, weight: readerHeadingWeight).wght, 600);
      expect(t.spec(const RunStyle(bold: true)).skiaWeight, ui.FontWeight.w400, reason: 'sem negrito sintético');
    }
    const a = ReaderTypography(font: ReaderFontFamily.atkinson);
    expect((a.spec(RunStyle.plain).family, a.spec(RunStyle.plain).skiaWeight), ('AtkinsonBook', ui.FontWeight.w400));
    final titulo = a.spec(RunStyle.plain, size: 26.65, weight: readerHeadingWeight);
    expect((titulo.wght, titulo.skiaWeight), (700.0, ui.FontWeight.w700));
    final negrito = a.spec(const RunStyle(bold: true));
    expect((negrito.wght, negrito.skiaWeight), (700.0, ui.FontWeight.w700));
    expect(a.spec(const RunStyle(italic: true)).italic, isTrue);
  });

  test('itálico e negrito saem dos arquivos (a imagem é a do arquivo pedido sozinho)', () async {
    const texto = 'Retórica dos namorados';
    // os dois lados com os mesmos eixos do livro: as variáveis pintam a mesma instância; a Atkinson os ignora
    Future<void> confere(
      ui.TextStyle livro,
      String asset, {
      ui.FontWeight w = ui.FontWeight.w400,
      double wght = 400,
    }) async {
      final so = await _soEsse(asset);
      final esperado = await _pixels(
        ui.TextStyle(
          fontFamily: so,
          fontSize: 20.5,
          fontWeight: w,
          fontVariations: [
            const ui.FontVariation('opsz', 20.5),
            ui.FontVariation('wght', wght),
          ],
        ),
        texto,
      );
      expect(await _pixels(livro, texto), esperado, reason: asset);
    }

    ui.TextStyle estilo(ReaderFontFamily f, RunStyle r) =>
        ReaderTypography(font: f).runStyle(r);
    await confere(
      estilo(ReaderFontFamily.lora, const RunStyle(italic: true)),
      'assets/fonts/livro/Lora-Italic-Wght.ttf',
    );
    await confere(
      estilo(ReaderFontFamily.figtree, const RunStyle(italic: true)),
      'assets/fonts/livro/Figtree-Italic-Wght.ttf',
    );
    await confere(
      estilo(ReaderFontFamily.atkinson, const RunStyle(italic: true)),
      'assets/fonts/livro/AtkinsonHyperlegible-Italic.ttf',
    );
    await confere(
      estilo(ReaderFontFamily.atkinson, const RunStyle(bold: true)),
      'assets/fonts/livro/AtkinsonHyperlegible-Bold.ttf',
      w: ui.FontWeight.w700,
      wght: 700,
    );
  });

  test('o grego vem da Literata em todas as fontes (mesma largura da Literata)', () {
    const grego = 'λόγος καὶ ἦθος';
    final literata = _paragrafo(const ReaderTypography().runStyle(RunStyle.plain), grego).maxIntrinsicWidth;
    for (final f in [ReaderFontFamily.lora, ReaderFontFamily.figtree, ReaderFontFamily.atkinson]) {
      final w = _paragrafo(ReaderTypography(font: f).runStyle(RunStyle.plain), grego).maxIntrinsicWidth;
      expect(w, moreOrLessEquals(literata, epsilon: 0.01), reason: '$f');
    }
  });

  test('fromLook: a fonte entra; layoutKey muda com a fonte; a cor não muda o layout', () {
    ReaderTypography de(ReaderLook l) => ReaderTypography.fromLook(l, viewportWidth: 390, viewportHeight: 844);
    const base = ReaderLook();
    expect(de(base).font, ReaderFontFamily.literata);
    final keys = {
      for (final f in ReaderFontFamily.values) de(base.copyWith(fontFamily: f)).layoutKey,
    };
    expect(keys, hasLength(4));
    final lora = de(base.copyWith(fontFamily: ReaderFontFamily.lora));
    expect(lora.layoutKey, contains('LoraBook'));
    expect(lora.withInk(const ui.Color(0xFFE3D9C6)).font, ReaderFontFamily.lora);
    expect(lora.withInk(const ui.Color(0xFFE3D9C6)).layoutKey, lora.layoutKey);
  });
}
```

O texto da imagem não tem grego nem vietnamita: as letras saem todas do arquivo testado, sem a reserva.

- [ ] **Passo 2 — rodar e ver falhar:** `readerFamilyOf`, `font` e `fromLook` não existem.
- [ ] **Passo 3 — `reader_fonts.dart`** (depois de `readerFontFallback`):

```dart
/// Famílias do texto do livro além da Literata (G14, D-18): os arquivos completos do google/fonts, registrados
/// com nomes próprios do livro (os da interface — `Figtree` estática — continuam separados).
const String readerLoraFamily = 'LoraBook';
const String readerFigtreeFamily = 'FigtreeBook';
const String readerAtkinsonFamily = 'AtkinsonBook';
```

E trocar o comentário de `readerFontFamily` para "Família do texto do livro na Literata (a padrão — D-18)".

- [ ] **Passo 4 — `reader_typography.dart`:**
  - o comentário do topo ganha: "G14.1 — a fonte escolhida (D-18): Literata, Lora e Figtree pelos eixos; Atkinson
    pelos arquivos de 400 e 700. As letras que faltam vêm dos subconjuntos da Literata.";
  - `const int readerFontsVersion = 2;` com o comentário "(2 = G14: Lora, Figtree e Atkinson)";
  - depois de `sideMarginOf`:

```dart
/// A família registrada no pubspec para a fonte escolhida (D-18).
String readerFamilyOf(ReaderFontFamily f) => switch (f) {
  ReaderFontFamily.literata => readerFontFamily,
  ReaderFontFamily.lora => readerLoraFamily,
  ReaderFontFamily.figtree => readerFigtreeFamily,
  ReaderFontFamily.atkinson => readerAtkinsonFamily,
};
```

  - `ReaderTypography`:
    - o construtor ganha `this.font = ReaderFontFamily.literata` e o campo
      `/// A fonte do texto (D-18). final ReaderFontFamily font;`;
    - `fromSettings` passa a ser `fromLook(s.look, …)`;
    - o novo `fromLook`:

```dart
  /// Os ajustes da folha (D-20, D-18) num viewport.
  factory ReaderTypography.fromLook(
    ReaderLook l, {
    required double viewportWidth,
    required double viewportHeight,
    double topInset = 92,
    double bottomInset = 82,
    ui.Color ink = readerInkCreme,
  }) => ReaderTypography(
    fontSize: readerFontSizes[l.fontStep - 1],
    lineSpacing: lineSpacingOf(l.lineSpacing),
    sideMargin: sideMarginOf(l.margins),
    font: l.fontFamily,
    viewportWidth: viewportWidth,
    viewportHeight: viewportHeight,
    topInset: topInset,
    bottomInset: bottomInset,
    ink: ink,
  );

  factory ReaderTypography.fromSettings(
    ReaderSettings s, {
    required double viewportWidth,
    required double viewportHeight,
    double topInset = 92,
    double bottomInset = 82,
    ui.Color ink = readerInkCreme,
  }) => ReaderTypography.fromLook(
    s.look,
    viewportWidth: viewportWidth,
    viewportHeight: viewportHeight,
    topInset: topInset,
    bottomInset: bottomInset,
    ink: ink,
  );
```

  - `withInk` copia `font: font`;
  - `layoutKey`:

```dart
  String get layoutKey =>
      'v$readerLayoutVersion|${readerFamilyOf(font)}|$fontSize|$lineSpacing|$sideMargin|'
      '$topInset|$bottomInset';
```

  - `spec`:

```dart
  ReaderTextSpec spec(
    RunStyle s, {
    double? size,
    double weight = readerTextWeight,
    bool link = false,
  }) {
    var w = s.bold && weight < readerBoldWeight ? readerBoldWeight : weight;
    // a Atkinson só tem 400 e 700 (sem eixo): o seminegrito dos títulos vira 700
    if (font == ReaderFontFamily.atkinson) {
      w = w >= 600 ? readerBoldWeight : readerTextWeight;
    }
    return ReaderTextSpec(
      font: font,
      size: size ?? fontSize,
      lineSpacing: lineSpacing,
      wght: w,
      italic: s.italic,
      features: [
        if (s.smallCaps) 'smcp',
        if (s.superscript) 'sups',
        if (s.subscript) 'subs',
      ],
      link: link,
      ink: ink,
    );
  }
```

  - `ReaderTextSpec`:

```dart
  const ReaderTextSpec({
    this.font = ReaderFontFamily.literata,
    required this.size,
    …
  });

  final ReaderFontFamily font;
  …
  String get family => readerFamilyOf(font);
  List<String> get fallback => readerFontFallback;

  /// Literata, Lora e Figtree: o peso vem do eixo e o Skia fica em 400 (sem negrito sintético por cima). A
  /// Atkinson não tem eixo: o peso escolhe o arquivo (400 ou 700).
  ui.FontWeight get skiaWeight =>
      font == ReaderFontFamily.atkinson && wght >= readerBoldWeight
      ? ui.FontWeight.w700
      : ui.FontWeight.w400;

  /// `opsz` = tamanho e `wght` em todas: a fonte sem esse eixo o ignora, e as letras que vêm da Literata (o
  /// grego) saem no tamanho óptico e no peso certos.
  List<ui.FontVariation> get variations => [ … igual … ];
```

  O comentário da classe passa a "Estilo de um trecho do livro em dados: a fonte escolhida (D-18) com `opsz` = [size]
  e `wght` = [wght] sempre explícitos…".

- [ ] **Passo 5 — rodar:** `flutter test test/features/reader/layout/reader_fonts_g14_test.dart test/features/reader/layout/laid_block_test.dart test/features/reader/layout/tela19_gate_test.dart test/features/reader/application/book_pager_test.dart`
  → verde. A tela 19 não muda: a Literata é a mesma e a chave só ganhou o nome que já tinha.
- [ ] **Passo 6 — commit:** `feat(leitor): o texto do livro na fonte escolhida, com itálico e negrito reais (D-18, G14.1)`.

### Tarefa 4: a área do texto por fonte

**Arquivos:** `lib/features/reader/layout/text_geometry.dart`, `lib/features/reader/layout/page_snapshot.dart`;
testes em `reader_fonts_g14_test.dart` e `test/features/reader/layout/page_text_geometry_test.dart`.

- [ ] **Passo 1 — testes que falham:**

  Em `reader_fonts_g14_test.dart`:

```dart
  test('área do texto (o fundo do grifo) por fonte: ascent + descent de cada uma', () {
    expect(readerTextArea(20.5), moreOrLessEquals(30.44, epsilon: 0.05));
    expect(readerTextArea(20.5, ReaderFontFamily.literata), readerTextArea(20.5));
    // hhea: Lora 1006/−274, Figtree 950/−250, Atkinson 950/−290 (por 1000)
    expect(readerTextArea(20.5, ReaderFontFamily.lora), moreOrLessEquals(1.28 * 20.5, epsilon: 0.05));
    expect(readerTextArea(20.5, ReaderFontFamily.figtree), moreOrLessEquals(1.2 * 20.5, epsilon: 0.05));
    expect(readerTextArea(20.5, ReaderFontFamily.atkinson), moreOrLessEquals(1.24 * 20.5, epsilon: 0.05));
  });
```

  (com `import 'package:app_leitura/features/reader/layout/text_geometry.dart';`).

  Em `page_text_geometry_test.dart`, um teste que abre o livro da tela 19 em Lora:

```dart
  test('G14: na Lora, as caixas da página usam a área do texto da Lora', () async {
    final lora = await EpubReaderDocument.open(
      livro.deps(t: const ReaderTypography(font: ReaderFontFamily.lora)),
    );
    addTearDown(lora.dispose);
    final p = lora.current as PageSnapshot;
    final caixa = p.boxesOf(p.spine, p.shown!.from, p.shown!.from + 5).first;
    expect(caixa.textBottom - caixa.textTop, moreOrLessEquals(readerTextArea(20.5, ReaderFontFamily.lora), epsilon: 1e-6));
  });
```

  (importar `reader_settings.dart` e `reader_typography.dart` se faltarem).

- [ ] **Passo 2 — rodar e ver falhar:** `readerTextArea` não aceita a fonte.
- [ ] **Passo 3 — `text_geometry.dart`:**

```dart
// G13.1 — a área do texto de uma linha como no Chromium: o fundo de um `span` (grifo, seleção) cobre o ascent +
// descent da fonte, centrado na linha (30,44 px na Literata 20,5 com a entrelinha de 35,26 — L21a). G14: medida uma
// vez por (fonte, tamanho), com a mesma família do livro (D-18).
import 'dart:ui' as ui;

import '../domain/reader_settings.dart';
import 'reader_typography.dart';

final Map<(ReaderFontFamily, double), double> _areas = {};

/// ascent + descent da fonte [font] do livro no tamanho [em] (sem a entrelinha).
double readerTextArea(
  double em, [
  ReaderFontFamily font = ReaderFontFamily.literata,
]) => _areas[(font, em)] ??= _measure(font, em);

double _measure(ReaderFontFamily font, double em) {
  final b =
      ui.ParagraphBuilder(
          ui.ParagraphStyle(textDirection: ui.TextDirection.ltr),
        )
        ..pushStyle(
          ui.TextStyle(
            fontFamily: readerFamilyOf(font),
            fontFamilyFallback: readerFontFallback,
            fontSize: em,
            fontWeight: ui.FontWeight.w400,
            fontVariations: [
              ui.FontVariation('opsz', em),
              const ui.FontVariation('wght', readerTextWeight),
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

- [ ] **Passo 4 — `page_snapshot.dart`** (linha ~246): `final area = readerTextArea(em, t.font);`.
- [ ] **Passo 5 — rodar:** os dois arquivos de teste, mais `page_snapshot_test.dart` e `l21_test.dart` → verde.
- [ ] **Passo 6 — commit:** `feat(leitor): fundo do grifo e da seleção na área da fonte escolhida (G14.1)`.

---

## G14.2 — Aplicar um ajuste

### Tarefa 5: `ReaderDocument.retypeset`

**Arquivos:** `reader_document.dart`, `epub_reader_document.dart`, `pdf_reader_document.dart`; teste em
`test/features/reader/application/epub_reader_document_test.dart` (grupo novo).

- [ ] **Passo 1 — teste que falha** (no `main` de `epub_reader_document_test.dart`, que já tem `LivroNaEstante`):

```dart
  group('G14 — retypeset', () {
    test('repagina na página do caractere que a pessoa lia; voltar aos ajustes de antes volta à mesma página', () async {
      final livro = await LivroNaEstante.domCasmurro();
      addTearDown(livro.close);
      await livro.guardarPosicao(2, 0);
      final doc = await EpubReaderDocument.open(livro.deps());
      addTearDown(doc.dispose);
      for (var i = 0; i < 3; i++) {
        expect(await doc.turn(PageDirection.forward), isTrue);
      }
      final lendo = doc.mark;
      final paginas = <ReaderMark>[];
      doc.changes.addListener(() => paginas.add(doc.mark));
      await doc.retypeset(const ReaderTypography(fontSize: 26, font: ReaderFontFamily.atkinson, sideMargin: 40));
      final p = doc.current as PageSnapshot;
      expect((p.typography.font, p.typography.fontSize), (ReaderFontFamily.atkinson, 26.0));
      final s = p.shown!;
      expect(s.unit, lendo.spine);
      expect(lendo.offset, inInclusiveRange(s.from, s.to - 1), reason: 'o caractere que a pessoa lia está na página');
      expect(paginas, isNotEmpty, reason: 'a tela é avisada');
      await doc.retypeset(const ReaderTypography());
      expect(doc.mark, lendo, reason: 'de volta aos ajustes de antes, a mesma página');
    });
  });
```

  Conferir no topo do arquivo os imports de `reader_settings.dart`, `reader_typography.dart`, `page_snapshot.dart`
  e `reader_document.dart`, e acrescentar os que faltarem.

- [ ] **Passo 2 — rodar e ver falhar:** `retypeset` não existe.
- [ ] **Passo 3 — `reader_document.dart`:**
  - importar `../layout/reader_typography.dart` (só o tipo);
  - na interface, depois de `recolor`:

```dart
  /// Os ajustes que mudam as quebras mudaram (tamanho, fonte, entrelinha, margens — G14): repagina e volta à
  /// página do caractere que a pessoa lia; a página de agora continua pintável até a nova chegar, e uma
  /// repaginação mais nova passa na frente. PDF: nada (a página é uma imagem — D-43).
  Future<void> retypeset(ReaderTypography t);
```

  O comentário do topo ganha: "G14: repaginar com os ajustes novos (`retypeset`)".

- [ ] **Passo 4 — EPUB** (depois de `recolor`):

```dart
  @override
  Future<void> retypeset(ReaderTypography t) async {
    // o paginador da G10 guarda o caractere que a pessoa lia (o da última virada ou abertura): mudar várias vezes
    // seguidas volta sempre a ele
    await _pager.relayout(t);
    _announce();
  }
```

- [ ] **Passo 5 — PDF** (depois de `recolor`):

```dart
  /// O PDF não tem layout de texto (D-43): a folha de ajustes nem abre nele (D-122).
  @override
  Future<void> retypeset(ReaderTypography t) async {}
```

  Importar `../layout/reader_typography.dart` em `pdf_reader_document.dart`.

- [ ] **Passo 6 — rodar:** `epub_reader_document_test.dart`, `epub_document_g12_test.dart` e `book_pager_test.dart`
  → verde.
- [ ] **Passo 7 — commit:** `feat(leitor): repaginar o livro aberto com os ajustes novos (G14.2)`.

### Tarefa 6: `applySettings` na sessão

**Arquivos:** `lib/features/reader/application/reader_session_controller.dart`; testes num grupo novo `G14` em
`test/features/reader/application/reader_session_controller_test.dart`.

- [ ] **Passo 1 — testes que falham** (grupo `G14`, dentro do `main`, depois do grupo `G12`):

```dart
  group('G14', () {
    Future<ReaderSettings?> linha() => ReaderSettingsDao(h.livro.db).forUser(usuarioTeste);

    test('applySettings: grava com versão, repagina mantendo o caractere e avisa a tela', () async {
      final c = await aberto();
      for (var i = 0; i < 3; i++) {
        await c.turn(PageDirection.forward);
      }
      final lendo = doc(c).mark;
      var avisos = 0;
      c.addListener(() => avisos++);
      await c.applySettings((l) => l.copyWith(fontStep: 7, fontFamily: ReaderFontFamily.lora));
      expect(c.look, const ReaderLook(fontStep: 7, fontFamily: ReaderFontFamily.lora));
      expect((c.typography!.fontSize, c.typography!.font), (26.0, ReaderFontFamily.lora));
      final p = doc(c).current as PageSnapshot;
      expect(p.typography.font, ReaderFontFamily.lora);
      expect(lendo.offset, inInclusiveRange(p.shown!.from, p.shown!.to - 1));
      final l1 = await linha();
      expect(l1!.look, c.look);
      expect(avisos, greaterThan(0));
      // outra mudança: nova versão (LWW) e de volta ao tamanho de antes, a mesma página
      await c.applySettings((l) => l.copyWith(fontStep: 4, fontFamily: ReaderFontFamily.literata));
      final l2 = await linha();
      expect(l2!.meta.version.compareTo(l1.meta.version), greaterThan(0));
      expect(doc(c).mark, lendo);
      expect(h.erros, isEmpty);
    });

    test('sem linha na conta: cria com os padrões da tela 26 mais a mudança', () async {
      final c = await aberto();
      expect(await linha(), isNull);
      expect(c.look, const ReaderLook());
      await c.applySettings((l) => l.copyWith(margins: ReaderMargins.larga));
      final l = await linha();
      expect((l!.id, l.meta.userId, l.look), (usuarioTeste, usuarioTeste, const ReaderLook(margins: ReaderMargins.larga)));
      expect(c.typography!.sideMargin, 40);
    });

    test('a mesma escolha não grava nem repagina', () async {
      final c = await aberto();
      final antes = doc(c).current;
      await c.applySettings((l) => l);
      expect(await linha(), isNull);
      expect(doc(c).current, same(antes));
    });

    test('só o papel: a cor do texto troca sem repaginar; um papel claro vira o último claro', () async {
      final c = await aberto();
      final quebras = (doc(c).current as PageSnapshot).typography.layoutKey;
      final inicio = doc(c).current.shown;
      await c.applySettings((l) => l.copyWith(paper: ReaderPaper.branco));
      expect(c.paper, ReaderPaper.branco);
      expect(c.palette, ReaderPalette.of(ReaderPaper.branco));
      final p = doc(c).current as PageSnapshot;
      expect((p.typography.layoutKey, p.shown), (quebras, inicio));
      expect(p.typography.ink, ReaderPalette.of(ReaderPaper.branco).text);
      expect(await KvDao(h.livro.db).get(lastLightPaperKey), 'branco');
      // o Noite pela folha guarda o claro de antes; o Tema volta a ele
      await c.applySettings((l) => l.copyWith(paper: ReaderPaper.noite));
      expect(await KvDao(h.livro.db).get(lastLightPaperKey), 'branco');
      await c.toggleTheme();
      expect(c.paper, ReaderPaper.branco);
      expect((await linha())!.paper, ReaderPaper.branco);
    });

    test('toques rápidos somam na fila e a tela termina no último', () async {
      final c = await aberto();
      await Future.wait([
        for (var i = 0; i < 3; i++)
          c.applySettings((l) => l.copyWith(fontStep: math.min(7, l.fontStep + 1))),
      ]);
      expect(c.look.fontStep, 7);
      expect((await linha())!.fontStep, 7);
      expect((doc(c).current as PageSnapshot).typography.fontSize, 26);
    });

    test('falha ao gravar: relatada; os ajustes, a tipografia e a página ficam como estavam', () async {
      final c = await aberto();
      final antes = doc(c).current;
      h.donoFalha = true;
      await c.applySettings((l) => l.copyWith(fontStep: 1));
      expect(c.look, const ReaderLook());
      expect(c.typography!.fontSize, 20.5);
      expect(doc(c).current, same(antes));
      expect(h.erros, [isA<StateError>()]);
      expect(c.state, isA<ReaderReady>());
    });

    test('reabrir: a sessão monta pela linha gravada', () async {
      final c = await aberto();
      await c.applySettings(
        (l) => l.copyWith(fontFamily: ReaderFontFamily.atkinson, lineSpacing: ReaderLineSpacing.solto),
      );
      final c2 = await aberto();
      expect(c2.look, c.look);
      expect((c2.typography!.font, c2.typography!.lineSpacing), (ReaderFontFamily.atkinson, 1.95));
      expect((doc(c2).current as PageSnapshot).typography.font, ReaderFontFamily.atkinson);
    });
  });
```

  Imports a mais no topo do teste: `dart:math` as `math`, `reader_palette.dart` (`ReaderPalette`).

- [ ] **Passo 2 — rodar e ver falhar:** `look` e `applySettings` não existem.
- [ ] **Passo 3 — código:**
  - o comentário do topo ganha: "G14.2 — os ajustes de leitura da folha (tela 26): grava com versão, repagina no
    caractere que a pessoa lia e o último papel claro; o Tema passa pelo mesmo caminho (D-121, D-144).";
  - campos: trocar `ReaderPaper _paper = ReaderPaper.creme;` por

```dart
  /// Os ajustes da conta (a folha da tela 26; os padrões da tela 26 enquanto a conta não tem linha).
  ReaderLook get look => _look;
  ReaderLook _look = const ReaderLook();

  /// Repaginações pedidas: só a mais nova relata falha (as anteriores terminam com ela).
  int _retypes = 0;
```

    e `ReaderPaper get paper => _look.paper;`;
  - em `_open`:

```dart
    final settings = await ReaderSettingsDao(deps.db).forUser(owner);
    _look = settings?.look ?? const ReaderLook();
    _palette = ReaderPalette.of(_look.paper);
    // a tela já pinta o "abrindo" no papel da conta (no Noite, sem passar pelo Creme)
    if (!_disposed) notifyListeners();
    final t = _typography = _typographyFor(_look, v, _palette.text);
```

  - `_typographyFor`:

```dart
  ReaderTypography _typographyFor(ReaderLook l, ReaderViewport v, Color ink) =>
      ReaderTypography.fromLook(
        l,
        viewportWidth: v.size.width,
        viewportHeight: v.size.height,
        topInset: _insets.top,
        bottomInset: _insets.bottom,
        ink: ink,
      );
```

    (`Color` vem de `package:flutter/painting.dart`; acrescentar ao `show EdgeInsets, Size`);
  - `toggleTheme` e o novo `applySettings`:

```dart
  /// A folha de ajustes (tela 26, D-144): aplica [change] sobre os ajustes de agora, na fila (toques rápidos
  /// somam), e grava a linha da conta com versão. Se o papel mudou, guarda o último claro (D-121). Tamanho, fonte,
  /// entrelinha e margens repaginam na página do caractere que a pessoa lia; a repaginação mais nova passa na
  /// frente, sem segurar a fila. Só o papel troca a cor do texto sem repaginar. Falha ao gravar: relatada, e tudo
  /// fica como estava. Termina quando a página nova chega.
  Future<void> applySettings(ReaderLookChange change) async {
    final doc = _doc;
    if (doc == null || _closed || _state is ReaderFailed) return;
    interaction();
    final pending = await _serial(() => _applyLook(doc, change));
    await pending?.relayout;
  }

  /// O botão Tema (D-37, D-121): de um papel claro para o Noite e do Noite de volta ao último claro (Creme se não
  /// houver) — o mesmo caminho da folha.
  Future<void> toggleTheme() async {
    final doc = _doc;
    if (doc == null || _closed || _state is ReaderFailed) return;
    interaction();
    await _serial(() async {
      final ReaderPaper next;
      try {
        next = _look.paper == ReaderPaper.noite
            ? await _lastLight()
            : ReaderPaper.noite;
      } on Object catch (e, st) {
        deps.onError(e, st);
        return null;
      }
      return _applyLook(doc, (l) => l.copyWith(paper: next));
    });
  }

  Future<ReaderPaper> _lastLight() async {
    final light = await KvDao(deps.db).get(lastLightPaperKey);
    return ReaderPaper.values.firstWhere(
      (p) => p.code == light && p != ReaderPaper.noite,
      orElse: () => ReaderPaper.creme,
    );
  }

  /// Aplica (na fila): grava, troca a cor ou pede a repaginação e avisa a tela. [relayout] = a repaginação em
  /// curso (quem pediu espera por ela; a fila não).
  Future<({Future<void> relayout})?> _applyLook(
    ReaderDocument doc,
    ReaderLookChange change,
  ) async {
    if (_closed || !identical(_doc, doc)) return null;
    final from = _look;
    final next = change(from);
    if (next == from) return null;
    try {
      await _save(from, next);
    } on Object catch (e, st) {
      // ajuste é conforto: uma falha do banco não derruba a leitura (tudo fica como estava)
      deps.onError(e, st);
      return null;
    }
    if (_closed || _disposed) return null;
    final palette = ReaderPalette.of(next.paper);
    Future<void>? relayout;
    if (next.sameLayout(from)) {
      // só o papel: o texto troca de cor antes (as mesmas quebras); o papel e as ilhas animam em seguida
      await doc.recolor(palette.text);
      if (_closed || _disposed) return null;
      _typography = _typography?.withInk(palette.text);
    } else {
      final t = _typography = _typographyFor(next, _viewport!, palette.text);
      final gen = ++_retypes;
      relayout = doc.retypeset(t).catchError((Object e, StackTrace st) {
        if (gen == _retypes) _navFailed(e, st);
      });
    }
    _look = next;
    _palette = palette;
    notifyListeners();
    return relayout == null ? null : (relayout: relayout);
  }

  /// Grava os ajustes da conta (versão HLC; sem linha, cria com os padrões da tela 26). O último claro (D-121) vai
  /// só depois do ajuste gravado: o papel claro escolhido, ou o claro que se deixou pelo Noite.
  Future<void> _save(ReaderLook from, ReaderLook next) async {
    final owner = await deps.owner();
    final dao = ReaderSettingsDao(deps.db);
    await deps.versioning.write('reader_settings', owner, (v) async {
      final at = DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true);
      final old = await dao.forUser(owner);
      await dao.upsert(
        old == null
            ? ReaderSettings(
                id: owner,
                meta: RecordMeta(
                  userId: owner,
                  createdAt: at,
                  updatedAt: at,
                  version: v,
                ),
              ).withLook(next)
            : old.withLook(next, meta: old.meta.edited(at, v)),
      );
    });
    if (next.paper == from.paper) return;
    final light = next.paper != ReaderPaper.noite ? next.paper : from.paper;
    if (light != ReaderPaper.noite) {
      await KvDao(deps.db).set(lastLightPaperKey, light.code);
    }
  }
```

  - apagar o corpo antigo de `toggleTheme`.

- [ ] **Passo 4 — rodar:** `reader_session_controller_test.dart` inteiro → verde. Os testes do Tema da G12
  (Creme → Noite → Creme, Sépia, falha do banco) continuam passando sem mudança.
- [ ] **Passo 5 — rodar também** `reader_screen_g12_test.dart` (o Tema pela tela).
- [ ] **Passo 6 — commit:** `feat(leitor): aplicar um ajuste grava, repagina no caractere e passa na fila (D-144, G14.2)`.

---

## G14.3 — A folha da tela 26

### Tarefa 7: cores, a legenda nas ilhas e os ícones da folha

**Arquivos:** `lib/core/design_system/tokens/app_colors.dart`, `app_icons_leitor.dart`,
`lib/features/reader/presentation/reader_chrome_palette.dart`; testes `reader_chrome_palette_test.dart` e
`test/design_system/leitor_svgs_g12_test.dart` (a lista `all` já é conferida).

- [ ] **Passo 1 — teste que falha** (`reader_chrome_palette_test.dart`, um teste novo):

```dart
  test('G14: a legenda dos cartões de fonte — #8A8073 nos claros, #B5AA98 no Noite; anima e esmaece', () {
    final c = ReaderChromePalette.of(ReaderPaper.creme);
    final n = ReaderChromePalette.of(ReaderPaper.noite);
    expect((hex(c.caption), hex(n.caption)), ('FF8A8073', 'FFB5AA98'));
    expect(hex(ReaderChromePalette.of(ReaderPaper.sepia).caption), 'FF8A8073');
    expect(ReaderChromePalette.lerp(c, n, 0.5).caption, Color.lerp(c.caption, n.caption, 0.5));
    expect(c.faded(0.5).caption.a, closeTo(0.5, 1e-6));
    expect(c == ReaderChromePalette.of(ReaderPaper.creme), isTrue);
  });
```

- [ ] **Passo 2 — rodar e ver falhar:** `caption` não existe.
- [ ] **Passo 3 — `app_colors.dart`** (no bloco do leitor, depois de `labelReader`):

```dart
  /// Legendas dos cartões de fonte fora da escolhida (L26 `rs.sheet.fonts.*.caption`; "inkSoft" da L00).
  static const Color inkSoft = Color(0xFF8A8073);

  /// Legenda do cartão de fonte escolhido, sobre a `brand` (L26).
  static const Color captionOnBrand = Color(0xFF3B3466);

  /// As duas linhas dos cartões de papel (L26 `rs.sheet.papers.*.line*`); as do Noite são o [dashNight].
  static const Color paperLineCream = Color(0xFFD9CCB4);
  static const Color paperLineWhite = Color(0xFFE3DCCD);
  static const Color paperLineSepia = Color(0xFFCDB48C);
```

- [ ] **Passo 4 — `reader_chrome_palette.dart`:** o campo novo `caption`:
  - no construtor;
  - no `of`: `caption: AppColors.mutedNight` no Noite e `caption: AppColors.inkSoft` nos claros;
  - no `faded`, no `lerp`, no `==` e no `hashCode`;
  - o comentário: `/// Legenda dos cartões de fonte da folha de ajustes (G14 — L26; no Noite, a cor do autor).`.
- [ ] **Passo 5 — `app_icons_leitor.dart`** (antes de `all`, e todos na lista `all`):

```dart
  /// (18) fechar a folha de ajustes (`rs.sheet.close.icon`); (12) o ✓ do papel escolhido
  /// (`rs.sheet.papers.*.check.icon`, sobre a `brand`).
  static const closeRound = '$_d/ic_close_round.svg';
  static const checkSmall = '$_d/ic_check_small.svg';

  /// (18) Entrelinha e Margens da folha (`rs.sheet.spacing.*.icon`, `rs.sheet.margins.*.icon`). Sem versão do Noite:
  /// lá são tingidos com a cor do título, menos no escolhido (sobre a `brand`) — G14.
  static const spacingTight = '$_d/ic_spacing_tight.svg';
  static const spacingMedium = '$_d/ic_spacing_medium.svg';
  static const spacingLoose = '$_d/ic_spacing_loose.svg';
  static const marginsNarrow = '$_d/ic_margins_narrow.svg';
  static const marginsMedium = '$_d/ic_margins_medium.svg';
  static const marginsWide = '$_d/ic_margins_wide.svg';
```

- [ ] **Passo 6 — rodar:** `reader_chrome_palette_test.dart`, `leitor_svgs_g12_test.dart`, `leitor_svgs_test.dart`,
  `app_colors_test.dart` e `islands_test.dart` → verde.
- [ ] **Passo 7 — commit:** `feat(leitor): cores, legenda das ilhas e ícones da folha de ajustes (G14.3)`.

### Tarefa 8: as letras da folha

**Arquivos:** `pubspec.yaml`, `lib/core/design_system/tokens/app_typography.dart`; teste novo
`test/design_system/fontes_leitor_g14_test.dart`.

- [ ] **Passo 1 — teste que falha** (as larguras são as da tabela de linhas da L26):

```dart
// G14.3 — as letras da folha de ajustes contra as medidas da prancha 26 (L26, "Linhas de texto"): a Bricolage 23
// e a Instrument Serif 28 do título, a Literata estática dos "A" (15 e 25/500), do "Aa" dos cartões (26 e 18 — D-104),
// o "Aa" na própria fonte (Lora, Figtree, Atkinson — as do livro) e a Figtree dos rótulos, nomes e opções.
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/load_fonts.dart';

double largura(InlineSpan s) {
  final p = TextPainter(text: s, textDirection: TextDirection.ltr)..layout();
  final w = p.width;
  p.dispose();
  return w;
}

double de(String t, TextStyle s) => largura(TextSpan(text: t, style: s));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  test('famílias novas: Bricolage 23 e Literata estática 15/500, 18, 25/500, 26', () {
    expect(AppFonts.bricolageOpsz, contains(23));
    expect(
      [
        AppTextStyles.readerSheetSmallA.fontFamily,
        AppTextStyles.readerSheetLargeA.fontFamily,
        AppTextStyles.readerSheetPaperSample.fontFamily,
        AppTextStyles.readerSheetSampleLiterata.fontFamily,
      ],
      ['Literata15', 'Literata25', 'Literata18', 'Literata26'],
    );
    expect(AppTextStyles.readerSheetSampleLora.fontFamily, 'LoraBook');
    expect(AppTextStyles.readerSheetSampleAtkinson.fontFamily, 'AtkinsonBook');
  });

  test('título "Ajustes de leitura" = 181,16 ±1 (Bricolage 23/800 + Instrument Serif itálico 28)', () {
    final t = TextSpan(
      children: [
        TextSpan(text: 'Ajustes ', style: AppTextStyles.readerSheetTitle),
        TextSpan(text: 'de leitura', style: AppTextStyles.readerSheetTitleSerif),
      ],
    );
    expect(largura(t), closeTo(181.16, 1.0));
    expect(de('Ajustes', AppTextStyles.readerSheetTitle), closeTo(110.88 - 29.5, 1.0));
  });

  test('tamanho e amostras', () {
    expect(de('A', AppTextStyles.readerSheetSmallA), closeTo(11.08, 1.0));
    expect(de('A', AppTextStyles.readerSheetLargeA), closeTo(18.24, 1.0));
    expect(de('Aa', AppTextStyles.readerSheetSampleLiterata), closeTo(32.71, 1.0));
    expect(de('Aa', AppTextStyles.readerSheetSampleLora), closeTo(30.39, 1.0));
    expect(de('Aa', AppTextStyles.readerSheetSampleFigtree), closeTo(30.69, 1.0));
    expect(de('Aa', AppTextStyles.readerSheetSampleAtkinson), closeTo(29.95, 1.0));
    expect(de('Aa', AppTextStyles.readerSheetPaperSample), closeTo(22.81, 1.0));
  });

  test('rótulos, nomes, legendas, opções e a pílula', () {
    expect(de('FONTE', AppTextStyles.readerSheetLabel), closeTo(42.41, 1.0));
    expect(de('ENTRELINHA', AppTextStyles.readerSheetLabel), closeTo(81.26, 1.0));
    expect(de('Literata', AppTextStyles.readerSheetFontName), closeTo(43.95, 1.0));
    expect(de('Atkinson', AppTextStyles.readerSheetFontName), closeTo(50.29, 1.0));
    expect(de('sem serifa', AppTextStyles.readerSheetCaption), closeTo(48.84, 1.0));
    expect(de('Creme', AppTextStyles.readerSheetPaperNameOn), closeTo(37.51, 1.0));
    expect(de('Branco', AppTextStyles.readerSheetPaperName), closeTo(38.63, 1.0));
    expect(de('Justo', AppTextStyles.readerSheetOption), closeTo(33.28, 1.0));
    expect(de('Médio', AppTextStyles.readerSheetOptionOn), closeTo(37.46, 1.0));
    expect(de('prévia ao vivo', AppTextStyles.readerSheetPill), closeTo(74.78, 1.0));
  });

  test('alturas de linha: as "normais" das fontes (título 36,4; rótulo 13,2; nome 14,4)', () {
    expect(
      (AppTextStyles.readerSheetTitle.height, AppTextStyles.readerSheetTitleSerif.height),
      (1.2, 1.3),
    );
    expect(AppTextStyles.readerSheetLabel.height, 1.2);
    expect(AppTextStyles.readerSheetSampleLora.height, 1.1);
    expect(AppTextStyles.readerSheetPaperSample.height, 1.0);
    expect(AppTextStyles.readerSheetSmallA.height, isNull, reason: 'line-height normal da Literata (1,485)');
  });
}
```

- [ ] **Passo 2 — rodar e ver falhar:** os estilos e as famílias não existem.
- [ ] **Passo 3 — `pubspec.yaml`:** as famílias estáticas da interface, no molde das que existem (`Literata17`,
  `Bricolage17`):
  - `Bricolage23`, `Bricolage23Ext` e `Bricolage23Vi`: `Bricolage23{,Ext,Vi}-ExtraBold.ttf`, peso 800;
  - `Literata15`, `Literata15Ext` e `Literata15Vi`: `Literata15{,Ext,Vi}-Medium.ttf`, peso 500;
  - `Literata18`, `Literata18Ext` e `Literata18Vi`: `Literata18{,Ext,Vi}-Regular.ttf`, peso 400;
  - `Literata25`, `Literata25Ext` e `Literata25Vi`: `Literata25{,Ext,Vi}-Medium.ttf`, peso 500;
  - `Literata26`, `Literata26Ext` e `Literata26Vi`: `Literata26{,Ext,Vi}-Regular.ttf`, peso 400.

  Os arquivos já estão em `assets/fonts` desde a G01. O comentário de cima do bloco novo diz: "G14 (L26): instâncias
  da G01 para a folha de ajustes".
- [ ] **Passo 4 — `app_typography.dart`:**
  - `AppFonts.bricolageOpsz` ganha o 23;
  - `AppFonts.literataStatic` ganha `15: {500}`, `18: {400}`, `25: {500}` e `26: {400}`;
  - `import 'reader_fonts.dart';` já existe (o `literataBook`);
  - em `AppTextStyles`, depois de `readerSearchExcerpt`:

```dart
  // Leitor — folha de ajustes (tela 26, G14). Cores da Creme; a folha troca pela paleta das ilhas.

  /// rs.sheet.title: "Ajustes" Bricolage 23/800 (ls −0,5) + "de leitura" Instrument Serif itálico 28 (ls −0,2),
  /// as alturas normais das fontes (1,2 e 1,3: a linha tem 36,4).
  static final TextStyle readerSheetTitle = AppFonts.bricolage(
    23,
    height: 1.2,
    letterSpacing: -0.5,
  );
  static final TextStyle readerSheetTitleSerif = AppFonts.serif(
    28,
    height: 1.3,
    italic: true,
    letterSpacing: -0.2,
  );

  /// rs.sheet.size.smaller/larger: Literata estática 15/500 e 25/500 (D-104), altura normal.
  static final TextStyle readerSheetSmallA = AppFonts.literata(15, FontWeight.w500);
  static final TextStyle readerSheetLargeA = AppFonts.literata(25, FontWeight.w500);

  /// "FONTE", "PAPEL", "ENTRELINHA", "MARGENS": Figtree 11/800, ls 1,2, altura normal.
  static final TextStyle readerSheetLabel = AppFonts.figtreeReader(
    11,
    FontWeight.w800,
    letterSpacing: 1.2,
    color: AppColors.labelReader,
  );

  /// O "Aa" de cada cartão de fonte, na própria fonte, 26 com `line-height: 1.1`. A Literata é a estática
  /// (D-104); Lora e Atkinson são as do livro (D-18); a Figtree, a da interface (é a mesma letra).
  static final TextStyle readerSheetSampleLiterata = AppFonts.literata(
    26,
    FontWeight.w400,
    height: 1.1,
  );
  static const TextStyle readerSheetSampleLora = TextStyle(
    fontFamily: readerLoraFamily,
    fontSize: 26,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
    height: 1.1,
    color: AppColors.ink,
    leadingDistribution: TextLeadingDistribution.even,
  );
  static final TextStyle readerSheetSampleFigtree = AppFonts.figtreeReader(
    26,
    FontWeight.w400,
    height: 1.1,
  );
  static const TextStyle readerSheetSampleAtkinson = TextStyle(
    fontFamily: readerAtkinsonFamily,
    fontSize: 26,
    fontWeight: FontWeight.w400,
    height: 1.1,
    color: AppColors.ink,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// rs.sheet.fonts.*.name (12/800) e .caption (10,5/600).
  static final TextStyle readerSheetFontName = AppFonts.figtreeReader(12, FontWeight.w800);
  static final TextStyle readerSheetCaption = AppFonts.figtreeReader(
    10.5,
    FontWeight.w600,
    color: AppColors.inkSoft,
  );

  /// O "Aa" do cartão de papel: Literata estática 18, `line-height: 1`.
  static final TextStyle readerSheetPaperSample = AppFonts.literata(
    18,
    FontWeight.w400,
    height: 1,
  );

  /// Nome do papel: 12/700; o escolhido, 12/800.
  static final TextStyle readerSheetPaperName = AppFonts.figtreeReader(12, FontWeight.w700);
  static final TextStyle readerSheetPaperNameOn = AppFonts.figtreeReader(12, FontWeight.w800);

  /// Opção da Entrelinha e das Margens: 13/700; a escolhida, 13/800.
  static final TextStyle readerSheetOption = AppFonts.figtreeReader(13, FontWeight.w700);
  static final TextStyle readerSheetOptionOn = AppFonts.figtreeReader(13, FontWeight.w800);

  /// A pílula "prévia ao vivo": Figtree 11,5/800.
  static final TextStyle readerSheetPill = AppFonts.figtreeReader(11.5, FontWeight.w800);
```

  Se o `TextStyle` const não aceitar a `FontVariation` const, trocar por `static final`.
- [ ] **Passo 5 — rodar:** `fontes_leitor_g14_test.dart`, `app_typography_test.dart`, `fonts_smoke_test.dart` e
  `fontes_leitor_g12_test.dart` → verde. Se uma largura passar de ±1, conferir a família no `FontManifest` antes de
  mexer na tolerância.
- [ ] **Passo 6 — commit:** `feat(leitor): as letras da folha de ajustes (Bricolage 23, Literata estática, amostras) (G14.3)`.

### Tarefa 9: o trilho tracejado e a opção de grupo

**Arquivos:** `lib/core/design_system/painters/dashed_stadium_painter.dart` (novo),
`lib/core/design_system/widgets/pressable.dart`; testes `test/design_system/g14_primitivos_test.dart` (novo) e
`test/home/performance_test.dart`.

- [ ] **Passo 1 — testes que falham** (`g14_primitivos_test.dart`):

```dart
// G14.3 — o que a folha de ajustes pede dos primitivos: o contorno tracejado da pílula (trilho do tamanho:
// `border: 1.5px dashed`, traço 3 e vão ~1,5 como o Chromium, medido na prancha @3x) e a opção de um grupo
// (radio: marcada ou não, num grupo exclusivo — não um botão).
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/painters/dashed_stadium_painter.dart';
import 'package:app_leitura/core/design_system/widgets/pressable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Tela implements ui.Canvas {
  final tracos = <(ui.Path, Paint)>[];

  @override
  void drawPath(ui.Path path, Paint paint) => tracos.add((path, paint));

  @override
  Float64List getTransform() => Float64List(16);

  @override
  Object? noSuchMethod(Invocation invocation) => null;
}

void main() {
  test('DashedStadiumPainter: traços de 3 com vão ~1,5 que fecham a pílula; traço de 1,5 na cor', () {
    final tela = _Tela();
    const DashedStadiumPainter(color: Color(0xFFCFC3AE)).paint(tela, const Size(215, 48));
    // contorno no meio do traço: 213,5 × 46,5 com raio 23,25 → 2 × 167 + π × 46,5 = 480,08
    expect(tela.tracos, hasLength((480.08 / 4.5).round()));
    for (final (path, paint) in tela.tracos) {
      expect(path.computeMetrics().single.length, moreOrLessEquals(3, epsilon: 0.01));
      expect((paint.style, paint.strokeWidth, paint.color.toARGB32()), (PaintingStyle.stroke, 1.5, 0xFFCFC3AE));
    }
    final b = tela.tracos.map((t) => t.$1.getBounds()).reduce((a, c) => a.expandToInclude(c));
    expect(b.left, moreOrLessEquals(0.75, epsilon: 0.01));
    expect(b.right, moreOrLessEquals(214.25, epsilon: 0.01));
  });

  testWidgets('Pressable com checked: opção de um grupo, marcada ou não (não é botão)', (tester) async {
    final h = tester.ensureSemantics();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Pressable(
              key: const ValueKey('a'),
              semanticsLabel: 'Lora, clássica',
              checked: true,
              onTap: () {},
              child: const SizedBox(width: 20, height: 20),
            ),
            Pressable(
              key: const ValueKey('b'),
              semanticsLabel: 'Figtree, sem serifa',
              checked: false,
              onTap: () {},
              child: const SizedBox(width: 20, height: 20),
            ),
          ],
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byKey(const ValueKey('a'))),
      isSemantics(
        label: 'Lora, clássica',
        hasCheckedState: true,
        isChecked: true,
        isInMutuallyExclusiveGroup: true,
        isButton: false,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.byKey(const ValueKey('b'))),
      isSemantics(
        label: 'Figtree, sem serifa',
        hasCheckedState: true,
        isChecked: false,
        isInMutuallyExclusiveGroup: true,
        isButton: false,
        hasTapAction: true,
      ),
    );
    h.dispose();
  });
}
```

  E no `performance_test.dart`:
  - o import do pintor novo;
  - o `'DashedStadiumPainter'` no conjunto de "todo pintor do app está coberto aqui";
  - um teste novo no grupo dos pintores:

```dart
    test('DashedStadiumPainter (espessura, cor) — G14', () {
      _expectRepaintsOnlyOnChange(() => const DashedStadiumPainter(), {
        'thickness': () => const DashedStadiumPainter(thickness: 1.2),
        'color': () => const DashedStadiumPainter(color: AppColors.ink),
      });
    });
```

- [ ] **Passo 2 — rodar e ver falhar.**
- [ ] **Passo 3 — `dashed_stadium_painter.dart`:**

```dart
import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_strokes.dart';

/// `border: 1.5px dashed` de uma pílula (`border-radius: 999px`), como o Chromium: traço = 2 × espessura e vão ideal
/// = espessura (o trilho do tamanho na tela 26 — medido na prancha @3x: 3 e ~1,5). O contorno é fechado: o vão é
/// ajustado para caber um número inteiro de traços.
class DashedStadiumPainter extends CustomPainter {
  const DashedStadiumPainter({
    this.thickness = AppStrokes.regular,
    this.color = AppColors.dashReader,
  });

  final double thickness;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final h = thickness / 2;
    final box = (Offset.zero & size).deflate(h);
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(box, Radius.circular(box.shortestSide / 2)),
      );
    final metric = path.computeMetrics().first;
    final dash = 2 * thickness;
    final n = math.max(1, (metric.length / (dash + thickness)).round());
    final step = metric.length / n;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    for (var i = 0; i < n; i++) {
      canvas.drawPath(metric.extractPath(i * step, i * step + dash), paint);
    }
  }

  @override
  bool shouldRepaint(DashedStadiumPainter old) =>
      old.thickness != thickness || old.color != color;
}
```

- [ ] **Passo 4 — `pressable.dart`:** o campo novo e a semântica:

```dart
  /// Opção de um grupo (radio — a fonte, o papel, a entrelinha e as margens da folha de ajustes, G14): marcada ou
  /// não; o nó vira uma opção num grupo exclusivo, não um botão.
  final bool? checked;
```

  No construtor, `this.checked,`. No `Semantics` do `build`:

```dart
      button: !widget.isLink && widget.checked == null,
      link: widget.isLink,
      checked: widget.checked,
      inMutuallyExclusiveGroup: widget.checked == null ? null : true,
```

- [ ] **Passo 5 — rodar:** `g14_primitivos_test.dart`, `performance_test.dart`, `primitives_test.dart` e
  `g12_primitivos_test.dart` → verde.
- [ ] **Passo 6 — commit:** `feat(design): contorno tracejado da pílula e opção de grupo no Pressable (G14.3)`.

### Tarefa 10: a folha — lugar, abrir e fechar, título e o ×

**Arquivos:** `lib/features/reader/presentation/reader_settings_sheet.dart` (novo); teste novo
`test/features/reader/presentation/reader_settings_sheet_test.dart`.

- [ ] **Passo 1 — testes que falham** (`reader_settings_sheet_test.dart`):

```dart
// G14.3 — a folha da tela 26 (L26) sozinha: o lugar da folha, da pílula, do papel que cobre a página abaixo do corte
// e do nó "Prévia da página" (com as áreas do aparelho); abrir e fechar em 150 ms; fechar pelo ×, pela página de cima
// e puxando pela alça (D-141); as opções pedindo a mudança; a semântica; e o Noite nas cores das ilhas (D-143).
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_settings_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/canvas.dart';
import '../../../support/load_fonts.dart';
import '../../../support/precache_svgs.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

/// O que a folha pediu (cada pedido aplicado aos ajustes mostrados) e quantas vezes fechou.
final class _Mesa {
  final pedidos = <ReaderLook>[];
  var fechou = 0;
}

Future<_Mesa> _montar(
  WidgetTester tester, {
  bool open = true,
  ReaderLook look = const ReaderLook(),
  ReaderPaper papel = ReaderPaper.creme,
  EdgeInsets area = EdgeInsets.zero,
  _Mesa? mesa,
}) async {
  final m = mesa ?? _Mesa();
  setCanvasView(tester, logical: const Size(390, 844));
  await precacheSvgs(tester, AppIconsLeitor.all);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: const Size(390, 844), viewPadding: area, padding: area),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: ReaderSettingsSheet(
          open: open,
          look: look,
          palette: ReaderChromePalette.of(papel),
          paper: ReaderPalette.of(papel).paper,
          brand: AppColors.lavender,
          page: (left: 28, top: 92, width: 334),
          pageText: 'Retórica dos namorados, dá-me uma comparação exata e poética…',
          onChange: (c) => m.pedidos.add(c(look)),
          onClose: () => m.fechou++,
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 150));
  return m;
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('aberta: a folha a 10 das bordas e da base; o papel cobre a página 15,2 abaixo do topo dela; a prévia e a pílula', (
    tester,
  ) async {
    await _montar(tester);
    final folha = tester.getRect(_key('rs.sheet'));
    expect((folha.left, folha.width, folha.bottom), (10.0, 370.0, 834.0));
    expect(folha.height, moreOrLessEquals(547.2, epsilon: 0.5));
    expect(tester.getRect(_key('rs.paper')).top, moreOrLessEquals(folha.top + 15.2, epsilon: 1e-6));
    expect(tester.getRect(_key('rs.page')), Rect.fromLTRB(28, 92, 362, folha.top + 15.2));
    final pilula = tester.getRect(_key('rs.livePill'));
    expect((pilula.top, pilula.center.dx, pilula.height), (54.0, 195.0, 26.0));
    expect(tester.getRect(_key('rs.livePill.dot')).topLeft - pilula.topLeft, const Offset(12.5, 9.5));
  });

  testWidgets('com as áreas do aparelho: base max(10, baixo − 24), pílula max(54, cima + 7)', (tester) async {
    await _montar(tester, area: const EdgeInsets.only(top: 47, bottom: 34));
    expect(tester.getRect(_key('rs.sheet')).bottom, 834);
    expect(tester.getRect(_key('rs.livePill')).top, 54);
    await _montar(tester, area: const EdgeInsets.only(top: 59, bottom: 50));
    expect(tester.getRect(_key('rs.sheet')).bottom, 844 - 26);
    expect(tester.getRect(_key('rs.livePill')).top, 66);
  });


  testWidgets('abre e fecha em 150 ms subindo e descendo; fechada não monta nada; fechando não pega toque', (
    tester,
  ) async {
    final m = _Mesa();
    final aberta = ValueNotifier(false);
    setCanvasView(tester, logical: const Size(390, 844));
    await precacheSvgs(tester, AppIconsLeitor.all);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ValueListenableBuilder<bool>(
            valueListenable: aberta,
            builder: (_, open, _) => ReaderSettingsSheet(
              open: open,
              look: const ReaderLook(),
              palette: ReaderChromePalette.of(ReaderPaper.creme),
              paper: ReaderPalette.of(ReaderPaper.creme).paper,
              brand: AppColors.lavender,
              page: (left: 28, top: 92, width: 334),
              pageText: '',
              onChange: (_) {},
              onClose: () => m.fechou++,
            ),
          ),
        ),
      ),
    );
    expect(_key('rs.sheet'), findsNothing, reason: 'fechada, nada montado');
    aberta.value = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 75));
    final meio = tester.getRect(_key('rs.sheet')).top;
    await tester.pump(const Duration(milliseconds: 75));
    final topo = tester.getRect(_key('rs.sheet')).top;
    expect(topo, moreOrLessEquals(844 - 10 - 547.2, epsilon: 0.5));
    expect(meio, greaterThan(topo + 100), reason: 'no meio da subida');
    aberta.value = false;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 75));
    expect(tester.getRect(_key('rs.sheet')).top, greaterThan(topo + 100));
    await tester.tapAt(const Offset(195, 200));
    expect(m.fechou, 0, reason: 'fechando, os toques passam');
    await tester.pump(const Duration(milliseconds: 75));
    expect(_key('rs.sheet'), findsNothing);
  });
```

  Os outros testes desta tarefa:

```dart
  testWidgets('fecha pelo × e pelo toque na página de cima (D-141); tocar na folha não fecha', (tester) async {
    final m = await _montar(tester);
    await tester.tap(_key('rs.sheet.close'));
    expect(m.fechou, 1);
    await tester.tapAt(const Offset(195, 200));
    expect(m.fechou, 2);
    await tester.tapAt(const Offset(60, 330)); // o título
    expect(m.fechou, 2);
  });

  testWidgets('puxar pela alça: 64 para baixo fecha; pouco volta ao lugar', (tester) async {
    final m = await _montar(tester);
    final topo = tester.getRect(_key('rs.sheet')).top;
    final alca = tester.getCenter(_key('rs.sheet.grabber'));
    await tester.dragFrom(alca, const Offset(0, 30));
    await tester.pump();
    expect(m.fechou, 0);
    expect(tester.getRect(_key('rs.sheet')).top, topo);
    final g = await tester.startGesture(alca);
    await g.moveBy(const Offset(0, 20));
    await g.moveBy(const Offset(0, 20));
    await tester.pump();
    expect(tester.getRect(_key('rs.sheet')).top, greaterThan(topo + 30), reason: 'a folha acompanha o dedo');
    await g.moveBy(const Offset(0, 40));
    await g.up();
    await tester.pump();
    expect(m.fechou, 1);
  });

  testWidgets('título "Ajustes de leitura" e o × de 44 com o ícone de 18', (tester) async {
    await _montar(tester);
    final titulo = tester.widget<AppText>(_key('rs.sheet.title'));
    expect(titulo.span.toPlainText(), 'Ajustes de leitura');
    final x = tester.getRect(_key('rs.sheet.close'));
    final folha = tester.getRect(_key('rs.sheet'));
    expect(x.topLeft - folha.topLeft, const Offset(306.5, 24.5));
    expect(x.size, const Size(44, 44));
    expect(tester.widget<AppSvg>(_key('rs.sheet.close.icon')).asset, AppIconsLeitor.closeRound);
    final caixa = tester.widget<NeoBox>(_key('rs.sheet'));
    expect(
      (caixa.color, caixa.border, caixa.shadow, caixa.shadowColor),
      (AppColors.surface, const BorderSide(width: 1.5, color: AppColors.ink), const Offset(0, 4), AppColors.ink),
    );
    expect(
      caixa.radius,
      const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
        bottomLeft: Radius.circular(44),
        bottomRight: Radius.circular(44),
      ),
    );
  });

  testWidgets('semântica: diálogo "Ajustes de leitura", a "Prévia da página" com o texto, "Fechar"; a pílula de fora', (
    tester,
  ) async {
    final h = tester.ensureSemantics();
    await _montar(tester);
    expect(find.bySemanticsLabel('Ajustes de leitura'), findsOneWidget);
    expect(
      tester.getSemantics(_key('rs.page')),
      isSemantics(label: 'Prévia da página', value: 'Retórica dos namorados, dá-me uma comparação exata e poética…'),
    );
    expect(find.bySemanticsLabel('Fechar'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('prévia ao vivo')), findsNothing);
    h.dispose();
  });

  testWidgets('Noite (D-143): folha, pílula e × nas cores das ilhas do Noite', (tester) async {
    await _montar(tester, papel: ReaderPaper.noite);
    final n = ReaderChromePalette.of(ReaderPaper.noite);
    final caixa = tester.widget<NeoBox>(_key('rs.sheet'));
    expect((caixa.color, caixa.border!.color, caixa.shadowColor), (n.island, n.border, n.shadow));
    final pilula = tester.widget<NeoBox>(_key('rs.livePill'));
    expect((pilula.color, pilula.border!.color), (n.island, n.border));
    expect(tester.widget<AppSvg>(_key('rs.sheet.close.icon')).color, n.title);
    expect(tester.widget<ColoredBox>(_key('rs.paper')).color, ReaderPalette.of(ReaderPaper.noite).paper);
  });
}
```

  Este passo cria o arquivo com os testes desta tarefa. A altura de 547,2 (no 1º teste e no topo de
  `844 − 10 − 547,2` do teste de abrir e fechar) só fecha depois da Tarefa 12. Até lá, esses dois `expect` ficam
  de fora (o de abrir e fechar confere só `meio > topo + 100`) e voltam na Tarefa 12.

- [ ] **Passo 2 — rodar e ver falhar:** o arquivo da folha não existe.
- [ ] **Passo 3 — `reader_settings_sheet.dart`** (a moldura; as Tarefas 11 e 12 completam a coluna):

```dart
// G14.3 — tela 26, a folha de ajustes de leitura (L26): a página do leitor fica viva em cima (a "prévia" é ela,
// não um `Text` à parte) e a folha embaixo. Ela tem tamanho (7 passos), fonte, papel, entrelinha e margens; cada
// toque pede a mudança à sessão, que grava e repagina (D-144). Abre e fecha em 150 ms subindo e descendo. Fecha pelo
// ×, tocando na página de cima ou puxando pela alça (D-141). No Noite, as cores das ilhas (D-143). Abaixo de 15,2
// do topo da folha, o papel cobre a página (L26: a prévia tem 210 e a folha começa em 286,8).
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/circle_icon_button.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../domain/reader_settings.dart';
import 'reader_chrome_palette.dart';
import 'reader_controls.dart' show readerControlsLayout;
import 'reader_overlays.dart' show readerFade;

/// A folha fica a 10 das bordas.
const double readerSheetSide = 10;

/// A página aparece até 15,2 abaixo do topo da folha (L26).
const double readerSheetPagePeek = 15.2;

/// Puxar pela alça fecha a partir de 64 para baixo, ou com o dedo a 700/s.
const double readerSheetDismissDrag = 64;
const double readerSheetDismissVelocity = 700;

/// A base da folha: 10 no canvas e num iPhone 390×844 (área de baixo 34).
double readerSheetBottom(EdgeInsets viewPadding) =>
    math.max(10.0, viewPadding.bottom - 24);

/// Onde fica a caixa do texto da página (o nó "Prévia da página" do leitor de tela).
typedef ReaderSheetPage = ({double left, double top, double width});

class ReaderSettingsSheet extends StatefulWidget {
  const ReaderSettingsSheet({
    super.key,
    required this.open,
    required this.look,
    required this.palette,
    required this.paper,
    required this.brand,
    required this.page,
    required this.pageText,
    required this.onChange,
    required this.onClose,
  });

  final bool open;

  /// Os ajustes mostrados (os da sessão).
  final ReaderLook look;

  /// As cores das ilhas (inteiras; a pílula esmaece sozinha).
  final ReaderChromePalette palette;

  /// O papel da página: cobre a página abaixo do corte.
  final Color paper;
  final Color brand;
  final ReaderSheetPage page;

  /// O texto da página (o valor da "Prévia da página").
  final String pageText;

  /// Uma mudança pedida (aplicada pela sessão sobre os ajustes dela — toques rápidos somam).
  final ValueChanged<ReaderLookChange> onChange;
  final VoidCallback onClose;

  @override
  State<ReaderSettingsSheet> createState() => _ReaderSettingsSheetState();
}

class _ReaderSettingsSheetState extends State<ReaderSettingsSheet> {
  /// Quanto o dedo puxou a folha para baixo pela alça.
  double _drag = 0;

  @override
  void didUpdateWidget(ReaderSettingsSheet old) {
    super.didUpdateWidget(old);
    if (widget.open && !old.open) _drag = 0;
  }

  void _dragged(DragUpdateDetails d) =>
      setState(() => _drag = math.max(0, _drag + d.delta.dy));

  void _released(DragEndDetails d) {
    if (_drag >= readerSheetDismissDrag ||
        d.velocity.pixelsPerSecond.dy >= readerSheetDismissVelocity) {
      widget.onClose();
    } else {
      setState(() => _drag = 0);
    }
  }

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(end: widget.open ? 1 : 0),
    duration: readerFade,
    builder: (context, a, _) {
      if (a == 0) return const SizedBox.shrink();
      final pad = MediaQuery.viewPaddingOf(context);
      return IgnorePointer(
        // fechando: os toques já vão para os controles que voltam
        ignoring: !widget.open,
        child: ExcludeSemantics(
          excluding: !widget.open,
          child: BlockSemantics(
            blocking: widget.open,
            child: Stack(
              children: [
                // a página de cima: o toque fecha (D-141); a página não vira nem seleciona por baixo
                Positioned.fill(
                  child: GestureDetector(
                    key: const ValueKey('rs.backdrop'),
                    behavior: HitTestBehavior.opaque,
                    excludeFromSemantics: true,
                    onTap: widget.onClose,
                  ),
                ),
                Positioned.fill(
                  child: CustomMultiChildLayout(
                    delegate: _SheetLayout(
                      shown: a,
                      drag: _drag,
                      bottom: readerSheetBottom(pad),
                      pillTop: readerControlsLayout(pad).top,
                      page: widget.page,
                    ),
                    children: [
                      LayoutId(
                        id: _Part.paper,
                        child: IgnorePointer(
                          child: ColoredBox(
                            key: const ValueKey('rs.paper'),
                            color: widget.paper,
                          ),
                        ),
                      ),
                      LayoutId(
                        id: _Part.preview,
                        child: Semantics(
                          key: const ValueKey('rs.page'),
                          container: true,
                          label: 'Prévia da página',
                          value: widget.pageText,
                          child: const SizedBox.expand(),
                        ),
                      ),
                      LayoutId(
                        id: _Part.pill,
                        child: ExcludeSemantics(
                          child: _LivePill(palette: widget.palette.faded(a), a: a),
                        ),
                      ),
                      LayoutId(
                        id: _Part.sheet,
                        child: Semantics(
                          container: true,
                          scopesRoute: true,
                          namesRoute: true,
                          explicitChildNodes: true,
                          label: 'Ajustes de leitura',
                          child: _Sheet(
                            look: widget.look,
                            palette: widget.palette,
                            brand: widget.brand,
                            onChange: widget.onChange,
                            onClose: widget.onClose,
                            onDrag: _dragged,
                            onRelease: _released,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

enum _Part { paper, preview, pill, sheet }

/// A folha embaixo (subindo com [shown] e descendo com o [drag]); o papel do corte para baixo; a prévia da caixa do
/// texto até o corte; a pílula centralizada no lugar da ilha de cima (D-124).
final class _SheetLayout extends MultiChildLayoutDelegate {
  _SheetLayout({
    required this.shown,
    required this.drag,
    required this.bottom,
    required this.pillTop,
    required this.page,
  });

  final double shown, drag, bottom, pillTop;
  final ReaderSheetPage page;

  @override
  void performLayout(Size size) {
    final s = layoutChild(
      _Part.sheet,
      BoxConstraints.tightFor(width: size.width - 2 * readerSheetSide),
    );
    final rest = size.height - bottom - s.height;
    // fechada: toda abaixo da tela, com a sombra
    final away = size.height + AppShadows.drop4.dy;
    final top = rest + (away - rest) * (1 - shown) + drag;
    positionChild(_Part.sheet, Offset(readerSheetSide, top));
    final cut = top + readerSheetPagePeek;
    layoutChild(
      _Part.paper,
      BoxConstraints.tightFor(
        width: size.width,
        height: math.max(0, size.height - cut),
      ),
    );
    positionChild(_Part.paper, Offset(0, cut));
    layoutChild(
      _Part.preview,
      BoxConstraints.tightFor(
        width: page.width,
        height: math.max(0, cut - page.top),
      ),
    );
    positionChild(_Part.preview, Offset(page.left, page.top));
    final pill = layoutChild(_Part.pill, BoxConstraints.loose(size));
    positionChild(_Part.pill, Offset((size.width - pill.width) / 2, pillTop));
  }

  @override
  bool shouldRelayout(_SheetLayout old) =>
      old.shown != shown ||
      old.drag != drag ||
      old.bottom != bottom ||
      old.pillTop != pillTop ||
      old.page != page;
}

/// "● prévia ao vivo" (`rs.livePill`): fora do leitor de tela.
class _LivePill extends StatelessWidget {
  const _LivePill({required this.palette, required this.a});

  /// Já esmaecida.
  final ReaderChromePalette palette;
  final double a;

  @override
  Widget build(BuildContext context) => NeoBox(
    key: const ValueKey('rs.livePill'),
    height: 26,
    color: palette.island,
    border: BorderSide(width: AppStrokes.regular, color: palette.border),
    radius: BorderRadius.circular(13),
    padding: const EdgeInsets.symmetric(horizontal: 11),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        SizedBox(
          key: const ValueKey('rs.livePill.dot'),
          width: 7,
          height: 7,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.flame.withValues(alpha: a),
              shape: BoxShape.circle,
            ),
          ),
        ),
        AppText(
          'prévia ao vivo',
          style: AppTextStyles.readerSheetPill.copyWith(color: palette.title),
          maxLines: 1,
        ),
      ],
    ),
  );
}

/// A folha (`rs.sheet`): alça, título e ×; as Tarefas 11 e 12 põem o tamanho, a fonte, o papel, a entrelinha e as
/// margens.
class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.look,
    required this.palette,
    required this.brand,
    required this.onChange,
    required this.onClose,
    required this.onDrag,
    required this.onRelease,
  });

  final ReaderLook look;
  final ReaderChromePalette palette;
  final Color brand;
  final ValueChanged<ReaderLookChange> onChange;
  final VoidCallback onClose;
  final GestureDragUpdateCallback onDrag;
  final GestureDragEndCallback onRelease;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    return NeoBox(
      key: const ValueKey('rs.sheet'),
      color: p.island,
      border: line,
      radius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
        bottomLeft: Radius.circular(44),
        bottomRight: Radius.circular(44),
      ),
      shadow: AppShadows.drop4,
      shadowColor: p.shadow,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // a alça e o título: puxar para baixo fecha (D-141)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onVerticalDragUpdate: onDrag,
            onVerticalDragEnd: onRelease,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: SizedBox(
                    key: const ValueKey('rs.sheet.grabber'),
                    width: 40,
                    height: 5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: p.dash,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  key: const ValueKey('rs.sheet.header'),
                  height: 44,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Ajustes ',
                              style: AppTextStyles.readerSheetTitle.copyWith(
                                color: p.title,
                              ),
                            ),
                            TextSpan(
                              text: 'de leitura',
                              style: AppTextStyles.readerSheetTitleSerif
                                  .copyWith(color: p.title),
                            ),
                          ],
                        ),
                        key: const ValueKey('rs.sheet.title'),
                        maxLines: 1,
                      ),
                      CircleIconButton(
                        key: const ValueKey('rs.sheet.close'),
                        size: 44,
                        color: p.well,
                        border: line,
                        icon: AppSvg(
                          AppIconsLeitor.closeRound,
                          key: const ValueKey('rs.sheet.close.icon'),
                          size: 18,
                          color: p.night ? p.title : null,
                        ),
                        semanticsLabel: 'Fechar',
                        onTap: onClose,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Passo 4 — rodar:** os testes da Tarefa 10 → verde (sem a altura de 547,2, que volta na Tarefa 12).
- [ ] **Passo 5 — commit:** `feat(leitor): folha de ajustes — lugar, abrir/fechar, título e fechar (D-141, G14.3)`.

### Tarefa 11: o tamanho da letra

**Arquivos:** `reader_settings_sheet.dart`, `reader_settings_sheet_test.dart`.

- [ ] **Passo 1 — testes que falham:**

```dart
  test('readerStepAt: o centro de cada ponto da prancha escolhe ele mesmo; entre dois, o mais perto', () {
    // L26 nº 15–21, relativos ao trilho (x 87,5, largura 215), com o 4º ativo
    const centros = [24.5, 51.0, 77.5, 107.5, 137.5, 164.0, 190.5];
    for (var i = 0; i < 7; i++) {
      expect(readerStepAt(centros[i], 215, 4), i + 1);
    }
    expect(readerStepAt(0, 215, 4), 1);
    expect(readerStepAt(215, 215, 4), 7);
    expect(readerStepAt((centros[4] + centros[5]) / 2 - 1, 215, 4), 5);
  });

  testWidgets('A− e A+ andam um passo; nas pontas ficam indisponíveis (cinza e "indisponível")', (tester) async {
    final h = tester.ensureSemantics();
    var m = await _montar(tester);
    await tester.tap(_key('rs.sheet.size.smaller'));
    await tester.tap(_key('rs.sheet.size.larger'));
    expect(m.pedidos.map((l) => l.fontStep), [3, 5]);
    m = await _montar(tester, look: const ReaderLook(fontStep: 1));
    expect(
      tester.getSemantics(_key('rs.sheet.size.smaller')),
      isSemantics(label: 'Diminuir a letra', hasEnabledState: true, isEnabled: false, hasTapAction: false),
    );
    await tester.tap(_key('rs.sheet.size.smaller'), warnIfMissed: false);
    expect(m.pedidos, isEmpty);
    final a = tester.widget<AppText>(
      find.descendant(of: _key('rs.sheet.size.smaller'), matching: find.byType(AppText)),
    );
    expect(a.span.style!.color, ReaderChromePalette.of(ReaderPaper.creme).disabled);
    m = await _montar(tester, look: const ReaderLook(fontStep: 7));
    expect(
      tester.getSemantics(_key('rs.sheet.size.larger')),
      isSemantics(label: 'Aumentar a letra', hasEnabledState: true, isEnabled: false, hasTapAction: false),
    );
    h.dispose();
  });

  testWidgets('trilho: tocar num ponto escolhe; arrastar escolhe o mais perto, sem repetir', (tester) async {
    final m = await _montar(tester);
    await tester.tapAt(tester.getCenter(_key('rs.sheet.size.step6')));
    expect(m.pedidos.map((l) => l.fontStep), [6]);
    m.pedidos.clear();
    final de = tester.getCenter(_key('rs.sheet.size.step2'));
    final ate = tester.getCenter(_key('rs.sheet.size.step6'));
    final g = await tester.startGesture(de);
    for (var i = 1; i <= 20; i++) {
      await g.moveTo(Offset.lerp(de, ate, i / 20)!);
    }
    await g.up();
    // o 4 é o mostrado: não pede de novo
    expect(m.pedidos.map((l) => l.fontStep), [2, 3, 5, 6]);
  });

  testWidgets('pontos: até o ativo em tinta, depois em #CFC3AE; o ativo de 14 na brand com borda', (tester) async {
    await _montar(tester);
    Color cor(int i) => (tester.widget<DecoratedBox>(
      find.descendant(of: _key('rs.sheet.size.step$i'), matching: find.byType(DecoratedBox)),
    ).decoration as BoxDecoration).color!;
    expect([cor(1), cor(3), cor(5), cor(7)], [AppColors.ink, AppColors.ink, AppColors.dashReader, AppColors.dashReader]);
    final ativo = tester.widget<NeoBox>(_key('rs.sheet.size.step4'));
    expect((ativo.width, ativo.color, ativo.border), (14.0, AppColors.lavender, const BorderSide(width: 1.5, color: AppColors.ink)));
    expect(tester.getRect(_key('rs.sheet.size.steps')).size, const Size(215, 48));
  });

  testWidgets('leitor de tela: "Tamanho da letra", "4 de 7", aumentar e diminuir', (tester) async {
    final h = tester.ensureSemantics();
    final m = await _montar(tester);
    final no = tester.getSemantics(find.bySemanticsLabel('Tamanho da letra'));
    expect(
      no,
      isSemantics(
        label: 'Tamanho da letra',
        value: '4 de 7',
        increasedValue: '5 de 7',
        decreasedValue: '3 de 7',
        isSlider: true,
        hasIncreaseAction: true,
        hasDecreaseAction: true,
      ),
    );
    tester.semantics.performAction(find.bySemanticsLabel('Tamanho da letra'), SemanticsAction.increase);
    expect(m.pedidos.single.fontStep, 5);
    h.dispose();
  });
```

  O `SemanticsAction` vem de `package:flutter/semantics.dart`. Se `tester.semantics.performAction` não existir
  nesta versão, usar `tester.getSemantics(...).owner!.performAction(no.id, SemanticsAction.increase)`.

- [ ] **Passo 2 — rodar e ver falhar:** `readerStepAt` e o tamanho não existem.
- [ ] **Passo 3 — código** em `reader_settings_sheet.dart`:
  - acrescentar `import '../../../core/design_system/painters/dashed_stadium_painter.dart';` e
    `import '../../../core/design_system/widgets/pressable.dart';`;
  - na coluna do `_Sheet`, depois do `GestureDetector` da alça:

```dart
          const SizedBox(height: 12),
          _SizeRow(
            step: look.fontStep,
            palette: p,
            brand: brand,
            onChange: onChange,
          ),
```

  - e as peças novas:

```dart
/// O passo do ponto mais perto de [dx] no trilho de largura [width]: pontos de 7 e o ativo de 14, distribuídos como
/// o `space-evenly` do arquivo dentro da borda de 1,5.
int readerStepAt(double dx, double width, int active) {
  const n = 7;
  final inner = width - 2 * AppStrokes.regular;
  final gap = (inner - (n - 1) * 7 - 14) / (n + 1);
  var x = AppStrokes.regular + gap;
  var best = 1;
  var bestD = double.infinity;
  for (var i = 1; i <= n; i++) {
    final w = i == active ? 14.0 : 7.0;
    final d = (dx - (x + w / 2)).abs();
    if (d < bestD) {
      bestD = d;
      best = i;
    }
    x += w + gap;
  }
  return best;
}

/// "A" pequeno, os 7 pontos e "A" grande (`rs.sheet.size`).
class _SizeRow extends StatelessWidget {
  const _SizeRow({
    required this.step,
    required this.palette,
    required this.brand,
    required this.onChange,
  });

  final int step;
  final ReaderChromePalette palette;
  final Color brand;
  final ValueChanged<ReaderLookChange> onChange;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const ValueKey('rs.sheet.size'),
    height: 48,
    child: Row(
      spacing: 10,
      children: [
        _StepButton(
          id: 'rs.sheet.size.smaller',
          label: 'Diminuir a letra',
          style: AppTextStyles.readerSheetSmallA,
          palette: palette,
          enabled: step > 1,
          onTap: () => onChange(
            (l) => l.copyWith(fontStep: math.max(1, l.fontStep - 1)),
          ),
        ),
        Expanded(
          child: _Steps(
            step: step,
            palette: palette,
            brand: brand,
            onPick: (n) => onChange((l) => l.copyWith(fontStep: n)),
          ),
        ),
        _StepButton(
          id: 'rs.sheet.size.larger',
          label: 'Aumentar a letra',
          style: AppTextStyles.readerSheetLargeA,
          palette: palette,
          enabled: step < 7,
          onTap: () => onChange(
            (l) => l.copyWith(fontStep: math.min(7, l.fontStep + 1)),
          ),
        ),
      ],
    ),
  );
}

/// Um "A" de 48: nas pontas fica indisponível (cinza e "indisponível" ao leitor de tela, como a Fonte no PDF).
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.id,
    required this.label,
    required this.style,
    required this.palette,
    required this.enabled,
    required this.onTap,
  });

  final String id, label;
  final TextStyle style;
  final ReaderChromePalette palette;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = enabled ? palette.title : palette.disabled;
    return Pressable(
      key: ValueKey(id),
      semanticsLabel: label,
      enabled: enabled,
      onTap: onTap,
      child: NeoBox(
        width: 48,
        height: 48,
        color: palette.well,
        border: BorderSide(width: AppStrokes.regular, color: ink),
        radius: BorderRadius.circular(24),
        child: Center(
          child: AppText('A', style: style.copyWith(color: ink), maxLines: 1),
        ),
      ),
    );
  }
}

/// O trilho tracejado com os 7 pontos (`rs.sheet.size.steps`): tocar num ponto ou arrastar escolhe o passo mais
/// perto; para o leitor de tela é um controle deslizante (D-144).
class _Steps extends StatefulWidget {
  const _Steps({
    required this.step,
    required this.palette,
    required this.brand,
    required this.onPick,
  });

  final int step;
  final ReaderChromePalette palette;
  final Color brand;
  final ValueChanged<int> onPick;

  @override
  State<_Steps> createState() => _StepsState();
}

class _StepsState extends State<_Steps> {
  /// O último passo pedido por este toque ou arrasto (não pede o mesmo de novo enquanto a sessão aplica).
  int? _picked;

  void _pick(double dx, double width) {
    final n = readerStepAt(dx, width, widget.step);
    if (n == widget.step || n == _picked) return;
    _picked = n;
    widget.onPick(n);
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final p = widget.palette;
    return Semantics(
      container: true,
      slider: true,
      label: 'Tamanho da letra',
      value: '$step de 7',
      increasedValue: step < 7 ? '${step + 1} de 7' : null,
      decreasedValue: step > 1 ? '${step - 1} de 7' : null,
      onIncrease: step < 7 ? () => widget.onPick(step + 1) : null,
      onDecrease: step > 1 ? () => widget.onPick(step - 1) : null,
      child: LayoutBuilder(
        builder: (context, c) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTapUp: (d) {
            _picked = null;
            _pick(d.localPosition.dx, c.maxWidth);
          },
          onHorizontalDragStart: (d) {
            _picked = null;
            _pick(d.localPosition.dx, c.maxWidth);
          },
          onHorizontalDragUpdate: (d) => _pick(d.localPosition.dx, c.maxWidth),
          child: CustomPaint(
            key: const ValueKey('rs.sheet.size.steps'),
            painter: DashedStadiumPainter(color: p.dash),
            child: SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.all(AppStrokes.regular),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 1; i <= 7; i++)
                      if (i == step)
                        NeoBox(
                          key: ValueKey('rs.sheet.size.step$i'),
                          width: 14,
                          height: 14,
                          color: widget.brand,
                          border: BorderSide(
                            width: AppStrokes.regular,
                            color: p.border,
                          ),
                          radius: BorderRadius.circular(7),
                        )
                      else
                        SizedBox(
                          key: ValueKey('rs.sheet.size.step$i'),
                          width: 7,
                          height: 7,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: i < step ? p.title : p.dash,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

  Os centros do teste de `readerStepAt` saem da conta: borda 1,5 + vão 19,5 + metade do ponto (3,5) = 24,5, e
  assim por diante, com o ativo de 14 no 4º. Se o teste mostrar outro número, conferir com a tabela da L26 (nº 15
  a 21: x − 87,5 + 3,5, e + 7 no ativo).

- [ ] **Passo 4 — rodar:** `reader_settings_sheet_test.dart` → verde.
- [ ] **Passo 5 — commit:** `feat(leitor): tamanho da letra na folha — A, pontos, arrasto e leitor de tela (D-144, G14.3)`.

### Tarefa 12: fonte, papel, entrelinha e margens

**Arquivos:** `reader_settings_sheet.dart`, `reader_settings_sheet_test.dart`.

- [ ] **Passo 1 — testes que falham:**

```dart
  testWidgets('a folha inteira tem 547,2 de altura (L26) e as seções nos lugares da prancha', (tester) async {
    await _montar(tester);
    final f = tester.getRect(_key('rs.sheet'));
    expect(f.height, moreOrLessEquals(547.2, epsilon: 0.5));
    Offset rel(String k) => tester.getRect(_key(k)).topLeft - f.topLeft;
    expect(rel('rs.sheet.fonts'), const Offset(19.5, 164.7));
    expect(rel('rs.sheet.papers'), const Offset(19.5, 284.9));
    expect(rel('rs.sheet.spacing'), const Offset(19.5, 401.5));
    expect(rel('rs.sheet.margins'), const Offset(19.5, 479.7));
  });

  testWidgets('Fonte: 4 cartões com o "Aa" na própria fonte; o ativo na brand com sombra 2/2; o toque pede a fonte', (
    tester,
  ) async {
    final m = await _montar(tester);
    String familia(String id) => tester.widget<AppText>(_key('rs.sheet.fonts.$id.sample')).span.style!.fontFamily!;
    expect(
      [for (final id in ['literata', 'lora', 'figtree', 'atkinson']) familia(id)],
      ['Literata26', 'LoraBook', 'Figtree', 'AtkinsonBook'],
    );
    final ativo = tester.widget<NeoBox>(find.descendant(of: _key('rs.sheet.fonts.literata'), matching: find.byType(NeoBox)));
    expect((ativo.color, ativo.shadow), (AppColors.lavender, const Offset(2, 2)));
    final outro = tester.widget<NeoBox>(find.descendant(of: _key('rs.sheet.fonts.lora'), matching: find.byType(NeoBox)));
    expect((outro.color, outro.shadow), (AppColors.paper, null));
    expect(
      tester.widget<AppText>(_key('rs.sheet.fonts.literata.caption')).span.style!.color,
      AppColors.captionOnBrand,
    );
    expect(tester.widget<AppText>(_key('rs.sheet.fonts.lora.caption')).span.style!.color, AppColors.inkSoft);
    await tester.tap(_key('rs.sheet.fonts.atkinson'));
    expect(m.pedidos.single.fontFamily, ReaderFontFamily.atkinson);
  });

  testWidgets('Papel: cada cartão nas cores do papel; ✓ e sombra só no ativo; o nome dele em 800', (tester) async {
    final m = await _montar(tester, look: const ReaderLook(paper: ReaderPaper.sepia));
    final sepia = tester.widget<NeoBox>(_key('rs.sheet.papers.sepia.card'));
    expect((sepia.color, sepia.shadow), (AppColors.paperSepia, const Offset(2, 2)));
    expect(tester.widget<NeoBox>(_key('rs.sheet.papers.night.card')).color, AppColors.paperNight);
    expect(_key('rs.sheet.papers.sepia.check'), findsOneWidget);
    expect(_key('rs.sheet.papers.cream.check'), findsNothing);
    expect(
      tester.widget<AppText>(_key('rs.sheet.papers.night.sample')).span.style!.color,
      AppColors.inkNight,
    );
    expect(
      (tester.widget<DecoratedBox>(find.descendant(of: _key('rs.sheet.papers.cream.line1'), matching: find.byType(DecoratedBox))).decoration as BoxDecoration).color,
      AppColors.paperLineCream,
    );
    expect(tester.widget<AppText>(_key('rs.sheet.papers.sepia.name')).span.style!.fontWeight, FontWeight.w800);
    expect(tester.widget<AppText>(_key('rs.sheet.papers.cream.name')).span.style!.fontWeight, FontWeight.w700);
    await tester.tap(_key('rs.sheet.papers.night'));
    expect(m.pedidos.single.paper, ReaderPaper.noite);
  });

  testWidgets('Entrelinha e Margens: segmentados de 3; o ativo na brand com borda; o toque pede', (tester) async {
    final m = await _montar(tester);
    final medio = tester.widget<NeoBox>(find.descendant(of: _key('rs.sheet.spacing.medium'), matching: find.byType(NeoBox)));
    expect((medio.color, medio.border!.color), (AppColors.lavender, AppColors.ink));
    final justo = tester.widget<NeoBox>(find.descendant(of: _key('rs.sheet.spacing.tight'), matching: find.byType(NeoBox)));
    expect((justo.color, justo.border!.color.a), (null, 0.0));
    expect(tester.widget<AppSvg>(_key('rs.sheet.margins.wide.icon')).asset, AppIconsLeitor.marginsWide);
    await tester.tap(_key('rs.sheet.spacing.loose'));
    await tester.tap(_key('rs.sheet.margins.narrow'));
    expect(
      [m.pedidos[0].lineSpacing, m.pedidos[1].margins],
      [ReaderLineSpacing.solto, ReaderMargins.estreita],
    );
  });

  testWidgets('leitor de tela: os 4 grupos e as opções marcadas (radio)', (tester) async {
    final h = tester.ensureSemantics();
    await _montar(tester);
    for (final g in ['Fonte', 'Tema do papel', 'Entrelinha', 'Margens']) {
      expect(find.bySemanticsLabel(g), findsOneWidget, reason: g);
    }
    expect(
      tester.getSemantics(_key('rs.sheet.fonts.literata')),
      isSemantics(label: 'Literata, tela', hasCheckedState: true, isChecked: true, isInMutuallyExclusiveGroup: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(_key('rs.sheet.papers.white')),
      isSemantics(label: 'Tema Branco', hasCheckedState: true, isChecked: false, isInMutuallyExclusiveGroup: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(_key('rs.sheet.spacing.medium')),
      isSemantics(label: 'Médio', hasCheckedState: true, isChecked: true, isInMutuallyExclusiveGroup: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(_key('rs.sheet.margins.wide')),
      isSemantics(label: 'Larga', hasCheckedState: true, isChecked: false, isInMutuallyExclusiveGroup: true, hasTapAction: true),
    );
    h.dispose();
  });

  testWidgets('Noite (D-143): os cartões de papel mantêm as cores; rótulos, legendas e opções nas cores das ilhas', (
    tester,
  ) async {
    await _montar(tester, papel: ReaderPaper.noite, look: const ReaderLook(paper: ReaderPaper.noite));
    final n = ReaderChromePalette.of(ReaderPaper.noite);
    expect(tester.widget<NeoBox>(_key('rs.sheet.papers.cream.card')).color, AppColors.paperCream);
    expect(tester.widget<AppText>(_key('rs.sheet.fontLabel')).span.style!.color, n.label);
    expect(tester.widget<AppText>(_key('rs.sheet.fonts.lora.caption')).span.style!.color, n.caption);
    expect(tester.widget<AppSvg>(_key('rs.sheet.spacing.tight.icon')).color, n.title);
    expect(tester.widget<AppSvg>(_key('rs.sheet.spacing.medium.icon')).color, isNull, reason: 'sobre a brand, o ícone de tinta');
  });
```

- [ ] **Passo 2 — rodar e ver falhar.**
- [ ] **Passo 3 — código** em `reader_settings_sheet.dart`:
  - na coluna do `_Sheet`, depois do `_SizeRow`:

```dart
          const SizedBox(height: 16),
          _Label('FONTE', id: 'rs.sheet.fontLabel', palette: p),
          const SizedBox(height: 7),
          _Fonts(look: look, palette: p, brand: brand, onChange: onChange),
          const SizedBox(height: 16),
          _Label('PAPEL', id: 'rs.sheet.paperLabel', palette: p),
          const SizedBox(height: 9),
          _Papers(look: look, palette: p, brand: brand, onChange: onChange),
          const SizedBox(height: 14),
          _Label('ENTRELINHA', id: 'rs.sheet.spacingLabel', palette: p),
          const SizedBox(height: 7),
          _Segmented<ReaderLineSpacing>(
            id: 'rs.sheet.spacing',
            label: 'Entrelinha',
            value: look.lineSpacing,
            options: _spacings,
            palette: p,
            brand: brand,
            onPick: (v) => onChange((l) => l.copyWith(lineSpacing: v)),
          ),
          const SizedBox(height: 12),
          _Label('MARGENS', id: 'rs.sheet.marginsLabel', palette: p),
          const SizedBox(height: 7),
          _Segmented<ReaderMargins>(
            id: 'rs.sheet.margins',
            label: 'Margens',
            value: look.margins,
            options: _margins,
            palette: p,
            brand: brand,
            onPick: (v) => onChange((l) => l.copyWith(margins: v)),
          ),
```

  - e as peças:

```dart
/// As fontes da folha: (fonte, id da prancha, nome, legenda, estilo do "Aa").
final List<(ReaderFontFamily, String, String, String, TextStyle)> _fonts = [
  (ReaderFontFamily.literata, 'literata', 'Literata', 'tela', AppTextStyles.readerSheetSampleLiterata),
  (ReaderFontFamily.lora, 'lora', 'Lora', 'clássica', AppTextStyles.readerSheetSampleLora),
  (ReaderFontFamily.figtree, 'figtree', 'Figtree', 'sem serifa', AppTextStyles.readerSheetSampleFigtree),
  (ReaderFontFamily.atkinson, 'atkinson', 'Atkinson', 'dislexia', AppTextStyles.readerSheetSampleAtkinson),
];

const List<(ReaderPaper, String, String)> _papers = [
  (ReaderPaper.creme, 'cream', 'Creme'),
  (ReaderPaper.branco, 'white', 'Branco'),
  (ReaderPaper.sepia, 'sepia', 'Sépia'),
  (ReaderPaper.noite, 'night', 'Noite'),
];

const List<(ReaderLineSpacing, String, String, String)> _spacings = [
  (ReaderLineSpacing.justo, 'tight', 'Justo', AppIconsLeitor.spacingTight),
  (ReaderLineSpacing.medio, 'medium', 'Médio', AppIconsLeitor.spacingMedium),
  (ReaderLineSpacing.solto, 'loose', 'Solto', AppIconsLeitor.spacingLoose),
];

const List<(ReaderMargins, String, String, String)> _margins = [
  (ReaderMargins.estreita, 'narrow', 'Estreita', AppIconsLeitor.marginsNarrow),
  (ReaderMargins.media, 'medium', 'Média', AppIconsLeitor.marginsMedium),
  (ReaderMargins.larga, 'wide', 'Larga', AppIconsLeitor.marginsWide),
];

/// As cores do cartão de cada papel (L26, PAPEL): fundo, "Aa" e as duas linhas — as mesmas em todo tema (D-143).
({Color card, Color ink, Color line}) readerPaperCard(ReaderPaper p) =>
    switch (p) {
      ReaderPaper.creme => (
        card: AppColors.paperCream,
        ink: AppColors.bookText,
        line: AppColors.paperLineCream,
      ),
      ReaderPaper.branco => (
        card: AppColors.paperWhite,
        ink: AppColors.ink,
        line: AppColors.paperLineWhite,
      ),
      ReaderPaper.sepia => (
        card: AppColors.paperSepia,
        ink: AppColors.bookTextSepia,
        line: AppColors.paperLineSepia,
      ),
      ReaderPaper.noite => (
        card: AppColors.paperNight,
        ink: AppColors.inkNight,
        line: AppColors.dashNight,
      ),
    };

/// "FONTE", "PAPEL", "ENTRELINHA", "MARGENS".
class _Label extends StatelessWidget {
  const _Label(this.text, {required this.id, required this.palette});

  final String text, id;
  final ReaderChromePalette palette;

  @override
  Widget build(BuildContext context) => AppText(
    text,
    key: ValueKey(id),
    style: AppTextStyles.readerSheetLabel.copyWith(color: palette.label),
    maxLines: 1,
  );
}

/// FONTE (`rs.sheet.fonts`): 4 cartões de 82; o escolhido na `brand` com sombra 2/2.
class _Fonts extends StatelessWidget {
  const _Fonts({
    required this.look,
    required this.palette,
    required this.brand,
    required this.onChange,
  });

  final ReaderLook look;
  final ReaderChromePalette palette;
  final Color brand;
  final ValueChanged<ReaderLookChange> onChange;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Fonte',
      child: Row(
        key: const ValueKey('rs.sheet.fonts'),
        spacing: 8,
        children: [
          for (final (f, id, name, caption, sample) in _fonts)
            Expanded(
              child: Builder(
                builder: (context) {
                  final on = look.fontFamily == f;
                  final ink = on ? AppColors.ink : p.title;
                  final k = 'rs.sheet.fonts.$id';
                  return Pressable(
                    key: ValueKey(k),
                    semanticsLabel: '$name, $caption',
                    checked: on,
                    onTap: () => onChange((l) => l.copyWith(fontFamily: f)),
                    child: NeoBox(
                      height: 82,
                      color: on ? brand : p.well,
                      border: line,
                      radius: BorderRadius.circular(16),
                      shadow: on ? AppShadows.hard2 : null,
                      shadowColor: p.shadow,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                            'Aa',
                            key: ValueKey('$k.sample'),
                            style: sample.copyWith(color: ink),
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            name,
                            key: ValueKey('$k.name'),
                            style: AppTextStyles.readerSheetFontName.copyWith(color: ink),
                            maxLines: 1,
                          ),
                          // gap 2 com `margin-top: -1`
                          const SizedBox(height: 1),
                          AppText(
                            caption,
                            key: ValueKey('$k.caption'),
                            style: AppTextStyles.readerSheetCaption.copyWith(
                              color: on ? AppColors.captionOnBrand : p.caption,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// PAPEL (`rs.sheet.papers`): o cartão de 62 nas cores do papel, com "Aa" e 2 linhas; o escolhido com sombra 2/2 e
/// o ✓ de 22 na `brand`; o nome embaixo (o escolhido em 800).
class _Papers extends StatelessWidget {
  const _Papers({
    required this.look,
    required this.palette,
    required this.brand,
    required this.onChange,
  });

  final ReaderLook look;
  final ReaderChromePalette palette;
  final Color brand;
  final ValueChanged<ReaderLookChange> onChange;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Tema do papel',
      child: Row(
        key: const ValueKey('rs.sheet.papers'),
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (paper, id, name) in _papers)
            Expanded(
              child: Builder(
                builder: (context) {
                  final on = look.paper == paper;
                  final c = readerPaperCard(paper);
                  final k = 'rs.sheet.papers.$id';
                  Widget bar(String key, {double width = 1}) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: width,
                    child: SizedBox(
                      key: ValueKey(key),
                      height: 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.line,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                  return Pressable(
                    key: ValueKey(k),
                    semanticsLabel: 'Tema $name',
                    checked: on,
                    onTap: () => onChange((l) => l.copyWith(paper: paper)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: NeoBox(
                            key: ValueKey('$k.card'),
                            height: 62,
                            color: c.card,
                            border: line,
                            radius: BorderRadius.circular(14),
                            shadow: on ? AppShadows.hard2 : null,
                            shadowColor: p.shadow,
                            child: Stack(
                              fit: StackFit.expand,
                              clipBehavior: Clip.none,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      AppText(
                                        'Aa',
                                        key: ValueKey('$k.sample'),
                                        style: AppTextStyles.readerSheetPaperSample.copyWith(color: c.ink),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 7),
                                      bar('$k.line1'),
                                      const SizedBox(height: 4),
                                      bar('$k.line2', width: 0.7),
                                    ],
                                  ),
                                ),
                                if (on)
                                  Positioned(
                                    right: -7,
                                    top: -7,
                                    child: NeoBox(
                                      key: ValueKey('$k.check'),
                                      width: 22,
                                      height: 22,
                                      color: brand,
                                      border: line,
                                      radius: BorderRadius.circular(11),
                                      child: Center(
                                        child: AppSvg(
                                          AppIconsLeitor.checkSmall,
                                          key: ValueKey('$k.check.icon'),
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        AppText(
                          name,
                          key: ValueKey('$k.name'),
                          style: (on
                                  ? AppTextStyles.readerSheetPaperNameOn
                                  : AppTextStyles.readerSheetPaperName)
                              .copyWith(color: p.title),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// ENTRELINHA e MARGENS: um segmentado de 46 com 3 opções; a escolhida na `brand`, com borda e texto em 800.
class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.id,
    required this.label,
    required this.value,
    required this.options,
    required this.palette,
    required this.brand,
    required this.onPick,
  });

  final String id, label;
  final T value;
  final List<(T, String, String, String)> options;
  final ReaderChromePalette palette;
  final Color brand;
  final ValueChanged<T> onPick;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: NeoBox(
        key: ValueKey(id),
        height: 46,
        color: p.well,
        border: BorderSide(width: AppStrokes.regular, color: p.border),
        radius: BorderRadius.circular(23),
        padding: const EdgeInsets.all(3),
        child: Row(
          spacing: 3,
          children: [
            for (final (v, sid, text, icon) in options)
              Expanded(
                child: Builder(
                  builder: (context) {
                    final on = v == value;
                    return Pressable(
                      key: ValueKey('$id.$sid'),
                      checked: on,
                      onTap: () => onPick(v),
                      child: NeoBox(
                        height: 37,
                        color: on ? brand : null,
                        border: BorderSide(
                          width: AppStrokes.regular,
                          color: on ? p.border : const Color(0x00000000),
                        ),
                        radius: BorderRadius.circular(999),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 7,
                          children: [
                            AppSvg(
                              icon,
                              key: ValueKey('$id.$sid.icon'),
                              size: 18,
                              // no Noite, tingido com o título; sobre a brand fica a tinta do arquivo
                              color: !on && p.night ? p.title : null,
                            ),
                            AppText(
                              text,
                              style: (on
                                      ? AppTextStyles.readerSheetOptionOn
                                      : AppTextStyles.readerSheetOption)
                                  .copyWith(color: on ? AppColors.ink : p.title),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

  Os ícones do segmentado ativo e do ✓ ficam sem tinta: os SVGs já são `#1A1714`, e a `brand` é clara nos dois temas.

- [ ] **Passo 4 — rodar:** `reader_settings_sheet_test.dart` → verde, com a altura de 547,2 de volta no 1º teste da
  Tarefa 10.
- [ ] **Passo 5 — commit:** `feat(leitor): fonte, papel, entrelinha e margens na folha (D-143, D-144, G14.3)`.

---

## G14.4 — Abrir, mudar, fechar

### Tarefa 13: a folha na tela do leitor

**Arquivos:** `lib/features/reader/presentation/reader_screen.dart`; testes novos
`test/features/reader/presentation/reader_screen_g14_test.dart`; muda o `reader_screen_g12_test.dart` (a Fonte saiu
do "Chega numa próxima fase", e o PDF confere que a folha não abre).

- [ ] **Passo 1 — testes que falham** (`reader_screen_g14_test.dart`; os ajudantes são os do
  `reader_screen_g12_test.dart`):

```dart
// G14.4 — a folha de ajustes pela rota real, com o Dom Casmurro num banco em memória: "Aa Fonte" abre a folha (os
// controles somem e a barra de status fica — D-105); ×, Voltar, toque na página de cima e puxar pela alça fecham e
// devolvem os controles (D-141, D-142); a página de cima não vira com a folha aberta; o prazo da pílula de voltar
// fica parado (D-125); mudar o tamanho repagina na tela mantendo o caractere e fica gravado (reabrir mantém); o papel
// anima em 220 ms (D-121).
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_overlays.dart' show readerSoonText;
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/app_text_finder.dart';
import '../../../support/canvas.dart';
import '../../../support/load_fonts.dart';
import '../../../support/personal_builders.dart';
import '../../../support/pump_reader.dart';
import '../../../support/reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

ReaderDocument _doc(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document;

Future<void> _quadros(WidgetTester tester, [int n = 40]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// O fundo da tela (o papel).
Color _papel(WidgetTester tester) => tester
    .widget<ColoredBox>(
      find.descendant(of: find.byType(ReaderScreen), matching: find.byType(ColoredBox)).first,
    )
    .color;

/// Abre os controles (toque no centro) e espera os 150 ms e o banco.
Future<void> _abrirControles(WidgetTester tester) async {
  await tester.tapAt(const Offset(195, 420));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await _quadros(tester, 6);
  expect(_key('r20.topIsland'), findsOneWidget);
}

Future<void> _fecharControles(WidgetTester tester) async {
  await tester.tapAt(const Offset(195, 420));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  expect(_key('r20.topIsland'), findsNothing);
}

/// Abre os controles e toca em "Aa Fonte"; espera os 150 ms.
Future<void> _abrirFolha(WidgetTester tester) async {
  await _abrirControles(tester);
  await tester.tap(_key('r20.bottomIsland.tools.font'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await _quadros(tester, 6);
  expect(_key('rs.sheet'), findsOneWidget);
}

/// Espera a sessão gravar e a página nova chegar.
Future<void> _aplicar(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async {
    livro = await LivroNaEstante.domCasmurro();
    await livro.guardarPosicao(2, livro.index.spine[2].chars ~/ 2);
  });
  tearDown(() async => livro.close());

  testWidgets('"Aa Fonte" abre a folha: os controles somem e a barra de status fica; × fecha e os controles voltam', (
    tester,
  ) async {
    setCanvasView(tester, logical: const Size(390, 844));
    final t = await abrirLeitor(tester, livro);
    await _abrirFolha(tester);
    expect(_key('r20.topIsland'), findsNothing, reason: 'os controles somem');
    expect(findAppText(readerSoonText), findsNothing, reason: 'não é mais "Chega numa próxima fase"');
    expect(t.ui.log.last, 'padrão', reason: 'a barra de status fica (D-105)');
    await tester.tap(_key('rs.sheet.close'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await _quadros(tester, 6);
    expect(_key('rs.sheet'), findsNothing);
    expect(_key('r20.topIsland'), findsOneWidget, reason: 'volta aos controles (D-142)');
    expect(t.ui.log.last, 'padrão');
    await _fecharControles(tester);
    expect(t.ui.log.last, 'imersivo');
    expect(t.erros, isEmpty);
  });

  testWidgets('o Voltar fecha a folha, depois os controles, depois o livro (D-42)', (tester) async {
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    await _abrirFolha(tester);
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(_key('rs.sheet'), findsNothing);
    expect(_key('r20.topIsland'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(_key('r20.topIsland'), findsNothing);
    expect(find.byType(ReaderScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ReaderScreen), findsNothing);
  });

  testWidgets('tocar na página de cima fecha; arrastar nela não vira a página', (tester) async {
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    final antes = _doc(tester).mark;
    await _abrirFolha(tester);
    await tester.dragFrom(const Offset(300, 200), const Offset(-200, 0));
    await _quadros(tester, 20);
    expect(_doc(tester).mark, antes, reason: 'a página não virou');
    expect(_key('rs.sheet'), findsOneWidget, reason: 'o arrasto não fecha');
    await tester.tapAt(const Offset(195, 200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await _quadros(tester, 6);
    expect(_key('rs.sheet'), findsNothing);
    expect(_key('r20.topIsland'), findsOneWidget);
  });

  testWidgets('puxar a folha pela alça fecha e volta aos controles', (tester) async {
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    await _abrirFolha(tester);
    await tester.dragFrom(tester.getCenter(_key('rs.sheet.grabber')), const Offset(0, 120));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await _quadros(tester, 6);
    expect(_key('rs.sheet'), findsNothing);
    expect(_key('r20.topIsland'), findsOneWidget);
  });

  testWidgets('A+ repagina na tela mantendo o caractere; fica gravado e reabrir mantém', (tester) async {
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    final lendo = _doc(tester).mark;
    await _abrirFolha(tester);
    await tester.tap(_key('rs.sheet.size.larger'));
    await _aplicar(tester);
    final p = _doc(tester).current as PageSnapshot;
    expect(p.typography.fontSize, 22);
    expect(lendo.offset, inInclusiveRange(p.shown!.from, p.shown!.to - 1));
    expect(tester.getSize(_key('rs.sheet.size.step5')), const Size(14, 14), reason: 'o ativo agora é o 5º');
    final linha = await tester.runAsync(() => ReaderSettingsDao(livro.db).forUser(usuarioTeste));
    expect(linha!.fontStep, 5);
    // reabrir mantém
    await tester.binding.handlePopRoute(); // fecha a folha
    await tester.pump(const Duration(milliseconds: 150));
    await tester.binding.handlePopRoute(); // fecha os controles
    await tester.pump(const Duration(milliseconds: 150));
    await tester.binding.handlePopRoute(); // sai do livro
    await tester.pumpAndSettle();
    await abrirLeitor(tester, livro);
    expect((_doc(tester).current as PageSnapshot).typography.fontSize, 22);
  });

  testWidgets('papel na folha: o papel anima em 220 ms, a página na cor nova e a folha mostra o escolhido', (
    tester,
  ) async {
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    await _abrirFolha(tester);
    await tester.tap(_key('rs.sheet.papers.sepia'));
    await _aplicar(tester);
    await tester.pump(const Duration(milliseconds: 220));
    expect(_papel(tester), ReaderPalette.of(ReaderPaper.sepia).paper);
    expect(
      (_doc(tester).current as PageSnapshot).typography.ink,
      ReaderPalette.of(ReaderPaper.sepia).text,
    );
    expect(_key('rs.sheet.papers.sepia.check'), findsOneWidget);
  });

  testWidgets('a pílula de voltar fica parada com a folha aberta (D-125)', (tester) async {
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    final pag = _doc(tester).numbers.refPage;
    await _abrirControles(tester);
    final trilho = tester.getRect(_key('r20.bottomIsland.scrubber.track'));
    await tester.tapAt(Offset(trilho.left + trilho.width * 0.25, trilho.center.dy));
    await _quadros(tester, 20);
    await tester.tap(_key('r20.bottomIsland.tools.font'));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(seconds: 20));
    await tester.tap(_key('rs.sheet.close'));
    await tester.pump(const Duration(milliseconds: 150));
    await _fecharControles(tester);
    await tester.pump(const Duration(milliseconds: 5700));
    expect(findAppText('Voltar à pág. $pag'), findsOneWidget, reason: 'o prazo começou ao fechar os controles');
  });

  testWidgets('leitor de tela: com a folha aberta, a página e os controles saem da árvore', (tester) async {
    final h = tester.ensureSemantics();
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    await _abrirFolha(tester);
    expect(find.bySemanticsLabel('Ajustes de leitura'), findsOneWidget);
    expect(find.bySemanticsLabel('Prévia da página'), findsOneWidget);
    expect(find.bySemanticsLabel('Fechar o livro'), findsNothing, reason: 'a ilha de cima ficou embaixo');
    expect(find.bySemanticsLabel(RegExp(r'^Dom Casmurro, página')), findsNothing);
    h.dispose();
  });
}
```

  Em `reader_screen_g12_test.dart`:
  - no teste "Fonte, Grifos, Anotar e Sumário…", trocar a lista por `['notes', 'annotate', 'toc']` e o nome por
    "Grifos, Anotar e Sumário: …";
  - no teste do PDF, depois do toque na Fonte: `expect(_key('rs.sheet'), findsNothing);`.

- [ ] **Passo 2 — rodar e ver falhar:** a Fonte ainda mostra o aviso.
- [ ] **Passo 3 — código** em `reader_screen.dart`:
  - o comentário do topo ganha: "G14.4 — tela 26: "Aa Fonte" abre a folha de ajustes por cima (os controles somem e
    voltam ao fechar — D-142); fecha pelo ×, pelo Voltar, pelo toque na página de cima ou puxando a alça (D-141);
    cada toque grava e repagina (D-144). No PDF a Fonte segue desabilitada (D-122).";
  - `import 'reader_settings_sheet.dart';`;
  - o estado, depois de `_search`:

```dart
  /// A folha de ajustes da tela 26 está aberta (G14): os controles ficam por baixo, escondidos (D-142).
  bool _settings = false;
```

  - em `_changed`:
    - `if (state is! ReaderReady && (_controls || _search || _settings)) {` com `_settings = false;` junto;
    - `_systemUi(immersive: ready && !_controls && !_search && !_settings);`;
  - `_setControls`: `_systemUi(immersive: _c?.state is ReaderReady && !open && !_search && !_settings);`;
  - `_holdBack`: `void _holdBack() => _c?.holdBack(_controls || _search || _settings);` com o comentário "… com os
    controles, a busca ou a folha de ajustes por cima …";
  - `_tool`:

```dart
      case ReaderTool.font:
        _openSettings();
      case ReaderTool.notes:
      case ReaderTool.annotate:
      case ReaderTool.toc:
        // Grifos → G19, Anotar → G16, Sumário → G15 (D-118)
        _showToast(readerSoonText);
```

  - os dois métodos novos (depois de `_closeSearch`):

```dart
  /// "Aa Fonte" (G14): a folha de ajustes por cima; os controles somem e voltam ao fechar (D-142); a barra de
  /// status fica (D-105). No PDF a Fonte está desabilitada e a folha não abre (D-122).
  void _openSettings() {
    if (_leaving || _doc is PdfReaderDocument) return;
    _clearToast();
    _dismissUndo();
    setState(() => _settings = true);
    _systemUi(immersive: false);
    _holdBack();
  }

  /// ×, Voltar, o toque na página de cima ou puxar a folha (D-141): cada toque já aplicou e gravou o ajuste;
  /// fechar só volta aos controles.
  void _closeSettings() {
    if (!_settings) return;
    setState(() => _settings = false);
    _systemUi(
      immersive: _c?.state is ReaderReady && !_controls && !_search,
    );
    _holdBack();
  }
```

  - `_closeSearch`: `_systemUi(immersive: _c?.state is ReaderReady && !_controls && !_settings);`;
  - no `PopScope`, depois do `_search`: `} else if (_settings) { _closeSettings(); }`;
  - no `ReaderControls`: `open: _controls && !_settings,`;
  - em `_ready`, logo depois do bloco dos controles (antes da folha da nota):

```dart
          // a folha de ajustes (tela 26): por cima dos controles; a página de cima é a prévia (sem véu)
          if (doc is! PdfReaderDocument)
            Positioned.fill(
              child: ReaderSettingsSheet(
                open: _settings,
                look: c.look,
                palette: islands,
                paper: palette.paper,
                brand: brand,
                page: (
                  left: t.sideMargin,
                  top: insets.top,
                  width: t.contentWidth,
                ),
                pageText: doc.current.spokenText,
                onChange: (change) => unawaited(c.applySettings(change)),
                onClose: _closeSettings,
              ),
            ),
```

- [ ] **Passo 4 — rodar:** `reader_screen_g14_test.dart`, `reader_screen_g12_test.dart`, `reader_screen_g13_test.dart`
  e `reader_screen_test.dart` → verde.
- [ ] **Passo 5 — commit:** `feat(leitor): "Aa Fonte" abre a folha de ajustes; fechar volta aos controles (D-141, D-142, G14.4)`.

### Tarefa 14: o Noite pela tela e o grifo na fonte nova

**Arquivos:** `reader_screen_g14_test.dart`; `test/features/reader/presentation/reader_page_view_test.dart` (se o
grifo pedir um teste de pintura).

- [ ] **Passo 1 — testes:**

```dart
  testWidgets('Noite pela folha: a folha e a pílula viram as ilhas do Noite em 220 ms; o Tema volta ao último claro', (
    tester,
  ) async {
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    await _abrirFolha(tester);
    await tester.tap(_key('rs.sheet.papers.white'));
    await _aplicar(tester);
    await tester.tap(_key('rs.sheet.papers.night'));
    await _aplicar(tester);
    await tester.pump(const Duration(milliseconds: 220));
    final n = ReaderChromePalette.of(ReaderPaper.noite);
    expect(tester.widget<NeoBox>(_key('rs.sheet')).color, n.island);
    expect(tester.widget<NeoBox>(_key('rs.livePill')).color, n.island);
    await tester.tap(_key('rs.sheet.close'));
    await tester.pump(const Duration(milliseconds: 150));
    await _quadros(tester, 6);
    await tester.tap(_key('r20.bottomIsland.tools.theme'));
    await _aplicar(tester);
    await tester.pump(const Duration(milliseconds: 220));
    expect(_papel(tester), ReaderPalette.of(ReaderPaper.branco).paper, reason: 'o último claro (D-121)');
  });
```

  O grifo na fonte nova já fica provado em duas partes:
  - a Tarefa 4 mostra as caixas da página na área da Lora;
  - a G13 mostra o pintor pintando o grifo na faixa das caixas (`textTop`/`textBottom`).

  Se a revisão pedir a prova inteira, acrescentar em `reader_page_view_test.dart`, no molde do teste de faixa da G13,
  o mesmo grifo num `_Livro` aberto com `ReaderTypography(font: ReaderFontFamily.lora)`.
- [ ] **Passo 2 — rodar:** verde. Se a folha não trocar de cor, conferir se o `TweenAnimationBuilder` das ilhas em
  `_ready` envolve a folha: ela recebe `islands`, que já anima.
- [ ] **Passo 3 — commit:** `test(leitor): Noite e último claro pela folha de ajustes (D-121, D-143, G14.4)`.

---

## G14.5 — Prova

### Tarefa 15: a fase L26

**Arquivos:** `test/support/fase_l26.dart` (novo), `test/features/reader/presentation/l26_test.dart` (novo).

- [ ] **Passo 1 — `fase_l26.dart`**, no molde do `fase_l20.dart`:

```dart
// G14.5 — a fase L26 (tela 26, a folha de ajustes): a tela pela rota real, no mundo de referência (D-34) com o
// ajuste da conta do mundo (passo 4, Literata, Creme, Médio, Média), com os controles abertos e "Aa Fonte" tocado,
// contra as medidas do arquivo:
// - geometria de todos os ids de `rs.page`, `rs.livePill` e `rs.sheet` (83, sem o inline do título), com as
//   tolerâncias da v1 (±0,5; ±1,0 em x/w nos que dependem do texto); a pílula pela caixa visual (`translateX`);
// - texto: as 14 linhas do parágrafo da prévia (as 6 de cima à vista, as outras atrás do papel do corte) e os textos
//   da folha, com as baselines;
// - estilo: folha, alça, ×, pontos, cartões, segmentados, rótulos, título e a pílula;
// - semântica: o diálogo, a prévia, os botões, o controle deslizante e os grupos com as opções marcadas;
// - dados: os ajustes mostrados são os da linha do mundo, lidos do banco.
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/mundo_2026_09_20.dart';
import '../fixtures/telas/instantaneo.dart';
import '../reference/leitor/ref_tipos.dart';
import 'dados_t20.dart';
import 'fase_l20.dart' show abrirTela20, instantaneoBrand;
import 'load_fonts.dart';
import 'pump_reader.dart';
import 'reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

const List<String> secoesL26 = ['rs.page', 'rs.livePill', 'rs.sheet'];

/// Abre a tela 20 (controles), toca em "Aa Fonte" e espera a folha (150 ms).
Future<LeitorNaTela> abrirTela26(
  WidgetTester tester,
  LivroNaEstante livro, {
  bool golden = false,
}) async {
  final t = await abrirTela20(tester, livro, golden: golden);
  await tester.tap(_key('r20.bottomIsland.tools.font'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  return t;
}

PageSnapshot _pagina(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document.current as PageSnapshot;

void faseL26({
  required String nome,
  required LeitorRefPrancha ref,
  required InstantaneoDoLeitor instantaneo,
}) {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela20());
  tearDown(() async => livro.close());

  final cores = ReaderChromePalette.of(ReaderPaper.creme);

  Rect medido(WidgetTester tester, String id) {
    if (id == 'rs.page.text') {
      final p = _pagina(tester);
      final s = p.page.slices.first as TextSlice;
      final b = p.block(s.block) as LaidText;
      final t = p.typography;
      return Rect.fromLTWH(t.sideMargin + b.left, t.topInset + s.y, b.width, b.lines.last.bottom);
    }
    return tester.getRect(_key(id));
  }

  testWidgets('$nome — geometria: os 83 ids das seções', (tester) async {
    await abrirTela26(tester, livro);
    final ids = [for (final s in secoesL26) ...ref.idsOfSection(s)];
    expect(ids, hasLength(83));
    final falhas = <String>[];
    for (final id in ids) {
      final m = medido(tester, id);
      final e = ref.elements[id]!;
      final r = e.visual ?? e.rect;
      final tolX = ref.textDependentX.contains(id) ? 1.0 : 0.5;
      void confere(String o, double g, double x, double tol) {
        if ((g - x).abs() > tol + 1e-6) falhas.add('$id.$o: ${g.toStringAsFixed(2)} ≠ ${x.toStringAsFixed(2)}');
      }

      confere('x', m.left, r.left, tolX);
      confere('y', m.top, r.top, 0.5);
      confere('w', m.width, r.width, tolX);
      confere('h', m.height, r.height, 0.5);
    }
    expect(falhas, isEmpty, reason: falhas.join('\n'));
  });

  testWidgets('$nome — texto: as 14 linhas da prévia (6 à vista) e os textos da folha', (tester) async {
    await abrirTela26(tester, livro);
    final p = _pagina(tester);
    final s = p.page.slices.first as TextSlice;
    final b = p.block(s.block) as LaidText;
    final linhas = ref.elements['rs.page.text']!.lines;
    final base = p.typography.topInset + s.y - b.lines[s.firstLine].top;
    final corte = tester.getRect(_key('rs.paper')).top;
    expect(linhas, hasLength(14));
    for (var i = 0; i < 14; i++) {
      final line = b.lines[s.firstLine + i];
      final e = linhas[i];
      expect(p.item.text.substring(line.start, line.end).trimRight(), e.text);
      expect(base + line.baseline, moreOrLessEquals(e.baseline, epsilon: 0.5), reason: e.text);
      if (e.hidden) {
        expect(base + line.top, greaterThanOrEqualTo(corte - 1e-6), reason: 'atrás do papel: ${e.text}');
      } else {
        expect(base + line.baseline, lessThan(corte), reason: 'à vista: ${e.text}');
      }
    }
    void textos(String id, {bool composto = false}) {
      final e = ref.elements[id]!;
      final esperadas = composto ? e.linesAll : e.lines;
      final dx = (e.visual?.left ?? e.rect.left) - e.rect.left;
      final r = tester.renderObject<RenderAppText>(
        find.descendant(of: _key(id), matching: find.byType(AppText), matchRoot: true).last,
      );
      final got = r.debugLines();
      expect(got.map((l) => l.text), esperadas.map((l) => l.text), reason: id);
      for (var i = 0; i < got.length; i++) {
        expect(got[i].baseline, moreOrLessEquals(esperadas[i].baseline, epsilon: 0.5), reason: '$id baseline');
        expect(got[i].left, moreOrLessEquals(esperadas[i].left + dx, epsilon: 1), reason: '$id início');
        expect(got[i].right, moreOrLessEquals(esperadas[i].right + dx, epsilon: 1), reason: '$id fim');
      }
    }

    textos('rs.sheet.title', composto: true);
    textos('rs.livePill');
    for (final id in ref.elements.keys.where(
      (k) =>
          k.startsWith('rs.sheet.') &&
          k != 'rs.sheet.title' &&
          k != 'rs.sheet.title.serif' &&
          ref.elements[k]!.lines.isNotEmpty,
    )) {
      textos(id);
    }
  });

  testWidgets('$nome — estilo: folha, alça, ×, pontos, cartões, segmentados, rótulos e pílula', (tester) async {
    await abrirTela26(tester, livro);
    final brand = instantaneoBrand(instantaneo);
    final linha = BorderSide(width: 1.5, color: cores.border);
    final folha = tester.widget<NeoBox>(_key('rs.sheet'));
    expect(
      (folha.color, folha.border, folha.shadow, folha.shadowColor),
      (cores.island, linha, const Offset(0, 4), cores.shadow),
    );
    expect(tester.getSize(_key('rs.sheet.grabber')), const Size(40, 5));
    final ativo = tester.widget<NeoBox>(_key('rs.sheet.size.step4'));
    expect((ativo.color, ativo.border), (brand, linha));
    final literata = tester.widget<NeoBox>(
      find.descendant(of: _key('rs.sheet.fonts.literata'), matching: find.byType(NeoBox)),
    );
    expect((literata.color, literata.shadow, literata.radius), (brand, const Offset(2, 2), BorderRadius.circular(16)));
    final creme = tester.widget<NeoBox>(_key('rs.sheet.papers.cream.card'));
    expect((creme.color, creme.shadow, creme.radius), (AppColors.paperCream, const Offset(2, 2), BorderRadius.circular(14)));
    final check = tester.widget<NeoBox>(_key('rs.sheet.papers.cream.check'));
    expect((check.color, check.border), (brand, linha));
    final medio = tester.widget<NeoBox>(
      find.descendant(of: _key('rs.sheet.spacing.medium'), matching: find.byType(NeoBox)),
    );
    expect((medio.color, medio.border), (brand, linha));
    final rotulo = tester.widget<AppText>(_key('rs.sheet.fontLabel')).span.style!;
    expect(
      (rotulo.fontFamily, rotulo.fontSize, rotulo.fontWeight, rotulo.letterSpacing, rotulo.color),
      ('Figtree', 11.0, FontWeight.w800, 1.2, cores.label),
    );
    final titulo = tester.widget<AppText>(_key('rs.sheet.title')).span as TextSpan;
    final (a, b) = (titulo.children![0] as TextSpan, titulo.children![1] as TextSpan);
    expect((a.style!.fontFamily, a.style!.fontSize, a.style!.letterSpacing), ('Bricolage23', 23.0, -0.5));
    expect(
      (b.style!.fontFamily, b.style!.fontSize, b.style!.fontStyle, b.style!.letterSpacing),
      ('InstrumentSerif', 28.0, FontStyle.italic, -0.2),
    );
    final ponto = tester.widget<DecoratedBox>(
      find.descendant(of: _key('rs.livePill.dot'), matching: find.byType(DecoratedBox)),
    );
    expect((ponto.decoration as BoxDecoration).color, AppColors.flame);
  });

  testWidgets('$nome — semântica: diálogo, prévia, botões, deslizante e grupos', (tester) async {
    final h = tester.ensureSemantics();
    await abrirTela26(tester, livro);
    for (final r in [
      'Ajustes de leitura',
      'Prévia da página',
      'Fechar',
      'Diminuir a letra',
      'Aumentar a letra',
      'Tamanho da letra',
      'Fonte',
      'Tema do papel',
      'Entrelinha',
      'Margens',
    ]) {
      expect(find.bySemanticsLabel(r), findsOneWidget, reason: r);
    }
    expect(
      tester.getSemantics(find.bySemanticsLabel('Tamanho da letra')),
      isSemantics(label: 'Tamanho da letra', value: '4 de 7', isSlider: true),
    );
    for (final (id, rotulo, marcado) in const [
      ('rs.sheet.fonts.literata', 'Literata, tela', true),
      ('rs.sheet.fonts.lora', 'Lora, clássica', false),
      ('rs.sheet.fonts.figtree', 'Figtree, sem serifa', false),
      ('rs.sheet.fonts.atkinson', 'Atkinson, dislexia', false),
      ('rs.sheet.papers.cream', 'Tema Creme', true),
      ('rs.sheet.papers.white', 'Tema Branco', false),
      ('rs.sheet.papers.sepia', 'Tema Sépia', false),
      ('rs.sheet.papers.night', 'Tema Noite', false),
      ('rs.sheet.spacing.tight', 'Justo', false),
      ('rs.sheet.spacing.medium', 'Médio', true),
      ('rs.sheet.spacing.loose', 'Solto', false),
      ('rs.sheet.margins.narrow', 'Estreita', false),
      ('rs.sheet.margins.medium', 'Média', true),
      ('rs.sheet.margins.wide', 'Larga', false),
    ]) {
      expect(
        tester.getSemantics(_key(id)),
        isSemantics(label: rotulo, hasCheckedState: true, isChecked: marcado, isInMutuallyExclusiveGroup: true),
        reason: id,
      );
    }
    expect(find.bySemanticsLabel(RegExp('prévia ao vivo')), findsNothing, reason: 'aria-hidden');
    h.dispose();
  });

  testWidgets('$nome — dados: os ajustes mostrados são os da linha do mundo', (tester) async {
    await abrirTela26(tester, livro);
    final ajuste = mundoReferencia.ajustes;
    expect(ajuste.look, const ReaderLook());
    expect(tester.getSize(_key('rs.sheet.size.step${ajuste.fontStep}')), const Size(14, 14));
    expect(_key('rs.sheet.papers.cream.check'), findsOneWidget);
    // a prévia é a página do instantâneo (o rodapé fica atrás do papel do corte, mas continua montado)
    final rodape = tester.widget<AppText>(_key('r19.footer.pageLabel')).span.toPlainText();
    expect(rodape, 'pág. ${instantaneo.pagina} de ${instantaneo.totalDePaginas}');
  });
}
```

- [ ] **Passo 2 — `l26_test.dart`:**

```dart
// G14.5 — fase L26 (tela 26, a folha de ajustes de leitura, Creme) contra as medidas do arquivo.
import '../../../fixtures/telas/t26.dart';
import '../../../reference/leitor/reference_layout_26_ajustes_leitura.dart';
import '../../../support/fase_l26.dart';

void main() => faseL26(nome: 'L26', ref: kRef26, instantaneo: t26);
```

- [ ] **Passo 3 — rodar:** verde. Se um id falhar, olhar o lado a lado da Tarefa 16 antes de mexer.
  - Os de texto (±1) dependem das larguras da Tarefa 8.
  - Os de caixa dependem da coluna da folha (as alturas 13,2, 14,4 e 12,6).
- [ ] **Passo 4 — commit:** `test(leitor): fase L26 contra as medidas do arquivo (G14.5)`.

### Tarefa 16: golden e capturas

**Arquivos:** `test/golden/leitor_26_test.dart`, `test/golden/capturas_g14_test.dart` (novos).

- [ ] **Passo 1 — golden** (molde do `leitor_21_test.dart`):

```dart
// G14.5 — golden da tela 26 (a folha de ajustes, Creme) (L26, "Visual"): a tela inteira @3x (390×844 → 1170×2532,
// sem áreas seguras, como a prancha) pela rota real, no mundo de referência, com "Aa Fonte" tocado. É comparado com
// `handoff_v2/referencia/png/26_ajustes_leitura_390x844@3x.png` no recorte y 46–842 por `tools/compare_images.py`:
// blur_mismatch_% ≤ 0,5. Com BOOKNEST_CAPTURAS=<pasta> grava também a captura lá.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/dados_t20.dart';
import '../support/fase_l26.dart';
import '../support/load_fonts.dart';
import '../support/reader_harness.dart';

void main() {
  setUpAll(loadAppFonts);
  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela20());
  tearDown(() async => livro.close());

  testWidgets('golden da tela 26 (Creme, folha de ajustes) (390×844 @3x)', (tester) async {
    await abrirTela26(tester, livro, golden: true);
    expect(find.byKey(const ValueKey('rs.sheet')), findsOneWidget);
    final image = await captureAt(tester, find.byKey(goldenRootKey));
    expect((image.width, image.height), (1170, 2532));
    final pasta = Platform.environment['BOOKNEST_CAPTURAS'];
    if (pasta != null) {
      final png = await tester.runAsync(() => image.toByteData(format: ui.ImageByteFormat.png));
      Directory(pasta).createSync(recursive: true);
      File('$pasta${Platform.pathSeparator}g14_tela26_390x844@3x.png').writeAsBytesSync(png!.buffer.asUint8List());
    }
    await expectLater(image, matchesGoldenFile('goldens/leitor_26@3x.png'));
  });
}
```

  Gerar com `--update-goldens`.
- [ ] **Passo 2 — comparar com a prancha:**
  `python3 tools/compare_images.py --flutter test/golden/goldens/leitor_26@3x.png --ref handoff_v2/referencia/png/26_ajustes_leitura_390x844@3x.png --scale 3 --rect 0,46,390,796 --out build/visual_diff_g14 --name tela26`.
  - O resultado precisa ficar em `blur_mismatch_% ≤ 0,5`.
  - Inspecionar o lado a lado e o heatmap. O ponto que mais pode pesar é o padrão dos traços do trilho: o início
    do traço no contorno.
- [ ] **Passo 3 — capturas** (`capturas_g14_test.dart`, molde do `capturas_g13_test.dart`, gravando em
  `BOOKNEST_CAPTURAS`; sem a variável, só monta e confere que abriu). Cada captura grava a linha do ajuste
  (`ReaderSettingsDao.upsert(m.ajustes.withLook(look))`) antes de abrir:
  - `g14_tela26_creme` e `g14_tela26_noite` (com a folha);
  - `g14_fonte_lora`, `g14_fonte_figtree` e `g14_fonte_atkinson` (a página, sem a folha);
  - `g14_tamanho_1` e `g14_tamanho_7`;
  - `g14_entrelinha_justo` e `g14_entrelinha_solto`;
  - `g14_margens_estreita` e `g14_margens_larga`.
- [ ] **Passo 4 — commit:** `test(leitor): golden da tela 26 e capturas da G14 (G14.5)`.

### Tarefa 17: verificação e relatório

- [ ] **Suíte completa com cobertura** (`suite.ps1`):
  - `flutter analyze` com 0 problemas e todos os testes verdes;
  - cobertura ≥ 90 % nos arquivos de `lib/` mexidos na fase (`git diff --name-only 515d6a3..HEAD -- lib`).
- [ ] **Mutação** (`tools/medicao/tmp/mut/g14/`, gerador `/home/claude/g03/mut/gerar_g14.py`, no molde do
  `gerar_g13.py`). Uma troca por regra, e cada uma precisa reprovar os testes indicados:
  - **fontes:**
    - títulos da Atkinson em 600;
    - Skia em 700 no negrito da Lora;
    - sem a reserva da Literata;
    - `layoutKey` sem a fonte;
    - `readerFontsVersion` 1;
    - área do texto sem a fonte;
  - **ajustes:**
    - mudança aplicada sobre os ajustes do toque (fora da fila);
    - falha que muda os ajustes mesmo assim;
    - sem o último claro;
    - o Noite pela folha sem guardar o claro de antes;
    - a mesma escolha grava;
    - sem a versão nova (`old.meta`);
    - `sameLayout` ignorando a fonte;
  - **folha:**
    - A− habilitado no 1;
    - A+ habilitado no 7;
    - `readerStepAt` sem o ativo de 14;
    - arrasto que repete o passo;
    - base −20 em vez de −24;
    - pílula em 50;
    - corte em 0 em vez de 15,2;
    - fechar por arrasto a partir de 32;
    - legenda do Noite na cor do claro;
    - ✓ em todos os papéis;
    - opção sem `checked`;
  - **tela:**
    - fechar a folha fecha os controles;
    - Voltar fecha os controles antes da folha;
    - a folha abre no PDF;
    - barra de status escondida com a folha;
    - o prazo da pílula conta com a folha.
- [ ] **Revisão independente** por um agente que não escreveu o código. Corrigir com teste o que for técnico;
  perguntar o que for de produto.
- [ ] **gitleaks** nos commits da fase (`515d6a3..HEAD`) e em `lib/features/reader`, `lib/core/design_system`,
  `test` e `docs/progresso`.
- [ ] **`docs/progresso/G14.md`:** resultados, revisão, desvios, pendências e o checklist com os commits.
- [ ] **`docs/progresso/RELATORIO_G14.md`:** termina em "✅ FASE G14 concluída — aguardando sua aprovação para
  iniciar a FASE G15.". Vai também ao projeto (`handoff_app_completo/relatorios/RELATORIO_G14.md`).
- [ ] **Decisões no projeto:** D-18 e D-20 aprovadas e D-141 a D-144 em
  `handoff_app_completo/05_DECISOES_E_PERGUNTAS.md`, com a cópia local em
  `/home/claude/g03/projeto/05_DECISOES_E_PERGUNTAS.md`.
- [ ] **Capturas** mandadas na conversa.
- [ ] **Commit:** `docs(g14): resultados, revisão independente e relatório da fase`.
