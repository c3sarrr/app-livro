# G17 — Painéis da caneta e do marca-texto (telas 23 e 23b): plano de implementação

> **Para quem executa:** execução inline (superpowers:executing-plans), uma tarefa por vez, TDD: o teste falha no
> Windows (RED), o código mínimo passa (GREEN), commit pequeno. Passos com `- [ ]`.

**Objetivo:** as telas 23 e 23b idênticas às pranchas e funcionando: os painéis abrem pelo 2º toque e pelo poço,
cada controle grava o `pen_presets`, a roda/brilho/hex escolhem qualquer cor, as favoritas crescem e encolhem, os
rótulos se editam, e o Marca-texto vira grifo nas palavras (D-32 para todos, desfazer, Concluir numa transação). A
"Outra cor" da tela 21 usa o mesmo seletor; a tinta preta aparece no Noite.

**Arquitetura:**
- **Cor (puro + pintores):** `lib/core/design_system/color/` (`hsv.dart`, `color_names.dart`) e
  `lib/core/design_system/painters/color_wheel_painter.dart`; o widget `ColorPicker`
  (`lib/core/design_system/widgets/color_picker.dart`), usado pelo painel da caneta e pela folha "Outra cor".
- **Motor do marca-texto (puro):** `lib/features/reader/annotations/ink/marker_snap.dart` (traço → trechos) e
  `highlight_desk.dart` (os grifos da página na sessão, com a `planHighlight` da D-32); a prévia da 23b em
  `lib/features/reader/annotations/marker_preview.dart` (D-171, com a medida injetada).
- **Sessão:** a `AnnotationSession` ganha os ajustes, o Marca-texto, o painel aberto (`panel`), os rótulos e as
  contagens, e a mesa de grifos dentro da `InkWorkingCopy` (um comando por traço). O `InkChanges` passa ao formato 2
  (grifos novos, mudados, tirados e apagados) e o `InkRepository` grava tudo na transação.
- **Tela:** `pen_panel.dart`, `marker_panel.dart`, `tool_panel_frame.dart` (véu, moldura, seta, cabeçalho),
  `labels_sheet.dart`, `other_color_sheet.dart`; o `AnnotationMode` hospeda os painéis; o `ReaderScreen` liga o
  Voltar, a "Outra cor" e os rótulos.
- **Pintura:** alturas (D-172), ondulado (`wavy_underline.dart`), mancha na altura (R25), tinta do marca-texto
  (multiplicada; Noite pela D-133), D-174 e o achado 17.

**Pilha:** Flutter/Dart, drift, flutter_svg (`ColorMapper`), flutter_test, goldens @3x, `tools/compare_images.py`.

**Execução e ambiente (igual à G16):**
- Código escrito no espelho `/home/claude/g03/repo`, levado ao Windows por `ciclo.sh` + `expandir.ps1`; `dart
  format`, `dart analyze` e `flutter test <arquivo>` no Windows; os arquivos formatados voltam por `puxar.sh`.
- Commits pequenos (`tools/medicao/tmp/commits_g17<letra>.ps1` + `msg_g17_NN.txt`), mensagem `tipo(escopo):
  descrição` em português, com o rodapé `Co-Authored-By` e `Claude-Session`. Leituras do git com
  `git --no-optional-locks`; nenhum `index.lock` fica.
- Spec: `docs/progresso/G17.md` (D-171…D-179, regras R1…R28). As seções do desenho são citadas como §1…§7.

## Arquivos

| Arquivo | Responsabilidade | Tarefa |
|---|---|---|
| `lib/core/design_system/color/hsv.dart` (novo) | HSV ↔ ARGB/hex, luminância, contraste | 1 |
| `lib/core/design_system/color/color_names.dart` (novo) | nomes das favoritas e das cores do marca-texto | 1 |
| `lib/core/design_system/painters/color_wheel_painter.dart` (novo) | roda cônica + radial branco | 2 |
| `lib/core/design_system/widgets/color_picker.dart` (novo) | roda com cursor, brilho, campo hex (R13, R14) | 3 |
| `pubspec.yaml`, `app_icons_leitor.dart`, `app_illustrations_leitor.dart`, `main.dart` | recursos da 23/23b | 4 |
| `lib/features/reader/presentation/tool_shelf.dart` | R28: o marca-texto na cor dele | 4 |
| `lib/features/reader/annotations/ink/ink_stroke.dart` | `InkTool.marker(3)` | 5 |
| `lib/features/reader/annotations/ink/pen_width_scale.dart` (novo) | a escala da D-50 e a volta | 5 |
| `lib/features/reader/application/annotation_session.dart` | ajustes, Marca-texto, painel, rótulos, contagens | 6, 10, 11 |
| `lib/features/reader/presentation/tool_panel_frame.dart` (novo) | véu, moldura, seta, cabeçalho, fechar | 7 |
| `lib/features/reader/presentation/annotation_mode.dart`, `annotation_island.dart`, `reader_screen.dart` | R1–R5, poço, pontos da ilha (R18), Voltar | 7 |
| `lib/features/reader/presentation/pen_panel.dart` (novo) | tela 23 | 8, 9 |
| `lib/features/reader/annotations/ink/ink_geometry.dart`, `application/ink_page_geometry.dart` | `textTop`/`textBottom` da linha | 10 |
| `lib/features/reader/annotations/ink/marker_snap.dart` (novo) | palavras cobertas → trechos (R21) | 10 |
| `lib/features/reader/annotations/ink/highlight_desk.dart` (novo) | grifos da página na sessão (D-173) | 11 |
| `lib/features/reader/annotations/ink/ink_commands.dart` | a mesa na cópia de trabalho; `MarkHighlights` | 11 |
| `lib/features/reader/annotations/ink/ink_changes.dart` | `HighlightRow`, formato 2 do rascunho | 12 |
| `lib/features/reader/annotations/ink_repository.dart`, `test/support/fake_ink_repository.dart` | grifos na transação | 12 |
| `lib/features/reader/application/reader_annotations.dart` | D-173 na tela 21; altura no `PaintedHighlight` | 13 |
| `lib/features/reader/presentation/page_marks.dart`, `wavy_underline.dart` (novo), `ink_painter.dart`, `reader_page_view.dart`, `annotation_canvas.dart` | alturas, ondulado, mancha na altura, tinta do marca-texto, D-174, achado 17 | 14 |
| `lib/features/reader/annotations/marker_preview.dart` (novo) | D-171 | 15 |
| `lib/features/reader/presentation/marker_panel.dart` (novo) | tela 23b | 16 |
| `lib/features/reader/application/highlight_labels_store.dart` (novo), `presentation/labels_sheet.dart` (novo) | rótulos e contagens (D-40, D-177) | 17 |
| `lib/features/reader/presentation/other_color_sheet.dart` (novo), `reader_screen.dart` | D-178 | 18 |
| painéis e folhas | Noite (R26) | 19 |
| `test/support/dados_t23.dart` (novo), `dados_t22.dart`, `fase_l23.dart` (novo) | o mundo da 23/23b | 20 |
| `test/features/reader/fases/l23_test.dart`, `l23b_test.dart`, `test/golden/leitor_23_test.dart` (novos) | fases e golden | 21 |
| `test/features/reader/presentation/reader_screen_g17_test.dart` (novo) | comportamento | 22 |
| `test/golden/capturas_g17_test.dart` (novo), docs | prova e relatório | 23 |

---

## G17.1 — Cor

### Tarefa 1: HSV, contraste e nomes

**Arquivos:** criar `lib/core/design_system/color/hsv.dart` e `color_names.dart`; testes
`test/core/design_system/color/hsv_test.dart` e `color_names_test.dart`.

