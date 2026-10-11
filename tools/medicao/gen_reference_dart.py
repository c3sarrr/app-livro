#!/usr/bin/env python3
"""G01.6 — gera as referências Dart das pranchas 19–27b a partir das medições em JSON:
  test/reference/leitor/ref_tipos.dart                      tipos (LeitorRefPrancha, LeitorRefElement…)
  test/reference/leitor/reference_layout_<slug>.dart        const kRef<tela> por prancha
  test/reference/leitor/referencias_leitor.dart             kRefLeitor: tela → prancha
Entradas: handoff_v2/referencia/layout/layout_<slug>.json, text_dependency.json, knife_edges.json.
Convenções da v1: retângulo de LAYOUT (sem transform) em coordenadas absolutas do canvas; tolerância
horizontal ±1,0 para ids em textDependentX, ±0,5 no resto; ids inline e contêineres especiais (frame, <main>)
não têm widget próprio no gate de geometria (os inline entram com kind inline, para as linhas do pai).
Os arquivos começam com `// dart format off` (como na v1).
Uso: [CONJUNTO=inicio2] python3 tools/medicao/gen_reference_dart.py
T02: as pastas vêm do conjunto (conjuntos.json); os outros conjuntos importam os tipos do leitor (dartTipos) e têm o
próprio índice (dartIndice: arquivo e nome do mapa).
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from conjunto import C, caminho, indice  # noqa: E402

AQUI = os.path.dirname(__file__)
RAIZ = os.path.abspath(os.path.join(AQUI, '..', '..'))
LAY = caminho('layout')
OUT = caminho('dart')
CFG = indice()
TIPOS_DART = C['dartTipos']
INDICE_DART, MAPA_DART = C['dartIndice']
KIND = {'box': 'LeitorRefKind.box', 'box+text': 'LeitorRefKind.boxText', 'text': 'LeitorRefKind.text',
        'icon': 'LeitorRefKind.icon', 'inline': 'LeitorRefKind.inline'}
CAB = ['// dart format off',
       '// GERADO AUTOMATICAMENTE por tools/medicao/gen_reference_dart.py — NÃO EDITE À MÃO.']

TIPOS = CAB + ['''// Tipos das referências medidas das telas do leitor (19–27b). Fonte: handoff_v2/referencia/layout/*.json.
// ignore_for_file: lines_longer_than_80_chars
import 'dart:ui';

/// box = caixa sem texto próprio · boxText = caixa com fundo/borda e texto · text = texto · icon = `<svg>`
/// inline = trecho dentro do texto do pai (sem widget próprio: conferido pelas linhas do pai).
enum LeitorRefKind { box, boxText, text, icon, inline }

/// Uma linha de texto medida: left/right dos glifos e baseline absoluta.
/// hidden = linha recortada por overflow (existe no layout, mas não aparece na prancha).
class LeitorRefLine {
  const LeitorRefLine(this.text, this.left, this.right, this.baseline, {this.hidden = false});
  final String text;
  final double left;
  final double right;
  final double baseline;
  final bool hidden;
}

class LeitorRefElement {
  const LeitorRefElement(this.section, this.rect, this.kind, {this.visual, this.lines = const <LeitorRefLine>[], this.linesAll = const <LeitorRefLine>[]});
  final String section;

  /// Retângulo de LAYOUT (transforms neutralizados), coordenadas absolutas do canvas.
  final Rect rect;

  /// Caixa visual com transform (rotate/translate) — só quando difere de [rect].
  final Rect? visual;
  final LeitorRefKind kind;

  /// Linhas do texto PRÓPRIO do elemento (nós de texto diretos).
  final List<LeitorRefLine> lines;

  /// Linhas do texto COMPOSTO (texto próprio + filhos inline), quando há filhos inline com texto.
  final List<LeitorRefLine> linesAll;
}

/// Uma linha frágil: [slack] = sobra até a borda; [joinOverflow] = quanto faltaria para a próxima palavra caber.
class LeitorKnifeEdge {
  const LeitorKnifeEdge(this.id, this.line, this.text, this.slack, this.joinOverflow);
  final String id;
  final int line;
  final String text;
  final double slack;
  final double? joinOverflow;
}

class LeitorRefPrancha {
  const LeitorRefPrancha({
    required this.tela,
    required this.slug,
    required this.prefix,
    required this.canvas,
    required this.sections,
    required this.elements,
    required this.textDependentX,
    required this.textDependentY,
    required this.ellipsized,
    required this.knifeEdges,
  });
  final String tela;
  final String slug;
  final String prefix;
  final Size canvas;
  final Map<String, Rect> sections;
  final Map<String, LeitorRefElement> elements;

  /// x/w dependem da largura medida do texto → tolerância horizontal ±1,0 (demais ±0,5).
  final Set<String> textDependentX;

  /// y/h mudam quando o texto alarga (quebras de linha a montante).
  final Set<String> textDependentY;

  /// `text-overflow: ellipsis` efetivo (o texto não cabe e vira "…").
  final Set<String> ellipsized;

  /// Quebras "fio de navalha" (sobra ou estouro < 1,5 px).
  final List<LeitorKnifeEdge> knifeEdges;

  /// Ids com widget próprio de uma seção (sem os inline), na ordem do arquivo.
  Iterable<String> idsOfSection(String section, {bool includeInline = false}) => elements.entries
      .where((e) => e.value.section == section && (includeInline || e.value.kind != LeitorRefKind.inline))
      .map((e) => e.key);
}
''']


def num(v):
    return repr(float(v))


def dstr(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def rect(a):
    return f'Rect.fromLTWH({num(a[0])}, {num(a[1])}, {num(a[2])}, {num(a[3])})'


def lines(ls):
    out = []
    for ln in ls:
        h = ', hidden: true' if ln.get('oculta') else ''
        out.append(f"LeitorRefLine({dstr(ln['text'])}, {num(ln['left'])}, {num(ln['right'])}, {num(ln['baseline'])}{h})")
    return '<LeitorRefLine>[' + ', '.join(out) + ']'


def const_name(tela):
    return f'kRef{tela}'


def const_info(tela):
    return f'kInformativo{tela}'


def prancha(p, dep, kni):
    L = json.load(open(os.path.join(LAY, f"layout_{p['slug']}.json"), encoding='utf-8'))
    W, H = L['meta']['canvas']
    out = CAB + [f"// Prancha {p['titulo']} — canvas {W}×{H}, dp lógico = px CSS.",
                 '// Medido no Chromium 141 com zoom 100 (bordas exatas de 1,5/1,3/1,2 px, métricas sem arredondamento).',
                 '// ignore_for_file: lines_longer_than_80_chars',
                 "import 'dart:ui';", '', f"import '{TIPOS_DART}';", '',
                 f"const LeitorRefPrancha {const_name(p['tela'])} = LeitorRefPrancha(",
                 f"  tela: {dstr(p['tela'])},", f"  slug: {dstr(p['slug'])},", f"  prefix: {dstr(p['prefixo'])},",
                 f'  canvas: Size({num(W)}, {num(H)}),', '  sections: <String, Rect>{']
    for s, r in L['sections'].items():
        out.append(f'    {dstr(s)}: {rect(r)},')
    out += ['  },', '  elements: <String, LeitorRefElement>{']
    n = 0
    for k, v in L['elements'].items():
        if 'section' not in v:
            continue
        args = [dstr(v['section']), rect(v['abs']), KIND[v['type']]]
        if v.get('vis'):
            args.append(f"visual: {rect(v['vis'])}")
        if v.get('lines'):
            args.append(f"lines: {lines(v['lines'])}")
        if v.get('linesAll'):
            args.append(f"linesAll: {lines(v['linesAll'])}")
        out.append(f'    {dstr(k)}: LeitorRefElement({", ".join(args)}),')
        n += 1
    els = L['elements']
    d = dep.get(p['slug'], {})
    tx = sorted(k for k, f in d.items() if (f['x'] or f['w']) and 'section' in els.get(k, {}))
    ty = sorted(k for k, f in d.items() if (f['y'] or f['h']) and 'section' in els.get(k, {}))
    el = sorted(k for k, v in els.items() if v.get('ellipsis'))
    out += ['  },',
            '  textDependentX: <String>{' + ', '.join(dstr(k) for k in tx) + '},',
            '  textDependentY: <String>{' + ', '.join(dstr(k) for k in ty) + '},',
            '  ellipsized: <String>{' + ', '.join(dstr(k) for k in el) + '},',
            '  knifeEdges: <LeitorKnifeEdge>[']
    for k, info in kni.get(p['slug'], {}).items():
        for r in info['riscos']:
            jo = 'null' if r['estouroComProxima'] is None else num(r['estouroComProxima'])
            # D-280: sobra null = a linha não quebra ao crescer (uma palavra só; caixa do tamanho do texto com espaço)
            sl = 'double.infinity' if r['sobra'] is None else num(r['sobra'])
            out.append(f"    LeitorKnifeEdge({dstr(k)}, {r['linha']}, {dstr(r['texto'])}, {sl}, {jo}),")
    out += ['  ],', ');']
    # R8 (T13): o texto que o app não desenha (o teclado do sistema, o botão da Apple) foi medido como o Chromium o
    # desenha, mas é só informativo; o motivo vem do índice (reserva), copiado no layout pelo build_layout.py.
    inf = {k: v['informativo'] for k, v in els.items() if v.get('informativo') and 'section' in v}
    if inf:
        out += ['', '/// R8 (T13) — medido, mas desenhado pelo sistema, não pelo app (só informativo): id → motivo.',
                f"const Map<String, String> {const_info(p['tela'])} = <String, String>{{"]
        out += [f'  {dstr(k)}: {dstr(m)},' for k, m in inf.items()] + ['};']
    return '\n'.join(out) + '\n', n


def main():
    os.makedirs(OUT, exist_ok=True)
    dep = json.load(open(os.path.join(LAY, 'text_dependency.json'), encoding='utf-8'))
    kni = json.load(open(os.path.join(LAY, 'knife_edges.json'), encoding='utf-8'))
    with open(os.path.join(OUT, 'ref_tipos.dart') if TIPOS_DART == 'ref_tipos.dart' else os.devnull, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(TIPOS))
    if MAPA_DART == 'kRefLeitor':
        titulo = 'do leitor'
    elif CFG.get('formato') == 'dc':  # T13: as telas do projeto (um .dc.html cada)
        titulo = f"do projeto ({CFG['projeto']})"
    else:
        titulo = f"de {os.path.basename(CFG['fonte'])}"
    idx = CAB + [f'// Índice das referências {titulo}: tela → prancha medida.', '// ignore_for_file: lines_longer_than_80_chars',
                 f"import '{TIPOS_DART}';"]
    # T13: com telas no argumento (tela ou slug, por vírgula), gera só essas; o índice lista as telas que já têm a
    # referência na pasta (as etapas medidas antes), na ordem do índice. Sem argumento, todas.
    arg = sys.argv[1] if len(sys.argv) > 1 else 'todas'
    sel = CFG['pranchas'] if arg == 'todas' else [p for p in CFG['pranchas'] if p['tela'] in arg.split(',') or p['slug'] in arg.split(',')]
    if not sel:
        sys.exit(f'prancha desconhecida: {arg}')
    for p in sel:
        src, n = prancha(p, dep, kni)
        with open(os.path.join(OUT, f"reference_layout_{p['slug']}.dart"), 'w', encoding='utf-8', newline='\n') as f:
            f.write(src)
        print(f"{p['slug']:24s} {n:>4d} elementos → reference_layout_{p['slug']}.dart")
    imps, mapa, infos = [], [], []
    for p in CFG['pranchas']:
        arq = os.path.join(OUT, f"reference_layout_{p['slug']}.dart")
        if not os.path.exists(arq):
            continue
        imps.append(f"import 'reference_layout_{p['slug']}.dart';")
        mapa.append(f"  {dstr(p['tela'])}: {const_name(p['tela'])},")
        with open(arq, encoding='utf-8') as f:
            if f"const Map<String, String> {const_info(p['tela'])} " in f.read():
                infos.append(f"  {dstr(p['tela'])}: {const_info(p['tela'])},")
    idx += imps + ['', f"export '{TIPOS_DART}';"] + [i.replace('import', 'export') for i in imps] + [
        '', f'const Map<String, LeitorRefPrancha> {MAPA_DART} = <String, LeitorRefPrancha>{{'] + mapa + ['};']
    if CFG.get('formato') == 'dc':  # R8 (T13): as telas com texto só informativo → o mapa id → motivo de cada uma
        idx += ['', '/// R8 (T13): tela → (id → motivo) do texto desenhado pelo sistema, não pelo app (só informativo).',
                'const Map<String, Map<String, String>> kInformativoProjeto = <String, Map<String, String>>{'
                ] + infos + ['};']
    with open(os.path.join(OUT, INDICE_DART), 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(idx) + '\n')


if __name__ == '__main__':
    main()
