// G12.3 — o que as camadas dos controles do leitor (telas 20/26b) compartilham: as cores do tema já esmaecidas
// (`ReaderChromePalette.faded`), a cor `brand` (D-33) e o esmaecimento [a] para os ícones e as cores fixas (o chip
// e o contador são `sun` com tinta nos dois temas). Abrir e fechar em 150 ms muda só o [a] — sem `Opacity` (D-124).
import 'package:flutter/widgets.dart';

import 'reader_chrome_palette.dart';

class ReaderChromeScope extends InheritedWidget {
  const ReaderChromeScope({
    super.key,
    required this.palette,
    required this.brand,
    required this.a,
    required super.child,
  });

  /// As cores do tema, já multiplicadas por [a].
  final ReaderChromePalette palette;
  final Color brand;

  /// 0 = fechado, 1 = aberto.
  final double a;

  /// Uma cor fixa (fora da paleta) esmaecida junto com o resto.
  Color tint(Color c) => a >= 1 ? c : c.withValues(alpha: c.a * a);

  static ReaderChromeScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ReaderChromeScope>()!;

  @override
  bool updateShouldNotify(ReaderChromeScope oldWidget) =>
      oldWidget.palette != palette ||
      oldWidget.brand != brand ||
      oldWidget.a != a;
}
