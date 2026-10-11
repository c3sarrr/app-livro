# T04 — Lendo agora (cronômetro do livro de papel, 01b): plano de implementação

> **Para quem executa:** execução inline (superpowers:executing-plans), uma tarefa por vez, TDD: o teste falha
> (RED), o código mínimo passa (GREEN), commit pequeno. Passos com `- [ ]`.
> Spec: `docs/progresso/T04.md` (D-256…D-263, R1…R12), citada por §1…§6. Branch `feat/t04-cronometro-papel`, base
> `6b14a57` (spec em `3f1b3fb`).

**Objetivo:** o "play" do livro de papel e o "Ler agora" começam uma sessão de cronômetro que sobrevive ao app fechado,
aparece numa mini-barra idêntica à 01b em todas as abas, pausa, retoma e termina numa folha mínima que grava a sessão,
a página e o total — com a 01b provada nas 4 camadas e os dados pela D-244.

**Arquitetura:** domínio puro (`OpenPaperSession`, relógio de parede) → `PaperTimerStore` (`kv`, como a tinta da G16) e
`PaperSessionWriter` (3 tabelas numa transação, `LocalVersioning`) → `PaperTimerController` (Riverpod) → cartão,
mini-barra no `MainShell`, folha no navigator raiz. O tique de 1 s é uma interface (`SecondTicker`) que os testes
trocam por um manual — um `Timer.periodic` real nunca deixa o `pumpAndSettle` assentar.

**Pilha:** Flutter 3.47.2 / Dart 3.13.2, flutter_riverpod 3, drift, go_router 18; Supabase local (Docker) para o
pgTAP; `tools/compare_images.py`.

**Execução e ambiente:** testes no Windows (`flutter test`, um processo por vez — sqlite3.dll); goldens com
`--update-goldens` (pode ser negado no modo automático: aí o usuário roda); `test/home/failures/*` restaurados do HEAD
quando um golden falhar; pgTAP com `supabase test db` (Docker de pé; se não estiver, pendência de ambiente com o
comando exato); gitleaks no WSL (`MSYS_NO_PATHCONV=1`).

## Arquivos

| Arquivo | Responsabilidade | Tarefa |
|---|---|---|
| `lib/features/reading_session/domain/open_paper_session.dart` (novo) | sessão aberta, relógio de parede, 24 h, outro dia, registro (R2–R4) | 1 |
| `lib/features/reading_session/application/paper_timer_format.dart` (novo) | "08:42"/"1:08:42", rótulos, kicker, progresso (R1, R5) | 1 |
| `lib/features/home/application/read_now.dart` (novo) | a regra do "Ler agora" (D-258, R11) | 1 |
| `lib/features/reader/domain/locator.dart` | `PaperLocator` (R7) | 1 |
| `lib/features/reading_session/data/paper_timer_store.dart` (novo) | interface + `kv` `paper_timer:<dono>` (R8) | 2 |
| `lib/features/account/data/local_library.dart` | apagar e adotar a chave | 2 |
| `lib/features/reading_session/data/paper_session_writer.dart` (novo) | interface + gravação do fim e da divisão do dia (R7, R4) | 3 |
| `lib/features/reading_session/data/paper_book_source.dart` (novo) | o livro da sessão, o total, a última página, as páginas do catálogo do aparelho (D-260) | 3 |
| `lib/features/reading_session/application/paper_timer_controller.dart` (novo) | o controlador e os provedores | 4 |
| `lib/features/reading_session/application/second_ticker.dart` (novo) | o tique de 1 s (interface + real + manual) | 4 |
| `lib/features/reading_session/application/reader_pause_observer.dart` (novo), `lib/app/router.dart`, `lib/app/app.dart` | D-263 | 4 |
| `test/fixtures/telas/inicio01b.dart` (novo), `test/fixtures/paper_timer_fakes.dart` (novo) | `t01b` e os falsos | 5 |
| `test/home/t01b_divergencias_test.dart` (novo) | os 5 ids do Para você | 5 |
| `lib/features/home/presentation/sections/also_reading_section.dart` | o botão da sessão (L01b.1, R6, D-257) | 6 |
| `lib/core/design_system/tokens/app_icons_inicio.dart`, `assets/…/ic_play_tinta.svg` (novo) | o ícone derivado (R9) | 7 |
| `lib/features/home/presentation/covers/book_cover.dart` | `CoverSlot.miniBar` (borda clara) | 7 |
| `lib/features/reading_session/presentation/session_mini_bar.dart` (novo) | a mini-barra (L01b.2–3) | 7 |
| `lib/features/shell/presentation/{main_shell,bottom_fade}.dart`, `shell_insets.dart` (novo), `home_screen.dart`, `placeholder_screen.dart` | ordem de pintura, degradê 240/48 %, folga +96 (L01b.4, D-259) | 8 |
| `lib/features/reading_session/presentation/session_sheet.dart` (novo) | a folha (D-256, D-260, D-262) | 9 |
| `home_screen.dart`, `today_section.dart`, `test/home/**` (T03), `docs/design/estados_sem_design.md`, `main.dart` | toques, testes da T03 que mudam, pré-carga (L01b.5) | 10 |
| `test/home/inicio01b/*` (novos), `test/home/golden_*` | página 01b, goldens, estados, desempenho (L01b.6) | 11 |
| `supabase/tests/database/27_sessao_papel.test.sql` (novo), `test/features/reading_session/*privacy*`, `test/integracao/cronometro_papel_test.dart` | banco, privacidade, integração | 12 |
| `docs/progresso/T04.md` | resultados, desvios, pendências | 13 |

