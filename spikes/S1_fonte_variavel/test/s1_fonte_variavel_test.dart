// G02 · S1 — Literata variável com FontVariation('opsz') × estática por tamanho × Chromium.
//
// Referência: dados/linhas_chromium.json (ferramentas/medir_chromium.js) — cada linha da amostra
// de Dom Casmurro (caps. XXXII–XXXIII) nos 7 tamanhos do leitor (D-20), quebrada a 334 px como o
// navegador quebra, com a largura isolada medida a zoom 100.
// Aqui: a mesma linha medida no SkParagraph do Flutter (o mesmo motor do app) com
//   vf_opsz     Literata-VF.ttf + FontVariation('opsz', tamanho) + FontVariation('wght', 400)
//   vf_sem_opsz Literata-VF.ttf sem variações (opsz padrão 12) — mostra por que o opsz é obrigatório
//   estatica    instância estática do tamanho, quando existe (16 · 20,5 · 26 — as da G01.7)
// e as quebras de cada parágrafo (recuo 1,3 em como PlaceholderSpan) comparadas com as do Chromium.
// Saída: dados/resultado_flutter.json + resumo impresso. Gate da D-17: vf_opsz ≤ 0,05 px por linha
// e as mesmas quebras em todos os tamanhos.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _fontes = <String, String>{
  'S1VF': '../../assets/fonts/Literata-VF.ttf',
  'S1E16': '../../assets/fonts/Literata16-Regular.ttf',
  'S1E20_5': '../../assets/fonts/Literata20_5-Regular.ttf',
  'S1E26': '../../assets/fonts/Literata26-Regular.ttf',
};

final _estaticas = <double, String>{16: 'S1E16', 20.5: 'S1E20_5', 26: 'S1E26'};

const _gateDesvio = 0.05;

Future<void> _carregar(String familia, String caminho) async {
  final bytes = File(caminho).readAsBytesSync();
  final loader = FontLoader(familia)
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}

ui.TextStyle _estilo(
  String familia,
  double s,
  List<ui.FontVariation>? v, [
  ui.FontWeight peso = ui.FontWeight.w400,
]) => ui.TextStyle(
  fontFamily: familia,
  fontSize: s,
  fontWeight: peso,
  fontVariations: v,
  color: const ui.Color(0xFF2A2520),
);

List<ui.FontVariation> _opsz(double s, [double peso = 400]) => [
  ui.FontVariation('opsz', s),
  ui.FontVariation('wght', peso),
];

double _largura(String texto, ui.TextStyle estilo) {
  final b =
      ui.ParagraphBuilder(
          ui.ParagraphStyle(textDirection: ui.TextDirection.ltr, maxLines: 1),
        )
        ..pushStyle(estilo)
        ..addText(texto);
  final p = b.build()
    ..layout(const ui.ParagraphConstraints(width: double.infinity));
  final w = p.maxIntrinsicWidth;
  p.dispose();
  return w;
}

/// Quebras do parágrafo a [largura] px com o recuo de 1,3 em como placeholder (1 unidade U+FFFC).
List<String> _quebras(String texto, double s, double largura) {
  final b =
      ui.ParagraphBuilder(
          ui.ParagraphStyle(
            textDirection: ui.TextDirection.ltr,
            textAlign: ui.TextAlign.left,
          ),
        )
        ..pushStyle(_estilo('S1VF', s, _opsz(s)))
        ..addPlaceholder(
          1.3 * s,
          0,
          ui.PlaceholderAlignment.baseline,
          baseline: ui.TextBaseline.alphabetic,
        )
        ..addText(texto);
  final p = b.build()..layout(ui.ParagraphConstraints(width: largura));
  final linhas = <int, StringBuffer>{};
  for (var i = 0; i < texto.length; i++) {
    final n = p.getLineNumberAt(i + 1)!; // +1: o placeholder ocupa o offset 0
    linhas.putIfAbsent(n, StringBuffer.new).write(texto[i]);
  }
  p.dispose();
  final ns = linhas.keys.toList()..sort();
  return [for (final n in ns) linhas[n].toString().trimRight()];
}

double _r(double v) => (v * 1e5).roundToDouble() / 1e5;

