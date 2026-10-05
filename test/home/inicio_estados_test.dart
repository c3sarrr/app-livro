// G08.4 — a Início com dados reais: seções que se adaptam (D-78), convites, convidado (D-84), frases de concluído
// (D-83), carregando e erro (D-85), capas reais (D-79). O caminho "com dados" do arquivo segue nos testes de
// fidelidade (fixture).
import 'dart:async';
import 'dart:io';

import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/app/router.dart' show AppRoutes;
import 'package:app_leitura/features/home/application/cover_providers.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/data/cover_store.dart';
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/placeholder/presentation/placeholder_screen.dart';
import 'package:app_leitura/features/scanner/presentation/scanner_camera.dart';
import 'package:app_leitura/features/scanner/presentation/scanner_screen.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../fixtures/overrides_do_mundo.dart' show relogioDoMundo;
import '../support/app_text_finder.dart';
import '../support/fake_scanner_camera.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';

final DateTime _agora = DateTime(2026, 9, 20, 20);

ReadingDay _dia({int lidos = 0, int meta = 30, int seq = 0, int selo = 7}) =>
    ReadingDay(
      goalMinutes: meta,
      readMinutes: lidos,
      streakDays: seq,
      pagesToday: 0,
      highlightsToday: 0,
      week: [
        for (var d = 14; d <= 20; d++)
          WeekDayStat(
            date: DateTime(2026, 9, d),
            minutes: d == 20 ? lidos : 0,
            barHeightPx: d == 20 ? (lidos * 4 / 3).clamp(0.0, 77.0) : 0,
            isToday: d == 20,
          ),
      ],
      badgeTargetDays: selo,
    );

HomeSnapshot _vazia({
  bool estanteVazia = true,
  List<RecentItem> recentes = const [],
  ReadingDay? dia,
  ContinueReading? lendo,
  List<AlsoReadingItem> tambem = const [],
  ForYou? paraVoce,
  UserSummary user = const UserSummary(unreadNotifications: 0),
}) => HomeSnapshot(
  now: _agora,
  user: user,
  continueReading: lendo,
  alsoReading: tambem,
  readingDay: dia ?? _dia(),
  forYou: paraVoce,
  club: null,
  recent: recentes,
  shelfIsEmpty: estanteVazia,
);

/// Fonte com o instantâneo na hora (como a fixture).
final class _Pronta implements SyncHomeRepository {
  _Pronta(this.s);
  final HomeSnapshot s;

  @override
  HomeSnapshot snapshot(DateTime now) => s;

  @override
  Stream<HomeSnapshot> watch(DateTime Function() clock) => const Stream.empty();
}

/// Fonte assíncrona controlada pelo teste (como a do banco).
final class _Fluxo implements HomeRepository {
  final List<StreamController<HomeSnapshot>> fluxos = [];

  @override
  Stream<HomeSnapshot> watch(DateTime Function() clock) {
    final c = StreamController<HomeSnapshot>();
    fluxos.add(c);
    return c.stream;
  }
}

final class _SemFoto implements CoverImages {
  @override
  Future<File?> cached(PhotoCover cover) async => null;

  @override
  Future<void> discard(PhotoCover cover) async {}

  @override
  Future<File?> resolve(PhotoCover cover) async => null;
}

Finder _key(String id) => find.byKey(ValueKey<String>(id));

/// O app real com a fonte do teste (como `pumpApp`, mas sem o repositório da fixture).
Future<void> _abrir(WidgetTester tester, List<Override> overrides) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await precacheAppIcons(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        relogioDoMundo,
        scannerCameraProvider.overrideWithValue(FakeScannerCamera.new),
        coverImagesProvider.overrideWithValue(_SemFoto()),
        ...overrides,
      ],
      child: const App.forTests(),
    ),
  );
  await tester.pumpAndSettle();
}

