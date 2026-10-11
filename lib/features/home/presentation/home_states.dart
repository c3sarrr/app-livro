// Estados da Início sem desenho no arquivo (D-21, D-85): carregando e erro, e o botão preto dos convites. Só
// primitivos que já existem (texto Figtree, a pílula tinta do "Continuar lendo"); listados em
// `docs/design/estados_sem_design.md` para o design desenhar depois.
import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';

/// A pílula tinta de 54 do "Continuar lendo" (ícone 20 + rótulo 16/700 papel), para os convites e o erro.
class InkPillButton extends StatelessWidget {
  const InkPillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      semanticsLabel: label,
      onTap: onTap,
      child: NeoBox(
        height: 54,
        color: AppColors.ink,
        radius: BorderRadius.circular(AppRadii.pill),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            AppSvg(icon, size: 20, color: AppColors.paper),
            AppText(label, style: AppTextStyles.cta16OnInk),
          ],
        ),
      ),
    );
  }
}

/// Carregando (D-85): o banco é local e costuma responder antes de qualquer aviso; passados 400 ms sem dados,
/// "Carregando sua estante…" (sem esqueleto).
class HomeLoadingView extends StatefulWidget {
  const HomeLoadingView({super.key});

  static const Duration delay = Duration(milliseconds: 400);

  @override
  State<HomeLoadingView> createState() => _HomeLoadingViewState();
}

class _HomeLoadingViewState extends State<HomeLoadingView> {
  Timer? _timer;
  var _show = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(HomeLoadingView.delay, () => setState(() => _show = true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const ValueKey('home.loading'),
    height: 120,
    child: Center(
      child: _show
          ? Semantics(
              liveRegion: true,
              child: AppText(
                'Carregando sua estante…',
                key: const ValueKey('home.loading.text'),
                style: AppTextStyles.body14Plum,
              ),
            )
          : const SizedBox.shrink(),
    ),
  );
}

/// Erro ao ler a estante (D-85): o que aconteceu e o que fazer.
class HomeErrorView extends StatelessWidget {
  const HomeErrorView({super.key, required this.onRetry, required this.icon});

  final VoidCallback onRetry;
  final String icon;

  @override
  Widget build(BuildContext context) => Column(
    key: const ValueKey('home.error'),
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: [
      Semantics(
        liveRegion: true,
        child: AppText(
          'Não deu para abrir sua estante.',
          key: const ValueKey('home.error.text'),
          style: AppTextStyles.title15,
        ),
      ),
      InkPillButton(
        key: const ValueKey('home.error.retry'),
        icon: icon,
        label: 'Tentar de novo',
        onTap: onRetry,
      ),
    ],
  );
}
