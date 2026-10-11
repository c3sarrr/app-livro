// dart format off
// GERADO AUTOMATICAMENTE por tools/medicao/gen_reference_dart.py — NÃO EDITE À MÃO.
// Prancha 41 · Scanner — sem permissão de câmera — canvas 390×844, dp lógico = px CSS.
// Medido no Chromium 141 com zoom 100 (bordas exatas de 1,5/1,3/1,2 px, métricas sem arredondamento).
// ignore_for_file: lines_longer_than_80_chars
import 'dart:ui';

import '../leitor/ref_tipos.dart';

const LeitorRefPrancha kRef41 = LeitorRefPrancha(
  tela: '41',
  slug: '041_scanner_sem_permissao',
  prefix: 'sc41',
  canvas: Size(390.0, 844.0),
  sections: <String, Rect>{
    'sc41.backdrop': Rect.fromLTWH(0.0, 0.0, 390.0, 844.0),
    'sc41.corners': Rect.fromLTWH(50.0, 176.0, 290.0, 170.0),
    'sc41.controls': Rect.fromLTWH(20.0, 58.0, 350.0, 48.0),
    'sc41.sheet': Rect.fromLTWH(10.0, 353.64, 370.0, 480.36),
  },
  elements: <String, LeitorRefElement>{
    'sc41.backdrop': LeitorRefElement('sc41.backdrop', Rect.fromLTWH(0.0, 0.0, 390.0, 844.0), LeitorRefKind.box),
    'sc41.corners': LeitorRefElement('sc41.corners', Rect.fromLTWH(50.0, 176.0, 290.0, 170.0), LeitorRefKind.icon),
    'sc41.controls': LeitorRefElement('sc41.controls', Rect.fromLTWH(20.0, 58.0, 350.0, 48.0), LeitorRefKind.box),
    'sc41.controls.close': LeitorRefElement('sc41.controls', Rect.fromLTWH(20.0, 58.0, 48.0, 48.0), LeitorRefKind.box),
    'sc41.controls.close.icon': LeitorRefElement('sc41.controls', Rect.fromLTWH(34.0, 72.0, 20.0, 20.0), LeitorRefKind.icon),
    'sc41.controls.mode': LeitorRefElement('sc41.controls', Rect.fromLTWH(91.92, 58.0, 206.15, 48.0), LeitorRefKind.box),
    'sc41.controls.mode.code': LeitorRefElement('sc41.controls', Rect.fromLTWH(96.42, 62.5, 101.25, 39.0), LeitorRefKind.boxText, lines: <LeitorRefLine>[LeitorRefLine('Código', 134.92, 182.17, 86.9)]),
    'sc41.controls.mode.code.icon': LeitorRefElement('sc41.controls', Rect.fromLTWH(109.92, 73.0, 18.0, 18.0), LeitorRefKind.icon),
    'sc41.controls.mode.type': LeitorRefElement('sc41.controls', Rect.fromLTWH(199.67, 62.5, 93.9, 39.0), LeitorRefKind.text, lines: <LeitorRefLine>[LeitorRefLine('Digitar', 236.67, 279.58, 86.9)]),
    'sc41.controls.mode.type.icon': LeitorRefElement('sc41.controls', Rect.fromLTWH(211.67, 73.0, 18.0, 18.0), LeitorRefKind.icon),
    'sc41.controls.torch': LeitorRefElement('sc41.controls', Rect.fromLTWH(322.0, 58.0, 48.0, 48.0), LeitorRefKind.box),
    'sc41.controls.torch.icon': LeitorRefElement('sc41.controls', Rect.fromLTWH(336.0, 72.0, 20.0, 20.0), LeitorRefKind.icon),
    'sc41.sheet': LeitorRefElement('sc41.sheet', Rect.fromLTWH(10.0, 353.64, 370.0, 480.36), LeitorRefKind.box),
    'sc41.sheet.handle': LeitorRefElement('sc41.sheet', Rect.fromLTWH(175.0, 365.14, 40.0, 5.0), LeitorRefKind.box),
    'sc41.sheet.art': LeitorRefElement('sc41.sheet', Rect.fromLTWH(29.5, 386.14, 331.0, 120.0), LeitorRefKind.box),
    'sc41.sheet.art.image': LeitorRefElement('sc41.sheet', Rect.fromLTWH(120.0, 386.14, 150.0, 120.0), LeitorRefKind.icon),
    'sc41.sheet.title': LeitorRefElement('sc41.sheet', Rect.fromLTWH(29.5, 520.14, 331.0, 59.16), LeitorRefKind.text, lines: <LeitorRefLine>[LeitorRefLine('A câmera está', 36.02, 202.41, 544.79)], linesAll: <LeitorRefLine>[LeitorRefLine('A câmera está desligada para', 36.02, 353.98, 544.79), LeitorRefLine('nós.', 175.09, 214.91, 574.37)]),
    'sc41.sheet.title.serif': LeitorRefElement('sc41.sheet', Rect.fromLTWH(175.09, 516.08, 178.89, 67.28), LeitorRefKind.inline, lines: <LeitorRefLine>[LeitorRefLine('desligada para', 206.74, 353.98, 544.79), LeitorRefLine('nós.', 175.09, 214.91, 574.37)]),
    'sc41.sheet.body': LeitorRefElement('sc41.sheet', Rect.fromLTWH(35.5, 587.3, 319.0, 40.6), LeitorRefKind.text, lines: <LeitorRefLine>[LeitorRefLine('Ela só serve para ler o código de barras —', 62.13, 327.87, 602.35), LeitorRefLine('nenhuma foto é guardada ou enviada.', 75.53, 314.46, 622.65)]),
    'sc41.sheet.path': LeitorRefElement('sc41.sheet', Rect.fromLTWH(29.5, 641.9, 331.0, 40.6), LeitorRefKind.box),
    'sc41.sheet.path.icon': LeitorRefElement('sc41.sheet', Rect.fromLTWH(42.8, 653.2, 18.0, 18.0), LeitorRefKind.icon),
    'sc41.sheet.path.text': LeitorRefElement('sc41.sheet', Rect.fromLTWH(68.8, 654.4, 235.01, 15.6), LeitorRefKind.text, lines: <LeitorRefLine>[LeitorRefLine('Ajustes do celular › BookNest ›', 68.8, 253.36, 666.75)], linesAll: <LeitorRefLine>[LeitorRefLine('Ajustes do celular › BookNest › Câmera', 68.8, 303.81, 666.75)]),
    'sc41.sheet.path.text.strong': LeitorRefElement('sc41.sheet', Rect.fromLTWH(256.45, 654.4, 47.36, 15.6), LeitorRefKind.inline, lines: <LeitorRefLine>[LeitorRefLine('Câmera', 256.45, 303.81, 666.75)]),
    'sc41.sheet.openSettings': LeitorRefElement('sc41.sheet', Rect.fromLTWH(29.5, 696.5, 331.0, 54.0), LeitorRefKind.boxText, lines: <LeitorRefLine>[LeitorRefLine('Abrir os ajustes do celular', 98.58, 291.42, 729.1)]),
    'sc41.sheet.typeIsbn': LeitorRefElement('sc41.sheet', Rect.fromLTWH(29.5, 760.5, 331.0, 50.0), LeitorRefKind.boxText, lines: <LeitorRefLine>[LeitorRefLine('Digitar o ISBN', 158.94, 257.06, 790.75)]),
    'sc41.sheet.typeIsbn.icon': LeitorRefElement('sc41.sheet', Rect.fromLTWH(132.94, 776.5, 18.0, 18.0), LeitorRefKind.icon),
  },
  textDependentX: <String>{'sc41.controls.mode', 'sc41.controls.mode.code', 'sc41.controls.mode.code.icon', 'sc41.controls.mode.type', 'sc41.controls.mode.type.icon', 'sc41.sheet.path.text', 'sc41.sheet.path.text.strong', 'sc41.sheet.title.serif', 'sc41.sheet.typeIsbn.icon'},
  textDependentY: <String>{},
  ellipsized: <String>{},
  knifeEdges: <LeitorKnifeEdge>[
  ],
);
