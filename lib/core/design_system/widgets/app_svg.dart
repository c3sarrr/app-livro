import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ícone SVG do pacote no tamanho de uso (sem colorFilter; cores já estão no arquivo).
/// O traço escala com o tamanho, como no navegador (1,8 × 22/24 = 1,65 px). Ícones são
/// `aria-hidden`/decorativos: ficam fora da árvore semântica.
class AppSvg extends StatelessWidget {
  const AppSvg(this.asset, {super.key, required this.size});
  final String asset;
  final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: SvgPicture.asset(asset, width: size, height: size),
    ),
  );
}
