// G16 (Tarefa 24) — a tinta do mundo de referência, tirada dos SVGs da prancha 22 (`handoff_v2/referencia/svg_tinta/`,
// o HTML da L22a): cada caminho é amostrado a cada 0,5 px (M/L/C/S/Q/T, absolutos e relativos, como o SVG desenha) na
// caixa medida do `kRef22` — a elipse esticada sem manter a proporção (o `preserveAspectRatio="none"` em 186,54×42,44),
// o risco em 34×12, a onda completa (a largura toda do trecho; a prancha mostra 66 %, ainda sendo desenhada) e as 2
// barras como Reta —; depois vai para a moldura em em do trecho (o início dele na linha de base da prancha, a letra de
// 20,5 — os 30 px do modo saem dos dois lados) e para o BNK1 (pressão 0,5; larguras pela D-159: 2,3 → 125; 1,8 → 98;
// 2,2 → 120; 2,4 → 131). G18 (R15): a nota à mão da 24b (`nota_mao_ressaca.svg`) na unidade da caixa.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

import 'package:app_leitura/features/reader/annotations/ink/bnk1_codec.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_units.dart';
import 'package:app_leitura/features/reader/annotations/space/space_metrics.dart';

import '../reference/leitor/reference_layout_22_modo_anotacao.dart';

/// Os caminhos dos SVGs da L22a.
const String caminhoDaElipse =
    'M60 3C86 2 99 10 98.5 21 97.5 33 76 38.5 48 37.5 20 36.5 2 30 2.5 19 3.5 8 25 2.5 53 3.5 70 4.5 83 8.5 88 12.5';
const String caminhoDoRisco = 'M1 7.5Q4 3 7 7.5T13 7.5 19 7.5 25 7.5 31 7.5';
final String caminhoDaOnda =
    'M0 5 ${List.filled(22, 'q3 -4.5 6 0 t6 0').join(' ')}';

/// A cor da tinta do mundo (coral).
const int tintaCoral = 0xFFFF552E;

/// A letra da página nas pranchas (20,5 px).
const double emDaPrancha = 20.5;

/// O passo da amostragem (px).
const double passoDaAmostra = 0.5;

