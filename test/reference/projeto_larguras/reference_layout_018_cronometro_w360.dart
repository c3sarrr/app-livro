// dart format off
// GERADO AUTOMATICAMENTE por tools/medicao/gen_reference_dart.py — NÃO EDITE À MÃO.
// Prancha 18 · Cronômetro de leitura (livro físico) — largura 360 — canvas 360×844, dp lógico = px CSS.
// Medido no Chromium 141 com zoom 100 (bordas exatas de 1,5/1,3/1,2 px, métricas sem arredondamento).
// ignore_for_file: lines_longer_than_80_chars
import 'dart:ui';

import '../leitor/ref_tipos.dart';

const LeitorRefPrancha kRef18w360 = LeitorRefPrancha(
  tela: '18w360',
  slug: '018_cronometro_w360',
  prefix: 'cr18',
  canvas: Size(360.0, 844.0),
  sections: <String, Rect>{
    'cr18.top': Rect.fromLTWH(20.0, 58.0, 320.0, 48.0),
    'cr18.book': Rect.fromLTWH(20.0, 124.0, 320.0, 69.0),
    'cr18.timer': Rect.fromLTWH(30.0, 211.0, 300.0, 300.0),
    'cr18.chips': Rect.fromLTWH(32.92, 529.0, 294.17, 34.0),
    'cr18.controls': Rect.fromLTWH(20.0, 621.98, 320.0, 109.01),
    'cr18.note': Rect.fromLTWH(84.97, 744.99, 190.06, 36.0),
    'cr18.lockHint': Rect.fromLTWH(56.81, 794.99, 246.38, 15.01),
  },
  elements: <String, LeitorRefElement>{
    'cr18.top': LeitorRefElement('cr18.top', Rect.fromLTWH(20.0, 58.0, 320.0, 48.0), LeitorRefKind.box),
    'cr18.top.minimize': LeitorRefElement('cr18.top', Rect.fromLTWH(20.0, 58.0, 48.0, 48.0), LeitorRefKind.box),
    'cr18.top.minimize.icon': LeitorRefElement('cr18.top', Rect.fromLTWH(33.0, 71.0, 22.0, 22.0), LeitorRefKind.icon),
    'cr18.top.session': LeitorRefElement('cr18.top', Rect.fromLTWH(123.99, 74.8, 69.42, 14.4), LeitorRefKind.text, lines: <LeitorRefLine>[LeitorRefLine('SESSÃO 7', 123.99, 193.4, 86.2)]),
    'cr18.top.sound': LeitorRefElement('cr18.top', Rect.fromLTWH(249.39, 62.0, 90.61, 40.0), LeitorRefKind.boxText, lines: <LeitorRefLine>[LeitorRefLine('Chuva', 285.89, 324.5, 86.55)]),
    'cr18.top.sound.icon': LeitorRefElement('cr18.top', Rect.fromLTWH(261.89, 73.5, 17.0, 17.0), LeitorRefKind.icon),
    'cr18.book': LeitorRefElement('cr18.book', Rect.fromLTWH(20.0, 124.0, 320.0, 69.0), LeitorRefKind.box),
    'cr18.book.cover': LeitorRefElement('cr18.book', Rect.fromLTWH(20.0, 124.0, 46.0, 69.0), LeitorRefKind.box, visual: Rect.fromLTWH(17.08, 122.13, 51.84, 72.75)),
    'cr18.book.cover.art': LeitorRefElement('cr18.book', Rect.fromLTWH(21.5, 125.5, 43.0, 66.0), LeitorRefKind.icon, visual: Rect.fromLTWH(18.71, 123.75, 48.59, 69.5)),
    'cr18.book.textBlock': LeitorRefElement('cr18.book', Rect.fromLTWH(80.0, 139.51, 250.68, 37.98), LeitorRefKind.box),
    'cr18.book.title': LeitorRefElement('cr18.book', Rect.fromLTWH(80.0, 139.51, 250.68, 19.38), LeitorRefKind.text, lines: <LeitorRefLine>[LeitorRefLine('Memórias Póstumas de Brás Cubas', 80.0, 330.68, 154.62)]),
    'cr18.book.author': LeitorRefElement('cr18.book', Rect.fromLTWH(80.0, 161.89, 250.68, 15.6), LeitorRefKind.text, lines: <LeitorRefLine>[LeitorRefLine('Machado de Assis · livro físico', 80.0, 256.54, 174.24)]),
    'cr18.timer': LeitorRefElement('cr18.timer', Rect.fromLTWH(30.0, 211.0, 300.0, 300.0), LeitorRefKind.box),
    'cr18.timer.ring': LeitorRefElement('cr18.timer', Rect.fromLTWH(30.0, 211.0, 300.0, 300.0), LeitorRefKind.icon),
    'cr18.timer.center': LeitorRefElement('cr18.timer', Rect.fromLTWH(30.0, 211.0, 300.0, 300.0), LeitorRefKind.box),
    'cr18.timer.status': LeitorRefElement('cr18.timer', Rect.fromLTWH(148.44, 301.69, 63.12, 13.81), LeitorRefKind.text, lines: <LeitorRefLine>[LeitorRefLine('LENDO', 163.44, 211.56, 312.62)]),
    'cr18.timer.status.dot': LeitorRefElement('cr18.timer', Rect.fromLTWH(148.44, 304.6, 8.0, 8.0), LeitorRefKind.box),
    'cr18.timer.time': LeitorRefElement('cr18.timer', Rect.fromLTWH(87.88, 321.5, 184.25, 74.0), LeitorRefKind.text, lines: <LeitorRefLine>[LeitorRefLine('08:42', 87.88, 272.12, 382.93)]),
    'cr18.timer.today': LeitorRefElement('cr18.timer', Rect.fromLTWH(119.8, 403.5, 120.4, 16.8), LeitorRefKind.text, lines: <LeitorRefLine>[LeitorRefLine('Hoje: de 30 min', 119.8, 240.2, 416.81)], linesAll: <LeitorRefLine>[LeitorRefLine('Hoje: 26 de 30 min', 119.8, 240.2, 416.81)]),
    'cr18.timer.today.minutes': LeitorRefElement('cr18.timer', Rect.fromLTWH(157.42, 403.5, 16.44, 16.8), LeitorRefKind.inline, lines: <LeitorRefLine>[LeitorRefLine('26', 157.42, 173.85, 416.81)]),
    'cr18.chips': LeitorRefElement('cr18.chips', Rect.fromLTWH(32.92, 529.0, 294.17, 34.0), LeitorRefKind.box),
    'cr18.chips.goal': LeitorRefElement('cr18.chips', Rect.fromLTWH(32.92, 529.0, 200.31, 34.0), LeitorRefKind.boxText, lines: <LeitorRefLine>[LeitorRefLine('Faltam 4 min para a meta', 66.42, 218.72, 550.55)]),
    'cr18.chips.goal.icon': LeitorRefElement('cr18.chips', Rect.fromLTWH(44.42, 538.0, 16.0, 16.0), LeitorRefKind.icon),
    'cr18.chips.streak': LeitorRefElement('cr18.chips', Rect.fromLTWH(241.22, 529.0, 85.86, 34.0), LeitorRefKind.boxText, lines: <LeitorRefLine>[LeitorRefLine('12 dias', 272.72, 313.58, 550.55)]),
    'cr18.chips.streak.icon': LeitorRefElement('cr18.chips', Rect.fromLTWH(251.72, 538.0, 16.0, 16.0), LeitorRefKind.icon),
    'cr18.controls': LeitorRefElement('cr18.controls', Rect.fromLTWH(20.0, 621.98, 320.0, 109.01), LeitorRefKind.box),
    'cr18.controls.photo': LeitorRefElement('cr18.controls', Rect.fromLTWH(26.0, 621.98, 86.0, 81.01), LeitorRefKind.box),
    'cr18.controls.photo.button': LeitorRefElement('cr18.controls', Rect.fromLTWH(40.0, 621.98, 58.0, 58.0), LeitorRefKind.box),
    'cr18.controls.photo.icon': LeitorRefElement('cr18.controls', Rect.fromLTWH(58.0, 639.98, 22.0, 22.0), LeitorRefKind.icon),
    'cr18.controls.photo.label': LeitorRefElement('cr18.controls', Rect.fromLTWH(49.15, 687.98, 39.7, 15.01), LeitorRefKind.text, lines: <LeitorRefLine>[LeitorRefLine('Trecho', 49.15, 88.85, 699.86)]),
    'cr18.controls.pause': LeitorRefElement('cr18.controls', Rect.fromLTWH(137.0, 621.98, 86.0, 109.01), LeitorRefKind.box),
    'cr18.controls.pause.button': LeitorRefElement('cr18.controls', Rect.fromLTWH(137.0, 621.98, 86.0, 86.0), LeitorRefKind.box),
    'cr18.controls.pause.icon': LeitorRefElement('cr18.controls', Rect.fromLTWH(165.0, 649.98, 30.0, 30.0), LeitorRefKind.icon),
    'cr18.controls.pause.label': LeitorRefElement('cr18.controls', Rect.fromLTWH(160.8, 715.98, 38.4, 15.01), LeitorRefKind.text, lines: <LeitorRefLine>[LeitorRefLine('Pausar', 160.8, 199.2, 727.86)]),
    'cr18.controls.end': LeitorRefElement('cr18.controls', Rect.fromLTWH(248.0, 621.98, 86.0, 81.01), LeitorRefKind.box),
    'cr18.controls.end.button': LeitorRefElement('cr18.controls', Rect.fromLTWH(262.0, 621.98, 58.0, 58.0), LeitorRefKind.box),
    'cr18.controls.end.icon': LeitorRefElement('cr18.controls', Rect.fromLTWH(282.0, 641.98, 18.0, 18.0), LeitorRefKind.icon),
    'cr18.controls.end.label': LeitorRefElement('cr18.controls', Rect.fromLTWH(266.46, 687.98, 49.09, 15.01), LeitorRefKind.text, lines: <LeitorRefLine>[LeitorRefLine('Encerrar', 266.46, 315.54, 699.86)]),
    'cr18.note': LeitorRefElement('cr18.note', Rect.fromLTWH(84.97, 744.99, 190.06, 36.0), LeitorRefKind.box),
    'cr18.note.button': LeitorRefElement('cr18.note', Rect.fromLTWH(84.97, 744.99, 190.06, 36.0), LeitorRefKind.boxText, lines: <LeitorRefLine>[LeitorRefLine('Anotar um pensamento', 119.47, 259.53, 767.54)]),
    'cr18.note.button.icon': LeitorRefElement('cr18.note', Rect.fromLTWH(97.47, 755.49, 15.0, 15.0), LeitorRefKind.icon),
    'cr18.lockHint': LeitorRefElement('cr18.lockHint', Rect.fromLTWH(56.81, 794.99, 246.38, 15.01), LeitorRefKind.text, lines: <LeitorRefLine>[LeitorRefLine('Pode bloquear a tela: o tempo continua.', 77.81, 303.19, 806.87)]),
    'cr18.lockHint.icon': LeitorRefElement('cr18.lockHint', Rect.fromLTWH(56.81, 795.5, 14.0, 14.0), LeitorRefKind.icon),
  },
  textDependentX: <String>{'cr18.book.author', 'cr18.book.textBlock', 'cr18.book.title', 'cr18.chips', 'cr18.chips.goal', 'cr18.chips.goal.icon', 'cr18.chips.streak', 'cr18.chips.streak.icon', 'cr18.controls.end.label', 'cr18.controls.pause.label', 'cr18.controls.photo.label', 'cr18.lockHint', 'cr18.lockHint.icon', 'cr18.note', 'cr18.note.button', 'cr18.note.button.icon', 'cr18.timer.status', 'cr18.timer.status.dot', 'cr18.timer.time', 'cr18.timer.today', 'cr18.timer.today.minutes', 'cr18.top.session', 'cr18.top.sound', 'cr18.top.sound.icon'},
  textDependentY: <String>{'cr18.book.author', 'cr18.book.textBlock', 'cr18.book.title'},
  ellipsized: <String>{},
  knifeEdges: <LeitorKnifeEdge>[
  ],
);
