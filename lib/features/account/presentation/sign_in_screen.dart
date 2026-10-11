// Entrar ou criar conta (D-67, D-21): idade (D-66) → e-mail com código, Google ou Apple → código.
// Quando a sessão chega, segue para concluir o cadastro (@ e idade) ou volta para o Perfil.
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
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

enum _Step { age, method, code }

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  _Step _step = _Step.age;
  bool _busy = false;
  String? _notice;
  bool _noticeIsError = true;

  AccountController get _controller =>
      ref.read(accountControllerProvider.notifier);

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, {String? done}) async {
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      await action();
      if (mounted) {
        setState(() {
          _notice = done;
          _noticeIsError = false;
        });
      }
    } on AccountFailure catch (f) {
      if (mounted) {
        setState(() {
          _notice = f.message;
          _noticeIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendCode() => _run(() async {
    await _controller.sendEmailCode(_email.text);
    if (mounted) setState(() => _step = _Step.code);
  }, done: 'Enviamos um código de 6 dígitos para o seu e-mail.');

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.perfil);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(accountControllerProvider, (_, next) {
      if (next is! MemberView) return;
      if (next.summary != null && next.needsOnboarding) {
        context.pushReplacement(AppRoutes.cadastro);
      } else if (next.summary != null || next.problem != null) {
        // entrou; se o servidor não respondeu, o Perfil mostra o motivo e "Tentar de novo"
        _close();
      }
    });
    final busy = _busy;
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
              const AccountHeading('Entrar ou criar conta'),
              ...switch (_step) {
                _Step.age => [
                  AgeStep(
                    onAllowed: (_) => setState(() => _step = _Step.method),
                  ),
                ],
                _Step.method => [
                  const AccountText(
                    'Com a conta você participa de clubes e posts. No plano Grátis, '
                    'seus livros e grifos continuam só neste aparelho.',
                    muted: true,
                  ),
                  AccountField(
                    controller: _email,
                    label: 'E-mail',
                    hint: 'seu@email.com',
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => _sendCode(),
                  ),
                  AccountButton(
                    'Receber código por e-mail',
                    tone: AccountButtonTone.primary,
                    onTap: busy ? null : _sendCode,
                  ),
                  AccountButton(
                    'Entrar com Google',
                    onTap: busy
                        ? null
                        : () => _run(_controller.signInWithGoogle),
                  ),
                  AccountButton(
                    'Entrar com Apple',
                    onTap: busy
                        ? null
                        : () => _run(_controller.signInWithApple),
                  ),
                ],
                _Step.code => [
                  AccountField(
                    controller: _code,
                    label: 'Código de 6 dígitos',
                    hint: '000000',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    autofocus: true,
                    onSubmitted: (_) => _run(
                      () =>
                          _controller.verifyEmailCode(_email.text, _code.text),
                    ),
                  ),
                  AccountButton(
                    'Entrar',
                    tone: AccountButtonTone.primary,
                    onTap: busy
                        ? null
                        : () => _run(
                            () => _controller.verifyEmailCode(
                              _email.text,
                              _code.text,
                            ),
                          ),
                  ),
                  AccountButton(
                    'Reenviar código',
                    onTap: busy ? null : _sendCode,
                  ),
                  AccountButton(
                    'Trocar e-mail',
                    onTap: busy
                        ? null
                        : () => setState(() {
                            _step = _Step.method;
                            _code.clear();
                            _notice = null;
                          }),
                  ),
                ],
              },
              if (_notice != null)
                AccountNotice(_notice!, error: _noticeIsError),
            ],
          ),
        ),
      ),
    );
  }
}
