# FASE 1 — Design System (tokens, texto exato, pintores e primitivos)

> Pré-requisito: FASE 0 aprovada.
> Resultado: todo o vocabulário visual do arquivo existe em código, testado **isoladamente**, antes de montar qualquer seção. Nenhuma seção da tela é desenhada nesta fase.

Esta fase tem 8 subfases. Cada uma tem testes próprios. Os valores abaixo foram extraídos do HTML (computados pelo navegador) — **copie-os literalmente**.

---

## Subfase 1.1 — Cores (`core/design_system/tokens/app_colors.dart`)

Todas as cores do arquivo (e somente elas). Alphas: `round(a × 255)`.

```dart
import 'dart:ui';

abstract final class AppColors {
  // Base
  static const Color paper = Color(0xFFF7F0E3);       // fundo da tela, entalhes do ticket, texto claro sobre tinta
  static const Color ink = Color(0xFF1A1714);         // texto principal, TODAS as bordas, sombras duras
  static const Color surface = Color(0xFFFFFAF1);     // cartões/botões claros, trilhas
  static const Color inkMuted = Color(0xFF5B544B);    // texto secundário
  static const Color inkPlum = Color(0xFF2F2A40);     // texto secundário sobre o cartão lavanda (autor, tempo restante)
  static const Color inkWarm = Color(0xFF4A4238);     // legenda "de 30 min", texto do selo "Novo"
  // Paleta
  static const Color lavender = Color(0xFFB6ACE4);    // brand padrão e weekColor padrão; capa O Alienista; lua do Frankenstein
  static const Color sun = Color(0xFFFED170);         // avatar, cartão do dia, FAB, sol da capa, arco O Cortiço, badge 14, marcador "M"
  static const Color flame = Color(0xFFFF552E);       // ponto do sino, chama, pino do dial, barra de hoje, capa Memórias, badge 3
  static const Color leaf = Color(0xFFABCF82);        // capa Mrs. Dalloway, avatar J
  static const Color blush = Color(0xFFFFC1C6);       // capa Orgulho, pílula do clube, avatar L, canhoto, progresso do grupo
  static const Color violet = Color(0xFF552CB7);      // capa Dom Casmurro
  static const Color azure = Color(0xFF058CD7);       // capa Quincas Borba
  static const Color emerald = Color(0xFF00995E);     // capa O Cortiço
  static const Color amber = Color(0xFFF2A815);       // mini-capa Senhora
  static const Color ringTrack = Color(0xFFEAE1CF);   // trilho dos anéis de progresso
  static const Color hatch = Color(0xFFEFE6D4);       // listra da hachura
  static const Color hatchToday = Color(0xFFFDE2B2);  // listra da hachura da barra "Hoje"
  static const Color stubLabel = Color(0xFF4A2F33);   // "ENCONTRO"
  static const Color divider = Color(0xFFE9E1D2);     // divisores da lista Recém-chegados
  static const Color tagLavenderBg = Color(0xFFECE7FA);
  static const Color tagLavenderFg = Color(0xFF3B2D86);
  static const Color tagSandBg = Color(0xFFEFE7D7);
  // Translúcidas
  static const Color spine22 = Color(0x38000000);     // rgba(0,0,0,.22) lombada Dom Casmurro
  static const Color spine18 = Color(0x2E000000);     // rgba(0,0,0,.18) lombadas Quincas / Cortiço
  static const Color spine15 = Color(0x26000000);     // rgba(0,0,0,.15) lombadas Mrs. Dalloway / Memórias
  static const Color spine12 = Color(0x1F000000);     // rgba(0,0,0,.12) lombadas Orgulho / O Alienista / Senhora
  static const Color decoRing = Color(0x241A1714);    // rgba(26,23,20,.14) círculos decorativos do cartão do dia
  static const Color chipGlass = Color(0xB3FFFAF1);   // rgba(255,250,241,.7) chips "24 páginas" / "2 destaques"
  static const Color goalLine = Color(0x731A1714);    // tinta com opacity .45 (linha tracejada da meta)
  static const Color dialTick = Color(0x591A1714);    // tinta com opacity .35 (marcações do dial)
  static const Color paperTransparent = Color(0x00F7F0E3); // início do fade inferior
  // Opções de tema do arquivo (props do componente)
  static const List<Color> brandOptions = [Color(0xFFB6ACE4), Color(0xFFFFC1C6), Color(0xFFABCF82), Color(0xFFFED170)];
  static const List<Color> weekColorOptions = [Color(0xFFB6ACE4), Color(0xFFFFB39E), Color(0xFFF2A815), Color(0xFFABCF82)];
}
```
Teste 1.1: um teste que confere cada constante contra a lista acima com `toARGB32()` (protege contra digitação; `.value` é obsoleto).

---

## Subfase 1.2 — Medidas: traços, raios, sombras, espaçamentos

```dart
abstract final class AppStrokes {
  static const double regular = 1.5;   // 173 lados de borda no arquivo
  static const double thin = 1.2;      // chips do dia, trilhos das barras 0–5, mini-capas
  static const double divider = 1.0;   // divisores da lista
}

abstract final class AppShadows {
  static const Offset hard4 = Offset(4, 4);   // hero, cartão do dia
  static const Offset hard3 = Offset(3, 3);   // capa Dom Casmurro
  static const Offset hard2 = Offset(2, 2);   // capas de "Também lendo"
  static const Offset drop4 = Offset(0, 4);   // navegação e FAB
  // SEMPRE BoxShadow(color: AppColors.ink, offset: X, blurRadius: 0, spreadRadius: 0)
}

abstract final class AppRadii {
  static const double pill = 999;          // normaliza para metade do menor lado
  static const double card = 28;           // hero, cartão do dia, ticket, navegação
  static const double cardM = 22;          // cards "Também lendo", cartão da semana
  static const double list = 24;           // lista Recém-chegados
  static const double navItem = 20;        // item ativo da navegação
  static const BorderRadius coverL = BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(10), bottomRight: Radius.circular(10), bottomLeft: Radius.circular(4)); // 104×156 e 116×174
  static const BorderRadius coverS = BorderRadius.only(topLeft: Radius.circular(3), topRight: Radius.circular(7), bottomRight: Radius.circular(7), bottomLeft: Radius.circular(3));  // 54×81 e 44×66
}

abstract final class AppSpacing {
  static const double gutter = 20;         // padding lateral do main
  static const double topInsetMin = 62;    // padding-top do main (ver D-02)
  static const double bottomPadding = 140; // padding-bottom do main
  // margin-top de cada seção, na ordem: headline, hero, também lendo, dia, para você, clube, recém-chegados
  static const List<double> sectionGaps = [24, 24, 32, 36, 40, 40, 40];
  static const double navSide = 16, navBottomMin = 30, navHeight = 70;
}
```

---

## Subfase 1.3 — Tipografia (`app_typography.dart`)

### 1.3.1 Construtores de estilo
```dart
import 'package:flutter/painting.dart';
import 'app_colors.dart';

abstract final class AppFonts {
  /// Instâncias estáticas existentes da Bricolage (optical size = tamanho em px; 11 px usa 12).
  static const Set<int> bricolageOpsz = {12, 18, 20, 22, 24, 26, 34, 42};

  static TextStyle bricolage(double size, {required double height, double letterSpacing = 0, Color color = AppColors.ink}) {
    final opsz = size.round().clamp(12, 96).toInt();
    assert(bricolageOpsz.contains(opsz), 'Sem instância Bricolage opsz $opsz: gere com design_handoff/ferramentas/build_fonts.py');
    return TextStyle(
      fontFamily: 'Bricolage$opsz',
      fontFamilyFallback: ['Bricolage${opsz}Ext', 'Bricolage${opsz}Vi'],
      fontSize: size, fontWeight: FontWeight.w800, height: height, letterSpacing: letterSpacing, color: color,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  /// Figtree: SOMENTE 400/500/600/700. `font-weight: 800` do CSS = 700 (é o que o navegador renderiza — D-14).
  static TextStyle figtree(double size, FontWeight weight, {double height = 1.2, double letterSpacing = 0, Color color = AppColors.ink}) {
    assert(weight.value >= 400 && weight.value <= 700, 'Figtree só existe de 400 a 700');
    return TextStyle(
      fontFamily: 'Figtree', fontFamilyFallback: const ['FigtreeExt'],
      fontSize: size, fontWeight: weight, height: height, letterSpacing: letterSpacing, color: color,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  static TextStyle serif(double size, {required double height, bool italic = false, double letterSpacing = 0, Color color = AppColors.ink}) {
    return TextStyle(
      fontFamily: 'InstrumentSerif', fontFamilyFallback: const ['InstrumentSerifExt'],
      fontSize: size, fontWeight: FontWeight.w400, fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      height: height, letterSpacing: letterSpacing, color: color,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }
}
```
`height` explícito sempre: "normal" do CSS = 1,2 (Figtree/Bricolage: ascender 0,95/0,93 + descender 0,25/0,27, lineGap 0) e 1,3 (Instrument Serif: 0,99 + 0,31).