---

## T04.0 — Preparação
- [x] Branch `feat/t04-cronometro-papel`; D-256…D-263 na §3 do PLANO; `T04.md` (commit `3f1b3fb`).
- [ ] Este plano. Commit `docs(progresso): T04 — plano`.

## T04.1 — Domínio e formatadores (TDD)

**Arquivos:** os 4 primeiros da tabela; testes em `test/features/reading_session/domain/open_paper_session_test.dart`,
`test/features/reading_session/application/paper_timer_format_test.dart`, `test/home/read_now_test.dart`,
`test/features/reader/domain/locator_test.dart` (grupo novo).

- [ ] **RED — `OpenPaperSession`** (relógio em UTC; `t0 = 2026-09-20T22:51:18Z`):
  - `start` → rodando, 0 s; `elapsedAt(t0 + 8:42)` = 522;
  - `pause(t0+522)` → pausada, `activeSeconds` 522, `pausedAt` = t0+522; `elapsedAt` depois não anda;
    `resume(t1)` → rodando desde t1, os 522 guardados; `elapsedAt(t1+60)` = 582;
  - relógio para trás: `settle(t0 − 30 s)` → `runningSince` = agora, nada descontado; `elapsedAt(t0 − 30 s)` = 0;
  - 24 h: rodando desde t0 com 86 000 acumulados → `settle(t0 + 1 h)` pausa com 86 400 e `pausedAt` = t0 + 400 s;
    `resume` com 86 400 continua pausada;
  - `record(now)`: < 10 s → `null`; 10 s → registro; o fim de parede é agora (rodando) ou `pausedAt` (pausada), nunca
    antes do início (relógio para trás);
  - `isOnLocalDay(now, offsetAt)`: −3 h; a sessão das 23:59 locais não é "hoje" à 00:00 seguinte; dia de 23/25 h;
  - `resumeOnAnotherDay`: pausada ontem → devolve o registro de ontem (até a pausa) e uma sessão nova rodando com outro
    id, 0 s; mesmo dia → nenhum registro;
  - `toJson`/`fromJson` ida e volta; `v` diferente de 1 → `null`; campos faltando → `null` (nunca lança).
- [ ] **GREEN** — o núcleo:

