#!/usr/bin/env python3
"""T13.9 (D-272) — testes do índice das larguras (`indice_larguras.py`) e do relatório de fluidez (`fluidez.py`).

Rodar da raiz do repositório (Python puro):
  PYTHONIOENCODING=utf-8 python3 -m unittest tools/medicao/test_larguras.py -v
Os testes contra os dados de verdade usam a extração do projeto (fora do git: `tools/medicao/pranchas_projeto/`,
refeita pelo `rodar_etapa.sh`); sem ela, são pulados.
"""
import contextlib
import io
import json
import os
import shutil
import sys
import tempfile
import unittest
from unittest import mock

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
import esboco  # noqa: E402
import fluidez  # noqa: E402
import indice_larguras  # noqa: E402

RAIZ = os.path.dirname(os.path.dirname(AQUI))
CONJUNTOS = indice_larguras.ler(os.path.join(AQUI, 'conjuntos.json'))
EXTRACAO = os.path.join(RAIZ, *CONJUNTOS['projeto']['extracao'].split('/'))


def texto(arq):
    with open(arq, encoding='utf-8') as f:
        return f.read()


def gravar(arq, dado):
    with open(arq, 'w', encoding='utf-8') as f:
        json.dump(dado, f)


def gerar(base, saida, *larguras):
    with mock.patch.object(sys, 'argv', ['indice_larguras.py', base, saida, *map(str, larguras)]), \
            contextlib.redirect_stdout(io.StringIO()):
        indice_larguras.main()
    return indice_larguras.ler(saida)


def esboco_de(pasta):
    """O esboço do template de uma prancha numa pasta de extração dada (sem depender do CONJUNTO do processo)."""
    def f(slug):
        tpl = texto(os.path.join(pasta, slug, 'template.html'))
        p = esboco.P(tpl)
        p.feed(tpl)
        return p.out
    return f


class IndiceLarguras(unittest.TestCase):
    BASE = {'_doc': 'base', 'formato': 'dc', 'frame': '#quadro', 'pranchas': [
        {'tela': '30b', 'slug': '030b_x', 'arquivo': 'telas/X.dc.html', 'prefixo': 'n30b', 'etapa': 'T17',
         'titulo': '30b · X', 'canvas': [390, 1330], 'previa': '', 'reserva': {'a.b': {'motivo': 'm', 'informativo': False}},
         'zoomBase': 20, 'zoomConvergencia': 40, '_zoom': 'D-279'},
        {'tela': '18b', 'slug': '018b_y', 'arquivo': 'telas/Y.dc.html', 'prefixo': 'cr18b', 'etapa': 'T18',
         'titulo': '18b · Y', 'canvas': [390, 844], 'previa': '',
         'convergenciaFaixa': {'y': [290, 335], 'zoom': 12}, '_convergencia': 'R3'},
    ]}

    def test_cada_tela_vira_uma_entrada_por_largura(self):
        with tempfile.TemporaryDirectory() as d:
            base = os.path.join(d, 'base.json')
            gravar(base, self.BASE)
            out = gerar(base, os.path.join(d, 'larg.json'), 360, 430)
        self.assertEqual({k: out[k] for k in ('formato', 'frame')}, {'formato': 'dc', 'frame': '#quadro'})
        self.assertEqual([p['tela'] for p in out['pranchas']], ['30bw360', '30bw430', '18bw360', '18bw430'])
        a, b = out['pranchas'][0], out['pranchas'][3]
        self.assertEqual(a, {'tela': '30bw360', 'slug': '030b_x_w360', 'base': '030b_x', 'prefixo': 'n30b',
                             'etapa': 'T17', 'arquivo': 'telas/X.dc.html', 'titulo': '30b · X — largura 360',
                             'canvas': [360, 1330], 'largura': 360, 'previa': '',
                             'reserva': {'a.b': {'motivo': 'm', 'informativo': False}},
                             'zoomBase': 20, 'zoomConvergencia': 40, '_zoom': 'D-279'})
        # a faixa da R3 é de cada largura: não vem da tela base
        self.assertEqual(b, {'tela': '18bw430', 'slug': '018b_y_w430', 'base': '018b_y', 'prefixo': 'cr18b',
                             'etapa': 'T18', 'arquivo': 'telas/Y.dc.html', 'titulo': '18b · Y — largura 430',
                             'canvas': [430, 844], 'largura': 430, 'previa': ''})

    def test_refazer_mantem_a_faixa_da_r3_gravada(self):
        with tempfile.TemporaryDirectory() as d:
            base, saida = os.path.join(d, 'base.json'), os.path.join(d, 'larg.json')
            gravar(base, self.BASE)
            out = gerar(base, saida, 360, 430)
            out['pranchas'][2]['convergenciaFaixa'] = {'y': [280, 330], 'zoom': 11}
            out['pranchas'][2]['_convergencia'] = 'motivo da 360'
            gravar(saida, out)
            de_novo = gerar(base, saida, 360, 430)
        self.assertEqual(de_novo['pranchas'][2]['convergenciaFaixa'], {'y': [280, 330], 'zoom': 11})
        self.assertEqual(de_novo['pranchas'][2]['_convergencia'], 'motivo da 360')
        self.assertNotIn('convergenciaFaixa', de_novo['pranchas'][3])

    def test_o_indice_do_projeto_e_o_gerado(self):
        # gerado da raiz com o caminho relativo (ele vai no _doc), por cima do commitado (que tem as faixas da R3)
        commitado = os.path.join(AQUI, 'pranchas_projeto_larguras.json')
        antes = os.getcwd()
        with tempfile.TemporaryDirectory() as d:
            saida = os.path.join(d, 'larg.json')
            shutil.copyfile(commitado, saida)
            os.chdir(RAIZ)
            try:
                gerar('tools/medicao/pranchas_projeto.json', saida, 360, 430)
            finally:
                os.chdir(antes)
            novo = texto(saida)
        self.assertEqual(novo, texto(commitado))

