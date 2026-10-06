// Primitivos mínimos da conta (D-21: telas sem design ainda → texto Figtree + botões do design system,
// listados em docs/design/estados_sem_design.md para o design desenhar depois).
import 'package:flutter/material.dart'
    show InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';

/// Texto corrido (Figtree 15/400).
class AccountText extends StatelessWidget {
  const AccountText(this.text, {super.key, this.muted = false, this.color});
  final String text;
  final bool muted;

  /// Outra cor (os estados do leitor no tema Noite — G12, D-124).
  final Color? color;

  @override
  Widget build(BuildContext context) => AppText(
    text,
    style: AppFonts.figtree(
      15,
      FontWeight.w400,
      height: 1.4,
      color: color ?? (muted ? AppColors.inkMuted : AppColors.ink),
    ),
  );
}

/// Título de etapa (Figtree 18/700).
class AccountHeading extends StatelessWidget {
  const AccountHeading(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: AppText(
      text,
      style: AppFonts.figtree(18, FontWeight.w700, height: 1.3),
    ),
  );
}

enum AccountButtonTone { primary, secondary, danger }

/// Botão: pílula com borda de tinta (o mesmo vocabulário dos CTAs da Início), sem ripple (D-04).
class AccountButton extends StatelessWidget {
  const AccountButton(
    this.label, {
    super.key,
    required this.onTap,
    this.tone = AccountButtonTone.secondary,
    this.fill,
    this.ink,
  });

  final String label;
  final VoidCallback? onTap;
  final AccountButtonTone tone;

  /// Outras cores de fundo e de tinta (os estados do leitor no tema Noite — G12, D-124).
  final Color? fill, ink;

  @override
  Widget build(BuildContext context) {
    // Desabilitado: cores esmaecidas (sem `Opacity` — F12 12.4, nada de saveLayer).
    final enabled = onTap != null;
    final fill =
        this.fill ??
        switch (tone) {
          AccountButtonTone.primary => AppColors.sun,
          AccountButtonTone.secondary => AppColors.surface,
          AccountButtonTone.danger => AppColors.blush,
        };
    final ink = enabled ? (this.ink ?? AppColors.ink) : AppColors.inkMuted;
    return Pressable(
      onTap: onTap,
      semanticsLabel: label,
      child: NeoBox(
        color: enabled ? fill : fill.withValues(alpha: 0.45),
        border: BorderSide(width: AppStrokes.regular, color: ink),
        radius: BorderRadius.circular(999),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Center(
          widthFactor: 1,
          child: AppText(
            label,
            style: AppFonts.figtree(
              15,
              FontWeight.w600,
              height: 1.2,
              color: ink,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Campo de texto numa caixa de borda de tinta (sem a decoração do Material).
class AccountField extends StatelessWidget {
  const AccountField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.autofocus = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    textField: true,
    child: NeoBox(
      color: AppColors.surface,
      border: const BorderSide(width: AppStrokes.regular, color: AppColors.ink),
      radius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Material(
        type: MaterialType.transparency,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          autofocus: autofocus,
          autocorrect: false,
          enableSuggestions: false,
          onSubmitted: onSubmitted,
          style: AppFonts.figtree(16, FontWeight.w500),
          cursorColor: AppColors.ink,
          decoration: InputDecoration.collapsed(
            hintText: hint ?? label,
            hintStyle: AppFonts.figtree(
              16,
              FontWeight.w400,
              color: AppColors.inkMuted,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Linha de aviso (erro ou confirmação), lida pelo leitor de tela quando muda.
class AccountNotice extends StatelessWidget {
  const AccountNotice(this.text, {super.key, this.error = false});
  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: AppText(
      text,
      style: AppFonts.figtree(
        14,
        FontWeight.w600,
        height: 1.4,
        color: error ? AppColors.flame : AppColors.emerald,
      ),
    ),
  );
}

/// Coluna com espaço uniforme entre os itens.
class AccountColumn extends StatelessWidget {
  const AccountColumn({super.key, required this.children, this.gap = 12});
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) SizedBox(height: gap),
        children[i],
      ],
    ],
  );
}
