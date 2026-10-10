import 'package:flutter/painting.dart';

import '../text/app_text.dart' show AppTextUnderline;
import 'app_colors.dart';
import 'reader_fonts.dart';

abstract final class AppFonts {
  /// Instâncias estáticas existentes da Bricolage (optical size = tamanho em px; 11 px usa 12). T02: 14 (63) e 32 (62).
  static const Set<int> bricolageOpsz = {
    12,
    14,
    17,
    18,
    20,
    22,
    23,
    24,
    26,
    32,
    34,
    42,
  };

  /// Instâncias fracionárias (G16: o 15,5 do título da pílula do modo anotação — família `Bricolage15_5`).
  static final Set<double> bricolageFractional = {15.5};

  static TextStyle bricolage(
    double size, {
    required double height,
    double letterSpacing = 0,
    Color color = AppColors.ink,
  }) {
    final String name;
    if (bricolageFractional.contains(size)) {
      name = size.toString().replaceAll('.', '_');
    } else {
      final opsz = size.round().clamp(12, 96).toInt();
      assert(
        bricolageOpsz.contains(opsz),
        'Sem instância Bricolage opsz $opsz: gere com tools/fonts/build_fonts.py',
      );
      name = '$opsz';
    }
    return TextStyle(
      fontFamily: 'Bricolage$name',
      fontFamilyFallback: ['Bricolage${name}Ext', 'Bricolage${name}Vi'],
      fontSize: size,
      fontWeight: FontWeight.w800,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  /// Figtree: SOMENTE 400/500/600/700. `font-weight: 800` do CSS = 700 (é o que o navegador renderiza — D-14).
  static TextStyle figtree(
    double size,
    FontWeight weight, {
    double height = 1.2,
    double letterSpacing = 0,
    Color color = AppColors.ink,
  }) {
    assert(
      weight.value >= 400 && weight.value <= 700,
      'Figtree só existe de 400 a 700',
    );
    return TextStyle(
      fontFamily: 'Figtree',
      fontFamilyFallback: const ['FigtreeExt'],
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  /// Figtree das telas do leitor (19–27b): ali o 800 é real (D-16, L00 — `Figtree-ExtraBold`). A Início continua
  /// com [figtree], até 700 (D-14). O "≈" (que a Figtree não tem) vem da Inter Bold (D-54, `BookNestApprox`).
  static TextStyle figtreeReader(
    double size,
    FontWeight weight, {
    double height = 1.2,
    double letterSpacing = 0,
    Color color = AppColors.ink,
  }) {
    assert(
      weight.value >= 400 && weight.value <= 800,
      'Figtree do leitor só existe de 400 a 800',
    );
    return TextStyle(
      fontFamily: 'Figtree',
      fontFamilyFallback: const ['FigtreeExt', 'BookNestApprox'],
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  /// Literata ESTÁTICA da interface do leitor (D-104: a variável fica só no texto do livro). Uma família por
  /// tamanho (opsz), registrada só com os pesos que existem.
  static final Map<double, Set<int>> literataStatic = {
    15: {400, 500},
    15.5: {400},
    16: {400},
    16.5: {400},
    17: {400, 500},
    18: {400},
    19: {500},
    22: {400},
    25: {500},
    26: {400},
  };

  static TextStyle literata(
    double size,
    FontWeight weight, {
    double? height,
    Color color = AppColors.ink,
  }) {
    assert(
      literataStatic[size]?.contains(weight.value) ?? false,
      'Sem Literata estática $size/${weight.value} registrada no pubspec',
    );
    final name = size == size.roundToDouble()
        ? '${size.round()}'
        : size.toString().replaceAll('.', '_');
    return TextStyle(
      fontFamily: 'Literata$name',
      fontFamilyFallback: ['Literata${name}Ext', 'Literata${name}Vi'],
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  /// A Literata variável do livro num tamanho de interface (G13: o "a" do Sublinhar — 13 do SVG em 20/24, L21b):
  /// `opsz` = [opsz] e `wght` 400 explícitos, como no texto do livro.
  static TextStyle literataBook(
    double opsz, {
    double? size,
    Color color = AppColors.ink,
  }) => TextStyle(
    fontFamily: readerFontFamily,
    fontFamilyFallback: readerFontFallback,
    fontSize: size ?? opsz,
    fontWeight: FontWeight.w400,
    fontVariations: [
      FontVariation('opsz', opsz),
      const FontVariation('wght', 400),
    ],
    color: color,
    height: 1,
  );

  static TextStyle serif(
    double size, {
    required double height,
    bool italic = false,
    double letterSpacing = 0,
    Color color = AppColors.ink,
  }) {
    return TextStyle(
      fontFamily: 'InstrumentSerif',
      fontFamilyFallback: const ['InstrumentSerifExt'],
      fontSize: size,
      fontWeight: FontWeight.w400,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }
}

abstract final class AppTextStyles {
  /// headline
  static final TextStyle displayXL = AppFonts.bricolage(
    42,
    height: 0.98,
    letterSpacing: -1.4,
  );

  /// club.stub.day
  static final TextStyle stubDay = AppFonts.bricolage(
    42,
    height: 0.95,
    letterSpacing: -1.5,
  );

  /// today.dial.value
  static final TextStyle dialValue = AppFonts.bricolage(
    34,
    height: 1,
    letterSpacing: -1,
  );

  /// hero.percent
  static final TextStyle heroPercent = AppFonts.bricolage(
    26,
    height: 1.2,
    letterSpacing: -0.6,
  );

  /// hero.title
  static final TextStyle heroTitle = AppFonts.bricolage(
    24,
    height: 1.05,
    letterSpacing: -0.6,
  );

  /// forYou.title, recent.title
  static final TextStyle sectionTitleL = AppFonts.bricolage(
    24,
    height: 1.2,
    letterSpacing: -0.6,
  );

  /// club.title
  static final TextStyle clubTitle = AppFonts.bricolage(
    22,
    height: 1,
    letterSpacing: -0.5,
  );

  /// today.title
  static final TextStyle cardTitleM = AppFonts.bricolage(
    20,
    height: 1.2,
    letterSpacing: -0.4,
  );

  /// alsoReading.title
  static final TextStyle sectionTitleS = AppFonts.bricolage(
    18,
    height: 1.2,
    letterSpacing: -0.3,
  );

  /// header.avatar
  static final TextStyle avatarInitial = AppFonts.bricolage(18, height: 1.2);

  /// club.youMarker
  static final TextStyle markerInitial = AppFonts.bricolage(11, height: 1.2);

  /// headline
  static final TextStyle displaySerifXL = AppFonts.serif(
    50,
    height: 0.98,
    italic: true,
    letterSpacing: -0.6,
  );

  /// club.title
  static final TextStyle clubSerif = AppFonts.serif(
    36,
    height: 0.95,
    italic: true,
    letterSpacing: -0.4,
  );

  /// today.title
  static final TextStyle cardSerifM = AppFonts.serif(
    23,
    height: 1.3,
    italic: true,
    letterSpacing: -0.2,
  );

  /// forYou.item2.cover.title, forYou.item3.cover.title
  static final TextStyle coverTitle26 = AppFonts.serif(
    26,
    height: 0.9,
    color: AppColors.surface,
  );

  /// hero.cover.title
  static final TextStyle coverTitle22 = AppFonts.serif(
    22,
    height: 0.92,
    color: AppColors.sun,
  );

  /// forYou.item1.cover.title
  static final TextStyle coverTitle19 = AppFonts.serif(19, height: 0.95);

  /// i01.forYou.item1.cover.title ("Esaú / e Jacó"): Instrument Serif 22, `lh 0,95`, tinta.
  static final TextStyle coverTitle22Ink = AppFonts.serif(22, height: 0.95);

  /// alsoReading.card1.cover.title
  static final TextStyle coverTitle11 = AppFonts.serif(11, height: 0.95);

  /// alsoReading.card2.cover.title
  static final TextStyle coverTitle9 = AppFonts.serif(9, height: 0.95);

  /// hero.cover.author
  static final TextStyle coverAuthorPaper = AppFonts.figtree(
    6.5,
    FontWeight.w700,
    letterSpacing: 0.91,
    color: AppColors.paper,
  );

  /// forYou.item1.cover.author
  static final TextStyle coverAuthorFlame = AppFonts.figtree(
    6.5,
    FontWeight.w700,
    letterSpacing: 0.91,
    color: AppColors.flame,
  );

  /// forYou.item2.cover.author, forYou.item3.cover.author
  static final TextStyle coverAuthorSurface = AppFonts.figtree(
    6.5,
    FontWeight.w700,
    letterSpacing: 0.91,
    color: AppColors.surface,
  );

  /// club.stub.label (CSS 800 → renderizado 700)
  static final TextStyle stubLabel = AppFonts.figtree(
    10,
    FontWeight.w700,
    letterSpacing: 1,
    color: AppColors.stubLabel,
  );

  /// club.avatar3 (CSS 800 → renderizado 700)
  static final TextStyle avatarCount = AppFonts.figtree(10, FontWeight.w700);

  /// nav.library.label, nav.clubs.label, nav.profile.label
  static final TextStyle navLabel = AppFonts.figtree(
    11,
    FontWeight.w600,
    color: AppColors.inkMuted,
  );

  /// today.dial.caption
  static final TextStyle dialCaption = AppFonts.figtree(
    11,
    FontWeight.w700,
    color: AppColors.inkWarm,
  );

  /// today.week.label0, today.week.label1, today.week.label2, today.week.label3, today.week.label4, today.week.label5
  static final TextStyle weekDay = AppFonts.figtree(
    11,
    FontWeight.w700,
    color: AppColors.inkMuted,
  );

  /// nav.scanner.label, hero.notesButton.badge, alsoReading.card1.ring.label, alsoReading.card2.ring.label, today.week.label6, club.avatar0, club.avatar1, club.avatar2, club.cta.badge, nav.home.label (CSS 700/800 → renderizado 700)
  static final TextStyle micro11Bold = AppFonts.figtree(11, FontWeight.w700);

  /// hero.timeLeft
  static final TextStyle caption12Plum = AppFonts.figtree(
    12,
    FontWeight.w600,
    color: AppColors.inkPlum,
  );

  /// today.week.total, club.groupLabel
  static final TextStyle caption12Muted = AppFonts.figtree(
    12,
    FontWeight.w600,
    color: AppColors.inkMuted,
  );

  /// hero.pagePill, today.chip.sessions, today.chip.highlights, club.pill, club.youLabel (CSS 700/800 → renderizado 700)
  static final TextStyle label12Bold = AppFonts.figtree(12, FontWeight.w700);

  /// recent.row0.tag, recent.row1.tag
  static final TextStyle tagLavender = AppFonts.figtree(
    12,
    FontWeight.w700,
    color: AppColors.tagLavenderFg,
  );

  /// recent.rowN.tag "Lido" (prancha 01, D-255)
  static final TextStyle tagRead = AppFonts.figtree(
    12,
    FontWeight.w700,
    color: AppColors.tagReadFg,
  );

  /// recent.row2.tag
  static final TextStyle tagSand = AppFonts.figtree(
    12,
    FontWeight.w700,
    color: AppColors.inkWarm,
  );

  /// alsoReading.count (CSS 800 → renderizado 700)
  static final TextStyle count12OnInk = AppFonts.figtree(
    12,
    FontWeight.w700,
    color: AppColors.paper,
  );

  /// club.stub.weekday, club.stub.month (CSS 800 → renderizado 700)
  static final TextStyle stubMeta = AppFonts.figtree(
    12,
    FontWeight.w700,
    letterSpacing: 0.96,
  );

  /// header.greeting, alsoReading.card1.author, alsoReading.card2.author, forYou.item1.author, forYou.item2.author, forYou.item3.author, club.subtitle, recent.row0.subtitle, recent.row1.subtitle, recent.row2.subtitle
  static final TextStyle body13Muted = AppFonts.figtree(
    13,
    FontWeight.w500,
    color: AppColors.inkMuted,
  );

  /// forYou.reasonChip, today.footer.text
  static final TextStyle body13Semi = AppFonts.figtree(13, FontWeight.w600);

  /// today.streakPill, today.week.title, club.stub.time, today.footer.text (CSS 800 → renderizado 700)
  static final TextStyle body13Bold = AppFonts.figtree(13, FontWeight.w700);

  /// hero.author
  static final TextStyle body14Plum = AppFonts.figtree(
    14,
    FontWeight.w500,
    color: AppColors.inkPlum,
  );

  /// forYou.seeAll, recent.libraryLink, forYou.item1.title, forYou.item2.title, forYou.item3.title
  static final TextStyle label14Bold = AppFonts.figtree(14, FontWeight.w700);

  /// club.cta.label
  static final TextStyle cta14OnInk = AppFonts.figtree(
    14,
    FontWeight.w700,
    color: AppColors.paper,
  );

  /// today.goalText.sentence
  static final TextStyle goalSentence = AppFonts.figtree(
    15,
    FontWeight.w600,
    height: 1.3,
  );

  /// today.goalText.sentence (CSS 800 → renderizado 700)
  static final TextStyle goalSentenceStrong = AppFonts.figtree(
    15,
    FontWeight.w700,
    height: 1.3,
  );

  /// alsoReading.card1.title, alsoReading.card2.title, recent.row0.title, recent.row1.title, recent.row2.title
  static final TextStyle title15 = AppFonts.figtree(15, FontWeight.w700);

  /// header.name
  static final TextStyle name16 = AppFonts.figtree(
    16,
    FontWeight.w700,
    letterSpacing: -0.1,
  );

  /// hero.cta.label
  static final TextStyle cta16OnInk = AppFonts.figtree(
    16,
    FontWeight.w700,
    color: AppColors.paper,
  );

  /// r19.footer.pageLabel / r19.footer.percent (L19): `tabular-nums`; a cor muda com o papel
  /// (`ReaderPalette.footer` — D-110).
  static final TextStyle readerFooter = AppFonts.figtreeReader(
    11.5,
    FontWeight.w600,
    color: AppColors.readerFooter,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  // Leitor — controles (telas 20/26b, G12). Cores da Creme; as telas trocam pela paleta do papel.

  /// r20.topIsland.title: Bricolage 17/800, 1,1, −0,3 (nowrap + "…").
  static final TextStyle readerIslandTitle = AppFonts.bricolage(
    17,
    height: 1.1,
    letterSpacing: -0.3,
  );

  /// r20.topIsland.author
  static final TextStyle readerIslandAuthor = AppFonts.figtreeReader(
    12.5,
    FontWeight.w600,
    color: AppColors.inkMuted,
  );

  /// r20.timeChip
  static final TextStyle readerChip = AppFonts.figtreeReader(
    12.5,
    FontWeight.w800,
  );

  /// r20.bottomIsland.scrubber.bubble ("pág. 159")
  static final TextStyle readerBubble = AppFonts.figtreeReader(
    12.5,
    FontWeight.w800,
    color: AppColors.paper,
  );

  /// r20.bottomIsland.progressRow ("62% do livro · 256 pág." e "≈ 2 h 10 min"): `tabular-nums`.
  static final TextStyle readerProgress = AppFonts.figtreeReader(
    12.5,
    FontWeight.w700,
    color: AppColors.inkMuted,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /// r20.bottomIsland.progressRow.position.percent (`strong`)
  static final TextStyle readerProgressStrong = readerProgress.copyWith(
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  /// r20.bottomIsland.tools.* (rótulos)
  static final TextStyle readerToolLabel = AppFonts.figtreeReader(
    12,
    FontWeight.w700,
  );

  /// r20.bottomIsland.tools.font.circle ("Aa"): Literata estática 19/500 (D-104).
  static final TextStyle readerToolAa = AppFonts.literata(19, FontWeight.w500);

  /// r20.bottomIsland.tools.notes.badge
  static final TextStyle readerBadge = AppFonts.figtreeReader(
    11,
    FontWeight.w800,
  );

  /// Pílulas do leitor ("Voltar à pág. N" — D-108; "Chega numa próxima fase" — D-118).
  static final TextStyle readerPill = AppFonts.figtreeReader(
    12.5,
    FontWeight.w800,
  );

  /// Busca no livro (D-120, sem desenho — D-23: só os primitivos do leitor).
  static final TextStyle readerSearchField = AppFonts.figtreeReader(
    16,
    FontWeight.w500,
  );
  static final TextStyle readerSearchCount = AppFonts.figtreeReader(
    12.5,
    FontWeight.w700,
    color: AppColors.inkMuted,
  );
  static final TextStyle readerSearchGroup = AppFonts.figtreeReader(
    11.5,
    FontWeight.w800,
    color: AppColors.inkMuted,
  );
  static final TextStyle readerSearchPage = AppFonts.figtreeReader(
    12,
    FontWeight.w700,
    color: AppColors.readerFooter,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /// r21.toolbar.colors.label "GRIFAR" e o título da folha da nota: Figtree 11/800, ls 1,2, `line-height: 1`.
  static final TextStyle readerToolbarLabel = AppFonts.figtreeReader(
    11,
    FontWeight.w800,
    height: 1,
    letterSpacing: 1.2,
    color: AppColors.labelReader,
  );

  /// r21.toolbar.actions.*: Figtree 11,5/800 (altura normal do botão — 13,81).
  static final TextStyle readerToolbarAction = AppFonts.figtreeReader(
    11.5,
    FontWeight.w800,
  );

  /// Folha da nota (D-131, extrapolada): o campo e os botões.
  static final TextStyle readerNoteField = AppFonts.figtreeReader(
    15,
    FontWeight.w500,
    height: 1.35,
  );
  static final TextStyle readerNoteButton = AppFonts.figtreeReader(
    14,
    FontWeight.w800,
  );

  static final TextStyle readerSearchExcerpt = AppFonts.literata(
    17,
    FontWeight.w400,
    height: 1.45,
    color: AppColors.bookText,
  );

  // Leitor — folha de ajustes (tela 26, G14). Cores da Creme; a folha troca pela paleta das ilhas.

  /// rs.sheet.title: "Ajustes" Bricolage 23/800 (ls −0,5) + "de leitura" Instrument Serif itálico 28 (ls −0,2), nas
  /// alturas normais das fontes (1,2 e 1,3: a linha tem 36,4).
  static final TextStyle readerSheetTitle = AppFonts.bricolage(
    23,
    height: 1.2,
    letterSpacing: -0.5,
  );
  static final TextStyle readerSheetTitleSerif = AppFonts.serif(
    28,
    height: 1.3,
    italic: true,
    letterSpacing: -0.2,
  );

  /// rs.sheet.size.smaller/larger: Literata estática 15/500 e 25/500 (D-104), altura normal.
  static final TextStyle readerSheetSmallA = AppFonts.literata(
    15,
    FontWeight.w500,
  );
  static final TextStyle readerSheetLargeA = AppFonts.literata(
    25,
    FontWeight.w500,
  );

  /// "FONTE", "PAPEL", "ENTRELINHA", "MARGENS": Figtree 11/800, ls 1,2, altura normal.
  static final TextStyle readerSheetLabel = AppFonts.figtreeReader(
    11,
    FontWeight.w800,
    letterSpacing: 1.2,
    color: AppColors.labelReader,
  );

  /// O "Aa" de cada cartão de fonte, na própria fonte, 26 com `line-height: 1.1`: a Literata estática (D-104); Lora
  /// e Atkinson as do livro (D-18); a Figtree a da interface (é a mesma letra).
  static final TextStyle readerSheetSampleLiterata = AppFonts.literata(
    26,
    FontWeight.w400,
    height: 1.1,
  );
  static const TextStyle readerSheetSampleLora = TextStyle(
    fontFamily: readerLoraFamily,
    fontSize: 26,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
    height: 1.1,
    color: AppColors.ink,
    leadingDistribution: TextLeadingDistribution.even,
  );
  static final TextStyle readerSheetSampleFigtree = AppFonts.figtreeReader(
    26,
    FontWeight.w400,
    height: 1.1,
  );
  static const TextStyle readerSheetSampleAtkinson = TextStyle(
    fontFamily: readerAtkinsonFamily,
    fontSize: 26,
    fontWeight: FontWeight.w400,
    height: 1.1,
    color: AppColors.ink,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// rs.sheet.fonts.*.name (12/800) e .caption (10,5/600).
  static final TextStyle readerSheetFontName = AppFonts.figtreeReader(
    12,
    FontWeight.w800,
  );
  static final TextStyle readerSheetCaption = AppFonts.figtreeReader(
    10.5,
    FontWeight.w600,
    color: AppColors.inkSoft,
  );

  /// O "Aa" do cartão de papel: Literata estática 18, `line-height: 1`.
  static final TextStyle readerSheetPaperSample = AppFonts.literata(
    18,
    FontWeight.w400,
    height: 1,
  );

  /// Nome do papel: 12/700; o escolhido, 12/800.
  static final TextStyle readerSheetPaperName = AppFonts.figtreeReader(
    12,
    FontWeight.w700,
  );
  static final TextStyle readerSheetPaperNameOn = AppFonts.figtreeReader(
    12,
    FontWeight.w800,
  );

  /// Opção da Entrelinha e das Margens: 13/700; a escolhida, 13/800.
  static final TextStyle readerSheetOption = AppFonts.figtreeReader(
    13,
    FontWeight.w700,
  );
  static final TextStyle readerSheetOptionOn = AppFonts.figtreeReader(
    13,
    FontWeight.w800,
  );

  /// A pílula "prévia ao vivo": Figtree 11,5/800.
  static final TextStyle readerSheetPill = AppFonts.figtreeReader(
    11.5,
    FontWeight.w800,
  );

  // ---- G15 · telas 27 e 27b (folha do sumário) -------------------------------------------------------------------

  /// "Sumário": Bricolage 26/800, ls −0,6, `line-height: 1`.
  static final TextStyle readerTocTitle = AppFonts.bricolage(
    26,
    height: 1,
    letterSpacing: -0.6,
  );

  /// "Dom Casmurro · 148 capítulos": Figtree 13/600 `#5B544B`.
  static final TextStyle readerTocSubtitle = AppFonts.figtreeReader(
    13,
    FontWeight.w600,
    color: AppColors.inkMuted,
  );

  /// As abas: a ativa 14/800, a outra 14/700; a contagem 14/700 (`#3B3466` na ativa, `#8A8073` na outra).
  static final TextStyle readerTocTab = AppFonts.figtreeReader(
    14,
    FontWeight.w700,
  );
  static final TextStyle readerTocTabOn = AppFonts.figtreeReader(
    14,
    FontWeight.w800,
  );
  static final TextStyle readerTocTabCount = AppFonts.figtreeReader(
    14,
    FontWeight.w700,
    color: AppColors.captionOnBrand,
  );

  /// A faixa do clube: "LEITORAS DE CAPITU · QUI 24/9" 11/800 ls 0,8 `#5B3A3E`; a meta 15/800.
  static final TextStyle readerTocClubKicker = AppFonts.figtreeReader(
    11,
    FontWeight.w800,
    letterSpacing: 0.8,
    color: AppColors.clubKicker,
  );
  static final TextStyle readerTocClubGoal = AppFonts.figtreeReader(
    15,
    FontWeight.w800,
  );

  /// O numeral: 12/800 ls 0,5 `#8A8073` (no atual, `#1A1714`).
  static final TextStyle readerTocNumeral = AppFonts.figtreeReader(
    12,
    FontWeight.w800,
    letterSpacing: 0.5,
    color: AppColors.inkSoft,
  );

  /// O título do capítulo: Literata estática 16, `line-height: 1.25` (D-104); o atual, 17/500.
  static final TextStyle readerTocChapter = AppFonts.literata(
    16,
    FontWeight.w400,
    height: 1.25,
  );
  static final TextStyle readerTocChapterCurrent = AppFonts.literata(
    17,
    FontWeight.w500,
    height: 1.25,
  );

  /// A página de início: 13/700 `#6F665B`, `tabular-nums`; no atual, 13/800 na tinta.
  static final TextStyle readerTocPage = AppFonts.figtreeReader(
    13,
    FontWeight.w700,
    color: AppColors.labelReader,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
  static final TextStyle readerTocPageCurrent = AppFonts.figtreeReader(
    13,
    FontWeight.w800,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /// O número das marcas: 11,5/800 `#6F665B`.
  static final TextStyle readerTocMarks = AppFonts.figtreeReader(
    11.5,
    FontWeight.w800,
    color: AppColors.labelReader,
  );

  /// "você está na pág. 159": 11,5/800.
  static final TextStyle readerTocHere = AppFonts.figtreeReader(
    11.5,
    FontWeight.w800,
  );

  /// A parte (D-153, versão mínima — D-21): 11/800 em maiúsculas, ls 0,8, `#8A8073`.
  static final TextStyle readerTocPart = AppFonts.figtreeReader(
    11,
    FontWeight.w800,
    letterSpacing: 0.8,
    color: AppColors.inkSoft,
  );

  /// "Este livro não tem sumário." (D-21): 14/600 `#6F665B`.
  static final TextStyle readerTocEmpty = AppFonts.figtreeReader(
    14,
    FontWeight.w600,
    color: AppColors.labelReader,
  );

  /// Marcadas: "pág. 3" 12,5/800 `tabular-nums`; "cap. I · Do título" 12/700 `#6F665B`; "você está aqui" 11/800.
  static final TextStyle readerBmPage = AppFonts.figtreeReader(
    12.5,
    FontWeight.w800,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
  static final TextStyle readerBmChapter = AppFonts.figtreeReader(
    12,
    FontWeight.w700,
    color: AppColors.labelReader,
  );
  static final TextStyle readerBmHere = AppFonts.figtreeReader(
    11,
    FontWeight.w800,
  );

  /// O excerto (D-49): Literata estática 15,5, `line-height: 1.5`, `#4A4238`.
  static final TextStyle readerBmExcerpt = AppFonts.literata(
    15.5,
    FontWeight.w400,
    height: 1.5,
    color: AppColors.inkWarm,
  );

  /// "marcada em 2 set": 11,5/700 `#8A8073`.
  static final TextStyle readerBmDate = AppFonts.figtreeReader(
    11.5,
    FontWeight.w700,
    color: AppColors.inkSoft,
  );

  /// A dica no fim: 13/600, `line-height: 1.45`, `#6F665B`.
  static final TextStyle readerBmHint = AppFonts.figtreeReader(
    13,
    FontWeight.w600,
    height: 1.45,
    color: AppColors.labelReader,
  );

  // Leitor — modo anotação (tela 22, G16). Cores da Creme; o Noite troca pela paleta (D-167 17).

  /// ann.modePill.title: Bricolage 15,5/800, 1,1, −0,2.
  static final TextStyle annModeTitle = AppFonts.bricolage(
    15.5,
    height: 1.1,
    letterSpacing: -0.2,
  );

  /// ann.modePill.subtitle: Figtree 11,5/600 `#5B544B`.
  static final TextStyle annModeSubtitle = AppFonts.figtreeReader(
    11.5,
    FontWeight.w600,
    color: AppColors.inkMuted,
  );

  /// ann.done ("Concluir"): Figtree 15/800.
  static final TextStyle annDone = AppFonts.figtreeReader(15, FontWeight.w800);

  /// ann.island.labels.*: Figtree 10/700 `#6F665B`.
  static final TextStyle annLabel = AppFonts.figtreeReader(
    10,
    FontWeight.w700,
    color: AppColors.labelReader,
  );

  /// ann.island.labels.*.pill (a ferramenta ativa, na pílula `brand`): Figtree 10/800.
  static final TextStyle annLabelActive = AppFonts.figtreeReader(
    10,
    FontWeight.w800,
  );

  // Leitor — painéis da caneta e do marca-texto (telas 23 e 23b, G17). Cores da Creme; o Noite troca pela paleta
  // (R26).

  /// ann.penPanel.title / ann.markerPanel.title ("Caneta", "Marca-texto"): Bricolage 22/800, 1,05, −0,4.
  static final TextStyle annPanelTitle = AppFonts.bricolage(
    22,
    height: 1.05,
    letterSpacing: -0.4,
  );

  /// ann.penPanel.subtitle ("Esferográfica · 1,2 mm · coral"): Figtree 12,5/600 `#5B544B`.
  static final TextStyle annPanelSubtitle = AppFonts.figtreeReader(
    12.5,
    FontWeight.w600,
    color: AppColors.inkMuted,
  );

  /// Os nomes dos cartões dos painéis ("Esferográfica", "Fundo"): Figtree 12/800.
  static final TextStyle annPanelOption = AppFonts.figtreeReader(
    12,
    FontWeight.w800,
  );

  /// ann.penPanel.sizeHeader.value ("1,2 mm"): Figtree 13/800, algarismos de largura fixa.
  static final TextStyle annPanelValue = AppFonts.figtreeReader(
    13,
    FontWeight.w800,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /// ann.markerPanel.preview: a frase da página em Literata 17, `line-height: 1.5`, `#2A2520` (D-171).
  static final TextStyle annMarkerPreview = AppFonts.literata(
    17,
    FontWeight.w400,
    height: 1.5,
    color: AppColors.bookText,
  );

  /// ann.markerPanel.styles.*.sample ("ressaca"): Literata 16, `line-height: 1.2`, `#2A2520`.
  static final TextStyle annMarkerSample = AppFonts.literata(
    16,
    FontWeight.w400,
    height: 1.2,
    color: AppColors.bookText,
  );

  /// ann.markerPanel.colors.*.label (o rótulo ou o nome da cor): Figtree 13,5/800, 1,15.
  static final TextStyle annColorLabel = AppFonts.figtreeReader(
    13.5,
    FontWeight.w800,
    height: 1.15,
  );

  /// ann.markerPanel.colors.*.count ("5 grifos"): Figtree 11/600 `#8A8073`.
  static final TextStyle annColorCount = AppFonts.figtreeReader(
    11,
    FontWeight.w600,
    color: AppColors.inkSoft,
  );

  /// ann.markerPanel.colorsHeader.editLabels ("Editar rótulos"): Figtree 12,5/800, sublinhado pelo
  /// [annPanelLinkUnderline] (T01: `text-underline-offset: 3px`, a espessura auto do Chromium, 12,5 ÷ 10).
  static final TextStyle annPanelLink = AppFonts.figtreeReader(
    12.5,
    FontWeight.w800,
  );
  static const AppTextUnderline annPanelLinkUnderline = AppTextUnderline(
    offset: 3,
    thickness: 1.25,
  );

  /// ann.markerPanel.heights.* ("Baixa", "Média", "Alta"): Figtree 13/600 `#5B544B`; a marcada, 13/800.
  static final TextStyle annHeightOption = AppFonts.figtreeReader(
    13,
    FontWeight.w600,
    color: AppColors.inkMuted,
  );
  static final TextStyle annHeightOptionActive = AppFonts.figtreeReader(
    13,
    FontWeight.w800,
  );

  /// ann.markerPanel.tip.text: Figtree 12,5/600, 1,35, `#3D3830`; o começo em negrito na tinta.
  static final TextStyle annTip = AppFonts.figtreeReader(
    12.5,
    FontWeight.w600,
    height: 1.35,
    color: AppColors.tipText,
  );
  static final TextStyle annTipStrong = AppFonts.figtreeReader(
    12.5,
    FontWeight.w800,
    height: 1.35,
  );

  // Leitor — o Espaço e a nota à mão (telas 24 e 24b, G18).

  /// ann.page.spaceOpener.sizeChip ("3 linhas"): Figtree 12,5/800 `#F7F0E3`.
  static final TextStyle annOpenerChip = AppFonts.figtreeReader(
    12.5,
    FontWeight.w800,
    color: AppColors.paper,
  );

  /// ann.page.handNote.tag ("Nota à mão"): Figtree 11,5/800 na tinta.
  static final TextStyle annNoteTag = AppFonts.figtreeReader(
    11.5,
    FontWeight.w800,
  );

  /// ann.page.handNote.hint ("puxe a alça para aumentar"): Figtree 11/700 `#A89D8B`.
  static final TextStyle annNoteHint = AppFonts.figtreeReader(
    11,
    FontWeight.w700,
    color: AppColors.readerFooter,
  );

  /// ann.penPanel.picker.hex.value ("#FF552E"): Figtree 15/800, 0,6, algarismos de largura fixa.
  static final TextStyle annHexValue = AppFonts.figtreeReader(
    15,
    FontWeight.w800,
    letterSpacing: 0.6,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  // Grifos e notas (tela 25, G19).

  /// hl.topBar.export ("Exportar"): Figtree 14/800.
  static final TextStyle hlExport = AppFonts.figtreeReader(14, FontWeight.w800);

  /// hl.title ("Grifos"): Bricolage 34/800, lh 0,98, ls −1.
  static final TextStyle hlTitle = AppFonts.bricolage(
    34,
    height: 0.98,
    letterSpacing: -1,
  );

  /// hl.title.serif ("e notas"): Instrument Serif itálico 42, ls −0,4 (lh 0,98 do título).
  static final TextStyle hlTitleSerif = AppFonts.serif(
    42,
    height: 0.98,
    italic: true,
    letterSpacing: -0.4,
  );

  /// hl.subtitle ("· na ordem do livro"): Figtree 14/600 `#5B544B`.
  static final TextStyle hlSubtitle = AppFonts.figtreeReader(
    14,
    FontWeight.w600,
    color: AppColors.inkMuted,
  );

  /// hl.subtitle.strong ("Dom Casmurro"): Figtree 14/800 na tinta.
  static final TextStyle hlSubtitleStrong = AppFonts.figtreeReader(
    14,
    FontWeight.w800,
  );

  /// hl.search.input: Figtree 15/600 na tinta; o texto de exemplo em `#757575` (o padrão do Chromium).
  static final TextStyle hlSearch = AppFonts.figtreeReader(15, FontWeight.w600);
  static final TextStyle hlSearchPlaceholder = AppFonts.figtreeReader(
    15,
    FontWeight.w600,
    color: AppColors.placeholder,
  );

  /// hl.types.* ("Tudo"): Figtree 13,5/800; o número, 700 (`#8A8073`; no ativo, na tinta).
  static final TextStyle hlChip = AppFonts.figtreeReader(13.5, FontWeight.w800);
  static final TextStyle hlChipCount = AppFonts.figtreeReader(
    13.5,
    FontWeight.w700,
    color: AppColors.inkSoft,
  );

  /// hl.filters.colors.label ("COR"): Figtree 11/800, ls 1, `#6F665B`.
  static final TextStyle hlColorLabel = AppFonts.figtreeReader(
    11,
    FontWeight.w800,
    letterSpacing: 1,
    color: AppColors.labelReader,
  );

  /// hl.filters.clubOnly ("Só do clube"): Figtree 13/800.
  static final TextStyle hlClubOnly = AppFonts.figtreeReader(
    13,
    FontWeight.w800,
  );

  /// hl.list.sep*.label ("pág. 3"): Figtree 12,5/800, algarismos de largura fixa.
  static final TextStyle hlSep = AppFonts.figtreeReader(
    12.5,
    FontWeight.w800,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /// hl.list.sepHere ("pág. 159 · você parou aqui", pílula coral): Figtree
  /// 12,5/800 sem algarismos tabulares — a pílula não usa `tnum` no arquivo.
  static final TextStyle hlSepHere = AppFonts.figtreeReader(
    12.5,
    FontWeight.w800,
  );

  /// hl.list.card*.head.* ("GRIFO", "NOTA", "2 DESENHOS"): Figtree 10,5/800, ls 0,9.
  static final TextStyle hlPill = AppFonts.figtreeReader(
    10.5,
    FontWeight.w800,
    letterSpacing: 0.9,
  );

  /// hl.list.card*.head.date ("2 set", "hoje"): Figtree 12/700 `#8A8073`.
  static final TextStyle hlDate = AppFonts.figtreeReader(
    12,
    FontWeight.w700,
    color: AppColors.inkSoft,
  );

  /// hl.list.card*.body.quote: Literata 16,5, lh 1,6, `#2A2520` (D-104); o contexto e o resto, `#8A8073`.
  static final TextStyle hlQuote = AppFonts.literata(
    16.5,
    FontWeight.w400,
    height: 1.6,
    color: AppColors.bookText,
  );
  static final TextStyle hlQuoteMuted = hlQuote.copyWith(
    color: AppColors.inkSoft,
  );

  /// hl.list.card*.body.note.label ("NOTA"): Figtree 10,5/800, ls 1, `#5B4A1C`.
  static final TextStyle hlNoteLabel = AppFonts.figtreeReader(
    10.5,
    FontWeight.w800,
    letterSpacing: 1,
    color: AppColors.noteLabel,
  );

  /// hl.list.card*.body.note.text: Figtree 14,5/700, lh 1,4.
  static final TextStyle hlNoteText = AppFonts.figtreeReader(
    14.5,
    FontWeight.w700,
    height: 1.4,
  );

  /// hl.list.card*.body.club.chip ("Leitoras de Capitu"): Figtree 12,5/800; "· 3 respostas", 700 `#5B3A3E`.
  static final TextStyle hlClub = AppFonts.figtreeReader(12.5, FontWeight.w800);
  static final TextStyle hlClubReplies = AppFonts.figtreeReader(
    12.5,
    FontWeight.w700,
    color: AppColors.clubKicker,
  );

  /// hl.list.card*.body.handNote.tag ("Nota à mão"): Figtree 10,5/800.
  static final TextStyle hlHandTag = AppFonts.figtreeReader(
    10.5,
    FontWeight.w800,
  );

  /// hl.end.text: Instrument Serif itálico 22, lh 1,15.
  static final TextStyle hlEnd = AppFonts.serif(22, height: 1.15, italic: true);

  /// hl.end.cta ("Continuar lendo · pág. 159"): Figtree 15,5/800 `#F7F0E3`.
  static final TextStyle hlEndCta = AppFonts.figtreeReader(
    15.5,
    FontWeight.w800,
    color: AppColors.paper,
  );

  // ---- T03 · a Início nova (prancha 01) ---------------------------------------------------------------------------

  /// i01.hero.formatPill ("E-BOOK"): Figtree 11/900 → 700 (D-14, D-246), ls 0,8.
  static final TextStyle formatBadge = AppFonts.figtree(
    11,
    FontWeight.w700,
    letterSpacing: 0.8,
  );

  /// Os `<text>` da capa do Dom Casmurro (`il_capa_dom_casmurro.svg`, viewBox 96×144 em 101×153 com `slice`: escala
  /// 1,0625): "Dom" / "Casmurro" Instrument Serif 19 → 20,1875, `#FED170`.
  static final TextStyle coverEyeTitle = AppFonts.serif(
    19 * _coverEyeScale,
    height: 1,
    color: AppColors.sun,
  );

  /// "MACHADO DE ASSIS" da mesma capa: Figtree 5,2/700 → 5,525, ls 0,9 → 0,95625, `#F7F0E3`.
  static final TextStyle coverEyeAuthor = AppFonts.figtree(
    5.2 * _coverEyeScale,
    FontWeight.w700,
    height: 1,
    letterSpacing: 0.9 * _coverEyeScale,
    color: AppColors.paper,
  );

  /// i01.alsoReading.cardN.meta ("Papel · 3h 40min"): Figtree 11,5/700.
  static final TextStyle paperMeta = AppFonts.figtree(11.5, FontWeight.w700);

  /// i01.alsoReading.card1.cover.title ("Brás / Cubas"): Instrument Serif 11, `lh 0,95`, `#FED170`.
  static final TextStyle coverTitle11Sun = AppFonts.serif(
    11,
    height: 0.95,
    color: AppColors.sun,
  );

  /// i01.review.kicker ("REVISÃO · 5 GRIFOS · 2 MIN"): Figtree 11/800 → 700, ls 1, `#6F665B`.
  static final TextStyle reviewKicker = AppFonts.figtree(
    11,
    FontWeight.w700,
    letterSpacing: 1,
    color: AppColors.labelReader,
  );

  /// i01.review.title ("Seus grifos "): Bricolage 20/800, `lh 1,05`, ls −0,5.
  static final TextStyle reviewTitle = AppFonts.bricolage(
    20,
    height: 1.05,
    letterSpacing: -0.5,
  );

  /// i01.review.title.serif ("de hoje"): Instrument Serif itálico 24, herda `lh 1,05` e ls −0,5.
  static final TextStyle reviewTitleSerif = AppFonts.serif(
    24,
    height: 1.05,
    italic: true,
    letterSpacing: -0.5,
  );

  /// i01.review.subtitle ("De Dom Casmurro, …"): Figtree 12,5/600, `lh 1,35`, `#5B544B`.
  static final TextStyle reviewSubtitle = AppFonts.figtree(
    12.5,
    FontWeight.w600,
    height: 1.35,
    color: AppColors.inkMuted,
  );

  // ---- T04 · a mini-barra do cronômetro (prancha 01b) ------------------------------------------------------------

  /// i01b.miniBar.kicker ("LENDO · PAPEL"): Figtree 10,5/800 → 700 (D-14), ls 1,4, `#B9AE9C`, altura normal (1,2).
  static final TextStyle miniBarKicker = AppFonts.figtree(
    10.5,
    FontWeight.w700,
    letterSpacing: 1.4,
    color: AppColors.kickerOnInk,
  );

  /// i01b.miniBar.title ("Brás Cubas"): Figtree 15/800 → 700, `lh 1,2`, `#F7F0E3`.
  static final TextStyle miniBarTitle = AppFonts.figtree(
    15,
    FontWeight.w700,
    color: AppColors.paper,
  );

  /// i01b.miniBar.time ("08:42"): Bricolage 24/800, altura normal (1,2), ls −0,6, `tabular-nums`, `#F7F0E3`.
  static final TextStyle miniBarTime = AppFonts.bricolage(
    24,
    height: 1.2,
    letterSpacing: -0.6,
    color: AppColors.paper,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /// Os `<text>` da capa com asas da mini-barra (`il_capa_bras_cubas_asas.svg`, viewBox 96×144 em 29,6×45,6 com
  /// `slice`: escala 45,6 ÷ 144): "MEMÓRIAS PÓSTUMAS DE" Figtree 4,6/800 → 700, ls 0,8, `#F7F0E3`.
  static final TextStyle coverWingsKicker = AppFonts.figtree(
    4.6 * _coverWingsScale,
    FontWeight.w700,
    height: 1,
    letterSpacing: 0.8 * _coverWingsScale,
    color: AppColors.paper,
  );

  /// "Brás Cubas" da mesma capa: Instrument Serif 17,5, `#FED170`.
  static final TextStyle coverWingsTitle = AppFonts.serif(
    17.5 * _coverWingsScale,
    height: 1,
    color: AppColors.sun,
  );

  /// "MACHADO DE ASSIS" da mesma capa: Figtree 5,2/700, ls 0,9, `#F7F0E3`.
  static final TextStyle coverWingsAuthor = AppFonts.figtree(
    5.2 * _coverWingsScale,
    FontWeight.w700,
    height: 1,
    letterSpacing: 0.9 * _coverWingsScale,
    color: AppColors.paper,
  );

  /// max(101 ÷ 96, 153 ÷ 144): o `slice` da capa do herói.
  static const double _coverEyeScale = 153 / 144;

  /// max(29,6 ÷ 96, 45,6 ÷ 144): o `slice` da capa com asas da mini-barra.
  static const double _coverWingsScale = 45.6 / 144;
}