### 1.3.2 Catálogo completo (46 tokens — cobre 100% dos textos da tela)

| Token (`AppTextStyles.*`) | Família / arquivo | Tamanho | Peso CSS → **renderizado** | Itálico | height | letterSpacing | Cor | Usado em (Keys) |
|---|---|---|---|---|---|---|---|---|
| `displayXL` | Bricolage42 | 42 | 800 | não | 0.98 | -1.4 | `ink` #1A1714 | `headline` (linha 1) |
| `stubDay` | Bricolage42 | 42 | 800 | não | 0.95 | -1.5 | `ink` #1A1714 | `club.stub.day` |
| `dialValue` | Bricolage34 | 34 | 800 | não | 1 | -1 | `ink` #1A1714 | `today.dial.value` |
| `heroPercent` | Bricolage26 | 26 | 800 | não | 1.2 | -0.6 | `ink` #1A1714 | `hero.percent` |
| `heroTitle` | Bricolage24 | 24 | 800 | não | 1.05 | -0.6 | `ink` #1A1714 | `hero.title` |
| `sectionTitleL` | Bricolage24 | 24 | 800 | não | 1.2 | -0.6 | `ink` #1A1714 | `forYou.title`, `recent.title` |
| `clubTitle` | Bricolage22 | 22 | 800 | não | 1 | -0.5 | `ink` #1A1714 | `club.title` (linha 1) |
| `cardTitleM` | Bricolage20 | 20 | 800 | não | 1.2 | -0.4 | `ink` #1A1714 | `today.title` (trecho "Seu dia de ") |
| `sectionTitleS` | Bricolage18 | 18 | 800 | não | 1.2 | -0.3 | `ink` #1A1714 | `alsoReading.title` |
| `avatarInitial` | Bricolage18 | 18 | 800 | não | 1.2 | 0 | `ink` #1A1714 | `header.avatar` |
| `markerInitial` | Bricolage12 | 11 | 800 | não | 1.2 | 0 | `ink` #1A1714 | `club.youMarker` |
| `displaySerifXL` | InstrumentSerif | 50 | 400 | sim | 0.98 | -0.6 | `ink` #1A1714 | `headline` (linha 2) |
| `clubSerif` | InstrumentSerif | 36 | 400 | sim | 0.95 | -0.4 | `ink` #1A1714 | `club.title` (linha 2) |
| `cardSerifM` | InstrumentSerif | 23 | 400 | sim | 1.3 | -0.2 | `ink` #1A1714 | `today.title` (trecho "leitura") |
| `coverTitle26` | InstrumentSerif | 26 | 400 | não | 0.9 | 0 | `surface` #FFFAF1 | `forYou.item2.cover.title`, `forYou.item3.cover.title` |
| `coverTitle22` | InstrumentSerif | 22 | 400 | não | 0.92 | 0 | `sun` #FED170 | `hero.cover.title` |
| `coverTitle19` | InstrumentSerif | 19 | 400 | não | 0.95 | 0 | `ink` #1A1714 | `forYou.item1.cover.title` |
| `coverTitle11` | InstrumentSerif | 11 | 400 | não | 0.95 | 0 | `ink` #1A1714 | `alsoReading.card1.cover.title` |
| `coverTitle9` | InstrumentSerif | 9 | 400 | não | 0.95 | 0 | `ink` #1A1714 | `alsoReading.card2.cover.title` |
| `coverAuthorPaper` | Figtree | 6.5 | 700 | não | 1.2 | 0.91 | `paper` #F7F0E3 | `hero.cover.author` |
| `coverAuthorFlame` | Figtree | 6.5 | 700 | não | 1.2 | 0.91 | `flame` #FF552E | `forYou.item1.cover.author` |
| `coverAuthorSurface` | Figtree | 6.5 | 700 | não | 1.2 | 0.91 | `surface` #FFFAF1 | `forYou.item2.cover.author`, `forYou.item3.cover.author` |
| `stubLabel` | Figtree | 10 | 800 → **700** | não | 1.2 | 1 | `stubLabel` #4A2F33 | `club.stub.label` |
| `avatarCount` | Figtree | 10 | 800 → **700** | não | 1.2 | 0 | `ink` #1A1714 | `club.avatar3` |
| `navLabel` | Figtree | 11 | 600 | não | 1.2 | 0 | `inkMuted` #5B544B | `nav.library.label`, `nav.clubs.label`, `nav.profile.label` |
| `dialCaption` | Figtree | 11 | 700 | não | 1.2 | 0 | `inkWarm` #4A4238 | `today.dial.caption` |
| `weekDay` | Figtree | 11 | 700 | não | 1.2 | 0 | `inkMuted` #5B544B | `today.week.label0`, `today.week.label1`, `today.week.label2`, `today.week.label3`, `today.week.label4`, `today.week.label5` |
| `micro11Bold` | Figtree | 11 | 700/800 → **700** | não | 1.2 | 0 | `ink` #1A1714 | `nav.scanner.label` (CSS 700), `hero.notesButton.badge` (CSS 800), `alsoReading.card1.ring.label` (CSS 800), `alsoReading.card2.ring.label` (CSS 800), `today.week.label6` (CSS 800), `club.avatar0` (CSS 800), `club.avatar1` (CSS 800), `club.avatar2` (CSS 800), `club.cta.badge` (CSS 800), `nav.home.label` (CSS 800) |
| `caption12Plum` | Figtree | 12 | 600 | não | 1.2 | 0 | `inkPlum` #2F2A40 | `hero.timeLeft` |
| `caption12Muted` | Figtree | 12 | 600 | não | 1.2 | 0 | `inkMuted` #5B544B | `today.week.total`, `club.groupLabel` |
| `label12Bold` | Figtree | 12 | 700/800 → **700** | não | 1.2 | 0 | `ink` #1A1714 | `hero.chapterPill` (CSS 700), `today.chip.pages` (CSS 700), `today.chip.highlights` (CSS 700), `club.pill` (CSS 700), `club.youLabel` (CSS 800) |
| `tagLavender` | Figtree | 12 | 700 | não | 1.2 | 0 | `tagLavenderFg` #3B2D86 | `recent.row0.tag`, `recent.row1.tag` |
| `tagSand` | Figtree | 12 | 700 | não | 1.2 | 0 | `inkWarm` #4A4238 | `recent.row2.tag` |
| `count12OnInk` | Figtree | 12 | 800 → **700** | não | 1.2 | 0 | `paper` #F7F0E3 | `alsoReading.count` |
| `stubMeta` | Figtree | 12 | 800 → **700** | não | 1.2 | 0.96 | `ink` #1A1714 | `club.stub.weekday`, `club.stub.month` |
| `body13Muted` | Figtree | 13 | 500 | não | 1.2 | 0 | `inkMuted` #5B544B | `header.greeting`, `alsoReading.card1.author`, `alsoReading.card2.author`, `forYou.item1.author`, `forYou.item2.author`, `forYou.item3.author`, `club.subtitle`, `recent.row0.subtitle`, `recent.row1.subtitle`, `recent.row2.subtitle` |
| `body13Semi` | Figtree | 13 | 600 | não | 1.2 | 0 | `ink` #1A1714 | `forYou.reasonChip`, `today.footer.text` (trechos normais) |
| `body13Bold` | Figtree | 13 | 800 → **700** | não | 1.2 | 0 | `ink` #1A1714 | `today.streakPill`, `today.week.title`, `club.stub.time`, `today.footer.text` (trecho "2 dias") |
| `body14Plum` | Figtree | 14 | 500 | não | 1.2 | 0 | `inkPlum` #2F2A40 | `hero.author` |
| `label14Bold` | Figtree | 14 | 700 | não | 1.2 | 0 | `ink` #1A1714 | `forYou.seeAll`, `recent.libraryLink`, `forYou.item1.title`, `forYou.item2.title`, `forYou.item3.title` |
| `cta14OnInk` | Figtree | 14 | 700 | não | 1.2 | 0 | `paper` #F7F0E3 | `club.cta.label` |
| `goalSentence` | Figtree | 15 | 600 | não | 1.3 | 0 | `ink` #1A1714 | `today.goalText.sentence` (trechos normais) |
| `goalSentenceStrong` | Figtree | 15 | 800 → **700** | não | 1.3 | 0 | `ink` #1A1714 | `today.goalText.sentence` (trecho "12 min") |
| `title15` | Figtree | 15 | 700 | não | 1.2 | 0 | `ink` #1A1714 | `alsoReading.card1.title`, `alsoReading.card2.title`, `recent.row0.title`, `recent.row1.title`, `recent.row2.title` |
| `name16` | Figtree | 16 | 700 | não | 1.2 | -0.1 | `ink` #1A1714 | `header.name` |
| `cta16OnInk` | Figtree | 16 | 700 | não | 1.2 | 0 | `paper` #F7F0E3 | `hero.cta.label` |

