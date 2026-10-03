# Anexo 03 — Motor do leitor (conteúdo, paginação, âncoras, seleção, tinta)

> Parte do pacote `handoff_v2/` · versão 2.0 · 03/10/2026
> Telas atendidas: 19–27b (Anexo 01). Este anexo define **como** o leitor funciona; a **aparência** vem da medição do arquivo (G01) e segue as regras de fidelidade do prompt v1.

---

## 1. Requisitos que o arquivo impõe

- Página com tipografia exata (Literata 20,5 / entrelinha 1,72 / recuo 1,3 em / margens 28 / topo 92 / base 82) e quebras de linha **iguais ao Chromium** no estado padrão (tela 19).
- Grifos com fundo em 3 alturas, sublinhado e **ondulado**; grifos antigos visíveis sob a seleção (21).
- Escrita à mão sobre o texto, que **"gruda nas palavras"** e **acompanha se a fonte mudar** (23b); espaço aberto entre linhas, em linhas inteiras, que empurra o texto (24/24b); texto travado durante o desenho (22).
- "pág. 159 de 256" e "62 %" estáveis; capítulos com página de início (27); marcadores por página (27b).
- Ajustes ao vivo (26) sem perder a posição.
- Tempo que "conta sozinho" (20).

## 2. Formatos

| Formato | Suporte v1 | Observações |
|---|---|---|
| EPUB 2 e 3 (refluível) | ✅ completo | foco do design |
| EPUB de layout fixo | ⚠️ como PDF (página inteira) | detectar `rendition:layout = pre-paginated` |
| PDF | ✅ leitura, grifo por texto, tinta por página | `pdfrx` (PDFium); "Fonte"/"Papel" não se aplicam → desabilitados (D-43) |
| Livro físico | ✅ sem conteúdo | cronômetro (`source=timer`) e página manual — telas fora deste arquivo |
| DRM (Adobe ADEPT, LCP) | ❌ | detectar e explicar ("este arquivo tem proteção e não pode ser aberto") |

## 3. Importação

1. Entrada: seletor de arquivos (`file_picker`), "Abrir com/Compartilhar" do sistema (Android `intent-filter` para `application/epub+zip` e `application/pdf`; iOS `CFBundleDocumentTypes` + `LSSupportsOpeningDocumentsInPlace = NO`, copiando para o sandbox).
2. Copiar para `ApplicationSupport/books/<sha256>.<ext>` (stream, sem carregar tudo na memória); calcular SHA-256 durante a cópia.
3. Deduplicar por (usuário, sha256).
4. Ler metadados (OPF: `dc:title`, `dc:creator`, `dc:language`, `dc:identifier` com ISBN) e capa; casar com o catálogo por ISBN quando existir.
5. Indexar o conteúdo (§4) num *isolate* (parse de XML é Dart puro; **não** usa `dart:ui`), gravar `book_content_index` e calcular as páginas de referência (§6).
6. Criar `user_books` (+ evento de analytics anônimo "livro importado", sem título).

## 4. Conteúdo canônico (EPUB → blocos)

- ZIP com acesso aleatório (pacote `archive`; ler só as entradas necessárias).
- `META-INF/container.xml` → OPF → `manifest` + `spine` → sumário (`nav.xhtml` no EPUB 3; `toc.ncx` no EPUB 2) com `href#fragmento`.
- Cada item do *spine* (XHTML, pacote `xml`/`html`) vira uma lista de **blocos**: `Paragraph(runs)`, `Heading(level, runs)`, `BlockQuote`, `ListItem`, `Image(src, alt, w, h)`, `SceneBreak`, `Preformatted`, `Table` (v1: linhas como parágrafos). `runs` = texto + estilo (itálico, negrito, versalete, sobrescrito/subscrito, link interno).
- CSS do livro: só um subconjunto (alinhamento, recuo, margens verticais em em, itálico/negrito, `small-caps`, `display:none`, `page-break-before`). Fontes do editor são ignoradas (os 4 tipos de letra do app valem sempre).
- **Texto canônico** de cada item do *spine*: concatenação NFC dos blocos com `\n` entre blocos. É o **sistema de coordenadas** de todas as âncoras (offsets em unidades UTF-16, iguais às do `TextRange` do Flutter). Guardar `char_count` por item e o `content_sha256` do arquivo — se o arquivo muda, as âncoras passam pela reancoragem (§5.3).
- Hifens suaves (U+00AD) preservados como oportunidade de quebra; NBSP preservado.

