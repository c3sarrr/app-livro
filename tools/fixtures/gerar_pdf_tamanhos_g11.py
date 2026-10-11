"""G11 — PDF de fixture com páginas de tamanhos diferentes (test/fixtures/livros/tamanhos.pdf), para o encaixe do
PDF básico (D-109) com o PDFium de verdade: A4 em pé, carta e A4 deitada, uma linha de texto em cada.
Pequeno e sem dado de ninguém.

Uso: python3 tools/fixtures/gerar_pdf_tamanhos_g11.py   (reportlab)
"""
import pathlib

from reportlab.lib.pagesizes import A4, landscape, letter
from reportlab.pdfgen import canvas

SAIDA = pathlib.Path(__file__).resolve().parents[2] / "test" / "fixtures" / "livros" / "tamanhos.pdf"


def main():
    SAIDA.parent.mkdir(parents=True, exist_ok=True)
    c = canvas.Canvas(str(SAIDA), invariant=1)
    for tamanho, texto in ((A4, "A4 em pe"), (letter, "Carta"), (landscape(A4), "A4 deitada")):
        c.setPageSize(tamanho)
        c.setFont("Helvetica", 14)
        c.drawString(40, tamanho[1] - 60, texto)
        c.showPage()
    c.save()


if __name__ == "__main__":
    main()
