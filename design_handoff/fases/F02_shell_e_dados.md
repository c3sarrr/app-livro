# FASE 2 — Dados, estado, rotas e esqueleto da tela Início

> Pré-requisito: FASE 1 aprovada.
> Resultado: o app abre na Início com o **ritmo vertical exato** do arquivo (inset superior, 8 seções como blocos vazios com a altura de referência, gaps entre seções, padding inferior), navegação por abas funcionando com placeholders, dados do arquivo modelados e formatados. Nenhum visual de seção ainda.

---

## Anatomia do contêiner (HTML literal)

```html
<div style="position: relative; width: 390px; height: 2390px; overflow: hidden; background: #F7F0E3; box-sizing: border-box;">
  <!-- Scroll content (top inset reserved for the real status bar / Dynamic Island) -->
  <main style="display: flex; flex-direction: column; padding: 62px 20px 140px; box-sizing: border-box;">
    <header …>                      (altura 48)
    <h1 style="margin: 24px 0 0 …"> (margem 24)
    <section Continuar lendo  style="margin-top: 24px …">
    <section Também lendo     style="margin-top: 32px …">
    <section Seu dia          style="margin-top: 36px …">
    <section Para você        style="margin-top: 40px …">
    <section Clube            style="margin-top: 40px …">
    <section Recém-chegados   style="margin-top: 40px …">
  </main>
  <!-- Bottom fade so content slips under the floating nav -->
  <div aria-hidden="true" style="position: absolute; left: 0; right: 0; bottom: 0; height: 150px; background: linear-gradient(to bottom, rgba(247,240,227,0), #F7F0E3 55%); pointer-events: none;"></div>
  <!-- Bottom navigation (fixed in the app; sits above the home-indicator area) -->
  <nav aria-label="Navegação principal" style="position: absolute; left: 16px; right: 16px; bottom: 30px; height: 70px; …">
</div>
```

Ritmo vertical de referência (absoluto no canvas):

| Bloco | y | altura | termina em | gap até o próximo |
|---|---|---|---|---|
| inset superior | 0 | 62 | 62 | — |
| `header` | 62 | 48 | 110 | 24 |
| `headline` | 134 | 90,16 | 224,16 | 24 |
| `hero` | 248,16 | 275 | 523,16 | 32 |
| `alsoReading` | 555,16 | 175,6 | 730,76 | 36 |
| `today` | 766,76 | 400,8 | 1167,56 | 40 |
| `forYou` | 1207,56 | 327 | 1534,56 | 40 |
| `club` | 1574,56 | 266,6 | 1841,16 | 40 |
| `recent` | 1881,16 | 334 | 2215,16 | — |
| padding inferior | 2215,16 | 140 | **2355,16** (altura total do conteúdo) | — |
| `bottomFade` (fixo) | 2240 | 150 | 2390 | — |
| `nav` (fixa) | 2290 | 70 | 2360 | — |

---

## Subfase 2.1 — Domínio (`features/home/domain/models.dart`)

Modele **dados crus** (nada de strings já formatadas, exceto nomes/títulos). Tipos imutáveis (`final`, construtores `const`).

- `enum CoverArt { domCasmurro, mrsDalloway, pridePrejudice, memoriasPostumas, quincasBorba, oCortico, frankenstein, oAlienista, senhora }`
- `Book { id, title, shortTitle?, author, cover }`
- `UserSummary { firstName, initial, unreadNotifications }`
- `ContinueReading { book, chapter, totalChapters, progress, timeLeft (Duration), highlightsCount }`
- `AlsoReadingItem { book, progress }`
- `WeekDayStat { date, minutes, barHeightPx, isToday }`
- `ReadingDay { goalMinutes, readMinutes, streakDays, pagesToday, highlightsToday, week (7), badgeTargetDays }`
- `ForYou { reasonAuthor, items }`
- `ClubParticipant { initial, color }`
- `BookClub { id, namePrefix, nameHighlight, book, untilChapter, shownParticipants, participantsCount, groupProgress, userProgress, userInitial, unreadMessages, nextMeeting (DateTime) }`
- `enum RecentStatus { wantToRead, isNew }` · `RecentItem { book, format, status }`
- `HomeSnapshot { now, user, continueReading, alsoReading, readingDay, forYou, club, recent }`

## Subfase 2.2 — Mock com os dados EXATOS (`features/home/data/home_repository.dart`)

`abstract interface class HomeRepository { HomeSnapshot snapshot(DateTime now); }` e `HomeMockRepository implements HomeRepository` com:

