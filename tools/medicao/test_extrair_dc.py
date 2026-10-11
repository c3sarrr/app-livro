#!/usr/bin/env python3
"""T13.1–T13.2 — testes da extração dos `.dc.html` (`extrair_dc.py`) e das fontes do css2 (`fontes_css2.py`).

Rodar da raiz do repositório (Python puro):
  PYTHONIOENCODING=utf-8 python3 -m unittest tools/medicao/test_extrair_dc.py -v
Os testes contra as exportações antigas usam as extrações delas (fora do git): `tools/medicao/pranchas_inicio2/`,
`tools/medicao/pranchas/` e `tools/medicao/tmp/r00/pranchas_clube/` (esta, refeita por `conferir_projeto.py`).
"""
import hashlib
import html
import io
import json
import os
import re
import shutil
import sys
import tempfile
import unittest

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
import esboco  # noqa: E402
import extrair_dc  # noqa: E402
import fontes_css2  # noqa: E402

RAIZ = fontes_css2.RAIZ
PROJETO = os.path.join(RAIZ, 'docs', 'design', 'projeto')
INDICE = os.path.join(AQUI, 'pranchas_projeto.json')
INDICES_CONFERENCIA = [os.path.join(AQUI, f'pranchas_projeto_conferencia_{n}.json') for n in ('inicio2', 'leitor')]
PASTAS_ANTIGAS = {'Início e revisão': os.path.join(AQUI, 'pranchas_inicio2'),
                  'Leitor': os.path.join(AQUI, 'pranchas'),
                  'Clube': os.path.join(AQUI, 'tmp', 'r00', 'pranchas_clube')}
# Os textos que saem de todos os subconjuntos das fontes da tela e caem na reserva do sistema (a Inter no ambiente de
# medição — D-54, o "≈" do leitor): (tela, caractere). Qualquer outro caractere fora do latin falha.
FORA_DE_TODAS = {('telas/BuscaVazia.dc.html', '→'), ('telas/NotificacoesAjustes.dc.html', '→'),
                 ('telas/DetalhesDigital.dc.html', '≈'),
                 ('telas/LeitorControles.dc.html', '≈'), ('telas/LeitorNoite.dc.html', '≈')}


def ler(caminho):
    with io.open(caminho, encoding='utf-8') as f:
        return f.read()


