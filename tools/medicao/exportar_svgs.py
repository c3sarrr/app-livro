#!/usr/bin/env python3
"""G01.8 — exporta os <svg> das 13 pranchas (tools/medicao/tmp/svgs.json, de svgs.js) como arquivos, com as
cores aplicadas (currentColor resolvido, props no valor padrão), sem duplicatas:
  assets/icons/leitor/ic_*.svg                 ícones de interface (como os da v1: cores já no SVG)
  assets/illustrations/leitor/il_*.svg         ilustrações (prateleira de ferramentas, pontas, prévia, dica)
  handoff_v2/referencia/svg_tinta/*.svg        tinta da fixture (traços à mão, elipse, ondulado, nota à mão):
                                               dado do "mundo de referência", não asset do app (D-34)
  handoff_v2/referencia/svg_graficos/*.svg     formas que o app desenha com CustomPainter (onda do
                                               preenchimento da barra, anel de progresso do capítulo)
  handoff_v2/referencia/svg_catalogo.json      id → arquivo, tamanho de uso, cores dinâmicas, armadilhas
Variantes de cor do mesmo desenho viram arquivos com sufixo (ex.: _noite). Cores que vêm de props do
componente ({{brand}}, {{ink}}) ficam no valor padrão e são listadas em `coresDinamicas` no catálogo.
Uso: [CONJUNTO=inicio2] python3 tools/medicao/exportar_svgs.py
T02: as pastas vêm do conjunto (conjuntos.json); com svgNomes, as tabelas abaixo (as do leitor) dão lugar às do
módulo indicado, com as OPCOES dele (reuso de asset existente, ids normalizados, altura em %, tamanho do layout).
T13.11 (R7): com `areas` no conjunto (etapa → pasta), os ícones e as ilustrações novos ficam na pasta da área da 1ª
etapa que os usa (D-284: assets/icons/<área>/, assets/illustrations/<área>/) e o catálogo diz a área de cada arquivo;
com OPCOES["desenho"] (D-283) os grupos e o reuso são pelo desenho — C14N sem o width/height da raiz, com os ids
internos renumerados e sem o stroke-linejoin quando nenhum traço tem junta; um id de variante em NOMES dá o nome
dela; OPCOES["nomesUnicos"] recusa arquivo novo com nome de arquivo existente; OPCOES["limparAntigos"] apaga os
arquivos que a rodada anterior gravou e esta não grava mais. SECO=1: só mostra o plano (nada é gravado).
OPCOES["armadilhaPorUso"]: um uso com entrada própria em ARMADILHAS usa a dele (a capa reusada noutra caixa, com a
escala daquela caixa); NOTAS_USO (do módulo) junta a nota de um uso só (o ícone encolhido pelo flex);
OPCOES["atributos"]: o uso guarda também o width/height do <svg> (o tamanho do arquivo) quando o layout é outro.
OPCOES["idTracejado"] (T13.11, D-285): no arquivo novo, o elemento com stroke-dasharray ganha id="tracejado" quando
outro elemento de mesmo nome tem traço — o registro de tracejados do app (`svgDashes`) esconde o traço pelo nome do
elemento e, com o id, só o dele; um tracejado por arquivo. O id não entra na chave do desenho (é uma marca do
registro, não do desenho).
"""
import collections
import glob
import importlib
import json
import os
import re
import sys
import xml.etree.ElementTree as ET

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from conjunto import C, caminho, indice  # noqa: E402

AQUI = os.path.dirname(__file__)
RAIZ = os.path.abspath(os.path.join(AQUI, '..', '..'))
COL = re.compile(r'#[0-9A-Fa-f]{6}\b|rgba?\([^)]*\)')
IDS_DC = re.compile(r'\b\w+-dc-(\w+)')   # ids internos do arquivo (home-dc-iris) → dc-iris

DEST = {cat: tuple(C[chave].split('/')) for cat, chave in (('ic', 'icones'), ('il', 'ilustracoes'),
                                                          ('tinta', 'svgTinta'), ('graf', 'svgGraficos')) if chave in C}
