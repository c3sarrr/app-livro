// G20 (R10, R12) — a prévia dos orçamentos do Anexo 03 §12 no PC: o que o Dart faz (abrir, paginar, importar, virar e
// traçar, e o sumário com 5.000 entradas), 5 vezes cada, com a mediana e o p95. É o modo de depuração do
// `flutter test`, sem a GPU e sem a memória do celular: serve para comparar, não para aprovar (o aparelho é a G26).
// Só roda com `--dart-define=BOOKNEST_ORCAMENTOS=true`; grava `tools/medicao/tmp/orcamentos_pc.json` (ou o caminho de
// BOOKNEST_ORCAMENTOS_SAIDA).
import 'dart:convert';
import 'dart:io';

import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/fase_l27.dart';
import '../support/load_fonts.dart';
import '../support/pump_reader.dart';
import 'fluxos_do_leitor.dart';

const bool _ligado = bool.fromEnvironment('BOOKNEST_ORCAMENTOS');

final Map<String, Object?> _saida = {};

/// Mediana e p95 (em ms) de [ms].
Map<String, double> _resumo(List<double> ms) {
  final s = [...ms]..sort();
  double q(double p) => s[((s.length - 1) * p).round()];
  return {'mediana_ms': q(0.5), 'p95_ms': q(0.95), 'max_ms': s.last};
}

double _ms(Duration d) => d.inMicroseconds / 1000;

/// Um índice com [n] capítulos sobre o texto do livro (títulos de 1 a 3 linhas, numerais 1…n), espalhados pelos itens
/// lineares — o sumário grande da R12.
BookIndex _indiceGrande(BookIndex base, int n) {
  final lineares = [
    for (var i = 0; i < base.spine.length; i++)
      if (base.spine[i].linear && base.spine[i].chars > 0) i,
  ];
  final porItem = (n / lineares.length).ceil();
  final toc = <TocPoint>[];
  for (var c = 0; c < n; c++) {
    final item = lineares[c ~/ porItem];
    final k = c % porItem;
    final titulo = switch (c % 3) {
      0 => 'Um capítulo curto',
      1 => 'Um capítulo com um título mais comprido que ocupa duas linhas',
      _ => 'Um capítulo com um título bem mais comprido, que passa da segunda linha e chega à terceira na folha',
    };
    toc.add(
      TocPoint(
        title: '${c + 1}. $titulo',
        depth: 0,
        leaf: true,
        spine: item,
        offset: base.spine[item].chars * k ~/ porItem,
      ),
    );
  }
  return BookIndex(
    contentSha256: base.contentSha256,
    layout: base.layout,
    spine: base.spine,
    toc: toc,
    refPages: base.refPages,
    refPageVersion: base.refPageVersion,
  );
}

