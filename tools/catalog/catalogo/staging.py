"""Banco de trabalho (SQLite em disco): autores, obras, popularidade e candidatos por ISBN.

Os dumps não cabem na memória; tudo passa por aqui. A união escolhe UM registro por ISBN (fonte
de referência da região, depois o mais completo) e dá a pontuação de popularidade.
"""
from __future__ import annotations

import json
import os
import sqlite3
from collections import Counter
from collections.abc import Iterable, Iterator
from datetime import datetime, timezone
from pathlib import Path

from . import dnb, openlibrary
from .fluxo import carregar_json
from .indice import Contagem, Nomes, Obras
from .isbn import regiao
from .saida import autores_json

LOTE = 20_000
#: commit a cada tantas linhas (o WAL não cresce sem limite; um estágio interrompido perde só o lote)
COMMIT_A_CADA = 500_000
#: linha de progresso no log a cada tantas linhas (execuções reais levam dezenas de minutos por estágio)
PROGRESSO_A_CADA = 5_000_000


def _progresso(msg: str) -> None:
    print(f"[{datetime.now(timezone.utc).strftime('%H:%M:%S')}]   {msg}", flush=True)

CAND_COLUNAS = """(
  isbn13 TEXT NOT NULL, titulo TEXT NOT NULL, subtitulo TEXT, autores TEXT NOT NULL,
  editora TEXT, ano INTEGER, paginas INTEGER, idioma TEXT, capa TEXT, obra TEXT, edicao TEXT,
  fonte TEXT NOT NULL, licenca TEXT NOT NULL, completude INTEGER NOT NULL, prioridade INTEGER NOT NULL
)"""

#: Cada estágio grava num ARQUIVO próprio (anexado à conexão): refazer um estágio = apagar o arquivo e
#: criá-lo de novo. Num banco único, as páginas liberadas por um DELETE eram reaproveitadas pela tabela
#: seguinte fora de ordem, e ler uma tabela de 8 GB espalhada num HD leva horas (achado 16).
#: estágio → (arquivo/esquema, tabelas)
ARQUIVOS: dict[str, tuple[str, str]] = {
    "autores": ("autores", "CREATE TABLE IF NOT EXISTS autores.autores "
                           "(chave TEXT PRIMARY KEY, nome TEXT NOT NULL) WITHOUT ROWID"),
    # só as obras com autores (o que a união usa: autores da obra quando a edição não tem)
    "obras": ("obras", "CREATE TABLE IF NOT EXISTS obras.obras "
                       "(chave TEXT PRIMARY KEY, autores TEXT NOT NULL) WITHOUT ROWID"),
    "popularidade": ("pop", "CREATE TABLE IF NOT EXISTS pop.pop_obra (chave TEXT PRIMARY KEY, n INTEGER NOT NULL) "
                            "WITHOUT ROWID; CREATE TABLE IF NOT EXISTS pop.pop_edicao "
                            "(chave TEXT PRIMARY KEY, n INTEGER NOT NULL) WITHOUT ROWID"),
    "edicoes_ol": ("cand_ol", f"CREATE TABLE IF NOT EXISTS cand_ol.cand_ol {CAND_COLUNAS}"),
    "dnb": ("cand_dnb", f"CREATE TABLE IF NOT EXISTS cand_dnb.cand_dnb {CAND_COLUNAS}"),
    "unir": ("rec", """CREATE TABLE IF NOT EXISTS rec.rec (
  isbn13 TEXT PRIMARY KEY, titulo TEXT NOT NULL, subtitulo TEXT, autores TEXT NOT NULL,
  editora TEXT, ano INTEGER, paginas INTEGER, idioma TEXT, capa TEXT,
  fonte TEXT NOT NULL, licenca TEXT NOT NULL, pontos INTEGER NOT NULL
) WITHOUT ROWID"""),
}
FORMATO = 2  # PRAGMA user_version do staging.db (1 = banco único, antes do achado 16)

#: colunas do registro final, na ordem usada por shards, catalog.db e delta
COLUNAS = ("isbn13", "titulo", "subtitulo", "autores", "editora", "ano", "paginas", "idioma", "capa", "fonte", "licenca")


def _completude(*campos: object) -> int:
    return sum(1 for c in campos if c not in (None, "", "[]"))


