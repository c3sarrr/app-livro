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
Uso: python3 tools/medicao/exportar_svgs.py
"""
import collections
import json
import os
import re

AQUI = os.path.dirname(__file__)
RAIZ = os.path.abspath(os.path.join(AQUI, '..', '..'))
COL = re.compile(r'#[0-9A-Fa-f]{6}\b|rgba?\([^)]*\)')

DEST = {'ic': ('assets', 'icons', 'leitor'), 'il': ('assets', 'illustrations', 'leitor'),
        'tinta': ('handoff_v2', 'referencia', 'svg_tinta'), 'graf': ('handoff_v2', 'referencia', 'svg_graficos')}
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


def svg_arquivo(v):
    s = v['svg'].replace('currentColor', v['color_hex'])
    # width="100%" (largura da caixa no arquivo) → largura medida: o flutter_svg não resolve porcentagem
    s = re.sub(r'(<svg[^>]*?)\swidth="100%"', lambda m: f'{m.group(1)} width="{round(v["w"], 2):g}"', s, count=1)
    s = re.sub(r'\saria-label="[^"]*"|\srole="[^"]*"', '', s)
    if 'xmlns=' not in s:
        s = s.replace('<svg', '<svg xmlns="http://www.w3.org/2000/svg"', 1)
    return re.sub(r'>\s+<', '><', s).strip() + '\n'


def rgb_hex(c):
    m = re.match(r'rgba?\((\d+), (\d+), (\d+)', c)
    return '#%02X%02X%02X' % tuple(int(x) for x in m.groups()) if m else c


def main():
    S = json.load(open(os.path.join(AQUI, 'tmp', 'svgs.json'), encoding='utf-8'))
    grupos = collections.OrderedDict()   # forma (sem cor) → [(id, prancha, v)]
    for slug, d in S.items():
        for k, v in d.items():
            v['color_hex'] = rgb_hex(v['color'])
            forma = COL.sub('C', re.sub(r'\s(width|height)="[^"]*"', '', v['svg'].replace('currentColor', 'C')))
            grupos.setdefault(forma, []).append((k, slug, v))
    for d in DEST.values():
        os.makedirs(os.path.join(RAIZ, *d), exist_ok=True)
    catalogo, arquivos, faltam = {}, {}, []
    for forma, itens in grupos.items():
        k0, slug0 = itens[0][0], itens[0][1]
        chave = f'{k0}@{slug0}' if f'{k0}@{slug0}' in NOMES else k0
        if chave not in NOMES:
            faltam.append(k0)
            continue
        cat, base = NOMES[chave]
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
            rel = '/'.join(DEST[cat]) + f'/{nome}.svg'
            if rel in arquivos:
                raise SystemExit(f'nome repetido: {rel}')
            k, slug, v = lst[0]
            conteudo = svg_arquivo(v)
            path = os.path.join(RAIZ, *DEST[cat], f'{nome}.svg')
            with open(path, 'w', encoding='utf-8', newline='\n') as f:
                f.write(conteudo)
            arquivos[rel] = {'categoria': cat, 'cores': list(cores), 'usos': len(lst)}
            for k, slug, v in lst:
                catalogo.setdefault(k, {})[slug] = {'arquivo': rel, 'tamanho': [round(v['w'], 2), round(v['h'], 2)],
                                                    **({'coresDinamicas': DINAMICAS[k]} if k in DINAMICAS else {}),
                                                    **({'armadilha': ARMADILHAS[k0]} if k0 in ARMADILHAS else {}),
                                                    **({'rotulo': v['aria']} if v.get('aria') else {})}
    if faltam:
        raise SystemExit(f'desenhos sem nome em NOMES: {faltam}')
    with open(os.path.join(RAIZ, 'handoff_v2', 'referencia', 'svg_catalogo.json'), 'w', encoding='utf-8', newline='\n') as f:
        json.dump({'_doc': __doc__.strip().splitlines()[0], 'arquivos': dict(sorted(arquivos.items())),
                   'usos': dict(sorted(catalogo.items()))}, f, ensure_ascii=False, indent=1)
        f.write('\n')
    por_cat = collections.Counter(a['categoria'] for a in arquivos.values())
    print(f'{len(arquivos)} arquivos de {len(grupos)} desenhos ({sum(len(i) for i in grupos.values())} usos): {dict(por_cat)}')


if __name__ == '__main__':
    main()
