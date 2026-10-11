// Bloco mínimo da conta na aba Perfil (D-69, D-21): entrar, concluir o cadastro, exportar, sair e
// excluir — até o design do Perfil (telas 01–18) chegar.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../application/account_controller.dart';
import '../domain/account_failure.dart';
import 'account_widgets.dart';
import 'pro_rows.dart';
import 'sync_indicator.dart';

enum _Confirm { none, signOut, delete, eraseHidden }

class AccountBlock extends ConsumerStatefulWidget {
  const AccountBlock({super.key});

  @override
  ConsumerState<AccountBlock> createState() => _AccountBlockState();
}

class _AccountBlockState extends ConsumerState<AccountBlock> {
  _Confirm _confirm = _Confirm.none;
  bool _busy = false;
  int _pending = 0;
  String? _notice;
  bool _noticeIsError = false;

  AccountController get _controller =>
      ref.read(accountControllerProvider.notifier);

  Future<void> _run(Future<void> Function() action, {String? done}) async {
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      await action();
      if (!mounted) return;
      setState(() {
        _confirm = _Confirm.none;
        _notice = done;
        _noticeIsError = false;
      });
    } on AccountFailure catch (f) {
      if (!mounted) return;
      setState(() {
        _notice = f.message;
        _noticeIsError = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export() async {
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      final missing = await _controller.exportMyData();
      if (!mounted) return;
      setState(() {
        _notice = missing == null
            ? 'Arquivo com os seus dados pronto.'
            : 'Arquivo pronto só com o que está neste aparelho: os dados da conta ficaram de fora. '
                  '${missing.message}';
        _noticeIsError = missing != null;
      });
    } on AccountFailure catch (f) {
      if (!mounted) return;
      setState(() {
        _notice = f.message;
        _noticeIsError = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _itens(int n, {bool guardado = false}) => n == 1
      ? (guardado ? '1 item guardado' : 'o item')
      : (guardado ? '$n itens guardados' : 'os $n itens');

  /// Dados guardados de contas que saíram deste aparelho (D-68): o convidado pode apagá-los.
  List<Widget> _hidden(int rows, bool busy) => switch (_confirm) {
    _Confirm.eraseHidden => [
      AccountText(
        'Apagar deste aparelho ${_itens(rows)} de contas que saíram? Quem entrar de novo nessas contas '
        'não os terá mais aqui.',
      ),
      AccountButton(
        'Apagar dados de contas que saíram',
        tone: AccountButtonTone.danger,
        onTap: busy
            ? null
            : () => _run(
                _controller.eraseHiddenData,
                done: 'Dados apagados deste aparelho.',
              ),
      ),
      AccountButton(
        'Cancelar',
        onTap: busy ? null : () => setState(() => _confirm = _Confirm.none),
      ),
    ],
    _ => [
      AccountText(
        'Há ${_itens(rows, guardado: true)} de contas que saíram deste aparelho. '
        'Voltam quando a conta entrar de novo.',
        muted: true,
      ),
      AccountButton(
        'Apagar dados de contas que saíram',
        onTap: busy
            ? null
            : () => setState(() => _confirm = _Confirm.eraseHidden),
      ),
    ],
  };

  static String _notSent(int n) => n == 1
      ? 'Há 1 alteração ainda não enviada à nuvem: se apagar deste aparelho, ela se perde.'
      : 'Há $n alterações ainda não enviadas à nuvem: se apagar deste aparelho, elas se perdem.';

  /// Antes de confirmar a saída, conta o que ainda não foi para a nuvem (Pro).
  Future<void> _askSignOut() async {
    var n = 0;
    try {
      n = await _controller.pendingUploads();
    } on Object {
      n = 0; // sem a contagem, a confirmação aparece do mesmo jeito
    }
    if (!mounted) return;
    setState(() {
      _pending = n;
      _confirm = _Confirm.signOut;
    });
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(accountControllerProvider);
    final busy = _busy;
    final children = <Widget>[
      ...switch (view) {
        AccountLoading() => [const AccountText('Carregando a conta…')],
        GuestView(canSignIn: false) => [
          const AccountText(
            'Seus livros, grifos e tempo de leitura ficam só neste aparelho.',
          ),
          const AccountText('Conta indisponível nesta versão.', muted: true),
          AccountButton('Exportar meus dados', onTap: busy ? null : _export),
        ],
        GuestView(:final hiddenRows) => [
          const AccountText(
            'Sem conta: seus livros, grifos e tempo de leitura ficam só neste aparelho.',
          ),
          AccountButton(
            'Entrar ou criar conta',
            tone: AccountButtonTone.primary,
            onTap: busy ? null : () => context.push(AppRoutes.entrar),
          ),
          AccountButton('Exportar meus dados', onTap: busy ? null : _export),
          if (hiddenRows > 0) ..._hidden(hiddenRows, busy),
        ],
        final MemberView m => _member(m, busy),
      },
      if (_notice != null) AccountNotice(_notice!, error: _noticeIsError),
    ];
    return AccountColumn(children: children);
  }

  List<Widget> _member(MemberView m, bool busy) {
    final summary = m.summary;
    return [
      if (summary != null)
        AccountHeading('@${summary.handle}')
      else
        AccountText(m.problem?.message ?? 'Carregando a conta…', muted: true),
      const SyncIndicator(),
      // G22 (D-231): o Pro (o estado, restaurar e gerenciar) até o design do Perfil
      const ProRows(),
      if (m.needsOnboarding)
        AccountButton(
          'Concluir cadastro',
          tone: AccountButtonTone.primary,
          onTap: busy ? null : () => context.push(AppRoutes.cadastro),
        ),
      if (m.problem != null)
        AccountButton(
          'Tentar de novo',
          onTap: busy ? null : () => _run(_controller.refresh),
        ),
      ..._memberActions(busy),
    ];
  }

  List<Widget> _memberActions(bool busy) => switch (_confirm) {
    _Confirm.none || _Confirm.eraseHidden => [
      AccountButton('Exportar meus dados', onTap: busy ? null : _export),
      AccountButton('Sair', onTap: busy ? null : _askSignOut),
      AccountButton(
        'Excluir conta',
        tone: AccountButtonTone.danger,
        onTap: busy ? null : () => setState(() => _confirm = _Confirm.delete),
      ),
    ],
    _Confirm.signOut => [
      const AccountText(
        'Ao sair, seus livros e grifos ficam guardados neste aparelho e voltam quando você entrar de novo.',
      ),
      if (_pending > 0) AccountText(_notSent(_pending)),
      AccountButton(
        'Sair e manter neste aparelho',
        tone: AccountButtonTone.primary,
        onTap: busy
            ? null
            : () => _run(() => _controller.signOut(eraseLocal: false)),
      ),
      AccountButton(
        'Sair e apagar deste aparelho',
        tone: AccountButtonTone.danger,
        onTap: busy
            ? null
            : () => _run(() => _controller.signOut(eraseLocal: true)),
      ),
      AccountButton(
        'Cancelar',
        onTap: busy ? null : () => setState(() => _confirm = _Confirm.none),
      ),
    ],
    _Confirm.delete => [
      const AccountText(
        'Excluir a conta apaga agora, no servidor, seu perfil, posts, clubes, assinatura e arquivos. '
        'Não dá para desfazer.',
      ),
      AccountButton(
        'Excluir e apagar também deste aparelho',
        tone: AccountButtonTone.danger,
        onTap: busy
            ? null
            : () => _run(
                () => _controller.deleteAccount(eraseLocal: true),
                done: 'Conta excluída.',
              ),
      ),
      AccountButton(
        'Excluir e manter meus dados neste aparelho',
        tone: AccountButtonTone.danger,
        onTap: busy
            ? null
            : () => _run(
                () => _controller.deleteAccount(eraseLocal: false),
                done: 'Conta excluída. Seus dados continuam neste aparelho, sem conta.',
              ),
      ),
      AccountButton(
        'Cancelar',
        onTap: busy ? null : () => setState(() => _confirm = _Confirm.none),
      ),
    ],
  };
}
