// Operações da conta no servidor (resumo, faixa etária, @, exportação e exclusão) sobre o cliente REAL
// do Supabase com o servidor de mentira: o que vai na rede, com o JWT de quem está logado, e os erros.
import 'package:app_leitura/features/account/data/account_api.dart';
import 'package:app_leitura/features/account/domain/account_failure.dart';
import 'package:app_leitura/features/account/domain/age.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show OtpType, SupabaseClient;

import 'support/fake_backend.dart';

void main() {
  late FakeBackend backend;
  late SupabaseClient client;
  late SupabaseAccountApi api;

  Future<void> montar({
    Map<String, Resposta>? respostas,
    bool logado = true,
  }) async {
    backend = FakeBackend(respostas: respostas);
    client = backend.client();
    api = SupabaseAccountApi(client);
    if (logado) {
      await client.auth.verifyOTP(
        email: emailTeste,
        token: '123456',
        type: OtpType.email,
      );
      backend.pedidos.clear();
    }
  }

  setUp(montar);
  tearDown(() => client.dispose());

  Future<void> trocar({
    Map<String, Resposta>? respostas,
    bool logado = true,
  }) async {
    await client.dispose();
    await montar(respostas: respostas, logado: logado);
  }

  test('resumo: POST /rest/v1/rpc/my_account com o JWT da conta', () async {
    final s = await api.summary();
    expect(s.id, contaTeste);
    expect(s.handleProvisional, isTrue);
    expect(backend.caminhos, ['POST /rest/v1/rpc/my_account']);
    expect(backend.pedidos.single.jwt, client.auth.currentSession!.accessToken);
  });

  test('sem login: nada vai para a rede (NotSignedIn)', () async {
    await trocar(logado: false);
    await expectLater(api.summary(), throwsA(isA<NotSignedIn>()));
    await expectLater(api.setHandle('ana.lima'), throwsA(isA<NotSignedIn>()));
    await expectLater(api.exportServerData(), throwsA(isA<NotSignedIn>()));
    await expectLater(api.deleteAccount(), throwsA(isA<NotSignedIn>()));
    expect(backend.pedidos, isEmpty);
  });

  test('faixa etária: só a FAIXA e a FONTE vão para o servidor; menor de 13 nem sai do aparelho', () async {
    await api.recordAge(
      const AgeCheck(AgeBand.from16to17, AgeSource.birthdate),
    );
    expect(backend.caminhos, ['POST /rest/v1/rpc/set_my_age_band']);
    expect(backend.pedidos.single.json, {
      'p_band': '16_17',
      'p_source': 'birthdate',
    });

    backend.pedidos.clear();
    await expectLater(
      api.recordAge(const AgeCheck(AgeBand.under13, AgeSource.playSignal)),
      throwsA(isA<Underage>()),
    );
    expect(backend.pedidos, isEmpty);
  });

  test('@: PATCH /rest/v1/profiles?id=eq.<conta> só com o handle', () async {
    await api.setHandle('ana.lima');
    final p = backend.pedidos.single;
    expect(p.method, 'PATCH');
    expect(p.path, '/rest/v1/profiles');
    expect(p.url.queryParameters['id'], 'eq.$contaTeste');
    expect(p.json, {'handle': 'ana.lima'});
  });

  test('erros do @ e da faixa viram falhas da conta', () async {
    Future<void> espera(Resposta r, Matcher m) async {
      await trocar(
        respostas: {
          'PATCH /rest/v1/profiles': r,
          'POST /rest/v1/rpc/set_my_age_band': r,
        },
      );
      await expectLater(api.setHandle('ana.lima'), throwsA(m));
    }

    await espera(
      erroPostgrest(
        409,
        '23505',
        'duplicate key value violates unique constraint',
      ),
      isA<HandleTaken>(),
    );
    await espera(
      erroPostgrest(400, '22023', 'handle_reserved'),
      isA<HandleInvalid>(),
    );
    await espera(
      erroPostgrest(400, '23514', 'check constraint'),
      isA<HandleInvalid>(),
    );
    await espera(
      erroPostgrest(400, 'P0001', 'content_blocked'),
      isA<ContentBlocked>(),
    );
    await espera(
      erroPostgrest(401, 'PGRST301', 'JWT expired'),
      isA<NotSignedIn>(),
    );
    await espera(
      erroPostgrest(400, 'XX000', 'boom'),
      isA<ServerFailure>().having((f) => f.code, 'code', 'pg_XX000'),
    );

    await espera(
      erroPostgrest(403, '42501', 'permission denied'),
      isA<ServerFailure>().having((f) => f.code, 'code', 'pg_42501'),
    ); // falta de permissão é defeito do servidor — não desloga ninguém

    await trocar(
      respostas: {
        'POST /rest/v1/rpc/set_my_age_band': erroPostgrest(
          400,
          'P0001',
          'underage',
        ),
      },
    );
    await expectLater(
      api.recordAge(const AgeCheck(AgeBand.adult, AgeSource.birthdate)),
      throwsA(isA<Underage>()),
    );
    // chave duplicada fora da troca do @ não é "@ em uso"
    await trocar(
      respostas: {
        'POST /rest/v1/rpc/set_my_age_band': erroPostgrest(
          409,
          '23505',
          'duplicate key',
        ),
      },
    );
    await expectLater(
      api.recordAge(const AgeCheck(AgeBand.adult, AgeSource.birthdate)),
      throwsA(isA<ServerFailure>()),
    );
  });

  test(
    'sessão válida e nenhum perfil (conta excluída fora do app) → AccountGone',
    () async {
      await trocar(respostas: {'POST /rest/v1/rpc/my_account': (200, null)});
      await expectLater(api.summary(), throwsA(isA<AccountGone>()));
    },
  );

  test('exportação: POST /functions/v1/export-data com o JWT; 429 = limite do dia; 401 = sem login', () async {
    final dados = await api.exportServerData();
    expect(dados['format_version'], 2);
    expect(backend.caminhos, ['POST /functions/v1/export-data']);
    expect(backend.pedidos.single.jwt, client.auth.currentSession!.accessToken);

    await trocar(
      respostas: {
        'POST /functions/v1/export-data': (
          429,
          {'erro': 'limite_diario_de_exportacoes'},
        ),
      },
    );
    await expectLater(
      api.exportServerData(),
      throwsA(isA<ExportLimitReached>()),
    );
    await trocar(
      respostas: {
        'POST /functions/v1/export-data': (401, {'erro': 'nao_autenticado'}),
      },
    );
    await expectLater(api.exportServerData(), throwsA(isA<NotSignedIn>()));
    await trocar(
      respostas: {
        'POST /functions/v1/export-data': (500, {'erro': 'falha'}),
      },
    );
    await expectLater(
      api.exportServerData(),
      throwsA(isA<ServerFailure>().having((f) => f.code, 'code', 'fn_500')),
    );
  });

  test(
    'exclusão: POST /functions/v1/delete-account com {confirmar: true}',
    () async {
      await api.deleteAccount();
      expect(backend.caminhos, ['POST /functions/v1/delete-account']);
      expect(backend.pedidos.single.json, {'confirmar': true});
    },
  );

  test('sem rede → OfflineFailure (banco e funções)', () async {
    backend.offline = true;
    await expectLater(api.summary(), throwsA(isA<OfflineFailure>()));
    await expectLater(api.exportServerData(), throwsA(isA<OfflineFailure>()));
    await expectLater(api.deleteAccount(), throwsA(isA<OfflineFailure>()));
  });
}
