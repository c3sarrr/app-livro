// Etapa de idade (D-66): primeiro o sinal da loja; se a loja não informar, a data de nascimento
// (usada só no aparelho para calcular a faixa e não guardada — o servidor recebe só a faixa).
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/account_controller.dart';
import '../domain/age.dart';
import 'account_widgets.dart';

class AgeStep extends ConsumerStatefulWidget {
  const AgeStep({super.key, required this.onAllowed, this.onBlocked});

  final ValueChanged<AgeCheck> onAllowed;

  /// Menor de 13 (a tela de cadastro oferece sair ou excluir a conta).
  final VoidCallback? onBlocked;

  @override
  ConsumerState<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends ConsumerState<AgeStep> {
  final _birth = TextEditingController();
  AgeGateOutcome? _outcome;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      _check,
    ); // depois do initState (setState não vale durante ele)
  }

  @override
  void dispose() {
    _birth.dispose();
    super.dispose();
  }

  Future<void> _check({DateTime? birthDate}) async {
    if (!mounted) return;
    setState(() => _busy = true);
    final o = await ref
        .read(accountControllerProvider.notifier)
        .checkAge(birthDate: birthDate);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _outcome = o;
    });
    if (o is AgeAllowed) widget.onAllowed(o.check);
    if (o is AgeBlocked) widget.onBlocked?.call();
  }

  void _submitBirth() {
    final d = parseBirthDate(_birth.text);
    if (d == null) {
      setState(() => _outcome = const AgeNeedsBirthDate(invalid: true));
      return;
    }
    _check(birthDate: d);
  }

  @override
  Widget build(BuildContext context) {
    final o = _outcome;
    if (_busy || o == null || o is AgeAllowed) {
      return const AccountText('Conferindo a idade…');
    }
    return AccountColumn(
      children: switch (o) {
        AgeNeedsBirthDate(:final invalid) => [
          const AccountHeading('Qual é a sua data de nascimento?'),
          const AccountText(
            'O BookNest é para 13 anos ou mais. A data não sai deste aparelho nem '
            'fica guardada: a conta recebe só a faixa de idade.',
            muted: true,
          ),
          AccountField(
            controller: _birth,
            label: 'Data de nascimento',
            hint: 'DD/MM/AAAA',
            keyboardType: TextInputType.datetime,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
            ],
            onSubmitted: (_) => _submitBirth(),
          ),
          if (invalid)
            const AccountNotice('Confira a data (DD/MM/AAAA).', error: true),
          AccountButton(
            'Continuar',
            tone: AccountButtonTone.primary,
            onTap: _submitBirth,
          ),
        ],
        AgeBlocked() => [
          const AccountHeading('O BookNest é para 13 anos ou mais'),
          const AccountText(
            'Você pode continuar usando o app sem conta: tudo fica só neste aparelho.',
          ),
        ],
        AgeStoreVerificationNeeded() => [
          const AccountHeading('Confirme sua idade na Play Store'),
          const AccountText(
            'O Google Play pede que você confirme a idade no app da Play Store. '
            'Depois, volte aqui e toque em "Conferir de novo".',
          ),
          AccountButton('Conferir de novo', onTap: _check),
        ],
        AgeAllowed() => const <Widget>[],
      },
    );
  }
}
