#!/usr/bin/env python3
"""T13.12 (R5) — testes dos insumos das T14–T18: os tokens novos e o mapa id → widget (`tokens_widgets.py`), as fases L
(`gen_fases.py`: as props de cada tela, a seção "Nas outras larguras", as seções sem contêiner, a tela sem props) e as
notas escritas à mão (`fases_notas_projeto*.py`). Os arquivos regenerados numa pasta temporária têm de ser os
commitados; as fases do inicio2 saem iguais às commitadas e as do leitor iguais às da G01 (`LEGADO_G01`).

Os tokens do app entram fixos no commit da T13.11 (`TOKENS_DO_APP`): as etapas seguintes acrescentam cores e classes
ao app, e o "já existe" do L00 é o retrato da medição (o mesmo caso do inicio2 com o `TOKENS_DART`).

Rodar da raiz do repositório no Windows:
  PYTHONIOENCODING=utf-8 python3 -m unittest tools/medicao/test_fases_projeto.py -v
"""
import glob
import importlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import types
import unittest

os.environ['CONJUNTO'] = 'projeto'
AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
_argv = sys.argv
sys.argv = sys.argv[:1]  # tokens_widgets e gen_classes_svg leem a pasta dos tokens do argv[1]
import gen_classes_svg  # noqa: E402
import tokens_widgets as tw  # noqa: E402
import gen_fases as gf  # noqa: E402
import fases_notas_projeto as notas  # noqa: E402
import fases_notas_projeto_comum as comum  # noqa: E402
from conjunto import RAIZ, caminho, indice  # noqa: E402
from esboco import esboco  # noqa: E402
sys.argv = _argv

NL = chr(10)


def ler(p):
    with open(p, encoding='utf-8') as f:
        return f.read()


TOKENS_DO_APP = '66ec95a'  # T13.11: os tokens do app com que tokens_projeto.json, o mapa e o L00 foram gerados
PASTA_TOKENS = 'lib/core/design_system/tokens'
LAYOUTS = {}
for _f in sorted(glob.glob(caminho('layout', 'layout_*.json'))):
    _L = json.loads(ler(_f))
    LAYOUTS[_L['meta']['prancha']] = _L
FASES = json.loads(ler(caminho('fasesIndice')))['fases']
PR = {p['slug']: p for p in indice()['pranchas']}
MAPA = json.loads(ler(caminho('mapa')))
TOKENS = json.loads(ler(caminho('tokens')))
CAT = json.loads(ler(caminho('svgCatalogo')))
PROP = re.compile('[{][{]([A-Za-z0-9_]+)[}][}] [(]padrão ([^)]*)[)]')



def md(fase):
    return ler(os.path.join(caminho('fases'), fase + '.md'))


def secoes_da(fase):
    return [f"{PR[fase['prancha']]['prefixo']}.{s}" for s in fase['secoes']]


def ids_da(fase):
    secoes = secoes_da(fase)
    return [k for k, e in LAYOUTS[fase['prancha']]['elements'].items() if e.get('section') in secoes]


def secao_do_md(texto, titulo):
    """As linhas de uma seção `## titulo` do arquivo da fase, até a próxima `## `."""
    linhas = texto.split(NL)
    ini = next(i for i, ln in enumerate(linhas) if ln.startswith('## ' + titulo))
    fim = next((i for i in range(ini + 1, len(linhas)) if linhas[i].startswith('## ')), len(linhas))
    return linhas[ini + 1:fim]


def tokens_fixos(destino):
    """Os arquivos de tokens do app no commit da T13.11, numa pasta."""
    nomes = subprocess.run(['git', 'ls-tree', '--name-only', TOKENS_DO_APP, PASTA_TOKENS + '/'], cwd=RAIZ, check=True,
                           capture_output=True, text=True).stdout.split()
    for n in nomes:
        corpo = subprocess.run(['git', 'show', f'{TOKENS_DO_APP}:{n}'], cwd=RAIZ, check=True, capture_output=True).stdout
        with open(os.path.join(destino, os.path.basename(n)), 'wb') as fh:
            fh.write(corpo)
    return destino


