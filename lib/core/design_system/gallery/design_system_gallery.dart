import 'package:flutter/widgets.dart';

import '../painters/chromium_dash.dart';
import '../painters/goal_dial_painter.dart';
import '../painters/hatch_painter.dart';
import '../painters/ring_progress_painter.dart';
import '../painters/top_border_crescent_painter.dart';
import '../text/app_text.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_shadows.dart';
import '../tokens/app_typography.dart';
import '../widgets/app_svg.dart';
import '../widgets/circle_icon_button.dart';
import '../widgets/count_badge.dart';
import '../widgets/neo_box.dart';
import '../widgets/pill.dart';
import '../widgets/pressable.dart';
import '../widgets/stadium_progress_bar.dart';

/// Galeria do design system — SOMENTE para revisão em debug (a rota `/_ds`, só em `kDebugMode`,
/// é registrada na F02). Mostra a paleta, os 46 estilos de texto com o texto de prova, todos os ícones
/// nos tamanhos de uso, cada pintor e cada primitivo nas variantes do arquivo.
/// NÃO faz parte da tela Início.
class DesignSystemGallery extends StatelessWidget {
  const DesignSystemGallery({super.key});

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppColors.paper,
    child: SingleChildScrollView(child: DesignSystemGalleryContent()),
  );
}

/// Conteúdo da galeria (sem rolagem), na largura disponível.
class DesignSystemGalleryContent extends StatelessWidget {
  const DesignSystemGalleryContent({super.key});

  static const _ink15 = BorderSide(width: 1.5, color: AppColors.ink);
  static const _ink12 = BorderSide(width: 1.2, color: AppColors.ink);

  static const List<(String, Color)> _palette = [
    ('paper', AppColors.paper),
    ('ink', AppColors.ink),
    ('surface', AppColors.surface),
    ('inkMuted', AppColors.inkMuted),
    ('inkPlum', AppColors.inkPlum),
    ('inkWarm', AppColors.inkWarm),
    ('lavender', AppColors.lavender),
    ('sun', AppColors.sun),
    ('flame', AppColors.flame),
    ('leaf', AppColors.leaf),
    ('blush', AppColors.blush),
    ('violet', AppColors.violet),
    ('azure', AppColors.azure),
    ('emerald', AppColors.emerald),
    ('amber', AppColors.amber),
    ('ringTrack', AppColors.ringTrack),
    ('hatch', AppColors.hatch),
    ('hatchToday', AppColors.hatchToday),
    ('stubLabel', AppColors.stubLabel),
    ('divider', AppColors.divider),
    ('tagLavenderBg', AppColors.tagLavenderBg),
    ('tagLavenderFg', AppColors.tagLavenderFg),
    ('tagSandBg', AppColors.tagSandBg),
    ('spine22', AppColors.spine22),
    ('spine18', AppColors.spine18),
    ('spine15', AppColors.spine15),
    ('spine12', AppColors.spine12),
    ('decoRing', AppColors.decoRing),
    ('chipGlass', AppColors.chipGlass),
    ('goalLine', AppColors.goalLine),
    ('dialTick', AppColors.dialTick),
    ('paperTransparent', AppColors.paperTransparent),
  ];

