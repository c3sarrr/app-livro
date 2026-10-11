"""R00 — as conferências que protegem os dados do app normal, sem aparelho: o `adb` e o `apksigner` são simulados.

    python3 -m unittest discover -s tools/celular -v
"""

from __future__ import annotations

import io
import shutil
import subprocess
import sys
import tempfile
import unittest
import zipfile
from contextlib import redirect_stdout
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parent))
import aparelho as ap  # noqa: E402
import capturar_r00  # noqa: E402
import demo  # noqa: E402

ASSINATURA_DO_PC = "a" * 64
OUTRA_ASSINATURA = "b" * 64


def _resultado(stdout: bytes = b"", stderr: bytes = b"", codigo: int = 0) -> subprocess.CompletedProcess:
    return subprocess.CompletedProcess([], codigo, stdout, stderr)


def _envelhecer(guardado: Path) -> Path:
    """O guardado com um nome de antes (dois guardados no mesmo segundo teriam o mesmo nome e esconderiam um erro)."""
    return guardado.rename(guardado.with_name("app_normal_2026-01-01_000000.apk"))


def _apk(pasta: Path, nome: str, assinatura: str, demo_: bool, codigo: str = "lib/arm64-v8a/libapp.so") -> Path:
    """Um APK de mentira: o código Dart em [codigo] (com ou sem a marca do demo) e a assinatura num arquivo que o
    `apksigner` simulado lê."""
    caminho = pasta / nome
    with zipfile.ZipFile(caminho, "w") as z:
        z.writestr(codigo, b"\x7fELF..." + (ap.MARCA_DO_DEMO if demo_ else b"booknest.db") + b"...")
        z.writestr("ASSINATURA", assinatura)
    return caminho


def _assinante(apk: Path) -> str:
    with zipfile.ZipFile(apk) as z:
        return z.read("ASSINATURA").decode()


class AparelhoFalso:
    """Responde aos comandos do `adb` como o celular: conectado ou não, com o app [instalado] (um APK) ou sem app."""

    def __init__(
        self,
        instalado: Path | None,
        conectado: bool = True,
        livre_kb: int = 8_000_000,
        primeiras: tuple[str, ...] = ("2026-10-09 10:00:00",),
        instala: bool = True,
    ) -> None:
        self.instalado = instalado
        self.conectado = conectado
        self.livre_kb = livre_kb
        self.primeiras = list(primeiras)
        self.instala = instala
        self.comandos: list[tuple[str, ...]] = []

    def __call__(self, aparelho: str, *args: str, saida: Path | None = None, conferir: bool = True):
        self.comandos.append(args)
        if not self.conectado:
            r = _resultado(stderr=f"error: device '{aparelho}' not found".encode(), codigo=1)
        elif args == ("get-state",):
            r = _resultado(b"device\n")
        elif args[:3] == ("shell", "pm", "path"):
            r = _resultado(b"package:/data/app/~~x/base.apk\n") if self.instalado else _resultado(codigo=1)
        elif args[0] == "pull":
            shutil.copy(self.instalado, args[2])
            r = _resultado()
        elif args[:2] == ("shell", "df"):
            r = _resultado(
                b"Filesystem 1K-blocks Used Available Use% Mounted on\n"
                + f"/dev/block/dm-48 110000000 90000000 {self.livre_kb} 82% /data\n".encode()
            )
        elif args[:2] == ("shell", "dumpsys"):
            data = self.primeiras.pop(0) if len(self.primeiras) > 1 else self.primeiras[0]
            r = _resultado(f"  firstInstallTime={data}\n".encode())
        elif args[0] == "install":
            if self.instala:
                self.instalado = Path(args[-1])
                r = _resultado(b"Performing Streamed Install\nSuccess\n")
            else:
                r = _resultado(b"Failure [INSTALL_FAILED_UPDATE_INCOMPATIBLE]\n", codigo=1)
        else:
            raise AssertionError(f"comando do adb inesperado: {args}")
        if conferir and r.returncode != 0:
            raise subprocess.CalledProcessError(r.returncode, ["adb", *args], r.stdout, r.stderr)
        if saida is not None:
            saida.write_bytes(r.stdout)
        return r

    def instalou(self) -> bool:
        return any(c[0] == "install" for c in self.comandos)


