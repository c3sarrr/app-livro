// Concluir o cadastro (D-66, D-69, D-21): registra a faixa etária (se a conta ainda não tem) e troca o
// @ provisório ("leitor_…") pelo escolhido. Sem boas-vindas nem passos extras.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../application/account_controller.dart';
import '../domain/account_failure.dart';
import 'account_widgets.dart';
import 'age_step.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _handle = TextEditingController();
  bool _busy = false;
  bool _underage = false;
  String? _error;

  AccountController get _controller =>
      ref.read(accountControllerProvider.notifier);

  @override
  void dispose() {
    _handle.dispose();
    super.dispose();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.perfil);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on AccountFailure catch (f) {
      if (mounted) setState(() => _error = f.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveHandle() =>
      _run(() => _controller.chooseHandle(_handle.text));

  @override
  Widget build(BuildContext context) {
    ref.listen(accountControllerProvider, (prev, next) {
      if (prev is MemberView && next is GuestView) {
        _close(); // saiu ou excluiu a conta daqui
        return;
      }
      final wasPending = prev is MemberView && prev.needsOnboarding;
      if (wasPending &&
          next is MemberView &&
          next.summary != null &&
          !next.needsOnboarding) {
        _close();
      }
    });
    final view = ref.watch(accountControllerProvider);
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
              const AccountHeading('Concluir cadastro'),
              ..._body(view),
              if (_error != null) AccountNotice(_error!, error: true),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _body(AccountView view) {
    if (view is! MemberView) {
      return [
        const AccountText('Entre na sua conta para concluir o cadastro.'),
      ];
    }
    final summary = view.summary;
    if (summary == null) {
      return [
        AccountText(
          view.problem?.message ?? 'Carregando a conta…',
          muted: true,
        ),
        if (view.problem != null)
          AccountButton(
            'Tentar de novo',
            onTap: _busy ? null : () => _run(_controller.refresh),
          ),
      ];
    }
    if (summary.ageBand == null) {
      // O controller registra a faixa na conta assim que a idade é aceita.
      return [
        AgeStep(
          onAllowed: (_) {},
          onBlocked: () => setState(() => _underage = true),
        ),
        // Menor de 13 com conta (criada sem passar pela idade): não segue — sai ou exclui (D-66).
        if (_underage) ...[
          AccountButton(
            'Excluir a conta',
            tone: AccountButtonTone.danger,
            onTap: _busy
                ? null
                : () =>
                      _run(() => _controller.deleteAccount(eraseLocal: false)),
          ),
          AccountButton(
            'Sair da conta',
            onTap: _busy
                ? null
                : () => _run(() => _controller.signOut(eraseLocal: false)),
          ),
        ],
      ];
    }
    if (summary.handleProvisional) {
      return [
        const AccountText(
          'Escolha o seu @. É como as pessoas vão encontrar você nos clubes. '
          'Use de 3 a 30 letras minúsculas, números, ponto ou sublinhado.',
          muted: true,
        ),
        AccountField(
          controller: _handle,
          label: 'Seu @',
          hint: '@seu.nome',
          autofocus: true,
          onSubmitted: (_) => _busy ? null : _saveHandle(),
        ),
        AccountButton(
          'Salvar @',
          tone: AccountButtonTone.primary,
          onTap: _busy ? null : _saveHandle,
        ),
      ];
    }
    return [AccountText('Tudo certo, @${summary.handle}.')];
  }
}
