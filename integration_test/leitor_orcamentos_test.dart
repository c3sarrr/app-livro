// G20 (R9) — os orçamentos do Anexo 03 §12 no aparelho, em `--profile` (roda na G26, com o celular):
//   flutter drive --profile --driver=test_driver/orcamentos_driver.dart \
//     --target=integration_test/leitor_orcamentos_test.dart -d <celular>
// Mede: abrir um livro já indexado até a 1ª página (< 600 ms); virar 30 páginas sem quadro perdido (o tempo de build e
// de raster de cada quadro); paginar um capítulo de ~40 páginas (< 120 ms, fatias ≤ 4 ms); importar um EPUB de 2 MB
// até poder ler (< 2 s); a memória com o livro aberto e depois das 30 viradas (< 180 MB). A latência do traço é a do
// medidor da G16 (`--dart-define=BOOKNEST_MEDIR_TINTA=true`, as linhas "G16LAT" no console).
// O resultado vai para `build/orcamentos_aparelho.json` (o driver grava).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/perf/fluxos_do_leitor.dart';

double _mb(int bytes) => bytes / (1024 * 1024);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final dados = <String, Object?>{};
  tearDownAll(
    () => binding.reportData = {...?binding.reportData, 'orcamentos': dados},
  );

  testWidgets('abrir já indexado, virar 30 páginas e a memória', (
    tester,
  ) async {
    final livro = await livroGerado();
    final sw = Stopwatch()..start();
    await abrirLivroIndexado(tester, livro);
    sw.stop();
    dados['abrir_ms'] = sw.elapsedMilliseconds;
    dados['abrir_orcamento_ms'] = 600;
    dados['memoria_aberto_mb'] = _mb(ProcessInfo.currentRss);
    final tela = tester.view.physicalSize / tester.view.devicePixelRatio;
    await binding.watchPerformance(
      () => virarPaginas(tester, 30, tela: tela),
      reportKey: 'virar_30',
    );
    dados['memoria_depois_de_virar_mb'] = _mb(ProcessInfo.currentRss);
    dados['memoria_orcamento_mb'] = 180;
    await livro.close();
  });

  testWidgets('paginar um capítulo de ~40 páginas', (tester) async {
    final livro = await livroGerado();
    final spine = livro.index.spine.indexWhere((s) => s.linear) + 3;
    final r = paginarCapitulo(livro, spine);
    dados['paginar_paginas'] = r.paginas;
    dados['paginar_ms'] = r.total.inMicroseconds / 1000;
    dados['paginar_orcamento_ms'] = 120;
    dados['paginar_maior_passo_ms'] = r.maiorPassoMicros / 1000;
    dados['paginar_fatia_orcamento_ms'] = 4;
    await livro.close();
  });

  testWidgets('importar um EPUB de 2 MB até poder ler', (tester) async {
    final bytes = epubDe2MB();
    final r = await importarEpub(bytes);
    dados['importar_bytes'] = bytes.length;
    dados['importar_ms'] = r.ate.inMilliseconds;
    dados['importar_orcamento_ms'] = 2000;
    dados['importar_resultado'] = r.resultado.runtimeType.toString();
  });
}