class Base(unittest.TestCase):
    def setUp(self) -> None:
        self.pasta = Path(tempfile.mkdtemp(prefix="booknest_celular_"))
        self.addCleanup(shutil.rmtree, self.pasta, True)
        self.guardados = self.pasta / "guardados"
        for obj, nome, valor in (
            (ap, "assinante_do_apk", _assinante),
            (ap, "assinante_do_keystore_de_debug", lambda: ASSINATURA_DO_PC),
            (demo, "GUARDADOS", self.guardados),
        ):
            patcher = mock.patch.object(obj, nome, valor)
            patcher.start()
            self.addCleanup(patcher.stop)

    def aparelho(self, falso: AparelhoFalso) -> AparelhoFalso:
        patcher = mock.patch.object(ap, "adb", falso)
        patcher.start()
        self.addCleanup(patcher.stop)
        return falso

    def quieto(self, f, *args):
        with redirect_stdout(io.StringIO()):
            return f(*args)


class Conferencias(Base):
    def test_sem_aparelho_para_em_vez_de_dizer_que_nao_ha_app(self) -> None:
        normal = _apk(self.pasta, "normal.apk", ASSINATURA_DO_PC, demo_=False)
        self.aparelho(AparelhoFalso(normal, conectado=False))
        with self.assertRaises(SystemExit) as e:
            ap.caminho_do_apk_instalado("X")
        self.assertIn("PARADO", str(e.exception.code))
        with self.assertRaises(SystemExit):
            self.quieto(demo.guardar_app_normal, "X")

    def test_assinatura_diferente_para_antes_de_instalar(self) -> None:
        falso = self.aparelho(AparelhoFalso(_apk(self.pasta, "normal.apk", OUTRA_ASSINATURA, demo_=False)))
        with self.assertRaises(SystemExit) as e:
            self.quieto(ap.conferir_antes_de_instalar, "X", ASSINATURA_DO_PC, 70)
        self.assertIn("PARADO", str(e.exception.code))
        self.assertFalse(falso.instalou())

    def test_pouco_espaco_para_antes_de_instalar(self) -> None:
        normal = _apk(self.pasta, "normal.apk", ASSINATURA_DO_PC, demo_=False)
        self.aparelho(AparelhoFalso(normal, livre_kb=200 * 1024))
        with self.assertRaises(SystemExit) as e:
            self.quieto(ap.conferir_antes_de_instalar, "X", ASSINATURA_DO_PC, 70)
        self.assertIn("MB livres", str(e.exception.code))

    def test_mesma_assinatura_e_espaco_passam(self) -> None:
        normal = _apk(self.pasta, "normal.apk", ASSINATURA_DO_PC, demo_=False)
        self.aparelho(AparelhoFalso(normal))
        self.quieto(ap.conferir_antes_de_instalar, "X", ASSINATURA_DO_PC, 70)

    def test_sem_app_instalado_nao_ha_o_que_preservar(self) -> None:
        self.aparelho(AparelhoFalso(None))
        self.quieto(ap.conferir_antes_de_instalar, "X", ASSINATURA_DO_PC, 70)

    def test_instala_por_cima_so_com_install_r(self) -> None:
        normal = _apk(self.pasta, "normal.apk", ASSINATURA_DO_PC, demo_=False)
        novo = _apk(self.pasta, "novo.apk", ASSINATURA_DO_PC, demo_=True)
        falso = self.aparelho(AparelhoFalso(normal))
        self.quieto(ap.instalar_por_cima, "X", novo)
        self.assertIn(("install", "-r", str(novo)), falso.comandos)
        self.assertFalse(any(c[:1] == ("uninstall",) or "uninstall" in c for c in falso.comandos))

    def test_instalacao_que_falha_so_falha(self) -> None:
        normal = _apk(self.pasta, "normal.apk", ASSINATURA_DO_PC, demo_=False)
        falso = self.aparelho(AparelhoFalso(normal, instala=False))
        with self.assertRaises(SystemExit) as e:
            self.quieto(ap.instalar_por_cima, "X", normal)
        self.assertIn("falhou", str(e.exception.code))
        self.assertFalse(any("uninstall" in c for c in falso.comandos))

    def test_primeira_instalacao_diferente_avisa(self) -> None:
        normal = _apk(self.pasta, "normal.apk", ASSINATURA_DO_PC, demo_=False)
        self.aparelho(AparelhoFalso(normal, primeiras=("2026-10-09 10:00:00", "2026-10-11 21:00:00")))
        with self.assertRaises(SystemExit) as e:
            self.quieto(ap.instalar_por_cima, "X", normal)
        self.assertIn("ATENÇÃO", str(e.exception.code))

    def test_reconhece_o_build_do_demo(self) -> None:
        self.assertTrue(ap.eh_build_do_demo(_apk(self.pasta, "d.apk", ASSINATURA_DO_PC, demo_=True)))
        self.assertFalse(ap.eh_build_do_demo(_apk(self.pasta, "n.apk", ASSINATURA_DO_PC, demo_=False)))
        # um build de debug (o código Dart no `kernel_blob.bin`) também
        debug = "assets/flutter_assets/kernel_blob.bin"
        self.assertTrue(ap.eh_build_do_demo(_apk(self.pasta, "dd.apk", ASSINATURA_DO_PC, demo_=True, codigo=debug)))
        # e um APK sem código Dart não é do demo
        self.assertFalse(ap.eh_build_do_demo(_apk(self.pasta, "x.apk", ASSINATURA_DO_PC, demo_=True, codigo="x.bin")))