## 5. Localizadores e âncoras

### 5.1 Localizador (posição)

```json
{"v":1, "sha":"<sha256 do arquivo>", "spine":12, "offset":5321,
 "quote":{"prefix":"…32 caracteres","exact":"Retórica dos namorados","suffix":"32 caracteres…"},
 "refPage":159, "progression":0.62113}
```

### 5.2 Âncora de anotação (intervalo)

```json
{"v":1, "sha":"…", "spine":12, "start":5390, "end":5413,
 "quote":{"prefix":"para dizer o que foram ", "exact":"aqueles olhos de Capitu", "suffix":". Não me acode imagem"},
 "refPage":159}
```

Inspiração: seletores do W3C Web Annotation (`TextPositionSelector` + `TextQuoteSelector`). Para PDF: `{"page":n, "quads":[…]}` em coordenadas normalizadas da página (0–1).

### 5.3 Reancoragem (arquivo trocado por outra edição/versão)

1. `sha` igual → usar `start/end`.
2. Senão, procurar `exact` perto do offset antigo (janela ±2.000); desempatar por `prefix`/`suffix`.
3. Senão, busca aproximada (bitap/diff-match-patch, distância ≤ 10 %) no item inteiro.
4. Senão → "grifos sem lugar" (lista no fim da tela 25 — UI não desenhada, D-44). Nunca apagar.

Teste de propriedade: 1.000 edições aleatórias de um capítulo (inserções/remoções fora e dentro do trecho) → taxa de reancoragem correta ≥ 99 % quando `exact` sobrevive.

## 6. Páginas de referência ("pág. 159 de 256")

Problema: a página visual depende da fonte, do tamanho, da tela e das margens; o arquivo mostra um número estável, que o clube e os marcadores usam.

**Regra (D-19):**
1. Se o EPUB tem `page-list` (páginas da edição impressa), usar.
2. Senão, **página sintética** = a cada **N caracteres** do texto canônico global, cortando na fronteira de palavra seguinte. `N` inicial = 1.500; calibrar na G02 com o EPUB real de Dom Casmurro (meta: total ≈ 256, como no arquivo). `N` fica numa constante global versionada (`ref_page_version`). **Atenção:** só o total pode chegar perto do arquivo; as páginas de início dos capítulos do sumário (121…179) são ilustrativas e uma regra uniforme não as reproduz — a fidelidade das telas usa o mapa injetado da fixture.
3. "pág. X" no leitor = página de referência do **primeiro caractere visível**. "de Y" = total. "%" = offset global ÷ total de caracteres (5 casas internas, exibido arredondado para inteiro: 62 %).
4. Capítulo → página de início = página de referência do primeiro caractere do capítulo (tela 27).

Na fixture de teste, o mapa é injetado para reproduzir exatamente 159/256 e as páginas do sumário (121, 126, …, 179).

## 7. Layout e paginação (o coração da fidelidade)

### 7.1 Tipografia do leitor

| Ajuste | Valores (padrão em negrito) — números fora do arquivo são proposta D-20 |
|---|---|
| Tamanho (7 passos) | 16 · 17,5 · 19 · **20,5** · 22 · 24 · 26 px |
| Fonte | **Literata** (variável, `opsz = tamanho`, `wght 400`) · Lora · Figtree · Atkinson Hyperlegible |
| Entrelinha | Justo 1,5 · **Médio 1,72** · Solto 1,95 |
| Margens laterais | Estreita 20 · **Média 28** · Larga 40 |
| Papel | **Creme** `#F8F1E4`/`#2A2520` · Branco `#FFFDF8`/`#1A1714` · Sépia `#EEDDBF`/`#4A3622` · Noite `#1F1B17`/`#E3D9C6` |

