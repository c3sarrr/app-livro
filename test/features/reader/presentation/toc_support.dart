// G15 — a folha do sumário sozinha nos testes de widget: uma `TocView` montada à mão (o mundo da tela 27 em miniatura)
// e a mesa que registra o que a folha pediu.
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation_stats.dart';
import 'package:app_leitura/features/reader/application/toc_view.dart';
import 'package:app_leitura/features/reader/domain/bookmark.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/toc_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/canvas.dart';
import '../../../support/personal_builders.dart';
import '../../../support/precache_svgs.dart';

Finder chave(String k) => find.byKey(ValueKey<String>(k));

/// O retângulo medido perto do esperado (as somas de 1,5, 81,1… não dão exato em ponto flutuante).
Matcher perto(Rect r, {double tol = 0.01}) => predicate<Rect>(
  (m) =>
      (m.left - r.left).abs() <= tol &&
      (m.top - r.top).abs() <= tol &&
      (m.width - r.width).abs() <= tol &&
      (m.height - r.height).abs() <= tol,
  'perto de $r',
);

/// O que a folha pediu.
final class MesaDoSumario {
  var fechou = 0;
  final capitulos = <TocRow>[];
  final abertos = <TocBookmarkCard>[];
  final fitas = <TocBookmarkCard>[];
  var clube = 0;
}

/// Uma linha de capítulo montada à mão.
TocRow linha(
  int capitulo, {
  String? numeral,
  String? titulo,
  int? pagina,
  bool lido = false,
  bool atual = false,
  double progresso = 0,
  ChapterMarks marcas = const ChapterMarks(count: 0, symbols: []),
  bool tocavel = true,
}) => TocRow(
  kind: TocRowKind.chapter,
  entry: capitulo,
  chapter: capitulo,
  numeral: numeral ?? 'C${capitulo + 1}',
  title: titulo ?? 'Capítulo ${capitulo + 1}',
  page: pagina ?? capitulo * 5 + 1,
  marks: marcas,
  read: lido,
  current: atual,
  progress: progresso,
  target: tocavel ? (spine: capitulo + 1, offset: 0) : null,
);

Bookmark marca(
  int n, {
  int pagina = 3,
  String? excerto = 'Uma noite destas…',
}) => Bookmark(
  id: idTeste(n),
  meta: RecordMeta(
    userId: usuarioTeste,
    createdAt: t0Teste,
    updatedAt: t0Teste,
    version: Hlc(t0Teste.millisecondsSinceEpoch, 0, 'aparelhoA'),
  ),
  userBookId: idTeste(1),
  locator: EpubLocator(
    sha: shaTeste,
    spine: 1,
    offset: n,
    refPage: pagina,
    progression: 0.1,
  ),
  refPage: pagina,
  chapterIndex: 0,
  excerpt: excerto,
);

TocBookmarkCard cartao(
  int n, {
  int pagina = 3,
  bool marcada = true,
  bool aqui = false,
  String? capitulo = 'cap. I · Do título',
  String? excerto = 'Uma noite destas, vindo da cidade para o Engenho Novo, encontrei no trem da Central…',
  String data = 'marcada em 2 set',
}) => TocBookmarkCard(
  bookmark: marca(n, pagina: pagina, excerto: excerto),
  marked: marcada,
  page: pagina,
  chapter: capitulo,
  here: aqui,
  excerpt: excerto,
  date: data,
  target: (spine: 1, offset: n),
);

/// O sumário em miniatura: [n] capítulos de uma linha, o atual em [atual] (lidos antes dele).
TocView vista({
  int n = 20,
  int? atual = 7,
  List<TocRow>? linhas,
  TocClubStrip? clube = (
    kicker: 'LEITORAS DE CAPITU · QUI 24/9',
    goal: 'Até o cap. L · faltam 18',
  ),
  List<TocBookmarkCard> cartoes = const [],
  int? capitulos = 148,
}) {
  final rows =
      linhas ??
      [
        for (var c = 0; c < n; c++)
          linha(
            c,
            lido: atual != null && c < atual,
            atual: c == atual,
            progresso: c == atual ? 18 / 44 : 0,
          ),
      ];
  final i = rows.indexWhere((r) => r.current);
  return TocView(
    subtitle: 'Dom Casmurro · 148 capítulos',
    chapters: capitulos,
    bookmarks: cartoes.where((c) => c.marked).length,
    rows: rows,
    currentRow: i < 0 ? null : i,
    refPage: 159,
    club: clube,
    cards: cartoes,
  );
}

Future<MesaDoSumario> montarSumario(
  WidgetTester tester, {
  bool open = true,
  TocView? view,
  bool semVista = false,
  ReaderPaper papel = ReaderPaper.creme,
  Size tela = const Size(390, 844),
}) async {
  final m = MesaDoSumario();
  setCanvasView(tester, logical: tela);
  await precacheSvgs(tester, AppIconsLeitor.all);
  // uma folha nova a cada montagem (como ao reabrir no leitor)
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(
    folhaDoSumario(
      m,
      open: open,
      view: semVista ? null : view ?? vista(),
      papel: papel,
      tela: tela,
    ),
  );
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pump();
  return m;
}

Widget folhaDoSumario(
  MesaDoSumario m, {
  required bool open,
  TocView? view,
  ReaderPaper papel = ReaderPaper.creme,
  Size tela = const Size(390, 844),
}) => MediaQuery(
  data: MediaQueryData(size: tela),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: TocSheet(
      open: open,
      view: view,
      palette: ReaderChromePalette.of(papel),
      brand: AppColors.lavender,
      onClose: () => m.fechou++,
      onChapter: m.capitulos.add,
      onBookmark: m.abertos.add,
      onRibbon: m.fitas.add,
      onClub: () => m.clube++,
    ),
  ),
);

/// Anotações para as marcas: um grifo amarelo, uma nota e uma tinta coral (o que dá os 3 símbolos do cap. XXXII).
ChapterMarks marcasDoXxxii() => const ChapterMarks(
  count: 5,
  symbols: [
    MarkSymbol(AnnotationKind.highlight, '#FED170'),
    MarkSymbol(AnnotationKind.drawing, '#FF552E'),
    MarkSymbol(AnnotationKind.handwriting, null),
  ],
);
