// G11.2 — a sessão de leitura da tela (desenho G11 §2): abre o livro da estante pelo id (Opening → Ready), diz
// por que não abriu (D-21, D-92: fora da estante, de outra conta, arquivo fora do aparelho, danificado, páginas
// fixas, falha inesperada com "Tentar de novo"), indexa ao abrir quando falta o índice ("Preparando o livro…"),
// liga tempo (D-95), posição (G10) e tela acesa (D-111) à página e ao ciclo de vida, e guarda a volta de um
// link por 6 s ou 2 viradas (D-108). Relógio monotônico falso no tempo; o prazo da volta anda à mão.
// G14: os ajustes da folha (D-144) — revisão: falhas da cor e do último claro, a sessão reaberta no meio da gravação
// e o papel trocado no meio de uma repaginação (as fatias de layout seguradas à mão).

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/application/reader_session_controller.dart';
import 'package:app_leitura/features/reader/application/reading_speed_source.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/chapter_content.dart';
import 'package:app_leitura/features/reader/content/content_blocks.dart';
import 'package:app_leitura/features/reader/content/content_failure.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/domain/reading_speed.dart'
    show defaultCharsPerMinute, timeLeftFor;
import 'package:app_leitura/features/reader/layout/layout_scheduler.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_states.dart'
    show readerFailureText;
import 'package:drift/drift.dart' show Variable;
import 'package:flutter/scheduler.dart'
    show Priority, SchedulerBinding, defaultSchedulingStrategy;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart' show pdfrxInitialize;

import '../../../support/fake_reader.dart';
import '../../../support/load_fonts.dart';
import '../../../support/personal_builders.dart';
import '../../../support/reader_harness.dart';

const ReaderViewport _tela = (
  size: Size(390, 844),
  padding: EdgeInsets.zero,
  devicePixelRatio: 3.0,
);

/// A sessão sobre um livro da estante, com relógio monotônico falso e os dublês.
final class _Sessao {
  _Sessao(this.livro);

  final LivroNaEstante livro;
  final awake = RecordingScreenAwake();
  final prazos = RelogioDePrazos();
  final indexados = <String>[];
  final erros = <Object>[];
  Duration agora = Duration.zero;
  Future<bool> Function(String id)? indexar;

  /// O capítulo que não abre e o erro dele (arquivo danificado, falha inesperada).
  Object? Function(int spine)? erroNoCapitulo;

  /// Como preparar o PDFium (livro em PDF).
  Future<void> Function()? pdfInitialize;

  /// G12: a conta que abre (falha quando [donoFalha]) e a velocidade da conta.
  bool donoFalha = false;

  /// G14: a próxima pergunta pela conta espera por este sinal (uma vez) — a gravação parada no meio.
  Completer<void>? donoEspera;
  Future<double> Function(AppDatabase db, String userId)? velocidade;

  ReaderSessionController controller() {
    final c = ReaderSessionController(
      userBookId: livro.userBookId,
      deps: ReaderDeps(
        db: livro.db,
        versioning: livro.versioning,
        owner: () async {
          final espera = donoEspera;
          if (espera != null) {
            donoEspera = null;
            await espera.future;
          }
          if (donoFalha) throw StateError('banco ocupado');
          return usuarioTeste;
        },
        booksDir: () async => livro.dir,
        indexBook: (id) async {
          indexados.add(id);
          if (indexar != null) return indexar!(id);
          await BookContentIndexDao(livro.db)
              .upsert(id, livro.index, builtAt: t0Teste);
          return true;
        },
        scheduler: LayoutScheduler(),
        screenAwake: awake,
        deviceId: 'aparelhoA',
        now: () => t0Teste.add(agora),
        elapsed: () => agora,
        autoTick: false,
        chapterLoader: (path) => (s) async {
          final erro = erroNoCapitulo?.call(s);
          if (erro != null) throw erro;
          return chapterOf(livro.epub, s);
        },
        startTimer: prazos.start,
        pdfInitialize: pdfInitialize,
        speedOf: velocidade ?? readingSpeedOf,
        onError: (e, _) => erros.add(e),
      ),
    );
    return c;
  }

