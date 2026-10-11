"""Limpeza de texto e campos (NFC, espaços, ano, páginas, idioma)."""
from __future__ import annotations

import re
import unicodedata

_ESPACOS = re.compile(r"\s+")
_ANO = re.compile(r"(1[4-9]\d\d|20\d\d)")
_PAGINAS = re.compile(r"(\d{1,5})")
ANO_MAXIMO = 2100

#: limites do servidor (catalog.editions) — o catálogo nunca gera um registro que ele recusaria
MAX_TITULO = 500


def limpar(v: object, maximo: int = MAX_TITULO) -> str | None:
    if not isinstance(v, str):
        return None
    # surrogate sozinho (JSON do dump com "\ud800") não vira UTF-8: sairia com erro no SQLite e no gzip
    v = v.encode("utf-8", "ignore").decode("utf-8")
    s = _ESPACOS.sub(" ", unicodedata.normalize("NFC", v)).strip()
    # pontuação final de catalogação ("Título /", "Editora :")
    s = s.rstrip(" /:;,").strip()
    if not s:
        return None
    return s[:maximo]


def ano(v: object) -> int | None:
    if isinstance(v, int):
        return v if 1450 <= v <= ANO_MAXIMO else None
    if not isinstance(v, str):
        return None
    m = _ANO.search(v)
    return int(m.group(1)) if m else None


def paginas(v: object) -> int | None:
    if isinstance(v, int):
        n = v
    elif isinstance(v, str):
        m = _PAGINAS.search(v)
        if not m:
            return None
        n = int(m.group(1))
    else:
        return None
    return n if 0 < n < 100_000 else None


def idioma_ol(chave: object) -> str | None:
    """'/languages/por' → 'por' (ISO 639-2/B, como no Open Library e na DNB)."""
    if isinstance(chave, str) and chave.startswith("/languages/"):
        c = chave.rsplit("/", 1)[1].strip().lower()
        return c if re.fullmatch(r"[a-z]{3}", c) else None
    return None


def idioma_uri(uri: str) -> str | None:
    """'http://id.loc.gov/vocabulary/iso639-2/ger' → 'ger'."""
    c = uri.rstrip("/").rsplit("/", 1)[-1].lower()
    return c if re.fullmatch(r"[a-z]{3}", c) else None
