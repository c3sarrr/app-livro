#!/usr/bin/env python3
"""
compare_images.py — comparação visual Flutter × referência (tela Início).

Compara o PNG gerado pelo golden do Flutter com o PNG de referência renderizado
a partir do HTML original, e gera evidências objetivas:

  * raw_mismatch_%   : % de pixels cuja diferença máxima por canal > --thr-raw
                       (sensível a anti-aliasing; serve como diagnóstico)
  * blur_mismatch_%  : % de pixels diferentes DEPOIS de desfocar as duas imagens
                       com sigma = --blur px lógicos (neutraliza diferenças de
                       rasterização/anti-aliasing entre motores). MÉTRICA DE GATE.
                       Calibração (sigma 1,5, limiar 24, gate 0,5%): reamostragem
                       diferente = 0%; deslocamento de 0,33 px lógico = 0–0,3%
                       (passa); 0,67 px = 0,5–6% (falha na maioria das seções);
                       1 px = 3–19% (falha sempre).
  * mean_abs_diff    : diferença média absoluta (0–255)
  * heatmap / lado-a-lado / onion-skin em PNG para inspeção visual

Uso básico (canvas inteiro @3x):
  python3 compare_images.py --flutter test/golden/goldens/inicio_canvas@3x.png \
      --ref design_handoff/referencia/png/inicio_canvas_390x2390@3x.png \
      --scale 3 --out build/visual_diff --name canvas

Uma seção (retângulo em px lógicos, ex.: hero):
  python3 compare_images.py ... --rect 16,244,358,283 --name hero

Todas as seções de uma vez (usa layout_inicio.json):
  python3 compare_images.py ... --layout design_handoff/referencia/layout/layout_inicio.json

Saída: código 0 se todas as regiões passarem no gate (blur_mismatch <= --gate),
       código 1 caso contrário.
Requer: pip install pillow numpy
"""
import argparse
import json
import os
import sys

import numpy as np
from PIL import Image, ImageFilter

PAPER = (247, 240, 227)  # #F7F0E3 — fundo usado para achatar transparência


def load_rgb(path):
    im = Image.open(path)
    if im.mode in ("RGBA", "LA") or (im.mode == "P" and "transparency" in im.info):
        im = im.convert("RGBA")
        bg = Image.new("RGBA", im.size, PAPER + (255,))
        im = Image.alpha_composite(bg, im)
    return im.convert("RGB")


def metrics(ref, flt, scale, blur_sigma, thr_raw, thr_blur):
    a = np.asarray(ref).astype(np.int16)
    b = np.asarray(flt).astype(np.int16)
    raw = np.abs(a - b).max(axis=2)
    radius = blur_sigma * scale
    ab = np.asarray(ref.filter(ImageFilter.GaussianBlur(radius))).astype(np.int16)
    bb = np.asarray(flt.filter(ImageFilter.GaussianBlur(radius))).astype(np.int16)
    blur = np.abs(ab - bb).max(axis=2)
    n = raw.size
    return {
        "raw_mismatch_%": round(100.0 * float((raw > thr_raw).sum()) / n, 4),
        "blur_mismatch_%": round(100.0 * float((blur > thr_blur).sum()) / n, 4),
        "mean_abs_diff": round(float(np.abs(a - b).mean()), 3),
        "max_diff": int(raw.max()),
    }, raw, blur


def save_evidence(ref, flt, raw, blur, out_dir, name):
    os.makedirs(out_dir, exist_ok=True)
    w, h = ref.size
    # heatmap: referência em cinza clarinho + diferenças (desfocadas) em vermelho
    gray = np.asarray(ref.convert("L")).astype(np.float32)
    base = 200 + gray * (55.0 / 255.0)
    heat = np.stack([base, base, base], axis=2)
    intensity = np.clip(blur.astype(np.float32) * 4.0, 0, 255)
    heat[..., 0] = np.maximum(heat[..., 0], intensity)
    heat[..., 1] = heat[..., 1] * (1 - intensity / 255.0)
    heat[..., 2] = heat[..., 2] * (1 - intensity / 255.0)
    heat_img = Image.fromarray(heat.astype(np.uint8))
    heat_img.save(os.path.join(out_dir, f"{name}_heatmap.png"))
    side = Image.new("RGB", (w * 3 + 20, h), (255, 255, 255))
    side.paste(ref, (0, 0))
    side.paste(flt, (w + 10, 0))
    side.paste(heat_img, (2 * w + 20, 0))
    side.save(os.path.join(out_dir, f"{name}_lado_a_lado.png"))
    Image.blend(ref, flt, 0.5).save(os.path.join(out_dir, f"{name}_onion.png"))