| Campo | Valor |
|---|---|
| agora de referência (D-09) | **domingo, 20/09/2026, 20:00** (coerente com "Boa noite,", semana S T Q Q S S + Hoje, encontro quinta 24/09) |
| usuário | `Marina`, inicial `M`, 2 notificações não lidas |
| continuar lendo | Dom Casmurro — Machado de Assis (`domCasmurro`), cap. 92 de 148, progresso 0,62, faltam 2h10min (estimado), 14 destaques |
| também lendo | Mrs. Dalloway — Virginia Woolf (`mrsDalloway`) 0,34 · Orgulho e Preconceito — Jane Austen (`pridePrejudice`) 0,81 |
| dia de leitura | meta 30 min, lidos 18, sequência 12 dias, 24 páginas, 2 destaques, selo aos 14 dias |
| semana (seg→hoje) | minutos `[32, 45, 30, 22, 38, 55, 18]`, alturas px `[43, 60, 40, 30, 51, 73, 24]` (D-10), hoje = domingo |
| para você | motivo: autor "Machado de Assis"; itens: Memórias Póstumas de Brás Cubas (curto: "Memórias Póstumas"; `memoriasPostumas`), Quincas Borba (`quincasBorba`) — ambos Machado de Assis; O Cortiço — Aluísio Azevedo (`oCortico`) |
| clube | "Leitoras de" + "Capitu", Dom Casmurro, até o cap. 100, participantes exibidos A `#B6ACE4`, J `#ABCF82`, L `#FFC1C6`, total 11, grupo 0,54, você 0,62 (inicial M), 3 mensagens novas, próximo encontro 24/09/2026 20:00 |
| recém-chegados | Frankenstein — Mary Shelley, EPUB, quero ler (`frankenstein`) · O Alienista — Machado de Assis, PDF, quero ler (`oAlienista`) · Senhora — José de Alencar, EPUB, novo (`senhora`) |

## Subfase 2.3 — Formatadores (`features/home/application/formatters.dart`) + testes unitários

Cada função abaixo tem teste que prova a saída **idêntica** ao arquivo:

| Função | Entrada (mock) | Saída exata |
|---|---|---|
| `greeting(now)` | 20:00 | `Boa noite,` (5–11 `Bom dia,`; 12–17 `Boa tarde,`; 18–4 `Boa noite,`) |
| `chapterLabel(92, 148)` | | `Cap. 92 de 148` |
| `percent(0.62)` | | `62%` |
| `durationLabel(130 min, approx: true)` | | `~2h 10min` |
| `durationLabel(240 min)` | soma da semana | `4h 00min` → `4h 00min no total` |
| `remainingGoal(30, 18)` | | trechos `Faltam ` + **`12 min`** + ` para fechar a meta de hoje.` |
| `countLabel(24, 'página', 'páginas')` | | `24 páginas` (idem `2 destaques`, `12 dias`) |
| `badgeHint(12, 14)` | | trechos `Mais ` + **`2 dias`** + ` para o selo de 14 dias` |
| `weekInitials(seg..sáb) + 'Hoje'` | | `S T Q Q S S Hoje` |
| `weekAria(...)` | | `Minutos lidos por dia: segunda 32, terça 45, quarta 30, quinta 22, sexta 38, sábado 55, hoje 18 de 30` |
| `participantsExtra(11, 3)` | | `+8` · aria `11 participantes` |
| `clubSubtitle(...)` | | `Dom Casmurro · até o cap. 100` (ponto médio U+00B7 com espaços) |
| `recentSubtitle(...)` | | `Mary Shelley · EPUB` · `Machado de Assis · PDF` · `José de Alencar · EPUB` |
| `recentStatusLabel` | | `Quero ler` · `Novo` |
| `weekdayShort(24/09/2026)` | | `QUI` · `monthShort` → `SET` · `day` → `24` · `hourLabel(20:00)` → `20h` |
| `meetingAria(...)` | | `Próximo encontro: quinta, 24 de setembro, às 20h` |
| `notificationsAria(2)` | | `Notificações, 2 novas` |
| `highlightsAria(14)` | | `Destaques e notas deste livro (14)` |
| `moreOptionsAria(book)` | | `Mais opções para Frankenstein` (etc.) |
| `messagesAria(3)` | | `3 mensagens novas` |

Abreviações próprias (não use `intl`, que produz "qui." e "set."): semana `SEG TER QUA QUI SEX SÁB DOM`; meses `JAN FEV MAR ABR MAI JUN JUL AGO SET OUT NOV DEZ`.

## Subfase 2.4 — Estado (Riverpod) (`features/home/application/home_providers.dart`)

