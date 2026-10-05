// G08.3 — foto real da capa com cache no aparelho (D-79, D-85): de onde vem, o que fica guardado (aparece
// offline), o que é recusado, quando tenta de novo e o que sai quando o cache passa de 40 MB.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_leitura/features/home/data/cover_store.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Um JPEG mínimo de [n] bytes (assinatura FF D8 FF).
Uint8List _jpeg([int n = 64]) =>
    Uint8List(n)..setAll(0, const [0xFF, 0xD8, 0xFF, 0xE0]);

Uint8List _png([int n = 64]) =>
    Uint8List(n)
      ..setAll(0, const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

Uint8List _webp([int n = 64]) => Uint8List(n)
  ..setAll(0, 'RIFF'.codeUnits)
  ..setAll(8, 'WEBP'.codeUnits);

void main() {
  late Directory dir;
  late DateTime agora;
  late List<http.Request> pedidos;
  late Map<String, http.Response Function()> respostas;
  late CoverStore loja;
  Set<Uri> fixas = {};

  CoverStore nova({int maxBytes = CoverStore.defaultMaxBytes}) => CoverStore(
    dir: () async => dir,
    client: MockClient((req) async {
      pedidos.add(req);
      final r = respostas[req.url.toString()];
      if (r == null) return http.Response('', 404);
      return r();
    }),
    now: () => agora,
    pinned: () async => fixas,
    maxBytes: maxBytes,
  );

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('booknest_capas_');
    agora = DateTime.utc(2026, 10, 5, 12);
    pedidos = [];
    respostas = {};
    fixas = {};
    loja = nova();
  });
  tearDown(() => dir.delete(recursive: true));

  const ol = 'https://covers.openlibrary.org/b/id/123-M.jpg?default=false';
  const porIsbn =
      'https://covers.openlibrary.org/b/isbn/9788535902778-M.jpg?default=false';

  group('de onde vem a foto (D-79)', () {
    test('ol:<id> → Open Library por id; URL https da API; recuo pelo ISBN', () {
      expect(
        coverCandidates(
          const PhotoCover(ref: 'ol:123', isbn13: '9788535902778'),
        ).map((u) => u.toString()),
        [ol, porIsbn],
      );
      expect(
        coverCandidates(
          const PhotoCover(ref: 'https://books.google.com/x?id=1&zoom=1'),
        ).map((u) => u.toString()),
        ['https://books.google.com/x?id=1&zoom=1'],
      );
      // http vira https; nada que não seja http(s) ou ol:<número>
      expect(
        coverCandidates(
          const PhotoCover(ref: 'http://books.google.com/books/content?id=1'),
        ).map((u) => u.toString()),
        ['https://books.google.com/books/content?id=1'],
      );
      // host fora da lista das fontes: ignorado, fica o recuo pelo ISBN (G08.6)
      expect(
        coverCandidates(
          const PhotoCover(
            ref: 'https://rastreio.exemplo.com/a.jpg',
            isbn13: '9788535902778',
          ),
        ).map((u) => u.toString()),
        [porIsbn],
      );
      for (final ruim in [
        'ol:abc',
        'ol:',
        'file:///etc/passwd',
        'javascript:alert(1)',
        'ftp://x/y.jpg',
        'capa.jpg',
      ]) {
        expect(coverCandidates(PhotoCover(ref: ruim)), isEmpty, reason: ruim);
      }
      expect(coverCandidates(const PhotoCover()), isEmpty);
      expect(
        coverCandidates(const PhotoCover(isbn13: '9788535902778')).single
            .toString(),
        porIsbn,
      );
    });
  });

  group('só os hosts das fontes de capa (G08.6)', () {
    test('a lista: Open Library (e o archive.org para onde ela redireciona), Google Books, Hardcover, ISBNdb', () {
      for (final h in [
        'covers.openlibrary.org',
        'archive.org',
        'ia600502.us.archive.org',
        'ia800505.us.archive.org',
        'books.google.com',
        'books.googleusercontent.com',
        'assets.hardcover.app',
        'images.isbndb.com',
        'COVERS.OpenLibrary.org',
      ]) {
        expect(coverHostAllowed(h), isTrue, reason: h);
      }
      for (final h in [
        'rastreio.exemplo.com',
        'covers.openlibrary.org.exemplo.com',
        'exemplo.com',
        'xbooks.google.com',
        'google.com',
        'openlibrary.org.evil',
        'ia1.us.archive.org.exemplo.com',
        'iax.us.archive.org',
        'web.archive.org',
        '127.0.0.1',
        'localhost',
        '',
      ]) {
        expect(coverHostAllowed(h), isFalse, reason: h);
      }
    });

    test(
      'o Open Library redireciona para o archive.org: segue e guarda',
      () async {
        const porId =
            'https://covers.openlibrary.org/b/id/9-M.jpg?default=false';
        respostas[porId] = () => http.Response(
          '',
          302,
          headers: {'location': 'https://archive.org/download/m/9-M.jpg'},
        );
        respostas['https://archive.org/download/m/9-M.jpg'] = () =>
            http.Response(
              '',
              302,
              headers: {
                'location': 'https://ia600502.us.archive.org/m/9-M.jpg',
              },
            );
        respostas['https://ia600502.us.archive.org/m/9-M.jpg'] = () =>
            http.Response.bytes(_jpeg(), 200);
        expect(await loja.resolve(const PhotoCover(ref: 'ol:9')), isNotNull);
        expect(pedidos, hasLength(3));
      },
    );

    test(
      'redirecionamento para um host de fora: sem capa, sem ir até ele',
      () async {
        respostas['https://books.google.com/r3'] = () => http.Response(
          '',
          302,
          headers: {'location': 'https://rastreio.exemplo.com/a.jpg'},
        );
        respostas['https://rastreio.exemplo.com/a.jpg'] = () =>
            http.Response.bytes(_jpeg(), 200);
        expect(
          await loja.resolve(
            const PhotoCover(ref: 'https://books.google.com/r3'),
          ),
          isNull,
        );
        expect(
          pedidos.map((p) => p.url.host),
          isNot(contains('rastreio.exemplo.com')),
        );
      },
    );
  });

  group('baixar e guardar', () {
    test('baixa uma vez e depois vem do aparelho (aparece offline)', () async {
      respostas[ol] = () => http.Response.bytes(_jpeg(), 200);
      const c = PhotoCover(ref: 'ol:123', isbn13: '9788535902778');
      final f = await loja.resolve(c);
      expect(f, isNotNull);
      expect(await f!.readAsBytes(), _jpeg());
      expect(pedidos, hasLength(1));
      expect(pedidos.single.headers['User-Agent'], startsWith('BookNest/'));
      // outra instância (app reaberto) e sem rede: vem do disco
      respostas.clear();
      final offline = nova();
      expect(await (await offline.resolve(c))!.readAsBytes(), _jpeg());
      expect(await offline.cached(c), isNotNull);
      expect(pedidos, hasLength(1));
    });

    test('sem foto no id (404) → tenta o ISBN', () async {
      respostas[porIsbn] = () => http.Response.bytes(_png(), 200);
      final f = await loja.resolve(
        const PhotoCover(ref: 'ol:123', isbn13: '9788535902778'),
      );
      expect(await f!.readAsBytes(), _png());
      expect(pedidos.map((p) => p.url.toString()), [ol, porIsbn]);
    });

    test('aceita JPEG, PNG, WebP e GIF; o resto é falha passageira (Wi-Fi com página de login)', () async {
      final tipos = {
        'a': _jpeg(),
        'b': _png(),
        'c': _webp(),
        'd': Uint8List(64)..setAll(0, 'GIF89a'.codeUnits),
      };
      for (final MapEntry(key: k, value: bytes) in tipos.entries) {
        final url = 'https://books.google.com/$k.img';
        respostas[url] = () => http.Response.bytes(bytes, 200);
        expect(await loja.resolve(PhotoCover(ref: url)), isNotNull, reason: k);
      }
      const html = 'https://books.google.com/pagina';
      respostas[html] = () => http.Response('<html>oi</html>', 200);
      expect(await loja.resolve(const PhotoCover(ref: html)), isNull);
      // não vira "sem capa" por 7 dias: passados 10 min, tenta de novo
      final antes = pedidos.length;
      expect(await loja.resolve(const PhotoCover(ref: html)), isNull);
      expect(pedidos, hasLength(antes));
      agora = agora.add(const Duration(minutes: 11));
      respostas[html] = () => http.Response.bytes(_jpeg(), 200);
      expect(await loja.resolve(const PhotoCover(ref: html)), isNotNull);
    });

    test(
      'redirecionamento: só para https (http é recusado, sem ir à rede)',
      () async {
        respostas['https://books.google.com/r1'] = () => http.Response(
          '',
          302,
          headers: {'location': 'https://books.googleusercontent.com/a.jpg'},
        );
        respostas['https://books.googleusercontent.com/a.jpg'] = () =>
            http.Response.bytes(_jpeg(), 200);
        expect(
          await loja.resolve(
            const PhotoCover(ref: 'https://books.google.com/r1'),
          ),
          isNotNull,
        );
        respostas['https://books.google.com/r2'] = () => http.Response(
          '',
          301,
          headers: {'location': 'http://books.googleusercontent.com/b.jpg'},
        );
        expect(
          await loja.resolve(
            const PhotoCover(ref: 'https://books.google.com/r2'),
          ),
          isNull,
        );
        expect(
          pedidos.map((p) => p.url.toString()),
          isNot(contains('http://books.googleusercontent.com/b.jpg')),
        );
        expect(pedidos.every((p) => p.followRedirects == false), isTrue);
      },
    );

    test(
      'foto que não abre (corrompida): descartada e marcada "sem capa"',
      () async {
        respostas[ol] = () => http.Response.bytes(_jpeg(), 200);
        const c = PhotoCover(ref: 'ol:123');
        expect(await loja.resolve(c), isNotNull);
        await loja.discard(c);
        expect(await loja.cached(c), isNull);
        expect(await loja.resolve(c), isNull);
        expect(
          pedidos,
          hasLength(1),
          reason: 'não baixa de novo antes de 7 dias',
        );
      },
    );

    test('mais de 2 MB: recusa (pelo cabeçalho ou pelo corpo)', () async {
      const grande = 'https://books.google.com/grande.jpg';
      respostas[grande] = () =>
          http.Response.bytes(_jpeg(CoverStore.maxImageBytes + 1), 200);
      expect(await loja.resolve(const PhotoCover(ref: grande)), isNull);
      const declarado = 'https://books.google.com/declarado.jpg';
      respostas[declarado] = () => http.Response.bytes(
        _jpeg(),
        200,
        headers: {'content-length': '${CoverStore.maxImageBytes + 1}'},
      );
      expect(await loja.resolve(const PhotoCover(ref: declarado)), isNull);
    });

    test('"sem capa" só é tentado de novo depois de 7 dias', () async {
      const c = PhotoCover(ref: 'ol:123');
      expect(await loja.resolve(c), isNull);
      expect(pedidos, hasLength(1));
      agora = agora.add(const Duration(days: 6));
      expect(await nova().resolve(c), isNull);
      expect(pedidos, hasLength(1), reason: 'marca guardada no disco');
      agora = agora.add(const Duration(days: 2));
      respostas[ol] = () => http.Response.bytes(_jpeg(), 200);
      expect(await nova().resolve(c), isNotNull);
      expect(pedidos, hasLength(2));
    });

    test('falha de rede: sem foto agora, sem martelar; tenta de novo depois de 10 min', () async {
      var falhar = true;
      final l = CoverStore(
        dir: () async => dir,
        client: MockClient((req) async {
          pedidos.add(req);
          if (falhar) throw const SocketException('sem rede');
          return http.Response.bytes(_jpeg(), 200);
        }),
        now: () => agora,
        pinned: () async => const {},
      );
      const c = PhotoCover(ref: 'ol:123', isbn13: '9788535902778');
      expect(await l.resolve(c), isNull);
      expect(pedidos, hasLength(1), reason: 'não insiste no ISBN sem rede');
      expect(await l.resolve(c), isNull);
      expect(pedidos, hasLength(1));
      falhar = false;
      agora = agora.add(const Duration(minutes: 11));
      expect(await l.resolve(c), isNotNull);
      expect(pedidos, hasLength(2));
    });

    test('erro do servidor (5xx/429) também é passageiro', () async {
      respostas[ol] = () => http.Response('', 503);
      const c = PhotoCover(ref: 'ol:123');
      expect(await loja.resolve(c), isNull);
      respostas[ol] = () => http.Response.bytes(_jpeg(), 200);
      expect(await loja.resolve(c), isNull, reason: 'espera 10 min');
      agora = agora.add(const Duration(minutes: 11));
      expect(await loja.resolve(c), isNotNull);
    });

    test(
      'até 4 downloads ao mesmo tempo; o mesmo endereço só uma vez',
      () async {
        var emAndamento = 0;
        var pico = 0;
        final liberar = Completer<void>();
        final l = CoverStore(
          dir: () async => dir,
          client: MockClient((req) async {
            pedidos.add(req);
            emAndamento++;
            pico = pico < emAndamento ? emAndamento : pico;
            await liberar.future;
            emAndamento--;
            return http.Response.bytes(_jpeg(), 200);
          }),
          now: () => agora,
          pinned: () async => const {},
        );
        final todos = [
          for (var i = 0; i < 10; i++) l.resolve(PhotoCover(ref: 'ol:$i')),
          l.resolve(const PhotoCover(ref: 'ol:0')),
        ];
        for (var i = 0; i < 400 && pedidos.length < 4; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(pico, 4);
        expect(pedidos, hasLength(4));
        liberar.complete();
        final r = await Future.wait(todos);
        expect(r.every((f) => f != null), isTrue);
        expect(pedidos, hasLength(10));
      },
    );
  });

  group('limite do cache (D-85: 40 MB fora da estante)', () {
    test('passa do limite: sai a menos usada; a da estante nunca sai', () async {
      final l = nova(maxBytes: 300);
      for (var i = 1; i <= 3; i++) {
        respostas['https://covers.openlibrary.org/b/id/$i-M.jpg?default=false'] =
            () => http.Response.bytes(_jpeg(100), 200);
      }
      fixas = {
        Uri.parse('https://covers.openlibrary.org/b/id/1-M.jpg?default=false'),
      };
      await l.resolve(const PhotoCover(ref: 'ol:1'));
      agora = agora.add(const Duration(minutes: 1));
      await l.resolve(const PhotoCover(ref: 'ol:2'));
      agora = agora.add(const Duration(minutes: 1));
      await l.resolve(const PhotoCover(ref: 'ol:3'));
      agora = agora.add(const Duration(minutes: 1));
      // usar a 2 de novo a deixa mais recente que a 3
      await l.resolve(const PhotoCover(ref: 'ol:2'));
      respostas['https://covers.openlibrary.org/b/id/4-M.jpg?default=false'] =
          () => http.Response.bytes(_jpeg(100), 200);
      agora = agora.add(const Duration(minutes: 1));
      await l.resolve(const PhotoCover(ref: 'ol:4'));
      await l.evictionDone;
      // fora da estante: 2, 3 e 4 = 300 bytes → cabe (limite 300); a 1 é da estante
      expect(await l.cached(const PhotoCover(ref: 'ol:1')), isNotNull);
      expect(await l.cached(const PhotoCover(ref: 'ol:2')), isNotNull);
      expect(await l.cached(const PhotoCover(ref: 'ol:3')), isNotNull);
      respostas['https://covers.openlibrary.org/b/id/5-M.jpg?default=false'] =
          () => http.Response.bytes(_jpeg(100), 200);
      agora = agora.add(const Duration(minutes: 1));
      await l.resolve(const PhotoCover(ref: 'ol:5'));
      await l.evictionDone;
      // 2, 3, 4, 5 = 400 > 300 → sai a 3 (a menos usada fora da estante)
      expect(await l.cached(const PhotoCover(ref: 'ol:3')), isNull);
      for (final i in [1, 2, 4, 5]) {
        expect(
          await l.cached(PhotoCover(ref: 'ol:$i')),
          isNotNull,
          reason: '$i',
        );
      }
    });
  });
}