void main() {
  setUpAll(loadAppFonts);
  tearDownAll(() {
    if (!_ligado) return;
    final caminho =
        Platform.environment['BOOKNEST_ORCAMENTOS_SAIDA'] ??
        'tools/medicao/tmp/orcamentos_pc.json';
    File(caminho).writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'aviso':
            'flutter test no PC (modo de depuração, sem a GPU e sem a memória do celular): '
            'comparação, não aprovação — os números do aparelho são da G26',
        ..._saida,
      }),
    );
  });

  testWidgets(
    'abrir já indexado até a 1ª página; virar 30 (o tempo de cada quadro montado)',
    (tester) async {
      final abrir = <double>[];
      final quadros = <double>[];
      for (var v = 0; v < 5; v++) {
        final livro = await livroGerado();
        setCanvasView(tester, logical: const Size(390, 844));
        final sw = Stopwatch()..start();
        await abrirLivroIndexado(tester, livro);
        abrir.add(_ms(sw.elapsed));
        for (var i = 0; i < 30; i++) {
          await tester.tapAt(const Offset(360, 420));
          for (var q = 0; q < 20; q++) {
            final f = Stopwatch()..start();
            await tester.pump(const Duration(milliseconds: 16));
            quadros.add(_ms(f.elapsed));
          }
        }
        await tester.pumpWidget(const SizedBox());
        await livro.close();
      }
      _saida['abrir'] = {..._resumo(abrir), 'orcamento_ms': 600};
      _saida['virar_30_quadro'] = {
        ..._resumo(quadros),
        'quadros': quadros.length,
        'acima_de_16_7_ms': quadros.where((q) => q > 16.7).length,
        'orcamento': '0 quadros perdidos (no aparelho, build + raster)',
      };
    },
    skip: !_ligado,
  );

  test('paginar um capítulo inteiro (o total e a maior fatia)', () async {
    final total = <double>[];
    final passo = <double>[];
    var paginas = 0;
    final livro = await livroGerado();
    final spine = livro.index.spine.indexWhere((s) => s.linear) + 3;
    for (var v = 0; v < 5; v++) {
      final r = paginarCapitulo(livro, spine);
      total.add(_ms(r.total));
      passo.add(r.maiorPassoMicros / 1000);
      paginas = r.paginas;
    }
    await livro.close();
    _saida['paginar'] = {
      ..._resumo(total),
      'paginas': paginas,
      'maior_passo': _resumo(passo),
      'orcamento_ms': 120,
      'orcamento_fatia_ms': 4,
    };
  }, skip: !_ligado);

  test('importar um EPUB de ~2 MB até poder ler', () async {
    final bytes = epubDe2MB();
    final ms = <double>[];
    for (var v = 0; v < 5; v++) {
      ms.add(_ms((await importarEpub(bytes)).ate));
    }
    _saida['importar'] = {
      ..._resumo(ms),
      'bytes': bytes.length,
      'orcamento_ms': 2000,
    };
  }, skip: !_ligado);

  testWidgets('traçar: o tempo de cada quadro com o dedo andando', (
    tester,
  ) async {
    final livro = await livroGerado();
    addTearDown(livro.close);
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLivroIndexado(tester, livro);
    await tester.tapAt(const Offset(195, 420));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.tap(
      find.byKey(const ValueKey('r20.bottomIsland.tools.annotate')),
    );
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    final ms = <double>[];
    for (var t = 0; t < 10; t++) {
      final y = 260.0 + 18 * t;
      final g = await tester.startGesture(Offset(60, y));
      for (var p = 1; p <= 24; p++) {
        await g.moveTo(
          Offset(60 + 10.0 * p, y),
          timeStamp: Duration(milliseconds: 8 * p),
        );
        final f = Stopwatch()..start();
        await tester.pump(const Duration(milliseconds: 8));
        ms.add(_ms(f.elapsed));
      }
      await g.up();
      await tester.pump(const Duration(milliseconds: 16));
    }
    _saida['tracar_quadro'] = {
      ..._resumo(ms),
      'orcamento': 'p95 ≤ 16,7 ms a 60 Hz (no aparelho, o medidor da G16)',
    };
  }, skip: !_ligado);

  testWidgets(
    'R12: o sumário com 5.000 entradas — o tempo até a folha assentar e as linhas montadas',
    (tester) async {
      final ms = <double>[];
      final montagem = <double>[];
      var linhas = 0;
      for (var v = 0; v < 3; v++) {
        final livro = await livroDaTela27();
        await livro.usarIndice(_indiceGrande(livro.index, 5000));
        setCanvasView(tester, logical: const Size(390, 844));
        await abrirLeitor(tester, livro, deps: (t) => depsDaTela27(t, livro));
        await tester.tapAt(const Offset(195, 420));
        for (var i = 0; i < 12; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        final sw = Stopwatch()..start();
        await tester.tap(
          find.byKey(const ValueKey('r20.bottomIsland.tools.toc')),
        );
        // o quadro que monta a lista (o índice chega antes, do banco, por futuros de verdade)
        final lista = find.byKey(const ValueKey('toc.sheet.chapters.list'));
        var quadro = Duration.zero;
        for (var i = 0; i < 600 && lista.evaluate().isEmpty; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 5)),
          );
          final q = Stopwatch()..start();
          await tester.pump(const Duration(milliseconds: 16));
          quadro = q.elapsed;
        }
        expect(lista, findsOneWidget);
        ms.add(_ms(sw.elapsed));
        montagem.add(_ms(quadro));
        linhas = find
            .byWidgetPredicate(
              (w) =>
                  w.key is ValueKey<String> &&
                  RegExp(r'^toc\.sheet\.chapters\.ch\d+\.link$')
                      .hasMatch((w.key! as ValueKey<String>).value),
              // as montadas fora da vista também (a lista sob demanda guarda as vizinhas)
              skipOffstage: false,
            )
            .evaluate()
            .length;
        await tester.pumpWidget(const SizedBox());
        await livro.close();
      }
      _saida['sumario_5000'] = {
        ..._resumo(ms),
        'quadro_que_monta_a_lista': _resumo(montagem),
        'linhas_montadas': linhas,
        'limite_ms': 100,
      };
    },
    skip: !_ligado,
  );
}