/// O caminho [d] na tela: cada ponto (x, y) do SVG vai a `origem + (x·sx, y·sy)`; amostrado a cada [passo] px ao
/// longo do traço. [ateX] corta no x do SVG (o `overflow: hidden` da onda).
List<Offset> amostrarCaminho(
  String d, {
  required Offset origem,
  double sx = 1,
  double sy = 1,
  double passo = passoDaAmostra,
  double? ateX,
}) {
  final tokens = RegExp(r'[MmLlCcSsQqTtZz]|-?(?:\d+\.?\d*|\.\d+)(?:[eE]-?\d+)?')
      .allMatches(d)
      .map((m) => m.group(0)!)
      .toList();
  var i = 0;
  String? cmd;
  var cur = Offset.zero;
  var start = Offset.zero;
  Offset? lastCubic;
  Offset? lastQuad;
  final densa = <Offset>[];
  double n() => double.parse(tokens[i++]);
  Offset pt(bool rel) {
    final x = n();
    final y = n();
    return rel ? cur + Offset(x, y) : Offset(x, y);
  }

  Offset tela(Offset p) => origem + Offset(p.dx * sx, p.dy * sy);
  void segmento(Offset Function(double t) f) {
    const passos = 96;
    for (var k = 1; k <= passos; k++) {
      densa.add(tela(f(k / passos)));
    }
  }

  while (i < tokens.length) {
    final t = tokens[i];
    if (RegExp('[A-Za-z]').hasMatch(t)) {
      cmd = t;
      i++;
      if (cmd == 'Z' || cmd == 'z') {
        final a = cur;
        segmento((u) => Offset.lerp(a, start, u)!);
        cur = start;
        continue;
      }
    }
    final rel = cmd!.toLowerCase() == cmd;
    switch (cmd.toUpperCase()) {
      case 'M':
        cur = pt(rel);
        start = cur;
        densa.add(tela(cur));
        // os pares seguintes de um M são L
        cmd = rel ? 'l' : 'L';
        lastCubic = lastQuad = null;
      case 'L':
        final a = cur;
        final b = pt(rel);
        segmento((u) => Offset.lerp(a, b, u)!);
        cur = b;
        lastCubic = lastQuad = null;
      case 'C':
        final p0 = cur;
        final c1 = pt(rel);
        final c2 = pt(rel);
        final p3 = pt(rel);
        segmento((u) => _cubica(p0, c1, c2, p3, u));
        cur = p3;
        lastCubic = c2;
        lastQuad = null;
      case 'S':
        final p0 = cur;
        final c1 = lastCubic == null ? p0 : p0 * 2 - lastCubic;
        final c2 = pt(rel);
        final p3 = pt(rel);
        segmento((u) => _cubica(p0, c1, c2, p3, u));
        cur = p3;
        lastCubic = c2;
        lastQuad = null;
      case 'Q':
        final p0 = cur;
        final c = pt(rel);
        final p2 = pt(rel);
        segmento((u) => _quadratica(p0, c, p2, u));
        cur = p2;
        lastQuad = c;
        lastCubic = null;
      case 'T':
        final p0 = cur;
        final c = lastQuad == null ? p0 : p0 * 2 - lastQuad;
        final p2 = pt(rel);
        segmento((u) => _quadratica(p0, c, p2, u));
        cur = p2;
        lastQuad = c;
        lastCubic = null;
      default:
        throw FormatException('comando $cmd', d);
    }
  }
  // o corte do `overflow: hidden`
  var linha = densa;
  final corte = ateX;
  if (corte != null) {
    final limite = origem.dx + corte * sx;
    linha = <Offset>[];
    for (var k = 0; k < densa.length; k++) {
      final p = densa[k];
      if (p.dx <= limite) {
        linha.add(p);
        continue;
      }
      if (k > 0) {
        final a = densa[k - 1];
        final f = (limite - a.dx) / (p.dx - a.dx);
        linha.add(Offset.lerp(a, p, f)!);
      }
      break;
    }
  }
  // de novo a cada [passo] px ao longo do traço
  final out = <Offset>[linha.first];
  var resto = passo;
  for (var k = 1; k < linha.length; k++) {
    var a = linha[k - 1];
    final b = linha[k];
    var seg = (b - a).distance;
    while (seg >= resto) {
      a = Offset.lerp(a, b, resto / seg)!;
      out.add(a);
      seg = (b - a).distance;
      resto = passo;
    }
    resto -= seg;
  }
  if ((out.last - linha.last).distance > 1e-6) out.add(linha.last);
  return out;
}

Offset _cubica(Offset p0, Offset c1, Offset c2, Offset p3, double t) {
  final u = 1 - t;
  return p0 * (u * u * u) +
      c1 * (3 * u * u * t) +
      c2 * (3 * u * t * t) +
      p3 * (t * t * t);
}

Offset _quadratica(Offset p0, Offset c, Offset p2, double t) {
  final u = 1 - t;
  return p0 * (u * u) + c * (2 * u * t) + p2 * (t * t);
}

/// Um desenho do mundo: o trecho (o id do `kRef22`), os traços em em, a largura do trecho em em e o BNK1.
typedef DesenhoDoMundo = ({
  String trecho,
  List<InkStroke> emEm,
  double w,
  String strokesB64,
});

/// A moldura do trecho [trecho] na prancha: o início e a linha de base (coordenadas da tela 22) e a largura em em.
({double x, double baseline, double w}) molduraNaPrancha(String trecho) {
  final l = kRef22.elements[trecho]!.lines.single;
  return (x: l.left, baseline: l.baseline, w: (l.right - l.left) / emDaPrancha);
}

InkStroke _traco(
  List<Offset> pontos, {
  required String trecho,
  required double larguraPx,
  InkTool tool = InkTool.pen,
}) {
  final m = molduraNaPrancha(trecho);
  return InkStroke(
    tool: tool.code,
    tip: 0,
    argb: tintaCoral,
    widthCentiMm: centiMmOfDp(larguraPx),
    points: [
      for (var i = 0; i < pontos.length; i++)
        InkPoint(
          (pontos[i].dx - m.x) / emDaPrancha,
          (pontos[i].dy - m.baseline) / emDaPrancha,
          0.5,
          4 * i,
        ),
    ],
  );
}

