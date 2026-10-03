"""Gera as referências Dart usadas pelos testes a partir das medições em JSON.

Uso (na pasta referencia/layout/ ou passando caminhos):
  python3 gen_reference_dart.py layout_inicio.json text_dependency.json > reference_layout.dart
  python3 gen_reference_dart.py --flat layout_w360.json > reference_layout_w360.dart
  python3 gen_reference_dart.py --flat layout_w430.json > reference_layout_w430.dart

- layout_inicio.json  : saída de build_layout.py (meta, sections, elements com abs/lines/type).
- text_dependency.json: saída de perturb.js (quais ids mudam x/w quando a largura dos textos muda
                        → tolerância horizontal ±1,0 em vez de ±0,5).
- --flat              : layout_wNNN.json (elements = id → [x, y, w, h]) → mapa kRefLayoutWNNN.

Os arquivos gerados começam com `// dart format off`, respeitado só no estilo "tall" do formatador
(versão de linguagem do pacote ≥ 3.7). Se `dart format --output=none --set-exit-if-changed test/reference`
acusar mudança no projeto, rode `dart format test/reference/` UMA vez (só muda quebras de linha, nunca valores).
"""
import json
import sys

KIND = {'box': 'RefKind.box', 'box+text': 'RefKind.boxText', 'text': 'RefKind.text', 'icon': 'RefKind.icon'}


def num(v):
    return repr(float(v))


def dstr(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def rect(a):
    return f'Rect.fromLTWH({num(a[0])}, {num(a[1])}, {num(a[2])}, {num(a[3])})'


def full(layout_path, dep_path):
    lay = json.load(open(layout_path, encoding='utf-8'))
    dep = json.load(open(dep_path, encoding='utf-8'))
    els = lay['elements']
    W, H = lay['meta']['canvas']
    out = [
        '// dart format off',
        '// GERADO AUTOMATICAMENTE a partir de referencia/layout/layout_inicio.json — NÃO EDITE À MÃO.',
        f'// Fonte da verdade geométrica da tela Início (canvas {W}×{H}, dp lógico = px CSS).',
        '// Medido no Chromium com zoom 100 (bordas exatas de 1.5/1.2 px, métricas sem arredondamento).',
        '// ignore_for_file: lines_longer_than_80_chars',
        "import 'dart:ui';",
        '',
        'enum RefKind { box, boxText, text, icon }',
        '',
        '/// Ids com `text-overflow: ellipsis` efetivo no arquivo (linha única truncada com "…").',
        'const Set<String> kEllipsized = <String>{' + ', '.join(dstr(k) for k, v in els.items() if v.get('ellipsis')) + '};',
        '',
        'class RefLine {',
        '  const RefLine(this.text, this.left, this.right, this.baseline);',
        '  final String text;',
        '  final double left;',
        '  final double right;',
        '  final double baseline;',
        '}',
        '',
        'class RefElement {',
        '  const RefElement(this.section, this.rect, this.kind, [this.lines = const <RefLine>[]]);',
        '  final String section;',
        '  /// Retângulo de LAYOUT (sem transform/rotação), coordenadas absolutas do canvas.',
        '  final Rect rect;',
        '  final RefKind kind;',
        '  /// Linhas de texto: left/right do trecho de glifos (por avanço) e baseline absoluta.',
        '  final List<RefLine> lines;',
        '}',
        '',
        'const Map<String, Rect> kRefSections = <String, Rect>{',
    ]
    for name, r in lay['sections'].items():
        out.append(f'  {dstr(name)}: {rect(r)},')
    out += ['};', '', 'const Map<String, RefElement> kRefLayout = <String, RefElement>{']
    for k, v in els.items():
        if v['type'] == 'inline' or 'section' not in v:
            continue  # inline: sem widget próprio (conferido pelas linhas do pai); frame/main: moldura do arquivo
        args = [dstr(v['section']), rect(v['abs']), KIND[v['type']]]
        if v.get('lines'):
            ls = ', '.join(f"RefLine({dstr(l['text'])}, {num(l['left'])}, {num(l['right'])}, {num(l['baseline'])})" for l in v['lines'])
            args.append(f'<RefLine>[{ls}]')
        out.append(f'  {dstr(k)}: RefElement({", ".join(args)}),')
    out += ['};', '',
            '/// Elementos cuja posição/largura HORIZONTAL depende da largura medida do texto',
            '/// (tolerância ±1,0 px em x/w). Todos os demais: ±0,5 px. Vertical: sempre ±0,5 px.',
            'const Set<String> kTextDependentX = <String>{']
    for k in sorted(k for k, f in dep.items() if (f['x'] or f['w']) and k in els):
        out.append(f'  {dstr(k)},')
    out.append('};')
    return '\n'.join(out) + '\n'


def flat(path):
    lay = json.load(open(path, encoding='utf-8'))
    W, _ = lay['meta']['canvas']
    out = [
        '// dart format off',
        f'// GERADO a partir do HTML original com a largura do canvas alterada para {W} px (comportamento fluido do CSS).',
        '// Validação SECUNDÁRIA da FASE 13 (tolerância ±1,0 px). Mesmas convenções de Keys/rotação do canvas 390.',
        '// ignore_for_file: lines_longer_than_80_chars',
        "import 'dart:ui';",
        '',
        f'const Map<String, Rect> kRefLayoutW{W} = <String, Rect>{{',
    ]
    for k, r in lay['elements'].items():
        out.append(f'  {dstr(k)}: {rect(r)},')
    out.append('};')
    return '\n'.join(out) + '\n'


if __name__ == '__main__':
    if sys.argv[1] == '--flat':
        sys.stdout.write(flat(sys.argv[2]))
    else:
        sys.stdout.write(full(sys.argv[1], sys.argv[2]))
