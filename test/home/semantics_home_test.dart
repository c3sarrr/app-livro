import 'dart:ui' show Tristate;

import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

/// Papel de um nó, pelas flags (o que o leitor de tela anuncia).
String _role(SemanticsNode n) {
  final f = n.flagsCollection;
  if (f.isHeader) return 'cabeçalho';
  if (f.isLink) return 'link';
  if (f.isButton) return 'botão';
  if (n.value.isNotEmpty) return 'barra de progresso';
  return n.childrenCount > 0 ? 'seção' : 'rótulo';
}

List<SemanticsNode> _tree(WidgetTester tester) =>
    find.semantics.byPredicate((_) => true).evaluate().toList();

Iterable<SemanticsNode> _labelled(WidgetTester tester) =>
    _tree(tester).where((n) => n.label.isNotEmpty);

Future<void> _canvas(WidgetTester tester) async {
  setCanvasView(tester);
  await pumpApp(tester);
}

bool _excludes(Widget w) =>
    (w is ExcludeSemantics && w.excluding) ||
    (w is Semantics && w.excludeSemantics);

/// O elemento está fora da árvore (`aria-hidden`): sob um `ExcludeSemantics`/`Semantics(excludeSemantics)` ou
/// é um widget (`AppSvg`, o entalhe) cuja raiz construída já é o `ExcludeSemantics`.
bool _excluded(Finder f) {
  if (find
      .ancestor(of: f, matching: find.byWidgetPredicate(_excludes))
      .evaluate()
      .isNotEmpty) {
    return true;
  }
  Element? first;
  f.evaluate().single.visitChildren((e) => first ??= e);
  return first != null && _excludes(first!.widget);
}

Finder _key(String id) => find.byKey(ValueKey<String>(id));

/// Todo rótulo/valor do arquivo (§12.2): (rótulo, papel, valor).
const _expected = <(String, String, String)>[
  // Seções (`<section aria-label>` / `<nav aria-label>`) e os 2 nós com o mesmo nome do HTML.
  ('Continuar lendo', 'seção', ''),
  ('Continuar lendo', 'link', ''), // o <a> do CTA
  ('Também lendo', 'seção', ''),
  ('Também lendo', 'cabeçalho', ''),
  ('Seu dia de leitura', 'seção', ''),
  ('Seu dia de leitura', 'cabeçalho', ''),
  ('Para você', 'seção', ''),
  ('Para você', 'cabeçalho', ''),
  ('Seu clube do livro', 'seção', ''),
  ('Adicionados recentemente', 'seção', ''),
  ('Navegação principal', 'seção', ''),
  // Rótulos próprios.
  ('Notificações, 2 novas', 'botão', ''),
  ('Destaques e notas deste livro (14)', 'botão', ''),
  ('Progresso do livro', 'barra de progresso', '62%'),
  (
    'Minutos lidos por dia: segunda 32, terça 45, quarta 30, quinta 22, sexta 38, sábado 55, hoje 18 de 30',
    'rótulo',
    '',
  ),
  ('11 participantes', 'rótulo', ''),
  ('Progresso do grupo', 'barra de progresso', '54%'),
  ('Você', 'rótulo', ''),
  ('3 mensagens novas', 'rótulo', ''),
  ('Próximo encontro: quinta, 24 de setembro, às 20h', 'rótulo', ''),
  ('Mais opções para Frankenstein', 'botão', ''),
  ('Mais opções para O Alienista', 'botão', ''),
  ('Mais opções para Senhora', 'botão', ''),
  ('Scanner: escanear livro ou página', 'link', ''),
  // Cabeçalhos que não repetem o nome de uma seção.
  ('Continue sua história.', 'cabeçalho', ''),
  ('Dom Casmurro', 'cabeçalho', ''),
  ('Leitoras de Capitu', 'cabeçalho', ''),
  ('Recém-chegados', 'cabeçalho', ''),
];

