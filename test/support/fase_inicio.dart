// T03 — o arnês das fases L01a1…L01a9 e L60: a Início da prancha 01 contra as referências medidas da 01 (`kRef01`), da
// 60 (`kRef60`) e das larguras 360/430 (`kRefInicio2Larguras`). Spec `docs/progresso/T03.md` §4: até a troca (T03.15)
// cada fase montava só as suas seções nos retângulos da prancha; desde a troca o arnês monta o APP inteiro (`/inicio`,
// a fixture `t01` — D-241) no canvas da prancha e as mesmas verificações valem na composição real.
// Keys do app = ids da prancha sem o prefixo (`i01.header.search` → `header.search`): as mesmas widgets servem a 01,
// a 01b e a 60. Retângulo de layout = sem os giros (o Chromium mede com os `transform` neutralizados); a caixa visual
// dos girados é conferida à parte, contra `visual`.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_inicio.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/scanner/presentation/scanner_camera.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../fixtures/home_mock_repository.dart';
import '../fixtures/overrides_do_mundo.dart';
import '../reference/inicio2/referencias_inicio2.dart';
import 'canvas.dart';
import 'capture.dart';
import 'fake_scanner_camera.dart';
import 'precache_svgs.dart';

/// Tamanho da prancha 01.
const Size canvas01 = Size(390, 2650);

/// A Key do app para o id da prancha (sem o prefixo `i01.`/`i60.`/`i01b.`).
String keyDoId(String id) => id.substring(id.indexOf('.') + 1);

/// O widget do app com a Key do id da prancha.
Finder ini(String id) => find.byKey(ValueKey<String>(keyDoId(id)));

/// Os ícones e as ilustrações da Início nova (sem pré-cache o golden sai sem eles).
Future<void> precacheInicio01(WidgetTester tester) async {
  await precacheAppIcons(tester); // com os da Início nova (AppIconsInicio)
  await precacheSvgs(tester, AppIllustrationsInicio.all);
}

/// Monta o app (`App.forTests()`, que abre em `/inicio`) no canvas de [prancha] (DPR [dpr], áreas seguras
/// [safeTop]/[safeBottom]) sob a raiz do golden, com o mundo de referência e a fonte da Início [repositorio] (a `t01`;
/// outra para os casos fora da prancha — os estados da G08, os formatos da D-254). [cronometro] troca o cronômetro do
/// mundo (sem sessão) pelo do teste — a 01b passa `overridesDa01b()`; [relogio], o relógio do mundo por um que o
/// teste move (o tempo do cronômetro).
Future<void> abrirInicio01(
  WidgetTester tester, {
  LeitorRefPrancha prancha = kRef01,
  double dpr = 3,
  double safeTop = 0,
  double safeBottom = 0,
  SyncHomeRepository repositorio = const HomeMockRepository(),
  Override? relogio,
  List<Override>? cronometro,
  List<Override> overrides = const [],
}) async {
  setCanvasView(
    tester,
    logical: prancha.canvas,
    dpr: dpr,
    safeTop: safeTop,
    safeBottom: safeBottom,
  );
  await precacheInicio01(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        relogio ?? relogioDoMundo,
        homeRepositoryProvider.overrideWithValue(repositorio),
        brandDoMundo,
        leitorDoMundo,
        destaquesDoMundo,
        ...(cronometro ?? cronometroDoMundo()),
        // o scanner abre por cima das abas: nos testes, sem o plugin da câmera
        scannerCameraProvider.overrideWithValue(FakeScannerCamera.new),
        ...overrides,
      ],
      child: const RepaintBoundary(key: goldenRootKey, child: App.forTests()),
    ),
  );
  await tester.pumpAndSettle();
}

/// O caminho da rota atual (`/inicio`, `/livro/…`): a prova de para onde um toque levou.
String rotaAtual(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(MainShell, skipOffstage: false)))
        .state
        .uri
        .path;

/// Toca no centro do widget do id e espera assentar. As colunas de texto não participam do hit test por si (só o
/// `Pressable` que as contém): a prova do toque é a rota ou a ação que se segue.
Future<void> tocar01(WidgetTester tester, String id) async {
  await tester.tap(ini(id), warnIfMissed: false);
  await tester.pumpAndSettle();
}

// ---- retângulos sem os giros ---------------------------------------------------------------------------------

/// O giro mais próximo acima de [box] (um `RenderTransform`), ou `null`.
RenderTransform? _giroAcima(RenderObject box) {
  for (var o = box.parent; o != null; o = o.parent) {
    if (o is RenderTransform) return o;
  }
  return null;
}

