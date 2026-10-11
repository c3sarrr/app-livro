// G07.5 / D-76 — tela do scanner no app real (roteador + shell), com a câmera de mentira e as camadas
// do catálogo de mentira: livro achado → estante; já na estante (D-77) sem rede; não achou → digitar ou
// ler a capa → estante e, só com o toque explícito, envio à comunidade (D-74); sem permissão; sem rede.
import 'package:app_leitura/app/router.dart';
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/features/catalog/application/catalog_providers.dart';
import 'package:app_leitura/features/catalog/application/isbn_resolver.dart';
import 'package:app_leitura/features/catalog/data/catalog_cache_dao.dart';
import 'package:app_leitura/features/catalog/data/community_catalog_api.dart';
import 'package:app_leitura/features/catalog/domain/catalog_book.dart';
import 'package:app_leitura/features/catalog/domain/catalog_failure.dart';
import 'package:app_leitura/features/catalog/domain/community.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/scanner/application/scanned_shelf.dart';
import 'package:app_leitura/features/scanner/application/scanner_controller.dart';
import 'package:app_leitura/features/scanner/data/cover_reader.dart';
import 'package:app_leitura/features/scanner/domain/cover_text.dart';
import 'package:app_leitura/features/scanner/presentation/scanner_camera.dart';
import 'package:app_leitura/features/scanner/presentation/scanner_screen.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart' show TextField;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/canvas.dart';
import '../../support/fake_scanner_camera.dart';
import '../../support/load_fonts.dart';
import '../../support/personal_builders.dart';
import '../../support/pump_app.dart';
import '../account/support/account_finders.dart';
import '../catalog/support/catalog_fakes.dart';

const _achado = '9788535902778';
const _sumido = '9786586490008';

final class _Comunidade implements CommunityCatalogApi {
  final Map<String, List<CommunitySuggestion>> pendentes = {};
  final List<Map<String, Object?>> envios = [];
  final List<String> confirmacoes = [];
  final List<String> consultas = [];

  @override
  Future<CommunityLookup> lookup(String isbn13) async {
    consultas.add(isbn13);
    return CommunityLookup(pending: pendentes[isbn13] ?? const []);
  }

  @override
  Future<CommunityContribution> submit({
    required String isbn13,
    required String title,
    required String authors,
    String? publisher,
  }) async {
    envios.add({
      'isbn13': isbn13,
      'title': title,
      'authors': authors,
      'publisher': publisher,
    });
    return const ContributionPending('01927a00-0000-7000-8000-0000000000e1');
  }

  @override
  Future<CommunityContribution> confirm(String submissionId) async {
    confirmacoes.add(submissionId);
    return ContributionConfirmed(submissionId);
  }
}

final class _Capa implements CoverReader {
  _Capa(this.linhas);
  final List<CoverLine>? linhas;
  int leituras = 0;

  @override
  Future<List<CoverLine>?> read() async {
    leituras++;
    return linhas;
  }
}

GoRouter _router(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(MainShell, skipOffstage: false)));

