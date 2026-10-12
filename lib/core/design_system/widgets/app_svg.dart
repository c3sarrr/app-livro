import 'dart:typed_data' show ByteData;

import 'package:flutter/foundation.dart' show mapEquals, setEquals;
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics_compat.dart'
    show RenderingStrategy;

import '../painters/svg_dash_painter.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_illustrations_biblioteca.dart';
import '../tokens/app_illustrations_cronometro.dart';
import '../tokens/app_illustrations_entrada.dart';
import '../tokens/app_illustrations_inicio.dart';
import '../tokens/app_illustrations_leitor.dart' show svgDashes;
import '../tokens/app_illustrations_perfil.dart';
import '../tokens/app_illustrations_scanner.dart';

/// Pré-carrega (lê, interpreta e compila) os SVGs do arquivo no cache do flutter_svg. Chamado no `main()` antes
/// do `runApp`: sem isso o primeiro quadro desenha a tela sem ícones e eles "piscam" ao entrar (o
/// `SvgPicture.asset` carrega de forma assíncrona). A chave de cache é a mesma que o `AppSvg` usa na construção.
Future<void> preloadAppIcons([Iterable<String> assets = AppIcons.all]) =>
    Future.wait(assets.map(_precache));

Future<Object?> _precache(String asset) => preloadAppSvg(asset);

/// Entradas do cache do flutter_svg: os SVGs do pacote com folga para as variantes de cor (G16, D-190, T01) — o
/// dobro deles: 308 desde a T13.11 (os 198 novos das telas das etapas 7–11), eram 110. O padrão do flutter_svg é 100,
/// menos do que o `main()` pré-carregava na T03 (102 com o Laço do Noite; 84 desde que a Início nova pré-carrega só o
/// que a 01 desenha): o LRU descartava os primeiros (os ícones da Início) e eles voltavam a "piscar" na primeira
/// abertura; a folga fica para as variantes de cor e as telas novas.
const int kSvgCacheSize = 640;

/// Pré-carrega [asset] com a troca [colors] (a chave de cache do [AppSvg] com essas cores): as variantes de cores
/// fixas, como o Laço do Noite (D-190). Garante antes o tamanho do cache ([kSvgCacheSize]).
Future<Object?> preloadAppSvg(String asset, {Map<Color, Color>? colors}) {
  if (svg.cache.maximumSize < kSvgCacheSize) {
    svg.cache.maximumSize = kSvgCacheSize;
  }
  final loader = appSvgLoader(asset, colors: colors);
  return svg.cache.putIfAbsent(
    loader.cacheKey(null),
    () => loader.loadBytes(null),
  );
}

/// O carregador que o [AppSvg] usa para [asset] com a troca [colors] (a mesma chave de cache: para pré-carregar). Nos
/// desenhos tracejados ([svgDashes], T01) o traço do elemento sai escondido: o [AppSvg] o pinta por cima. Nos desenhos
/// com `<text>` ([svgsWithText]: as capas da Início, T03, e as ilustrações das telas das etapas 7–11, T13.11) os textos
/// saem: o widget da tela os escreve em `AppText`.
SvgAssetLoader appSvgLoader(String asset, {Map<Color, Color>? colors}) {
  final mapper = _mapperOf(asset, colors);
  return svgsWithText.contains(asset)
      ? _SvgWithoutTextLoader(asset, colorMapper: mapper)
      : SvgAssetLoader(asset, colorMapper: mapper);
}

/// Os desenhos que o [AppSvg] lê sem os `<text>` ([svgWithoutText]): os `withText` das classes de ilustrações. O
/// único outro SVG com `<text>`, o `ic_underline` do leitor, não passa pelo [AppSvg] (o ícone do Sublinhar é pintado
/// pelo `UnderlineIconPainter`, G13).
final Set<String> svgsWithText = Set.unmodifiable({
  ...AppIllustrationsInicio.withText,
  ...AppIllustrationsBiblioteca.withText,
  ...AppIllustrationsScanner.withText,
  ...AppIllustrationsEntrada.withText,
  ...AppIllustrationsPerfil.withText,
  ...AppIllustrationsCronometro.withText,
});

/// O SVG sem os elementos `<text>` (T03): o flutter_svg os desenharia com a fonte do sistema (a família do arquivo,
/// "'Instrument Serif', Georgia, serif", não é a registrada no app).
String svgWithoutText(String xml) => xml.replaceAll(_svgText, '');

final RegExp _svgText = RegExp(r'<text\b[^>]*>[\s\S]*?</text>');

/// O [SvgAssetLoader] de [svgWithoutText], com uma chave de cache própria (o mesmo arquivo com os textos é outro
/// desenho).
@immutable
final class _SvgWithoutTextLoader extends SvgAssetLoader {
  const _SvgWithoutTextLoader(super.assetName, {super.colorMapper});

