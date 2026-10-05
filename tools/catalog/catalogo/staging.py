"""Banco de trabalho (SQLite em disco): autores, obras, popularidade e candidatos por ISBN.

Os dumps não cabem na memória; tudo passa por aqui. A união escolhe UM registro por ISBN (fonte
de referência da região, depois o mais completo) e dá a pontuação de popularidade.
"""
from __future__ import annotations

import json
import sqlite3
from collections import Counter
from collections.abc import Iterable, Iterator
from datetime import datetime, timezone
from pathlib import Path

from . import dnb, openlibrary
from .isbn import regiao
from .saida import autores_json

LOTE = 20_000
#: commit a cada tantas linhas (o WAL não cresce sem limite; um estágio interrompido perde só o lote)
COMMIT_A_CADA = 500_000

ESQUEMA = """
CREATE TABLE IF NOT EXISTS estagios (nome TEXT PRIMARY KEY, feito_em TEXT NOT NULL, detalhe TEXT) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS autores (chave TEXT PRIMARY KEY, nome TEXT NOT NULL) WITHOUT ROWID;
-- só as obras com autores (o que a união usa: autores da obra quando a edição não tem)
CREATE TABLE IF NOT EXISTS obras (chave TEXT PRIMARY KEY, autores TEXT NOT NULL) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS pop_obra (chave TEXT PRIMARY KEY, n INTEGER NOT NULL) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS pop_edicao (chave TEXT PRIMARY KEY, n INTEGER NOT NULL) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS cand (
  isbn13 TEXT NOT NULL, titulo TEXT NOT NULL, subtitulo TEXT, autores TEXT NOT NULL,
  editora TEXT, ano INTEGER, paginas INTEGER, idioma TEXT, capa TEXT, obra TEXT, edicao TEXT,
  fonte TEXT NOT NULL, licenca TEXT NOT NULL, completude INTEGER NOT NULL, prioridade INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS rec (
  isbn13 TEXT PRIMARY KEY, titulo TEXT NOT NULL, subtitulo TEXT, autores TEXT NOT NULL,
  editora TEXT, ano INTEGER, paginas INTEGER, idioma TEXT, capa TEXT,
  fonte TEXT NOT NULL, licenca TEXT NOT NULL, pontos INTEGER NOT NULL
) WITHOUT ROWID;
"""

#: colunas do registro final, na ordem usada por shards, catalog.db e delta
COLUNAS = ("isbn13", "titulo", "subtitulo", "autores", "editora", "ano", "paginas", "idioma", "capa", "fonte", "licenca")


def _completude(*campos: object) -> int:
    return sum(1 for c in campos if c not in (None, "", "[]"))


