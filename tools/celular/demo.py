"""R00 (D-267) — o modo demonstração no celular, sem risco para os dados do app normal, e a volta.

    python3 tools/celular/demo.py [--alvo 1|2] [--recomecar] [--aparelho RXCT200CA6F]
    python3 tools/celular/demo.py --voltar [--apk <app_normal.apk>] [--aparelho RXCT200CA6F]

Instalar (o padrão): compila o alvo em perfil (`flutter build apk --profile -t test/fixtures/main_demonstracao.dart`,
ou o `main_mundo_referencia.dart` com `--alvo 2`), confere que o APK novo tem a assinatura do app instalado e que há
espaço, **guarda o APK do app normal** que está no aparelho (se o instalado não é um build do demo) fora do
repositório, instala por cima com `adb install -r` (os dados ficam; se falhar, só falha) e abre o app. O demo usa o
`booknest_demo.db` e as pastas `*_demo` — o `booknest.db` do app normal fica intocado, mas o ícone passa a abrir o
demo até a volta. `--recomecar` compila o alvo (1) com `BOOKNEST_DEMO_RECOMECAR=true`: esse build apaga o mundo do
demo a cada abertura (rode de novo sem ele depois). O alvo (2) usa o mesmo banco do demo: recomeça-se pelo alvo (1).

Voltar: reinstala por cima o último APK normal guardado (ou o `--apk` dado), com as mesmas conferências.

Os APKs guardados ficam em `%LOCALAPPDATA%\\booknest\\celular\\` (fora do repositório). Nunca usar `flutter install`
(desinstala antes) — ver `tools/celular/aparelho.py`.
"""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import aparelho as ap  # noqa: E402

RAIZ = Path(__file__).resolve().parents[2]
ALVOS = {1: "test/fixtures/main_demonstracao.dart", 2: "test/fixtures/main_mundo_referencia.dart"}
APK_DO_BUILD = RAIZ / "build" / "app" / "outputs" / "flutter-apk" / "app-profile.apk"
GUARDADOS = Path(os.environ.get("LOCALAPPDATA", str(Path.home()))) / "booknest" / "celular"


def _sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def _mb(p: Path) -> int:
    return max(1, p.stat().st_size // (1024 * 1024))


def guardar_app_normal(aparelho: str) -> Path | None:
    """Guarda o APK instalado, se ele é o app normal (não um build do demo); devolve o guardado (ou o último)."""
    GUARDADOS.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as pasta:
        instalado = ap.puxar_apk_instalado(aparelho, Path(pasta) / "instalado.apk")
        if instalado is None:
            print("nenhum app instalado: nada a guardar")
            return ultimo_guardado()
        if ap.eh_build_do_demo(instalado):
            print("o app instalado já é um build do demo (o normal guardado continua o de antes)")
            return ultimo_guardado()
        sha = _sha(instalado)
        for g in GUARDADOS.glob("app_normal_*.apk"):
            if _sha(g) == sha:
                print(f"o app normal já estava guardado: {g}")
                return g
        destino = GUARDADOS / f"app_normal_{dt.datetime.now():%Y-%m-%d_%H%M%S}.apk"
        shutil.copy2(instalado, destino)
        print(f"app normal guardado: {destino}")
        return destino


def ultimo_guardado() -> Path | None:
    guardados = sorted(GUARDADOS.glob("app_normal_*.apk"))
    return guardados[-1] if guardados else None


def instalar_demo(aparelho: str, alvo: int, recomecar: bool) -> None:
    flutter = shutil.which("flutter") or "flutter"
    comando = [flutter, "build", "apk", "--profile", "-t", ALVOS[alvo]]
    if recomecar:
        comando.append("--dart-define=BOOKNEST_DEMO_RECOMECAR=true")
    print(" ".join(comando))
    subprocess.run(comando, cwd=RAIZ, check=True)
    if not ap.eh_build_do_demo(APK_DO_BUILD):
        sys.exit(f"PARADO: {APK_DO_BUILD} não tem o código do demo; nada foi instalado.")
    ap.conferir_antes_de_instalar(aparelho, ap.assinante_do_apk(APK_DO_BUILD), _mb(APK_DO_BUILD))
    guardado = guardar_app_normal(aparelho)
    ap.instalar_por_cima(aparelho, APK_DO_BUILD)
    ap.adb(aparelho, "shell", "monkey", "-p", ap.PACOTE, "-c", "android.intent.category.LAUNCHER", "1")
    print(f"o demo (alvo {alvo}) está aberto no aparelho.")
    if guardado is not None:
        print(f"para voltar ao app normal: python3 tools/celular/demo.py --voltar   ({guardado.name})")


def voltar(aparelho: str, apk: Path | None) -> None:
    normal = apk or ultimo_guardado()
    if normal is None or not normal.exists():
        sys.exit(
            "nenhum APK normal guardado: compile o app normal (`flutter build apk --profile` — ou com o seu "
            "--dart-define-from-file) e rode `demo.py --voltar --apk build/app/outputs/flutter-apk/app-profile.apk`."
        )
    if ap.eh_build_do_demo(normal):
        sys.exit(f"PARADO: {normal} é um build do demo, não o app normal.")
    ap.conferir_antes_de_instalar(aparelho, ap.assinante_do_apk(normal), _mb(normal))
    ap.instalar_por_cima(aparelho, normal)
    print(f"o app normal voltou: {normal.name}")


def main() -> None:
    for fluxo in (sys.stdout, sys.stderr):
        fluxo.reconfigure(encoding="utf-8", errors="replace")
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--alvo", type=int, choices=(1, 2), default=1)
    p.add_argument("--recomecar", action="store_true")
    p.add_argument("--voltar", action="store_true", help="reinstala o app normal guardado")
    p.add_argument("--apk", type=Path, help="com --voltar: o APK do app normal a reinstalar")
    p.add_argument("--aparelho", default="RXCT200CA6F")
    a = p.parse_args()
    if a.recomecar and a.alvo == 2:
        p.error("o --recomecar é do alvo (1): o alvo (2) usa o mesmo banco do demo, recomece pelo alvo (1)")
    if a.voltar:
        voltar(a.aparelho, a.apk)
    else:
        instalar_demo(a.aparelho, a.alvo, a.recomecar)


if __name__ == "__main__":
    main()
