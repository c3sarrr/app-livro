// G02 · S4 — codec BNK1: ida e volta, erros, compatibilidade de versão e tamanho.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:spike_s4_tinta/bnk1.dart';
import 'package:spike_s4_tinta/simulador.dart';

Traco _aleatorio(math.Random r) {
  final n = r.nextInt(300);
  var t = 0;
  var x = (r.nextDouble() - 0.5) * 200;
  var y = (r.nextDouble() - 0.5) * 200;
  return Traco(
    ferramenta: r.nextInt(6),
    ponta: r.nextInt(3),
    argb: r.nextInt(1 << 32),
    larguraCentesimosMm: r.nextInt(0x10000),
    pontos: [
      for (var i = 0; i < n; i++)
        PontoTinta(
          x += (r.nextDouble() - 0.5) * (i % 50 == 0 ? 400 : 4),
          y += (r.nextDouble() - 0.5) * (i % 50 == 0 ? 400 : 4),
          r.nextDouble(),
          t += r.nextInt(i % 70 == 0 ? 5000 : 20),
        ),
    ],
  );
}

void _confere(List<Traco> a, List<Traco> b, UnidadeCamada u) {
  expect(b.length, a.length);
  for (var k = 0; k < a.length; k++) {
    expect(b[k].ferramenta, a[k].ferramenta);
    expect(b[k].ponta, a[k].ponta);
    expect(b[k].argb, a[k].argb);
    expect(b[k].larguraCentesimosMm, a[k].larguraCentesimosMm);
    expect(b[k].pontos.length, a[k].pontos.length);
    for (var i = 0; i < a[k].pontos.length; i++) {
      final p = a[k].pontos[i];
      final q = b[k].pontos[i];
      expect((p.x - q.x).abs(), lessThanOrEqualTo(0.5 / u.escala + 1e-12));
      expect((p.y - q.y).abs(), lessThanOrEqualTo(0.5 / u.escala + 1e-12));
      expect(
        (p.pressao - q.pressao).abs(),
        lessThanOrEqualTo(0.5 / 255 + 1e-12),
      );
      expect(q.tMs, p.tMs);
    }
  }
}

