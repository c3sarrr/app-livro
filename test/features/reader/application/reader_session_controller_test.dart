// G11.2 — a sessão de leitura da tela (desenho G11 §2): abre o livro da estante pelo id (Opening → Ready), diz
// por que não abriu (D-21, D-92: fora da estante, de outra conta, arquivo fora do aparelho, danificado, páginas
// fixas, falha inesperada com "Tentar de novo"), indexa ao abrir quando falta o índice ("Preparando o livro…"),
// liga tempo (D-95), posição (G10) e tela acesa (D-111) à página e ao ciclo de vida, e guarda a volta de um
// link por 6 s ou 2 viradas (D-108). Relógio monotônico falso no tempo; o prazo da volta anda à mão.

import 'dart:io';

import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/application/reader_session_controller.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/chapter_content.dart';
import 'package:app_leitura/features/reader/content/content_blocks.dart';
import 'package:app_leitura/features/reader/content/content_failure.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/layout_scheduler.dart';
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

  ReaderSessionController controller() {
    final c = ReaderSessionController(
      userBookId: livro.userBookId,
      deps: ReaderDeps(
        db: livro.db,
        versioning: livro.versioning,
        owner: () async => usuarioTeste,
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

  Future<ReaderSessionController> aberto() async {
    final c = h.controller();
    addTearDown(() async {
      await c.close();
      c.dispose();
    });
    await c.open(_tela);
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

    test('exemplar físico não tem arquivo', () async {
      expect(
        await falha(
          () => UserBooksDao(h.livro.db)
              .upsert(h.livro.book.copyWith(format: BookFileFormat.physical)),
        ),
        ReaderFailure.fileMissing,
      );
    });

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
}
