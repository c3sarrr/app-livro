// Construtores de entidades pessoais para os testes do banco (valores válidos por padrão).
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/ink_layer.dart';
import 'package:app_leitura/features/reader/domain/bookmark.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reading_position.dart';
import 'package:app_leitura/features/reader/domain/reading_session.dart';

const String usuarioTeste = '6f1c2a3b-4d5e-4f60-8a7b-9c0d1e2f3a4b';
const String shaTeste =
    'a3f1c2d4e5f60718293a4b5c6d7e8f90a1b2c3d4e5f60718293a4b5c6d7e8f90';
final DateTime t0Teste = DateTime.utc(2026, 9, 20, 23);

/// sha256 de teste diferente por livro (o servidor não aceita dois livros ativos com o mesmo arquivo).
String shaDoLivroTeste(int n) =>
    shaTeste.substring(0, 56) + n.toRadixString(16).padLeft(8, '0');

/// UUID de teste: `0199a7c4-2f00-7a10-8b20-<n em 12 dígitos>`.
String idTeste(int n) =>
    '0199a7c4-2f00-7a10-8b20-${n.toString().padLeft(12, '0')}';

RecordMeta metaTeste({
  DateTime? em,
  int contador = 0,
  bool apagado = false,
  String userId = usuarioTeste,
}) {
  final t = em ?? t0Teste;
  return RecordMeta(
    userId: userId,
    createdAt: t,
    updatedAt: t,
    deletedAt: apagado ? t : null,
    version: Hlc(t.millisecondsSinceEpoch, contador, 'aparelhoA'),
  );
}

UserBook livroTeste(
  int n, {
  String title = 'Dom Casmurro',
  bool apagado = false,
  String dono = usuarioTeste,
}) => UserBook(
  id: idTeste(n),
  meta: metaTeste(apagado: apagado, userId: dono),
  title: title,
  authorDisplay: 'Machado de Assis',
  format: BookFileFormat.epub,
  status: ShelfStatus.reading,
  contentSha256: shaDoLivroTeste(n),
  refPagesTotal: 256,
  refPageVersion: 1,
  chaptersTotal: 148,
  addedAt: DateTime.utc(2026, 9, n.clamp(1, 28), 12),
);

EpubAnchor ancoraTeste({
  int inicio = 0,
  String exato = 'aqueles olhos de Capitu',
  int pagina = 159,
}) => EpubAnchor(
  sha: shaTeste,
  spine: 32,
  start: inicio,
  end: inicio + exato.length,
  quote: TextQuote(exact: exato),
  refPage: pagina,
);

EpubLocator localizadorTeste({int pagina = 159}) => EpubLocator(
  sha: shaTeste,
  spine: 32,
  offset: 120,
  quote: const TextQuote(exact: 'Retórica dos namorados'),
  refPage: pagina,
  progression: 0.62113,
);

Annotation grifoTeste(
  int n, {
  required String livro,
  String cor = '#FED170',
  int pagina = 159,
  int inicio = 0,
  String exato = 'aqueles olhos de Capitu',
  bool apagado = false,
  int contador = 0,
  String dono = usuarioTeste,
}) => Annotation(
  id: idTeste(n),
  meta: metaTeste(apagado: apagado, contador: contador, userId: dono),
  userBookId: livro,
  kind: AnnotationKind.highlight,
  groupId: idTeste(n),
  anchor: ancoraTeste(inicio: inicio, exato: exato, pagina: pagina),
  refPage: pagina,
  chapterIndex: 31,
  color: cor,
  style: HighlightStyle.fill,
  fillHeight: FillHeight.medium,
);

Annotation notaTeste(
  int n, {
  required String livro,
  required Annotation pai,
  required String texto,
  String? dono,
}) => Annotation(
  id: idTeste(n),
  meta: metaTeste(userId: dono ?? pai.meta.userId),
  userBookId: livro,
  kind: AnnotationKind.note,
  parentId: pai.id,
  groupId: pai.groupId,
  anchor: pai.anchor,
  refPage: pai.refPage,
  chapterIndex: pai.chapterIndex,
  noteText: texto,
);

InkLayer camadaTeste(int n, {required String livro}) => InkLayer(
  id: idTeste(n),
  meta: metaTeste(),
  userBookId: livro,
  kind: InkLayerKind.space,
  anchor: ancoraTeste(inicio: 200, exato: ''),
  spaceLines: 3,
  collapsed: true,
  strokesB64: '',
  strokeCount: 0,
);

ReadingPosition posicaoTeste(String livro, {String dono = usuarioTeste}) =>
    ReadingPosition(
      id: livro,
      meta: metaTeste(userId: dono),
      locator: localizadorTeste(),
      refPage: 159,
      chapterIndex: 31,
      progression: 0.62113,
      deviceId: 'aparelhoA',
    );

ReadingSession sessaoTeste(
  int n, {
  required String livro,
  required DateTime inicio,
  int segundos = 600,
  String dono = usuarioTeste,
}) => ReadingSession(
  id: idTeste(n),
  meta: metaTeste(userId: dono),
  userBookId: livro,
  startedAt: inicio,
  endedAt: inicio.add(Duration(seconds: segundos)),
  activeSeconds: segundos,
  refPageFrom: 150,
  refPageTo: 159,
  pagesViewed: 9,
  source: SessionSource.auto,
  deviceId: 'aparelhoA',
);

Bookmark marcadorTeste(
  int n, {
  required String livro,
  int pagina = 159,
  bool apagado = false,
  String dono = usuarioTeste,
}) => Bookmark(
  id: idTeste(n),
  meta: metaTeste(apagado: apagado, userId: dono),
  userBookId: livro,
  locator: localizadorTeste(pagina: pagina),
  refPage: pagina,
  chapterIndex: 31,
  excerpt: 'Retórica dos namorados, dá-me uma comparação exata e poética…',
);
