import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/sections/also_reading_section.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/home_mock_repository.dart';
import '../fixtures/overrides_do_mundo.dart';
import '../support/canvas.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';
import '../support/pump_app.dart';

/// Só a seção, com o callback (a tela liga o destino `/livro/:bookId` na F12).
Future<void> _pumpSection(
  WidgetTester tester, {
  ValueChanged<Book>? onBookTap,
}) async {
  await precacheAppIcons(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overridesDoMundo,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 350,
            child: AlsoReadingSection(onBookTap: onBookTap),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

SemanticsNode _node(WidgetTester tester, String id) =>
    tester.getSemantics(find.byKey(ValueKey<String>(id)));

/// Nome do link = textos do card na ordem do documento (como o nome calculado de um `<a>`); o Flutter
/// junta os rótulos dos filhos fundidos com "\n". A capa mantém o `<br>` do arquivo e o título vai inteiro
/// (as reticências são só da pintura).
const _cardNames = {
  'alsoReading.card1': 'Mrs.\nDalloway\n34%\nMrs. Dalloway\nVirginia Woolf',
  'alsoReading.card2':
      'Orgulho e\nPreconceito\n81%\nOrgulho e Preconceito\nJane Austen',
};

/// F06 — semântica e toques da seção `alsoReading`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'seção "Também lendo" (container + explicitChildNodes): h3, contador "2" e 2 links com o texto do card',
    (tester) async {
      final semantics = tester.ensureSemantics();
      setCanvasView(tester);
      await pumpApp(tester);

      // <section aria-label="Também lendo">: nó próprio que NÃO absorve os filhos.
      final section = _node(tester, 'alsoReading');
      expect(section.label, 'Também lendo');
      expect(section.flagsCollection.isHeader, isFalse);
      expect(section.flagsCollection.isLink, isFalse);
      expect(section.flagsCollection.isButton, isFalse);
      expect(section.childrenCount, greaterThan(1));

      // <h3>Também lendo</h3>.
      final title = _node(tester, 'alsoReading.title');
      expect(title.label, 'Também lendo');
      expect(title.flagsCollection.isHeader, isTrue);
      expect(title.getSemanticsData().headingLevel, 3);
      expect(title.childrenCount, 0);
      expect(
        find.semantics.byPredicate(
          (n) => n.flagsCollection.isHeader && n.label == 'Também lendo',
        ),
        findsOne,
      );
      // "Também lendo" aparece 2 vezes: o rótulo da seção e o cabeçalho.
      expect(find.semantics.byLabel('Também lendo'), findsNWidgets(2));

      // Contador: <span>2</span> visível, lido como texto (sem papel de botão). O nó é o do AppText de
      // dentro do badge (a caixa do badge não tem nó próprio: `getSemantics` da Key cairia na seção).
      final count = tester.getSemantics(
        find.descendant(
          of: find.byKey(const ValueKey('alsoReading.count')),
          matching: find.byType(AppText),
        ),
      );
      expect(count.label, '2');
      expect(count.flagsCollection.isButton, isFalse);
      expect(count, isNot(same(section)));
      expect(find.semantics.byLabel('2'), findsOne);

      // <a href>: link sem aria-label → o nome é o texto do card; tudo do card cai nesse nó.
      for (final MapEntry(key: card, value: name) in _cardNames.entries) {
        final link = _node(tester, card);
        debugPrint(
          '[semântica] $card: link "${link.label.replaceAll('\n', r'\n')}"',
        );
        expect(link.label, name, reason: card);
        expect(link.flagsCollection.isLink, isTrue, reason: card);
        expect(link.flagsCollection.isButton, isFalse, reason: card);
        expect(link.childrenCount, 0, reason: card);
        for (final id in [
          '$card.top',
          '$card.cover',
          '$card.cover.title',
          '$card.ring',
          '$card.ring.svg', // aria-hidden: não acrescenta nada ao nome
          '$card.ring.label',
          '$card.textBlock',
          '$card.title',
          '$card.author',
        ]) {
          expect(_node(tester, id), same(link), reason: id);
        }
      }
      // Nenhum texto do card vira nó solto na seção.
      for (final text in [
        '34%',
        '81%',
        'Mrs. Dalloway',
        'Virginia Woolf',
        'Orgulho e Preconceito',
        'Jane Austen',
        'Mrs.\nDalloway',
        'Orgulho e\nPreconceito',
      ]) {
        expect(find.semantics.byLabel(text), findsNothing, reason: text);
      }
      semantics.dispose();
    },
  );

  testWidgets(
    'toques: cada card chama o callback com o seu livro (toque e ação semântica); fora dos cards não dispara',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final tapped = <Book>[];
      await _pumpSection(tester, onBookTap: tapped.add);
      for (final card in _cardNames.keys) {
        expect(
          _node(tester, card).getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
          reason: card,
        );
      }
      await tester.tap(find.byKey(const ValueKey('alsoReading.card1')));
      await tester.pumpAndSettle();
      expect(tapped, [HomeMockRepository.mrsDalloway]);
      await tester.tap(find.byKey(const ValueKey('alsoReading.card2')));
      await tester.pumpAndSettle();
      expect(tapped, [
        HomeMockRepository.mrsDalloway,
        HomeMockRepository.pridePrejudice,
      ]);
      for (final name in _cardNames.values) {
        tester.semantics.tap(
          find.semantics.byPredicate(
            (n) => n.flagsCollection.isLink && n.label == name,
          ),
        );
      }
      await tester.pumpAndSettle();
      expect(tapped.map((b) => b.id), [
        'mrs-dalloway',
        'orgulho-e-preconceito',
        'mrs-dalloway',
        'orgulho-e-preconceito',
      ]);
      // Cabeçalho e vão entre os cards: nenhum callback.
      await tester.tap(find.byKey(const ValueKey('alsoReading.title')));
      final c1 = tester.getRect(
        find.byKey(const ValueKey('alsoReading.card1')),
      );
      await tester.tapAt(Offset(c1.right + 6, c1.center.dy));
      await tester.pumpAndSettle();
      expect(tapped, hasLength(4));
      semantics.dispose();
    },
  );

  testWidgets(
    'sem callback (tela antes da F12): os links existem, mas não anunciam ação de toque',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpSection(tester);
      for (final card in _cardNames.keys) {
        final link = _node(tester, card);
        expect(link.flagsCollection.isLink, isTrue, reason: card);
        expect(
          link.getSemanticsData().hasAction(SemanticsAction.tap),
          isFalse,
          reason: card,
        );
      }
      semantics.dispose();
    },
  );
}
