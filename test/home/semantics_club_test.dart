import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/features/home/presentation/sections/book_club_ticket.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';
import '../support/pump_app.dart';

/// Só a seção, na largura do conteúdo (350), com o callback do CTA (a tela liga
/// `/clube/:clubId/discussao` na F12).
Future<void> _pumpSection(
  WidgetTester tester, {
  VoidCallback? onDiscussionTap,
}) async {
  await precacheAppIcons(tester);
  await tester.pumpWidget(
    ProviderScope(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            // Folga de 20 para os entalhes (−13) ficarem dentro da tela.
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 350,
              child: BookClubTicket(onDiscussionTap: onDiscussionTap),
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

/// Nó da `<section aria-label="Seu clube do livro">`: o `Semantics` raiz da seção (a Key `club` fica no
/// `ClipRRect` logo abaixo, sem nó próprio).
SemanticsNode _section(WidgetTester tester) => _node(tester, 'club');

/// Nó do AppText sob [id] (texto solto dentro da seção).
SemanticsNode _textNode(WidgetTester tester, String id) => tester.getSemantics(
  find.descendant(
    of: find.byKey(ValueKey<String>(id)),
    matching: find.byType(AppText),
    matchRoot: true,
  ),
);

/// Todos os nós abaixo de [root], em pré-ordem (ordem da árvore = ordem do documento).
List<SemanticsNode> _descendants(SemanticsNode root) {
  final out = <SemanticsNode>[];
  void visit(SemanticsNode n) {
    n.visitChildren((c) {
      out.add(c);
      visit(c);
      return true;
    });
  }

  visit(root);
  return out;
}

/// Filhos diretos na ordem da árvore.
List<SemanticsNode> _children(SemanticsNode n) {
  final out = <SemanticsNode>[];
  n.visitChildren((c) {
    out.add(c);
    return true;
  });
  return out;
}

List<String> _childLabels(SemanticsNode n) => [
  for (final c in _children(n)) c.label,
];

/// Ordem de travessia do leitor de tela (a do Flutter ordena por geometria).
List<String> _traversalLabels(SemanticsNode n) => [
  for (final c in n.debugListChildrenInOrder(
    DebugSemanticsDumpOrder.traversalOrder,
  ))
    c.label,
];

Set<SemanticsAction> _actionsOf(SemanticsNode n) {
  final data = n.getSemanticsData();
  return {
    for (final a in SemanticsAction.values)
      if (data.hasAction(a)) a,
  };
}

const _meeting = 'Próximo encontro: quinta, 24 de setembro, às 20h';

/// Filhos diretos da seção, na ordem do documento.
const _sectionChildren = [
  'Clube do livro',
  '11 participantes',
  'Leitoras de Capitu',
  'Dom Casmurro · até o cap. 100',
  'Progresso do grupo',
  'Você',
  'Grupo em 54%',
  'Você em 62%',
  'Abrir discussão',
  _meeting,
];

/// F09 — semântica e toques da seção `club`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'seção "Seu clube do livro" (container + explicitChildNodes): 10 nós na ordem do documento — texto da pílula, "11 participantes", h3 "Leitoras de Capitu", subtítulo, progressbar (54%), "Você", legendas, link "Abrir discussão" (com o badge "3 mensagens novas") e o canhoto; entalhes, perfuração, letras dos avatares e o "M" fora da árvore',
    (tester) async {
      final semantics = tester.ensureSemantics();
      setCanvasView(tester);
      await pumpApp(tester);

      final section = _section(tester);
      expect(section.label, 'Seu clube do livro');
      expect(section.flagsCollection.isHeader, isFalse);
      expect(section.flagsCollection.isLink, isFalse);
      expect(section.flagsCollection.isButton, isFalse);
      expect(section.mergeAllDescendantsIntoThisNode, isFalse);
      expect(
        section.rect.size,
        tester.getSize(find.byKey(const ValueKey('club'))),
      );
      debugPrint(
        '[semântica] filhos da seção: ${_childLabels(section).join(' | ')}',
      );
      expect(_childLabels(section), _sectionChildren);
      // A travessia do leitor de tela é a ordenação GEOMÉTRICA padrão do Flutter (não a da árvore): o canhoto
      // ocupa a altura toda, então o corpo inteiro vira um único grupo e a heurística troca vizinhos (ex.:
      // "11 participantes" antes de "Clube do livro"). O mesmo já ocorre no hero (F05) e no cartão do dia
      // (F07); fica registrado para a revisão de semântica da F12.
      // Fixada aqui como lista para que qualquer mudança (por exemplo, sort keys na F12) seja consciente: três
      // inversões em relação ao documento — pílula ↔ avatares, progressbar ↔ "Você", "Você em 62%" ↔ link.
      final traversal = _traversalLabels(section);
      debugPrint('[semântica] travessia da seção: ${traversal.join(' | ')}');
      expect(traversal, [
        '11 participantes',
        'Clube do livro',
        'Leitoras de Capitu',
        'Dom Casmurro · até o cap. 100',
        'Você',
        'Progresso do grupo',
        'Grupo em 54%',
        'Abrir discussão',
        'Você em 62%',
        _meeting,
      ]);

      final nodes = _children(section);
      expect(nodes, hasLength(10));
      expect(nodes[0], same(_textNode(tester, 'club.pill')));
      expect(nodes[1], same(_node(tester, 'club.avatars')));
      expect(nodes[2], same(_node(tester, 'club.title')));
      expect(nodes[3], same(_textNode(tester, 'club.subtitle')));
      expect(nodes[4], same(_node(tester, 'club.progressBar')));
      expect(nodes[5], same(_node(tester, 'club.youMarker')));
      expect(nodes[6], same(_textNode(tester, 'club.groupLabel')));
      expect(nodes[7], same(_textNode(tester, 'club.youLabel')));
      expect(nodes[8], same(_node(tester, 'club.cta')));
      // A Key `club.stub` está no SizedBox(92) ACIMA do Semantics do canhoto (o nó mais próximo dela é o da
      // seção); o conteúdo do canhoto cai no nó dele.
      expect(_node(tester, 'club.stub'), same(section));
      expect(nodes[9], same(_node(tester, 'club.stub.label')));
      expect(nodes[9], same(_node(tester, 'club.stub.time')));
      // Subárvore inteira: os 10 filhos + o badge dentro do link = 11 nós.
      final all = _descendants(section);
      expect(all.map((n) => n.label).toList(), [
        ..._sectionChildren.take(9),
        '3 mensagens novas',
        _meeting,
      ]);
      // aria-hidden (entalhes, perfuração) e decorações sem nome não geram nós: as Keys caem no nó da
      // seção (os entalhes) ou no do canhoto (a perfuração, excluída junto com o conteúdo dele).
      expect(_node(tester, 'club.notchTop'), same(section));
      expect(_node(tester, 'club.notchBottom'), same(section));
      expect(_node(tester, 'club.stub.perforation'), same(nodes[9]));
      expect(_node(tester, 'club.ticket'), same(section));
      // As letras dos avatares e o "M" do marcador ficam dentro dos nós com aria-label.
      for (var i = 0; i < 4; i++) {
        expect(_node(tester, 'club.avatar$i'), same(nodes[1]), reason: '$i');
      }
      // Nenhum texto interno vira nó dentro da seção (o "M" do cabeçalho da F03 fica fora dela).
      final labels = {for (final n in all) n.label};
      for (final label in [
        'A',
        'J',
        'L',
        '+8',
        'M',
        '3',
        'ENCONTRO',
        'QUI',
        '24',
        'SET',
        '20h',
        'Leitoras de',
        'Capitu',
      ]) {
        expect(labels.contains(label), isFalse, reason: label);
      }

      // Papéis: 1 cabeçalho (h3, nível 3), 1 link, nenhum botão, nenhuma imagem; só a progressbar tem valor.
      final withSection = [section, ...all];
      expect(
        [
          for (final n in withSection)
            if (n.flagsCollection.isHeader)
              (n.label, n.getSemanticsData().headingLevel),
        ],
        [('Leitoras de Capitu', 3)],
      );
      expect(
        [
          for (final n in withSection)
            if (n.flagsCollection.isLink) n.label,
        ],
        ['Abrir discussão'],
      );
      expect(withSection.where((n) => n.flagsCollection.isButton), isEmpty);
      expect(withSection.where((n) => n.flagsCollection.isImage), isEmpty);
      expect(
        [
          for (final n in withSection)
            if (n.value.isNotEmpty) (n.label, n.value),
        ],
        [('Progresso do grupo', '54%')],
      );
      for (final n in withSection) {
        expect(n.hint, isEmpty, reason: n.label);
        expect(n.tooltip, isEmpty, reason: n.label);
        expect(n.label, isNot(contains('\n')), reason: n.label);
      }

      // <h3>Leitoras de<br>Capitu</h3>: um nó só, sem a quebra, do tamanho do título (2 linhas).
      final title = nodes[2];
      expect(title.flagsCollection.isHeader, isTrue);
      expect(title.childrenCount, 0);
      expect(
        title.rect.size,
        tester.getSize(find.byKey(const ValueKey('club.title'))),
      );

      // Link: nome = texto visível; o badge é um nó próprio dentro dele (sem papel nem ação).
      final link = nodes[8];
      expect(link.flagsCollection.isLink, isTrue);
      expect(link.flagsCollection.isButton, isFalse);
      // Na tela a rota do CTA só é ligada na F12 (sem callback, sem ação); com o callback, ver o teste de
      // toques abaixo.
      expect(_actionsOf(link), isEmpty);
      expect(_childLabels(link), ['3 mensagens novas']);
      final badge = _children(link).single;
      expect(badge, same(_node(tester, 'club.cta.badge')));
      expect(_actionsOf(badge), isEmpty);
      expect(badge.flagsCollection.isLink, isFalse);
      expect(
        link.rect.size,
        tester.getSize(find.byKey(const ValueKey('club.cta'))),
      );

      // Os demais nós não são interativos.
      for (final n in [...nodes.take(8), nodes[9]]) {
        expect(_actionsOf(n), isEmpty, reason: n.label);
      }
      // Canhoto: um nó do tamanho do canhoto inteiro.
      expect(
        nodes[9].rect.size,
        tester.getSize(find.byKey(const ValueKey('club.stub'))),
      );
      semantics.dispose();
    },
  );

  testWidgets(
    'toques: só o CTA (o <a> inteiro, 221 × 46) chama onDiscussionTap — no balão, no rótulo, no badge, perto das pontas arredondadas (12 px para dentro) e pela ação semântica; pílula, avatares, título, trilho, marcador, legendas, canhoto e entalhes não disparam nada',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await _pumpSection(tester, onDiscussionTap: () => taps++);
      Rect rect(String id) => tester.getRect(find.byKey(ValueKey(id)));
      final cta = rect('club.cta');
      // Com o callback: o link tem a ação de toque; nenhum outro nó da seção tem ação.
      final section = _section(tester);
      final withActions = {
        for (final n in _descendants(section))
          if (_actionsOf(n).isNotEmpty) n.label: _actionsOf(n),
      };
      expect(withActions, {
        'Abrir discussão': {SemanticsAction.tap},
      });
      expect(_actionsOf(section), isEmpty);

      await tester.tap(find.byKey(const ValueKey('club.cta')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('club.cta.icon')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('club.cta.label')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('club.cta.badge')));
      await tester.pumpAndSettle();
      for (final (what, point) in [
        ('perto da ponta esquerda', Offset(cta.left + 12, cta.center.dy)),
        ('perto da ponta direita', Offset(cta.right - 12, cta.center.dy)),
        ('acima do rótulo', Offset(cta.center.dx, cta.top + 3)),
      ]) {
        debugPrint('[toque] dentro do CTA: $what em $point');
        await tester.tapAt(point);
        await tester.pumpAndSettle();
      }
      tester.semantics.tap(
        find.semantics.byPredicate(
          (n) => n.flagsCollection.isLink && n.label == 'Abrir discussão',
        ),
      );
      await tester.pumpAndSettle();
      expect(taps, 8);

      for (final id in [
        'club.pill',
        'club.avatar0',
        'club.avatar3',
        'club.title',
        'club.subtitle',
        'club.progressBar',
        'club.youMarker',
        'club.groupLabel',
        'club.youLabel',
        'club.stub.label',
        'club.stub.day',
        'club.stub.time',
      ]) {
        await tester.tap(find.byKey(ValueKey(id)), warnIfMissed: false);
      }
      final ticket = rect('club.ticket');
      final notch = rect('club.notchTop');
      for (final (what, point) in [
        ('fundo do ticket', Offset(ticket.left + 150, ticket.top + 45)),
        (
          'entre o título e o trilho',
          Offset(cta.center.dx, rect('club.subtitle').bottom + 7),
        ),
        ('entre as legendas e o CTA', Offset(cta.center.dx, cta.top - 7)),
        ('abaixo do CTA', Offset(cta.center.dx, cta.bottom + 9)),
        (
          'entalhe (metade visível)',
          Offset(notch.center.dx, notch.center.dy + 6),
        ),
      ]) {
        debugPrint('[toque] sem efeito: $what em $point');
        await tester.tapAt(point);
      }
      await tester.pumpAndSettle();
      expect(taps, 8);
      semantics.dispose();
    },
  );
}