```dart
/// Limite do banco (`active_seconds ≤ 86400`): ao chegar nele, a sessão pausa sozinha (R2).
const int maxPaperSessionSeconds = 86400;

/// Menos que isto não grava a sessão (G10, R3).
const int minPaperSessionSeconds = 10;

/// O que gravar em `reading_sessions` (source = timer).
@immutable
final class PaperSessionRecord {
  const PaperSessionRecord({required this.id, required this.userBookId, required this.startedAt,
      required this.endedAt, required this.activeSeconds});
  final String id;
  final String userBookId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int activeSeconds;
  // == e hashCode por campo
}

/// A sessão do cronômetro aberta neste aparelho (R2, R4, R8): tempo pelo relógio de parede, a partir do
/// "rodando desde" — sobrevive ao app fechado (a pessoa continua lendo o papel).
@immutable
final class OpenPaperSession {
  OpenPaperSession({required String id, required String userBookId, required DateTime startedAt,
      required int activeSeconds, DateTime? runningSince, DateTime? pausedAt})
    : id = Check.uuid(id, 'id'),
      userBookId = Check.uuid(userBookId, 'userBookId'),
      startedAt = Check.utc(startedAt, 'startedAt'),
      activeSeconds = Check.range(activeSeconds, 0, maxPaperSessionSeconds, 'activeSeconds'),
      runningSince = Check.utcOrNull(runningSince, 'runningSince'),
      pausedAt = Check.utcOrNull(pausedAt, 'pausedAt');

  factory OpenPaperSession.start({required String id, required String userBookId, required DateTime now}) =>
      OpenPaperSession(id: id, userBookId: userBookId, startedAt: now.toUtc(), activeSeconds: 0,
          runningSince: now.toUtc());

  final String id;
  final String userBookId;
  final DateTime startedAt;

  /// Segundos até o "rodando desde" (rodando) ou até a pausa (pausada).
  final int activeSeconds;
  final DateTime? runningSince;
  final DateTime? pausedAt;

  bool get isRunning => runningSince != null;

  int elapsedAt(DateTime now) { … }          // R2: trecho negativo = 0; teto 86 400
  OpenPaperSession settle(DateTime now) { … } // R2: relógio para trás, pausa das 24 h
  OpenPaperSession pause(DateTime now) { … }
  OpenPaperSession resume(DateTime now) { … }
  PaperSessionRecord? record(DateTime now) { … } // R3
  bool isOnLocalDay(DateTime now, Duration Function(DateTime utc) offsetAt) { … }
  ({PaperSessionRecord? closed, OpenPaperSession next}) resumeOnAnotherDay(
      DateTime now, Duration Function(DateTime utc) offsetAt, String newId) { … } // R4
  Map<String, Object?> toJson() => { 'v': 1, 'id': …, 'book': …, 'startedAt': …, 'activeSeconds': …,
      'runningSince': …, 'pausedAt': … };
  static OpenPaperSession? fromJson(Object? json) { … } // nunca lança
  // == e hashCode por campo
}
```

- [ ] **RED — `PaperTimerFormat`:** `clock(0)` "00:00", `clock(522)` "08:42", `clock(3599)` "59:59", `clock(3600)`
  "1:00:00", `clock(4122)` "1:08:42", `clock(86400)` "24:00:00"; `spoken(522)` "8 minutos e 42 segundos",
  `spoken(60)` "1 minuto", `spoken(61)` "1 minuto e 1 segundo", `spoken(1)` "1 segundo", `spoken(0)` "0 segundos",
  `spoken(4122)` "1 hora, 8 minutos e 42 segundos", `spoken(7200)` "2 horas"; `kicker(running: true)` "LENDO · PAPEL",
  `kicker(running: false)` "EM PAUSA · PAPEL"; `miniBarLabel(running: true, title: 'Brás Cubas', seconds: 522)` =
  "Sessão em andamento: Brás Cubas, 8 minutos e 42 segundos. Abrir cronômetro" (texto literal da prancha); pausada
  "Sessão em pausa: …"; `pauseAria('Brás Cubas')` "Pausar leitura de Brás Cubas" (literal), `resumeAria` "Retomar
  leitura de …"; botões "Pausar"/"Retomar"; `dailyProgress(readMinutes: 18, goalMinutes: 30, openSeconds: 522)` =
  0,89 (exato a 1e-9), com meta 0 → 1 se leu algo e 0 se não, nunca > 1 nem < 0.
- [ ] **RED — `readNowAction`** (D-258, R11): sessão pausada → `ResumeSession`; rodando → `KeepRunning`; sem sessão e
  herói de papel → `StartTimer(herói)`; herói e-book + Também lendo [e-book, papel A, papel B] → `StartTimer(A)` (o 1º de
  papel na ordem, inclusive além dos 2 da grade); herói PDF sem papel → `OpenReader(herói)`; sem herói → `NoAction`.
- [ ] **RED — `PaperLocator`:** `{"v":1,"kind":"paper","refPage":344}` → `PaperLocator(344)`; ida e volta; refPage 0 →
  `RawLocator` (não lança); um `EpubLocator` não vira papel.
- [ ] GREEN nos 4; cobertura de `reading_session/domain` e `application` 100 % nas linhas novas. Commit
  `feat(cronometro): a sessão do papel pelo relógio de parede e os textos da 01b (T04.1)`.

## T04.2 — A sessão aberta no `kv` (R8)

**Arquivos:** `paper_timer_store.dart`, `local_library.dart`; testes `test/features/reading_session/data/paper_timer_store_test.dart`,
`test/features/account/local_library_test.dart` (casos novos).

```dart
abstract interface class PaperTimerStore {
  Future<OpenPaperSession?> load(String owner);
  Future<void> save(String owner, OpenPaperSession session);
  Future<void> clear(String owner);
}

/// `paper_timer:<dono>` no `kv` (só local), como o rascunho da tinta (`ink_draft:`).
String paperTimerKey(String owner) => 'paper_timer:$owner';
```

