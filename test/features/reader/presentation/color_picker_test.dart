// G17.1 — o seletor de cor da tela 23 (L23.6, R13, R14): a roda com o cursor, o BRILHO com o botão e o campo hex,
// nos lugares do `kRef23` (com o seletor posto onde a prancha o põe); arrastar e tocar na roda e no brilho; o brilho
// 0 guarda o tom; o hex digitado vale ao completar os 6 dígitos; o leitor de tela.
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/reader/presentation/color_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/reference_layout_23_ajustes_caneta.dart';
import '../../../support/app_text_finder.dart';
import '../../../support/load_fonts.dart';
import '../../../support/pecas_l23.dart';

final Rect _caixa = kRef23.elements['pen.penPanel.picker']!.rect;

/// O seletor na caixa da prancha, com a cor de fora que muda como o painel mudaria.
Future<({List<String> durante, List<String> fim, ValueNotifier<String> cor})>
_montar(WidgetTester tester, {String inicial = '#FF552E'}) async {
  final durante = <String>[];
  final fim = <String>[];
  final cor = ValueNotifier(inicial);
  addTearDown(cor.dispose);
  await montarPecasL23(tester, [
    Positioned(
      left: _caixa.left,
      top: _caixa.top,
      width: _caixa.width,
      child: ValueListenableBuilder(
        valueListenable: cor,
        builder: (_, c, _) => ColorPicker(
          color: c,
          onChanged: (h) {
            durante.add(h);
            cor.value = h;
          },
          onChangeEnd: (h) {
            fim.add(h);
            cor.value = h;
          },
        ),
      ),
    ),
  ]);
  return (durante: durante, fim: fim, cor: cor);
}

Finder _k(String k) => find.byKey(ValueKey<String>(k));

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'os lugares da prancha (roda, cursor, BRILHO, botão, hex, amostra e código)',
    (tester) async {
      await _montar(tester);
      conferirGeometriaL23(tester, kRef23, const [
        'pen.penPanel.picker',
        'pen.penPanel.picker.wheel',
        'pen.penPanel.picker.wheel.cursor',
        'pen.penPanel.picker.side',
        'pen.penPanel.picker.brightnessLabel',
        'pen.penPanel.picker.brightness',
        'pen.penPanel.picker.brightness.knob',
        'pen.penPanel.picker.hex',
        'pen.penPanel.picker.hex.swatch',
        'pen.penPanel.picker.hex.value',
      ]);
      conferirLinhasL23(tester, kRef23, 'pen.penPanel.picker.brightnessLabel');
      conferirLinhasL23(tester, kRef23, 'pen.penPanel.picker.hex.value');
    },
  );

  testWidgets(
    'tocar a 90° do topo, na borda: tom 90 durante e no fim; arrastar para fora prende na borda',
    (tester) async {
      final m = await _montar(tester);
      final roda = tester.getRect(_k('ann.penPanel.picker.wheel'));
      final g = await tester.startGesture(roda.center + const Offset(55, 0));
      await tester.pump();
      await g.moveTo(roda.center + const Offset(300, 0));
      await tester.pump();
      await g.up();
      await tester.pump();
      // tom 90 (entre o amarelo e o verde) com intensidade 1 e brilho 1
      expect(m.fim.single, '#80FF00');
      expect(m.durante, isNotEmpty);
      expect(m.cor.value, '#80FF00');
    },
  );

  testWidgets(
    'o brilho até o começo dá o preto; de volta a 100 %, a mesma cor (R13)',
    (tester) async {
      final m = await _montar(tester);
      final trilho = tester.getRect(_k('ann.penPanel.picker.brightness'));
      await tester.dragFrom(
        tester.getCenter(_k('ann.penPanel.picker.brightness.knob')),
        Offset(-trilho.width, 0),
      );
      await tester.pumpAndSettle();
      expect(m.fim.last, '#000000');
      await tester.tapAt(Offset(trilho.right - 2, trilho.center.dy));
      await tester.pumpAndSettle();
      expect(m.fim.last, '#FF552E');
    },
  );

  testWidgets('o degradê do brilho vai da tinta à cor com brilho 100 %', (
    tester,
  ) async {
    await _montar(tester, inicial: '#802A17');
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: _k('ann.penPanel.picker.brightness'),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final g = (box.decoration as BoxDecoration).gradient! as LinearGradient;
    expect(g.colors.first, AppColors.ink);
    // a mesma cor com brilho 1: #802A17 tem V = 128/255
    expect(g.colors.last.toARGB32(), 0xFFFF542E);
  });

  testWidgets(
    'o hex: digitar "1a2b3c" mostra #1A2B3C e vale ao completar; "G" é recusado; incompleto volta',
    (tester) async {
      final m = await _montar(tester);
      await tester.tap(_k('ann.penPanel.picker.hex'));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '1a2b3');
      await tester.pump();
      expect(m.fim, isEmpty);
      await tester.enterText(find.byType(EditableText), '1a2b3c');
      await tester.pump();
      expect(m.fim.single, '#1A2B3C');
      expect(find.text('#1A2B3C'), findsWidgets);
      await tester.enterText(find.byType(EditableText), 'GG');
      await tester.pump();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '#',
      );
      await tester.enterText(find.byType(EditableText), '12');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      // incompleto: volta ao código da cor atual
      expect(find.byType(EditableText), findsNothing);
      expect(findAppText('#1A2B3C'), findsOneWidget);
      expect(m.fim, ['#1A2B3C']);
    },
  );

  testWidgets('leitor de tela: a roda, o brilho e o campo', (tester) async {
    final h = tester.ensureSemantics();
    final m = await _montar(tester);
    expect(
      tester.getSemantics(_k('ann.penPanel.picker.wheel')),
      matchesSemantics(
        label: 'Roda de cores: tom e intensidade',
        value: 'coral',
        increasedValue: '#FF892E',
        decreasedValue: '#FF2E3B',
        isSlider: true,
        hasIncreaseAction: true,
        hasDecreaseAction: true,
      ),
    );
    expect(
      tester.getSemantics(_k('ann.penPanel.picker.brightness')),
      matchesSemantics(
        label: 'Brilho',
        value: '100 %',
        increasedValue: '100 %',
        decreasedValue: '95 %',
        isSlider: true,
        hasIncreaseAction: true,
        hasDecreaseAction: true,
      ),
    );
    tester.semantics.performAction(
      find.semantics.byLabel('Roda de cores: tom e intensidade'),
      SemanticsAction.increase,
    );
    await tester.pump();
    expect(m.fim.last, '#FF892E');
    expect(
      tester.getSemantics(_k('ann.penPanel.picker.hex')),
      matchesSemantics(
        label: 'Código da cor',
        value: '#FF892E',
        isTextField: true,
        hasTapAction: true,
      ),
    );
    h.dispose();
  });
}
