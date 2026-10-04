#!/usr/bin/env python3
"""G01.3 — esboço da árvore de cada prancha para montar o idmap: numera os elementos do template
na mesma ordem do dc-runtime (data-dc-tpl = posição do elemento dentro de <x-dc>, começando em 1
no primeiro filho do <helmet>) e mostra profundidade, tag, comentário do arquivo, aria/role/título,
texto direto e o estilo inline resumido.
Uso: python3 tools/medicao/esboco.py <slug> [--json]
"""
import html
import json
import os
import re
import sys
from html.parser import HTMLParser

AQUI = os.path.dirname(__file__)
VOID = {'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'link', 'meta', 'source', 'track', 'wbr'}


class P(HTMLParser):
    def __init__(self, texto=''):
        super().__init__(convert_charrefs=True)
        # deslocamento absoluto do início de cada linha → posição (linha, coluna) do getpos() vira índice no texto
        self._linhas = [0]
        for ln in texto.splitlines(keepends=True):
            self._linhas.append(self._linhas[-1] + len(ln))
        self.on = False
        self.n = 0
        self.stack = []
        self.out = []
        self.last_comment = None

    def handle_starttag(self, tag, attrs):
        if tag == 'x-dc':
            self.on = True
            return
        if not self.on or tag == 'helmet':
            return
        self.n += 1
        a = dict(attrs)
        ln, col = self.getpos()
        ini = self._linhas[ln - 1] + col
        node = {'tpl': self.n, 'tag': tag, 'depth': len(self.stack), 'parent': self.stack[-1]['tpl'] if self.stack else None,
                'ini': ini, 'fim': ini + len(self.get_starttag_text() or ''),
                'attrs': {k: v for k, v in a.items() if k != 'style'}, 'style': a.get('style', ''),
                'comment': self.last_comment, 'text': ''}
        self.last_comment = None
        self.out.append(node)
        if tag not in VOID:
            self.stack.append(node)

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)
        if self.stack and self.stack[-1]['tag'] == tag and tag not in VOID:
            self.stack.pop()

    def handle_endtag(self, tag):
        if tag == 'x-dc':
            self.on = False
            return
        if not self.on or tag == 'helmet':
            return
        ln, col = self.getpos()
        fim = self._linhas[ln - 1] + col + len(tag) + 3
        while self.stack:
            n = self.stack.pop()
            n['fim'] = fim
            if n['tag'] == tag:
                break

    def handle_data(self, d):
        if self.on and self.stack and d.strip():
            self.stack[-1]['text'] += re.sub(r'\s+', ' ', d)

    def handle_comment(self, c):
        if self.on:
            self.last_comment = re.sub(r'\s+', ' ', c).strip()


def fatia(slug, tpl):
    """Marcação literal (do template, com {{props}}) do elemento tpl, incluindo o comentário que o precede."""
    texto = open(os.path.join(AQUI, 'pranchas', slug, 'template.html'), encoding='utf-8').read()
    n = next(x for x in esboco(slug) if x['tpl'] == tpl)
    return texto[n['ini']:n['fim']], n.get('comment')


def esboco(slug):
    tpl = open(os.path.join(AQUI, 'pranchas', slug, 'template.html'), encoding='utf-8').read()
    p = P(tpl)
    p.feed(tpl)
    for n in p.out:
        n['text'] = n['text'].strip()
    return p.out


if __name__ == '__main__':
    nodes = esboco(sys.argv[1])
    if '--json' in sys.argv:
        print(json.dumps(nodes, ensure_ascii=False, indent=1))
        sys.exit()
    for n in nodes:
        a = n['attrs']
        lab = ' '.join(f'{k}="{a[k]}"' for k in ('aria-label', 'role', 'title', 'aria-hidden', 'aria-pressed', 'aria-current', 'aria-checked') if k in a)
        st = re.sub(r'\s+', ' ', n['style'])
        print(f"{'  ' * n['depth']}{n['tpl']:>3} <{n['tag']}> " + (f"/* {n['comment']} */ " if n['comment'] else '') + lab + (f' «{n["text"][:60]}»' if n['text'] else '') + (f'  [{st[:150]}]' if st and '--style' in sys.argv else ''))
