# G20 — Integração do leitor: plano de implementação

> **Para quem executa:** execução inline (superpowers:executing-plans), uma tarefa por vez, TDD: o teste falha no
> Windows (RED), o código mínimo passa (GREEN), commit pequeno. Passos com `- [ ]`.

**Objetivo:** juntar a Início, o leitor, o sumário e a 25 com dados reais e provar que conversam:
- "Cap. N de M" pela numeração do livro (D-206) e as relações do Anexo 01 §14 com o livro real;
- o Voltar por camadas;
- a restauração da tela e da posição (D-207);
- o retrato travado no nativo (D-209);
- a acessibilidade com os guias do Flutter e o toque que cresce por dentro (D-208);
- os orçamentos (teste de aparelho pronto e a prévia no PC), o teto do cache de páginas e o sumário grande.

**Arquitetura:**
- **Domínio puro:**
  - `lib/features/home/domain/home_chapter.dart` (`homeChapter`, R1);
  - `chapterNumerals` em `toc_view.dart`, ao lado de `chapterLabels`.
- **Início:** o `LocalHomeRepository` lê o índice do livro do herói e usa `homeChapter`.
- **Restauração:**
  - `restorationScopeId` no `MaterialApp.router`, no `GoRouter` e no `StatefulShellRoute`;
  - `restorationId` no rolável da Início;
  - `RestorationMixin` no `ReaderScreen` (R4);
  - `HighlightsExitBus` (R5).
- **Acessibilidade:**
  - `TapTarget` (`lib/core/design_system/widgets/tap_target.dart`), o alvo que cresce por dentro (R7);
  - os anúncios do modo anotação (`toolAnnouncement`);
  - os nós "Desenho, ‹data›" na página.
- **Desempenho:**
  - o teto do `PageLayoutCacheDao` (R11);
  - os fluxos medidos em `test/perf/fluxos_do_leitor.dart`, usados pelo teste de aparelho
    (`integration_test/leitor_orcamentos_test.dart`) e pela prévia do PC (`test/perf/orcamentos_pc_test.dart`).

**Pilha:**
- Flutter 3.47.2 / Dart 3.13.2, drift, flutter_riverpod, go_router 18;
- `flutter_test` (`restartAndRestore`, `meetsGuideline`, `handlePopRoute`);
- `integration_test` e `flutter_driver` (SDK, só desenvolvimento).

**Execução e ambiente (igual à G19):**
- Código escrito no espelho `/home/claude/g03/repo` e levado ao Windows por `ciclo.sh` + `expandir.ps1`.
- No Windows: `dart format`, `flutter analyze` e `flutter test <arquivo>`. Os arquivos formatados voltam por `puxar.sh`.
- Comandos longos por `tools/medicao/tmp/rodar.ps1 -Nome X -Cmd "..."`: log em `tmp\X.log` e `X.fim` com 0 ou 1.
  Encadeie com `&` para os testes rodarem mesmo com avisos do analyze.
- Commits pequenos: `tools/medicao/tmp/commits_g20<letra>.ps1` + `msg_g20_NN.txt`, gerados por `novo_commit20.sh`.
  - Mensagem `tipo(escopo): descrição` em português, com o rodapé `Co-Authored-By` e `Claude-Session`.
  - Leituras do git com `git --no-optional-locks`; nenhum `index.lock` fica.
- Spec: `docs/progresso/G20.md` (D-204…D-209, regras R1…R12), citada por §1…§7.
- Branch `feat/g20-integracao-leitor`, base `8622d18` (a spec é o `989caa6`).

## Arquivos

| Arquivo | Responsabilidade | Tarefa |
|---|---|---|
| `docs/progresso/G19.md` | D-204 e D-205 nos desvios | 1 |
| `lib/features/reader/application/toc_view.dart` | `chapterNumerals` | 2 |
| `lib/features/home/domain/home_chapter.dart` (novo) | R1 | 2 |
| `lib/features/home/data/local_home_repository.dart` | o herói com `homeChapter` | 3 |
| `test/support/app_com_livro.dart` (novo) | o app inteiro com o Dom Casmurro real (Início real + leitor + 25) | 4 |
| `test/integration/relacoes_inicio_leitor_test.dart` (novo) | R2 | 4 |
| `test/features/reader/presentation/voltar_camadas_test.dart` (novo) | R3 | 5 |
| `lib/app/app.dart`, `router.dart`, `lib/features/home/presentation/home_screen.dart` | escopo de restauração, rolagem da Início | 6 |
| `lib/features/reader/presentation/reader_screen.dart` | R4 (`RestorationMixin`) | 7 |
| `lib/features/highlights/application/highlights_exit.dart`, `highlights_providers.dart`, `highlights_screen.dart`, `reader_screen.dart` | R5 (`HighlightsExitBus`) | 8 |
| `test/integration/restauracao_test.dart` (novo) | D-207, R4, R5, D-166 | 6–9 |
| `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`, `test/home/orientacao_nativa_test.dart` (novo) | D-209 | 10 |
| `lib/core/design_system/widgets/tap_target.dart` (novo) + teste | R7 | 11 |
| `test/integration/acessibilidade_leitor_test.dart` (novo) e os widgets que falharem | R6, R7 | 12 |
| `lib/features/reader/presentation/annotation_island.dart`, `reader_screen.dart` | R8 (anúncios, desenhos) | 13 |
| `lib/core/data/database/daos/content_daos.dart`, `book_pager.dart` | R11 | 14 |
| `pubspec.yaml`, `test/perf/fluxos_do_leitor.dart` (novo), `integration_test/leitor_orcamentos_test.dart` (novo), `test_driver/orcamentos_driver.dart` (novo), `docs/adr/ADR-005_paginacao.md` | R9 | 15 |
| `test/perf/orcamentos_pc_test.dart` (novo) | R10 | 16 |
| `test/perf/sumario_grande_test.dart` (novo), `toc_chapters.dart` (só se medir > 100 ms) | R12 | 17 |
| `docs/progresso/G20.md`, `RELATORIO_G20.md` | prova e relatório | 18 |

---

### Tarefa 1: Pendências da G19 (D-204, D-205)

**Arquivos:** `docs/progresso/G19.md`

- [ ] **Passo 1:** na seção "Desvios" do `G19.md`, depois dos dois primeiros itens, acrescentar:

```markdown
- **Respondido em 09/10/2026 (antes da G20):** as miniaturas ficam com a tinta de verdade (D-204, a L25c é conferida
  sem as 4 caixas de tinta) e as datas ficam sem "ontem" (D-205).
```