/// A origem de [box] no canvas com todos os `transform` neutralizados (como o passo A da medição).
Offset origemSemGiro(RenderBox box) {
  final giro = _giroAcima(box);
  if (giro == null) return box.localToGlobal(Offset.zero);
  final dentro = giro.child!;
  return origemSemGiro(giro) + box.localToGlobal(Offset.zero, ancestor: dentro);
}

/// O retângulo de layout do id (sem os giros).
Rect retanguloDeLayout(WidgetTester tester, String id) {
  final box = tester.renderObject<RenderBox>(ini(id));
  return origemSemGiro(box) & box.size;
}

/// A caixa visual do id: a envolvente dos 4 cantos com os giros aplicados. Nas capas giradas a Key do id fica no
/// slot sem giro e o filho do `Transform` leva `<id>#rot` (a convenção vinda da v1): a caixa
/// visual é a dele.
Rect caixaVisual(WidgetTester tester, String id) {
  final rot = find.byKey(ValueKey<String>('${keyDoId(id)}#rot'));
  final box = tester.renderObject<RenderBox>(
    rot.evaluate().isEmpty ? ini(id) : rot,
  );
  final cantos = [
    box.localToGlobal(Offset.zero),
    box.localToGlobal(Offset(box.size.width, 0)),
    box.localToGlobal(Offset(0, box.size.height)),
    box.localToGlobal(Offset(box.size.width, box.size.height)),
  ];
  final xs = cantos.map((c) => c.dx);
  final ys = cantos.map((c) => c.dy);
  return Rect.fromLTRB(
    xs.reduce(math.min),
    ys.reduce(math.min),
    xs.reduce(math.max),
    ys.reduce(math.max),
  );
}

/// Os ids com widget próprio das [secoes] (sem os `inline`, conferidos pelas linhas do pai). Uma seção sem nenhum
/// id (um nome errado) é erro: o gate não pode passar sem conferir nada.
List<String> idsDasSecoes(LeitorRefPrancha prancha, Iterable<String> secoes) =>
    [
      for (final s in secoes)
        ...switch (prancha.idsOfSection(s).toList()) {
          [] => throw ArgumentError.value(
            s,
            'secoes',
            'sem ids na ${prancha.tela}',
          ),
          final ids => ids,
        },
    ];

/// As camadas presas à tela (não rolam com o conteúdo): o degradê, a barra e a mini-barra do cronômetro (01b).
const Set<String> camadasFixas = {'bottomFade', 'nav', 'miniBar'};

/// Quanto somar ao y medido na tela para voltar à coordenada de layout da prancha: a prancha rolada (a 60, com o
/// `<main>` transladado de −[rolagem]) mede o layout sem a translação; as camadas fixas não rolam.
double _deslocamento(LeitorRefPrancha prancha, String id, double rolagem) =>
    camadasFixas.contains(keyDoId(prancha.elements[id]!.section)) ? 0 : rolagem;

/// Gate de geometria (prompt v2 §7, camada 1): cada id das [secoes] contra o retângulo de layout da prancha
/// (±0,5; ±1,0 em x/w para `textDependentX`) e, nos girados, a caixa visual contra `visual` (±0,5). Devolve as
/// falhas. [medir] troca a medida de um id (as exceções da fase, cada uma justificada no teste). Com a tela rolada
/// de [rolagem] (a 60), o layout medido volta à coordenada da prancha (+[rolagem], menos nas [camadasFixas]) e a
/// caixa visual — a da tela — confere contra `visual`, que na prancha rolada é a caixa transladada.
List<String> geometria01(
  WidgetTester tester,
  Iterable<String> secoes, {
  LeitorRefPrancha prancha = kRef01,
  Map<String, Rect Function(WidgetTester)> medir = const {},
  double rolagem = 0,
}) {
  final falhas = <String>[];
  for (final id in idsDasSecoes(prancha, secoes)) {
    final e = prancha.elements[id]!;
    final n = ini(id).evaluate().length;
    if (!medir.containsKey(id) && n != 1) {
      falhas.add('$id: $n widgets com a Key ${keyDoId(id)}');
      continue;
    }
    final m = (medir[id]?.call(tester) ?? retanguloDeLayout(tester, id))
        .translate(0, _deslocamento(prancha, id, rolagem));
    final tolX = prancha.textDependentX.contains(id) ? 1.0 : 0.5;
    void confere(String o, double g, double x, double tol) {
      if ((g - x).abs() > tol + 1e-6) {
        falhas.add(
          '$id.$o: ${g.toStringAsFixed(2)} ≠ ${x.toStringAsFixed(2)} (±$tol)',
        );
      }
    }

    confere('x', m.left, e.rect.left, tolX);
    confere('y', m.top, e.rect.top, 0.5);
    confere('w', m.width, e.rect.width, tolX);
    confere('h', m.height, e.rect.height, 0.5);
    final v = e.visual;
    if (v != null && !medir.containsKey(id)) {
      final cv = caixaVisual(tester, id);
      confere('visual.x', cv.left, v.left, tolX);
      confere('visual.y', cv.top, v.top, 0.5);
      confere('visual.w', cv.width, v.width, tolX);
      confere('visual.h', cv.height, v.height, 0.5);
    }
  }
  return falhas;
}

