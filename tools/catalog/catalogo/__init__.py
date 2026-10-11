"""Pipeline do catálogo de livros do BookNest (G07 · Anexo 02 §7 · ADR-008 · D-73).

Dumps abertos → registros normalizados (NFC, ISBN-13, autores, licença por registro) → shards por
prefixo de ISBN (camada da borda: R2 + Worker) e `catalog.db` com os mais lidos (camada do aparelho),
com manifestos e delta entre versões. Tudo determinístico: a mesma entrada gera os mesmos bytes.
"""
