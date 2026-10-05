# tools/catalog — pipeline do catálogo de livros (G07)

Dumps abertos → `catalog.db` (aparelho, top-N) + shards por prefixo de ISBN (borda: R2 + Worker) +
manifesto e delta entre versões. Anexo 02 §7 · ADR-008 · D-73/D-75. Licenças: `LICENCAS.md`.

## Rodar (Ubuntu do WSL — os dumps ficam fora do git, em `/root/booknest_catalogo`)

```bash
bash tools/catalog/baixar_dumps.sh tudo            # Open Library (~13 GB) + DNB (~9,5 GB), com retomada
cd tools/catalog
python3 -m catalogo.pipeline --dumps /root/booknest_catalogo/dumps \
  --trabalho /root/booknest_catalogo/trabalho --saida /root/booknest_catalogo/publicar --top 600000
python3 -m pytest -q tests                         # testes com dumps de amostra
```

Os estágios do banco de trabalho são retomáveis (o que já foi feito é pulado). A mesma entrada gera os
mesmos bytes (gzip sem data, ordem fixa) — os hashes do manifesto se repetem.

## Saída

```
publicar/
  catalog/v1/manifest.json                    ← versão atual (o app lê este)
  catalog/v1/<versão>/catalog.db.gz           ← banco do aparelho (top-N)
  catalog/v1/<versão>/delta-<anterior>.jsonl.gz
  isbn/v1/index.json                          ← prefixos (o Worker carrega uma vez)
  isbn/v1/<prefixo>.jsonl.gz                  ← todos os ISBNs do prefixo, um JSON por linha
  isbn/v1/shards.json                         ← contagem, bytes e sha256 de cada shard
```

Registro (shard e delta): `{"i": isbn13, "t": título, "s": subtítulo, "a": [autores], "p": editora,
"y": ano, "n": páginas, "l": idioma ISO 639-2/B, "c": capa ("ol:<id>"), "f": fonte, "lic": licença}`.

## Regras

- ISBN-10 vira ISBN-13; dígito verificador conferido; só 978/979.
- Um registro por ISBN: no grupo 978-3 vence a DNB; no resto, o Open Library; depois o mais completo.
- Pontos (popularidade): estantes + notas do Open Library (nota vale 2) da obra e da edição, nº de edições
  da obra (até 20) e completude; ×`--peso-br` para ISBN brasileiro ou idioma português (mercado de lançamento).
- DNB: as triplas de um mesmo título vêm espalhadas no dump — são filtradas (grep) e ordenadas por sujeito
  (sort em disco) antes de juntar.
- Disco e memória (o banco de trabalho fica no HD do WSL): nada de consulta aleatória ao banco por linha.
  Cada estágio grava num arquivo próprio em `--trabalho` (`autores.db`, `obras.db`, `pop.db`, `cand_ol.db`,
  `cand_dnb.db`, `rec.db`; `staging.db` guarda só os estágios feitos) e refazer um estágio apaga o arquivo —
  as tabelas ficam contíguas no disco. Autores e obras são gravados ordenados pela chave (tabela temporária
  + ordenação externa do SQLite); as edições consultam autores/obras em índices compactos em memória
  (`catalogo/indice.py`, ~1 GB com os dumps de 2026); a união lê os candidatos ordenados por ISBN. Espaço
  temporário do SQLite em `/var/tmp` (`SQLITE_TMPDIR` muda) — prever ~2× o tamanho da pasta de trabalho.
  Uma pasta de trabalho do formato antigo (um arquivo só) é recusada: use outra pasta.
- Um `.gz` cortado derruba a leitura (código de saída do `pigz`/`gzip` conferido) — baixe de novo.
