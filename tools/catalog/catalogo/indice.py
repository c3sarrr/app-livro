"""Índices compactos em memória para as chaves do Open Library (`/authors/OL123A`, `/works/OL45W`…).

Com os dumps reais (15 mi de autores, dezenas de milhões de obras e edições) e o banco de trabalho num HD,
consultar o SQLite a cada edição é uma busca aleatória no disco por linha — dias de execução. Aqui o número
da chave endereça direto um `array` (poucos bytes por chave, sem um objeto Python por registro); chave fora
do padrão (registro antigo, zero à esquerda) vai para um dicionário à parte e nunca colide com outra.
"""
from __future__ import annotations

from array import array

#: números acima disso vão para o dicionário (protege a memória de uma chave absurda no dump)
LIMITE = 100_000_000


class _Chaves:
    def __init__(self, prefixo: str, sufixo: str):
        self.prefixo = prefixo
        self.sufixo = sufixo
        self._ini = len(prefixo)
        self._fim = -len(sufixo) if sufixo else None

    def numero(self, chave: str | None) -> int | None:
        """O número da chave no padrão exato (sem zero à esquerda), ou None."""
        if not chave or not chave.startswith(self.prefixo) or not chave.endswith(self.sufixo):
            return None
        meio = chave[self._ini : self._fim]
        if not meio or not meio.isascii() or not meio.isdigit() or (meio[0] == "0" and len(meio) > 1):
            return None
        n = int(meio)
        return n if n < LIMITE else None

    def chave(self, n: int) -> str:
        return f"{self.prefixo}{n}{self.sufixo}"


def _crescer(a: array, n: int) -> None:
    """Garante a posição n (zeros = vazio), crescendo em blocos para não realocar a cada chave."""
    if n >= len(a):
        novo = max(n + 1, len(a) + (len(a) >> 1), 1024)
        a.frombytes(bytes(a.itemsize * (novo - len(a))))


class Nomes:
    """chave → texto (nomes dos autores): bytes UTF-8 num bloco único, início e tamanho por número."""

    def __init__(self, prefixo: str, sufixo: str):
        self._k = _Chaves(prefixo, sufixo)
        self._pos = array("Q")
        self._tam = array("H")  # 0 = ausente (texto vazio não entra)
        self._bloco = bytearray()
        self._outros: dict[str, str] = {}
        self._n = 0

    def por(self, chave: str, texto: str) -> None:
        """A última gravação de uma chave vence (como INSERT OR REPLACE)."""
        b = texto.encode("utf-8")
        n = self._k.numero(chave)
        no_array = n is not None and n < len(self._tam) and self._tam[n] > 0
        novo = not no_array and chave not in self._outros
        if n is None or not b or len(b) > 0xFFFF:  # não cabe no array: dicionário (e o array esquece a chave)
            if no_array:
                self._tam[n] = 0  # type: ignore[index]
            self._outros[chave] = texto
        else:
            self._outros.pop(chave, None)
            _crescer(self._pos, n)
            _crescer(self._tam, n)
            self._pos[n] = len(self._bloco)
            self._tam[n] = len(b)
            self._bloco += b
        if novo:
            self._n += 1

    def get(self, chave: str | None) -> str | None:
        if not chave:
            return None
        n = self._k.numero(chave)
        if n is not None and n < len(self._tam) and self._tam[n]:
            p = self._pos[n]
            return self._bloco[p : p + self._tam[n]].decode("utf-8")
        return self._outros.get(chave)

    def __len__(self) -> int:
        return self._n


class Obras:
    """chave da obra → chaves dos autores (no máximo 255), como números num bloco único."""

    def __init__(self, prefixo: str, sufixo: str, prefixo_autor: str, sufixo_autor: str):
        self._k = _Chaves(prefixo, sufixo)
        self._a = _Chaves(prefixo_autor, sufixo_autor)
        self._pos = array("I")
        self._tam = array("B")  # nº de autores + 1 (0 = ausente)
        self._bloco = array("I")
        self._outros: dict[str, list[str]] = {}

    def por(self, chave: str, autores: list[str]) -> None:
        nums = [self._a.numero(a) for a in autores[:254]]
        n = self._k.numero(chave)
        if n is None or any(x is None for x in nums):
            self._outros[chave] = list(autores[:254])
            if n is not None and n < len(self._tam):
                self._tam[n] = 0  # a última versão é a do dicionário
            return
        self._outros.pop(chave, None)
        _crescer(self._pos, n)
        _crescer(self._tam, n)
        self._pos[n] = len(self._bloco)
        self._tam[n] = len(nums) + 1
        self._bloco.extend(nums)  # type: ignore[arg-type]

    def get(self, chave: str | None) -> list[str]:
        n = self._k.numero(chave)
        if n is not None and n < len(self._tam) and self._tam[n]:
            p = self._pos[n]
            return [self._a.chave(x) for x in self._bloco[p : p + self._tam[n] - 1]]
        return list(self._outros.get(chave, [])) if chave else []


class Contagem:
    """chave → inteiro ≥ 0 (popularidade, nº de edições da obra); ausente = 0."""

    def __init__(self, prefixo: str, sufixo: str):
        self._k = _Chaves(prefixo, sufixo)
        self._v = array("I")
        self._outros: dict[str, int] = {}

    def somar(self, chave: str | None, valor: int = 1) -> None:
        if not chave:
            return
        n = self._k.numero(chave)
        if n is None:
            self._outros[chave] = self._outros.get(chave, 0) + valor
            return
        _crescer(self._v, n)
        self._v[n] = min(self._v[n] + valor, 0xFFFFFFFF)

    def get(self, chave: str | None) -> int:
        if not chave:
            return 0
        n = self._k.numero(chave)
        if n is None:
            return self._outros.get(chave, 0)
        return self._v[n] if n < len(self._v) else 0
