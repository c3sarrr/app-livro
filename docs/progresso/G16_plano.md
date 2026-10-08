# G16 — Modo anotação e motor de tinta (tela 22): plano de implementação

> **Para quem executa:** execução inline (superpowers:executing-plans), uma tarefa por vez, TDD: o teste falha no
> Windows (RED), o código mínimo passa (GREEN), commit pequeno. Passos com `- [ ]`.

**Objetivo:** a tela 22 idêntica à prancha e funcionando de verdade: entrar no modo anotação, desenhar com Caneta e
Reta, apagar com a Borracha, selecionar e mover com o Laço, desfazer e refazer, gravar no Concluir numa transação, e a
tinta salva aparecendo no leitor limpo, presa às palavras.

**Arquitetura:**
- Um motor puro em `lib/features/reader/annotations/ink/`: tipos do traço, unidades da D-159, suavização (porte do
  perfect-freehand do S4), codec BNK1, âncora e moldura (D-162), agrupamento, cartões, ferramentas, árbitro de dedos,
  pilha de comandos e o rascunho em JSON. Nenhum widget; testes sem Flutter.
- Um `InkRepository` (interface; Drift + fake) grava o Concluir numa transação, guarda e recupera o rascunho no `kv`
  e lê os desenhos do livro.
- Uma `AnnotationSession` (ChangeNotifier, uma por entrada no modo) junta tudo: a cópia de trabalho da página, a
  pilha, o traço ao vivo, o deslocamento da página e o rascunho a cada 5 s.
- Um `ReaderInk` (a fonte da tinta salva) entrega ao pintor os desenhos da página e a mancha dos grifos à mão; o
  `ReaderPagesPainter` pinta, nesta ordem, fundos · texto · sublinhado · mancha · tinta.
- A camada `AnnotationMode` (tela 22) fica por cima de tudo no `ReaderScreen`: canvas com `Listener` cru, pílula e
  Concluir, prateleira, ilha, indicador de toque e borda de mesa.

**Pilha:** Flutter/Dart, drift (SQLite), PowerSync (só no teste da fila), flutter_svg (`ColorMapper`), flutter_test,
goldens @3x, `tools/compare_images.py`.

**Execução e ambiente (diferente da G15):**
- O código é escrito direto no repositório (`C:\Users\T-Gamer\Desktop\app_livros`), sem espelho.
- Testes no Windows: um arquivo com `flutter test <arquivo>`; a suíte com `flutter test`.
- Leituras do git com `git --no-optional-locks`. Commits pequenos, mensagem `tipo(escopo): descrição` em português,
  com o rodapé `Co-Authored-By`.
- Spec: `docs/progresso/G16.md` (D-159…D-167). As seções do desenho são citadas como §1…§7.

## Arquivos

| Arquivo | Responsabilidade | Tarefa |
|---|---|---|
| `lib/features/reader/annotations/ink/ink_stroke.dart` (novo) | ponto, traço, códigos de ferramenta e ponta do BNK1 | 1 |
| `lib/features/reader/annotations/ink/ink_units.dart` (novo) | D-159: mm → dp, Fina/Média/Grossa, centésimos de mm | 1 |
| `lib/features/reader/annotations/ink/freehand.dart` (novo) | porte do perfect-freehand 1.2.3 (MIT), pontas, pressão simulada | 2 |
| `test/fixtures/tinta/pf_referencia.json` (movido do S4) | os 30 casos do npm | 2 |
| `lib/features/reader/annotations/ink/bnk1_codec.dart` (novo) | codec v1 congelado, erros tipados, base64, teto de 256 KiB | 3 |
| `lib/features/reader/annotations/ink/ink_geometry.dart` (novo) | linhas e palavras da página, sem widget | 4 |
| `lib/features/reader/application/ink_page_geometry.dart` (novo) | `DisplayPage` → `InkPageGeometry` | 4 |
| `lib/features/reader/annotations/ink/drawing_anchor.dart` (novo) | linha, trecho, moldura, colocação de volta, âncora de 8 chaves | 5 |
| `lib/features/reader/annotations/ink/drawing_clusters.dart` (novo) | D-162: traços que se tocam | 6 |
| `lib/features/reader/annotations/ink/card_groups.dart` (novo) | Anexo 02 §4.3: `group_id` dos desenhos | 6 |
| `lib/features/reader/annotations/ink/ink_tools.dart` (novo) | Reta, Borracha, Laço, batente | 7 |
| `lib/features/reader/annotations/ink/gesture_arbiter.dart` (novo) | 1 dedo/caneta desenha, 2 dedos movem, rejeição de palma | 8 |
| `lib/features/reader/annotations/ink/ink_commands.dart` (novo) | cópia de trabalho, comandos, desfazer/refazer (100) | 9 |
| `lib/features/reader/annotations/ink/ink_changes.dart` (novo) | o que o Concluir grava e o rascunho em JSON | 10 |
| `lib/core/data/database/daos/annotation_daos.dart`, `kv_dao.dart` | `byIds`, `ofLayers`, `KvDao.delete` | 11 |
| `lib/features/reader/annotations/ink_repository.dart` (novo) | interface + Drift + recuperação do rascunho | 12 |
| `test/support/fake_ink_repository.dart` (novo) | o *fake* | 12 |
| `lib/features/account/data/local_library.dart` | a limpeza leva o rascunho | 13 |
| `lib/features/reader/application/annotation_session.dart` (novo) | a sessão do modo | 14 |
| `lib/features/reader/application/reader_ink.dart` (novo) | a tinta salva para o leitor; rascunho ao abrir (D-166) | 15 |
| `lib/features/reader/application/reader_annotations.dart` | `inkHighlightsIn` (D-161) | 15 |
| `lib/features/reader/presentation/ink_painter.dart` (novo) | contorno → `Path`, cápsula da Reta, mancha, cache de `Picture` | 16 |
| `lib/features/reader/presentation/reader_page_view.dart` | ordem de pintura com a tinta | 16 |
| `pubspec.yaml`, `app_typography.dart`, `app_icons_leitor.dart`, `app_illustrations_leitor.dart` (novo), `app_svg.dart`, `conic_ring_painter.dart` (novo), `highlight_toolbar.dart` | recursos da tela | 17 |
| `lib/features/reader/presentation/annotation_top_bar.dart` (novo) | L22b | 18 |
| `lib/features/reader/presentation/tool_shelf.dart` (novo) | L22c | 19 |
| `lib/features/reader/presentation/annotation_island.dart` (novo) | L22d | 20 |
| `lib/features/reader/presentation/annotation_canvas.dart` (novo) | L22a: `Listener`, página, tinta, traço vivo, laço, indicador, borda de mesa | 21 |
| `lib/features/reader/presentation/annotation_mode.dart` (novo) | a camada da tela 22 com os lugares da D-167 (3) | 22 |
| `lib/features/reader/presentation/reader_screen.dart` | integração | 23 |
| `test/fixtures/tinta_do_mundo.dart` (novo), `mundo_2026_09_20.dart`, `telas/instantaneo.dart`, `telas/t22.dart`, `test/support/mundo_epub.dart`, `test/fixtures/mundo_de_referencia_test.dart` | o mundo da 22 | 24 |
| `test/support/fase_l22.dart`, `l22a…d_test.dart`, `test/golden/leitor_22_test.dart` (novos) | fases e golden | 25 |
| `test/features/reader/presentation/reader_screen_g16_test.dart` (novo) | comportamento da tela | 26 |