// ---- texto ---------------------------------------------------------------------------------------------------

Element _textoDe(WidgetTester tester, String id, String primeira) {
  for (final e
      in find
          .descendant(
            of: ini(id),
            matching: find.byType(AppText),
            matchRoot: true,
          )
          .evaluate()) {
    final w = e.widget as AppText;
    if (w.span
        .toPlainText(includeSemanticsLabels: false)
        .startsWith(primeira)) {
      return e;
    }
  }
  throw StateError('sem AppText "$primeira" em ${keyDoId(id)}');
}

/// O `AppText` (widget) de [id] cujo texto começa por [primeira] (o próprio id ou um descendente).
AppText appText01(WidgetTester tester, String id, [String primeira = '']) =>
    _textoDe(tester, id, primeira).widget as AppText;

/// As linhas de um `AppText` no canvas, sem os giros (a baseline e as pontas de cada linha).
List<AppTextLine> _noCanvas(RenderAppText r) {
  final origem = r.localToGlobal(Offset.zero);
  final semGiro = origemSemGiro(r);
  return [
    for (final l in r.debugLines())
      (
        text: l.text,
        left: semGiro.dx + (l.left - origem.dx),
        right: semGiro.dx + (l.right - origem.dx),
        baseline: semGiro.dy + (l.baseline - origem.dy),
      ),
  ];
}

/// As linhas de [id] no canvas, sem os giros (a baseline e as pontas de cada linha).
List<AppTextLine> linhas01(WidgetTester tester, String id, String primeira) =>
    _noCanvas(_textoDe(tester, id, primeira).renderObject! as RenderAppText);

/// As linhas do texto composto de [id] (`linesAll`: o texto dele com os trechos `inline`, que não têm widget
/// próprio): os `AppText` sob o id — menos os que estão dentro de outro id da prancha — juntados por baseline. O
/// título "Continue / sua história." são dois `AppText`, um por linha; um trecho na mesma linha pode ser um
/// `AppText.rich` ou um `AppText` ao lado (o espaço entre os dois volta quando há folga entre eles).
List<AppTextLine> linhasCompostas01(
  WidgetTester tester,
  String id, {
  LeitorRefPrancha prancha = kRef01,
}) {
  final outros = {
    for (final k in prancha.elements.keys)
      if (k.startsWith('$id.') &&
          prancha.elements[k]!.kind != LeitorRefKind.inline)
        ...ini(k).evaluate(),
  };
  bool dentroDeOutro(Element e) {
    var dentro = false;
    e.visitAncestorElements((a) {
      dentro = outros.contains(a);
      return !dentro;
    });
    return dentro;
  }

  final todas = [
    for (final e
        in find
            .descendant(
              of: ini(id),
              matching: find.byType(AppText),
              matchRoot: true,
            )
            .evaluate())
      if (!dentroDeOutro(e)) ..._noCanvas(e.renderObject! as RenderAppText),
  ];
  if (todas.isEmpty) throw StateError('sem AppText em ${keyDoId(id)}');
  todas.sort(
    (a, b) => (a.baseline - b.baseline).abs() <= 0.5
        ? a.left.compareTo(b.left)
        : a.baseline.compareTo(b.baseline),
  );
  final linhas = <AppTextLine>[todas.first];
  for (final l in todas.skip(1)) {
    final u = linhas.last;
    if ((l.baseline - u.baseline).abs() > 0.5) {
      linhas.add(l);
      continue;
    }
    final espaco =
        l.left - u.right > 1 &&
        !u.text.endsWith(' ') &&
        !l.text.startsWith(' ');
    linhas.last = (
      text: '${u.text}${espaco ? ' ' : ''}${l.text}',
      left: u.left,
      right: math.max(u.right, l.right),
      baseline: u.baseline,
    );
  }
  return linhas;
}