class Staging:
    def __init__(self, caminho: Path):
        caminho.parent.mkdir(parents=True, exist_ok=True)
        self.db = sqlite3.connect(caminho)
        # WAL: interromper o pipeline (Ctrl+C, queda) não corrompe o banco — o estágio é refeito do zero
        # (LIMPEZA) na próxima execução. synchronous=OFF: a queda do sistema pode perder o fim, nunca
        # deixar o banco inconsistente para o próprio processo.
        self.db.executescript(
            "PRAGMA journal_mode=WAL; PRAGMA synchronous=OFF; PRAGMA temp_store=FILE;"
            "PRAGMA cache_size=-1000000; PRAGMA wal_autocheckpoint=50000;" + ESQUEMA
        )

    def fechar(self) -> None:
        self.db.commit()
        self.db.close()

    # ------------------------------------------------------------------ estágios
    def feito(self, nome: str) -> bool:
        return self.db.execute("SELECT 1 FROM estagios WHERE nome = ?", (nome,)).fetchone() is not None

    #: o que cada estágio grava (para refazê-lo do zero, sem sobras da execução anterior)
    LIMPEZA = {
        "autores": ["DELETE FROM autores"],
        "obras": ["DELETE FROM obras"],
        "popularidade": ["DELETE FROM pop_obra", "DELETE FROM pop_edicao"],
        "edicoes_ol": [f"DELETE FROM cand WHERE fonte = '{openlibrary.FONTE}'"],
        "dnb": [f"DELETE FROM cand WHERE fonte = '{dnb.FONTE}'"],
        "unir": ["DELETE FROM rec"],
    }
    #: quem copia dados de quem: as edições do Open Library levam os nomes dos autores e das obras
    DEPENDENTES = {"autores": ["edicoes_ol"], "obras": ["edicoes_ol"]}

    def desfazer(self, nome: str) -> list[str]:
        """Esquece um estágio, o que ele gravou e os estágios que dependem dele (a união sempre).
        Devolve os estágios desfeitos."""
        feitos = []
        for n in [nome, *self.DEPENDENTES.get(nome, []), "unir"]:
            if n in feitos:
                continue
            for sql in self.LIMPEZA.get(n, []):
                self.db.execute(sql)
            self.db.execute("DELETE FROM estagios WHERE nome = ?", (n,))
            feitos.append(n)
        self.db.commit()
        return feitos

    def limpar_estagio(self, nome: str) -> None:
        """Antes de (re)fazer um estágio: apaga o que uma execução interrompida deixou dele."""
        for sql in self.LIMPEZA.get(nome, []):
            self.db.execute(sql)
        self.db.commit()

    def assinatura(self, nome: str) -> object:
        """A assinatura das entradas gravada quando o estágio foi feito (None = não feito)."""
        r = self.db.execute("SELECT detalhe FROM estagios WHERE nome = ?", (nome,)).fetchone()
        if r is None:
            return None
        return json.loads(r[0] or "{}").get("assinatura")

    def marcar(self, nome: str, detalhe: dict | None = None) -> None:
        self.db.execute(
            "INSERT OR REPLACE INTO estagios VALUES (?, ?, ?)",
            (nome, datetime.now(timezone.utc).isoformat(timespec="seconds"), json.dumps(detalhe or {})),
        )
        self.db.commit()

    def _lotes(self, sql: str, linhas: Iterable[tuple]) -> int:
        n, lote, desde_commit = 0, [], 0
        for linha in linhas:
            lote.append(linha)
            if len(lote) >= LOTE:
                self.db.executemany(sql, lote)
                n += len(lote)
                desde_commit += len(lote)
                lote.clear()
                if desde_commit >= COMMIT_A_CADA:
                    self.db.commit()
                    desde_commit = 0
        if lote:
            self.db.executemany(sql, lote)
            n += len(lote)
        self.db.commit()
        return n

    # ------------------------------------------------------------------ Open Library
    def carregar_autores(self, caminho: Path) -> int:
        return self._lotes("INSERT OR REPLACE INTO autores VALUES (?, ?)", openlibrary.autores(caminho))

    def carregar_obras(self, caminho: Path) -> int:
        linhas = ((k, json.dumps(a)) for k, _t, a in openlibrary.obras(caminho) if a)
        return self._lotes("INSERT OR REPLACE INTO obras VALUES (?, ?)", linhas)

    def carregar_popularidade(self, notas: Path | None, estantes: Path | None) -> dict:
        """Estante de leitura vale 1, nota vale 2 (quem avalia leu)."""
        por_obra: Counter[str] = Counter()
        por_edicao: Counter[str] = Counter()
        for caminho, peso in ((estantes, 1), (notas, 2)):
            if caminho is None:
                continue
            for obra, edicao in openlibrary.contagens(caminho):
                por_obra[obra] += peso
                if edicao:
                    por_edicao[edicao] += peso
        self._lotes("INSERT OR REPLACE INTO pop_obra VALUES (?, ?)", por_obra.items())
        self._lotes("INSERT OR REPLACE INTO pop_edicao VALUES (?, ?)", por_edicao.items())
        return {"obras": len(por_obra), "edicoes": len(por_edicao)}

    def _nomes(self, chaves: set[str]) -> dict[str, str]:
        out: dict[str, str] = {}
        lista = sorted(chaves)
        for i in range(0, len(lista), 900):
            parte = lista[i : i + 900]
            q = f"SELECT chave, nome FROM autores WHERE chave IN ({','.join('?' * len(parte))})"
            out.update(self.db.execute(q, parte).fetchall())
        return out

    def _obras(self, chaves: set[str]) -> dict[str, list[str]]:
        """Autores (chaves) de cada obra; em ordem de chave (leitura do B-tree em sequência)."""
        out: dict[str, list[str]] = {}
        lista = sorted(chaves)
        for i in range(0, len(lista), 900):
            parte = lista[i : i + 900]
            q = f"SELECT chave, autores FROM obras WHERE chave IN ({','.join('?' * len(parte))})"
            for k, a in self.db.execute(q, parte):
                out[k] = json.loads(a)
        return out

    def carregar_edicoes_ol(self, caminho: Path) -> int:
        def linhas() -> Iterator[tuple]:
            lote: list[openlibrary.Edicao] = []

            def esvaziar() -> Iterator[tuple]:
                # a obra só é consultada quando a edição não traz os autores
                obras = self._obras({e.obra for e in lote if e.obra and not e.autores})
                chaves = {k for e in lote for k in e.autores}
                for e in lote:
                    if not e.autores and e.obra in obras:
                        chaves.update(obras[e.obra])
                nomes = self._nomes(chaves)
                for e in lote:
                    ks = e.autores or obras.get(e.obra or "", [])
                    autores = [nomes[k] for k in ks if k in nomes]
                    a_json = autores_json(autores)
                    comp = _completude(e.subtitulo, a_json, e.editora, e.ano, e.paginas, e.idioma, e.capa)
                    for i in e.isbns:
                        prio = 1 if regiao(i) != "DE" else 0
                        yield (i, e.titulo, e.subtitulo, a_json, e.editora, e.ano, e.paginas, e.idioma, e.capa,
                               e.obra, e.chave, openlibrary.FONTE, openlibrary.LICENCA, comp, prio)
                lote.clear()

            for e in openlibrary.edicoes(caminho):
                lote.append(e)
                if len(lote) >= LOTE:
                    yield from esvaziar()
            yield from esvaziar()

        return self._lotes("INSERT INTO cand VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", linhas())

    # ------------------------------------------------------------------ DNB
    def carregar_dnb(self, caminho: Path, trabalho: Path | None = None) -> int:
        def linhas() -> Iterator[tuple]:
            for t in dnb.titulos(caminho, trabalho):
                a_json = autores_json(t.autores)
                comp = _completude(t.subtitulo, a_json, t.editora, t.ano, t.paginas, t.idioma, None)
                for i in t.isbns:
                    prio = 2 if regiao(i) == "DE" else 0
                    yield (i, t.titulo, t.subtitulo, a_json, t.editora, t.ano, t.paginas, t.idioma, None,
                           None, None, dnb.FONTE, dnb.LICENCA, comp, prio)

        return self._lotes("INSERT INTO cand VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", linhas())

    # ------------------------------------------------------------------ união
    def unir(self, peso_br: int = 3) -> int:
        """Um registro por ISBN + pontos = popularidade da obra e da edição + nº de edições da obra
        (até 20) + completude; com peso para o mercado de lançamento (Brasil/português — D-73)."""
        self.db.executescript(
            """
            DROP TABLE IF EXISTS ed_por_obra;
            CREATE TABLE ed_por_obra AS
              SELECT obra, count(*) AS n FROM (SELECT DISTINCT obra, edicao FROM cand WHERE obra IS NOT NULL)
              GROUP BY obra;
            CREATE UNIQUE INDEX ed_por_obra_idx ON ed_por_obra (obra);
            DELETE FROM rec;
            """
        )
        self.db.execute(
            """
            INSERT INTO rec
            SELECT isbn13, titulo, subtitulo, autores, editora, ano, paginas, idioma, capa, fonte, licenca,
                   CASE WHEN substr(isbn13, 1, 5) IN ('97885', '97865') OR idioma = 'por'
                        THEN melhor * ? ELSE melhor END
            FROM (
              SELECT c.*,
                     max(coalesce(po.n, 0) + coalesce(pe.n, 0) + min(coalesce(eo.n, 1), 20) - 1 + c.completude)
                       OVER (PARTITION BY c.isbn13) AS melhor,
                     row_number() OVER (PARTITION BY c.isbn13
                                        ORDER BY c.prioridade DESC, c.completude DESC, c.fonte, c.edicao, c.titulo)
                       AS rn
              FROM cand c
              LEFT JOIN pop_obra po ON po.chave = c.obra
              LEFT JOIN pop_edicao pe ON pe.chave = c.edicao
              LEFT JOIN ed_por_obra eo ON eo.obra = c.obra
            )
            WHERE rn = 1
            """,
            (peso_br,),
        )
        self.db.commit()
        return self.db.execute("SELECT count(*) FROM rec").fetchone()[0]

    def registros(self, sql_extra: str = "", params: tuple = ()) -> Iterator[tuple]:
        cols = ", ".join(COLUNAS)
        yield from self.db.execute(f"SELECT {cols} FROM rec {sql_extra}", params)