---

### Tarefa 1: tipos do traço e unidades da D-159

**Arquivos:** criar `lib/features/reader/annotations/ink/ink_stroke.dart` e `ink_units.dart`; testes
`test/features/reader/annotations/ink/ink_stroke_test.dart` e `ink_units_test.dart`.

- [ ] **Passo 1 (RED):**

```dart
// G16.1 (D-159) — espessura na escala da prancha 22: 1 mm = 11/6 dp.
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_units.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('1,2 mm Média desenha com 2,2 px (o traço ao vivo da 22)', () {
    expect(dpPerMm, 11 / 6);
    expect(strokeDp(1.2, StrokeSize.medium), closeTo(2.2, 1e-12));
    expect(strokeDp(1.2, StrokeSize.thin), closeTo(1.32, 1e-12));
    expect(strokeDp(1.2, StrokeSize.thick), closeTo(3.96, 1e-12));
  });
  test('o slider de 0,3–4,0 mm vira 0,55–7,33 px', () {
    expect(strokeDp(0.3, StrokeSize.medium), closeTo(0.55, 1e-12));
    expect(strokeDp(4.0, StrokeSize.medium), closeTo(22 / 3, 1e-12));
  });
  test('a largura gravada é a efetiva, em centésimos de mm', () {
    expect(widthCentiMm(1.2, StrokeSize.medium), 120);
    expect(widthCentiMm(1.2, StrokeSize.thin), 72);
    expect(widthCentiMm(1.2, StrokeSize.thick), 216);
    expect(widthCentiMm(4.0, StrokeSize.thick), 720);
    expect(dpOfCentiMm(120), closeTo(2.2, 1e-12));
    // as larguras do arquivo viram centésimos pela D-159 (§7): 2,3 / 1,8 / 2,4 px
    expect(centiMmOfDp(2.3), 125);
    expect(centiMmOfDp(1.8), 98);
    expect(centiMmOfDp(2.4), 131);
  });
}
```

`ink_stroke_test.dart`: `InkStroke` com igualdade por valor (lista de pontos), `translated(dx, dy)` move só x/y,
`InkTool.pen.code == 1`, `InkTool.line.code == 2`, `InkTool.fromCode(3)` é `null` (marca-texto da G17),
`tipCode(PenTip.fountain) == 1` e `tipOfCode(9) == PenTip.ballpoint` (ponta desconhecida = esferográfica),
`colorHex(0xFFFF552E) == '#FF552E'`.

Run: `flutter test test/features/reader/annotations/ink/`. Esperado: FAIL (os arquivos não existem).

- [ ] **Passo 2 (GREEN):**

```dart
// ink_units.dart
// G16.1 (D-159) — espessura na escala da prancha 22: a caneta Média de 1,2 mm desenha com 2,2 px, como o traço ao
// vivo da 22 (2,2 px ÷ 1,2 mm). O "mm" passa a ser nominal (substitui a escala física da D-28). Fina, Média e Grossa
// = 0,6×, 1× e 1,8× do valor do painel. O traço grava a largura efetiva (D-59 vale também para a espessura).
import '../domain/pen_presets.dart';

const double dpPerMm = 11 / 6;

double sizeFactor(StrokeSize s) => switch (s) {
  StrokeSize.thin => 0.6,
  StrokeSize.medium => 1.0,
  StrokeSize.thick => 1.8,
};

double strokeDp(double widthMm, StrokeSize s) =>
    widthMm * sizeFactor(s) * dpPerMm;

int widthCentiMm(double widthMm, StrokeSize s) =>
    (widthMm * sizeFactor(s) * 100).round();

double dpOfCentiMm(int centiMm) => centiMm / 100 * dpPerMm;

int centiMmOfDp(double dp) => (dp / dpPerMm * 100).round();
```

`ink_stroke.dart`: `InkPoint(x, y, pressure, tMs)`; `InkStroke({tool, tip, argb, widthCentiMm, points})` com `int tool`
e `int tip` (o codec preserva códigos que este app não conhece), `copyWith`, `translated`, `==`/`hashCode`;
`enum InkTool { pen(1), line(2) }` + `fromCode`; `tipCode`/`tipOfCode` (índice do `PenTip`); `colorHex(argb)`.

- [ ] **Passo 3:** os testes passam. Commit `feat(tinta): tipos do traço e unidades da D-159`.

### Tarefa 2: suavização — o porte do perfect-freehand

**Arquivos:** criar `lib/features/reader/annotations/ink/freehand.dart`; mover
`spikes/S4_tinta/dados/pf_referencia.json` para `test/fixtures/tinta/pf_referencia.json` (cópia; o spike fica como
está); teste `test/features/reader/annotations/ink/freehand_test.dart`.

- [ ] **Passo 1 (RED):** o teste do spike (`suavizacao_test.dart`) com os nomes novos, lendo
  `test/fixtures/tinta/pf_referencia.json`:
  - os 30 casos com erro máximo `< 1e-9`;
  - pontas: mais pressão = traço mais largo, menos na esferográfica (`esfero < tinteiro < pincel`);
  - `tipOptions(tip, size:)`: `streamline` 0,2 nas três (§1), afinamento 0,1/0,6/0,85, tinteiro com
    `taperEnd: double.infinity`, pincel com `smoothing` 0,5, `simulatePressure: false` (a pressão vem do ponto);
  - `simulatedPressure(prev, distance, size)` = a fórmula do perfect-freehand
    (`min(1, prev + (min(1, 1 − min(1, d/size)) − prev) × min(1, d/size) × 0,275)`), com 3 valores calculados à
    mão; o 1º ponto vale 0,25 (`firstPressure`);
  - onda curta (12 px de comprimento de onda, 4,5 px de amplitude, amostrada a 2 px): com `streamline` 0,2 a amplitude
    do contorno fica ≥ 85 % da do caminho; com 0,5 cai abaixo de 70 % (o motivo do 0,2).

- [ ] **Passo 2 (GREEN):** porte linha a linha de `spikes/S4_tinta/lib/suavizacao.dart`, com o comentário de licença
  MIT e os nomes em inglês:

| spike | `lib/` |
|---|---|
| `OpcoesTraco` (`tamanho`, `afinamento`, `suavizacao`, `estabilizacao`, `simularPressao`, `taperInicio`, `taperFim`, `capInicio`, `capFim`, `completo`) | `FreehandOptions` (`size`, `thinning`, `smoothing`, `streamline`, `simulatePressure`, `taperStart`, `taperEnd`, `capStart`, `capEnd`, `last`) |
| `PontoTraco` (`ponto`, `pressao`, `vetor`, `distancia`, `comprimento`) | `FreehandPoint` (`point`, `pressure`, `vector`, `distance`, `runningLength`) |
| `pontosDoTraco` / `contornoDoTraco` / `contorno` | `strokePoints` / `strokeOutline` / `freehandOutline` |
| `_simular` | `simulatedPressure` (público: a captura usa) |
| `Ponta` + `dpPorMm` | `tipOptions(PenTip, {required double size, bool last})` (o `dpPorMm` sai: é o da D-159) |

- [ ] **Passo 3:** passa. Commit `feat(tinta): suavização por ponta (porte do perfect-freehand)`.

### Tarefa 3: codec BNK1

**Arquivos:** criar `lib/features/reader/annotations/ink/bnk1_codec.dart`; teste
`test/features/reader/annotations/ink/bnk1_codec_test.dart`.

