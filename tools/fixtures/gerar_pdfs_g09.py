"""G09 — PDFs de fixture da importação (test/fixtures/livros/): pequenos, sem dado de ninguém.

  amostra.pdf     3 páginas, título/autor no dicionário Info, sumário (outline) com 2 entradas
  sem_titulo.pdf  1 página, sem metadados (o título vem do nome do arquivo)
  protegido.pdf   a amostra com senha de abertura ("segredo") → "protegido"

Uso: python3 tools/fixtures/gerar_pdfs_g09.py   (reportlab + pypdf)
"""
import io
import pathlib

from pypdf import PdfReader, PdfWriter
from reportlab.lib.pagesizes import A5
from reportlab.pdfgen import canvas

SAIDA = pathlib.Path(__file__).resolve().parents[2] / "test" / "fixtures" / "livros"


def paginas(textos):
    buf = io.BytesIO()
    c = canvas.Canvas(buf, pagesize=A5, invariant=1)
    for t in textos:
        c.setFont("Helvetica", 14)
        c.drawString(40, 520, t)
        c.showPage()
    c.save()
    return PdfReader(io.BytesIO(buf.getvalue()))


def gravar(writer, nome):
    with open(SAIDA / nome, "wb") as f:
        writer.write(f)


def amostra():
    w = PdfWriter(clone_from=paginas(["Primeiro conto", "continua", "Segundo conto"]))
    w.add_metadata({"/Title": "Contos de Teste", "/Author": "Autora Exemplo"})
    w.add_outline_item("Primeiro conto", 0)
    w.add_outline_item("Segundo conto", 2)
    return w


def main():
    SAIDA.mkdir(parents=True, exist_ok=True)
    gravar(amostra(), "amostra.pdf")
    gravar(PdfWriter(clone_from=paginas(["Sem título"])), "sem_titulo.pdf")
    p = amostra()
    p.encrypt(user_password="segredo", owner_password="dono", algorithm="AES-128")
    gravar(p, "protegido.pdf")


if __name__ == "__main__":
    main()