AREAS = C.get('areas') or {}             # T13.11: etapa → pasta da área (os ícones e as ilustrações novos)
SECO = bool(os.environ.get('SECO'))
# primeiro id de cada desenho → (destino, nome-base). O sufixo de variante vem de VARIANTE (cor distintiva).
NOMES = {
    'r20.topIsland.close.icon': ('ic', 'ic_arrow_left'),
    'r20.topIsland.search.icon': ('ic', 'ic_search'),
    'r20.topIsland.bookmark.icon': ('ic', 'ic_ribbon_marked'),
    'r20.bottomIsland.scrubber.fill.wave': ('graf', 'onda_preenchimento_barra'),
    'r20.bottomIsland.tools.theme.icon': ('ic', 'ic_sun'),
    'r20.bottomIsland.tools.theme.icon@26b_tema_noite': ('ic', 'ic_moon'),   # mesmo id na 26b, outro desenho
    'r20.bottomIsland.tools.notes.icon': ('ic', 'ic_highlighter_reader'),
    'r20.bottomIsland.tools.annotate.icon': ('ic', 'ic_annotate'),
    'r20.bottomIsland.tools.toc.icon': ('ic', 'ic_toc'),
    'r20.timeChip.icon': ('ic', 'ic_timer'),
    'r21.toolbar.colors.other.icon': ('ic', 'ic_plus_tiny'),
    'r21.toolbar.colors.underline.icon': ('ic', 'ic_underline'),
    'r21.toolbar.actions.note.icon': ('ic', 'ic_note'),
    'r21.toolbar.actions.copy.icon': ('ic', 'ic_copy'),
    'r21.toolbar.actions.share.icon': ('ic', 'ic_share'),
    'ann.page.text.handHighlight.stroke': ('tinta', 'grifo_mao_livre_capitu'),
    'ann.page.text.circled.ellipse': ('tinta', 'elipse_olhos_de_ressaca'),
    'ann.page.text.circled.flourish': ('tinta', 'risco_sobre_olhos_de_ressaca'),
    'ann.page.text.wavy.wave': ('tinta', 'ondulado_fluido_misterioso'),
    'ann.modePill.icon': ('ic', 'ic_pencil'),
    'ann.done.icon': ('ic', 'ic_check'),
    'ann.toolShelf.pen.art': ('il', 'il_ferramenta_caneta_ativa'),
    'ann.toolShelf.marker.art': ('il', 'il_ferramenta_marcatexto'),
    'ann.toolShelf.eraser.art': ('il', 'il_ferramenta_borracha'),
    'ann.toolShelf.lasso.art': ('il', 'il_ferramenta_laco'),
    'ann.toolShelf.line.art': ('il', 'il_ferramenta_reta'),
    'ann.toolShelf.space.art': ('il', 'il_ferramenta_espaco'),
    'ann.island.undo.icon': ('ic', 'ic_undo'),
    'ann.island.redo.icon': ('ic', 'ic_redo'),
    'pen.penPanel.close.icon': ('ic', 'ic_close'),
    'pen.penPanel.preview.art': ('il', 'il_previa_traco_caneta'),
    'pen.penPanel.tips.ballpoint.sample': ('il', 'il_ponta_esferografica'),
    'pen.penPanel.tips.fountain.sample': ('il', 'il_ponta_tinteiro'),
    'pen.penPanel.tips.brush.sample': ('il', 'il_ponta_pincel'),
    'pen.penPanel.favorites.add.icon': ('ic', 'ic_plus'),
    'mk.markerPanel.tip.icon': ('il', 'il_dica_gruda_nas_palavras'),
    'sp.page.spaceOpener.trail': ('tinta', 'rastro_arrasto_espaco'),
    'sp.page.spaceOpener.sizeChip.icon': ('ic', 'ic_arrows_vertical'),
    'sp.toolShelf.pen.art': ('il', 'il_ferramenta_caneta'),
    'sp.toolShelf.space.art': ('il', 'il_ferramenta_espaco_ativa'),
    'hn.page.handNote.tag.icon': ('ic', 'ic_pencil_bold'),
    'hn.page.handNote.actions.collapse.icon': ('ic', 'ic_chevron_up'),
    'hn.page.handNote.actions.delete.icon': ('ic', 'ic_trash'),
    'hn.page.handNote.ink': ('tinta', 'nota_mao_ressaca'),
    'hl.sparkle': ('ic', 'ic_star_deco'),
    'hl.filters.clubOnly.icon': ('ic', 'ic_people'),
    'hl.list.card1.head.more.icon': ('ic', 'ic_more_dots'),
    'hl.list.card5.body.club.chip.icon': ('ic', 'ic_people_chip'),
    'hl.list.sep6.label.icon': ('ic', 'ic_ribbon'),
    'hl.list.card7.body.quote.ink.ellipse': ('tinta', 'miniatura_elipse_olhos_de_ressaca'),
    'hl.list.card7.body.handNote.tag.icon': ('ic', 'ic_pencil_heavy'),
    'hl.list.card7.body.handNote.ink': ('tinta', 'miniatura_nota_mao_ressaca'),
    'hl.list.card8.body.quote.ink1.wave': ('tinta', 'miniatura_ondulado_fluido_misterioso'),
    'rs.sheet.close.icon': ('ic', 'ic_close_round'),
    'rs.sheet.papers.cream.check.icon': ('ic', 'ic_check_small'),
    'rs.sheet.spacing.tight.icon': ('ic', 'ic_spacing_tight'),
    'rs.sheet.spacing.medium.icon': ('ic', 'ic_spacing_medium'),
    'rs.sheet.spacing.loose.icon': ('ic', 'ic_spacing_loose'),
    'rs.sheet.margins.narrow.icon': ('ic', 'ic_margins_narrow'),
    'rs.sheet.margins.medium.icon': ('ic', 'ic_margins_medium'),
    'rs.sheet.margins.wide.icon': ('ic', 'ic_margins_wide'),
    'toc.sheet.club.flag.icon': ('ic', 'ic_flag'),
    'toc.sheet.club.arrow.icon': ('ic', 'ic_chevron_right'),
    'toc.sheet.chapters.ch25.read.icon': ('ic', 'ic_check_read'),
    'toc.sheet.chapters.ch32.progressRing': ('graf', 'anel_progresso_capitulo'),
    'toc.sheet.chapters.ch32.youAreHere.icon': ('ic', 'ic_ribbon_tiny'),
    'toc.sheet.chapters.ch32.marks.handwritten.icon': ('ic', 'ic_pencil_coral'),
}
VARIANTE = {'#EDE3D1': 'noite', '#6F665B': 'cinza', '#FF552E': 'coral', '#FED170': 'amarelo', '#FFFAF1': 'contorno'}
# props do componente com cor no SVG (conferido no template: {{brand}} / {{ink}} dentro do <svg>)
DINAMICAS = {'r20.bottomIsland.scrubber.fill.wave': {'#B6ACE4': 'brand'},
             'ann.page.text.circled.ellipse': {'#FF552E': 'ink'}, 'ann.page.text.circled.flourish': {'#FF552E': 'ink'},
             'ann.page.text.wavy.wave': {'#FF552E': 'ink'},
             'ann.toolShelf.pen.art': {'#B6ACE4': 'brand', '#FF552E': 'ink'},
             'pen.toolShelf.pen.art': {'#B6ACE4': 'brand'}, 'mk.toolShelf.pen.art': {'#B6ACE4': 'brand'},
             'hn.toolShelf.pen.art': {'#B6ACE4': 'brand'}, 'sp.toolShelf.space.art': {'#B6ACE4': 'brand'},
             'r20.bottomIsland.scrubber.fill.wave#26b': {'#B6ACE4': 'brand'}}
