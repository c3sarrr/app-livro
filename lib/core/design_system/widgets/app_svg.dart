import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics_compat.dart'
    show RenderingStrategy;

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
  const AppSvg(
    this.asset, {
    super.key,
    required this.size,
    this.height,
    this.color,
    this.opacity,
  });
  final String asset;

  /// Largura (e altura, se [height] for nulo).
  final double size;

  /// Altura de um ícone não quadrado (a fita do marcador, 22×24 — G12).
  final double? height;
  final Color? color;

  /// Esmaece o ícone sem trocar as cores dele (abrir/fechar os controles do leitor sem `Opacity` — G12):
  /// `modulate` com branco a este alfa.
  final double? opacity;

  @override
  Widget build(BuildContext context) {
    final h = height ?? size;
    final a = opacity;
    final ColorFilter? filter = color != null
        ? ColorFilter.mode(color!, BlendMode.srcIn)
        : a != null && a < 1
        ? ColorFilter.mode(Color.fromRGBO(255, 255, 255, a), BlendMode.modulate)
        : null;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: h,
        child: SvgPicture.asset(
          asset,
          width: size,
          height: h,
          colorFilter: filter,
          // com filtro, o caminho por picture pinta numa camada (`saveLayer`, proibida no app — F12 12.4); o
          // rasterizado aplica o filtro direto na imagem do ícone
          renderingStrategy: filter == null
              ? RenderingStrategy.picture
              : RenderingStrategy.raster,
        ),
      ),
    );
  }
}
