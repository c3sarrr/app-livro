// G02 · S3 — paginador com dart:ui (Anexo 03 §7.2).
// Cada bloco vira um ui.Paragraph (layout uma vez); as linhas vão para a página até a próxima não
// caber; parágrafo partido entre páginas = o mesmo Paragraph pintado com deslocamento e recorte.
// Recuo de 1,3 em = PlaceholderSpan no início do parágrafo → ocupa 1 unidade (U+FFFC) no texto
// do Paragraph; [offsetCanonico] / [offsetParagrafo] fazem a conversão (helper único).
//
// ACHADO do S3: o SkParagraph arredonda a ALTURA de cada linha para px inteiro
// (InternalLineMetrics::height() = round(descent − ascent + leading)): com 20,5 × 1,72 = 35,26 as
// linhas saem a cada 35,00 px e a 19ª linha fica 4,68 px acima do Chromium. Por isso o modelo
// vertical é próprio: topo exato de cada linha = soma de (ascent + descent) — que o Flutter dá sem
// arredondar — e a pintura é feita linha a linha ([pintarFatia]: recorte da faixa da linha +
// deslocamento [BlocoLayout.correcao]).
import 'dart:ui' as ui;

import 'epub.dart';

class Tipografia {
  const Tipografia({
    this.tamanho = 20.5,
    this.entrelinha = 1.72,
    this.margem = 28,
    this.larguraTela = 390,
    this.alturaTela = 844,
    this.topo = 92,
    this.base = 82,
    this.arredondar64 = false,
    this.familia = 'S3VF',
    this.fallback = const ['S3VFExt', 'S3VFVi'],
  });

  final double tamanho;
  final double entrelinha;
  final double margem;
  final double larguraTela;
  final double alturaTela;
  final double topo;
  final double base;

  /// true = altura de linha arredondada para baixo a 1/64 px (o que o Chromium faz a zoom 1 com
  /// fator de escala 1); false = tamanho × entrelinha exato (o que as referências medidas mostram).
  final bool arredondar64;
  final String familia;
  final List<String> fallback;

  double get alturaLinha => arredondar64
      ? (tamanho * entrelinha * 64).floorToDouble() / 64
      : tamanho * entrelinha;
  double get larguraConteudo => larguraTela - 2 * margem;
  double get alturaConteudo => alturaTela - topo - base;
  double get recuo => 1.3 * tamanho;

  /// Tolerância de encaixe vertical (Anexo 03 §7.1).
  static const tolerancia = 0.02;

  ui.TextStyle estilo({bool titulo = false}) => ui.TextStyle(
    fontFamily: familia,
    fontFamilyFallback: fallback,
    fontSize: tamanho,
    height: alturaLinha / tamanho,
    leadingDistribution: ui.TextLeadingDistribution.even,
    fontWeight: titulo ? ui.FontWeight.w600 : ui.FontWeight.w400,
    fontVariations: [
      ui.FontVariation('opsz', tamanho),
      ui.FontVariation('wght', titulo ? 600 : 400),
    ],
    color: const ui.Color(0xFF2A2520),
  );
}

class BlocoLayout {
  BlocoLayout(this.bloco, this.paragrafo, this.linhas) {
    var y = 0.0;
    for (final lm in linhas) {
      _topos.add(y);
      y += lm.ascent + lm.descent;
    }
  }

  final Bloco bloco;
  final ui.Paragraph paragrafo;
  final List<ui.LineMetrics> linhas;
  final _topos = <double>[];

  /// Topo exato da linha [l] (sem o arredondamento de altura do SkParagraph).
  double topo(int l) => _topos[l];
  double fundo(int l) => _topos[l] + linhas[l].ascent + linhas[l].descent;
  double baseline(int l) => _topos[l] + linhas[l].ascent;

  /// Quanto a linha [l] precisa descer, ao pintar o Paragraph, para cair na posição exata.
  double correcao(int l) => baseline(l) - linhas[l].baseline;

  /// Offset no texto do Paragraph → offset canônico do item (desconta o U+FFFC do recuo).
  int offsetCanonico(int noParagrafo) =>
      bloco.inicio + noParagrafo - (bloco.recuo ? 1 : 0);