  /// (token, estilo, texto de prova, fundo). Os 4 tokens de texto misto usam o trecho do arquivo.
  static final List<(String, TextStyle, String, Color)> _type = [
    ('displayXL', AppTextStyles.displayXL, 'Continue', AppColors.paper),
    ('stubDay', AppTextStyles.stubDay, '24', AppColors.paper),
    ('dialValue', AppTextStyles.dialValue, '18', AppColors.paper),
    ('heroPercent', AppTextStyles.heroPercent, '62%', AppColors.paper),
    ('heroTitle', AppTextStyles.heroTitle, 'Dom Casmurro', AppColors.paper),
    (
      'sectionTitleL',
      AppTextStyles.sectionTitleL,
      'Para você',
      AppColors.paper,
    ),
    ('clubTitle', AppTextStyles.clubTitle, 'Leitoras de', AppColors.paper),
    ('cardTitleM', AppTextStyles.cardTitleM, 'Seu dia de ', AppColors.paper),
    (
      'sectionTitleS',
      AppTextStyles.sectionTitleS,
      'Também lendo',
      AppColors.paper,
    ),
    ('avatarInitial', AppTextStyles.avatarInitial, 'M', AppColors.paper),
    ('markerInitial', AppTextStyles.markerInitial, 'M', AppColors.paper),
    (
      'displaySerifXL',
      AppTextStyles.displaySerifXL,
      'sua história.',
      AppColors.paper,
    ),
    ('clubSerif', AppTextStyles.clubSerif, 'Capitu', AppColors.paper),
    ('cardSerifM', AppTextStyles.cardSerifM, 'leitura', AppColors.paper),
    (
      'coverTitle26',
      AppTextStyles.coverTitle26,
      'O Cortiço',
      AppColors.emerald,
    ),
    ('coverTitle22', AppTextStyles.coverTitle22, 'Casmurro', AppColors.violet),
    (
      'coverTitle19',
      AppTextStyles.coverTitle19,
      'Póstumas de',
      AppColors.paper,
    ),
    ('coverTitle11', AppTextStyles.coverTitle11, 'Dalloway', AppColors.paper),
    ('coverTitle9', AppTextStyles.coverTitle9, 'Preconceito', AppColors.paper),
    (
      'coverAuthorPaper',
      AppTextStyles.coverAuthorPaper,
      'MACHADO DE',
      AppColors.violet,
    ),
    (
      'coverAuthorFlame',
      AppTextStyles.coverAuthorFlame,
      'MACHADO DE ASSIS',
      AppColors.paper,
    ),
    (
      'coverAuthorSurface',
      AppTextStyles.coverAuthorSurface,
      'MACHADO DE ASSIS',
      AppColors.azure,
    ),
    ('stubLabel', AppTextStyles.stubLabel, 'ENCONTRO', AppColors.blush),
    ('avatarCount', AppTextStyles.avatarCount, '+8', AppColors.paper),
    ('navLabel', AppTextStyles.navLabel, 'Biblioteca', AppColors.paper),
    ('dialCaption', AppTextStyles.dialCaption, 'de 30 min', AppColors.paper),
    ('weekDay', AppTextStyles.weekDay, 'S', AppColors.paper),
    ('micro11Bold', AppTextStyles.micro11Bold, 'Scanner', AppColors.paper),
    (
      'caption12Plum',
      AppTextStyles.caption12Plum,
      '~2h 10min',
      AppColors.lavender,
    ),
    (
      'caption12Muted',
      AppTextStyles.caption12Muted,
      '4h 00min no total',
      AppColors.paper,
    ),
    (
      'label12Bold',
      AppTextStyles.label12Bold,
      'Cap. 92 de 148',
      AppColors.paper,
    ),
    (
      'tagLavender',
      AppTextStyles.tagLavender,
      'Quero ler',
      AppColors.tagLavenderBg,
    ),
    ('tagSand', AppTextStyles.tagSand, 'Novo', AppColors.tagSandBg),
    ('count12OnInk', AppTextStyles.count12OnInk, '2', AppColors.ink),
    ('stubMeta', AppTextStyles.stubMeta, 'QUI', AppColors.blush),
    ('body13Muted', AppTextStyles.body13Muted, 'Boa noite,', AppColors.paper),
    (
      'body13Semi',
      AppTextStyles.body13Semi,
      'Porque você lê Machado de Assis',
      AppColors.paper,
    ),
    ('body13Bold', AppTextStyles.body13Bold, '12 dias', AppColors.paper),
    (
      'body14Plum',
      AppTextStyles.body14Plum,
      'Machado de Assis',
      AppColors.lavender,
    ),
    ('label14Bold', AppTextStyles.label14Bold, 'Ver tudo', AppColors.paper),
    ('cta14OnInk', AppTextStyles.cta14OnInk, 'Abrir discussão', AppColors.ink),
    ('goalSentence', AppTextStyles.goalSentence, 'Faltam ', AppColors.sun),
    (
      'goalSentenceStrong',
      AppTextStyles.goalSentenceStrong,
      '12 min',
      AppColors.sun,
    ),
    ('title15', AppTextStyles.title15, 'Mrs. Dalloway', AppColors.paper),
    ('name16', AppTextStyles.name16, 'Marina', AppColors.paper),
    ('cta16OnInk', AppTextStyles.cta16OnInk, 'Continuar lendo', AppColors.ink),
  ];

