// G02 · S4 — suavização do traço no estilo perfect-freehand (Anexo 03 §9.3). Dart puro.
//
// Porte fiel de perfect-freehand 1.2.3 (getStrokePoints + getStrokeOutlinePoints + simulatePressure),
// MIT License, Copyright (c) 2021 Stephen Ruiz Ltd — https://github.com/steveruizok/perfect-freehand
// Conferido contra o pacote npm 1.2.3 em test/suavizacao_test.dart (tolerância 1e-9).
import 'dart:math' as math;

typedef Vec = (double, double);

class OpcoesTraco {
  const OpcoesTraco({
    this.tamanho = 16,
    this.afinamento = 0.5,
    this.suavizacao = 0.5,
    this.estabilizacao = 0.5,
    this.simularPressao = true,
    this.taperInicio = 0,
    this.taperFim = 0,
    this.capInicio = true,
    this.capFim = true,
    this.completo = false,
  });

  /// Diâmetro base (dp).
  final double tamanho;

  /// thinning: efeito da pressão no diâmetro (0 = constante).
  final double afinamento;

  /// smoothing: distância mínima entre pontos do contorno (fração do tamanho).
  final double suavizacao;

  /// streamline: quanto o ponto segue o anterior (0 = cru, 1 = muito suave).
  final double estabilizacao;
  final bool simularPressao;

  /// Distância de afunilamento no início/fim (0 = sem; `double.infinity` = o traço todo).
  final double taperInicio;
  final double taperFim;
  final bool capInicio;
  final bool capFim;

  /// last: o traço terminou (usa o ponto real no fim).
  final bool completo;

  OpcoesTraco copyWith({
    double? tamanho,
    bool? completo,
    bool? simularPressao,
  }) => OpcoesTraco(
    tamanho: tamanho ?? this.tamanho,
    afinamento: afinamento,
    suavizacao: suavizacao,
    estabilizacao: estabilizacao,
    simularPressao: simularPressao ?? this.simularPressao,
    taperInicio: taperInicio,
    taperFim: taperFim,
    capInicio: capInicio,
    capFim: capFim,
    completo: completo ?? this.completo,
  );
}

/// Pontas do painel da caneta (tela 23) — Anexo 03 §9.3.
enum Ponta {
  esferografica(OpcoesTraco(afinamento: 0.1)),
  tinteiro(OpcoesTraco(afinamento: 0.6, taperFim: double.infinity)),
  pincel(OpcoesTraco(afinamento: 0.85, suavizacao: 0.5));

  const Ponta(this.opcoes);
  final OpcoesTraco opcoes;
}

/// D-28: 1 mm = 160 / 25,4 dp; Fina/Média/Grossa = 0,6× / 1× / 1,8×.
const dpPorMm = 160 / 25.4;

class PontoTraco {
  PontoTraco(
    this.ponto,
    this.pressao,
    this.vetor,
    this.distancia,
    this.comprimento,
  );
  final Vec ponto;
  final double pressao;
  Vec vetor;
  final double distancia;
  final double comprimento;
}

// Constantes do perfect-freehand.
const _taxaPressao = 0.275;
const _piFixo = math.pi + 0.0001;
const _segInicio = 13;
const _segFim = 29;
const _segCanto = 13;
const _ruidoFim = 3.0;
const _minT = 0.15;
const _faixaT = 0.85;
const _raioMin = 0.01;
const _pressaoPrimeiro = 0.25;
const _pressaoPadrao = 0.5;

Vec _add(Vec a, Vec b) => (a.$1 + b.$1, a.$2 + b.$2);
Vec _sub(Vec a, Vec b) => (a.$1 - b.$1, a.$2 - b.$2);
Vec _mul(Vec a, double n) => (a.$1 * n, a.$2 * n);
Vec _per(Vec a) => (a.$2, -a.$1);
Vec _neg(Vec a) => (-a.$1, -a.$2);
double _dpr(Vec a, Vec b) => a.$1 * b.$1 + a.$2 * b.$2;
double _len(Vec a) => math.sqrt(a.$1 * a.$1 + a.$2 * a.$2);
Vec _uni(Vec a) {
  final l = _len(a);
  return (a.$1 / l, a.$2 / l);
}

double _dist(Vec a, Vec b) => _len(_sub(a, b));
double _dist2(Vec a, Vec b) {
  final d = _sub(a, b);
  return d.$1 * d.$1 + d.$2 * d.$2;
}

Vec _lrp(Vec a, Vec b, double t) => _add(a, _mul(_sub(b, a), t));
Vec _prj(Vec a, Vec b, double c) => _add(a, _mul(b, c));
Vec _rot(Vec a, Vec c, double r) {
  final s = math.sin(r);
  final co = math.cos(r);
  final px = a.$1 - c.$1;
  final py = a.$2 - c.$2;
  return (px * co - py * s + c.$1, px * s + py * co + c.$2);
}

