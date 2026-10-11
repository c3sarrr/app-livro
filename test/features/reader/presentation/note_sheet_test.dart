// G13.4 — a folha da nota (D-131, extrapolada com os tokens das ilhas): o cartão a 14 das bordas e 14 acima do
// teclado, raio 28, borda 1,5 e sombra 3/3 sobre o véu; "NOTA", o trecho entre aspas (Literata 17, até 2 linhas), o
// campo focado com a dica e Cancelar/Salvar; Salvar desabilitado com o campo vazio (numa nota nova); o Noite.
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/note_sheet.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:flutter/material.dart' show MaterialApp, TextField;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/load_fonts.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

void main() {
  setUpAll(loadAppFonts);

  late List<String> eventos;

  Future<void> montar(
    WidgetTester tester, {
    ReaderPaper papel = ReaderPaper.creme,
    String inicial = '',
    String trecho = 'como a vaga que se retira da praia, nos dias de ressaca.',
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    eventos = [];
    await tester.pumpWidget(
      // o campo é um TextField (pede as traduções do Material, como no app)
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            viewInsets: EdgeInsets.only(bottom: 300),
          ),
          child: Stack(
            children: [
              // a página embaixo
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => eventos.add('página'),
                ),
              ),
              NoteSheet(
                excerpt: trecho,
                initial: inicial,
                palette: ReaderChromePalette.of(papel),
                paper: ReaderPalette.of(papel),
                brand: AppColors.lavender,
                onCancel: () => eventos.add('cancelar'),
                onSave: (t) => eventos.add('salvar $t'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'cartão a 14 das bordas e 14 acima do teclado; raio 28, borda 1,5, sombra 3/3; véu na página',
    (tester) async {
      await montar(tester);
      final r = tester.getRect(_key('leitor.nota'));
      expect((r.left, r.right, r.bottom), (14.0, 376.0, 844.0 - 300 - 14));
      final c = tester.widget<NeoBox>(_key('leitor.nota'));
      expect(
        (c.color, c.border, c.radius, c.shadow, c.shadowColor),
        (
          AppColors.surface,
          const BorderSide(width: 1.5, color: AppColors.ink),
          BorderRadius.circular(28),
          const Offset(3, 3),
          AppColors.ink,
        ),
      );
      expect(
        tester.widget<ColoredBox>(_key('leitor.nota.veu')).color,
        ReaderChromePalette.of(ReaderPaper.creme).veil,
      );
      expect(
        tester.getRect(_key('leitor.nota.veu')),
        const Rect.fromLTWH(0, 0, 390, 844),
      );
    },
  );

  testWidgets(
    '"NOTA", o trecho entre aspas em Literata 17 (até 2 linhas, com reticências) e o campo focado com a dica',
    (tester) async {
      await montar(
        tester,
        trecho: List.filled(40, 'olhos de ressaca').join(' '),
      );
      final titulo = tester
          .widget<AppText>(_key('leitor.nota.titulo'))
          .span
          .style!;
      expect(
        (
          titulo.fontSize,
          titulo.fontWeight,
          titulo.letterSpacing,
          titulo.color,
        ),
        (11.0, FontWeight.w800, 1.2, AppColors.labelReader),
      );
      final trecho = tester.widget<AppText>(_key('leitor.nota.trecho'));
      expect(
        trecho.span.style,
        AppTextStyles.readerSearchExcerpt.copyWith(
          color: ReaderPalette.of(ReaderPaper.creme).text,
        ),
      );
      expect((trecho.maxLines, trecho.ellipsis), (2, true));
      expect((trecho.span as TextSpan).text, startsWith('“olhos de ressaca'));
      final linhas = tester
          .renderObject<RenderAppText>(_key('leitor.nota.trecho'))
          .debugLines();
      expect(linhas, hasLength(2));
      expect(
        linhas.map((l) => l.text).join().length,
        lessThan((trecho.span as TextSpan).text!.length),
        reason: 'cortado com reticências',
      );
      final campo = tester.state<EditableTextState>(find.byType(EditableText));
      expect(campo.widget.focusNode.hasFocus, isTrue);
      expect(campo.widget.style.fontSize, 15);
      expect(campo.widget.style.fontWeight, FontWeight.w500);
      expect(find.text('Escreva sua nota…'), findsOneWidget);
    },
  );

  testWidgets(
    'Salvar desabilitado com o campo vazio ou só com espaços; com texto, salva o que foi escrito',
    (tester) async {
      final h = tester.ensureSemantics();
      await montar(tester);
      expect(
        tester.getSemantics(_key('leitor.nota.salvar')),
        isSemantics(label: 'Salvar', hasEnabledState: true, isEnabled: false),
      );
      await tester.tap(_key('leitor.nota.salvar'));
      await tester.enterText(_key('leitor.nota.campo'), '   ');
      await tester.pump();
      await tester.tap(_key('leitor.nota.salvar'));
      expect(eventos, isEmpty);
      await tester.enterText(_key('leitor.nota.campo'), 'olhos de ressaca');
      await tester.pump();
      await tester.tap(_key('leitor.nota.salvar'));
      await tester.tap(_key('leitor.nota.cancelar'));
      expect(eventos, ['salvar olhos de ressaca', 'cancelar']);
      final salvar = tester.widget<NeoBox>(
        find.descendant(
          of: _key('leitor.nota.salvar'),
          matching: find.byType(NeoBox),
        ),
      );
      expect(
        (salvar.color, salvar.shadow, salvar.height),
        (AppColors.lavender, const Offset(2, 2), 44.0),
      );
      final cancelar = tester.widget<NeoBox>(
        find.descendant(
          of: _key('leitor.nota.cancelar'),
          matching: find.byType(NeoBox),
        ),
      );
      expect((cancelar.color, cancelar.shadow), (AppColors.surface, null));
      h.dispose();
    },
  );

  testWidgets(
    'nota que já existe: abre com o texto e Salvar vale vazio (apaga a nota — D-131)',
    (tester) async {
      await montar(tester, inicial: 'era ressaca');
      expect(find.text('era ressaca'), findsOneWidget);
      await tester.enterText(_key('leitor.nota.campo'), '');
      await tester.pump();
      await tester.tap(_key('leitor.nota.salvar'));
      expect(eventos, ['salvar ']);
    },
  );

  test('o limite conta como o banco (code points), não em grafemas', () {
    // "é" com o acento combinado: 1 grafema, 2 code points
    const e = 'e\u0301';
    const corte = NoteLengthLimit(3);
    final v = corte.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(
        text: '$e$e',
        selection: TextSelection.collapsed(offset: 4),
      ),
    );
    expect((v.text, v.text.runes.length), ('${e}e', 3));
    expect(v.selection, const TextSelection.collapsed(offset: 3));
    const cabe = TextEditingValue(text: 'abc');
    expect(
      identical(corte.formatEditUpdate(TextEditingValue.empty, cabe), cabe),
      isTrue,
    );
    expect(const NoteLengthLimit().max, noteMaxLength);
    expect(noteMaxLength, 10000);
  });

  testWidgets('o campo usa o limite do banco', (tester) async {
    await montar(tester);
    final campo = tester.widget<TextField>(
      find.descendant(
        of: _key('leitor.nota.campo'),
        matching: find.byType(TextField),
        matchRoot: true,
      ),
    );
    expect(
      campo.inputFormatters!.whereType<NoteLengthLimit>().single.max,
      noteMaxLength,
    );
  });

  testWidgets('o véu segura os toques (a página embaixo não recebe)', (
    tester,
  ) async {
    await montar(tester);
    await tester.tapAt(const Offset(195, 100));
    expect(eventos, isEmpty);
  });

  testWidgets('Noite: as cores das ilhas', (tester) async {
    await montar(tester, papel: ReaderPaper.noite);
    final c = tester.widget<NeoBox>(_key('leitor.nota'));
    expect(
      (c.color, c.border!.color, c.shadowColor),
      (AppColors.islandNight, AppColors.inkNight, AppColors.shadowNight),
    );
    expect(
      tester.widget<AppText>(_key('leitor.nota.titulo')).span.style!.color,
      AppColors.mutedNight,
    );
    final campo = tester.widget<NeoBox>(
      find
          .ancestor(
            of: _key('leitor.nota.campo'),
            matching: find.byType(NeoBox),
          )
          .first,
    );
    expect(
      campo.color,
      AppColors.paperNight,
      reason: 'a caixa do campo é o "well" das ilhas',
    );
  });
}
