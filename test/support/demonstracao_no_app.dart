// R00 (D-267) — o app inteiro sobre o banco do modo demonstração (o PowerSync de verdade num arquivo, que responde
// fora do tempo falso dos testes de widget): montar com os overrides de um alvo e os dublês do aparelho (a câmera do
// scanner, a tela acesa, a barra do sistema, a rede das capas), andar até uma chave aparecer e desmontar. Serve à
// suíte (`test/app/modo_demonstracao_test.dart`, `test/app/navegacao_test.dart`) e ao celular
// (`integration_test/navegacao_test.dart`, `integration_test/capturas_r00_test.dart`).
import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/features/catalog/application/catalog_providers.dart'
    show catalogHttpClientProvider;
import 'package:app_leitura/features/reader/application/reader_providers.dart';
import 'package:app_leitura/features/reader/layout/layout_scheduler.dart';
import 'package:app_leitura/features/scanner/presentation/scanner_camera.dart';
import 'package:flutter/scheduler.dart' show Priority;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'canvas.dart';
import 'fake_reader.dart';
import 'fake_scanner_camera.dart';
import 'precache_svgs.dart';

/// Um quadro: deixa o banco responder (fora do tempo falso) e anda 16 ms.
Future<void> quadro(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 2)),
  );
  await tester.pump(const Duration(milliseconds: 16));
}

Future<void> quadros(WidgetTester tester, int n) async {
  for (var i = 0; i < n; i++) {
    await quadro(tester);
  }
}

/// Anda até [achado] (ou a chave [chave]) aparecer; falha com [motivo] se não aparecer.
Future<void> ate(
  WidgetTester tester, {
  String? chave,
  Finder? achado,
  String? motivo,
  int voltas = 4000,
}) async {
  final f = achado ?? find.byKey(ValueKey<String>(chave!));
  for (var i = 0; i < voltas; i++) {
    if (f.evaluate().isNotEmpty) return;
    await quadro(tester);
  }
  fail(motivo ?? '${chave ?? f.describeMatch(Plurality.one)} não apareceu');
}

/// Anda até [achado] sumir.
Future<void> ateSumir(
  WidgetTester tester,
  Finder achado, {
  String? motivo,
  int voltas = 1000,
}) async {
  for (var i = 0; i < voltas; i++) {
    if (achado.evaluate().isEmpty) return;
    await quadro(tester);
  }
  fail(motivo ?? '${achado.describeMatch(Plurality.one)} não sumiu');
}

/// Monta o app com [demo] (os overrides de um alvo da D-267) e os dublês do aparelho, e anda até o herói da Início.
/// [tela] = o tamanho lógico (na suíte); no celular, `null` (a tela de verdade). [sistemaDeVerdade]: a barra do sistema
/// e a tela acesa do aparelho (as capturas: o leitor esconde a barra — D-105), no lugar dos dublês. Devolve as URLs
/// pedidas à rede.
Future<List<Uri>> montarDemonstracao(
  WidgetTester tester,
  List<Override> demo, {
  Size? tela = const Size(390, 844),
  bool sistemaDeVerdade = false,
}) async {
  final pedidos = <Uri>[];
  if (tela != null) setCanvasView(tester, logical: tela);
  await precacheAppIcons(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...demo,
        catalogHttpClientProvider.overrideWithValue(
          MockClient((r) async {
            pedidos.add(r.url);
            return http.Response('', 404);
          }),
        ),
        scannerCameraProvider.overrideWithValue(FakeScannerCamera.new),
        if (!sistemaDeVerdade) ...[
          screenAwakeProvider.overrideWithValue(RecordingScreenAwake()),
          readerSystemUiProvider.overrideWithValue(RecordingSystemUi()),
        ],
        // as fatias do layout com prioridade de animação: no tempo falso a ociosa nunca chega (G11)
        layoutSchedulerProvider.overrideWithValue(
          LayoutScheduler(priority: Priority.animation),
        ),
      ],
      child: const App.forTests(),
    ),
  );
  await ate(tester, chave: 'hero.title');
  await quadros(tester, 20);
  return pedidos;
}

/// Desmonta o app e deixa os temporizadores das capas e do relógio da Início acabarem.
Future<void> desmontarDemonstracao(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  // no tempo falso; no celular (o binding do integration_test) o tempo é o de verdade
  if (tester.binding is AutomatedTestWidgetsFlutterBinding) {
    await tester.pump(const Duration(minutes: 5));
  }
}
