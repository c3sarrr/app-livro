import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/app_icons.dart';

/// Pré-carrega (lê, interpreta e compila) os SVGs do arquivo no cache do flutter_svg. Chamado no `main()` antes
/// do `runApp`: sem isso o primeiro quadro desenha a tela sem ícones e eles "piscam" ao entrar (o
/// `SvgPicture.asset` carrega de forma assíncrona). A chave de cache é a mesma que o `AppSvg` usa na construção.
Future<void> preloadAppIcons([Iterable<String> assets = AppIcons.all]) =>
    Future.wait(assets.map(_precache));

Future<Object?> _precache(String asset) {
  final loader = SvgAssetLoader(asset);
  return svg.cache.putIfAbsent(
    loader.cacheKey(null),
    () => loader.loadBytes(null),
  );
}

/// Ícone SVG do pacote no tamanho de uso (sem colorFilter; cores já estão no arquivo). [color] tinge o traço
/// (só nos estados D-21 sobre fundo tinta — G08 —, para não criar arquivos de ícone novos).
/// O traço escala com o tamanho, como no navegador (1,8 × 22/24 = 1,65 px). Ícones são
/// `aria-hidden`/decorativos: ficam fora da árvore semântica.
class AppSvg extends StatelessWidget {
  const AppSvg(this.asset, {super.key, required this.size, this.color});
  final String asset;
  final double size;
  final Color? color;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: SvgPicture.asset(
        asset,
        width: size,
        height: size,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color!, BlendMode.srcIn),
      ),
    ),
  );
}