- [ ] **Passo 2:** em "Pendências", trocar os dois itens Q27/Q28 por "Respondidas → D-204 e D-205 (09/10/2026)".
- [ ] **Passo 3:** commit `docs(g19): as miniaturas e as datas respondidas (D-204, D-205)`.

### Tarefa 2: "Cap. N de M" — `chapterNumerals` e `homeChapter` (R1, D-206)

**Arquivos:**
- Modificar: `lib/features/reader/application/toc_view.dart` (junto de `chapterLabels`)
- Criar: `lib/features/home/domain/home_chapter.dart`
- Testes: `test/home/home_chapter_test.dart`, `test/features/reader/application/toc_view_test.dart`

- [ ] **Passo 1: os testes (RED).** Em `test/home/home_chapter_test.dart`:

```dart
// G20 (R1, D-206) — o "Cap. N de M" da Início pela numeração do livro.
import 'package:app_leitura/features/home/domain/home_chapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // o Dom Casmurro do Gutenberg: 2 de abertura, I…CXLVIII, FIM, INDICE, a licença
  final dom = <String?>[
    null,
    null,
    for (var i = 1; i <= 148; i++) '$i',
    null,
    null,
    null,
  ];

  test('numeração em sequência: a ordem entre os numerados (XXXII = 32 de 148)', () {
    expect(homeChapter(dom, chapterIndex: 33, chaptersTotal: 153), (chapter: 32, total: 148));
    expect(homeChapter(dom, chapterIndex: 2, chaptersTotal: 153), (chapter: 1, total: 148));
  });

  test('antes do 1º numerado, nada (a pílula some); depois do último, o último', () {
    expect(homeChapter(dom, chapterIndex: 0, chaptersTotal: 153), isNull);
    expect(homeChapter(dom, chapterIndex: 1, chaptersTotal: 153), isNull);
    expect(homeChapter(dom, chapterIndex: 152, chaptersTotal: 153), (chapter: 148, total: 148));
  });

  test('numeração que recomeça por parte: a ordem continua (o 3º da parte 2 é o 13 de 22)', () {
    final partes = <String?>[
      for (var i = 1; i <= 10; i++) '$i',
      for (var i = 1; i <= 12; i++) '$i',
    ];
    expect(homeChapter(partes, chapterIndex: 12, chaptersTotal: 22), (chapter: 13, total: 22));
  });

  test('capítulo sem número no meio dos numerados vale o último numerado antes dele', () {
    final meio = <String?>['1', '2', null, '3'];
    expect(homeChapter(meio, chapterIndex: 2, chaptersTotal: 4), (chapter: 2, total: 3));
  });

  test('sem numeração: as folhas do sumário (chapter_index + 1 de chapters_total)', () {
    expect(homeChapter(const [null, null, null], chapterIndex: 1, chaptersTotal: 3), (chapter: 2, total: 3));
    expect(homeChapter(const [], chapterIndex: 4, chaptersTotal: 20), (chapter: 5, total: 20));
  });

  test('sem posição ou sem total (e sem numeração): nada', () {
    expect(homeChapter(dom, chapterIndex: null, chaptersTotal: 153), isNull);
    expect(homeChapter(const [], chapterIndex: 4, chaptersTotal: null), isNull);
  });
}
```

Em `toc_view_test.dart`, um teste para `chapterNumerals` com o índice do Dom Casmurro real, pelo
`indexEpubFile(domCasmurroEpub, …)` de `reader_harness.dart`:

```dart
  test('G20: os numerais de cada capítulo do Dom Casmurro real (148 numerados, I = 1, XXXII = 32)', () {
    final index = indexEpubFile(domCasmurroEpub, 'a' * 64);
    final n = chapterNumerals(index);
    expect(n.where((x) => x != null), hasLength(148));
    expect(n.firstWhere((x) => x != null), 'I');
    expect(n.where((x) => x != null).elementAt(31), 'XXXII');
    expect(n.length, index.chaptersTotal);
  });
```

- [ ] **Passo 2:** rodar os dois arquivos no Windows e ver falhar (funções inexistentes).
- [ ] **Passo 3: `chapterNumerals`** em `toc_view.dart`, logo depois de `chapterLabels` (mesmo `_rows`):

```dart
/// G20 (D-206): o numeral de cada capítulo (folha) pelo índice dele, como o leitor mostra (D-150/D-155/D-156); sem
/// numeral, `null`; sem índice ou sumário, nenhum.
List<String?> chapterNumerals(BookIndex? index) {
  if (index == null || index.toc.isEmpty) return const [];
  final out = <String?>[];
  for (final r in _rows(_Places(index), (spine: 0, offset: 0), const [])) {
    final c = r.chapter;
    if (r.kind != TocRowKind.chapter || c == null) continue;
    while (out.length <= c) {
      out.add(null);
    }
    out[c] = r.numeral;
  }
  return out;
}
```

- [ ] **Passo 4: `homeChapter`** em `lib/features/home/domain/home_chapter.dart`:

```dart
// G20 (R1, D-206) — o "Cap. N de M" do herói da Início pela numeração do livro: contam só os capítulos com numeral
// (os do leitor — D-150/D-155/D-156); fora de um numerado vale o último antes da posição; antes do 1º, nada (a
// pílula some, D-85); sem numeração, as folhas do sumário, como antes.

/// "Cap. [chapter] de [total]"; `null` = a pílula some.
typedef HomeChapter = ({int chapter, int total});

/// [numerals] = o numeral de cada folha do sumário (`chapterNumerals`); [chapterIndex] = a folha da posição
/// (`reading_positions.chapter_index`); [chaptersTotal] = `user_books.chapters_total`.
HomeChapter? homeChapter(
  List<String?> numerals, {
  required int? chapterIndex,
  required int? chaptersTotal,
}) {
  if (chapterIndex == null) return null;
  final numbered = [
    for (var i = 0; i < numerals.length; i++)
      if (numerals[i] != null) i,
  ];
  if (numbered.isEmpty) {
    return chaptersTotal == null
        ? null
        : (chapter: chapterIndex + 1, total: chaptersTotal);
  }
  var n = 0;
  for (final i in numbered) {
    if (i > chapterIndex) break;
    n++;
  }
  return n == 0 ? null : (chapter: n, total: numbered.length);
}
```

