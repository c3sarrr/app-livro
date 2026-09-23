import 'dart:typed_data';

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/tokens/app_shadows.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/circle_icon_button.dart';
import 'package:app_leitura/core/design_system/widgets/count_badge.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pill.dart';
import 'package:app_leitura/core/design_system/widgets/pressable.dart';
import 'package:app_leitura/core/design_system/widgets/stadium_progress_bar.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout.dart';
import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/geometry.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';
import '../support/text_lines.dart';

const _red = Color(0xFFFF0000);
const _ink15 = BorderSide(width: 1.5, color: AppColors.ink);
const _ink12 = BorderSide(width: 1.2, color: AppColors.ink);

Widget _ltr(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Align(alignment: Alignment.topLeft, child: child),
);

/// Canvas 390×2390 com cada filho no canto superior esquerdo do retângulo de referência de `id`.
/// O tamanho sai do próprio primitivo — é ele que está sob teste.
Widget _atReference(Map<String, Widget> byId) => Directionality(
  textDirection: TextDirection.ltr,
  child: Stack(
    children: [
      for (final MapEntry(key: id, value: child) in byId.entries)
        Positioned(
          left: kRefLayout[id]!.rect.left,
          top: kRefLayout[id]!.rect.top,
          child: child,
        ),
    ],
  ),
);

ValueKey<String> _k(String id) => ValueKey<String>(id);

/// Cor do pixel em (x, y) lógicos de uma captura em [pixelRatio]×.
Color _pixelAt(
  Uint8List rgba,
  int width,
  double x,
  double y,
  double pixelRatio,
) {
  final i = ((y * pixelRatio).floor() * width + (x * pixelRatio).floor()) * 4;
  return Color.fromARGB(rgba[i + 3], rgba[i], rgba[i + 1], rgba[i + 2]);
}

int _argb(Color c) => c.toARGB32();

/// Registra o maior desvio (x, y, w, h) entre o retângulo de layout e a referência, para o relatório.
void _logMaxDeviation(WidgetTester tester, String label, Iterable<String> ids) {
  var worst = ('', '', 0.0);
  for (final id in ids) {
    final got = layoutRect(tester, id), ref = kRefLayout[id]!.rect;
    for (final (what, d) in [
      ('x', got.left - ref.left),
      ('y', got.top - ref.top),
      ('w', got.width - ref.width),
      ('h', got.height - ref.height),
    ]) {
      if (d.abs() > worst.$3.abs()) worst = (id, what, d);
    }
  }
  debugPrint(
    '[geometria] $label: ${ids.length} ids; maior desvio ${worst.$1}.${worst.$2} = ${worst.$3.toStringAsFixed(3)}',
  );
}

