// G14.3 — a folha da tela 26 (L26) sozinha: o lugar da folha, da pílula, do papel que cobre a página abaixo do corte
// e do nó "Prévia da página" (com as áreas do aparelho); abrir e fechar em 150 ms; fechar pelo ×, pela página de cima
// e puxando pela alça (D-141); o tamanho (A, pontos, arrasto, leitor de tela), a fonte, o papel, a entrelinha e as
// margens pedindo a mudança (D-144); a semântica; e o Noite nas cores das ilhas (D-143). Revisão: toques seguidos
// antes de a sessão avisar valem o último (e somam no leitor de tela); a pílula deixa o toque passar; o empurrão para
// cima não fecha; o título é cabeçalho e os rótulos visíveis ficam com os grupos.
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_settings_sheet.dart';
import 'package:flutter/semantics.dart' show SemanticsAction;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/canvas.dart';
import '../../../support/load_fonts.dart';
import '../../../support/precache_svgs.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

/// O que a folha pediu (cada pedido aplicado aos ajustes mostrados) e quantas vezes fechou.
final class _Mesa {
  _Mesa(this.atual);

  final pedidos = <ReaderLook>[];

  /// Os ajustes da sessão com cada pedido aplicado em ordem (a folha mostra os de antes até a sessão avisar).
  ReaderLook atual;
  var fechou = 0;
}

Widget _folha({
  required bool open,
  required ReaderLook look,
  required ReaderPaper papel,
  required _Mesa mesa,
}) => ReaderSettingsSheet(
  open: open,
  look: look,
  palette: ReaderChromePalette.of(papel),
  paper: ReaderPalette.of(papel).paper,
  brand: AppColors.lavender,
  page: (left: 28, top: 92, width: 334),
  pageText: 'Retórica dos namorados, dá-me uma comparação exata e poética…',
  onChange: (c) {
    mesa.pedidos.add(c(look));
    mesa.atual = c(mesa.atual);
  },
  onClose: () => mesa.fechou++,
);

Future<_Mesa> _montar(
  WidgetTester tester, {
  bool open = true,
  ReaderLook look = const ReaderLook(),
  ReaderPaper papel = ReaderPaper.creme,
  EdgeInsets area = EdgeInsets.zero,
}) async {
  final m = _Mesa(look);
  setCanvasView(tester, logical: const Size(390, 844));
  await precacheSvgs(tester, AppIconsLeitor.all);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: const Size(390, 844),
        viewPadding: area,
        padding: area,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: _folha(open: open, look: look, papel: papel, mesa: m),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 150));
  return m;
}

NeoBox _caixa(WidgetTester tester, String id) => tester.widget<NeoBox>(
  find.descendant(of: _key(id), matching: find.byType(NeoBox)).first,
);

Color _cor(WidgetTester tester, String id) =>
    (tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: _key(id),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration)
        .color!;

TextStyle _estilo(WidgetTester tester, String id) =>
    tester.widget<AppText>(_key(id)).span.style!;