- [ ] **Passo 1 (RED):**

```dart
// G17.1 — HSV da roda da tela 23 (R13), hex e contraste (D-174).
import 'package:app_leitura/core/design_system/color/hsv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('coral #FF552E: tom 11,2°, intensidade 0,82, brilho 1 (o cursor do arquivo)', () {
    final c = Hsv.fromHex('#FF552E');
    expect(c.h, closeTo(11.196, 1e-3));
    expect(c.s, closeTo(209 / 255, 1e-9));
    expect(c.v, 1);
    expect(c.toHex(), '#FF552E');
  });
  test('ida e volta: todo hex de 6 dígitos volta igual', () {
    for (final hex in ['#000000', '#FFFFFF', '#1A1714', '#552CB7', '#058CD7', '#00995E', '#F2A815', '#FED170',
        '#FFC1C6', '#ABCF82', '#B6ACE4', '#7F7F80']) {
      expect(Hsv.fromHex(hex).toHex(), hex, reason: hex);
    }
  });
  test('as 6 cores primárias da roda (0°, 60° … 300°)', () {
    expect(const Hsv(0, 1, 1).toHex(), '#FF0000');
    expect(const Hsv(60, 1, 1).toHex(), '#FFFF00');
    expect(const Hsv(120, 1, 1).toHex(), '#00FF00');
    expect(const Hsv(180, 1, 1).toHex(), '#00FFFF');
    expect(const Hsv(240, 1, 1).toHex(), '#0000FF');
    expect(const Hsv(300, 1, 1).toHex(), '#FF00FF');
    expect(const Hsv(360, 1, 1).toHex(), '#FF0000');
  });
  test('com brilho 0 a cor é preta, mas o tom e a intensidade ficam (R13)', () {
    final c = const Hsv(11, 0.8, 1).withV(0);
    expect(c.toHex(), '#000000');
    expect((c.h, c.s), (11, 0.8));
  });
  test('hexValido: só #RRGGBB, maiúsculas', () {
    expect(normalizeHex('ff552e'), '#FF552E');
    expect(normalizeHex('#ff552e'), '#FF552E');
    expect(normalizeHex('#FF55'), isNull);
    expect(normalizeHex('#GG0000'), isNull);
  });
  test('contraste WCAG 2.1 e a D-174 (< 1,5 : 1 com o papel do Noite)', () {
    expect(contrastRatio(0xFFFFFFFF, 0xFF000000), closeTo(21, 1e-9));
    expect(contrastRatio(0xFF1A1714, 0xFF1F1B17), lessThan(1.5));
    expect(contrastRatio(0xFF552CB7, 0xFF1F1B17), greaterThan(1.5));
    expect(contrastRatio(0xFF058CD7, 0xFF1F1B17), greaterThan(1.5));
  });
}
```

`color_names_test.dart`: `penColorName('#FF552E') == 'Coral'` … `'#1A1714' == 'Tinta preta'`; `penColorName('#12AB34')
== null`; `markerColorName('#FED170') == 'amarelo'`, `'#FFC1C6' == 'rosa'`, `'#ABCF82' == 'verde'`, `'#B6ACE4' ==
'lavanda'`; `markerColors` na ordem amarelo, rosa, verde, lavanda (os hex da `highlightPalette`); comparação sem
diferença de maiúsculas.

Run: `flutter test test/core/design_system/color/`. Esperado: FAIL (arquivos não existem).

- [ ] **Passo 2 (GREEN):**

```dart
// hsv.dart
// G17.1 — a cor da roda da tela 23 (R13): tom 0–360 (0° no topo, sentido horário — o conic-gradient do arquivo),
// intensidade 0–1 (do centro à borda) e brilho 0–1 (o V do HSV). `normalizeHex` aceita só 6 dígitos (R14).
// `contrastRatio` é o da WCAG 2.1 (D-174).
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable;

@immutable
final class Hsv {
  const Hsv(this.h, this.s, this.v);

  final double h;
  final double s;
  final double v;

  factory Hsv.fromArgb(int argb) {
    final r = (argb >> 16 & 0xFF) / 255;
    final g = (argb >> 8 & 0xFF) / 255;
    final b = (argb & 0xFF) / 255;
    final max = math.max(r, math.max(g, b));
    final min = math.min(r, math.min(g, b));
    final d = max - min;
    double h;
    if (d == 0) {
      h = 0;
    } else if (max == r) {
      h = 60 * (((g - b) / d) % 6);
    } else if (max == g) {
      h = 60 * ((b - r) / d + 2);
    } else {
      h = 60 * ((r - g) / d + 4);
    }
    return Hsv(h < 0 ? h + 360 : h, max == 0 ? 0 : d / max, max);
  }

  factory Hsv.fromHex(String hex) => Hsv.fromArgb(0xFF000000 | int.parse(hex.substring(1), radix: 16));

  Hsv withH(double h) => Hsv(h, s, v);
  Hsv withS(double s) => Hsv(h, s, v);
  Hsv withV(double v) => Hsv(h, s, v);

  int toArgb() {
    final c = v * s;
    final hh = (h % 360) / 60;
    final x = c * (1 - ((hh % 2) - 1).abs());
    final (r, g, b) = switch (hh.floor()) {
      0 => (c, x, 0.0),
      1 => (x, c, 0.0),
      2 => (0.0, c, x),
      3 => (0.0, x, c),
      4 => (x, 0.0, c),
      _ => (c, 0.0, x),
    };
    final m = v - c;
    int ch(double u) => ((u + m) * 255).round().clamp(0, 255);
    return 0xFF000000 | ch(r) << 16 | ch(g) << 8 | ch(b);
  }

  String toHex() => '#${(toArgb() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  @override
  bool operator ==(Object other) => other is Hsv && other.h == h && other.s == s && other.v == v;

  @override
  int get hashCode => Object.hash(h, s, v);
}

/// `#RRGGBB` em maiúsculas; `null` se não forem 6 dígitos hexadecimais (com ou sem "#").
String? normalizeHex(String text) {
  final t = text.startsWith('#') ? text.substring(1) : text;
  if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(t)) return null;
  return '#${t.toUpperCase()}';
}

double relativeLuminance(int argb) {
  double lin(int c) {
    final u = c / 255;
    return u <= 0.04045 ? u / 12.92 : math.pow((u + 0.055) / 1.055, 2.4).toDouble();
  }
  return 0.2126 * lin(argb >> 16 & 0xFF) + 0.7152 * lin(argb >> 8 & 0xFF) + 0.0722 * lin(argb & 0xFF);
}

double contrastRatio(int a, int b) {
  final la = relativeLuminance(a);
  final lb = relativeLuminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}
```

O teste da ida e volta prova o arredondamento: se algum hex não voltar igual, guardar no `Hsv` o tom e a intensidade
com precisão dupla e arredondar só na saída (já é assim). `color_names.dart`: dois mapas constantes e
`penColorName`/`markerColorName` (chave em maiúsculas); `markerColors` = os 4 hex da `highlightPalette` na ordem.

- [ ] **Passo 3:** passa. Commit `feat(cor): HSV, hex, contraste e nomes das cores (G17.1)`.

### Tarefa 2: a roda de cores

**Arquivos:** criar `lib/core/design_system/painters/color_wheel_painter.dart`; teste
`test/core/design_system/painters/color_wheel_painter_test.dart`; entrada no `test/home/performance_test.dart`.

- [ ] **Passo 1 (RED):** pintando a roda de 124 num `PictureRecorder` e lendo os pixels (`toByteData(rawRgba)`):
  - o centro é branco (`#FFFFFF` ± 2);
  - na borda útil (raio 60,5), o topo é vermelho, 60° no sentido horário é amarelo, 180° é ciano, 270° é magenta-azul
    (± 6 por canal: o degradê do arquivo é cônico em RGB, como o CSS);
  - fora do círculo, transparente; a borda de 1,5 em tinta (`#1A1714`) no raio 61,25;
  - `wheelHsvAt(offset, size)` e `wheelOffsetOf(hsv, size)` são inversos (tom pelo ângulo do topo no sentido horário;
    intensidade = distância ÷ 60,5, limitada a 1): coral → o centro do cursor do arquivo `(103, 523,8)` com a roda em
    `(31,5, 510,5)`, ± 0,5;
  - `shouldRepaint` só com outro tamanho ou outra cor de borda (a roda não muda com a cor escolhida).

