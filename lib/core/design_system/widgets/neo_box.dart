import 'package:flutter/widgets.dart';

import '../tokens/app_colors.dart';

/// = <div> com box-sizing border-box, background, border uniforme, border-radius, box-shadow duro e,
/// opcionalmente, overflow:hidden — recortando os FILHOS na padding box com raio interno (raio − borda).
///
/// Regras: `width/height` = tamanho **externo** (border-box). O `Container` já recua o filho pela borda.
/// Para elementos **content-box** (ponto do sino, anel da capa, círculos decorativos) passe o tamanho
/// externo já somado (tabela das fases).
class NeoBox extends StatelessWidget {
  const NeoBox({
    super.key,
    this.width,
    this.height,
    this.color,
    this.border,
    this.radius = BorderRadius.zero,
    this.shadow,
    this.shadowColor = AppColors.ink,
    this.padding = EdgeInsets.zero,
    this.clip = false,
    this.child,
  });
  final double? width, height;
  final Color? color;

  /// Ex.: `const BorderSide(width: 1.5, color: AppColors.ink)`.
  final BorderSide? border;
  final BorderRadius radius;

  /// `AppShadows.*`.
  final Offset? shadow;

  /// Cor da sombra dura (a tinta; no leitor Noite, `#0B0A08` — G12).
  final Color shadowColor;
  final EdgeInsets padding;
  final bool clip;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final bw = border?.width ?? 0;
    Widget? content = child == null
        ? null
        : Padding(padding: padding, child: child);
    if (clip && content != null) {
      // Raios negativos viram 0 no toRRect.
      content = ClipRRect(
        borderRadius: radius - BorderRadius.circular(bw),
        child: content,
      );
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        border: border == null ? null : Border.fromBorderSide(border!),
        boxShadow: shadow == null
            ? null
            : [
                BoxShadow(
                  color: shadowColor,
                  offset: shadow!,
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: content,
    );
  }
}