Rect _rect(WidgetTester tester, String id) => tester.getRect(_key(id));

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'estante vazia: "Comece sua história.", convite para escanear, Dia de leitura zerado e nada mais',
    (tester) async {
      await _abrir(tester, [
        homeRepositoryProvider.overrideWithValue(_Pronta(_vazia())),
      ]);
      expect(findAppText('Comece'), findsOneWidget);
      expect(findAppText('Continue'), findsNothing);
      expect(findAppText('sua história.'), findsOneWidget);
      expect(findAppText('Sua estante está vazia'), findsOneWidget);
      expect(
        findAppText('Escaneie o código de barras de um livro para começar.'),
        findsOneWidget,
      );
      expect(findAppText('Escanear livro'), findsOneWidget);
      for (final id in ['alsoReading', 'forYou', 'club', 'recent']) {
        expect(_key(id), findsNothing, reason: id);
      }
      expect(_key('today'), findsOneWidget);
      // gaps do arquivo: cabeçalho 24 título 24 cartão — e o gap de antes do Dia de leitura (36)
      expect(
        _rect(tester, 'headline').top - _rect(tester, 'header').bottom,
        24,
      );
      expect(_rect(tester, 'hero').top - _rect(tester, 'headline').bottom, 24);
      expect(_rect(tester, 'today').top - _rect(tester, 'hero').bottom, 36);
      expect(
        findAppText('Faltam 30 min para fechar a meta de hoje.'),
        findsOneWidget,
      );
      expect(findAppText('Mais 7 dias para o selo de 7 dias'), findsOneWidget);

      await tester.tap(_key('hero.invite.cta'));
      await tester.pumpAndSettle();
      expect(find.byType(ScannerScreen), findsOneWidget);
    },
  );

  testWidgets(
    'com livros e nenhum em leitura: convite para a Biblioteca e os recém-chegados (físico)',
    (tester) async {
      const b = Book(
        id: 'b1',
        title: 'Dom Casmurro',
        author: 'Machado de Assis',
        cover: PhotoCover(ref: 'ol:8231432', isbn13: '9788535902778'),
      );
      await _abrir(tester, [
        homeRepositoryProvider.overrideWithValue(
          _Pronta(
            _vazia(
              estanteVazia: false,
              recentes: const [
                RecentItem(
                  book: b,
                  format: BookFormat.physical,
                  status: RecentStatus.wantToRead,
                ),
              ],
            ),
          ),
        ),
      ]);
      expect(findAppText('Nada em leitura agora'), findsOneWidget);
      expect(
        findAppText('Escolha um livro da sua estante para começar.'),
        findsOneWidget,
      );
      expect(_key('recent'), findsOneWidget);
      expect(findAppText('Machado de Assis · Físico'), findsOneWidget);
      expect(findAppText('Quero ler'), findsOneWidget);
      expect(
        find.descendant(
          of: _key('recent.row0.cover'),
          matching: _key('cover.generated'),
          matchRoot: true,
        ),
        findsOneWidget,
      );
      expect(_rect(tester, 'recent').top - _rect(tester, 'today').bottom, 40);

      await tester.tap(_key('hero.invite.cta'));
      await tester.pumpAndSettle();
      final router = GoRouter.of(
        tester.element(find.byType(MainShell, skipOffstage: false)),
      );
      expect(router.state.uri.path, AppRoutes.biblioteca);
      expect(
        find.byWidgetPredicate(
          (w) => w is PlaceholderScreen && w.title == 'Biblioteca',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'convidado (D-84): "Boa noite" sem vírgula, sem nome, ícone de pessoa, sininho sem ponto',
    (tester) async {
      await _abrir(tester, [
        homeRepositoryProvider.overrideWithValue(_Pronta(_vazia())),
      ]);
      expect(findAppText('Boa noite'), findsOneWidget);
      expect(findAppText('Boa noite,'), findsNothing);
      expect(_key('header.name'), findsNothing);
      expect(_key('header.avatar.guest'), findsOneWidget);
      expect(_key('header.bell.dot'), findsNothing);
    },
  );

  testWidgets(
    'com conta: primeiro nome e inicial (o resto do cabeçalho do arquivo)',
    (tester) async {
      await _abrir(tester, [
        homeRepositoryProvider.overrideWithValue(
          _Pronta(
            _vazia(
              user: const UserSummary(
                firstName: 'Ana',
                initial: 'A',
                unreadNotifications: 0,
              ),
            ),
          ),
        ),
      ]);
      expect(findAppText('Boa noite,'), findsOneWidget);
      expect(findAppText('Ana'), findsOneWidget);
      expect(_key('header.avatar.guest'), findsNothing);
    },
  );

  testWidgets('meta batida e selo conquistado (D-83)', (tester) async {
    await _abrir(tester, [
      homeRepositoryProvider.overrideWithValue(
        _Pronta(_vazia(dia: _dia(lidos: 31, seq: 7))),
      ),
    ]);
    expect(findAppText('Meta de hoje cumprida.'), findsOneWidget);
    expect(findAppText('Selo de 7 dias conquistado'), findsOneWidget);
  });

  testWidgets(
    'livro real em leitura: capa gerada na moldura do herói, sem pílula de capítulo nem tempo; 1 em "também lendo"',
    (tester) async {
      const a = Book(
        id: 'a',
        title: 'A hora da estrela',
        author: 'Clarice Lispector',
        cover: PhotoCover(ref: 'ol:1'),
      );
      const b = Book(
        id: 'b',
        title: 'Perto do coração selvagem',
        author: 'Clarice Lispector',
        cover: PhotoCover(),
      );
      await _abrir(tester, [
        homeRepositoryProvider.overrideWithValue(
          _Pronta(
            _vazia(
              estanteVazia: false,
              lendo: const ContinueReading(
                book: a,
                progress: 0.4,
                highlightsCount: 0,
              ),
              tambem: const [AlsoReadingItem(book: b, progress: 0.1)],
              paraVoce: const ForYou(
                reasonAuthor: 'Clarice Lispector',
                items: [
                  Book(
                    id: '9788532508010',
                    title: 'Água viva',
                    author: 'Clarice Lispector',
                    cover: PhotoCover(isbn13: '9788532508010'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]);
      expect(findAppText('Continue'), findsOneWidget);
      expect(findAppText('A hora da estrela'), findsWidgets);
      expect(_key('hero.chapterPill'), findsNothing);
      expect(_key('hero.timeLeft'), findsNothing);
      expect(
        find.descendant(
          of: _key('hero.cover'),
          matching: _key('cover.generated'),
        ),
        findsOneWidget,
      );
      expect(_key('alsoReading.card1'), findsOneWidget);
      expect(_key('alsoReading.card2'), findsNothing);
      expect(findAppText('1'), findsWidgets);
      // o cartão único fica na metade, como os dois do arquivo
      expect(
        _rect(tester, 'alsoReading.card1').width,
        moreOrLessEquals((350 - 12) / 2, epsilon: 0.01),
      );
      expect(findAppText('Porque você lê Clarice Lispector'), findsOneWidget);
      expect(_key('forYou.item1.cover'), findsOneWidget);
    },
  );

  group('carregando e erro (D-85)', () {
    testWidgets('carregando: cabeçalho na hora; o aviso só depois de 400 ms', (
      tester,
    ) async {
      final fonte = _Fluxo();
      await _abrir(tester, [homeRepositoryProvider.overrideWithValue(fonte)]);
      expect(_key('home.loading'), findsOneWidget);
      expect(_key('header'), findsOneWidget);
      expect(_key('home.loading.text'), findsNothing);
      await tester.pump(const Duration(milliseconds: 400));
      expect(findAppText('Carregando sua estante…'), findsOneWidget);
      fonte.fluxos.single.add(_vazia());
      await tester.pumpAndSettle();
      expect(_key('home.loading'), findsNothing);
      expect(findAppText('Sua estante está vazia'), findsOneWidget);
    });

    testWidgets('erro: aviso e "Tentar de novo" refaz a leitura', (
      tester,
    ) async {
      final fonte = _Fluxo();
      await _abrir(tester, [homeRepositoryProvider.overrideWithValue(fonte)]);
      fonte.fluxos.single.addError(const FileSystemException('banco'));
      await tester.pumpAndSettle();
      expect(findAppText('Não deu para abrir sua estante.'), findsOneWidget);
      expect(findAppText('Tentar de novo'), findsOneWidget);
      expect(_key('hero'), findsNothing);
      await tester.tap(_key('home.error.retry'));
      await tester.pump();
      expect(fonte.fluxos, hasLength(2));
      fonte.fluxos.last.add(_vazia());
      await tester.pumpAndSettle();
      expect(_key('home.error'), findsNothing);
      expect(findAppText('Sua estante está vazia'), findsOneWidget);
    });

    testWidgets('erro depois de dados: a Início continua com os dados (D-85)', (
      tester,
    ) async {
      final fonte = _Fluxo();
      final relatados = <Object>[];
      await _abrir(tester, [
        homeRepositoryProvider.overrideWithValue(fonte),
        homeErrorReporterProvider.overrideWithValue((e, _) => relatados.add(e)),
      ]);
      fonte.fluxos.single.add(_vazia());
      await tester.pumpAndSettle();
      fonte.fluxos.single.addError(const FileSystemException('banco'));
      await tester.pumpAndSettle();
      expect(relatados, hasLength(1));
      expect(_key('home.error'), findsNothing);
      expect(findAppText('Sua estante está vazia'), findsOneWidget);
    });
  });
}