- [ ] **Passo 2 (GREEN):** o pintor desenha, no círculo de raio `size/2 − 1,5`, um `SweepGradient` com as cores
  `[#FF0000, #FFFF00, #00FF00, #00FFFF, #0000FF, #FF00FF, #FF0000]`, `startAngle: −π/2` girado (o `SweepGradient` do
  Flutter começa à direita: usar `transform: GradientRotation(−π/2)`), por cima um `RadialGradient` de branco a
  branco transparente (o `closest-side`), e o anel de 1,5. As funções `wheelHsvAt`/`wheelOffsetOf` ficam no mesmo
  arquivo.

- [ ] **Passo 3:** passa (e o `performance_test` com as variantes). Commit `feat(cor): roda de cores com pintor
  próprio`.

### Tarefa 3: o seletor (roda, brilho e hex)

**Arquivos:** criar `lib/core/design_system/widgets/color_picker.dart`; teste
`test/core/design_system/widgets/color_picker_test.dart`.

- [ ] **Passo 1 (RED):** o `ColorPicker(color: '#FF552E', onChanged:, onChangeEnd:, brand:, palette:)` numa caixa
  de 327 de largura:
  - geometria do `kRef23` relativa ao `pen.penPanel.picker` (31,5; 510,5): roda 124; cursor 24 em (59,5; 1,3);
    lado 187 a 140 da esquerda; BRILHO, trilho de 16, botão de 26 em (162,5; 31,1); o hex de 42 com a amostra 18 e
    "#FF552E" (Figtree 15/800, espaço 0,6);
  - tocar na roda a 90° do topo, na borda, chama `onChanged` com o tom 90 e `onChangeEnd` ao soltar; arrastar para
    fora prende na borda;
  - arrastar o brilho até o começo dá `#000000`; voltar a 100 % dá a cor com o tom e a intensidade guardados (R13);
  - o degradê do brilho vai de `#1A1714` à cor com brilho 100 %;
  - o campo hex: digitar "1a2b3c" mostra "#1A2B3C" e chama `onChangeEnd('#1A2B3C')` ao completar os 6; "G" é
    recusado; sair com "#12" volta ao hex atual (R14);
  - semântica: a roda é slider "Roda de cores: tom e intensidade" com o valor "coral" (ou o hex); aumentar gira o tom
    +15°; o brilho é slider "Brilho" com "100 %" e passos de 5; o campo é "Código da cor".

- [ ] **Passo 2 (GREEN):** `StatefulWidget` com o `Hsv` atual (atualizado quando o `color` de fora muda e não é a
  cor que ele mesmo mandou), `GestureDetector` de arrasto na roda e no trilho, `TextField` com um
  `TextInputFormatter` (só `[0-9A-Fa-f]`, maiúsculas, até 6) e o "#" fixo como prefixo; o foco do campo avisa o pai
  (`onHexFocus(bool)`) para a subida da R14. O cursor e o botão são `NeoBox` circulares (aro 3 `#FFFAF1` + borda de
  tinta), na cor atual.

- [ ] **Passo 3:** passa. Commit `feat(cor): seletor com roda, brilho e hex (R13, R14)`.

---

## G17.2 — Sessão, recursos e painéis

### Tarefa 4: recursos e o marca-texto na cor dele (R28)

**Arquivos:** `pubspec.yaml` (as ilustrações `il_previa_traco_caneta`, `il_ponta_{esferografica,tinteiro,pincel}`,
`il_dica_gruda_nas_palavras` e os ícones `ic_close`, `ic_plus`), `app_illustrations_leitor.dart`
(`penPreview`, `tipBallpoint`, `tipFountain`, `tipBrush`, `markerTip`), `app_icons_leitor.dart` (`close`, `plus`),
`main.dart` (pré-cache), `tool_shelf.dart`; testes `test/core/design_system/tokens/app_illustrations_leitor_test.dart`
e `test/features/reader/presentation/tool_shelf_test.dart`.

- [ ] **Passo 1 (RED):** cada constante aponta para um arquivo que existe e carrega (o teste dos recursos da G16);
  `ToolShelf.art(marker, on: true, brand:, ink:, marker: AppColors.blush)` troca `AppColors.sun` (`#FED170`) por `#FFC1C6`; com
  `#FED170`, o mapa é vazio (igual à prancha).
- [ ] **Passo 2 (GREEN):** o parâmetro `marker` no `ToolShelf` e no `art` (`{AppColors.sun: marker}`).
- [ ] **Passo 3:** passa. Commit `feat(leitor): recursos das telas 23 e 23b; marca-texto na cor dele (R28)`.

### Tarefa 5: o Marca-texto no BNK1 e a escala da espessura

**Arquivos:** `ink_stroke.dart` (`InkTool.marker(3)`), criar `ink/pen_width_scale.dart`; testes
`ink_stroke_test.dart`, `pen_width_scale_test.dart`.

- [ ] **Passo 1 (RED):**

```dart
test('a escala da D-50: 1,2 mm em 32 %; as pontas; ida e volta em passos de 0,1', () {
  expect(sliderOfWidth(1.2), closeTo(0.3198, 1e-3));
  expect(widthOfSlider(0), 0.3);
  expect(widthOfSlider(1), 4.0);
  for (var mm = 3; mm <= 40; mm++) {
    expect(widthOfSlider(sliderOfWidth(mm / 10)), mm / 10);
  }
  expect(widthOfSlider(0.32), 1.2); // arredonda para 0,1
});
test('o Marca-texto é a ferramenta 3 do BNK1', () {
  expect(InkTool.fromCode(3), InkTool.marker);
});
```

- [ ] **Passo 2 (GREEN):** `widthOfSlider(t) = (0,3 + 3,7·t^1,24)` arredondado a 0,1 e preso em 0,3–4,0;
  `sliderOfWidth(mm) = ((mm − 0,3)/3,7)^(1/1,24)`. Atualizar o teste da G16 que esperava `fromCode(3) == null`.
- [ ] **Passo 3:** passa. Commit `feat(tinta): Marca-texto no BNK1 e a escala da espessura (D-50)`.

### Tarefa 6: os ajustes e o painel na sessão

**Arquivos:** `annotation_session.dart`; teste `test/features/reader/application/annotation_session_test.dart`
(grupo novo "ajustes da G17").