Código do catálogo (gerado a partir do arquivo — copie literalmente):
```dart
abstract final class AppTextStyles {
  /// headline
  static final TextStyle displayXL = AppFonts.bricolage(42, height: 0.98, letterSpacing: -1.4);
  /// club.stub.day
  static final TextStyle stubDay = AppFonts.bricolage(42, height: 0.95, letterSpacing: -1.5);
  /// today.dial.value
  static final TextStyle dialValue = AppFonts.bricolage(34, height: 1, letterSpacing: -1);
  /// hero.percent
  static final TextStyle heroPercent = AppFonts.bricolage(26, height: 1.2, letterSpacing: -0.6);
  /// hero.title
  static final TextStyle heroTitle = AppFonts.bricolage(24, height: 1.05, letterSpacing: -0.6);
  /// forYou.title, recent.title
  static final TextStyle sectionTitleL = AppFonts.bricolage(24, height: 1.2, letterSpacing: -0.6);
  /// club.title
  static final TextStyle clubTitle = AppFonts.bricolage(22, height: 1, letterSpacing: -0.5);
  /// today.title
  static final TextStyle cardTitleM = AppFonts.bricolage(20, height: 1.2, letterSpacing: -0.4);
  /// alsoReading.title
  static final TextStyle sectionTitleS = AppFonts.bricolage(18, height: 1.2, letterSpacing: -0.3);
  /// header.avatar
  static final TextStyle avatarInitial = AppFonts.bricolage(18, height: 1.2);
  /// club.youMarker
  static final TextStyle markerInitial = AppFonts.bricolage(11, height: 1.2);
  /// headline
  static final TextStyle displaySerifXL = AppFonts.serif(50, height: 0.98, italic: true, letterSpacing: -0.6);
  /// club.title
  static final TextStyle clubSerif = AppFonts.serif(36, height: 0.95, italic: true, letterSpacing: -0.4);
  /// today.title
  static final TextStyle cardSerifM = AppFonts.serif(23, height: 1.3, italic: true, letterSpacing: -0.2);
  /// forYou.item2.cover.title, forYou.item3.cover.title
  static final TextStyle coverTitle26 = AppFonts.serif(26, height: 0.9, color: AppColors.surface);
  /// hero.cover.title
  static final TextStyle coverTitle22 = AppFonts.serif(22, height: 0.92, color: AppColors.sun);
  /// forYou.item1.cover.title
  static final TextStyle coverTitle19 = AppFonts.serif(19, height: 0.95);
  /// alsoReading.card1.cover.title
  static final TextStyle coverTitle11 = AppFonts.serif(11, height: 0.95);
  /// alsoReading.card2.cover.title
  static final TextStyle coverTitle9 = AppFonts.serif(9, height: 0.95);
  /// hero.cover.author
  static final TextStyle coverAuthorPaper = AppFonts.figtree(6.5, FontWeight.w700, letterSpacing: 0.91, color: AppColors.paper);
  /// forYou.item1.cover.author
  static final TextStyle coverAuthorFlame = AppFonts.figtree(6.5, FontWeight.w700, letterSpacing: 0.91, color: AppColors.flame);
  /// forYou.item2.cover.author, forYou.item3.cover.author
  static final TextStyle coverAuthorSurface = AppFonts.figtree(6.5, FontWeight.w700, letterSpacing: 0.91, color: AppColors.surface);
  /// club.stub.label (CSS 800 → renderizado 700)
  static final TextStyle stubLabel = AppFonts.figtree(10, FontWeight.w700, letterSpacing: 1, color: AppColors.stubLabel);
  /// club.avatar3 (CSS 800 → renderizado 700)
  static final TextStyle avatarCount = AppFonts.figtree(10, FontWeight.w700);
  /// nav.library.label, nav.clubs.label, nav.profile.label
  static final TextStyle navLabel = AppFonts.figtree(11, FontWeight.w600, color: AppColors.inkMuted);
  /// today.dial.caption
  static final TextStyle dialCaption = AppFonts.figtree(11, FontWeight.w700, color: AppColors.inkWarm);
  /// today.week.label0, today.week.label1, today.week.label2, today.week.label3, today.week.label4, today.week.label5
  static final TextStyle weekDay = AppFonts.figtree(11, FontWeight.w700, color: AppColors.inkMuted);
  /// nav.scanner.label, hero.notesButton.badge, alsoReading.card1.ring.label, alsoReading.card2.ring.label, today.week.label6, club.avatar0, club.avatar1, club.avatar2, club.cta.badge, nav.home.label (CSS 700/800 → renderizado 700)
  static final TextStyle micro11Bold = AppFonts.figtree(11, FontWeight.w700);
  /// hero.timeLeft
  static final TextStyle caption12Plum = AppFonts.figtree(12, FontWeight.w600, color: AppColors.inkPlum);
  /// today.week.total, club.groupLabel
  static final TextStyle caption12Muted = AppFonts.figtree(12, FontWeight.w600, color: AppColors.inkMuted);
  /// hero.chapterPill, today.chip.pages, today.chip.highlights, club.pill, club.youLabel (CSS 700/800 → renderizado 700)
  static final TextStyle label12Bold = AppFonts.figtree(12, FontWeight.w700);
  /// recent.row0.tag, recent.row1.tag
  static final TextStyle tagLavender = AppFonts.figtree(12, FontWeight.w700, color: AppColors.tagLavenderFg);
  /// recent.row2.tag
  static final TextStyle tagSand = AppFonts.figtree(12, FontWeight.w700, color: AppColors.inkWarm);
  /// alsoReading.count (CSS 800 → renderizado 700)
  static final TextStyle count12OnInk = AppFonts.figtree(12, FontWeight.w700, color: AppColors.paper);
  /// club.stub.weekday, club.stub.month (CSS 800 → renderizado 700)
  static final TextStyle stubMeta = AppFonts.figtree(12, FontWeight.w700, letterSpacing: 0.96);
  /// header.greeting, alsoReading.card1.author, alsoReading.card2.author, forYou.item1.author, forYou.item2.author, forYou.item3.author, club.subtitle, recent.row0.subtitle, recent.row1.subtitle, recent.row2.subtitle
  static final TextStyle body13Muted = AppFonts.figtree(13, FontWeight.w500, color: AppColors.inkMuted);
  /// forYou.reasonChip, today.footer.text
  static final TextStyle body13Semi = AppFonts.figtree(13, FontWeight.w600);
  /// today.streakPill, today.week.title, club.stub.time, today.footer.text (CSS 800 → renderizado 700)
  static final TextStyle body13Bold = AppFonts.figtree(13, FontWeight.w700);
  /// hero.author
  static final TextStyle body14Plum = AppFonts.figtree(14, FontWeight.w500, color: AppColors.inkPlum);
  /// forYou.seeAll, recent.libraryLink, forYou.item1.title, forYou.item2.title, forYou.item3.title
  static final TextStyle label14Bold = AppFonts.figtree(14, FontWeight.w700);
  /// club.cta.label
  static final TextStyle cta14OnInk = AppFonts.figtree(14, FontWeight.w700, color: AppColors.paper);
  /// today.goalText.sentence
  static final TextStyle goalSentence = AppFonts.figtree(15, FontWeight.w600, height: 1.3);
  /// today.goalText.sentence (CSS 800 → renderizado 700)
  static final TextStyle goalSentenceStrong = AppFonts.figtree(15, FontWeight.w700, height: 1.3);
  /// alsoReading.card1.title, alsoReading.card2.title, recent.row0.title, recent.row1.title, recent.row2.title
  static final TextStyle title15 = AppFonts.figtree(15, FontWeight.w700);
  /// header.name
  static final TextStyle name16 = AppFonts.figtree(16, FontWeight.w700, letterSpacing: -0.1);
  /// hero.cta.label
  static final TextStyle cta16OnInk = AppFonts.figtree(16, FontWeight.w700, color: AppColors.paper);
}
```

### 1.3.3 Teste de prova tipográfica (obrigatório passar)
Para cada linha, faça layout de um `ui.Paragraph` com o estilo (largura infinita) e confira `maxIntrinsicWidth` (±0,10) e `height` (±0,01). Os 4 tokens que só aparecem em textos mistos (`cardTitleM`, `cardSerifM`, `goalSentence`, `goalSentenceStrong`) são provados nas fases F07 (linhas completas).