  /// (nome, asset, tamanho de uso, fundo).
  static const List<(String, String, double, Color)> _icons = [
    ('bell', AppIcons.bell, 22, AppColors.surface),
    ('sparkleOutline', AppIcons.sparkleOutline, 30, AppColors.lavender),
    ('sparkleSolid', AppIcons.sparkleSolid, 14, AppColors.surface),
    ('sparkleSolid', AppIcons.sparkleSolid, 16, AppColors.surface),
    ('bookOpen', AppIcons.bookOpen, 20, AppColors.ink),
    ('highlighter', AppIcons.highlighter, 22, AppColors.surface),
    ('flame', AppIcons.flame, 17, AppColors.surface),
    ('arrowRight', AppIcons.arrowRight, 18, AppColors.paper),
    ('messageCircle', AppIcons.messageCircle, 18, AppColors.ink),
    ('moreHorizontal', AppIcons.moreHorizontal, 20, AppColors.paper),
    ('navHomeActive', AppIcons.navHomeActive, 22, AppColors.lavender),
    ('navLibrary', AppIcons.navLibrary, 22, AppColors.surface),
    ('navScanner', AppIcons.navScanner, 28, AppColors.sun),
    ('navClubs', AppIcons.navClubs, 22, AppColors.surface),
    ('navProfile', AppIcons.navProfile, 22, AppColors.surface),
    ('navHome*', AppIcons.navHome, 22, AppColors.surface),
    ('navLibraryActive*', AppIcons.navLibraryActive, 22, AppColors.lavender),
    ('navClubsActive*', AppIcons.navClubsActive, 22, AppColors.lavender),
    ('navProfileActive*', AppIcons.navProfileActive, 22, AppColors.lavender),
  ];

  static Widget _title(String text) => Padding(
    padding: const EdgeInsets.only(top: 32, bottom: 12),
    child: AppText(text, style: AppTextStyles.sectionTitleL),
  );

  static Widget _caption(String text) =>
      AppText(text, style: AppTextStyles.navLabel);