ARMADILHAS = {
    'r20.bottomIsland.scrubber.fill.wave': 'preserveAspectRatio="none" + vector-effect="non-scaling-stroke" (o flutter_svg ignora o vector-effect): desenhar com CustomPainter esticando a forma na altura do trilho e traço fixo de 1,5.',
    'ann.page.text.circled.ellipse': 'vector-effect="non-scaling-stroke" e preserveAspectRatio="none" (esticado sobre o trecho): na app é tinta (traços salvos), não asset.',
    'r21.toolbar.colors.underline.icon': 'tem <text> ("a" em Literata 13): o flutter_svg desenha texto com a fonte do sistema → desenhar o "a" com AppText (Literata13 não existe: usar a variável com opsz 13) por cima do traço ondulado.',
    'toc.sheet.chapters.ch32.progressRing': 'stroke-dasharray/dashoffset = progresso no capítulo (44 de perímetro, offset 26 → 41 %): anel desenhado por CustomPainter com o valor real.',
    'hn.page.handNote.ink': 'width="100%" (largura da caixa) e rótulo role=img com o texto escrito (D-31: no app o rótulo é genérico).',
    'hl.list.card7.body.handNote.ink': 'width="100%"; miniatura da nota à mão (no app: renderizada a partir dos traços salvos, com cache em imagem).',
    'pen.penPanel.preview.art': 'width="100%": a prévia ocupa a largura da faixa pautada; no app é desenhada com a ponta/espessura/cor atuais.',
}
DOC = None
OPCOES, NOTAS_USO = {}, {}
if C.get('svgNomes'):
    _m = importlib.import_module(C['svgNomes'])
    NOMES, VARIANTE, DINAMICAS, ARMADILHAS, DOC, OPCOES = _m.NOMES, _m.VARIANTE, _m.DINAMICAS, _m.ARMADILHAS, _m.DOC, _m.OPCOES
    NOTAS_USO = getattr(_m, 'NOTAS_USO', {})