class Staging:
    def __init__(self, caminho: Path):
        caminho.parent.mkdir(parents=True, exist_ok=True)
        self.pasta = caminho.parent
        self.db = sqlite3.connect(caminho)
        # WAL: interromper o pipeline (Ctrl+C, queda) não corrompe o banco — o estágio é refeito do zero
        # na próxima execução. synchronous=OFF: a queda do sistema pode perder o fim, nunca deixar o
        # banco inconsistente para o próprio processo. O cache do principal (só `estagios`) é o limite de
        # memória das ordenações do SQLite (1 GB); cada arquivo anexado tem o seu.
        self.db.executescript(
            "PRAGMA journal_mode=WAL; PRAGMA synchronous=OFF; PRAGMA temp_store=FILE; PRAGMA cache_size=-1000000;"
            "CREATE TABLE IF NOT EXISTS estagios (nome TEXT PRIMARY KEY, feito_em TEXT NOT NULL, detalhe TEXT)"
            " WITHOUT ROWID;"
        )
        tabelas = {r[0] for r in self.db.execute("SELECT name FROM sqlite_schema WHERE type = 'table'")}
        if self.db.execute("PRAGMA user_version").fetchone()[0] != FORMATO:
            if tabelas - {"estagios"}:
                raise SystemExit(f"{caminho}: banco de trabalho no formato antigo (um arquivo só) — use outra pasta "
                                 "em --trabalho ou apague esta")
            self.db.execute(f"PRAGMA user_version = {FORMATO}")
        for esquema, ddl in ARQUIVOS.values():
            self._anexar(esquema, ddl)
        # os candidatos das duas fontes, lidos juntos pela união
        self.db.execute("CREATE TEMP VIEW IF NOT EXISTS cand AS "
                        "SELECT * FROM cand_ol.cand_ol UNION ALL SELECT * FROM cand_dnb.cand_dnb")

    def _arquivo(self, esquema: str) -> Path:
        return self.pasta / f"{esquema}.db"

    def _anexar(self, esquema: str, ddl: str) -> None:
        self.db.execute(f"ATTACH DATABASE ? AS {esquema}", (str(self._arquivo(esquema)),))
        self.db.executescript(f"PRAGMA {esquema}.journal_mode=WAL; PRAGMA {esquema}.synchronous=OFF;"
                              f"PRAGMA {esquema}.cache_size=-200000; PRAGMA {esquema}.wal_autocheckpoint=50000;")
        self.db.executescript(ddl)

    def _recriar(self, estagio: str) -> None:
        """Apaga o arquivo do estágio e cria vazio (páginas novas sempre contíguas, no fim do arquivo)."""
        esquema, ddl = ARQUIVOS[estagio]
        self.db.commit()
        self.db.execute(f"DETACH DATABASE {esquema}")
        for suf in ("", "-wal", "-shm", "-journal"):
            Path(f"{self._arquivo(esquema)}{suf}").unlink(missing_ok=True)
        self._anexar(esquema, ddl)

    def fechar(self) -> None:
        self.db.commit()
        self.db.close()

    # ------------------------------------------------------------------ estágios
    def feito(self, nome: str) -> bool:
        return self.db.execute("SELECT 1 FROM estagios WHERE nome = ?", (nome,)).fetchone() is not None

    #: quem copia dados de quem: as edições do Open Library levam os nomes dos autores e das obras
    DEPENDENTES = {"autores": ["edicoes_ol"], "obras": ["edicoes_ol"]}

    def desfazer(self, nome: str) -> list[str]:
        """Esquece um estágio, o que ele gravou e os estágios que dependem dele (a união sempre).
        Devolve os estágios desfeitos."""
        feitos = []
        for n in [nome, *self.DEPENDENTES.get(nome, []), "unir"]:
            if n in feitos:
                continue
            self._recriar(n)
            self.db.execute("DELETE FROM estagios WHERE nome = ?", (n,))
            self.db.commit()
            feitos.append(n)
        return feitos

    def limpar_estagio(self, nome: str) -> None:
        """Antes de (re)fazer um estágio: apaga o que uma execução interrompida deixou dele."""
        self._recriar(nome)

    def assinatura(self, nome: str) -> object:
        """A assinatura das entradas gravada quando o estágio foi feito (None = não feito)."""
        r = self.db.execute("SELECT detalhe FROM estagios WHERE nome = ?", (nome,)).fetchone()
        if r is None:
            return None
        return json.loads(r[0] or "{}").get("assinatura")

    def firmar(self, estagio: str) -> None:
        """Consolida o arquivo do estágio no disco (checkpoint do WAL + fsync). Com synchronous=OFF, sem isto
        uma queda logo depois da marca deixaria o estágio "feito" com o fim perdido (revisão 2, achado 5)."""
        esquema, _ = ARQUIVOS[estagio]
        self.db.commit()
        self.db.execute(f"PRAGMA {esquema}.wal_checkpoint(TRUNCATE)").fetchall()
        fd = os.open(self._arquivo(esquema), os.O_RDONLY)
        try:
            os.fsync(fd)
        finally:
            os.close(fd)

    def marcar(self, nome: str, detalhe: dict | None = None) -> None:
        if nome in ARQUIVOS:
            self.firmar(nome)
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
                if n % PROGRESSO_A_CADA < LOTE:
                    _progresso(f"{n:,} linhas".replace(",", "."))
        if lote:
            self.db.executemany(sql, lote)
            n += len(lote)
        self.db.commit()
        return n

    def _lotes_ordenados(self, tabela: str, colunas: tuple[str, str], linhas: Iterable[tuple]) -> int:
        """Grava `linhas` em `tabela` (chave primária = 1ª coluna) em ordem de chave: primeiro no fim de uma
        tabela temporária (escrita sequencial), depois ordenadas pelo SQLite (ordenação externa) — inserir
        no B-tree na ordem do dump é uma busca aleatória no disco por linha. Chave repetida: a última do
        arquivo vence (como INSERT OR REPLACE na ordem do arquivo)."""
        a, b = colunas
        self.db.execute("DROP TABLE IF EXISTS temp.bruto")
        self.db.execute(f"CREATE TEMP TABLE bruto ({a} TEXT NOT NULL, {b} TEXT NOT NULL)")
        n = self._lotes("INSERT INTO temp.bruto VALUES (?, ?)", linhas)
        _progresso(f"{tabela}: ordenando {n:,} linhas pela chave".replace(",", "."))
        self.db.execute(f"INSERT OR REPLACE INTO {tabela}.{tabela} SELECT {a}, {b} FROM temp.bruto ORDER BY {a}, rowid")
        self.db.execute("DROP TABLE temp.bruto")
        self.db.commit()
        return n

    # ------------------------------------------------------------------ Open Library
    # Os vazios (autor sem nome, obra sem autores) entram na ordenação e só saem depois: a versão mais nova de
    # uma chave repetida vence mesmo vazia (revisão 2, achado 6).
    def carregar_autores(self, caminho: Path) -> int:
        n = self._lotes_ordenados("autores", ("chave", "nome"), openlibrary.autores(caminho))
        self.db.execute("DELETE FROM autores.autores WHERE nome = ''")
        self.db.commit()
        return n

    def carregar_obras(self, caminho: Path) -> int:
        linhas = ((k, json.dumps(a)) for k, _t, a in openlibrary.obras(caminho))
        n = self._lotes_ordenados("obras", ("chave", "autores"), linhas)
        self.db.execute("DELETE FROM obras.obras WHERE autores = '[]'")
        self.db.commit()
        return n

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
        # em ordem de chave: o B-tree cresce só pelo fim (sem busca aleatória no disco)
        self._lotes("INSERT OR REPLACE INTO pop.pop_obra VALUES (?, ?)", sorted(por_obra.items()))
        self._lotes("INSERT OR REPLACE INTO pop.pop_edicao VALUES (?, ?)", sorted(por_edicao.items()))
        return {"obras": len(por_obra), "edicoes": len(por_edicao)}

    def _indices_ol(self) -> tuple[Nomes, Obras]:
        """Autores e obras em memória (leitura sequencial das tabelas, em ordem de chave)."""
        nomes = Nomes("/authors/OL", "A")
        for k, nome in self.db.execute("SELECT chave, nome FROM autores"):
            nomes.por(k, nome)
        obras = Obras("/works/OL", "W", "/authors/OL", "A")
        for k, a in self.db.execute("SELECT chave, autores FROM obras"):
            obras.por(k, carregar_json(a))
        return nomes, obras

    def carregar_edicoes_ol(self, caminho: Path) -> int:
        nomes, obras = self._indices_ol()
        _progresso(f"índices em memória: {len(nomes):,} autores".replace(",", "."))

        def montar(e: openlibrary.Edicao) -> list[tuple]:
            """Roda nos processos auxiliares (herdam `nomes` e `obras` pelo fork)."""
            # a obra só é consultada quando a edição não traz os autores
            ks = e.autores or obras.get(e.obra)
            autores = [n for n in (nomes.get(k) for k in ks) if n is not None]
            a_json = autores_json(autores)
            comp = _completude(e.subtitulo, a_json, e.editora, e.ano, e.paginas, e.idioma, e.capa)
            return [(i, e.titulo, e.subtitulo, a_json, e.editora, e.ano, e.paginas, e.idioma, e.capa,
                     e.obra, e.chave, openlibrary.FONTE, openlibrary.LICENCA, comp, 1 if regiao(i) != "DE" else 0)
                    for i in e.isbns]

        return self._lotes("INSERT INTO cand_ol.cand_ol VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                           openlibrary.edicoes_montadas(caminho, montar))

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

        return self._lotes("INSERT INTO cand_dnb.cand_dnb VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", linhas())

    # ------------------------------------------------------------------ união
    #: desempate total na escolha do registro de um ISBN (mesma entrada → mesma saída, sempre)
    ORDEM_UNIAO = ("prioridade DESC, completude DESC, fonte, edicao, titulo, subtitulo, autores, editora, ano, "
                   "paginas, idioma, capa, licenca, obra")

    def unir(self, peso_br: int = 3) -> int:
        """Um registro por ISBN + pontos = popularidade da obra e da edição + nº de edições da obra
        (até 20) + completude; com peso para o mercado de lançamento (Brasil/português — D-73).

        Tudo em leituras ordenadas pelo SQLite (ordenação externa, sequencial): juntar tabelas grandes
        linha a linha seria uma busca aleatória no disco por candidato. Popularidade e nº de edições
        ficam em memória (índices compactos); `rec` é gravada em ordem de ISBN (o B-tree cresce pelo fim)."""
        pop_obra, pop_edicao = Contagem("/works/OL", "W"), Contagem("/books/OL", "M")
        ed_obra = Contagem("/works/OL", "W")
        for k, n in self.db.execute("SELECT chave, n FROM pop_obra"):
            pop_obra.somar(k, n)
        for k, n in self.db.execute("SELECT chave, n FROM pop_edicao"):
            pop_edicao.somar(k, n)
        anterior: tuple | None = None
        for par in self.db.execute("SELECT obra, edicao FROM cand WHERE obra IS NOT NULL ORDER BY obra, edicao"):
            if par != anterior:  # edições distintas da obra (uma edição com vários ISBNs conta uma vez)
                ed_obra.somar(par[0])
                anterior = par

        def pontos(obra: str | None, edicao: str | None, completude: int) -> int:
            n_ed = ed_obra.get(obra) if obra is not None else 0
            return pop_obra.get(obra) + pop_edicao.get(edicao) + min(n_ed or 1, 20) - 1 + completude

        cols = ", ".join(COLUNAS)
        consulta = f"SELECT {cols}, obra, edicao, completude FROM cand ORDER BY isbn13, {self.ORDEM_UNIAO}"

        def registros() -> Iterator[tuple]:
            atual: tuple | None = None
            melhor = 0
            for r in self.db.execute(consulta):
                if atual is not None and r[0] != atual[0]:
                    yield self._final(atual, melhor, peso_br)
                    atual = None
                p = pontos(r[11], r[12], r[13])
                if atual is None:
                    atual, melhor = r, p
                else:
                    melhor = max(melhor, p)
            if atual is not None:
                yield self._final(atual, melhor, peso_br)

        self._recriar("unir")  # `rec` sempre do zero, num arquivo novo
        return self._lotes("INSERT INTO rec.rec VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", registros())

    @staticmethod
    def _final(r: tuple, melhor: int, peso_br: int) -> tuple:
        isbn13, idioma = r[0], r[7]
        if isbn13[:5] in ("97885", "97865") or idioma == "por":
            melhor *= peso_br
        return (*r[:11], melhor)

    def registros(self, sql_extra: str = "", params: tuple = ()) -> Iterator[tuple]:
        cols = ", ".join(COLUNAS)
        yield from self.db.execute(f"SELECT {cols} FROM rec {sql_extra}", params)
