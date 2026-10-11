"""O pipeline de ponta a ponta com os dumps de amostra: união, shards, catalog.db, delta, manifesto."""
from __future__ import annotations

import gzip
import hashlib
import json
import sqlite3
from argparse import Namespace
from pathlib import Path

from catalogo import catalogo_db, pipeline, shards
from catalogo.staging import Staging
from conftest import escrever_dumps


def rodar(dumps: Path, base: Path, **kw) -> dict:
    args = Namespace(dumps=str(dumps), trabalho=str(base / "trabalho"), saida=str(base / "saida"), top=kw.get("top", 50),
                     peso_br=kw.get("peso_br", 3), max_shard=kw.get("max_shard", 4000), revisao=kw.get("revisao", 1),
                     deltas=3, sem_dnb=kw.get("sem_dnb", False), hash_dumps=True, refazer=kw.get("refazer", []))
    return pipeline.executar(args)


def test_uniao_e_registros(dumps, tmp_path):
    m = rodar(dumps, tmp_path)
    st = Staging(tmp_path / "trabalho" / "staging.db")
    rec = {r[0]: r for r in st.db.execute("SELECT isbn13, titulo, autores, fonte, licenca, pontos FROM rec")}
    st.fechar()
    assert set(rec) == {"9788535902778", "9780141439518", "9780199535569", "9786555321234", "9783596294336",
                        "9783446236202"}
    # autores pela obra quando a edição não tem
    assert json.loads(rec["9788535902778"][2]) == ["Machado de Assis"]
    # grupo 978-3: a DNB vence o Open Library
    assert rec["9783596294336"][1:4] == ("Der Zauberberg", '["Thomas Mann"]', "dnb")
    assert rec["9780141439518"][3:5] == ("openlibrary", "OL-sem-direitos")
    assert m["versao"] == "2026-09-30.1"
    assert m["db"]["registros"] == 6


def test_shards_por_prefixo_com_divisao(dumps, tmp_path):
    rodar(dumps, tmp_path, max_shard=1)
    saida = tmp_path / "saida"
    indice = json.loads((saida / "isbn/v1/index.json").read_text())["prefixos"]
    # 9780141… e 9780199… dividem o prefixo 9780 até separar
    assert all(len(p) >= 7 for p in indice)
    for i in ("9788535902778", "9780141439518", "9780199535569", "9786555321234", "9783596294336", "9783446236202"):
        r = shards.procurar(saida, i)
        assert r is not None and r["i"] == i
    assert shards.procurar(saida, "9781234567897") is None
    r = shards.procurar(saida, "9788535902778")
    assert r == {"i": "9788535902778", "t": "Dom Casmurro", "a": ["Machado de Assis"], "p": "Penguin-Companhia",
                 "y": 2016, "n": 256, "l": "por", "c": "ol:8231432", "f": "openlibrary", "lic": "OL-sem-direitos"}


def test_catalog_db_top_n_com_peso_do_brasil_e_busca_sem_acento(dumps, tmp_path):
    m = rodar(dumps, tmp_path, top=3, peso_br=50)
    db = sqlite3.connect(tmp_path / "saida/catalog/v1/2026-09-30.1/catalog.db")
    isbns = [r[0] for r in db.execute("SELECT isbn13 FROM editions ORDER BY isbn13")]
    # P&P (o mais lido) + os dois brasileiros com peso; o resto fica só nos shards
    assert isbns == ["9780141439518", "9786555321234", "9788535902778"]
    achados = db.execute("SELECT e.title FROM editions_fts f JOIN editions e ON e.id = f.rowid "
                         "WHERE editions_fts MATCH ?", ("estrela",)).fetchall()
    assert achados == [("A hora da estrela",)]
    assert db.execute("SELECT count(*) FROM editions_fts WHERE editions_fts MATCH 'machado'").fetchone()[0] == 1
    meta = dict(db.execute("SELECT key, value FROM meta"))
    assert meta["registros"] == "3"
    assert meta["conteudo_sha256"] == catalogo_db.hash_conteudo(db) == m["db"]["conteudo_sha256"]
    gz = tmp_path / "saida" / m["db"]["path"]
    assert hashlib.sha256(gz.read_bytes()).hexdigest() == m["db"]["sha256"]
    assert gzip.decompress(gz.read_bytes()) == (tmp_path / "saida/catalog/v1/2026-09-30.1/catalog.db").read_bytes()


