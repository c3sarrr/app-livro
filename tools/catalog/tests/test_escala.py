"""Escala dos dumps reais num HD: nada de consulta aleatória ao banco por registro (índices compactos em
memória) e a união igual à consulta SQL de referência (a versão anterior, com junções por linha)."""
from __future__ import annotations

import gzip
import json
import random

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
    st.db.executemany("INSERT INTO cand VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", linhas)
    st.db.commit()
    n = st.unir(peso_br=3)
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
    ])
    st = Staging(tmp_path / "staging.db")
    assert st.carregar_autores(dumps / "a.txt.gz") == 3
    assert st.carregar_obras(dumps / "w.txt.gz") == 2
    assert st.carregar_edicoes_ol(dumps / "e.txt.gz") == 3
    got = {i: json.loads(a) for i, a in st.db.execute("SELECT isbn13, autores FROM cand")}
    assert got == {"9780306406157": ["Antigo"], "9788535902778": ["Zero Sete", "Sete"], "9780141439518": ["Sete"]}
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