| Token | Texto de prova | Largura esperada (±0,10) | Altura de 1 linha (±0,01) |
|---|---|---|---|
| `displayXL` | `Continue` | 170.69 | 41.16 |
| `stubDay` | `24` | 48.24 | 39.90 |
| `dialValue` | `18` | 31.86 | 34.00 |
| `heroPercent` | `62%` | 56.46 | 31.20 |
| `heroTitle` | `Dom Casmurro` | 169.03 | 25.20 |
| `sectionTitleL` | `Para você` | 109.35 | 28.80 |
| `clubTitle` | `Leitoras de` | 112.98 | 22.00 |
| `sectionTitleS` | `Também lendo` | 126.54 | 21.60 |
| `avatarInitial` | `M` | 17.06 | 21.60 |
| `markerInitial` | `M` | 10.54 | 13.20 |
| `displaySerifXL` | `sua história.` | 219.65 | 49.00 |
| `clubSerif` | `Capitu` | 86.41 | 34.20 |
| `coverTitle26` | `O Cortiço` | 81.77 | 23.40 |
| `coverTitle22` | `Casmurro` | 74.56 | 20.24 |
| `coverTitle19` | `Póstumas de` | 80.98 | 18.05 |
| `coverTitle11` | `Dalloway` | 34.52 | 10.45 |
| `coverTitle9` | `Preconceito` | 35.46 | 8.55 |
| `coverAuthorPaper` | `MACHADO DE` | 52.96 | 7.80 |
| `coverAuthorFlame` | `MACHADO DE ASSIS` | 78.33 | 7.80 |
| `coverAuthorSurface` | `MACHADO DE ASSIS` | 78.33 | 7.80 |
| `stubLabel` | `ENCONTRO` | 64.63 | 12.00 |
| `avatarCount` | `+8` | 12.44 | 12.00 |
| `navLabel` | `Biblioteca` | 49.80 | 13.20 |
| `dialCaption` | `de 30 min` | 49.84 | 13.20 |
| `weekDay` | `S` | 6.68 | 13.20 |
| `micro11Bold` | `Scanner` | 41.30 | 13.20 |
| `caption12Plum` | `~2h 10min` | 56.96 | 14.40 |
| `caption12Muted` | `4h 00min no total` | 97.72 | 14.40 |
| `label12Bold` | `Cap. 92 de 148` | 81.55 | 14.40 |
| `tagLavender` | `Quero ler` | 51.46 | 14.40 |
| `tagSand` | `Novo` | 29.44 | 14.40 |
| `count12OnInk` | `2` | 6.95 | 14.40 |
| `stubMeta` | `QUI` | 24.26 | 14.40 |
| `body13Muted` | `Boa noite,` | 58.43 | 15.60 |
| `body13Semi` | `Porque você lê Machado de Assis` | 196.28 | 15.60 |
| `body13Bold` | `12 dias` | 40.24 | 15.60 |
| `body14Plum` | `Machado de Assis` | 113.41 | 16.80 |
| `label14Bold` | `Ver tudo` | 55.99 | 16.80 |
| `cta14OnInk` | `Abrir discussão` | 98.63 | 16.80 |
| `title15` | `Mrs. Dalloway` | 95.79 | 18.00 |
| `name16` | `Marina` | 49.51 | 19.20 |
| `cta16OnInk` | `Continuar lendo` | 117.89 | 19.20 |

```dart
// (token, texto, largura esperada, altura de 1 linha) — medidos no HTML original.
final kTypographyProof = <(TextStyle, String, double, double)>[
  (AppTextStyles.displayXL, 'Continue', 170.69, 41.16),
  (AppTextStyles.stubDay, '24', 48.24, 39.9),
  (AppTextStyles.dialValue, '18', 31.86, 34.0),
  (AppTextStyles.heroPercent, '62%', 56.46, 31.2),
  (AppTextStyles.heroTitle, 'Dom Casmurro', 169.03, 25.2),
  (AppTextStyles.sectionTitleL, 'Para você', 109.35, 28.8),
  (AppTextStyles.clubTitle, 'Leitoras de', 112.98, 22.0),
  (AppTextStyles.sectionTitleS, 'Também lendo', 126.54, 21.6),
  (AppTextStyles.avatarInitial, 'M', 17.06, 21.6),
  (AppTextStyles.markerInitial, 'M', 10.54, 13.2),
  (AppTextStyles.displaySerifXL, 'sua história.', 219.65, 49.0),
  (AppTextStyles.clubSerif, 'Capitu', 86.41, 34.2),
  (AppTextStyles.coverTitle26, 'O Cortiço', 81.77, 23.4),
  (AppTextStyles.coverTitle22, 'Casmurro', 74.56, 20.24),
  (AppTextStyles.coverTitle19, 'Póstumas de', 80.98, 18.05),
  (AppTextStyles.coverTitle11, 'Dalloway', 34.52, 10.45),
  (AppTextStyles.coverTitle9, 'Preconceito', 35.46, 8.55),
  (AppTextStyles.coverAuthorPaper, 'MACHADO DE', 52.96, 7.8),
  (AppTextStyles.coverAuthorFlame, 'MACHADO DE ASSIS', 78.33, 7.8),
  (AppTextStyles.coverAuthorSurface, 'MACHADO DE ASSIS', 78.33, 7.8),
  (AppTextStyles.stubLabel, 'ENCONTRO', 64.63, 12.0),
  (AppTextStyles.avatarCount, '+8', 12.44, 12.0),
  (AppTextStyles.navLabel, 'Biblioteca', 49.8, 13.2),
  (AppTextStyles.dialCaption, 'de 30 min', 49.84, 13.2),
  (AppTextStyles.weekDay, 'S', 6.68, 13.2),
  (AppTextStyles.micro11Bold, 'Scanner', 41.3, 13.2),
  (AppTextStyles.caption12Plum, '~2h 10min', 56.96, 14.4),
  (AppTextStyles.caption12Muted, '4h 00min no total', 97.72, 14.4),
  (AppTextStyles.label12Bold, 'Cap. 92 de 148', 81.55, 14.4),
  (AppTextStyles.tagLavender, 'Quero ler', 51.46, 14.4),
  (AppTextStyles.tagSand, 'Novo', 29.44, 14.4),
  (AppTextStyles.count12OnInk, '2', 6.95, 14.4),
  (AppTextStyles.stubMeta, 'QUI', 24.26, 14.4),
  (AppTextStyles.body13Muted, 'Boa noite,', 58.43, 15.6),
  (AppTextStyles.body13Semi, 'Porque você lê Machado de Assis', 196.28, 15.6),
  (AppTextStyles.body13Bold, '12 dias', 40.24, 15.6),
  (AppTextStyles.body14Plum, 'Machado de Assis', 113.41, 16.8),
  (AppTextStyles.label14Bold, 'Ver tudo', 55.99, 16.8),
  (AppTextStyles.cta14OnInk, 'Abrir discussão', 98.63, 16.8),
  (AppTextStyles.title15, 'Mrs. Dalloway', 95.79, 18.0),
  (AppTextStyles.name16, 'Marina', 49.51, 19.2),
  (AppTextStyles.cta16OnInk, 'Continuar lendo', 117.89, 19.2),
];
```
> Convenção de `letterSpacing`: o navegador soma o espaçamento **também após o último caractere** (ex.: `Continue` = avanços − 8 × 1,4) e o `ui.Paragraph` do Flutter faz o mesmo na largura intrínseca — por isso as larguras batem. A única diferença (deslocamento de meia letra na pintura) é tratada pelo `AppText` na 1.4.

---

## Subfase 1.4 — `AppText`: texto com métricas exatas (`core/design_system/text/app_text.dart`)

Por quê: ver prompt mestre 6.4. Primeiro **prove** o problema no seu SDK:

```dart
testWidgets('Text vs AppText (prova do arredondamento)', (tester) async {
  await tester.pumpWidget(Directionality(textDirection: TextDirection.ltr, child: Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Boa noite,', key: const Key('text'), style: AppTextStyles.body13Muted),
      AppText('Boa noite,', key: const Key('app'), style: AppTextStyles.body13Muted),
    ],
  ))));
  final t = tester.getSize(find.byKey(const Key('text')));
  final a = tester.getSize(find.byKey(const Key('app')));
  debugPrint('Text=$t | AppText=$a'); // registre no relatório (historicamente Text = 59.0 × 16.0)
  expect(a.height, moreOrLessEquals(15.6, epsilon: 0.01));
  expect(a.width, moreOrLessEquals(58.43, epsilon: 0.10));
});
```

Implementação de referência (comportamento obrigatório):