def crop(im, rect, scale):
    x, y, w, h = rect
    box = (int(round(x * scale)), int(round(y * scale)),
           int(round((x + w) * scale)), int(round((y + h) * scale)))
    return im.crop(box)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--flutter", required=True)
    ap.add_argument("--ref", required=True)
    ap.add_argument("--scale", type=float, default=3.0, help="device pixel ratio das duas imagens")
    ap.add_argument("--rect", help="x,y,w,h em px lógicos (opcional)")
    ap.add_argument("--layout", help="layout_inicio.json para comparar seção por seção")
    ap.add_argument("--margin", type=float, default=6.0, help="margem (px lógicos) ao redor de cada seção")
    ap.add_argument("--blur", type=float, default=1.5, help="sigma do desfoque em px lógicos (calibrado: 0,33 px de deslocamento passa; >= 0,67 px falha)")
    ap.add_argument("--thr-raw", type=int, default=40)
    ap.add_argument("--thr-blur", type=int, default=24)
    ap.add_argument("--gate", type=float, default=0.5, help="limite de blur_mismatch_% para PASSAR")
    ap.add_argument("--out", default="build/visual_diff")
    ap.add_argument("--name", default="comparacao")
    args = ap.parse_args()

    ref = load_rgb(args.ref)
    flt = load_rgb(args.flutter)
    if ref.size != flt.size:
        print(f"ERRO: tamanhos diferentes ref={ref.size} flutter={flt.size}. "
              f"Renderize o golden no MESMO tamanho lógico e DPR da referência.")
        sys.exit(2)

    regions = []
    if args.layout:
        lay = json.load(open(args.layout, encoding="utf-8"))
        W, H = lay["meta"]["canvas"]
        for name, (x, y, w, h) in lay["sections"].items():
            m = args.margin
            x0, y0 = max(0, x - m), max(0, y - m)
            x1, y1 = min(W, x + w + m), min(H, y + h + m)
            regions.append((name, (x0, y0, x1 - x0, y1 - y0)))
    elif args.rect:
        regions.append((args.name, tuple(float(v) for v in args.rect.split(","))))
    else:
        regions.append((args.name, (0, 0, ref.size[0] / args.scale, ref.size[1] / args.scale)))

    report, ok_all = {}, True
    print(f"{'região':<14}{'blur_mismatch_%':>17}{'raw_mismatch_%':>16}{'mean_abs':>10}{'max':>6}  resultado")
    for name, rect in regions:
        r, f = crop(ref, rect, args.scale), crop(flt, rect, args.scale)
        m, raw, blur = metrics(r, f, args.scale, args.blur, args.thr_raw, args.thr_blur)
        ok = m["blur_mismatch_%"] <= args.gate
        ok_all &= ok
        m["rect_logico"] = rect
        m["passou"] = ok
        report[name] = m
        save_evidence(r, f, raw, blur, args.out, name)
        print(f"{name:<14}{m['blur_mismatch_%']:>17}{m['raw_mismatch_%']:>16}{m['mean_abs_diff']:>10}{m['max_diff']:>6}  {'PASSOU' if ok else 'FALHOU'}")
    os.makedirs(args.out, exist_ok=True)
    json.dump(report, open(os.path.join(args.out, f"{args.name}_relatorio.json"), "w"), indent=1)
    print(f"\nEvidências em: {args.out}  (heatmap, lado_a_lado, onion, relatorio.json)")
    sys.exit(0 if ok_all else 1)


if __name__ == "__main__":
    main()