/// Cabeçalhos (`header: true`) e seus níveis (`<h1>`–`<h3>`).
const _headers = <(String, int)>[
  ('Continue sua história.', 1),
  ('Dom Casmurro', 2),
  ('Também lendo', 3),
  ('Seu dia de leitura', 3),
  ('Para você', 3),
  ('Leitoras de Capitu', 3),
  ('Recém-chegados', 3),
];

/// Decorativos (`aria-hidden`): brilhos, círculos, desenhos, entalhes, perfuração, fade, FAB e ícones.
const _decorative = <String>[
  'header.bell.icon',
  'header.bell.dot',
  'hero.sparkleLarge',
  'hero.sparkleSmall',
  'hero.cta.icon',
  'hero.notesButton.icon',
  'hero.notesButton.badge',
  'alsoReading.card1.ring.svg',
  'alsoReading.card2.ring.svg',
  'today.decoCircleLarge',
  'today.decoCircleSmall',
  'today.streakPill.icon',
  'today.dial.svg',
  'today.week.goalLine',
  'today.footer.icon',
  'forYou.seeAll.icon',
  'forYou.reasonChip.icon',
  'club.cta.icon',
  'club.notchTop',
  'club.notchBottom',
  'club.stub.perforation',
  'recent.libraryLink.icon',
  'recent.row0.more.icon',
  'recent.row1.more.icon',
  'recent.row2.more.icon',
  'bottomFade',
  'nav.scanner.fab',
  'nav.scanner.icon',
  'nav.home.icon',
  'nav.library.icon',
  'nav.clubs.icon',
  'nav.profile.icon',
];

/// Ordem de travessia do leitor de tela (a do Flutter ordena por geometria) × ordem da árvore (= HTML).
List<String> _treeOrder(SemanticsNode root) {
  final out = <String>[];
  void visit(SemanticsNode n) {
    if (n.label.isNotEmpty) out.add(n.label);
    n.visitChildren((c) {
      visit(c);
      return true;
    });
  }

  visit(root);
  return out;
}

List<String> _traversalOrder(SemanticsNode root) {
  final out = <String>[];
  void visit(SemanticsNode n) {
    if (n.label.isNotEmpty) out.add(n.label);
    for (final c in n.debugListChildrenInOrder(
      DebugSemanticsDumpOrder.traversalOrder,
    )) {
      visit(c);
    }
  }

  visit(root);
  return out;
}

