// T03 — o arnês das fases L01a1…L01a9 e L60: a Início nova contra as referências medidas da prancha 01 (`kRef01`) e
// da 60 (`kRef60`). Spec `docs/progresso/T03.md` §4:
// - antes da troca (`inicioNoApp == false`), cada teste monta as seções que confere num canvas de 390 × 2650 (o da
//   prancha), cada uma no retângulo da prancha, com a fixture `t01` — a Início da v1 continua no app;
// - depois da troca, o mesmo teste monta o app inteiro (`/inicio`) e as mesmas verificações valem na composição real.
// Keys do app = ids da prancha sem o prefixo (`i01.header.search` → `header.search`): as mesmas widgets servem a 01,
// a 01b e a 60. Retângulo de layout = sem os giros (o Chromium mede com os `transform` neutralizados); a caixa visual
// dos girados é conferida à parte, contra `visual`.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_inicio.dart';
import 'package:app_leitura/core/preferences/brand_preference.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/telas/inicio01.dart';
import '../reference/inicio2/referencias_inicio2.dart';
import 'canvas.dart';
import 'capture.dart';
import 'precache_svgs.dart';

/// `true` depois da troca da T03 (spec §4): o arnês monta o app inteiro.
const bool inicioNoApp = false;

/// Tamanho da prancha 01.
const Size canvas01 = Size(390, 2650);

/// A Key do app para o id da prancha (sem o prefixo `i01.`/`i60.`/`i01b.`).
String keyDoId(String id) => id.substring(id.indexOf('.') + 1);

/// O widget do app com a Key do id da prancha.
Finder ini(String id) => find.byKey(ValueKey<String>(keyDoId(id)));

/// A fonte da fixture `t01` (síncrona, como a da v1 — D-09).
final class RepositorioT01 implements SyncHomeRepository {
  const RepositorioT01();

  @override
  HomeSnapshot snapshot(DateTime now) => TelaInicio01.snapshot(now);

  @override
  Stream<HomeSnapshot> watch(DateTime Function() clock) => const Stream.empty();
}

/// Os overrides da Início da prancha 01 (relógio de referência, fixture `t01`, `brand` na memória). [repositorio]:
/// outra fonte para os casos fora da prancha (os estados da G08, os formatos da D-254).
List<Override> overridesDaT01({
  SyncHomeRepository repositorio = const RepositorioT01(),
}) => [
  clockProvider.overrideWithValue(() => TelaInicio01.agora),
  homeRepositoryProvider.overrideWithValue(repositorio),
  brandStoreProvider.overrideWith((ref) => MemoryBrandStore()),
];

/// Os ícones e as ilustrações da Início nova (sem pré-cache o golden sai sem eles).
Future<void> precacheInicio01(WidgetTester tester) async {
  await precacheAppIcons(tester); // com os da Início nova (AppIconsInicio)
  await precacheSvgs(tester, AppIllustrationsInicio.all);
}

/// Monta as [secoes] (id da seção da prancha → widget) nos retângulos de [prancha], no canvas da prancha (DPR 3),
/// sob a raiz do golden. `larguraTotal`: seções que vão de 0 a 390 (o carrossel do Para você), com a Key da seção
/// num retângulo à parte, como a `HomeScreen` faz.
Future<void> abrirSecoes01(
  WidgetTester tester,
  Map<String, Widget> secoes, {
  LeitorRefPrancha prancha = kRef01,
  Set<String> larguraTotal = const {},
  List<Override> overrides = const [],
  SyncHomeRepository repositorio = const RepositorioT01(),
}) async {
  assert(!inicioNoApp, 'depois da troca, use o app (abrirInicio01)');
  setCanvasView(tester, logical: prancha.canvas);
  await precacheInicio01(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...overridesDaT01(repositorio: repositorio),
        ...overrides,
      ],
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData(size: prancha.canvas, devicePixelRatio: 3),
          child: RepaintBoundary(
            key: goldenRootKey,
            child: ColoredBox(
              color: AppColors.paper,
              child: Stack(
                children: [
                  for (final MapEntry(key: id, value: w) in secoes.entries)
                    if (larguraTotal.contains(id)) ...[
                      Positioned.fromRect(
                        rect: prancha.sections[id]!,
                        child: IgnorePointer(
                          child: SizedBox.expand(
                            key: ValueKey<String>(keyDoId(id)),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: prancha.sections[id]!.top,
                        width: prancha.canvas.width,
                        child: w,
                      ),
                    ] else
                      Positioned(
                        left: prancha.sections[id]!.left,
                        top: prancha.sections[id]!.top,
                        width: prancha.sections[id]!.width,
                        child: w,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
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

/// A caixa visual do id: a envolvente dos 4 cantos com os giros aplicados.
Rect caixaVisual(WidgetTester tester, String id) {
  final box = tester.renderObject<RenderBox>(ini(id));
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

/// Os ids com widget próprio das [secoes] (sem os `inline`, conferidos pelas linhas do pai).
List<String> idsDasSecoes(LeitorRefPrancha prancha, Iterable<String> secoes) =>
    [for (final s in secoes) ...prancha.idsOfSection(s)];

/// Gate de geometria (prompt v2 §7, camada 1): cada id das [secoes] contra o retângulo de layout da prancha
/// (±0,5; ±1,0 em x/w para `textDependentX`) e, nos girados, a caixa visual contra `visual` (±0,5). Devolve as
/// falhas. [medir] troca a medida de um id (as exceções da fase, cada uma justificada no teste).
List<String> geometria01(
  WidgetTester tester,
  Iterable<String> secoes, {
  LeitorRefPrancha prancha = kRef01,
  Map<String, Rect Function(WidgetTester)> medir = const {},
}) {
  final falhas = <String>[];
  for (final id in idsDasSecoes(prancha, secoes)) {
    final e = prancha.elements[id]!;
    final n = ini(id).evaluate().length;
    if (!medir.containsKey(id) && n != 1) {
      falhas.add('$id: $n widgets com a Key ${keyDoId(id)}');
      continue;
    }
    final m = medir[id]?.call(tester) ?? retanguloDeLayout(tester, id);
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
/// existem no app e só não aparecem. Devolve as falhas.
List<String> texto01(
  WidgetTester tester,
  Iterable<String> secoes, {
  LeitorRefPrancha prancha = kRef01,
}) {
  final falhas = <String>[];
  for (final id in idsDasSecoes(prancha, secoes)) {
    final e = prancha.elements[id]!;
    final composto = e.linesAll.isNotEmpty;
    final esperadas = composto ? e.linesAll : e.lines;
    if (esperadas.isEmpty) continue;
    final List<AppTextLine> got;
    try {
      got = composto
          ? linhasCompostas01(tester, id, prancha: prancha)
          : linhas01(tester, id, esperadas.first.text);
    } on StateError catch (x) {
      falhas.add('$id: ${x.message}');
      continue;
    }
    final g = got.map((l) => l.text).toList();
    final x = esperadas.map((l) => l.text).toList();
    if (g.join('|') != x.join('|')) {
      falhas.add('$id: $g ≠ $x');
      continue;
    }
    for (var i = 0; i < got.length; i++) {
      final r = esperadas[i];
      if ((got[i].baseline - r.baseline).abs() > 0.5 ||
          (got[i].left - r.left).abs() > 1 ||
          (got[i].right - r.right).abs() > 1) {
        falhas.add(
          '$id[$i] "${r.text}": baseline ${got[i].baseline.toStringAsFixed(2)}/${r.baseline}, '
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
