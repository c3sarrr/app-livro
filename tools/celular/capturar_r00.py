"""R00.8 (R7) — a prova das 16 telas prontas no Galaxy S22+, lado a lado com as pranchas.

Roda o roteiro do aparelho (`integration_test/capturas_r00_test.dart`) com o `flutter drive` em perfil e, a cada linha
`R00CAP <nn>` que ele imprime (o app parado no estado da prancha), tira a captura da tela pelo `adb`. No fim monta, para
cada tela, a captura e o PNG da prancha na mesma altura, com o título embaixo.

Os dados do Cesar moram no app instalado (`booknest.db`); o roteiro só abre o banco do demo (`booknest_demo.db`, D-267).
Antes de instalar, confere que o APK instalado foi assinado com a chave de debug deste computador (senão o
`adb install -r` falha e o `flutter` desinstala o app para tentar de novo — e os dados vão junto) e roda o `flutter drive`
com `--keep-app-running` (sem ele o `flutter drive` desinstala o app no fim).

    PYTHONIOENCODING=utf-8 python3 tools/celular/capturar_r00.py [--alvo 1|2] [--aparelho RXCT200CA6F]

`--alvo 2` = o `main_mundo_referencia.dart` (a Início igual à prancha): só as 3 telas da Início (`<nn>_prancha_*`).
"""

from __future__ import annotations

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

RAIZ = Path(__file__).resolve().parents[2]
PACOTE = "com.example.app_leitura"
ADB = Path(os.environ.get("LOCALAPPDATA", "")) / "Android" / "sdk" / "platform-tools" / "adb.exe"
SDK = ADB.parent.parent
# o SHA-256 do certificado da chave de debug deste computador (o `apksigner` sobre o APK instalado — R00, 11/10/2026)
ASSINANTE_ESPERADO = "14faa78b4f3acda7700523c7eff8a5e9bd1be7a0c75ea379ab8258b34ae65143"
JDK = Path(r"C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot")

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


def adb(aparelho: str, *args: str, saida: Path | None = None) -> bytes:
    r = subprocess.run([str(ADB), "-s", aparelho, *args], capture_output=True, check=True)
    if saida is not None:
        saida.write_bytes(r.stdout)
    return r.stdout


def conferir_assinatura(aparelho: str) -> None:
    """O APK instalado tem o assinante esperado (sem app instalado não há dado a perder)."""
    caminho = adb(aparelho, "shell", "pm", "path", PACOTE).decode().strip()
    if not caminho:
        print("nenhum app instalado: nada a preservar")
        return
    apk = caminho.splitlines()[0].removeprefix("package:")
    with tempfile.TemporaryDirectory() as pasta:
        local = Path(pasta) / "instalado.apk"
        subprocess.run([str(ADB), "-s", aparelho, "pull", apk, str(local)], capture_output=True, check=True)
        build_tools = sorted((SDK / "build-tools").iterdir())[-1]
        env = {**os.environ, "JAVA_HOME": str(JDK), "PATH": f"{JDK / 'bin'}{os.pathsep}{os.environ['PATH']}"}
        r = subprocess.run(
            [str(build_tools / "apksigner.bat"), "verify", "--print-certs", str(local)],
            capture_output=True,
            text=True,
            env=env,
            check=True,
        )
    achado = re.search(r"SHA-256 digest: ([0-9a-f]{64})", r.stdout)
    if achado is None or achado.group(1) != ASSINANTE_ESPERADO:
        sys.exit(
            "PARADO: o app instalado não foi assinado com a chave de debug deste computador; instalar por cima "
            "falharia e o flutter desinstalaria o app (apagando os dados). Nada foi instalado."
        )
    print("assinatura do app instalado: a chave de debug deste computador (ok)")


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
                adb(aparelho, "exec-out", "screencap", "-p", saida=pasta / f"{m.group(1)}{sufixo}")
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
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--alvo", type=int, choices=(1, 2), default=1)
    ap.add_argument("--aparelho", default="RXCT200CA6F")
    ap.add_argument("--saida", type=Path, default=RAIZ / "docs" / "progresso" / "R00_celular")
    ap.add_argument("--so-montar", action="store_true", help="não roda o aparelho: só monta o lado a lado")
    args = ap.parse_args()
    sufixo = "_prancha_celular.png" if args.alvo == 2 else "_celular.png"
    if not args.so_montar:
        conferir_assinatura(args.aparelho)
        capturar(args.aparelho, args.alvo, args.saida)
    for numero, titulo, prancha in TELAS:
        if args.alvo == 2 and numero not in TELAS_DA_INICIO:
            continue
        print(lado_a_lado(args.saida, numero, titulo, prancha, sufixo).relative_to(RAIZ))


if __name__ == "__main__":
    main()
