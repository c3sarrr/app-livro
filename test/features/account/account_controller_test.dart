// G05: convidado por padrão (D-64), idade antes do login (D-66), login (D-67), dados por conta (D-68),
// @ (onboarding), sair, excluir e exportar (D-65) — o AccountController com dublês e o banco em memória.
import 'dart:convert';

import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/features/account/application/account_controller.dart';
import 'package:app_leitura/features/account/data/store_age_signals.dart';
import 'package:app_leitura/features/account/domain/account_failure.dart';
import 'package:app_leitura/features/account/domain/age.dart';
import 'package:app_leitura/features/account/domain/auth_status.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:flutter/foundation.dart' show FlutterError, FlutterErrorDetails;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/personal_builders.dart';
import 'support/account_fakes.dart';
import 'support/fake_backend.dart';

void main() {
  late AccountHarness h;
  late ProviderContainer c;
  late List<AccountView> estados;
  var montado = false;

  void montar(AccountHarness harness) {
    montado = true;
    h = harness;
    c = ProviderContainer(overrides: [...h.overrides, h.relogio]);
    estados = [];
    c.listen(
      accountControllerProvider,
      (_, s) => estados.add(s),
      fireImmediately: true,
    );
  }

  AccountController ctl() => c.read(accountControllerProvider.notifier);
  AccountView estado() => c.read(accountControllerProvider);

  Future<void> assentar() async {
    await ctl().settled();
    await pumpEventQueue();
  }

  tearDown(() async {
    if (!montado) return;
    montado = false;
    await ctl().settled(); // a fila de sessão termina antes de fechar o banco
    c.dispose();
    await h.close();
  });

  Future<String> convidado() => h.library.guestOwnerId();

  /// Idade aceita pela data de nascimento (adulto) e login por código.
  Future<void> entrar() async {
    expect(
      await ctl().checkAge(birthDate: DateTime(1990, 5, 1)),
      isA<AgeAllowed>(),
    );
    await ctl().sendEmailCode(emailTeste);
    await ctl().verifyEmailCode(emailTeste, '123456');
    await assentar();
  }

  group('convidado (D-64)', () {
    test('sem servidor nesta versão: convidado sem login; exportar leva só o aparelho', () async {
      montar(AccountHarness(servidor: false));
      expect(estado(), const GuestView(canSignIn: false));
      await UserBooksDao(h.db).upsert(livroTeste(1, dono: await convidado()));
      final json =
          jsonDecode((await ctl().buildExport()).json) as Map<String, Object?>;
      expect(json['account'], isNull);
      expect(
        ((json['device']! as Map)['user_books']! as List).single,
        containsPair('title', 'Dom Casmurro'),
      );
      await expectLater(
        ctl().sendEmailCode(emailTeste),
        throwsA(isA<AgeCheckRequired>()),
      );
    });

    test('com servidor e sem sessão: convidado que pode entrar; o dono ativo é o convidado', () async {
      montar(AccountHarness());
      await assentar();
      expect(estado(), const GuestView(canSignIn: true));
      expect(await h.library.activeOwnerId(), await convidado());
    });
  });

  group('idade antes do login (D-66)', () {
    test('sem passar pela idade, nenhum login vai para o servidor', () async {
      montar(AccountHarness());
      for (final acao in [
        () => ctl().sendEmailCode(emailTeste),
        () => ctl().verifyEmailCode(emailTeste, '123456'),
        ctl().signInWithGoogle,
        ctl().signInWithApple,
      ]) {
        await expectLater(acao(), throwsA(isA<AgeCheckRequired>()));
      }
      expect(h.gateway!.calls, isEmpty);
    });

    test('sinal da loja primeiro: adulto pela Play Store → liberado, sem pedir a data', () async {
      montar(
        AccountHarness(
          loja: const StoreAgeRange(lower: 18, source: AgeSource.playSignal),
        ),
      );
      final r = await ctl().checkAge();
      expect(
        r,
        isA<AgeAllowed>().having(
          (a) => a.check,
          'check',
          const AgeCheck(AgeBand.adult, AgeSource.playSignal),
        ),
      );
      await ctl().signInWithGoogle();
      expect(h.gateway!.calls, ['google']);
    });

    test('loja pede verificação na Play Store → o app não troca pela data de nascimento', () async {
      montar(AccountHarness(loja: const StoreAgeVerificationNeeded()));
      expect(await ctl().checkAge(), isA<AgeStoreVerificationNeeded>());
      await expectLater(
        ctl().sendEmailCode(emailTeste),
        throwsA(isA<AgeCheckRequired>()),
      );
    });

    test('loja sem sinal → data de nascimento; data impossível pede de novo; 13 anos completos entra', () async {
      montar(AccountHarness());
      expect(await ctl().checkAge(), isA<AgeNeedsBirthDate>());
      expect(
        await ctl().checkAge(birthDate: DateTime(2030, 1, 1)),
        isA<AgeNeedsBirthDate>().having((o) => o.invalid, 'invalid', isTrue),
      );
      expect(
        await ctl().checkAge(birthDate: DateTime(2012, 10, 4)),
        isA<AgeAllowed>().having(
          (a) => a.check,
          'check',
          const AgeCheck(AgeBand.from13to15, AgeSource.birthdate),
        ),
      );
    });

    test('menor de 13: bloqueia, anula uma checagem aprovada antes e outra data não destrava', () async {
      montar(AccountHarness());
      expect(
        await ctl().checkAge(birthDate: DateTime(1990, 1, 1)),
        isA<AgeAllowed>(),
      );
      expect(
        await ctl().checkAge(birthDate: DateTime(2015, 1, 1)),
        isA<AgeBlocked>(),
      );
      await expectLater(
        ctl().sendEmailCode(emailTeste),
        throwsA(isA<AgeCheckRequired>()),
      );
      expect(
        await ctl().checkAge(birthDate: DateTime(1990, 1, 1)),
        isA<AgeBlocked>(),
      );
      expect(
        await ctl().checkAge(),
        isA<AgeBlocked>(),
        reason: 'loja sem sinal: continua bloqueado',
      );
      expect(await h.library.isUnderageBlocked(), isTrue);
      expect(h.gateway!.calls, isEmpty);
      // só a loja (13+) destrava
      h.store.resultado = const StoreAgeRange(
        lower: 18,
        source: AgeSource.playSignal,
      );
      expect(await ctl().checkAge(), isA<AgeAllowed>());
      expect(await h.library.isUnderageBlocked(), isFalse);
    });
  });

  group('entrar (D-67) e dados por conta (D-68)', () {
    test('código por e-mail → conta; a FAIXA (não a data) vai para o servidor; o convidado passa para a conta', () async {
      montar(AccountHarness());
      await assentar();
      final g = await convidado();
      await UserBooksDao(h.db).upsert(livroTeste(1, dono: g));
      await entrar();

      expect(h.gateway!.calls, ['enviar:$emailTeste', 'conferir:123456']);
      expect(h.api!.faixas, [
        const AgeCheck(AgeBand.adult, AgeSource.birthdate),
      ]);
      final s = estado();
      expect(s, isA<MemberView>());
      s as MemberView;
      expect(s.userId, contaTeste);
      expect(s.summary!.id, contaTeste);
      expect(s.needsOnboarding, isTrue, reason: '@ provisório');
      expect(await h.library.activeOwnerId(), contaTeste);
      expect(await h.library.countRows(g), 0);
      expect(
        (await UserBooksDao(h.db).byId(idTeste(1)))!.meta.userId,
        contaTeste,
      );
      // a faixa enviada uma vez só
      await ctl().refresh();
      expect(h.api!.faixas, hasLength(1));
    });

    test('sessão já guardada ao abrir: carregando → conta', () async {
      montar(
        AccountHarness(
          inicial: const SignedIn(userId: contaTeste, email: emailTeste),
        ),
      );
      expect(estados.first, const AccountLoading());
      await assentar();
      expect(
        estado(),
        isA<MemberView>().having((m) => m.summary?.id, 'id', contaTeste),
      );
    });

    test('sem internet depois do login: motivo na tela; os dados do convidado só passam com a conta confirmada', () async {
      montar(AccountHarness());
      await assentar();
      final g = await convidado();
      await UserBooksDao(h.db).upsert(livroTeste(1, dono: g));
      h.api!.falhaResumo = const OfflineFailure();
      await entrar();
      final s = estado() as MemberView;
      expect(s.summary, isNull);
      expect(s.offline, isTrue);
      expect(s.needsOnboarding, isFalse);
      expect(
        await h.library.countRows(g),
        1,
        reason: 'ainda não confirmada: nada muda de dono',
      );
      expect(await h.library.activeOwnerId(), g);
      h.api!.falhaResumo = null;
      await ctl().refresh();
      expect((estado() as MemberView).summary, isNotNull);
      expect((estado() as MemberView).problem, isNull);
      expect(await h.library.countRows(contaTeste), 1);
      expect(await h.library.activeOwnerId(), contaTeste);
    });

    test('sessão revogada: sai deste aparelho; o convidado não perde nada para a conta', () async {
      montar(AccountHarness());
      await assentar();
      final g = await convidado();
      await UserBooksDao(h.db).upsert(livroTeste(1, dono: g));
      h.api!.falhaResumo = const NotSignedIn();
      await entrar();
      expect(h.gateway!.calls.last, 'sair');
      expect(estado(), const GuestView(canSignIn: true));
      expect(await h.library.countRows(g), 1);
      expect(await h.library.countRows(contaTeste), 0);
      expect(await h.library.activeOwnerId(), g);
    });

    test('conta excluída fora do app (página web): o que era dela no aparelho fica com o convidado', () async {
      montar(AccountHarness(inicial: const SignedIn(userId: contaTeste)));
      await UserBooksDao(h.db).upsert(livroTeste(1, dono: contaTeste));
      await h.library.setActiveOwner(contaTeste);
      h.api!.falhaResumo = const AccountGone();
      await assentar();
      final g = await convidado();
      expect(h.gateway!.calls, ['sair']);
      expect(estado(), const GuestView(canSignIn: true));
      expect(await h.library.countRows(contaTeste), 0);
      expect(await h.library.countRows(g), 1);
    });

    test('falha inesperada no aparelho ao entrar: motivo na tela e "tentar de novo" (não fica carregando)', () async {
      final erros = <FlutterErrorDetails>[];
      final antes = FlutterError.onError;
      FlutterError.onError = erros.add;
      addTearDown(() => FlutterError.onError = antes);
      montar(AccountHarness());
      h.api!.falhaInesperada = StateError('banco');
      await entrar();
      expect(erros, hasLength(1));
      expect(
        estado(),
        isA<MemberView>().having(
          (m) => m.problem,
          'problem',
          isA<ServerFailure>(),
        ),
      );
      h.api!.falhaInesperada = null;
      await ctl().refresh();
      expect((estado() as MemberView).summary, isNotNull);
    });

    test(
      'erro do servidor no resumo não trava a conta (motivo na tela)',
      () async {
        montar(AccountHarness());
        h.api!.falhaResumo = const ServerFailure('pg_XX000');
        await entrar();
        expect((estado() as MemberView).problem, isA<ServerFailure>());
      },
    );

    test('conta sem faixa (entrou em outro aparelho): a idade aceita depois é registrada', () async {
      montar(AccountHarness(inicial: const SignedIn(userId: contaTeste)));
      h.api!.json = contaJson(faixa: null);
      await assentar();
      expect((estado() as MemberView).needsOnboarding, isTrue);
      await ctl().checkAge(birthDate: DateTime(2009, 1, 1));
      expect(h.api!.faixas, [
        const AgeCheck(AgeBand.from16to17, AgeSource.birthdate),
      ]);
      expect((estado() as MemberView).summary!.ageBand, AgeBand.from16to17);
    });
  });

  group('@ (concluir cadastro)', () {
    test('normaliza e grava; o cadastro fica completo', () async {
      montar(AccountHarness());
      await entrar();
      await ctl().chooseHandle('  @Ana.Lima ');
      expect(h.api!.calls, contains('arroba:ana.lima'));
      final s = estado() as MemberView;
      expect(s.summary!.handle, 'ana.lima');
      expect(s.needsOnboarding, isFalse);
    });

    test(
      'fora da regra não vai para o servidor; @ em uso volta como HandleTaken',
      () async {
        montar(AccountHarness());
        await entrar();
        await expectLater(
          ctl().chooseHandle('ab'),
          throwsA(isA<HandleInvalid>()),
        );
        await expectLater(
          ctl().chooseHandle('leitor_abc'),
          throwsA(isA<HandleInvalid>()),
        );
        expect(h.api!.calls.where((c) => c.startsWith('arroba:')), isEmpty);
        await expectLater(
          ctl().chooseHandle('tomado'),
          throwsA(isA<HandleTaken>()),
        );
      },
    );

    test('convidado não escolhe @', () async {
      montar(AccountHarness());
      await assentar();
      await expectLater(
        ctl().chooseHandle('ana.lima'),
        throwsA(isA<NotSignedIn>()),
      );
    });
  });

  group('sair (D-68: cada conta tem a sua)', () {
    test('sair e manter: os dados da conta ficam escondidos e voltam no próximo login', () async {
      montar(AccountHarness());
      await assentar();
      await UserBooksDao(h.db).upsert(livroTeste(1, dono: await convidado()));
      await entrar();
      await ctl().signOut(eraseLocal: false);
      expect(estado(), const GuestView(canSignIn: true, hiddenRows: 1));
      final g = await convidado();
      expect(await h.library.activeOwnerId(), g);
      expect(await h.library.countRows(contaTeste), 1);
      expect(await h.library.countRows(g), 0);

      // como convidado, algo novo; ao entrar de novo, junta com o que era da conta
      await UserBooksDao(h.db).upsert(livroTeste(2, dono: g));
      await entrar();
      expect(await h.library.activeOwnerId(), contaTeste);
      expect(await h.library.countRows(contaTeste), 2);
    });

    test(
      'sair e apagar: some deste aparelho (inclusive os arquivos dos livros)',
      () async {
        montar(AccountHarness());
        await entrar();
        await UserBooksDao(h.db).upsert(livroTeste(1, dono: contaTeste));
        await ReaderSettingsDao(h.db).upsert(
          ReaderSettings(
            id: contaTeste,
            meta: metaTeste(userId: contaTeste),
          ),
        );
        await ctl().signOut(eraseLocal: true);
        expect(estado(), const GuestView(canSignIn: true));
        expect(await h.library.countRows(contaTeste), 0);
      },
    );

    test('sem rede: sai do mesmo jeito (a sessão local é removida)', () async {
      montar(AccountHarness());
      await entrar();
      h.gateway!.saidaSemRede = true;
      await ctl().signOut(eraseLocal: false);
      expect(estado(), const GuestView(canSignIn: true));
    });
  });

  test('convidado apaga os dados guardados de contas que saíram', () async {
    montar(AccountHarness());
    await entrar();
    await UserBooksDao(h.db).upsert(livroTeste(1, dono: contaTeste));
    await ctl().signOut(eraseLocal: false);
    expect((estado() as GuestView).hiddenRows, 1);
    await UserBooksDao(h.db).upsert(livroTeste(2, dono: await convidado()));
    await ctl().eraseHiddenData();
    expect(estado(), const GuestView(canSignIn: true));
    expect(await h.library.countRows(contaTeste), 0);
    expect(
      await h.library.countRows(await convidado()),
      1,
      reason: 'o do convidado fica',
    );
  });

  group('excluir conta', () {
    test(
      'excluir e apagar do aparelho: servidor + aparelho; volta a convidado',
      () async {
        montar(AccountHarness());
        await entrar();
        await UserBooksDao(h.db).upsert(livroTeste(1, dono: contaTeste));
        await ctl().deleteAccount(eraseLocal: true);
        expect(h.api!.calls, contains('excluir'));
        expect(h.gateway!.calls.last, 'sair');
        expect(estado(), const GuestView(canSignIn: true));
        expect(await h.library.countRows(contaTeste), 0);
      },
    );

    test(
      'excluir e manter no aparelho: os dados passam para o convidado',
      () async {
        montar(AccountHarness());
        await entrar();
        await UserBooksDao(h.db).upsert(livroTeste(1, dono: contaTeste));
        await ctl().deleteAccount(eraseLocal: false);
        final g = await convidado();
        expect(await h.library.countRows(contaTeste), 0);
        expect(await h.library.countRows(g), 1);
        expect(await h.library.activeOwnerId(), g);
      },
    );

    test('convidado não exclui conta', () async {
      montar(AccountHarness());
      await assentar();
      await expectLater(
        ctl().deleteAccount(eraseLocal: true),
        throwsA(isA<NotSignedIn>()),
      );
      expect(h.api!.calls, isEmpty);
    });
  });

  group('exportar (D-65)', () {
    test(
      'conta: o que o servidor guarda + o que está no aparelho do dono ativo',
      () async {
        montar(AccountHarness());
        await entrar();
        await UserBooksDao(h.db).upsert(livroTeste(1, dono: contaTeste));
        await ctl().exportMyData();
        final (nome, texto) = h.sink.entregas.single;
        expect(nome, 'booknest-meus-dados-2026-10-04.json');
        final json = jsonDecode(texto) as Map<String, Object?>;
        expect(json['format_version'], 1);
        expect(json['app'], 'BookNest');
        expect(json['generated_at'], '2026-10-04T12:00:00.000Z');
        expect((json['account']! as Map)['format_version'], 2);
        expect(((json['device']! as Map)['user_books']! as List), hasLength(1));
      },
    );

    test('sem a parte do servidor (sem internet, limite do dia): o aparelho é exportado e o arquivo diz o motivo', () async {
      montar(AccountHarness());
      await entrar();
      await UserBooksDao(h.db).upsert(livroTeste(1, dono: contaTeste));
      for (final (falha, codigo) in [
        (const OfflineFailure(), 'sem_conexao'),
        (const ExportLimitReached(), 'limite_diario'),
        (const ServerFailure('fn_500'), 'erro_do_servidor'),
      ]) {
        h.api!.falhaExportacao = falha;
        expect(await ctl().exportMyData(), same(falha));
        final json =
            jsonDecode(h.sink.entregas.last.$2) as Map<String, Object?>;
        expect(json['account'], isNull);
        expect(json['account_unavailable'], codigo);
        expect(((json['device']! as Map)['user_books']! as List), hasLength(1));
      }
      h.api!.falhaExportacao = null;
      expect(await ctl().exportMyData(), isNull);
      final completo =
          jsonDecode(h.sink.entregas.last.$2) as Map<String, Object?>;
      expect(completo.containsKey('account_unavailable'), isFalse);
    });
  });

  test('exportFileName usa a data UTC', () {
    expect(
      exportFileName(DateTime.utc(2026, 12, 31, 23, 59)),
      'booknest-meus-dados-2026-12-31.json',
    );
  });

  test('SignedIn/SignedOut: igualdade por valor (a fila não repete o mesmo estado)', () {
    expect(const SignedIn(userId: 'a'), const SignedIn(userId: 'a'));
    expect(const SignedIn(userId: 'a'), isNot(const SignedIn(userId: 'b')));
    expect(const SignedOut(), const SignedOut());
  });
}
