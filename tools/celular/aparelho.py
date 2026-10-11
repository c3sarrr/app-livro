"""R00 — o que os scripts do celular dividem: o `adb`, o `apksigner`, a assinatura e o espaço livre.

Os dados do Cesar moram no app instalado (`com.example.app_leitura`: `booknest.db`, `livros/`, `capas_arquivo/`,
`catalogo/`). Uma desinstalação apaga tudo, e o `flutter` desinstala sozinho em três casos (conferido no
`flutter_tools` 3.47.2): `flutter install` (sempre, antes de instalar), `flutter drive` sem `--keep-app-running` e
`flutter test integration_test` sem `--no-uninstall` (no fim), e qualquer instalação que falhe no `adb install -r`
(para tentar de novo). Por isso, antes de instalar qualquer build: o APK novo tem de ter a mesma assinatura do
instalado (senão o `adb install -r` falha) e o aparelho tem de ter espaço. Os scripts instalam com `adb install -r`
puro — que, se falhar, só falha.
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

PACOTE = "com.example.app_leitura"
# o nome do banco do demo (D-267): só um build com o código do modo demonstração tem esse texto no código Dart do APK
# (o `libapp.so` dos builds de perfil e release; o `kernel_blob.bin` dos de debug)
MARCA_DO_DEMO = b"booknest_demo.db"
CODIGO_DART = ("libapp.so", "kernel_blob.bin")


def _sdk() -> Path:
    for var in ("ANDROID_HOME", "ANDROID_SDK_ROOT"):
        if os.environ.get(var):
            return Path(os.environ[var])
    return Path(os.environ.get("LOCALAPPDATA", "")) / "Android" / "sdk"


def _jdk() -> Path | None:
    if os.environ.get("JAVA_HOME"):
        return Path(os.environ["JAVA_HOME"])
    padrao = Path(r"C:\Program Files\Eclipse Adoptium")
    if padrao.is_dir():
        jdks = sorted(padrao.glob("jdk-17*"))
        if jdks:
            return jdks[-1]
    return None


SDK = _sdk()
ADB = SDK / "platform-tools" / ("adb.exe" if os.name == "nt" else "adb")


def _versao(p: Path) -> tuple[int, ...]:
    return tuple(int(x) for x in re.findall(r"\d+", p.name)) or (0,)


def _build_tools() -> Path:
    pastas = [p for p in (SDK / "build-tools").iterdir() if p.is_dir()]
    if not pastas:
        sys.exit(f"sem build-tools em {SDK}")
    return max(pastas, key=_versao)


def _env_java() -> dict[str, str]:
    env = dict(os.environ)
    jdk = _jdk()
    if jdk is not None:
        env["JAVA_HOME"] = str(jdk)
        env["PATH"] = f"{jdk / 'bin'}{os.pathsep}{env.get('PATH', '')}"
    return env


def adb(aparelho: str, *args: str, saida: Path | None = None, conferir: bool = True) -> subprocess.CompletedProcess:
    r = subprocess.run([str(ADB), "-s", aparelho, *args], capture_output=True, check=conferir)
    if saida is not None:
        saida.write_bytes(r.stdout)
    return r


def assinante_do_apk(apk: Path) -> str:
    """O SHA-256 do certificado que assinou [apk] (o `apksigner`)."""
    bt = _build_tools()
    nome = "apksigner.bat" if os.name == "nt" else "apksigner"
    r = subprocess.run(
        [str(bt / nome), "verify", "--print-certs", str(apk)],
        capture_output=True, text=True, env=_env_java(), check=True,
    )
    achado = re.search(r"SHA-256 digest: ([0-9a-f]{64})", r.stdout)
    if achado is None:
        sys.exit(f"o apksigner não deu a assinatura de {apk}")
    return achado.group(1)


def assinante_do_keystore_de_debug() -> str:
    """O SHA-256 do certificado da chave de debug deste computador — a que o Gradle usa nos builds de perfil e debug
    (`android/app/build.gradle.kts`: o release também assina com ela por enquanto)."""
    jdk = _jdk()
    keytool = (jdk / "bin" / "keytool") if jdk else Path(shutil.which("keytool") or "keytool")
    keystore = Path.home() / ".android" / "debug.keystore"
    if not keystore.exists():
        sys.exit(f"sem a chave de debug ({keystore}): o primeiro build a cria; rode um `flutter build apk --debug`.")
    r = subprocess.run(
        [str(keytool), "-list", "-v", "-keystore", str(keystore), "-storepass", "android",
         "-alias", "androiddebugkey"],
        capture_output=True, text=True, encoding="utf-8", errors="replace", check=True,
    )
    achado = re.search(r"SHA256:\s*([0-9A-F:]{95})", r.stdout)
    if achado is None:
        sys.exit("o keytool não deu o SHA-256 da chave de debug")
    return achado.group(1).replace(":", "").lower()


def conferir_aparelho(aparelho: str) -> None:
    """Para tudo se o aparelho não responde: sem ele, "nenhum app instalado" seria um engano."""
    r = adb(aparelho, "get-state", conferir=False)
    if r.returncode != 0 or r.stdout.decode(errors="replace").strip() != "device":
        sys.exit(
            f"PARADO: o aparelho {aparelho} não está conectado (ou não autorizou este computador): "
            f"{(r.stdout + r.stderr).decode(errors='replace').strip()}"
        )


def caminho_do_apk_instalado(aparelho: str) -> str | None:
    """O `base.apk` do app instalado; `None` sem app (o `pm path` sai com 1 e sem texto)."""
    conferir_aparelho(aparelho)
    r = adb(aparelho, "shell", "pm", "path", PACOTE, conferir=False)
    texto = r.stdout.decode(errors="replace").strip()
    if r.returncode != 0 or not texto.startswith("package:"):
        return None
    return texto.splitlines()[0].removeprefix("package:")


def puxar_apk_instalado(aparelho: str, destino: Path) -> Path | None:
    caminho = caminho_do_apk_instalado(aparelho)
    if caminho is None:
        return None
    adb(aparelho, "pull", caminho, str(destino))
    return destino


def eh_build_do_demo(apk: Path) -> bool:
    """O APK tem o código do modo demonstração (o nome do banco do demo no código Dart)."""
    with zipfile.ZipFile(apk) as z:
        return any(MARCA_DO_DEMO in z.read(n) for n in z.namelist() if n.endswith(CODIGO_DART))


def espaco_livre_mb(aparelho: str) -> int:
    linhas = adb(aparelho, "shell", "df", "-k", "/data").stdout.decode().strip().splitlines()
    campos = linhas[-1].split()
    return int(campos[3]) // 1024


def primeira_instalacao(aparelho: str) -> str | None:
    """A data da primeira instalação: igual antes e depois prova que o app não foi desinstalado."""
    texto = adb(aparelho, "shell", "dumpsys", "package", PACOTE).stdout.decode(errors="replace")
    achado = re.search(r"firstInstallTime=(\S+ \S+)", texto)
    return achado.group(1) if achado else None


def conferir_antes_de_instalar(aparelho: str, assinante_novo: str, tamanho_mb: int) -> None:
    """Para tudo se instalar por cima pudesse apagar os dados: assinatura diferente do instalado ou pouco espaço."""
    with tempfile.TemporaryDirectory() as pasta:
        instalado = puxar_apk_instalado(aparelho, Path(pasta) / "instalado.apk")
        if instalado is None:
            print("nenhum app instalado: nada a preservar")
        else:
            atual = assinante_do_apk(instalado)
            if atual != assinante_novo:
                sys.exit(
                    "PARADO: o app instalado tem outra assinatura que o build novo; instalar por cima falharia e o "
                    "flutter desinstalaria o app (apagando os dados). Nada foi instalado.\n"
                    f"  instalado: {atual}\n  novo:      {assinante_novo}"
                )
            print("assinatura: a mesma do app instalado (ok)")
    livre = espaco_livre_mb(aparelho)
    if livre < 3 * tamanho_mb:
        sys.exit(f"PARADO: {livre} MB livres no aparelho; o build tem {tamanho_mb} MB. Nada foi instalado.")


def instalar_por_cima(aparelho: str, apk: Path) -> None:
    """`adb install -r`: mantém os dados; se falhar, só falha (não desinstala nada)."""
    antes = primeira_instalacao(aparelho)
    r = adb(aparelho, "install", "-r", str(apk), conferir=False)
    texto = (r.stdout + r.stderr).decode(errors="replace")
    if r.returncode != 0 or "Success" not in texto:
        sys.exit(f"a instalação falhou (o app de antes continua como estava):\n{texto}")
    depois = primeira_instalacao(aparelho)
    print(f"instalado por cima: primeira instalação {antes} → {depois}")
    if antes is not None and depois != antes:
        sys.exit("ATENÇÃO: a data da primeira instalação mudou — o app foi reinstalado do zero")
