#!/usr/bin/env python3
"""T13.11 (R7) — as classes por área dos SVGs novos (AppIconsBiblioteca, AppIllustrationsEntrada…), geradas do catálogo
do conjunto (`svgCatalogo`, com `areas` e `area` em cada arquivo — D-284). Uma classe por área e categoria (ícones,
ilustrações), com as constantes em camelCase do nome do arquivo (sem o `ic_`/`il_`), o tamanho de uso, a descrição, os
ids das pranchas, as cores dinâmicas e as armadilhas do catálogo; a lista `all` e, nas ilustrações, `withText` (os com
`<text>`, que o AppSvg lê sem os textos). O cabeçalho diz as telas da área e os reusados (D-283) que elas usam, com a
classe de antes de cada um. Roda no Windows (passa o `dart format` no que escreve):
    CONJUNTO=projeto python3 tools/medicao/gen_classes_svg.py [pasta dos tokens]
Os testes de `test/design_system/t13_recursos_projeto_test.dart` conferem pasta = catálogo = classe.
"""
import collections
import glob
import json
import os
import re
import shutil
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from conjunto import C, RAIZ, caminho, indice  # noqa: E402


def _ler(p):
    with open(p, encoding='utf-8') as f:
        return f.read()


TOK = sys.argv[1] if len(sys.argv) > 1 else os.path.join(RAIZ, 'lib', 'core', 'design_system', 'tokens')
TITULOS = {'T14': 'Biblioteca', 'T15': 'Scanner e busca', 'T16': 'Entrada e onboarding',
           'T17': 'Perfil, ajustes, conta, privacidade e notificações', 'T18': 'Cronômetro'}
CATEGORIAS = {'ic': ('AppIcons', 'icons', 'os ícones novos'), 'il': ('AppIllustrations', 'illustrations', 'as ilustrações novas')}
RESERVADAS = {'abstract', 'as', 'assert', 'async', 'await', 'break', 'case', 'catch', 'class', 'const', 'continue',
              'default', 'do', 'else', 'enum', 'export', 'extends', 'false', 'final', 'finally', 'for', 'if', 'in',
              'is', 'new', 'null', 'return', 'super', 'switch', 'this', 'throw', 'true', 'try', 'var', 'void', 'while',
              'with', 'all', 'withText'}
GERADOS = {f'{c[1]}_{a}' for c in CATEGORIAS.values() for a in (C.get('areas') or {}).values()}


def constante(arquivo):
    base = os.path.basename(arquivo)[:-4]
    base = re.sub('^(ic|il)_', '', base)
    partes = base.split('_')
    nome = partes[0] + ''.join(p[:1].upper() + p[1:] for p in partes[1:])
    if not re.fullmatch('[a-z][A-Za-z0-9]*', nome) or nome in RESERVADAS:
        raise SystemExit(f'{arquivo}: constante inválida "{nome}"')
    return nome


def num(v):
    return str(int(v)) if float(v).is_integer() else f'{v:g}'.replace('.', ',')


def tamanho(t):
    w, h = t
    return num(w) if w == h else f'{num(w)}×{num(h)}'


def classes_existentes(todas=False):
    """Caminho → `Classe.constante` nas classes de antes (as que não são geradas aqui); com [todas], também
    nas geradas (o mapa id → widget da T13.12)."""
    achados = {}
    for f in sorted(glob.glob(os.path.join(TOK, 'app_*.dart'))):
        nome = os.path.basename(f)[4:-5]
        if nome in GERADOS and not todas:
            continue
        s = _ler(f)
        for corpo in re.split('abstract final class ', s)[1:]:
            classe = re.match('[A-Za-z0-9_]+', corpo).group(0)
            d = re.search("static const _d = '([^']+)'", corpo)
            # a constante longa o `dart format` quebra depois do "="
            for c, v in re.findall("static const ([A-Za-z0-9_]+) =[ " + chr(10) + chr(13) + "]*'([^']+)'", corpo):
                if c != '_d':
                    achados.setdefault(v.replace('$_d', d.group(1)) if d else v, f'{classe}.{c}')
    return achados


def codigo(texto):
    """As tags (`<text>`, `<svg>`…) entre crases: o dartdoc leria como HTML (unintended_html_in_doc_comment)."""
    return re.sub('(?<!`)(<[A-Za-z/][^<>`]*>)(?!`)', lambda m: '`' + m.group(1) + '`', texto)


def quebra(texto, recuo, largura=120):
    """O texto em linhas de comentário `///` de até `largura` colunas."""
    linhas, atual = [], ''
    for palavra in codigo(texto).split(' '):
        if atual and len(recuo) + 4 + len(atual) + 1 + len(palavra) > largura:
            linhas.append(atual)
            atual = palavra
        else:
            atual = f'{atual} {palavra}' if atual else palavra
    linhas.append(atual)
    return [f'{recuo}/// {l}' for l in linhas]