> **Correção de letter-spacing do SkParagraph (verificada no código do Skia, `TextLine.cpp`):** o motor de texto do Flutter desloca cada linha **alinhada à esquerda** em **metade do letter-spacing** do primeiro caractere (`fShift += getHalfLetterSpacing()` — comentário "fix for flutter"); em linhas centralizadas/à direita esse deslocamento é sobrescrito pelo alinhamento. O navegador começa a linha em 0. Ex.: "Continue" (ls −1,4) sairia 0,7 px à esquerda. O `RenderAppText` desfaz isso pintando com `dx = −lineMetrics.left` quando o alinhamento é `start` (LTR). A largura intrínseca já inclui o espaçamento após o último caractere (igual ao navegador) — nenhuma outra compensação é necessária.
> Consequência de projeto: **um `AppText` = um estilo de letter-spacing por linha inicial**. Parágrafos com `<br>` cujas linhas têm letter-spacing diferente (título "Continue / sua história." e "Leitoras de / Capitu") viram **uma coluna de `AppText` de linha única** — as alturas de linha somam exatamente o mesmo (41,16 + 49; 22 + 34,2). O `assert` abaixo pega qualquer caso futuro.

```dart
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

typedef AppTextLine = ({String text, double left, double right, double baseline});

/// Texto do design system: largura/altura/baseline EXATAS (sem arredondar), `maxLines` + "…",
/// alinhamento, semântica e correção do deslocamento de meio letter-spacing do SkParagraph.
/// Regras de tamanho = CSS:
/// - largura "tight" imposta → usa-a;
/// - senão: min(largura disponível, largura intrínseca máxima) (shrink-to-fit de item flex);
/// - altura = soma exata das linhas (height × fontSize por linha, distribuição "even").
class AppText extends LeafRenderObjectWidget {
  AppText(String text, {super.key, required TextStyle style, this.maxLines, this.ellipsis = false,
      this.textAlign = TextAlign.start, this.semanticsLabel})
      : span = TextSpan(text: text, style: style);

  const AppText.rich(this.span, {super.key, this.maxLines, this.ellipsis = false,
      this.textAlign = TextAlign.start, this.semanticsLabel});

  final InlineSpan span;
  final int? maxLines;
  final bool ellipsis;
  final TextAlign textAlign;
  final String? semanticsLabel;

  @override
  RenderAppText createRenderObject(BuildContext context) => RenderAppText(
        span: span, maxLines: maxLines, ellipsis: ellipsis, textAlign: textAlign,
        textDirection: Directionality.of(context), semanticsLabel: semanticsLabel);

  @override
  void updateRenderObject(BuildContext context, RenderAppText renderObject) {
    renderObject
      ..span = span
      ..maxLines = maxLines
      ..ellipsis = ellipsis
      ..textAlign = textAlign
      ..textDirection = Directionality.of(context)
      ..semanticsLabel = semanticsLabel;
  }
}

class RenderAppText extends RenderBox {
  RenderAppText({required InlineSpan span, int? maxLines, bool ellipsis = false, TextAlign textAlign = TextAlign.start,
      required TextDirection textDirection, String? semanticsLabel})
      : _span = span, _maxLines = maxLines, _ellipsis = ellipsis, _textAlign = textAlign,
        _textDirection = textDirection, _semanticsLabel = semanticsLabel;

  static const TextHeightBehavior _heightBehavior = TextHeightBehavior(leadingDistribution: TextLeadingDistribution.even);

  InlineSpan _span;
  set span(InlineSpan v) { if (v == _span) return; _span = v; _invalidate(); markNeedsSemanticsUpdate(); }
  int? _maxLines;
  set maxLines(int? v) { if (v == _maxLines) return; _maxLines = v; _invalidate(); }
  bool _ellipsis;
  set ellipsis(bool v) { if (v == _ellipsis) return; _ellipsis = v; _invalidate(); }
  TextAlign _textAlign;
  set textAlign(TextAlign v) { if (v == _textAlign) return; _textAlign = v; _invalidate(); }
  TextDirection _textDirection;
  set textDirection(TextDirection v) { if (v == _textDirection) return; _textDirection = v; _invalidate(); }
  String? _semanticsLabel;
  set semanticsLabel(String? v) { if (v == _semanticsLabel) return; _semanticsLabel = v; markNeedsSemanticsUpdate(); }

  ui.Paragraph? _paragraph;
  double _laidOutWidth = double.nan;
  double _paintWidth = double.nan; // largura de layout escolhida em performLayout (paint/baseline sempre usam esta)

  void _invalidate() {
    _paragraph?.dispose();
    _paragraph = null;
    _laidOutWidth = double.nan;
    markNeedsLayout();
  }

  ui.Paragraph _layoutAt(double width) {
    if (_paragraph == null) {
      final root = _span.style ?? const TextStyle();
      final builder = ui.ParagraphBuilder(root.getParagraphStyle(
        textAlign: _textAlign, textDirection: _textDirection, maxLines: _maxLines,
        ellipsis: _ellipsis ? '…' : null, textHeightBehavior: _heightBehavior));
      _span.build(builder);
      _paragraph = builder.build();
      _laidOutWidth = double.nan;
    }
    if (_laidOutWidth != width) {
      _paragraph!.layout(ui.ParagraphConstraints(width: width));
      _laidOutWidth = width;
    }
    return _paragraph!;
  }

  /// Largura em que o parágrafo deve ser diagramado para as restrições dadas.
  double _layoutWidthFor(BoxConstraints c) {
    final natural = _layoutAt(double.infinity).maxIntrinsicWidth;
    if (c.hasTightWidth) return c.maxWidth;
    // +0,001 evita que o quebrador de linha quebre por arredondamento quando a largura == intrínseca.
    return natural <= c.maxWidth ? natural + 0.001 : c.maxWidth;
  }

  Size _sizeFor(BoxConstraints c) {
    final natural = _layoutAt(double.infinity).maxIntrinsicWidth;
    final width = c.hasTightWidth ? c.maxWidth : math.min(c.maxWidth, natural);
    final p = _layoutAt(_layoutWidthFor(c));
    return c.constrain(Size(width, p.height));
  }

  /// Parágrafo diagramado na largura final (reexecuta o layout do ui.Paragraph se uma medição intrínseca/seca
  /// posterior o tiver diagramado em outra largura).
  ui.Paragraph get _final => _layoutAt(_paintWidth);

  /// Deslocamento que desfaz o "meio letter-spacing" do SkParagraph em linhas alinhadas à esquerda.
  double get _dx {
    final isStart = _textAlign == TextAlign.left ||
        (_textAlign == TextAlign.start && _textDirection == TextDirection.ltr) || _textAlign == TextAlign.justify;
    if (!isStart) return 0;
    final lines = _final.computeLineMetrics();
    if (lines.isEmpty) return 0;
    assert(lines.every((l) => (l.left - lines.first.left).abs() < 0.01),
        'Linhas com letter-spacing inicial diferente: divida em vários AppText (um por linha).');
    return -lines.first.left;
  }

  @override double computeMinIntrinsicWidth(double height) => _layoutAt(double.infinity).minIntrinsicWidth;
  @override double computeMaxIntrinsicWidth(double height) => _layoutAt(double.infinity).maxIntrinsicWidth;
  @override double computeMinIntrinsicHeight(double width) => _layoutAt(width).height;
  @override double computeMaxIntrinsicHeight(double width) => _layoutAt(width).height;
  @override Size computeDryLayout(BoxConstraints constraints) => _sizeFor(constraints);

  @override
  void performLayout() {
    size = _sizeFor(constraints);
    _paintWidth = _layoutWidthFor(constraints);
  }

  // Necessário para Row/Flex com CrossAxisAlignment.baseline em layout "seco" (Flutter ≥ 3.22).
  @override
  double? computeDryBaseline(BoxConstraints constraints, TextBaseline baseline) {
    final p = _layoutAt(_layoutWidthFor(constraints));
    return baseline == TextBaseline.alphabetic ? p.alphabeticBaseline : p.ideographicBaseline;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final p = _final;
    return baseline == TextBaseline.alphabetic ? p.alphabeticBaseline : p.ideographicBaseline;
  }

  @override bool hitTestSelf(Offset position) => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    final p = _final;
    context.canvas.drawParagraph(p, offset.translate(_dx, 0));
  }

  // Igual ao RenderParagraph: NÃO é fronteira semântica. Sob um nó sem explicitChildNodes (link, cabeçalho)
  // o rótulo se funde nele; sob uma seção (explicitChildNodes: true) um AppText solto vira um nó de texto
  // próprio — exatamente como o Text do Flutter.
  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..label = _semanticsLabel ?? _span.toPlainText()
      ..textDirection = _textDirection;
  }

  @visibleForTesting
  bool get debugDidExceedMaxLines => _final.didExceedMaxLines;

  /// Linhas visíveis em coordenadas GLOBAIS (já com a correção _dx): texto (sem espaços finais), início, fim, baseline.
  @visibleForTesting
  List<AppTextLine> debugLines() {
    final p = _final;
    final dx = _dx;
    final text = _span.toPlainText(includeSemanticsLabels: false);
    final metrics = p.computeLineMetrics();
    final buffers = List.generate(metrics.length, (_) => StringBuffer());
    final starts = List<int?>.filled(metrics.length, null);
    for (var i = 0; i < text.length; i++) {
      final line = p.getLineNumberAt(i);
      if (line == null) continue;
      buffers[line].write(text[i]);
      starts[line] ??= i;
    }
    final origin = localToGlobal(Offset.zero);
    final out = <AppTextLine>[];
    for (var l = 0; l < metrics.length; l++) {
      final visible = buffers[l].toString().replaceAll('\n', '').trimRight();
      final s = starts[l] ?? 0;
      final boxes = p.getBoxesForRange(s, s + visible.length);
      final left = boxes.isEmpty ? metrics[l].left : boxes.map((b) => b.left).reduce(math.min);
      final right = boxes.isEmpty ? metrics[l].left + metrics[l].width : boxes.map((b) => b.right).reduce(math.max);
      out.add((text: visible, left: origin.dx + dx + left, right: origin.dx + dx + right, baseline: origin.dy + metrics[l].baseline));
    }
    return out;
  }

  @override
  void dispose() {
    _paragraph?.dispose();
    super.dispose();
  }
}
```