void main() {
  setUpAll(loadAppFonts);

  group('1.7 NeoBox', () {
    testWidgets(
      'decoração = cor, borda uniforme, raio e sombra dura (blur 0, spread 0) na mesma caixa',
      (tester) async {
        await tester.pumpWidget(
          _ltr(
            const NeoBox(
              width: 100,
              height: 60,
              color: AppColors.surface,
              border: _ink15,
              radius: BorderRadius.all(Radius.circular(28)),
              shadow: AppShadows.hard4,
            ),
          ),
        );
        final deco =
            tester.widget<Container>(find.byType(Container)).decoration!
                as BoxDecoration;
        expect(deco.color, AppColors.surface);
        expect(deco.border, Border.all(width: 1.5, color: AppColors.ink));
        expect(deco.borderRadius, BorderRadius.circular(28));
        expect(deco.boxShadow, const [
          BoxShadow(color: AppColors.ink, offset: Offset(4, 4)),
        ]);
        expect(deco.boxShadow!.single.blurRadius, 0);
        expect(deco.boxShadow!.single.spreadRadius, 0);
        expect(
          tester.getSize(find.byType(NeoBox)),
          const Size(100, 60),
          reason: 'tamanho externo (border-box)',
        );
        expect(
          find.byType(ClipRRect),
          findsNothing,
          reason: 'sem clip, nada recorta',
        );
      },
    );

    testWidgets(
      'clip: filhos recortados na padding box com raio − borda; borda e sombra não são recortadas',
      (tester) async {
        await tester.pumpWidget(
          _ltr(
            const RepaintBoundary(
              key: Key('k'),
              child: ColoredBox(
                color: AppColors.paper,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 6, 6),
                  child: NeoBox(
                    width: 100,
                    height: 60,
                    color: AppColors.surface,
                    border: _ink15,
                    radius: BorderRadius.all(Radius.circular(28)),
                    shadow: AppShadows.hard4,
                    clip: true,
                    child: ColoredBox(color: _red),
                  ),
                ),
              ),
            ),
          ),
        );
        expect(
          tester.widget<ClipRRect>(find.byType(ClipRRect)).borderRadius,
          BorderRadius.circular(26.5),
        );
        expect(
          tester.getRect(find.byType(ClipRRect)),
          const Rect.fromLTWH(1.5, 1.5, 97, 57),
        );
        expect(
          find.ancestor(
            of: find.byType(DecoratedBox),
            matching: find.byType(ClipRRect),
          ),
          findsNothing,
          reason: 'o recorte fica DENTRO da caixa decorada (não corta a própria borda nem a sombra)',
        );
        final image = await captureAt(
          tester,
          find.byKey(const Key('k')),
          pixelRatio: 10,
        );
        final rgba = await rgbaOf(tester, image);
        Color at(double x, double y) => _pixelAt(rgba, image.width, x, y, 10);
        // Borda lateral e, no canto, a faixa da borda entre os raios 26,5 e 28 (centro (28, 28)).
        expect(
          _argb(at(0.75, 30)),
          _argb(AppColors.ink),
          reason: 'borda esquerda',
        );
        expect(
          _argb(at(8.73, 8.73)),
          _argb(AppColors.ink),
          reason: 'faixa da borda no canto (raio 27,25)',
        );
        // Filho só dentro do raio interno.
        expect(_argb(at(3, 30)), _argb(_red), reason: 'filho junto à borda');
        expect(
          _argb(at(10.32, 10.32)),
          _argb(_red),
          reason: 'filho no canto (raio 25)',
        );
        // Fora do raio externo e fora da sombra: fundo.
        expect(
          _argb(at(7.49, 7.49)),
          _argb(AppColors.paper),
          reason: 'fora do canto',
        );
        // Sombra dura (4, 4) fora da caixa, intacta.
        expect(
          _argb(at(102, 30)),
          _argb(AppColors.ink),
          reason: 'sombra à direita',
        );
        expect(
          _argb(at(50, 62)),
          _argb(AppColors.ink),
          reason: 'sombra embaixo',
        );
        expect(
          _argb(at(2, 58)),
          _argb(AppColors.paper),
          reason: 'canto inferior esquerdo: fora da caixa e da sombra',
        );
      },
    );
  });

  group('1.7 variantes do arquivo (tamanho e texto medidos no HTML)', () {
    testWidgets(
      'Pill: capítulo, chips do dia, clube, hora do canhoto, selos da lista',
      (tester) async {
        setCanvasView(tester);
        const v5h10 = EdgeInsets.symmetric(vertical: 5, horizontal: 10);
        await tester.pumpWidget(
          _atReference({
            'hero.chapterPill': Pill(
              key: _k('hero.chapterPill'),
              padding: v5h10,
              color: AppColors.surface,
              border: _ink15,
              child: AppText(
                'Cap. 92 de 148',
                style: AppTextStyles.label12Bold,
              ),
            ),
            'today.chip.pages': Pill(
              key: _k('today.chip.pages'),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
              color: AppColors.chipGlass,
              border: _ink12,
              child: AppText('24 páginas', style: AppTextStyles.label12Bold),
            ),
            'today.chip.highlights': Pill(
              key: _k('today.chip.highlights'),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
              color: AppColors.chipGlass,
              border: _ink12,
              child: AppText('2 destaques', style: AppTextStyles.label12Bold),
            ),
            'club.pill': Pill(
              key: _k('club.pill'),
              padding: v5h10,
              color: AppColors.blush,
              border: _ink15,
              child: AppText(
                'Clube do livro',
                style: AppTextStyles.label12Bold,
              ),
            ),
            'club.stub.time': Pill(
              key: _k('club.stub.time'),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              color: AppColors.surface,
              border: _ink15,
              child: AppText('20h', style: AppTextStyles.body13Bold),
            ),
            'recent.row0.tag': Pill(
              key: _k('recent.row0.tag'),
              padding: v5h10,
              color: AppColors.tagLavenderBg,
              child: AppText('Quero ler', style: AppTextStyles.tagLavender),
            ),
            'recent.row2.tag': Pill(
              key: _k('recent.row2.tag'),
              padding: v5h10,
              color: AppColors.tagSandBg,
              child: AppText('Novo', style: AppTextStyles.tagSand),
            ),
            'forYou.reasonChip': Pill(
              key: _k('forYou.reasonChip'),
              padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
              color: AppColors.surface,
              border: _ink15,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  const AppSvg(
                    AppIcons.sparkleSolid,
                    key: ValueKey<String>('forYou.reasonChip.icon'),
                    size: 14,
                  ),
                  AppText(
                    'Porque você lê Machado de Assis',
                    style: AppTextStyles.body13Semi,
                  ),
                ],
              ),
            ),
          }),
        );
        const ids = [
          'hero.chapterPill',
          'today.chip.pages',
          'today.chip.highlights',
          'club.pill',
          'club.stub.time',
          'recent.row0.tag',
          'recent.row2.tag',
          'forYou.reasonChip',
        ];
        expectGeometry(tester, [...ids, 'forYou.reasonChip.icon']);
        _logMaxDeviation(tester, 'Pill', [...ids, 'forYou.reasonChip.icon']);
        for (final id in ids) {
          expectTextLines(tester, id);
        }
        expect(
          tester
              .widget<Container>(
                find.descendant(
                  of: find.byKey(_k('recent.row0.tag')),
                  matching: find.byType(Container),
                ),
              )
              .decoration,
          isA<BoxDecoration>().having((d) => d.border, 'border', isNull),
        );
      },
    );

    testWidgets('CountBadge: "14" (borda, sun), "2" (tinta) e "3" (flame)', (
      tester,
    ) async {
      setCanvasView(tester);
      await tester.pumpWidget(
        _atReference({
          'hero.notesButton.badge': CountBadge(
            key: _k('hero.notesButton.badge'),
            label: '14',
            style: AppTextStyles.micro11Bold,
            minWidth: 22,
            height: 22,
            horizontalPadding: 5,
            background: AppColors.sun,
            border: _ink15,
          ),
          'alsoReading.count': CountBadge(
            key: _k('alsoReading.count'),
            label: '2',
            style: AppTextStyles.count12OnInk,
            minWidth: 22,
            height: 22,
            horizontalPadding: 7,
            background: AppColors.ink,
          ),
          'club.cta.badge': CountBadge(
            key: _k('club.cta.badge'),
            label: '3',
            style: AppTextStyles.micro11Bold,
            minWidth: 20,
            height: 20,
            horizontalPadding: 6,
            background: AppColors.flame,
          ),
        }),
      );
      const ids = [
        'hero.notesButton.badge',
        'alsoReading.count',
        'club.cta.badge',
      ];
      expectGeometry(tester, ids);
      _logMaxDeviation(tester, 'CountBadge', ids);
      for (final id in ids) {
        expectTextLines(tester, id);
      }
    });

    testWidgets(
      'CircleIconButton: sino 48 (com ponto), destaques 54 (com badge), mais-opções 44',
      (tester) async {
        setCanvasView(tester);
        await precacheAppIcons(tester);
        await tester.pumpWidget(
          _atReference({
            'header.bell': CircleIconButton(
              key: _k('header.bell'),
              size: 48,
              color: AppColors.surface,
              border: _ink15,
              semanticsLabel: 'Notificações',
              icon: const AppSvg(
                AppIcons.bell,
                key: ValueKey<String>('header.bell.icon'),
                size: 22,
              ),
              // Ponto content-box: 9 + 2 × 1,5 = 12.
              overlays: [
                Positioned(
                  top: 9,
                  right: 11,
                  child: NeoBox(
                    key: _k('header.bell.dot'),
                    width: 12,
                    height: 12,
                    color: AppColors.flame,
                    border: _ink15,
                    radius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            'hero.notesButton': CircleIconButton(
              key: _k('hero.notesButton'),
              size: 54,
              color: AppColors.surface,
              border: _ink15,
              semanticsLabel: 'Destaques',
              icon: const AppSvg(
                AppIcons.highlighter,
                key: ValueKey<String>('hero.notesButton.icon'),
                size: 22,
              ),
              overlays: [
                Positioned(
                  top: -4,
                  right: -4,
                  child: CountBadge(
                    key: _k('hero.notesButton.badge'),
                    label: '14',
                    style: AppTextStyles.micro11Bold,
                    minWidth: 22,
                    height: 22,
                    horizontalPadding: 5,
                    background: AppColors.sun,
                    border: _ink15,
                  ),
                ),
              ],
            ),
            'recent.row0.more': CircleIconButton(
              key: _k('recent.row0.more'),
              size: 44,
              semanticsLabel: 'Mais opções',
              icon: const AppSvg(
                AppIcons.moreHorizontal,
                key: ValueKey<String>('recent.row0.more.icon'),
                size: 20,
              ),
            ),
          }),
        );
        const ids = [
          'header.bell', 'header.bell.icon', 'header.bell.dot', //
          'hero.notesButton', 'hero.notesButton.icon', //
          'hero.notesButton.badge', 'recent.row0.more', //
          'recent.row0.more.icon',
        ];
        expectGeometry(tester, ids);
        _logMaxDeviation(tester, 'CircleIconButton', ids);
        expectTextLines(tester, 'hero.notesButton.badge');
      },
    );

    testWidgets(
      'StadiumProgressBar: hero (181 × 10, 62 %) e clube (221 × 12)',
      (tester) async {
        setCanvasView(tester);
        final hero = kRefLayout['hero.progressBar']!.rect,
            club = kRefLayout['club.progressBar']!.rect;
        await tester.pumpWidget(
          _atReference({
            'hero.progressBar': SizedBox(
              width: hero.width,
              child: StadiumProgressBar(
                key: _k('hero.progressBar'),
                fillKey: _k('hero.progressFill'),
                progress: 0.62,
                height: 10,
                background: AppColors.surface,
                fillColor: AppColors.ink,
              ),
            ),
            'club.progressBar': SizedBox(
              width: club.width,
              child: StadiumProgressBar(
                key: _k('club.progressBar'),
                fillKey: _k('club.progressFill'),
                progress: 117.72 / 218,
                height: 12,
                background: AppColors.surface,
                fillColor: AppColors.blush,
              ),
            ),
          }),
        );
        const ids = [
          'hero.progressBar',
          'hero.progressFill',
          'club.progressBar',
          'club.progressFill',
        ];
        expectGeometry(tester, ids);
        _logMaxDeviation(tester, 'StadiumProgressBar', ids);
        final clip = tester.widget<ClipRRect>(
          find.descendant(
            of: find.byKey(_k('hero.progressBar')),
            matching: find.byType(ClipRRect),
          ),
        );
        expect(
          clip.borderRadius,
          BorderRadius.circular(999) - BorderRadius.circular(1.5),
        );
      },
    );
  });

  group('1.7 Pressable (D-04)', () {
    testWidgets(
      'sem ripple: escala 0,97 em 90 ms ao pressionar, volta em 120 ms; flag desliga',
      (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          _ltr(
            Pressable(
              onTap: () => taps++,
              child: const SizedBox(key: Key('c'), width: 100, height: 40),
            ),
          ),
        );
        double scale() =>
            tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;
        // Largura GLOBAL do filho (inclui o transform de escala): 100 em repouso, 97 pressionado.
        double painted() =>
            tester.getRect(find.byKey(const Key('c'))).width / 100;
        final gesture = await tester.startGesture(
          tester.getCenter(find.byKey(const Key('c'))),
        );
        await tester.pump();
        expect(scale(), 0.97);
        expect(
          tester.widget<AnimatedScale>(find.byType(AnimatedScale)).duration,
          const Duration(milliseconds: 90),
        );
        await tester.pump(const Duration(milliseconds: 90));
        expect(
          painted(),
          moreOrLessEquals(0.97, epsilon: 1e-6),
          reason: 'escala aplicada ao filho',
        );
        await gesture.up();
        await tester.pump();
        expect(taps, 1);
        expect(scale(), 1.0);
        expect(
          tester.widget<AnimatedScale>(find.byType(AnimatedScale)).duration,
          const Duration(milliseconds: 120),
        );
        await tester.pump(const Duration(milliseconds: 120));
        expect(painted(), moreOrLessEquals(1.0, epsilon: 1e-6));

        Pressable.feedbackEnabled = false;
        addTearDown(() => Pressable.feedbackEnabled = true);
        final second = await tester.startGesture(
          tester.getCenter(find.byKey(const Key('c'))),
        );
        await tester.pump(const Duration(milliseconds: 90));
        expect(scale(), 1.0, reason: 'feedback desligado pela flag');
        await second.up();
        await tester.pump(const Duration(milliseconds: 120));
        expect(taps, 2);
      },
    );

    testWidgets(
      'semântica: nó próprio (container) de botão/link; aria-label exclui os filhos',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          _ltr(
            Semantics(
              key: const Key('parent'),
              container: true,
              label: 'Cartão',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Pressable(
                    key: const Key('button'),
                    onTap: () {},
                    semanticsLabel: 'Mais opções',
                    child: AppText('…', style: AppTextStyles.body13Bold),
                  ),
                  Pressable(
                    key: const Key('link'),
                    onTap: () {},
                    isLink: true,
                    child: AppText(
                      'Ver tudo',
                      style: AppTextStyles.label14Bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        expect(
          tester.getSemantics(find.byKey(const Key('button'))),
          matchesSemantics(
            label: 'Mais opções',
            isButton: true,
            hasTapAction: true,
          ),
        );
        expect(
          tester.getSemantics(find.byKey(const Key('link'))),
          matchesSemantics(label: 'Ver tudo', isLink: true, hasTapAction: true),
        );
        expect(
          tester.getSemantics(find.byKey(const Key('parent'))),
          matchesSemantics(
            label: 'Cartão',
            children: [isA<SemanticsNode>(), isA<SemanticsNode>()],
          ),
          reason:
              'os botões não se fundem no pai, mesmo sem explicitChildNodes',
        );
        handle.dispose();
      },
    );

    testWidgets('CircleIconButton expõe o rótulo (aria-label) e não o ícone', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await precacheAppIcons(tester);
      await tester.pumpWidget(
        _ltr(
          CircleIconButton(
            size: 48,
            icon: const AppSvg(AppIcons.bell, size: 22),
            semanticsLabel: 'Notificações',
            onTap: () {},
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(CircleIconButton)),
        matchesSemantics(
          label: 'Notificações',
          isButton: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });
}