/// Gate de texto (camada 4): as linhas de cada id das [secoes] — texto, quebras, baseline (±0,5) e pontas (±1,0)
/// — contra `lines` (ou `linesAll`, no texto composto: [linhasCompostas01]); as linhas `hidden` (recortadas) também
/// existem no app e só não aparecem. Devolve as falhas. [rolagem]: como em [geometria01] (a baseline da prancha
/// rolada é a do layout).
List<String> texto01(
  WidgetTester tester,
  Iterable<String> secoes, {
  LeitorRefPrancha prancha = kRef01,
  double rolagem = 0,
}) {
  final falhas = <String>[];
  for (final id in idsDasSecoes(prancha, secoes)) {
    final e = prancha.elements[id]!;
    final composto = e.linesAll.isNotEmpty;
    final esperadas = composto ? e.linesAll : e.lines;
    if (esperadas.isEmpty) continue;
    final List<AppTextLine> got;
    RenderAppText? render;
    try {
      if (composto) {
        got = linhasCompostas01(tester, id, prancha: prancha);
      } else {
        render =
            _textoDe(tester, id, esperadas.first.text).renderObject!
                as RenderAppText;
        got = _noCanvas(render);
      }
    } on StateError catch (x) {
      falhas.add('$id: ${x.message}');
      continue;
    }
    // `text-overflow: ellipsis`: a prancha mede o texto inteiro ("Orgulho e Preconceito", até 351,4) e mostra
    // "Orgulho e Precon…"; o app tem o prefixo visível e o "…" pintado. A linha confere pelo prefixo, a baseline e o
    // início (o ponto do corte tem teste próprio na fase).
    final cortada =
        (render?.debugDidExceedMaxLines ?? false) &&
        got.length == 1 &&
        esperadas.length == 1;
    final g = got.map((l) => l.text).toList();
    final x = esperadas.map((l) => l.text).toList();
    if (cortada
        ? !(x.single.startsWith(g.single) && g.single.length < x.single.length)
        : g.join('|') != x.join('|')) {
      falhas.add('$id: $g ≠ $x${cortada ? ' (cortada)' : ''}');
      continue;
    }
    final dy = _deslocamento(prancha, id, rolagem);
    for (var i = 0; i < got.length; i++) {
      final r = esperadas[i];
      if ((got[i].baseline + dy - r.baseline).abs() > 0.5 ||
          (got[i].left - r.left).abs() > 1 ||
          (!cortada && (got[i].right - r.right).abs() > 1)) {
        falhas.add(
          '$id[$i] "${r.text}": baseline ${(got[i].baseline + dy).toStringAsFixed(2)}/${r.baseline}, '
          '${got[i].left.toStringAsFixed(2)}–${got[i].right.toStringAsFixed(2)} ≠ ${r.left}–${r.right}',
        );
      }
    }
  }
  return falhas;
}

// ---- semântica -------------------------------------------------------------------------------------------------

/// O nó de semântica do widget do id (o mais próximo que o cobre).
SemanticsNode noDe(WidgetTester tester, String id) =>
    tester.getSemantics(ini(id));

/// Os links (`<a>`) dentro da `<section aria-label="[rotulo]">` (o nó da seção, não o do título homônimo), em
/// pré-ordem: no app há outros links na tela (a barra, as outras seções).
List<SemanticsNode> linksDaSecao(String rotulo) {
  final secao = find.semantics
      .byLabel(rotulo)
      .evaluate()
      .where((n) => !n.getSemanticsData().flagsCollection.isHeader)
      .single;
  final links = <SemanticsNode>[];
  void visitar(SemanticsNode n) {
    n.visitChildren((c) {
      if (c.getSemanticsData().flagsCollection.isLink) links.add(c);
      visitar(c);
      return true;
    });
  }

  visitar(secao);
  return links;
}

// ---- captura (camada 3) ----------------------------------------------------------------------------------------

/// Captura a raiz do golden @3x e, com `BOOKNEST_CAPTURAS=<pasta>`, grava `<nome>.png` lá (o gate visual roda
/// fora do teste: `tools/compare_images.py --rect` contra o PNG da prancha, no recorte da fase).
Future<ui.Image> capturar01(WidgetTester tester, String nome) async {
  final image = await captureAt(tester, find.byKey(goldenRootKey));
  final pasta = Platform.environment['BOOKNEST_CAPTURAS'];
  if (pasta != null) {
    final png = await tester.runAsync(
      () => image.toByteData(format: ui.ImageByteFormat.png),
    );
    Directory(pasta).createSync(recursive: true);
    File('$pasta${Platform.pathSeparator}$nome.png')
        .writeAsBytesSync(png!.buffer.asUint8List());
  }
  return image;
}