- [ ] **Passo 5:** rodar e ver passar. Commit `feat(inicio): o "Cap. N de M" pela numeração do livro (D-206, R1)`
  (só o domínio e o `toc_view`).

### Tarefa 3: o herói da Início com `homeChapter`

**Arquivos:**
- Modificar: `lib/features/home/data/local_home_repository.dart` (`_Data`, `_Reader.read`, a montagem do `ContinueReading`)
- Teste: `test/home/local_home_repository_test.dart`

- [ ] **Passo 1: o teste (RED).** No grupo do herói, um teste com o índice do Dom Casmurro real gravado
  (`BookContentIndexDao(db).upsert(livro.id, indexEpubFile(domCasmurroEpub, sha), builtAt: t0Teste)`), o livro em
  leitura com `chaptersTotal: 153` e a posição com `capitulo: 33`:

```dart
    test('G20 (D-206): com o índice do livro, "Cap. 32 de 148" (a numeração do livro, não as 153 entradas)', () async {
      final livro = _livro(1, status: ShelfStatus.reading, aberto: _local(10, 5, 8), capitulos: 153);
      await gravar([livro]);
      await BookContentIndexDao(db).upsert(
        livro.id,
        indexEpubFile(domCasmurroEpub, shaDoLivroTeste(1)),
        builtAt: t0Teste,
      );
      await ReadingPositionsDao(db).upsert(_posicao(livro, progresso: 0.2, capitulo: 33));
      final h = (await repo.read(_agora)).continueReading!;
      expect((h.chapter, h.totalChapters), (32, 148));
    });
```

  E o teste do "mundo de referência no banco" continua dizendo 32 de 148: não muda.
- [ ] **Passo 2:** rodar e ver falhar (34 de 153).
- [ ] **Passo 3:** no `_Data`, o campo `heroNumerals` (`List<String?>`). No `_Reader.read`, logo depois de
  `heroAnnotations`:

```dart
    // G20 (D-206): os numerais dos capítulos do livro do herói, para o "Cap. N de M"
    final heroNumerals = reading.isEmpty
        ? const <String?>[]
        : chapterNumerals(await BookContentIndexDao(db).byBook(reading.first.id));
```

  (`db` do `_Reader` é o `AppDatabase`; os imports são `content_daos.dart` e `toc_view.dart` show `chapterNumerals`.)
  Na montagem:

```dart
      continueReading: hero == null
          ? null
          : () {
              final ch = homeChapter(
                data.heroNumerals,
                chapterIndex: hero.chapterIndex,
                chaptersTotal: hero.chaptersTotal,
              );
              return ContinueReading(
                book: hero.book,
                chapter: ch?.chapter,
                totalChapters: ch?.total,
                progress: hero.progress,
                timeLeft: _timeLeft(hero, data),
                highlightsCount: data.heroAnnotations,
                format: _formatOf(hero.format),
              );
            }(),
```

- [ ] **Passo 4:** rodar `test/home/local_home_repository_test.dart` inteiro e ver passar (os testes antigos sem
  índice caem no recuo). Commit `feat(inicio): o herói conta os capítulos do livro (D-206)`.

### Tarefa 4: as relações Início ↔ leitor ↔ sumário ↔ 25 com o livro real (R2)

**Arquivos:**
- Criar: `test/support/app_com_livro.dart`, `test/integration/relacoes_inicio_leitor_test.dart`

- [ ] **Passo 1: o app inteiro com o livro real.** `app_com_livro.dart`:
  - `LivroNaEstante.domCasmurro()`;
  - o livro com status `reading`, `chaptersTotal` = `index.chaptersTotal` e `lastOpenedAt`, regravado pelo
    `UserBooksDao`;
  - uma posição inicial no começo do cap. XXXII (`guardarPosicao(spine, offset)` com o item do capítulo pelo
    `tocStartPages`/`index.toc`);
  - o `ProviderScope` com:
    - `homeRepositoryProvider` = `LocalHomeRepository(database: () async => livro.db, owner: () async => livro.leitor,
      utcOffsetAt: (_) => Duration.zero, debounce: Duration.zero)`;
    - `clockProvider` fixo em 09/10/2026 15:00 UTC;
    - `readerDepsProvider` = `livro.readerDeps(awake: …, now: o mesmo relógio, utcOffsetAt: (_) => Duration.zero)`;
    - `highlightsDepsProvider` = `HighlightsDeps` do mesmo banco (como `depsDaTela25`, sem a fonte da fixture: o
      `EpubCardTextSource` do arquivo do livro);
    - `scannerCameraProvider` e `readerSystemUiProvider` com os dublês de `pump_reader.dart`;
  - `App.forTests()`.

  A função devolve um `AppComLivro` com o livro, os erros e o relógio:

```dart
Future<AppComLivro> abrirAppComLivro(WidgetTester tester) async { /* acima */ }
```

- [ ] **Passo 2: o teste (pode passar ou falhar — cada falha é uma relação quebrada).** Em
  `relacoes_inicio_leitor_test.dart`, `testWidgets` a 390×844 (`setCanvasView`):
  1. **Herói:** lê o texto da pílula `inicio.hero.chapter` ("Cap. 32 de 148"), o % e o tempo restante.
  2. **Continuar:** toca no herói (`inicio.hero.continue`), espera o leitor (`esperarLeitor`). O rodapé
     `r19.footer` diz "pág. X de Y · Z %", e X é a página da posição gravada (`ReadingPositionsDao.forBook`).
  3. **Capítulo:**
     - abre os controles e o sumário (`r20.bottomIsland.tools.toc`);
     - o capítulo "você está aqui" (a linha `current`) tem o numeral XXXII;
     - a ordem dele entre os numerados = 32 = o N da Início.
  4. **Páginas crescentes:** as páginas das linhas do sumário (as que têm página) são crescentes.
  5. **Ler:** fecha a folha, vira 5 páginas (arrasto), anda 3 min no relógio, volta pelo Voltar do sistema
     (`tester.binding.handlePopRoute()` até a Início), assenta. O herói mostra:
     - o novo %, igual ao último rodapé;
     - o mesmo capítulo do leitor;
     - os minutos do dia = o chip de tempo do leitor (`r20.timeChip`, lido antes de sair).
  6. **Tempo:** o "~2h 10min" do herói e o "≈ 2 h 10 min" do chip de tempo restante dos controles saem do mesmo
     número (os dois formatadores aplicados ao mesmo `Duration`).
  7. **Contagens:**
     - no leitor, grifa um trecho (pressão longa e uma cor da barra), com o contador `r20.bottomIsland.tools.notes.badge`
       = 1;
     - abre a 25 pelo botão Grifos: "Tudo 1", e a soma dos 4 tipos = 1;
     - volta à Início: o rótulo "Destaques e notas deste livro (1)";
     - apaga pela 25 ("Mais opções" → Apagar): os três voltam a 0 (o contador some e a Início diz 0).
  8. **25:** com 3 grifos em páginas diferentes, as páginas dos separadores da 25 são crescentes, e "você parou aqui"
     está na página do rodapé.

  Cada passo com `expect` e `reason` dizendo a relação do Anexo 01 §14.
