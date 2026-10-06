import 'package:flutter/painting.dart';

import 'app_colors.dart';
import 'reader_fonts.dart';

abstract final class AppFonts {
  /// Instâncias estáticas existentes da Bricolage (optical size = tamanho em px; 11 px usa 12).
  static const Set<int> bricolageOpsz = {12, 17, 18, 20, 22, 24, 26, 34, 42};

  static TextStyle bricolage(
    double size, {
    required double height,
    double letterSpacing = 0,
    Color color = AppColors.ink,
  }) {
    final opsz = size.round().clamp(12, 96).toInt();
    assert(
      bricolageOpsz.contains(opsz),
      'Sem instância Bricolage opsz $opsz: gere com design_handoff/ferramentas/build_fonts.py',
    );
    return TextStyle(
      fontFamily: 'Bricolage$opsz',
      fontFamilyFallback: ['Bricolage${opsz}Ext', 'Bricolage${opsz}Vi'],
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
    17: {400, 500},
    19: {500},
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

  /// hero.chapterPill, today.chip.pages, today.chip.highlights, club.pill, club.youLabel (CSS 700/800 → renderizado 700)
  static final TextStyle label12Bold = AppFonts.figtree(12, FontWeight.w700);

  /// recent.row0.tag, recent.row1.tag
  static final TextStyle tagLavender = AppFonts.figtree(
    12,
    FontWeight.w700,
    color: AppColors.tagLavenderFg,
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
}