- [ ] **Passo 1 (RED):** com o `savePresets` gravando numa lista:
  - `setPenTip(fountain)`, `setPenWidth(2.0)`, `setPenColor('#058CD7')` mudam o `presets` e gravam uma vez cada;
    `setPenWidth(2.0, save: false)` (o arrasto) só muda; `setPenWidth(2.0)` sem mudança não grava;
  - `addFavorite()` junta a cor atual no fim (nada se já está ou se há 12); `removeFavorite('#058CD7')` tira e
    devolve o índice; `restoreFavorite('#058CD7', 2)` devolve ao lugar (o Desfazer da pílula);
  - `setHighlighterStyle(wavy)`, `setHighlighterColor('#FFC1C6')`, `setHighlighterHeight(high)` gravam;
  - `setTool(marker)` passa a valer (`inThisPhase` só recusa o Espaço); `color` é a da caneta com Caneta e Reta, a do
    marca-texto com o Marca-texto, e a da última de tinta com Borracha e Laço (R2);
  - `panel`: `openPanel(AnnotationTool.pen)` → `(kind: pen, from: pen)`; `openPanel(line)` → `(kind: pen, from:
    line)`; `openPanel(marker)` → `(kind: marker, from: marker)`; `openPanel(eraser)` depois do Marca-texto → `(kind:
    marker, from: marker)`; `closePanel()` → `null`;
  - a sessão avisa (`notifyListeners`) em cada ajuste.
- [ ] **Passo 2 (GREEN):** os métodos acima, com `_save(PenPresets next, {bool save = true})` (o mesmo
  `catchError` → `onError` da espessura); `AnnotationTool.inThisPhase => this != space`; `_lastInk` atualizado no
  `setTool` de Caneta/Reta/Marca-texto; `ValueNotifier<OpenPanel?> panel` com `typedef OpenPanel = ({PanelKind
  kind, AnnotationTool from})` e `enum PanelKind { pen, marker }`. `setStrokeSize` continua só para a caneta; com o
  Marca-texto, a ilha chama `setHighlighterHeight` (Tarefa 7).
- [ ] **Passo 3:** passa (e o teste da G16 que esperava `setTool(marker) == false` passa a esperar `true`). Commit
  `feat(leitor): ajustes da caneta e do marca-texto na sessão (G17.2)`.

### Tarefa 7: véu, moldura, seta e as regras de abrir e fechar (R1–R5, R18 na ilha)

**Arquivos:** criar `tool_panel_frame.dart`; `annotation_mode.dart`, `annotation_island.dart`, `reader_screen.dart`;
testes `test/features/reader/presentation/tool_panel_frame_test.dart`, `annotation_mode_test.dart`,
`annotation_island_test.dart`.

- [ ] **Passo 1 (RED):**
  - `ToolPanelFrame(title:, subtitle:, arrowLeft:, onClose:, child:)` em 390×844 com a prateleira em 676: o véu
    (`ann.fade`, 0,0,390,844, papel a 66 %, `ExcludeSemantics`), o painel (`ann.penPanel` 14/125/362/529 com o
    filho da 23 no `kRef23`), a seta (`ann.penPanel.arrow` na caixa 57,5/644,5/17,5 e visual 53,88/640,88/24,75), o
    cabeçalho, o título, o subtítulo, o fechar 44 e o ícone 18; raio 26, borda 1,5, sombra 4/4; `Semantics` dialog
    "Ajustes da caneta"; o fechar é "Fechar ajustes";
  - no modo: 2º toque na Caneta abre a 23; de novo fecha (R1); Reta ativa + 2º toque abre a 23 com a seta em 251;
    Borracha e Laço: nada (sem aviso); Espaço: aviso; poço com Borracha depois do Marca-texto abre a 23b; o toque no
    véu só fecha (a sessão não recebe ponteiro); outra ferramenta fecha e troca (R4); Fina/Média/Grossa, Desfazer e
    Refazer funcionam com o painel aberto; o véu aparece em 150 ms e, com `disableAnimations`, na hora (R5);
  - a ilha com o Marca-texto: o poço e os pontos em `#FED170`; os pontos dizem "Baixa", "Média" e "Alta"; tocar
    "Alta" chama `setHighlighterHeight(high)`; com Sublinhado, os pontos ficam a 0,38 e "indisponível" (R18); o poço
    diz "Cor do marca-texto: amarelo. Toque para ajustar o marca-texto";
  - no `ReaderScreen`: o Voltar com um painel aberto fecha o painel e não conclui (D-42 por camadas).
- [ ] **Passo 2 (GREEN):**
  - `ToolPanelFrame`: `Stack` com o véu (`GestureDetector` que fecha) e o painel `Positioned(left: 14, right: 14,
    bottom: shelfBottom + 70 + 22)`; a seta `Positioned(left: arrowLeft + 1,5, bottom: −9,5 − 1,5)` como
    `Transform.rotate(π/4)` de um `NeoBox` 16 só com as bordas de baixo e da direita; o miolo num
    `SingleChildScrollView` só quando não cabe (R7);
  - `arrowLeftOf(AnnotationTool)`: pen 42, marker 95, line 251;
  - `AnnotationMode._tool`: `if (t == s.tool) { s.panel.value?.from == t ? s.closePanel() : s.openPanel(t) }`;
    senão `s.closePanel()` e `setTool` (Espaço → `onSoon`); poço → `s.openPanel(s.tool)`; os painéis entre o topo e
    a prateleira na ordem do `Stack` (canvas, borda, topo, véu+painel, prateleira, ilha, pílula de aviso);
  - `AnnotationIsland`: `heights` (com o Marca-texto) no lugar de `strokeSize`, `enabledSizes`, rótulos dos pontos e
    do poço pela ferramenta;
  - `ReaderScreen.PopScope`: `if (_ann?.session.panel.value != null) { session.closePanel(); return; }` antes do
    Concluir.
- [ ] **Passo 3:** passa. Commit `feat(leitor): véu, moldura e seta dos painéis; abrir e fechar (R1–R5, R18)`.

---

## G17.3 — Painel da caneta (tela 23)

### Tarefa 8: cabeçalho, prévia e pontas (L23.1–L23.3)

**Arquivos:** criar `pen_panel.dart`; teste `test/features/reader/presentation/pen_panel_test.dart`.

- [ ] **Passo 1 (RED):** `PenPanel(session:)` no `ToolPanelFrame`, 390×844, com o `pen_presets` padrão:
  - geometria (`kRef23`, ±0,5; ±1 em x/w nos `textDependentX`): `ann.penPanel.title`, `.subtitle`, `.preview`,
    `.preview.art`, `.tipLabel`, `.tips`, `.tips.{ballpoint,fountain,brush}` e as `.sample`;
  - o subtítulo "Esferográfica · 1,2 mm · coral" (R8); com `#12AB34`: "Esferográfica · 1,2 mm · #12AB34"; com
    Tinteiro e 2 mm: "Tinteiro · 2,0 mm · coral" (sempre 1 casa, como o `numeric(3,1)`);
  - a prévia (R9): o caminho do arquivo amostrado (os mesmos pontos do SVG, a cada 0,5 px) pelo `inkPath` com a ponta,
    a cor e `widthCentiMm` = espessura × Fina/Média/Grossa × 17/11; na Média de 1,2 mm o contorno tem 3,4 px de
    largura no meio do traço (± 0,1); na Grossa de 4,0 mm a faixa recorta; `role=img` "Prévia do traço";
  - pontas: o ativo com `brand` e a sombra 2/2; tocar Tinteiro chama `setPenTip(fountain)`; as amostras na cor da
    caneta (o `#FF552E` do SVG trocado); `radiogroup` "Tipo de ponta" com os rótulos e o marcado.
- [ ] **Passo 2 (GREEN):** `PenPanel` (`StatelessWidget` que ouve a sessão); a prévia num `CustomPainter`
  (`PenPreviewPainter`, entra no `performance_test`) com a faixa pautada (`#F7F0E3`, fio `#E6DBC6` de 1,5 a cada
  19,5), o recorte do raio 16 e o traço `InkStroke(tool: pen, tip:, argb:, widthCentiMm:, points:)` dos pontos do
  caminho `il_previa_traco_caneta` (caixa 300×56 centrada em 326: deslocamento 13) com pressão 0,5.
