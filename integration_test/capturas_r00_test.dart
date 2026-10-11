// R00.8 (R7) — o roteiro das capturas das 16 telas prontas no Galaxy S22+: o app do modo demonstração (D-267) sobre o
// banco do demo numa pasta temporária (o mundo de referência recém-semeado; o banco do app normal não é aberto), levado
// ao estado de cada prancha com gestos de verdade. Em cada uma imprime `R00CAP <nn>` e fica parado 6 s — o script do
// computador (`tools/celular/capturar_r00.py`) tira a captura pelo `adb` nesse intervalo.
//   --dart-define=R00_ALVO=1 (padrão): o alvo (1), as 16 telas;
//   --dart-define=R00_ALVO=2: o alvo (2) (a Início igual à prancha), as 3 telas da Início.
// Rodar só pelo script: ele confere a assinatura do app instalado e o espaço, guarda o APK do app normal e usa o
// `--keep-app-running` (sem as conferências o `flutter drive` pode desinstalar o app, e os dados vão junto).
import 'dart:io';

import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/reader/annotations/space/space_metrics.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/presentation/annotation_mode.dart';
import 'package:app_leitura/features/reader/presentation/hand_note.dart'
    show noteDeletedText;
import 'package:app_leitura/features/reading_session/application/second_ticker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/fixtures/demonstracao/overrides_demonstracao.dart';
import '../test/fixtures/demonstracao/prancha_no_aparelho.dart';
import '../test/fixtures/mundo_2026_09_20.dart';
import '../test/fixtures/paper_timer_fakes.dart' show ManualTicker;
import '../test/support/demonstracao_no_app.dart';
import '../test/support/navegacao.dart';

const int _alvo = int.fromEnvironment('R00_ALVO', defaultValue: 1);

/// O relógio do roteiro: o "agora" de referência (dom 20/09/2026 20:00), que só anda quando o roteiro manda.
final class _Relogio {
  DateTime agora = mundoReferencia.agora;
}

Finder _k(String chave) => find.byKey(ValueKey<String>(chave));

/// Marca a tela [numero] e fica parado enquanto o computador tira a captura.
Future<void> _capturar(WidgetTester t, String numero) async {
  await quadros(t, 30);
  // ignore: avoid_print — a marca que o script do computador lê
  print('R00CAP $numero');
  await t.runAsync(() => Future<void>.delayed(const Duration(seconds: 6)));
  await quadro(t);
}

Size _tela(WidgetTester t) => t.view.physicalSize / t.view.devicePixelRatio;

/// A Início rolada até o pé de [chave] ficar em [base] (lógicos, do alto da tela).
Future<void> _rolarAte(WidgetTester t, String chave, double base) async {
  final rolagem = find
      .descendant(
        of: find.byType(HomeScreen),
        matching: find.byType(Scrollable),
      )
      .first;
  final pos = t.state<ScrollableState>(rolagem).position;
  final pe = t.getRect(_k(chave)).bottom;
  pos.jumpTo((pos.pixels + pe - base).clamp(0.0, pos.maxScrollExtent));
  await quadros(t, 10);
}

/// A 01b: o play do Brás Cubas e 8 min 42 s no relógio ("08:42", como a prancha).
Future<void> _inicio01b(WidgetTester t, _Relogio r, ManualTicker tique) async {
  await voltarAoInicio(t);
  await tocarChave(t, 'alsoReading.card1.play');
  await ate(t, chave: 'miniBar');
  r.agora = r.agora.add(const Duration(minutes: 8, seconds: 42));
  tique.tick();
  await voltarAoInicioComSessao(t);
}

/// A Início no topo sem descartar a sessão aberta.
Future<void> voltarAoInicioComSessao(WidgetTester t) async {
  final rolagem = find
      .descendant(
        of: find.byType(HomeScreen),
        matching: find.byType(Scrollable),
      )
      .first;
  t.state<ScrollableState>(rolagem).position.jumpTo(0);
  await quadros(t, 10);
}

