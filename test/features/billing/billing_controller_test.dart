// G22.3 — o estado do Pro (docs/progresso/G22.md §3): a conta configura o RevenueCat (R1) — o Grátis que nunca
// comprou neste aparelho só quando age (G22.7: o Grátis sem compra não fala com o RevenueCat) —, a tela mostra o Pro
// da loja e o do servidor, e a ativação (R2) confere no servidor com o recuo até ele confirmar. Sem chave, nada.
import 'dart:async';

import 'package:app_leitura/core/config/server_providers.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/features/account/application/account_controller.dart';
import 'package:app_leitura/features/account/domain/account_failure.dart';
import 'package:app_leitura/features/billing/application/billing_controller.dart';
import 'package:app_leitura/features/billing/application/billing_providers.dart';
import 'package:app_leitura/features/billing/domain/billing_models.dart';
import 'package:app_leitura/features/home/application/home_providers.dart'
    show clockProvider;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart'
    show FlutterError, FlutterErrorDetails, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/billing_fakes.dart';

void main() {
  late LojaFalsa loja;
  late ServidorProFalso servidor;
  late ContaFalsa conta;
  late List<Duration> esperas;
  late ProviderContainer c;
  late MemoriaFalsa memoria;

  /// O recuo da ativação (R2): 1, 2, 4, 8, 16 e 29 s.
  const recuo = [1, 2, 4, 8, 16, 29];

  ProviderContainer container(
    AccountView inicial, {
    bool comLoja = true,
    Future<void> Function(Duration)? esperar,
    Set<String> usadas = const {},
  }) {
    conta = ContaFalsa(inicial);
    memoria = MemoriaFalsa({...usadas});
    final cc = ProviderContainer(
      overrides: [
        accountControllerProvider.overrideWith(() => conta),
        billingGatewayProvider.overrideWithValue(comLoja ? loja : null),
        proServerApiProvider.overrideWithValue(servidor),
        billingStoreMemoryProvider.overrideWithValue(memoria),
        billingSleepProvider.overrideWithValue(
          esperar ??
              (d) async {
                esperas.add(d);
              },
        ),
        clockProvider.overrideWithValue(() => agora),
      ],
    );
    addTearDown(cc.dispose);
    // o controller vive enquanto alguém o escuta (como o app)
    cc.listen(billingControllerProvider, (_, _) {});
    return cc;
  }

  ProView estado() => c.read(billingControllerProvider);
  ProReady pronto() => estado() as ProReady;

  setUp(() {
    loja = LojaFalsa();
    servidor = ServidorProFalso();
    esperas = [];
  });

  test('sem chave do RevenueCat: indisponível e nenhuma chamada', () async {
    c = container(membro(contaA), comLoja: false);
    await pumpEventQueue();
    expect(estado(), isA<ProUnavailable>());
    expect(servidor.chamadas, isEmpty);
  });

  test('convidado: o RevenueCat não é configurado (R1)', () async {
    c = container(const GuestView(canSignIn: true));
    await pumpEventQueue();
    expect(estado(), isA<ProUnavailable>());
    expect(loja.chamadas, isEmpty);
  });

  test('Grátis que nunca usou a loja neste aparelho: o RevenueCat fica quieto; a tela tem o Grátis do servidor', () async {
    c = container(membro(contaA));
    await pumpEventQueue();
    expect(loja.chamadas, isEmpty);
    expect(pronto().customer, ProCustomer.none);
    expect(pronto().serverPro, isFalse);
    expect(pronto().activating, isFalse);
  });

  test('Pro no servidor: configura com o id do Supabase e a tela tem o Pro da loja', () async {
    loja.cliente = proDaLoja;
    c = container(membro(contaA, pro: true));
    await pumpEventQueue();
    expect(loja.chamadas, ['configure:$contaA', 'customer']);
    expect(pronto().customer, proDaLoja);
    expect(pronto().serverPro, isTrue);
  });

  test(
    'a conta já comprou ou restaurou neste aparelho: configura ao entrar',
    () async {
      c = container(membro(contaA), usadas: {contaA});
      await pumpEventQueue();
      expect(loja.chamadas, ['configure:$contaA', 'customer']);
    },
  );

  test(
    'trocar de conta é logIn com a nova; sair é logOut e indisponível',
    () async {
      c = container(membro(contaA, pro: true));
      await pumpEventQueue();
      conta.mudar(membro(contaB, pro: true));
      await pumpEventQueue();
      conta.mudar(const GuestView(canSignIn: true));
      await pumpEventQueue();
      expect(loja.chamadas, [
        'configure:$contaA',
        'customer',
        'logIn:$contaB',
        'logOut',
      ]);
      expect(estado(), isA<ProUnavailable>());
    },
  );

  test('trocar para uma conta Grátis que nunca usou a loja: sai do RevenueCat da anterior', () async {
    c = container(membro(contaA, pro: true));
    await pumpEventQueue();
    conta.mudar(membro(contaB));
    await pumpEventQueue();
    expect(loja.chamadas, ['configure:$contaA', 'customer', 'logOut']);
    expect(pronto().customer, ProCustomer.none);
    // e a volta para uma conta que usa a loja é logIn (o SDK já está configurado)
    conta.mudar(membro(contaA, pro: true));
    await pumpEventQueue();
    expect(loja.chamadas.last, 'logIn:$contaA');
  });

  test('o servidor virou Pro (comprou em outro aparelho): configura e o estado chega à tela', () async {
    c = container(membro(contaA));
    await pumpEventQueue();
    loja.cliente = proDaLoja;
    conta.mudar(membro(contaA, pro: true));
    await pumpEventQueue();
    expect(pronto().serverPro, isTrue);
    expect(pronto().customer, proDaLoja);
    expect(loja.chamadas, ['configure:$contaA', 'customer']);
  });

  group('a ativação (R2)', () {
    test('a loja diz Pro e o servidor não: conferir agora, o recuo até confirmar e o resumo relido uma vez', () async {
      loja.cliente = proDaLoja;
      servidor.respostas.addAll([
        (pro: false, activeUntil: null),
        (pro: false, activeUntil: null),
        (pro: true, activeUntil: proAte),
      ]);
      final vistos = <bool>[];
      c = container(membro(contaA), usadas: {contaA});
      c.listen(billingControllerProvider, (_, n) {
        if (n is ProReady) vistos.add(n.activating);
      });
      conta.proNoServidor = true;
      await pumpEventQueue();
      expect(servidor.chamadas, ['syncNow', 'current', 'current', 'current']);
      expect(esperas, [for (final s in recuo.take(3)) Duration(seconds: s)]);
      expect(conta.releituras, 1);
      expect(vistos, contains(true));
      expect(pronto().activating, isFalse);
      expect(pronto().serverPro, isTrue);
      expect(pronto().notice, isNull);
    });

    test('o conferir agora já confirma: sem recuo', () async {
      loja.cliente = proDaLoja;
      servidor.aoConferir = (pro: true, activeUntil: proAte);
      c = container(membro(contaA), usadas: {contaA});
      conta.proNoServidor = true;
      await pumpEventQueue();
      expect(servidor.chamadas, ['syncNow']);
      expect(esperas, isEmpty);
      expect(conta.releituras, 1);
    });

    test('o conferir agora falha (RevenueCat fora do ar): o recuo tenta o conferir agora e lê o servidor', () async {
      loja.cliente = proDaLoja;
      servidor.falhaAoConferir = Exception('502');
      servidor.respostas.add((pro: true, activeUntil: proAte));
      c = container(membro(contaA), usadas: {contaA});
      conta.proNoServidor = true;
      await pumpEventQueue();
      expect(servidor.chamadas, ['syncNow', 'syncNow', 'current']);
      expect(conta.releituras, 1);
    });

    test('nunca confirma: para depois de ≈ 60 s com o aviso, e tenta de novo ao voltar ao app', () async {
      loja.cliente = proDaLoja;
      c = container(membro(contaA), usadas: {contaA});
      await pumpEventQueue();
      expect(esperas, [for (final s in recuo) Duration(seconds: s)]);
      expect(
        esperas.fold(Duration.zero, (a, b) => a + b),
        const Duration(seconds: 60),
      );
      expect(pronto().activating, isFalse);
      expect(
        pronto().notice,
        'O Pro ainda não chegou ao servidor. A sincronização liga assim que ele confirmar.',
      );
      expect(conta.releituras, 0);

      servidor.chamadas.clear();
      servidor.respostas.add((pro: true, activeUntil: proAte));
      conta.proNoServidor = true;
      c.read(billingControllerProvider.notifier).resumed();
      await pumpEventQueue();
      expect(servidor.chamadas.first, 'syncNow');
      expect(conta.releituras, 1);
      expect(pronto().serverPro, isTrue);
    });

    test('voltar ao app sem ativação pendente e sem Pro na loja não chama o servidor', () async {
      c = container(membro(contaA), usadas: {contaA});
      await pumpEventQueue();
      c.read(billingControllerProvider.notifier).resumed();
      await pumpEventQueue();
      expect(servidor.chamadas, isEmpty);
    });

    test('D-236: volta ao app com a loja Pro e o período do servidor vencido (a renovação ainda sem webhook): '
        'confere uma vez e ativa', () async {
      loja.cliente = proDaLoja;
      c = container(membro(contaA, pro: true));
      await pumpEventQueue();
      expect(servidor.chamadas, isEmpty);
      servidor.respostas.add((pro: false, activeUntil: null));
      servidor.aoConferir = (pro: true, activeUntil: proAte);
      conta.proNoServidor = true;
      c.read(billingControllerProvider.notifier).resumed();
      await pumpEventQueue();
      expect(servidor.chamadas, ['current', 'syncNow']);
      expect(conta.releituras, 1);
      expect(pronto().serverPro, isTrue);
      expect(pronto().notice, isNull);
    });

    test(
      'D-236: volta ao app com a loja e o servidor Pro: só confere',
      () async {
        loja.cliente = proDaLoja;
        c = container(membro(contaA, pro: true));
        await pumpEventQueue();
        servidor.respostas.add((pro: true, activeUntil: proAte));
        c.read(billingControllerProvider.notifier).resumed();
        await pumpEventQueue();
        expect(servidor.chamadas, ['current']);
        expect(conta.releituras, 0);
        expect(pronto().serverPro, isTrue);
      },
    );

    test(
      'D-236: duas voltas seguidas conferem uma vez; sem rede, nada muda',
      () async {
        loja.cliente = proDaLoja;
        c = container(membro(contaA, pro: true));
        await pumpEventQueue();
        final segura = servidor.segurarLeitura = Completer<void>();
        servidor.falhaAoLer = Exception('sem rede');
        c.read(billingControllerProvider.notifier)
          ..resumed()
          ..resumed();
        segura.complete();
        await pumpEventQueue();
        expect(servidor.chamadas, ['current']);
        expect(pronto().serverPro, isTrue);
        expect(pronto().notice, isNull);
        // a próxima volta confere de novo
        servidor
          ..segurarLeitura = null
          ..falhaAoLer = null
          ..respostas.add((pro: true, activeUntil: proAte));
        c.read(billingControllerProvider.notifier).resumed();
        await pumpEventQueue();
        expect(servidor.chamadas, ['current', 'current']);
      },
    );

    test(
      'D-236: a conta troca enquanto confere: nada da conta antiga segue',
      () async {
        loja.cliente = proDaLoja;
        c = container(membro(contaA, pro: true));
        await pumpEventQueue();
        final segura = servidor.segurarLeitura = Completer<void>();
        servidor.respostas.add((pro: false, activeUntil: null));
        c.read(billingControllerProvider.notifier).resumed();
        loja.cliente = ProCustomer.none;
        conta.mudar(membro(contaB));
        await pumpEventQueue();
        segura.complete();
        await pumpEventQueue();
        expect(servidor.chamadas, ['current']);
        expect(conta.releituras, 0);
      },
    );

    test('a conta troca no meio da ativação: nada da conta antiga segue', () async {
      loja.cliente = proDaLoja;
      var primeira = true;
      c = container(
        membro(contaA),
        usadas: {contaA},
        esperar: (d) async {
          esperas.add(d);
          if (primeira) {
            primeira = false;
            loja.cliente = ProCustomer.none;
            conta.mudar(membro(contaB));
          }
        },
      );
      await pumpEventQueue();
      // a ativação da A parou na 1ª espera: nenhum `current`, nenhuma releitura
      expect(servidor.chamadas, ['syncNow']);
      expect(conta.releituras, 0);
      // a B nunca usou a loja: o RevenueCat sai da A e fica quieto
      expect(loja.chamadas.last, 'logOut');
      expect(pronto().activating, isFalse);
      expect(pronto().notice, isNull);
    });

    test(
      'a loja avisa uma mudança (renovação desligada): o estado muda',
      () async {
        loja.cliente = proDaLoja;
        servidor.aoConferir = (pro: true, activeUntil: proAte);
        c = container(membro(contaA, pro: true));
        await pumpEventQueue();
        loja.avisar(
          ProCustomer(active: true, activeUntil: proAte, store: 'testStore'),
        );
        await pumpEventQueue();
        expect(pronto().customer.willRenew, isFalse);
      },
    );

    test('a loja avisa que virou Pro (compra em outro aparelho) e o servidor ainda não: ativa', () async {
      c = container(membro(contaA), usadas: {contaA});
      await pumpEventQueue();
      servidor.aoConferir = (pro: true, activeUntil: proAte);
      conta.proNoServidor = true;
      loja.avisar(proDaLoja);
      await pumpEventQueue();
      expect(servidor.chamadas, ['syncNow']);
      expect(conta.releituras, 1);
    });
  });

  group('revisão independente (G22.7)', () {
    test('I1: a conta chega sem o resumo e depois Pro: não ativa enquanto não sabe o Pro do servidor', () async {
      loja.cliente = proDaLoja;
      c = container(const MemberView(userId: contaA), usadas: {contaA});
      await pumpEventQueue();
      expect(pronto().customer, proDaLoja);
      expect(servidor.chamadas, isEmpty);
      conta.mudar(membro(contaA, pro: true));
      await pumpEventQueue();
      expect(servidor.chamadas, isEmpty);
      expect(pronto().serverPro, isTrue);
    });

    test(
      'I1: sem o resumo e depois Grátis no servidor com a loja Pro: aí ativa',
      () async {
        loja.cliente = proDaLoja;
        servidor.aoConferir = (pro: true, activeUntil: proAte);
        c = container(const MemberView(userId: contaA), usadas: {contaA});
        await pumpEventQueue();
        expect(servidor.chamadas, isEmpty);
        conta.proNoServidor = true;
        conta.mudar(membro(contaA));
        await pumpEventQueue();
        expect(servidor.chamadas, ['syncNow']);
        expect(conta.releituras, 1);
        expect(pronto().serverPro, isTrue);
      },
    );

    test(
      'I1: o resumo que não chegou (servidor fora) não vira Grátis',
      () async {
        loja.cliente = proDaLoja;
        c = container(membro(contaA, pro: true));
        await pumpEventQueue();
        conta.mudar(
          const MemberView(userId: contaA, problem: ServerFailure('fora')),
        );
        await pumpEventQueue();
        expect(pronto().serverPro, isTrue);
        expect(servidor.chamadas, isEmpty);
      },
    );

    test('I2: a assinatura cancelada venceu com o app fechado: voltar relê a loja e não ativa', () async {
      loja.cliente = ProCustomer(
        active: true,
        activeUntil: agora.subtract(const Duration(hours: 1)),
        store: 'testStore',
      );
      c = container(membro(contaA, pro: true));
      await pumpEventQueue();
      servidor.respostas.add((pro: false, activeUntil: null));
      loja.clientes.add(ProCustomer.none);
      c.read(billingControllerProvider.notifier).resumed();
      await pumpEventQueue();
      expect(servidor.chamadas, isEmpty);
      expect(pronto().customer.active, isFalse);
    });

    test('I2: o servidor diz que não e a loja relida também: para sem aviso e sem nova tentativa', () async {
      loja.clientes.addAll([proDaLoja, ProCustomer.none]);
      c = container(membro(contaA), usadas: {contaA});
      await pumpEventQueue();
      expect(servidor.chamadas, ['syncNow']);
      expect(esperas, isEmpty);
      expect(pronto().activating, isFalse);
      expect(pronto().notice, isNull);
      expect(pronto().customer.active, isFalse);
      servidor.chamadas.clear();
      c.read(billingControllerProvider.notifier).resumed();
      await pumpEventQueue();
      expect(servidor.chamadas, isEmpty);
    });

    test(
      'I2: a loja avisa que deixou de ser Pro no meio do recuo: para sem aviso',
      () async {
        loja.cliente = proDaLoja;
        var primeira = true;
        c = container(
          membro(contaA),
          usadas: {contaA},
          esperar: (d) async {
            esperas.add(d);
            if (primeira) {
              primeira = false;
              loja.avisar(ProCustomer.none);
            }
          },
        );
        await pumpEventQueue();
        expect(esperas, hasLength(1));
        expect(pronto().activating, isFalse);
        expect(pronto().notice, isNull);
      },
    );

    test(
      'm2: o conferir agora falhou: o recuo tenta o conferir agora de novo',
      () async {
        loja.cliente = proDaLoja;
        servidor.falhaAoConferir = Exception('502');
        var primeira = true;
        c = container(
          membro(contaA),
          usadas: {contaA},
          esperar: (d) async {
            esperas.add(d);
            if (primeira) {
              primeira = false;
              servidor
                ..falhaAoConferir = null
                ..aoConferir = (pro: true, activeUntil: proAte);
            }
          },
        );
        conta.proNoServidor = true;
        await pumpEventQueue();
        expect(servidor.chamadas, ['syncNow', 'syncNow']);
        expect(conta.releituras, 1);
      },
    );

    test(
      'I4: a ativação da conta anterior, parada no recuo, não segura a da nova',
      () async {
        loja.cliente = proDaLoja;
        final segura = Completer<void>();
        var primeira = true;
        c = container(
          membro(contaA),
          usadas: {contaA, contaB},
          esperar: (d) async {
            esperas.add(d);
            if (primeira) {
              primeira = false;
              await segura.future;
            }
          },
        );
        await pumpEventQueue();
        expect(servidor.chamadas, ['syncNow']);
        servidor.aoConferir = (pro: true, activeUntil: proAte);
        conta.proNoServidor = true;
        conta.mudar(membro(contaB));
        await pumpEventQueue();
        expect(servidor.chamadas, ['syncNow', 'syncNow']);
        expect(conta.releituras, 1);
        segura.complete();
        await pumpEventQueue();
        // a da A sai na volta do recuo, sem reler nada
        expect(conta.releituras, 1);
        expect(servidor.chamadas, ['syncNow', 'syncNow']);
      },
    );

    test(
      'I4: um aviso da loja que não é da conta de agora é ignorado',
      () async {
        loja.cliente = proDaLoja;
        c = container(membro(contaA, pro: true), usadas: {contaA});
        await pumpEventQueue();
        loja.cliente = ProCustomer.none;
        conta.mudar(
          membro(contaB),
        ); // a B nunca usou a loja: o RevenueCat sai da A
        await pumpEventQueue();
        expect(loja.chamadas.last, 'logOut');
        loja.avisar(proDaLoja);
        await pumpEventQueue();
        expect(pronto().customer, ProCustomer.none);
        expect(servidor.chamadas, isEmpty);
      },
    );

    test('m3: a loja não conecta ao entrar (sem rede): a tela sai do "Configurando" com o Pro do servidor', () async {
      loja.falhaAoConectar = const BillingOffline();
      c = container(membro(contaA, pro: true));
      await pumpEventQueue();
      expect(pronto().serverPro, isTrue);
      expect(pronto().customer, ProCustomer.none);
    });
  });

  group('o que a cobertura achou (G22.7, escrito depois do código)', () {
    /// O erro inesperado é avisado pelo FlutterError (aqui, só contado).
    List<FlutterErrorDetails> erros() {
      final vistos = <FlutterErrorDetails>[];
      final antes = FlutterError.onError;
      FlutterError.onError = vistos.add;
      addTearDown(() => FlutterError.onError = antes);
      return vistos;
    }

    test('os pacotes: o Grátis que abre a tela técnica liga a loja; sem conta, nenhum', () async {
      c = container(membro(contaA));
      await pumpEventQueue();
      expect(loja.chamadas, isEmpty);
      final pacotes = await c
          .read(billingControllerProvider.notifier)
          .packages();
      expect(pacotes, [mensal, anual]);
      expect(loja.chamadas, ['configure:$contaA', 'customer', 'packages']);
      conta.mudar(const GuestView(canSignIn: true));
      await pumpEventQueue();
      expect(
        await c.read(billingControllerProvider.notifier).packages(),
        isEmpty,
      );
    });

    test('um erro que não é da loja ao entrar: avisado, e a tela sai do "Configurando"', () async {
      final vistos = erros();
      loja.falhaAoConectar = StateError('inesperado');
      c = container(membro(contaA, pro: true));
      await pumpEventQueue();
      expect(vistos, hasLength(1));
      expect(pronto().serverPro, isTrue);
    });

    test(
      'um erro inesperado numa ação: avisado, "Não deu certo" e a fila segue',
      () async {
        final vistos = erros();
        c = container(membro(contaA));
        await pumpEventQueue();
        loja.compra = StateError('inesperado');
        await c.read(billingControllerProvider.notifier).purchase(mensal);
        expect(vistos, hasLength(1));
        expect(pronto().notice, failedNotice);
        loja.compra = const PurchaseCancelled();
        await c.read(billingControllerProvider.notifier).purchase(mensal);
        expect(
          loja.chamadas.where((x) => x.startsWith('purchase')),
          hasLength(2),
        );
      },
    );

    test('um erro inesperado ao ler os pacotes chega a quem pediu', () async {
      c = container(membro(contaA));
      await pumpEventQueue();
      loja.falhaAoConectar = StateError('inesperado');
      await expectLater(
        c.read(billingControllerProvider.notifier).packages(),
        throwsStateError,
      );
    });

    test(
      'a conta carregando não muda nada; ativar sem conta não faz nada',
      () async {
        c = container(const GuestView(canSignIn: true));
        await pumpEventQueue();
        conta.mudar(const AccountLoading());
        await pumpEventQueue();
        expect(estado(), isA<ProUnavailable>());
        await c.read(billingControllerProvider.notifier).activate();
        expect(servidor.chamadas, isEmpty);
      },
    );

    test(
      'a loja deixa de dizer Pro na última espera do recuo: para sem aviso',
      () async {
        loja.cliente = proDaLoja;
        c = container(
          membro(contaA),
          usadas: {contaA},
          esperar: (d) async {
            esperas.add(d);
            if (esperas.length == recuo.length) loja.avisar(ProCustomer.none);
          },
        );
        await pumpEventQueue();
        expect(esperas, hasLength(recuo.length));
        expect(pronto().notice, isNull);
        expect(pronto().activating, isFalse);
      },
    );
  });

  test('mutação (M23): a loja com o Pro "ativo" e o período vencido, sem carência, não ativa; com a carência, ativa', () async {
    loja.cliente = ProCustomer(
      active: true,
      activeUntil: agora.subtract(const Duration(hours: 1)),
      store: 'testStore',
    );
    c = container(membro(contaA), usadas: {contaA});
    await pumpEventQueue();
    expect(servidor.chamadas, isEmpty);
    servidor.aoConferir = (pro: true, activeUntil: proAte);
    conta.proNoServidor = true;
    loja.avisar(
      ProCustomer(
        active: true,
        activeUntil: agora.subtract(const Duration(hours: 1)),
        billingIssue: true,
        graceUntil: agora.add(const Duration(days: 2)),
        store: 'testStore',
      ),
    );
    await pumpEventQueue();
    expect(servidor.chamadas, ['syncNow']);
  });

  group('a chave pelo env (o build de produção não usa a da Test Store)', () {
    test('a da plataforma', () {
      expect(
        billingKeyFor(
          android: 'goog_a',
          ios: 'appl_i',
          platform: TargetPlatform.android,
          release: true,
        ),
        'goog_a',
      );
      expect(
        billingKeyFor(
          android: 'goog_a',
          ios: 'appl_i',
          platform: TargetPlatform.iOS,
          release: true,
        ),
        'appl_i',
      );
    });

    test('vazia, o modelo do env ou fora do celular: nenhuma', () {
      for (final k in ['', '<chave pública goog_… — G07>']) {
        expect(
          billingKeyFor(
            android: k,
            ios: k,
            platform: TargetPlatform.android,
            release: false,
          ),
          isNull,
        );
      }
      expect(
        billingKeyFor(
          android: 'goog_a',
          ios: 'appl_i',
          platform: TargetPlatform.windows,
          release: false,
        ),
        isNull,
      );
    });

    test('a da Test Store só fora do build de produção', () {
      expect(
        billingKeyFor(
          android: 'test_x',
          ios: '',
          platform: TargetPlatform.android,
          release: true,
        ),
        isNull,
      );
      expect(
        billingKeyFor(
          android: 'test_x',
          ios: '',
          platform: TargetPlatform.android,
          release: false,
        ),
        'test_x',
      );
    });

    test('sem a chave no env (os testes, o Windows): o gateway é nulo', () {
      final cc = ProviderContainer(
        overrides: [supabaseClientProvider.overrideWithValue(null)],
      );
      addTearDown(cc.dispose);
      expect(cc.read(billingGatewayProvider), isNull);
      expect(cc.read(proServerApiProvider), isNull);
    });
  });

  test('a lembrança do aparelho fica no kv, por conta', () async {
    final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    addTearDown(db.close);
    final m = KvBillingStoreMemory(() async => KvDao(db));
    expect(await m.used(contaA), isFalse);
    await m.markUsed(contaA);
    expect(await m.used(contaA), isTrue);
    expect(await m.used(contaB), isFalse);
  });
}
