#!/usr/bin/env python3
"""
conferir_goldens.py — T01: refaz o gate visual de TODAS as telas com prancha de uma vez.

Os testes de `test/golden/` comparam o golden do app consigo mesmo; a comparação com o PNG do HTML era feita à mão,
fase a fase, com `tools/compare_images.py`. Este script roda essa comparação em todas as telas fiéis (a Início da v1
e as 19–27b do leitor): a tela inteira e os recortes de cada fase, com o mesmo método e o mesmo limite
(`blur_mismatch_% <= 0,5`). Sai uma tabela em Markdown.

Uso (na raiz do repositório):
  python3 tools/medicao/conferir_goldens.py                       # tabela no terminal
  python3 tools/medicao/conferir_goldens.py --saida build/visual_diff/conferir/tabela.md
  python3 tools/medicao/conferir_goldens.py --telas 23 23b --evidencias build/visual_diff/conferir

Código de saída: 1 se algum recorte reprovar (as exceções aprovadas não contam), mesmo que falte arquivo; senão 2
se faltar algum arquivo; senão 0.
Requer: pip install pillow numpy
"""
import argparse
import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
import compare_images as ci  # noqa: E402

GOLDENS = "test/golden/goldens"
PNG_V1 = "design_handoff/referencia/png"
LAYOUT_V1 = "design_handoff/referencia/layout"
PNG_V2 = "handoff_v2/referencia/png"

# Recortes das fases (y em px lógicos, a largura toda). As exceções aprovadas não reprovam a conferência: o número
# aparece na tabela com a decisão ao lado.
LEITOR = [
    ("19", "19_leitor_limpo_390x844@3x.png", [("L19", 84, 844)], {}),
    ("20", "20_leitor_controles_390x844@3x.png", [("L20", 46, 844)], {}),
    # D-55: a 21 é a versão corrigida da prancha.
    ("21", "21_selecao_texto_corrigida_390x844@3x.png", [("L21", 84, 844)], {}),
    (
        "22",
        "22_modo_anotacao_390x844@3x.png",
        [("L22a", 108, 844), ("L22b", 42, 110), ("L22c", 656, 754), ("L22d", 716, 822)],
        {},
    ),
    ("23", "23_ajustes_caneta_390x844@3x.png", [("L23", 117, 673.63)], {}),
    ("23b", "23b_ajustes_marcatexto_390x844@3x.png", [("L23b", 100.86, 673.63)], {}),
    ("24", "24_abrindo_espaco_390x844@3x.png", [("L24", 108, 844)], {}),
    ("24b", "24b_nota_mao_390x844@3x.png", [("L24b", 108, 844)], {}),
    (
        "25",
        "25_grifos_notas_390x2170@3x.png",
        [
            ("L25a", 46, 257.96),
            ("L25b", 253.96, 367.96),
            ("L25c", 377.96, 2099.98),
            ("L25d", 2109.98, 2170),
        ],
        # D-204: as miniaturas desenham a tinta salva do mundo; o arquivo desenha um <svg> próprio. A exceção vale para
        # a tela inteira (as miniaturas estão nela); os recortes L25a, L25b e L25d continuam no gate, e os vãos de 4 e
        # 10 px entre eles ficam só na conferência da tela.
        {"L25c": "D-204", "tela": "D-204"},
    ),
    ("26", "26_ajustes_leitura_390x844@3x.png", [("L26", 46, 842)], {}),
    ("26b", "26b_tema_noite_390x844@3x.png", [("L26b", 46, 844)], {}),
    ("27", "27_sumario_390x844@3x.png", [("L27", 84, 844)], {}),
    ("27b", "27b_sumario_marcadas_390x844@3x.png", [("L27b", 84, 842)], {}),
]


