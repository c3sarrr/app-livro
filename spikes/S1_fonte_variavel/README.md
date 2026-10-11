# S1 · Fonte variável (Literata `opsz`) — ADR-004

| Arquivo | O que é |
|---|---|
| `ferramentas/extrair_amostra.py` | Caps. XXXII–XXXIII do EPUB real (Gutenberg #55752) → `dados/amostra.json` (30 parágrafos, NFC, confere cobertura da fonte) |
| `ferramentas/medir_chromium.js` | Chromium 141: quebras a 334 px (zoom 1) e largura de cada linha isolada (zoom 100) nos 7 tamanhos → `dados/linhas_chromium.json` |
| `dados/linhas_pranchas_g01.json` | As 259 linhas em Literata das pranchas 19–27b medidas na G01.7 (tamanhos 15–26, peso 400/500) |
| `test/s1_fonte_variavel_test.dart` | Mede as mesmas linhas no SkParagraph do Flutter (VF+`opsz`, VF sem `opsz`, estática) e compara quebras → `dados/resultado_flutter.json` |

Resultado: VF + `opsz` explícito ≤ **0,0008 px** por linha (1.701 linhas, 7 tamanhos), quebras **idênticas**;
sem `opsz` até 2,04 px. Detalhes e decisão: `docs/adr/ADR-004_fonte_do_leitor.md`.
