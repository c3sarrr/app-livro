import 'dart:math' as math;

import 'package:app_leitura/core/design_system/painters/chromium_dash.dart';
import 'package:app_leitura/core/design_system/painters/goal_dial_painter.dart';
import 'package:app_leitura/core/design_system/painters/hatch_painter.dart';
import 'package:app_leitura/core/design_system/painters/ring_progress_painter.dart';
import 'package:app_leitura/core/design_system/painters/top_border_crescent_painter.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_inicio.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout.dart';
import '../support/canvas.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

/// F13 · 13.4 — checklist manual anti-simplificação, medido na ÁRVORE REAL do app (canvas 390 × 2390), não só por
/// busca de texto no código: sombras duras, rotações, bordas, ícones SVG, famílias/pesos de fonte, pintores e as
/// quebras/reticências especiais do arquivo.
void main() {
  setUpAll(loadAppFonts);

  String f(double v) => v.toStringAsFixed(2);

  testWidgets(
    'sombras duras: exatamente as 7 do arquivo, todas com blur 0 e spread 0',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final shadows = <String>[];
      for (final box in tester.widgetList<DecoratedBox>(
        find.byType(DecoratedBox),
      )) {
        final d = box.decoration;
        if (d is! BoxDecoration || d.boxShadow == null) continue;
        for (final s in d.boxShadow!) {
          expect(s.blurRadius, 0, reason: 'sombra com blur');
          expect(s.spreadRadius, 0, reason: 'sombra com spread');
          expect(s.color, AppColors.ink, reason: 'sombra fora da cor ink');
          shadows.add('${f(s.offset.dx)}/${f(s.offset.dy)}');
        }
      }
      shadows.sort();
      debugPrint('[F13 sombras] ${shadows.length} sombras duras: $shadows');
      // hero 4/4 · dia 4/4 · capa Dom Casmurro 3/3 · capas "Também lendo" 2/2 (×2) · barra 0/4 · FAB 0/4.
      expect(shadows, [
        '0.00/4.00',
        '0.00/4.00',
        '2.00/2.00',
        '2.00/2.00',
        '3.00/3.00',
        '4.00/4.00',
        '4.00/4.00',
      ]);
    },
  );

  testWidgets(
    'rotações: −3° (capa do hero), −4° e +3° (capas de "Também lendo")',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final angles = <double>[];
      for (final t in tester.widgetList<Transform>(find.byType(Transform))) {
        // O slot de FAB do `Scaffold` (framework) sempre monta um `RotationTransition` de −45° SEM filho: não pinta
        // nada (o FAB do app é o `ScannerFab`, desenhado pelo `MainShell`; `FloatingActionButton` é proibido).
        if (t.child == null) continue;
        final m = t.transform.storage;
        final angle = math.atan2(m[1], m[0]) * 180 / math.pi;
        if (angle.abs() > 0.01) {
          angles.add(double.parse(angle.toStringAsFixed(3)));
          final chain = <String>[];
          tester.element(find.byWidget(t)).visitAncestorElements((e) {
            final k = e.widget.key;
            chain.add(
              k is ValueKey
                  ? '${e.widget.runtimeType}[${k.value}]'
                  : '${e.widget.runtimeType}',
            );
            return chain.length < 14;
          });
          debugPrint(
            '[F13 rotações]   ${angle.toStringAsFixed(3)}° → filho ${t.child.runtimeType}; '
            'ancestrais: ${chain.join(' < ')}',
          );
        }
      }
      angles.sort();
      debugPrint('[F13 rotações] $angles');
      expect(angles, [-4.0, -3.0, 3.0]);
    },
  );

  testWidgets('bordas: só 1, 1,2 e 1,5 px (nunca arredondadas)', (
    tester,
  ) async {
    setCanvasView(tester);
    await pumpApp(tester);
    final widths = <double, int>{};
    for (final box in tester.widgetList<DecoratedBox>(
      find.byType(DecoratedBox),
    )) {
      final d = box.decoration;
      if (d is! BoxDecoration || d.border == null) continue;
      final b = d.border! as Border;
      for (final side in [b.top, b.right, b.bottom, b.left]) {
        if (side.style == BorderStyle.none || side.width == 0) continue;
        widths.update(side.width, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    debugPrint('[F13 bordas] lados por espessura: $widths');
    expect(widths.keys.toSet().difference({1.0, 1.2, 1.5, 2.0}), isEmpty);
    expect(widths.containsKey(1.2), isTrue);
    expect(widths.containsKey(1.5), isTrue);
    expect(widths.containsKey(1.0), isTrue);
  });

  testWidgets(
    'ícones: os 18 SVGs do pacote são usados (14 na Início + 4 extrapolados D-07) e a lupa da prancha 01 (T03)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      Set<String> used() => {
        for (final s in tester.widgetList<AppSvg>(
          find.byType(AppSvg, skipOffstage: false),
        ))
          s.asset,
      };
      final inicio = used();
      final all = {...inicio};
      for (final tab in ['library', 'clubs', 'profile']) {
        await tester.tap(find.byKey(ValueKey('nav.$tab')));
        await tester.pumpAndSettle();
        all.addAll(used());
      }
      debugPrint(
        '[F13 ícones] Início: ${inicio.length} · união das 4 abas: ${all.length} de ${AppIcons.all.length}',
      );
      expect(AppIcons.all.length, 18);
      expect(all.difference(AppIcons.all.toSet()), {AppIconsInicio.search});
      expect(AppIcons.all.toSet().difference(all), isEmpty);
      expect(inicio.length, 15);
      // Nenhum CustomPaint desenha ícone: os pintores existentes são só os da lista abaixo.
    },
  );

  testWidgets(
    'fontes: só as famílias do pacote; Figtree ≤ 700; Bricolage 800 com a família do tamanho',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final styles = <String, int>{};
      void walk(InlineSpan span, TextStyle? parent) {
        if (span is! TextSpan) return;
        final style = parent == null
            ? span.style
            : (span.style == null ? parent : parent.merge(span.style));
        if ((span.text ?? '').isNotEmpty && style != null) {
          final family = style.fontFamily!;
          final weight = (style.fontWeight ?? FontWeight.w400).value;
          final size = style.fontSize!;
          if (family == 'Figtree') {
            expect(weight, lessThanOrEqualTo(700), reason: '"${span.text}"');
          } else if (family.startsWith('Bricolage')) {
            expect(weight, 800, reason: '"${span.text}"');
            final opsz = int.parse(family.substring('Bricolage'.length));
            expect(
              opsz,
              size < 12 ? 12 : size.round(),
              reason: '"${span.text}"',
            );
          } else {
            expect(family, 'InstrumentSerif', reason: '"${span.text}"');
            expect(weight, 400, reason: '"${span.text}"');
          }
          expect(
            style.height,
            isNotNull,
            reason: 'height explícito: "${span.text}"',
          );
          final key = '$family w$weight ${size}px';
          styles.update(key, (v) => v + 1, ifAbsent: () => 1);
        }
        for (final c in span.children ?? const <InlineSpan>[]) {
          walk(c, style);
        }
      }

      for (final t in tester.widgetList<AppText>(find.byType(AppText))) {
        walk(t.span, null);
      }
      final keys = styles.keys.toList()..sort();
      debugPrint(
        '[F13 fontes] ${keys.length} combinações família/peso/tamanho em uso:',
      );
      for (final k in keys) {
        debugPrint('[F13 fontes]   $k × ${styles[k]}');
      }
      expect(styles.keys.where((k) => k.startsWith('Figtree w800')), isEmpty);
    },
  );

  testWidgets(
    'pintores: hachuras, tracejados, meias-luas, mostrador e anéis do arquivo',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final counts = <String, int>{};
      for (final p in tester.widgetList<CustomPaint>(
        find.byType(CustomPaint),
      )) {
        final painter = p.painter;
        if (painter == null) continue;
        counts.update(
          painter.runtimeType.toString(),
          (v) => v + 1,
          ifAbsent: () => 1,
        );
      }
      debugPrint('[F13 pintores] $counts');
      // 8 = 7 trilhos da semana + 1 trilho do clube. O HTML original tem 8 `repeating-linear-gradient(135deg…)`
      // (o texto do checklist da F13 diz "7 hachuras": contagem só dos trilhos da semana; o arquivo vence).
      expect(counts[(HatchPainter).toString()], 8, reason: 'hachuras');
      expect(
        counts[(ChromiumDashPainter).toString()],
        2,
        reason: 'meta tracejada + perfuração',
      );
      expect(counts[(GoalDialPainter).toString()], 1);
      expect(
        counts[(RingProgressPainter).toString()],
        2,
        reason: 'anéis de "Também lendo"',
      );
      expect(
        counts[(TopBorderCrescentPainter).toString()],
        7,
        reason: 'meias-luas das 7 barras',
      );
    },
  );

  testWidgets(
    'quebras especiais e reticências do arquivo, lidas do app em execução',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      List<String> linesOf(String id) {
        final renders =
            find
                .descendant(
                  of: find.byKey(ValueKey<String>(id)),
                  matching: find.byType(AppText),
                  matchRoot: true,
                )
                .evaluate()
                .map((e) => e.renderObject! as RenderAppText)
                .toList()
              ..sort(
                (a, b) => a
                    .localToGlobal(Offset.zero)
                    .dy
                    .compareTo(b.localToGlobal(Offset.zero).dy),
              );
        return [for (final r in renders) ...r.debugLines().map((l) => l.text)];
      }

      // Cada quebra esperada do checklist deve existir no arquivo (kRefLayout) e ser reproduzida pelo app.
      final expected = <String, List<String>>{
        'capa Dom Casmurro (autor)': ['MACHADO DE', 'ASSIS'],
        'capa Memórias Póstumas': ['Memórias', 'Póstumas de', 'Brás Cubas'],
        'meta do dia': ['Faltam 12 min para fechar', 'a meta de hoje.'],
        'O Alienista (autor · formato)': ['Machado de Assis ·', 'PDF'],
        'O Alienista (selo)': ['Quero', 'ler'],
      };
      for (final MapEntry(key: name, value: lines) in expected.entries) {
        final ids = [
          for (final e in kRefLayout.entries)
            if (e.value.lines.map((l) => l.text).toList().toString() ==
                lines.toString())
              e.key,
        ];
        expect(ids, isNotEmpty, reason: '$name: quebra não existe no arquivo');
        for (final id in ids) {
          expect(linesOf(id), lines, reason: '$name ($id)');
        }
        debugPrint('[F13 quebras] $name → $lines  ids: ${ids.join(', ')}');
      }

      // Reticências ("Orgulho e Precon…", "Memórias Póstu…"): linha única truncada, nos 2 ids do arquivo.
      for (final id in kEllipsized) {
        final renders = find
            .descendant(
              of: find.byKey(ValueKey<String>(id)),
              matching: find.byType(AppText),
              matchRoot: true,
            )
            .evaluate()
            .map((e) => e.renderObject! as RenderAppText)
            .toList();
        expect(renders.single.debugDidExceedMaxLines, isTrue, reason: id);
        debugPrint(
          '[F13 reticências] $id: texto "${kRefLayout[id]!.lines.first.text}" truncado em 1 linha → ${linesOf(id)}',
        );
      }
    },
  );
}