- `TextStyle(fontFamily:'Literata', fontVariations:[FontVariation('opsz', size), FontVariation('wght', 400)], fontSize: size, height: lineHeight, leadingDistribution: TextLeadingDistribution.even)`. Se o spike S1 reprovar a fonte variável (diferença > 0,05 px por linha contra o Chromium), usar instâncias estáticas por tamanho (como a Bricolage da Início) — possível porque os 7 tamanhos são fixos.
- Itálico/negrito no corpo do livro: arquivos completos da Literata/Lora/Figtree/Atkinson (OFL, repositório google/fonts) — fora do arquivo de design (D-18), só no conteúdo.
- Recuo de 1,3 em: `PlaceholderSpan` (largura = 1,3 × tamanho, altura 0, alinhamento na linha de base) no início de cada parágrafo com recuo. O placeholder ocupa **1 unidade UTF-16 (U+FFFC)** no texto do `Paragraph` → toda conversão offset do parágrafo ↔ offset canônico desconta esse deslocamento (helper único + teste).
- Altura de linha igual ao Chromium: o Blink arredonda a altura da linha para a unidade de layout de **1/64 px** (20,5 × 1,72 = 35,26 → 35,25). O paginador usa a mesma altura arredondada; senão 19 linhas × 35,26 = 669,94 px numa caixa de 670 px vira "cabe/não cabe" por arredondamento. Regra de encaixe com tolerância de 0,02 px.
- Alinhamento à esquerda, sem hifenização (igual ao arquivo).
- Escala de texto do sistema **não** afeta o leitor (o leitor tem o próprio tamanho); afeta a interface? Não — D-05 da v1 continua.

### 7.2 Paginação

- Caixa de conteúdo = tela − insets (topo 92, base 82, laterais conforme margem; mais as áreas seguras do aparelho como na D-02 da v1).
- Para cada bloco: `ui.ParagraphBuilder` → `Paragraph.layout(width)` → `computeLineMetrics()`. Linhas vão para a página até a próxima não caber; parágrafo partido entre páginas = mesmo `Paragraph` pintado com deslocamento e recorte (sem refazer layout).
- Títulos: mantêm-se com a linha seguinte (sem título órfão no pé). Imagens: cabem inteiras ou vão para a próxima página, escaladas para caber.
- Espaços abertos (tinta, §9.5) entram no fluxo como blocos de altura `n × lineHeightPx` depois da linha que contém a âncora.
- **Execução:** `dart:ui` só roda no isolate principal → paginar em fatias (≤ 4 ms por quadro, `SchedulerBinding.scheduleTask` com prioridade `idle`), capítulo atual primeiro, vizinhos depois. Cache em `page_layout_cache` por (sha, hash dos ajustes, largura×altura, versão das fontes).
- **Gate de fidelidade (S3/G11):** no estado padrão (390×844, Literata 20,5, Médio, Média, Creme), a página com o parágrafo do cap. XXXII tem **as mesmas 19 linhas** da tela 19 (mesmo texto em cada linha) e baselines ±0,5 px da medição. Para esse gate usar um **EPUB de fixture** montado com o texto **exato** do arquivo (edições reais variam: "ideia"/"idéia", pontuação) — o EPUB real de domínio público serve para desempenho e para os testes de importação.

### 7.3 Virar página (D-22)

Toque no terço esquerdo/direito ou arrasto horizontal; animação de deslizar 220 ms `Curves.easeOutCubic`; sem efeito de papel dobrando. Barra de posição (tela 20): arrastar mostra o balão "pág. N" (página de referência) e só navega ao soltar.

## 8. Tempo de leitura ("contando sozinho") e tempo restante