- [ ] **Passo 1 (RED):** os testes do spike com os nomes novos, e mais:

```dart
test('formato congelado da versão 1 (o mesmo vetor do S4)', () {
  const t = InkStroke(
    tool: 0,
    tip: 1,
    argb: 0xFFE4572E,
    widthCentiMm: 120,
    points: [
      InkPoint(1.5, -0.25, 0.5, 0),
      InkPoint(1.62, -0.2, 0.6, 8),
      InkPoint(1.75, -0.1, 0.7, 16),
    ],
  );
  final hex = encodeBnk1([t], Bnk1Unit.em)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  expect(
    hex,
    '424e4b310101'
    '0001e4572eff780003'
    'ac02318000'
    '180a9908'
    '1a14b308',
  );
});
```

- ida e volta de 1.000 traços aleatórios nas duas unidades (quantização ≤ 0,5/escala; pressão ≤ 0,5/255; tempo
  exato) e recodificar dá os mesmos bytes;
- camada vazia `[0x42,0x4E,0x4B,0x31,1,0]`; traço sem pontos;
- erros tipados: `InvalidSignature`, `UnknownVersion(2)`, cada prefixo truncado lança `Bnk1Failure`,
  `TrailingBytes`, tempo voltando → `ValueOutOfRange`;
- base64: `encodeStrokesB64`/`decodeStrokesB64` de ida e volta; `''` decodifica como nenhum traço (camadas antigas do
  mundo); base64 inválido lança `InvalidSignature`;
- unidade pelo tipo da camada: `unitOf(InkLayerKind.overText) == Bnk1Unit.em` (1/100 em),
  `unitOf(InkLayerKind.space) == Bnk1Unit.box` (1/10000);
- teto: `fitsBnk1([...])` é `false` quando os bytes passariam de `256 × 1024` e o base64 de `InkLayer.maxStrokesB64`
  (349.528).

- [ ] **Passo 2 (GREEN):** porte de `spikes/S4_tinta/lib/bnk1.dart` (`codificarBnk1` → `encodeBnk1`,
  `decodificarBnk1` → `decodeBnk1`, `FalhaBnk1` → `sealed class Bnk1Failure`, `AssinaturaInvalida` →
  `InvalidSignature`, `VersaoDesconhecida` → `UnknownVersion`, `DadosTruncados` → `TruncatedData`, `LixoNoFim` →
  `TrailingBytes`, `ValorForaDaFaixa` → `ValueOutOfRange`, `UnidadeCamada` → `Bnk1Unit`), mais `unitOf`,
  `encodeStrokesB64`, `decodeStrokesB64` e `fitsBnk1`.

- [ ] **Passo 3:** passa. Commit `feat(tinta): codec BNK1 com o formato congelado do S4`.

### Tarefa 4: geometria da página para a tinta

**Arquivos:** criar `lib/features/reader/annotations/ink/ink_geometry.dart` (puro) e
`lib/features/reader/application/ink_page_geometry.dart` (o adaptador); testes
`test/features/reader/annotations/ink/ink_geometry_test.dart` e
`test/features/reader/application/ink_page_geometry_test.dart`.

- **Puro:** `InkWord = ({int from, int to, double left, double right})`;
  `InkLine({unit, from, to, top, bottom, baseline, em, left, right, words})` com `refY = baseline − 0,25 em` (o meio da
  letra pequena — §2); `InkPageGeometry(lines)` com `lineHeight` (a altura da 1ª linha; 0 sem linhas). `InkRect`
  (`left/top/right/bottom`, `center`, `inflate`, `overlaps`, `union`).
- **Adaptador** `inkGeometryOf(DisplayPage page)`: as caixas de `boxesOf(shown)` agrupadas por linha de base (|Δ| <
  0,5) dão as linhas; as palavras saem de `wordAround` andando pelos offsets do `shown` (espaço = `null` → próximo
  offset), cada uma com a caixa de `boxesOf(w.from, w.to)` na linha dela. Pontuação conta como palavra (é o
  `getWordBoundary`); imagem (U+FFFC) também. Sem `shown` (PDF) = sem linhas.

Testes:
- puro: `refY`, `overlaps` nas bordas, `union`;
- adaptador, com a pág. 159 do mundo (o livro da tela 19 aberto num `PageSnapshot`):
  - 19 linhas, com as linhas de base da prancha 19 (±0,5);
  - a linha 8 tem as palavras "Olhos", "de", "ressaca", "?", "Vá", ",", …; a caixa de "Olhos de ressaca?" começa em
    28 e termina em 196,54 (±1, as medidas da 22 sem os 30 px);
  - PDF (página sem `shown`) → geometria vazia.

- [ ] RED → GREEN → commit `feat(tinta): linhas e palavras da página para a âncora`.

### Tarefa 5: âncora — linha, trecho, moldura e a volta à página

**Arquivos:** criar `lib/features/reader/annotations/ink/drawing_anchor.dart`; teste
`test/features/reader/annotations/ink/drawing_anchor_test.dart`.

API:
- `InkFrame({x, baseline, em, w})`: origem no início do trecho, na linha de base; `w` = largura do trecho em em.
- `DrawingPlace = ({int line, int from, int to, InkFrame frame})`.
- `DrawingPlace? placeDrawing(InkRect bounds, InkPageGeometry g)`: a linha cujo `refY` está mais perto do centro de
  `bounds`; o trecho = as palavras dessa linha com ≥ 50 % da largura dentro de `[bounds.left, bounds.right]`; sem
  nenhuma, a palavra mais perto (pela distância horizontal); `null` sem linhas.
- `toFrame(InkStroke s, InkFrame f)` (página → em) e `fromFrame(InkStroke s, PlacedFrame p)` (em → página), com
  `PlacedFrame = ({double x, double baseline, double em, double k})`.
- `PlacedFrame? placedFrame(List<TextLineBox> pieces, double? w)`: um pedaço → `k = (largura ÷ em) ÷ w`; mais de um
  (o trecho quebrou) → `k = 1` no 1º; nenhum → `null` (a âncora não volta: não pinta, não apaga — D-44); `w` nulo
  (camada sem a chave `ink`) → `k = 1`. Pedaços da mesma linha (estilos diferentes) se juntam antes.
- Âncora de 8 chaves: `TextAnchor inkLayerAnchor(EpubAnchor range, double w)` = `RawAnchor({...range.toJson(),
  'ink': {'w': w com 4 casas}})`; `({EpubAnchor range, double? w})? inkAnchorOf(TextAnchor a)` lê a de 8 chaves (e a de
  7, com `w` nulo). O `EpubAnchor` continua só com 7 chaves.

- [ ] **Passo 1 (RED):** uma página sintética com 3 linhas (linhas de base 100; 135,25; 170,5; em 20,5; palavras
  com caixas conhecidas) e os casos do §2:

```dart
test('a linha da âncora: o ponto 0,25 em acima da base mais perto do centro', () {
  // centro 3 px abaixo da linha 1: fica na 1 (como o sublinhado duplo na 13)
  expect(placeDrawing(box(top: 98, bottom: 108), g)!.line, 0);
  // centro logo acima da linha de base da 2: fica na 2
  expect(placeDrawing(box(top: 126, bottom: 134), g)!.line, 1);
});
test('o trecho: palavras com ≥ 50 % da largura dentro da extensão do desenho', () {
  final p = placeDrawing(box(left: 0, right: 61), g)!; // "Olhos" inteira, "de" com 60 %
  expect(textOfRange(p), 'Olhos de');
  final q = placeDrawing(box(left: 300, right: 330), g)!; // depois do fim da linha
  expect(textOfRange(q), 'fim'); // a palavra mais perto
});
test('a moldura e a volta: mesma página dá os mesmos pontos', () {
  final p = placeDrawing(bounds, g)!;
  final em = toFrame(stroke, p.frame);
  final back = fromFrame(em, (x: p.frame.x, baseline: p.frame.baseline, em: p.frame.em, k: 1));
  expect(maxDistance(back, stroke), lessThan(1e-9));
});
test('outra fonte: estica na horizontal; na vertical fica em em a partir da base', () { ... });
test('o trecho que passou a quebrar: k = 1 no começo do 1º pedaço', () { ... });
test('a âncora que não volta: null (não pinta, não apaga)', () {
  expect(placedFrame(const [], 3.2), isNull);
});
test('âncora de 8 chaves: grava e lê; o EpubAnchor recusa as 8', () {
  final a = inkLayerAnchor(range, 8.21234);
  expect(a.toJson()['ink'], {'w': 8.2123});
  expect(TextAnchor.fromJson(a.toJson()), isA<RawAnchor>());
  expect(inkAnchorOf(TextAnchor.fromJson(a.toJson())), (range: range, w: 8.2123));
  expect(inkAnchorOf(range)!.w, isNull);
});
```

- [ ] **Passo 2 (GREEN):** a implementação acima.
- [ ] **Passo 3:** passa. Commit `feat(tinta): âncora nas palavras e moldura em em (D-162)`.

### Tarefa 6: agrupamento (D-162) e cartões (Anexo 02 §4.3)

**Arquivos:** criar `drawing_clusters.dart` e `card_groups.dart` em `ink/`; testes
`drawing_clusters_test.dart` e `card_groups_test.dart`.

- `InkRect strokeBox(InkStroke s)`: a caixa dos pontos crescida em meia espessura (`dpOfCentiMm(w) / 2`).
- `int? touchedDrawing(InkRect strokeBox, List<({int order, InkRect box})> drawings, {required double lineHeight})`:
  a caixa de cada desenho crescida em meia altura de linha; entre os tocados, o de maior `order` (o mais recente);
  `null` = desenho novo. Os que ele toca **não** se fundem.
- `String cardGroup({required String id, required int line, required List<CardCandidate> others})`: o grupo do
  desenho da mesma página cuja linha de âncora está a até 2 linhas; mais de um → o mais perto, empate → o mais antigo
  (`createdAt`, depois o id); senão o próprio id.

Testes (com as caixas medidas da pág. 159, em coordenadas do leitor limpo):
- elipse (19; 335,23 → 205,54; 377,67) e risco (95,27; 327,23 → 129,27; 339,23): juntos;
- as 2 barras do sublinhado duplo (83,67 → 271,14; 548,57/553,57, 2,4 de altura): juntas;
- a onda (27 → 135,99; 476,45 → 486,45): separada da elipse e das barras;
- tocando dois desenhos: entra no mais recente;
- cartões: a onda (linha 11) e o duplo (linha 13) no mesmo grupo (o do mais antigo); a elipse (linha 8) no dela;
  empate de distância → o mais antigo; 3 linhas → o próprio id.

- [ ] RED → GREEN → commit `feat(tinta): desenhos de traços que se tocam e grupos dos cartões`.

### Tarefa 7: ferramentas puras — Reta, Borracha, Laço e batente

**Arquivos:** criar `ink_tools.dart` em `ink/`; teste `ink_tools_test.dart`.

- `snapLineEnd(start, end)`: o ângulo gruda no múltiplo de 15° mais perto quando a diferença é < 4°, mantendo o
  comprimento; `lineTooShort(start, end)`: < 4 px.
- `segmentDistance(a1, a2, b1, b2)` (0 quando cruzam); `eraserTouchesStroke(e1, e2, InkStroke s)`: algum segmento do
  traço a até `dpOfCentiMm(w)/2 + 8` do segmento da borracha (traço de 1 ponto = um ponto; Reta = o segmento).
- `eraserTouchesRect(e1, e2, InkRect r)`: o segmento passa pela área pintada do grifo (as caixas das letras de cada
  linha; no sublinhado, até a base do traço — `baseline + 7`).
- `insidePolygon(p, polygon)` (par-ímpar) e `lassoSelects(InkStroke s, polygon)`: ≥ 50 % dos pontos dentro.
- `panLimit({required double lastLineBottom, required double deskTop})` = `max(0, lastLineBottom − deskTop)`;
  `rubberBand(raw, limit)`: dentro de `[−limit, 0]` igual; fora, anda 1/3 do excesso (D-165, como a D-107).

Testes: 15° e 4° (3,9° gruda, 4,1° não; 89° → 90°; −44° → −45°), 3,9 px não cria; borracha a 8 px + meia espessura
toca e a 8,2 não; cruzando sem pontos perto toca; Reta de 2 pontos; grifo tocado e não tocado; polígono côncavo;
50 % exatos selecionam e 49 % não; batente nos dois lados.

- [ ] RED → GREEN → commit `feat(tinta): Reta, Borracha, Laço e batente (D-165)`.

### Tarefa 8: árbitro de dedos e caneta

**Arquivos:** criar `gesture_arbiter.dart` em `ink/`; teste `gesture_arbiter_test.dart`.

API:

```dart
enum InkPointerKind { touch, stylus, ignored } // mouse = touch; invertedStylus = ignored (fora da G16)
typedef InkPointer = ({int id, InkPointerKind kind, double x, double y, double pressure, int tMs});
sealed class InkGesture {}
final class DrawStart extends InkGesture { DrawStart(this.p); final InkPointer p; }
final class DrawMove extends InkGesture { DrawMove(this.p); final InkPointer p; }
final class DrawEnd extends InkGesture {}
final class DrawDiscard extends InkGesture {}
final class PanStart extends InkGesture {}
final class PanMove extends InkGesture { PanMove(this.dy); final double dy; }
final class PanEnd extends InkGesture {}

final class InkGestureArbiter {
  static const int discardWindowMs = 150;
  bool get stylusSeen;
  List<InkGesture> down(InkPointer p);
  List<InkGesture> move(InkPointer p);
  List<InkGesture> up(InkPointer p);
  List<InkGesture> cancel(InkPointer p);
}
```

Regras (§3):
- 1 dedo (sem caneta na sessão) ou a caneta → desenha;
- 2º dedo até 150 ms do 1º → `DrawDiscard` + `PanStart`; depois → `DrawEnd` + `PanStart`;
- depois do 1º evento `stylus`, só a caneta desenha: 1 ou 2 dedos movem a página; dedo durante o traço da caneta é
  palma (ignorado até sair);
- a caneta chegando com um dedo desenhando: o traço do dedo termina e a caneta começa;
- o movimento da página usa o centro dos dedos (`PanMove(dy)`, sem salto quando um dedo sai ou entra) e termina quando
  os dedos saem; dedos além do 2º são ignorados;
- `cancel` do traço → `DrawDiscard`.

Testes: cada regra acima, mais "dedo que sobrou continua movendo" e "3º dedo ignorado".

- [ ] RED → GREEN → commit `feat(tinta): árbitro de dedos e caneta (rejeição de palma)`.

### Tarefa 9: cópia de trabalho e pilha de comandos