- [ ] **Passo 3:** passa. Commit `feat(leitor): painel da caneta — cabeçalho, prévia e pontas (L23.1–L23.3)`.

### Tarefa 9: espessura, favoritas e seletor (L23.4–L23.6)

**Arquivos:** `pen_panel.dart`; teste `pen_panel_test.dart`.

- [ ] **Passo 1 (RED):**
  - espessura: `ann.penPanel.sizeHeader{,.label,.value}`, `.size`, `.size.{minDot,slider,slider.fill,slider.knob,
    maxDot}` no `kRef23`; o preenchimento 89,92 a 1,2 mm (32 %); arrastar o botão até o fim dá "4,0 mm" e grava ao
    soltar (uma vez); o slider "Espessura" 0,3–4, "1,2 milímetro", aumentar → 1,3 (R11);
  - favoritas: `.favorites`, as 6 e o `.add` com o ícone no `kRef23`; a coral marcada (aro duplo); tocar Azul chama
    `setPenColor('#058CD7')`; com uma cor nova, "+" junta e a fileira passa a 7 círculos + "+" na 2ª fileira
    (passo 47,5; o painel cresce para cima); com a cor já favorita, "+" a 0,38 "indisponível"; com 12, sem "+";
    pressão longa tira e mostra "Cor tirada das favoritas" com Desfazer, que devolve ao lugar; leitor de tela
    "Coral"…"Tinta preta", "Cor #12AB34", a ação "Tirar das favoritas", o "+" "Salvar a cor atual nas favoritas"
    (R12, D-175);
  - seletor: o `ColorPicker` no `.picker` com a roda, o cursor, o brilho, o botão e o hex do `kRef23`; arrastar na
    roda muda a cor da caneta, a prévia e o subtítulo e grava ao soltar; o hex: o painel sobe com o teclado até o
    campo ficar 8 acima dele (R14).
- [ ] **Passo 2 (GREEN):** o slider próprio (`HatchPainter` do design system a 135°, `#E9DFCC` 3 / `#FFFAF1` 4, o
  preenchimento `brand`, o botão `NeoBox` 28) com `sliderOfWidth`/`widthOfSlider`; as favoritas num `Wrap` de 7
  colunas com espaçamento fixo (os 47,5 do arquivo) e o `UndoPill` (D-132) acima da prateleira; o `ColorPicker` com
  `onChanged → setPenColor(save: false)` e `onChangeEnd → setPenColor`; a subida do hex pelo
  `MediaQuery.viewInsetsOf(context).bottom`.
- [ ] **Passo 3:** passa. Commit `feat(leitor): painel da caneta — espessura, favoritas e seletor (L23.4–L23.6)`.

---

## G17.4 — Marca-texto na página

### Tarefa 10: palavras cobertas (R21) e o traço do marca-texto (R20, R22)

**Arquivos:** `ink_geometry.dart` (`InkLine.textTop`/`textBottom`, opcionais), `ink_page_geometry.dart`, criar
`marker_snap.dart`; `annotation_session.dart`; testes `marker_snap_test.dart`, `ink_page_geometry_test.dart`,
`annotation_session_test.dart`.

- [ ] **Passo 1 (RED):** `marker_snap_test.dart`, com uma página de 3 linhas montada à mão (palavras de 40 px com 10
  de espaço; "Olhos de ressaca? Vá, de ressaca." na 2ª):

```dart
test('reta sobre "de ressaca": um trecho, das letras da 1ª à última palavra', () {
  final runs = markedRuns(traco(y: 47, de: 55, ate: 160), pagina, textOf: texto);
  expect(runs, [(unit: 0, from: 37, to: 47)]);
});
test('palavra com menos da metade sob o traço fica de fora; a pontuação não conta nem quebra', () { … });
test('torto, descendo para a linha de baixo: as palavras de cada linha que ficam ≥ 50 % sob o traço', () { … });
test('cobertas seguidas em 2 linhas (fim de uma, começo da outra) = um trecho só', () { … });
test('cobertas com uma palavra no meio sem cobrir = 2 trechos', () { … });
test('um toque (1 ponto, sem comprimento) não cobre palavra: nenhum trecho (vira tinta — R22)', () { … });
test('sem palavra sob o traço (margem): nenhum trecho', () { … });
```

  Na sessão: com o Marca-texto, o traço ao vivo é `LiveMarker(points, width, argb)` com a largura da faixa da altura
  na linha mais perto (Média = 80 % de `textBottom − textTop`); ao soltar sobre palavras, nenhum traço novo e um
  passo no desfazer; na margem, um traço `tool: 3` com a cor a 90 % (`0xE6`) e a largura em centésimos de mm
  (R22), num desenho da D-162.
- [ ] **Passo 2 (GREEN):**

```dart
// marker_snap.dart
// G17.4 — o Marca-texto "gruda nas palavras" (Anexo 03 §9.4, R21): a linha central do traço é recortada na faixa de
// cada linha (topo e base da linha inteira); uma palavra com letra ou número é coberta quando ≥ 50 % da largura dela
// fica sob os pedaços do traço nessa faixa; cobertas seguidas no texto (só pontuação e espaço entre elas) formam um
// trecho. Dart puro.
typedef MarkedRun = ({int unit, int from, int to});

final RegExp _letter = RegExp(r'[\p{L}\p{N}]', unicode: true);

List<MarkedRun> markedRuns(
  List<InkOffset> points,
  InkPageGeometry page, {
  required String? Function(int unit) textOf,
  double cover = 0.5,
}) {
  final runs = <MarkedRun>[];
  int? unit;
  int? from;
  int? to;
  void close() {
    if (unit != null) runs.add((unit: unit!, from: from!, to: to!));
    unit = null;
  }
  for (final line in page.lines) {
    final spans = _spansIn(points, line.top, line.bottom);
    final text = textOf(line.unit);
    for (final w in line.words) {
      if (text == null || !_letter.hasMatch(text.substring(w.from, w.to))) continue;
      final covered = _overlap(spans, w.left, w.right) >= cover * (w.right - w.left);
      if (!covered) {
        close();
      } else if (unit == line.unit) {
        to = w.to;
      } else {
        close();
        unit = line.unit;
        from = w.from;
        to = w.to;
      }
    }
  }
  close();
  return runs;
}
```

  `_spansIn` recorta cada segmento `p[k]…p[k+1]` em `[top, bottom]` (o pedaço x entre as interseções) e une os
  intervalos; `_overlap` soma a sobreposição. A sessão ganha o modo `marker` (`_drawStart/_drawMove/_drawEnd`), o
  `LiveMarker` e o `InkStroke` de ferramenta 3 quando `markedRuns` é vazio. O adaptador `inkGeometryOf` preenche
  `textTop`/`textBottom` (do `TextLineBox`).
- [ ] **Passo 3:** passa. Commit `feat(tinta): o marca-texto gruda nas palavras (R20–R22)`.

### Tarefa 11: a mesa de grifos e a D-32 ao vivo (D-173, R23)

**Arquivos:** criar `highlight_desk.dart`; `ink_commands.dart` (a mesa na `InkWorkingCopy`, o comando
`MarkHighlights`, a Borracha na mesa); `annotation_session.dart` (os grifos da página entram como `DeskHighlight`;
`paintedHighlights`/`paintedInkHighlights`; contagens da sessão); testes `highlight_desk_test.dart`,
`ink_commands_test.dart`, `annotation_session_test.dart`.

