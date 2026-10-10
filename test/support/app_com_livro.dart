// G20 — o app inteiro com o Dom Casmurro real: a Início com a fonte real (`LocalHomeRepository`) sobre o mesmo banco
// do leitor e da tela 25, o relógio fixo, o fuso UTC e os dublês do aparelho. Serve às relações do Anexo 01 §14 (R2),
// ao Voltar por camadas e à restauração.
import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/features/highlights/application/card_text_source.dart';
import 'package:app_leitura/features/highlights/application/highlights_club_source.dart';
import 'package:app_leitura/features/highlights/application/highlights_controller.dart';
import 'package:app_leitura/features/highlights/application/highlights_providers.dart';
import 'package:app_leitura/features/highlights/application/highlights_repository.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/data/home_sources.dart'
    show ClubTicketSource;
import 'package:app_leitura/features/home/data/local_home_repository.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/application/reader_providers.dart';
import 'package:app_leitura/features/scanner/presentation/scanner_camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/overrides_do_mundo.dart' show brandDoMundo;
import '../fixtures/paper_timer_fakes.dart' show overridesDaSessao;
import 'canvas.dart';
import 'dados_t25.dart' show ArquivosDeTeste;
import 'fake_scanner_camera.dart';
import 'precache_svgs.dart';
import 'pump_reader.dart';
import 'reader_harness.dart';

/// 09/10/2026 12:00 UTC — o "agora" das provas da G20 (o fuso fica em UTC).
final DateTime agoraG20 = DateTime.utc(2026, 10, 9, 12);

/// O relógio das provas da G20: a parede ([agora]) e o monotônico da sessão ([mono]) andam juntos, só por
/// [andar] (o tempo do `pump` não conta — a sessão de leitura mede pelo monotônico).
final class RelogioG20 {
  DateTime agora = agoraG20;
  Duration mono = Duration.zero;

  void andar(Duration d) {
    agora = agora.add(d);
    mono += d;
  }
}

/// O Dom Casmurro real na estante, em leitura, com a posição no começo do cap. XXXII ("Olhos de ressaca").
Future<LivroNaEstante> domCasmurroEmLeitura() async {
  final livro = await LivroNaEstante.domCasmurro();
  await UserBooksDao(livro.db).upsert(
    livro.book.copyWith(
      status: ShelfStatus.reading,
      chaptersTotal: Nullable(livro.index.chaptersTotal),
      startedAt: Nullable(agoraG20.subtract(const Duration(days: 3))),
      lastOpenedAt: Nullable(agoraG20.subtract(const Duration(hours: 1))),
    ),
  );
  final t = livro.index.toc.firstWhere(
    (t) => t.title.startsWith('Olhos de ressaca'),
  );
  await livro.guardarPosicao(t.spine!, t.offset ?? 0);
  return livro;
}

/// As dependências da tela 25 sobre o banco do [livro], com o texto dos cartões pelo arquivo dele.
HighlightsDeps depsReaisDaTela25(
  LivroNaEstante livro, {
  DateTime Function()? agora,
}) => HighlightsDeps(
  db: livro.db,
  repository: HighlightsRepository(
    db: livro.db,
    versioning: livro.versioning,
    owner: () async => livro.leitor,
  ),
  textSourceFor: (b) async =>
      EpubCardTextSource(path: livro.path, sha: b.contentSha256 ?? ''),
  club: const NoHighlightsClub(),
  now: agora ?? () => agoraG20,
  utcOffsetAt: (_) => Duration.zero,
  files: ArquivosDeTeste(),
  onError: Error.throwWithStackTrace,
);

/// Monta o app (começa na Início) com o [livro] e espera a Início com os dados. Devolve os dublês do leitor. O
/// [relogio] é o mesmo para a Início, o leitor e a tela 25. [cronometro]: o do papel (sem ele, um cronômetro em
/// memória sem sessão nem livros — os testes do papel no banco passam o deles).
Future<LeitorNaTela> abrirAppComLivro(
  WidgetTester tester,
  LivroNaEstante livro, {
  RelogioG20? relogio,
  Size tela = const Size(390, 844),
  List<Override> overrides = const [],
  List<Override>? cronometro,
  ClubTicketSource? clube,
}) async {
  final r = relogio ?? RelogioG20();
  setCanvasView(tester, logical: tela);
  final t = LeitorNaTela(livro);
  await precacheAppIcons(tester);
  await precacheSvgs(tester, AppIconsLeitor.all);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(() => r.agora),
        homeRepositoryProvider.overrideWithValue(
          LocalHomeRepository(
            database: () async => livro.db,
            owner: () async => livro.leitor,
            utcOffsetAt: (_) => Duration.zero,
            debounce: Duration.zero,
            club: clube,
          ),
        ),
        homeAccountUserProvider.overrideWithValue(null),
        brandDoMundo,
        scannerCameraProvider.overrideWithValue(FakeScannerCamera.new),
        readerDepsProvider.overrideWith(
          (ref) async => livro.readerDeps(
            awake: t.awake,
            onError: (e, _) => t.erros.add(e),
            now: () => r.agora,
            elapsed: () => r.mono,
            utcOffsetAt: (_) => Duration.zero,
          ),
        ),
        readerSystemUiProvider.overrideWithValue(t.ui),
        highlightsDepsProvider.overrideWith(
          (ref) async => depsReaisDaTela25(livro, agora: () => r.agora),
        ),
        ...(cronometro ?? overridesDaSessao()),
        ...overrides,
      ],
      child: const App.forTests(),
    ),
  );
  await esperarInicio(tester);
  return t;
}

/// Anda até o herói da Início aparecer com os dados do banco.
Future<void> esperarInicio(WidgetTester tester, {int voltas = 60}) async {
  for (var i = 0; i < voltas; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 16));
    if (find.byKey(const ValueKey('hero.title')).evaluate().isNotEmpty) {
      await tester.pumpAndSettle();
      return;
    }
  }
  fail('a Início não mostrou o herói em $voltas voltas');
}

/// Os textos de todos os `AppText` dentro de [key], na ordem da árvore, juntos por " ".
String textosEm(WidgetTester tester, String key) => [
  for (final e
      in find
          .descendant(
            of: find.byKey(ValueKey<String>(key)),
            matching: find.byType(AppText),
            matchRoot: true,
          )
          .evaluate())
    (e.widget as AppText).span.toPlainText(includeSemanticsLabels: false),
].join(' ');
