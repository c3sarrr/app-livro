"""Escala dos dumps reais num HD: nada de consulta aleatória ao banco por registro (índices compactos em
memória) e a união igual à consulta SQL de referência (a versão anterior, com junções por linha)."""
from __future__ import annotations

import gzip
import json
import random
from pathlib import Path

from catalogo.indice import Contagem, Nomes, Obras
from catalogo import staging
from catalogo.staging import Staging
from conftest import _ol


def test_nomes_por_chave():
    n = Nomes("/authors/OL", "A")
    n.por("/authors/OL1A", "Machado")
    n.por("/authors/OL10A", "Clarice")
    n.por("/authors/OL010A", "Zero à esquerda")  # outra chave (texto), não pode colidir com OL10A
    n.por("/authors/fora-do-padrão", "Antigo")
    n.por("/authors/OL3000000A", "Ação Ñandú 日本")
    n.por("/authors/OL1A", "Machado de Assis")  # a última vence (como INSERT OR REPLACE)
    assert n.get("/authors/OL1A") == "Machado de Assis"
    assert n.get("/authors/OL10A") == "Clarice"
    assert n.get("/authors/OL010A") == "Zero à esquerda"
    assert n.get("/authors/fora-do-padrão") == "Antigo"
    assert n.get("/authors/OL3000000A") == "Ação Ñandú 日本"
    for ausente in ("/authors/OL2A", "/authors/OL99999999A", "/authors/OLA", "/works/OL1W", "/authors/OL-1A",
                    "/authors/OL²A"):
        assert n.get(ausente) is None
    assert len(n) == 5
    # a última gravação vence também quando ela não cabe no array (texto vazio ou enorme) — revisão 2, achado 7
    n.por("/authors/OL10A", "")
    assert n.get("/authors/OL10A") == ""
    n.por("/authors/OL1A", "x" * 70_000)
    assert n.get("/authors/OL1A") == "x" * 70_000
    n.por("/authors/OL1A", "De volta ao array")
    assert n.get("/authors/OL1A") == "De volta ao array"
    assert len(n) == 5


def test_obras_por_chave():
    o = Obras("/works/OL", "W", "/authors/OL", "A")
    o.por("/works/OL5W", ["/authors/OL1A", "/authors/OL2A"])
    o.por("/works/OL6W", ["/authors/OL1A", "/authors/esquisito", "/authors/OL07A"])
    o.por("/works/velha", ["/authors/OL3A"])
    o.por("/works/OL5W", ["/authors/OL9A"])  # a última vence
    o.por("/works/OL8W", [])
    assert o.get("/works/OL5W") == ["/authors/OL9A"]
    assert o.get("/works/OL6W") == ["/authors/OL1A", "/authors/esquisito", "/authors/OL07A"]
    assert o.get("/works/velha") == ["/authors/OL3A"]
    assert o.get("/works/OL8W") == []
    assert o.get("/works/OL7W") == [] and o.get("/works/OL123456789W") == []


def test_contagem_por_chave():
    c = Contagem("/works/OL", "W")
    c.somar("/works/OL5W", 2)
    c.somar("/works/OL5W", 1)
    c.somar("/works/x", 4)
    c.somar("/works/OL05W", 7)
    assert (c.get("/works/OL5W"), c.get("/works/x"), c.get("/works/OL05W"), c.get("/works/OL6W"), c.get(None)) == (
        3, 4, 7, 0, 0)


REFERENCIA = """
SELECT isbn13, titulo, subtitulo, autores, editora, ano, paginas, idioma, capa, fonte, licenca,
       CASE WHEN substr(isbn13, 1, 5) IN ('97885', '97865') OR idioma = 'por' THEN melhor * ? ELSE melhor END
FROM (
  SELECT c.*,
         max(coalesce(po.n, 0) + coalesce(pe.n, 0) + min(coalesce(eo.n, 1), 20) - 1 + c.completude)
           OVER (PARTITION BY c.isbn13) AS melhor,
         row_number() OVER (PARTITION BY c.isbn13
                            ORDER BY c.prioridade DESC, c.completude DESC, c.fonte, c.edicao, c.titulo, c.subtitulo,
                                     c.autores, c.editora, c.ano, c.paginas, c.idioma, c.capa, c.licenca, c.obra) AS rn
  FROM cand c
  LEFT JOIN pop_obra po ON po.chave = c.obra
  LEFT JOIN pop_edicao pe ON pe.chave = c.edicao
  LEFT JOIN (SELECT obra, count(*) AS n FROM (SELECT DISTINCT obra, edicao FROM cand WHERE obra IS NOT NULL)
             GROUP BY obra) eo ON eo.obra = c.obra
)
WHERE rn = 1 ORDER BY isbn13
"""