- [ ] RED: ida e volta pelo banco em memória; JSON ilegível ou `v` desconhecido → `null` e a chave **apagada** (relatada
  pelo `onError` injetado no `KvPaperTimerStore`, padrão `reportReaderError`); dois donos não se misturam; `erase(dono)` apaga só a dele;
  adoção do convidado: a do convidado vira a da conta quando a conta não tem sessão; com as duas, fica a que começou por
  último e a outra sai.
- [ ] GREEN (`LocalLibrary.erase` e a adoção ganham a chave; o `UPDATE kv` da adoção não pode bater na chave primária —
  apaga a perdedora antes). Commit `feat(cronometro): a sessão aberta mora no kv (T04.2 · R8)`.

## T04.3 — Gravar o fim e o livro da sessão (R7, R4, D-260, D-261)

**Arquivos:** `paper_session_writer.dart`, `paper_book_source.dart`; testes
`test/features/reading_session/data/paper_session_writer_test.dart`, `paper_book_source_test.dart` (banco em memória,
`test/support/personal_builders.dart`).

```dart
/// O que a folha manda gravar ao encerrar (D-256): o registro (null = menos de 10 s), a página e o total informados.
@immutable
final class PaperSessionEnd {
  const PaperSessionEnd({required this.userBookId, required this.record, required this.endedAt, this.page,
      this.pagesTotal});
  …
}

abstract interface class PaperSessionWriter {
  /// Encerrar (R7): sessão (se houver registro), posição (se houver página), `last_opened_at` e o total — uma transação.
  Future<void> end(PaperSessionEnd end);

  /// Só a sessão (a divisão do dia, R4): nem posição nem `last_opened_at`.
  Future<void> recordOnly(PaperSessionRecord record);
}

/// Livro da sessão: o que a mini-barra e a folha mostram.
@immutable
final class PaperBook {
  const PaperBook({required this.book, this.pagesTotal, this.lastPage, this.isbn13});
  final Book book; // o modelo da Início (título, autor, capa)
  …
}

abstract interface class PaperBookSource {
  Future<PaperBook?> book(String owner, String userBookId); // null = apagado ou de outro dono
  Future<int?> catalogPages(String isbn13);                 // só o aparelho: catalog_cache, depois catalog.db
}
```

- [ ] RED (writer): com registro de 522 s, página 120 e total 368, depois de uma posição na pág. 96 →
  `reading_sessions` (id do registro, início/fim, 522, `timer`, de 96 até 120, `pages_viewed` 24, `device_id`),
  `reading_positions` (`PaperLocator(120)`, ref_page 120, capítulo 0, progressão 0,32609), `user_books`
  (`last_opened_at` = fim, `ref_pages_total` 368), todas com versão nova e `updated_at` do HLC; sem posição antes →
  `ref_page_from` nulo e `pages_viewed` nulo; página 90 depois de 96 → `pages_viewed` nulo (negativo); sem página →
  nenhuma posição, `ref_page_to` nulo; registro nulo com página → posição e livro, sem sessão (R3); registro nulo sem
  página → **nada** gravado; falha no meio → nada gravado (uma transação); `recordOnly` → só a sessão; página 0 ou
  maior que o total → `ArgumentError` (a folha valida antes; aqui é a guarda).
- [ ] RED (source): o livro de papel do dono com título, autor e capa como o `LocalHomeRepository` monta; apagado ou de
  outro dono → `null`; `catalogPages` lê o cache do scanner e depois o `catalog.db`, nunca a rede (o
  `IsbnResolver` não é usado — só as duas camadas locais).
- [ ] GREEN. Commit `feat(cronometro): o fim da sessão grava a sessão, a página e o total (T04.3 · R7, D-260, D-261)`.

## T04.4 — O controlador, o tique e o leitor (D-262, D-263)

**Arquivos:** `paper_timer_controller.dart`, `second_ticker.dart`, `reader_pause_observer.dart`, `router.dart`,
`app.dart`; testes `test/features/reading_session/application/paper_timer_controller_test.dart`,
`reader_pause_observer_test.dart`.