double _simular(double anterior, double distancia, double tamanho) {
  final sp = math.min(1.0, distancia / tamanho);
  final rp = math.min(1.0, 1 - sp);
  return math.min(1.0, anterior + (rp - anterior) * (sp * _taxaPressao));
}

double _raio(double tamanho, double afinamento, double pressao) =>
    tamanho * (0.5 - afinamento * (0.5 - pressao));

/// getStrokePoints. [entrada] = (x, y, pressão ou null).
List<PontoTraco> pontosDoTraco(
  List<(double, double, double?)> entrada,
  OpcoesTraco o,
) {
  if (entrada.isEmpty) return [];
  final t = _minT + (1 - o.estabilizacao) * _faixaT;
  var pts = [...entrada];
  if (pts.length == 2) {
    final ultimo = pts[1];
    pts = [pts[0]];
    for (var i = 1; i < 5; i++) {
      // Como no JS: o lrp só devolve (x, y) — a pressão dos pontos inseridos fica "sem valor".
      final p = _lrp((pts[0].$1, pts[0].$2), (ultimo.$1, ultimo.$2), i / 4);
      pts.add((p.$1, p.$2, null));
    }
  }
  if (pts.length == 1) {
    pts = [...pts, (pts[0].$1 + 1, pts[0].$2 + 1, pts[0].$3)];
  }
  bool valida(double? p) => p != null && p >= 0;
  final saida = <PontoTraco>[
    PontoTraco(
      (pts[0].$1, pts[0].$2),
      valida(pts[0].$3) ? pts[0].$3! : _pressaoPrimeiro,
      (1, 1),
      0,
      0,
    ),
  ];
  var atingiuMinimo = false;
  var comprimento = 0.0;
  var anterior = saida[0];
  final max = pts.length - 1;
  for (var i = 1; i < pts.length; i++) {
    final Vec ponto = o.completo && i == max
        ? (pts[i].$1, pts[i].$2)
        : _lrp(anterior.ponto, (pts[i].$1, pts[i].$2), t);
    if (ponto.$1 == anterior.ponto.$1 && ponto.$2 == anterior.ponto.$2) {
      continue;
    }
    final distancia = _dist(ponto, anterior.ponto);
    comprimento += distancia;
    if (i < max && !atingiuMinimo) {
      if (comprimento < o.tamanho) continue;
      atingiuMinimo = true;
    }
    anterior = PontoTraco(
      ponto,
      valida(pts[i].$3) ? pts[i].$3! : _pressaoPadrao,
      _uni(_sub(anterior.ponto, ponto)),
      distancia,
      comprimento,
    );
    saida.add(anterior);
  }
  saida[0].vetor = saida.length > 1 ? saida[1].vetor : (0, 0);
  return saida;
}

