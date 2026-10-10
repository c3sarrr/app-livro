import 'dart:convert';
import 'dart:io';
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
import 'package:app_leitura/features/home/presentation/covers/senhora_mini_cover.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/inicio2/reference_layout_001_inicio.dart';
import '../support/canvas.dart';
import '../support/fase_inicio.dart' show keyDoId;
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

/// F13 · 13.4 — checklist manual anti-simplificação, medido na ÁRVORE REAL do app, não só por busca de texto no
/// código: sombras duras, rotações, bordas, ícones SVG, famílias/pesos de fonte, pintores e as quebras/reticências
/// especiais do arquivo. Desde a T03 (D-240) a Início da prancha 01 (canvas 390 × 2650, `kRef01`).
/// O layout medido da prancha 01 (versionado): os estilos e o CSS de cada elemento.
Map<String, dynamic> _elementos01() =>
    (jsonDecode(
          File('docs/design/medicao/inicio2/layout/layout_001_inicio.json')
              .readAsStringSync(),
        ) as Map<String, dynamic>)['elements']
        as Map<String, dynamic>;

/// Os arquivos SVG que a prancha 01 usa (o catálogo da T02): ícones, a capa e os 2 gráficos medidos.
Set<String> _svgsDa01() {
  final catalogo = jsonDecode(
    File('docs/design/medicao/inicio2/svg_catalogo.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  return {
    for (final uso in (catalogo['usos'] as Map<String, dynamic>).values)
      if ((uso as Map<String, dynamic>)['001_inicio'] case {
        'arquivo': final String arquivo,
      })
        arquivo,
  };
}

void main() {
  setUpAll(loadAppFonts);

  String f(double v) => v.toStringAsFixed(2);

  testWidgets(
    'sombras duras: exatamente as 11 da prancha 01, todas com blur 0 e spread 0',
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
      // As da prancha 01 (box-shadow de cada elemento medido, todas tinta, sem blur e sem spread).
      final prancha = <String>[
        for (final e in _elementos01().values)
          if ((e as Map<String, dynamic>)['style'] case {
            'shadow': final String sombra,
          })
            (() {
              final m = RegExp(r'^#1A1714 ([\d.]+)px ([\d.]+)px 0px 0px$')
                  .firstMatch(sombra)!;
              return '${f(double.parse(m[1]!))}/${f(double.parse(m[2]!))}';
            })(),
      ]..sort();
      // herói, dia e revisão 4/4 · capa do Dom Casmurro 3/3 · capas de "Também lendo" 2/2 (×2) · cartas da revisão
      // 2/2 (×3) · barra 0/4 · FAB 0/4.
      expect(prancha, [
        '0.00/4.00',
        '0.00/4.00',
        '2.00/2.00',
        '2.00/2.00',
        '2.00/2.00',
        '2.00/2.00',
        '2.00/2.00',
        '3.00/3.00',
        '4.00/4.00',
        '4.00/4.00',
        '4.00/4.00',
      ]);
      expect(shadows, prancha);
    },
  );

  testWidgets(
    'rotações: −3° (capa do herói), −4° e +3° (capas de "Também lendo"), −12°, +8° e −2° (cartas da revisão)',
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
      final prancha = <double>[
        for (final e in _elementos01().values)
          for (final m in RegExp(
            r'rotate\(([-\d.]+)deg\)',
          ).allMatches(((e as Map<String, dynamic>)['css'] as String?) ?? ''))
            double.parse(m[1]!),
      ]..sort();
      expect(prancha, [-12.0, -4.0, -3.0, -2.0, 3.0, 8.0]);
      expect(angles, prancha);
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
    'ícones: os 18 SVGs do pacote são usados (D-07) e a Início usa exatamente os SVGs da prancha 01 (os 2 gráficos medidos — anel e mostrador — são pintores)',
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
      debugPrint('[F13 ícones] Início: ${inicio.toList()..sort()}');
      debugPrint(
        '[F13 ícones] fora do pacote: ${all.difference(AppIcons.all.toSet()).toList()..sort()}',
      );
      debugPrint(
        '[F13 ícones] do pacote sem uso: ${AppIcons.all.toSet().difference(all).toList()..sort()}',
      );
      expect(AppIcons.all.length, 18);
      expect(AppIcons.all.toSet().difference(all), isEmpty);
      final prancha = _svgsDa01();
      final graficos = prancha
          .where(
            (a) => a.startsWith('docs/design/medicao/inicio2/svg_graficos/'),
          )
          .toSet();
      expect(graficos.map((a) => a.split('/').last), {
        'anel_progresso_livro.svg',
        'mostrador_meta_diaria.svg',
      });
      expect(inicio, prancha.difference(graficos));
      expect(inicio, hasLength(21));
      // Só a Início usa SVG fora do pacote da v1: os 6 ícones novos e a capa do Dom Casmurro (T02/T03).
      expect(all.difference(AppIcons.all.toSet()), {
        AppIconsInicio.search,
        AppIconsInicio.bookPaper,
        AppIconsInicio.play,
        AppIconsInicio.sparkleYellow,
        AppIconsInicio.sparkleSolidYellow,
        AppIconsInicio.stopwatch,
        'assets/illustrations/inicio2/il_capa_dom_casmurro.svg',
      });
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
      // 8 = 7 trilhos da semana + 1 trilho do clube. A prancha 01 tem 8 `repeating-linear-gradient(135deg…)`
      // (o texto do checklist da F13 diz "7 hachuras": contagem só dos trilhos da semana; o arquivo vence).
      final css = [
        for (final e in _elementos01().values)
          ((e as Map<String, dynamic>)['css'] as String?) ?? '',
      ];
      expect(
        css.where((c) => c.contains('repeating-linear-gradient(135deg')),
        hasLength(8),
      );
      expect(css.where((c) => c.contains('px dashed')), hasLength(2));
      expect(counts[(HatchPainter).toString()], 8, reason: 'hachuras');
      expect(
        counts[(ChromiumDashPainter).toString()],
        2,
        reason: 'meta tracejada + perfuração',
      );
      expect(counts[(GoalDialPainter).toString()], 1);
      expect(
        counts[(RingProgressPainter).toString()],
        1,
        reason: 'o anel do Orgulho (o Brás Cubas tem o "play" — D-253)',
      );
      expect(
        counts[(TopBorderCrescentPainter).toString()],
        7,
        reason: 'meias-luas das 7 barras',
      );
      expect(
        counts[(ArchBorderPainter).toString()],
        1,
        reason: 'o arco da Senhora (border-bottom: none)',
      );
      // E nenhum outro pintor.
      expect(counts.keys.toSet(), {
        for (final t in [
          HatchPainter,
          ChromiumDashPainter,
          GoalDialPainter,
          RingProgressPainter,
          TopBorderCrescentPainter,
          ArchBorderPainter,
        ])
          t.toString(),
      });
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

      // Cada quebra esperada do checklist deve existir na prancha 01 (kRef01, o texto composto quando há filhos
      // inline) e ser reproduzida pelo app.
      final expected = <String, List<String>>{
        'capa Brás Cubas (título)': ['Brás', 'Cubas'],
        'capa Orgulho e Preconceito (título)': ['Orgulho e', 'Preconceito'],
        'meta do dia': ['Faltam 12 min para fechar', 'a meta de hoje.'],
        'revisão (subtítulo)': ['De Dom Casmurro, Quincas Borba', 'e Iracema.'],
        'capa Esaú e Jacó (título)': ['Esaú', 'e Jacó'],
        'capa Memorial de Aires (título)': ['Memorial', 'de Aires'],
        'capa Casa de Pensão (título)': ['Casa de', 'Pensão'],
      };
      for (final MapEntry(key: name, value: lines) in expected.entries) {
        final ids = [
          for (final e in kRef01.elements.entries)
            if ((e.value.linesAll.isNotEmpty ? e.value.linesAll : e.value.lines)
                    .map((l) => l.text)
                    .toList()
                    .toString() ==
                lines.toString())
              e.key,
        ];
        expect(ids, isNotEmpty, reason: '$name: quebra não existe no arquivo');
        for (final id in ids) {
          expect(linesOf(keyDoId(id)), lines, reason: '$name ($id)');
        }
        debugPrint('[F13 quebras] $name → $lines  ids: ${ids.join(', ')}');
      }

      // Reticências ("Orgulho e Precon…"): linha única truncada, no id da prancha 01.
      expect(kRef01.ellipsized, {'i01.alsoReading.card2.title'});
      for (final ref in kRef01.ellipsized) {
        final id = keyDoId(ref);
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
          '[F13 reticências] $id: texto "${kRef01.elements[ref]!.lines.first.text}" truncado em 1 linha → ${linesOf(id)}',
        );
      }
    },
  );
}
