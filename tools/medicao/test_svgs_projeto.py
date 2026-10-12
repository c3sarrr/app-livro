#!/usr/bin/env python3
"""T13.11 (R7) — testes das regras novas dos SVGs do projeto: a chave do desenho (D-283), o catálogo (a armadilha por
uso, as notas de um uso só, o desenho fora da caixa, os atributos e a pasta da área — D-284), os recortes @3x e o
gerador das classes por área.

Rodar da raiz do repositório no Windows (o gerador das classes passa o `dart format`):
  PYTHONIOENCODING=utf-8 python3 -m unittest tools/medicao/test_svgs_projeto.py -v
"""
import glob
import json
import os
import shutil
import sys
import tempfile
import unittest

os.environ['CONJUNTO'] = 'projeto'
AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
from PIL import Image  # noqa: E402

import exportar_svgs as ex  # noqa: E402
import gen_classes_svg as gen  # noqa: E402
import recortes_elementos as rec  # noqa: E402
from conjunto import C, RAIZ, caminho, indice  # noqa: E402

PASTAS = [f'assets/{t}/{a}' for t in ('icons', 'illustrations') for a in C['areas'].values()]
CAT = json.load(open(caminho('svgCatalogo'), encoding='utf-8'))
PR = {p['slug']: p for p in indice()['pranchas']}


def svg(corpo, extra=''):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"{extra}>{corpo}</svg>'


class Desenho(unittest.TestCase):
    """D-283: o mesmo desenho com outro tamanho, outros ids ou um linejoin que não muda nada tem a mesma chave."""

    def test_sem_tamanho_tira_so_o_da_raiz(self):
        s = ex.sem_tamanho(svg('<rect width="5" height="6"/>'))
        self.assertNotIn('width="20"', s)
        self.assertNotIn('height="20"', s)
        self.assertIn('<rect width="5" height="6"/>', s)

    def test_renumera_os_ids_e_as_referencias(self):
        s = ex.renumerar_ids(svg('<defs><path id="anel-x" d="M0 0"/><linearGradient id="g9"/></defs>'
                                 '<text><textPath href="#anel-x">A</textPath></text><rect fill="url(#g9)"/>'))
        for esperado in ('id="d1"', 'href="#d1"', 'id="d2"', 'url(#d2)'):
            self.assertIn(esperado, s)
        self.assertNotIn('anel-x', s)
        self.assertNotIn('g9', s)

    def test_traco_sem_junta(self):
        self.assertTrue(ex.sem_juntas(svg('<path d="M5 12h14M12 5v14"/>')))                  # o "+"
        self.assertTrue(ex.sem_juntas(svg('<circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/>')))  # a lupa
        self.assertFalse(ex.sem_juntas(svg('<path d="m9 6 6 6-6 6"/>')))                      # o chevron: 2 segmentos
        self.assertFalse(ex.sem_juntas(svg('<path d="M0 0L5 5Z"/>')))                         # fechado
        self.assertFalse(ex.sem_juntas(svg('<polyline points="0,0 5,5 10,0"/>')))
        self.assertFalse(ex.sem_juntas(svg('<rect width="5" height="5"/>')))

    def test_chave_do_desenho(self):
        mais = '<path d="M5 12h14M12 5v14" stroke="#1A1714" stroke-width="2"{lj}/>'
        a = svg('<g id="x">' + mais.format(lj=' stroke-linejoin="round"') + '</g>')
        b = svg('<g id="y">' + mais.format(lj='') + '</g>').replace('width="20" height="20"', 'width="18" height="18"')
        self.assertEqual(ex.desenho(a), ex.desenho(b))
        chevron = '<path d="m9 6 6 6-6 6" stroke="#1A1714" stroke-linejoin="{lj}"/>'
        self.assertNotEqual(ex.desenho(svg(chevron.format(lj='round'))), ex.desenho(svg(chevron.format(lj='miter'))))
        self.assertNotEqual(ex.desenho(a), ex.desenho(a.replace('#1A1714', '#FFFAF1')))

    def test_id_do_tracejado(self):
        # D-285: com outro <rect> de traço, o tracejado ganha o id; sozinho no nome (a mira), fica como está
        livro = svg('<rect x="1" width="9" height="9" stroke="#1A1714"></rect>'
                    '<rect x="2" width="5" height="5" fill="none" stroke="#FF552E" stroke-dasharray="5 4"></rect>')
        marcado = ex.id_tracejado(livro, 'livro.svg')
        self.assertIn('<rect id="tracejado" x="2" width="5"', marcado)
        self.assertEqual(marcado.count('id="tracejado"'), 1)
        mira = svg('<path d="M5 45V27" stroke="#FFFAF1" stroke-dasharray="2 9"/><rect width="5" height="5" stroke="#1A1714"/>')
        self.assertEqual(ex.id_tracejado(mira, 'mira.svg'), mira)
        self.assertEqual(ex.id_tracejado(svg('<rect width="5" height="5"/>'), 'x.svg'), svg('<rect width="5" height="5"/>'))
        # dois tracejados, o da raiz ou um com id próprio: o registro quer um só, sem id
        for ruim in (livro.replace('stroke="#1A1714"', 'stroke="#1A1714" stroke-dasharray="1 1"'),
                     svg('<rect width="5" height="5" stroke="#1A1714"/>', ' stroke-dasharray="2 2"'),
                     livro.replace('<rect x="2"', '<rect id="borda" x="2"')):
            with self.assertRaises(SystemExit):
                ex.id_tracejado(ruim, 'ruim.svg')
        # a marca não entra na chave do desenho
        self.assertEqual(ex.desenho(marcado), ex.desenho(livro))

    def test_atributos_do_arquivo(self):
        self.assertEqual(ex.atributos({'svg': svg('<rect width="5" height="5"/>')}), [20.0, 20.0])
        self.assertIsNone(ex.atributos({'svg': '<svg width="100%" height="40"><rect width="5" height="5"/></svg>'}))