Map<String, Object> _estat(List<double> d) {
  final abs = d.map((e) => e.abs()).toList()..sort();
  final p95 = abs[math.min(abs.length - 1, (abs.length * 0.95).ceil() - 1)];
  return {
    'linhas': d.length,
    'max': _r(abs.last),
    'p95': _r(p95),
    'media_abs': _r(abs.reduce((a, b) => a + b) / abs.length),
    'media_com_sinal': _r(d.reduce((a, b) => a + b) / d.length),
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final ref = jsonDecode(
    File('dados/linhas_chromium.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final amostra = jsonDecode(
    File('dados/amostra.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final paragrafos = (amostra['paragrafos'] as List).cast<String>();
  final tamanhos = (ref['tamanhos'] as Map<String, dynamic>);
  final largura = (ref['largura'] as num).toDouble();
  final resultado = <String, Object>{
    'referencia': 'dados/linhas_chromium.json (${ref['chromium']})',
    'flutter': Platform.version,
    'gate_desvio_px': _gateDesvio,
    'tamanhos': <String, Object>{},
  };

  setUpAll(() async {
    for (final MapEntry(key: f, value: c) in _fontes.entries) {
      await _carregar(f, c);
    }
  });

  tearDownAll(() {
    File(
      'dados/resultado_flutter.json',
    ).writeAsStringSync(const JsonEncoder.withIndent(' ').convert(resultado));
  });

  final ordem = tamanhos.keys.map(double.parse).toList()..sort();
  for (final s in ordem) {
    final chave = tamanhos.keys.firstWhere((k) => double.parse(k) == s);
    test('Literata ${s}px: larguras e quebras × Chromium', () {
      final linhas = ((tamanhos[chave] as Map)['linhas'] as List)
          .cast<Map<String, dynamic>>();
      final variantes = <String, ui.TextStyle>{
        'vf_opsz': _estilo('S1VF', s, _opsz(s)),
        'vf_sem_opsz': _estilo('S1VF', s, null),
        if (_estaticas[s] != null) 'estatica': _estilo(_estaticas[s]!, s, null),
      };
      final desvios = {for (final v in variantes.keys) v: <double>[]};
      final porLinha = <Map<String, Object>>[];
      for (final l in linhas) {
        final t = l['texto'] as String;
        final cr = (l['largura'] as num).toDouble();
        final item = <String, Object>{'texto': t, 'chromium': cr};
        for (final MapEntry(key: v, value: e) in variantes.entries) {
          final w = _largura(t, e);
          desvios[v]!.add(w - cr);
          item[v] = _r(w - cr);
        }
        porLinha.add(item);
      }
      // Quebras: parágrafo por parágrafo, com vf_opsz.
      final chromiumPorPar = <int, List<String>>{};
      for (final l in linhas) {
        chromiumPorPar
            .putIfAbsent(l['p'] as int, () => [])
            .add(l['texto'] as String);
      }
      var iguais = 0;
      var total = 0;
      final diferentes = <Map<String, Object>>[];
      for (final MapEntry(key: ip, value: esperado) in chromiumPorPar.entries) {
        final obtido = _quebras(paragrafos[ip], s, largura);
        for (var i = 0; i < math.max(esperado.length, obtido.length); i++) {
          total++;
          final a = i < esperado.length ? esperado[i] : '∅';
          final b = i < obtido.length ? obtido[i] : '∅';
          if (a == b) {
            iguais++;
          } else {
            diferentes.add({'p': ip, 'linha': i, 'chromium': a, 'flutter': b});
          }
        }
      }
      final est = {for (final v in variantes.keys) v: _estat(desvios[v]!)};
      (resultado['tamanhos'] as Map<String, Object>)[chave] = {
        'desvio_largura': est,
        'quebras': {
          'linhas': total,
          'iguais': iguais,
          'diferentes': diferentes,
        },
        'por_linha': porLinha,
      };
      print(
        'S1 ${s.toString().padLeft(4)} px · ${linhas.length} linhas · '
        '${est.entries.map((e) => '${e.key} máx ${(e.value['max'] as double).toStringAsFixed(4)}').join(' · ')}'
        ' · quebras $iguais/$total',
      );
      expect(est['vf_opsz']!['max'] as double, lessThanOrEqualTo(_gateDesvio));
      expect(diferentes, isEmpty);
    });
  }

  // As 259 linhas em Literata das 13 pranchas (G01.7): tamanhos da interface (15–26) e wght 500.
  test('Literata nas pranchas 19–27b (wght 400/500, 15–26 px) × Chromium', () {
    final g01 = jsonDecode(
      File('dados/linhas_pranchas_g01.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final linhas = (g01['linhas'] as List).cast<Map<String, dynamic>>();
    final desvios = <double>[];
    final porGrupo = <String, List<double>>{};
    final piores = <Map<String, Object>>[];
    for (final l in linhas) {
      final s = (l['tamanho'] as num).toDouble();
      final peso = (l['peso'] as num).toDouble();
      final w = _largura(
        l['texto'] as String,
        _estilo(
          'S1VF',
          s,
          _opsz(s, peso),
          peso == 500 ? ui.FontWeight.w500 : ui.FontWeight.w400,
        ),
      );
      final d = w - (l['chromium'] as num).toDouble();
      desvios.add(d);
      porGrupo.putIfAbsent('${s}px/${peso.toInt()}', () => []).add(d);
      if (d.abs() > 0.02) {
        piores.add({
          'id': l['id'] as String,
          'texto': l['texto'] as String,
          'desvio': _r(d),
        });
      }
    }
    final est = _estat(desvios);
    resultado['pranchas_g01'] = {
      'observacao': 'Chromium com 2 casas decimais (arredondamento ±0,005 px)',
      'geral': est,
      'por_tamanho_peso': {
        for (final MapEntry(key: k, value: v) in porGrupo.entries) k: _estat(v),
      },
      'acima_de_0_02': piores,
    };
    print(
      'S1 pranchas G01 · ${linhas.length} linhas · vf_opsz máx '
      '${(est['max'] as double).toStringAsFixed(4)} · '
      '${porGrupo.keys.length} combinações tamanho/peso',
    );
    expect(est['max'] as double, lessThanOrEqualTo(_gateDesvio));
  });
}
