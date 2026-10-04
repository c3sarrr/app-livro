# Relatório da FASE G01 — Medição do arquivo novo e geração das fases de tela

Data: 03/10/2026 · branch `feat/g01-medicao` (a partir de `feat/app-completo`) · nada enviado ao GitHub.
Detalhe de cada subfase, com as evidências: `docs/progresso/G01.md`.

## Resultado

O bundle das 13 pranchas do leitor (telas 19–27b) virou referência medida, no mesmo padrão da v1, e as 22 fases de tela L19…L27b estão prontas para as fases G11–G19.

| Subfase | Entregue | Evidência |
|---|---|---|
| G01.1 Ferramentas | `tools/medicao/` (v1 copiada em `inicio/` + extração de bundle aninhado, `pranchas.json`, `comum.js`) | 13 pranchas extraídas; `page_order`, títulos e `$preview` conferidos; hash igual no Windows e no Linux |
| G01.2 Render isolado | `conferir_render.js`, `render_raiz.js`, `comparar_previa.py` | isolada@1x = raiz@1x **pixel a pixel** nas 13; prévias do pacote = raiz@2x exato (as prévias são 1x ampliado — borradas) |
| G01.3 Ids semânticos | `idmaps_spec.py` → `idmaps/*.json` | **1025 ids**, tag conferida posição a posição contra o template, 0 erro |
| G01.4 Medição | `medir.js` + `build_layout.py` → `handoff_v2/referencia/layout/layout_<tela>.json` | 1025/1025 medidos; tag e texto = template; baseline por ascent medido; fontes reais por nó (CDP) |
| G01.5 PNGs | `handoff_v2/referencia/png/` (39 @1/2/3x), `secoes/` e `redline/` (22 fases) | supersample 20× = 10× (blur 0,0000 % nas 13) |
| G01.6 Texto e Dart | `text_dependency.json`, `knife_edges.json`, `test/reference/leitor/` (`kRef19`…`kRef27b`) | teste de sincronia JSON × Dart: 16/16 |
| G01.7 Fontes | 69 arquivos em `assets/fonts/` (Figtree 800, Bricolage 15,5/17/23, Literata estática + variável, Lora, Atkinson) + 28 subconjuntos originais do gstatic | 498 linhas medidas com HarfBuzz: fontes novas **≤ 0,010 px** do Chromium; bytes reprodutíveis |
| G01.8 SVG | 51 ícones, 13 ilustrações, 12 traços da fixture, 3 formas de pintor + `svg_catalogo.json` + 11 recortes de elementos em CSS | troca SVG→arquivo: ícones e ilustrações idênticos; flutter_svg abre os 79 (81 testes) |
| G01.9 Fases L | `handoff_v2/fases/L19…L27b` (22) + `LEIA-ME.md` | formato da F05 da v1; diferenças × prancha base geradas (23/23b/24/24b × 22; 26b × 20) |
| G01.10 Tokens/widgets | `tokens_leitor.json`, `mapa_widgets.json`, `fases/L00_tokens_e_widgets.md` | 70 cores (56 novas), 18 raios, 8 bordas, 13 sombras, 90 estilos de texto; widget para os 1025 ids |
| G01.11 Reprodutibilidade | `rodar_tudo.sh`, `hashes_saida.py`, `G01_hashes_saida.txt` | 2 rodadas completas: **320/320 saídas com o mesmo sha256**, e 320/320 iguais à cópia do Windows |

Commits: `58815c8` G01.1 · `419462c` G01.2 · `1ace891` G01.3 · `b6ccfd2` G01.4 · `8ce741d` G01.5 · `ee9577a` + `fbb4b20` G01.6 (o 2º reaplica a versão final — o 1º lote chegou ao Windows com arquivos antigos por cache da transferência; desde então todo lote é conferido por hash) · `9690546` G01.7 · `8ce16d3` G01.8 · `cbfc021` G01.10 · `a91c8b7` G01.9 · `25dd546` G01.11 · G01.12 (este relatório).

Qualidade: `flutter analyze` sem nenhum problema; `dart format` sem diferenças; **`flutter test` = 645 testes, todos verdes** (548 da G00 + 16 de `test/reference/leitor/referencias_leitor_test.dart` + 81 de `test/design_system/leitor_svgs_test.dart`). `.gitattributes` ganhou as saídas da G01 que precisam ficar byte a byte (referências Dart do leitor, idmaps, fontes originais, manifesto de hashes).

## Achados do arquivo — preciso da sua decisão (Q14–Q19 no Anexo 05)

Nenhum deles bloqueou a medição: a referência literal foi medida como está. Eles só mudam o que o app vai mostrar e contra o que o teste compara.

| # | Achado | Recomendação |
|---|---|---|
| Q14 | **"≈" fora das fontes**: "≈ 2 h 10 min" (20/26b) — o "≈" não existe na Figtree (nem na versão completa); o navegador desenhou com uma fonte do sistema (na medição, Inter Bold). | **Embutir só o glifo "≈" da Inter Bold** (OFL): o app fica igual à referência em qualquer aparelho. |
| Q15 | **Texto vazando na 21**: o `article` da 21 tem `overflow: visible` (para a barra aparecer) e as linhas 20–22 descem até o rodapé. | Usar a referência **corrigida** `21_selecao_texto_corrigida_*` (já gerada): 19 linhas como na 19. |
| Q16 | **25 maior que a prancha**: conteúdo até 2271,58 e prancha de 2170 — o botão "Continuar lendo · pág. 159" fica fora. | Teste visual até 2170; o botão vale pelas medidas. |
| Q17 | **Dois `aria-label="Trecho selecionado"` na 21** (um em span transparente). | Semântica só da seleção visível. |
| Q18 | **Prateleira da 23b**: o marca-texto é o ativo (sobe 12 px), mas a caneta continua pintada com `brand` (desenho de ativa). | A cor `brand` acompanha a ferramenta ativa (na 23b a caneta volta ao desenho de inativa). |
| Q19 | **Tinta amarela na 23b**: a tinta que já estava na página fica amarela (nas outras pranchas é coral). | A tinta existente mantém a cor com que foi feita. |

## Outros pontos para as próximas fases

- **Fontes da v1:** as estáticas antigas (Figtree 400/600/700, Bricolage 26) ficam até 0,049 px do navegador porque o instanciador usa os avanços do `gvar`, não do `HVAR`. As novas já saem do HVAR (≤ 0,01 px). Sugestão para a G11: regenerar as da v1 com a correção e reconferir os goldens da Início.
- **Fios de navalha** (vão para o S3 da G02): linhas 7 e 19 da página do leitor (0,711 e 0,538 px) e o título do cap. XXXI no sumário (0,053 px).
- **Design system (G11):** `AppFonts.bricolage` não pode arredondar o tamanho (15,5 ≠ 16); `AppFonts.figtree` precisa do w800 só no leitor; sombras de anel = `spreadRadius`; `brand`/`ink` dinâmicos também dentro de SVG.
- **Conteúdo do livro (D-18):** Lora e Atkinson em itálico/negrito e Figtree itálico não estão no arquivo — virão do google/fonts quando o motor do leitor precisar.
- Pendências de ambiente da G00 continuam (JDK do Android; sem Mac para iOS).

## Próxima fase

**G02 — Spikes técnicos e ADRs**: S1 (Literata variável × estática × Chromium; a prévia da G01.7 já dá ≤ 0,01 px com a variável), S2 (banco + sync PowerSync/Supabase), S3 (paginação: as 19 linhas da tela 19, com os fios de navalha acima) e os demais do Anexo 05.
