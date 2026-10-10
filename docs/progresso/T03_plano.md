# T03 — Início nova (01 e 60): plano de implementação

> **Para quem executa:** execução inline (superpowers:executing-plans), uma tarefa por vez, TDD: o teste falha
> (RED), o código mínimo passa (GREEN), commit pequeno. Passos com `- [ ]`.
> Spec: `docs/progresso/T03.md` (D-252…D-255), citada por §1…§6. Branch `feat/t03-inicio-nova`, base `f449f14`.

**Objetivo:** a Início do app idêntica à prancha 01 (e à 60, rolada), com dados reais e os estados da G08, e a suíte
de fidelidade da Início medindo a 01 (D-240).

**Arquitetura:** as seções da 01 são verificadas primeiro na posição da prancha por um arnês (`fase_inicio.dart`),
com a v1 ainda no app; uma troca única liga a 01 na `HomeScreen` e troca a suíte (spec §4). Keys = ids sem o prefixo.

**Pilha:** Flutter 3.47.2 / Dart 3.13.2, flutter_riverpod 3, drift; medição no WSL (Chromium 141 / Playwright,
`tools/medicao/wsl.sh`, fontconfig sem hinting); `tools/compare_images.py`.

**Execução e ambiente:** testes no Windows (`flutter test`, um processo por vez — sqlite3.dll); medição no WSL
(`MSYS_NO_PATHCONV=1 wsl bash tools/medicao/wsl.sh '<cmd>'`); goldens com `--update-goldens` (o de temas sozinho,
depois do canvas); arquivos `test/home/failures/*` restaurados do HEAD quando um golden falhar.

## Arquivos

| Arquivo | Responsabilidade | Tarefa |
|---|---|---|
| `docs/progresso/PLANO_FIDELIDADE_TELAS.md`, `T03.md`, `T03_plano.md` | D-252…D-255, spec, plano | 0 |
| `lib/features/home/domain/models.dart` | campos novos (§1) | 1 |
| `lib/features/home/application/formatters.dart` | textos novos | 1 |
| `lib/features/home/data/local_home_repository.dart` | D-252…D-255, sessões de hoje | 2 |
| `test/fixtures/telas/inicio01.dart` (novo) | `TelaInicio01` (`t01`, `t60`) | 3 |
| `test/home/t01_divergencias_test.dart` (novo) | mundo no banco × `t01`, uma a uma | 3 |
| `tools/medicao/*` (larguras), `docs/design/medicao/inicio2/larguras/` (novo) | a 01 a 360 e 430 | 4 |
| `test/reference/inicio2/reference_layout_001_inicio_w360.dart`/`_w430.dart` (novos) | referências das larguras | 4 |
| `test/support/fase_inicio.dart` (novo) | arnês: monta as seções na prancha ou o app; geometria, texto, estilo, recorte | 5 |
| `lib/core/design_system/tokens/app_colors.dart`, `app_typography.dart` | 3 cores e os estilos novos da 01 | 6–13 |
| `lib/features/home/presentation/sections/header_section.dart` | lupa (L01a1) | 6 |
| `lib/features/home/presentation/sections/hero_section.dart` (novo) | herói da 01 + convite da G08 (L01a2) | 7 |
| `lib/features/home/presentation/covers/dom_casmurro_cover_v2.dart` (novo) | SVG sem textos + `AppText` | 7 |
| `lib/features/home/presentation/sections/also_reading_section.dart`, `covers/bras_cubas_cover.dart` (novo) | papel, "play", pílula (L01a3) | 8 |
| `lib/features/home/presentation/sections/today_section.dart` (novo) | Seu dia da 01 (L01a4) | 9 |
| `lib/features/home/presentation/sections/review_section.dart` (novo) | revisão (L01a5) | 10 |
| `lib/features/home/presentation/covers/*` (Para você) | capas parametrizadas (L01a6) | 11 |
| `book_club_ticket.dart` | nada (dados) — testes (L01a7) | 12 |
| `recently_added_section.dart` | "Lido", "Papel" (L01a8) | 13 |
| `lib/features/shell/presentation/*` | nada — testes na página de 2650 (L01a9) | 14 |
| `home_screen.dart`, `app_spacing.dart`, `test/home/**`, `test/golden/goldens/inicio_*` | a troca (D-240) | 15 |
| `docs/design/estados_sem_design.md`, `T03.md` | toques sem ação; resultados | 16 |

