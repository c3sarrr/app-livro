// G08.3 — capa de livro real (D-79): a foto guardada na moldura de cada seção; sem foto, a capa gerada (a mesma
// para o mesmo livro, no estilo das 9 capas do arquivo).
import 'dart:io';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/features/home/application/cover_providers.dart';
import 'package:app_leitura/features/home/data/cover_store.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/covers/book_cover.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_text_finder.dart';
import '../support/load_fonts.dart';
import '../support/personal_builders.dart';

final class _Capas implements CoverImages {
  _Capas([this.arquivo]);

  final File? arquivo;
  final List<PhotoCover> pedidos = [];
  final List<PhotoCover> descartadas = [];

  @override
  Future<void> discard(PhotoCover cover) async => descartadas.add(cover);

  @override
  Future<File?> cached(PhotoCover cover) async => arquivo;

  @override
  Future<File?> resolve(PhotoCover cover) async {
    pedidos.add(cover);
    return arquivo;
  }
}

Future<void> _pump(WidgetTester tester, Widget child, CoverImages capas) =>
    tester.pumpWidget(
      ProviderScope(
        overrides: [coverImagesProvider.overrideWithValue(capas)],
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: child),
        ),
      ),
    );

const _livro = Book(
  id: 'b1',
  title: 'A hora da estrela',
  author: 'Clarice Lispector',
  cover: PhotoCover(ref: 'ol:1', isbn13: '9786555321234'),
);

/// Devolve, a cada pedido, o próximo da lista (o último se repete).
final class _CapasEmSequencia implements CoverImages {
  _CapasEmSequencia(this.respostas);

  final List<File?> respostas;
  final List<PhotoCover> pedidos = [];

  @override
  Future<File?> cached(PhotoCover cover) async => null;

  @override
  Future<File?> resolve(PhotoCover cover) async {
    pedidos.add(cover);
    return respostas[(pedidos.length - 1).clamp(0, respostas.length - 1)];
  }

  @override
  Future<void> discard(PhotoCover cover) async {}
}

