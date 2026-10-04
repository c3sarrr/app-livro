// G05.6 — privacidade do plano Grátis (§4.3.7, ADR-002): com conta, o Grátis só fala com o servidor
// para login/sessão e perfil. Os livros, grifos, notas, sessões e a data de nascimento NUNCA saem do
// aparelho. O teste passa pela pilha real (controller → gateway/API → cliente do Supabase) e grava
// cada pedido HTTP; qualquer endpoint fora da lista ou qualquer dado pessoal no pedido reprova.
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/features/account/application/account_controller.dart';
import 'package:app_leitura/features/account/application/account_providers.dart';
import 'package:app_leitura/features/account/data/native_sign_in.dart';
import 'package:app_leitura/features/account/data/store_age_signals.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../support/personal_builders.dart';
import 'support/account_fakes.dart';
import 'support/fake_backend.dart';

final class _SemGoogle implements GoogleTokenSource {
  @override
  Future<GoogleTokens> obtain() => throw UnimplementedError();
}

final class _SemApple implements AppleTokenSource {
  @override
  bool get isNative => true;
  @override
  Future<String> identityToken({required String hashedNonce}) =>
      throw UnimplementedError();
}

/// O que o Grátis pode chamar (login/sessão e perfil — §4.3.7).
const Set<String> permitidos = {
  'POST /auth/v1/otp',
  'POST /auth/v1/verify',
  'POST /auth/v1/logout',
  'POST /rest/v1/rpc/my_account',
  'POST /rest/v1/rpc/set_my_age_band',
  'PATCH /rest/v1/profiles',
  'POST /functions/v1/export-data',
  'POST /functions/v1/delete-account',
};

void main() {
  test('Grátis com conta: entrar, idade, @, exportar e sair só tocam login/perfil — nenhum dado pessoal sai', () async {
    final backend = FakeBackend();
    final SupabaseClient client = backend.client();
    final h = AccountHarness(
      servidor: false,
      loja: const StoreAgeUnavailable(),
    );
    final c = ProviderContainer(
      overrides: [
        ...h.deviceOverrides,
        h.relogio,
        // o gateway e a API são os reais, montados sobre o cliente do Supabase
        supabaseClientProvider.overrideWithValue(client),
        googleTokenSourceProvider.overrideWithValue(_SemGoogle()),
        appleTokenSourceProvider.overrideWithValue(_SemApple()),
      ],
    );
    addTearDown(() async {
      c.dispose();
      await client.dispose();
      await h.close();
    });
    c.listen(accountControllerProvider, (_, _) {}, fireImmediately: true);
    final ctl = c.read(accountControllerProvider.notifier);
    await ctl.settled();

    // Dados pessoais do convidado no aparelho.
    final g = await h.library.guestOwnerId();
    const titulo = 'Memórias Póstumas de Brás Cubas';
    const trecho = 'Ao verme que primeiro roeu as frias carnes';
    const nota = 'Dedicatória mais irônica da literatura brasileira';
    final livro = livroTeste(1, dono: g, title: titulo);
    await UserBooksDao(h.db).upsert(livro);
    final grifo = grifoTeste(10, livro: livro.id, dono: g, exato: trecho);
    await AnnotationsDao(h.db).upsert(grifo);
    await AnnotationsDao(h.db)
        .upsert(notaTeste(11, livro: livro.id, pai: grifo, texto: nota));
    await ReadingSessionsDao(h.db)
        .upsert(sessaoTeste(12, livro: livro.id, inicio: t0Teste, dono: g));

    // Fluxo completo do Grátis com conta.
    await ctl.checkAge(birthDate: DateTime(1987, 3, 14));
    await ctl.sendEmailCode(emailTeste);
    await ctl.verifyEmailCode(emailTeste, '123456');
    await ctl.settled();
    await ctl.chooseHandle('bras.cubas');
    await ctl.exportMyData();
    await ctl.signOut(eraseLocal: false);

    // O arquivo exportado tem os dados (vai para a pessoa, pelo menu de compartilhar)…
    final (_, exportado) = h.sink.entregas.single;
    expect(exportado, contains(titulo));
    expect(exportado, contains(nota));

    // …mas nada disso foi para a rede.
    expect(backend.pedidos, isNotEmpty);
    final fora = backend.caminhos
        .where((p) => !permitidos.contains(p))
        .toList();
    expect(
      fora,
      isEmpty,
      reason: 'endpoints fora do permitido ao Grátis: $fora',
    );
    final proibidos = [
      titulo,
      trecho,
      nota,
      livro.id,
      livro.contentSha256!,
      grifo.id,
      '1987', // a data de nascimento fica no aparelho (só a faixa sobe)
      '03-14',
      '14/03',
    ];
    for (final p in backend.pedidos) {
      final tudo = '${p.url} ${p.body}';
      for (final x in proibidos) {
        expect(
          tudo.contains(x),
          isFalse,
          reason: '"$x" saiu do aparelho em $p',
        );
      }
    }
    // Os endpoints de sincronização e de livros na nuvem (Pro) nunca aparecem.
    for (final p in backend.caminhos) {
      expect(p, isNot(contains('sync_apply_changes')));
      expect(p, isNot(contains('ebook-upload-url')));
      expect(p, isNot(contains('/storage/v1/')));
    }
    debugPrintPedidos(backend);
  });
}

void debugPrintPedidos(FakeBackend b) =>
    debugPrint('[privacidade] pedidos do Grátis: ${b.caminhos.join(', ')}');