void main() {
  setUpAll(loadAppFonts);

  group('lugar, abrir e fechar', () {
    testWidgets(
      'aberta: a folha a 10 das bordas e da base, 547,2 de altura; o papel cobre a página 15,2 abaixo do topo dela; a prévia e a pílula',
      (tester) async {
        await _montar(tester);
        final folha = tester.getRect(_key('rs.sheet'));
        expect((folha.left, folha.width, folha.bottom), (10.0, 370.0, 834.0));
        expect(folha.height, moreOrLessEquals(547.2, epsilon: 0.5));
        expect(
          tester.getRect(_key('rs.paper')).top,
          moreOrLessEquals(folha.top + 15.2, epsilon: 1e-6),
        );
        expect(
          tester.getRect(_key('rs.page')),
          Rect.fromLTRB(28, 92, 362, folha.top + 15.2),
        );
        final pilula = tester.getRect(_key('rs.livePill'));
        expect(
          (pilula.top, pilula.center.dx, pilula.height),
          (54.0, 195.0, 26.0),
        );
        expect(
          tester.getRect(_key('rs.livePill.dot')).topLeft - pilula.topLeft,
          const Offset(12.5, 9.5),
        );
        void rel(String k, double x, double y) {
          final d = tester.getRect(_key(k)).topLeft - folha.topLeft;
          expect(d.dx, moreOrLessEquals(x, epsilon: 1e-4), reason: k);
          expect(d.dy, moreOrLessEquals(y, epsilon: 1e-4), reason: k);
        }

        rel('rs.sheet.grabber', 165, 11.5);
        rel('rs.sheet.size', 19.5, 80.5);
        rel('rs.sheet.fonts', 19.5, 164.7);
        rel('rs.sheet.papers', 19.5, 284.9);
        rel('rs.sheet.spacing', 19.5, 401.5);
        rel('rs.sheet.margins', 19.5, 479.7);
      },
    );

    testWidgets(
      'com as áreas do aparelho: base max(10, baixo − 24), pílula max(54, cima + 7)',
      (tester) async {
        await _montar(tester, area: const EdgeInsets.only(top: 47, bottom: 34));
        expect(tester.getRect(_key('rs.sheet')).bottom, 834);
        expect(tester.getRect(_key('rs.livePill')).top, 54);
        await _montar(tester, area: const EdgeInsets.only(top: 59, bottom: 50));
        expect(tester.getRect(_key('rs.sheet')).bottom, 844 - 26);
        expect(tester.getRect(_key('rs.livePill')).top, 66);
      },
    );

    testWidgets(
      'abre e fecha em 150 ms subindo e descendo; fechada não monta nada; fechando não pega toque',
      (tester) async {
        final m = _Mesa(const ReaderLook());
        final aberta = ValueNotifier(false);
        addTearDown(aberta.dispose);
        setCanvasView(tester, logical: const Size(390, 844));
        await precacheSvgs(tester, AppIconsLeitor.all);
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(390, 844)),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: ValueListenableBuilder<bool>(
                valueListenable: aberta,
                builder: (_, open, _) => _folha(
                  open: open,
                  look: const ReaderLook(),
                  papel: ReaderPaper.creme,
                  mesa: m,
                ),
              ),
            ),
          ),
        );
        expect(_key('rs.sheet'), findsNothing, reason: 'fechada, nada montado');
        aberta.value = true;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 75));
        final meio = tester.getRect(_key('rs.sheet')).top;
        await tester.pump(const Duration(milliseconds: 65));
        expect(
          tester.getRect(_key('rs.sheet')).top,
          greaterThan(844 - 10 - 547.2 + 30),
          reason: 'aos 140 ms ainda sobe',
        );
        await tester.pump(const Duration(milliseconds: 10));
        final topo = tester.getRect(_key('rs.sheet')).top;
        expect(topo, moreOrLessEquals(844 - 10 - 547.2, epsilon: 0.5));
        expect(meio, greaterThan(topo + 100), reason: 'no meio da subida');
        aberta.value = false;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 75));
        expect(tester.getRect(_key('rs.sheet')).top, greaterThan(topo + 100));
        await tester.tapAt(const Offset(195, 200));
        expect(m.fechou, 0, reason: 'fechando, os toques passam');
        await tester.pump(const Duration(milliseconds: 75));
        expect(_key('rs.sheet'), findsNothing);
      },
    );

    testWidgets(
      'fecha pelo × e pelo toque na página de cima (D-141), também sobre a pílula; tocar na folha não fecha',
      (tester) async {
        final m = await _montar(tester);
        await tester.tap(_key('rs.sheet.close'));
        expect(m.fechou, 1);
        await tester.tapAt(const Offset(195, 200));
        expect(m.fechou, 2);
        await tester.tapAt(tester.getCenter(_key('rs.livePill')));
        expect(m.fechou, 3, reason: 'a pílula é só aviso: o toque é da página');
        await tester.tapAt(const Offset(60, 330)); // o título
        await tester.tapAt(const Offset(195, 840)); // o papel abaixo da folha
        expect(m.fechou, 4, reason: 'o título não fecha; abaixo da folha, sim');
      },
    );

    testWidgets('puxar pela alça: 64 para baixo fecha; pouco volta ao lugar', (
      tester,
    ) async {
      final m = await _montar(tester);
      final topo = tester.getRect(_key('rs.sheet')).top;
      final alca = tester.getCenter(_key('rs.sheet.grabber'));
      final pouco = await tester.startGesture(alca);
      for (var i = 0; i < 6; i++) {
        await pouco.moveBy(const Offset(0, 5));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await pouco.up();
      await tester.pump();
      expect(m.fechou, 0);
      expect(tester.getRect(_key('rs.sheet')).top, topo);
      final g = await tester.startGesture(alca);
      for (var i = 0; i < 4; i++) {
        await g.moveBy(const Offset(0, 10));
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(
        tester.getRect(_key('rs.sheet')).top,
        greaterThan(topo + 20),
        reason: 'a folha acompanha o dedo',
      );
      for (var i = 0; i < 4; i++) {
        await g.moveBy(const Offset(0, 10));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await g.up();
      await tester.pump();
      expect(m.fechou, 1);
    });

    testWidgets(
      'puxar mais de 64 e devolver com força para cima não fecha: a folha volta ao lugar',
      (tester) async {
        final m = await _montar(tester);
        final topo = tester.getRect(_key('rs.sheet')).top;
        final g = await tester.startGesture(
          tester.getCenter(_key('rs.sheet.grabber')),
        );
        var t = Duration.zero;
        for (var i = 0; i < 12; i++) {
          t += const Duration(milliseconds: 100);
          await g.moveBy(const Offset(0, 10), timeStamp: t);
          await tester.pump();
        }
        expect(
          tester.getRect(_key('rs.sheet')).top,
          greaterThan(topo + readerSheetDismissDrag + 25),
          reason: 'devagar, passou dos 64',
        );
        // e o empurrão para cima: 25 em 25 ms (1.000/s)
        for (var i = 0; i < 5; i++) {
          t += const Duration(milliseconds: 5);
          await g.moveBy(const Offset(0, -5), timeStamp: t);
        }
        await g.up(timeStamp: t);
        await tester.pump();
        expect(m.fechou, 0);
        expect(tester.getRect(_key('rs.sheet')).top, topo);
      },
    );

    testWidgets(
      'título "Ajustes de leitura", o × de 44 com o ícone de 18 e a caixa da folha',
      (tester) async {
        await _montar(tester);
        final titulo = tester.widget<AppText>(_key('rs.sheet.title'));
        expect(titulo.span.toPlainText(), 'Ajustes de leitura');
        final x = tester.getRect(_key('rs.sheet.close'));
        final folha = tester.getRect(_key('rs.sheet'));
        expect(x.topLeft - folha.topLeft, const Offset(306.5, 24.5));
        expect(x.size, const Size(44, 44));
        expect(
          tester.widget<AppSvg>(_key('rs.sheet.close.icon')).asset,
          AppIconsLeitor.closeRound,
        );
        expect(
          tester.widget<AppSvg>(_key('rs.sheet.close.icon')).color,
          isNull,
        );
        final caixa = tester.widget<NeoBox>(_key('rs.sheet'));
        expect(
          (caixa.color, caixa.border, caixa.shadow, caixa.shadowColor),
          (
            AppColors.surface,
            const BorderSide(width: 1.5, color: AppColors.ink),
            const Offset(0, 4),
            AppColors.ink,
          ),
        );
        expect(
          caixa.radius,
          const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
            bottomLeft: Radius.circular(44),
            bottomRight: Radius.circular(44),
          ),
        );
        expect(_cor(tester, 'rs.sheet.grabber'), AppColors.dashReader);
        expect(
          tester.widget<ColoredBox>(_key('rs.paper')).color,
          AppColors.paperCream,
        );
      },
    );

    testWidgets(
      'semântica: diálogo "Ajustes de leitura", a "Prévia da página" com o texto, "Fechar"; a pílula de fora',
      (tester) async {
        final h = tester.ensureSemantics();
        await _montar(tester);
        // o diálogo (o título "Ajustes de leitura" também é um nó, de texto)
        expect(
          tester.getSemantics(_key('rs.sheet')),
          isSemantics(
            label: 'Ajustes de leitura',
            scopesRoute: true,
            namesRoute: true,
          ),
        );
        expect(
          tester.getSemantics(_key('rs.page')),
          isSemantics(
            label: 'Prévia da página',
            value:
                'Retórica dos namorados, dá-me uma comparação exata e poética…',
          ),
        );
        expect(find.bySemanticsLabel('Fechar'), findsOneWidget);
        expect(find.bySemanticsLabel(RegExp('prévia ao vivo')), findsNothing);
        // o título é o cabeçalho da folha; "FONTE", "PAPEL"… ficam com os grupos ("Fonte", "Tema do papel"…)
        expect(
          tester.getSemantics(_key('rs.sheet.title')),
          isSemantics(label: 'Ajustes de leitura', isHeader: true),
        );
        for (final r in ['FONTE', 'PAPEL', 'ENTRELINHA', 'MARGENS']) {
          expect(find.bySemanticsLabel(r), findsNothing, reason: r);
        }
        h.dispose();
      },
    );

    testWidgets(
      'Noite (D-143): folha, pílula e × nas cores das ilhas do Noite',
      (tester) async {
        await _montar(tester, papel: ReaderPaper.noite);
        final n = ReaderChromePalette.of(ReaderPaper.noite);
        final caixa = tester.widget<NeoBox>(_key('rs.sheet'));
        expect(
          (caixa.color, caixa.border!.color, caixa.shadowColor),
          (n.island, n.border, n.shadow),
        );
        final pilula = tester.widget<NeoBox>(_key('rs.livePill'));
        expect((pilula.color, pilula.border!.color), (n.island, n.border));
        expect(
          tester.widget<AppSvg>(_key('rs.sheet.close.icon')).color,
          n.title,
        );
        expect(
          tester.widget<ColoredBox>(_key('rs.paper')).color,
          ReaderPalette.of(ReaderPaper.noite).paper,
        );
        expect(_cor(tester, 'rs.sheet.grabber'), n.dash);
      },
    );
  });

  group('tamanho', () {
    test('readerStepAt: o centro de cada ponto da prancha escolhe ele mesmo; entre dois, o mais perto', () {
      // L26 nº 15–21, relativos ao trilho (x 87,5, largura 215), com o 4º ativo
      const centros = [24.5, 51.0, 77.5, 107.5, 137.5, 164.0, 190.5];
      for (var i = 0; i < 7; i++) {
        expect(readerStepAt(centros[i], 215, 4), i + 1);
      }
      expect(readerStepAt(0, 215, 4), 1);
      expect(readerStepAt(215, 215, 4), 7);
      expect(readerStepAt((centros[4] + centros[5]) / 2 - 1, 215, 4), 5);
      expect(readerStepAt((centros[4] + centros[5]) / 2 + 1, 215, 4), 6);
      // com o 1º ativo, o 1º ponto é o grande
      expect(readerStepAt(1.5 + 19.5 + 7, 215, 1), 1);
    });

    testWidgets(
      'A− e A+ andam um passo; nas pontas ficam indisponíveis (cinza e "indisponível")',
      (tester) async {
        final h = tester.ensureSemantics();
        var m = await _montar(tester);
        await tester.tap(_key('rs.sheet.size.smaller'));
        await tester.tap(_key('rs.sheet.size.larger'));
        expect(m.pedidos.map((l) => l.fontStep), [3, 5]);
        expect(
          tester.getSemantics(_key('rs.sheet.size.smaller')),
          isSemantics(
            label: 'Diminuir a letra',
            isButton: true,
            hasTapAction: true,
          ),
        );
        m = await _montar(tester, look: const ReaderLook(fontStep: 1));
        expect(
          tester.getSemantics(_key('rs.sheet.size.smaller')),
          isSemantics(
            label: 'Diminuir a letra',
            isButton: true,
            hasEnabledState: true,
            isEnabled: false,
            hasTapAction: false,
          ),
        );
        await tester.tap(_key('rs.sheet.size.smaller'), warnIfMissed: false);
        expect(m.pedidos, isEmpty);
        final cinza = ReaderChromePalette.of(ReaderPaper.creme).disabled;
        final a = tester.widget<AppText>(
          find.descendant(
            of: _key('rs.sheet.size.smaller'),
            matching: find.byType(AppText),
          ),
        );
        expect(a.span.style!.color, cinza);
        expect(_caixa(tester, 'rs.sheet.size.smaller').border!.color, cinza);
        m = await _montar(tester, look: const ReaderLook(fontStep: 7));
        expect(
          tester.getSemantics(_key('rs.sheet.size.larger')),
          isSemantics(
            label: 'Aumentar a letra',
            isButton: true,
            hasEnabledState: true,
            isEnabled: false,
            hasTapAction: false,
          ),
        );
        await tester.tap(_key('rs.sheet.size.smaller'));
        expect(m.pedidos.single.fontStep, 6);
        h.dispose();
      },
    );

    testWidgets(
      'trilho: tocar num ponto escolhe; arrastar escolhe o mais perto, sem repetir',
      (tester) async {
        final m = await _montar(tester);
        await tester.tapAt(tester.getCenter(_key('rs.sheet.size.step6')));
        expect(m.pedidos.map((l) => l.fontStep), [6]);
        // a sessão ainda aplica o 6 (a folha mostra o 4): tocar no 4 pede o 4 — vale o último toque
        await tester.tapAt(tester.getCenter(_key('rs.sheet.size.step4')));
        expect(m.pedidos.map((l) => l.fontStep), [6, 4]);
        expect(m.atual.fontStep, 4);
        m.pedidos.clear();
        final de = tester.getCenter(_key('rs.sheet.size.step2'));
        final ate = tester.getCenter(_key('rs.sheet.size.step6'));
        final g = await tester.startGesture(de);
        for (var i = 1; i <= 20; i++) {
          await g.moveTo(Offset.lerp(de, ate, i / 20)!);
        }
        await g.up();
        // o 2 pode não sair (o arrasto começa depois do limiar)
        final passos = m.pedidos.map((l) => l.fontStep).toList();
        expect(passos.last, 6);
        expect(passos, containsAllInOrder([3, 4, 5, 6]));
        expect(passos.toSet(), hasLength(passos.length), reason: 'sem repetir');
      },
    );

    testWidgets(
      'pontos: até o ativo em tinta, depois em #CFC3AE; o ativo de 14 na brand com borda',
      (tester) async {
        await _montar(tester);
        expect(
          [
            _cor(tester, 'rs.sheet.size.step1'),
            _cor(tester, 'rs.sheet.size.step3'),
            _cor(tester, 'rs.sheet.size.step5'),
            _cor(tester, 'rs.sheet.size.step7'),
          ],
          [
            AppColors.ink,
            AppColors.ink,
            AppColors.dashReader,
            AppColors.dashReader,
          ],
        );
        final ativo = tester.widget<NeoBox>(_key('rs.sheet.size.step4'));
        expect(
          (ativo.width, ativo.color, ativo.border),
          (
            14.0,
            AppColors.lavender,
            const BorderSide(width: 1.5, color: AppColors.ink),
          ),
        );
        expect(
          tester.getRect(_key('rs.sheet.size.steps')).size,
          const Size(215, 48),
        );
        final folha = tester.getRect(_key('rs.sheet')).topLeft;
        expect(
          tester.getRect(_key('rs.sheet.size.step1')).topLeft - folha,
          const Offset(98.5, 101),
        );
        expect(
          tester.getRect(_key('rs.sheet.size.step4')).topLeft - folha,
          const Offset(178, 97.5),
        );
      },
    );

    testWidgets(
      'leitor de tela: "Tamanho da letra", "4 de 7", aumentar e diminuir',
      (tester) async {
        final h = tester.ensureSemantics();
        final m = await _montar(tester);
        final no = find.bySemanticsLabel('Tamanho da letra');
        expect(
          tester.getSemantics(no),
          isSemantics(
            label: 'Tamanho da letra',
            value: '4 de 7',
            increasedValue: '5 de 7',
            decreasedValue: '3 de 7',
            isSlider: true,
            hasIncreaseAction: true,
            hasDecreaseAction: true,
          ),
        );
        final deslizante = find.semantics.byLabel('Tamanho da letra');
        tester.semantics.performAction(deslizante, SemanticsAction.increase);
        tester.semantics.performAction(deslizante, SemanticsAction.decrease);
        expect(m.pedidos.map((l) => l.fontStep), [5, 3]);
        // dois "aumentar" antes de a sessão avisar somam: um passo sobre os ajustes da sessão, não sobre o mostrado
        tester.semantics.performAction(deslizante, SemanticsAction.increase);
        tester.semantics.performAction(deslizante, SemanticsAction.increase);
        expect(m.atual.fontStep, 6);
        await _montar(tester, look: const ReaderLook(fontStep: 7));
        expect(
          tester.getSemantics(find.bySemanticsLabel('Tamanho da letra')),
          isSemantics(
            label: 'Tamanho da letra',
            value: '7 de 7',
            decreasedValue: '6 de 7',
            isSlider: true,
            hasIncreaseAction: false,
            hasDecreaseAction: true,
          ),
        );
        h.dispose();
      },
    );
  });

  group('fonte, papel, entrelinha e margens', () {
    testWidgets(
      'Fonte: 4 cartões com o "Aa" na própria fonte; o ativo na brand com sombra 2/2; o toque pede a fonte',
      (tester) async {
        final m = await _montar(tester);
        expect(
          [
            for (final id in ['literata', 'lora', 'figtree', 'atkinson'])
              _estilo(tester, 'rs.sheet.fonts.$id.sample').fontFamily,
          ],
          ['Literata26', 'LoraBook', 'Figtree', 'AtkinsonBook'],
        );
        final ativo = _caixa(tester, 'rs.sheet.fonts.literata');
        expect(
          (ativo.color, ativo.shadow, ativo.radius),
          (AppColors.lavender, const Offset(2, 2), BorderRadius.circular(16)),
        );
        final outro = _caixa(tester, 'rs.sheet.fonts.lora');
        expect((outro.color, outro.shadow), (AppColors.paper, null));
        expect(
          _estilo(tester, 'rs.sheet.fonts.literata.caption').color,
          AppColors.captionOnBrand,
        );
        expect(
          _estilo(tester, 'rs.sheet.fonts.lora.caption').color,
          AppColors.inkSoft,
        );
        await tester.tap(_key('rs.sheet.fonts.atkinson'));
        expect(m.pedidos.single.fontFamily, ReaderFontFamily.atkinson);
      },
    );

    testWidgets(
      'Papel: cada cartão nas cores do papel; ✓ e sombra só no ativo; o nome dele em 800',
      (tester) async {
        final m = await _montar(
          tester,
          look: const ReaderLook(paper: ReaderPaper.sepia),
        );
        final sepia = tester.widget<NeoBox>(_key('rs.sheet.papers.sepia.card'));
        expect(
          (sepia.color, sepia.shadow),
          (AppColors.paperSepia, const Offset(2, 2)),
        );
        final creme = tester.widget<NeoBox>(_key('rs.sheet.papers.cream.card'));
        expect((creme.color, creme.shadow), (AppColors.paperCream, null));
        expect(
          tester.widget<NeoBox>(_key('rs.sheet.papers.night.card')).color,
          AppColors.paperNight,
        );
        expect(_key('rs.sheet.papers.sepia.check'), findsOneWidget);
        expect(_key('rs.sheet.papers.cream.check'), findsNothing);
        expect(
          _estilo(tester, 'rs.sheet.papers.night.sample').color,
          AppColors.inkNight,
        );
        expect(
          _cor(tester, 'rs.sheet.papers.cream.line1'),
          AppColors.paperLineCream,
        );
        expect(
          _cor(tester, 'rs.sheet.papers.white.line2'),
          AppColors.paperLineWhite,
        );
        expect(
          _cor(tester, 'rs.sheet.papers.night.line1'),
          AppColors.dashNight,
        );
        expect(
          tester.getSize(_key('rs.sheet.papers.cream.line2')).width,
          moreOrLessEquals(
            0.7 * tester.getSize(_key('rs.sheet.papers.cream.line1')).width,
            epsilon: 0.01,
          ),
        );
        expect(
          _estilo(tester, 'rs.sheet.papers.sepia.name').fontWeight,
          FontWeight.w800,
        );
        expect(
          _estilo(tester, 'rs.sheet.papers.cream.name').fontWeight,
          FontWeight.w700,
        );
        await tester.tap(_key('rs.sheet.papers.night'));
        expect(m.pedidos.single.paper, ReaderPaper.noite);
      },
    );

    testWidgets(
      'Entrelinha e Margens: segmentados de 3; o ativo na brand com borda; o toque pede',
      (tester) async {
        final m = await _montar(tester);
        final medio = _caixa(tester, 'rs.sheet.spacing.medium');
        expect(
          (medio.color, medio.border!.color),
          (AppColors.lavender, AppColors.ink),
        );
        final justo = _caixa(tester, 'rs.sheet.spacing.tight');
        expect((justo.color, justo.border!.color.a), (null, 0.0));
        expect(
          tester.widget<AppSvg>(_key('rs.sheet.margins.wide.icon')).asset,
          AppIconsLeitor.marginsWide,
        );
        expect(
          tester.widget<AppSvg>(_key('rs.sheet.spacing.loose.icon')).color,
          isNull,
        );
        await tester.tap(_key('rs.sheet.spacing.loose'));
        await tester.tap(_key('rs.sheet.margins.narrow'));
        expect(
          [m.pedidos[0].lineSpacing, m.pedidos[1].margins],
          [ReaderLineSpacing.solto, ReaderMargins.estreita],
        );
      },
    );

    testWidgets('leitor de tela: os 4 grupos e as opções marcadas (radio)', (
      tester,
    ) async {
      final h = tester.ensureSemantics();
      await _montar(tester);
      for (final g in ['Fonte', 'Tema do papel', 'Entrelinha', 'Margens']) {
        expect(find.bySemanticsLabel(g), findsOneWidget, reason: g);
      }
      for (final (id, rotulo, marcado) in const [
        ('rs.sheet.fonts.literata', 'Literata, tela', true),
        ('rs.sheet.papers.white', 'Tema Branco', false),
        ('rs.sheet.spacing.medium', 'Médio', true),
        ('rs.sheet.margins.wide', 'Larga', false),
      ]) {
        expect(
          tester.getSemantics(_key(id)),
          isSemantics(
            label: rotulo,
            hasCheckedState: true,
            isChecked: marcado,
            isInMutuallyExclusiveGroup: true,
            hasTapAction: true,
          ),
          reason: id,
        );
      }
      h.dispose();
    });

    testWidgets(
      'Noite (D-143): os cartões de papel mantêm as cores; rótulos, legendas, opções e cartões nas cores das ilhas',
      (tester) async {
        await _montar(
          tester,
          papel: ReaderPaper.noite,
          look: const ReaderLook(paper: ReaderPaper.noite),
        );
        final n = ReaderChromePalette.of(ReaderPaper.noite);
        expect(
          tester.widget<NeoBox>(_key('rs.sheet.papers.cream.card')).color,
          AppColors.paperCream,
        );
        expect(
          tester
              .widget<NeoBox>(_key('rs.sheet.papers.cream.card'))
              .border!
              .color,
          n.border,
        );
        expect(_estilo(tester, 'rs.sheet.fontLabel').color, n.label);
        expect(_estilo(tester, 'rs.sheet.fonts.lora.caption').color, n.caption);
        expect(_estilo(tester, 'rs.sheet.fonts.lora.sample').color, n.title);
        expect(
          _estilo(tester, 'rs.sheet.fonts.literata.sample').color,
          AppColors.ink,
          reason: 'sobre a brand, a tinta',
        );
        expect(_caixa(tester, 'rs.sheet.fonts.lora').color, n.well);
        expect(
          tester.widget<AppSvg>(_key('rs.sheet.spacing.tight.icon')).color,
          n.title,
        );
        expect(
          tester.widget<AppSvg>(_key('rs.sheet.spacing.medium.icon')).color,
          isNull,
          reason: 'sobre a brand, o ícone de tinta',
        );
        expect(_estilo(tester, 'rs.sheet.papers.night.name').color, n.title);
        expect(_cor(tester, 'rs.sheet.size.step1'), n.title);
        expect(_cor(tester, 'rs.sheet.size.step7'), n.dash);
      },
    );
  });
}