DesenhoDoMundo _desenho(String trecho, List<InkStroke> tracos) => (
  trecho: trecho,
  emEm: List.unmodifiable(tracos),
  w: molduraNaPrancha(trecho).w,
  strokesB64: encodeStrokesB64(tracos, Bnk1Unit.em),
);

/// A caixa medida de [id] na prancha 22.
Rect caixaNaPrancha(String id) => kRef22.elements[id]!.rect;

/// A elipse (2,3 px) e o risco acima (1,8 px) em "Olhos de ressaca?" — um desenho, 2 traços.
List<Offset> pontosDaElipse22() {
  final c = caixaNaPrancha('ann.page.text.circled.ellipse');
  return amostrarCaminho(
    caminhoDaElipse,
    origem: c.topLeft,
    sx: c.width / 100,
    sy: c.height / 40,
  );
}

List<Offset> pontosDoRisco22() => amostrarCaminho(
  caminhoDoRisco,
  origem: caixaNaPrancha('ann.page.text.circled.flourish').topLeft,
);

/// A onda (2,2 px) sob "fluido misterioso", até [ate] da largura do trecho (1 = completa; a prancha mostra 66 %).
List<Offset> pontosDaOnda22({double ate = 1}) {
  final trecho = kRef22.elements['ann.page.text.wavy']!.rect;
  final onda = caixaNaPrancha('ann.page.text.wavy.wave');
  return amostrarCaminho(
    caminhoDaOnda,
    origem: onda.topLeft,
    ateX: trecho.width * ate,
  );
}

/// As 2 barras do sublinhado duplo (2,4 px, raio de ponta) como Reta: do centro da ponta esquerda ao da direita.
List<(Offset, Offset)> barrasDoDuplo22() => [
  for (final id in const [
    'ann.page.text.doubleUnderline.line1',
    'ann.page.text.doubleUnderline.line2',
  ])
    () {
      final r = caixaNaPrancha(id);
      final raio = r.height / 2;
      return (
        Offset(r.left + raio, r.center.dy),
        Offset(r.right - raio, r.center.dy),
      );
    }(),
];

/// A elipse e o risco, presos a "Olhos de ressaca?".
final DesenhoDoMundo desenhoDaElipse = _desenho('ann.page.text.circled', [
  _traco(pontosDaElipse22(), trecho: 'ann.page.text.circled', larguraPx: 2.3),
  _traco(pontosDoRisco22(), trecho: 'ann.page.text.circled', larguraPx: 1.8),
]);

/// A onda completa, presa a "fluido misterioso".
final DesenhoDoMundo desenhoDoOndulado = _desenho('ann.page.text.wavy', [
  _traco(pontosDaOnda22(), trecho: 'ann.page.text.wavy', larguraPx: 2.2),
]);

/// O sublinhado duplo, preso a "a vaga que se retira".
final DesenhoDoMundo desenhoDoDuplo = _desenho(
  'ann.page.text.doubleUnderline',
  [
    for (final (a, b) in barrasDoDuplo22())
      _traco(
        [a, b],
        trecho: 'ann.page.text.doubleUnderline',
        larguraPx: 2.4,
        tool: InkTool.line,
      ),
  ],
);

// ---- G18 (R15) — a nota à mão da 24b ---------------------------------------------------------------------------

/// O arquivo da tinta da nota (`handoff_v2/referencia/svg_tinta/nota_mao_ressaca.svg`, o mesmo do HTML da L24b).
const String arquivoDaNotaAMao =
    'handoff_v2/referencia/svg_tinta/nota_mao_ressaca.svg';

/// O SVG desenha numa caixa de 334×150 dentro do `<svg width="100%" height="150">` da caixa — 331 de largura por
/// dentro da borda —; com o `preserveAspectRatio` padrão (meet, no meio), a escala é 331/334 e sobram 0,674 em cima.
const double larguraDaTintaDaNota = 331;
const double escalaDaNotaAMao = larguraDaTintaDaNota / 334;
const double sobraDaNotaAMao = (150 - 150 * escalaDaNotaAMao) / 2;

