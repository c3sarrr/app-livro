// Scanner (`/scanner`, tela cheia) — provisório D-21/D-76 até o design das telas 01–18: câmera num
// cartão com borda e sombra dura, texto de ajuda, pílulas "Digitar ISBN" e "Lanterna" e um cartão de
// resultado. Só primitivos que já existem (NeoBox, Pill, Pressable e os da conta — D-21).
import 'dart:async';

import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pill.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../../account/presentation/account_widgets.dart';
import '../../catalog/domain/catalog_book.dart';
import '../../catalog/domain/community.dart';
import '../application/scanner_controller.dart';
import '../domain/cover_text.dart';
import '../domain/scan_state.dart';
import 'scanner_camera.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  late final ScannerCamera _camera = ref.read(scannerCameraProvider)();
  final _isbn = TextEditingController();
  bool _typing = false;
  bool _invalidIsbn = false;

  @override
  void dispose() {
    unawaited(_camera.dispose());
    _isbn.dispose();
    super.dispose();
  }

  ScannerController get _controller =>
      ref.read(scannerControllerProvider.notifier);

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.inicio);
    }
  }

  Future<void> _search() async {
    final ok = await _controller.typed(_isbn.text);
    if (!mounted) return;
    setState(() {
      _invalidIsbn = !ok;
      if (ok) _typing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scannerControllerProvider);
    return ColoredBox(
      color: AppColors.paper,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: AccountColumn(
            gap: 16,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: AccountButton('Fechar', onTap: _close),
              ),
              const AccountHeading('Escanear livro'),
              _CameraCard(camera: _camera, onCode: _controller.onBarcode),
              ValueListenableBuilder(
                valueListenable: _camera.status,
                builder: (context, status, _) => AccountText(switch (status) {
                  CameraStatus.denied => 'Sem acesso à câmera. Permita a câmera nos ajustes do aparelho ou digite o ISBN.',
                  CameraStatus.unavailable =>
                    'A câmera não abriu. Digite o ISBN do livro.',
                  _ => 'Aponte para o código de barras da contracapa.',
                }, muted: true),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _PillButton(
                    'Digitar ISBN',
                    key: const ValueKey('scanner.digitar'),
                    active: _typing,
                    onTap: () => setState(() {
                      _typing = !_typing;
                      _invalidIsbn = false;
                    }),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _camera.torch,
                    builder: (context, on, _) => on == null
                        ? const SizedBox.shrink()
                        : _PillButton(
                            'Lanterna',
                            key: const ValueKey('scanner.lanterna'),
                            active: on,
                            onTap: () => unawaited(_camera.toggleTorch()),
                          ),
                  ),
                ],
              ),
              if (_typing) ...[
                AccountField(
                  controller: _isbn,
                  label: 'ISBN (10 ou 13 dígitos)',
                  hint: '978-85-…',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9Xx\- ]')),
                  ],
                  autofocus: true,
                  onSubmitted: (_) => _search(),
                ),
                AccountButton(
                  'Buscar',
                  tone: AccountButtonTone.primary,
                  onTap: _search,
                ),
                if (_invalidIsbn)
                  const AccountNotice(
                    'Esse número não é um ISBN válido. Confira os dígitos.',
                    error: true,
                  ),
              ],
              if (state case ScanAiming(notABook: true))
                const AccountNotice('Esse código não é de um livro.'),
              if (state is! ScanAiming) _ResultCard(state: state),
            ],
          ),
        ),
      ),
    );
  }
}