class TokensEMapa(unittest.TestCase):
    """tokens_projeto.json, mapa_widgets.json e L00_projeto_tokens_e_widgets.md."""

    def test_gerados_iguais_aos_commitados(self):
        tmp = tempfile.mkdtemp()
        os.makedirs(os.path.join(tmp, 'tokens_app'))
        tok = tokens_fixos(os.path.join(tmp, 'tokens_app'))
        saidas = {k: os.path.join(tmp, os.path.basename(caminho(k))) for k in ('tokens', 'mapa', 'tokensMd')}
        antes = (tw.caminho, tw.TOK, gen_classes_svg.TOK, tw.CONSTANTES)
        tw.caminho = lambda k, *a: saidas[k] if k in saidas and not a else caminho(k, *a)
        tw.TOK, gen_classes_svg.TOK, tw.CONSTANTES = tok, tok, None
        try:
            tw.main()
            tw.markdown()
        finally:
            tw.caminho, tw.TOK, gen_classes_svg.TOK, tw.CONSTANTES = antes
        for k, p in saidas.items():
            self.assertEqual(ler(p), ler(caminho(k)), f'{k}: regenerado ≠ commitado')
        shutil.rmtree(tmp)

    def test_mapa_com_todos_os_ids(self):
        self.assertEqual(sorted(MAPA), sorted(LAYOUTS))
        for slug, L in LAYOUTS.items():
            self.assertEqual(sorted(MAPA[slug]), sorted(L['elements']), slug)
            for k, v in MAPA[slug].items():
                self.assertTrue(v['widget'], f'{slug} {k}: sem widget')

    def test_svg_pela_constante_da_classe_do_app(self):
        """O widget de cada ícone e ilustração é `AppSvg(Classe.constante, …)` e a constante, na classe do app, é o
        arquivo do catálogo (as classes por área da T13.11 e as de antes, para os reusados)."""
        consts = {}
        for f in sorted(glob.glob(os.path.join(RAIZ, PASTA_TOKENS, 'app_*.dart'))):
            for corpo in ler(f).split('abstract final class ')[1:]:
                classe = re.match('[A-Za-z0-9_]+', corpo).group(0)
                d = re.search("static const _d = '([^']+)'", corpo)
                for c, v in re.findall("static const ([A-Za-z0-9_]+) =[ " + NL + "]*'([^']+)'", corpo):
                    consts[f'{classe}.{c}'] = v.replace('$_d', d.group(1)) if d else v
        vistos = 0
        for k, por_tela in CAT['usos'].items():
            for slug, uso in por_tela.items():
                cat = CAT['arquivos'][uso['arquivo']]['categoria']
                if cat not in ('ic', 'il'):
                    continue
                w = MAPA[slug][k]['widget']
                m = re.match('AppSvg[(]([A-Za-z0-9_]+[.][A-Za-z0-9_]+), size: ', w)
                self.assertIsNotNone(m, f'{slug} {k}: {w}')
                self.assertEqual(consts.get(m.group(1)), uso['arquivo'], f'{slug} {k}: {m.group(1)}')
                vistos += 1
        self.assertGreater(vistos, 300)

    def test_cada_cor_nova_tem_nome(self):
        bases = set()
        for c in TOKENS['cores']:
            base, _, a = c['cor'].partition('@')
            bases.add(base)
            if c['existe']:
                self.assertIsNone(c['nomeProposto'], c['cor'])
                continue
            self.assertNotIn(c['nomeProposto'], (None, '', '—'), c['cor'])
            if a and float(a) == 0:
                self.assertTrue(c['nomeProposto'].startswith('transparent'), c['cor'])
        # nenhum nome sobrando (de uma cor que a medição não tem mais)
        self.assertEqual(sorted(set(tw.NOMES_COR_PROJETO) - bases), [])

    def test_nome_proposto(self):
        ex = {'#1A1714': 'ink'}
        self.assertEqual(tw.nome_proposto('#123456@0', ex), 'transparent (parada dos degradês e das máscaras)')
        self.assertEqual(tw.nome_proposto('#1A1714@0.5', ex), 'ink @ 0,5')
        self.assertEqual(tw.nome_proposto('#3E3832@0.4', ex), 'inkBody @ 0,4')
        self.assertEqual(tw.nome_proposto('#3E3832', ex), 'inkBody (regras da senha, sinopse, textos de apoio)')
        self.assertEqual(tw.nome_proposto('#ABCDEF', ex), '—')

    def test_props_do_l00_iguais_as_das_telas(self):
        """O parágrafo das props do L00 (escrito à mão) tem todas as props medidas, a contagem do brand e as telas do
        halo verde e do lavanda."""
        linha = next(ln for ln in ler(caminho('tokensMd')).split(NL) if ln.startswith('- Props (cores dinâmicas)'))
        props = {}
        for slug, L in LAYOUTS.items():
            for k, v in L['meta']['props'].items():
                props.setdefault(k, []).append((PR[slug]['tela'], v))
        nomes = set(re.findall('`([a-z]+)`', linha.split(' — ')[0]))
        self.assertEqual(nomes, set(props))
        self.assertIn(f"`brand` (lavanda, {len(props['brand'])} telas)", linha)
        cor = dict((v, t) for t, v in props['halo'])
        self.assertIn(f"`halo` (verde na {cor['#ABCF82']}, lavanda na {cor['#B6ACE4']})", linha)