  @override
  String provideSvg(ByteData? message) =>
      svgWithoutText(super.provideSvg(message));

  @override
  SvgCacheKey cacheKey(BuildContext? context) {
    final key = super.cacheKey(context);
    return SvgCacheKey(
      keyData: (key.keyData, 'sem <text>'),
      colorMapper: key.colorMapper,
      theme: key.theme,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _SvgWithoutTextLoader && super == other;

  @override
  int get hashCode => Object.hash(super.hashCode, 'sem <text>');
}

SvgColorSwap? _mapperOf(String asset, Map<Color, Color>? colors) {
  final dash = svgDashes[asset];
  if (colors == null && dash == null) return null;
  return SvgColorSwap(
    colors ?? const {},
    strokeless: dash == null
        ? const {}
        : {dash.id == null ? dash.element : '#${dash.id}'},
  );
}

/// Troca cores exatas do SVG (o ARGB inteiro) por outras na leitura do arquivo — o `ColorMapper` do flutter_svg: as
/// ilustrações com as cores do usuário (G16: `#B6ACE4` → a `brand`, `#FF552E` → a tinta). [strokeless]: os elementos
/// cujo traço sai escondido (T01: o tracejado que o [AppSvg] pinta) — pelo nome (`ellipse`) ou, com `#`, pelo `id`
/// (T13.11, D-285: `#tracejado`, quando outros elementos de mesmo nome têm traço). Igual por conteúdo, para a chave do
/// cache valer entre construções.
@immutable
final class SvgColorSwap extends ColorMapper {
  SvgColorSwap(Map<Color, Color> colors, {Set<String> strokeless = const {}})
    : _colors = {
        for (final e in colors.entries) e.key.toARGB32(): e.value.toARGB32(),
      },
      _strokeless = Set.unmodifiable(strokeless);

  final Map<int, int> _colors;
  final Set<String> _strokeless;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (attributeName == 'stroke' &&
        (_strokeless.contains(elementName) ||
            (id != null && _strokeless.contains('#$id')))) {
      return const Color(0x00000000);
    }
    final to = _colors[color.toARGB32()];
    return to == null ? color : Color(to);
  }

  @override
  bool operator ==(Object other) =>
      other is SvgColorSwap &&
      mapEquals(other._colors, _colors) &&
      setEquals(other._strokeless, _strokeless);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered([
      for (final e in _colors.entries) Object.hash(e.key, e.value),
    ]),
    Object.hashAllUnordered(_strokeless),
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
    this.colors,
    this.fit = BoxFit.contain,
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

  /// Troca de cores exatas do arquivo (G16: as ilustrações com a `brand` e a tinta do usuário — [SvgColorSwap]).
  final Map<Color, Color>? colors;

  /// Como o viewBox entra na caixa. [BoxFit.cover] = o `preserveAspectRatio="xMidYMid slice"` do arquivo (T03: as
  /// capas da Início nova; o flutter_svg ignora o atributo e mede o desenho pelo viewBox).
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final h = height ?? size;
    final a = opacity;
    final ColorFilter? filter = color != null
        ? ColorFilter.mode(color!, BlendMode.srcIn)
        : a != null && a < 1
        ? ColorFilter.mode(Color.fromRGBO(255, 255, 255, a), BlendMode.modulate)
        : null;
    // o mesmo carregador do pré-cache (`appSvgLoader`): a mesma chave
    final picture = SvgPicture(
      appSvgLoader(asset, colors: colors),
      width: size,
      height: h,
      fit: fit,
      colorFilter: filter,
      // com filtro, o caminho por picture pinta numa camada (`saveLayer`, proibida no app — F12 12.4); o
      // rasterizado aplica o filtro direto na imagem do ícone
      renderingStrategy: filter == null
          ? RenderingStrategy.picture
          : RenderingStrategy.raster,
    );
    // T01: o traço tracejado que o SVG leu escondido, por cima (nada que vem depois dele no arquivo o cruza — o teste
    // do registro confere), medido na escala da pintura com a densidade do aparelho (D-286)
    final dash = svgDashes[asset];
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: h,
        child: dash == null
            ? picture
            : CustomPaint(
                foregroundPainter: SvgDashPainter(
                  dash,
                  color: color ?? colors?[dash.color],
                  // com [color], o desenho não esmaece (o filtro é o `srcIn`); o traço também não
                  opacity: color != null ? 1 : a ?? 1,
                  devicePixelRatio:
                      MediaQuery.maybeDevicePixelRatioOf(context) ??
                      View.maybeOf(context)?.devicePixelRatio ??
                      1,
                ),
                child: picture,
              ),
      ),
    );
  }
}