Helper de teste `test/support/text_lines.dart` (usado em todas as fases de seção). Junta as linhas de **todos** os `AppText` sob a Key (ordem vertical) — assim um id cujo texto foi dividido em vários `AppText` (ex.: `headline`) é conferido como um parágrafo só:
```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout.dart';
import 'geometry.dart'; // kRotated
// + import do AppText/RenderAppText do app

void expectTextLines(WidgetTester tester, String id) {
  final ref = kRefLayout[id]!;
  final finder = find.descendant(of: find.byKey(ValueKey<String>(id)), matching: find.byType(AppText), matchRoot: true);
  expect(finder, findsWidgets, reason: '$id: nenhum AppText sob a Key');
  final renders = finder.evaluate().map((e) => e.renderObject! as RenderAppText).toList()
    ..sort((a, b) => a.localToGlobal(Offset.zero).dy.compareTo(b.localToGlobal(Offset.zero).dy));
  final got = [for (final r in renders) ...r.debugLines()];
  if (kEllipsized.contains(id)) {
    expect(renders.single.debugDidExceedMaxLines, isTrue, reason: '$id deve truncar com "…" (${ref.lines.first.text})');
    return;
  }
  expect(got.map((l) => l.text).toList(), ref.lines.map((l) => l.text).toList(), reason: '$id: quebras/strings diferentes');
  // Texto dentro de capa rotacionada: coordenadas globais incluem a rotação → só quebras/strings
  // (posição coberta por expectGeometry/layoutRect e pelo golden).
  if (kRotated.any((c) => id.startsWith('$c.'))) return;
  for (var i = 0; i < got.length; i++) {
    expect(got[i].baseline, moreOrLessEquals(ref.lines[i].baseline, epsilon: 0.5), reason: '$id L${i + 1} baseline');
    expect(got[i].left, moreOrLessEquals(ref.lines[i].left, epsilon: 0.5), reason: '$id L${i + 1} início');
    expect(got[i].right, moreOrLessEquals(ref.lines[i].right, epsilon: 0.5), reason: '$id L${i + 1} fim');
  }
}
```
Testes 1.4 (todos obrigatórios): (a) prova Text × AppText; (b) shrink-wrap: `AppText` dentro de `Row` mede a intrínseca exata; (c) tight: dentro de `SizedBox(width: 138)` com `maxLines: 1, ellipsis: true` e `'Orgulho e Preconceito'` em `title15` → `debugDidExceedMaxLines == true` e o golden isolado mostra `Orgulho e Precon…`; (d) baseline: `Row(crossAxisAlignment: baseline)` com `heroPercent` "62%" e `caption12Plum` "~2h 10min" → topo do segundo texto 12,78 px abaixo do topo do primeiro (valor do arquivo: 143,08 − 130,30); (e) coluna com `AppText('Continue', displayXL)` + `AppText('sua história.', displaySerifXL)` → altura **90,16**, baselines **34,44** e **82,66** a partir do topo; (f) **correção de meio letter-spacing**: `AppText('Continue', displayXL)` em `x = 0` → `debugLines().first.left` = **0,00 ±0,05** (sem a correção daria −0,70) e o mesmo para `stubLabel` "ENCONTRO" (sem a correção +0,50); (g) medição intrínseca após o layout (ex.: dentro de `IntrinsicWidth`) não altera a pintura (golden isolado idêntico).

---

## Subfase 1.5 — Ícones (`app_icons.dart` + `widgets/app_svg.dart`)

```dart
abstract final class AppIcons {
  static const bell = 'assets/icons/ic_bell.svg';                   // 22 — sino
  static const sparkleOutline = 'assets/icons/ic_sparkle_outline.svg'; // 30 — brilho grande do hero
  static const sparkleSolid = 'assets/icons/ic_sparkle_solid.svg';     // 14/16 — brilhos sólidos
  static const bookOpen = 'assets/icons/ic_book_open.svg';           // 20 — CTA "Continuar lendo" (traço #F7F0E3)
  static const highlighter = 'assets/icons/ic_highlighter.svg';      // 22 — botão destaques
  static const flame = 'assets/icons/ic_flame.svg';                  // 17 — sequência
  static const arrowRight = 'assets/icons/ic_arrow_right.svg';       // 18 — "Ver tudo", "Biblioteca" (traço 2)
  static const messageCircle = 'assets/icons/ic_message_circle.svg'; // 18 — "Abrir discussão" (traço #F7F0E3)
  static const moreHorizontal = 'assets/icons/ic_more_horizontal.svg'; // 20 — "mais opções"
  static const navHomeActive = 'assets/icons/ic_nav_home_active.svg'; // 22 — aba Início ativa (preenchimento #FFFAF1)
  static const navLibrary = 'assets/icons/ic_nav_library.svg';       // 22
  static const navScanner = 'assets/icons/ic_nav_scanner.svg';       // 28 (traço 1,9)
  static const navClubs = 'assets/icons/ic_nav_clubs.svg';           // 22
  static const navProfile = 'assets/icons/ic_nav_profile.svg';       // 22
  // D-07 (extrapolados, só quando outra aba estiver ativa)
  static const navHome = 'assets/icons/_extrapolado_ic_nav_home.svg';
  static const navLibraryActive = 'assets/icons/_extrapolado_ic_nav_library_active.svg';
  static const navClubsActive = 'assets/icons/_extrapolado_ic_nav_clubs_active.svg';
  static const navProfileActive = 'assets/icons/_extrapolado_ic_nav_profile_active.svg';
  static const all = [bell, sparkleOutline, sparkleSolid, bookOpen, highlighter, flame, arrowRight, messageCircle,
    moreHorizontal, navHomeActive, navLibrary, navScanner, navClubs, navProfile, navHome, navLibraryActive, navClubsActive, navProfileActive];
}
```
`AppSvg(asset, size: 22)` = `SizedBox.square(dimension: size, child: SvgPicture.asset(asset, width: size, height: size))` — sem `colorFilter` (as cores já estão nos SVGs; o traço escala com o tamanho, como no navegador: 1,8 × 22/24 = 1,65 px). Envolver em `ExcludeSemantics` (ícones são `aria-hidden` ou decorativos).

---

## Subfase 1.6 — Pintores (`core/design_system/painters/`)

### 1.6.1 `HatchPainter` — `repeating-linear-gradient(135deg, A 0 3px, B 3px 7px)`
```dart
class HatchPainter extends CustomPainter {
  const HatchPainter({required this.stripe, this.base = AppColors.surface});
  final Color stripe;
  final Color base;
  static const double _period = 7, _stripe = 3, _k = 0.7071067811865476; // 1/√2

  @override
  void paint(Canvas canvas, Size size) {
    // Origem = canto superior esquerdo da PADDING BOX (dentro da borda). t = (x + y)/√2; listra se (t mod 7) < 3.
    final shader = ui.Gradient.linear(Offset.zero, const Offset(_period * _k, _period * _k),
        [stripe, stripe, base, base], const [0, _stripe / _period, _stripe / _period, 1], TileMode.repeated);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(HatchPainter old) => old.stripe != stripe || old.base != base;
}
```
Teste: pinte 30,742 × 77,6 num `PictureRecorder` (escala 3×), converta com `picture.toImageSync(...)` (ou `toImage` dentro de `tester.runAsync`, senão o teste trava) e amostre pixels sobre a diagonal, onde `t = (x + y)/√2`: ponto (0,707; 0,707) → t = 1 → **listra**; ponto (3,536; 3,536) → t = 5 → **base**; ponto (5,303; 5,303) → t = 7,5 → **listra** (novo período). As listras formam "/" (de baixo-esquerda para cima-direita) — confira o golden isolado contra `secoes/F07_seu_dia@3x.png`.

