// G17.2 — a moldura dos painéis das telas 23 e 23b (L23.1, L23b.1): o véu sobre a página e o topo, o painel a 14 das
// bordas com a base 22 acima do topo da prateleira, raio 26, borda 1,5 e sombra dura 4/4, a seta pendurada embaixo
// apontando para a ferramenta (Caneta 42, Marca-texto 95), o cabeçalho com o título, o subtítulo e o fechar. Tocar no
// véu ou no fechar fecha (R3). Leitor de tela: o diálogo e o "Fechar ajustes".
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:app_leitura/features/reader/presentation/tool_panel_frame.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/ref_tipos.dart';
import '../../../reference/leitor/reference_layout_23_ajustes_caneta.dart';
import '../../../reference/leitor/reference_layout_23b_ajustes_marcatexto.dart';
import '../../../support/load_fonts.dart';
import '../../../support/pecas_l23.dart';

/// O topo da prateleira das pranchas (L22c).
const double _prateleira = 676;

Future<List<String>> _montar(
  WidgetTester tester,
  LeitorRefPrancha ref, {
  ReaderPaper papel = ReaderPaper.creme,
}) async {
  final eventos = <String>[];
  final pen = ref == kRef23;
  final painel = ref.sections[pen ? 'pen.penPanel' : 'mk.markerPanel']!;
  // o miolo com a altura que deixa o painel do tamanho da prancha
  final bottomPad = pen ? 18.0 : 16.0;
  final miolo = painel.height - 3 - 14 - 44 - bottomPad;
  await montarPecasL23(tester, [
    Positioned.fill(
      child: ToolPanelLayer(
        id: pen ? 'ann.penPanel' : 'ann.markerPanel',
        label: pen ? 'Ajustes da caneta' : 'Ajustes do marca-texto',
        title: pen ? 'Caneta' : 'Marca-texto',
        subtitle: pen
            ? 'Esferográfica · 1,2 mm · coral'
            : 'Fundo · amarelo “lindo” · média',
        arrowLeft: pen ? 42 : 95,
        bottom: 844 - _prateleira + panelAboveShelf,
        bottomPadding: bottomPad,
        paper: ReaderPalette.of(papel).paper,
        onClose: () => eventos.add('fechar'),
        child: SizedBox(height: miolo),
      ),
    ),
  ], papel: papel);
  return eventos;
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '23: véu, painel, seta, cabeçalho, título, subtítulo e fechar nos lugares da prancha',
    (tester) async {
      await _montar(tester, kRef23);
      conferirGeometriaL23(tester, kRef23, const [
        'pen.fade',
        'pen.penPanel',
        'pen.penPanel.arrow',
        'pen.penPanel.header',
        'pen.penPanel.header.texts',
        'pen.penPanel.title',
        'pen.penPanel.subtitle',
        'pen.penPanel.close',
        'pen.penPanel.close.icon',
      ]);
      conferirLinhasL23(tester, kRef23, 'pen.penPanel.title');
      conferirLinhasL23(tester, kRef23, 'pen.penPanel.subtitle');
    },
  );

  testWidgets('23b: a mesma moldura, mais alta, com a seta no Marca-texto', (
    tester,
  ) async {
    await _montar(tester, kRef23b);
    conferirGeometriaL23(tester, kRef23b, const [
      'mk.fade',
      'mk.markerPanel',
      'mk.markerPanel.arrow',
      'mk.markerPanel.header',
      'mk.markerPanel.header.texts',
      'mk.markerPanel.title',
      'mk.markerPanel.subtitle',
      'mk.markerPanel.close',
      'mk.markerPanel.close.icon',
    ]);
    conferirLinhasL23(tester, kRef23b, 'mk.markerPanel.title');
    conferirLinhasL23(tester, kRef23b, 'mk.markerPanel.subtitle');
  });

  testWidgets(
    'cores: o véu é o papel a 66 %; o painel #FFFAF1, borda 1,5 e sombra 4/4 de tinta, raio 26',
    (tester) async {
      await _montar(tester, kRef23);
      final veu = tester.widget<ColoredBox>(chaveL23('ann.fade'));
      expect(
        veu.color.toARGB32(),
        AppColors.paperCream.withValues(alpha: 0.66).toARGB32(),
      );
      final caixa = tester.widget<Container>(chaveL23('ann.penPanel'));
      final d = caixa.decoration! as BoxDecoration;
      expect(d.color, AppColors.surface);
      expect(d.border, Border.all(width: 1.5, color: AppColors.ink));
      expect(d.borderRadius, BorderRadius.circular(26));
      expect(d.boxShadow!.single.offset, const Offset(4, 4));
      expect(d.boxShadow!.single.color, AppColors.ink);
    },
  );

  testWidgets(
    'Noite: o véu no papel do Noite; o painel nas cores da ilha do Noite (R26)',
    (tester) async {
      await _montar(tester, kRef23, papel: ReaderPaper.noite);
      final veu = tester.widget<ColoredBox>(chaveL23('ann.fade'));
      expect(
        veu.color.toARGB32(),
        AppColors.paperNight.withValues(alpha: 0.66).toARGB32(),
      );
      final caixa = tester.widget<Container>(chaveL23('ann.penPanel'));
      final d = caixa.decoration! as BoxDecoration;
      expect(d.color, AppColors.islandNight);
      expect(d.border, Border.all(width: 1.5, color: AppColors.inkNight));
      expect(d.boxShadow!.single.color, AppColors.shadowNight);
    },
  );

  testWidgets('tocar no véu ou no fechar fecha; tocar no painel não (R3)', (
    tester,
  ) async {
    final eventos = await _montar(tester, kRef23);
    await tester.tapAt(const Offset(195, 60));
    await tester.tap(chaveL23('ann.penPanel.close'));
    await tester.tapAt(const Offset(195, 400));
    await tester.pump();
    expect(eventos, ['fechar', 'fechar']);
  });

  testWidgets(
    'leitor de tela: o diálogo "Ajustes da caneta" e o "Fechar ajustes"; o véu e a seta ficam fora',
    (tester) async {
      final h = tester.ensureSemantics();
      await _montar(tester, kRef23);
      expect(find.bySemanticsLabel('Ajustes da caneta'), findsOneWidget);
      expect(
        tester.getSemantics(chaveL23('ann.penPanel.close')),
        matchesSemantics(
          label: 'Fechar ajustes',
          isButton: true,
          hasTapAction: true,
        ),
      );
      h.dispose();
    },
  );
}