/// F12 12.2 — acessibilidade da tela inteira (espelho dos `aria-*` do arquivo).
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '12.2 cada rótulo/valor do arquivo existe, com o papel certo, em nós próprios; as 4 exceções têm exatamente 2 nós (seção + link/cabeçalho) e mais nada carrega esses nomes',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _canvas(tester);
      final nodes = _labelled(tester).toList();
      for (final (label, role, value) in _expected) {
        final matches = nodes
            .where((n) => n.label == label && _role(n) == role)
            .toList();
        final times = _expected
            .where((e) => e.$1 == label && e.$2 == role)
            .length;
        expect(
          matches,
          hasLength(times),
          reason: '"$label" como $role: $times nó(s) próprio(s)',
        );
        for (final n in matches) {
          expect(n.value, value, reason: '"$label" → valor');
        }
      }
      // Nada além do esperado carrega esses nomes: contagem total por rótulo = soma das linhas da tabela.
      for (final label in {for (final e in _expected) e.$1}) {
        expect(
          nodes.where((n) => n.label == label),
          hasLength(_expected.where((e) => e.$1 == label).length),
          reason: 'nós com o rótulo "$label"',
        );
      }
      debugPrint(
        '[semântica] ${_expected.length} (rótulo, papel) do arquivo → ${{for (final e in _expected) e.$1}.length} rótulos distintos, todos em nós próprios; árvore com ${nodes.length} nós rotulados',
      );
      semantics.dispose();
    },
  );

  testWidgets(
    '12.2 nenhum rótulo é concatenado: nenhum nó fala de 2 rótulos da tabela ao mesmo tempo (os links "sem aria-label" levam só o texto do próprio conteúdo)',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _canvas(tester);
      final labels = {for (final e in _expected) e.$1};
      for (final n in _labelled(tester)) {
        final contained = labels.where(n.label.contains).toList();
        expect(
          contained.length,
          lessThanOrEqualTo(1),
          reason: 'nó "${n.label.replaceAll('\n', ' ⏎ ')}" funde $contained',
        );
      }
      semantics.dispose();
    },
  );

  testWidgets(
    '12.2 cabeçalhos: exatamente 7 nós com `header`, nos níveis do HTML (h1 "Continue sua história.", h2 "Dom Casmurro", h3 nos 5 títulos de seção); títulos de duas linhas sem quebra no rótulo',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _canvas(tester);
      final headers = _tree(tester)
          .where((n) => n.flagsCollection.isHeader)
          .toList();
      expect([
        for (final n in headers) (n.label, n.getSemanticsData().headingLevel),
      ], _headers);
      for (final n in headers) {
        expect(n.label, isNot(contains('\n')), reason: n.label);
        expect(n.flagsCollection.isLink, isFalse, reason: n.label);
        expect(n.flagsCollection.isButton, isFalse, reason: n.label);
        expect(n.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      }
      semantics.dispose();
    },
  );

  testWidgets(
    '12.2 decorativos (`aria-hidden`) FORA da árvore: brilhos, círculos, desenho do dial, linha da meta, anéis, entalhes, perfuração, fade, FAB e ícones; o "18" e o "de 30 min" do dial continuam legíveis',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _canvas(tester);
      for (final id in _decorative) {
        expect(_key(id), findsOneWidget, reason: id);
        expect(_excluded(_key(id)), isTrue, reason: '$id deve estar fora');
      }
      // O texto do dial NÃO é decorativo.
      for (final (id, text) in [
        ('today.dial.value', '18'),
        ('today.dial.caption', 'de 30 min'),
      ]) {
        expect(_excluded(_key(id)), isFalse, reason: id);
        expect(tester.getSemantics(_key(id)).label, text, reason: id);
      }
      // Nenhum nó da árvore descreve um decorativo.
      final labels = _labelled(tester).map((n) => n.label).toList();
      for (final noise in ['sparkle', 'ic_', '.svg', 'bell', 'fade']) {
        expect(
          labels.where((l) => l.toLowerCase().contains(noise)),
          isEmpty,
          reason: noise,
        );
      }
      semantics.dispose();
    },
  );

  testWidgets(
    '12.2 item ativo da navegação com `selected: true` — só o Início — e a árvore da barra é o `<nav>` com 5 links',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _canvas(tester);
      final nav = tester.getSemantics(_key('nav'));
      expect(nav.label, 'Navegação principal');
      final selected = {
        for (final id in ['home', 'library', 'clubs', 'profile', 'scanner'])
          id: tester.getSemantics(_key('nav.$id')).flagsCollection.isSelected,
      };
      expect(selected, {
        'home': Tristate.isTrue,
        'library': Tristate.none,
        'clubs': Tristate.none,
        'profile': Tristate.none,
        'scanner': Tristate.none,
      });
      expect(
        _tree(tester)
            .where((n) => n.flagsCollection.isSelected == Tristate.isTrue),
        hasLength(1),
      );
      semantics.dispose();
    },
  );

  testWidgets(
    '12.2 toda ação da tela tem nó acionável: 1 `tap` por botão/link do mapa de toques (13 destinos + 3 "mais opções" + 5 da barra + "Ver tudo"/"Biblioteca") e nenhum nó rótulo-puro oferece ação',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _canvas(tester);
      final actionable = _tree(tester).where((n) {
        return n.getSemanticsData().hasAction(SemanticsAction.tap);
      }).toList();
      final byRole = <String, List<String>>{};
      for (final n in actionable) {
        byRole.putIfAbsent(_role(n), () => []).add(n.label);
      }
      // Botões: sino, destaques e os 3 "mais opções". Links: CTA, 2 cards, "Ver tudo", 3 itens, CTA do clube,
      // "Biblioteca", 3 linhas e os 5 itens da barra.
      expect(byRole['botão'], hasLength(5));
      expect(byRole['link'], hasLength(1 + 2 + 1 + 3 + 1 + 1 + 3 + 5));
      expect(byRole.keys.toSet(), {'botão', 'link'});
      semantics.dispose();
    },
  );

  group('12.2 diretrizes de acessibilidade (registradas; o visual não é alterado)', () {
    testWidgets(
      'iOS: todo alvo de toque tem ≥ 44 × 44 (iOSTapTargetGuideline) e todo alvo tem rótulo (labeledTapTargetGuideline)',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await _canvas(tester);
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        debugPrint(
          '[diretrizes] iOSTapTargetGuideline (44×44): PASSOU · labeledTapTargetGuideline: PASSOU',
        );
        semantics.dispose();
      },
    );

    testWidgets(
      'Android (48 × 48): reprova SOMENTE os 3 botões "Mais opções", que medem 44 × 44 no arquivo — falha registrada, visual intacto',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await _canvas(tester);
        final result = await androidTapTargetGuideline.evaluate(tester);
        expect(result.passed, isFalse);
        final reason = result.reason ?? '';
        final failing = RegExp(r'label: "([^"]+)"')
            .allMatches(reason)
            .map((m) => m.group(1))
            .toList();
        expect(failing, [
          'Mais opções para Frankenstein',
          'Mais opções para O Alienista',
          'Mais opções para Senhora',
        ]);
        expect(
          RegExp(r'but found Size\(44\.0, 44\.0\)').allMatches(reason),
          hasLength(3),
        );
        debugPrint(
          '[diretrizes] androidTapTargetGuideline (48×48): REPROVOU 3 nós — ${failing.join(' | ')} (44 × 44 no arquivo)',
        );
        semantics.dispose();
      },
    );

    testWidgets(
      'contraste do texto (textContrastGuideline): resultado do tema padrão e das 4 opções de brand / 4 de weekColor (informativo — as cores são do arquivo)',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await _canvas(tester);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(HomeScreen)),
        );
        final results = <String>[];
        Future<void> check(String name) async {
          await tester.pumpAndSettle();
          final r = await textContrastGuideline.evaluate(tester);
          results.add('$name: ${r.passed ? 'PASSOU' : 'REPROVOU'}');
          if (!r.passed) {
            results.add(
              '   ${(r.reason ?? '').split('\n').take(6).join('\n   ')}',
            );
          }
        }

        await check('padrão (brand #B6ACE4, weekColor #B6ACE4)');
        // O tema padrão passa: regressão aqui é falha real.
        expect(results.first, contains('PASSOU'));
        final notifier = container.read(homeThemeProvider.notifier);
        for (final c in AppColors.brandOptions.skip(1)) {
          notifier.setBrand(c);
          await check('brand ${_hex(c)}');
        }
        notifier.setBrand(AppColors.brandOptions.first);
        for (final c in AppColors.weekColorOptions.skip(1)) {
          notifier.setWeekColor(c);
          await check('weekColor ${_hex(c)}');
        }
        debugPrint(
          '[diretrizes] textContrastGuideline:\n${results.join('\n')}',
        );
        semantics.dispose();
      },
    );
  });

  testWidgets(
    '12.2 (informativo) ordem de travessia × ordem do HTML: os mesmos nós, mas o Flutter percorre por geometria; a diferença é registrada (decisão do usuário, ver relatório)',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _canvas(tester);
      // A raiz da árvore: o ancestral mais alto de qualquer nó.
      var root = tester.getSemantics(_key('nav'));
      while (root.parent != null) {
        root = root.parent!;
      }
      final tree = _treeOrder(root);
      final traversal = _traversalOrder(root);
      expect(traversal, unorderedEquals(tree));
      var moved = 0;
      for (var i = 0; i < tree.length; i++) {
        if (tree[i] != traversal[i]) moved++;
      }
      debugPrint(
        '[semântica] travessia × árvore: ${tree.length} nós rotulados, $moved posições diferentes',
      );
      semantics.dispose();
    },
  );
}

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6, '0')}';