void main() {
  final resultado = <String, Object>{};
  tearDownAll(() {
    Directory('dados').createSync(recursive: true);
    File(
      'dados/resultado_bnk1.json',
    ).writeAsStringSync(const JsonEncoder.withIndent(' ').convert(resultado));
  });

  test('ida e volta: 1.000 traços aleatórios nas duas unidades', () {
    final r = math.Random(20261003);
    var pontos = 0;
    for (final u in UnidadeCamada.values) {
      for (var lote = 0; lote < 50; lote++) {
        final tracos = List.generate(10, (_) => _aleatorio(r));
        pontos += tracos.fold(0, (s, t) => s + t.pontos.length);
        final bytes = codificarBnk1(tracos, u);
        final volta = decodificarBnk1(bytes, u);
        _confere(tracos, volta, u);
        // Idempotente: recodificar o que voltou dá os mesmos bytes.
        expect(codificarBnk1(volta, u), bytes);
      }
    }
    resultado['ida_e_volta'] = {'tracos': 1000, 'pontos': pontos};
  });

  test('camada vazia e traço sem pontos', () {
    final vazia = codificarBnk1([], UnidadeCamada.em);
    expect(vazia, [0x42, 0x4E, 0x4B, 0x31, 1, 0]);
    expect(decodificarBnk1(vazia, UnidadeCamada.em), isEmpty);
    const t = Traco(
      ferramenta: 1,
      ponta: 2,
      argb: 0x80FFD23F,
      larguraCentesimosMm: 65535,
      pontos: [],
    );
    final b = codificarBnk1([t], UnidadeCamada.caixa);
    final v = decodificarBnk1(b, UnidadeCamada.caixa).single;
    expect(v.argb, 0x80FFD23F);
    expect(v.larguraCentesimosMm, 65535);
    expect(v.pontos, isEmpty);
  });

  test('formato congelado da versão 1 (compatibilidade)', () {
    // Qualquer mudança nestes bytes quebra camadas já gravadas: exige versão 2 + migração.
    const t = Traco(
      ferramenta: 0,
      ponta: 1,
      argb: 0xFFE4572E,
      larguraCentesimosMm: 120,
      pontos: [
        PontoTinta(1.5, -0.25, 0.5, 0),
        PontoTinta(1.62, -0.2, 0.6, 8),
        PontoTinta(1.75, -0.1, 0.7, 16),
      ],
    );
    final hex = codificarBnk1([
      t,
    ], UnidadeCamada.em).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    expect(
      hex,
      '424e4b310101' // "BNK1", versão 1, 1 traço
      '0001e4572eff780003' // caneta, ponta 1, RGB, alpha, 1,20 mm, 3 pontos
      'ac02318000' // Δx +150 · Δy −25 · pressão 128 · Δt 0
      '180a9908' // Δx +12 · Δy +5 · 153 · 8 ms
      '1a14b308', // Δx +13 · Δy +10 · 179 (0,7 × 255 = 178,5 arredonda para cima) · 8 ms
    );
  });

  test('erros tipados: assinatura, versão, truncado, lixo, tempo voltando', () {
    final ok = codificarBnk1([
      tracoEmEm(tracoSintetico(math.Random(1), FormaTraco.manuscrito, 120)),
    ], UnidadeCamada.em);
    expect(
      () => decodificarBnk1(
        Uint8List.fromList([0x42, 0x4E, 0x4B, 0x32, 1, 0]),
        UnidadeCamada.em,
      ),
      throwsA(isA<AssinaturaInvalida>()),
    );
    final v2 = Uint8List.fromList(ok)..[4] = 2;
    expect(
      () => decodificarBnk1(v2, UnidadeCamada.em),
      throwsA(isA<VersaoDesconhecida>().having((e) => e.versao, 'versao', 2)),
    );
    var truncados = 0;
    for (var n = 0; n < ok.length; n++) {
      expect(
        () =>
            decodificarBnk1(Uint8List.sublistView(ok, 0, n), UnidadeCamada.em),
        throwsA(isA<FalhaBnk1>()),
      );
      truncados++;
    }
    expect(
      () => decodificarBnk1(Uint8List.fromList([...ok, 0]), UnidadeCamada.em),
      throwsA(isA<LixoNoFim>()),
    );
    expect(
      () => codificarBnk1(const [
        Traco(
          ferramenta: 0,
          ponta: 0,
          argb: 0,
          larguraCentesimosMm: 10,
          pontos: [PontoTinta(0, 0, 0, 10), PontoTinta(0, 0, 0, 5)],
        ),
      ], UnidadeCamada.em),
      throwsA(isA<ValorForaDaFaixa>()),
    );
    resultado['erros'] = {'prefixos_truncados_recusados': truncados};
  });

  test(
    'tamanho: bytes por 100 pontos de traços realistas e limite de 256 KiB',
    () {
      final porHz = <String, Object>{};
      for (final hz in [60.0, 120.0, 240.0]) {
        final r = math.Random(42);
        final taxas = <double>[];
        var bytesTotal = 0;
        var pontosTotal = 0;
        for (var i = 0; i < 300; i++) {
          final forma = FormaTraco.values[i % 3];
          final t = tracoEmEm(tracoSintetico(r, forma, hz));
          final b = codificarBnk1([t], UnidadeCamada.em);
          final semCabecalho =
              b.length - 6; // "BNK1" + versão + nº de traços (1 byte)
          taxas.add(100 * semCabecalho / t.pontos.length);
          bytesTotal += semCabecalho;
          pontosTotal += t.pontos.length;
        }
        taxas.sort();
        final media = 100 * bytesTotal / pontosTotal;
        // Quantos pontos cabem numa camada de 256 KiB com este perfil, e quanto tempo de escrita isso é.
        final pontosNoLimite = (limiteCamadaBytes * pontosTotal / bytesTotal)
            .floor();
        porHz['${hz.toInt()} Hz'] = {
          'bytes_por_100_pontos_media': double.parse(media.toStringAsFixed(1)),
          'p05': double.parse(taxas[15].toStringAsFixed(1)),
          'p95': double.parse(taxas[284].toStringAsFixed(1)),
          'pontos_em_256KiB': pontosNoLimite,
          'minutos_de_tinta_em_256KiB': double.parse(
            (pontosNoLimite / hz / 60).toStringAsFixed(1),
          ),
        };
        expect(media, lessThanOrEqualTo(450));
      }
      resultado['tamanho'] = porHz;
      print('S4 BNK1 tamanho: $porHz');
    },
  );
}