/// A pasta temporária do demo sai do aparelho no fim (o banco do demo e as pastas dele).
Future<void> _apagar(WidgetTester t, Directory suporte) => t.runAsync(() async {
  if (suporte.existsSync()) suporte.deleteSync(recursive: true);
});

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('as telas prontas, uma a uma, para as capturas (alvo $_alvo)', (
    tester,
  ) async {
    final suporte = Directory.systemTemp.createTempSync('booknest_r00_cap_');
    // também quando o roteiro falha: a pasta temporária do demo não fica no aparelho
    addTearDown(
      () => suporte.existsSync() ? suporte.delete(recursive: true) : null,
    );
    final relogio = _Relogio();
    final tique = ManualTicker();
    await montarDemonstracao(
      tester,
      _alvo == 2
          ? overridesDaPranchaNoAparelho(
              suporte: () async => suporte,
              tique: tique,
              relogio: () => relogio.agora,
            )
          : [
              ...overridesDemonstracao(
                suporte: () async => suporte,
                relogio: () => relogio.agora,
              ),
              secondTickerProvider.overrideWithValue(tique),
            ],
      tela: null,
      sistemaDeVerdade: true,
    );

    // ---- a Início ----
    await voltarAoInicio(tester);
    await _capturar(tester, '01');
    // a 60: a Início rolada como na prancha — o pé do "Seu dia" em 289,7 (medido no PNG @3x) e, no alvo (2), o
    // cartão da revisão logo abaixo (no alvo (1) ele não existe até a T05 — D-247)
    await _rolarAte(tester, 'today', 289.7);
    await _capturar(tester, '60');
    await _inicio01b(tester, relogio, tique);
    await _capturar(tester, '01b');
    await descartarSessao(tester);
    if (_alvo == 2) {
      await desmontarDemonstracao(tester);
      await _apagar(tester, suporte);
      return;
    }

    // ---- o leitor ----
    // a 19, a 20 e a 26b numa sessão só, ainda com "18 min hoje" (cada entrada no leitor soma o tempo da sessão)
    await chegar(tester, 'leitor19');
    await _capturar(tester, '19');
    final meio = _tela(tester).center(Offset.zero);
    await tester.tapAt(meio);
    await ate(tester, chave: 'r20.bottomIsland');
    await _capturar(tester, '20');
    await tocarChave(tester, 'r20.bottomIsland.tools.theme');
    await _capturar(tester, '26b');
    await tocarChave(tester, 'r20.bottomIsland.tools.theme');
    await chegar(tester, 'leitor21');
    await _capturar(tester, '21');
    await chegar(tester, 'leitor22');
    await _capturar(tester, '22');
    await chegar(tester, 'leitor23');
    await _capturar(tester, '23');
    await chegar(tester, 'leitor23b');
    await _capturar(tester, '23b');

    // a 24: o Espaço aberto 3 linhas na fresta de "Vá, de ressaca.", segurado no meio do arrasto. No mundo essa fresta
    // já tem a nota da 24b (uma nota por âncora — G18, R5), e a prancha 24 é o momento antes dela: a nota sai na
    // sessão, o espaço abre, e os dois passos são desfeitos antes de concluir (o banco do demo fica como estava).
    await chegar(tester, 'leitor22');
    await tocarChave(tester, 'ann.page.handNote.actions.delete');
    // a pílula "Nota apagada · Desfazer" some sozinha em 4 s
    await tester.runAsync(
      () => Future<void>.delayed(favoriteUndoLife + const Duration(seconds: 1)),
    );
    await ateSumir(tester, find.text(noteDeletedText));
    await tocarChave(tester, 'ann.toolShelf.space');
    final sessao = tester
        .widget<AnnotationMode>(find.byType(AnnotationMode))
        .session;
    final olhos = sessao.geometry.lines.firstWhere(
      (l) => sessao.anchors
          .textOf(l.unit)!
          .substring(l.from, l.to)
          .startsWith('Olhos de ressaca'),
    );
    final fresta = olhos.bottom + sessao.textShift;
    final x = _tela(tester).width / 2;
    final linhas3 =
        fresta + openerMarginTop + 3 * sessao.geometry.lineHeight - 2;
    final g = await tester.startGesture(Offset(x, fresta + 2));
    for (var y = fresta + 10; y < linhas3; y += 8) {
      await g.moveTo(Offset(x, y));
      await quadro(tester);
    }
    await g.moveTo(Offset(x, linhas3));
    await quadros(tester, 4);
    expect(find.byKey(const ValueKey('ann.page.spaceOpener')), findsOneWidget);
    await _capturar(tester, '24');
    await g.up();
    await quadros(tester, 20);
    // desfazer a nota nova e depois a nota apagada: a nota do mundo volta
    await tocarChave(tester, 'ann.island.undo');
    await tocarChave(tester, 'ann.island.undo');
    await quadros(tester, 10);
    expect(_k('ann.page.handNote.tag'), findsOneWidget);
    await tocarChave(tester, 'ann.done');
    await quadros(tester, 30);

    // a 24b: a nota à mão do mundo, na pág. 159, no modo anotação
    await chegar(tester, 'leitor22');
    await _capturar(tester, '24b');

    await chegar(tester, 'grifos');
    await _capturar(tester, '25');
    await chegar(tester, 'leitor26');
    await _capturar(tester, '26');
    await chegar(tester, 'leitor27');
    await _capturar(tester, '27');
    await chegar(tester, 'leitor27b');
    await _capturar(tester, '27b');

    await voltarAoInicio(tester);
    await desmontarDemonstracao(tester);
    await _apagar(tester, suporte);
  }, timeout: const Timeout(Duration(minutes: 20)));
}