- [ ] **Passo 1 (RED):** `highlight_desk_test.dart`:
  - `DeskHighlight(id, unit, start, end, color, style, height, ink, groupId, createdAt)`;
  - `desk.mark(run, color:, style:, height:, id:, groupId:, at:)` sobre um grifo de seleção amarelo: o mesmo
    amarelo/fundo → um só, o id do mais antigo, `ink: false` (fica o jeito do mais antigo — D-173); rosa sobre
    amarelo → o rosa inteiro e o amarelo cortado em 2 (o da direita novo, com a cor, o estilo, a altura, o grupo e a
    origem do antigo); cobrindo todo um amarelo com nota → o amarelo sai e `noteTargets[amarelo] == rosa`;
  - encadeado: A tirado para B, depois B tirado para C → `resolvedTargets[A] == C`;
  - `counts()` por cor; `apagados` ficam fora de `items` e das contagens.
  Comandos: `MarkHighlights(before, after)` aplica e desfaz (a mesa volta igual, com os destinos das notas); a
  Borracha tira o grifo à mão novo (some) e o salvo (vai para `erasedHighlights`); grifo de seleção não é apagável.
  Sessão: marca sobre o grifo à mão do mundo e pinta a lista nova; Desfazer volta; a contagem do amarelo sobe 1.
- [ ] **Passo 2 (GREEN):** a mesa como valor imutável (`List<DeskHighlight> items`, `Map<String, String> notes`) e
  `mark` com a `planHighlight` dos grifos do mesmo `unit`:

```dart
HighlightDesk mark(MarkedRun r, {required String color, required HighlightStyle style, required FillHeight? height,
    required String id, required String groupId, required DateTime at}) {
  final same = [for (final h in items) if (h.unit == r.unit) h];
  final plan = planHighlight([
    for (final h in same)
      (id: h.id, start: h.start, end: h.end, color: h.color, style: h.style, createdAt: h.createdAt),
  ], (start: r.from, end: r.to, color: color, style: style));
  final byId = {for (final h in same) h.id: h};
  final keep = plan.keepId == null ? null : byId[plan.keepId];
  final next = <DeskHighlight>[
    for (final h in items)
      if (h.unit != r.unit || !(plan.removed.contains(h.id) || h.id == plan.keepId)) _resized(h, plan),
    keep == null
        ? DeskHighlight(id: id, unit: r.unit, start: plan.start, end: plan.end, color: color, style: style,
            height: style == HighlightStyle.fill ? height : null, ink: true, groupId: groupId, createdAt: at)
        : keep.copyWith(start: plan.start, end: plan.end),
    for (final a in plan.added) byId[a.from]!.copyWith(id: _newId(), start: a.start, end: a.end),
  ];
  final target = keep?.id ?? id;
  return HighlightDesk(next, {...notes, for (final g in plan.removed) g: plan.notesTo[g] ?? target});
}
```

  (`_newId` vem de um gerador injetado — os pedaços da direita ganham id novo, como na tela 21.) A
  `InkWorkingCopy` guarda a mesa; `MarkHighlights` troca a mesa inteira (antes/depois); `Erase` passa os ids de
  grifo à mesa (`desk.erase(ids)` → `erased`). A sessão monta a mesa ao abrir (o `ReaderScreen` passa os grifos com
  `unit/start/end` do `placeOf`, cor, estilo, altura, grupo, origem e data) e entrega à pintura
  `paintedHighlights` (os de seleção) e `paintedInkHighlights` (os à mão), sem os apagados.
- [ ] **Passo 3:** passa. Commit `feat(tinta): grifos do marca-texto com a D-32 na sessão (D-173, R23)`.

### Tarefa 12: o Concluir com os grifos e o rascunho no formato 2 (R24)

**Arquivos:** `ink_changes.dart` (`HighlightRow`, `MovedHighlight`, `InkChanges.highlights/moved/removed`, JSON v2
lendo o v1), `annotation_session.dart` (`changes()`), `ink_repository.dart` (a transação),
`test/support/fake_ink_repository.dart`; testes `ink_changes_test.dart`, `ink_repository_test.dart`,
`annotation_session_test.dart`, `ink_privacy_free_test.dart`.

- [ ] **Passo 1 (RED):**
  - `InkChanges(highlights: [HighlightRow(...)], moved: [(id, range, refPage, chapterIndex)], removed: {'a': 'b'})`
    ida e volta no JSON v2; o rascunho v1 da G16 (texto fixo no teste) ainda é lido, com as listas vazias; v3 →
    `null`;
  - `changes()`: o grifo novo com a âncora de 7 chaves (sha, item, início, fim, citação, página de referência), a
    página, o capítulo, o grupo do traço, a cor, o estilo, a altura e `source: ink`; o amarelo cortado → `moved`; o
    pedaço da direita → `highlights` com a origem dele; o tirado → `removed` com o destino resolvido; o apagado pela
    Borracha → `erasedHighlights` e fora das outras listas;
  - repositório (Drift): numa transação, grava os novos (versão HLC), muda os movidos, tomba os tirados e leva as
    notas deles para o destino (o grupo, a âncora, a página e o capítulo do destino), apaga os apagados com as notas
    (D-168); no Grátis, nenhuma linha na fila e nenhuma chamada de rede; no Pro, as linhas na fila;
  - a recuperação do rascunho (D-166) grava os grifos do rascunho v2.
- [ ] **Passo 2 (GREEN):** os tipos e o JSON; `InkRepository.conclude` com `_writeHighlight`, `_moveHighlight`,
  `_removeHighlight(id, to)` (as notas como em `ReaderAnnotations._apply`); o `FakeInkRepository` guarda as listas.
- [ ] **Passo 3:** passa. Commit `feat(tinta): o Concluir grava os grifos do marca-texto; rascunho no formato 2 (R24)`.

### Tarefa 13: a tela 21 com a D-173 e a altura no grifo pintado

**Arquivos:** `reader_annotations.dart`, `page_marks.dart` (`PaintedHighlight.height`); testes
`reader_annotations_test.dart`.

- [ ] **Passo 1 (RED):** grifar pela tela 21 (amarelo, fundo) sobre o grifo à mão amarelo do mundo une num só (o à
  mão, mais antigo); rosa sobre ele corta o à mão; `restyle` também; `highlightsIn` traz a altura (`low`/`high`) e
  `inkHighlightsIn` também.
- [ ] **Passo 2 (GREEN):** `_spansIn` com `a.kind == AnnotationKind.highlight` (os dois `source`); o comentário da
  D-140 atualizado pela D-173; `PaintedHighlight(height: a.fillHeight ?? FillHeight.medium)` (no sublinhado e no
  ondulado, ignorada).
- [ ] **Passo 3:** passa. Commit `feat(leitor): a D-32 vale para os grifos à mão na tela 21 (D-173)`.

### Tarefa 14: pintura — alturas, ondulado, mancha na altura, tinta do marca-texto, D-174, achado 17

**Arquivos:** `page_marks.dart`, criar `wavy_underline.dart`, `ink_painter.dart`, `reader_page_view.dart`,
`annotation_canvas.dart`; testes `page_marks_test.dart`, `wavy_underline_test.dart`, `ink_painter_test.dart`,
`reader_page_view_test.dart`, `performance_test.dart`.

- [ ] **Passo 0 (medida):** medir no recorte @3x da 23b (`mk.markerPanel.styles.wavy.sample.word`) o comprimento e
  a amplitude da onda do Chromium (2,5 px, a 2 px da base) com `tools/medicao/` (perfil vertical da cor amarela por
  coluna); registrar os números no comentário do `wavy_underline.dart` e no `G17.md` ("Resultados").
