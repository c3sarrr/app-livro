import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/sections/also_reading_section.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/home_mock_repository.dart';
import '../fixtures/overrides_do_mundo.dart';
import '../support/fase_inicio.dart';
import '../support/load_fonts.dart';

/// Só a seção, com os callbacks (a Início liga `/livro/:bookId` e o "sem ação" do "play" — D-243 b).
Future<void> _pumpSection(
  WidgetTester tester, {
  ValueChanged<Book>? onBookTap,
  ValueChanged<Book>? onStartReadingTap,
}) async {
  await precacheInicio01(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overridesDoMundo,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 350,
            child: AlsoReadingSection(
              onBookTap: onBookTap,
              onStartReadingTap: onStartReadingTap,
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

/// O `<a>` do cartão de papel com página (sem `aria-label`): o nome é o texto do cartão na ordem do documento —
/// a capa (com o `<br>`), o anel, o título inteiro (as reticências são só da pintura), o autor e a pílula.
const _card2 =
    'Orgulho e\nPreconceito\n81%\nOrgulho e Preconceito\nJane Austen\nPapel · pág. 344';

/// Filhos da `<section aria-label="Também lendo">` na ordem do documento (prancha 01, L01a3): o h3, o contador, o
/// cartão do livro de papel sem página (o link da capa com o `aria-label`, o botão "play" e os textos soltos) e o
/// cartão do Orgulho (um link só).
const _children = [
  'Também lendo',
  '3',
  'Memórias Póstumas de Brás Cubas',
  'Iniciar leitura de Brás Cubas',
  'Brás Cubas',
  'Machado de Assis',
  'Papel · 3h 40min',
  _card2,
];

/// F06 — semântica e toques da seção `alsoReading`; desde a T03 a da prancha 01 (L01a3, D-253): o Brás Cubas de
/// papel sem página (capa = link com o título inteiro, "play" = botão sem ação até a T04) e o Orgulho de papel na
/// pág. 344 (o cartão inteiro é o link).
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'seção "Também lendo" (container + explicitChildNodes): h3, contador "3", o link da capa e o botão do Brás '
    'Cubas, os textos do cartão de papel e o link do Orgulho, na ordem do documento',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await abrirInicio01(tester);

      // <section aria-label="Também lendo">: nó próprio que NÃO absorve os filhos.
      final section = _node(tester, 'alsoReading');
      expect(section.label, 'Também lendo');
      expect(section.flagsCollection.isHeader, isFalse);
      expect(section.flagsCollection.isLink, isFalse);
      expect(section.flagsCollection.isButton, isFalse);
      final labels = <String>[];
      section.visitChildren((n) {
        labels.add(n.label);
        return true;
      });
      expect(labels, _children);

      // <h3>Também lendo</h3>.
      final title = _node(tester, 'alsoReading.title');
      expect(title.label, 'Também lendo');
      expect(title.flagsCollection.isHeader, isTrue);
      expect(title.getSemanticsData().headingLevel, 3);
      expect(title.childrenCount, 0);
      // "Também lendo" aparece 2 vezes: o rótulo da seção e o cabeçalho.
      expect(find.semantics.byLabel('Também lendo'), findsNWidgets(2));

      // Contador: <span>3</span> visível, lido como texto (sem papel de botão). O nó é o do AppText de dentro do
      // badge (a caixa do badge não tem nó próprio).
      final count = tester.getSemantics(
        find.descendant(
          of: find.byKey(const ValueKey('alsoReading.count')),
          matching: find.byType(AppText),
        ),
      );
      expect(count.label, '3');
      expect(count.flagsCollection.isButton, isFalse);
      expect(count, isNot(same(section)));

      // O cartão de papel sem página: <a aria-label="Memórias Póstumas de Brás Cubas"> na capa (o texto "Brás /
      // Cubas" da capa não entra — o aria-label manda) e <button aria-label="Iniciar leitura de Brás Cubas">.
      final capa = _node(tester, 'alsoReading.card1.cover');
      expect(capa.label, 'Memórias Póstumas de Brás Cubas');
      expect(capa.flagsCollection.isLink, isTrue);
      expect(capa.flagsCollection.isButton, isFalse);
      expect(capa.childrenCount, 0);
      for (final id in [
        'alsoReading.card1.cover.title',
        'alsoReading.card1.cover.spine',
        'alsoReading.card1.cover.hat',
        'alsoReading.card1.cover.brim',
      ]) {
        expect(_node(tester, id), same(capa), reason: id);
      }
      final play = _node(tester, 'alsoReading.card1.play');
      expect(play.label, 'Iniciar leitura de Brás Cubas');
      expect(play.flagsCollection.isButton, isTrue);
      expect(play.flagsCollection.isLink, isFalse);
      expect(play.childrenCount, 0);
      expect(_node(tester, 'alsoReading.card1.play.icon'), same(play));
      // O resto do cartão é texto solto (o cartão de papel não é link): título, autor e a pílula — o ícone dela é
      // `aria-hidden` e não muda o nome.
      for (final (id, texto) in [
        ('alsoReading.card1.title', 'Brás Cubas'),
        ('alsoReading.card1.author', 'Machado de Assis'),
        ('alsoReading.card1.meta', 'Papel · 3h 40min'),
      ]) {
        final n = tester.getSemantics(
          find.descendant(
            of: find.byKey(ValueKey<String>(id)),
            matching: find.byType(AppText),
            matchRoot: true,
          ),
        );
        expect(n.label, texto, reason: id);
        expect(n.flagsCollection.isLink, isFalse, reason: id);
        expect(n.flagsCollection.isButton, isFalse, reason: id);
      }
      expect(find.semantics.byLabel('Brás\nCubas'), findsNothing);

      // O cartão do Orgulho: <a href> sem aria-label → o nome é o texto do cartão; tudo dele cai nesse nó.
      final link = _node(tester, 'alsoReading.card2');
      expect(link.label, _card2);
      expect(link.flagsCollection.isLink, isTrue);
      expect(link.flagsCollection.isButton, isFalse);
      expect(link.childrenCount, 0);
      for (final id in [
        'alsoReading.card2.top',
        'alsoReading.card2.cover',
        'alsoReading.card2.cover.title',
        'alsoReading.card2.ring',
        'alsoReading.card2.ring.svg', // aria-hidden: não acrescenta nada ao nome
        'alsoReading.card2.ring.label',
        'alsoReading.card2.textBlock',
        'alsoReading.card2.title',
        'alsoReading.card2.author',
        'alsoReading.card2.meta',
        'alsoReading.card2.meta.icon', // aria-hidden
      ]) {
        expect(_node(tester, id), same(link), reason: id);
      }
      // Nenhum texto do cartão do Orgulho vira nó solto na seção.
      for (final text in [
        '81%',
        'Orgulho e Preconceito',
        'Jane Austen',
        'Orgulho e\nPreconceito',
        'Papel · pág. 344',
      ]) {
        expect(find.semantics.byLabel(text), findsNothing, reason: text);
      }
      semantics.dispose();
    },
  );

  testWidgets(
    'toques: a capa e o cartão do Orgulho chamam onBookTap com o livro, o "play" chama onStartReadingTap (toque e '
    'ação semântica); título, textos do cartão de papel e o vão entre os cartões não disparam',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final abertos = <Book>[];
      final plays = <Book>[];
      await _pumpSection(
        tester,
        onBookTap: abertos.add,
        onStartReadingTap: plays.add,
      );
      for (final id in [
        'alsoReading.card1.cover',
        'alsoReading.card1.play',
        'alsoReading.card2',
      ]) {
        expect(
          _node(tester, id).getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
          reason: id,
        );
      }
      await tester.tap(find.byKey(const ValueKey('alsoReading.card1.cover')));
      await tester.tap(find.byKey(const ValueKey('alsoReading.card1.play')));
      await tester.tap(find.byKey(const ValueKey('alsoReading.card2')));
      await tester.pumpAndSettle();
      expect(abertos, [
        HomeMockRepository.brasCubas,
        HomeMockRepository.orgulho,
      ]);
      expect(plays, [HomeMockRepository.brasCubas]);
      for (final rotulo in [
        'Memórias Póstumas de Brás Cubas',
        'Iniciar leitura de Brás Cubas',
        _card2,
      ]) {
        tester.semantics.tap(find.semantics.byLabel(rotulo));
      }
      await tester.pumpAndSettle();
      expect(abertos.map((b) => b.id), [
        'memorias-postumas-de-bras-cubas',
        'orgulho-e-preconceito',
        'memorias-postumas-de-bras-cubas',
        'orgulho-e-preconceito',
      ]);
      expect(plays, hasLength(2));
      // Cabeçalho, textos do cartão de papel e vão entre os cartões: nenhum callback.
      for (final id in [
        'alsoReading.title',
        'alsoReading.card1.title',
        'alsoReading.card1.meta',
      ]) {
        await tester.tap(find.byKey(ValueKey<String>(id)), warnIfMissed: false);
      }
      final c1 = tester.getRect(
        find.byKey(const ValueKey('alsoReading.card1')),
      );
      await tester.tapAt(Offset(c1.right + 6, c1.center.dy));
      await tester.pumpAndSettle();
      expect((abertos.length, plays.length), (4, 2));
      semantics.dispose();
    },
  );

  testWidgets(
    'sem callback: o link da capa, o botão e o link do cartão existem, mas não anunciam ação de toque',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpSection(tester);
      for (final (id, link) in [
        ('alsoReading.card1.cover', true),
        ('alsoReading.card1.play', false),
        ('alsoReading.card2', true),
      ]) {
        final n = _node(tester, id).getSemanticsData();
        expect(n.flagsCollection.isLink, link, reason: id);
        expect(n.flagsCollection.isButton, !link, reason: id);
        expect(n.hasAction(SemanticsAction.tap), isFalse, reason: id);
      }
      semantics.dispose();
    },
  );
}