- [ ] **Passo 3:** rodar no Windows. Para cada relação que falhar:
  - achar a causa (superpowers:systematic-debugging);
  - escrever o teste de unidade da causa;
  - corrigir.

  Se a correção pedir uma regra nova (o Anexo não decide), **parar e perguntar ao Cesar**.
- [ ] **Passo 4:** commit `test(integracao): as relações Início ↔ leitor ↔ sumário ↔ 25 com o livro real (R2)` (+
  um commit `fix(...)` por correção).

### Tarefa 5: o Voltar por camadas (R3)

**Arquivos:** criar `test/features/reader/presentation/voltar_camadas_test.dart`

- [ ] **Passo 1: a matriz.** Um `testWidgets` por linha da tabela da §3. A função comum:

```dart
/// Aperta o Voltar do sistema e anda os quadros da animação.
Future<void> voltar(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}
```

  As camadas, abertas pelos auxiliares das fases:
  - **Rótulos:** `abrirTela23b` + `ann.markerPanel.colorsHeader.editLabels`. Depois do Voltar: `ann.labels` some e
    `ann.markerPanel` fica.
  - **Painéis:** `abrirTela23`/`abrirTela23b`. O painel some e `ann.mode` fica.
  - **Modo:** `abrirTela22` (soltando o dedo). `ann.mode` some e o desenho está no banco
    (`InkLayersDao(livro.db).forBook`).
  - **Nota:** `abrirTela21` + `r21.toolbar.actions.note`. `leitor.nota` some.
  - **Outra cor:** `abrirTela21` + `r21.toolbar.colors.other`. `leitor.outraCor` some e `r21.toolbar` fica.
  - **Busca:** `abrirTela20` + `r20.topIsland.search`. `leitor.busca` some e `r20.topIsland` fica.
  - **Ajustes:** `abrirTela26`. `rs.sheet` some e `r20.topIsland` fica.
  - **Sumário:** `abrirTela27`. `toc.sheet` some e `r20.topIsland` fica.
  - **Controles:** `abrirTela20`. `r20.topIsland` some e `r19.footer` fica.
  - **Seleção:** `abrirTela21`. `r21.toolbar` some.
  - **Leitura limpa:** `abrirLeitor`. Volta à Início (`find.byType(HomeScreen)`), e a posição está gravada.
  - **25:**
    - pelo leitor (`abrirLeitor` com `destaques:` + Grifos): `hl.more` some com o Voltar; o 2º Voltar volta ao
      leitor na mesma página;
    - pela Início (`abrirTela25`): o Voltar volta à Início.
- [ ] **Passo 2:** rodar. Cada linha que falhar é uma lacuna: teste de unidade, se couber, e a correção no
  `PopScope` do `reader_screen.dart` (ou da 25).
- [ ] **Passo 3:** commit `test(leitor): o Voltar do sistema por camadas (R3)`, mais as correções.

### Tarefa 6: o escopo de restauração e a Início (D-207)

**Arquivos:**
- Modificar: `lib/app/app.dart`, `lib/app/router.dart`, `lib/features/home/presentation/home_screen.dart`
- Criar: `test/integration/restauracao_test.dart`

- [ ] **Passo 1: o teste (RED)** com `pumpApp` da fixture (a Início do mundo):

```dart
  testWidgets('D-207: a Início volta na mesma aba e na mesma rolagem', (tester) async {
    await pumpApp(tester);
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    final rolagem = tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels;
    expect(rolagem, greaterThan(0));
    await tester.restartAndRestore();
    expect(
      tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels,
      rolagem,
    );
  });

  testWidgets('D-207: a aba ativa volta (Perfil)', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('nav.perfil')));
    await tester.pumpAndSettle();
    await tester.restartAndRestore();
    expect(find.text('Perfil'), findsWidgets);
  });
```

  As chaves da navegação são as da F11. Conferir em `main_shell.dart` e ajustar o `nav.perfil`, se for outra.
- [ ] **Passo 2:** rodar e ver falhar (sem escopo, nada volta).
- [ ] **Passo 3: o escopo.**
  - `app.dart`: `MaterialApp.router(restorationScopeId: 'app', …)`.
  - `router.dart`: `GoRouter(restorationScopeId: 'raiz', …)` e `StatefulShellRoute.indexedStack(restorationScopeId:
    'abas', …)`, com `StatefulShellBranch(restorationScopeId: 'aba.<caminho>', …)` no `tab(...)`.
  - `home_screen.dart`: `SingleChildScrollView(restorationId: 'inicio.rolagem', …)`.
- [ ] **Passo 4:** rodar `restauracao_test.dart`, `test/home/` e `test/app/router_test.dart` e ver passar. Commit
  `feat(app): a restauração da tela e da rolagem (D-207)`.

### Tarefa 7: o leitor restaurado e o salto uma vez só (R4)

**Arquivos:** `lib/features/reader/presentation/reader_screen.dart`; teste em `restauracao_test.dart`

- [ ] **Passo 1: os testes (RED).**
  1. **Leitor na página:**
     - `abrirLeitor(tester, livro)` com o Dom Casmurro na pág. N (`guardarPosicao`), vira 2 páginas e lê o rodapé;
     - `tester.restartAndRestore()` e `esperarLeitor`;
     - o rodapé tem a mesma página, `r20.topIsland` não existe (camadas fechadas) e a rota é `/leitor/<id>`.
  2. **`?ir=` uma vez:**
     - `abrirLeitor(…, ir: <id de um grifo da pág. 41>)`;
     - depois do salto, vira 3 páginas;
     - `restartAndRestore()`;
     - o rodapé está na página depois das 3 viradas (a posição gravada), e não na do grifo.
- [ ] **Passo 2:** rodar e ver falhar o 2º (restaurado, o `?ir=` salta de novo).
- [ ] **Passo 3: o `RestorationMixin`.**

