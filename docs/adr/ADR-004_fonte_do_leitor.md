# ADR-004 — Fonte do leitor: Literata variável com `opsz` explícito

- **Status:** aceita pelo spike S1 (G02) · aguarda a aprovação da G02 pelo Cesar · confirma a **D-17**
- **Data:** 03/10/2026
- **Prova:** `spikes/S1_fonte_variavel/` (números em `dados/resultado_flutter.json`)

## Contexto

O corpo do leitor (tela 19) é Literata 20,5 px com `font-optical-sizing: auto`: o Chromium escolhe o eixo
`opsz` igual ao tamanho em px. O leitor oferece 7 tamanhos (D-20: 16 · 17,5 · 19 · **20,5** · 22 · 24 · 26)
e as telas usam ainda Literata 400/500 em 15–26 px. A D-17 propôs a fonte **variável** com `opsz = tamanho`
e `wght` via `fontVariations`, trocando por instâncias estáticas se o desvio passasse de 0,05 px por linha.

## Decisão

1. O leitor usa **`Literata-VF.ttf`** (o binário latin variável `opsz`+`wght` do próprio arquivo de design,
   convertido na G01.7) com **`FontVariation('opsz', tamanho)` e `FontVariation('wght', peso)` sempre
   explícitos** — o Flutter **não** aplica optical size automático.
2. Subconjuntos `Literata-VFExt` / `-VFVi` / `-VFCyr*` / `-VFGr*` entram como famílias de fallback
   (`fontFamilyFallback`, na ordem do `unicode-range`), com as mesmas variações (D-18: conteúdo do livro).
3. Um helper único monta o `TextStyle` do leitor (`reader_typography.dart`, G11/G14) — ninguém escreve
   `fontVariations` à mão; teste de unidade garante que `opsz == fontSize`.
4. As instâncias estáticas da G01.7 continuam válidas (≤ 0,0074 px) e são o **plano B** se algum aparelho
   desenhar a variável errado.

## Evidências (Flutter 3.47.2 / Dart 3.13.2 no Windows × Chromium 141)

Amostra: caps. XXXII–XXXIII do EPUB real de *Dom Casmurro* (Gutenberg #55752), 30 parágrafos,
7.031 caracteres, quebrados a 334 px (390 − 2 × 28) com recuo de 1,3 em, nos 7 tamanhos do leitor →
**1.701 linhas**. Largura de cada linha isolada no Chromium a zoom 100 (sem o arredondamento de 1/64 px);
conferência: Chromium = HarfBuzz com `opsz = tamanho` em até 0,0007 px.

| Tamanho | Linhas | VF + `opsz` (máx) | VF sem `opsz` (máx) | Estática (máx) | Quebras iguais |
|---|---|---|---|---|---|
| 16 | 190 | **0,0006** | 0,570 | 0,0062 | 190/190 |
| 17,5 | 203 | **0,0006** | 0,703 | — | 203/203 |
| 19 | 221 | **0,0006** | 0,980 | — | 221/221 |
| **20,5** | 241 | **0,0007** | 1,054 | 0,0026 | 241/241 |
| 22 | 259 | **0,0005** | 1,316 | — | 259/259 |
| 24 | 281 | **0,0007** | 1,592 | — | 281/281 |
| 26 | 306 | **0,0008** | 2,038 | 0,0074 | 306/306 |

- Gate da D-17 (≤ 0,05 px/linha): **passa com folga de 60×**; quebras de linha **1.701/1.701 idênticas**.
- Sem o `opsz` explícito a linha fica até **2 px** mais larga (o eixo cai no padrão 12) — quebraria
  as linhas da tela 19. Por isso o item 1 é obrigatório.
- Literata das 13 pranchas (G01.7: 259 linhas, 10 combinações de tamanho 15–26 e peso 400/500):
  máx **0,0100 px** (limitado pelo arredondamento de 2 casas da medição do Chromium).

## Consequências

- Um arquivo (164 KB latin + subconjuntos) serve os 7 tamanhos × 2 pesos; as estáticas por tamanho
  custariam ≈ 126 KB por tamanho/peso (latin + ext + vi).
- Mudar o tamanho no painel (tela 26) não troca de família: só o `opsz` — sem carregar fonte nova.
- O fallback (Ext/Vi/Cyr/Gr) precisa receber as mesmas variações (o helper garante).

## Alternativas consideradas

- **Instâncias estáticas por tamanho** (D-17, plano B): também passam (≤ 0,0074 px), mas multiplicam
  arquivos por tamanho × peso × subconjunto e engessam os tamanhos.
- **Variável sem `opsz`**: reprovada (até 2,04 px por linha).

## Pendências

- Conferir em aparelho (G11, golden + olho) que Android (FreeType) e iOS (CoreText) **desenham** a
  variável com o `opsz` pedido — a largura vem do HarfBuzz, igual em todas as plataformas, mas o
  contorno do glifo é rasterizado pela plataforma.
- Proposta para a G11 (pergunta no relatório da G02): usar a variável também na **interface**
  (as 259 linhas das pranchas passam com 0,010 px) e aposentar as 33 estáticas de Literata (1,39 MB; a variável com todos os subconjuntos tem 0,58 MB).

## Como reproduzir

```bash
# referência (container/Linux com Playwright 1.56)
python3 spikes/S1_fonte_variavel/ferramentas/extrair_amostra.py spikes/_dados/pg55752.epub \
  spikes/S1_fonte_variavel/dados/amostra.json assets/fonts/Literata-VF.ttf
NODE_PATH=$(npm root -g) node spikes/S1_fonte_variavel/ferramentas/medir_chromium.js
# Flutter (Windows)
cd spikes/S1_fonte_variavel && flutter test   # 8 testes; grava dados/resultado_flutter.json
```