def main():
    areas = C.get('areas')
    if not areas:
        print('conjunto sem "areas": nada a gerar')
        return
    cat = json.loads(_ler(caminho('svgCatalogo')))
    pranchas = indice()['pranchas']
    ordem = {p['slug']: i for i, p in enumerate(pranchas)}
    area_de = {p['slug']: areas.get(p.get('etapa')) for p in pranchas}
    usos = collections.defaultdict(list)          # arquivo → [(slug, id, uso)]
    for id_, por in cat['usos'].items():
        for slug, u in por.items():
            usos[u['arquivo']].append((slug, id_, u))
    for lst in usos.values():
        lst.sort(key=lambda x: (ordem[x[0]], x[1]))
    antes = classes_existentes()
    escritos = []
    for etapa, area in areas.items():
        telas = sorted((p['tela'] for p in pranchas if p.get('etapa') == etapa),
                       key=lambda t: (int(re.match('[0-9]+', t).group(0)), t))
        for sigla, (prefixo, pasta, rotulo) in CATEGORIAS.items():
            classe = prefixo + area[:1].upper() + area[1:]
            d = f'assets/{pasta}/{area}'
            meus = sorted(a for a, v in cat['arquivos'].items()
                          if v['categoria'] == sigla and not v.get('reuso') and v.get('area') == area)
            reusados = sorted({a for a, v in cat['arquivos'].items() if v.get('reuso') and v['categoria'] == sigla
                               and any(area_de[s] == area for s, _, _ in usos[a])})
            nomes = [constante(a) for a in meus]
            if len(set(nomes)) != len(nomes):
                raise SystemExit(f'{classe}: constantes repetidas')
            cab = (f'T13.11 (R7) — {rotulo} da {etapa} · {TITULOS[etapa]} (telas {", ".join(telas)}), em `{d}/` '
                   f'(D-284: a pasta da área da 1ª etapa que usa o desenho). Gerado por `tools/medicao/gen_classes_svg.py` '
                   f'do catálogo `{C["svgCatalogo"]}` — não editar à mão. As cores já estão nos SVGs (cada variante de '
                   f'cor é um arquivo); o tamanho de uso entre parênteses, depois a descrição e os ids das pranchas.')
            if reusados:
                cab += (' Os reusados (D-283: o mesmo desenho de um asset que já existia) continuam nas classes de antes: '
                        + '; '.join(f'`{antes.get(a, a)}`' for a in reusados) + '.')
            if not meus:
                cab += ' Esta área não tem desenho novo nesta categoria: a classe existe para a convenção (R7).'
            out = [l.replace('///', '//', 1) for l in quebra(cab, '')]
            out.append(f'abstract final class {classe} {{')
            if meus:
                out.append(f"  static const _d = '{d}';")
            com_texto = []
            for a, nome in zip(meus, nomes):
                lst = usos[a]
                tams = list(dict.fromkeys(tamanho(u['tamanho']) + (f", atributos {tamanho(u['atributos'])}" if u.get('atributos') else '')
                                          for _, _, u in lst))
                ids = list(dict.fromkeys(id_ for _, id_, _ in lst))
                ids_txt = ', '.join(f'`{i}`' for i in ids[:3]) + (f' e mais {len(ids) - 3}' if len(ids) > 3 else '')
                desc = cat['arquivos'][a].get('descricao', '').rstrip('.')
                texto = f'({"; ".join(tams)}) {desc[:1].upper() + desc[1:]} ({ids_txt}).'
                din = {}
                for _, _, u in lst:
                    din.update(u.get('coresDinamicas') or {})
                if din:
                    texto += ' Cor dinâmica: ' + ', '.join(f'{c} = prop "{p}"' for c, p in din.items()) + '.'
                arms = list(dict.fromkeys((id_, u['armadilha']) for _, id_, u in lst if u.get('armadilha')))
                if arms and len({t for _, t in arms}) == 1 and len(arms) == len(ids):
                    texto += f' Armadilha: {arms[0][1]}'
                else:
                    for id_, t in arms:
                        texto += f' Armadilha em `{id_}`: {t}'
                out.append('')
                out.extend(quebra(texto, '  '))
                out.append(f"  static const {nome} = '$_d/{os.path.basename(a)}';")
                if '<text' in _ler(os.path.join(RAIZ, a)):
                    com_texto.append(nome)
            out.append('')
            out.append('  static const all = <String>[' + ', '.join(nomes) + (',' if nomes else '') + '];')
            if sigla == 'il':
                out.append('')
                out.extend(quebra('Os desenhos com `<text>`: o `AppSvg` os lê sem os textos (`svgWithoutText`) e os textos '
                                  'voltam em `AppText` (ou num pintor, os de `<textPath>`) — armadilhas no catálogo.', '  '))
                out.append('  static const Set<String> withText = <String>{' + ', '.join(com_texto)
                           + (',' if com_texto else '') + '};')
            out.append('}')
            caminho_dart = os.path.join(TOK, f'app_{pasta}_{area}.dart')
            with open(caminho_dart, 'w', encoding='utf-8', newline=chr(10)) as f:
                f.write(chr(10).join(out) + chr(10))
            escritos.append(caminho_dart)
            print(f'{classe:32s} {len(meus):3d} arquivos, {len(com_texto)} com <text>, {len(reusados)} reusados')
    dart = shutil.which('dart')
    if dart:
        subprocess.run([dart, 'format', *escritos], check=True, capture_output=True)
    else:
        print('aviso: sem o dart no PATH — rode `dart format` nos arquivos gerados')


if __name__ == '__main__':
    main()