### 1.6.2 `chromiumDashStarts` + `ChromiumDashPainter` — `border-*: 1.5px dashed`
```dart
/// Traço = 2 × espessura e vão ideal = espessura (Chromium, espessura física ≥ 3 px — telas ≥ 2x).
/// O vão é ajustado para o padrão começar E terminar com traço (StrokeData::SelectBestDashGap, caminho aberto).
List<double> chromiumDashStarts({required double length, required double thickness}) {
  final dash = 2 * thickness, gap = thickness;
  // Chromium: se length <= 2 × traço, desenha linha contínua (não ocorre nesta tela; os casos são 263,6 e 288).
  assert(length > 2 * dash, 'comprimento curto: desenhe uma linha contínua');
  final minDashes = ((length + gap) / (dash + gap)).floorToDouble();
  final maxDashes = minDashes + 1;
  final minGap = minDashes > 1 ? (length - minDashes * dash) / (minDashes - 1) : double.infinity;
  final maxGap = (length - maxDashes * dash) / (maxDashes - 1);
  final useMin = maxGap <= 0 || (minGap - gap).abs() < (maxGap - gap).abs();
  final n = (useMin ? minDashes : maxDashes).toInt();
  final g = useMin ? minGap : maxGap;
  return [for (var i = 0; i < n; i++) i * (dash + g)];
}

class ChromiumDashPainter extends CustomPainter {
  const ChromiumDashPainter({required this.axis, this.thickness = AppStrokes.regular, this.color = AppColors.ink});
  final Axis axis;
  final double thickness;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final length = axis == Axis.horizontal ? size.width : size.height;
    final paint = Paint()..color = color;
    final dash = 2 * thickness;
    for (final s in chromiumDashStarts(length: length, thickness: thickness)) {
      canvas.drawRect(axis == Axis.horizontal ? Rect.fromLTWH(s, 0, dash, thickness) : Rect.fromLTWH(0, s, thickness, dash), paint);
    }
  }

  @override
  bool shouldRepaint(ChromiumDashPainter old) => old.axis != axis || old.thickness != thickness || old.color != color;
}
```
Testes (valores do arquivo): perfuração do ticket `length 263.6` → **59** traços, vão **1,4931**, último traço termina em 263,6; linha da meta `length 288` → **64** traços, vão **1,5238**, termina em 288.

### 1.6.3 `RingProgressPainter` — anel 46×46 de "Também lendo"
```dart
class RingProgressPainter extends CustomPainter {
  const RingProgressPainter({required this.progress}); // 0..1
  final double progress;
  static const double radius = 18, stroke = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawCircle(c, radius, Paint()..style = PaintingStyle.stroke..strokeWidth = stroke..color = AppColors.ringTrack);
    if (progress <= 0) return;
    canvas.drawArc(Rect.fromCircle(center: c, radius: radius), -math.pi / 2, 2 * math.pi * progress.clamp(0.0, 1.0), false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round..color = AppColors.ink);
  }

  @override
  bool shouldRepaint(RingProgressPainter old) => old.progress != progress;
}
```
Equivalência com o SVG do arquivo (`stroke-dasharray="38.5 113.1"` p/ 34% e `"91.6 113.1"` p/ 81%, `rotate(-90)`): diferença de comprimento de arco ≤ 0,05 px.

### 1.6.4 `GoalDialPainter` — dial 112×112 de "Seu dia de leitura"
```dart
class GoalDialPainter extends CustomPainter {
  const GoalDialPainter({required this.progress}); // lidos / meta (18/30 = 0,6)
  final double progress;
  static const Offset _c = Offset(56, 56);

  @override
  void paint(Canvas canvas, Size size) {
    // 1) face r=54: preenchimento surface + traço 1,5 tinta centrado no raio (como SVG)
    canvas.drawCircle(_c, 54, Paint()..color = AppColors.surface);
    canvas.drawCircle(_c, 54, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = AppColors.ink);
    // 2) marcações: r=44, traço 2, dash 1,5 / vão 7,71, início às 3h, sentido horário, cap reto, alpha .35
    const r = 44.0, dash = 1.5, period = 1.5 + 7.71;
    final circumference = 2 * math.pi * r;
    final rect = Rect.fromCircle(center: _c, radius: r);
    final tick = Paint()..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.butt..color = AppColors.dialTick;
    for (var i = 0; i * period < circumference; i++) {
      final s = i * period, e = math.min(s + dash, circumference);
      canvas.drawArc(rect, s / r, (e - s) / r, false, tick);
    }
    // 3) progresso: r=44, traço 10, cap redondo, início no topo, horário
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(rect, -math.pi / 2, sweep, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round..color = AppColors.ink);
    // 4) pino no fim do arco: r=6, flame + traço 1,5 tinta → no arquivo (30,1; 91,6)
    final a = -math.pi / 2 + sweep;
    final knob = _c + Offset(math.cos(a), math.sin(a)) * r;
    canvas.drawCircle(knob, 6, Paint()..color = AppColors.flame);
    canvas.drawCircle(knob, 6, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = AppColors.ink);
  }

  @override
  bool shouldRepaint(GoalDialPainter old) => old.progress != progress;
}
```
Testes: com `progress = 0.6` o centro do pino = (30,137; 91,597) ±0,05; são 31 marcações (a última com 0,16 de comprimento, coberta pelo arco); ordem de pintura face → marcações → arco → pino.
> O SVG do arquivo grava o pino arredondado em `cx="30.1" cy="91.6"`; o valor calculado difere 0,04 px (0,11 px físico em 3×, abaixo de qualquer tolerância). Use o **cálculo** (o pino precisa acompanhar o progresso real) — não "chumbe" as coordenadas.

### 1.6.5 `TopBorderCrescentPainter` — preenchimento das barras da semana
CSS de cada preenchimento: `height: H; background: C; border-top: 1.5px solid #1A1714; border-radius: 999px; box-sizing: border-box`. O raio normaliza para `R = min(W, H)/2` e a borda superior vira uma **meia-lua**: espessura 1,5 no topo, afinando até 0 nas laterais (raio interno vertical = R − 1,5; horizontal = R).
```dart
class TopBorderCrescentPainter extends CustomPainter {
  const TopBorderCrescentPainter({required this.fill, this.border = AppStrokes.regular, this.borderColor = AppColors.ink});
  final Color fill;
  final double border;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2;
    final outer = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(r));
    canvas.drawRRect(outer, Paint()..color = fill);
    final innerTop = Radius.elliptical(r, math.max(0, r - border));
    final inner = RRect.fromLTRBAndCorners(0, border, size.width, size.height,
        topLeft: innerTop, topRight: innerTop, bottomLeft: Radius.circular(r), bottomRight: Radius.circular(r));
    canvas.drawPath(Path.combine(PathOperation.difference, Path()..addRRect(outer), Path()..addRRect(inner)), Paint()..color = borderColor);
  }

  @override
  bool shouldRepaint(TopBorderCrescentPainter old) => old.fill != fill || old.border != border || old.borderColor != borderColor;
}
```
Teste visual isolado: barra 30,742 × 43 (lavanda) e 30,142 × 24 (flame) comparadas com o recorte ampliado das barras (F07).

---

## Subfase 1.7 — Primitivos (`core/design_system/widgets/`)

### `NeoBox` — a caixa CSS completa
```dart
/// = <div> com box-sizing border-box, background, border uniforme, border-radius, box-shadow duro e,
/// opcionalmente, overflow:hidden — recortando os FILHOS na padding box com raio interno (raio − borda).
class NeoBox extends StatelessWidget {
  const NeoBox({super.key, this.width, this.height, this.color, this.border, this.radius = BorderRadius.zero,
      this.shadow, this.padding = EdgeInsets.zero, this.clip = false, this.child});
  final double? width, height;
  final Color? color;
  final BorderSide? border;          // ex.: const BorderSide(width: 1.5, color: AppColors.ink)
  final BorderRadius radius;
  final Offset? shadow;              // AppShadows.*
  final EdgeInsets padding;
  final bool clip;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final bw = border?.width ?? 0;
    Widget? content = child == null ? null : Padding(padding: padding, child: child);
    if (clip && content != null) {
      content = ClipRRect(borderRadius: radius - BorderRadius.circular(bw), child: content); // raios negativos viram 0 no toRRect
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        border: border == null ? null : Border.fromBorderSide(border!),
        boxShadow: shadow == null ? null : [BoxShadow(color: AppColors.ink, offset: shadow!, blurRadius: 0, spreadRadius: 0)],
      ),
      child: content,
    );
  }
}
```
Regras: `width/height` = tamanho **externo** (border-box). O `Container` já recua o filho pela borda. Para elementos **content-box** (ponto do sino, anel da capa, círculos decorativos) passe o tamanho externo já somado (tabela das fases).

