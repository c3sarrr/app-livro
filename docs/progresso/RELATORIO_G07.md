# Relatório da FASE G07 — Catálogo e scanner reais

Data: 05/10/2026 · branch `feat/g07-catalogo` (a partir de `feat/g06-sync`) · nada enviado ao GitHub nem à
nuvem (D-75). Evidências de cada subfase: `docs/progresso/G07.md`.
Decisões usadas (respondidas por você em 04/10, antes da fase): cobertura global por região do ISBN (D-73) ·
"adicionar este livro" só com toque explícito, quem enviou fica oculto (D-74) · Cloudflare e dumps só no PC
(D-75) · scanner mínimo no estilo do app (D-76) · `isbn13` na estante (D-77) · celular depois (roteiro).

## Resultado

| Subfase | Entrega | Prova |
|---|---|---|
| G07.1 Pipeline | `tools/catalog/`: Open Library + DNB → 1 registro por ISBN (fonte da região primeiro, peso para o Brasil) → shards por prefixo + `catalog.db` (top 600 mil, busca sem acento) + deltas + manifesto com sha256; licença por registro (`LICENCAS.md`); mesma entrada = mesmos bytes | pytest **31**; execução real abaixo |
| G07.2 Worker | `workers/catalog`: `GET /v1/isbn/:isbn` (shard do prefixo, cache por versão, 120/min por IP) e `/v1/catalog/*` com Range/ETag; R2 local (D-75) | vitest **10**; fumaça com os dados reais |
| G07.3 App | `catalog.db` baixado só no Wi-Fi, 1×/dia, com retomada, sha256, delta numa transação e troca atômica; ISBN em camadas: estante → `catalog.db` → borda → comunidade → `isbn-lookup` (cota; ordem pela região; devolve a cota se tudo falhar) | testes do catálogo; Deno `isbn-lookup` **18** |
| G07.4 Comunidade + D-77 | RPCs de envio/confirmação com trava por ISBN, 2 confirmações de outras contas, cascata ao excluir a conta, exportação; `user_books.isbn13` no servidor e no aparelho (migração local v2 sem perder dado) | pgTAP `20_catalogo_comunidade` (49); prova de corrida 80/80 |
| G07.5 Scanner | `/scanner` (D-76): câmera num cartão com borda e sombra dura, "Aponte para o código de barras da contracapa.", pílulas "Digitar ISBN"/"Lanterna", cartão do resultado com [Adicionar à estante]; ISBN-10/13 e 978-65; OCR da capa para "adicionar este livro"; aviso "já está na estante" | `scanner_screen_test` e afins; roteiro do celular (`G07_roteiro_celular.md`) |
| G07.6 Taxa de falha | medida contra o catálogo real (tabela abaixo) | `docs/progresso/medicao_g07/falha_isbn.json` |

### O catálogo real (versão `2026-09-30.1`, dumps de 30/09)

| Etapa | Números | Tempo |
|---|---|---|
| Autores | 15.444.094 | 2 min |
| Obras com autores | 39.372.141 | 27 min |
| Popularidade | 3.338.277 obras · 2.494.485 edições | 2 min |
| Edições do Open Library com ISBN | 37.142.887 candidatos | 18 min |
| DNB (Alemanha, CC0) | 8.428.258 candidatos | 83 min |
| União | **40.082.709 ISBNs** | 44 min |
| Shards da borda | 49.880 (até 3.998 livros cada), 1,7 GB | 23 min |
| `catalog.db` do aparelho | 600 mil livros, **35,8 MB** comprimido | 8 min |

Execução completa: ~3 h 20 min no HD do PC, 2,4 GB de memória no pico. **Reprodutível:** o `catalog.db`
gerado de novo do mesmo banco de trabalho tem o mesmo sha256, e 25 shards espalhados saem idênticos.
Publicação no R2 local: 49.885 objetos em 19,5 min. Fumaça no `wrangler dev` com esses dados: ISBN achado
200 (22–243 ms frio, 8–28 ms com cache), inexistente 404, inválido 400; manifesto; `catalog.db.gz` com
Range 206, retomada pelo fim, 304 e 416.