class Demo(Base):
    def test_guarda_o_app_normal_uma_vez(self) -> None:
        normal = _apk(self.pasta, "normal.apk", ASSINATURA_DO_PC, demo_=False)
        self.aparelho(AparelhoFalso(normal))
        primeiro = _envelhecer(self.quieto(demo.guardar_app_normal, "X"))
        segundo = self.quieto(demo.guardar_app_normal, "X")
        self.assertEqual(primeiro, segundo)
        self.assertEqual(list(self.guardados.glob("app_normal_*.apk")), [primeiro])
        self.assertEqual(primeiro.read_bytes(), normal.read_bytes())

    def test_build_do_demo_instalado_nao_vira_o_normal_guardado(self) -> None:
        normal = _apk(self.pasta, "normal.apk", ASSINATURA_DO_PC, demo_=False)
        falso = self.aparelho(AparelhoFalso(normal))
        guardado = _envelhecer(self.quieto(demo.guardar_app_normal, "X"))
        falso.instalado = _apk(self.pasta, "demo.apk", ASSINATURA_DO_PC, demo_=True)
        self.assertEqual(self.quieto(demo.guardar_app_normal, "X"), guardado)
        self.assertEqual(list(self.guardados.glob("app_normal_*.apk")), [guardado])
        self.assertEqual(guardado.read_bytes(), normal.read_bytes())

    def test_voltar_recusa_um_build_do_demo(self) -> None:
        self.aparelho(AparelhoFalso(_apk(self.pasta, "normal.apk", ASSINATURA_DO_PC, demo_=False)))
        with self.assertRaises(SystemExit) as e:
            self.quieto(demo.voltar, "X", _apk(self.pasta, "demo.apk", ASSINATURA_DO_PC, demo_=True))
        self.assertIn("PARADO", str(e.exception.code))

    def test_voltar_sem_nada_guardado_explica_o_que_fazer(self) -> None:
        self.aparelho(AparelhoFalso(_apk(self.pasta, "demo.apk", ASSINATURA_DO_PC, demo_=True)))
        with self.assertRaises(SystemExit) as e:
            self.quieto(demo.voltar, "X", None)
        self.assertIn("--voltar --apk", str(e.exception.code))

    def test_voltar_reinstala_o_ultimo_guardado(self) -> None:
        normal = _apk(self.pasta, "normal.apk", ASSINATURA_DO_PC, demo_=False)
        falso = self.aparelho(AparelhoFalso(normal))
        guardado = self.quieto(demo.guardar_app_normal, "X")
        falso.instalado = _apk(self.pasta, "demo.apk", ASSINATURA_DO_PC, demo_=True)
        self.quieto(demo.voltar, "X", None)
        self.assertIn(("install", "-r", str(guardado)), falso.comandos)


