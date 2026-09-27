import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

SemanticsNode _node(WidgetTester tester, String id) =>
    tester.getSemantics(find.byKey(ValueKey<String>(id)));

/// Nó do AppText sob [id] (caixas como a pílula e os chips não têm nó próprio).
SemanticsNode _textNode(WidgetTester tester, String id) => tester.getSemantics(
  find.descendant(
    of: find.byKey(ValueKey<String>(id)),
    matching: find.byType(AppText),
    matchRoot: true,
  ),
);

/// `aria-label` do gráfico no arquivo (literal).
const _weekAria =
    'Minutos lidos por dia: segunda 32, terça 45, quarta 30, quinta 22, sexta 38, sábado 55, hoje 18 de 30';

/// Filhos da seção na ordem do documento: o h3, os textos visíveis e o gráfico (um nó com o aria-label).
const _children = [
  'Seu dia de leitura',
  '12 dias',
  '18',
  'de 30 min',
  'Faltam 12 min para fechar a meta de hoje.',
  '24 páginas',
  '2 destaques',
  'Esta semana',
  '4h 00min no total',
  _weekAria,
  'S',
  'T',
  'Q',
  'Q',
  'S',
  'S',
  'Hoje',
  'Mais 2 dias para o selo de 14 dias',
];

/// F07 — semântica da seção `today`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'seção "Seu dia de leitura" (container + explicitChildNodes): h3, textos visíveis e o gráfico com o aria-label do arquivo',
    (tester) async {
      final semantics = tester.ensureSemantics();
      setCanvasView(tester);
      await pumpApp(tester);

      // <section aria-label="Seu dia de leitura">: nó próprio que NÃO absorve os filhos.
      final section = _node(tester, 'today');
      expect(section.label, 'Seu dia de leitura');
      expect(section.flagsCollection.isHeader, isFalse);
      expect(section.flagsCollection.isLink, isFalse);
      expect(section.flagsCollection.isButton, isFalse);
      expect(
        section.rect.size,
        tester.getSize(find.byKey(const ValueKey('today'))),
      );

      final labels = <String>[];
      section.visitChildren((n) {
        labels.add(n.label);
        return true;
      });
      debugPrint('[semântica] filhos da seção: ${labels.join(' | ')}');
      expect(labels, _children);

      // <h3>Seu dia de <span>leitura</span></h3>: um só nó de cabeçalho com o texto dos dois trechos.
      final title = _node(tester, 'today.title');
      expect(title.label, 'Seu dia de leitura');
      expect(title.flagsCollection.isHeader, isTrue);
      expect(title.getSemanticsData().headingLevel, 3);
      expect(title.childrenCount, 0);
      expect(
        find.semantics.byPredicate(
          (n) => n.flagsCollection.isHeader && n.label == 'Seu dia de leitura',
        ),
        findsOne,
      );
      // O rótulo da seção + o cabeçalho.
      expect(find.semantics.byLabel('Seu dia de leitura'), findsNWidgets(2));

      // Textos visíveis: nós de texto próprios, sem papel de botão/link (nada é tocável nesta seção).
      for (final (id, text) in [
        ('today.streakPill', '12 dias'),
        ('today.dial.value', '18'),
        ('today.dial.caption', 'de 30 min'),
        (
          'today.goalText.sentence',
          'Faltam 12 min para fechar a meta de hoje.',
        ),
        ('today.chip.pages', '24 páginas'),
        ('today.chip.highlights', '2 destaques'),
        ('today.week.title', 'Esta semana'),
        ('today.week.total', '4h 00min no total'),
        ('today.week.label6', 'Hoje'),
        ('today.footer.text', 'Mais 2 dias para o selo de 14 dias'),
      ]) {
        final node = _textNode(tester, id);
        expect(node.label, text, reason: id);
        expect(node, isNot(same(section)), reason: id);
        expect(node.flagsCollection.isButton, isFalse, reason: id);
        expect(node.flagsCollection.isLink, isFalse, reason: id);
        expect(node.flagsCollection.isHeader, isFalse, reason: id);
        expect(node.childrenCount, 0, reason: id);
      }

      // <div aria-label="Minutos lidos por dia: …">: um nó com o rótulo literal e nada dentro (as barras
      // e a linha tracejada ficam fora).
      final chart = _node(tester, 'today.week.chart');
      expect(chart.label, _weekAria);
      expect(chart.childrenCount, 0);
      for (final id in [
        'today.week.goalLine',
        'today.week.bar0',
        'today.week.bar0.fill',
        'today.week.bar6',
        'today.week.bar6.fill',
      ]) {
        expect(_node(tester, id), same(chart), reason: id);
      }

      // aria-hidden: círculos, chama, desenho do dial e brilho não geram nós (caem no nó da seção).
      for (final id in [
        'today.decoCircleLarge',
        'today.decoCircleSmall',
        'today.streakPill.icon',
        'today.dial.svg',
        'today.footer.icon',
      ]) {
        expect(_node(tester, id), same(section), reason: id);
      }

      // Nenhuma ação na seção (o arquivo não tem links nem botões aqui).
      final actionable = <String>[];
      void visit(SemanticsNode n) {
        final data = n.getSemanticsData();
        if (data.hasAction(SemanticsAction.tap) ||
            n.flagsCollection.isButton ||
            n.flagsCollection.isLink) {
          actionable.add(n.label);
        }
        n.visitChildren((c) {
          visit(c);
          return true;
        });
      }

      visit(section);
      expect(actionable, isEmpty);
      semantics.dispose();
    },
  );
}