**Arquivos:** criar `ink_commands.dart` em `ink/`; teste `ink_commands_test.dart`.

- `SessionStroke({int id, InkStroke stroke})` (traço com id da sessão, em coordenadas do leitor limpo).
- `SessionDrawing({String id, int order, List<SessionStroke> strokes, SavedDrawingRef? saved})`: `saved` = a camada e
  a anotação que já existiam (para gravar por cima ou apagar).
- `InkWorkingCopy`: os desenhos da página (por id), os grifos apagados (ids) e `changedDrawings` (ids mexidos).
- Comandos (`sealed class InkCommand { apply(w); revert(w); }`):
  - `AddStroke(stroke, into: drawingId?, newDrawingId, order)`;
  - `Erase(strokeIds, highlightIds)` (uma passada da borracha ou o apagar da seleção do laço);
  - `MoveStrokes(strokeIds, dx, dy, newDrawingId, order)`: os traços saem dos desenhos deles e formam um desenho novo;
    o desenho que ficou sem traços some (e volta no desfazer).
- `InkHistory`: `push` (aplica, limpa o refazer, guarda no máximo 100 — o mais antigo sai), `undo`, `redo`,
  `canUndo`, `canRedo`.

Testes: cada comando com apply/revert voltando exatamente ao estado anterior; 101 comandos → 100 desfazeres; ação nova
limpa o refazer; mover o único traço de um desenho apaga o desenho e o desfazer o devolve; `changedDrawings` marca os
desenhos tocados (e o desfazer não desmarca: o Concluir compara com o que foi lido).

- [ ] RED → GREEN → commit `feat(tinta): desfazer e refazer na sessão (máx. 100)`.

### Tarefa 10: o que o Concluir grava e o rascunho em JSON

**Arquivos:** criar `ink_changes.dart` em `ink/`; teste `ink_changes_test.dart`.

- `InkChanges`:
  - `layers`: `DrawingRow({layerId, annotationId, createdAt, anchor (8 chaves), range (7 chaves), refPage,
    chapterIndex, groupId, color, strokesB64, strokeCount})`;
  - `deletedLayers` (ids de camada — a anotação vai junto);
  - `erasedHighlights` (ids de grifo — as notas vão junto);
  - `isEmpty`.
- `draftKey(owner, userBookId)` = `'ink_draft:$owner:$userBookId'`.
- `encodeDraft(InkChanges, {required DateTime at})` / `decodeDraft(String)`: JSON com `v: 1`, as linhas prontas a
  gravar, os ids e a hora; versão desconhecida ou JSON quebrado → `null` (não derruba a abertura).

Testes: ida e volta igual; `v: 2` → `null`; JSON truncado → `null`; vazio.

- [ ] RED → GREEN → commit `feat(tinta): mudanças do Concluir e rascunho em JSON`.

### Tarefa 11: DAOs

**Arquivos:** `lib/core/data/database/daos/annotation_daos.dart`, `kv_dao.dart`; testes em
`test/core/data/database/` (os arquivos de DAO que já existem).

- `InkLayersDao.byIds(ids)` (vivas ou não) e `InkLayersDao.liveOverTextForBook(userBookId)`;
- `AnnotationsDao.byIds(ids)` e `AnnotationsDao.drawingsOfLayers(layerIds)`;
- `KvDao.delete(key)`.

- [ ] RED → GREEN → commit `feat(dados): leituras por id das camadas e anotações e apagar do kv`.

### Tarefa 12: `InkRepository`

**Arquivos:** criar `lib/features/reader/annotations/ink_repository.dart` e `test/support/fake_ink_repository.dart`;
teste `test/features/reader/annotations/ink_repository_test.dart`.

```dart
/// Um desenho salvo do livro: a camada `over_text` viva e a anotação `drawing` dela.
typedef SavedDrawing = ({InkLayer layer, Annotation annotation});

abstract interface class InkRepository {
  Future<List<SavedDrawing>> drawingsOfBook(String userBookId);
  /// Uma transação, pelo `LocalVersioning.write`, com HLC.
  Future<void> commit(String owner, String userBookId, InkChanges c);
  Future<void> saveDraft(String owner, String userBookId, InkChanges c);
  Future<InkChanges?> draftOf(String owner, String userBookId);
  Future<void> clearDraft(String owner, String userBookId);
  /// D-166: grava o rascunho como um Concluir e apaga a chave; se falhar, a chave fica (`false`).
  Future<bool> recoverDraft(String owner, String userBookId);
}
```

`DriftInkRepository(db, versioning, {now})`:
- `commit`: numa `db.transaction`, cada linha pelo `versioning.write`:
  - camadas novas (`created = updated = at`) e mudadas (mantém o `createdAt` lido, `edited`);
  - anotações `drawing` (`source = ink`, a cor do 1º traço, `ref_page`/`chapter_index` do começo do trecho, o grupo);
  - `deletedLayers`: camada e anotações dela com `deleted`;
  - `erasedHighlights`: o grifo e as notas filhas com `deleted`;
  - linha que já não existe ou já está apagada: pula (idempotente).
- `recoverDraft`: lê, `commit`, `clearDraft`; falha → `onError` sem conteúdo e `false`.

Testes (banco em memória):
- o Concluir grava camadas, anotações, HLC crescente e `updated_at` = hora do HLC;
- um erro no meio (a guarda de versão) não grava nada (transação);
- grifo e notas apagados;
- aplicar duas vezes dá as mesmas linhas;
- `drawingsOfBook` não traz as apagadas nem as `space`;
- rascunho de ida e volta no `kv` e `recoverDraft` grava e apaga a chave; falha deixa a chave.

- [ ] RED → GREEN → commit `feat(tinta): repositório da tinta — Concluir numa transação e rascunho (D-166)`.

### Tarefa 13: fila do Pro, privacidade do Grátis e limpeza do rascunho

**Arquivos:** `lib/features/account/data/local_library.dart`; testes
`test/features/reader/annotations/ink_sync_queue_test.dart` (PowerSync, como o `powersync_connection_test.dart`),
`test/features/reader/annotations/ink_privacy_free_test.dart` e o teste da `local_library` que já existe.

- Pro: o rascunho (`saveDraft`) não põe nada na `ps_crud`; o `commit` põe um `PUT` por linha mudada; Grátis: a fila
  continua vazia.
- Privacidade: um cliente HTTP que grava cada pedido (o `FakeBackend` da G05) durante uma sessão inteira pelo
  repositório e pela sessão (desenhar, apagar, mover, concluir, rascunho): nenhum pedido.
- `erase(owner)` apaga também `ink_draft:<dono>:*`.

- [ ] RED → GREEN → commit `test(tinta): fila do Pro só no Concluir e nada na rede no Grátis`.

### Tarefa 14: `AnnotationSession`

**Arquivos:** criar `lib/features/reader/application/annotation_session.dart`; teste
`test/features/reader/application/annotation_session_test.dart` (com o `FakeInkRepository` e uma página sintética).

- `AnnotationSession.open({page, geometry, anchors, drawings (os salvos da página), highlights (grifos da página, de
  seleção e à mão, com as caixas), presets (PenPresets), repository, owner, userBookId, startTimer, now, onError,
  onInteraction, savePresets})`.
