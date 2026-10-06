// G10.2 — conteúdo de um capítulo para o leitor (Anexo 03 §7.2): o item do spine aberto (blocos + texto
// canônico, G09) e o tamanho natural das imagens dele, lidos num isolate. O layout com `dart:ui` fica no
// isolate principal, em fatias.
import 'content_blocks.dart';
import 'epub_book.dart';
import 'image_size.dart';

/// Imagem maior que isto não tem o tamanho lido (fica sem espaço na página, como imagem quebrada).
const int maxImageBytes = 8 * 1024 * 1024;

final class ChapterContent {
  const ChapterContent({
    required this.spineIndex,
    required this.item,
    required this.imageSizes,
  });

  final int spineIndex;
  final ParsedItem item;

  /// Caminho da imagem no ZIP → (largura, altura) em px.
  final Map<String, (int, int)> imageSizes;
}

/// Abre o livro em [path], lê o item [spineIndex] e o tamanho das imagens dele (ponto de entrada do isolate).
ChapterContent loadChapter(String path, int spineIndex) {
  final book = EpubBook.open(path);
  try {
    return chapterOf(book, spineIndex);
  } finally {
    book.close();
  }
}

/// O mesmo, com o livro já aberto.
ChapterContent chapterOf(EpubBook book, int spineIndex) {
  final item = book.parseItem(spineIndex);
  final sizes = <String, (int, int)>{};
  for (final b in item.blocks) {
    if (b is! ImageBlock || sizes.containsKey(b.path)) continue;
    final name = book.zip.find(b.path);
    if (name == null) continue;
    try {
      final s = imageSizeOf(book.zip.read(name, maxBytes: maxImageBytes));
      if (s != null) sizes[b.path] = s;
    } on Object {
      // imagem quebrada ou grande demais: fica sem tamanho
    }
  }
  return ChapterContent(
    spineIndex: spineIndex,
    item: item,
    imageSizes: Map.unmodifiable(sizes),
  );
}
