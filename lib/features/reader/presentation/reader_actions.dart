// G13.4 — o texto de Copiar e Compartilhar (D-39, D-136), o trecho que vai para a busca e o compartilhar do sistema
// (sobrescrito nos testes).
import 'dart:ui' show Rect;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Quanto do trecho vai para o campo da busca.
const int searchPrefillMax = 100;

/// `“trecho”` + quebra + `— Autor, Título (pág. N)` (D-39).
String quoteForSharing({
  required String excerpt,
  required String author,
  required String title,
  required int refPage,
}) => '“${cleanExcerpt(excerpt)}”\n— $author, $title (pág. $refPage)';

/// O trecho no campo da busca: até [searchPrefillMax] caracteres, cortado na palavra.
String searchPrefill(String text) {
  final t = cleanExcerpt(text);
  if (t.length <= searchPrefillMax) return t;
  final cut = t.lastIndexOf(' ', searchPrefillMax);
  return t.substring(0, cut > 0 ? cut : searchPrefillMax);
}

/// O trecho para mostrar ou citar: sem o caractere das imagens (U+FFFC) e com os espaços (e quebras) virando um
/// espaço só.
String cleanExcerpt(String s) =>
    s.replaceAll('￼', '').replaceAll(RegExp(r'\s+'), ' ').trim();

/// Abre a folha de compartilhar do sistema com [text]; no iPad ela sai de [origin] (o botão).
final readerShareProvider =
    Provider<Future<void> Function(String text, Rect? origin)>(
      (ref) => (text, origin) async {
        await SharePlus.instance.share(
          ShareParams(text: text, sharePositionOrigin: origin),
        );
      },
    );
