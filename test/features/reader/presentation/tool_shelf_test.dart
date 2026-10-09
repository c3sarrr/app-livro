// G16.6 — a prateleira de ferramentas (L22c): os 6 objetos nos lugares da prancha, a ativa 12 px acima (a caixa de
// layout fica); desenho de ativa só na Caneta e no Espaço (D-58) — a Caneta ativa com a `brand` e a tinta trocadas
// no SVG, a inativa com o corpo `#FFFAF1` e a tinta; as outras só sobem; no Noite, os objetos como no Creme
// (D-167 17), menos o Laço, com o preenchimento opaco já composto sobre o claro dos objetos (D-190); o grupo de
// opções "Ferramentas de anotação" para o leitor de tela e o toque.
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
import '../../../support/capture.dart';
import '../../../support/pecas_l22.dart';
import '../../../support/precache_svgs.dart';

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

  testWidgets(
    'Noite (D-167 17): os objetos como no Creme; o Laço com o preenchimento opaco (D-190)',
    (tester) async {
      await montar(tester, papel: ReaderPaper.noite);
      final ativa = arte(tester, 'ann.toolShelf.pen');
      expect(ativa.asset, AppIllustrationsLeitor.toolPenActive);
      expect(ativa.colors, {
        AppColors.lavender: _brand,
        AppColors.flame: _tinta,
      });
      expect(arte(tester, 'ann.toolShelf.eraser').colors, isNull);
      final laco = arte(tester, 'ann.toolShelf.lasso');
      expect(laco.asset, AppIllustrationsLeitor.toolLasso);
      expect(laco.colors, {const Color(0x59B6ACE4): const Color(0xFFE5DFEC)});
      conferirGeometriaL22(tester, kRef22.idsOfSection('ann.toolShelf'));
      // no Creme, o Laço do arquivo
      await montar(tester);
      expect(arte(tester, 'ann.toolShelf.lasso').colors, isNull);
    },
  );

  test(
    'D-190: o Laço no Noite, ativo ou não; as outras ferramentas não mudam',
    () {
      for (final on in const [false, true]) {
        final (noite, trocas) = ToolShelf.art(
          AnnotationTool.lasso,
          on: on,
          brand: _brand,
          ink: _tinta,
          night: true,
        );
        expect(noite, AppIllustrationsLeitor.toolLasso);
        expect(trocas, {ToolShelf.lassoFill: ToolShelf.lassoFillNight});
        expect(
          ToolShelf.art(
            AnnotationTool.lasso,
            on: on,
            brand: _brand,
            ink: _tinta,
          ),
          (AppIllustrationsLeitor.toolLasso, null),
        );
      }
      // o lavanda a 35 % do arquivo, já composto sobre o #FFFAF1 dos objetos
      expect(ToolShelf.lassoFill, const Color(0x59B6ACE4));
      expect(ToolShelf.lassoFillNight, const Color(0xFFE5DFEC));
      for (final tool in AnnotationTool.values) {
        if (tool == AnnotationTool.lasso) continue;
        for (final on in const [false, true]) {
          final (a, ca) = ToolShelf.art(
            tool,
            on: on,
            brand: _brand,
            ink: _tinta,
            night: true,
          );
          final (b, cb) = ToolShelf.art(
            tool,
            on: on,
            brand: _brand,
            ink: _tinta,
          );
          expect(a, b, reason: '$tool $on');
          expect(ca, cb, reason: '$tool $on');
        }
      }
    },
  );

  testWidgets(
    'D-190: no Noite, o miolo do Laço sai #E5DFEC sobre o papel escuro (a troca acha a cor do arquivo)',
    (tester) async {
      final (asset, noite) = ToolShelf.art(
        AnnotationTool.lasso,
        on: false,
        brand: _brand,
        ink: _tinta,
        night: true,
      );
      await precacheSvgs(tester, [asset], colors: noite);
      await precacheSvgs(tester, [asset]);
      const chave = ValueKey('laco');
      Future<List<int>> miolo(Map<Color, Color>? cores) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: RepaintBoundary(
                key: chave,
                child: ColoredBox(
                  color: const Color(0xFF1A1714),
                  child: AppSvg(asset, size: 50, height: 70, colors: cores),
                ),
              ),
            ),
          ),
        );
        final imagem = await captureAt(tester, find.byKey(chave));
        final px = await rgbaOf(tester, imagem);
        // o centro da elipse (25, 15), a 3×
        final i = (45 * imagem.width + 75) * 4;
        return px.sublist(i, i + 4);
      }

      expect(await miolo(noite), [0xE5, 0xDF, 0xEC, 0xFF]);
      // sem a troca, o preenchimento translúcido deixa o escuro passar
      expect((await miolo(null))[0], lessThan(0x80));
    },
  );

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

  test('R28: o desenho do Marca-texto troca o amarelo pela cor dele; com o amarelo, igual à prancha', () {
    final (asset, rosa) = ToolShelf.art(
      AnnotationTool.marker,
      on: true,
      brand: _brand,
      ink: _tinta,
      marker: AppColors.blush,
    );
    expect(asset, AppIllustrationsLeitor.toolMarker);
    expect(rosa, {AppColors.sun: AppColors.blush});
    final (_, amarelo) = ToolShelf.art(
      AnnotationTool.marker,
      on: false,
      brand: _brand,
      ink: _tinta,
      marker: AppColors.sun,
    );
    expect(amarelo, isNull);
    // a Caneta continua com a tinta dela, mesmo com o Marca-texto ativo
    final (_, caneta) = ToolShelf.art(
      AnnotationTool.pen,
      on: false,
      brand: _brand,
      ink: _tinta,
      marker: AppColors.blush,
    );
    expect(caneta, {AppColors.flame: _tinta});
  });

  testWidgets('R28 na prateleira: o SVG do Marca-texto recebe a cor dele', (
    tester,
  ) async {
    await montarPecasL22(tester, [
      Positioned(
        left: 39,
        top: 676,
        child: ToolShelf(
          active: AnnotationTool.marker,
          ink: _tinta,
          marker: AppColors.leaf,
          onTool: (_) {},
        ),
      ),
    ], brand: _brand);
    final svg = tester.widget<AppSvg>(
      find.descendant(
        of: find.byKey(const ValueKey('ann.toolShelf.marker')),
        matching: find.byType(AppSvg),
      ),
    );
    expect(svg.colors, {AppColors.sun: AppColors.leaf});
  });
}