### Taxa de falha com ISBNs reais (G07.6)

| Amostra | Só o aparelho | Aparelho + borda (Grátis, sem API) | Final com APIs |
|---|---|---|---|
| Brasil — 299 ISBNs (mesma amostra do ADR-008) | 98,3 % | **33,1 %** | **3,0 %** (a CBL achou 90 dos 99 que faltavam) |
| Mundo, obras populares — 150 (de 9.350) | 70,7 % | 45,3 % | 45,3 % |
| Mundo, cauda longa — 150 (de 24.838) | 88,0 % | 15,3 % | 15,3 % |

Consultas externas: ~33 a cada 100 leituras de livros brasileiros (dentro da cota Grátis de 30/dia). Fora do
Brasil, a API do Open Library não achou nenhum dos que faltavam, e o Google Books só entra com chave (sem ela
respondeu 429 em todas) — é o que pode baixar os 45 % / 15 % (ver pendências).

Números finais: `flutter analyze` sem problemas · `flutter test` **1.036 verdes** (6 de integração à parte) ·
integração com Supabase + PowerSync locais **6/6** · `supabase test db` **21 arquivos, 524 testes** (PG 17) · Deno **70** (+9 de integração) ·
Worker **10** (+3 do script de publicação) · pytest **31** · gitleaks: histórico da fase e pastas novas sem vazamento.

## Revisão independente

Um agente separado leu tudo sem editar: **11 achados**, nenhum alto — todos corrigidos com teste novo (tabela
em `G07.md`). Os principais:

| # | Achado | O que fiz |
|---|---|---|
| 1 | O delta mensal nunca fechava o hash com livro de vários autores | autores em JSON compacto no pipeline, igual ao `jsonEncode` do Dart |
| 2 | O mesmo `--trabalho` com dumps novos publicava versão nova com dados velhos | assinatura das entradas por estágio; o que mudou é refeito com os dependentes |
| 3 | Duas confirmações simultâneas davam *deadlock* e uma se perdia | trava por ISBN + `FOR UPDATE`; prova de corrida: 21 *deadlocks* em 80 → 0 |
| 4 | Erro fora do catálogo (portal de Wi-Fi, HTML com 200) deixava o scanner preso em "Procurando…" | toda falha vira falha tipada; sempre há "Tentar de novo" |
| 5–11 | convidado marcado como "consultado", download inteiro a cada abertura, troca não atômica, `rejected`, cota gasta quando tudo falha, dígitos Unicode, medição não reprodutível | corrigidos |

## O que só os dados reais mostraram (achados 12–18)

| # | O que apareceu | Correção |
|---|---|---|
| 12 | o processo principal era o gargalo (ler o JSON num núcleo só) | blocos de 8 MB lidos em até 8 processos, na ordem do arquivo |
| 13 | registros antigos no dump de obras derrubavam o estágio | formatos antigos lidos; o resto é contado e descartado |
| 14 | (mutação no app) com o `.gz` quebrado o arquivo ficava aberto e não podia ser apagado no Windows | fecha num `finally` |
| 15 | um dump cortado virava catálogo pela metade, sem erro | o código de saída do `pigz`/`gzip` é conferido |
| 16 | no HD, inserir fora de ordem = uma busca no disco por linha (obras > 1 h; edições levariam dias) | um arquivo por estágio, gravação ordenada pela chave, índices compactos em memória, união por leitura ordenada |
| 17 | com tudo em memória, o processo principal virou o gargalo das edições | a montagem roda nos processos auxiliares (fork) |
| 18 | **a BrasilAPI recusa todo ISBN de fora do Brasil** (400 "ISBN inválido"): livro estrangeiro nunca era achado pela API | fora do Brasil, `isbn-lookup` consulta a API do Open Library direto (e o Google Books, com chave); D-73 e ADR-008 atualizados |

