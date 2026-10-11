"""S1 — extrai a amostra de texto do EPUB real de Dom Casmurro (Project Gutenberg #55752).

Uso: python3 extrair_amostra.py <pg55752.epub> <saida.json>
Pega os parágrafos (<p>) dos capítulos XXXII e XXXIII, com espaços colapsados e NFC
(o mesmo texto canônico do Anexo 03 §4), e confere que todos os caracteres existem no
subconjunto latin da Literata do arquivo (senão a comparação mediria a fonte de fallback).
"""
import hashlib
import json
import re
import sys
import unicodedata
import zipfile
from html.parser import HTMLParser

CAPITULOS = ('XXXII', 'XXXIII')


class Paragrafos(HTMLParser):
    def __init__(self):
        super().__init__()
        self.cap = None
        self.em_p = False
        self.buf = []
        self.saida = []  # (capítulo, texto)

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag == 'a' and a.get('id', '') and re.fullmatch(r'[IVXLC]+', a['id']):
            self.cap = a['id']
        if tag == 'p':
            self.em_p = True
            self.buf = []
        if tag == 'br' and self.em_p:
            self.buf.append(' ')

    def handle_endtag(self, tag):
        if tag == 'p' and self.em_p:
            self.em_p = False
            t = unicodedata.normalize('NFC', re.sub(r'\s+', ' ', ''.join(self.buf)).strip())
            if t and self.cap in CAPITULOS:
                self.saida.append((self.cap, t))

    def handle_data(self, data):
        if self.em_p:
            self.buf.append(data)


def main(epub, saida):
    bruto = open(epub, 'rb').read()
    z = zipfile.ZipFile(epub)
    p = Paragrafos()
    for nome in sorted(n for n in z.namelist() if n.endswith('-h-0.htm.xhtml')):
        p.feed(z.read(nome).decode('utf-8'))
    from fontTools.ttLib import TTFont
    cmap = TTFont(sys.argv[3] if len(sys.argv) > 3 else 'assets/fonts/Literata-VF.ttf').getBestCmap()
    fora = sorted({c for _, t in p.saida for c in t if ord(c) not in cmap})
    assert not fora, f'caracteres fora da Literata latin: {fora}'
    json.dump({
        'fonte': 'Project Gutenberg #55752 (Dom Casmurro, Machado de Assis — domínio público)',
        'epub_sha256': hashlib.sha256(bruto).hexdigest(),
        'capitulos': list(CAPITULOS),
        'paragrafos': [t for _, t in p.saida],
    }, open(saida, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print(len(p.saida), 'parágrafos;', sum(len(t) for _, t in p.saida), 'caracteres')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