- Estado: `tool` (`AnnotationTool.pen|marker|eraser|lasso|line|space`), `strokeSize`, `color`, `canUndo/canRedo`,
  `panOffset`, `live` (`ValueNotifier<LiveInk?>`: traço ao vivo, a prévia da Reta ou o contorno do laço), `selection`
  (traços do laço + retângulo), `dirty`, `failed` (a pílula da falha), `revision` (para o cache da pintura).
- Entradas: `pointerDown/Move/Up/Cancel(InkPointer)` passam pelo árbitro; `setTool`, `setStrokeSize` (grava no
  `pen_presets` na hora — `savePresets`), `undo`, `redo`, `panEnd` (o batente volta em 220 ms — a tela anima).
- Caneta: pontos em coordenadas do leitor limpo (a tela tira 30 + deslocamento); pressão real da caneta ou simulada
  (`simulatedPressure`) na captura; toque sem arrastar = 1 ponto; `DrawEnd` vira `AddStroke` (no desenho tocado ou num
  novo; desenho que passaria de 256 KiB fecha e o traço começa outro).
- Reta: prévia ao vivo; grudada (15°/4°); < 4 px não cria; grava 2 pontos com `tool = line`.
- Borracha: cada passada é um `Erase` (traços e grifos **à mão** tocados — D-168: os de seleção nem entram como
  candidatos).
- Laço: contorno ao vivo; ao soltar seleciona (≥ 50 %); arrastar dentro do retângulo move ao vivo (`MoveStrokes` ao
  soltar); tocar fora solta; `setTool(eraser)` com seleção apaga os selecionados (um `Erase`) e deixa a Borracha.
- `changes()`: o `InkChanges` da sessão: desenhos novos e mudados com a âncora refeita (`placeDrawing` com o desenho
  inteiro), os pontos em em (`toFrame`), BNK1, o grupo dos novos (`cardGroup`, em ordem de criação, contra os da
  página), `refPage`/`chapterIndex` do começo do trecho (`anchors.placeOf`); desenhos que ficaram sem traços →
  `deletedLayers`.
- Rascunho: a cada 5 s com mudanças (`startTimer`) e `toBackground()`; `conclude()` grava pelo `commit`, apaga a
  chave e devolve `true`; falha → `failed = true`, rascunho guardado, `false`; sem mudanças → `true` sem gravar.
- `onInteraction` a cada toque (D-95).

Testes: cada item acima, com o relógio falso.

- [ ] RED → GREEN → commit `feat(tinta): sessão do modo anotação`.

### Tarefa 15: a tinta salva no leitor e o rascunho ao abrir

**Arquivos:** criar `lib/features/reader/application/reader_ink.dart`; mudar `reader_annotations.dart`; testes
`test/features/reader/application/reader_ink_test.dart` e `reader_annotations_test.dart`.

- `ReaderAnnotations.inkHighlightsIn(ReaderRange shown)`: os grifos `source = ink` do trecho (fora da D-32 — D-140).
- `InkSource` (interface, `Listenable`): `inkHighlightsIn(shown)`, `drawingsOn(DisplayPage page)` (os desenhos cuja
  âncora começa na página, já em coordenadas da tela — `placedFrame` + `fromFrame` —, com cache por página, layout e
  revisão) e `revision`.
- `ReaderInk(repository, owner, userBookId, anchors, annotations, onError)`: `load()` primeiro tenta
  `recoverDraft` (D-166, sem perguntar), depois lê os desenhos e relê quando `ink_layers`/`annotations` mudam (como o
  `ReaderAnnotations`); reancora pelo Anexo 03 §5.3 quando o sha é outro; sem lugar → não pinta.

Testes: desenho na página do começo do trecho e não na seguinte; outra fonte estica; órfão não aparece e continua no
banco; rascunho de uma sessão "morta" é gravado ao abrir e a chave some; falha deixa a chave e relata.

- [ ] RED → GREEN → commit `feat(tinta): a tinta salva para o leitor e o rascunho gravado ao abrir (D-166)`.

### Tarefa 16: pintura

**Arquivos:** criar `lib/features/reader/presentation/ink_painter.dart`; mudar `reader_page_view.dart` e
`page_marks.dart`; testes `test/features/reader/presentation/ink_painter_test.dart` e `reader_page_view_test.dart`.

- `Path inkPath(InkStroke s)`: Caneta = `freehandOutline` com `tipOptions(tip, size: dpOfCentiMm(w), last: true)` e a
  pressão de cada ponto; Reta = cápsula (segmento com pontas redondas) da largura do traço; 1 ponto = círculo.
- `paintInk(canvas, strokes)`: preenchido na cor e no alpha do traço (D-59).
- `InkPictureCache`: `ui.Picture` por (página, `layoutKey`, revisão), até 4 páginas, descartando as velhas.
- Mancha do grifo à mão (D-161): `paintHandHighlights(canvas, page, highlights, {Color? lightText})`; caixa de cada
  pedaço de linha: `left − 5 … right + 5`, de `textTop + 3` a `textBottom − 1`; o caminho do arquivo numa caixa de
  100×20 esticada; 90 % de opacidade, `BlendMode.multiply`; no Noite, a técnica da D-133 (por trás D − cor, por cima D
  em diferença).
- `ReaderPagesPainter` ganha `ink: InkSource?` e pinta fundos → texto → sublinhado → mancha → tinta, na atual e na
  vizinha.

Testes: contorno da Caneta com a largura da D-159; Reta com 2,2 de altura; ponto; cache (mesma chave = a mesma
`Picture`; revisão nova = outra); ordem de pintura pelo `debugPaint`/`recording canvas` (a mancha depois do texto, a
tinta por último); Noite com a diferença; a vizinha com a tinta dela.

- [ ] RED → GREEN → commit `feat(leitor): tinta e mancha do grifo à mão na página (D-59, D-161)`.

### Tarefa 17: recursos da tela

**Arquivos:** `pubspec.yaml`, `lib/core/design_system/tokens/app_typography.dart` (ou `reader_fonts.dart`, onde o
`literata` 15,5 já está), `app_icons_leitor.dart`, criar `app_illustrations_leitor.dart`, `app_svg.dart`, criar
`lib/core/design_system/painters/conic_ring_painter.dart`, mudar `highlight_toolbar.dart`; testes em
`test/design_system/`.

- As famílias `Bricolage15_5` (+`Ext`, `Vi`) no `pubspec.yaml`; `AppFonts.bricolage(15.5)` → `'Bricolage15_5'`.
- Estilos: `annModeTitle` (Bricolage 15,5/800, lh 1,1, ls −0,2), `annModeSubtitle` (Figtree 11,5/600 `#5B544B`),
  `annDone` (Figtree 15/800), `annLabel` (Figtree 10/700 `#6F665B`), `annLabelActive` (Figtree 10/800).
- `AppIconsLeitor.pencil`, `check`, `undo`, `redo` (no `all`, com pré-cache).
- `AppIllustrationsLeitor` com as 8 ilustrações; a pasta `assets/illustrations/leitor/` no `pubspec.yaml`.
- `AppSvg(..., colors: {Color(0xFFB6ACE4): brand, Color(0xFFFF552E): ink})` pelo `ColorMapper` do flutter_svg
  (`SvgAssetLoader(colorMapper: …)`, com a chave de cache própria).
- `ConicRingPainter(border, center, centerRadius, halo?)`: o anel da G13 com o miolo como parâmetro e o aro opcional;
  a barra da G13 usa com 7 (o golden da 21 não muda).

