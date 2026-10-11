// G17 (D-177) — a folha "Rótulos" (no padrão da folha da nota): o cartão a 14 das bordas e 14 acima do teclado sobre o
// véu, que segura os toques; "RÓTULOS", as 4 cores com a amostra e o campo (até 24, contando como o banco; a dica é o
// nome da cor) e Cancelar/Salvar; Salvar devolve os 4 textos sem os espaços das pontas (só espaços = vazio).
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/labels_sheet.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:flutter/material.dart' show MaterialApp, TextField;
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
    Map<String, String> rotulos = const {
      '#FED170': 'lindo',
      '#FFC1C6': 'personagem',
    },
    double teclado = 300,
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
              LabelsSheet(
                labels: rotulos,
                palette: ReaderChromePalette.of(papel),
                brand: AppColors.lavender,
                onCancel: () => eventos.add('cancelar'),
                onSave: eventos.add,
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets(
    'o cartão a 14 das bordas e 14 acima do teclado; o véu segura os toques',
    (tester) async {
      await montar(tester);
      final r = tester.getRect(_key('ann.labels'));
      expect((r.left, r.right, r.bottom), (14.0, 376.0, 844 - 300 - 14.0));
      await tester.tapAt(const Offset(195, 40));
      expect(eventos, isEmpty);
    },
  );

  testWidgets(
    '"RÓTULOS" e as 4 cores com os rótulos de agora; sem rótulo, a dica é o nome da cor',
    (tester) async {
      await montar(tester);
      expect(findAppText('RÓTULOS'), findsOneWidget);
      final campos = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(campos, hasLength(4));
      expect(
        [for (final c in campos) c.controller!.text],
        ['lindo', 'personagem', '', ''],
      );
      expect(
        [for (final c in campos) c.decoration!.hintText],
        ['amarelo', 'rosa', 'verde', 'lavanda'],
      );
      for (final id in const ['yellow', 'pink', 'green', 'lavender']) {
        expect(_key('ann.labels.$id.swatch'), findsOneWidget);
      }
    },
  );

  testWidgets(
    'até 24 (contando como o banco); Salvar devolve os 4 sem os espaços das pontas',
    (tester) async {
      await montar(tester);
      await tester.enterText(_key('ann.labels.green.field'), 'é' * 30);
      await tester.enterText(_key('ann.labels.pink.field'), '   ');
      await tester.enterText(_key('ann.labels.lavender.field'), '  pro clube ');
      await tester.pump();
      expect(
        tester
            .widget<TextField>(_key('ann.labels.green.field'))
            .controller!
            .text,
        'é' * 24,
      );
      await tester.tap(_key('ann.labels.save'));
      expect(eventos.single, {
        '#FED170': 'lindo',
        '#FFC1C6': '',
        '#ABCF82': 'é' * 24,
        '#B6ACE4': 'pro clube',
      });
    },
  );

  testWidgets('Cancelar', (tester) async {
    await montar(tester, teclado: 0);
    await tester.tap(_key('ann.labels.cancel'));
    expect(eventos, ['cancelar']);
  });

  testWidgets(
    'Noite (R26): o cartão nas cores da ilha do Noite e os campos no poço',
    (tester) async {
      await montar(tester, papel: ReaderPaper.noite);
      expect(
        tester.widget<NeoBox>(_key('ann.labels')).color,
        AppColors.islandNight,
      );
      final campo = tester.widget<NeoBox>(
        find
            .ancestor(
              of: _key('ann.labels.pink.field'),
              matching: find.byType(NeoBox),
            )
            .first,
      );
      expect(campo.color, AppColors.paperNight);
    },
  );
}
