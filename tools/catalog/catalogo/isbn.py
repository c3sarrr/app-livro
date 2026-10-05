"""ISBN: validação, ISBN-10 → ISBN-13 e a região do grupo de registro (D-73)."""
from __future__ import annotations

import re

_LIMPA = re.compile(r"[\s\-‐‑‒–—.]")


def _digito13(doze: str) -> str:
    soma = sum(int(c) * (1 if i % 2 == 0 else 3) for i, c in enumerate(doze))
    return str((10 - soma % 10) % 10)


def normalizar(entrada: object) -> str | None:
    """ISBN-10 ou ISBN-13 (com ou sem hífens) → ISBN-13 válido, ou None."""
    if not isinstance(entrada, str):
        return None
    s = _LIMPA.sub("", entrada).upper()
    if len(s) == 10 and s[:9].isdigit() and (s[9].isdigit() or s[9] == "X"):
        soma = sum((10 - i) * int(c) for i, c in enumerate(s[:9]))
        soma += 10 if s[9] == "X" else int(s[9])
        if soma % 11:
            return None
        doze = "978" + s[:9]
        return doze + _digito13(doze)
    if len(s) == 13 and s.isdigit() and s[:3] in ("978", "979"):
        return s if _digito13(s[:12]) == s[12] else None
    return None


def para_isbn10(isbn13: str) -> str | None:
    """ISBN-13 do prefixo 978 → ISBN-10 (979 não tem ISBN-10)."""
    if not isbn13.startswith("978"):
        return None
    nove = isbn13[3:12]
    soma = sum((10 - i) * int(c) for i, c in enumerate(nove))
    d = (11 - soma % 11) % 11
    return nove + ("X" if d == 10 else str(d))


def eh_brasil(isbn13: str) -> bool:
    """Grupo de registro do Brasil: 978-85 e 978-65 (editoras novas, desde ~2020)."""
    return isbn13.startswith(("97885", "97865"))


def regiao(isbn13: str) -> str:
    """Região usada para ordenar fontes e o peso do lançamento (D-73)."""
    if eh_brasil(isbn13):
        return "BR"
    if isbn13.startswith("9783"):
        return "DE"  # grupo de língua alemã: a DNB é a fonte de referência
    return "MUNDO"
