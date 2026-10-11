// G11 (D-114) — as imagens do EPUB para a tela. A G10 reserva o lugar delas na página (tamanho lido do arquivo);
// aqui elas são lidas do arquivo (num isolate) e decodificadas na maior largura em que podem aparecer (a caixa
// do texto × densidade da tela), sob pedido da página que vai pintar. Ficam na memória até [budgetBytes] — as
// menos usadas saem primeiro — e a que chega avisa para a página repintar. Imagem que não abre fica como o
// espaço vazio que a página já reservou.
import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show Listenable, ValueNotifier;

import '../content/chapter_content.dart' show maxImageBytes;
import '../content/epub_book.dart';

/// Lê os bytes da imagem [href] (caminho dentro do EPUB); `null` = não está no arquivo.
typedef EpubImageLoader = Future<Uint8List?> Function(String href);

/// Lê as imagens do arquivo [path] num isolate (o fecho leva só o caminho).
EpubImageLoader isolateImageLoader(String path) =>
    (href) => Isolate.run(() => readEpubImage(path, href));

/// Os bytes da imagem [href] do EPUB em [path] (até [maxImageBytes]).
Uint8List? readEpubImage(String path, String href) {
  final book = EpubBook.open(path);
  try {
    return readImageOf(book, href);
  } finally {
    book.close();
  }
}

/// O mesmo, com o livro já aberto.
Uint8List? readImageOf(EpubBook book, String href) {
  final name = book.zip.find(href);
  return name == null ? null : book.zip.read(name, maxBytes: maxImageBytes);
}

/// Memória das imagens decodificadas (≈ 4 bytes por pixel): cabem algumas páginas ilustradas.
const int epubImagesBudget = 48 * 1024 * 1024;

final class EpubImageCache {
  EpubImageCache({
    required this.load,
    required this.maxWidth,
    this.budgetBytes = epubImagesBudget,
  });

  final EpubImageLoader load;

  /// Largura máxima em pixels físicos (a caixa do texto × dpr): maior que isso nunca aparece.
  final int maxWidth;
  final int budgetBytes;

  /// Em ordem de uso (a primeira é a que está há mais tempo sem aparecer).
  final Map<String, ui.Image> _images = {};
  final Set<String> _loading = {};
  final Set<String> _broken = {};
  final _changes = ValueNotifier<int>(0);
  bool _disposed = false;

  /// Avisa quando uma imagem chega (a página repinta).
  Listenable get changes => _changes;

  /// Quantas estão na memória (testes).
  int get length => _images.length;

  /// A imagem [href], se já está pronta; senão começa a ler e avisa em [changes] quando chegar.
  ui.Image? imageOf(String href) {
    final img = _images.remove(href);
    if (img != null) {
      _images[href] = img; // a mais recente
      return img;
    }
    if (!_disposed && !_broken.contains(href) && _loading.add(href)) {
      unawaited(_fetch(href));
    }
    return null;
  }

  Future<void> _fetch(String href) async {
    try {
      final bytes = await load(href);
      if (bytes == null || _disposed) {
        if (bytes == null) _broken.add(href);
        return;
      }
      final image = await decodeImageForWidth(bytes, maxWidth);
      if (_disposed) {
        image.dispose();
        return;
      }
      _images[href] = image;
      _trim();
      _changes.value++;
    } on Object {
      _broken.add(
        href,
      ); // imagem quebrada ou grande demais: fica o espaço vazio da página
    } finally {
      _loading.remove(href);
    }
  }

  /// Solta as menos usadas até caber no orçamento (a última que chegou sempre fica).
  void _trim() {
    var total = 0;
    for (final i in _images.values) {
      total += i.width * i.height * 4;
    }
    while (total > budgetBytes && _images.length > 1) {
      final oldest = _images.keys.first;
      final i = _images.remove(oldest)!;
      total -= i.width * i.height * 4;
      i.dispose();
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final i in _images.values) {
      i.dispose();
    }
    _images.clear();
    _changes.dispose();
  }
}

/// Decodifica [bytes] com no máximo [maxWidth] pixels de largura (mantém a proporção; nunca amplia).
Future<ui.Image> decodeImageForWidth(Uint8List bytes, int maxWidth) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  final ui.ImageDescriptor descriptor;
  try {
    descriptor = await ui.ImageDescriptor.encoded(buffer);
  } finally {
    buffer.dispose();
  }
  try {
    final codec = await descriptor.instantiateCodec(
      targetWidth: descriptor.width > maxWidth ? maxWidth : null,
    );
    try {
      return (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
  } finally {
    descriptor.dispose();
  }
}