```dart
/// O tique de 1 s da mini-barra e da folha. Os testes usam [ManualTicker]: um `Timer.periodic` real não deixa o
/// `pumpAndSettle` assentar.
abstract interface class SecondTicker {
  Stream<void> get ticks;
}

final secondTickerProvider = Provider<SecondTicker>((ref) => const PeriodicSecondTicker());

/// O estado que a tela lê: a sessão aberta (null = nenhuma) e o livro dela.
@immutable
final class PaperTimerState {
  const PaperTimerState({this.session, this.book});
  final OpenPaperSession? session;
  final PaperBook? book;
}

final paperTimerProvider = AsyncNotifierProvider<PaperTimerController, PaperTimerState>(PaperTimerController.new);

class PaperTimerController extends AsyncNotifier<PaperTimerState> {
  Future<PaperTimerState> build();       // carrega, `settle`, descarta a de livro apagado (R8)
  Future<void> start(String userBookId); // sem sessão aberta; com outra aberta → StateError (a tela abre a folha)
  Future<void> pause();
  Future<void> resume();                 // outro dia → recordOnly + nova (R4)
  Future<void> toggle();
  Future<void> end({int? page, int? pagesTotal});
  Future<void> discard();
  Future<void> pauseForReader();         // D-263: só se estiver rodando
}
```

Provedores de dependência (sobrepostos nos testes): `paperTimerStoreProvider`, `paperSessionWriterProvider`,
`paperBookSourceProvider`, `paperTimerOwnerProvider` (o dono ativo do `LocalLibrary`), `paperTimerIdsProvider`
(`UuidV7Generator`), o relógio = `clockProvider` (o mesmo da Início — a `t01b` dá 08:42 com o relógio do mundo) e o
fuso = `readerUtcOffset`.

- [ ] RED (controlador com falsos): começar grava no store e o estado tem sessão e livro; pausar/retomar/alternar;
  encerrar chama o writer com o registro, a página e o total e limpa o store; descartar limpa sem gravar; começar com
  outra aberta → erro e nada muda; retomar noutro dia → `recordOnly` do anterior e sessão nova; carregar uma sessão de
  livro apagado → descartada; carregar depois de 25 h rodando → pausada em 24 h; trocar de dono (a conta entra) →
  recarrega a do dono novo; `pauseForReader` pausa só a que roda.
- [ ] RED (observador): empilhar `/leitor/:bookId` chama `pauseForReader`; `/livro/:bookId`, `/scanner` e as abas não.
- [ ] GREEN; `createRouter(observers: …)` e o `App` passam o observador (o contêiner vem de
  `ProviderScope.containerOf(navigator.context)`). Commit `feat(cronometro): o controlador da sessão e a pausa ao abrir o leitor (T04.4 · D-262, D-263)`.

## T04.5 — Fixture `t01b`, falsos e divergências (D-241)

**Arquivos:** `test/fixtures/telas/inicio01b.dart`, `test/fixtures/paper_timer_fakes.dart`,
`test/fixtures/home_mock_repository.dart` (a `HomeMockRepository01b`), `test/home/t01b_divergencias_test.dart`.

- [ ] `TelaInicio01b`: o instantâneo da `t01` com `dailyReview: null` (a 01b não tem a revisão); a sessão aberta do
  Brás Cubas (`OpenPaperSession` rodando desde `TelaInicio01.agora − 8 min 42 s`, id e livro do mundo); o `PaperBook`
  do Brás Cubas com a capa desenhada; nenhum número da prancha no código de produção (D-34).
- [ ] `paper_timer_fakes.dart`: `MemoryPaperTimerStore`, `RecordingPaperSessionWriter`, `FixedPaperBookSource`,
  `ManualTicker` e `overridesDaSessao(t01b)` para o arnês.
- [ ] `t01b_divergencias_test`: com a `t01b` no app (390 × 844, safe 47/34), os 272 ids de `kRef01b` batem, **exceto**
  exatamente os 5 do Para você (`forYou.item2.cover.title`, `forYou.item2.title`, `forYou.item3.cover.textBlock`,
  `forYou.item3.cover.title`, `forYou.item3.title`), cada um com o valor dos dois lados (o app mostra Memorial de Aires e
  Casa de Pensão, como a 01; a 01b troca por Quincas Borba e O Cortiço abaixo da dobra). Commit `test(fixtures)`.

## T04.6 — O cartão com a sessão (L01b.1, R6, D-257)

**Arquivos:** `also_reading_section.dart`; testes `test/home/inicio01b/cartao_test.dart` (novo),
`test/home/inicio01/tambem_lendo_test.dart` (o caso "sem ação" sai — ver T04.10).