/// getStrokeOutlinePoints: polígono do contorno.
List<Vec> contornoDoTraco(List<PontoTraco> pontos, OpcoesTraco o) {
  final tamanho = o.tamanho;
  if (pontos.isEmpty || tamanho <= 0) return [];
  final total = pontos.last.comprimento;
  final taperInicio = o.taperInicio == double.infinity
      ? math.max(tamanho, total)
      : o.taperInicio;
  final taperFim = o.taperFim == double.infinity
      ? math.max(tamanho, total)
      : o.taperFim;
  final minDist = math.pow(tamanho * o.suavizacao, 2);
  final esq = <Vec>[];
  final dir = <Vec>[];

  var pressaoAnterior = pontos.take(10).fold<double>(pontos[0].pressao, (
    acc,
    c,
  ) {
    var p = c.pressao;
    if (o.simularPressao) p = _simular(acc, c.distancia, tamanho);
    return (acc + p) / 2;
  });
  var raio = _raio(tamanho, o.afinamento, pontos.last.pressao);
  double? primeiroRaio;
  var vetorAnterior = pontos[0].vetor;
  var esqAnterior = pontos[0].ponto;
  var dirAnterior = esqAnterior;
  var esqTemp = esqAnterior;
  var dirTemp = dirAnterior;
  var cantoAnterior = false;

  for (var i = 0; i < pontos.length; i++) {
    var pressao = pontos[i].pressao;
    final ponto = pontos[i].ponto;
    final vetor = pontos[i].vetor;
    final distancia = pontos[i].distancia;
    final comp = pontos[i].comprimento;
    final ultimo = i == pontos.length - 1;
    if (!ultimo && total - comp < _ruidoFim) continue;

    if (o.afinamento != 0) {
      if (o.simularPressao) {
        pressao = _simular(pressaoAnterior, distancia, tamanho);
      }
      raio = _raio(tamanho, o.afinamento, pressao);
    } else {
      raio = tamanho / 2;
    }
    primeiroRaio ??= raio;

    final fIni = comp < taperInicio ? _easeInicio(comp / taperInicio) : 1.0;
    final fFim = total - comp < taperFim
        ? _easeFim((total - comp) / taperFim)
        : 1.0;
    raio = math.max(_raioMin, raio * math.min(fIni, fFim));

    final vetorProx = (!ultimo ? pontos[i + 1] : pontos[i]).vetor;
    final dprProx = !ultimo ? _dpr(vetor, vetorProx) : 1.0;
    final dprAnt = _dpr(vetor, vetorAnterior);
    final canto = dprAnt < 0 && !cantoAnterior;
    final cantoProx = dprProx < 0;

    if (canto || cantoProx) {
      final off = _mul(_per(vetorAnterior), raio);
      const passo = 1 / _segCanto;
      for (var t = 0.0; t <= 1; t += passo) {
        esqTemp = _rot(_sub(ponto, off), ponto, _piFixo * t);
        esq.add(esqTemp);
        dirTemp = _rot(_add(ponto, off), ponto, _piFixo * -t);
        dir.add(dirTemp);
      }
      esqAnterior = esqTemp;
      dirAnterior = dirTemp;
      if (cantoProx) cantoAnterior = true;
      continue;
    }
    cantoAnterior = false;

    if (ultimo) {
      final off = _mul(_per(vetor), raio);
      esq.add(_sub(ponto, off));
      dir.add(_add(ponto, off));
      continue;
    }

    final off = _mul(_per(_lrp(vetorProx, vetor, dprProx)), raio);
    esqTemp = _sub(ponto, off);
    if (i <= 1 || _dist2(esqAnterior, esqTemp) > minDist) {
      esq.add(esqTemp);
      esqAnterior = esqTemp;
    }
    dirTemp = _add(ponto, off);
    if (i <= 1 || _dist2(dirAnterior, dirTemp) > minDist) {
      dir.add(dirTemp);
      dirAnterior = dirTemp;
    }
    pressaoAnterior = pressao;
    vetorAnterior = vetor;
  }

  final primeiro = (pontos[0].ponto.$1, pontos[0].ponto.$2);
  final Vec ultimoPonto = pontos.length > 1
      ? (pontos.last.ponto.$1, pontos.last.ponto.$2)
      : _add(pontos[0].ponto, (1, 1));
  final capIni = <Vec>[];
  final capFim = <Vec>[];

  if (pontos.length == 1) {
    if (!(taperInicio != 0 || taperFim != 0) || o.completo) {
      return _ponto(primeiro, primeiroRaio ?? raio);
    }
  } else {
    if (taperInicio != 0 || (taperFim != 0 && pontos.length == 1)) {
      // início afunilado
    } else if (o.capInicio) {
      const passo = 1 / _segInicio;
      for (var t = passo; t <= 1; t += passo) {
        capIni.add(_rot(dir[0], primeiro, _piFixo * t));
      }
    } else {
      final cv = _sub(esq[0], dir[0]);
      final a = _mul(cv, 0.5);
      final b = _mul(cv, 0.51);
      capIni.addAll([
        _sub(primeiro, a),
        _sub(primeiro, b),
        _add(primeiro, b),
        _add(primeiro, a),
      ]);
    }
    final direcao = _per(_neg(pontos.last.vetor));
    if (taperFim != 0 || (taperInicio != 0 && pontos.length == 1)) {
      capFim.add(ultimoPonto);
    } else if (o.capFim) {
      final ini = _prj(ultimoPonto, direcao, raio);
      const passo = 1 / _segFim;
      for (var t = passo; t < 1; t += passo) {
        capFim.add(_rot(ini, ultimoPonto, _piFixo * 3 * t));
      }
    } else {
      capFim.addAll([
        _add(ultimoPonto, _mul(direcao, raio)),
        _add(ultimoPonto, _mul(direcao, raio * 0.99)),
        _sub(ultimoPonto, _mul(direcao, raio * 0.99)),
        _sub(ultimoPonto, _mul(direcao, raio)),
      ]);
    }
  }
  return [...esq, ...capFim, ...dir.reversed, ...capIni];
}

double _easeInicio(double t) => t * (2 - t);
double _easeFim(double t) {
  final u = t - 1;
  return u * u * u + 1;
}

List<Vec> _ponto(Vec centro, double raio) {
  final off = _add(centro, (1, 1));
  final ini = _prj(centro, _uni(_per(_sub(centro, off))), -raio);
  final pts = <Vec>[];
  const passo = 1 / _segInicio;
  for (var t = passo; t <= 1; t += passo) {
    pts.add(_rot(ini, centro, _piFixo * 2 * t));
  }
  return pts;
}

/// getStroke.
List<Vec> contorno(List<(double, double, double?)> entrada, OpcoesTraco o) =>
    contornoDoTraco(pontosDoTraco(entrada, o), o);