```dart
final clockProvider = Provider<DateTime Function()>((ref) => () => HomeMockRepository.referenceNow);
final homeRepositoryProvider = Provider<HomeRepository>((ref) => const HomeMockRepository());
final homeSnapshotProvider = Provider<HomeSnapshot>(
    (ref) => ref.watch(homeRepositoryProvider).snapshot(ref.watch(clockProvider)()));

class HomeTheme { const HomeTheme({this.brand = AppColors.lavender, this.weekColor = AppColors.lavender}); final Color brand; final Color weekColor; }
class HomeThemeController extends Notifier<HomeTheme> {
  @override HomeTheme build() => const HomeTheme();
  void setBrand(Color c) { assert(AppColors.brandOptions.contains(c)); state = HomeTheme(brand: c, weekColor: state.weekColor); }
  void setWeekColor(Color c) { assert(AppColors.weekColorOptions.contains(c)); state = HomeTheme(brand: state.brand, weekColor: c); }
}
final homeThemeProvider = NotifierProvider<HomeThemeController, HomeTheme>(HomeThemeController.new);
```
Widgets de seção leem só o recorte de que precisam (`ref.watch(homeSnapshotProvider.select((s) => s.continueReading))`).

## Subfase 2.5 — App, tema mínimo e sistema (`app/app.dart`, `main.dart`)

- `MaterialApp.router(debugShowCheckedModeBanner: false, theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: AppColors.paper, splashFactory: NoSplash.splashFactory, highlightColor: Colors.transparent, hoverColor: Colors.transparent), …)`.
- `builder`: `MediaQuery(data: mq.copyWith(textScaler: TextScaler.noScaling))` (D-05) + `DefaultTextHeightBehavior(textHeightBehavior: TextHeightBehavior(leadingDistribution: TextLeadingDistribution.even))` + `DefaultTextStyle(style: AppFonts.figtree(16, FontWeight.w400))` (corpo do arquivo: Figtree 16/400, cor tinta).
- `main.dart`: `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)`; `setPreferredOrientations([DeviceOrientation.portraitUp])` (D-06); `LicenseRegistry` (F00); `runApp(const ProviderScope(child: App()))`.
- `AnnotatedRegion<SystemUiOverlayStyle>` no shell: status bar transparente, `statusBarIconBrightness: Brightness.dark`, `statusBarBrightness: Brightness.light`, `systemNavigationBarColor: Colors.transparent`, `systemNavigationBarIconBrightness: Brightness.dark`, `systemNavigationBarContrastEnforced: false` (D-13).
- `App.forTests()` = mesmo app com `initialLocation: '/inicio'` (usado nos goldens).

## Subfase 2.6 — Rotas (`app/router.dart`)

- `StatefulShellRoute.indexedStack` com ramos `/inicio`, `/biblioteca`, `/clubes`, `/perfil`; builder → `MainShell(shell: …)`.
- `/scanner` fora do shell (navigator raiz, `fullscreenDialog`), placeholder (D-08).
- Rotas-destino (placeholders, usadas na F12): `/notificacoes`, `/leitor/:bookId`, `/livro/:bookId`, `/livro/:bookId/destaques`, `/para-voce`, `/clube/:clubId/discussao`.
- `/_ds` somente em `kDebugMode` (galeria da F01).
- `PlaceholderScreen(title)`: `ColoredBox(paper)` + `SafeArea` + título centralizado em `AppTextStyles.sectionTitleL` (D-07). Nada além disso.

## Subfase 2.7 — `MainShell` (camadas fixas) e `HomeScreen` (esqueleto)

`MainShell` (ordem de pintura = ordem do HTML):
```dart
Stack(children: [
  Positioned.fill(child: shell),                                                    // conteúdo da aba
  const Positioned(left: 0, right: 0, bottom: 0, height: 150,
      child: IgnorePointer(child: SizedBox.expand(key: ValueKey('bottomFade')))),  // F11 desenha o gradiente
  Positioned(left: 16, right: 16, bottom: navBottom, height: 70,
      child: const SizedBox.expand(key: ValueKey('nav'))),                          // F11 desenha a barra
  // F11: ScannerFab posicionado aqui (acima da barra)
])
```
`navBottom = max(30, MediaQuery.viewPaddingOf(context).bottom − 4)` (D-02).