### Demais primitivos — assinaturas OBRIGATÓRIAS (as fases seguintes chamam exatamente assim)
```dart
/// Pílula que abraça o conteúdo (raio 999). `border` null = sem borda.
class Pill extends StatelessWidget {
  const Pill({super.key, required this.padding, required this.color, this.border, required this.child});
  final EdgeInsets padding; final Color color; final BorderSide? border; final Widget child;
  @override
  Widget build(BuildContext context) =>
      NeoBox(color: color, border: border, radius: BorderRadius.circular(999), padding: padding, child: child);
}

/// Contador/badge: min-width, altura fixa, padding horizontal, raio 999, texto centralizado.
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.label, required this.style, required this.minWidth, required this.height,
      required this.horizontalPadding, required this.background, this.border});
  final String label; final TextStyle style; final double minWidth, height, horizontalPadding;
  final Color background; final BorderSide? border;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth),
        child: NeoBox(height: height, color: background, border: border, radius: BorderRadius.circular(999),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Center(widthFactor: 1, child: AppText(label, style: style))),
      );
}

/// Botão circular: tamanho d, fundo/borda opcionais, ícone centralizado e camadas sobrepostas (ponto/badge).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.size, required this.icon, this.color, this.border,
      this.overlays = const <Widget>[], this.onTap, required this.semanticsLabel});
  final double size; final Widget icon; final Color? color; final BorderSide? border;
  final List<Widget> overlays;   // Positioned(...) medidos a partir da borda INTERNA (padding box)
  final VoidCallback? onTap; final String semanticsLabel;
  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap, semanticsLabel: semanticsLabel,
        child: NeoBox(width: size, height: size, color: color, border: border, radius: BorderRadius.circular(size / 2),
            child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [icon, ...overlays])),
      );
}

/// D-04: feedback de toque sem ripple. Sempre um nó semântico PRÓPRIO (container) de botão/link:
/// `semanticsLabel` != null → esse rótulo (= aria-label) e os filhos excluídos;
/// `semanticsLabel` == null → os textos dos filhos se fundem no nó (= nome calculado do conteúdo de um <a>).
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.semanticsLabel, this.isLink = false});
  final Widget child; final VoidCallback? onTap; final String? semanticsLabel; final bool isLink;
  static bool feedbackEnabled = true;
  @override
  State<Pressable> createState() => _PressableState();
}
// _PressableState: GestureDetector(behavior: HitTestBehavior.opaque, excludeFromSemantics: true, onTap, onTapDown/Up/Cancel → _down) +
// AnimatedScale(scale: feedbackEnabled && _down ? 0.97 : 1.0, duration: _down ? 90ms : 120ms, curve: Curves.easeOut)
// envolvido em Semantics(container: true, button: !isLink, link: isLink, label: semanticsLabel,
//   excludeSemantics: semanticsLabel != null, onTap: onTap).
// `container: true` é obrigatório: garante um nó próprio em QUALQUER contexto. Dentro de uma seção
// (explicitChildNodes: true, que atravessa os render objects sem semântica) um Semantics anotado já formaria nó,
// mas dentro de um nó sem explicitChildNodes (um link, um cabeçalho, um Semantics(container) qualquer)
// o flag/rótulo do botão se fundiria nesse pai.

/// Barra de progresso em pílula com preenchimento à esquerda.
class StadiumProgressBar extends StatelessWidget {
  const StadiumProgressBar({super.key, this.fillKey, required this.progress, required this.height,
      required this.background, required this.fillColor, this.border = const BorderSide(width: 1.5, color: AppColors.ink)});
  final Key? fillKey; final double progress, height; final Color background, fillColor; final BorderSide border;
  @override
  Widget build(BuildContext context) => NeoBox(
        height: height, color: background, border: border, radius: BorderRadius.circular(999), clip: true,
        child: Align(alignment: Alignment.centerLeft, child: FractionallySizedBox(
            key: fillKey, alignment: Alignment.centerLeft, widthFactor: progress, heightFactor: 1,
            child: DecoratedBox(decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(999))))),
      );
}

/// Ícone SVG do pacote no tamanho de uso (sem colorFilter; cores já estão no arquivo).
class AppSvg extends StatelessWidget {
  const AppSvg(this.asset, {super.key, required this.size});
  final String asset; final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
      child: SizedBox.square(dimension: size, child: SvgPicture.asset(asset, width: size, height: size)));
}
```
Variantes usadas (valores do arquivo): `Pill` capítulo (`5/10`, borda 1,5, `surface`), chips do dia (`5/9`, borda **1,2**, `chipGlass`), clube (`5/10`, borda 1,5, `blush`), motivo (`7 12 7 10`, borda 1,5), hora do canhoto (`4/10`, borda 1,5), selos da lista (`5/10`, **sem borda**). `CountBadge` "14" (min 22, h 22, pad 5, borda 1,5, `sun`), contador "2" (min 22, h 22, pad 7, sem borda, `ink`, texto `paper`), mensagens "3" (min 20, h 20, pad 6, sem borda, `flame`). `CircleIconButton` sino 48 (`surface`, borda 1,5), destaques 54 (`surface`, borda 1,5, overlay badge), mais-opções 44 (sem fundo/borda).

---

## Subfase 1.8 — Galeria do design system (somente debug)

Widget `DesignSystemGallery` (a **rota** `/_ds`, só em `kDebugMode`, é registrada na F02) mostrando: paleta, os 46 estilos com o texto de prova, todos os ícones nos tamanhos de uso, cada pintor e cada primitivo nas variantes acima. Gere golden `test/golden/goldens/ds_galeria@3x.png` para revisão visual no relatório. **Não** faz parte da tela Início.

---

## Checklist de aceite da FASE 1

- [ ] 1.1 `AppColors` com as 32 constantes + 2 listas de opções; teste de constantes verde
- [ ] 1.2 `AppStrokes`, `AppShadows`, `AppRadii`, `AppSpacing` exatamente como acima
- [ ] 1.3 `AppFonts` com asserts (opsz existente; Figtree 400–700)
- [ ] 1.3 Catálogo `AppTextStyles` com os 46 tokens (código literal)
- [ ] 1.3 Prova tipográfica: 42/42 amostras dentro da tolerância (colar saída)
- [ ] 1.4 Prova Text × AppText executada e registrada (valores dos dois)
- [ ] 1.4 `AppText` + `RenderAppText` implementados (tamanho exato, baseline, maxLines/"…", correção de meio letter-spacing, semântica sem fronteira, `debugLines`)
- [ ] 1.4 Testes (b) shrink, (c) reticências "Orgulho e Precon…", (d) baseline 12,78, (e) coluna 90,16 / 34,44 / 82,66, (f) correção de meio letter-spacing, (g) intrínseca não altera pintura — verdes
- [ ] 1.4 `test/support/text_lines.dart` criado
- [ ] 1.5 `AppIcons` (18 caminhos) + `AppSvg`; pré-cache no harness usando `AppIcons.all`
- [ ] 1.6 `HatchPainter` + teste de amostragem de pixels
- [ ] 1.6 `chromiumDashStarts` + testes 263,6 → 59 / 1,4931 e 288 → 64 / 1,5238
- [ ] 1.6 `RingProgressPainter` (34% e 81%) + golden isolado
- [ ] 1.6 `GoalDialPainter` + teste do pino (30,137; 91,597) e 31 marcações
- [ ] 1.6 `TopBorderCrescentPainter` + golden isolado
- [ ] 1.7 `NeoBox` (+ teste: recorte interno com raio − borda; sombra não recortada)
- [ ] 1.7 `Pill`, `CountBadge`, `CircleIconButton`, `Pressable`, `StadiumProgressBar`, `AppSvg` com as assinaturas exatas acima
- [ ] 1.7 Nenhum widget Material de estilo (Card/Chip/InkWell/…) em `core/design_system/`
- [ ] 1.8 `DesignSystemGallery` + golden de revisão anexado (rota registrada na F02)
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório no modelo do prompt mestre

**Ao concluir: entregue o relatório e PARE.**
`✅ FASE 1 concluída — aguardando sua aprovação para iniciar a FASE 2.`
