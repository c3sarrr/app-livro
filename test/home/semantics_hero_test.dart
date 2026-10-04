import 'package:app_leitura/features/home/presentation/sections/continue_reading_hero.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/overrides_do_mundo.dart';
import '../support/canvas.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';
import '../support/pump_app.dart';

/// Só a seção, com os callbacks (a tela liga os destinos na F12).
Future<void> _pumpHero(
  WidgetTester tester, {
  VoidCallback? onContinue,
  VoidCallback? onHighlights,
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
            child: ContinueReadingHero(
              onContinueTap: onContinue,
              onHighlightsTap: onHighlights,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

SemanticsNode _node(WidgetTester tester, String id) =>
    tester.getSemantics(find.byKey(ValueKey<String>(id)));

/// F05 — 5.5: semântica e toques da seção `hero`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '5.5 seção "Continuar lendo" (container + explicitChildNodes): h2, link, botão (14), barra (62%) e textos como nós próprios',
    (tester) async {
      final semantics = tester.ensureSemantics();
      setCanvasView(tester);
      await pumpApp(tester);

      // <section aria-label="Continuar lendo">: nó próprio que NÃO absorve os filhos.
      final section = _node(tester, 'hero');
      expect(section.label, 'Continuar lendo');
      expect(section.flagsCollection.isHeader, isFalse);
      expect(section.flagsCollection.isLink, isFalse);
      expect(section.flagsCollection.isButton, isFalse);
      expect(section.childrenCount, greaterThan(1));

      // <h2>Dom Casmurro</h2>.
      final title = _node(tester, 'hero.title');
      expect(title.label, 'Dom Casmurro');
      expect(title.flagsCollection.isHeader, isTrue);
      expect(title.getSemanticsData().headingLevel, 2);
      expect(title.childrenCount, 0);
      expect(
        find.semantics.byPredicate(
          (n) => n.flagsCollection.isHeader && n.label == 'Dom Casmurro',
        ),
        findsOne,
      );

      // <a href>Continuar lendo</a>: link com o rótulo; ícone e rótulo sem nós próprios.
      final cta = _node(tester, 'hero.cta');
      expect(cta.label, 'Continuar lendo');
      expect(cta.flagsCollection.isLink, isTrue);
      expect(cta.flagsCollection.isButton, isFalse);
      expect(cta.childrenCount, 0);
      // Ação de toque: só com callback (a tela liga os destinos na F12) — ver o teste de toques.
      for (final id in ['hero.cta.icon', 'hero.cta.label']) {
        expect(_node(tester, id), same(cta), reason: id);
      }

      // <button aria-label="Destaques e notas deste livro (14)">: o badge "14" não vira nó.
      final notes = _node(tester, 'hero.notesButton');
      expect(notes.label, 'Destaques e notas deste livro (14)');
      expect(notes.flagsCollection.isButton, isTrue);
      expect(notes.childrenCount, 0);
      for (final id in ['hero.notesButton.icon', 'hero.notesButton.badge']) {
        expect(_node(tester, id), same(notes), reason: id);
      }
      expect(find.semantics.byLabel('14'), findsNothing);

      // role="progressbar" aria-label="Progresso do livro" aria-valuenow="62".
      final bar = _node(tester, 'hero.progressBar');
      expect(bar.label, 'Progresso do livro');
      expect(bar.value, '62%');
      expect(bar.childrenCount, 0);
      expect(_node(tester, 'hero.progressFill'), same(bar));

      // Brilhos (aria-hidden): sem nó próprio — caem no nó da seção.
      for (final id in ['hero.sparkleLarge', 'hero.sparkleSmall']) {
        expect(_node(tester, id), same(section), reason: id);
      }

      // Textos visíveis continuam legíveis (como no navegador), cada um como nó de texto.
      for (final text in [
        'Cap. 92 de 148',
        'Machado de Assis',
        '62%',
        '~2h 10min',
        'MACHADO DE ASSIS', // a quebra forçada da arte não chega à semântica
      ]) {
        expect(find.semantics.byLabel(text), findsOne, reason: text);
      }
      expect(find.semantics.byLabel('MACHADO DE\nASSIS'), findsNothing);
      // "Continuar lendo" aparece 2 vezes: o rótulo da seção e o link.
      expect(find.semantics.byLabel('Continuar lendo'), findsNWidgets(2));
      semantics.dispose();
    },
  );

  testWidgets(
    '5.5 toques: CTA e botão de destaques chamam os callbacks (toque e ação semântica); toque fora não dispara',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var continueTaps = 0, highlightTaps = 0;
      await _pumpHero(
        tester,
        onContinue: () => continueTaps++,
        onHighlights: () => highlightTaps++,
      );
      for (final id in ['hero.cta', 'hero.notesButton']) {
        expect(
          _node(tester, id).getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
          reason: id,
        );
      }
      await tester.tap(find.byKey(const ValueKey('hero.cta')));
      await tester.pumpAndSettle();
      expect((continueTaps, highlightTaps), (1, 0));
      await tester.tap(find.byKey(const ValueKey('hero.notesButton')));
      await tester.pumpAndSettle();
      expect((continueTaps, highlightTaps), (1, 1));
      tester.semantics.tap(
        find.semantics.byPredicate(
          (n) => n.flagsCollection.isLink && n.label == 'Continuar lendo',
        ),
      );
      tester.semantics.tap(
        find.semantics.byLabel('Destaques e notas deste livro (14)'),
      );
      await tester.pumpAndSettle();
      expect((continueTaps, highlightTaps), (2, 2));
      // Fundo do cartão (fora dos alvos): nenhum callback.
      final hero = tester.getRect(find.byKey(const ValueKey('hero')));
      await tester.tapAt(hero.topLeft + const Offset(10, 190));
      await tester.pumpAndSettle();
      expect((continueTaps, highlightTaps), (2, 2));
      semantics.dispose();
    },
  );
}
