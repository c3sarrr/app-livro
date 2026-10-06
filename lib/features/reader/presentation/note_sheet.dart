// G13.4 — a folha da nota (D-131; D-23: não desenhada, extrapolada com os tokens das ilhas): um cartão que sobe com
// o teclado — "NOTA", o trecho citado, o campo e Cancelar/Salvar — sobre o véu da página, como os controles. Salvar
// fica desabilitado com o campo vazio (só espaços conta como vazio). O véu segura os toques (a página não vira por
// baixo).
import 'package:flutter/material.dart'
    show InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/services.dart'
    show TextEditingValue, TextInputFormatter, TextSelection;
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import 'reader_chrome_palette.dart';
import 'reader_palette.dart';

/// O tamanho máximo de uma nota (o CHECK do banco — Anexo 02).
const int noteMaxLength = 10000;

/// Corta o campo em [max] caracteres contados como o banco conta (code points — `Check.text`), não em grafemas.
final class NoteLengthLimit extends TextInputFormatter {
  const NoteLengthLimit([this.max = noteMaxLength]);
  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final runes = newValue.text.runes;
    if (runes.length <= max) return newValue;
    final text = String.fromCharCodes(runes.take(max));
    final sel = newValue.selection;
    return TextEditingValue(
      text: text,
      selection: sel.isValid
          ? TextSelection(
              baseOffset: sel.baseOffset.clamp(0, text.length),
              extentOffset: sel.extentOffset.clamp(0, text.length),
            )
          : TextSelection.collapsed(offset: text.length),
    );
  }
}

/// A folha fica a 14 das bordas e 14 acima do teclado.
const double noteSheetMargin = 14;

class NoteSheet extends StatefulWidget {
  const NoteSheet({
    super.key,
    required this.excerpt,
    required this.initial,
    required this.palette,
    required this.paper,
    required this.brand,
    required this.onCancel,
    required this.onSave,
  });

  /// O trecho citado (já limpo).
  final String excerpt;

  /// O texto da nota que já existe (ou vazio).
  final String initial;
  final ReaderChromePalette palette;
  final ReaderPalette paper;
  final Color brand;
  final VoidCallback onCancel;
  final ValueChanged<String> onSave;

  @override
  State<NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<NoteSheet> {
  late final TextEditingController _field = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    // salvar vazio só vale numa nota que já existe (apaga a nota — D-131)
    final empty = _field.text.trim().isEmpty && widget.initial.trim().isEmpty;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    Widget button(
      String key,
      String label,
      Color fill,
      Offset? shadow,
      VoidCallback? onTap,
    ) => Expanded(
      child: Pressable(
        key: ValueKey(key),
        semanticsLabel: label,
        enabled: onTap != null,
        onTap: onTap,
        child: NeoBox(
          height: 44,
          color: fill,
          border: line,
          radius: BorderRadius.circular(999),
          shadow: shadow,
          shadowColor: p.shadow,
          child: Center(
            child: AppText(
              label,
              style: AppTextStyles.readerNoteButton.copyWith(
                color: onTap == null ? p.disabled : p.title,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: () {},
            child: ColoredBox(
              key: const ValueKey('leitor.nota.veu'),
              color: p.veil,
            ),
          ),
        ),
        Positioned(
          left: noteSheetMargin,
          right: noteSheetMargin,
          bottom: keyboard + noteSheetMargin,
          child: NeoBox(
            key: const ValueKey('leitor.nota'),
            color: p.island,
            border: line,
            radius: BorderRadius.circular(28),
            shadow: AppShadows.hard3,
            shadowColor: p.shadow,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText(
                  'NOTA',
                  key: const ValueKey('leitor.nota.titulo'),
                  style: AppTextStyles.readerToolbarLabel.copyWith(
                    color: p.label,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                AppText(
                  '“${widget.excerpt}”',
                  key: const ValueKey('leitor.nota.trecho'),
                  style: AppTextStyles.readerSearchExcerpt.copyWith(
                    color: widget.paper.text,
                  ),
                  maxLines: 2,
                  ellipsis: true,
                ),
                const SizedBox(height: 12),
                NeoBox(
                  color: p.well,
                  border: line,
                  radius: BorderRadius.circular(16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: TextField(
                      key: const ValueKey('leitor.nota.campo'),
                      controller: _field,
                      autofocus: true,
                      minLines: 3,
                      maxLines: 8,
                      inputFormatters: const [NoteLengthLimit()],
                      onChanged: (_) => setState(() {}),
                      style: AppTextStyles.readerNoteField.copyWith(
                        color: p.title,
                      ),
                      cursorColor: p.title,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Escreva sua nota…',
                        hintStyle: AppTextStyles.readerNoteField.copyWith(
                          color: p.muted,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  spacing: 10,
                  children: [
                    button(
                      'leitor.nota.cancelar',
                      'Cancelar',
                      p.island,
                      null,
                      widget.onCancel,
                    ),
                    button(
                      'leitor.nota.salvar',
                      'Salvar',
                      widget.brand,
                      AppShadows.hard2,
                      empty ? null : () => widget.onSave(_field.text),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
