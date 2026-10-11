// G18 (Tarefa 20) — o mundo das telas 24 e 24b no banco do leitor (D-34, R15): a 24 é o mundo da 23 (sem a nota à
// mão — `mundoSemNotaAMao`) com o Espaço e o dedo parado 3 linhas abaixo da fresta de "Vá, de ressaca." (no x de 58 %
// da caixa, como a prancha); a 24b é o mundo de referência, com a nota salva depois de "Vá, de ressaca." (3 linhas e a
// tinta de `nota_mao_ressaca.svg`), e a Caneta (D-187). As telas abrem pelo fluxo de verdade: controles → Anotar.
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/annotation_mode.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/mundo_2026_09_20.dart' show mundoReferencia;
import 'canvas.dart';
import 'dados_t20.dart' show depsDaTela20;
import 'dados_t22.dart';
import 'dados_t23.dart';
import 'precache_svgs.dart';
import 'pump_reader.dart';
import 'reader_harness.dart';

/// O Dom Casmurro da tela 24 (o mundo da 23) no papel [papel]; [sessao] como em [livroDaTela23].
Future<LivroNaEstante> livroDaTela24({
  ReaderPaper papel = ReaderPaper.creme,
  bool sessao = false,
}) => livroDaTela23(papel: papel, sessao: sessao);

/// O Dom Casmurro da tela 24b (o mundo de referência, com a nota à mão salva) no papel [papel]. [sessao] (T01, as
/// provas de fidelidade): o fluxo recolhe e abre a nota — dois passos que acendem o Desfazer como na prancha, com a
/// caixa igual. (A onda e o sublinhado duplo da sessão da 22 ficam atrás da prateleira e da ilha na 24b, onde o dedo
/// não desenha.)
Future<LivroNaEstante> livroDaTela24b({
  ReaderPaper papel = ReaderPaper.creme,
  bool sessao = false,
}) async {
  final livro = await livroDaTela22(papel: papel, mundo: mundoReferencia);
  if (sessao) _passosDaNota[livro] = true;
  return livro;
}

final Expando<bool> _passosDaNota = Expando('passos da nota da 24b');

Finder _key(String k) => find.byKey(ValueKey<String>(k));

Future<void> _quadros(WidgetTester tester, [int n = 20]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// A sessão do modo anotação na tela.
AnnotationSession sessaoNaTela(WidgetTester tester) =>
    tester.widget<AnnotationMode>(find.byType(AnnotationMode)).session;

/// O texto da linha [l] da página da sessão (os trechos da D-160 com espaço comum).
String textoDaLinha(AnnotationSession s, InkLine l) =>
    s.anchors.textOf(l.unit)!.substring(l.from, l.to).replaceAll(' ', ' ');

/// A linha da página da sessão que começa com [inicio].
InkLine linhaQueComeca(AnnotationSession s, String inicio) =>
    s.geometry.lines.firstWhere((l) => textoDaLinha(s, l).startsWith(inicio));

/// A fresta da prancha 24 na tela: a base da linha de "Vá, de ressaca." (30 abaixo do leitor limpo).
double frestaDaTela24(AnnotationSession s) =>
    linhaQueComeca(s, 'Olhos de ressaca? Vá, de ressaca.').bottom + s.textShift;

/// O x do dedo da prancha 24: 58 % da largura da caixa.
const double dedoDaTela24 = 28 + 0.58 * 334;

/// Os desenhos das telas 24 e 24b: o chip, a etiqueta e os botões (no Noite, na cor clara).
Future<void> precacheTela24(WidgetTester tester) async {
  await precacheTela23(tester);
  await precacheSvgs(tester, const [
    AppIconsLeitor.arrowsVertical,
    AppIconsLeitor.pencilBold,
    AppIconsLeitor.chevronUp,
    AppIconsLeitor.trash,
  ]);
  await precacheSvgs(
    tester,
    const [AppIconsLeitor.arrowsVertical],
    colors: {AppColors.paper: AppColors.ink},
  );
  await precacheSvgs(
    tester,
    const [AppIconsLeitor.chevronUp, AppIconsLeitor.trash],
    colors: {AppColors.ink: AppColors.inkNight},
  );
}

/// O leitor na pág. 159 e o modo anotação.
Future<LeitorNaTela> _modo(
  WidgetTester tester,
  LivroNaEstante livro, {
  required bool golden,
}) async {
  setCanvasView(tester, logical: const Size(390, 844));
  await precacheTela24(tester);
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

/// Abre a tela 24: o Espaço e o dedo arrastado 3 linhas a partir da fresta de "Vá, de ressaca.", parado (o abridor
/// na tela). Devolve o dedo, para quem quiser soltar.
Future<(LeitorNaTela, TestGesture)> abrirTela24(
  WidgetTester tester,
  LivroNaEstante livro, {
  bool golden = false,
}) async {
  final t = await _modo(tester, livro, golden: golden);
  await tester.tap(_key('ann.toolShelf.space'));
  await tester.pump();
  final s = sessaoNaTela(tester);
  final fresta = frestaDaTela24(s);
  final g = await tracarL22(tester, [
    Offset(dedoDaTela24, fresta + 2),
    Offset(dedoDaTela24, fresta + 20),
    Offset(dedoDaTela24, fresta + 14 + 3 * s.geometry.lineHeight - 2),
  ], soltar: false);
  await _quadros(tester, 6);
  expect(s.opening.value?.lines, 3);
  return (t, g);
}

/// Abre a tela 24b: a nota salva na página do modo e a Caneta (a ferramenta de começo — D-187).
Future<LeitorNaTela> abrirTela24b(
  WidgetTester tester,
  LivroNaEstante livro, {
  bool golden = false,
}) async {
  final t = await _modo(tester, livro, golden: golden);
  final s = sessaoNaTela(tester);
  expect(s.notes, hasLength(1));
  expect(s.tool, AnnotationTool.pen);
  if (_passosDaNota[livro] == true) {
    await tester.tap(_key('ann.page.handNote.actions.collapse'));
    await tester.pump();
    await _quadros(tester, 6);
    await tester.tap(_key('ann.page.handNote.open'));
    await tester.pump();
    await _quadros(tester, 6);
    expect((s.notes.single.collapsed, s.canUndo), (false, true));
    // os dois passos gravam no banco: quem lê o banco depois vê a nota aberta, não o meio do caminho
    await esperarBancoL22(tester);
  }
  return t;
}