- Sessão `auto` começa quando o leitor está visível, o app em primeiro plano e há conteúdo na tela; pausa ao ir para segundo plano, ao bloquear a tela, ou após **120 s sem interação** (virar página, rolar, tocar) — D-27; termina ao fechar o livro. Sessões < 10 s são descartadas.
- "N min hoje" = soma de `active_seconds` de hoje (fuso do usuário) + sessão aberta, arredondado para baixo em minutos.
- Páginas lidas = páginas de referência que ficaram ≥ 3 s na tela.
- Velocidade pessoal = média móvel exponencial (α = 0,2) de caracteres/min das últimas sessões ≥ 3 min; padrão inicial 1.000 caracteres/min (≈ 180 palavras/min em português — calibrar no beta).
- "≈ 2 h 10 min" = caracteres restantes ÷ velocidade; arredondar para 10 min acima de 1 h e para 5 min abaixo; formato "≈ H h MM min" (leitor) e "~Hh MMmin" (Início, já existe no `formatters.dart`).

## 9. Seleção e tinta

### 9.1 Seleção (tela 21)

Pressão longa → palavra (`Paragraph.getWordBoundary`) → alças desenhadas pelo design system (`#552CB7`) → arrastar alça com `getPositionForOffset` (limites de palavra ao arrastar devagar, caractere ao arrastar com a lupa — D-45). Seleção limitada à página visível na v1. Retângulos de seleção/grifo = `getBoxesForRange` por linha.

### 9.2 Pintura da página (ordem de camadas)

1. Papel · 2. Fundos dos grifos (altura Baixa/Média/Alta = frações da caixa da linha medidas na tela 23b) · 3. Texto · 4. Sublinhado e ondulado (pintor próprio; medir amplitude/comprimento de onda do ondulado no arquivo — não usar `TextDecorationStyle.wavy`, que não bate com o Chromium) · 5. Tinta confirmada (imagem em cache por página) · 6. Traço ao vivo · 7. Seleção e alças.

### 9.3 Entrada de tinta

- `Listener` de ponteiro cru (não `GestureDetector`), amostras com `pressure`, `tilt`, `kind`.
- Com caneta (stylus) detectada na sessão: só a caneta desenha; dedos navegam (rejeição de palma). Sem caneta: 1 dedo desenha, **2 dedos movem a página** (texto do arquivo).
- Suavização no estilo *perfect-freehand* (algoritmo MIT; implementar/portar em Dart puro, com testes): parâmetros por ponta — Esferográfica (afinamento 0,1, sem afunilar), Tinteiro (afinamento 0,6 com pressão, afunila no fim), Pincel (afinamento 0,85, suavização 0,5).
- Espessura em mm → dp: `1 mm = 160 / 25,4 ≈ 6,299 dp` (D-28); Fina/Média/Grossa = 0,6× / 1× / 1,8× do valor do painel.
- Latência: medida como tempo entre o `timeStamp` do evento de ponteiro e o fim da rasterização do quadro que o mostra (`FrameTiming`), p95 ≤ 16,7 ms a 60 Hz e ≤ 8,3 ms a 120 Hz; pintor com `Listenable` só da camada viva (nada de `setState` na página). Pontos previstos (*predicted touches* do iOS / `MotionEventPredictor` do Android) via canal de plataforma ficam como melhoria se a meta não for atingida.

### 9.4 Ferramentas

| Ferramenta | Comportamento |
|---|---|
| Caneta | traço livre; ao soltar, ancora (§9.5) |
| Marca-texto | traço livre que **vira grifo**: palavras cuja caixa da linha é coberta ≥ 50 % na horizontal e cuja faixa vertical cruza o traço → `annotation(kind=highlight, source=ink)` com cor/estilo/altura do painel ("gruda nas palavras"). Se não há texto sob o traço (dentro de um espaço) → fica como tinta translúcida |
| Borracha | apaga o traço inteiro tocado (v1) e grifos tocados (com desfazer) |
| Laço | polígono livre seleciona traços com ≥ 50 % dos pontos dentro; arrastar move (reancora); menu de ações não desenhado (D-46) |
| Reta | segmento do toque ao soltar; ângulos múltiplos de 15° grudam quando a diferença é < 4° |
| Espaço | arrastar entre linhas abre espaço em linhas inteiras (rótulo vivo "↕ N linhas"); mín. 1, máx. 12 (D-41) |