def svg_arquivo(v):
    s = v['svg'].replace('currentColor', v['color_hex'])
    if OPCOES.get('normalizarIds'):
        s = IDS_DC.sub(r'dc-\1', s)
    # width="100%" (largura da caixa no arquivo) → largura medida: o flutter_svg não resolve porcentagem
    s = re.sub(r'(<svg[^>]*?)\swidth="100%"', lambda m: f'{m.group(1)} width="{round(v["w"], 2):g}"', s, count=1)
    if OPCOES.get('alturaPercentual'):
        s = re.sub(r'(<svg[^>]*?)\sheight="100%"', lambda m: f'{m.group(1)} height="{round(v["h"], 2):g}"', s, count=1)
    s = re.sub(r'\saria-label="[^"]*"|\srole="[^"]*"', '', s)
    if 'xmlns=' not in s:
        s = s.replace('<svg', '<svg xmlns="http://www.w3.org/2000/svg"', 1)
    return re.sub(r'>\s+<', '><', s).strip() + '\n'


def atributos(v):
    """O width/height numéricos da raiz do <svg> (o tamanho do arquivo), ou None (porcentagem, sem atributo)."""
    raiz = re.match('<svg[^>]*>', v['svg']).group(0)
    w, h = re.search(' width="([0-9.]+)"', raiz), re.search(' height="([0-9.]+)"', raiz)
    return [round(float(w.group(1)), 2), round(float(h.group(1)), 2)] if w and h else None


def rgb_hex(c):
    m = re.match(r'rgba?\((\d+), (\d+), (\d+)', c)
    return '#%02X%02X%02X' % tuple(int(x) for x in m.groups()) if m else c


def canonico(s):
    return ET.canonicalize(IDS_DC.sub(r'dc-\1', s), strip_text=True)


# ── T13.11 (D-283): o desenho ────────────────────────────────────────────────────────────────────────────────────────
_ID = re.compile(r'\sid="([^"]+)"')
_CMD = re.compile(r'[MmLlHhVvCcSsQqTtAaZz]')
_NUM = re.compile(r'-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?')
_ARGS = {'L': 2, 'H': 1, 'V': 1, 'C': 6, 'S': 4, 'Q': 4, 'T': 2, 'A': 7}