void main() {
  setUpAll(loadAppFonts);

  test('foto que não veio (rede fora) é pedida de novo depois da espera (D-79: troca quando chega)', () async {
    const c = PhotoCover(ref: 'ol:1');
    final capas = _CapasEmSequencia([null, File('capa.jpg')]);
    final container = ProviderContainer.test(
      overrides: [
        coverImagesProvider.overrideWithValue(capas),
        coverRetryDelayProvider.overrideWithValue(
          const Duration(milliseconds: 30),
        ),
      ],
    );
    final vistos = <String?>[];
    container.listen(coverFileProvider(c), (_, v) {
      if (v.hasValue) vistos.add(v.value?.path);
    }, fireImmediately: true);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(capas.pedidos, hasLength(2));
    // durante a nova tentativa o valor anterior (sem foto) continua; depois, a foto
    expect(vistos.first, isNull);
    expect(vistos.last, 'capa.jpg');
  });

  testWidgets('foto guardada que não abre: descartada e a capa gerada fica', (
    tester,
  ) async {
    final dir = Directory.systemTemp.createTempSync('booknest_capa_ruim_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final ruim = File('${dir.path}${Platform.pathSeparator}ruim.img')
      ..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0, ...List.filled(60, 7)]);
    final capas = _Capas(ruim);
    const c = PhotoCover(ref: 'ol:9');
    await tester.runAsync(() async {
      await _pump(
        tester,
        const PhotoBookCover(book: _livro, cover: c, slot: CoverSlot.hero),
        capas,
      );
      for (var i = 0; i < 40 && capas.descartadas.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    expect(capas.descartadas, [c]);
    await tester.pump();
    expect(find.byKey(const ValueKey('cover.generated')), findsOneWidget);
  });
  group('capa gerada', () {
    test(
      'a mesma para o mesmo livro (sem acento e sem caixa não muda nada)',
      () {
        final a = GeneratedCoverArt(
          title: 'A hora da estrela',
          author: 'Clarice Lispector',
          slot: CoverSlot.hero,
        );
        final b = GeneratedCoverArt(
          title: 'A HORA DA ESTRELA',
          author: 'Clarice  Lispéctor',
          slot: CoverSlot.recent,
        );
        expect(a.palette, b.palette);
        expect(a.shape, b.shape);
      },
    );

    test('livros diferentes variam (paleta e forma das capas do arquivo)', () {
      final capas = [
        for (var i = 0; i < 40; i++)
          GeneratedCoverArt(
            title: 'Livro número $i',
            author: 'Autora $i',
            slot: CoverSlot.forYou,
          ),
      ];
      expect(capas.map((c) => c.palette).toSet().length, greaterThan(6));
      expect(capas.map((c) => c.shape).toSet(), CoverShape.values.toSet());
    });
  });

  group('foto ou capa gerada na moldura da seção', () {
    testWidgets(
      'sem foto: capa gerada com título e autor, e a fonte é consultada',
      (tester) async {
        final capas = _Capas();
        await _pump(
          tester,
          const PhotoBookCover(
            book: _livro,
            cover: PhotoCover(ref: 'ol:1', isbn13: '9786555321234'),
            slot: CoverSlot.hero,
          ),
          capas,
        );
        await tester.pump();
        expect(find.byKey(const ValueKey('cover.generated')), findsOneWidget);
        expect(find.byKey(const ValueKey('cover.photo')), findsNothing);
        expect(findAppText('A hora da estrela'), findsOneWidget);
        expect(findAppText('CLARICE LISPECTOR'), findsOneWidget);
        expect(capas.pedidos, [
          const PhotoCover(ref: 'ol:1', isbn13: '9786555321234'),
        ]);
        expect(
          tester.getSize(find.byType(PhotoBookCover)),
          const Size(104, 156),
        );
      },
    );

    testWidgets('com a foto guardada: a imagem no lugar da capa gerada', (
      tester,
    ) async {
      await _pump(
        tester,
        const PhotoBookCover(
          book: _livro,
          cover: PhotoCover(ref: 'ol:1'),
          slot: CoverSlot.forYou,
        ),
        _Capas(File('capa_inexistente.jpg')),
      );
      await tester.pump();
      expect(find.byKey(const ValueKey('cover.photo')), findsOneWidget);
      expect(tester.getSize(find.byType(PhotoBookCover)), const Size(116, 174));
    });

    testWidgets('miniatura (recém-chegados): só cor e forma, 44×66', (
      tester,
    ) async {
      await _pump(
        tester,
        const PhotoBookCover(
          book: _livro,
          cover: PhotoCover(),
          slot: CoverSlot.recent,
        ),
        _Capas(),
      );
      await tester.pump();
      expect(findAppText('A hora da estrela'), findsNothing);
      expect(tester.getSize(find.byType(PhotoBookCover)), const Size(44, 66));
    });

    testWidgets('a capa é decorativa: fora da árvore de acessibilidade', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const PhotoBookCover(
          book: _livro,
          cover: PhotoCover(),
          slot: CoverSlot.hero,
        ),
        _Capas(),
      );
      await tester.pump();
      expect(find.bySemanticsLabel(RegExp('estrela')), findsNothing);
      handle.dispose();
    });
  });

  test('capas que nunca saem do cache: as de todos os livros guardados no aparelho', () async {
    final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    addTearDown(db.close);
    UserBook livro(int n, {String? capa, String? isbn, bool apagado = false}) =>
        UserBook(
          id: idTeste(n),
          meta: metaTeste(apagado: apagado),
          title: 'L$n',
          authorDisplay: 'A',
          format: BookFileFormat.physical,
          status: ShelfStatus.wantToRead,
          coverRef: capa,
          isbn13: isbn,
          addedAt: t0Teste,
        );
    for (final b in [
      livro(1, capa: 'ol:10'),
      livro(2, isbn: '9788535902778'),
      livro(3, capa: 'ol:30', apagado: true),
      livro(4),
    ]) {
      await UserBooksDao(db).upsert(b);
    }
    expect((await shelfCoverUrls(db)).map((u) => u.toString()).toSet(), {
      'https://covers.openlibrary.org/b/id/10-M.jpg?default=false',
      'https://covers.openlibrary.org/b/isbn/9788535902778-M.jpg?default=false',
    });
  });
}