- [ ] **Passo 1 (RED):**
  - `backgroundBands`: Baixa corta de 50 % a 92 %, Média 12–92 %, Alta 0–100 % da altura da letra (D-172);
  - `wavyUnderlinePath(left, right, y, thickness: 2.5)`: período e amplitude medidos; começa na fase do Chromium
    (no `left` da caixa); o grifo ondulado pinta por cima do texto, na cor viva;
  - a mancha (R25): Média = a caixa da D-161; Baixa do meio da letra até 1 px acima da base; Alta do topo à base;
  - `paintInk` com o Marca-texto (ferramenta 3): polilinha de pontas redondas na largura, a cor a 90 %,
    multiplicada; no Noite (`lightText`), a técnica da D-133 em duas passadas (por trás e por cima);
  - D-174: no Noite, a tinta com contraste < 1,5 : 1 contra `#1F1B17` sai em `#E3D9C6` (traço de `#1A1714`); o
    roxo `#552CB7` fica; no Creme, nada muda; o cache de `Picture` separa Creme e Noite;
  - achado 17: no Noite, a mancha de um grifo à mão recorta o fundo do grifo de seleção na mesma linha (a conta da
    D-133 uma vez só): o pixel da sobreposição tem a cor da mancha;
  - o `performance_test` com os pintores novos e as variantes do `shouldRepaint`.
- [ ] **Passo 2 (GREEN):** as frações por altura num `switch`; `wavy_underline.dart` com o caminho por
  `quadraticBezierTo` alternando ±amplitude a cada meio período; `handHighlightBoxes` com a altura;
  `paintInk(canvas, strokes, {Color? lightText})` com o ramo do Marca-texto e a troca da D-174; `backgroundBands(…,
  cuts:)` com as caixas da mancha no Noite.
- [ ] **Passo 3:** passa. Commit `feat(leitor): alturas, ondulado, mancha na altura, tinta do marca-texto e o Noite
  (D-172, D-174, R25)`.

---

## G17.5 — Painel do marca-texto (tela 23b)

### Tarefa 15: a frase da prévia (D-171)

**Arquivos:** criar `lib/features/reader/annotations/marker_preview.dart`; teste `marker_preview_test.dart`.

- [ ] **Passo 1 (RED):** com a medida injetada (`width: (s) => s.length * 7.86`, o Literata 17 médio da prancha, e
  um teste com a medida real do `TextPainter` no widget):

```dart
test('pág. 159: "Olhos de ressaca? Vá, de ressaca.", o grifo em "ressaca"', () {
  final p = markerPreviewOf(textoDaPagina159, maxWidth: 296, width: medir);
  expect(p.text, 'Olhos de ressaca? Vá, de ressaca.');
  expect(p.text.substring(p.from, p.to), 'ressaca');
  expect(p.firstSentence, 'Olhos de ressaca');
});
test('a página começa no meio de uma frase: ela não entra', () { … });
test('nenhuma frase cabe: as primeiras palavras da 1ª frase que começa na página, com "…"', () { … });
test('empate na palavra mais longa: a 1ª', () { … });
test('sem texto: a frase do arquivo', () { … });
```

- [ ] **Passo 2 (GREEN):** frases = do começo (da página, se ela começa um parágrafo ou depois de um fim de frase) até
  `[.?!…]` seguido de aspas/parênteses opcionais e espaço ou fim; a 1ª frase inteira que cabe sozinha, mais as
  seguintes enquanto couberem; a palavra = a sequência mais longa de `[\p{L}\p{N}]`; `firstSentence` sem a
  pontuação final (o rótulo do leitor de tela).
- [ ] **Passo 3:** passa. Commit `feat(leitor): a frase da prévia do marca-texto (D-171)`.

### Tarefa 16: o painel do marca-texto (L23b.1–L23b.5)

**Arquivos:** criar `marker_panel.dart`; teste `test/features/reader/presentation/marker_panel_test.dart`.