`HomeScreen`:
```dart
Scaffold(                                   // sem appBar; só fundo + toque na status bar do iOS (ver abaixo)
  backgroundColor: AppColors.paper,
  body: SingleChildScrollView(
    primary: true,
    padding: EdgeInsets.only(top: topInset, bottom: 140),   // topInset = max(62, viewPadding.top + 15)
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _gutter(const _Placeholder('header', 48)),
      const SizedBox(height: 24), _gutter(const _Placeholder('headline', 90.16)),
      const SizedBox(height: 24), _gutter(const _Placeholder('hero', 275)),
      const SizedBox(height: 32), _gutter(const _Placeholder('alsoReading', 175.6)),
      const SizedBox(height: 36), _gutter(const _Placeholder('today', 400.8)),
      const SizedBox(height: 40), _fullBleed('forYou', const _Placeholder(null, 327)), // carrossel vai até as bordas (F08)
      const SizedBox(height: 40), _gutter(const _Placeholder('club', 266.6)),
      const SizedBox(height: 40), _gutter(const _Placeholder('recent', 334)),
    ]),
  ),
)
```
- Por que `Scaffold`: no iOS, "tocar na status bar rola para o topo" é implementado **pelo `Scaffold`** (ele anima o `PrimaryScrollController`); `primary: true` sozinho não faz isso. Sem `appBar`, `drawer` ou `floatingActionButton` — o `Scaffold` não desenha nada além do fundo `#F7F0E3` (o golden não muda). O `MainShell` **não** usa `Scaffold` (evita dois tratadores de status bar).
- `_gutter(child)` = `Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: child)`.
- `_fullBleed(id, child)` = `Stack(children: [Positioned(left: 20, right: 20, top: 0, bottom: 0, child: IgnorePointer(child: SizedBox.expand(key: ValueKey(id)))), child])` — o retângulo da seção "Para você" é 20→370, mas o carrossel ocupa 0→390 (`margin: 4px -20px 0` no CSS). A Key marca o retângulo do CSS sem restringir o carrossel.
- `_Placeholder(id, height)` = `SizedBox(key: id == null ? null : ValueKey(id), height: height)`. **Cada fase de seção substitui o seu placeholder** e o teste de geometria do bloco precisa continuar passando com a altura real.

## Subfase 2.8 — Testes da fase

1. Unitários dos formatadores (tabela 2.3 inteira).
2. Geometria no canvas 390×2390 (`setCanvasView`): ids `header`, `headline`, `hero`, `alsoReading`, `today`, `forYou`, `club`, `recent`, `bottomFade`, `nav` → `expectGeometry`.
3. Viewport 390×844 com `safeTop: 47, safeBottom: 34`: `header.y = 62` e `nav.y = 844 − 30 − 70 = 744` (prova de D-02).
4. Rolagem: no viewport 390×844, o conteúdo rola até o fim (extensão total 2355,16) e a `nav` permanece em y 744.
5. Rotas: tocar programaticamente nas rotas `/biblioteca`, `/clubes`, `/perfil`, `/scanner` abre os placeholders; voltar para `/inicio` preserva o scroll (IndexedStack).
6. Golden do canvas gerado (por enquanto só o fundo). Compare **apenas** o retângulo do inset superior `--rect 0,0,390,56` (no arquivo é só fundo `#F7F0E3`) → `blur_mismatch_% = 0,0` e `raw_mismatch_% = 0,0`. As demais regiões serão comparadas nas fases das seções.

---

## Checklist de aceite da FASE 2

- [ ] 2.1 Modelos imutáveis criados (sem strings formatadas)
- [ ] 2.2 Mock com 100% dos dados da tabela; `referenceNow = 2026-09-20 20:00`
- [ ] 2.3 Formatadores + testes unitários: todas as saídas idênticas à tabela
- [ ] 2.4 Providers (`clock`, `homeRepository`, `homeSnapshot`, `homeTheme`) + testes do `HomeThemeController` (só aceita as opções do arquivo)
- [ ] 2.5 `App` com trava de escala de texto, `DefaultTextHeightBehavior` even, `NoSplash`, sem banner de debug; `main.dart` com edge-to-edge e retrato
- [ ] 2.6 Rotas do shell + `/scanner` + destinos placeholder + `/_ds` (debug)
- [ ] 2.7 `MainShell` com as camadas na ordem do HTML e `navBottom` = max(30, viewPadding.bottom − 4)
- [ ] 2.7 `HomeScreen` = `Scaffold(backgroundColor: paper)` + `SingleChildScrollView(primary: true)` com inset `max(62, viewPadding.top + 15)`, gutters, gaps 24/24/32/36/40/40/40 e padding inferior 140
- [ ] 2.8 Geometria dos 10 blocos no canvas: 10/10 dentro da tolerância
- [ ] 2.8 Viewport 390×844: header em 62 e nav em 744
- [ ] 2.8 Rolagem até 2355,16 com nav fixa
- [ ] 2.8 Navegação entre abas/placeholders e preservação do scroll
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório no modelo do prompt mestre

**Ao concluir: entregue o relatório e PARE.**
`✅ FASE 2 concluída — aguardando sua aprovação para iniciar a FASE 3.`
