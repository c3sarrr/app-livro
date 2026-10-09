// G19.2 — de onde vem o texto dos cartões da tela 25 (R3) e quem está sem lugar (D-199): o texto canônico dos itens
// do EPUB que têm anotação, lido num isolate (como a busca da G12) e guardado enquanto a tela vive; cada âncora é
// reancorada como no leitor (G13: o mesmo arquivo usa os deslocamentos; outro, a citação). Sem o arquivo, ou com erro
// ao ler, o recuo pela citação guardada — e ninguém fica "sem lugar" (não dá para saber).
import 'dart:isolate';

import '../../reader/annotations/domain/annotation.dart';
import '../../reader/content/chapter_content.dart';
import '../../reader/content/epub_book.dart';
import '../../reader/domain/anchoring.dart';
import '../../reader/domain/locator.dart';
import '../domain/card_text.dart';
import '../domain/highlight_card.dart';

/// Os trechos de cada cartão (por `group_id`) e os grupos sem lugar.
final class CardTexts {
  const CardTexts(this.byGroup, this.orphans);
  final Map<String, List<CardSpan>> byGroup;
  final Set<String> orphans;
}

abstract interface class CardTextSource {
  Future<CardTexts> textsFor(List<HighlightCard> cards);
}

/// Os itens que marcam o texto: grifos, desenhos e notas à mão (a nota de texto fica embaixo, no post-it).
Iterable<Annotation> markedItems(HighlightCard c) =>
    c.items.where((a) => a.kind != AnnotationKind.note);

List<CardQuote> _quotes(HighlightCard c) => [
  for (final a in markedItems(c))
    if (a.anchor case EpubAnchor(:final quote) when quote.exact.isNotEmpty)
      (
        id: a.id,
        prefix: quote.prefix,
        exact: quote.exact,
        suffix: quote.suffix,
      ),
];

/// Só a citação guardada (o livro não está no aparelho).
final class AnchorOnlyCardTextSource implements CardTextSource {
  const AnchorOnlyCardTextSource();

  @override
  Future<CardTexts> textsFor(List<HighlightCard> cards) async => CardTexts({
    for (final c in cards) c.groupId: spansFromQuotes(_quotes(c)),
  }, const {});
}

/// O texto canônico dos itens [spines] do EPUB em [path].
typedef SpineTexts = Future<Map<int, String>> Function(
  String path,
  List<int> spines,
);

/// Padrão: abre o EPUB num isolate (fora da UI) e lê os itens pedidos.
Future<Map<int, String>> isolateSpineTexts(String path, List<int> spines) =>
    Isolate.run(() {
      final book = EpubBook.open(path);
      try {
        return {for (final s in spines) s: chapterOf(book, s).item.text};
      } finally {
        book.close();
      }
    });

final class EpubCardTextSource implements CardTextSource {
  EpubCardTextSource({
    required this.path,
    required this.sha,
    this.spineTexts = isolateSpineTexts,
  });

  /// O arquivo do livro (`null` = não está no aparelho).
  final String? path;

  /// O sha do conteúdo do arquivo de agora.
  final String sha;
  final SpineTexts spineTexts;
  final Map<int, String> _cache = {};

  @override
  Future<CardTexts> textsFor(List<HighlightCard> cards) async {
    final p = path;
    if (p == null) return const AnchorOnlyCardTextSource().textsFor(cards);
    final need = <int>{
      for (final c in cards)
        for (final a in markedItems(c))
          if (a.anchor case EpubAnchor(:final spine)
              when !_cache.containsKey(spine))
            spine,
    };
    if (need.isNotEmpty) {
      try {
        _cache.addAll(await spineTexts(p, need.toList()..sort()));
      } on Object {
        return const AnchorOnlyCardTextSource().textsFor(cards);
      }
    }
    final byGroup = <String, List<CardSpan>>{};
    final orphans = <String>{};
    for (final c in cards) {
      final marks = <CardMark>[];
      int? spine;
      var lost = false;
      for (final a in markedItems(c)) {
        final anchor = a.anchor;
        if (anchor is! EpubAnchor) continue;
        // um cartão fica num item só do livro (o do 1º trecho)
        if (spine != null && anchor.spine != spine) continue;
        final text = _cache[anchor.spine];
        if (text == null) continue;
        spine = anchor.spine;
        switch (reanchor(anchor, text, currentSha: sha)) {
          case Anchored(:final start, :final end):
            marks.add((id: a.id, start: start, end: end));
          case Orphaned():
            lost = true;
        }
      }
      final text = spine == null ? null : _cache[spine];
      if (text == null || marks.isEmpty) {
        byGroup[c.groupId] = spansFromQuotes(_quotes(c));
        if (lost) orphans.add(c.groupId);
        continue;
      }
      byGroup[c.groupId] = cardSpans(text, marks);
    }
    return CardTexts(byGroup, orphans);
  }
}