  static Widget _labeled(String label, Widget child) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 4,
    children: [child, _caption(label)],
  );

  /// `#RRGGBB` (opaca) ou `#AARRGGBB` (translúcida).
  static String _hex(Color c) {
    final argb = c.toARGB32();
    final digits = argb >>> 24 == 0xFF ? argb & 0xFFFFFF : argb;
    final width = argb >>> 24 == 0xFF ? 6 : 8;
    return '#${digits.toRadixString(16).toUpperCase().padLeft(width, '0')}';
  }

  Widget _swatch(String name, Color color) => SizedBox(
    width: 80,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 3,
      children: [
        NeoBox(
          width: 80,
          height: 36,
          color: color,
          border: _ink12,
          radius: BorderRadius.circular(8),
        ),
        AppText(name, style: AppTextStyles.avatarCount),
        AppText(_hex(color), style: AppTextStyles.navLabel),
      ],
    ),
  );

  Widget _typeRow(
    String name,
    TextStyle style,
    String sample,
    Color background,
  ) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    spacing: 8,
    children: [
      Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: ColoredBox(
            color: background,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: AppText(sample, style: style),
            ),
          ),
        ),
      ),
      _caption(name),
    ],
  );

  Widget _iconTile(String name, String asset, double size, Color background) =>
      _labeled(
        '$name ${size.toStringAsFixed(0)}',
        NeoBox(
          width: 44,
          height: 44,
          color: background,
          border: _ink12,
          radius: BorderRadius.circular(10),
          child: Center(child: AppSvg(asset, size: size)),
        ),
      );

  Widget _weekBar(double height, {required bool today}) => NeoBox(
    width: (280 - 6 * 8) / 7,
    height: 80,
    color: AppColors.surface,
    border: today ? _ink15 : _ink12,
    radius: BorderRadius.circular(AppRadii.pill),
    clip: true,
    child: Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: HatchPainter(
            stripe: today ? AppColors.hatchToday : AppColors.hatch,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: height,
          child: CustomPaint(
            painter: TopBorderCrescentPainter(
              fill: today ? AppColors.flame : AppColors.lavender,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText('Design system', style: AppTextStyles.displayXL),
        AppText(
          'galeria de revisão (debug)',
          style: AppTextStyles.displaySerifXL,
        ),
        _title('Paleta (32 + opções)'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final (name, color) in _palette) _swatch(name, color),
          ],
        ),
        const SizedBox(height: 12),
        _caption('brandOptions · weekColorOptions'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final c in AppColors.brandOptions) _swatch('brand', c),
            for (final c in AppColors.weekColorOptions) _swatch('week', c),
          ],
        ),
        _title('Tipografia (46 tokens)'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [
            for (final (name, style, sample, bg) in _type)
              _typeRow(name, style, sample, bg),
          ],
        ),
        const SizedBox(height: 10),
        _caption(
          'texto misto (F07): cardTitleM + cardSerifM · goalSentence + goalSentenceStrong',
        ),
        const SizedBox(height: 6),
        AppText.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Seu dia de ', style: AppTextStyles.cardTitleM),
              TextSpan(text: 'leitura', style: AppTextStyles.cardSerifM),
            ],
          ),
        ),
        _title('Ícones (18, tamanhos de uso)'),
        _caption('* extrapolados (D-07)'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final (name, asset, size, bg) in _icons)
              _iconTile(name, asset, size, bg),
          ],
        ),
        _title('Pintores'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            _labeled(
              'Hatch',
              const SizedBox(
                width: 30.742,
                height: 77.6,
                child: CustomPaint(
                  painter: HatchPainter(stripe: AppColors.hatch),
                ),
              ),
            ),
            _labeled(
              'Hoje',
              const SizedBox(
                width: 30.742,
                height: 77.6,
                child: CustomPaint(
                  painter: HatchPainter(stripe: AppColors.hatchToday),
                ),
              ),
            ),
            _labeled(
              'Meia-lua',
              const SizedBox(
                width: 30.742,
                height: 43,
                child: CustomPaint(
                  painter: TopBorderCrescentPainter(fill: AppColors.lavender),
                ),
              ),
            ),
            _labeled(
              'Hoje',
              const SizedBox(
                width: 30.142,
                height: 24,
                child: CustomPaint(
                  painter: TopBorderCrescentPainter(fill: AppColors.flame),
                ),
              ),
            ),
            _labeled('Barra', _weekBar(43, today: false)),
            _labeled('Barra hoje', _weekBar(24, today: true)),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            for (final (progress, label) in const [
              (0.34, '34%'),
              (0.81, '81%'),
            ])
              _labeled(
                'Anel $label',
                SizedBox.square(
                  dimension: 46,
                  child: CustomPaint(
                    painter: RingProgressPainter(progress: progress),
                    child: Center(
                      child: AppText(label, style: AppTextStyles.micro11Bold),
                    ),
                  ),
                ),
              ),
            _labeled(
              'Dial 18/30',
              const SizedBox.square(
                dimension: 112,
                child: CustomPaint(painter: GoalDialPainter(progress: 18 / 30)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            const SizedBox(
              width: 1.5,
              height: 263.6,
              child: CustomPaint(
                painter: ChromiumDashPainter(axis: Axis.vertical),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  _caption(
                    'Perfuração do ticket (à esquerda): 263,6 — 59 traços, vão 1,4931',
                  ),
                  _labeled(
                    'Linha da meta 288 (goalLine; 64 traços, vão 1,5238)',
                    const SizedBox(
                      width: 288,
                      height: 1.5,
                      child: CustomPaint(
                        painter: ChromiumDashPainter(
                          axis: Axis.horizontal,
                          color: AppColors.goalLine,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        _title('Primitivos'),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _labeled(
              'NeoBox (sombra 4)',
              NeoBox(
                width: 140,
                height: 80,
                color: AppColors.lavender,
                border: _ink15,
                radius: BorderRadius.circular(AppRadii.card),
                shadow: AppShadows.hard4,
              ),
            ),
            _labeled(
              'NeoBox(clip)',
              NeoBox(
                width: 140,
                height: 80,
                color: AppColors.surface,
                border: _ink15,
                radius: BorderRadius.circular(AppRadii.card),
                clip: true,
                child: const CustomPaint(
                  painter: HatchPainter(stripe: AppColors.hatch),
                  child: SizedBox.expand(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Pill(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              color: AppColors.surface,
              border: _ink15,
              child: AppText(
                'Cap. 92 de 148',
                style: AppTextStyles.label12Bold,
              ),
            ),
            ColoredBox(
              color: AppColors.sun,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Pill(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 9,
                  ),
                  color: AppColors.chipGlass,
                  border: _ink12,
                  child: AppText(
                    '24 páginas',
                    style: AppTextStyles.label12Bold,
                  ),
                ),
              ),
            ),
            Pill(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              color: AppColors.blush,
              border: _ink15,
              child: AppText(
                'Clube do livro',
                style: AppTextStyles.label12Bold,
              ),
            ),
            Pill(
              padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
              color: AppColors.surface,
              border: _ink15,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  const AppSvg(AppIcons.sparkleSolid, size: 14),
                  AppText(
                    'Porque você lê Machado de Assis',
                    style: AppTextStyles.body13Semi,
                  ),
                ],
              ),
            ),
            Pill(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              color: AppColors.surface,
              border: _ink15,
              child: AppText('20h', style: AppTextStyles.body13Bold),
            ),
            Pill(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              color: AppColors.tagLavenderBg,
              child: AppText('Quero ler', style: AppTextStyles.tagLavender),
            ),
            Pill(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              color: AppColors.tagSandBg,
              child: AppText('Novo', style: AppTextStyles.tagSand),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CountBadge(
              label: '14',
              style: AppTextStyles.micro11Bold,
              minWidth: 22,
              height: 22,
              horizontalPadding: 5,
              background: AppColors.sun,
              border: _ink15,
            ),
            CountBadge(
              label: '2',
              style: AppTextStyles.count12OnInk,
              minWidth: 22,
              height: 22,
              horizontalPadding: 7,
              background: AppColors.ink,
            ),
            CountBadge(
              label: '3',
              style: AppTextStyles.micro11Bold,
              minWidth: 20,
              height: 20,
              horizontalPadding: 6,
              background: AppColors.flame,
            ),
            CircleIconButton(
              size: 48,
              color: AppColors.surface,
              border: _ink15,
              semanticsLabel: 'Notificações',
              icon: const AppSvg(AppIcons.bell, size: 22),
              overlays: [
                Positioned(
                  top: 9,
                  right: 11,
                  child: NeoBox(
                    width: 12,
                    height: 12,
                    color: AppColors.flame,
                    border: _ink15,
                    radius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            CircleIconButton(
              size: 54,
              color: AppColors.surface,
              border: _ink15,
              semanticsLabel: 'Destaques',
              icon: const AppSvg(AppIcons.highlighter, size: 22),
              overlays: [
                Positioned(
                  top: -4,
                  right: -4,
                  child: CountBadge(
                    label: '14',
                    style: AppTextStyles.micro11Bold,
                    minWidth: 22,
                    height: 22,
                    horizontalPadding: 5,
                    background: AppColors.sun,
                    border: _ink15,
                  ),
                ),
              ],
            ),
            const CircleIconButton(
              size: 44,
              semanticsLabel: 'Mais opções',
              icon: AppSvg(AppIcons.moreHorizontal, size: 20),
            ),
            Pressable(
              isLink: true,
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  AppText('Ver tudo', style: AppTextStyles.label14Bold),
                  const AppSvg(AppIcons.arrowRight, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _labeled(
          'StadiumProgressBar 181 × 10 · 62 %',
          const SizedBox(
            width: 181,
            child: StadiumProgressBar(
              progress: 0.62,
              height: 10,
              background: AppColors.surface,
              fillColor: AppColors.ink,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _labeled(
          'StadiumProgressBar 221 × 12 · 54 %',
          const SizedBox(
            width: 221,
            child: StadiumProgressBar(
              progress: 0.54,
              height: 12,
              background: AppColors.surface,
              fillColor: AppColors.blush,
            ),
          ),
        ),
      ],
    ),
  );
}
