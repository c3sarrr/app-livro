// G17 (Tarefa 20) — o mundo das telas 23 e 23b no banco do leitor (D-34): o Dom Casmurro do mundo com o EPUB da 22
// (NBSP dentro dos 4 trechos anotados — D-160), o índice da 19, a pág. 159, a tinta toda do mundo
// (`mundoSemNotaAMao`), os grifos de todos os livros (as contagens 5/3/2/2 — D-40), os rótulos e o `pen_presets` do
// mundo. As telas abrem pelo fluxo de verdade: controles → Anotar → o 2º toque na Caneta (23) ou o Marca-texto e o 2º
// toque nele (23b); o painel entra em 150 ms.
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_leitor.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/telas/instantaneo.dart'
    show mundoSemNotaAMao, semOsDesenhosDaSessao;
import 'canvas.dart';
import 'dados_t20.dart' show depsDaTela20;
import 'dados_t22.dart';
import 'precache_svgs.dart';
import 'pump_reader.dart';
import 'reader_harness.dart';

/// O Dom Casmurro das telas 23 e 23b na estante da conta do mundo, no papel [papel]. [sessao] (T01, as provas de
/// fidelidade): gravado sem os desenhos da sessão da 22, que o fluxo desenha — o Desfazer aceso como na prancha.
Future<LivroNaEstante> livroDaTela23({
  ReaderPaper papel = ReaderPaper.creme,
  bool sessao = false,
}) async {
  final livro = await livroDaTela22(
    papel: papel,
    mundo: sessao ? semOsDesenhosDaSessao(mundoSemNotaAMao) : mundoSemNotaAMao,
  );
  return sessao ? comASessaoDaTela22(livro) : livro;
}

Finder _key(String k) => find.byKey(ValueKey<String>(k));

Future<void> _quadros(WidgetTester tester, [int n = 20]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Os desenhos dos painéis (as pontas na cor da caneta do mundo, a dica, o fechar e o "+"): o flutter_svg carrega de
/// forma assíncrona e, sem isto, o golden sai sem eles.
Future<void> precacheTela23(WidgetTester tester) async {
  await precacheTela22(tester);
  await precacheSvgs(tester, [
    ...AppIllustrationsLeitor.panels,
    AppIconsLeitor.close,
    AppIconsLeitor.plus,
  ]);
  await precacheSvgs(
    tester,
    [AppIllustrationsLeitor.markerTip],
    colors: {AppColors.ink: AppColors.inkNight},
  );
}

/// O leitor na pág. 159 e o modo anotação, prontos para abrir um painel.
Future<LeitorNaTela> _modo(
  WidgetTester tester,
  LivroNaEstante livro, {
  required bool golden,
}) async {
  setCanvasView(tester, logical: const Size(390, 844));
  await precacheTela23(tester);
  final t = await abrirLeitor(
    tester,
    livro,
    golden: golden,
    deps: (t) => depsDaTela20(t, livro),
  );
  await esperarBancoL22(tester);
  await entrarNoModoAnotacao(tester);
  await desenharASessaoDaTela22(tester, livro);
  return t;
}

/// Abre a tela 23: o 2º toque na Caneta (a ferramenta de começo) abre o painel dela.
Future<LeitorNaTela> abrirTela23(
  WidgetTester tester,
  LivroNaEstante livro, {
  bool golden = false,
}) async {
  final t = await _modo(tester, livro, golden: golden);
  await tester.tap(_key('ann.toolShelf.pen'));
  await tester.pump();
  await _quadros(tester, 12);
  expect(_key('ann.penPanel'), findsOneWidget);
  return t;
}

/// Abre a tela 23b: o Marca-texto e o 2º toque nele abrem o painel dele.
Future<LeitorNaTela> abrirTela23b(
  WidgetTester tester,
  LivroNaEstante livro, {
  bool golden = false,
}) async {
  final t = await _modo(tester, livro, golden: golden);
  await tester.tap(_key('ann.toolShelf.marker'));
  await tester.pump();
  await tester.tap(_key('ann.toolShelf.marker'));
  await tester.pump();
  await _quadros(tester, 12);
  expect(_key('ann.markerPanel'), findsOneWidget);
  return t;
}
