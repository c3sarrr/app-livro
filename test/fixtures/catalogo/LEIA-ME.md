# Catálogo de teste (G07)

Gerado pelo pipeline `tools/catalog` a partir dos dumps de amostra de `tools/catalog/tests/conftest.py`
(variante 1 = 2026-09-30.1; variante 2 = 2026-10-31.1, com o delta da 1 para a 2). Prova que o
`catalog.db` feito em Python é lido pelo app (o hash do conteúdo bate nos dois lados).

Regerar (determinístico — mesmos bytes): `python3 tools/catalog/gerar_fixture_app.py`.