def sem_tamanho(s):
    """Sem o width/height da raiz (o tamanho de uso fica no catálogo)."""
    raiz = re.match(r'<svg\b[^>]*>', s).group(0)
    return re.sub(r'\s(width|height)="[^"]*"', '', raiz) + s[len(raiz):]


def renumerar_ids(s):
    """Os ids internos → d1, d2… na ordem em que aparecem, com as referências (href="#…", url(#…))."""
    for n, velho in enumerate(dict.fromkeys(_ID.findall(s)), 1):
        e = re.escape(velho)
        s = re.sub(rf'(\sid="){e}"', rf'\g<1>d{n}"', s)
        s = re.sub(rf'(href="#){e}"', rf'\g<1>d{n}"', s)
        s = re.sub(rf'url\(#{e}\)', f'url(#d{n})', s)
    return s


def sem_juntas(s):
    """Nenhum traço com junta (o stroke-linejoin não muda nada): sem <polyline>/<polygon>/<rect> e cada subcaminho
    de cada <path> com um segmento só (o "+", o "×", a lupa); fechar (z) ou dois segmentos seguidos têm junta."""
    if re.search(r'<(polyline|polygon|rect)\b', s):
        return False
    for d in re.findall(r'\sd="([^"]*)"', s):
        for sub in re.split(r'(?=[Mm])', d):
            partes = re.findall(r'([MmLlHhVvCcSsQqTtAaZz])([^MmLlHhVvCcSsQqTtAaZz]*)', sub)
            if not partes:
                continue
            (m, m_args), resto = partes[0], partes[1:]
            n_m = len(_NUM.findall(m_args))
            segmentos = (n_m - 2) // 2 if n_m > 2 else 0       # pares depois do moveto = linetos implícitos
            for c, args in resto:
                if c in 'Zz':
                    return False
                segmentos += max(1, len(_NUM.findall(args)) // _ARGS[c.upper()])
            if segmentos > 1:
                return False
    return True


def desenho(s):
    """A chave do desenho (D-283): C14N sem o tamanho da raiz, ids renumerados, sem linejoin quando não há junta; sem
    a marca id="tracejado" (D-285)."""
    s = renumerar_ids(sem_tamanho(s.replace(' id="tracejado"', '')))
    if sem_juntas(s):
        s = re.sub(r'\sstroke-linejoin="[^"]*"', '', s)
    return ET.canonicalize(s, strip_text=True)


def id_tracejado(s, rel):
    """T13.11 (D-285): o elemento tracejado do arquivo novo com id="tracejado" quando outro elemento de mesmo nome tem
    traço (o registro do app esconde o traço só dele; sozinho, basta o nome — a mira). Um por arquivo, fora da raiz e
    sem id próprio; senão, recusa."""
    achados = re.findall('<[a-z]+ [^<>]*stroke-dasharray=', s)
    if not achados:
        return s
    tag = achados[0][1:].split(' ')[0]
    if len(achados) == 1 and len(re.findall(f'<{tag} [^<>]*stroke=', s)) == 1:
        return s
    if len(achados) > 1 or achados[0].startswith('<svg') or ' id="' in achados[0]:
        raise SystemExit(f'{rel}: {len(achados)} elemento(s) tracejado(s), na raiz ou com id — o registro quer um só')
    return s.replace(achados[0], achados[0].replace(' ', ' id="tracejado" ', 1), 1)


def chave_desenho(s):
    return desenho(s) if OPCOES.get('desenho') else canonico(s)


def pastas_proprias():
    """As pastas de ícones e ilustrações que este conjunto grava (as áreas, com `areas`)."""
    if AREAS:
        return {'/'.join(DEST[c] + (a,)) + '/' for c in ('ic', 'il') for a in AREAS.values()}
    return {'/'.join(DEST['ic']) + '/', '/'.join(DEST['il']) + '/'}


def assets_existentes():
    """chave → caminho relativo dos SVGs de assets/icons e assets/illustrations, fora das pastas deste conjunto."""
    proprias = pastas_proprias()
    achados = {}
    for f in sorted(glob.glob(os.path.join(RAIZ, 'assets', 'icons', '**', '*.svg'), recursive=True)
                    + glob.glob(os.path.join(RAIZ, 'assets', 'illustrations', '**', '*.svg'), recursive=True)):
        rel = os.path.relpath(f, RAIZ).replace(os.sep, '/')
        if any(rel.startswith(p) for p in proprias):
            continue
        achados.setdefault(chave_desenho(open(f, encoding='utf-8').read()), rel)
    return achados


def nomes_existentes():
    """Os nomes dos SVGs de assets/icons e assets/illustrations fora das pastas deste conjunto (nomesUnicos)."""
    proprias = pastas_proprias()
    return {os.path.basename(f) for f in glob.glob(os.path.join(RAIZ, 'assets', '*', '**', '*.svg'), recursive=True)
            if not any(os.path.relpath(f, RAIZ).replace(os.sep, '/').startswith(p) for p in proprias)}


def main():
    S = json.load(open(caminho('tmp', 'svgs.json'), encoding='utf-8'))
    existentes = assets_existentes() if OPCOES.get('reusar') else {}
    grupos = collections.OrderedDict()   # forma (sem cor) → [(id, prancha, v)]
    for slug, d in S.items():
        lay = json.load(open(caminho('layout', f'layout_{slug}.json'), encoding='utf-8'))['elements'] \
            if OPCOES.get('tamanhoLayout') else {}
        for k, v in d.items():
            v['color_hex'] = rgb_hex(v['color'])
            if k in lay:
                v['w'], v['h'] = lay[k]['abs'][2], lay[k]['abs'][3]
            svg = IDS_DC.sub(r'dc-\1', v['svg']) if OPCOES.get('normalizarIds') else v['svg']
            if OPCOES.get('desenho'):
                limpo = re.sub(r' (aria-label|role)="[^"]*"', '', v['svg'].replace('currentColor', 'C'))
                forma = COL.sub('C', desenho(limpo))
            else:
                forma = COL.sub('C', re.sub(r'\s(width|height)="[^"]*"', '', svg.replace('currentColor', 'C')))
            grupos.setdefault(forma, []).append((k, slug, v))
    for d in DEST.values():
        os.makedirs(os.path.join(RAIZ, *d), exist_ok=True)
    etapa = {p['slug']: p.get('etapa') for p in indice()['pranchas']} if AREAS else {}
    nomes_fora = nomes_existentes() if OPCOES.get('nomesUnicos') else set()
    catalogo, arquivos, faltam, plano = {}, {}, [], []
    for forma, itens in grupos.items():
        k0, slug0 = itens[0][0], itens[0][1]
        chave_nome = f'{k0}@{slug0}' if f'{k0}@{slug0}' in NOMES else k0
        if chave_nome not in NOMES:
            faltam.append(k0)
            continue
        cat, base = NOMES[chave_nome][:2]
        por_cor = collections.OrderedDict()
        for k, slug, v in itens:
            cores = tuple(sorted(set(COL.findall(v['svg'].replace('currentColor', v['color_hex'])))))
            por_cor.setdefault(cores, []).append((k, slug, v))
        todas = [set(c) for c in por_cor]
        comuns = set.intersection(*todas) if todas else set()
        for i, (cores, lst) in enumerate(por_cor.items()):
            nome = base
            if i > 0:
                dist = [c for c in cores if c not in comuns and c in VARIANTE]
                nome = f"{base}_{VARIANTE[dist[0]] if dist else i + 1}"
                if lst[0][0] in NOMES:              # T13.11: o nome dado à variante (a tinta de um desenho colorido)
                    nome = NOMES[lst[0][0]][1]
            k, slug, v = lst[0]
            # D-284: os ícones e as ilustrações novos na pasta da área da 1ª etapa que usa esta variante
            pasta = DEST[cat] + ((AREAS[etapa[slug]],) if AREAS and cat in ('ic', 'il') else ())
            rel = '/'.join(pasta) + f'/{nome}.svg'
            conteudo = svg_arquivo(v)
            reuso = existentes.get(chave_desenho(conteudo)) if cat in ('ic', 'il') else None
            rel = reuso or rel
            if rel in arquivos:
                raise SystemExit(f'nome repetido: {rel}')
            if not reuso and cat in ('ic', 'il') and f'{nome}.svg' in nomes_fora:
                raise SystemExit(f'{rel}: o nome já existe noutra pasta de assets (nomesUnicos)')
            if not reuso and OPCOES.get('idTracejado') and cat in ('ic', 'il'):
                conteudo = id_tracejado(conteudo, rel)
            if not reuso and not SECO:
                os.makedirs(os.path.join(RAIZ, *pasta), exist_ok=True)
                with open(os.path.join(RAIZ, *pasta, f'{nome}.svg'), 'w', encoding='utf-8', newline='\n') as f:
                    f.write(conteudo)
            desc = (NOMES.get(k) or NOMES[chave_nome])[2:3]
            arquivos[rel] = {'categoria': cat, 'cores': list(cores), 'usos': len(lst), **({'reuso': True} if reuso else {}),
                             **({'area': pasta[-1]} if AREAS and cat in ('ic', 'il') and not reuso else {}),
                             **({'descricao': desc[0]} if desc else {})}
            plano.append(f"{'reuso ' if reuso else ''}{rel}  ({len(lst)} usos; {k}@{slug})")
            for k, slug, v in lst:
                arm = ARMADILHAS.get(k) if OPCOES.get('armadilhaPorUso') and k in ARMADILHAS else ARMADILHAS.get(k0)
                arm = ' '.join(a for a in (arm, NOTAS_USO.get(k)) if a)
                tam = [round(v['w'], 2), round(v['h'], 2)]
                attr = atributos(v) if OPCOES.get('atributos') else None
                catalogo.setdefault(k, {})[slug] = {'arquivo': rel, 'tamanho': tam,
                                                    **({'atributos': attr} if attr and attr != tam else {}),
                                                    **({'coresDinamicas': DINAMICAS[k]} if k in DINAMICAS else {}),
                                                    **({'armadilha': arm} if arm else {}),
                                                    **({'rotulo': v['aria']} if v.get('aria') else {})}
    if faltam:
        raise SystemExit(f'desenhos sem nome em NOMES: {faltam}')
    if SECO:
        print('\n'.join(plano))
        print(f'{len(arquivos)} arquivos de {len(grupos)} desenhos (seco: nada gravado)')
        return
    if OPCOES.get('limparAntigos') and os.path.exists(caminho('svgCatalogo')):
        # os arquivos que a rodada anterior gravou e esta não grava mais (um nome trocado, um desenho que virou reuso)
        antes = json.load(open(caminho('svgCatalogo'), encoding='utf-8'))['arquivos']
        for rel, a in antes.items():
            if not a.get('reuso') and rel not in arquivos and os.path.exists(os.path.join(RAIZ, rel)):
                os.remove(os.path.join(RAIZ, rel))
    with open(caminho('svgCatalogo'), 'w', encoding='utf-8', newline='\n') as f:
        json.dump({'_doc': DOC or __doc__.strip().splitlines()[0], 'arquivos': dict(sorted(arquivos.items())),
                   'usos': dict(sorted(catalogo.items()))}, f, ensure_ascii=False, indent=1)
        f.write('\n')
    por_cat = collections.Counter(a['categoria'] for a in arquivos.values())
    print(f'{len(arquivos)} arquivos de {len(grupos)} desenhos ({sum(len(i) for i in grupos.values())} usos): {dict(por_cat)}')


if __name__ == '__main__':
    main()