class Notificacoes(unittest.TestCase):
    def setUp(self) -> None:
        self.pasta = Path(tempfile.mkdtemp(prefix="booknest_barra_"))
        self.addCleanup(shutil.rmtree, self.pasta, True)

    def _captura(
        self,
        fundo: tuple[int, int, int],
        icone: bool,
        relogio: tuple[int, int] = (76, 178),
        icones: tuple[int, int] = (201, 364),
        barra: bool = True,
    ) -> Path:
        from PIL import Image, ImageDraw

        im = Image.new("RGB", capturar_r00.TAMANHO_DA_CAPTURA, fundo)
        d = ImageDraw.Draw(im)
        if barra:
            # o relógio em dois pedaços com um vão de 9 px ("11" e ":44"), a rede e a bateria
            d.rectangle((relogio[0], 27, relogio[0] + 29, 68), fill=(60, 60, 60))
            d.rectangle((relogio[0] + 39, 27, relogio[1], 68), fill=(60, 60, 60))
            d.rectangle((806, 27, 1009, 68), fill=(60, 60, 60))
        d.rectangle((0, 300, 1079, 2339), fill=(20, 120, 200))  # o app
        if icone:
            d.rectangle((icones[0], 27, icones[1], 68), fill=(250, 30, 80))
        caminho = self.pasta / "x_celular.png"
        im.save(caminho)
        return caminho

    def test_some_o_icone_e_o_resto_fica(self) -> None:
        from PIL import Image, ImageChops

        limpa = Image.open(self._captura((247, 239, 226), icone=False)).convert("RGB")
        caminho = self._captura((247, 239, 226), icone=True)
        capturar_r00.cobrir_notificacoes(caminho)
        self.assertIsNone(ImageChops.difference(Image.open(caminho).convert("RGB"), limpa).getbbox())

    def test_sem_a_barra_nada_muda_e_de_novo_tambem_nao(self) -> None:
        from PIL import Image

        caminho = self._captura((24, 22, 20), icone=False)
        antes = Image.open(caminho).convert("RGB").tobytes()
        capturar_r00.cobrir_notificacoes(caminho)
        capturar_r00.cobrir_notificacoes(caminho)
        self.assertEqual(Image.open(caminho).convert("RGB").tobytes(), antes)

    def test_o_relogio_estreito_nao_deixa_lasca(self) -> None:
        # "11:44" acaba em x 158 e o 1º ícone começa em x 176, antes da faixa fixa
        from PIL import Image, ImageChops

        estreito = {"relogio": (66, 158), "icones": (176, 364)}
        limpa = Image.open(self._captura((247, 239, 226), icone=False, **estreito)).convert("RGB")
        caminho = self._captura((247, 239, 226), icone=True, **estreito)
        self.assertEqual(capturar_r00.faixa_das_notificacoes(Image.open(caminho).convert("RGB")), (165, 373))
        capturar_r00.cobrir_notificacoes(caminho)
        self.assertIsNone(ImageChops.difference(Image.open(caminho).convert("RGB"), limpa).getbbox())

    def test_sem_a_barra_o_conteudo_no_alto_fica(self) -> None:
        # sem a barra (sem relógio e bateria), um desenho do app no alto não é tomado por ícone
        from PIL import Image

        from PIL import ImageDraw

        im = Image.open(self._captura((247, 239, 226), icone=True, barra=False)).convert("RGB")
        ImageDraw.Draw(im).rectangle((50, 30, 100, 65), fill=(60, 60, 60))  # um "voltar" do app no lugar do relógio
        self.assertIsNone(capturar_r00.faixa_das_notificacoes(im))

    def test_a_barra_sobre_o_conteudo_usa_o_relogio_da_captura_lisa(self) -> None:
        # a 60: a barra sobre o mostrador rolado; o relógio estreito ("11:49") da 01, do mesmo minuto, dá o começo
        from PIL import Image, ImageDraw

        estreito = {"relogio": (66, 158), "icones": (176, 364)}
        lisa = self._captura((247, 239, 226), icone=True, **estreito)
        x0 = capturar_r00.cobrir_notificacoes(lisa)
        self.assertEqual(x0, 165)
        im = Image.open(self._captura((247, 239, 226), icone=True, **estreito)).convert("RGB")
        ImageDraw.Draw(im).ellipse((120, 0, 420, 300), outline=(10, 10, 10), width=20)  # o mostrador rolado
        self.assertEqual(capturar_r00.faixa_das_notificacoes(im, x0), (165, capturar_r00.FAIXA_FIXA[1]))
        self.assertEqual(capturar_r00.faixa_das_notificacoes(im), capturar_r00.FAIXA_FIXA)
        self.assertIsNone(capturar_r00.inicio_depois_do_relogio(im))

    def test_o_roteiro_passa_o_relogio_da_01_para_a_60(self) -> None:
        # o `flutter drive` e o `screencap` simulados: a 01 com a barra lisa, a 60 com a barra sobre o mostrador
        from PIL import Image, ImageDraw

        estreito = {"relogio": (66, 158), "icones": (176, 364)}
        pngs = []
        for nome in ("01", "60", "01b"):
            im = Image.open(self._captura((247, 239, 226), icone=True, **estreito)).convert("RGB")
            if nome == "60":
                ImageDraw.Draw(im).ellipse((120, 0, 420, 300), outline=(10, 10, 10), width=20)
            caminho = self.pasta / f"fonte_{nome}.png"
            im.save(caminho)
            pngs.append(caminho.read_bytes())

        class Drive:
            def __init__(self, *a, **k) -> None:
                self.stdout = iter([f"R00CAP {n}\n" for n in ("01", "60", "01b")])

            def __enter__(self):
                return self

            def __exit__(self, *a) -> None:
                return None

            def wait(self) -> int:
                return 0

        def adb(aparelho, *args, saida=None, conferir=True):
            assert args == ("exec-out", "screencap", "-p"), args
            saida.write_bytes(pngs.pop(0))
            return _resultado()

        saida = self.pasta / "capturas"
        with mock.patch.object(capturar_r00.subprocess, "Popen", Drive), mock.patch.object(ap, "adb", adb):
            self.assertEqual(self.quieto(capturar_r00.capturar, "X", 2, saida), ["01", "60", "01b"])
        sessenta = Image.open(saida / "60_prancha_celular.png").convert("RGB")
        # a lasca do 1º ícone (x 176) coberta: a faixa começou no fim do relógio da 01 (x 165), não na fixa (x 188)
        self.assertEqual(sessenta.getpixel((180, 47)), (247, 239, 226))
        self.assertEqual(sessenta.getpixel((150, 47)), (60, 60, 60))  # o relógio fica

    def quieto(self, f, *args):
        with redirect_stdout(io.StringIO()):
            return f(*args)

    def test_outro_aparelho_para(self) -> None:
        from PIL import Image

        caminho = self.pasta / "outro.png"
        Image.new("RGB", (1440, 3200), "white").save(caminho)
        with self.assertRaises(SystemExit):
            capturar_r00.cobrir_notificacoes(caminho)


class Capturas(Base):
    def test_confere_a_chave_de_debug_antes_do_flutter_drive(self) -> None:
        # o `flutter drive` assina com a chave de debug deste computador: um app instalado com outra chave para tudo
        falso = self.aparelho(AparelhoFalso(_apk(self.pasta, "normal.apk", OUTRA_ASSINATURA, demo_=False)))
        with self.assertRaises(SystemExit) as e:
            self.quieto(capturar_r00.preparar, "X")
        self.assertIn("PARADO", str(e.exception.code))
        self.assertEqual(list(self.guardados.glob("*")) if self.guardados.exists() else [], [])
        self.assertFalse(falso.instalou())

    def test_com_a_chave_de_debug_guarda_o_app_normal(self) -> None:
        normal = _apk(self.pasta, "normal.apk", ASSINATURA_DO_PC, demo_=False)
        self.aparelho(AparelhoFalso(normal))
        guardado = self.quieto(capturar_r00.preparar, "X")
        self.assertEqual(guardado.read_bytes(), normal.read_bytes())


if __name__ == "__main__":
    unittest.main()