---

## T03.0 — Preparação
- [ ] Branch `feat/t03-inicio-nova`; D-252…D-255 na §3 do PLANO; `T03.md`; este plano. Commit `docs(progresso)`.

## T03.1 — Domínio e formatadores (TDD)
- [ ] Testes (RED) em `test/home/formatters_test.dart` e `test/home/g08_modelo_test.dart`: `pageLabel(159, 256)` =
      "pág. 159 de 256"; `formatBadge` epub/pdf/physical = "E-BOOK"/"PDF"/"PAPEL"; `paperMeta` = "Papel · 3h 40min",
      "Papel · pág. 344", "Papel"; `countLabel(…, 'sessão', 'sessões')`; `reviewKicker(5, 2)`; `reviewSubtitle` com 1,
      2 e 3 livros ("De A.", "De A e B.", "De A, B e C."); `recentStatusLabel(read)` = "Lido";
      `formatLabel(physical)` = "Papel"; rótulos "Buscar livros", "Iniciar leitura de Brás Cubas".
- [ ] Modelos: campos novos, aditivos (a v1 ignora). GREEN, cobertura ≥ 85 %. Commit `feat(inicio)`.

## T03.2 — Dados reais (TDD)
- [ ] Testes (RED) em `test/home/local_home_repository_test.dart`, grupo "T03":
  - herói: `refPage`/`refPagesTotal` da posição e do livro; sem posição ou sem total → `null` (D-254);
  - Também lendo: `format`; papel com posição → `paperPage` e progresso; papel sem posição → `paperPage` nula e
    `readTime` = soma das sessões do livro (todas as origens, sem as apagadas, de qualquer dia); sem sessão → `null`
    (D-252/D-253); e-book → nada disso;
  - "N sessões": só as que começaram hoje no fuso do aparelho (virada da meia-noite e horário de verão como nos
    minutos), sem as apagadas;
  - recém-chegados: "lido" nunca aberto entra; "lido" aberto, "abandonado" e "lendo" não; ordem por chegada; 3 no
    máximo; "Lido" vale mais que "Novo" (D-255);
  - `dailyReview` sempre `null` (D-247).
- [ ] Implementação na mesma passada das sessões (sem consulta nova por livro). Commit `feat(inicio)`.

## T03.3 — Fixture `t01`/`t60` e divergências (D-241)
- [ ] `TelaInicio01.snapshot(now)` do mundo + os valores só da 01, cada um com o motivo (spec §2).
- [ ] `test/home/t01_divergencias_test.dart`: grava o mundo, lê com o repositório e lista as diferenças para a `t01`;
      espera exatamente a lista (capítulo/meta do clube/destaques fora; "grifos hoje", tempo restante, alturas, "Novo",
      sessões, livros de papel, "Lido", "Papel" dentro), cada uma com o valor dos dois lados.
- [ ] Commit `test(fixtures)`.

## T03.4 — Referências 360 e 430 da 01
- [ ] `tools/medicao`: modo largura (o frame com `width` trocado, como a F13 da v1): layout de todos os ids, linhas,
      supershot @2x; `pranchas_inicio2.json` ganha as variantes; `gen_reference_dart.py` gera `kRef01W360`/`W430`.
- [ ] Rodar 2× no WSL → mesmos hashes; teste em `referencias_inicio2_test.dart` (Dart = JSON).
- [ ] Commit `feat(medicao)`.