/// Câmera num cartão com borda de tinta e sombra dura (D-76), com a moldura de mira no centro.
class _CameraCard extends StatelessWidget {
  const _CameraCard({required this.camera, required this.onCode});
  final ScannerCamera camera;
  final ValueChanged<String> onCode;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Câmera do scanner',
    container: true,
    child: NeoBox(
      color: AppColors.ink,
      border: const BorderSide(width: AppStrokes.regular, color: AppColors.ink),
      radius: BorderRadius.circular(AppRadii.card),
      shadow: AppShadows.hard4,
      clip: true,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: ValueListenableBuilder(
          valueListenable: camera.status,
          builder: (context, status, preview) => switch (status) {
            CameraStatus.denied || CameraStatus.unavailable => Center(
              child: AppText(
                status == CameraStatus.denied
                    ? 'Câmera sem permissão'
                    : 'Câmera indisponível',
                style: AppFonts.figtree(
                  15,
                  FontWeight.w600,
                  color: AppColors.paper,
                ),
              ),
            ),
            _ => preview!,
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              ExcludeSemantics(child: camera.preview(onCode)),
              const Center(
                child: FractionallySizedBox(
                  widthFactor: 0.72,
                  heightFactor: 0.42,
                  child: NeoBox(
                    border: BorderSide(width: 2, color: AppColors.paper),
                    radius: BorderRadius.all(Radius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Pílula de ação (borda de tinta; ligada = `sun`).
class _PillButton extends StatelessWidget {
  const _PillButton(
    this.label, {
    super.key,
    required this.onTap,
    this.active = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: active,
    child: Pressable(
      onTap: onTap,
      semanticsLabel: label,
      child: Pill(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        color: active ? AppColors.sun : AppColors.surface,
        border: const BorderSide(
          width: AppStrokes.regular,
          color: AppColors.ink,
        ),
        child: AppText(label, style: AppFonts.figtree(14, FontWeight.w600)),
      ),
    ),
  );
}

/// Cartão de resultado (D-76): título · autor, editora e ano · ação.
class _ResultCard extends ConsumerWidget {
  const _ResultCard({required this.state});
  final ScanState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(scannerControllerProvider.notifier);
    return NeoBox(
      key: const ValueKey('scanner.resultado'),
      color: AppColors.surface,
      border: const BorderSide(width: AppStrokes.regular, color: AppColors.ink),
      radius: BorderRadius.circular(AppRadii.cardM),
      shadow: AppShadows.hard3,
      padding: const EdgeInsets.all(18),
      child: Semantics(
        liveRegion: true,
        child: switch (state) {
          ScanLooking(:final isbn13) => AccountText(
            'Procurando o ISBN $isbn13…',
          ),
          ScanFound(:final book) => AccountColumn(
            children: [
              ..._bookLines(book.title, _details(book)),
              _Busy(
                label: 'Adicionar à estante',
                primary: true,
                run: c.addFound,
              ),
            ],
          ),
          ScanOnShelf(:final book) => AccountColumn(
            children: [
              const AccountNotice('Este livro já está na sua estante.'),
              ..._bookLines(book.title, book.authorDisplay),
              AccountButton('Escanear outro', onTap: c.scanAgain),
            ],
          ),
          final ScanAdded added => _AddedBody(state: added),
          ScanFailed(:final failure) => AccountColumn(
            children: [
              AccountNotice(catalogFailureMessage(failure), error: true),
              _Busy(label: 'Tentar de novo', primary: true, run: c.retry),
              AccountButton('Digitar os dados', onTap: c.enterManually),
            ],
          ),
          final ScanNotFound missing => _NotFoundBody(
            key: ValueKey(missing.isbn13),
            state: missing,
          ),
          ScanAiming() => const SizedBox.shrink(),
        },
      ),
    );
  }
}

List<Widget> _bookLines(String title, String details) => [
  AccountHeading(title),
  if (details.isNotEmpty) AccountText(details, muted: true),
];

/// "Autor · Editora · ano".
String _details(CatalogBook b) => [
  if (b.authorDisplay.isNotEmpty) b.authorDisplay,
  if (b.publisher case final p? when p.isNotEmpty) p,
  if (b.year case final y?) '$y',
].join(' · ');

class _AddedBody extends ConsumerWidget {
  const _AddedBody({required this.state});
  final ScanAdded state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(scannerControllerProvider.notifier);
    final envio = switch (state.contribution) {
      ContributionPending() => 'Enviado ao catálogo da comunidade. Ele entra no catálogo depois de 2 confirmações de outras pessoas.',
      ContributionConfirmed() =>
        'Sua confirmação foi registrada. Obrigado por ajudar o catálogo.',
      ContributionApproved() =>
        'Com a sua confirmação, o livro entrou no catálogo da comunidade.',
      ContributionAlreadyInCatalog() => 'Este livro já estava no catálogo.',
      null => null,
    };
    final falha = state.contributionFailure;
    return AccountColumn(
      children: [
        const AccountNotice('Adicionado à sua estante.'),
        ..._bookLines(state.book.title, state.book.authorDisplay),
        if (envio != null) AccountText(envio, muted: true),
        if (falha != null)
          AccountNotice(
            'O livro está na estante, mas o envio ao catálogo não foi: ${catalogFailureMessage(falha)}',
            error: true,
          ),
        AccountButton(
          'Escanear outro',
          tone: AccountButtonTone.primary,
          onTap: c.scanAgain,
        ),
      ],
    );
  }
}

/// Ninguém achou: sugestões da comunidade (se houver) e o formulário "Adicionar este livro".
class _NotFoundBody extends ConsumerStatefulWidget {
  const _NotFoundBody({super.key, required this.state});
  final ScanNotFound state;

  @override
  ConsumerState<_NotFoundBody> createState() => _NotFoundBodyState();
}

class _NotFoundBodyState extends ConsumerState<_NotFoundBody> {
  final _title = TextEditingController();
  final _authors = TextEditingController();
  final _publisher = TextEditingController();
  String? _notice;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _authors.dispose();
    _publisher.dispose();
    super.dispose();
  }

  Future<void> _readCover() async {
    setState(() => _busy = true);
    try {
      final lines = await ref.read(coverReaderProvider).read();
      if (!mounted || lines == null) return;
      final g = guessFromCover(lines);
      setState(() {
        if (g.title != null) _title.text = g.title!;
        if (g.author != null) _authors.text = g.author!;
        _notice = g.title == null
            ? 'Não deu para ler a capa. Digite o título e o autor.'
            : 'Confira o que foi lido da capa antes de adicionar.';
      });
    } on Object {
      if (mounted) {
        setState(() => _notice = 'Não deu para ler a capa. Digite os dados.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _add({required bool share}) async {
    setState(() {
      _busy = true;
      _notice = null;
    });
    final ok = await ref
        .read(scannerControllerProvider.notifier)
        .addTyped(
          title: _title.text,
          authors: _authors.text,
          publisher: _publisher.text,
          share: share,
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (!ok) _notice = 'Digite pelo menos o título.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.read(scannerControllerProvider.notifier);
    final podeEnviar = ref.watch(canContributeProvider);
    final busy = _busy;
    return AccountColumn(
      children: [
        AccountHeading('Não achamos o ISBN ${widget.state.isbn13}'),
        for (final s in widget.state.suggestions) _SuggestionTile(s),
        const AccountText(
          'Adicione este livro: digite os dados ou leia a capa.',
          muted: true,
        ),
        AccountButton('Ler a capa', onTap: busy ? null : _readCover),
        AccountField(controller: _title, label: 'Título'),
        AccountField(
          controller: _authors,
          label: 'Autor (separe vários com ;)',
        ),
        AccountField(controller: _publisher, label: 'Editora (opcional)'),
        AccountButton(
          'Adicionar à estante',
          key: const ValueKey('scanner.adicionar'),
          tone: AccountButtonTone.primary,
          onTap: busy ? null : () => _add(share: false),
        ),
        if (podeEnviar) ...[
          AccountButton(
            'Adicionar e enviar ao catálogo',
            key: const ValueKey('scanner.enviar'),
            onTap: busy ? null : () => _add(share: true),
          ),
          const AccountText(
            'O envio leva o ISBN, o título, o autor e a editora para o catálogo da comunidade. '
            'Seu nome não aparece para ninguém.',
            muted: true,
          ),
        ],
        if (_notice != null) AccountNotice(_notice!),
        AccountButton('Escanear outro', onTap: busy ? null : c.scanAgain),
      ],
    );
  }
}

class _SuggestionTile extends ConsumerWidget {
  const _SuggestionTile(this.s);
  final CommunitySuggestion s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(scannerControllerProvider.notifier);
    final podeEnviar = ref.watch(canContributeProvider);
    return NeoBox(
      color: AppColors.paper,
      border: const BorderSide(width: AppStrokes.regular, color: AppColors.ink),
      radius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(14),
      child: AccountColumn(
        gap: 10,
        children: [
          AccountText(
            s.mine
                ? 'Sua sugestão (esperando confirmações)'
                : 'Sugestão da comunidade · ${s.confirmations} '
                      '${s.confirmations == 1 ? 'confirmação' : 'confirmações'}',
            muted: true,
          ),
          ..._bookLines(
            s.title,
            [authorsForShelf(s.authors), ?s.publisher].join(' · '),
          ),
          if (podeEnviar && s.canConfirm)
            _Busy(
              label: 'Confirmar e adicionar',
              run: () => c.confirmSuggestion(s),
            ),
        ],
      ),
    );
  }
}

/// Botão que fica desabilitado enquanto a ação roda (dois toques não fazem duas vezes).
class _Busy extends StatefulWidget {
  const _Busy({required this.label, required this.run, this.primary = false});
  final String label;
  final Future<void> Function() run;
  final bool primary;

  @override
  State<_Busy> createState() => _BusyState();
}

class _BusyState extends State<_Busy> {
  bool _running = false;

  @override
  Widget build(BuildContext context) => AccountButton(
    widget.label,
    tone: widget.primary
        ? AccountButtonTone.primary
        : AccountButtonTone.secondary,
    onTap: _running
        ? null
        : () async {
            setState(() => _running = true);
            try {
              await widget.run();
            } finally {
              if (mounted) setState(() => _running = false);
            }
          },
  );
}