- [ ] RED: com a `t01b`, `alsoReading.card1.play` (o mesmo id) tem `ic_pause` 16 em (142,5; 644,46) e o aro
  `#FF552E` de 3 (sombra dura, blur 0, sem deslocamento), rótulo "Pausar leitura de Brás Cubas"; a pílula continua
  "Papel · 3h 40min" (D-252); pausada → `ic_play` 18, o mesmo aro, "Retomar leitura de Brás Cubas"; sessão do 2º cartão
  (papel com página) → o botão no lugar do anel e o cartão vira `<div>` (capa = link, botão), a pílula "Papel · pág.
  344"; sessão de um livro fora da grade → nenhum cartão muda; geometria dos 33 ids de `i01b.alsoReading` (±0,5/±1,0),
  texto, estilo e semântica da L01b.
- [ ] GREEN: `_BookCard` lê `paperTimerProvider.select((s) => (book, running))` só do próprio livro (não reconstrói com o
  tique); o aro é um `DecoratedBox` circular com `BoxShadow(color: AppColors.flame, spreadRadius: 3)` atrás do
  `CircleIconButton` (o layout continua 46). Commit `feat(inicio): o cartão do livro em sessão — pausar e retomar com o aro coral (T04.6 · L01b.1)`.

## T04.7 — A mini-barra (L01b.2–3, R5, R9, R10, R12)

**Arquivos:** `session_mini_bar.dart`, `app_icons_inicio.dart` + o SVG, `book_cover.dart`; testes
`test/home/inicio01b/mini_barra_test.dart`, `test/features/reading_session/presentation/session_mini_bar_test.dart`.

- [ ] `ic_play_tinta.svg` = o `ic_play.svg` da prancha com `fill="#1A1714"` (R9), no `AppIconsInicio` e no catálogo de
  SVGs (`docs/design/medicao/inicio2/svg_catalogo.json` não muda — é medido; a origem fica no comentário do token e
  em `estados_sem_design.md`).
- [ ] `CoverSlot.miniBar`: 32 × 48, borda 1,2 **`#F7F0E3`** (campo `borderColor` novo, padrão tinta), raio 2/5/5/2, sem
  sombra, sem lombada, sem texto (miniatura).
- [ ] RED (na prancha, `t01b`): os 11 ids de `i01b.miniBar` (358 × 66 em 16/648; barrinha 315,95 × 4 em 1,5/1,5; capa
  13,5/9 girada −5°; arte 29,6 × 45,6; textos 57,5; tempo 227,45/18,6 "08:42"; pausar 302,5/11), as 3 linhas de texto
  ("LENDO · PAPEL" com ls 1,4, "Brás Cubas", "08:42" com `FontFeature.tabularFigures()`), estilo (fundo e borda tinta 1,5,
  raio 22, sombra 0/4 `rgba(26,23,20,.35)` blur 0, recorte; barrinha `{{brand}}` raio 0/4/4/0; ponto 7 `#FF552E`; kicker
  `#B9AE9C` Figtree 10,5/700; título 15/700 `#F7F0E3`; tempo Bricolage 24/800 ls −0,6; círculo 44 `#F7F0E3`), semântica
  (link com o rótulo literal, "Pausar", o resto fora da árvore).
- [ ] RED (estados): pausada → `ic_play_tinta`, "EM PAUSA · PAPEL", ponto `#B9AE9C`, "Sessão em pausa: …", "Retomar",
  tempo parado com o tique; "1:08:42" cabe e o título encolhe com reticências; título longo com reticências; capa real
  (`PhotoBookCover` com `CoverSlot.miniBar`) e gerada; barrinha 0 sem o instantâneo da Início e 100 % com a meta batida;
  tique: o tempo e o rótulo mudam a cada tique do `ManualTicker`, e só eles reconstroem; sem tique com o app em segundo
  plano (`AppLifecycleListener`), e voltar recalcula pela parede.
- [ ] GREEN: a capa desenhada = `il_capa_bras_cubas_asas` sem os `<text>` (como a capa do herói da T03: o desenho por
  `AppSvg` + os textos por `AppText` nas posições × 0,3167 — `MEMÓRIAS PÓSTUMAS DE` Figtree 4,6/700 (800 → 700, D-246),
  `Brás Cubas` Instrument Serif 17,5, `MACHADO DE ASSIS` Figtree 5,2/700), com o `slice` da prancha. Commit
  `feat(inicio): a mini-barra do cronômetro da 01b (T04.7 · L01b.2–3)`.

## T04.8 — O shell: ordem, degradê e folga (L01b.4, D-259)

**Arquivos:** `main_shell.dart`, `bottom_fade.dart`, `shell_insets.dart` (novo), `home_screen.dart`,
`placeholder_screen.dart`; testes `test/home/geometry_shell_test.dart` (casos novos), `test/home/inicio01b/shell_test.dart`.