class Catalogo(unittest.TestCase):
    """O catálogo commitado: as armadilhas e os atributos de cada uso, e a pasta da área de cada arquivo novo."""

    def uso(self, id_):
        (u,) = CAT['usos'][id_].values()
        return u

    def test_armadilha_da_capa_reusada_e_a_do_uso(self):
        for id_, caixa, escala in [('d17.cover.book.art', '173×261', '1,8125'), ('d17b.cover.book.art', '173×261', '1,8125'),
                                   ('e07.cover.art', '101×153', '1,0625'), ('cr18.book.cover.art', '43×66', '0,4583'),
                                   ('cr18b.book.cover.art', '43×66', '0,4583')]:
            arm = self.uso(id_)['armadilha']
            self.assertIn(f'da caixa {caixa} ', arm, id_)
            self.assertIn(f'= {escala})', arm, id_)

    def test_nota_de_um_uso_so(self):
        notas = {'d17.highlights.club.chevron': '16,43×20', 'bu28b.searchBar.field.icon': '16,78×20',
                 'bu28c.searchBar.field.icon': '16,78×20', 'e08.card.header.icon': '9,97×12'}
        com_nota = {id_ for id_, por in CAT['usos'].items() for u in por.values() if 'flex-shrink: 0' in u.get('armadilha', '')}
        self.assertEqual(com_nota, set(notas))
        for id_, lay in notas.items():
            self.assertIn(f'fica {lay} no layout', self.uso(id_)['armadilha'])
        # os outros usos do mesmo arquivo não herdam a nota
        arquivos = {self.uso(id_)['arquivo'] for id_ in notas}
        outros = [id_ for id_, por in CAT['usos'].items() for u in por.values() if u['arquivo'] in arquivos and id_ not in notas]
        self.assertTrue(outros)

    def test_tracejados_com_armadilha_e_id(self):
        tracejados = {id_ for id_, por in CAT['usos'].items() for u in por.values()
                      if 'stroke-dasharray' in u.get('armadilha', '') and 'svgDashes' in u.get('armadilha', '')}
        self.assertEqual(tracejados, {'sc39.sheet.lead.art', 'sc40.sheet.lead.art', 'sc41.corners'})
        marcados = sorted(a for a in CAT['arquivos'] if 'id="tracejado"' in open(os.path.join(RAIZ, a), encoding='utf-8').read())
        self.assertEqual(marcados, ['assets/illustrations/scanner/il_livro_codigo_barras.svg',
                                    'assets/illustrations/scanner/il_livro_interrogacao.svg'])

    def test_desenho_fora_da_caixa(self):
        fora = {id_ for id_, por in CAT['usos'].items() for u in por.values() if 'overflow: visible' in u.get('armadilha', '')}
        self.assertEqual(fora, {'e10.envelope', 'e12.daily.option3.art', 'e16.stamp', 'sc69.sticker.card.barcode.bars',
                                'sc69b.sticker.card.barcode.bars'})

    def test_atributos_so_quando_o_layout_e_outro(self):
        com = {id_: u for id_, por in CAT['usos'].items() for u in por.values() if 'atributos' in u}
        bordas = {f'{p}.fill.edge' for p in ('d17.mood.split', 'd17b.mood.split', 'd17b.progress.bar', 'e08.sheet.form.strength.bar',
                                             'e11.sheet.form.strength.bar', 'e12.top.progress', 'e13.top.progress',
                                             'e13b.top.progress', 'e14.top.progress', 'e35.loading')}
        self.assertEqual(set(com), bordas | {'d17.highlights.club.chevron', 'bu28b.searchBar.field.icon',
                                             'bu28c.searchBar.field.icon', 'e08.card.header.icon'})
        for id_, u in com.items():
            self.assertNotEqual(u['atributos'], u['tamanho'], id_)

    def test_pasta_da_area_da_1a_etapa_que_usa(self):
        etapa_de = {slug: p.get('etapa') for slug, p in PR.items()}
        for arquivo, a in CAT['arquivos'].items():
            if a.get('reuso') or a['categoria'] == 'graf':
                continue
            primeira = min(etapa_de[s] for por in CAT['usos'].values() for s, u in por.items() if u['arquivo'] == arquivo)
            self.assertEqual(a['area'], C['areas'][primeira], arquivo)
            raiz = 'assets/icons' if a['categoria'] == 'ic' else 'assets/illustrations'
            self.assertTrue(arquivo.startswith(f"{raiz}/{a['area']}/"), arquivo)

    def test_reusados_apontam_para_os_assets_de_antes(self):
        reusados = [a for a, v in CAT['arquivos'].items() if v.get('reuso')]
        self.assertEqual(len(reusados), 40)
        for a in reusados:
            self.assertFalse(any(a.startswith(p + '/') for p in PASTAS), a)
            self.assertTrue(os.path.exists(os.path.join(RAIZ, a)), a)