Desfazer/Refazer: pilha de comandos por sessão do modo anotação (máx. 100); "Concluir" grava tudo numa transação; autosave a cada 5 s em rascunho (recuperável após falha).

### 9.5 Ancoragem da tinta ("acompanha se a fonte mudar")

- **Sobre o texto (`over_text`):** cada traço é ancorado na palavra mais próxima do seu centro (âncora §5.2 da palavra) e guardado em **coordenadas de em** relativas à caixa dessa palavra (x a partir do início da palavra, y a partir da linha de base, em unidades de `fontSize`). Ao refazer o layout com outra fonte/tamanho, o traço é reposicionado e escalado pela nova caixa da palavra. Se a âncora quebrar entre linhas, o traço segue a primeira palavra (limitação documentada).
- **Em espaço aberto (`space`):** âncora = posição de texto da costura (fim da linha anterior); traços em coordenadas normalizadas da caixa do espaço (x 0–1 da largura; y em linhas). A caixa cresce/encolhe em linhas inteiras (alça "puxe a alça para aumentar").
- Enquanto o modo anotação está aberto, o layout fica congelado (comentário do arquivo).

### 9.6 Codec dos traços (BNK1)

```
cabeçalho: "BNK1" | versão u8 | nº de traços varint
traço:      ferramenta u8 | ponta u8 | cor RGB 3 bytes | alpha u8 | largura (centésimos de mm) u16
            nº de pontos varint
            pontos: x,y quantizados (1/100 de em ou 1/10000 da caixa) em delta zigzag varint,
                    pressão u8 (0–255), Δt ms varint
```
Tamanho típico: 100 pontos ≈ 350–450 bytes. Limite por camada: 256 KiB (CHECK no banco). Testes: ida e volta sem perda (quantização documentada), compatibilidade de versão.

## 10. Busca

- No livro (botão lupa da tela 20): busca no texto canônico (sem acento, sem caixa), resultados com contexto; UI não desenhada (D-23).
- Nos grifos (tela 25): FTS5 local (`annotations_fts`) em texto do trecho + nota; tokenizador `unicode61 remove_diacritics 2`.

## 11. Acessibilidade

- Página: nó semântico com o rótulo do arquivo ("Dom Casmurro, página 159 de 256") e o texto da página como valor (leitores de tela leem a página); ações de virar página expostas como ações semânticas.
- Controles: rótulos idênticos aos `aria-label` do arquivo (D-15 da v1).
- Modo anotação: anunciar ferramenta e cor; tinta tem rótulo genérico ("Desenho", "Nota à mão") + data.

## 12. Desempenho (orçamentos — medidos na G26 em aparelho intermediário)

| Métrica | Orçamento |
|---|---|
| Abrir livro já indexado até a 1ª página | < 600 ms |
| Virar página | 0 quadros perdidos a 60/120 Hz |
| Paginar um capítulo de 40 páginas | < 120 ms no total, em fatias de ≤ 4 ms |
| Latência do traço (evento → fim da rasterização, p95) | ≤ 16,7 ms a 60 Hz · ≤ 8,3 ms a 120 Hz |
| Importar EPUB de 2 MB | < 2 s até poder ler (indexação completa em segundo plano) |
| Memória do leitor aberto | < 180 MB |

## 13. Testes do motor

- Unidade: parser OPF/NCX/nav, normalização, offsets, páginas de referência, reancoragem, HLC, codec BNK1, suavização, ferramentas (laço, reta, conversão marca-texto → grifo), agrupamento `group_id`.
- Widget/golden: telas 19–27b contra as referências medidas (geometria ±0,5, estilo exato, `blur_mismatch_% ≤ 0,5`), com a fixture do mundo de referência.
- Fidelidade de quebra de linha: 19 linhas da tela 19 + linhas das telas 21/22/24/24b.
- Integração (`integration_test`/Patrol): importar EPUB real de domínio público, ler, grifar, anotar, mudar fonte (tinta acompanha), fechar e reabrir (posição restaurada).
- Propriedade: reancoragem; LWW com relógios defasados.