- [ ] RED: com sessão, o `MainShell` pinta conteúdo → degradê → mini-barra → barra → FAB (ordem dos filhos da `Stack`);
  degradê `i01b.bottomFade` 390 × 240 em y 604 com `stops [0, 0.48]`; mini-barra `bottom = navBottom + 100` (130 no
  aparelho da 01b; acompanha a D-02 com safe 50 → navBottom 46); sem sessão, 150 / 55 % e nada da mini-barra; a mesma
  mini-barra nas 4 abas e ausente sob `/leitor`, `/livro`, `/scanner`; a folga: Início 140 → 236 (rolagem máxima da
  01b = a da 01 sem a revisão + 96), blocos mínimos 116 → 212; os 17 ids da barra e o degradê da L01b.
- [ ] GREEN: `ShellInsets` (InheritedWidget com `extraBottom`, 0 ou 96) fornecido pelo `MainShell` por cima do `shell`;
  `HomeScreen` e `PlaceholderScreen` somam. Commit `feat(shell): a mini-barra entre o degradê e a barra, com a folga das abas (T04.8 · L01b.4)`.

## T04.9 — A folha da sessão (D-256, D-260, D-262)

**Arquivos:** `session_sheet.dart`; testes `test/features/reading_session/presentation/session_sheet_test.dart`.

- [ ] RED (com os falsos): abre por cima das abas (navigator raiz), com o título, "Sessão em andamento · 08:42" que anda
  com o tique; Pausar/Retomar alterna e o texto vira "Sessão em pausa · …"; página só dígitos; com total no livro, só a
  página; sem total, "De quantas páginas é o livro?" já com as páginas do catálogo (ou vazio); página sem total →
  "Informe o total de páginas para registrar a página." e não encerra; página fora de 1…N → "A página vai de 1 a N." e
  não encerra; "Última registrada: pág. 96" com posição; "Encerrar sessão" grava (writer) e fecha; "Descartar sessão" →
  confirmação ("Descartar esta sessão? Os 08:42 não serão gravados.") → "Descartar" limpa sem gravar, "Voltar" volta;
  "Fechar" não muda nada; aberta para outro livro (D-262): a linha "Para começar Orgulho e Preconceito, encerre ou
  descarte esta sessão." e, ao encerrar ou descartar, a sessão nova começa no outro livro; "Fechar" não começa nada;
  semântica (cabeçalho, botões, campos com rótulo); o teclado sobe a folha sem cobrir os campos.
