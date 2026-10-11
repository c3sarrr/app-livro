#!/usr/bin/env python3
# R00 (R3) — as ligações do Mapa de navegação (tela 00, `docs/design/projeto/telas/MapaNavegacao.dc.html`), lidas da
# geometria: o mapa é estático (cartões em `position: absolute` com left/top/width/height em px do quadro de
# 1700 × 1300; as setas num único <svg viewBox="0 0 1700 1300">, curvas `M x y C … x y` com `marker-end`), então não
# precisa de Chromium. Cada ponta de seta cai num cartão (com folga); a ponta `M` é a origem e a última coordenada,
# com a ponta de seta, o destino. Seta com uma ponta fora de qualquer cartão vai para `sem_par` — nada some calado.
#
# Rodar da raiz do repositório:
#   PYTHONIOENCODING=utf-8 python3 tools/medicao/mapa_navegacao.py [--mapa <arquivo>] [--saida <arquivo.json>]
# Saída 1 quando há seta sem par.
import argparse
import html
import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]

CARTAO = re.compile(
    r'<div style="position: absolute; left: ([\d.]+)px; top: ([\d.]+)px; width: ([\d.]+)px; height: ([\d.]+)px;'
    r'([^"]*)"><span[^>]*>([^<]+)</span><span[^>]*>([^<]+)</span></div>')
SECAO = re.compile(
    r'<section aria-label="([^"]+)" style="position: absolute; left: ([\d.]+)px; top: ([\d.]+)px; '
    r'width: ([\d.]+)px; height: ([\d.]+)px;')
SETA = re.compile(r'<path d="M([\d.]+) ([\d.]+) C([\d. ]+)"([^>]*)>')
FOLGA = 8.0


def cartoes_de(texto):
    out = []
    for x, y, w, h, estilo, numero, titulo in CARTAO.findall(texto):
        out.append({
            'numero': None if numero == '+' else html.unescape(numero),
            'titulo': html.unescape(titulo),
            'faltando': numero == '+' or 'dashed' in estilo,
            'x': float(x), 'y': float(y), 'w': float(w), 'h': float(h),
        })
    return out


def secao_de(c, secoes):
    for s in secoes:
        if s['x'] <= c['x'] <= s['x'] + s['w'] and s['y'] <= c['y'] <= s['y'] + s['h']:
            return s['nome']
    return None


def cartao_em(x, y, cartoes):
    """O cartão que contém (x, y) com a folga; entre vários, o de centro vertical mais perto."""
    dentro = [c for c in cartoes
              if c['x'] - FOLGA <= x <= c['x'] + c['w'] + FOLGA and c['y'] - FOLGA <= y <= c['y'] + c['h'] + FOLGA]
    return min(dentro, key=lambda c: abs(c['y'] + c['h'] / 2 - y)) if dentro else None


def rotulo(c):
    return f"{c['numero']} · {c['titulo']}" if c['numero'] else f"+ {c['titulo']}"


def ler(mapa):
    texto = mapa.read_text(encoding='utf-8')
    secoes = [{'nome': html.unescape(n), 'x': float(x), 'y': float(y), 'w': float(w), 'h': float(h)}
              for n, x, y, w, h in SECAO.findall(texto)]
    cartoes = cartoes_de(texto)
    for c in cartoes:
        c['secao'] = secao_de(c, secoes)
    ligacoes, sem_par = [], []
    for x0, y0, resto, atributos in SETA.findall(texto):
        nums = [float(v) for v in resto.split()]
        x1, y1 = nums[-2], nums[-1]
        de, para = cartao_em(float(x0), float(y0), cartoes), cartao_em(x1, y1, cartoes)
        seta_fim, seta_inicio = 'marker-end' in atributos, 'marker-start' in atributos
        if de is None or para is None:
            sem_par.append({'de': [float(x0), float(y0)], 'para': [x1, y1],
                            'cartao_de': de and rotulo(de), 'cartao_para': para and rotulo(para)})
            continue
        if seta_fim or not seta_inicio:
            ligacoes.append({'de': rotulo(de), 'para': rotulo(para), 'ida_e_volta': seta_fim and seta_inicio})
        else:
            ligacoes.append({'de': rotulo(para), 'para': rotulo(de), 'ida_e_volta': False})
    barra = re.search(r'Barra de baixo</strong>(.*?)</div>', texto, re.S)
    return {
        'fonte': mapa.relative_to(RAIZ).as_posix(),
        'secoes': [s['nome'] for s in secoes],
        'cartoes': cartoes,
        'ligacoes': ligacoes,
        'sem_par': sem_par,
        'barra_de_baixo': re.sub(r'\s+', ' ', html.unescape(re.sub('<[^>]+>', '', barra.group(1)))).strip()
        if barra else None,
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--mapa', default=str(RAIZ / 'docs/design/projeto/telas/MapaNavegacao.dc.html'))
    ap.add_argument('--saida', default=str(RAIZ / 'docs/design/medicao/projeto/mapa_navegacao.json'))
    args = ap.parse_args()
    dados = ler(Path(args.mapa).resolve())
    saida = Path(args.saida).resolve()
    saida.parent.mkdir(parents=True, exist_ok=True)
    saida.write_text(json.dumps(dados, ensure_ascii=False, indent=1) + '\n', encoding='utf-8', newline='\n')
    desenhados = sum(1 for c in dados['cartoes'] if not c['faltando'])
    print(f"{len(dados['cartoes'])} cartões ({desenhados} telas + {len(dados['cartoes']) - desenhados} faltando) · "
          f"{len(dados['ligacoes'])} ligações · {len(dados['sem_par'])} sem par · {saida.relative_to(RAIZ).as_posix()}")
    for s in dados['sem_par']:
        print('  SEM PAR', s)
    return 1 if dados['sem_par'] else 0


if __name__ == '__main__':
    sys.exit(main())
