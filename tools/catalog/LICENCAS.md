# Licenças das fontes do catálogo (G07 · D-73 · ADR-008)

Cada registro publicado leva a fonte (`f` / `source`) e a licença (`lic` / `source_license`).
Só entram nos shards da borda e no `catalog.db` fontes com licença que permite redistribuir.

| Fonte | Licença | Onde está dito | Entra no catálogo compartilhado |
|---|---|---|---|
| Open Library (Internet Archive) — `openlibrary` | sem novos direitos reivindicados (`OL-sem-direitos`) | <https://openlibrary.org/developers/licensing>: *"The Internet Archive does not assert any new copyright or other proprietary rights over any of the material in the Open Library database."* | sim |
| Deutsche Nationalbibliothek — `dnb` | CC0 1.0 (`CC0-1.0`) | <https://data.dnb.de/opendata/>: *"Metadata is provided under Creative Commons Zero (CC0 1.0) terms, unless otherwise stated."* | sim |
| Comunidade do BookNest — `community` | conforme os termos de uso (G25: a contribuição é cedida ao catálogo) | D-74 | sim, depois de 2 confirmações |
| CBL / Mercado Editorial (pela BrasilAPI) — `brasilapi` | **sem licença de reuso publicada** | <https://www.cbl.org.br/> não publica termos de reuso dos metadados | **não** — só na estante da pessoa e no cache do aparelho |
| Google Books (pela BrasilAPI) | termos do Google Books (sem armazenar) | Anexo 02 §7.5 | **não** |
| Hardcover / ISBNdb | termos de cada serviço | Anexo 02 §7.5 | **não** |

## Próximas fontes abertas (D-73 — cobertura global; avaliar a licença antes de ligar)

| Fonte | Cobertura | Licença declarada |
|---|---|---|
| British National Bibliography (BNB) | Reino Unido / inglês | CC0 1.0 |
| Biblioteca Nacional de España (datos.bne.es) | Espanha / espanhol | CC0 1.0 |
| Bibliothèque nationale de France (data.bnf.fr) | França / francês | Licence Ouverte (Etalab) — exige atribuição |

## Capas

O catálogo guarda só o **identificador** da capa na fonte (`ol:<id>`); a imagem não é republicada. A API de
capas do Open Library por **id** pode ser usada pelo app; por ISBN, ela limita 100 pedidos a cada 5 minutos por IP
e não serve para download em massa.