class Recortes(unittest.TestCase):
    """Os recortes @3x de png/elementos: um por item, no tamanho da caixa; união, região e o que fica fora do quadro."""

    def test_um_png_por_item_no_tamanho_da_caixa(self):
        nomes = [item[2] for item in rec.ITENS_PROJETO]
        self.assertEqual(len(nomes), len(set(nomes)))
        pasta = caminho('png', 'elementos')
        self.assertEqual({os.path.basename(f)[:-7] for f in glob.glob(os.path.join(pasta, '*@3x.png'))}, set(nomes))
        for item in rec.ITENS_PROJETO:
            x0, y0, x1, y1 = rec.caixa(item, PR)
            self.assertEqual(Image.open(os.path.join(pasta, f'{item[2]}@3x.png')).size, (x1 - x0, y1 - y0), item[2])

    def test_uniao_e_regiao(self):
        (adesivo,) = [i for i in rec.ITENS_PROJETO if i[2] == 'adesivo_isbn_digitado']
        uniao = rec.caixa(adesivo, PR)
        for id_ in adesivo[1]:
            b = rec.caixa((adesivo[0], id_, 'x'), PR)
            self.assertTrue(uniao[0] <= b[0] and uniao[1] <= b[1] and uniao[2] >= b[2] and uniao[3] >= b[3], id_)
        self.assertLess(uniao[1], rec.caixa((adesivo[0], 'sc69.sticker', 'x'), PR)[1])   # as fitas passam por cima
        (fundo,) = [i for i in rec.ITENS_PROJETO if i[2] == 'fundo_listrado_sem_permissao']
        self.assertEqual(rec.caixa(fundo, PR), (0, 330, 1170, 522))

    def test_fora_do_quadro_e_erro_e_nao_entra(self):
        for slug, id_ in [('002_biblioteca', 'b02.collections.card3.pile'), ('028_busca_explorar', 'bu28.trending.book4.cover')]:
            with self.assertRaises(SystemExit):
                rec.caixa((slug, id_, 'x'), PR)
            self.assertNotIn(id_, [i[1] for i in rec.ITENS_PROJETO])

    def test_sob_um_veu_nao_entra(self):
        ids = {i[1] for i in rec.ITENS_PROJETO}
        for id_ in ['e13b.top.progress', 'e13b.suggestions.grid', 'p65.preview.avatar', 'cr18b.book.cover',
                    *[f'e13b.suggestions.book{n}.cover' for n in range(1, 7)]]:
            self.assertNotIn(id_, ids)


class Classes(unittest.TestCase):
    """O gerador das classes por área: os nomes das constantes e o gerado = o commitado."""

    def test_constante(self):
        self.assertEqual(gen.constante('assets/icons/biblioteca/ic_chevron_right_clube.svg'), 'chevronRightClube')
        self.assertEqual(gen.constante('assets/illustrations/scanner/il_livro_interrogacao.svg'), 'livroInterrogacao')
        self.assertEqual(gen.constante('assets/illustrations/entrada/despertador_30_min.svg'), 'despertador30Min')
        for ruim in ('ic_switch.svg', 'ic_all.svg', 'il_30_min.svg'):
            with self.assertRaises(SystemExit):
                gen.constante(f'assets/icons/x/{ruim}')

    @unittest.skipUnless(shutil.which('dart'), 'sem o dart no PATH')
    def test_gerado_igual_ao_commitado(self):
        tok = os.path.join(RAIZ, 'lib', 'core', 'design_system', 'tokens')
        gerados = [f'app_{t}_{a}.dart' for t in ('icons', 'illustrations') for a in C['areas'].values()]
        with tempfile.TemporaryDirectory() as tmp:
            for f in glob.glob(os.path.join(tok, 'app_*.dart')):
                if os.path.basename(f) not in gerados:
                    shutil.copy(f, tmp)
            antes, gen.TOK = gen.TOK, tmp
            try:
                gen.main()
            finally:
                gen.TOK = antes
            for nome in gerados:
                with open(os.path.join(tmp, nome), 'rb') as a, open(os.path.join(tok, nome), 'rb') as b:
                    self.assertEqual(a.read(), b.read(), nome)


if __name__ == '__main__':
    unittest.main()
