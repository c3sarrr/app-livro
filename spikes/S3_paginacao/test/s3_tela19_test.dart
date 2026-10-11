// G02 · S3 — gate de fidelidade da paginação (Anexo 03 §7.2): um EPUB de fixture com o texto
// EXATO da tela 19, paginado no estado padrão (390×844, Literata 20,5, Médio 1,72, Média 28),
// dá as mesmas 19 linhas da tela 19, com baselines ±0,5 px da medição da G01.
// Compara as duas regras de altura de linha: exata (20,5 × 1,72 = 35,26) e arredondada a 1/64 px
// (35,25 — o que o Chromium faz a zoom 1 e fator de escala 1).
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spike_s3_paginacao/epub.dart';
import 'package:spike_s3_paginacao/paginador.dart';

import 'fontes.dart';

const _gate = 0.5;

/// EPUB 3 mínimo com o parágrafo do cap. XXXII exatamente como no arquivo de design.
/// O item começa no parágrafo (como os itens "partidos" do EPUB do Gutenberg), então ele abre
/// a página — é a página da tela 19.
Uint8List fixtureEpub(String paragrafo) {
  String esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
  final arq = Archive()
    ..addFile(ArchiveFile.string('mimetype', 'application/epub+zip'))
    ..addFile(
      ArchiveFile.string(
        'META-INF/container.xml',
        '<?xml version="1.0"?><container version="1.0" '
            'xmlns="urn:oasis:names:tc:opendocument:xmlns:container"><rootfiles>'
            '<rootfile full-path="OEBPS/content.opf" '
            'media-type="application/oebps-package+xml"/></rootfiles></container>',
      ),
    )
    ..addFile(
      ArchiveFile.string(
        'OEBPS/content.opf',
        '<?xml version="1.0" encoding="UTF-8"?><package xmlns="http://www.idpf.org/2007/opf" '
            'version="3.0" unique-identifier="id"><metadata '
            'xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:identifier id="id">fixture-tela19'
            '</dc:identifier><dc:title>Dom Casmurro</dc:title><dc:language>pt-BR</dc:language>'
            '</metadata><manifest><item id="c32b" href="cap32b.xhtml" '
            'media-type="application/xhtml+xml"/></manifest><spine><itemref idref="c32b"/>'
            '</spine></package>',
      ),
    )
    ..addFile(
      ArchiveFile.string(
        'OEBPS/cap32b.xhtml',
        '<?xml version="1.0" encoding="UTF-8"?><html xmlns="http://www.w3.org/1999/xhtml">'
            '<head><title>XXXII</title></head><body>\n<p>${esc(paragrafo)}</p>\n</body></html>',
      ),
    );
  return ZipEncoder().encodeBytes(arq);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final layout = jsonDecode(
    File('../../handoff_v2/referencia/layout/layout_19_leitor_limpo.json')
        .readAsStringSync(),
  ) as Map<String, dynamic>;
  final texto =
      ((layout['elements'] as Map)['r19.page.text'] as Map<String, dynamic>);
  final refLinhas = (texto['lines'] as List).cast<Map<String, dynamic>>();
  final knife =
      ((jsonDecode(
                File('../../handoff_v2/referencia/layout/knife_edges.json')
                    .readAsStringSync(),
              ) as Map)['19_leitor_limpo']
              as Map)['r19.page.text']
          as Map<String, dynamic>;
  final resultado = <String, Object>{};

  setUpAll(carregarFontes);
  tearDownAll(() {
    Directory('dados').createSync(recursive: true);
    File(
      'dados/resultado_tela19.json',
    ).writeAsStringSync(const JsonEncoder.withIndent(' ').convert(resultado));
  });

  test('fixture: o EPUB tem 1 item com 1 parágrafo = texto do arquivo', () {
    final livro = lerEpub(fixtureEpub(texto['text'] as String));
    expect(livro.itens, hasLength(1));
    expect(livro.itens.single.blocos.single.texto, texto['text']);
    expect(livro.itens.single.texto, texto['text']);
  });

  for (final arredondar in [false, true]) {
    final nome = arredondar ? 'arredondada_1_64' : 'exata';
    test('tela 19 · altura de linha $nome: 19 linhas iguais e baselines ±0,5', () {
      final t = Tipografia(arredondar64: arredondar);
      final item = lerEpub(fixtureEpub(texto['text'] as String)).itens.single;
      final bl = item.blocos.map((b) => layoutBloco(b, t)).toList();
      final paginas = paginar(bl, t);
      final b = bl.single;

      // Página 1 = 19 linhas (0…18); página 2 = as 3 restantes (19…21) no topo.
      expect(paginas, hasLength(2));
      expect(paginas[0].fatias.single.primeira, 0);
      expect(paginas[0].fatias.single.ultima, 18);
      expect(paginas[1].fatias.single.primeira, 19);
      expect(paginas[1].fatias.single.ultima, 21);

      final linhas = <Map<String, Object>>[];
      var maxBase = 0.0;
      var maxBaseSk = 0.0;
      var maxDir = 0.0;
      for (final (ip, pg) in paginas.indexed) {
        final f = pg.fatias.single;
        for (var l = f.primeira; l <= f.ultima; l++) {
          // Texto canônico da linha (o helper desconta o U+FFFC do recuo).
          final ini = b.inicioDaLinha(l);
          final fim = l + 1 < b.linhas.length
              ? b.inicioDaLinha(l + 1)
              : item.blocos.single.texto.length + 1;
          final c0 = b.offsetCanonico(ini == 0 ? 1 : ini);
          final c1 = b.offsetCanonico(fim);
          final txt = item.texto.substring(c0, c1).trimRight();
          // Vertical: a linha l da página ip ocupa a posição da linha de referência l − 19·ip
          // (a página 2 começa no topo); horizontal e texto: a própria linha l.
          final refPos = refLinhas[l - 19 * ip];
          final ref = refLinhas[l];
          // Modelo exato (o que o paginador usa e pinta) e o que o SkParagraph daria sozinho.
          final baseline = t.topo + f.y + (b.baseline(l) - b.topo(f.primeira));
          final lm0 = b.linhas[f.primeira];
          final baselineSk =
              t.topo +
              f.y +
              (b.linhas[l].baseline - (lm0.baseline - lm0.ascent));
          // Borda direita do último glifo visível.
          final caixas = b.paragrafo.getBoxesForRange(
            b.offsetParagrafo(c0),
            b.offsetParagrafo(c0 + txt.length),
          );
          final direita =
              t.margem +
              caixas.map((c) => c.right).reduce((a, c) => a > c ? a : c);
          final esquerda =
              t.margem +
              caixas.map((c) => c.left).reduce((a, c) => a < c ? a : c);
          final dBase = baseline - (refPos['baseline'] as num).toDouble();
          final dBaseSk = baselineSk - (refPos['baseline'] as num).toDouble();
          maxBaseSk = dBaseSk.abs() > maxBaseSk ? dBaseSk.abs() : maxBaseSk;
          final dDir = direita - (ref['right'] as num).toDouble();
          maxBase = dBase.abs() > maxBase ? dBase.abs() : maxBase;
          maxDir = dDir.abs() > maxDir ? dDir.abs() : maxDir;
          linhas.add({
            'pagina': ip + 1,
            'linha': l + 1,
            'texto': txt,
            'igual': txt == ref['text'],
            'baseline': double.parse(baseline.toStringAsFixed(4)),
            'dBaseline': double.parse(dBase.toStringAsFixed(4)),
            'dBaselineSkParagraph': double.parse(dBaseSk.toStringAsFixed(4)),
            'esquerda': double.parse(esquerda.toStringAsFixed(4)),
            'direita': double.parse(direita.toStringAsFixed(4)),
            'dDireita': double.parse(dDir.toStringAsFixed(4)),
          });
          expect(txt, ref['text'], reason: 'linha ${l + 1}');
        }
      }
      // Recuo: 1º glifo da linha 1 em 28 + 1,3 em = 54,65.
      expect(
        (linhas.first['esquerda']! as double) - refLinhas.first['left'],
        closeTo(0, _gate),
      );
      resultado[nome] = {
        'altura_linha': t.alturaLinha,
        'linhas_iguais': linhas.where((l) => l['igual'] == true).length,
        'max_desvio_baseline': maxBase,
        'max_desvio_baseline_skparagraph_sozinho': maxBaseSk,
        'passo_linha_skparagraph': b.linhas[1].baseline - b.linhas[0].baseline,
        'max_desvio_borda_direita': maxDir,
        'altura_19_linhas': b.fundo(18) - b.topo(0),
        'caixa': t.alturaConteudo,
        'linhas': linhas,
      };
      print(
        'S3 tela 19 [$nome] linha ${t.alturaLinha} px · 22/22 linhas iguais · '
        'baseline máx ${maxBase.toStringAsFixed(4)} (SkParagraph sozinho '
        '${maxBaseSk.toStringAsFixed(4)}) · direita máx '
        '${maxDir.toStringAsFixed(4)} · 19 linhas = '
        '${(b.fundo(18) - b.topo(0)).toStringAsFixed(4)} de ${t.alturaConteudo}',
      );
      expect(maxBase, lessThanOrEqualTo(_gate));
      expect(maxDir, lessThanOrEqualTo(1.0)); // x dependente de texto: ±1,0
      for (final x in bl) {
        x.dispose();
      }
    });
  }

  test(
    'pintura da página 1 @3x: linha a linha × SkParagraph inteiro',
    () async {
      const t = Tipografia();
      final item = lerEpub(fixtureEpub(texto['text'] as String)).itens.single;
      final bl = item.blocos.map((b) => layoutBloco(b, t)).toList();
      final pg = paginar(bl, t).first;
      Directory('dados').createSync(recursive: true);
      for (final (nome, pintor) in [
        ('por_linha', pintarFatia),
        ('skparagraph_inteiro', pintarFatiaIngenua),
      ]) {
        const escala = 3.0;
        final rec = ui.PictureRecorder();
        final c = ui.Canvas(rec)
          ..scale(escala)
          ..drawRect(
            const ui.Rect.fromLTWH(0, 0, 390, 844),
            ui.Paint()..color = const ui.Color(0xFFF8F1E4),
          );
        for (final f in pg.fatias) {
          pintor(c, bl[f.bloco], f, ui.Offset(t.margem, t.topo));
        }
        final img = await rec.endRecording().toImage(1170, 2532);
        final png = await img.toByteData(format: ui.ImageByteFormat.png);
        File('dados/tela19_pagina_${nome}_390x844@3x.png')
            .writeAsBytesSync(png!.buffer.asUint8List());
        img.dispose();
      }
      for (final x in bl) {
        x.dispose();
      }
    },
  );

  test('fios de navalha (linhas 7 e 19): mesma folga do Chromium', () {
    const t = Tipografia();
    final riscos = (knife['riscos'] as List).cast<Map<String, dynamic>>();
    final palavras = (texto['text'] as String).split(' ');
    final saida = <Map<String, Object>>[];
    for (final r in riscos) {
      final linha = r['texto'] as String;
      // Próxima palavra = a que vem depois desta linha no texto.
      final n = linha.split(' ').length;
      final antes = (refLinhas
          .take((r['linha'] as int) - 1)
          .map((l) => (l['text'] as String).split(' ').length)
          .fold(0, (a, b) => a + b));
      final proxima = palavras[antes + n];
      final pb = ui.ParagraphBuilder(ui.ParagraphStyle(maxLines: 1))
        ..pushStyle(t.estilo())
        ..addText('$linha $proxima');
      final p = pb.build()
        ..layout(const ui.ParagraphConstraints(width: double.infinity));
      final estouro = p.maxIntrinsicWidth - (r['disponivel'] as num);
      p.dispose();
      saida.add({
        'linha': r['linha'] as int,
        'proxima': proxima,
        'estouro_flutter': double.parse(estouro.toStringAsFixed(4)),
        'estouro_chromium': r['estouroComProxima'] as num,
      });
      expect(
        estouro,
        closeTo((r['estouroComProxima'] as num).toDouble(), 0.01),
      );
      expect(estouro, greaterThan(0)); // a próxima palavra continua não cabendo
    }
    resultado['fios_de_navalha'] = saida;
    print('S3 fios de navalha: $saida');
  });
}