def el(tpl, x, y, w, h, tipo='box', secao='s', **extra):
    return {'tpl': tpl, 'type': tipo, 'abs': [x, y, w, h], **({'section': secao} if secao else {}), **extra}


def linhas(*pares):
    return [{'text': 't', 'left': a, 'right': b} for a, b in pares]


class Fluidez(unittest.TestCase):
    # frame(1) > main(2) > [card(3) > [botao(4), texto(5), selo(6), rotulo(7), trecho(8), grupo sem id(9) > fundo(10)],
    #                      fileira(11, overflow hidden) > item(12), onda(13) > desenho(14), camada(15)]
    ARVORE = [(1, None), (2, 1), (3, 2), (4, 3), (5, 3), (6, 3), (7, 3), (8, 3), (9, 3), (10, 9), (11, 2), (12, 11),
              (13, 2), (14, 13), (15, 2)]

    def larguras(self):
        # por largura: (x do selo, x do trecho, a linha do texto até onde vai)
        varia = {390: (290, 340, 200), 360: (240, 250, 260), 430: (330, 380, 200)}
        L = {}
        for W, (selo, trecho, fim) in varia.items():
            d = W - 390
            L[W] = {
                'p.frame': el(1, 0, 0, W, 844, secao=None), 'p.main': el(2, 0, 0, W, 844, secao=None),
                'p.card': el(3, 16, 100, 358 + d, 80),
                'p.card.botao': el(4, 300, 140, 60, 30),                       # largura fixa: passa do card a 360
                'p.card.texto': el(5, 24, 110, 260 + d, 20, 'text', lines=linhas((24, fim))),
                'p.card.selo': el(6, selo, 110, 40, 20),                       # fixo: cai em cima do texto a 360
                'p.card.rotulo': el(7, 24, 160, 100, 15, 'text', lines=linhas((24, 120)),
                                    **({'ellipsis': True} if W == 360 else {})),
                'p.card.trecho': el(8, trecho, 110, 30, 20, 'inline'),         # inline: não conta como vizinho
                'p.card.fundo': el(10, 16, 100, 358 + d, 80),                 # o pai medido é o card (9 sem id)
                'p.fileira': el(11, 16, 300, 358 + d, 50, style={'overflow': 'hidden'}),
                'p.fileira.item': el(12, 300, 300, 100, 50),                  # já passava a 390 (do desenho)
                'p.onda': el(13, 0, 700, 390, 100),                           # fixa: sai do quadro a 360
                'p.onda.desenho': el(14, 0, 700, 390, 100),                   # sai junto com o pai: não entra
                'p.camada': el(15, 0, 90, W, 120),                            # já cobria o card a 390
            }
        return L

    def analisar(self, W):
        L = self.larguras()
        nos = [{'tpl': t, 'parent': p} for t, p in self.ARVORE]
        p = {'base': 'b', 'prefixo': 'p', 'canvas': [W, 844]}
        with mock.patch.object(fluidez, 'esboco', lambda base: nos):
            return fluidez.analisar(p, {360: L[360], 430: L[430]}, L[390])

    def test_fora(self):
        self.assertEqual(fluidez.fora((10, 10, 20, 20), (0, 0, 100, 100)), (0.0, 0.0))
        self.assertEqual(fluidez.fora((-5, 10, 110, 20), (0, 0, 100, 100)), (10.0, 0.0))
        self.assertEqual(fluidez.fora((10, 95, 20, 103), (0, 0, 100, 100)), (0.0, 3.0))

    def test_pais_pula_o_que_nao_tem_id(self):
        L = self.larguras()[390]
        nos = [{'tpl': t, 'parent': p} for t, p in self.ARVORE]
        with mock.patch.object(fluidez, 'esboco', lambda base: nos):
            pai = fluidez.pais('b', L)
        self.assertEqual(pai['p.card.fundo'], 'p.card')
        self.assertEqual(pai['p.card'], 'p.main')
        self.assertIsNone(pai['p.frame'])

    def test_os_problemas_a_360(self):
        itens = self.analisar(360)
        self.assertEqual(itens, [
            {'id': 'p.card.botao', 'tipo': 'passa do pai', 'eixo': 'x', 'px': 16.0, 'px390': 0.0, 'novo': True,
             'larguraFixa': True, 'pai': 'p.card', 'corte': 'vaza', 'paiLarguraFixa': False},
            {'id': 'p.card.texto', 'tipo': 'texto passa', 'eixo': 'x', 'px': 6.0, 'px390': 0.0, 'novo': True,
             'larguraFixa': False},
            {'id': 'p.card.rotulo', 'tipo': 'reticências', 'eixo': 'x', 'px': 0, 'px390': 0, 'novo': True,
             'larguraFixa': True},
            {'id': 'p.fileira.item', 'tipo': 'sai do quadro', 'eixo': 'x', 'px': 40.0, 'px390': 10.0, 'novo': False,
             'larguraFixa': True},
            {'id': 'p.fileira.item', 'tipo': 'passa do pai', 'eixo': 'x', 'px': 56.0, 'px390': 26.0, 'novo': False,
             'larguraFixa': True, 'pai': 'p.fileira', 'corte': 'cortado', 'paiLarguraFixa': False},
            {'id': 'p.onda', 'tipo': 'sai do quadro', 'eixo': 'x', 'px': 30.0, 'px390': 0.0, 'novo': True,
             'larguraFixa': True},
            {'id': 'p.card.texto', 'tipo': 'invade o vizinho', 'eixo': 'x', 'px': 14.0, 'px390': 0.0, 'novo': True,
             'larguraFixa': False, 'vizinho': 'p.card.selo', 'vizinhoLarguraFixa': True},
        ])

    def test_a_430_nada(self):
        # o card cresce: o botão cabe, o texto cabe, a camada cobre mais o card (já cobria a 390)
        self.assertEqual(self.analisar(430), [])