void main() {
  setUpAll(loadAppFonts);

  late AppDatabase db;
  late FakeScannerCamera camera;
  late FakeEdge edge;
  late _Comunidade comunidade;
  late FakeExternal externa;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    camera = FakeScannerCamera();
    edge = FakeEdge()
      ..books[_achado] = const CatalogBook(
        isbn13: _achado,
        title: 'Dom Casmurro',
        authors: ['Machado de Assis'],
        publisher: 'Penguin-Companhia',
        year: 2016,
        source: 'openlibrary',
        license: 'OL-sem-direitos',
      );
    comunidade = _Comunidade();
    externa = FakeExternal();
  });
  tearDown(() => db.close());

  Future<void> abrir(
    WidgetTester tester, {
    bool conta = false,
    CoverReader? capa,
  }) async {
    setCanvasView(
      tester,
      logical: const Size(390, 1600),
      safeTop: 47,
      safeBottom: 34,
    );
    await pumpApp(
      tester,
      scannerCamera: () => camera,
      overrides: [
        scannedShelfProvider.overrideWith(
          (ref) async => ScannedShelf(
            db: db,
            versioning: LocalVersioning(
              db,
              HlcClock(
                deviceId: 'aparelhoA',
                nowMs: () => DateTime.utc(2026, 10, 5).millisecondsSinceEpoch,
              ),
            ),
            owner: () async => usuarioTeste,
          ),
        ),
        isbnResolverProvider.overrideWith(
          (ref) async => IsbnResolver(
            cache: CatalogCacheDao(db),
            localCatalog: () async => null,
            edge: edge,
            community: conta ? comunidade : null,
            external: conta ? externa : null,
          ),
        ),
        communityCatalogApiProvider.overrideWithValue(
          conta ? comunidade : null,
        ),
        canContributeProvider.overrideWithValue(conta),
        coverReaderProvider.overrideWithValue(capa ?? _Capa(null)),
      ],
    );
    _router(tester).push<void>(AppRoutes.scanner).ignore();
    await tester.pumpAndSettle();
    expect(find.byType(ScannerScreen), findsOneWidget);
  }

  Future<void> ler(WidgetTester tester, String codigo) async {
    camera.read(codigo);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'layout D-76: câmera no cartão, ajuda e as pílulas; o livro achado vai para a estante',
    (tester) async {
      await abrir(tester);
      expect(find.byKey(const ValueKey('scanner.camera.fake')), findsOneWidget);
      expect(
        texto('Aponte para o código de barras da contracapa.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('scanner.digitar')), findsOneWidget);
      expect(find.byKey(const ValueKey('scanner.lanterna')), findsOneWidget);

      await ler(tester, _achado);
      expect(texto('Dom Casmurro'), findsOneWidget);
      expect(
        texto('Machado de Assis · Penguin-Companhia · 2016'),
        findsOneWidget,
      );
      await tocar(tester, 'Adicionar à estante');
      expect(texto('Adicionado à sua estante.'), findsOneWidget);
      final estante = await UserBooksDao(db).shelf(usuarioTeste);
      expect(estante.single.isbn13, _achado);
      expect(estante.single.format, BookFileFormat.physical);
      expect(edge.calls, [_achado]);

      // D-77: o mesmo ISBN de novo — aviso, sem rede
      await tocar(tester, 'Escanear outro');
      await ler(tester, _achado);
      expect(texto('Este livro já está na sua estante.'), findsOneWidget);
      expect(edge.calls, [_achado], reason: 'nada vai para a rede');
      expect(await UserBooksDao(db).shelf(usuarioTeste), hasLength(1));
    },
  );

  testWidgets('código que não é de livro: aviso e a câmera continua', (
    tester,
  ) async {
    await abrir(tester);
    await ler(tester, '7891000315507'); // EAN-13 de um produto
    expect(texto('Esse código não é de um livro.'), findsOneWidget);
    expect(find.byKey(const ValueKey('scanner.resultado')), findsNothing);
    expect(edge.calls, isEmpty);
  });

  testWidgets(
    'Digitar ISBN: inválido avisa; ISBN-10 com hífens vira ISBN-13 e busca',
    (tester) async {
      await abrir(tester);
      await tester.tap(find.byKey(const ValueKey('scanner.digitar')));
      await tester.pumpAndSettle();
      await digitar(tester, 'ISBN (10 ou 13 dígitos)', '85-359-0277-6');
      await tocar(tester, 'Buscar');
      expect(
        texto('Esse número não é um ISBN válido. Confira os dígitos.'),
        findsOneWidget,
      );
      await digitar(tester, 'ISBN (10 ou 13 dígitos)', '85-359-0277-5');
      await tocar(tester, 'Buscar');
      expect(edge.calls, [_achado]);
      expect(texto('Dom Casmurro'), findsOneWidget);
    },
  );

  testWidgets(
    'Lanterna liga e desliga; sem lanterna no aparelho, a pílula some',
    (tester) async {
      await abrir(tester);
      await tester.tap(find.byKey(const ValueKey('scanner.lanterna')));
      await tester.pumpAndSettle();
      expect(camera.torchToggles, 1);
      expect(camera.torch.value, isTrue);
      camera.torch.value = null;
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('scanner.lanterna')), findsNothing);
    },
  );

  testWidgets('sem permissão da câmera: explica e o ISBN pode ser digitado', (
    tester,
  ) async {
    await abrir(tester);
    camera.status.value = CameraStatus.denied;
    await tester.pumpAndSettle();
    expect(texto('Câmera sem permissão'), findsOneWidget);
    expect(
      texto(
        'Sem acesso à câmera. Permita a câmera nos ajustes do aparelho ou digite o ISBN.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('scanner.digitar')), findsOneWidget);
  });

  testWidgets(
    'convidado, não achou: digita os dados e põe na estante — nada vai para a comunidade',
    (tester) async {
      await abrir(tester);
      await ler(tester, _sumido);
      expect(texto('Não achamos o ISBN $_sumido'), findsOneWidget);
      expect(find.byKey(const ValueKey('scanner.enviar')), findsNothing);
      await tocar(tester, 'Adicionar à estante');
      expect(texto('Digite pelo menos o título.'), findsOneWidget);
      await digitar(tester, 'Título', 'Livro Novo');
      await digitar(
        tester,
        'Autor (separe vários com ;)',
        'Ana Autora; Bia Coautora',
      );
      await tocar(tester, 'Adicionar à estante');
      expect(texto('Adicionado à sua estante.'), findsOneWidget);
      final b = (await UserBooksDao(db).shelf(usuarioTeste)).single;
      expect(
        [b.title, b.authorDisplay, b.isbn13],
        ['Livro Novo', 'Ana Autora · Bia Coautora', _sumido],
      );
      expect(comunidade.envios, isEmpty);
      expect(
        comunidade.consultas,
        isEmpty,
        reason: 'sem conta: sem comunidade',
      );
    },
  );

  testWidgets(
    'com conta: ler a capa preenche; só o toque em "enviar" manda ISBN, título, autor e editora',
    (tester) async {
      final capa = _Capa(const [
        CoverLine('CLARICE LISPECTOR', 40, top: 10),
        CoverLine('A HORA DA ESTRELA', 90, top: 200),
      ]);
      await abrir(tester, conta: true, capa: capa);
      await ler(tester, _sumido);
      expect(comunidade.consultas, [_sumido]);
      expect(externa.calls, [_sumido]);
      await tocar(tester, 'Ler a capa');
      expect(capa.leituras, 1);
      expect(
        texto('Confira o que foi lido da capa antes de adicionar.'),
        findsOneWidget,
      );
      String valor(String rotulo) =>
          tester.widget<TextField>(campo(rotulo)).controller!.text;
      expect(valor('Título'), 'A Hora da Estrela');
      expect(valor('Autor (separe vários com ;)'), 'Clarice Lispector');
      await digitar(tester, 'Editora (opcional)', 'Rocco');
      expect(comunidade.envios, isEmpty, reason: 'ler a capa não envia nada');

      await tocar(tester, 'Adicionar e enviar ao catálogo');
      expect(comunidade.envios, [
        {
          'isbn13': _sumido,
          'title': 'A Hora da Estrela',
          'authors': 'Clarice Lispector',
          'publisher': 'Rocco',
        },
      ]);
      expect(
        texto(
          'Enviado ao catálogo da comunidade. Ele entra no catálogo depois de 2 confirmações de outras pessoas.',
        ),
        findsOneWidget,
      );
      expect(
        (await UserBooksDao(db).shelf(usuarioTeste)).single.isbn13,
        _sumido,
      );
    },
  );

  testWidgets('com conta: sugestão da comunidade → "Confirmar e adicionar"', (
    tester,
  ) async {
    comunidade.pendentes[_sumido] = const [
      CommunitySuggestion(
        id: '01927a00-0000-7000-8000-0000000000d1',
        title: 'Livro Sugerido',
        authors: 'Autora',
        confirmations: 1,
        mine: false,
        confirmedByMe: false,
      ),
    ];
    await abrir(tester, conta: true);
    await ler(tester, _sumido);
    expect(texto('Sugestão da comunidade · 1 confirmação'), findsOneWidget);
    await tocar(tester, 'Confirmar e adicionar');
    expect(comunidade.confirmacoes, ['01927a00-0000-7000-8000-0000000000d1']);
    expect(
      texto('Sua confirmação foi registrada. Obrigado por ajudar o catálogo.'),
      findsOneWidget,
    );
    expect(
      (await UserBooksDao(db).shelf(usuarioTeste)).single.title,
      'Livro Sugerido',
    );
  });

  testWidgets(
    'sem rede: "Tentar de novo" busca outra vez; "Digitar os dados" abre o formulário',
    (tester) async {
      edge.failure = const CatalogOffline();
      await abrir(tester);
      await ler(tester, _achado);
      expect(
        texto('Sem conexão. Tente de novo quando a internet voltar.'),
        findsOneWidget,
      );
      edge.failure = null;
      await tocar(tester, 'Tentar de novo');
      expect(texto('Dom Casmurro'), findsOneWidget);

      await tocar(tester, 'Adicionar à estante');
      await tocar(tester, 'Escanear outro');
      edge.failure = const CatalogOffline();
      await ler(tester, _sumido);
      await tocar(tester, 'Digitar os dados');
      expect(texto('Não achamos o ISBN $_sumido'), findsOneWidget);
    },
  );

  testWidgets('fechar a tela desliga a câmera', (tester) async {
    await abrir(tester);
    _router(tester).pop();
    await tester.pumpAndSettle();
    expect(camera.disposed, isTrue);
  });

  testWidgets(
    'erro inesperado numa camada: "Algo deu errado" com "Tentar de novo" (nunca preso em "Procurando…")',
    (tester) async {
      edge.failure = StateError('resposta estranha');
      await abrir(tester);
      await ler(tester, _achado);
      expect(texto('Algo deu errado. Tente de novo.'), findsOneWidget);
      edge.failure = null;
      await tocar(tester, 'Tentar de novo');
      expect(texto('Dom Casmurro'), findsOneWidget);
    },
  );
}