```dart
class _ReaderScreenState extends ConsumerState<ReaderScreen> with RestorationMixin {
  // R4: o salto do `?ir=` já foi feito (sobrevive à restauração)
  final RestorableBool _wentToDone = RestorableBool(false);

  @override
  String? get restorationId => 'leitor.${widget.bookId}';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_wentToDone, 'saltou');
  }
```

  O `_wentTo` vira `_wentToDone.value`, que passa a `true` antes do `addPostFrameCallback` do salto. No `dispose`,
  `_wentToDone.dispose()`.
- [ ] **Passo 4:** rodar `restauracao_test.dart` e `test/features/highlights/presentation/highlights_reader_test.dart`
  e ver passar. Commit `feat(leitor): restaurado, abre na posição; o ?ir= salta uma vez (R4)`.

### Tarefa 8: a saída da 25 por um canal (R5)

**Arquivos:**
- Modificar: `lib/features/highlights/application/highlights_exit.dart`, `highlights_providers.dart`,
  `lib/features/highlights/presentation/highlights_screen.dart`, `lib/features/reader/presentation/reader_screen.dart`
- Testes: `test/features/highlights/application/highlights_exit_bus_test.dart` (novo), `restauracao_test.dart`

- [ ] **Passo 1: os testes (RED).**
  - O barramento entrega a saída só para quem escuta o mesmo livro:

```dart
  test('o canal entrega a saída de um livro a quem escuta esse livro', () async {
    final bus = HighlightsExitBus();
    addTearDown(bus.dispose);
    final a = <HighlightsExit>[];
    final sub = bus.of('livroA').listen(a.add);
    addTearDown(sub.cancel);
    bus.post('livroB', const HighlightsContinue());
    bus.post('livroA', const HighlightsOpenAt('x', page: 41));
    await Future<void>.delayed(Duration.zero);
    expect(a, [const HighlightsOpenAt('x', page: 41)]);
  });
```

  - **Restauração:**
    - o leitor + a 25 aberta pelo botão Grifos;
    - `restartAndRestore()` (volta a pilha leitor → 25);
    - toca no cartão 3 (`dragUntilVisible` + tap);
    - o leitor salta para a pág. do trecho, com "← Voltar à pág.".
- [ ] **Passo 2:** rodar e ver falhar (sem canal).
- [ ] **Passo 3: o canal.** Em `highlights_exit.dart`:

```dart
/// R5 (G20): a saída da 25 para o leitor do mesmo livro. O leitor escuta desde que abre — inclusive restaurado, quando
/// ninguém mais espera o resultado do `push`.
final class HighlightsExitBus {
  final StreamController<(String, HighlightsExit)> _out = StreamController.broadcast();

  void post(String bookId, HighlightsExit exit) => _out.add((bookId, exit));

  Stream<HighlightsExit> of(String bookId) =>
      _out.stream.where((e) => e.$1 == bookId).map((e) => e.$2);

  Future<void> dispose() => _out.close();
}
```

  Em `highlights_providers.dart`:

```dart
final highlightsExitBusProvider = Provider<HighlightsExitBus>((ref) {
  final bus = HighlightsExitBus();
  ref.onDispose(bus.dispose);
  return bus;
});
```

  Na 25 (`_open` e `_continue`, com `fromReader`): `Navigator.of(context).pop();` e, depois,
  `ref.read(highlightsExitBusProvider).post(widget.bookId, exit)`.

  No leitor:
  - o `initState` (ou o 1º `didChangeDependencies`) assina `ref.read(highlightsExitBusProvider).of(widget.bookId)`;
  - o `_onHighlightsExit(exit)` faz o que o `switch` do `_openHighlights` fazia;
  - o `_openHighlights` só faz o `push`;
  - o `dispose` cancela a assinatura.
- [ ] **Passo 4:** rodar o teste novo, `highlights_reader_test.dart`, `l25d_test.dart` (Continuar lendo) e
  `restauracao_test.dart`. Commit `feat(grifos): a saída da 25 por um canal que sobrevive à restauração (R5)`.

### Tarefa 9: restaurado no modo anotação (D-166)

**Arquivos:** só o teste em `restauracao_test.dart`

- [ ] **Passo 1:**
  - `abrirTela22` (o traço solto);
  - o ciclo de vida vai a `paused` (`tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused)`);
  - `restartAndRestore()` e `esperarLeitor`;
  - o leitor está limpo (`ann.mode` não existe) e o desenho está no banco (o rascunho gravado, D-166).
- [ ] **Passo 2:** rodar. Se passar de primeira, fica como prova. Se falhar, corrigir com teste. Commit
  `test(leitor): restaurado no meio do modo anotação, a tinta fica (D-166)`.

### Tarefa 10: retrato no nativo (D-209)

**Arquivos:** `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`, `test/home/orientacao_nativa_test.dart`

- [ ] **Passo 1: o teste (RED).**

```dart
// G20 (D-209) — o retrato travado também no nativo: Android e iPhone desde a abertura; o iPad em tela cheia.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android: a MainActivity só em retrato', () {
    final m = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(m, contains('android:screenOrientation="portrait"'));
  });

  test('iOS: iPhone e iPad só em retrato, o iPad em tela cheia', () {
    final p = File('ios/Runner/Info.plist').readAsStringSync();
    String lista(String chave) =>
        RegExp('<key>$chave</key>\\s*<array>(.*?)</array>', dotAll: true).firstMatch(p)!.group(1)!;
    expect(RegExp('<string>(.*?)</string>').allMatches(lista('UISupportedInterfaceOrientations')).map((m) => m.group(1)),
        ['UIInterfaceOrientationPortrait']);
    expect(RegExp('<string>(.*?)</string>').allMatches(lista('UISupportedInterfaceOrientations~ipad')).map((m) => m.group(1)),
        ['UIInterfaceOrientationPortrait']);
    expect(p, matches(RegExp(r'<key>UIRequiresFullScreen</key>\s*<true/>')));
  });
}
```

- [ ] **Passo 2:** rodar e ver falhar.
- [ ] **Passo 3:**
  - no manifesto, `android:screenOrientation="portrait"` na `<activity android:name=".MainActivity"`;
  - no plist, as duas listas só com `UIInterfaceOrientationPortrait` e `<key>UIRequiresFullScreen</key><true/>`.
- [ ] **Passo 4:** rodar e ver passar. Commit `feat(plataforma): retrato travado no Android e no iOS (D-209)`.

