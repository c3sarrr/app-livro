"""R00.8 (R7) — a prova das 16 telas prontas no Galaxy S22+, lado a lado com as pranchas.

Roda o roteiro do aparelho (`integration_test/capturas_r00_test.dart`) com o `flutter drive` em perfil e, a cada linha
`R00CAP <nn>` que ele imprime (o app parado no estado da prancha), tira a captura da tela pelo `adb`. No fim monta, para
cada tela, a captura e o PNG da prancha na mesma altura, com o título embaixo. A faixa dos ícones de notificação da
barra do Android é coberta em cada captura (o repositório é público e os ícones são os do celular do Cesar); o
relógio, a rede e a bateria ficam.

Os dados do Cesar moram no app instalado (`booknest.db`); o roteiro só abre o banco do demo (`booknest_demo.db`, D-267).
Antes de instalar (`tools/celular/aparelho.py`), confere que o APK instalado foi assinado com a chave de debug deste
computador — a que assina o build do `flutter drive` (senão o `adb install -r` falha e o `flutter` desinstala o app
para tentar de novo, e os dados vão junto) — e que há espaço; guarda o APK do app normal (como o `demo.py`) e roda o
`flutter drive` com `--keep-app-running` (sem ele o `flutter drive` desinstala o app no fim). No fim o ícone abre o
build do roteiro: `python3 tools/celular/demo.py --voltar` devolve o app normal.

    python3 tools/celular/capturar_r00.py [--alvo 1|2] [--aparelho RXCT200CA6F] [--so-montar]

`--alvo 2` = o `main_mundo_referencia.dart` (a Início igual à prancha): só as 3 telas da Início (`<nn>_prancha_*`).
"""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
import aparelho as ap  # noqa: E402
import demo  # noqa: E402

RAIZ = Path(__file__).resolve().parents[2]
# o tamanho de um build de perfil do roteiro (≈ 70 MB em 11/10/2026), com folga: a conferência pede 3× livres
TAMANHO_DO_BUILD_MB = 120

INICIO2 = RAIZ / "docs" / "design" / "medicao" / "inicio2" / "png"
LEITOR = RAIZ / "handoff_v2" / "referencia" / "png"

# (número, título, PNG da prancha @3x) — a 01 e a 25 são mais altas que a tela: entra o topo (844 lógicos)
TELAS: list[tuple[str, str, Path]] = [
    ("01", "Início", INICIO2 / "001_inicio_390x2650@3x.png"),
    ("60", "Início — grifos de hoje (revisão)", INICIO2 / "060_inicio_grifos_de_hoje_390x844@3x.png"),
    ("01b", "Início — lendo agora", INICIO2 / "001b_inicio_lendo_agora_390x844@3x.png"),
    ("19", "Leitor — modo limpo", LEITOR / "19_leitor_limpo_390x844@3x.png"),
    ("20", "Leitor — com controles", LEITOR / "20_leitor_controles_390x844@3x.png"),
    ("21", "Leitor — seleção de texto", LEITOR / "21_selecao_texto_corrigida_390x844@3x.png"),
    ("22", "Leitor — modo anotação", LEITOR / "22_modo_anotacao_390x844@3x.png"),
    ("23", "Leitor — ajustes da caneta", LEITOR / "23_ajustes_caneta_390x844@3x.png"),
    ("23b", "Leitor — ajustes do marca-texto", LEITOR / "23b_ajustes_marcatexto_390x844@3x.png"),
    ("24", "Leitor — abrindo espaço", LEITOR / "24_abrindo_espaco_390x844@3x.png"),
    ("24b", "Leitor — nota à mão", LEITOR / "24b_nota_mao_390x844@3x.png"),
    ("25", "Grifos e notas", LEITOR / "25_grifos_notas_390x2170@3x.png"),
    ("26", "Leitor — ajustes de leitura (Aa)", LEITOR / "26_ajustes_leitura_390x844@3x.png"),
    ("26b", "Leitor — tema Noite", LEITOR / "26b_tema_noite_390x844@3x.png"),
    ("27", "Leitor — sumário", LEITOR / "27_sumario_390x844@3x.png"),
    ("27b", "Leitor — sumário, Marcadas", LEITOR / "27b_sumario_marcadas_390x844@3x.png"),
]
TELAS_DA_INICIO = ("01", "60", "01b")
MARCA = re.compile(r"R00CAP (\w+)")
ALTURA = 1400  # altura de cada lado da imagem lado a lado (px)
# a captura do S22+ e, nela, a barra do Android (medido nas capturas de 11/10/2026): o relógio começa em x 66–76 e
# acaba entre x 158 ("11:44") e x 178 ("03:48"); os ícones de notificação vêm depois de um vão de 18 px ou mais, antes do
# meio (a câmera, x 540); a bateria fica em x 942–1009; os desenhos ocupam y 27–68
TAMANHO_DA_CAPTURA = (1080, 2340)
LINHAS_DA_BARRA = (18, 82)  # a faixa pintada (o y1 fora)
VAO_DEPOIS_DO_RELOGIO = 14  # dentro do relógio os vãos são de até 10 px
# quando a barra está sobre o conteúdo rolado (a 60) não dá para separar os ícones do fundo: a faixa vai do fim do
# relógio medido na captura anterior com a barra lisa (a 01, do mesmo minuto) — ou, sem ela, do fim do relógio mais
# largo — até depois de três ícones
FAIXA_FIXA = (188, 400)


