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
  ({int spine, int offset, String text, int? last})? _pending;
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

  /// Uma página apareceu: grava depois de [delay] se a pessoa ficar nela. [offset] = o 1º caractere visível (o
  /// lugar); [last] = o último da página — o capítulo gravado é o último que começa na página (D-210); sem [last],
  /// o do 1º caractere.
  void pageShown(int spine, int offset, String text, {int? last}) {
    _pending = (spine: spine, offset: offset, text: text, last: last);
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
        await _save(p.spine, p.offset, p.text, p.last);
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

  Future<void> _save(int spine, int offset, String text, int? last) async {
    final locator = locatorAt(spine, offset, text);
    final n = numbersAt(index, spine, locator.offset);
    final chapter = last == null
        ? n.chapterIndex
        : numbersAt(
            index,
            spine,
            last.clamp(locator.offset, text.length),
          ).chapterIndex;
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
          chapterIndex: chapter,
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

/// Abre [pager] onde a pessoa parou (a posição guardada em [keeper], reencontrada no arquivo de agora); sem
/// posição, no começo do livro. Noutra edição, a citação é procurada no item de mesmo número; se ela não está
/// lá (a edição nova tem itens a mais ou a menos), vale a % guardada.
Future<PagerPosition> reopen(
  BookPager pager,
  ReadingPositionKeeper keeper,
) async {
  final saved = await keeper.saved();
  final l = saved?.locator;
  if (l is! EpubLocator || saved!.meta.isDeleted) {
    return pager.openAt(pager.firstSpine, 0);
  }
  final index = pager.index;
  final byProgression = index.spineAt(
    (l.progression * index.totalChars).round(),
  );
  if (l.spine >= index.spine.length) {
    return byProgression == null
        ? pager.openAt(pager.firstSpine, 0)
        : pager.openAt(byProgression.$1, byProgression.$2);
  }
  if (l.sha == index.contentSha256) {
    return pager.openAt(l.spine, l.offset);
  }
  final content = await pager.content(l.spine);
  final (offset, method) = relocate(
    l,
    content.item.text,
    currentSha: index.contentSha256,
  );
  if (method == AnchorMethod.clamped && byProgression != null) {
    return pager.openAt(byProgression.$1, byProgression.$2);
  }
  return pager.openAt(l.spine, offset);
}
