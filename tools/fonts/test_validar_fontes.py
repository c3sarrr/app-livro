#!/usr/bin/env python3
"""T13.10 (R6) — testes da conferência por trecho do `validar_fontes.py` em casos montados à mão: as regras que as 41
telas não exercitam por inteiro (o espaço do fim da borda que é do elemento não aparece em nenhuma linha; juntar os
trechos vizinhos da mesma fonte muda uma linha em 0,0001 px) ficam provadas aqui, e as que exercitam, também.

Rodar da raiz do repositório, no WSL (requer uharfbuzz e fontTools, como o validador):
  PYTHONIOENCODING=utf-8 python3 -m unittest tools/fonts/test_validar_fontes.py -v
"""
import json
import os
import sys
import tempfile
import unittest
from unittest import mock

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.dirname(os.path.dirname(AQUI))
sys.path.insert(0, AQUI)
os.environ.setdefault('CONJUNTO', 'projeto')
import validar_fontes as vf  # noqa: E402


def fonte(familia='Figtree', peso=600, tam=13.0, ls='normal', estilo='normal'):
    return {'family': familia, 'style': estilo, 'weightCss': peso, 'size': tam, 'letterSpacing': ls}


def estilo(pl=0, bl=0, ml=0, pr=0, br=0, mr=0):
    return {'paddingLeft': f'{pl}px', 'borderLeftWidth': f'{bl}px', 'marginLeft': f'{ml}px',
            'paddingRight': f'{pr}px', 'borderRightWidth': f'{br}px', 'marginRight': f'{mr}px'}


class EspacosDeBorda(unittest.TestCase):
    """O espaço na borda do texto de um elemento é dele quando o vizinho de fora da tag não é espaço."""

    TEMPLATE = ('<p>ISBN<span> do verso.</span> <b>foo </b>bar <i> x</i>'
                '<em title="a>b"> y</em><s>z </s> w</p>')

    def setUp(self):
        t = self.TEMPLATE
        self.tmp = tempfile.NamedTemporaryFile('w', suffix='.html', delete=False, encoding='utf-8')
        self.tmp.write(t)
        self.tmp.close()

        def no(tpl, abre, fecha, de=0):
            ini = t.index(abre, de)
            return {'tpl': tpl, 'ini': ini, 'fim': t.index(fecha, ini) + len(fecha), 'parent': 0}
        self.nos = [{'tpl': 0, 'ini': 0, 'fim': len(t), 'parent': None},
                    no(1, '<span>', '</span>'), no(2, '<b>', '</b>'), no(3, '<i>', '</i>'),
                    no(4, '<em ', '</em>'), no(5, '<s>', '</s>')]

    def tearDown(self):
        os.unlink(self.tmp.name)

    def test_regras(self):
        with mock.patch('esboco.esboco', lambda base: self.nos), \
                mock.patch('conjunto.caminho', lambda *partes: self.tmp.name):
            b = vf.espacos_de_borda('qualquer')
        self.assertEqual(b[1], (True, False))    # "ISBN<span> do verso.": o espaço é da span
        self.assertEqual(b[2], (False, True))    # "<b>foo </b>bar": o espaço do fim é do <b>
        self.assertEqual(b[3], (False, False))   # "bar <i> x": o branco colapsa no de fora
        self.assertEqual(b[4], (True, False))    # o ">" dentro das aspas não fecha a tag
        self.assertEqual(b[5], (False, False))   # "<s>z </s> w": o de dentro colapsa no de fora


