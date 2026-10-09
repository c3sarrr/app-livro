// G19.7 — a folha Exportar da tela 25 (D-194; D-23: no padrão da folha da nota): "Exportar grifos e notas", o livro e
// quantos itens vão, as três pílulas de formato (`radiogroup` "Formato": Markdown, marcada ao abrir; CSV; "PDF com
// desenhos" com a etiqueta PRO, que avisa "Chega numa próxima fase" e não muda a escolha) e Cancelar/Exportar. Sem
// grifos nem notas de texto (R12), o Exportar fica apagado.
import 'package:flutter/rendering.dart' show SemanticsRole;
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../../reader/presentation/reader_chrome_palette.dart';
import '../application/highlights_controller.dart';
import 'highlight_more_sheet.dart';

/// "Dom Casmurro · 8 grifos e notas de texto"; sem itens, R12.
String exportSubtitle(String title, int n) => switch (n) {
  0 => 'Nada para exportar em Markdown ou CSV ainda',
  1 => '$title · 1 grifo ou nota de texto',
  _ => '$title · $n grifos e notas de texto',
};

class HighlightExportSheet extends StatefulWidget {
  const HighlightExportSheet({
    super.key,
    required this.title,
    required this.exportable,
    required this.palette,
    required this.brand,
    required this.onPdf,
    required this.onCancel,
    required this.onExport,
  });

  final String title;

  /// Quantos grifos e notas de texto vão no arquivo.
  final int exportable;
  final ReaderChromePalette palette;
  final Color brand;
  final VoidCallback onPdf;
  final VoidCallback onCancel;
  final ValueChanged<ExportFormat> onExport;

  @override
  State<HighlightExportSheet> createState() => _HighlightExportSheetState();
}

class _HighlightExportSheetState extends State<HighlightExportSheet> {
  ExportFormat _format = ExportFormat.markdown;

  Widget _option(
    String key,
    String label,
    bool on,
    VoidCallback onTap, {
    bool pro = false,
  }) {
    final p = widget.palette;
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    return Pressable(
      checked: on,
      semanticsLabel: pro ? '$label, PRO' : label,
      onTap: onTap,
      child: NeoBox(
        key: ValueKey('hl.export.formats.$key'),
        height: 44,
        color: on ? widget.brand : p.island,
        border: line,
        radius: BorderRadius.circular(999),
        shadow: on ? AppShadows.hard2 : null,
        shadowColor: p.shadow,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            AppText(
              label,
              style: AppTextStyles.readerNoteButton.copyWith(color: p.title),
              maxLines: 1,
            ),
            if (pro)
              NeoBox(
                key: const ValueKey('hl.export.formats.pdf.pro'),
                height: 20,
                color: AppColors.ink,
                radius: BorderRadius.circular(999),
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Center(
                  child: AppText(
                    'PRO',
                    style: AppTextStyles.hlPill.copyWith(
                      color: AppColors.paper,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final n = widget.exportable;
    return HighlightsSheetFrame(
      id: 'hl.export',
      label: 'Exportar grifos e notas',
      palette: p,
      onDismiss: widget.onCancel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            'Exportar grifos e notas',
            key: const ValueKey('hl.export.title'),
            style: AppTextStyles.readerNoteButton.copyWith(color: p.title),
            maxLines: 1,
          ),
          const SizedBox(height: 6),
          AppText(
            exportSubtitle(widget.title, n),
            key: const ValueKey('hl.export.subtitle'),
            style: AppTextStyles.hlSubtitle.copyWith(color: p.muted),
          ),
          const SizedBox(height: 14),
          Semantics(
            container: true,
            role: SemanticsRole.radioGroup,
            label: 'Formato',
            explicitChildNodes: true,
            child: Wrap(
              key: const ValueKey('hl.export.formats'),
              spacing: 8,
              runSpacing: 8,
              children: [
                _option(
                  'markdown',
                  'Markdown',
                  _format == ExportFormat.markdown,
                  () => setState(() => _format = ExportFormat.markdown),
                ),
                _option(
                  'csv',
                  'CSV',
                  _format == ExportFormat.csv,
                  () => setState(() => _format = ExportFormat.csv),
                ),
                _option(
                  'pdf',
                  'PDF com desenhos',
                  false,
                  widget.onPdf,
                  pro: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: sheetButton(
                  p,
                  'hl.export.cancel',
                  'Cancelar',
                  onTap: widget.onCancel,
                ),
              ),
              Expanded(
                child: sheetButton(
                  p,
                  'hl.export.go',
                  'Exportar',
                  fill: n == 0 ? null : widget.brand,
                  shadow: n == 0 ? null : AppShadows.hard2,
                  onTap: n == 0 ? null : () => widget.onExport(_format),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
