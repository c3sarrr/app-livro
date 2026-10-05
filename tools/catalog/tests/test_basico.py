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
    monkeypatch.setattr(openlibrary, "BLOCO_BYTES", 300)  # blocos menores que uma linha também
    assert tudo() == sequencial
    assert len(sequencial[2]) > 2


def test_blocos_nunca_dividem_uma_linha():
    import io

    from catalogo.fluxo import blocos

    dados = b"".join(f"linha {i} {'x' * (i % 37)}\n".encode() for i in range(500)) + b"sem fim"
    for tamanho in (1, 7, 64, 1000, 10**6):
        partes = list(blocos(io.BytesIO(dados), tamanho))
        assert b"".join(partes) == dados
        assert all(p.endswith(b"\n") for p in partes[:-1])


def test_registros_com_formato_inesperado_nao_derrubam_a_leitura():
    """Dumps reais têm registros antigos: autor da obra como texto, ISBN solto em vez de lista, JSON que
    não é objeto. Os aproveitáveis entram; os outros são contados e descartados."""
    linhas = [
        '/type/work\t/works/OL1W\t1\t2020\t{"title": "Velha", "authors": [{"author": "/authors/OL9A"}]}',
        '/type/work\t/works/OL2W\t1\t2020\t["não", "é", "objeto"]',
        '/type/work\t/works/OL3W\t1\t2020\t{"title": "Nova", "authors": [{"author": {"key": "/authors/OL8A"}}]}',
        '/type/work\t/works/OL4W\t1\t2020\t{"title": "Quebrada", "authors": [{"author": {"key": 5}}]}',
        '/type/work\t/works/OL5W\t1\t2020\t{json inválido',
    ]
    obras, estranhos = openlibrary._lote(("obra", None, ("\n".join(linhas) + "\n").encode()))
    assert [(o[0], o[2]) for o in obras] == [("/works/OL1W", ["/authors/OL9A"]), ("/works/OL3W", ["/authors/OL8A"]),
                                              ("/works/OL4W", [])]
    assert estranhos == 1  # o JSON inválido (o que não é objeto é ignorado)
    ed = ('/type/edition\t/books/OL1M\t1\t2020\t{"title": "Solto", "isbn_13": "9788535902778", '
          '"publishers": "Editora", "authors": [{"key": "/authors/OL1A"}], "works": {"key": "/works/OL1W"}}\n')
    (e,), _ = openlibrary._lote(("edicao", '"isbn_', ed.encode()))
    assert (e.isbns, e.editora, e.autores, e.obra) == (["9788535902778"], "Editora", ["/authors/OL1A"], "/works/OL1W")


def test_dump_truncado_derruba_a_leitura(tmp_path):
    """Um .gz cortado (download interrompido, disco cheio) não pode virar um catálogo pela metade
    em silêncio: a leitura falha quando o descompressor acusa o erro."""
    import gzip

    import pytest

    from catalogo.fluxo import abrir_bytes, abrir_linhas

    linhas = "".join(f'/type/author\t/authors/OL{i}A\t1\t2020\t{{"name": "Autor {i}"}}\n' for i in range(20_000))
    inteiro = gzip.compress(linhas.encode(), mtime=0)
    cortado = tmp_path / "ol_dump_authors_cortado.txt.gz"
    cortado.write_bytes(inteiro[: len(inteiro) // 2])
    with pytest.raises(RuntimeError, match="descompress"):
        list(openlibrary.autores(cortado))
    with pytest.raises(RuntimeError, match="descompress"), abrir_linhas(cortado) as f:
        for _ in f:
            pass
    # quem para de ler antes do fim (só o começo do arquivo) não é erro
    ok = tmp_path / "ok.txt.gz"
    ok.write_bytes(inteiro)
    with abrir_bytes(ok) as f:
        assert f.read(10) == linhas[:10].encode()
    with abrir_linhas(ok) as f:
        assert next(iter(f)).startswith("/type/author")
    assert len(list(openlibrary.autores(ok))) == 20_000