/// Os caminhos (`d`) dos `<path>` do arquivo, na ordem, e o círculo da íris (centro e raio).
({List<String> caminhos, Offset centro, double raio}) caminhosDaNotaAMao() {
  final svg = File(arquivoDaNotaAMao).readAsStringSync();
  final caminhos = [
    for (final m in RegExp(r'<path d="([^"]+)"').allMatches(svg)) m.group(1)!,
  ];
  final c = RegExp(r'<circle cx="([\d.]+)" cy="([\d.]+)" r="([\d.]+)"')
      .firstMatch(svg)!;
  return (
    caminhos: caminhos,
    centro: Offset(double.parse(c.group(1)!), double.parse(c.group(2)!)),
    raio: double.parse(c.group(3)!),
  );
}

/// Cada `M` de um caminho começa um traço (as letras escritas sem tirar a caneta).
List<String> tracosDoCaminho(String d) => [
  for (final m in RegExp(r'M[^M]+').allMatches(d)) m.group(0)!.trim(),
];

/// A íris cheia do arquivo (um círculo de 7,5) como a caneta faz: uma espiral de traço 2,2 do contorno de dentro até
/// o centro, com passo de 2 (cobre o círculo sem falhas). Coordenadas do SVG.
List<Offset> espiralDaIris(Offset centro, double raio) {
  const largura = 2.2;
  const passoDaVolta = 2.0;
  final r0 = raio - largura / 2;
  final voltas = r0 / passoDaVolta;
  final out = <Offset>[];
  const porVolta = 96;
  final n = (voltas * porVolta).ceil();
  for (var k = 0; k <= n; k++) {
    final a = 2 * math.pi * k / porVolta;
    final r = math.max(0.0, r0 - passoDaVolta * k / porVolta);
    out.add(centro + Offset(math.cos(a) * r, math.sin(a) * r));
  }
  return out;
}

/// Um ponto do SVG da nota em px por dentro da borda da caixa (o canto de cima à esquerda da tinta).
Offset naCaixaDaNota(Offset svg) => Offset(
  svg.dx * escalaDaNotaAMao,
  sobraDaNotaAMao + svg.dy * escalaDaNotaAMao,
);

/// Os traços da nota da 24b na unidade dela (x = fração da largura, y = linhas de 42 — `note_ink.dart`): cada
/// subcaminho amostrado a cada 0,5 px, a íris como espiral; caneta coral de 2,2 px, pressão 0,5.
List<InkStroke> tracosDaNotaAMao() {
  final (:caminhos, :centro, :raio) = caminhosDaNotaAMao();
  final linhas = <List<Offset>>[
    for (final d in caminhos)
      for (final t in tracosDoCaminho(d))
        amostrarCaminho(
          t,
          origem: const Offset(0, sobraDaNotaAMao),
          sx: escalaDaNotaAMao,
          sy: escalaDaNotaAMao,
        ),
    [for (final p in espiralDaIris(centro, raio)) naCaixaDaNota(p)],
  ];
  return [
    for (final l in linhas)
      InkStroke(
        tool: InkTool.pen.code,
        tip: 0,
        argb: tintaCoral,
        widthCentiMm: centiMmOfDp(2.2),
        points: [
          for (var i = 0; i < l.length; i++)
            InkPoint(
              l[i].dx / larguraDaTintaDaNota,
              l[i].dy / noteLinePx,
              0.5,
              4 * i,
            ),
        ],
      ),
  ];
}

/// A nota da 24b em BNK1 (unidade `box`) e quantos traços.
final ({String strokesB64, int strokeCount}) notaAMaoDoMundo = () {
  final t = tracosDaNotaAMao();
  return (strokesB64: encodeStrokesB64(t, Bnk1Unit.box), strokeCount: t.length);
}();

/// A distância do ponto [p] ao segmento [a]–[b] (os testes conferem a tinta contra o caminho do arquivo).
double distanciaAoSegmento(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final l2 = ab.distanceSquared;
  if (l2 == 0) return (p - a).distance;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / l2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}

/// A menor distância de [p] à polilinha [linha].
double distanciaALinha(Offset p, List<Offset> linha) {
  var best = double.infinity;
  for (var i = 1; i < linha.length; i++) {
    best = math.min(best, distanciaAoSegmento(p, linha[i - 1], linha[i]));
  }
  return best;
}
