# S6 · Catálogo/ISBN — prova do ADR-008

Taxa de falha da busca por ISBN com uma **amostra real de livros brasileiros**: 300 ISBN-13 de editoras
brasileiras (978-65 e 978-85) sorteados (semente fixa) entre 3.366 edições do **Wikidata** — fonte
independente do Open Library. (A 1ª tentativa de amostra pelo Google Books sem chave recebeu 429 em todas as
buscas; o código continua como alternativa.)

```powershell
python3 spikes\S6_catalogo_isbn\amostra_isbn.py spikes\S6_catalogo_isbn\dados\amostra_isbn.json 300 wikidata
```

Resultado em `dados/amostra_isbn.json` (resumo + uma linha por ISBN) e no ADR-008.