def _telas():
    """(tela, golden, referência, escala, regiões [(nome, (x, y, w, h))], exceções)."""
    out = []
    lay = json.load(open(os.path.join(LAYOUT_V1, "layout_inicio.json"), encoding="utf-8"))
    secoes = [("tela", (0, 0, 390, 2390))]
    w_canvas, h_canvas = lay["meta"]["canvas"]
    for nome, (x, y, w, h) in lay["sections"].items():
        m = 6.0  # a margem do compare_images.py --layout
        x0, y0 = max(0, x - m), max(0, y - m)
        x1, y1 = min(w_canvas, x + w + m), min(h_canvas, y + h + m)
        secoes.append((nome, (x0, y0, x1 - x0, y1 - y0)))
    out.append(("inicio", "inicio_canvas@3x.png", os.path.join(PNG_V1, "inicio_canvas_390x2390@3x.png"), 3, secoes, {}))
    out.append((
        "inicio_viewport",
        "inicio_viewport@3x.png",
        os.path.join(PNG_V1, "inicio_viewport_390x844_DERIVADA@3x.png"),
        3,
        [("tela", (0, 0, 390, 844))],
        {},
    ))
    for largura in (360, 430):
        out.append((
            "inicio_w%d" % largura,
            "inicio_w%d@2x.png" % largura,
            os.path.join(PNG_V1, "inicio_w%dx2390@2x.png" % largura),
            2,
            [("tela", (0, 0, largura, 2390))],
            {},
        ))
    for tela, ref, recortes, excecoes in LEITOR:
        altura = 2170 if tela == "25" else 844
        regioes = [("tela", (0, 0, 390, altura))]
        regioes += [(nome, (0, y0, 390, y1 - y0)) for nome, y0, y1 in recortes]
        out.append(("leitor_" + tela, "leitor_%s@3x.png" % tela, os.path.join(PNG_V2, ref), 3, regioes, excecoes))
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--telas", nargs="*", help="só estas (ex.: inicio 19 23b); padrão: todas")
    ap.add_argument("--goldens", default=GOLDENS, help="pasta dos goldens (padrão: %(default)s)")
    ap.add_argument("--saida", help="grava a tabela em Markdown neste arquivo")
    ap.add_argument("--evidencias", help="grava heatmap, lado a lado e onion de cada região nesta pasta")
    ap.add_argument("--gate", type=float, default=0.5)
    args = ap.parse_args()

    pedidas = set(args.telas or [])
    linhas = ["| Tela | Região | y (px lógicos) | blur_mismatch_% | raw_mismatch_% | Resultado |", "|---|---|---|---|---|---|"]
    ok_tudo, faltou = True, False
    for tela, golden, ref, escala, regioes, excecoes in _telas():
        curta = tela.replace("leitor_", "")
        if pedidas and tela not in pedidas and curta not in pedidas:
            continue
        caminho = os.path.join(args.goldens, golden)
        if not (os.path.exists(caminho) and os.path.exists(ref)):
            linhas.append("| %s | — | — | — | — | falta %s |" % (curta, caminho if not os.path.exists(caminho) else ref))
            faltou = True
            continue
        a, b = ci.load_rgb(ref), ci.load_rgb(caminho)
        if a.size != b.size:
            linhas.append("| %s | — | — | — | — | tamanhos diferentes %s × %s |" % (curta, a.size, b.size))
            ok_tudo = False
            continue
        for nome, rect in regioes:
            r, f = ci.crop(a, rect, escala), ci.crop(b, rect, escala)
            m, raw, blur = ci.metrics(r, f, escala, 1.5, 40, 24)
            passou = m["blur_mismatch_%"] <= args.gate
            excecao = excecoes.get(nome)
            if passou:
                resultado = "passou"
            elif excecao:
                resultado = "exceção %s" % excecao
            else:
                resultado = "**FALHOU**"
                ok_tudo = False
            if args.evidencias:
                ci.save_evidence(r, f, raw, blur, os.path.join(args.evidencias, curta), nome)
            y0, y1 = rect[1], rect[1] + rect[3]
            linhas.append("| %s | %s | %s–%s | %.4f | %.4f | %s |" % (
                curta, nome, ("%g" % round(y0, 2)).replace(".", ","), ("%g" % round(y1, 2)).replace(".", ","),
                m["blur_mismatch_%"], m["raw_mismatch_%"], resultado))
    tabela = "\n".join(linhas)
    print(tabela)
    if args.saida:
        os.makedirs(os.path.dirname(os.path.abspath(args.saida)), exist_ok=True)
        open(args.saida, "w", encoding="utf-8").write(tabela + "\n")
    sys.exit(1 if not ok_tudo else (2 if faltou else 0))


if __name__ == "__main__":
    main()