### Tarefa 11: `TapTarget`, o alvo que cresce por dentro (R7)

**Arquivos:** criar `lib/core/design_system/widgets/tap_target.dart` e
`test/core/design_system/widgets/tap_target_test.dart`

- [ ] **Passo 1: os testes (RED).**
  - Uma caixa de 28×28 com `TapTarget` dentro de um `Center` de 200×200:
    - o nó semântico mede 48×48, centrado;
    - um toque a 10 px da borda dela (fora do desenho, dentro dos 48) chama o `onTap`;
    - um toque a 30 px não chama;
    - o tamanho de layout continua 28×28.
  - **Dois vizinhos a 34:** com `hitLimit` (a metade do vão), o toque no meio do vão vai para o mais perto, e os nós
    semânticos medem 48×48 cada um.
  - `meetsGuideline(androidTapTargetGuideline)` passa com o `TapTarget` e falha sem ele.
- [ ] **Passo 2:** rodar e ver falhar.
- [ ] **Passo 3: o widget.**

```dart
// G20 (R7, D-208) — o alvo de toque que cresce por dentro: o nó semântico e a área de toque ganham o tamanho mínimo
// (48 — Android; vale também os 44 do iOS), centrados no desenho, sem mudar o layout nem o que se vê. [hitLimit]
// corta a área de toque de cada lado (a metade do vão até o vizinho); o nó semântico fica com o mínimo.
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class TapTarget extends SingleChildRenderObjectWidget {
  const TapTarget({super.key, this.minSize = 48, this.hitLimit, super.child});

  final double minSize;
  final EdgeInsets? hitLimit;

  @override
  RenderTapTarget createRenderObject(BuildContext context) =>
      RenderTapTarget(minSize: minSize, hitLimit: hitLimit);

  @override
  void updateRenderObject(BuildContext context, RenderTapTarget r) => r
    ..minSize = minSize
    ..hitLimit = hitLimit;
}

class RenderTapTarget extends RenderProxyBox {
  RenderTapTarget({required double minSize, EdgeInsets? hitLimit})
    : _minSize = minSize,
      _hitLimit = hitLimit;

  double _minSize;
  set minSize(double v) {
    if (v == _minSize) return;
    _minSize = v;
    markNeedsSemanticsUpdate();
  }

  EdgeInsets? _hitLimit;
  set hitLimit(EdgeInsets? v) {
    if (v == _hitLimit) return;
    _hitLimit = v;
  }

  /// O retângulo do tamanho mínimo, centrado no desenho.
  Rect get _grown {
    final w = math.max(size.width, _minSize);
    final h = math.max(size.height, _minSize);
    return Rect.fromCenter(center: size.center(Offset.zero), width: w, height: h);
  }

  Rect get _hitArea {
    final g = _grown;
    final l = _hitLimit;
    if (l == null) return g;
    return Rect.fromLTRB(
      math.max(g.left, -l.left),
      math.max(g.top, -l.top),
      math.min(g.right, size.width + l.right),
      math.min(g.bottom, size.height + l.bottom),
    );
  }

  @override
  Rect get semanticBounds => _grown;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!_hitArea.contains(position)) return false;
    // dentro da área nova, o toque vai para o desenho (a posição presa na borda dele)
    final inside = Offset(
      position.dx.clamp(0, size.width),
      position.dy.clamp(0, size.height),
    );
    final hit = hitTestChildren(result, position: inside);
    if (hit) result.add(BoxHitTestEntry(this, position));
    return hit;
  }
}
```

- [ ] **Passo 4:** rodar e ver passar. Commit `feat(design): o alvo de toque que cresce por dentro (R7, D-208)`.

### Tarefa 12: os guias nas telas do leitor (R6, R7)

**Arquivos:**
- Criar: `test/integration/acessibilidade_leitor_test.dart`
- Modificar: os widgets que falharem (ex.: `scrubber.dart`, `highlight_filters.dart`, `color_picker.dart`, os chips)

- [ ] **Passo 1: os testes.** Uma função para cada tela:

```dart
Future<void> guias(WidgetTester tester, String tela, List<String> contraste) async {
  final h = tester.ensureSemantics();
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline), reason: tela);
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline), reason: tela);
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline), reason: tela);
  // o contraste é medido, não reprova (D-208)
  final c = await textContrastGuideline.evaluate(tester);
  if (!c.passed) contraste.add('## $tela\n${c.reason}');
  h.dispose();
}
```

  Um `testWidgets` por tela da §6:
  - 19, 20, 20 com a busca, 21, 22, 23, 23b, 24, 24b, 26, 26b, 27, 27b;
  - a 25 no topo e rolada, com Mais opções e Exportar;
  - as folhas da nota, Outra cor e Rótulos.

  Cada um abre pelos auxiliares das fases e chama `guias`. Um `tearDownAll` grava a lista do contraste em
  `tools/medicao/tmp/contraste_g20.md`, só com `BOOKNEST_CAPTURAS` definido, como as capturas.
- [ ] **Passo 2:** rodar. A falha de cada guia lista os nós (rótulo e tamanho). Juntar a lista dos alvos pequenos.
- [ ] **Passo 3:** para cada alvo da lista:
  - envolver o desenho tocável num `TapTarget`, com `hitLimit` onde há vizinho a menos de 48;
  - onde o pai é justo, passar o espaço de fora para dentro do pai, conferindo que a fase (L19…L27b) continua
    passando;
  - escrever um teste que toca na borda da área nova e vê a ação acontecer.
- [ ] **Passo 4:** rodar a acessibilidade, as fases L19–L27b, os goldens do leitor e da 25 e ver passar.
- [ ] **Passo 5:** commits por grupo, por exemplo `feat(leitor): alvos de toque de 48 na barra e nos chips (R7)`.

### Tarefa 13: os anúncios do modo e os desenhos na página (R8)

**Arquivos:**
- Modificar: `lib/features/reader/presentation/annotation_island.dart` (`toolAnnouncement`) e `reader_screen.dart` (ouvir
  a sessão; os nós dos desenhos)
- Testes: `test/features/reader/presentation/annotation_island_test.dart`, `reader_screen_g20_test.dart` (novo)

- [ ] **Passo 1: os testes (RED).**

