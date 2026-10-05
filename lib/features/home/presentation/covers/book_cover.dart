// Capa de livro real (G08, D-79): a foto da fonte guardada no aparelho, na mesma moldura de cada seção (borda,
// raio, sombra dura e lombada das capas do arquivo); sem foto, a capa gerada — cor, forma e título derivados
// do livro, no estilo das 9 capas desenhadas — até a foto chegar.
import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_shadows.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/neo_box.dart';
import '../../application/cover_providers.dart';
import '../../data/catalog_for_you_source.dart' show foldText;
import '../../domain/models.dart';

/// Moldura e texto de cada lugar onde a Início mostra capa (medidas das capas do arquivo).
@immutable
final class CoverSlot {
  const CoverSlot({
    required this.width,
    required this.height,
    required this.border,
    required this.radius,
    this.shadow,
    required this.spineWidth,
    required this.spineColor,
    this.titleSize,
    this.titleLines = 0,
    this.showAuthor = false,
    this.inset = 8,
  });

  final double width;
  final double height;
  final double border;
  final BorderRadius radius;
  final Offset? shadow;
  final double spineWidth;
  final Color spineColor;

  /// Corpo do título na capa gerada; `null` = só cor e forma (miniatura).
  final double? titleSize;
  final int titleLines;
  final bool showAuthor;

  /// Margem do texto dentro da capa (fora a lombada).
  final double inset;

  /// Herói: 104×156, borda 1,5, raio 4/10/10/4, sombra 3/3, lombada 7 (.22) — como Dom Casmurro.
  static const hero = CoverSlot(
    width: 104,
    height: 156,
    border: 1.5,
    radius: AppRadii.coverL,
    shadow: AppShadows.hard3,
    spineWidth: 7,
    spineColor: AppColors.spine22,
    titleSize: 22,
    titleLines: 4,
    showAuthor: true,
    inset: 10,
  );

  /// Também lendo: 54×81, borda 1,5, raio 3/7/7/3, sombra 2/2, lombada 5 (.15).
  static const alsoReading = CoverSlot(
    width: 54,
    height: 81,
    border: 1.5,
    radius: AppRadii.coverS,
    shadow: AppShadows.hard2,
    spineWidth: 5,
    spineColor: AppColors.spine15,
    titleSize: 11,
    titleLines: 3,
    inset: 6,
  );

  /// Para você: 116×174, borda 1,5, raio 4/10/10/4, sem sombra, lombada 7 (.18).
  static const forYou = CoverSlot(
    width: 116,
    height: 174,
    border: 1.5,
    radius: AppRadii.coverL,
    spineWidth: 7,
    spineColor: AppColors.spine18,
    titleSize: 19,
    titleLines: 4,
    showAuthor: true,
    inset: 10,
  );

  /// Recém-chegados: 44×66, borda 1,2, raio 3/7/7/3, sem sombra, lombada 4 (.12), sem texto.
  static const recent = CoverSlot(
    width: 44,
    height: 66,
    border: 1.2,
    radius: AppRadii.coverS,
    spineWidth: 4,
    spineColor: AppColors.spine12,
  );
}

/// A foto do livro (do aparelho ou da rede) ou, sem ela, a capa gerada.
class PhotoBookCover extends ConsumerWidget {
  const PhotoBookCover({
    super.key,
    required this.book,
    required this.cover,
    required this.slot,
  });