def test_reproduzivel(dumps, tmp_path):
    a = rodar(dumps, tmp_path / "a")
    b = rodar(dumps, tmp_path / "b")
    assert a["db"]["sha256"] == b["db"]["sha256"]
    sa = json.loads((tmp_path / "a/saida/isbn/v1/shards.json").read_text())
    sb = json.loads((tmp_path / "b/saida/isbn/v1/shards.json").read_text())
    assert sa == sb


def aplicar_delta(db: Path, delta_gz: Path) -> None:
    """O mesmo algoritmo do app (lib/features/catalog): transação, put = upsert, del = apagar."""
    con = sqlite3.connect(db)
    linhas = gzip.decompress(delta_gz.read_bytes()).decode().splitlines()
    cab = json.loads(linhas[0])
    with con:
        for l in linhas[1:]:
            op = json.loads(l)
            if op["op"] == "del":
                con.execute("DELETE FROM editions WHERE isbn13 = ?", (op["i"],))
                continue
            r = op["r"]
            # como o `jsonEncode` do Dart: compacto, sem escapar o que não é ASCII (achado 1 da revisão)
            vals = (r["i"], r["t"], r.get("s"), json.dumps(r["a"], ensure_ascii=False, separators=(",", ":")),
                    r.get("p"), r.get("y"),
                    r.get("n"), r.get("l"), r.get("c"), r["f"], r["lic"])
            con.execute(
                "INSERT INTO editions (isbn13, title, subtitle, authors, publisher, year, pages, language, cover_ref, "
                "source, source_license) VALUES (?,?,?,?,?,?,?,?,?,?,?) ON CONFLICT(isbn13) DO UPDATE SET "
                "title=excluded.title, subtitle=excluded.subtitle, authors=excluded.authors, publisher=excluded.publisher, "
                "year=excluded.year, pages=excluded.pages, language=excluded.language, cover_ref=excluded.cover_ref, "
                "source=excluded.source, source_license=excluded.source_license", vals)
        con.execute("UPDATE meta SET value = ? WHERE key = 'versao'", (cab["para"],))
    con.close()


def test_delta_entre_versoes_reproduz_a_nova(tmp_path):
    d1 = escrever_dumps(tmp_path / "d1", 1, "2026-09-30")
    m1 = rodar(d1, tmp_path)
    antigo = tmp_path / "saida/catalog/v1/2026-09-30.1/catalog.db"
    copia = tmp_path / "aparelho.db"
    copia.write_bytes(antigo.read_bytes())
    d2 = escrever_dumps(tmp_path / "d2", 2, "2026-10-31")
    # a v2 sai na mesma pasta de saída (para achar a anterior) com outro banco de trabalho
    m2 = pipeline.executar(Namespace(dumps=str(d2), trabalho=str(tmp_path / "trabalho2"), saida=str(tmp_path / "saida"),
                                     top=50, peso_br=3, max_shard=4000, revisao=1, deltas=3, sem_dnb=False,
                                     hash_dumps=False))
    assert m2["versao"] == "2026-10-31.1"
    assert len(m2["deltas"]) == 1
    d = m2["deltas"][0]
    # puts: Oxford (título), Brás Cubas (novo) e o livro de 2 autores da DNB (ano) — o hash do app com
    # vários autores tem de fechar
    assert (d["de"], d["put"], d["del"]) == ("2026-09-30.1", 3, 1)
    aplicar_delta(copia, tmp_path / "saida" / d["path"])
    con = sqlite3.connect(copia)
    assert catalogo_db.hash_conteudo(con) == m2["db"]["conteudo_sha256"]
    # o FTS acompanha o delta (gatilhos)
    assert con.execute("SELECT count(*) FROM editions_fts WHERE editions_fts MATCH 'oxford'").fetchone()[0] == 1
    assert con.execute("SELECT count(*) FROM editions_fts WHERE editions_fts MATCH 'estrela'").fetchone()[0] == 0
    assert m1["db"]["registros"] == 6 and m2["db"]["registros"] == 6
    manifesto = json.loads((tmp_path / "saida/catalog/v1/manifest.json").read_text())
    assert manifesto["versao"] == "2026-10-31.1"