class Fases(unittest.TestCase):
    """As 73 fases L do projeto e o LEIA-ME_projeto.md."""

    def test_geradas_iguais_as_commitadas(self):
        tmp = tempfile.mkdtemp()
        antes = gf.OUT
        gf.OUT = tmp
        try:
            gf.main()
        finally:
            gf.OUT = antes
        esperados = sorted([f['fase'] + '.md' for f in FASES] + [gf.C['fasesLeiaMe'][0]])
        self.assertEqual(sorted(os.listdir(tmp)), esperados)
        for n in esperados:
            self.assertEqual(ler(os.path.join(tmp, n)), ler(os.path.join(caminho('fases'), n)), n)
        shutil.rmtree(tmp)

    def test_caixa_visual_com_os_numeros(self):
        """T13.12: a caixa visual dos elementos com transform sai com x, y, w e h (desde a G01 saía "{fmt(...)}" cru);
        a Início também, e o leitor não (`LEGADO_G01`)."""
        caixa = re.compile('^- `[^`]+`: caixa visual .* = x -?[0-9.]+, y -?[0-9.]+, w [0-9.]+, h [0-9.]+ [(]relativa à seção[)][.]$')
        vistas = 0
        for n in sorted(os.listdir(caminho('fases'))):
            texto = ler(os.path.join(caminho('fases'), n))
            self.assertNotIn('{fmt(', texto, n)
            for ln in texto.split(NL):
                if ': caixa visual ' in ln:
                    self.assertRegex(ln, caixa, n)
                    vistas += 1
        self.assertGreater(vistas, 100)
        self.assertFalse(gf.LEGADO_G01)
        self.assertIn('{fmt(', ler(os.path.join(RAIZ, 'handoff_v2', 'fases', 'L27_sumario.md')))

    def test_diferencas_nunca_vazias(self):
        """T13.12: a seção "Diferenças" de uma fase que reaproveita seções diz o que muda ou que nada muda (a 30c, com o
        título da 30, ficava só com o cabeçalho)."""
        for f in FASES:
            if not f.get('reusa'):
                continue
            sec = [ln for ln in secao_do_md(md(f['fase']), 'Diferenças') if ln.strip()]
            corpo = sec[1:]  # a 1ª é a frase de abertura
            self.assertTrue(corpo, f['fase'])
            nada = [ln for ln in corpo if ln.startswith('Nenhuma diferença')]
            self.assertEqual(bool(nada), not any(ln.startswith(('|', 'Só na base', 'Só nesta prancha')) for ln in corpo),
                             f['fase'])
        self.assertIn('Nenhuma diferença: todos os ids das seções reutilizadas são idênticos aos da 30.',
                      md('L30c_tudo_em_dia'))

    def test_inicio2_com_os_mesmos_bytes(self):
        """A Início regenerada = a commitada (na T13.12 mudaram 7 fases: a caixa visual com os números e, na L60, a
        linha "Nenhuma diferença" — o manifesto da T02 acompanha)."""
        tmp = tempfile.mkdtemp()
        codigo = NL.join(['import os, sys', "os.environ['CONJUNTO'] = 'inicio2'", f'sys.path.insert(0, {AQUI!r})',
                          'import gen_fases', 'gen_fases.OUT = sys.argv[1]', 'gen_fases.main()'])
        env = {**os.environ, 'CONJUNTO': 'inicio2', 'PYTHONIOENCODING': 'utf-8'}
        subprocess.run([sys.executable, '-c', codigo, tmp], cwd=RAIZ, env=env, check=True, capture_output=True)
        nomes = sorted(os.listdir(tmp))
        self.assertGreater(len(nomes), 10)
        for n in nomes:
            self.assertEqual(ler(os.path.join(tmp, n)), md(n[:-3]) if n.endswith('.md') else None, n)
        shutil.rmtree(tmp)

    @unittest.skipUnless(os.path.isdir(os.path.join(RAIZ, 'tools/medicao/tmp/conferencia_g01/layout')),
                         'sem a conferência da G01 (CONJUNTO=leitor_conferencia rodar_tudo.sh)')
    def test_leitor_como_na_g01(self):
        """As fases do leitor saem como na G01 (`LEGADO_G01`): a conferência regenerada = o `handoff_v2/fases`, mesmo
        com as três correções da T13.12 (que valem só para a Início e o projeto)."""
        tmp = tempfile.mkdtemp()
        codigo = NL.join(['import os, sys', "os.environ['CONJUNTO'] = 'leitor_conferencia'",
                          f'sys.path.insert(0, {AQUI!r})', 'import gen_fases', 'gen_fases.OUT = sys.argv[1]',
                          'gen_fases.main()'])
        env = {**os.environ, 'CONJUNTO': 'leitor_conferencia', 'PYTHONIOENCODING': 'utf-8'}
        subprocess.run([sys.executable, '-c', codigo, tmp], cwd=RAIZ, env=env, check=True, capture_output=True)
        nomes = sorted(n for n in os.listdir(tmp) if n.endswith('.md'))
        self.assertGreater(len(nomes), 20)
        for n in nomes:
            self.assertEqual(ler(os.path.join(tmp, n)), ler(os.path.join(RAIZ, 'handoff_v2', 'fases', n)), n)
        shutil.rmtree(tmp)

    def test_nome_da_fase(self):
        """R5: L + o número da tela, depois o da seção nas telas com mais de uma fase (1, 2, 3… seguidos)."""
        por_tela = {}
        for f in FASES:
            tela = PR[f['prancha']]['tela']
            partes = f['fase'].split('_')
            self.assertEqual(partes[0], 'L' + tela, f['fase'])
            por_tela.setdefault(f['prancha'], []).append(partes[1])
        for slug, segundas in por_tela.items():
            if len(segundas) > 1:
                self.assertEqual(segundas, [str(i + 1) for i in range(len(segundas))], slug)
        self.assertEqual(len(FASES), 73)
        self.assertEqual(sorted({f['prancha'] for f in FASES}), sorted(LAYOUTS))

    def test_irmas_citam_a_principal(self):
        for f in FASES:
            if not f.get('reusa'):
                continue
            texto = md(f['fase'])
            base = f['reusa']['base']
            self.assertIn(base, PR)
            self.assertIn(f"## Diferenças em relação à prancha {PR[base]['tela']} (seções reutilizadas: ", texto)

    def test_props_de_cada_tela(self):
        for f in FASES:
            texto = md(f['fase'])
            L = LAYOUTS[f['prancha']]
            props = L['meta']['props']
            if props:
                linha = 'Props do componente: ' + ', '.join('`{{' + k + '}}` = padrão `' + v + '`' for k, v in props.items()) + '.'
            else:
                linha = 'Props do componente: nenhuma (as cores desta tela são fixas).'
            self.assertIn(NL + linha + NL, texto, f['fase'])
            todas = {**gf.PROPS_PADRAO, **props}
            for nome, padrao in PROP.findall(texto):
                self.assertEqual(padrao, todas.get(nome), f"{f['fase']}: {nome}")
        self.assertIn('{{halo}} (padrão #ABCF82)', md('L17_1_capa'))

    def test_nas_outras_larguras(self):
        """As linhas da seção são as da fluidez e dos fios de navalha a 360 e 430 (T13.9) dos ids da fase."""
        for f in FASES:
            slug, ids = f['prancha'], set(ids_da(f))
            esperadas, facas = [], 0
            for w in (360, 430):
                for it in gf.LARG['fluidez'].get(f'{slug}_w{w}', []):
                    if it['id'] in ids:
                        esperadas.append((str(w), f"`{it['id']}`", gf.fmt(it['px']), gf.fmt(it['px390'])))
                for k, info in gf.LARG['facas'].get(f'{slug}_w{w}', {}).items():
                    if k in ids:
                        facas += len(info['riscos'])
            sec = secao_do_md(md(f['fase']), 'Nas outras larguras')
            linhas = [ln.split(' | ') for ln in sec if re.match('[|] (360|430) [|]', ln)]
            self.assertEqual([(c[0][2:], c[1], c[3], c[4]) for c in linhas], esperadas, f['fase'])
            self.assertEqual(sum(1 for ln in sec if re.match('- A (360|430): fio de navalha', ln)), facas, f['fase'])
            if not esperadas and not facas:
                self.assertTrue(any(ln.startswith('- Nada desta fase') for ln in sec), f['fase'])

    def test_fios_de_navalha_a_390_em_alguma_fase(self):
        """Cada risco de `knife_edges.json` (a 390) está nas armadilhas de exatamente uma fase da prancha — também o das
        seções reaproveitadas da base (a fileira do autor da 17b), com a marca de onde vem."""
        for slug, por_id in gf.KNI.items():
            fases = [f for f in FASES if f['prancha'] == slug]
            for k, info in por_id.items():
                citado = [f['fase'] for f in fases
                          for ln in secao_do_md(md(f['fase']), 'Armadilhas')
                          if ln.startswith('- Fio de navalha') and f'`{k}`' in ln]
                self.assertEqual(len(citado), len(info['riscos']), (slug, k, citado))
                if not citado:
                    continue  # sem risco: só as linhas medidas (o "Quadrinhos" da 28, que passa da caixa)
                self.assertEqual(len(set(citado)), 1, (slug, k, citado))
                f = next(x for x in fases if x['fase'] == citado[0])
                reusada = k.split('.')[1] not in f['secoes']
                linhas = [ln for ln in secao_do_md(md(f['fase']), 'Armadilhas') if f'`{k}`' in ln]
                self.assertEqual(all('seção reaproveitada da' in ln for ln in linhas), reusada, (slug, k))
        self.assertIn('d17b.meta', gf.KNI['017b_detalhes_ebook'])

    def test_html_literal_com_todas_as_secoes(self):
        """Cada seção da fase está no HTML literal — também as sem contêiner (a 1ª linha de cada id de topo)."""
        for f in FASES:
            slug = f['prancha']
            sem = LAYOUTS[slug]['meta'].get('secoesSemElemento') or {}
            nos = {n['tpl']: n for n in esboco(slug)}
            im = json.loads(ler(caminho('idmaps', f'{slug}.json')))
            tpl_de = {v: int(k) for k, v in im['ids'].items()}
            tpl = ler(caminho('extracao', slug, 'template.html'))
            html = NL.join(secao_do_md(md(f['fase']), 'HTML literal'))
            alvos = [i for s in secoes_da(f) for i in (sem.get(s) or [s])]
            nos_fase = [nos[tpl_de[i]] for i in alvos]
            # as de dentro de outra seção da fase saem junto com ela
            topo = [n for n in nos_fase if not any(o is not n and o['ini'] <= n['ini'] and n['fim'] <= o['fim']
                                                   for o in nos_fase)]
            # a 1ª linha PRÓPRIA de cada elemento de topo (do começo dele ao fim da linha ou dele) está no HTML, e tantas
            # vezes quantos são os elementos de topo com ela — T13.12: os confetes da 16 estão todos numa linha do
            # arquivo, e antes cada bloco levava junto os irmãos anteriores
            proprias = []
            for n in topo:
                fim = tpl.find(NL, n['ini'])
                proprias.append(tpl[n['ini']:min(n['fim'], fim if fim >= 0 else len(tpl))].strip())
            for p in set(proprias):
                self.assertEqual(html.count(p), proprias.count(p), f"{f['fase']}: {p[:80]}")
        self.assertTrue(any(LAYOUTS[s]['meta'].get('secoesSemElemento') for s in LAYOUTS))
        self.assertEqual(len(LAYOUTS['016_onboarding_carteirinha']['meta']['secoesSemElemento']['e16.confetti']), 10)

    def test_leia_me(self):
        arq = gf.C['fasesLeiaMe'][0]
        texto = ler(os.path.join(caminho('fases'), arq))
        for f in FASES:
            self.assertIn(f"| [{f['fase']}]({f['fase']}.md) | {f['titulo']} | {PR[f['prancha']]['etapa']} | ", texto)


