// G10.3 — posição de leitura (Anexo 03 §5.1 e §6): o 1º caractere visível da página vira um `EpubLocator`
// (citação de até 32 caracteres a partir dele, com 32 de contexto; página de referência; % com 5 casas) e é
// gravado em `reading_positions` com versão (sincroniza no Pro) — depois de 1 s parado numa página, e na hora
// ao ir para segundo plano ou fechar o livro ([flush]). Para reabrir, a posição guardada é reencontrada no
// texto de agora pela reancoragem da G09 (mesmo arquivo → o caractere guardado; outro → pela citação).
import 'dart:async';
import 'dart:math' as math;

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/reader_daos.dart';
import '../../../core/data/database/versioning.dart';
import '../../../core/data/model/record_meta.dart';
import '../content/book_index.dart';
import '../domain/anchoring.dart';
import '../domain/locator.dart';
import '../domain/reader_numbers.dart';
import '../domain/reading_position.dart';
import 'book_pager.dart';
import 'reader_errors.dart';

/// Quanto a página precisa ficar parada para a posição ser gravada.
const Duration positionSaveDelay = Duration(seconds: 1);

/// Tamanho da citação da posição (o mesmo contexto das âncoras).
const int locatorQuoteChars = 32;

final class ReadingPositionKeeper {
  ReadingPositionKeeper({
    required this._db,
    required this._versioning,
    required this._owner,
    required this.userBookId,
    required this.index,
    this.deviceId,
    this.delay = positionSaveDelay,
    this._onError = reportReaderError,
  });

  final AppDatabase _db;
  final LocalVersioning _versioning;
  final Future<String> Function() _owner;
  final String userBookId;
  final BookIndex index;
  final String? deviceId;
  final Duration delay;
  final ReaderErrorReporter _onError;

  Timer? _timer;
  ({int spine, int offset, String text})? _pending;
  Future<void> _saving = Future<void>.value();

  /// O `EpubLocator` do caractere [offset] do capítulo [spine] ([text] = texto canônico do capítulo).
  EpubLocator locatorAt(int spine, int offset, String text) {
    final at = offset.clamp(0, text.length);
    final n = numbersAt(index, spine, at);
    return EpubLocator(
      sha: index.contentSha256,
      spine: spine,
      offset: at,
      quote: quoteAt(text, at, _quoteEnd(text, at)),
      refPage: n.refPage,
      progression: n.progression,
    );
  }

  /// Uma página apareceu: grava depois de [delay] se a pessoa ficar nela.
  void pageShown(int spine, int offset, String text) {
    _pending = (spine: spine, offset: offset, text: text);
    _timer?.cancel();
    _timer = Timer(delay, () => unawaited(flush()));
  }

  /// Grava agora o que estiver pendente (segundo plano, fechar o livro).
  Future<void> flush() {
    _timer?.cancel();
    _timer = null;
    final p = _pending;
    _pending = null;
    if (p == null) return _saving;
    return _saving = _saving.then((_) async {
      try {
        await _save(p.spine, p.offset, p.text);
      } on Object catch (e, st) {
        _onError(e, st); // a próxima página tenta de novo
      }
    });
  }

  /// A posição guardada deste livro.
  Future<ReadingPosition?> saved() =>
      ReadingPositionsDao(_db).forBook(userBookId);

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _save(int spine, int offset, String text) async {
    final locator = locatorAt(spine, offset, text);
    final n = numbersAt(index, spine, locator.offset);
    final owner = await _owner();
    final dao = ReadingPositionsDao(_db);
    await _versioning.write('reading_positions', userBookId, (v) async {
      final at = DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true);
      final old = await dao.forBook(userBookId);
      await dao.upsert(
        ReadingPosition(
          id: userBookId,
          meta: RecordMeta(
            userId: owner,
            createdAt: old?.meta.createdAt ?? at,
            updatedAt: at,
            version: v,
          ),
          locator: locator,
          refPage: n.refPage,
          chapterIndex: n.chapterIndex,
          progression: n.progression,
          deviceId: deviceId,
        ),
      );
    });
  }

  /// Fim da citação: até [locatorQuoteChars] caracteres, sem cortar palavra (volta ao último espaço).
  static int _quoteEnd(String text, int start) {
    final max = math.min(text.length, start + locatorQuoteChars);
    if (max == text.length) return max;
    final cut = text.lastIndexOf(' ', max);
    return cut > start ? cut : max;
  }
}

/// Onde reabrir a partir da posição guardada [l]: (capítulo, caractere) no texto de agora ([text] = texto
/// canônico do capítulo dela; [currentSha] = arquivo de agora).
(int, int) whereToReopen(
  EpubLocator l,
  String text, {
  required String currentSha,
}) {
  final (offset, _) = relocate(l, text, currentSha: currentSha);
  return (l.spine, offset);
}

/// Abre [pager] onde a pessoa parou (a posição guardada em [keeper], reencontrada no arquivo de agora); sem
/// posição, no começo do livro.
Future<PagerPosition> reopen(
  BookPager pager,
  ReadingPositionKeeper keeper,
) async {
  final saved = await keeper.saved();
  final l = saved?.locator;
  if (l is! EpubLocator ||
      saved!.meta.isDeleted ||
      l.spine >= pager.index.spine.length) {
    return pager.openAt(pager.firstSpine, 0);
  }
  if (l.sha == pager.index.contentSha256) {
    return pager.openAt(l.spine, l.offset);
  }
  final content = await pager.content(l.spine);
  final (spine, offset) = whereToReopen(
    l,
    content.item.text,
    currentSha: pager.index.contentSha256,
  );
  return pager.openAt(spine, offset);
}