def test_refazer_a_dnb_depois_de_uma_execucao_sem_ela(dumps, tmp_path):
    """Os dumps da DNB chegam depois: a 1ª execução sai sem eles; `--refazer dnb` só recarrega a DNB
    (e a união) e o resultado é o mesmo de uma execução completa."""
    sem = rodar(dumps, tmp_path / "a", sem_dnb=True)
    assert sem["db"]["registros"] == 5  # o ISBN que só a DNB tem ainda não entrou
    st = Staging(tmp_path / "a" / "trabalho" / "staging.db")
    assert st.db.execute("SELECT count(*) FROM cand WHERE fonte = 'dnb'").fetchone()[0] == 0
    st.fechar()
    depois = rodar(dumps, tmp_path / "a", refazer=["dnb"], revisao=2)
    completa = rodar(dumps, tmp_path / "b", revisao=2)
    assert depois["db"]["registros"] == completa["db"]["registros"] == 6
    assert depois["db"]["conteudo_sha256"] == completa["db"]["conteudo_sha256"]


def test_mesmo_banco_de_trabalho_com_dumps_novos_refaz_o_que_mudou(tmp_path):
    """No mês seguinte o comando do README roda com o MESMO --trabalho: o que mudou de entrada é refeito
    (achado 2 da revisão) e o resultado é igual ao de um banco de trabalho novo."""
    d1 = escrever_dumps(tmp_path / "d1", 1, "2026-09-30")
    d2 = escrever_dumps(tmp_path / "d2", 2, "2026-10-31")
    rodar(d1, tmp_path / "a")
    reaproveitado = rodar(d2, tmp_path / "a")
    novo = rodar(d2, tmp_path / "b")
    assert reaproveitado["versao"] == novo["versao"] == "2026-10-31.1"
    assert reaproveitado["db"]["conteudo_sha256"] == novo["db"]["conteudo_sha256"]
    assert reaproveitado["deltas"][0]["put"] > 0


def test_refazer_autores_refaz_as_edicoes_e_a_uniao(dumps, tmp_path):
    rodar(dumps, tmp_path)
    st = Staging(tmp_path / "trabalho" / "staging.db")
    assert st.desfazer("autores") == ["autores", "edicoes_ol", "unir"]
    assert not st.feito("edicoes_ol") and st.feito("obras") and st.feito("dnb")
    assert st.db.execute("SELECT count(*) FROM cand WHERE fonte = 'openlibrary'").fetchone()[0] == 0
    assert st.db.execute("SELECT count(*) FROM cand WHERE fonte = 'dnb'").fetchone()[0] > 0
    st.fechar()


def test_estagio_interrompido_e_refeito_sem_sobras(dumps, tmp_path):
    """Um estágio que caiu no meio (Ctrl+C) deixou linhas e não ficou marcado: a próxima execução
    apaga as sobras antes de refazê-lo (banco em WAL — não corrompe)."""
    rodar(dumps, tmp_path)
    st = Staging(tmp_path / "trabalho" / "staging.db")
    assert st.db.execute("PRAGMA journal_mode").fetchone()[0] == "wal"
    st.db.execute("DELETE FROM estagios WHERE nome IN ('autores', 'edicoes_ol', 'unir')")
    st.db.execute("INSERT INTO autores VALUES ('/authors/OL999A', 'Sobra de uma execução interrompida')")
    st.fechar()
    rodar(dumps, tmp_path, revisao=2)
    st = Staging(tmp_path / "trabalho" / "staging.db")
    assert st.db.execute("SELECT count(*) FROM autores WHERE chave = '/authors/OL999A'").fetchone()[0] == 0
    assert st.db.execute("SELECT count(*) FROM autores").fetchone()[0] == 4
    st.fechar()
