// G17 (D-178, R27) — a folha "Outra cor" da tela 21 (no padrão da folha da nota): o cartão a 14 das bordas e 14 acima
// do teclado sobre o véu, que segura os toques; "OUTRA COR", o seletor da tela 23 começando na cor dada (a última
// de grifo — D-130 — ou a do grifo tocado) e Cancelar/Grifar; Grifar devolve a cor escolhida; o leitor de tela ouve
// "Outra cor".
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/other_color_sheet.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/app_text_finder.dart';
import '../../../support/load_fonts.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

void main() {
  setUpAll(loadAppFonts);

  late List<Object> eventos;

  Future<void> montar(
    WidgetTester tester, {
    String inicial = '#FFC1C6',
    double teclado = 0,
    ReaderPaper papel = ReaderPaper.creme,
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    eventos = [];
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(390, 844),
            viewInsets: EdgeInsets.only(bottom: teclado),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => eventos.add('página'),
                ),
              ),
              OtherColorSheet(
                initial: inicial,
                palette: ReaderChromePalette.of(papel),
                brand: AppColors.lavender,
                onCancel: () => eventos.add('cancelar'),
                onApply: eventos.add,
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets(
    '"OUTRA COR", o seletor na cor dada e o cartão a 14 das bordas e 14 acima do teclado',
    (tester) async {
      await montar(tester, teclado: 300);
      expect(findAppText('OUTRA COR'), findsOneWidget);
      expect(findAppText('#FFC1C6'), findsOneWidget);
      final r = tester.getRect(_key('leitor.outraCor'));
      expect((r.left, r.right, r.bottom), (14.0, 376.0, 844 - 300 - 14.0));
      // o véu segura os toques
      await tester.tapAt(const Offset(195, 20));
      expect(eventos, isEmpty);
    },
  );

  testWidgets('Grifar devolve a cor escolhida no seletor (o código digitado)', (
    tester,
  ) async {
    await montar(tester);
    await tester.tap(_key('leitor.outraCor.picker.hex'));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), '1a2b3c');
    await tester.pump();
    await tester.tap(_key('leitor.outraCor.grifar'));
    expect(eventos, ['#1A2B3C']);
  });

  testWidgets('Grifar sem mexer: a cor dada; Cancelar', (tester) async {
    await montar(tester);
    await tester.tap(_key('leitor.outraCor.grifar'));
    expect(eventos, ['#FFC1C6']);
    await tester.tap(_key('leitor.outraCor.cancelar'));
    expect(eventos.last, 'cancelar');
  });

  testWidgets('o leitor de tela: o diálogo "Outra cor"', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(tester);
    expect(find.bySemanticsLabel('Outra cor'), findsOneWidget);
    semantica.dispose();
  });

  testWidgets('Noite (R26): o cartão nas cores da ilha do Noite', (
    tester,
  ) async {
    await montar(tester, papel: ReaderPaper.noite);
    expect(
      tester.widget<NeoBox>(_key('leitor.outraCor')).color,
      AppColors.islandNight,
    );
    expect(
      tester.widget<NeoBox>(_key('leitor.outraCor')).border!.color,
      AppColors.inkNight,
    );
  });
}