  /// Offset canônico do item → offset no texto do Paragraph.
  int offsetParagrafo(int canonico) =>
      canonico - bloco.inicio + (bloco.recuo ? 1 : 0);

  /// Primeiro offset (no Paragraph) da linha [l], por busca binária em getLineNumberAt.
  int inicioDaLinha(int l) {
    if (l == 0) return 0;
    var lo = 0;
    var hi = bloco.texto.length + (bloco.recuo ? 1 : 0);
    while (lo < hi) {
      final m = (lo + hi) >> 1;
      if ((paragrafo.getLineNumberAt(m) ?? 1 << 30) < l) {
        lo = m + 1;
      } else {
        hi = m;
      }
    }
    return lo;
  }

  void dispose() => paragrafo.dispose();
}

BlocoLayout layoutBloco(Bloco b, Tipografia t) {
  final pb = ui.ParagraphBuilder(
    ui.ParagraphStyle(
      textDirection: ui.TextDirection.ltr,
      textAlign: ui.TextAlign.left,
    ),
  )..pushStyle(t.estilo(titulo: b.tipo == TipoBloco.titulo));
  if (b.recuo) {
    pb.addPlaceholder(
      t.recuo,
      0,
      ui.PlaceholderAlignment.baseline,
      baseline: ui.TextBaseline.alphabetic,
    );
  }
  pb.addText(b.texto);
  final p = pb.build()
    ..layout(ui.ParagraphConstraints(width: t.larguraConteudo));
  return BlocoLayout(b, p, p.computeLineMetrics());
}

/// Trecho de um bloco numa página: linhas [primeira, ultima] desenhadas com o topo da
/// primeira em [y] (coordenada da caixa de conteúdo).
class Fatia {
  Fatia(this.bloco, this.primeira, this.ultima, this.y);

  final int bloco;
  final int primeira;
  final int ultima;
  final double y;
}

class Pagina {
  Pagina(this.fatias);

  final List<Fatia> fatias;
}

/// Pagina os blocos já com layout. Títulos ficam com a 1ª linha do bloco seguinte.
List<Pagina> paginar(List<BlocoLayout> blocos, Tipografia t) {
  final paginas = <Pagina>[];
  var atual = <Fatia>[];
  var y = 0.0;
  final limite = t.alturaConteudo + Tipografia.tolerancia;

  void fechar() {
    if (atual.isNotEmpty) paginas.add(Pagina(atual));
    atual = <Fatia>[];
    y = 0;
  }

  for (var i = 0; i < blocos.length; i++) {
    final b = blocos[i];
    var l = 0;
    // Título órfão: se o título cabe mas a 1ª linha do próximo bloco não, vira a página antes.
    if (b.bloco.tipo == TipoBloco.titulo && i + 1 < blocos.length && y > 0) {
      final prox = blocos[i + 1];
      final alturaTitulo = b.fundo(b.linhas.length - 1) - b.topo(0);
      final alturaProx = prox.fundo(0) - prox.topo(0);
      if (y + alturaTitulo + alturaProx > limite) fechar();
    }
    while (l < b.linhas.length) {
      final inicioFatia = l;
      final deslocamento = b.topo(l);
      while (l < b.linhas.length && y + (b.fundo(l) - deslocamento) <= limite) {
        l++;
      }
      if (l == inicioFatia) {
        // Nem uma linha cabe: página nova (se a página já está vazia, força a linha).
        if (atual.isEmpty) {
          l++;
        } else {
          fechar();
          continue;
        }
      }
      atual.add(Fatia(i, inicioFatia, l - 1, y));
      y += b.fundo(l - 1) - deslocamento;
      if (l < b.linhas.length) fechar();
    }
  }
  fechar();
  return paginas;
}

/// Pinta a fatia linha a linha na posição exata: [origem] = canto superior esquerdo da caixa de
/// conteúdo da página. Cada linha é recortada na própria faixa (topo…fundo exatos).
void pintarFatia(ui.Canvas c, BlocoLayout b, Fatia f, ui.Offset origem) {
  for (var l = f.primeira; l <= f.ultima; l++) {
    final lm = b.linhas[l];
    final dy = origem.dy + f.y - b.topo(f.primeira) + b.correcao(l);
    c
      ..save()
      ..clipRect(
        ui.Rect.fromLTRB(
          origem.dx - 64,
          lm.baseline - lm.ascent + dy,
          origem.dx + b.paragrafo.width + 64,
          lm.baseline + lm.descent + dy,
        ),
      )
      ..drawParagraph(b.paragrafo, ui.Offset(origem.dx, dy))
      ..restore();
  }
}