Testes: a família carrega; o mapa troca só as duas cores; o anel com miolo 13,5 e aro 2,5 `#FFFAF1`; a 21 continua
igual (o teste da L21 que já existe).

- [ ] RED → GREEN → commit `feat(design): Bricolage 15,5, ícones, ilustrações, troca de cor no SVG e anel cônico (G16)`.

### Tarefa 18: pílula do modo e Concluir (L22b)

**Arquivos:** criar `annotation_top_bar.dart`; teste `annotation_top_bar_test.dart`.

- `ann.modePill`: `NeoBox` `#FFFAF1` (Noite: `#2A2520`), borda 1,5, raio 26, sombra 3/3; padding 0/16/0/7;
  `ann.modePill.iconCircle` (38, `#FED170`, borda 1,5) com `ann.modePill.icon` (lápis 19); `ann.modePill.texts` com
  `title` e `subtitle` (gap 9; subtítulo com margem 2).
- `ann.done`: botão `#ABCF82`, borda 1,5, raio 26, sombra 3/3, padding 0/18/0/14, ✓ 19 + "Concluir" (gap 7),
  `onDone`; `Pressable` sem ripple.
- O topo em `max(50, área segura de cima + 3)`, laterais 14 (a `AnnotationMode` posiciona).

Testes: medidas da L22b no canvas 390×844; textos; Noite; semântica (ícones fora; "Concluir" botão).

- [ ] RED → GREEN → commit `feat(leitor): pílula do modo anotação e Concluir (L22b)`.

### Tarefa 19: prateleira de ferramentas (L22c)

**Arquivos:** criar `tool_shelf.dart`; teste `tool_shelf_test.dart`.

- `ann.toolShelf` 312×70, `Row` de 6 botões 52×70 (`ann.toolShelf.{pen,marker,eraser,lasso,line,space}` com `.art`
  50×70 centralizado); a ativa sobe 12 (`Transform.translate`, a caixa de layout fica).
- Desenho de ativa só na Caneta e no Espaço (D-58): Caneta ativa = `il_ferramenta_caneta_ativa` com `brand`/`ink`
  trocados; inativa = `il_ferramenta_caneta` (corpo `#FFFAF1`) com o `ink`; as outras só sobem.
- Semântica: `radiogroup` "Ferramentas de anotação" com os rótulos do arquivo e o marcado.
- `onTool(AnnotationTool)`.

Testes: medidas (layout e visual da ativa), troca de ilustração, cores trocadas, semântica, toque.

- [ ] RED → GREEN → commit `feat(leitor): prateleira de ferramentas (L22c)`.

### Tarefa 20: a ilha (L22d)

**Arquivos:** criar `annotation_island.dart`; teste `annotation_island_test.dart`.

- `ann.island` (362×90, `#FFFAF1`/Noite `#2A2520`, borda 1,5, raio 26, sombra 3/3, padding 5/12/0).
- `ann.island.labels`: grade 6×52 centralizada; o ativo em pílula `brand` (Figtree 10/800, altura 19, borda 1,5); os
  outros Figtree 10/700 `#6F665B` (Noite: as cores da D-143); fora do leitor de tela.
- `ann.island.row`: separador tracejado `#CFC3AE` (`chromiumDash`), gap 10.
- `ann.island.colorWell` (42, `ConicRingPainter` com miolo 27 na cor da tinta e aro 2,5 `#FFFAF1`); semântica "Cor da
  caneta: ‹nome›. Toque para escolher qualquer cor" (coral, roxo, azul, verde, dourado, tinta preta; outra = o hex).
- `ann.island.width`: cápsula `#F7F0E3` borda 1,5 com Fina/Média/Grossa (36; pontos 5/9/14 na cor da tinta com aro
  1/1,2/1,4); a ativa com fundo `brand` e borda; `radiogroup` "Espessura do traço".
- `ann.island.spacer`; `ann.island.undo`/`redo` (44, `#F7F0E3`, borda 1,5; ícone 20); desabilitado = opacidade 0,38
  e `aria-disabled`.

Testes: as 24 medidas; rótulo ativo muda com a ferramenta; nomes das cores; desabilitados; toques.

- [ ] RED → GREEN → commit `feat(leitor): ilha do modo anotação (L22d)`.

### Tarefa 21: o canvas (L22a)

**Arquivos:** criar `annotation_canvas.dart`; teste `annotation_canvas_test.dart`.

- `Listener` cru (`onPointerDown/Move/Up/Cancel` → `InkPointer` com `kind`, pressão, `timeStamp`) para a sessão.
- Pintura (um `CustomPaint`): o papel, a `DisplayPage` transladada `30 + panOffset` (recorte da caixa `ann.page`),
  fundos dos grifos de seleção não apagados, texto, sublinhado, mancha (D-161) dos não apagados, a tinta da sessão
  (`Picture` em cache pela `revision`).
- O traço ao vivo numa `RepaintBoundary` própria que só ouve `session.live` (contorno inteiro a cada amostra —
  ADR-006); a prévia da Reta; o contorno tracejado do laço (lavanda 35 %, traço `#1A1714` 1,7, tracejado 4/3) e o
  retângulo da seleção (6 de folga, raio 8 — D-21).
- `TouchIndicator` (D-167 6): só com o dedo; anel 38 `rgba(182,172,228,0.42)` com `DashedStadiumPainter` 1,5
  `#1A1714`; ponto 12 na cor da tinta com borda 1,5 (`ann.page.text.wavy.touchRing/touchDot` no golden); na Borracha e
  no Laço, só o anel.
- `DeskEdge` (`ann.deskEdge`): `IgnorePointer` + `DecoratedBox` com o degradê de 250 (papel opaco nos 135 de baixo,
  o papel com alfa 0 em cima).

Testes: o toque vira traço (pela sessão); 2 dedos movem; indicador só no dedo e só o anel na Borracha; laço tracejado;
a página transladada 30; o recorte; a borda não pega toque.

- [ ] RED → GREEN → commit `feat(leitor): canvas do modo anotação (L22a)`.

### Tarefa 22: a camada `AnnotationMode`

**Arquivos:** criar `annotation_mode.dart`; teste `annotation_mode_test.dart`.

- Monta, por cima da tela inteira: canvas, borda de mesa, prateleira (312×70, centralizada, base 68 acima da base da
  ilha, **atrás** da ilha), ilha (base `max(30, área segura de baixo − 4)`, laterais 14, altura 90), pílula e Concluir
  (topo `max(50, área segura de cima + 3)`, laterais 14).
- Entrada: o texto desce 30 em 220 ms `easeOutCubic` e a moldura aparece em 150 ms; saída ao contrário.
- Noite (D-167 17): pílula e ilha `#2A2520`, bordas e letras `#EDE3D1`, sombra `#0B0A08`; o Concluir e o círculo
  amarelo ficam com a borda e a sombra do Noite; a prateleira como no Creme; a borda de mesa com o papel do Noite.
- Semântica: a página "‹Título›, página X de Y — modo anotação"; "Barra de anotação".
- A pílula da falha "Não deu para salvar as anotações agora." (D-21) acima da ilha.

Testes: os lugares com área segura 0 e com 47/34 (iPhone); Noite; semântica.

- [ ] RED → GREEN → commit `feat(leitor): camada do modo anotação com os lugares do aparelho (D-167)`.

### Tarefa 23: integração no `ReaderScreen`

**Arquivos:** `reader_screen.dart`; teste `reader_screen_g16_test.dart` (fatia da integração).