  Future<List<int>> segundos() async => [
    for (final s in await ReadingSessionsDao(
      livro.db,
    ).forBook(livro.userBookId))
      s.activeSeconds,
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  late _Sessao h;
  setUp(() async => h = _Sessao(await LivroNaEstante.domCasmurro()));
  tearDown(() async => h.livro.close());

  Future<ReaderSessionController> aberto({ReaderViewport tela = _tela}) async {
    final c = h.controller();
    addTearDown(() async {
      await c.close();
      c.dispose();
    });
    await c.open(tela);
    return c;
  }

  ReaderDocument doc(ReaderSessionController c) =>
      (c.state as ReaderReady).document;

  test(
    'abre: Opening → Ready, com o papel dos ajustes e as áreas da tela',
    () async {
      await ReaderSettingsDao(h.livro.db).upsert(
        ReaderSettings(
          id: usuarioTeste,
          meta: metaTeste(),
          paper: ReaderPaper.sepia,
        ),
      );
      final c = h.controller();
      addTearDown(() async {
        await c.close();
        c.dispose();
      });
      final vistos = <String>[];
      c.addListener(() => vistos.add(c.state.runtimeType.toString()));
      expect(c.state, isA<ReaderOpening>());
      await c.open(_tela);
      expect(vistos.first, 'ReaderOpening');
      expect(c.state, isA<ReaderReady>());
      expect(c.palette.paper, const Color(0xFFEEDDBF));
      expect((c.insets.top, c.insets.bottom), (92.0, 82.0));
      expect(doc(c).title, 'Dom Casmurro');
      expect(h.indexados, isEmpty, reason: 'o índice já estava pronto');
      expect(h.erros, isEmpty);
    },
  );

  group('não abriu (D-21)', () {
    Future<ReaderFailure> falha(Future<void> Function() preparar) async {
      await preparar();
      final c = h.controller();
      addTearDown(() async {
        await c.close();
        c.dispose();
      });
      await c.open(_tela);
      return (c.state as ReaderFailed).failure;
    }

    test('livro apagado da estante', () async {
      expect(
        await falha(
          () => UserBooksDao(h.livro.db).upsert(
            h.livro.book.copyWith(
              meta: h.livro.book.meta.deleted(
                t0Teste,
                h.livro.book.meta.version,
              ),
            ),
          ),
        ),
        ReaderFailure.notOnShelf,
      );
    });

    test('id que não existe e livro de outra conta', () async {
      final c = ReaderSessionController(
        userBookId: idTeste(99),
        deps: h.controller().deps,
      );
      addTearDown(c.dispose);
      await c.open(_tela);
      expect((c.state as ReaderFailed).failure, ReaderFailure.notOnShelf);
      expect(
        await falha(
          () => UserBooksDao(h.livro.db).upsert(
            h.livro.book.copyWith(
              meta: RecordMeta(
                userId: idTeste(98),
                createdAt: t0Teste,
                updatedAt: t0Teste,
                version: h.livro.book.meta.version,
              ),
            ),
          ),
        ),
        ReaderFailure.notOnShelf,
      );
    });

    test(
      'arquivo fora do aparelho (nem na pasta dos livros de agora)',
      () async {
        expect(
          await falha(
            () => LocalFilesDao(h.livro.db).upsert(
              userBookId: h.livro.userBookId,
              path: '${h.livro.dir.path}/sumiu/outro_nome.epub',
              bytes: 1,
              sha256: h.livro.index.contentSha256,
              now: t0Teste,
            ),
          ),
          ReaderFailure.fileMissing,
        );
      },
    );

    test(
      'exemplar físico: o aviso próprio (D-123), não o de arquivo sumido',
      () async {
        expect(
          await falha(
            () => UserBooksDao(h.livro.db)
                .upsert(h.livro.book.copyWith(format: BookFileFormat.physical)),
          ),
          ReaderFailure.physical,
        );
        expect(
          readerFailureText(ReaderFailure.physical),
          'Este livro é físico: não tem arquivo para ler aqui.',
        );
      },
    );

    test('arquivo danificado: o índice não sai', () async {
      h.indexar = (_) async => false;
      expect(
        await falha(
          () => BookContentIndexDao(h.livro.db).delete(h.livro.userBookId),
        ),
        ReaderFailure.damaged,
      );
    });

    test('livro de páginas fixas (D-92)', () async {
      final fixo = BookIndex(
        contentSha256: h.livro.index.contentSha256,
        layout: 'fixed',
        spine: h.livro.index.spine,
        toc: h.livro.index.toc,
        refPages: h.livro.index.refPages,
      );
      expect(
        await falha(
          () =>
              BookContentIndexDao(h.livro.db)
                  .upsert(h.livro.userBookId, fixo, builtAt: t0Teste),
        ),
        ReaderFailure.fixedLayout,
      );
    });

    test(
      'falha inesperada: vai para o relatório e "Tentar de novo" reabre',
      () async {
        await BookContentIndexDao(h.livro.db).delete(h.livro.userBookId);
        var vez = 0;
        h.indexar = (id) async {
          if (vez++ == 0) throw StateError('disco cheio');
          await BookContentIndexDao(h.livro.db)
              .upsert(id, h.livro.index, builtAt: t0Teste);
          return true;
        };
        final c = h.controller();
        addTearDown(() async {
          await c.close();
          c.dispose();
        });
        await c.open(_tela);
        expect((c.state as ReaderFailed).failure, ReaderFailure.unexpected);
        expect(h.erros.single, isA<StateError>());
        await c.retry();
        expect(c.state, isA<ReaderReady>());
      },
    );
  });

  test('sem índice: "Preparando o livro…" e indexa ao abrir', () async {
    await BookContentIndexDao(h.livro.db).delete(h.livro.userBookId);
    final c = h.controller();
    addTearDown(() async {
      await c.close();
      c.dispose();
    });
    final preparando = <bool>[];
    c.addListener(() {
      if (c.state case ReaderOpening(:final preparing)) {
        preparando.add(preparing);
      }
    });
    await c.open(_tela);
    expect(preparando, contains(true));
    expect(h.indexados, [h.livro.userBookId]);
    expect(c.state, isA<ReaderReady>());
  });

  test('G15 (D-154): índice de antes da G15 (sem os numerais) é refeito uma vez ao abrir', () async {
    await h.livro.db.customStatement(
      'UPDATE book_content_index SET toc_json = ? WHERE user_book_id = ?',
      [
        '[{"title":"I","spine":1,"offset":0,"depth":0,"leaf":true}]',
        h.livro.userBookId,
      ],
    );
    final c = h.controller();
    addTearDown(() async {
      await c.close();
      c.dispose();
    });
    final preparando = <bool>[];
    c.addListener(() {
      if (c.state case ReaderOpening(:final preparing)) {
        preparando.add(preparing);
      }
    });
    await c.open(_tela);
    expect(preparando, contains(true));
    expect(h.indexados, [h.livro.userBookId]);
    expect(c.state, isA<ReaderReady>());
    await c.close();
    final d = h.controller();
    addTearDown(() async {
      await d.close();
      d.dispose();
    });
    await d.open(_tela);
    expect(d.state, isA<ReaderReady>());
    expect(h.indexados, [
      h.livro.userBookId,
    ], reason: 'o índice refeito já está em dia');
  });

  test('arquivo que mudou de pasta (atualização do iOS): acha pelo nome na pasta de agora', () async {
    final f = await LocalFilesDao(h.livro.db).byBook(h.livro.userBookId);
    await LocalFilesDao(h.livro.db).upsert(
      userBookId: h.livro.userBookId,
      path: '/pasta/antiga/${f!.path.split(RegExp(r'[/\\]')).last}',
      bytes: f.bytes,
      sha256: f.sha256,
      now: t0Teste,
    );
    final c = await aberto();
    expect(c.state, isA<ReaderReady>());
  });

  test('tempo, posição e tela acesa: visível conta; segundo plano pausa, grava e solta a tela', () async {
    final c = await aberto();
    c.setVisible(true);
    expect(h.awake.log, ['on']);
    h.agora += const Duration(seconds: 30);
    expect(await c.turn(PageDirection.forward), isTrue);
    h.agora += const Duration(seconds: 15);
    await c.lifecycle(AppLifecycleState.paused);
    expect(h.awake.log, ['on', 'off']);
    final pos = await ReadingPositionsDao(h.livro.db)
        .forBook(h.livro.userBookId);
    expect((pos!.locator as EpubLocator).offset, doc(c).mark.offset);
    h.agora += const Duration(minutes: 10); // em segundo plano: não conta
    await c.lifecycle(AppLifecycleState.resumed);
    expect(h.awake.log, ['on', 'off', 'on']);
    h.agora += const Duration(seconds: 5);
    await c.close();
    expect(h.awake.log.last, 'off');
    expect(await h.segundos(), [50]);
    final sessao = (await ReadingSessionsDao(
      h.livro.db,
    ).forBook(h.livro.userBookId)).single;
    expect(sessao.refPageFrom, isNotNull);
  });

  test('link (D-108): vai, guarda a volta; some em 2 viradas ou em 6 s; voltar = caractere exato', () async {
    final rosto = h.livro.index.spine.indexWhere(
      (s) => s.path.endsWith('55752-h-0.htm.xhtml'),
    );
    final link = [
      for (final b in chapterOf(h.livro.epub, rosto).item.blocks)
        if (b is TextBlock)
          for (final r in b.runs)
            if (r.link != null && r.text.trim() == 'Indice') r.link!,
    ].single;
    final hit = (target: link, spine: rosto, offset: 0);
    await h.livro.guardarPosicao(rosto, 0);
    final c = await aberto();
    final origem = doc(c).mark;
    final pagOrigem = doc(c).numbers.refPage;
    BackLink? volta() => (c.state as ReaderReady).back;

    expect(await c.follow(hit), isTrue);
    expect(volta(), (mark: origem, refPage: pagOrigem));
    expect(doc(c).mark, isNot(origem));
    await c.turn(PageDirection.forward);
    expect(volta(), isNotNull, reason: '1 virada');
    await c.turn(PageDirection.forward);
    expect(volta(), isNull, reason: '2 viradas');
    expect(h.prazos.pendentes, 0, reason: 'o prazo some junto');

    await c.follow(hit);
    h.prazos.avancar(const Duration(seconds: 5));
    expect(volta(), isNotNull);
    h.prazos.avancar(const Duration(seconds: 1));
    expect(volta(), isNull, reason: '6 s');

    await doc(c).goTo(origem);
    await c.follow(hit);
    await c.back();
    expect(doc(c).mark, origem);
    expect(volta(), isNull);
    expect(
      await c.follow((target: 'OEBPS/fora.xhtml#x', spine: rosto, offset: 0)),
      isFalse,
    );
    expect(volta(), isNull);
  });

  test('sair sem esperar: dispose fecha, grava a posição e o tempo antes de soltar o livro', () async {
    final c = h.controller();
    await c.open(_tela);
    c.setVisible(true);
    h.agora += const Duration(seconds: 20);
    await c.turn(PageDirection.forward);
    final mark = doc(c).mark;
    h.agora += const Duration(seconds: 20);
    c.dispose();
    await c.close(); // o mesmo fechamento que o dispose começou
    final pos = await ReadingPositionsDao(h.livro.db)
        .forBook(h.livro.userBookId);
    expect((pos!.locator as EpubLocator).offset, mark.offset);
    expect(await h.segundos(), [40]);
  });

  test('a página mudou: a tela é avisada (números novos)', () async {
    await h.livro.guardarPosicao(2, h.livro.index.spine[2].chars ~/ 2);
    final c = await aberto();
    var avisos = 0;
    c.addListener(() => avisos++);
    final antes = doc(c).numbers;
    await c.turn(PageDirection.forward);
    expect(avisos, greaterThan(0));
    expect(doc(c).numbers, isNot(antes));
  });

  group('revisão da G11', () {
    LinkHit indice() {
      final rosto = h.livro.index.spine.indexWhere(
        (s) => s.path.endsWith('55752-h-0.htm.xhtml'),
      );
      final link = [
        for (final b in chapterOf(h.livro.epub, rosto).item.blocks)
          if (b is TextBlock)
            for (final r in b.runs)
              if (r.link != null && r.text.trim() == 'Indice') r.link!,
      ].single;
      return (target: link, spine: rosto, offset: 0);
    }

    Future<EpubLocator> gravada() async =>
        (await ReadingPositionsDao(h.livro.db).forBook(h.livro.userBookId))!
                .locator
            as EpubLocator;

    test('com a volta valendo, a posição gravada é a de onde se saiu; ao sumir, a do destino (D-115)', () async {
      final hit = indice();
      await h.livro.guardarPosicao(hit.spine, 0);
      final c = await aberto();
      final origem = doc(c).mark;
      expect(await c.follow(hit), isTrue);
      final destino = doc(c).mark;
      await doc(c).flush();
      expect(
        ((await gravada()).spine, (await gravada()).offset),
        (origem.spine, origem.offset),
      );
      h.prazos.avancar(backLinkLife);
      await Future<void>.delayed(Duration.zero);
      await doc(c).flush();
      expect(
        ((await gravada()).spine, (await gravada()).offset),
        (destino.spine, destino.offset),
      );
    });

    test('fechar com a volta valendo grava a origem (D-115)', () async {
      final hit = indice();
      await h.livro.guardarPosicao(hit.spine, 0);
      final c = await aberto();
      final origem = doc(c).mark;
      await c.follow(hit);
      await c.turn(PageDirection.forward); // 1 virada: a volta ainda vale
      await c.close();
      expect(
        ((await gravada()).spine, (await gravada()).offset),
        (origem.spine, origem.offset),
      );
    });

    test(
      'volta sem prazo (leitor de tela — D-116): só as 2 viradas a tiram',
      () async {
        final hit = indice();
        await h.livro.guardarPosicao(hit.spine, 0);
        final c = await aberto();
        await c.follow(hit, timed: false);
        expect(h.prazos.pendentes, 0);
        expect((c.state as ReaderReady).back, isNotNull);
        await c.turn(PageDirection.forward);
        await c.turn(PageDirection.forward);
        expect((c.state as ReaderReady).back, isNull);
      },
    );

    test('em fila: virar logo depois de seguir o link vira a partir do destino e conta para a volta', () async {
      final hit = indice();
      await h.livro.guardarPosicao(hit.spine, 0);
      final c = await aberto();
      final seguiu = c.follow(hit);
      final virou = c.turn(PageDirection.forward);
      expect(await seguiu, isTrue);
      expect(await virou, isTrue);
      expect(doc(c).mark.spine, isNot(hit.spine), reason: 'virou no destino');
      expect(
        (c.state as ReaderReady).back,
        isNotNull,
        reason: '1 virada contada',
      );
      await c.turn(PageDirection.forward);
      expect((c.state as ReaderReady).back, isNull, reason: '2ª virada');
    });

    test(
      'virar para um capítulo danificado: o aviso da D-21; nada é relatado',
      () async {
        h.erroNoCapitulo = (s) => s == 1 ? const ContentDamaged('teste') : null;
        await h.livro.guardarPosicao(2, 0);
        final c = await aberto();
        expect(await c.turn(PageDirection.backward), isFalse);
        expect((c.state as ReaderFailed).failure, ReaderFailure.damaged);
        expect(h.erros, isEmpty);
        expect(
          await c.turn(PageDirection.forward),
          isFalse,
          reason: 'com o aviso na tela, nada vira',
        );
      },
    );

    test('falha inesperada ao virar: relatada; "Tentar de novo" reabre onde a pessoa estava', () async {
      h.erroNoCapitulo = (s) => s == 1 ? StateError('memória') : null;
      await h.livro.guardarPosicao(2, 0);
      final c = await aberto();
      final onde = doc(c).mark;
      expect(await c.turn(PageDirection.backward), isFalse);
      expect((c.state as ReaderFailed).failure, ReaderFailure.unexpected);
      expect(h.erros.single, isA<StateError>());
      h.erroNoCapitulo = null;
      await c.retry();
      expect(doc(c).mark, onde);
      expect(await c.turn(PageDirection.backward), isTrue);
    });

    test(
      'livro em PDF abre pela sessão: números do PDF, virar e posição',
      () async {
        // a pasta do PDF é só deste teste: no Windows o PDFium solta o arquivo um pouco depois do dispose
        final tmp = Directory.systemTemp.createTempSync(
          'booknest_g11_sessao_pdf_',
        );
        addTearDown(() async {
          for (var i = 0; i < 20 && tmp.existsSync(); i++) {
            try {
              tmp.deleteSync(recursive: true);
            } on FileSystemException {
              await Future<void>.delayed(const Duration(milliseconds: 100));
            }
          }
        });
        h.pdfInitialize = () => pdfrxInitialize(tmpPath: tmp.path);
        final copia = File('test/fixtures/livros/amostra.pdf')
            .copySync('${tmp.path}${Platform.pathSeparator}livro.pdf');
        await UserBooksDao(h.livro.db)
            .upsert(h.livro.book.copyWith(format: BookFileFormat.pdf));
        await LocalFilesDao(h.livro.db).upsert(
          userBookId: h.livro.userBookId,
          path: copia.path,
          bytes: copia.lengthSync(),
          sha256: shaTeste,
          now: t0Teste,
        );
        final c = h.controller();
        await c.open(_tela);
        expect(doc(c).numbers.pageLabel, 'pág. 1 de 3');
        expect(await c.turn(PageDirection.forward), isTrue);
        expect(doc(c).numbers.pageLabel, 'pág. 2 de 3');
        await c.close();
        c.dispose();
        final pos = await ReadingPositionsDao(h.livro.db)
            .forBook(h.livro.userBookId);
        expect(pos!.locator, isA<PdfLocator>());
        expect((pos.locator as PdfLocator).page, 1);
      },
    );
  });

  group('G12', () {
    test('jumpToPage (barra) guarda a volta como o link (D-119): pílula, alfinete (D-115), 6 s; rodapé = página escolhida', () async {
      final c = await aberto();
      final origem = doc(c).mark;
      final pagOrigem = doc(c).numbers.refPage;
      BackLink? volta() => (c.state as ReaderReady).back;
      expect(await c.jumpToPage(200), isTrue);
      expect(doc(c).numbers.refPage, 200);
      expect(volta(), (mark: origem, refPage: pagOrigem));
      expect(doc(c).found, isNull);
      await doc(c).flush();
      final pos = await ReadingPositionsDao(h.livro.db)
          .forBook(h.livro.userBookId);
      expect(
        (pos!.locator as EpubLocator).spine,
        origem.spine,
        reason: 'alfinete: grava a origem (D-115)',
      );
      h.prazos.avancar(const Duration(seconds: 6));
      expect(volta(), isNull);
      // leitor de tela: sem prazo (D-116)
      await c.jumpToPage(10, timed: false);
      h.prazos.avancar(const Duration(seconds: 60));
      expect(volta(), isNotNull);
    });

    test(
      'jumpTo (busca) mostra a página da ocorrência, marca e guarda a volta',
      () async {
        final c = await aberto();
        final pagOrigem = doc(c).numbers.refPage;
        final destino = doc(c).markOfRefPage(200);
        final ocorrencia = (
          unit: destino.spine,
          from: destino.offset,
          to: destino.offset + 3,
        );
        expect(await c.jumpTo(destino, found: ocorrencia), isTrue);
        final p = (doc(c).current as PageSnapshot).page;
        expect(doc(c).mark.spine, destino.spine);
        expect(destino.offset, inInclusiveRange(p.start, p.end - 1));
        expect(doc(c).found, ocorrencia);
        expect((c.state as ReaderReady).back?.refPage, pagOrigem);
      },
    );

    test('jumpTo para a mesma página de referência não guarda volta', () async {
      final c = await aberto();
      final aqui = doc(c).numbers.refPage;
      expect(await c.jumpToPage(aqui), isTrue);
      expect((c.state as ReaderReady).back, isNull);
      expect(await c.jumpTo(doc(c).mark), isTrue);
      expect((c.state as ReaderReady).back, isNull);
    });

    test(
      'toggleBookmark: grava com versão, apaga com deleted_at e grava de novo',
      () async {
        final c = await aberto();
        // o livro abre na capa (só imagem): a fita vale numa página de texto
        await c.jumpToPage(10);
        final dao = BookmarksDao(h.livro.db);
        await c.toggleBookmark();
        final m = (await dao.forBook(h.livro.userBookId)).single;
        expect(m.refPage, doc(c).numbers.refPage);
        expect(m.meta.userId, usuarioTeste);
        expect(m.excerpt, isNotEmpty);
        expect(m.locator, isA<EpubLocator>());
        await c.toggleBookmark();
        expect(await dao.forBook(h.livro.userBookId), isEmpty);
        final linhas = await h.livro.db
            .customSelect(
              'SELECT deleted_at, version_hlc FROM bookmarks WHERE id = ?',
              variables: [Variable.withString(m.id)],
            )
            .get();
        expect(linhas.single.readNullable<String>('deleted_at'), isNotNull);
        expect(
          linhas.single.read<String>('version_hlc'),
          isNot(m.meta.version.toString()),
        );
        await c.toggleBookmark();
        expect(await dao.forBook(h.livro.userBookId), hasLength(1));
      },
    );

    test('toggleTheme: Creme → Noite → Creme; Sépia → Noite → Sépia (último claro no aparelho); mesma página', () async {
      final c = await aberto();
      final antes = doc(c).mark;
      await c.toggleTheme();
      expect(c.paper, ReaderPaper.noite);
      expect(c.palette.paper, const Color(0xFF1F1B17));
      expect(c.typography!.ink, const Color(0xFFE3D9C6));
      expect(
        (doc(c).current as PageSnapshot).typography.ink,
        const Color(0xFFE3D9C6),
      );
      expect(doc(c).mark, antes);
      final ajuste = await ReaderSettingsDao(h.livro.db).forUser(usuarioTeste);
      expect(ajuste!.paper, ReaderPaper.noite);
      expect(await KvDao(h.livro.db).get(lastLightPaperKey), 'creme');
      await c.toggleTheme();
      expect(c.paper, ReaderPaper.creme);
      expect(
        (await ReaderSettingsDao(h.livro.db).forUser(usuarioTeste))!.paper,
        ReaderPaper.creme,
      );

      // com Sépia gravada, volta a Sépia
      await ReaderSettingsDao(h.livro.db).upsert(
        (await ReaderSettingsDao(h.livro.db).forUser(usuarioTeste))!
            .copyWith(paper: ReaderPaper.sepia),
      );
      final c2 = await aberto();
      expect(c2.paper, ReaderPaper.sepia);
      await c2.toggleTheme();
      expect(await KvDao(h.livro.db).get(lastLightPaperKey), 'sepia');
      await c2.toggleTheme();
      expect(c2.paper, ReaderPaper.sepia);
      expect(h.erros, isEmpty);
    });

    test('minutesToday soma a sessão aberta; timeLeft = restante ÷ velocidade e some na última página', () async {
      final c = await aberto();
      c.setVisible(true);
      c.interaction();
      h.agora = const Duration(minutes: 3);
      expect(await c.minutesToday(), 3);
      final n = doc(c).numbers;
      final esperado = timeLeftFor(
        ((1 - n.progression) * h.livro.index.totalChars).round(),
        defaultCharsPerMinute,
      );
      expect(c.timeLeft(), esperado);
      // fim do livro (D-124): a última página da tela, mesmo que o rodapé não diga a última de referência
      await doc(c).goToRefPage(n.refTotal);
      while (await doc(c).turn(PageDirection.forward)) {}
      expect(doc(c).atEnd, isTrue);
      expect(c.timeLeft(), isNull);
      expect(await doc(c).turn(PageDirection.backward), isTrue);
      expect(c.timeLeft(), isNotNull);
    });

    test('Tema: falha do banco não derruba a leitura; o papel e o último claro ficam como estavam', () async {
      final c = await aberto();
      h.donoFalha = true;
      await c.toggleTheme();
      expect(c.state, isA<ReaderReady>());
      expect(c.paper, ReaderPaper.creme);
      expect(h.erros, [isA<StateError>()]);
      expect(await KvDao(h.livro.db).get(lastLightPaperKey), isNull);
      h.donoFalha = false;
      await c.toggleTheme();
      expect(c.paper, ReaderPaper.noite);
    });

    test('abrir: o papel da conta chega à tela antes da página (sem passar pelo Creme)', () async {
      await ReaderSettingsDao(h.livro.db).upsert(
        ReaderSettings(
          id: usuarioTeste,
          meta: metaTeste(),
          paper: ReaderPaper.noite,
        ),
      );
      final c = h.controller();
      addTearDown(() async {
        await c.close();
        c.dispose();
      });
      final papeis = <(ReaderPaper, bool)>[];
      c.addListener(() => papeis.add((c.paper, c.state is ReaderReady)));
      await c.open(_tela);
      final pronto = papeis.indexWhere((p) => p.$2);
      final noite = papeis.indexWhere((p) => p.$1 == ReaderPaper.noite);
      expect(
        noite,
        inInclusiveRange(0, pronto - 1),
        reason: 'o Noite avisado antes da página',
      );
      expect(
        papeis.skip(noite).every((p) => p.$1 == ReaderPaper.noite),
        isTrue,
      );
    });

    test('velocidade que falha: abre com a padrão e relata', () async {
      h.velocidade = (_, _) async => throw StateError('sessões ilegíveis');
      final c = await aberto();
      expect(c.state, isA<ReaderReady>());
      expect(h.erros, [isA<StateError>()]);
      final n = doc(c).numbers;
      expect(
        c.timeLeft(),
        timeLeftFor(
          ((1 - n.progression) * h.livro.index.totalChars).round(),
          defaultCharsPerMinute,
        ),
      );
    });

    test('barra numa tela grande (página da tela > 1.500 caracteres): pedir a próxima sempre anda', () async {
      final c = await aberto(
        tela: (
          size: const Size(1400, 2000),
          padding: EdgeInsets.zero,
          devicePixelRatio: 2.0,
        ),
      );
      await c.jumpToPage(100);
      for (var i = 0; i < 5; i++) {
        final antes = doc(c).numbers.refPage;
        final marca = doc(c).mark;
        await c.jumpToPage(antes + 1);
        expect(doc(c).mark, isNot(marca), reason: 'pág. $antes → ${antes + 1}');
        expect(doc(c).numbers.refPage, greaterThan(antes));
      }
    });
    test('prazo só ao fechar (D-125): com os controles ou a busca por cima, a volta não conta os 6 s nem as viradas; ao fechar, conta do zero', () async {
      final c = await aberto();
      BackLink? volta() => (c.state as ReaderReady).back;
      c.holdBack(true); // os controles abertos: a barra de posição salta
      expect(await c.jumpToPage(200), isTrue);
      expect(volta(), isNotNull);
      expect(h.prazos.pendentes, 0, reason: 'a pílula escondida não tem prazo');
      h.prazos.avancar(const Duration(seconds: 60));
      await c.turn(PageDirection.forward);
      await c.turn(PageDirection.forward);
      expect(volta(), isNotNull, reason: 'nem as viradas contam');
      c.holdBack(false); // fecharam: a pílula aparece e o prazo começa
      expect(h.prazos.pendentes, 1);
      h.prazos.avancar(const Duration(seconds: 5));
      await c.turn(PageDirection.forward);
      expect(volta(), isNotNull, reason: '5 s e 1 virada depois de fechar');
      // abrir de novo para tudo; fechar recomeça do zero (6 s e 2 viradas)
      c.holdBack(true);
      expect(h.prazos.pendentes, 0);
      h.prazos.avancar(const Duration(seconds: 30));
      c.holdBack(false);
      h.prazos.avancar(const Duration(seconds: 5));
      await c.turn(PageDirection.forward);
      expect(volta(), isNotNull, reason: 'as viradas também recomeçam');
      h.prazos.avancar(const Duration(seconds: 1));
      expect(volta(), isNull, reason: '6 s depois de fechar');
      // sem volta, segurar e soltar não cria prazo
      c
        ..holdBack(true)
        ..holdBack(false);
      expect(h.prazos.pendentes, 0);
      // leitor de tela (sem prazo, D-116): soltar não cria prazo; só as 2 viradas, depois de fechar
      c.holdBack(true);
      await c.jumpToPage(10, timed: false);
      await c.turn(PageDirection.forward);
      await c.turn(PageDirection.forward);
      c.holdBack(false);
      expect(h.prazos.pendentes, 0);
      await c.turn(PageDirection.forward);
      expect(volta(), isNotNull);
      await c.turn(PageDirection.forward);
      expect(volta(), isNull);
    });

    test('saltos seguidos (D-126): a volta fica para antes do 1º salto; o prazo e as viradas recomeçam a cada salto', () async {
      final c = await aberto();
      final origem = doc(c).mark;
      final pagOrigem = doc(c).numbers.refPage;
      BackLink? volta() => (c.state as ReaderReady).back;
      await c.jumpToPage(200);
      h.prazos.avancar(const Duration(seconds: 5));
      await c.turn(PageDirection.forward);
      // a busca depois da barra
      final destino = doc(c).markOfRefPage(300);
      await c.jumpTo(
        destino,
        found: (
          unit: destino.spine,
          from: destino.offset,
          to: destino.offset + 3,
        ),
      );
      expect(volta(), (mark: origem, refPage: pagOrigem));
      h.prazos.avancar(const Duration(seconds: 5));
      await c.turn(PageDirection.forward);
      expect(
        volta(),
        isNotNull,
        reason: 'o 2º salto recomeçou os 6 s e as viradas',
      );
      expect(h.prazos.pendentes, 1, reason: 'um prazo só');
      await c.jumpToPage(100);
      expect(volta(), (mark: origem, refPage: pagOrigem));
      await doc(c).flush();
      final pos = await ReadingPositionsDao(h.livro.db)
          .forBook(h.livro.userBookId);
      expect(
        (pos!.locator as EpubLocator).spine,
        origem.spine,
        reason: 'o alfinete continua na origem (D-115)',
      );
      await c.back();
      expect(doc(c).mark, origem);
      expect(volta(), isNull);
    });

    test('saltos seguidos: voltar pela barra à página de onde se saiu tira a pílula (D-119)', () async {
      final c = await aberto();
      final pagOrigem = doc(c).numbers.refPage;
      BackLink? volta() => (c.state as ReaderReady).back;
      await c.jumpToPage(200);
      expect(volta(), isNotNull);
      await c.jumpToPage(pagOrigem);
      expect(doc(c).numbers.refPage, pagOrigem);
      expect(volta(), isNull);
      expect(h.prazos.pendentes, 0);
    });
  });

  group('G15', () {
    test('setBookmark (D-152): tira com versão; devolve a mesma linha (id, criação, excerto, página); repetido não grava', () async {
      final c = await aberto();
      await c.jumpToPage(10);
      final dao = BookmarksDao(h.livro.db);
      await c.toggleBookmark();
      final m = (await dao.forBook(h.livro.userBookId)).single;
      await c.setBookmark(m, on: false);
      expect(await dao.forBook(h.livro.userBookId), isEmpty);
      final tirada = (await dao.byId(m.id))!;
      expect(tirada.meta.isDeleted, isTrue);
      expect(tirada.meta.version.compareTo(m.meta.version), greaterThan(0));
      // tirar de novo: nada muda
      await c.setBookmark(m, on: false);
      expect((await dao.byId(m.id))!.meta, tirada.meta);
      // devolve: a mesma linha, viva, com versão maior
      await c.setBookmark(m, on: true);
      final volta = (await dao.forBook(h.livro.userBookId)).single;
      expect(volta.id, m.id);
      expect(volta.meta.createdAt, m.meta.createdAt);
      expect(volta.excerpt, m.excerpt);
      expect(volta.refPage, m.refPage);
      expect(volta.locator, m.locator);
      expect(volta.meta.version.compareTo(tirada.meta.version), greaterThan(0));
      // devolver a que já está viva: nada muda
      await c.setBookmark(m, on: true);
      expect((await dao.byId(m.id))!.meta, volta.meta);
      expect(h.erros, isEmpty);
    });

    test('setBookmark: a linha mais nova do banco vale (outro aparelho tirou); falha vai para onError', () async {
      final c = await aberto();
      await c.jumpToPage(10);
      final dao = BookmarksDao(h.livro.db);
      await c.toggleBookmark();
      final m = (await dao.forBook(h.livro.userBookId)).single;
      // outro aparelho tirou: tirar daqui com a cópia velha não grava de novo
      await c.toggleBookmark();
      final tirada = (await dao.byId(m.id))!;
      await c.setBookmark(m, on: false);
      expect((await dao.byId(m.id))!.meta, tirada.meta);
      // o banco recusa a gravação: o erro é relatado, nada lança e a marca continua tirada
      await h.livro.db.customStatement(
        'CREATE TRIGGER g15_falha BEFORE UPDATE ON bookmarks '
        "BEGIN SELECT RAISE(ABORT, 'disco cheio'); END",
      );
      await c.setBookmark(m, on: true);
      expect(h.erros, hasLength(1));
      expect((await dao.byId(m.id))!.meta.isDeleted, isTrue);
    });
  });

  group('G14', () {
    Future<ReaderSettings?> linha() =>
        ReaderSettingsDao(h.livro.db).forUser(usuarioTeste);

    /// Segura as fatias de layout (as tarefas do `SchedulerBinding`) até soltar: a repaginação fica em curso.
    void Function() seguraLayout() {
      final b = SchedulerBinding.instance;
      b.schedulingStrategy = ({
        required int priority,
        required SchedulerBinding scheduler,
      }) => false;
      var solto = false;
      void solta() {
        if (solto) return;
        solto = true;
        b.schedulingStrategy = defaultSchedulingStrategy;
        // acorda a fila parada
        unawaited(b.scheduleTask<void>(() {}, Priority.animation));
      }

      addTearDown(solta);
      return solta;
    }

    /// Espera [pronto] em tempo de verdade (o banco e o layout andam sozinhos), até 2 s.
    Future<void> ate(FutureOr<bool> Function() pronto) async {
      for (var i = 0; i < 200 && !await pronto(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(await pronto(), isTrue, reason: 'não chegou a tempo');
    }

    test('applySettings: grava com versão, repagina mantendo o caractere e avisa a tela', () async {
      final c = await aberto();
      for (var i = 0; i < 3; i++) {
        await c.turn(PageDirection.forward);
      }
      final lendo = doc(c).mark;
      var avisos = 0;
      c.addListener(() => avisos++);
      await c.applySettings(
        (l) => l.copyWith(fontStep: 7, fontFamily: ReaderFontFamily.lora),
      );
      expect(
        c.look,
        const ReaderLook(fontStep: 7, fontFamily: ReaderFontFamily.lora),
      );
      expect(
        (c.typography!.fontSize, c.typography!.font),
        (26.0, ReaderFontFamily.lora),
      );
      final p = doc(c).current as PageSnapshot;
      expect(p.typography.font, ReaderFontFamily.lora);
      expect(lendo.offset, inInclusiveRange(p.shown!.from, p.shown!.to - 1));
      final l1 = await linha();
      expect(l1!.look, c.look);
      expect(avisos, greaterThan(0));
      // outra mudança: nova versão (LWW) e, de volta aos ajustes de antes, a mesma página
      await c.applySettings(
        (l) => l.copyWith(fontStep: 4, fontFamily: ReaderFontFamily.literata),
      );
      final l2 = await linha();
      expect(l2!.meta.version.compareTo(l1.meta.version), greaterThan(0));
      expect(l2.meta.createdAt, l1.meta.createdAt);
      expect(doc(c).mark, lendo);
      expect(h.erros, isEmpty);
    });

    test(
      'sem linha na conta: cria com os padrões da tela 26 mais a mudança',
      () async {
        final c = await aberto();
        expect(await linha(), isNull);
        expect(c.look, const ReaderLook());
        await c.applySettings((l) => l.copyWith(margins: ReaderMargins.larga));
        final l = await linha();
        expect(
          (l!.id, l.meta.userId, l.look),
          (
            usuarioTeste,
            usuarioTeste,
            const ReaderLook(margins: ReaderMargins.larga),
          ),
        );
        expect(c.typography!.sideMargin, 40);
      },
    );

    test('a mesma escolha não grava nem repagina', () async {
      final c = await aberto();
      final antes = doc(c).current as PageSnapshot;
      await c.applySettings((l) => l);
      expect(await linha(), isNull);
      final agora = doc(c).current as PageSnapshot;
      expect(agora.typography, same(antes.typography), reason: 'sem repaginar');
      expect(agora.page, same(antes.page));
    });

    test('só o papel: a cor do texto troca sem repaginar; um papel claro vira o último claro', () async {
      final c = await aberto();
      final quebras = (doc(c).current as PageSnapshot).typography.layoutKey;
      final inicio = doc(c).current.shown;
      await c.applySettings((l) => l.copyWith(paper: ReaderPaper.branco));
      expect(c.paper, ReaderPaper.branco);
      expect(c.palette, ReaderPalette.of(ReaderPaper.branco));
      expect(c.typography!.ink, ReaderPalette.of(ReaderPaper.branco).text);
      final p = doc(c).current as PageSnapshot;
      expect((p.typography.layoutKey, p.shown), (quebras, inicio));
      expect(p.typography.ink, ReaderPalette.of(ReaderPaper.branco).text);
      expect(await KvDao(h.livro.db).get(lastLightPaperKey), 'branco');
      // o Noite pela folha guarda o claro de antes; o Tema volta a ele
      await c.applySettings((l) => l.copyWith(paper: ReaderPaper.noite));
      expect(await KvDao(h.livro.db).get(lastLightPaperKey), 'branco');
      await c.toggleTheme();
      expect(c.paper, ReaderPaper.branco);
      expect((await linha())!.paper, ReaderPaper.branco);
      expect(h.erros, isEmpty);
    });

    test('toques rápidos somam na fila e a tela termina no último', () async {
      final c = await aberto();
      await Future.wait([
        for (var i = 0; i < 3; i++)
          c.applySettings(
            (l) => l.copyWith(fontStep: math.min(7, l.fontStep + 1)),
          ),
      ]);
      expect(c.look.fontStep, 7);
      expect((await linha())!.fontStep, 7);
      expect((doc(c).current as PageSnapshot).typography.fontSize, 26);
      expect(h.erros, isEmpty);
    });

    test('falha ao gravar: relatada; os ajustes, a tipografia e a página ficam como estavam', () async {
      final c = await aberto();
      final antes = doc(c).current as PageSnapshot;
      h.donoFalha = true;
      await c.applySettings((l) => l.copyWith(fontStep: 1));
      expect(c.look, const ReaderLook());
      expect(c.typography!.fontSize, 20.5);
      final agora = doc(c).current as PageSnapshot;
      expect(agora.typography, same(antes.typography));
      expect(agora.page, same(antes.page));
      expect(h.erros, [isA<StateError>()]);
      expect(c.state, isA<ReaderReady>());
    });

    test('falha ao guardar o último claro: relatada; o papel vale (o ajuste já está gravado)', () async {
      final c = await aberto();
      await h.livro.db.customStatement(
        "CREATE TRIGGER kv_falha BEFORE INSERT ON kv WHEN NEW.key = '$lastLightPaperKey' "
        "BEGIN SELECT RAISE(ABORT, 'disco cheio'); END",
      );
      await c.applySettings((l) => l.copyWith(paper: ReaderPaper.branco));
      final branco = ReaderPalette.of(ReaderPaper.branco).text;
      expect(c.paper, ReaderPaper.branco);
      expect((await linha())!.paper, ReaderPaper.branco);
      expect(c.typography!.ink, branco);
      expect((doc(c).current as PageSnapshot).typography.ink, branco);
      expect(await KvDao(h.livro.db).get(lastLightPaperKey), isNull);
      expect(h.erros, hasLength(1));
      expect(c.state, isA<ReaderReady>());
    });

    test('a sessão reabre enquanto grava ("Tentar de novo"): o ajuste gravado vai para o livro de agora', () async {
      final c = await aberto();
      final antigo = doc(c);
      final espera = h.donoEspera = Completer<void>();
      final f = c.applySettings((l) => l.copyWith(paper: ReaderPaper.branco));
      await Future<void>.delayed(Duration.zero);
      expect(h.donoEspera, isNull, reason: 'a gravação espera pela conta');
      await c
          .retry(); // lê os ajustes de antes (a gravação ainda não aconteceu)
      expect(doc(c), isNot(same(antigo)));
      expect(c.paper, ReaderPaper.creme);
      espera.complete();
      await f;
      final branco = ReaderPalette.of(ReaderPaper.branco).text;
      expect(c.paper, ReaderPaper.branco);
      expect(c.typography!.ink, branco);
      expect((doc(c).current as PageSnapshot).typography.ink, branco);
      expect((await linha())!.paper, ReaderPaper.branco);
      expect(h.erros, isEmpty);
      expect(c.state, isA<ReaderReady>());
    });

    test('o livro sai no meio da troca de cor ("Tentar de novo"): a falha da cor não escapa; vale o livro novo', () async {
      // sem o atalho do cache: a página na cor nova espera pelo layout (que fica seguro)
      await h.livro.db.customStatement('DROP TABLE page_layout_cache');
      final c = await aberto();
      final antigo = doc(c);
      final solta = seguraLayout();
      final f = c.applySettings((l) => l.copyWith(paper: ReaderPaper.branco));
      // o último claro é o fim da gravação: depois dele, a troca de cor fica parada no layout
      await ate(
        () async => await KvDao(h.livro.db).get(lastLightPaperKey) == 'branco',
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final reabrir = c.retry(); // solta o livro de antes no meio da troca
      Object? escapou;
      await f.catchError((Object e) {
        escapou = e;
      });
      expect(escapou, isNull);
      solta();
      await reabrir;
      expect(doc(c), isNot(same(antigo)));
      expect(c.state, isA<ReaderReady>());
      expect(c.paper, ReaderPaper.branco, reason: 'a reabertura leu o gravado');
      expect(
        (doc(c).current as PageSnapshot).typography.ink,
        ReaderPalette.of(ReaderPaper.branco).text,
      );
      expect(h.erros, isEmpty);
    });

    test('trocar o papel no meio de uma repaginação não segura a fila: o papel vai junto com ela', () async {
      final c = await aberto();
      final solta = seguraLayout();
      final a = c.applySettings((l) => l.copyWith(fontStep: 7));
      final b = c.applySettings((l) => l.copyWith(paper: ReaderPaper.noite));
      await ate(() => c.paper == ReaderPaper.noite);
      expect(c.look, const ReaderLook(fontStep: 7, paper: ReaderPaper.noite));
      expect(
        (doc(c).current as PageSnapshot).typography.fontSize,
        20.5,
        reason: 'a página nova ainda não chegou',
      );
      solta();
      await Future.wait([a, b]);
      final noite = ReaderPalette.of(ReaderPaper.noite).text;
      final p = doc(c).current as PageSnapshot;
      expect((p.typography.fontSize, p.typography.ink), (26.0, noite));
      expect(c.typography!.ink, noite);
      expect(h.erros, isEmpty);
    });

    test('D-148: o ajuste que chegou de outro aparelho com o livro aberto fica; o toque daqui soma a ele', () async {
      final c = await aberto();
      // outro aparelho (pela sincronização): margens largas
      await ReaderSettingsDao(h.livro.db).upsert(
        ReaderSettings(
          id: usuarioTeste,
          meta: metaTeste(),
          margins: ReaderMargins.larga,
        ),
      );
      expect(c.look.margins, ReaderMargins.media, reason: 'a sessão não sabe');
      await c.applySettings((l) => l.copyWith(fontStep: 5));
      const esperado = ReaderLook(fontStep: 5, margins: ReaderMargins.larga);
      expect((await linha())!.look, esperado);
      expect(c.look, esperado);
      expect((c.typography!.fontSize, c.typography!.sideMargin), (22.0, 40.0));
      final p = doc(c).current as PageSnapshot;
      expect((p.typography.fontSize, p.typography.sideMargin), (22.0, 40.0));
      // chega de novo de fora (entrelinha solta) e aqui muda só o papel: a entrelinha entra junto e repagina
      final linhaAgora = (await linha())!;
      await ReaderSettingsDao(h.livro.db).upsert(
        linhaAgora.withLook(
          linhaAgora.look.copyWith(lineSpacing: ReaderLineSpacing.solto),
        ),
      );
      await c.applySettings((l) => l.copyWith(paper: ReaderPaper.sepia));
      final fim = esperado.copyWith(
        lineSpacing: ReaderLineSpacing.solto,
        paper: ReaderPaper.sepia,
      );
      expect(((await linha())!.look, c.look), (fim, fim));
      final q = doc(c).current as PageSnapshot;
      expect(
        (q.typography.lineSpacing, q.typography.ink),
        (1.95, ReaderPalette.of(ReaderPaper.sepia).text),
      );
      expect(h.erros, isEmpty);
    });

    test('reabrir: a sessão monta pela linha gravada', () async {
      final c = await aberto();
      await c.applySettings(
        (l) => l.copyWith(
          fontFamily: ReaderFontFamily.atkinson,
          lineSpacing: ReaderLineSpacing.solto,
        ),
      );
      final c2 = await aberto();
      expect(c2.look, c.look);
      expect(
        (c2.typography!.font, c2.typography!.lineSpacing),
        (ReaderFontFamily.atkinson, 1.95),
      );
      expect(
        (doc(c2).current as PageSnapshot).typography.font,
        ReaderFontFamily.atkinson,
      );
    });
  });
}
