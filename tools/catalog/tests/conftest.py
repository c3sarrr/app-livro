"""Dumps de amostra no formato real (Open Library TSV+JSON; DNB N-Triples em NFD)."""
from __future__ import annotations

import gzip
import json
import sys
import unicodedata
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))


def _gz(caminho: Path, linhas: list[str]) -> None:
    with gzip.open(caminho, "wt", encoding="utf-8") as f:
        f.write("".join(linhas))


def _ol(tipo: str, chave: str, obj: dict) -> str:
    return f"/type/{tipo}\t{chave}\t3\t2026-09-01T00:00:00\t{json.dumps(obj, ensure_ascii=False)}\n"


def escrever_dumps(pasta: Path, variante: int = 1, data: str = "2026-09-30") -> Path:
    pasta.mkdir(parents=True, exist_ok=True)
    _gz(pasta / f"ol_dump_authors_{data}.txt.gz", [
        _ol("author", "/authors/OL1A", {"name": "Machado de Assis"}),
        _ol("author", "/authors/OL2A", {"name": "Jane Austen"}),
        _ol("author", "/authors/OL3A", {"personal_name": "Clarice  Lispector"}),
        _ol("author", "/authors/OL4A", {"name": "Thomas Mann"}),
    ])
    _gz(pasta / f"ol_dump_works_{data}.txt.gz", [
        _ol("work", "/works/OL10W", {"title": "Dom Casmurro", "authors": [{"author": {"key": "/authors/OL1A"}}]}),
        _ol("work", "/works/OL20W", {"title": "Pride and Prejudice", "authors": [{"author": {"key": "/authors/OL2A"}}]}),
        _ol("work", "/works/OL30W", {"title": "A hora da estrela", "authors": [{"author": {"key": "/authors/OL3A"}}]}),
        _ol("work", "/works/OL40W", {"title": "Der Zauberberg", "authors": [{"author": {"key": "/authors/OL4A"}}]}),
    ])
    edicoes = [
        # brasileira, autores só pela obra, ISBN-10 que vira 978-85
        _ol("edition", "/books/OL100M", {"title": "Dom Casmurro /", "isbn_10": ["85-359-0277-5"],
                                         "works": [{"key": "/works/OL10W"}], "publishers": ["Penguin-Companhia"],
                                         "publish_date": "2016", "number_of_pages": 256,
                                         "languages": [{"key": "/languages/por"}], "covers": [8231432],
                                         "publish_country": "bl "}),
        # inglesa, popular
        _ol("edition", "/books/OL200M", {"title": "Pride and Prejudice", "isbn_13": ["9780141439518"],
                                         "authors": [{"key": "/authors/OL2A"}], "works": [{"key": "/works/OL20W"}],
                                         "publishers": ["Penguin Classics"], "publish_date": "January 30, 2003",
                                         "number_of_pages": 480, "languages": [{"key": "/languages/eng"}]}),
        _ol("edition", "/books/OL201M", {"title": "Pride & Prejudice", "isbn_13": ["9780199535569"],
                                         "works": [{"key": "/works/OL20W"}], "publish_date": "2008"}),
        # 978-65 (editora nova), ISBN com hífens
        _ol("edition", "/books/OL300M", {"title": "A hora da estrela", "isbn_13": ["978-65-5532-123-4"],
                                         "works": [{"key": "/works/OL30W"}], "publish_date": "2020",
                                         "languages": [{"key": "/languages/por"}]}),
        # alemã também na DNB (a DNB vence no grupo 978-3)
        _ol("edition", "/books/OL400M", {"title": "Zauberberg (OL)", "isbn_13": ["9783596294336"],
                                         "works": [{"key": "/works/OL40W"}]}),
        # sem ISBN válido: fica de fora
        _ol("edition", "/books/OL500M", {"title": "Sem ISBN", "isbn_13": ["9780000000000"]}),
        _ol("edition", "/books/OL501M", {"title": "Sem nada"}),
    ]
    if variante == 2:
        edicoes[2] = _ol("edition", "/books/OL201M", {"title": "Pride & Prejudice (Oxford)", "isbn_13": ["9780199535569"],
                                                     "works": [{"key": "/works/OL20W"}], "publish_date": "2008"})
        del edicoes[3]  # 978-65 sai
        edicoes.append(_ol("edition", "/books/OL600M", {"title": "Memórias póstumas de Brás Cubas",
                                                        "isbn_13": ["9788535910667"],
                                                        "authors": [{"key": "/authors/OL1A"}]}))
    _gz(pasta / f"ol_dump_editions_{data}.txt.gz", edicoes)
    _gz(pasta / f"ol_dump_ratings_{data}.txt.gz", [
        "/works/OL20W\t/books/OL200M\t5\t2025-01-01\n", "/works/OL20W\t\t4\t2025-01-02\n",
        "/works/OL10W\t/books/OL100M\t5\t2025-01-01\n",
    ])
    _gz(pasta / f"ol_dump_reading-log_{data}.txt.gz",
        ["/works/OL20W\t/books/OL200M\twant-to-read\t2025-01-01\n"] * 6
        + ["/works/OL30W\t/books/OL300M\talready-read\t2025-01-01\n"])
    nfd = lambda s: unicodedata.normalize("NFD", s)  # noqa: E731 - a DNB entrega em NFD
    xs = "^^<http://www.w3.org/2001/XMLSchema#string>"
    nt = [
        f'<https://d-nb.info/1> <http://purl.org/ontology/bibo/isbn13> "9783596294336"{xs} .\n',
        f'<https://d-nb.info/1> <http://purl.org/dc/elements/1.1/title> "{nfd("Der Zauberberg")}"{xs} .\n',
        '<https://d-nb.info/2> <http://purl.org/ontology/bibo/isbn13> "978-3-446-23620-2" .\n',
        '<https://d-nb.info/1> <http://rdaregistry.info/Elements/u/P60493> "Roman" .\n',
        '<https://d-nb.info/1> <http://rdaregistry.info/Elements/u/P60327> "Thomas Mann. Mit einem Nachwort von X" .\n',
        '<https://d-nb.info/3> <http://purl.org/dc/elements/1.1/title> "Zeitschrift ohne ISBN" .\n',
        '<https://d-nb.info/1> <http://purl.org/dc/elements/1.1/publisher> "S. Fischer" .\n',
        '<https://d-nb.info/1> <http://www.w3.org/2002/07/owl#sameAs> <http://example.org/x> .\n',
        '<https://d-nb.info/1> <http://purl.org/dc/terms/issued> "1991" .\n',
        f'<https://d-nb.info/2> <http://purl.org/dc/elements/1.1/title> "{nfd("Über Bücher")}\\u0021"@de .\n',
        '<https://d-nb.info/1> <http://purl.org/dc/terms/language> <http://id.loc.gov/vocabulary/iso639-2/ger> .\n',
        '<https://d-nb.info/2> <http://rdaregistry.info/Elements/u/P60327> "von Anna Müller und Bernd Weiß [Ill.]" .\n',
        '<https://d-nb.info/1> <http://iflastandards.info/ns/isbd/elements/P1053> "1008 S." .\n',
    ]
    _gz(pasta / "dnb-all_lds.nt.gz", [unicodedata.normalize("NFD", l) for l in nt])
    return pasta


@pytest.fixture
def dumps(tmp_path: Path) -> Path:
    return escrever_dumps(tmp_path / "dumps")
