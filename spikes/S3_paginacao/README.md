# S3 · Paginação — ADR-005

| Arquivo | O que é |
|---|---|
| `lib/epub.dart` | EPUB mínimo: container.xml → OPF → spine → blocos (parágrafos/títulos) e texto canônico por item |
| `lib/paginador.dart` | Tipografia do leitor, layout por bloco (`dart:ui`), **modelo vertical exato + pintura por linha**, paginação, layout em pedaços costurados |
| `lib/paginas_referencia.dart` | Páginas de referência (D-19): a cada N caracteres, na fronteira de palavra seguinte |
| `test/s3_tela19_test.dart` | Gate: EPUB de fixture com o texto exato → 19 linhas da tela 19, baselines, borda direita, fios de navalha, PNG @3x |
| `test/s3_epub_real_test.dart` | EPUB real (`spikes/_dados/pg55752.epub`): tempos, páginas por tamanho, pedaços, calibração do N |
| `dados/` | Resultados (JSON), PNGs da página 1 e comparação com a referência |

Achado principal: o SkParagraph arredonda a altura de cada linha a px inteiro (35,26 → 35,00); a pintura
por linha com o modelo exato dá baseline máx 0,0027 px e golden 0,21 %. Detalhes: `docs/adr/ADR-005_paginacao.md`.