class Notas(unittest.TestCase):
    """A parte escrita à mão: uma entrada por fase, completa, da etapa certa, sem rascunho."""

    def test_uma_nota_por_fase(self):
        self.assertEqual(sorted(notas.NOTAS), sorted(f['fase'] for f in FASES))

    def test_notas_completas(self):
        controle = re.compile('[' + ''.join(chr(c) for c in list(range(0, 9)) + [11, 12] + list(range(14, 32))) + ']')
        for f in FASES:
            n = notas.NOTAS[f['fase']]
            self.assertEqual(n['g'], PR[f['prancha']]['etapa'], f['fase'])
            self.assertEqual(set(n) - {'armadilhas'}, {'g', 'arquivos', 'contexto', 'leitura', 'interacoes', 'dados', 'subfases'},
                             f['fase'])
            for campo in ('arquivos', 'leitura', 'interacoes', 'dados', 'subfases') + (('armadilhas',) if 'armadilhas' in n else ()):
                self.assertTrue(n[campo] and all(isinstance(x, str) and x.strip() for x in n[campo]), f"{f['fase']} {campo}")
            self.assertGreaterEqual(len(n['contexto']), 60, f['fase'])
            self.assertGreaterEqual(len(n['leitura']), 3, f['fase'])
            self.assertGreaterEqual(len(n['subfases']), 2, f['fase'])
            self.assertEqual(n['subfases'][-1], comum.VERIFICACAO, f['fase'])
            for a in n['arquivos']:
                self.assertRegex(a, '^(features|core|app)/[a-z0-9_/]+[.]dart$', f['fase'])
            texto = json.dumps(n, ensure_ascii=False)
            for proibido in ('PROVISORIO', 'PROVISÓRIO', 'TODO', 'XXX', 'lorem'):
                self.assertNotIn(proibido, texto, f['fase'])
            juntos = ' '.join([n['contexto']] + [x for c in ('leitura', 'interacoes', 'dados', 'armadilhas', 'subfases')
                                                 for x in n.get(c, [])])
            self.assertIsNone(controle.search(juntos), f['fase'])

    def test_modulos_sem_barra_invertida(self):
        """A ferramenta de escrita decodifica sequências com barra invertida: os módulos de notas não têm nenhuma."""
        for m in ['fases_notas_projeto', 'fases_notas_projeto_comum'] + [f'fases_notas_projeto_t{i}' for i in range(14, 19)]:
            self.assertNotIn(chr(92), ler(os.path.join(AQUI, m + '.py')), m)

    def test_sem_destino(self):
        t = comum.sem_destino('T14', 'O toque no avatar')
        self.assertTrue(t.startswith('O toque no avatar: '))
        self.assertIn('D-243 b', t)
        self.assertIn('pergunta da T14', t)

    def test_agregador_recusa_fase_repetida(self):
        nomes = [f'fases_notas_projeto_t{i}' for i in range(14, 19)]
        antes = {n: sys.modules[n] for n in nomes}
        try:
            for i, n in enumerate(nomes):
                sys.modules[n] = types.SimpleNamespace(NOTAS={'L00_x' if i < 2 else f'L{i}_y': {}})
            with self.assertRaises(SystemExit):
                importlib.reload(notas)
        finally:
            sys.modules.update(antes)
            importlib.reload(notas)
        self.assertEqual(len(notas.NOTAS), 73)


if __name__ == '__main__':
    unittest.main()