- [ ] **Passo 1 (RED):** `MarkerPanel(session:, previewSource:)` no `ToolPanelFrame` (seta em 95), com os rótulos e
  as contagens do mundo:
  - geometria (`kRef23b`): `ann.markerPanel` (14/108,86/362/545,13), a seta, o cabeçalho, o título "Marca-texto", o
    subtítulo "Fundo · amarelo “lindo” · média" (R15), o fechar, a prévia (o texto centrado e o grifo em
    "ressaca"), ESTILO e os 3 cartões com as amostras, CORES E RÓTULOS e "Editar rótulos", as 4 linhas com amostra,
    rótulo e "5 grifos"/"3 grifos"/"2 grifos"/"2 grifos", ALTURA e as 3 opções com as amostras, a dica com o ícone e
    o texto em 3 linhas com "Gruda nas palavras." em negrito;
  - estilos: tocar "Ondulado" chama `setHighlighterStyle(wavy)`; o subtítulo perde a altura; a prévia ondula; a
    ALTURA fica a 0,38, "indisponível", e não responde (R18);
  - cores: tocar "rosa" muda a cor, o anel duplo e a borda de tinta passam à linha dela; sem rótulo, a linha diz
    "rosa" e o leitor de tela "rosa, 3 grifos"; "1 grifo" no singular; rótulo de 24 letras corta com "…" (R17);
  - semântica: as tabelas da L23b (`dialog` "Ajustes do marca-texto", `img` "Prévia: Olhos de ressaca, com fundo
    amarelo na palavra ressaca", os 3 `radiogroup` com os marcados).
- [ ] **Passo 2 (GREEN):** o painel com a prévia (`markerPreviewOf` + `AppText.rich` em Literata 17, o fundo de 14 a
  92 % a 95 % na Média), os cartões, as linhas (`NeoBox` 50, `colorWell` com o aro duplo), a pílula segmentada de 44
  e a caixa tracejada (o tracejado da ilha (G16), 1,3 `#8A7F63`).
- [ ] **Passo 3:** passa. Commit `feat(leitor): painel do marca-texto (L23b.1–L23b.5)`.

### Tarefa 17: rótulos e contagens (D-40, D-177)

**Arquivos:** criar `application/highlight_labels_store.dart` e `presentation/labels_sheet.dart`;
`annotation_session.dart` (`labels`, `colorCounts`), `reader_screen.dart` (carrega ao abrir o modo; a folha);
testes `highlight_labels_store_test.dart`, `labels_sheet_test.dart`, `reader_screen_g17_test.dart` (rótulos).

- [ ] **Passo 1 (RED):**
  - `HighlightLabelsStore.load(owner)` → `({Map<String, String> labels, Map<String, int> counts})`: os rótulos vivos
    por cor e os grifos vivos de todos os livros por cor (`highlightsOfUser`), as 4 do mundo com 5/3/2/2;
  - `save(owner, {'#FED170': 'lindo demais', '#FFC1C6': ''})`: muda o amarelo (mesma linha, versão nova), apaga o
    rosa (tombstone), cria o que não existia; rótulo com mais de 24 letras é cortado no campo (não chega aqui);
    Grátis sem fila, Pro na fila;
  - `LabelsSheet`: "RÓTULOS", as 4 cores com a amostra e o campo (até 24, contando como o banco), Cancelar/Salvar;
    sobe com o teclado; campo só com espaços = vazio;
  - na tela: "Editar rótulos" abre a folha sobre o painel; Salvar volta ao painel com o rótulo novo no subtítulo e
    na linha; Cancelar não grava; o Voltar fecha a folha primeiro.
- [ ] **Passo 2 (GREEN):** o store com o `HighlightLabelsDao` e o `versioning.write('highlight_labels', …)` (como o
  `PenPresetsStore`); a folha copiando a estrutura da `NoteSheet` (o cartão a 14 das bordas e 14 acima do teclado,
  o véu que segura os toques); a sessão guarda `labels` e `counts` (+ o saldo da mesa — Tarefa 11).
- [ ] **Passo 3:** passa. Commit `feat(leitor): rótulos do marca-texto e contagens de todos os livros (D-40, D-177)`.

---

## G17.6 — Outra cor e Noite

### Tarefa 18: a folha "Outra cor" da tela 21 (D-178, R27)

**Arquivos:** criar `other_color_sheet.dart`; `reader_screen.dart` (o `onOtherColor` deixa o aviso da D-129);
testes `other_color_sheet_test.dart`, `reader_screen_g13_test.dart` (o teste do aviso vira o da folha).

- [ ] **Passo 1 (RED):** com um trecho selecionado, "Outra cor" abre a folha "OUTRA COR" com o `ColorPicker` na
  última cor de grifo (D-130); arrastar e "Grifar" faz o fundo Médio na cor escolhida pela D-32 e fecha; num grifo
  tocado (D-132), a folha começa na cor dele e "Grifar" troca a cor; Cancelar e o Voltar voltam à barra com a
  seleção; o hex sobe com o teclado; semântica `dialog` "Outra cor".
- [ ] **Passo 2 (GREEN):** a folha no padrão da `NoteSheet`; o `ReaderScreen` com `_otherColor` (como `_note`) e o
  Voltar por camadas.
- [ ] **Passo 3:** passa. Commit `feat(leitor): "Outra cor" com o seletor da tela 23 (D-38, D-178)`.

### Tarefa 19: o Noite dos painéis e das folhas (R26)

**Arquivos:** `tool_panel_frame.dart`, `pen_panel.dart`, `marker_panel.dart`, `labels_sheet.dart`,
`other_color_sheet.dart`, `color_picker.dart`; testes dos widgets (grupo "Noite").

- [ ] **Passo 1 (RED):** no Noite, o painel `#2A2520` com borda e letras `#EDE3D1` e sombra `#0B0A08`; o véu é
  `#1F1B17` a 66 %; os cartões e campos internos com o poço do Noite; o ativo `brand` com letras escuras; as
  amostras de cor e a roda não mudam; o fechar com o ícone claro.
- [ ] **Passo 2 (GREEN):** as cores pelo `ReaderChromePalette` (as mesmas da ilha — D-167 17).
- [ ] **Passo 3:** passa. Commit `feat(leitor): painéis e folhas no Noite (R26)`.

---

## G17.7 — Prova

### Tarefa 20: o mundo das telas 23 e 23b

**Arquivos:** `test/support/dados_t22.dart` (o `livroDaTela22` aceita o mundo e grava os rótulos), criar
`test/support/dados_t23.dart` (`livroDaTela23`, `abrirTela23`, `abrirTela23b`), `test/fixtures/telas/t23.dart` e
`t23b.dart` (sem mudança de dados), `test/fixtures/mundo_de_referencia_test.dart`.

- [ ] **Passo 1 (RED):** abrir a 23 pela rota real (Anotar → 2º toque na Caneta) mostra o painel com o `pen_presets`
  do mundo; a 23b (Anotar → Marca-texto → 2º toque) com os rótulos lindo/personagem/ideia/pro clube e 5/3/2/2; a
  página tem os 4 trechos anotados (o mundo `mundoSemNotaAMao` com a tinta toda), em NBSP (D-160).
- [ ] **Passo 2 (GREEN):** os ajudantes, como os da 22.
- [ ] **Passo 3:** passa. Commit `test(leitor): mundo das telas 23 e 23b`.

### Tarefa 21: fases L23 e L23b e o golden

**Arquivos:** criar `test/support/fase_l23.dart`, `test/features/reader/fases/l23_test.dart`, `l23b_test.dart`,
`test/golden/leitor_23_test.dart` (e os PNG em `test/golden/goldens/`).

- [ ] **Passo 1:** L23 (seções `pen.fade` e `pen.penPanel`, 48 ids) e L23b (`mk.fade` e `mk.markerPanel`, 53 ids):
  geometria (sem os inline; ±0,5, ±1 em x/w nos `textDependentX`), texto (quebras e baselines), estilo (cores,
  bordas exatas, raios, sombras duras, fontes e pesos reais), semântica (as tabelas, exceções da D-51) e os dados do
  banco (o `pen_presets` e os rótulos).
- [ ] **Passo 2:** os goldens @3x e o `compare_images.py` nos recortes (23: y 117–673,63; 23b: y 100,86–673,63),
  ≤ 0,5 %; na 23b, mascarar ou anotar o sublinhado duplo coral (D-59). Conferir o lado a lado e o mapa de calor.
- [ ] **Passo 3:** passa. Commit `test(leitor): fases L23 e L23b e golden contra as pranchas`.

### Tarefa 22: comportamento da tela

**Arquivos:** criar `test/features/reader/presentation/reader_screen_g17_test.dart`.

- [ ] **Passo 1:** pela rota real: R1–R5 e o Voltar; cada controle grava o `pen_presets`; favoritas ("+", tirar e
  Desfazer); hex pelo teclado; os rótulos pela folha; o Marca-texto grifa (a página mostra o grifo antes do Concluir),
  une com o grifo à mão amarelo, corta um de seleção, desfaz e refaz, a Borracha apaga, e o Concluir grava (as notas
  vão para o destino); a tinta translúcida na margem e depois no leitor limpo; depois de A+ e da Lora o grifo segue
  as palavras; o rascunho v2 gravado ao reabrir; Noite (o painel e a tinta preta); o leitor de tela; Grátis sem
  rede.
- [ ] **Passo 2:** o que falhar vira correção com teste. Commit `test(leitor): comportamento das telas 23 e 23b`.

### Tarefa 23: verificação, capturas e relatório

- [ ] `dart format`, `flutter analyze` (0), `flutter test` (a suíte inteira).
- [ ] Revisão independente por um agente que não escreveu o código (spec + código + testes, sem editar); cada achado
  vira correção com teste ou pergunta.
- [ ] Mutação das regras novas (`tools/medicao/tmp/mut/g17/gerar_g17.py`, como o da G16): 17/11, 0,5 (R21), 7
  colunas, 12 favoritas, 15°, 5 %, 8 px do teclado, 50/12/92/0/100 (D-172), 90 %, 1,5 : 1 (D-174), 22/9,5/42/95/251
  da moldura, a D-171, a D-173, o achado 17, R1–R4, R18.
- [ ] Cobertura ≥ 90 % nos arquivos de `lib/` mexidos (`git diff --name-only 137259f -- lib`).
- [ ] gitleaks nos commits da fase e nas pastas tocadas.
- [ ] Capturas (`test/golden/capturas_g17_test.dart`, `BOOKNEST_CAPTURAS`): a 23 e a 23b em Creme e no Noite; o
  marca-texto antes e depois de soltar; a D-32 com o marca-texto; a folha dos rótulos; a folha "Outra cor"; a tinta
  preta no Noite; o lado a lado com as pranchas. Mandar na conversa.
- [ ] `docs/progresso/G17.md` (Resultados, Revisão, Desvios, Pendências, Capturas, Checklist),
  `docs/progresso/RELATORIO_G17.md`; no projeto, `handoff_app_completo/relatorios/RELATORIO_G17.md` e as D-171…D-179
  em `handoff_app_completo/05_DECISOES_E_PERGUNTAS.md`.
- [ ] Commit `docs(g17): resultados, revisão, desvios e relatório da fase`.