def preparar(aparelho: str) -> Path | None:
    """Antes do `flutter drive` instalar o build dele: a assinatura (a chave de debug deste computador), o espaço e o
    APK do app normal guardado. Devolve o guardado (para a volta)."""
    ap.conferir_antes_de_instalar(aparelho, ap.assinante_do_keystore_de_debug(), TAMANHO_DO_BUILD_MB)
    return demo.guardar_app_normal(aparelho)


def _diferenca(a: tuple[int, ...], b: tuple[int, ...]) -> int:
    return max(abs(x - y) for x, y in zip(a, b))


def _fundo_liso(im: Image.Image) -> tuple[int, ...] | None:
    """A cor do fundo da barra, se ele é liso (as linhas logo acima e logo abaixo dos desenhos, de ponta a ponta)."""
    px = im.load()
    y0, y1 = LINHAS_DA_BARRA
    fundo = px[30, (y0 + y1) // 2]
    if all(_diferenca(px[x, y], fundo) <= 12 for x in range(0, im.size[0], 4) for y in (y0 - 6, y1 + 4)):
        return fundo
    return None


def _colunas_com_tinta(im: Image.Image, fundo: tuple[int, ...]):
    px = im.load()
    y0, y1 = LINHAS_DA_BARRA
    return lambda x: any(_diferenca(px[x, y], fundo) > 48 for y in range(y0 + 6, y1 - 10))


def inicio_depois_do_relogio(im: Image.Image) -> int | None:
    """A 1ª coluna depois do relógio (o fim dele + 7), numa barra sobre fundo liso; `None` sem barra (sem relógio ou
    sem bateria) ou com o fundo desigual."""
    fundo = _fundo_liso(im)
    if fundo is None:
        return None
    tinta = _colunas_com_tinta(im, fundo)
    inicio = next((x for x in range(40, 120) if tinta(x)), None)
    if inicio is None or not any(tinta(x) for x in range(930, 1020)):
        return None  # sem relógio ou sem bateria: a barra não está na tela
    fim, vao = inicio, 0
    for x in range(inicio, im.size[0] // 2):
        if tinta(x):
            fim, vao = x, 0
        else:
            vao += 1
            if vao >= VAO_DEPOIS_DO_RELOGIO:
                break
    return fim + 7


def faixa_das_notificacoes(im: Image.Image, x0_de_referencia: int | None = None) -> tuple[int, int] | None:
    """As colunas (x0, x1 fora) dos ícones de notificação na captura [im], ou `None` sem barra ou sem ícone. Com a
    barra sobre um fundo liso: do fim do relógio ao último desenho antes do meio. Com o fundo da barra desigual (a barra
    sobre o conteúdo rolado): do [x0_de_referencia] (o fim do relógio numa captura lisa do mesmo minuto) ou da
    [FAIXA_FIXA] até o fim dela."""
    fundo = _fundo_liso(im)
    if fundo is None:
        return (x0_de_referencia or FAIXA_FIXA[0], FAIXA_FIXA[1])
    x0 = inicio_depois_do_relogio(im)
    if x0 is None:
        return None
    tinta = _colunas_com_tinta(im, fundo)
    icones = [x for x in range(x0, im.size[0] // 2) if tinta(x)]
    return (x0, icones[-1] + 9) if icones else None


def cobrir_notificacoes(png: Path, x0_de_referencia: int | None = None) -> int | None:
    """Pinta a faixa dos ícones de notificação, coluna a coluna, com o degradê entre a cor logo acima e a logo abaixo
    dela: com a barra sobre um fundo liso some só o ícone; sem a barra (o leitor limpo) ou sem notificação nada muda;
    com a barra sobre o conteúdo rolado (a 60), a faixa vira um degradê. Devolve o fim do relógio desta captura (+ 7),
    quando a barra dela é lisa, para servir de [x0_de_referencia] à seguinte."""
    im = Image.open(png).convert("RGB")
    if im.size != TAMANHO_DA_CAPTURA:
        sys.exit(f"{png.name}: {im.size[0]} × {im.size[1]}; a faixa das notificações é medida no S22+ (1080 × 2340)")
    medido = inicio_depois_do_relogio(im)
    colunas = faixa_das_notificacoes(im, x0_de_referencia)
    if colunas is None:
        return medido
    x0, x1 = colunas
    y0, y1 = LINHAS_DA_BARRA
    px = im.load()
    for x in range(x0, x1):
        acima, abaixo = px[x, y0 - 1], px[x, y1]
        for y in range(y0, y1):
            t = (y - y0 + 1) / (y1 - y0 + 1)
            px[x, y] = tuple(round(a + (b - a) * t) for a, b in zip(acima, abaixo))
    im.save(png, optimize=True)
    return medido


def capturar(aparelho: str, alvo: int, pasta: Path) -> list[str]:
    esperadas = TELAS_DA_INICIO if alvo == 2 else tuple(n for n, _, _ in TELAS)
    sufixo = "_prancha_celular.png" if alvo == 2 else "_celular.png"
    pasta.mkdir(parents=True, exist_ok=True)
    flutter = shutil.which("flutter") or "flutter"
    comando = [
        flutter,
        "drive",
        "--profile",
        "--keep-app-running",
        "--driver=test_driver/integration_test.dart",
        "--target=integration_test/capturas_r00_test.dart",
        f"--dart-define=R00_ALVO={alvo}",
        "-d",
        aparelho,
    ]
    print(" ".join(comando))
    feitas: list[str] = []
    relogio: int | None = None  # o fim do relógio na última captura com a barra lisa
    with subprocess.Popen(
        comando,
        cwd=RAIZ,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
    ) as p:
        assert p.stdout is not None
        for linha in p.stdout:
            print(linha, end="")
            m = MARCA.search(linha)
            if m and m.group(1) in esperadas:
                captura = pasta / f"{m.group(1)}{sufixo}"
                ap.adb(aparelho, "exec-out", "screencap", "-p", saida=captura)
                relogio = cobrir_notificacoes(captura, relogio) or relogio
                feitas.append(m.group(1))
                print(f"  → captura {m.group(1)}")
        codigo = p.wait()
    if codigo != 0:
        sys.exit(f"o flutter drive terminou com {codigo}")
    faltam = [n for n in esperadas if n not in feitas]
    if faltam:
        sys.exit(f"faltaram as capturas: {', '.join(faltam)}")
    return feitas


def _fonte(tamanho: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(RAIZ / "assets" / "fonts" / "Figtree-Bold.ttf"), tamanho)


def _na_altura(img: Image.Image, altura: int) -> Image.Image:
    return img.resize((round(img.width * altura / img.height), altura), Image.LANCZOS)


def _legenda(d: ImageDraw.ImageDraw, xy: tuple[int, int], texto: str, largura: int) -> None:
    """[texto] no tamanho 34, ou menor até caber na [largura] da imagem de cima."""
    tamanho = 34
    while tamanho > 18 and d.textlength(texto, font=_fonte(tamanho)) > largura:
        tamanho -= 1
    d.text(xy, texto, fill="black", font=_fonte(tamanho))


def lado_a_lado(pasta: Path, numero: str, titulo: str, prancha: Path, sufixo: str) -> Path:
    celular = Image.open(pasta / f"{numero}{sufixo}").convert("RGB")
    ref = Image.open(prancha).convert("RGB")
    # a prancha no tamanho de uma tela (390 × 844 lógicos a 3×): a 01 e a 25 entram pelo topo
    if ref.height > 844 * 3 + 2:
        ref = ref.crop((0, 0, ref.width, 844 * 3))
    a = _na_altura(celular, ALTURA)
    b = _na_altura(ref, ALTURA)
    margem, rodape = 40, 120
    tela = Image.new("RGB", (a.width + b.width + margem * 3, ALTURA + margem + rodape), "white")
    tela.paste(a, (margem, margem))
    tela.paste(b, (margem * 2 + a.width, margem))
    d = ImageDraw.Draw(tela)
    alvo = " · alvo (2)" if sufixo.startswith("_prancha") else ""
    _legenda(d, (margem, ALTURA + margem + 20), f"celular · Galaxy S22+ (384 × 832){alvo}", a.width)
    _legenda(d, (margem * 2 + a.width, ALTURA + margem + 20), f"prancha {numero} · {titulo}", b.width)
    saida = pasta / f"{numero}{sufixo.replace('_celular.png', '_lado_a_lado.png')}"
    tela.save(saida, optimize=True)
    return saida


def main() -> None:
    for fluxo in (sys.stdout, sys.stderr):
        fluxo.reconfigure(encoding="utf-8", errors="replace")
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--alvo", type=int, choices=(1, 2), default=1)
    p.add_argument("--aparelho", default="RXCT200CA6F")
    p.add_argument("--saida", type=Path, default=RAIZ / "docs" / "progresso" / "R00_celular")
    p.add_argument("--so-montar", action="store_true", help="não roda o aparelho: só monta o lado a lado")
    args = p.parse_args()
    sufixo = "_prancha_celular.png" if args.alvo == 2 else "_celular.png"
    relogio: int | None = None
    if not args.so_montar:
        guardado = preparar(args.aparelho)
        capturar(args.aparelho, args.alvo, args.saida)
        if guardado is not None:
            print(f"para voltar ao app normal: python3 tools/celular/demo.py --voltar   ({guardado.name})")
    for numero, titulo, prancha in TELAS:
        if args.alvo == 2 and numero not in TELAS_DA_INICIO:
            continue
        if args.so_montar:
            # de novo não muda nada; na ordem das capturas, a 60 usa o relógio da 01
            relogio = cobrir_notificacoes(args.saida / f"{numero}{sufixo}", relogio) or relogio
        print(lado_a_lado(args.saida, numero, titulo, prancha, sufixo).relative_to(RAIZ))


if __name__ == "__main__":
    main()