## T03.5 — Arnês da 01
- [ ] `test/support/fase_inicio.dart`: `abrirInicio01(tester, {secoes, prancha = kRef01, largura, dpr})` — antes da
      troca, as seções num canvas 390 × 2650 nos retângulos da prancha (`Positioned`, fundo `paper`, fixture `t01`);
      depois, o app; `idDaKey`/`keyDoId`; `geometria01`, `texto01`, recorte do golden (`capturarRecorte`) e
      `compararRecorte` (chama o `compare_images.py` e devolve `blur_mismatch_%`, pulado se não houver Python).
- [ ] Teste do arnês (mapeamento de ids; um id girado medido pela caixa de layout). Commit `test(inicio)`.

## T03.6…T03.14 — Uma fase L por seção
Em cada uma: ler a fase L; testes (RED) em `test/home/inicio01/<secao>_test.dart` — geometria de todos os ids da
seção, texto, estilo, semântica, toque (D-243 b quando houver) e recorte do golden (≤ 0,5 %); implementar; lado a lado
e heatmap inspecionados; commit `feat(inicio)`.
- [ ] **T03.6 L01a1** cabeçalho: `header.actions`, lupa 48 (`AppIconsInicio.search` 22), sem ação. Ajusta os testes
      da v1 do cabeçalho (a lupa entra; os ids da v1 não mudam de lugar).
- [ ] **T03.7 L01a2** herói (`HeroSection`): capa SVG sem textos + "Dom"/"Casmurro"/"MACHADO DE ASSIS" em `AppText`
      (escala 1,0625, `slice`), giro −3°, lombada; pílulas em `Wrap` (gap 6); título, autor, 62 %, tempo, barra;
      CTA e destaques com o contador; brilhos; convite da G08 no tamanho da 01.
- [ ] **T03.8 L01a3** Também lendo: cartão de papel ("play" 46 sem ação, pílula com `bookPaper` 12), anel, capa do
      Brás Cubas (cartola), reticências "Orgulho e Precon…", contador 3.
- [ ] **T03.9 L01a4** Seu dia (`TodaySection`): "Ler agora" (cronômetro 17) sem ação, "N sessões", texto da meta,
      mostrador, semana, rodapé.
- [ ] **T03.10 L01a5** revisão (`ReviewSection`): arte dos 3 cartões girados, brilho, textos, "Revisar" sem ação;
      some sem `dailyReview`.
- [ ] **T03.11 L01a6** Para você: capas parametrizadas (Esaú e Jacó 22, Memorial de Aires e Casa de Pensão 26).
- [ ] **T03.12 L01a7** clube: "até o cap. 50"; mesmos pintores.
- [ ] **T03.13 L01a8** recém-chegados: "Lido" (`tagReadBg`/`tagReadText`), "Papel", ⋯ sem ação.
- [ ] **T03.14 L01a9** barra e degradê na página de 2650.

## T03.15 — A troca (D-240), um commit
- [ ] `HomeScreen`: cabeçalho, título, `HeroSection`, Também lendo, `TodaySection`, `ReviewSection`, Para você,
      clube, recém-chegados; `AppSpacing.sectionGaps` com 8 gaps; a seção sem dados some com o seu gap.
- [ ] Início dos testes = `t01` (`HomeMockRepository`); arnês no modo app; saem `ContinueReadingHero`,
      `ReadingDayCard`, `chapter`/`pagesToday`, a `TelaInicio` da v1, as referências da v1 da Início e a suíte da v1.
- [ ] Página: 287/287 ids e todas as linhas; ritmo vertical; golden do canvas @3x; **L60** (viewport 390 × 844, safe
      47/34, rolagem 930, barra e degradê presos) com golden contra o PNG da 60; 360/430 (±1,0 e golden @2x); temas;
      semântica da página; toques; estados da G08; auditoria anti-simplificação com os números da 01; desempenho.
- [ ] Commit `feat(inicio)!`/`test(inicio)` conforme o conteúdo.

## T03.16 — Fecho
- [ ] `estados_sem_design.md` (spec §5); auto-revisão (referência, redline, golden e heatmap por seção, tabela linha a
      linha); §7; gitleaks; `T03.md` com resultados, desvios e pendências; relatório → PARAR.