def test_uniao_igual_a_consulta_de_referencia(tmp_path, monkeypatch):
    # lotes e commits pequenos: a leitura ordenada continua aberta enquanto a gravação faz commit
    monkeypatch.setattr(staging, "LOTE", 7)
    monkeypatch.setattr(staging, "COMMIT_A_CADA", 20)
    rnd = random.Random(7)
    st = Staging(tmp_path / "staging.db")
    obras = [f"/works/OL{i}W" for i in range(1, 40)] + ["/works/antiga", "/works/OL040W"]
    edicoes = [f"/books/OL{i}M" for i in range(1, 300)] + ["/books/sem-numero"]
    st.db.executemany("INSERT INTO pop_obra VALUES (?, ?)", [(o, rnd.randint(1, 50)) for o in rnd.sample(obras, 20)])
    st.db.executemany("INSERT INTO pop_edicao VALUES (?, ?)",
                      [(e, rnd.randint(1, 9)) for e in rnd.sample(edicoes, 60)])
    linhas = []
    for _ in range(1500):
        isbn = f"978{rnd.choice(['85', '65', '0', '3', '1'])}{rnd.randint(0, 120):05d}"
        fonte = rnd.choice(["openlibrary", "openlibrary", "dnb"])
        obra = rnd.choice(obras) if fonte == "openlibrary" and rnd.random() < 0.9 else None
        ed = rnd.choice(edicoes) if fonte == "openlibrary" else None
        linhas.append((isbn, rnd.choice(["T", "U", "V"]), None, '["A"]', None, None, None,
                       rnd.choice([None, "por", "eng"]), None, obra, ed, fonte, "lic", rnd.randint(0, 6),
                       rnd.randint(0, 2)))
    st.db.executemany("INSERT INTO cand_ol VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                      [r for r in linhas if r[11] == "openlibrary"])
    st.db.executemany("INSERT INTO cand_dnb VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                      [r for r in linhas if r[11] == "dnb"])
    st.db.commit()
    n = st.unir(peso_br=3)
    assert st.unir(peso_br=3) == n  # refazer a união começa de uma tabela vazia
    feito = st.db.execute("SELECT * FROM rec ORDER BY isbn13").fetchall()
    esperado = st.db.execute(REFERENCIA, (3,)).fetchall()
    assert n == len(esperado) > 50
    assert feito == esperado
    st.fechar()


def test_edicoes_com_chaves_fora_do_padrao(tmp_path):
    """Chaves com zero à esquerda ou fora do padrão OL…A/OL…W continuam achando os nomes certos."""
    dumps = tmp_path / "dumps"
    dumps.mkdir()

    def gz(nome, linhas):
        with gzip.open(dumps / nome, "wt", encoding="utf-8") as f:
            f.write("".join(linhas))

    gz("a.txt.gz", [_ol("author", "/authors/OL7A", {"name": "Sete"}),
                    _ol("author", "/authors/OL07A", {"name": "Zero Sete"}),
                    _ol("author", "/authors/antigo", {"name": "Antigo"})])
    gz("w.txt.gz", [_ol("work", "/works/velha", {"authors": [{"author": "/authors/antigo"}]}),
                    _ol("work", "/works/OL1W", {"authors": [{"author": {"key": "/authors/OL07A"}},
                                                            {"author": {"key": "/authors/OL7A"}}]})])
    gz("e.txt.gz", [
        _ol("edition", "/books/OL1M", {"title": "Um", "isbn_13": ["9780306406157"],
                                       "works": [{"key": "/works/velha"}]}),
        _ol("edition", "/books/OL2M", {"title": "Dois", "isbn_13": ["9788535902778"],
                                       "works": [{"key": "/works/OL1W"}]}),
        _ol("edition", "/books/OL3M", {"title": "Três", "isbn_13": ["9780141439518"],
                                       "authors": [{"key": "/authors/OL7A"}, {"key": "/authors/sumiu"}]}),
        # dois ISBNs na mesma edição (13 e 10): uma linha para cada
        _ol("edition", "/books/OL4M", {"title": "Quatro", "isbn_13": ["9783161484100"], "isbn_10": ["0451526538"],
                                       "authors": [{"key": "/authors/OL07A"}]}),
    ])
    st = Staging(tmp_path / "staging.db")
    assert st.carregar_autores(dumps / "a.txt.gz") == 3
    assert st.carregar_obras(dumps / "w.txt.gz") == 2
    assert st.carregar_edicoes_ol(dumps / "e.txt.gz") == 5
    got = {i: (json.loads(a), p) for i, a, p in st.db.execute("SELECT isbn13, autores, prioridade FROM cand")}
    assert got == {"9780306406157": (["Antigo"], 1), "9788535902778": (["Zero Sete", "Sete"], 1),
                   "9780141439518": (["Sete"], 1), "9783161484100": (["Zero Sete"], 0),
                   "9780451526533": (["Zero Sete"], 1)}
    st.fechar()


def test_tabelas_de_trabalho_gravadas_em_ordem_de_chave(tmp_path, monkeypatch):
    """Inserir num B-tree em ordem aleatória é o que derruba o HD (cada linha, uma busca no disco): autores
    e obras entram ordenados pela chave; duplicadas → a última do arquivo vence."""
    dumps = tmp_path / "dumps"
    dumps.mkdir()
    chaves = [f"/authors/OL{i}A" for i in random.Random(3).sample(range(1, 5000), 3000)]
    with gzip.open(dumps / "a.txt.gz", "wt", encoding="utf-8") as f:
        f.write("".join(_ol("author", k, {"name": f"N{k}"}) for k in chaves))
        f.write(_ol("author", chaves[0], {"name": "Última"}))
    st = Staging(tmp_path / "staging.db")
    vistos: list[str] = []
    st.db.set_trace_callback(lambda sql: vistos.append(sql))
    assert st.carregar_autores(dumps / "a.txt.gz") == 3001
    st.db.set_trace_callback(None)
    assert not any("INSERT OR REPLACE INTO autores VALUES" in s for s in vistos)
    assert any("ORDER BY" in s and "INTO autores" in s for s in vistos)
    assert st.db.execute("SELECT nome FROM autores WHERE chave = ?", (chaves[0],)).fetchone() == ("Última",)
    assert st.db.execute("SELECT count(*) FROM autores").fetchone() == (3000,)
    st.fechar()


def test_refazer_estagio_recria_o_arquivo_sem_paginas_livres(dumps, tmp_path):
    """Cada estágio num arquivo próprio: refazer apaga o arquivo — nenhuma página liberada fica para a
    tabela seguinte ocupar fora de ordem (num banco único, o DELETE deixava o arquivo cheio de buracos)."""
    from test_pipeline import rodar

    rodar(dumps, tmp_path)
    trabalho = tmp_path / "trabalho"
    assert sorted(p.name for p in trabalho.glob("*.db")) == [
        "autores.db", "cand_dnb.db", "cand_ol.db", "obras.db", "pop.db", "rec.db", "staging.db"]
    st = Staging(trabalho / "staging.db")
    for esquema in ("autores", "obras", "cand_ol", "rec"):  # marca em cada arquivo: some se o arquivo for refeito
        st.db.execute(f"CREATE TABLE {esquema}.marca (x)")
    st.db.commit()
    assert st.desfazer("autores") == ["autores", "edicoes_ol", "unir"]
    st.fechar()
    rodar(dumps, tmp_path, revisao=2)
    st = Staging(trabalho / "staging.db")
    marcas = {e for e in ("autores", "obras", "cand_ol", "rec")
              if st.db.execute(f"SELECT 1 FROM {e}.sqlite_schema WHERE name = 'marca'").fetchone()}
    assert marcas == {"obras"}  # só o estágio que não foi refeito guarda a marca
    for esquema in ("autores", "obras", "pop", "cand_ol", "cand_dnb", "rec"):
        assert st.db.execute(f"PRAGMA {esquema}.freelist_count").fetchone() == (0,), esquema
        assert st.db.execute(f"PRAGMA {esquema}.journal_mode").fetchone() == ("wal",), esquema
    assert st.db.execute("SELECT count(*) FROM rec").fetchone() == (6,)
    st.fechar()


def test_banco_de_trabalho_no_formato_antigo_e_recusado(tmp_path):
    import sqlite3

    import pytest

    con = sqlite3.connect(tmp_path / "staging.db")
    con.execute("CREATE TABLE autores (chave TEXT PRIMARY KEY, nome TEXT NOT NULL) WITHOUT ROWID")
    con.commit()
    con.close()
    with pytest.raises(SystemExit, match="formato antigo"):
        Staging(tmp_path / "staging.db")


_NOMES_GET = Nomes.get


def _nome_anotando_o_processo(self, chave):
    """Envolve a consulta do nome do autor e anota em que processo ela rodou (arquivo em PIDS_NOMES)."""
    import os

    with open(os.environ["PIDS_NOMES"], "a") as f:
        f.write(f"{os.getpid()}\n")
    return _NOMES_GET(self, chave)


def test_edicoes_montadas_nos_processos_auxiliares(dumps, tmp_path, monkeypatch):
    """Nomes dos autores, obra e linhas finais são montados nos processos auxiliares (herdam os índices do
    principal pelo fork): o principal só grava. Mesmas linhas, na mesma ordem, que num processo só."""
    import os

    from catalogo import openlibrary

    edicoes = next(dumps.glob("ol_dump_editions_*.txt.gz"))
    monkeypatch.setattr(Nomes, "get", _nome_anotando_o_processo)

    def carregar(pasta, processos, bloco):
        monkeypatch.setattr(openlibrary, "PROCESSOS", processos)
        monkeypatch.setattr(openlibrary, "BLOCO_BYTES", bloco)
        pids = pasta / "pids.txt"
        monkeypatch.setenv("PIDS_NOMES", str(pids))
        st = Staging(pasta / "staging.db")
        st.carregar_autores(next(dumps.glob("ol_dump_authors_*.txt.gz")))
        st.carregar_obras(next(dumps.glob("ol_dump_works_*.txt.gz")))
        st.carregar_edicoes_ol(edicoes)
        linhas = st.db.execute("SELECT * FROM cand_ol ORDER BY rowid").fetchall()
        st.fechar()
        return linhas, set(pids.read_text().split())

    um, pids_um = carregar(tmp_path / "um", 1, 1 << 20)
    tres, pids_tres = carregar(tmp_path / "tres", 3, 300)
    assert um == tres and len(um) >= 5
    assert pids_um == {str(os.getpid())}
    assert pids_tres and str(os.getpid()) not in pids_tres  # com 3 processos, nenhum nome é buscado no principal
    assert {r[0]: json.loads(r[3]) for r in um}["9788535902778"] == ["Machado de Assis"]
    assert openlibrary._MONTAGEM is None  # nada fica pendurado no módulo depois do estágio


def test_chave_repetida_no_dump_a_ultima_versao_vence_mesmo_vazia(tmp_path):
    """Revisão 2, achado 6: a versão mais nova de um autor sem nome (ou de uma obra sem autores) apaga a antiga —
    o filtro vem depois da escolha da última versão."""
    dumps = tmp_path / "dumps"
    dumps.mkdir()
    with gzip.open(dumps / "a.txt.gz", "wt", encoding="utf-8") as f:
        f.write(_ol("author", "/authors/OL1A", {"name": "Velho"}) + _ol("author", "/authors/OL2A", {"name": "Fica"})
                + _ol("author", "/authors/OL1A", {"bio": "sem nome"}))
    with gzip.open(dumps / "w.txt.gz", "wt", encoding="utf-8") as f:
        f.write(_ol("work", "/works/OL1W", {"authors": [{"author": {"key": "/authors/OL2A"}}]})
                + _ol("work", "/works/OL2W", {"authors": [{"author": {"key": "/authors/OL2A"}}]})
                + _ol("work", "/works/OL1W", {"title": "sem autores"}))
    st = Staging(tmp_path / "staging.db")
    st.carregar_autores(dumps / "a.txt.gz")
    st.carregar_obras(dumps / "w.txt.gz")
    assert st.db.execute("SELECT chave, nome FROM autores ORDER BY chave").fetchall() == [("/authors/OL2A", "Fica")]
    assert st.db.execute("SELECT chave FROM obras ORDER BY chave").fetchall() == [("/works/OL2W",)]
    st.fechar()


def test_estagio_so_e_marcado_depois_de_gravado_no_disco(dumps, tmp_path, monkeypatch):
    """Revisão 2, achado 5: com synchronous=OFF, o arquivo do estágio é consolidado (checkpoint + fsync) antes
    da marca em `estagios` — uma queda logo depois não deixa um estágio "feito" com o fim perdido."""
    import os

    from catalogo.staging import ARQUIVOS
    from test_pipeline import rodar

    trabalho = tmp_path / "trabalho"
    vistos: dict[str, int] = {}
    marcar = Staging.marcar

    def espiando(self, nome, detalhe=None):
        wal = trabalho / f"{ARQUIVOS[nome][0]}.db-wal"

        def na_marca(sql):  # no instante em que a marca é gravada, o WAL do estágio já tem de estar vazio
            if sql.startswith("INSERT OR REPLACE INTO estagios"):
                vistos[nome] = wal.stat().st_size if wal.exists() else 0

        self.db.set_trace_callback(na_marca)
        try:
            return marcar(self, nome, detalhe)
        finally:
            self.db.set_trace_callback(None)

    monkeypatch.setattr(Staging, "marcar", espiando)
    sincronizados: list[str] = []
    fsync = os.fsync
    monkeypatch.setattr(os, "fsync", lambda fd: sincronizados.append(os.readlink(f"/proc/self/fd/{fd}")) or fsync(fd))
    rodar(dumps, tmp_path)
    assert vistos == {n: 0 for n in ARQUIVOS}
    assert {Path(s).name for s in sincronizados} >= {f"{e}.db" for e, _ in ARQUIVOS.values()}