- [ ] GREEN com os primitivos da D-21 (`account_widgets.dart`) na moldura das folhas mínimas da G21 (a "Antes de
  publicar"). Commit `feat(cronometro): a folha da sessão — página, total, encerrar e descartar (T04.9 · D-256, D-260, D-262)`.

## T04.10 — Os toques (L01b.5) e o que muda nos testes da T03

**Arquivos:** `home_screen.dart`, `today_section.dart`, `main.dart` (pré-carga), `docs/design/estados_sem_design.md`,
`test/home/touch_home_test.dart`, `test/home/inicio01/{tambem_lendo,seu_dia}_test.dart`, `test/home/pre_carga_inicio_test.dart`.

- [ ] RED no app inteiro (`abrirInicio01` com os falsos): o play do Brás Cubas na `t01` começa a sessão (a mini-barra
  aparece, o cartão vira "pausar", a rota não muda); o pausar do cartão e o da mini-barra pausam e retomam; tocar a
  mini-barra abre a folha; o play de outro livro com sessão abre a folha com o aviso; "Ler agora" segue a D-258 (na
  `t01`: começa o Brás Cubas — o herói é e-book e o 1º de papel do Também lendo é ele); com herói e-book e nenhum papel,
  abre `/leitor/<herói>` e pausa a sessão que rodava (D-263); sem nada em leitura, sem ação (R11).
- [ ] Os testes da T03 que provavam "sem ação" no play e no "Ler agora" passam a provar a ação (o motivo vai para o
  relatório — memória "later phases touch earlier tests"); a lupa, o "Revisar" e o ⋯ continuam sem ação.
- [ ] `estados_sem_design.md`: as 2 linhas da T03 ganham "ganhou ação na T04"; seção T04 (folha, pausado, mini-barra nas
  abas sem prancha, "Ler agora" sem nada em leitura, `ic_play_tinta`).
- [ ] Pré-carga: `AppIconsInicio.inicio01b` (pausar, pausar tinta, play tinta) e `AppIllustrationsInicio.inicio01b`
  (Brás Cubas com asas) no `main()`, com o teste da lista igual ao que a 01b desenha. Commit
  `feat(inicio): o play, o "Ler agora" e a mini-barra ganham ação (T04.10 · L01b.5)`.

## T04.11 — A 01b inteira, goldens e desempenho (L01b.6)

**Arquivos:** `test/home/inicio01b/pagina_test.dart`, `test/home/golden_viewport_test.dart` (caso 01b),
`test/home/golden_theme_test.dart`, `test/home/reconstrucoes_test.dart`, `test/home/semantics_*` (01b).

- [ ] Página: os 272 ids (menos os 5 da T04.5) e todas as linhas contra `kRef01b`, rolagem 0, 390 × 844 safe 47/34; o
  golden da tela inteira `@3x` (1170 × 2532) e os recortes da L01b (`i01b.alsoReading`, `i01b.miniBar`,
  `i01b.bottomFade`, `i01b.nav`, faixa y 554,96–844) contra `001b_inicio_lendo_agora_390x844@3x.png` →
  `python3 tools/compare_images.py --flutter <golden> --ref <png> --scale 3 --layout docs/design/medicao/inicio2/layout/layout_001b_inicio_lendo_agora.json --out build/visual_diff/t04`
  → `blur_mismatch_% ≤ 0,5` por recorte (tabela no relatório; lado a lado e heatmap inspecionados).
- [ ] Goldens dos estados (pausado, "1:08:42", capa real) e dos temas (o `brand` muda a barrinha).
- [ ] Desempenho: com a sessão rodando, um tique reconstrói só o tempo, o rótulo e a barrinha
  (`debugOnRebuildDirtyWidget`); a Início e o cartão não reconstroem; uma leitura igual do banco não reconstrói nada
  (o `reconstrucoes_test` da T03 continua). Commit `test(inicio): a 01b inteira contra a prancha — geometria, texto, goldens e desempenho (T04.11 · L01b.6)`.

## T04.12 — Banco, privacidade e integração (D-244)

**Arquivos:** `supabase/tests/database/27_sessao_papel.test.sql`, `test/features/reading_session/paper_timer_privacy_free_test.dart`,
`test/integracao/cronometro_papel_test.dart` (ou `test/integration/`, conforme o padrão da G20).

- [ ] pgTAP: pelo caminho da sincronização (a RPC de lote da G04/G06), uma sessão `timer` e uma posição com
  `{"v":1,"kind":"paper","refPage":120}` do dono → aceitas e lidas de volta intactas; as mesmas de outro usuário e de
  anônimo → negadas pela RLS; `active_seconds` 86 401 → recusada. `supabase test db` verde.
- [ ] Privacidade do Grátis: o interceptador do `privacy_free_test` no fluxo começar → pausar → retomar → encerrar com
  total do catálogo → nenhum pedido de rede.
- [ ] Integração (app inteiro, banco real em memória — `app_com_livro.dart` com um livro de papel em leitura): começar
  no play → pausar → retomar → encerrar com página 120 de 368 → a Início lê do banco: 3 sessões no "Seu dia", os
  minutos somados, o Brás Cubas no herói com "pág. 120 de 368" e "PAPEL", fora do Também lendo; o app fecha com a
  sessão rodando (novo `ProviderScope` sobre o mesmo banco, relógio + 1 h) → "1:08:42"; "Ler agora" com e-book no
  herói abre o leitor e a sessão do papel fica pausada. Commit `test(cronometro): pgTAP, privacidade do Grátis e o fluxo inteiro (T04.12 · D-244)`.

## T04.13 — Verificação e relatório
- [ ] `dart format --set-exit-if-changed lib test`; `flutter analyze` 0; `flutter test` inteira; `supabase test db`.
- [ ] Cobertura (`flutter test --coverage`): `lib/features/reading_session/domain` e `application` ≥ 85 % (meta 100 %
  nas linhas novas); as linhas novas da Início e do shell cobertas.
- [ ] Mutação (fora do git, `tools/medicao/tmp/mut/t04/`): ≥ 20 trocas nas regras novas (R1–R5, D-258, D-260, D-261,
  D-262, R7, o aro, a ordem do shell, a folga) — todas caem; as que passarem ganham teste.
- [ ] Revisão independente (só leitura, do diff da fase) e correção dos achados.
- [ ] gitleaks nos commits da fase e nas pastas tocadas; `git status` limpo.
- [ ] `T04.md`: resultados (tabelas), desvios, pendências (vazias, salvo ambiente); relatório §9 e a frase de parada.
