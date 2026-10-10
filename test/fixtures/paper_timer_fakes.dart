// T04 — os falsos do cronômetro do livro de papel: a sessão aberta em memória, o writer que só anota, a estante fixa,
// o tique manual (um `Timer.periodic` real nunca deixa o `pumpAndSettle` assentar) e os overrides que o arnês da Início
// e os testes do controlador usam.
import 'dart:async';

import 'package:app_leitura/features/reading_session/application/paper_timer_controller.dart';
import 'package:app_leitura/features/reading_session/application/second_ticker.dart';
import 'package:app_leitura/features/reading_session/data/paper_book_source.dart';
import 'package:app_leitura/features/reading_session/data/paper_session_writer.dart';
import 'package:app_leitura/features/reading_session/data/paper_timer_store.dart';
import 'package:app_leitura/features/reading_session/domain/open_paper_session.dart';
import 'package:app_leitura/features/reading_session/domain/paper_timer_failure.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'telas/inicio01b.dart';

/// O dono das sessões dos testes (o usuário do mundo de referência).
const String donoDaSessao = '6f1c2a3b-4d5e-4f60-8a7b-9c0d1e2f3a4b';

final class MemoryPaperTimerStore implements PaperTimerStore {
  MemoryPaperTimerStore([Map<String, OpenPaperSession>? sessoes])
    : sessoes = {...?sessoes};

  final Map<String, OpenPaperSession> sessoes;
  int gravacoes = 0;

  @override
  Future<OpenPaperSession?> load(String owner) async => sessoes[owner];

  @override
  Future<void> save(String owner, OpenPaperSession session) async {
    gravacoes++;
    sessoes[owner] = session;
  }

  @override
  Future<void> clear(String owner) async => sessoes.remove(owner);
}

final class RecordingPaperSessionWriter implements PaperSessionWriter {
  final List<PaperSessionEnd> fins = [];
  final List<PaperSessionRecord> divisoes = [];

  /// O que o próximo `end` lança (e esquece).
  Object? falha;

  @override
  Future<void> end(PaperSessionEnd end) async {
    final f = falha;
    if (f != null) {
      falha = null;
      throw f;
    }
    fins.add(end);
  }

  @override
  Future<void> recordOnly(PaperSessionRecord record) async {
    final f = falha;
    if (f != null) {
      falha = null;
      throw f;
    }
    divisoes.add(record);
  }
}

final class FixedPaperBookSource implements PaperBookSource {
  FixedPaperBookSource(this.livros, {this.paginasDoCatalogo = const {}});

  /// Por id do livro (todos do [donoDaSessao]).
  final Map<String, PaperBook> livros;
  final Map<String, int> paginasDoCatalogo;
  final List<String> consultasDoCatalogo = [];

  @override
  Future<PaperBook?> book(String owner, String userBookId) async =>
      owner == donoDaSessao ? livros[userBookId] : null;

  @override
  Future<int?> catalogPages(String isbn13) async {
    consultasDoCatalogo.add(isbn13);
    return paginasDoCatalogo[isbn13];
  }
}

/// O tique dos testes: só anda quando o teste manda.
final class ManualTicker implements SecondTicker {
  final StreamController<void> _c = StreamController<void>.broadcast();

  @override
  Stream<void> get ticks => _c.stream;

  bool get hasListener => _c.hasListener;

  void tick() => _c.add(null);
}

/// Ids previsíveis para as sessões novas: `…000000000001`, `…000000000002`…
String Function() idsDeTeste() {
  var n = 0;
  return () => '01925a00-0000-7000-8000-${(++n).toString().padLeft(12, '0')}';
}

/// Os overrides do cronômetro para um teste: a sessão aberta (ou nenhuma), a estante, o writer e o tique — o relógio
/// é o `clockProvider` de cada teste (o do mundo, nos testes da Início). Sem [store] / [writer] / [ticker] / [ids],
/// cada container cria os seus: a sessão de um teste não vaza para o seguinte.
List<Override> overridesDaSessao({
  PaperTimerStore? store,
  RecordingPaperSessionWriter? writer,
  FixedPaperBookSource? livros,
  SecondTicker? ticker,
  String Function()? ids,
  String dono = donoDaSessao,
  Stream<String>? donos,
  Duration Function(DateTime utc)? fuso,
}) => [
  paperTimerOwnerProvider.overrideWith((ref) => donos ?? Stream.value(dono)),
  paperTimerStoreProvider.overrideWith(
    (ref) async => store ?? MemoryPaperTimerStore(),
  ),
  paperSessionWriterProvider.overrideWith(
    (ref) async => writer ?? RecordingPaperSessionWriter(),
  ),
  paperBookSourceProvider.overrideWith(
    (ref) async => livros ?? FixedPaperBookSource(const {}),
  ),
  // cada container ganha o seu tique e a sua contagem de ids (o mundo é uma lista só, para todos os testes)
  secondTickerProvider.overrideWith((ref) => ticker ?? ManualTicker()),
  paperTimerIdsProvider.overrideWith((ref) => ids ?? idsDeTeste()),
  paperTimerUtcOffsetProvider.overrideWithValue(
    fuso ?? (_) => const Duration(hours: -3),
  ),
];

/// Lança a falha tipada como o writer real (para os testes da folha).
const PaperTimerFailure livroSumiu = PaperBookGone();

/// A estante de papel das pranchas 01/01b: o Brás Cubas (sem página) e o Orgulho e Preconceito (pág. 344 de 425).
FixedPaperBookSource estanteDePapel01({
  Map<String, int> paginasDoCatalogo = const {},
}) => FixedPaperBookSource({
  TelaInicio01b.livroDaSessao.book.id: TelaInicio01b.livroDaSessao,
  TelaInicio01b.orgulho.book.id: TelaInicio01b.orgulho,
}, paginasDoCatalogo: paginasDoCatalogo);

/// A prancha 01b: a sessão do Brás Cubas rodando há 8 min 42 s (com o relógio do mundo), a estante de papel da 01.
List<Override> overridesDa01b({
  MemoryPaperTimerStore? store,
  RecordingPaperSessionWriter? writer,
  SecondTicker? ticker,
}) => overridesDaSessao(
  store: store ?? MemoryPaperTimerStore({donoDaSessao: TelaInicio01b.sessao}),
  writer: writer,
  livros: estanteDePapel01(),
  ticker: ticker,
);
