// G11 — o app real com um livro de verdade aberto no leitor: monta o app (como `pumpApp`, mas com o leitor
// ligado a um banco em memória em vez do "abrindo" da fixture da Início), empurra `/leitor/<id>` e espera a
// página aparecer. Os dublês (tela acesa, barra de status) e os erros ficam à mão.
import 'dart:async';

import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/app/routes.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/features/highlights/application/highlights_controller.dart';
import 'package:app_leitura/features/highlights/application/highlights_providers.dart';
import 'package:app_leitura/features/reader/application/reader_providers.dart';
import 'package:app_leitura/features/reader/application/reader_session_controller.dart';
import 'package:app_leitura/features/scanner/presentation/scanner_camera.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../fixtures/overrides_do_mundo.dart';
import 'canvas.dart' show goldenRootKey;
import 'fake_reader.dart';
import 'fake_scanner_camera.dart';
import 'precache_svgs.dart';
import 'reader_harness.dart';

final class LeitorNaTela {
  LeitorNaTela(this.livro);

  final LivroNaEstante livro;
  final awake = RecordingScreenAwake();
  final ui = RecordingSystemUi();
  final erros = <Object>[];
}

GoRouter routerOf(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(MainShell, skipOffstage: false)));

/// Monta o app, empurra o leitor do [livro] e espera a página (ou o estado final, se [esperar] = false não
/// espera nada). [deps] troca as dependências (ex.: um Future que demora); [golden] põe a raiz do app num
/// `RepaintBoundary` (`goldenRootKey`) para a captura. [destaques] = as dependências da tela 25 (sem elas, a tela
/// fica no topo, sem banco); [ir] = o `?ir=` da rota (G19).
Future<LeitorNaTela> abrirLeitor(
  WidgetTester tester,
  LivroNaEstante livro, {
  Future<ReaderDeps> Function(LeitorNaTela t)? deps,
  bool esperar = true,
  List<Override> overrides = const [],
  bool golden = false,
  HighlightsDeps? destaques,
  String? ir,
}) async {
  final t = LeitorNaTela(livro);
  await precacheAppIcons(tester);
  await precacheSvgs(tester, AppIconsLeitor.all);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        relogioDoMundo,
        repositorioDoMundo,
        brandDoMundo,
        scannerCameraProvider.overrideWithValue(FakeScannerCamera.new),
        readerDepsProvider.overrideWith(
          (ref) =>
              deps?.call(t) ??
              Future.value(
                livro.readerDeps(
                  awake: t.awake,
                  onError: (e, _) => t.erros.add(e),
                ),
              ),
        ),
        readerSystemUiProvider.overrideWithValue(t.ui),
        highlightsDepsProvider.overrideWith(
          (ref) => destaques == null
              ? Completer<HighlightsDeps>().future
              : Future.value(destaques),
        ),
        ...cronometroDoMundo(),
        ...overrides,
      ],
      child: golden
          ? const RepaintBoundary(key: goldenRootKey, child: App.forTests())
          : const App.forTests(),
    ),
  );
  await tester.pumpAndSettle();
  unawaited(
    routerOf(tester).push<void>(AppRoutes.leitor(livro.userBookId, goTo: ir)),
  );
  if (esperar) await esperarLeitor(tester);
  return t;
}

/// Anda os quadros até a página do leitor (ou um erro) aparecer — a abertura usa o banco e a fila de layout — e
/// até a entrada da rota terminar (medidas e toques na posição final da tela).
Future<void> esperarLeitor(WidgetTester tester, {int quadros = 400}) async {
  for (var i = 0; i < quadros; i++) {
    await tester.pump(const Duration(milliseconds: 16));
    if (find.byKey(const ValueKey('r19.footer')).evaluate().isNotEmpty ||
        find.byKey(const ValueKey('leitor.erro')).evaluate().isNotEmpty) {
      await tester.pumpAndSettle();
      return;
    }
  }
  fail('o leitor não abriu em $quadros quadros');
}