```dart
  test('R8: o anúncio da ferramenta e da cor', () {
    expect(toolAnnouncement(AnnotationTool.marker, const Color(0xFFFED170)), 'Marca-texto, amarelo');
    expect(toolAnnouncement(AnnotationTool.pen, const Color(0xFFFF552E)), 'Caneta, coral');
    expect(toolAnnouncement(AnnotationTool.line, const Color(0xFFFF552E)), 'Reta, coral');
    expect(toolAnnouncement(AnnotationTool.eraser, const Color(0xFFFF552E)), 'Borracha');
    expect(toolAnnouncement(AnnotationTool.lasso, const Color(0xFFFF552E)), 'Laço');
    expect(toolAnnouncement(AnnotationTool.space, const Color(0xFFFF552E)), 'Espaço');
  });
```

  No `reader_screen_g20_test.dart`:
  - `abrirTela22` (o traço solto), `tester.takeAnnouncements()` para zerar, toque no Marca-texto: anúncio
    "Marca-texto, amarelo"; troca de cor no poço: anúncio com a cor nova; Borracha: "Borracha";
  - o leitor limpo na pág. 159 do mundo (com os desenhos da tela 20): um nó `image` "Desenho, 20 de setembro" para
    cada desenho da página (pelo `find.semantics.byPredicate`).
- [ ] **Passo 2:** rodar e ver falhar.
- [ ] **Passo 3:**
  - `toolAnnouncement(AnnotationTool t, Color c)` em `annotation_island.dart`:
    - o nome da ferramenta é o rótulo da prateleira (`tool_shelf.dart`);
    - a cor vem de `colorName(c, pen: t != AnnotationTool.marker)`;
    - Borracha, Laço e Espaço vão sem a cor.
  - No `reader_screen.dart`, ao abrir a sessão, guardar `(tool, color)` e ouvir `session.addListener`: quando um dos
    dois muda, `_announce(toolAnnouncement(...))`. O anúncio da entrada fica como está.
  - Os desenhos da página: logo depois das notas à mão (o mesmo `Positioned.fromRect` + `IgnorePointer`), para cada
    `ink.drawingsOn(doc.current)` um `Semantics(image: true, label: drawingInkLabel(d.saved.createdAt))`. O retângulo é
    o `inkBounds(d.strokes)`; a função vem de `ink_thumbnail.dart` e passa para `ink_painter.dart`, com o
    `ink_thumbnail.dart` importando de lá. Também: `drawingInkLabel` em `hand_note.dart`, ao lado de
    `noteInkLabel`, com o mesmo formato ("Desenho, 20 de setembro").
- [ ] **Passo 4:** rodar e ver passar (e as fases L20–L24b, cuja semântica conta os nós). Commit
  `feat(leitor): anúncios da ferramenta e da cor e os desenhos no leitor de tela (R8)`.

### Tarefa 14: o teto do cache de páginas (R11)

**Arquivos:** `lib/core/data/database/daos/content_daos.dart` (`PageLayoutCacheDao`), `lib/features/reader/application/book_pager.dart`; teste `test/features/reader/layout/page_layout_cache_test.dart`

- [ ] **Passo 1: os testes (RED).**
  - Gravar 5 combinações do mesmo livro (os `settingsHash` 'a'…'e', `now` crescente): sobram 4, sem a 'a'.
  - Gravar 'a'…'d', ler 'a' com `now` novo (marca o uso), gravar 'e': sai a 'b'.
  - Outro livro não conta no teto do primeiro.
- [ ] **Passo 2:** rodar e ver falhar.
- [ ] **Passo 3:**
  - `get({…, DateTime? now})`: com `now`, a linha achada tem o `created_at` trocado para `now`. A coluna passa a
    valer "o último uso", e o comentário da tabela diz isso.
  - `put`: depois do `insertOnConflictUpdate`, apagar as linhas do livro fora das 4 de `created_at` mais novo.

```dart
  /// R11 (G20): até 4 combinações por livro; a de uso mais antigo sai.
  static const int perBook = 4;

  Future<void> _trim(String userBookId) => _db.customStatement(
    'DELETE FROM page_layout_cache WHERE user_book_id = ?1 AND rowid NOT IN ('
    'SELECT rowid FROM page_layout_cache WHERE user_book_id = ?1 '
    'ORDER BY created_at DESC LIMIT $perBook)',
    [userBookId],
  );
```

  (Se a tabela for `WITHOUT ROWID`, a mesma consulta usa a chave: `(settings_hash, viewport, fonts_version) NOT IN
  (…)`.)
  - `book_pager.dart`: passar o relógio que ele já usa no `put` também no `get`.
- [ ] **Passo 4:** rodar o teste do cache e `book_pager_test.dart`. Commit
  `perf(leitor): o cache de páginas guarda até 4 combinações por livro (R11)`.

### Tarefa 15: o teste de aparelho (R9)

**Arquivos:**
- `pubspec.yaml` (dev: `integration_test: sdk: flutter`, `flutter_driver: sdk: flutter`)
- criar `test/perf/fluxos_do_leitor.dart`, `integration_test/leitor_orcamentos_test.dart`,
  `test_driver/orcamentos_driver.dart`, `test/perf/fluxos_do_leitor_test.dart`
- `docs/adr/ADR-005_paginacao.md`

- [ ] **Passo 1:** os fluxos em `test/perf/fluxos_do_leitor.dart`, sem medir nada (quem chama mede):
  - `abrirLivroIndexado(tester, livro)` → até o `r19.footer`;
  - `virarPaginas(tester, n)`;
  - `paginarCapitulo(livro, spine)` → `Duration`, com o `ChapterLayout` direto e as fatias do `LayoutScheduler`;
  - `tracar(tester, n)` → `n` traços no modo anotação;
  - `importarEpub(bytes)` → `Duration` até poder ler, pelo `BookImporter`;
  - `epubDe2MB()` → um EPUB de ~2 MB com texto pseudoaleatório (semente fixa) pelo `epub_builder.dart`.
- [ ] **Passo 2:** `test/perf/fluxos_do_leitor_test.dart` (fumaça, na suíte comum): cada fluxo roda uma vez no
  `flutter_test` sem quebrar (sem medir tempo).
- [ ] **Passo 3:** `integration_test/leitor_orcamentos_test.dart`, com o
  `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`:
  - abrir: `Stopwatch` em volta de `abrirLivroIndexado`;
  - virar 30: `binding.watchPerformance(() => virarPaginas(tester, 30), reportKey: 'virar')`;
  - paginar: `paginarCapitulo` num capítulo de ~40 páginas;
  - traço: o medidor da G16 (`BOOKNEST_MEDIR_TINTA`), pelas linhas `G16LAT`;
  - importar: `importarEpub(epubDe2MB())`;
  - memória: `ProcessInfo.currentRss` com o livro aberto e depois das 30 viradas;
  - `binding.reportData = {...}` com cada número e o orçamento ao lado.

  `test_driver/orcamentos_driver.dart`:

```dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  responseDataCallback: (data) => writeResponseData(data, testOutputFilename: 'orcamentos_aparelho'),
);
```

  Comando (G26): `flutter drive --profile --driver=test_driver/orcamentos_driver.dart
  --target=integration_test/leitor_orcamentos_test.dart -d <celular>`.
- [ ] **Passo 4:** no ADR-005, uma linha: "`integration_test` e `flutter_driver` (SDK, só desenvolvimento) — a medição
  dos orçamentos do Anexo 03 §12 no aparelho (G20, R9)".
- [ ] **Passo 5:** `flutter pub get`, `flutter analyze` (o arquivo do aparelho precisa compilar) e a fumaça. Commit
  `test(desempenho): o teste de aparelho dos orçamentos, pronto para a G26 (R9)`.

### Tarefa 16: a prévia no PC (R10)

**Arquivos:** criar `test/perf/orcamentos_pc_test.dart`

- [ ] **Passo 1:** o teste, pulado sem `--dart-define=BOOKNEST_ORCAMENTOS=true`
  (`skip: !bool.fromEnvironment('BOOKNEST_ORCAMENTOS')`):
  - mede os fluxos da Tarefa 15 com `Stopwatch`, 5 vezes cada, com a mediana e o p95;
  - nas viradas, o tempo real de cada `pump` (build, layout e pintura, sem a GPU);
  - grava `tools/medicao/tmp/orcamentos_pc.json` (`BOOKNEST_ORCAMENTOS_SAIDA`, ou esse caminho).
- [ ] **Passo 2:** rodar no Windows com `flutter test --dart-define=BOOKNEST_ORCAMENTOS=true
  test/perf/orcamentos_pc_test.dart`, levar o JSON e montar a tabela do relatório: cada número ao lado do
  orçamento, com o aviso (modo de depuração, sem a GPU, sem a memória do celular).
- [ ] **Passo 3:** commit `test(desempenho): a prévia dos orçamentos no PC (R10)`.

### Tarefa 17: o sumário grande (R12)

**Arquivos:** criar `test/perf/sumario_grande_test.dart`; `lib/features/reader/presentation/toc_chapters.dart` (só se
passar de 100 ms)

- [ ] **Passo 1: a medição.**
  - Um índice com 5.000 capítulos (`BookIndex` sintético, títulos de 1–3 linhas, numerais 1…5000), pela
    `depsDaTela27` com o índice trocado (`usarIndice`);
  - abrir a folha (`r20.bottomIsland.tools.toc`) com `Stopwatch` até o `toc.sheet` assentar;
  - contar as linhas montadas (`find.byKey` com o prefixo das linhas);
  - gravar o tempo e as linhas, só com `BOOKNEST_ORCAMENTOS`, como a prévia.
- [ ] **Passo 2:** rodar no Windows.
  - **Até 100 ms:** o teste fica como prova, e o relatório registra o número.
  - **Acima de 100 ms:** a lista passa a montar sob demanda:
    - a altura de cada linha vem de um `TextPainter` com o estilo e a largura do título, sem montar o widget;
    - a soma das linhas de cima dá a rolagem inicial com o atual a 378,4;
    - a lista vira `ListView.builder` com `itemExtentBuilder`;
    - a L27/L27b e o golden da 27 continuam passando;
    - o teste confere as linhas montadas (no máximo ~30) e a rolagem inicial.
- [ ] **Passo 3:** commit `perf(sumario): …` (ou `test(sumario): a medição com 5.000 entradas (R12)`).

### Tarefa 18: prova e relatório (G20.8)

- [ ] **Passo 1:** suíte completa com cobertura: `rodar.ps1 -Nome g20v -Cmd "flutter analyze & flutter test
  --coverage"`. Ler `+N ~7`; cobertura dos arquivos de `git diff --name-only 8622d18 -- lib` pelo
  `tools/coverage/resumo.py` (meta ≥ 90 %).
- [ ] **Passo 2:** os goldens do leitor e da 25 continuam (≤ 0,5 %; a L25c pela D-204, com
  `tools/medicao/g19/golden_sem_tinta.py`).
- [ ] **Passo 3: revisão independente** por um agente que não escreveu o código (`superpowers:requesting-code-review`),
  com a spec e o diff `8622d18..HEAD`. Corrigir os achados com teste (superpowers:receiving-code-review).
- [ ] **Passo 4: mutação.** `tools/medicao/tmp/mut/g20/gerar_g20.py` (como o da G19), com trocas em:
  - `homeChapter`: o `>`, o recuo e o `n == 0`;
  - o `PopScope` (a ordem das camadas);
  - R4: `_wentToDone.value = true` fora;
  - R5: o `post` fora, o filtro do livro;
  - o `TapTarget`: o `_hitArea`, o `semanticBounds`, o `hitLimit`;
  - `toolAnnouncement`: a cor nas ferramentas sem cor;
  - R11: o `LIMIT 4` e o `now` do `get`;
  - o manifesto e o plist.

  Uma 2ª rodada para as que passarem.
- [ ] **Passo 5:** gitleaks (`tools/medicao/tmp/gitleaks_g20.sh`): os commits `8622d18..HEAD` e as pastas tocadas.
- [ ] **Passo 6: capturas** (`test/golden/capturas_g20_test.dart`, com `BOOKNEST_CAPTURAS`):
  - o herói antes e depois de ler, com "Cap. 32 de 148";
  - o leitor no mesmo ponto;
  - a sequência do Voltar;
  - a restauração (antes e depois);
  - os alvos que cresceram, com a área marcada (um `CustomPaint` só no teste).

  Mandar na conversa.
- [ ] **Passo 7:**
  - `G20.md`: checklist, resultados, a tabela de contraste, os orçamentos do PC, revisão, desvios e pendências;
  - `RELATORIO_G20.md` no estilo do da G19, no projeto (`handoff_app_completo/relatorios/`);
  - o `05_DECISOES_E_PERGUNTAS.md`, se algo mudou;
  - commit dos documentos e gitleaks de novo.
- [ ] **Passo 8:** a última linha do relatório: "✅ FASE G20 concluída — aguardando sua aprovação para iniciar a FASE
  G21."
