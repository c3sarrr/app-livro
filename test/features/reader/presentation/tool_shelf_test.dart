// G16.6 — a prateleira de ferramentas (L22c): os 6 objetos nos lugares da prancha, a ativa 12 px acima (a caixa de
// layout fica); desenho de ativa só na Caneta e no Espaço (D-58) — a Caneta ativa com a `brand` e a tinta trocadas
// no SVG, a inativa com o corpo `#FFFAF1` e a tinta; as outras só sobem; no Noite, os objetos como no Creme
// (D-167 17); o grupo de opções "Ferramentas de anotação" para o leitor de tela e o toque.
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_leitor.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart'
    show AnnotationTool;
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/tool_shelf.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/reference_layout_22_modo_anotacao.dart';
import '../../../support/pecas_l22.dart';

const _brand = Color(0xFF058CD7);
const _tinta = Color(0xFFFF552E);

void main() {
  Future<List<AnnotationTool>> montar(
    WidgetTester tester, {
    AnnotationTool ativa = AnnotationTool.pen,
    ReaderPaper papel = ReaderPaper.creme,
    Color tinta = _tinta,
  }) async {
    final toques = <AnnotationTool>[];
    await montarPecasL22(
      tester,
      [
        Positioned(
          left: 39,
          top: 676,
          child: ToolShelf(active: ativa, ink: tinta, onTool: toques.add),
        ),
      ],
      papel: papel,
      brand: _brand,
    );
    return toques;
  }

  AppSvg arte(WidgetTester tester, String id) =>
      tester.widget<AppSvg>(chaveL22('$id.art'));

  testWidgets(
    'L22c — geometria: os 13 ids (a Caneta ativa na caixa visual, 12 acima)',
    (tester) async {
      await montar(tester);
      final ids = kRef22.idsOfSection('ann.toolShelf').toList();
      expect(ids, hasLength(13));
      conferirGeometriaL22(tester, ids);
      // a caixa de layout da ativa fica no lugar
      expect(
        tester.getRect(chaveL22('ann.toolShelf.pen#slot')),
        kRef22.elements['ann.toolShelf.pen']!.rect,
      );
    },
  );

  testWidgets(
    'a ativa sobe 12 e as outras descem: a Borracha ativa, a Caneta volta ao lugar',
    (tester) async {
      await montar(tester, ativa: AnnotationTool.eraser);
      expect(tester.getRect(chaveL22('ann.toolShelf.eraser')).top, 664);
      expect(tester.getRect(chaveL22('ann.toolShelf.eraser.art')).top, 664);
      expect(tester.getRect(chaveL22('ann.toolShelf.pen')).top, 676);
      expect(
        tester.getRect(chaveL22('ann.toolShelf')).size,
        const Size(312, 70),
      );
    },
  );

  testWidgets(
    'desenho de ativa só na Caneta (D-58): ativa com a brand e a tinta; inativa com o corpo claro e a tinta',
    (tester) async {
      await montar(tester);
      final ativa = arte(tester, 'ann.toolShelf.pen');
      expect(ativa.asset, AppIllustrationsLeitor.toolPenActive);
      expect(ativa.colors, {
        AppColors.lavender: _brand,
        AppColors.flame: _tinta,
      });
      expect(
        [
          for (final id in const ['marker', 'eraser', 'lasso', 'line', 'space'])
            arte(tester, 'ann.toolShelf.$id').asset,
        ],
        [
          AppIllustrationsLeitor.toolMarker,
          AppIllustrationsLeitor.toolEraser,
          AppIllustrationsLeitor.toolLasso,
          AppIllustrationsLeitor.toolLine,
          AppIllustrationsLeitor.toolSpace,
        ],
      );
      expect(arte(tester, 'ann.toolShelf.eraser').colors, isNull);
      await montar(tester, ativa: AnnotationTool.lasso, tinta: AppColors.azure);
      final inativa = arte(tester, 'ann.toolShelf.pen');
      expect(inativa.asset, AppIllustrationsLeitor.toolPen);
      expect(inativa.colors, {AppColors.flame: AppColors.azure});
      // o Laço só sobe
      expect(
        arte(tester, 'ann.toolShelf.lasso').asset,
        AppIllustrationsLeitor.toolLasso,
      );
    },
  );

  testWidgets('Noite (D-167 17): os objetos como no Creme', (tester) async {
    await montar(tester, papel: ReaderPaper.noite);
    final ativa = arte(tester, 'ann.toolShelf.pen');
    expect(ativa.asset, AppIllustrationsLeitor.toolPenActive);
    expect(ativa.colors, {AppColors.lavender: _brand, AppColors.flame: _tinta});
    conferirGeometriaL22(tester, kRef22.idsOfSection('ann.toolShelf'));
  });

  testWidgets(
    'semântica: "Ferramentas de anotação" com as 6 opções e a marcada; o toque escolhe',
    (tester) async {
      final toques = await montar(tester);
      final h = tester.ensureSemantics();
      expect(
        tester.getSemantics(chaveL22('ann.toolShelf')),
        isSemantics(label: 'Ferramentas de anotação'),
      );
      for (final (id, rotulo, marcada) in const [
        ('pen', 'Caneta', true),
        ('marker', 'Marca-texto', false),
        ('eraser', 'Borracha', false),
        ('lasso', 'Laço — selecionar e mover traços', false),
        ('line', 'Linha reta', false),
        (
          'space',
          'Espaço — arrastar entre as linhas para abrir lugar de escrever',
          false,
        ),
      ]) {
        expect(
          tester.getSemantics(chaveL22('ann.toolShelf.$id')),
          isSemantics(
            label: rotulo,
            hasCheckedState: true,
            isChecked: marcada,
            isInMutuallyExclusiveGroup: true,
            hasTapAction: true,
          ),
          reason: id,
        );
      }
      await tester.tap(chaveL22('ann.toolShelf.line'));
      await tester.tap(chaveL22('ann.toolShelf.marker'));
      expect(toques, [AnnotationTool.line, AnnotationTool.marker]);
      h.dispose();
    },
  );
}