class TrechosDaLinha(unittest.TestCase):
    def montar(self, linhas_filho, brancas_filho, st=None):
        R = {'text': 'foo bar', 'baseline': 10.0, 'left': 0.0, 'right': 50.0}
        els = {'p': {'tpl': 1, 'style': {'font': fonte()}}, 'b': {'tpl': 2, 'style': {'font': fonte(peso=800)}}}
        M = {'linesAll': {'p': [R]}, 'lines': {'b': linhas_filho},
             'styles': {'b': st or estilo(pl=2, pr=3, br=1, mr=0.5)}}
        anc = {'p': [], 'b': ['p']}
        return vf.trechos_da_linha('p', R, els, M, anc, {1: (False, False), 2: brancas_filho})

    def test_espaco_do_fim_que_e_do_elemento(self):
        partes, extra, ids = self.montar([{'text': 'foo', 'baseline': 10.0, 'left': 0.0, 'right': 20.0}],
                                         (False, True))
        self.assertEqual(partes, [['foo ', 'b'], ['bar', 'p']])
        self.assertEqual(extra, 4.5)             # só o recuo da direita: a esquerda é o 1º glifo da linha
        self.assertEqual(ids, ['b', 'p'])

    def test_espaco_do_fim_que_e_de_fora(self):
        partes, extra, _ = self.montar([{'text': 'foo', 'baseline': 10.0, 'left': 0.0, 'right': 20.0}],
                                       (False, False))
        self.assertEqual(partes, [['foo', 'b'], [' bar', 'p']])
        self.assertEqual(extra, 4.5)

    def test_quebra_dentro_do_elemento(self):
        # o filho tem duas linhas e esta é a 2ª: nem o espaço do começo nem o recuo da esquerda entram aqui
        R = {'text': 'ab cd ef', 'baseline': 30.0, 'left': 0.0, 'right': 60.0}
        els = {'p': {'tpl': 1, 'style': {'font': fonte()}}, 's': {'tpl': 2, 'style': {'font': fonte(peso=800)}}}
        linhas_s = [{'text': 'xx', 'baseline': 10.0, 'left': 40.0, 'right': 60.0},
                    {'text': 'cd', 'baseline': 30.0, 'left': 20.0, 'right': 35.0}]
        M = {'linesAll': {'p': [R]}, 'lines': {'s': linhas_s}, 'styles': {'s': estilo(pl=5, pr=7)}}
        partes, extra, _ = vf.trechos_da_linha('p', R, els, M, {'p': [], 's': ['p']}, {1: (False, False),
                                                                                        2: (True, True)})
        self.assertEqual(partes, [['ab ', 'p'], ['cd ', 's'], ['ef', 'p']])
        self.assertEqual(extra, 7.0)

    def test_recuo_soma_padding_borda_e_margem(self):
        self.assertEqual(vf.recuo(estilo(pl=1, bl=2, ml=4), 'Left'), 7.0)
        self.assertEqual(vf.recuo(estilo(pr=0.5, br=0.25, mr=0.125), 'Right'), 0.875)
        self.assertEqual(vf.recuo({'paddingLeft': 'auto', 'borderLeftWidth': '0px', 'marginLeft': '1px'}, 'Left'),
                         1.0)


class JuntarTrechos(unittest.TestCase):
    def test_vizinhos_da_mesma_fonte_se_juntam(self):
        els = {'a': {'style': {'font': fonte()}}, 'b': {'style': {'font': fonte()}},
               'c': {'style': {'font': fonte(peso=800)}}}
        runs = vf.juntar_trechos([['Capitu ', 'a'], ['era ', 'b'], ['Capitu', 'c'], ['.', 'a']], els)
        self.assertEqual([(t, d) for t, d, _ in runs], [('Capitu era ', 'a'), ('Capitu', 'c'), ('.', 'a')])

    def test_espacamento_ou_tamanho_diferentes_separam(self):
        els = {'a': {'style': {'font': fonte()}}, 'b': {'style': {'font': fonte(ls='0.5px')}},
               'c': {'style': {'font': fonte(tam=14.0)}}}
        runs = vf.juntar_trechos([['x', 'a'], ['y', 'b'], ['z', 'c']], els)
        self.assertEqual(len(runs), 3)


