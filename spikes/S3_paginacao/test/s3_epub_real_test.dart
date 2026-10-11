// G02 · S3 — desempenho e páginas de referência com o EPUB real de Dom Casmurro
// (Project Gutenberg #55752, domínio público; spikes/_dados/pg55752.epub, fora do git).
// Mede: leitura do EPUB → blocos; layout de cada bloco (custo por bloco = fatia possível);
// paginação; páginas por capítulo; e calibra o N das páginas de referência (D-19).
// Números do host (Windows, Ryzen 5 2600X, flutter test em JIT): o layout é nativo
// (SkParagraph), mas o aparelho de referência da G26 é mais lento — ver ADR-005.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spike_s3_paginacao/epub.dart';
import 'package:spike_s3_paginacao/paginador.dart';
import 'package:spike_s3_paginacao/paginas_referencia.dart';

import 'fontes.dart';

const _epub = '../_dados/pg55752.epub';
const _sha = '847b26bbc6bfefcf7cc323a94eacefd3c7a9657e66749cb360b77b34a3e994fd';
final _capitulo = RegExp(r'^[IVXLC]+$');
const _maxChars = 1200;

double _ms(int us) => us / 1000;

Map<String, Object> _resumo(List<int> us) {
  final s = [...us]..sort();
  double p(double q) => _ms(s[((s.length - 1) * q).round()]);
  return {
    'n': s.length,
    'total_ms': _ms(s.fold(0, (a, b) => a + b)),
    'p50_ms': p(0.5),
    'p95_ms': p(0.95),
    'p99_ms': p(0.99),
    'max_ms': _ms(s.last),
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final existe = File(_epub).existsSync();
  final resultado = <String, Object>{};

  setUpAll(carregarFontes);
  tearDownAll(() {
    if (resultado.isNotEmpty) {
      Directory('dados').createSync(recursive: true);
      File(
        'dados/resultado_epub_real.json',
      ).writeAsStringSync(const JsonEncoder.withIndent(' ').convert(resultado));
    }
  });

  test('EPUB real: leitura, layout, paginação e páginas de referência', () {
    final bytes = File(_epub).readAsBytesSync();
    expect(sha256.convert(bytes).toString(), _sha);

    final sw = Stopwatch()..start();
    final livro = lerEpub(bytes);
    final leituraUs = sw.elapsedMicroseconds;
    final blocos = [for (final it in livro.itens) ...it.blocos];
    resultado['livro'] = {
      'titulo': livro.titulo,
      'itens_spine': livro.itens.length,
      'blocos': blocos.length,
      'caracteres': livro.caracteres,
      'leitura_ms': _ms(leituraUs),
    };

    final porTamanho = <String, Object>{};
    for (final tamanho in [20.5, 16.0, 26.0]) {
      final t = Tipografia(tamanho: tamanho);
      // 2 rodadas: a 1ª inclui o aquecimento (cache de shaping/fontes); a 2ª é a de regime.
      late List<int> custos;
      late List<Pagina> paginas;
      late int paginarUs;
      late List<List<BlocoLayout>> porItem;
      late List<List<Pagina>> paginasPorItem;
      final rodadas = <Map<String, Object>>[];
      for (var rodada = 0; rodada < 2; rodada++) {
        custos = <int>[];
        porItem = [];
        for (final it in livro.itens) {
          final ls = <BlocoLayout>[];
          for (final b in it.blocos) {
            final s = Stopwatch()..start();
            ls.add(layoutBloco(b, t));
            custos.add(s.elapsedMicroseconds);
          }
          porItem.add(ls);
        }
        final sp = Stopwatch()..start();
        paginasPorItem = [for (final ls in porItem) paginar(ls, t)];
        paginarUs = sp.elapsedMicroseconds;
        paginas = [for (final ps in paginasPorItem) ...ps];
        rodadas.add({
          'layout': _resumo(custos),
          'paginacao_ms': _ms(paginarUs),
          'paginas': paginas.length,
        });
        if (rodada == 0) {
          for (final ls in porItem) {
            for (final b in ls) {
              b.dispose();
            }
          }
        }
      }
      final totalUs = custos.fold(0, (a, b) => a + b) + paginarUs;
      // Os blocos mais caros (para dimensionar as fatias de ≤ 4 ms).
      final ordem = List.generate(custos.length, (i) => i)
        ..sort((a, b) => custos[b].compareTo(custos[a]));
      final mais = [
        for (final i in ordem.take(8))
          {'caracteres': blocos[i].texto.length, 'ms': _ms(custos[i])},
      ];
      final acima4 = custos.where((c) => c > 4000).length;
      // Capítulos: do título com âncora romana até o próximo.
      final caps = <String, ({int paginas, int us})>{};
      String? atual;
      final usPorCap = <String, int>{};
      final paginasPorCap = <String, Set<String>>{};
      var k = 0;
      for (final (ii, ls) in porItem.indexed) {
        for (final (ib, b) in ls.indexed) {
          final anc = b.bloco.ancora;
          if (b.bloco.tipo == TipoBloco.titulo &&
              anc != null &&
              _capitulo.hasMatch(anc)) {
            atual = anc;
          }
          final c = atual ?? '(antes do cap. I)';
          usPorCap[c] = (usPorCap[c] ?? 0) + custos[k++];
          for (final (ip, pg) in paginasPorItem[ii].indexed) {
            if (pg.fatias.any((f) => f.bloco == ib)) {
              paginasPorCap.putIfAbsent(c, () => {}).add('$ii/$ip');
            }
          }
        }
      }
      for (final c in usPorCap.keys) {
        caps[c] = (paginas: paginasPorCap[c]?.length ?? 0, us: usPorCap[c]!);
      }
      final maior = caps.entries.reduce(
        (a, b) => a.value.paginas >= b.value.paginas ? a : b,
      );
      final msPorPagina = _ms(totalUs) / paginas.length;
      porTamanho['$tamanho'] = {
        'rodadas': rodadas,
        'paginas': paginas.length,
        'total_ms': _ms(totalUs),
        'ms_por_pagina': msPorPagina,
        'capitulo_40_paginas_estimado_ms': msPorPagina * 40,
        'maior_capitulo': {
          'capitulo': maior.key,
          'paginas': maior.value.paginas,
          'ms': _ms(maior.value.us),
        },
        'capitulos': caps.length,
        'blocos_mais_caros': mais,
        'blocos_acima_de_4ms': acima4,
      };
      print(
        'S3 EPUB real ${tamanho}px · ${paginas.length} págs · layout+paginação '
        '${_ms(totalUs).toStringAsFixed(1)} ms (${msPorPagina.toStringAsFixed(3)} ms/pág; '
        '40 págs ≈ ${(msPorPagina * 40).toStringAsFixed(1)} ms) · bloco máx '
        '${(rodadas[1]['layout'] as Map)['max_ms']} ms · p99 '
        '${(rodadas[1]['layout'] as Map)['p99_ms']} ms · maior cap. ${maior.key} '
        '(${maior.value.paginas} págs, ${_ms(maior.value.us).toStringAsFixed(1)} ms)',
      );
      // Orçamento do Anexo 03 §12 (no host): capítulo de 40 páginas < 120 ms, fatias ≤ 4 ms.
      expect(msPorPagina * 40, lessThan(120));
      // Parágrafos longos: layout em pedaços costurados na última linha (ver paginador.dart).
      if (tamanho == 20.5) {
        var maxPedacoUs = 0;
        var longos = 0;
        var pedacos = 0;
        var linhasConferidas = 0;
        for (final ls in porItem) {
          for (final b in ls) {
            if (b.bloco.texto.length <= _maxChars) continue;
            longos++;
            final r = layoutEmPedacos(b.bloco, t, _maxChars);
            pedacos += r.pedacos;
            maxPedacoUs = r.custosUs.fold(maxPedacoUs, (a, c) => a > c ? a : c);
            final inteiro = [
              for (var l = 0; l < b.linhas.length; l++)
                l == 0 ? 0 : b.inicioDaLinha(l) - (b.bloco.recuo ? 1 : 0),
            ];
            expect(r.inicios, inteiro, reason: b.bloco.texto.substring(0, 40));
            linhasConferidas += inteiro.length;
          }
        }
        porTamanho['pedacos'] = {
          'max_chars': _maxChars,
          'paragrafos_longos': longos,
          'pedacos': pedacos,
          'linhas_iguais_ao_layout_inteiro': linhasConferidas,
          'pedaco_mais_caro_ms': _ms(maxPedacoUs),
        };
        print(
          'S3 pedaços (> $_maxChars car.): $longos parágrafos, $pedacos pedaços, '
          '$linhasConferidas linhas idênticas ao layout inteiro, pedaço máx '
          '${_ms(maxPedacoUs)} ms',
        );
        expect(maxPedacoUs, lessThan(4000));
      }
      for (final ls in porItem) {
        for (final b in ls) {
          b.dispose();
        }
      }
    }
    resultado['por_tamanho'] = porTamanho;

    // Páginas de referência (D-19): texto canônico global = itens unidos por '\n'.
    final global = livro.itens.map((i) => i.texto).join('\n');
    final ini = global.indexOf('DOM CASMURRO');
    final fim = global.indexOf('*** END OF THE PROJECT GUTENBERG');
    final soLivro = global.substring(ini, fim);
    final cap32 = global.indexOf('Tudo era materia ás curiosidades de Capitú');
    final ref = <String, Object>{};
    for (final n in [1500, 1467, 1542]) {
      final todo = PaginasReferencia.calcular(global, n);
      final livroSo = PaginasReferencia.calcular(soLivro, n);
      ref['N=$n'] = {
        'paginas_epub_inteiro': todo.paginas,
        'paginas_so_o_livro': livroSo.paginas,
        'pagina_do_cap_XXXII': todo.paginaDe(cap32),
      };
    }
    ref['caracteres_epub_inteiro'] = global.length;
    ref['caracteres_so_o_livro'] = soLivro.length;
    ref['N_para_256_so_o_livro'] = (soLivro.length / 256).round();
    ref['N_para_256_epub_inteiro'] = (global.length / 256).round();
    resultado['paginas_referencia'] = ref;
    print('S3 páginas de referência: $ref');
    final p1500 = PaginasReferencia.calcular(soLivro, 1500).paginas;
    expect(p1500, inInclusiveRange(240, 272)); // ≈ 256 ± 6 %
  }, skip: existe ? false : 'baixe o EPUB real (spikes/README.md)');
}