/// Pintura ingênua (o Paragraph inteiro de uma vez, com a altura de linha arredondada pelo
/// SkParagraph) — só para comparação no spike.
void pintarFatiaIngenua(ui.Canvas c, BlocoLayout b, Fatia f, ui.Offset origem) {
  final lm0 = b.linhas[f.primeira];
  final lmN = b.linhas[f.ultima];
  final dy = origem.dy + f.y - (lm0.baseline - lm0.ascent);
  c
    ..save()
    ..clipRect(
      ui.Rect.fromLTRB(
        origem.dx - 64,
        lm0.baseline - lm0.ascent + dy,
        origem.dx + b.paragrafo.width + 64,
        lmN.baseline + lmN.descent + dy,
      ),
    )
    ..drawParagraph(b.paragrafo, ui.Offset(origem.dx, dy))
    ..restore();
}

/// Layout de parágrafo longo em pedaços (fatias de tempo ≤ 4 ms): cada pedaço tem até
/// [maxChars] caracteres (estendido até o próximo espaço); a última linha de cada pedaço é
/// descartada e o pedaço seguinte recomeça no início dela. Como a quebra de linha é gulosa
/// (cada linha só depende de onde começa), as linhas mantidas são idênticas às do layout inteiro.
/// Devolve o início (offset no texto do bloco, sem o U+FFFC) de cada linha e o custo de cada
/// pedaço em microssegundos.
({List<int> inicios, List<int> custosUs, int pedacos}) layoutEmPedacos(
  Bloco b,
  Tipografia t,
  int maxChars,
) {
  final inicios = <int>[];
  final custos = <int>[];
  var pos = 0;
  var pedacos = 0;
  while (true) {
    var fim = pos + maxChars;
    if (fim >= b.texto.length) {
      fim = b.texto.length;
    } else {
      while (fim < b.texto.length && b.texto.codeUnitAt(fim) != 0x20) {
        fim++;
      }
    }
    final ultimo = fim == b.texto.length;
    final comRecuo = pos == 0 && b.recuo;
    final sw = Stopwatch()..start();
    final parte = Bloco(b.tipo, b.texto.substring(pos, fim));
    final pb = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textDirection: ui.TextDirection.ltr,
        textAlign: ui.TextAlign.left,
      ),
    )..pushStyle(t.estilo(titulo: b.tipo == TipoBloco.titulo));
    if (comRecuo) {
      pb.addPlaceholder(
        t.recuo,
        0,
        ui.PlaceholderAlignment.baseline,
        baseline: ui.TextBaseline.alphabetic,
      );
    }
    pb.addText(parte.texto);
    final p = pb.build()
      ..layout(ui.ParagraphConstraints(width: t.larguraConteudo));
    final n = p.computeLineMetrics().length;
    custos.add(sw.elapsedMicroseconds);
    pedacos++;
    final mantidas = ultimo ? n : n - 1;
    if (!ultimo && mantidas < 1) {
      p.dispose();
      throw StateError('maxChars pequeno demais');
    }
    final desloc = comRecuo ? 1 : 0;
    int inicioLinha(int l) {
      if (l == 0) return 0;
      var lo = 0;
      var hi = parte.texto.length + desloc;
      while (lo < hi) {
        final m = (lo + hi) >> 1;
        if ((p.getLineNumberAt(m) ?? 1 << 30) < l) {
          lo = m + 1;
        } else {
          hi = m;
        }
      }
      return lo;
    }

    for (var l = 0; l < mantidas; l++) {
      inicios.add(pos + (l == 0 ? 0 : inicioLinha(l) - desloc));
    }
    final proximo = ultimo ? fim : pos + inicioLinha(n - 1) - desloc;
    p.dispose();
    if (ultimo) break;
    pos = proximo;
  }
  return (inicios: inicios, custosUs: custos, pedacos: pedacos);
}