- "Anotar" (EPUB) fecha os controles e abre a sessão com a página atual, os desenhos e grifos dela e o `pen_presets`;
  modo imersivo; anúncio "Modo anotação. Caneta, ‹cor›.".
- PDF: "Chega numa próxima fase" (D-164).
- Escondidos no modo: rodapé, fita, chip e a pílula "Voltar à pág. N" (o prazo não corre — `holdBack`, D-125).
- Sem resposta no modo (D-167 19): pressão longa, links, grifos e terços (a página de baixo não recebe toque).
- Concluir e Voltar (D-42): gravam e saem (texto sobe 30 em 220 ms); sem mudanças, só sai; falha → o modo fica com a
  pílula; tocar de novo tenta de novo.
- Avisos da D-163: Marca-texto, Espaço, poço e 2º toque na ativa (a ferramenta continua).
- O `ReaderInk` (tinta salva) junto do `ReaderAnnotations`; o rascunho gravado ao abrir (D-166).
- Ciclo de vida: segundo plano grava o rascunho.

- [ ] RED → GREEN → commit `feat(leitor): Anotar abre o modo anotação; Concluir e Voltar gravam (D-42, D-163, D-164)`.

### Tarefa 24: o mundo da tela 22

**Arquivos:** criar `test/fixtures/tinta_do_mundo.dart`; mudar `mundo_2026_09_20.dart`, `telas/instantaneo.dart`,
`telas/t22.dart`, `test/support/mundo_epub.dart`, `test/fixtures/mundo_de_referencia_test.dart`; criar
`test/support/dados_t22.dart`.

- `tinta_do_mundo.dart`: amostra os caminhos do arquivo a cada 0,5 px (M/C/S/Q/T/L, como o SVG) e leva às caixas
  medidas do `kRef22` (elipse com `preserveAspectRatio="none"` em 186,54×42,44; risco em 34×12; a onda completa; as 2
  barras como Reta), menos os 30 px do modo; depois para em na moldura do trecho (origem e linha de base da prancha,
  em 20,5) e para o BNK1 (pressão 0,5; larguras pela D-159: 2,3 → 125; 1,8 → 98; 2,4 → 131).
- O mundo base ganha os traços (elipse com 2 traços; onda; duplo) e as âncoras de 8 chaves.
- `mundoDaTela22`: sem a onda e o duplo (camadas e anotações); `t22` usa ele.
- D-169: `mundoSemTintaDeHoje` (a tinta de hoje — os 3 desenhos e o grifo à mão — com a âncora sem lugar: outro `sha`
  e uma citação que não existe no capítulo); os instantâneos e os livros de teste das pranchas 19, 20, 26, 26b, 27 e
  27b passam a usar ele, e os goldens dessas pranchas não mudam (o teste prova que a contagem continua 12 e a página
  não pinta tinta).
- `mundoEpub(..., nbsp: {...})`: NBSP dentro dos 4 trechos anotados do cap. XXXII; as âncoras da 22 refeitas com o sha
  e a citação desse arquivo (os offsets não mudam).
- O teste da G03 "22/23/23b/24": a 22 passa a ter 2 anotações (o grifo à mão e a elipse) e 1 camada — a única mudança
  prevista num teste de fase anterior.
- `dados_t22.dart`: o livro da 22 na estante (EPUB com NBSP, índice da 19, pág. 159, anotações e camadas do mundo,
  `pen_presets` do mundo) e `abrirTela22` pelo fluxo real (controles → Anotar → Reta, as 2 barras nos centros medidos
  → Caneta → a onda até 66 % e o último movimento até o centro do anel, com o dedo parado).

- [ ] RED → GREEN → commit `test(leitor): mundo da tela 22 com a tinta do arquivo e NBSP (D-160)`.

### Tarefa 25: fases L22a–d e golden 22

**Arquivos:** criar `test/support/fase_l22.dart`, `test/features/reader/presentation/l22a_test.dart` … `l22d_test.dart`,
`test/golden/leitor_22_test.dart` (o padrão dos goldens 27/27b).

- Geometria: os ids de cada seção (sem os inline) com ±0,5 (±1,0 em x/w nos `textDependentX`); `ann.page.text` pelo
  bloco; a tinta pelos pontos (desvio ≤ 0,5 px além da quantização) e a mancha pela caixa calculada; anel e ponto pelo
  retângulo.
- Texto: as 22 linhas do parágrafo (a 22ª escondida), o fio de navalha das linhas 7 e 19; rótulos; "Concluir"; "Modo
  anotação"; o subtítulo. Mais: vindo da 19 (sem NBSP), as quebras do leitor limpo ficam e o texto só desce 30.
- Estilo: bordas 1,5/1,3/1,2, sombras duras, as fontes e as cores; o degradê.
- Golden @3x contra `22_modo_anotacao_390x844@3x.png` nos recortes (a 108–844, b 42–110, c 656–754, d 716–822) com
  `blur_mismatch_% ≤ 0,5`; lado a lado e heatmap inspecionados.
- Semântica e dados (os textos saem do instantâneo e das contas).

- [ ] RED → GREEN → commit `test(leitor): fases L22a–d e golden da tela 22`.

### Tarefa 26: comportamento da tela

**Arquivos:** `test/features/reader/presentation/reader_screen_g16_test.dart`.

- "Anotar" abre; vindo da 19 as quebras ficam e o texto desce 30 (D-160);
- Concluir e Voltar gravam e saem; sem mudança só sai;
- Marca-texto, Espaço, poço e 2º toque mostram o aviso;
- a espessura grava no `pen_presets`;
- Desfazer e Refazer ligam e desligam;
- 2 dedos movem até o limite e voltam do batente;
- a tinta aparece no leitor limpo e acompanha a mudança de fonte, tamanho e margem (G14);
- PDF; Noite; leitor de tela; a falha ao salvar; o rascunho depois de "matar" a sessão.

- [ ] RED → GREEN → commit `test(leitor): comportamento do modo anotação`.

### Tarefa 27: verificação, revisão e relatório

- [ ] `dart format --set-exit-if-changed lib test`, `flutter analyze` (0), `flutter test` (a suíte).
- [ ] Cobertura ≥ 90 % nos arquivos da fase (`flutter test --coverage` + soma por arquivo do `lcov.info`).
- [ ] Mutação das regras novas (150 ms, 15°/4°, 4 px, 50 %, meia altura de linha, 2 linhas, 0,25 em, 100 comandos,
  5 s, 30 px, 256 KiB): cada mutação manual derruba ao menos um teste.
- [ ] gitleaks nos commits da branch e nas pastas tocadas.
- [ ] Revisão independente por um agente que não escreveu o código; correções em subfase.
- [ ] Latência no celular (modo profile, medidor do S4 ligado ao modo por `--dart-define`): p50, p95 e máx. contra
  16,7/8,3 ms — com o celular da pessoa ligado por USB; se não bater, a subfase dos pontos previstos (Anexo 03 §9.3).
- [ ] Capturas na conversa: a 22 em Creme e no Noite; a tinta no leitor limpo antes e depois de mudar a fonte; o laço
  com seleção; a borracha; o lado a lado com a prancha.
- [ ] `G16.md` (Resultados, Revisão independente, Desvios, Pendências, Capturas, Checklist) e `RELATORIO_G16.md`.
- [ ] Commit `docs(g16): resultados, revisão independente, desvios e relatório da fase; capturas` e **parar** com a
  frase do §4.1.
