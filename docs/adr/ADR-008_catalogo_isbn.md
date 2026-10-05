# ADR-008 — Catálogo/ISBN em camadas: aparelho → borda (dumps abertos) → comunidade → APIs (BrasilAPI primeiro)

- **Status:** aceita (G02), **com um ajuste de expectativa**: para livros brasileiros a camada de APIs (BrasilAPI/CBL) é a que mais acha — perguntar ao Cesar (Q24)
- **Data:** 03/10/2026
- **Prova:** `spikes/S6_catalogo_isbn/` (`dados/amostra_isbn.json`)

## Contexto

Scanner sem limite (10+ leituras/pessoa/dia) com custo quase zero (Anexo 02 §7): leitura do código no aparelho;
`catalog.db` com os ISBNs mais comuns; catálogo próprio por prefixo no R2/Workers a partir de dumps CC0 (Open
Library, DNB); comunidade (2 confirmações); APIs externas por último (BrasilAPI → Hardcover → ISBNdb), com cota.

## Evidências — amostra real (03/10/2026)

300 ISBN-13 de editoras brasileiras sorteados entre 3.366 do Wikidata; consulta a cada um no **Open Library**
(a base dos dumps CC0 das camadas 2–3) e na **BrasilAPI** (`/api/isbn/v1`, camada 5). Zero erros de rede.

| Fonte | Achados | Taxa de falha |
|---|---|---|
| Open Library (≈ camadas 2–3) | 199/300 | **33,7 %** |
| — prefixo 978-85 (editoras mais antigas) | 146/198 | 26,3 % |
| — prefixo 978-65 (editoras novas, desde ~2020) | 53/102 | **48,0 %** |
| BrasilAPI (camada 5) | 292/300 | **2,7 %** — 287 pela **CBL** (agência brasileira do ISBN), 5 pelo Open Library |
| União (Open Library ou BrasilAPI) | 293/300 | **2,3 %** |

Os 7 que nenhuma achou são livros técnicos/acadêmicos e um lançamento de 2025 (lista no JSON); um ISBN da
amostra tem dígito verificador inválido (BrasilAPI responde 400).

## Decisão

1. Mantém as camadas do Anexo 02 §7 (aparelho → R2/Workers → comunidade → APIs), **sabendo** que os dumps
   abertos cobrem só ~2/3 dos livros brasileiros (metade dos lançamentos 978-65): o `catalog.db` e o R2 resolvem
   o grosso dos livros estrangeiros e dos brasileiros mais antigos/populares sem custo; o resto cai nas APIs.
2. **BrasilAPI é a 1ª API** (grátis, cobre 97 % da amostra pela CBL), com recuo para Hardcover → ISBNdb, cota do
   Anexo 02 (Grátis 30/dia, Pro 150/dia) e cache por ISBN no aparelho (`catalog_cache`).
3. Estimativa de chamadas externas: com ~34 % de falha nas camadas gratuitas para livros brasileiros, quem
   escaneia 10 livros/dia gasta ~3–4 consultas externas → bem dentro da cota de 30.
4. Licença: resultado de API externa vai para a estante da pessoa, **não** para o catálogo compartilhado
   (Anexo 02 §7.5) — até a G07 confirmar se os dados da CBL via BrasilAPI podem ir para o catálogo da
   comunidade (Q24). A camada da comunidade (OCR da capa + 2 confirmações) continua sendo o caminho para os
   lançamentos ausentes dos dumps entrarem no catálogo compartilhado.

## Consequências

- O custo do scanner continua quase zero, mas a **disponibilidade da BrasilAPI** (projeto comunitário, sem SLA)
  vira dependência para livros brasileiros → recuo automático para Hardcover/ISBNdb e monitoramento de falhas
  na Edge Function `isbn-lookup` (G07).
- Vale incluir no pipeline `tools/catalog/` (G07) outras fontes abertas de livros brasileiros, se existirem
  com licença compatível (a avaliar), para reduzir a dependência de API.

## Alternativas consideradas

- **Só APIs (sem dumps):** mais simples, mas custo e cota por leitura e dependência total de terceiros.
- **ISBNdb como 1ª API:** pago; a BrasilAPI cobre melhor os livros brasileiros na amostra.

## Medição da G07 (05/10/2026, catálogo `2026-09-30.1`)

Pipeline completo com os dumps reais (Open Library + DNB): **40.082.709 ISBNs** na borda (49.880 shards,
1,7 GB) e `catalog.db` com os 600 mil mais lidos (35,8 MB comprimido). Amostra estratificada (`tools/catalog/
medir_falha.py`; resultado em `docs/progresso/medicao_g07/falha_isbn.json`); APIs só para o que o catálogo
aberto não tem, como no app:

| Estrato | n | Só o aparelho | Aparelho + borda (Grátis, sem API) | Final com APIs |
|---|---|---|---|---|
| Brasil (amostra do S6) | 299 | 98,3 % de falha | **33,1 %** | **2,0 %** (a CBL achou 93 dos 99) |
| Mundo, obras populares (Wikidata, 20+ artigos) | 150 de 9.350 | 70,7 % | 45,3 % | ≤ 45,3 % — indeterminado |
| Mundo, cauda (1–3 artigos) | 150 de 24.830 | 90,0 % | 16,7 % | ≤ 16,7 % — indeterminado |

- A **BrasilAPI só aceita ISBN brasileiro**: para 978-0, 978-3 etc. responde 400 "ISBN inválido", com ou sem
  `providers`. A Edge Function `isbn-lookup` passou a consultar, fora do Brasil, a **API do Open Library** e o
  **Google Books** direto (D-73 ajustada). A API do Open Library não achou nenhum dos 93 que faltavam (o dump
  é do mesmo mês); o Google Books respondeu **429 sem chave** em todas as consultas — a camada de APIs para
  livros de fora do Brasil só pode ser medida (e só funciona em produção) com `GOOGLE_BOOKS_KEY` (ou Hardcover).
- O `catalog.db` do aparelho quase não acerta a amostra brasileira (5/299): a popularidade vem das estantes do
  Open Library, onde livro brasileiro quase não aparece. A borda resolve 2/3; a CBL, o resto.
- Consultas externas por 100 leituras: 33 (Brasil), 32 no total — dentro da cota (Grátis 30/dia ≈ 90 leituras).

## Pendências

- Chave do Google Books (e/ou Hardcover) na produção — e medir de novo a camada de APIs fora do Brasil.
- Peso do Brasil/português no top-N do `catalog.db` (hoje ×3) — só 5 dos 299 brasileiros entram; avaliar com
  dados de uso reais.
- Q24: licença dos dados da CBL para o catálogo compartilhado.