@unittest.skipUnless(os.path.isdir(EXTRACAO), 'sem a extração do projeto (tools/medicao/pranchas_projeto/)')
class FluidezDoProjeto(unittest.TestCase):
    def test_o_json_commitado_e_o_calculado(self):
        larg = CONJUNTOS['projeto_larguras']
        pasta = os.path.join(RAIZ, *larg['layout'].split('/'))
        pasta0 = os.path.join(RAIZ, *CONJUNTOS[larg['conjuntoBase']]['layout'].split('/'))
        idx = indice_larguras.ler(os.path.join(RAIZ, larg['indice']))['pranchas']
        comm = indice_larguras.ler(os.path.join(os.path.dirname(pasta), 'fluidez.json'))
        self.assertEqual(comm['TOL'], fluidez.TOL)
        self.assertEqual(list(comm['telas']), [p['slug'] for p in idx])
        with mock.patch.object(fluidez, 'esboco', esboco_de(EXTRACAO)):
            for p in idx:
                irmas = {q['largura']: fluidez.lay(pasta, q['slug']) for q in idx if q['base'] == p['base']}
                calc = json.loads(json.dumps(fluidez.analisar(p, irmas, fluidez.lay(pasta0, p['base']))))
                self.assertEqual(calc, comm['telas'][p['slug']], p['slug'])


if __name__ == '__main__':
    unittest.main()