  final Book book;
  final PhotoCover cover;
  final CoverSlot slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(coverFileProvider(cover)).value;
    final images = ref.read(coverImagesProvider);
    final container = ProviderScope.containerOf(context, listen: false);
    final generated = GeneratedCoverArt(
      title: book.title,
      author: book.author,
      slot: slot,
    );
    return ExcludeSemantics(
      child: NeoBox(
        width: slot.width,
        height: slot.height,
        color: generated.palette.background,
        border: BorderSide(width: slot.border, color: AppColors.ink),
        radius: slot.radius,
        shadow: slot.shadow,
        clip: true,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (file == null)
              generated
            else
              _Photo(
                file: file,
                slot: slot,
                fallback: generated,
                // Arquivo guardado que não abre: descarta e volta para a capa gerada (sem baixar de novo por 7 dias).
                onBroken: () async {
                  await images.discard(cover);
                  container.invalidate(coverFileProvider(cover));
                },
              ),
            // Lombada por cima da foto também (a capa "vira livro" como as do arquivo).
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: slot.spineWidth,
              child: NeoBox(color: slot.spineColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _Photo extends StatefulWidget {
  const _Photo({
    required this.file,
    required this.slot,
    required this.fallback,
    required this.onBroken,
  });

  final File file;
  final CoverSlot slot;
  final Widget fallback;
  final Future<void> Function() onBroken;

  @override
  State<_Photo> createState() => _PhotoState();
}

class _PhotoState extends State<_Photo> {
  var _reported = false;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Image.file(
      widget.file,
      key: const ValueKey('cover.photo'),
      fit: BoxFit.cover,
      cacheWidth: (widget.slot.width * dpr).ceil(),
      gaplessPlayback: true,
      errorBuilder: (context, error, stack) {
        if (!_reported) {
          _reported = true;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => unawaited(widget.onBroken()),
          );
        }
        return widget.fallback;
      },
    );
  }
}

/// Cores de uma capa gerada (fundo, texto e forma), da paleta das 9 capas do arquivo.
typedef CoverPalette = ({Color background, Color text, Color accent});

const List<CoverPalette> _palettes = [
  (
    background: AppColors.violet,
    text: AppColors.surface,
    accent: AppColors.sun,
  ),
  (background: AppColors.azure, text: AppColors.surface, accent: AppColors.sun),
  (
    background: AppColors.emerald,
    text: AppColors.surface,
    accent: AppColors.sun,
  ),
  (background: AppColors.flame, text: AppColors.ink, accent: AppColors.ink),
  (background: AppColors.amber, text: AppColors.ink, accent: AppColors.surface),
  (
    background: AppColors.lavender,
    text: AppColors.ink,
    accent: AppColors.violet,
  ),
  (background: AppColors.sun, text: AppColors.ink, accent: AppColors.flame),
  (background: AppColors.leaf, text: AppColors.ink, accent: AppColors.ink),
  (background: AppColors.blush, text: AppColors.ink, accent: AppColors.flame),
  (
    background: AppColors.ink,
    text: AppColors.surface,
    accent: AppColors.lavender,
  ),
];

/// Formas das capas do arquivo: sol, arco, anel, linhas.
enum CoverShape { sun, arch, ring, lines }

/// FNV-1a 32 bits + a mistura final do MurmurHash3 (determinístico entre execuções e plataformas; sem a
/// mistura, os bits baixos repetem a paridade dos caracteres e metade das paletas nunca sai).
int _hash(String s) {
  var h = 0x811C9DC5;
  for (final c in s.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  h ^= h >> 16;
  h = (h * 0x85EBCA6B) & 0xFFFFFFFF;
  h ^= h >> 13;
  h = (h * 0xC2B2AE35) & 0xFFFFFFFF;
  return h ^ (h >> 16);
}

/// Capa gerada a partir do título e do autor: sempre a mesma para o mesmo livro.
class GeneratedCoverArt extends StatelessWidget {
  GeneratedCoverArt({
    super.key,
    required this.title,
    required this.author,
    required this.slot,
  }) : _seed = _hash('${foldText(title)}|${foldText(author)}');

  final String title;
  final String author;
  final CoverSlot slot;
  final int _seed;

  CoverPalette get palette => _palettes[_seed % _palettes.length];

  CoverShape get shape =>
      CoverShape.values[(_seed ~/ _palettes.length) % CoverShape.values.length];

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final w = slot.width;
    final h = slot.height;
    final titleSize = slot.titleSize;
    return KeyedSubtree(
      key: const ValueKey('cover.generated'),
      child: ColoredBox(
        color: p.background,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _shape(p.accent, w, h),
            if (titleSize != null)
              Positioned(
                left: slot.spineWidth + slot.inset,
                right: slot.inset,
                bottom: slot.inset,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    AppText(
                      title,
                      style: AppTextStyles.coverTitle19.copyWith(
                        fontSize: titleSize,
                        color: p.text,
                      ),
                      maxLines: slot.titleLines,
                      ellipsis: true,
                    ),
                    if (slot.showAuthor && author.isNotEmpty)
                      AppText(
                        author.toUpperCase(),
                        style: AppTextStyles.coverAuthorPaper.copyWith(
                          color: p.text,
                        ),
                        maxLines: 2,
                        ellipsis: true,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// A forma fica na metade de cima (o texto ocupa a de baixo), proporcional ao tamanho da capa.
  Widget _shape(Color c, double w, double h) => switch (shape) {
    CoverShape.sun => Positioned(
      right: -w * 0.18,
      top: h * 0.08,
      width: w * 0.62,
      height: w * 0.62,
      child: NeoBox(color: c, radius: BorderRadius.circular(w)),
    ),
    CoverShape.arch => Positioned(
      left: slot.spineWidth + w * 0.14,
      right: w * 0.14,
      top: h * 0.1,
      height: w * 0.42,
      child: NeoBox(
        color: c,
        radius: BorderRadius.vertical(top: Radius.circular(w)),
      ),
    ),
    CoverShape.ring => Positioned(
      left: slot.spineWidth + w * 0.12,
      top: h * 0.1,
      width: w * 0.42,
      height: w * 0.42,
      child: NeoBox(
        border: BorderSide(width: (w * 0.06).clamp(2.0, 6.0), color: c),
        radius: BorderRadius.circular(w),
      ),
    ),
    CoverShape.lines => Positioned(
      left: slot.spineWidth + w * 0.12,
      right: w * 0.12,
      top: h * 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: h * 0.035,
        children: [
          for (final f in const [1.0, 0.7, 0.4])
            FractionallySizedBox(
              widthFactor: f,
              child: NeoBox(
                height: (h * 0.03).clamp(2.0, 6.0),
                color: c,
                radius: BorderRadius.circular(3),
              ),
            ),
        ],
      ),
    ),
  };
}