def sha(caminho):
    with open(caminho, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()


def telas_do_indice(indice):
    return json.loads(ler(indice))['pranchas']


def antigas():
    """As 35 telas que já tinham exportação: (grupo, pasta antiga da tela, arquivo do projeto)."""
    out = []
    for linha in ler(os.path.join(RAIZ, 'docs', 'design', 'medicao', 'projeto', 'conferencia_projeto.md')).splitlines():
        m = re.match(r'^\| ([^|]+?) \| \w+ \| `([^`]+)` \| `(telas/[^`]+)` \|', linha)
        if m:
            out.append((m.group(1), os.path.join(PASTAS_ANTIGAS[m.group(1)], m.group(2)), m.group(3)))
    return out


def faixas(unicode_range):
    out = []
    for p in unicode_range.split(','):
        a, _, b = p.strip()[2:].partition('-')
        out.append((int(a, 16), int(b or a, 16)))
    return out


def texto_da_tela(conteudo):
    """O texto visível da tela: fora do <helmet>, sem o interior dos <svg> (salvo os <text>)."""
    corpo = conteudo[conteudo.index('</helmet>'):conteudo.index('</x-dc>')]
    corpo = re.sub(r'<svg[\s\S]*?</svg>', lambda m: re.sub(r'<(?!/?text\b)[^>]*>', ' ', m.group(0)), corpo)
    return html.unescape(re.sub(r'<[^>]+>', ' ', corpo))


class FontesDoCss2(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tabela = fontes_css2.tabela()
        faltam = [p for p in PASTAS_ANTIGAS.values() if not os.path.isdir(p)]
        if faltam:
            raise unittest.SkipTest(f'extrações antigas fora do disco: {faltam} (refazer pela R00/T02)')
        man = json.loads(ler(os.path.join(fontes_css2.ORIGINAIS, 'manifesto.json')))['arquivos']
        cls.sha_da_url = {v['url']: v['sha256'] for v in man.values()}

    def _divergencia_aceita(self, pasta, face):
        return any(d['familia'] == face['familia'] and d['subconjunto'] == face['subconjunto']
                   and d['unicodeRange'] == face['unicodeRange'] and os.path.join(RAIZ, *d['pasta'].split('/')) == pasta
                   for d in self.tabela['_divergencias'])

    def _sha_do_src(self, src, assets=None):
        if src.startswith('http'):
            return self.sha_da_url.get(src, src)
        if assets:
            return sha(os.path.join(assets, src + '.woff2'))
        return sha(os.path.join(RAIZ, *src.split('/')))

    def test_faces_iguais_aos_helmets_antigos(self):
        """R2: nas 35 exportações antigas, as faces montadas pela consulta do `.dc.html` = as do helmet antigo."""
        lista = antigas()
        self.assertEqual(len(lista), 35)
        for grupo, pasta, arq in lista:
            with self.subTest(tela=arq):
                antigo = ler(os.path.join(pasta, 'template.html'))
                velhas = fontes_css2.faces_do_css(antigo[antigo.index('<helmet>'):antigo.index('</helmet>')])
                novas = fontes_css2.faces(fontes_css2.href_da_tela(ler(os.path.join(PROJETO, *arq.split('/')))),
                                          self.tabela)
                self.assertEqual(len(novas), len(velhas))
                for v, n in zip(velhas, novas):
                    for campo in ('subconjunto', 'familia', 'estilo', 'peso', 'stretch', 'display'):
                        self.assertEqual(v[campo], n[campo], f'{campo}: {v} × {n}')
                    if v['unicodeRange'] != n['unicodeRange']:
                        self.assertTrue(self._divergencia_aceita(os.path.dirname(pasta), v), f'unicode-range: {v}')
                    self.assertEqual(self._sha_do_src(v['src'], os.path.join(pasta, 'assets')),
                                     self._sha_do_src(n['src']), f'binário: {v} × {n}')

    def test_faces_iguais_ao_css2_real(self):
        """R2 (D-273): as faces montadas = as das respostas do css2 baixadas para as consultas das 41 (menos o latin
        das famílias que o arquivo antigo embutia, que o css2 serve por outra URL do mesmo binário)."""
        consultas = json.loads(ler(os.path.join(fontes_css2.CSS2_PROJETO, 'consultas.json')))['consultas']
        self.assertEqual(len(consultas), 5)
        for c in consultas:
            with self.subTest(consulta=c['arquivo']):
                reais = fontes_css2.faces_do_css(ler(os.path.join(fontes_css2.CSS2_PROJETO, c['arquivo'])))
                novas = fontes_css2.faces(c['url'], self.tabela)
                self.assertEqual(len(novas), len(reais))
                for r, n in zip(reais, novas):
                    for campo in ('subconjunto', 'familia', 'estilo', 'peso', 'stretch', 'display', 'unicodeRange'):
                        self.assertEqual(r[campo], n[campo], f'{campo}: {r} × {n}')
                    if r['subconjunto'] != 'latin' or r['src'] in self.sha_da_url:
                        self.assertEqual(self.sha_da_url.get(r['src'], r['src']), self._sha_do_src(n['src']))

    def test_versoes_iguais(self):
        """D-273: nas respostas de hoje, os subconjuntos fora do latin das famílias que já tínhamos estão nas mesmas
        URLs (a versão está na URL: …/figtree/v9/…) — o desenho usou as fontes que temos."""
        for c in json.loads(ler(os.path.join(fontes_css2.CSS2_PROJETO, 'consultas.json')))['consultas']:
            for f in fontes_css2.faces_do_css(ler(os.path.join(fontes_css2.CSS2_PROJETO, c['arquivo']))):
                if f['subconjunto'] == 'latin':
                    continue
                b = self.tabela['binarios'][fontes_css2._chave(f['familia'], f['estilo'], f['subconjunto'])]
                self.assertEqual(f['src'], b.get(f['peso']) or b.get('*'), f'{c["arquivo"]}: {f}')

    def test_numeracao_igual_a_antiga(self):
        """O helmet continua com 3 filhos: nas 35, o template novo numera os elementos como o antigo (quadro no 4)."""
        tabela = self.tabela
        for grupo, pasta, arq in antigas():
            with self.subTest(tela=arq):
                _, novo, _ = extrair_dc.montar(ler(os.path.join(PROJETO, *arq.split('/'))), tabela)
                seqs = []
                for t in (ler(os.path.join(pasta, 'template.html')), novo):
                    p = esboco.P(t)
                    p.feed(t)
                    seqs.append([(n['tpl'], n['tag'], n['parent']) for n in p.out])
                self.assertEqual(seqs[0], seqs[1])
                self.assertEqual(seqs[1][3][:2], (4, 'div'))


class Extracao(unittest.TestCase):
    def test_preview_igual_ao_catalogo(self):
        cat = extrair_dc.catalogo(PROJETO)
        telas = telas_do_indice(INDICE)
        self.assertEqual(len(telas), 41)
        for p in telas:
            with self.subTest(tela=p['tela']):
                titulo, tam, sha12 = cat[p['arquivo']]
                pr = extrair_dc.props(ler(os.path.join(PROJETO, *p['arquivo'].split('/'))))
                self.assertEqual([pr['$preview']['width'], pr['$preview']['height']], tam)
                self.assertEqual(p['canvas'], tam)
                self.assertEqual(p['titulo'], titulo)
                self.assertEqual(sha(os.path.join(PROJETO, *p['arquivo'].split('/')))[:12], sha12)

    def test_consultas_conhecidas(self):
        """Toda consulta das 41 e das 19 da conferência tem os binários na tabela."""
        tabela = fontes_css2.tabela()
        for indice in [INDICE] + INDICES_CONFERENCIA:
            for p in telas_do_indice(indice):
                with self.subTest(tela=p['arquivo']):
                    fontes_css2.faces(fontes_css2.href_da_tela(ler(os.path.join(PROJETO, *p['arquivo'].split('/')))),
                                      tabela)

    def test_sem_texto_que_so_os_outros_subconjuntos_cobririam(self):
        """Só o latin é local: nenhum texto das telas pode depender dos outros subconjuntos. Fora do latin, só os
        caracteres de FORA_DE_TODAS, que nenhum subconjunto tem (caem na reserva, como o "≈" da D-54)."""
        tabela = fontes_css2.tabela()
        achados = set()
        for indice in [INDICE] + INDICES_CONFERENCIA:
            for p in telas_do_indice(indice):
                conteudo = ler(os.path.join(PROJETO, *p['arquivo'].split('/')))
                faces = fontes_css2.faces(fontes_css2.href_da_tela(conteudo), tabela)
                latin = [x for f in faces if f['subconjunto'] == 'latin' for x in faixas(f['unicodeRange'])]
                outros = [x for f in faces if f['subconjunto'] != 'latin' for x in faixas(f['unicodeRange'])]
                for c in set(texto_da_tela(conteudo)):
                    if c.isspace() or any(a <= ord(c) <= b for a, b in latin):
                        continue
                    self.assertFalse(any(a <= ord(c) <= b for a, b in outros),
                                     f'{p["arquivo"]}: "{c}" (U+{ord(c):04X}) só num subconjunto que não é o latin')
                    achados.add((p['arquivo'], c))
        self.assertEqual(achados, FORA_DE_TODAS)

    def test_extracao_de_uma_tela(self):
        """A pasta da tela: o original renderizável (sem o css2, helmet com 3 filhos, latin em assets/), o template
        com o id do binário, o runtime, as props e os binários iguais aos locais."""
        tmp = tempfile.mkdtemp(prefix='t13_extr_')
        try:
            cfg = json.loads(ler(INDICE))
            cfg['pranchas'] = [p for p in cfg['pranchas'] if p['tela'] in ('02', '07')]
            indice = os.path.join(tmp, 'indice.json')
            with io.open(indice, 'w', encoding='utf-8') as f:
                json.dump(cfg, f, ensure_ascii=False)
            self.assertEqual(extrair_dc.extrair(indice, os.path.join(tmp, 'saida')), 0)
            rel = json.loads(ler(os.path.join(tmp, 'saida', 'extracao.json')))
            for p in cfg['pranchas']:
                with self.subTest(tela=p['tela']):
                    d = os.path.join(tmp, 'saida', p['slug'])
                    fonte = ler(os.path.join(PROJETO, *p['arquivo'].split('/')))
                    orig, tpl = ler(os.path.join(d, 'original.html')), ler(os.path.join(d, 'template.html'))
                    for t in (orig, tpl):
                        self.assertNotIn('fonts.googleapis.com/css2', t)
                        hel = t[t.index('<helmet>') + 8:t.index('</helmet>')]
                        self.assertEqual(re.findall(r'<(link|style)\b', hel), ['link', 'style', 'style'])
                        self.assertEqual(t[t.index('</helmet>'):], fonte[fonte.index('</helmet>'):])
                    locais = re.findall(r'url\(assets/([^)]+)\.woff2\)', orig)
                    self.assertTrue(locais)
                    self.assertEqual(sorted(set(locais)), sorted(set(re.findall(r'url\("([^"]+)"\)', tpl))))
                    for i in set(locais):
                        b = os.path.join(d, 'assets', i + '.woff2')
                        self.assertIn(sha(b), {sha(os.path.join(fontes_css2.FONTES_DO_ARQUIVO, x))
                                               for x in os.listdir(fontes_css2.FONTES_DO_ARQUIVO)}
                                      | {sha(os.path.join(fontes_css2.ORIGINAIS, x))
                                         for x in os.listdir(fontes_css2.ORIGINAIS) if x.endswith('.woff2')})
                    self.assertEqual(sha(os.path.join(d, 'support.js')), sha(os.path.join(PROJETO, 'dc-runtime.js')))
                    self.assertEqual(json.loads(ler(os.path.join(d, 'props.json'))), extrair_dc.props(fonte))
                    self.assertEqual(rel['pranchas'][p['slug']]['sha256'], hashlib.sha256(fonte.encode('utf-8')).hexdigest())
            self.assertIn('Roboto', ler(os.path.join(tmp, 'saida', '007_login', 'original.html')))
        finally:
            shutil.rmtree(tmp, ignore_errors=True)


if __name__ == '__main__':
    unittest.main()
