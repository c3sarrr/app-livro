"""ISBN, texto, leitores dos dumps."""
from __future__ import annotations

import unicodedata

from catalogo import dnb, isbn, openlibrary, texto


def test_isbn_normaliza_valida_e_converte():
    assert isbn.normalizar("85-359-0277-5") == "9788535902778"
    assert isbn.normalizar("0-8044-2957-X") == "9780804429573"
    assert isbn.normalizar("978-65-5532-123-4") == "9786555321234"
    assert isbn.normalizar("979-10-90636-07-1") == "9791090636071"
    assert isbn.normalizar("9786555321230") is None  # dígito errado
    assert isbn.normalizar("8535902776") is None
    assert isbn.normalizar("9770000000000") is None  # não é livro
    assert isbn.normalizar(None) is None
    assert isbn.para_isbn10("9788535902778") == "8535902775"
    assert isbn.para_isbn10("9791090636071") is None


def test_isbn_so_aceita_digitos_ascii():
    # achado 10 da revisão: '²' derrubava o estágio (int('²')) e dígitos arábico-índicos viravam "ISBN"
    assert isbn.normalizar("030640615²") is None
    assert isbn.normalizar("٠٣٠٦٤٠٦١٥٢") is None
    assert isbn.normalizar("978٠٣٠٦٤٠٦١٥7") is None
    assert isbn.normalizar("0306406152") == "9780306406157"


def test_texto_sem_surrogate_sozinho():
    assert texto.limpar("Livro \ud800quebrado") == "Livro quebrado"


def test_regiao_do_isbn():
    assert isbn.regiao("9788535902778") == "BR"
    assert isbn.regiao("9786555321234") == "BR"
    assert isbn.regiao("9783596294336") == "DE"
    assert isbn.regiao("9780141439518") == "MUNDO"


def test_texto():
    nfd = unicodedata.normalize("NFD", "Memórias  póstumas /")
    assert texto.limpar(nfd) == "Memórias póstumas"
    assert texto.limpar("   ") is None
    assert len(texto.limpar("x" * 900)) == 500
    assert texto.ano("January 30, 2003") == 2003
    assert texto.ano("c1899") == 1899
    assert texto.ano("sem data") is None
    assert texto.paginas("1008 S.") == 1008
    assert texto.paginas(0) is None
    assert texto.idioma_ol("/languages/por") == "por"
    assert texto.idioma_uri("http://id.loc.gov/vocabulary/iso639-2/ger") == "ger"


def test_edicoes_do_open_library(dumps):
    eds = list(openlibrary.edicoes(next(dumps.glob("ol_dump_editions_*"))))
    assert [e.chave for e in eds] == ["/books/OL100M", "/books/OL200M", "/books/OL201M", "/books/OL300M",
                                      "/books/OL400M"]
    dom = eds[0]
    assert (dom.isbns, dom.titulo, dom.idioma, dom.capa, dom.pais, dom.ano, dom.paginas) == (
        ["9788535902778"], "Dom Casmurro", "por", "ol:8231432", "bl", 2016, 256)
    assert eds[1].ano == 2003


def test_dnb_triplas_e_registros(dumps):
    t = dnb.tripla('<https://d-nb.info/2> <http://purl.org/dc/elements/1.1/title> "A \\"B\\" \\u00e9"@de .')
    assert t == ("<https://d-nb.info/2>", "http://purl.org/dc/elements/1.1/title", 'A "B" é', True)
    assert dnb.autores_da_mencao("von Anna Müller und Bernd Weiß") == ["Anna Müller", "Bernd Weiß"]
    assert dnb.autores_da_mencao("Thomas Mann ; mit einem Nachwort") == ["Thomas Mann"]
    assert dnb.autores_da_mencao("Mo Hayder. Dt. von Rainer Schmidt") == ["Mo Hayder"]
    assert dnb.autores_da_mencao("J. R. R. Tolkien. Aus dem Engl.") == ["J. R. R. Tolkien"]
    assert dnb.autores_da_mencao("hrsg. von Erik Stephan. [Hrsg. Städtische Museen]") == ["Erik Stephan"]
    # sujeitos intercalados no dump (como no real): a preparação ordena por sujeito antes de juntar
    regs = sorted(dnb.titulos(dumps / "dnb-all_lds.nt.gz"), key=lambda r: r.isbns)
    assert [r.isbns for r in regs] == [["9783446236202"], ["9783596294336"]]
    regs.reverse()
    z = regs[0]
    assert (z.titulo, z.subtitulo, z.autores, z.editora, z.ano, z.paginas, z.idioma) == (
        "Der Zauberberg", "Roman", ["Thomas Mann"], "S. Fischer", 1991, 1008, "ger")
    assert regs[1].titulo == "Über Bücher!"
    assert regs[1].titulo == unicodedata.normalize("NFC", regs[1].titulo)


def test_leitura_em_paralelo_igual_a_sequencial(dumps, monkeypatch):
    """Lotes pequenos em 3 processos: mesma saída, na mesma ordem, que a leitura num processo só."""
    caminhos = {t: next(dumps.glob(f"ol_dump_{t}_*.txt.gz")) for t in ("authors", "works", "editions")}

    def tudo():
        return (list(openlibrary.autores(caminhos["authors"])), list(openlibrary.obras(caminhos["works"])),
                list(openlibrary.edicoes(caminhos["editions"])))

    monkeypatch.setattr(openlibrary, "PROCESSOS", 1)
    sequencial = tudo()
    monkeypatch.setattr(openlibrary, "PROCESSOS", 3)
    monkeypatch.setattr(openlibrary, "LOTE_LINHAS", 2)
    assert tudo() == sequencial
    assert len(sequencial[2]) > 2