## Segunda revisão independente (achados 19–26)

Outro agente separado revisou só as mudanças dos achados 12–18: **8 achados, 1 alto**, todos corrigidos com
teste. Ele também conferiu, com 30 sementes aleatórias, que a união nova dá o mesmo resultado da consulta SQL
anterior.

| # | Achado | O que fiz |
|---|---|---|
| 19 (alta) | a publicação no R2 podia perder um shard com erro e publicar os manifestos assim mesmo | envio em paralelo que para no 1º erro e sai **antes** dos manifestos (3 testes); a publicação real já feita conferiu: 49.885 = 49.880 shards + 5 |
| 20 | a amostra do Wikidata podia ser cortada na ordem do texto do ISBN | sorteio com semente pelo próprio Wikidata + universo por `COUNT` (nesta medição não houve corte) |
| 21–22 | Google Books: o volume certo podia vir em 2º; sem chave, todo livro estrangeiro ausente virava "indisponível" | 10 resultados, vale o que tem o ISBN; o Google só entra com chave |
| 23 | com `synchronous=OFF`, uma queda logo depois da marca podia deixar um estágio "feito" pela metade | o arquivo do estágio é consolidado no disco antes da marca |
| 24–26 | casos latentes (chave repetida no dump, nome que não cabe no índice, BrasilAPI 200 sem título na medição) | corrigidos; nos dumps reais não há chave repetida |

Controles de mutação: **app 19/19** · pipeline **18/18** (união 7, arquivos por estágio 4, montagem 3, dump
cortado 1, gravação no disco e vazios 3) · `isbn-lookup` **6/6** · publicação **2/2** · banco: a prova de
corrida reprova sem a trava.

## Ajuste na D-73 (implementação, mesma decisão)

A D-73 dizia "fontes globais pela BrasilAPI". A BrasilAPI só aceita ISBN brasileiro (medido), então fora do
Brasil a função consulta as mesmas fontes **direto**: a API do Open Library e, quando houver chave, o Google
Books. A decisão — cobertura global com a ordem pela região do ISBN — continua a mesma; o texto da D-73 e o
ADR-008 foram atualizados.

## O que fica pendente (registrado)

- **Chave do Google Books** (`GOOGLE_BOOKS_KEY`, grátis) ou token do Hardcover na produção: sem elas, um livro de
  fora do Brasil que o catálogo aberto não tem dá "não achei" (o app oferece digitar os dados e enviar à
  comunidade). Com a chave, medir quanto cai dos 45 % / 15 %.
- **Teste no celular** (você pediu para depois): roteiro em `docs/progresso/G07_roteiro_celular.md` (~20 min).
- **Peso do Brasil no `catalog.db`:** só 5 dos 299 livros brasileiros da amostra entram nos 600 mil do aparelho
  (a popularidade vem das estantes do Open Library); a borda e a CBL resolvem — ajustar com dados de uso reais.
- **Publicação na nuvem** (D-75): conta Cloudflare, bucket R2 e Worker de verdade; a rotina mensal do pipeline.
- **Q24 / licença da CBL** para o catálogo compartilhado: continua fora (só na estante da pessoa).
- **Espaço no PC:** no disco do Ubuntu (D:) ficaram os dumps (26 GB) e o banco de trabalho (41 GB, dos quais
  24 GB são o arquivo ordenado da DNB); o R2 local ocupa ~2 GB no C:. O banco de trabalho pode ser apagado (o
  pipeline refaz tudo em ~3 h 20 min); o disco virtual do Ubuntu não encolhe sozinho — se quiser, compacto depois.

## Commits

Ver `git log feat/g06-sync..feat/g07-catalogo` (um por subfase, os da revisão e os dos dados reais).