class Fontes(unittest.TestCase):
    def test_reserva_no_peso_do_texto(self):
        self.assertEqual(vf.por_cobertura('≈ 2 h', 'Figtree-SemiBold.ttf', 600),
                         [['≈', 'BookNestApprox-SemiBold.otf'], [' 2 h', 'Figtree-SemiBold.ttf']])
        self.assertEqual(vf.por_cobertura('dica →', 'Figtree-ExtraBold.ttf', 800),
                         [['dica ', 'Figtree-ExtraBold.ttf'], ['→', 'BookNestApprox-ExtraBold.otf']])
        with self.assertRaises(KeyError):
            vf.por_cobertura('☃', 'Figtree-SemiBold.ttf', 600)

    def test_familia_sem_font_face_cai_na_1a_da_lista_que_tem(self):
        L = {'fontFaces': [{'family': 'Roboto'}, {'family': 'Figtree'}]}
        fo = {'family': 'Google Sans'}
        e = {'css': "color: red; font-family: Arial; font-family: 'Google Sans', \"Roboto\", Arial"}
        self.assertEqual(vf.familia(L, e, fo), 'Roboto')
        self.assertEqual(vf.familia(L, e, {'family': 'Figtree'}), 'Figtree')
        self.assertEqual(vf.familia(L, {'css': 'font-family: Arial'}, fo), 'Google Sans')

    def test_arquivos_do_projeto(self):
        self.assertEqual(vf.arquivo('Bricolage Grotesque', 'normal', 700, 15.0), ('Bricolage15-Bold.ttf', None))
        self.assertEqual(vf.arquivo('Bricolage Grotesque', 'normal', 800, 11.0), ('Bricolage12-ExtraBold.ttf', None))
        self.assertEqual(vf.arquivo('Roboto', 'normal', 500, 15.0), ('Roboto-Medium.ttf', None))
        self.assertEqual(vf.arquivo('Literata', 'normal', 600, 24.0), ('Literata24-SemiBold.ttf', None))
        with self.assertRaises(KeyError):
            vf.arquivo('Literata', 'italic', 400, 24.0)

    def test_ligaduras_e_limites(self):
        self.assertEqual(vf.SEM_LIGADURAS, {'liga': False, 'clig': False})     # D-282: as do Blink
        self.assertEqual(vf.LIMITE_TRECHO, 0.01)                                # R6
        self.assertEqual(vf.LIMITE, 0.05)                                       # G01 (leitor e Início)

    def test_espacamento_desliga_o_fi(self):
        # o "fi" da Instrument Serif itálica: com espaçamento, dois glifos (o Chromium); sem, a ligadura
        nome = os.path.join(vf.FONTS, 'InstrumentSerif-Italic.ttf')
        com = vf.largura(nome, None, 'definem', 22.0, -0.4, False)
        sem_ls = vf.largura(nome, None, 'definem', 22.0, 0.0, False) - 0.4 * len('definem')
        self.assertGreater(com - sem_ls, 0.5)


class SaidasGravadas(unittest.TestCase):
    def test_resumo_dos_dois_conjuntos(self):
        for c, n in (('projeto', 1216), ('projeto_larguras', 2438)):
            with open(os.path.join(RAIZ, 'docs', 'design', 'medicao', c, 'validacao_fontes.json'),
                      encoding='utf-8') as f:
                v = json.load(f)
            r = v['resumo']
            self.assertEqual((r['linhas'], r['limite'], r['acimaDoLimite']), (n, 0.01, 0), c)
            self.assertLessEqual(r['maxDiferenca'], 0.005, c)
            for it in v['linhas']:
                self.assertEqual(''.join(t['texto'] for t in it['trechos']), it['texto'], (c, it['id']))
                self.assertLessEqual(abs(it['diferenca']), 0.005, (c, it['id']))
            self.assertTrue(all(x.split()[0] in {p['prancha'] for p in v['linhas']}
                                for x in r['foraDaConferencia']), c)


if __name__ == '__main__':
    unittest.main()
