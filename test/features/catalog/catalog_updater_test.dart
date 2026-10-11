// G07 — o catalog.db no aparelho: baixa no Wi-Fi, retoma do ponto, confere o sha256, aplica o delta
// do mês (conferido pelo hash) e cai para o arquivo inteiro se o delta não fechar.
import 'dart:io';
import 'dart:typed_data';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/features/catalog/application/catalog_updater.dart';
import 'package:app_leitura/features/catalog/domain/catalog_failure.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/catalog_fakes.dart';

void main() {
  late Directory dir;
  late AppDatabase db;
  late FakeCatalogServer server;
  late CatalogUpdater updater;
  var rede = NetworkKind.unmetered;
  var agora = DateTime.utc(2026, 10, 5, 12);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('booknest_catalogo_');
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    server = FakeCatalogServer();
    rede = NetworkKind.unmetered;
    agora = DateTime.utc(2026, 10, 5, 12);
    updater = CatalogUpdater(
      client: server,
      base: Uri.parse('http://catalogo.teste/'),
      dir: Directory('${dir.path}/catalogo'),
      network: () async => rede,
      kv: KvDao(db),
      now: () => agora,
    );
  });
  tearDown(() async {
    await updater.close();
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<List<String>> arquivos() async => [
    for (final f in Directory('${dir.path}/catalogo').listSync())
      f.uri.pathSegments.last,
  ]..sort();

  test(
    'sem catálogo: dados móveis espera; Wi-Fi baixa, confere e instala',
    () async {
      expect(await updater.catalog(), isNull);
      rede = NetworkKind.metered;
      expect(
        await updater.update(),
        isA<CatalogUpdateSkipped>().having(
          (s) => s.reason,
          'motivo',
          'rede_movel',
        ),
      );
      rede = NetworkKind.none;
      expect(
        await updater.update(force: true),
        isA<CatalogUpdateSkipped>().having(
          (s) => s.reason,
          'motivo',
          'sem_rede',
        ),
      );
      expect(server.requests, isEmpty, reason: 'nada sai sem Wi-Fi');
      rede = NetworkKind.unmetered;
      final r = await updater.update();
      expect(
        r,
        isA<CatalogInstalled>().having(
          (i) => (i.version, i.fromDelta),
          'versão',
          (v1, null),
        ),
      );
      final cat = (await updater.catalog())!;
      expect(await cat.version(), v1);
      expect((await cat.byIsbn('9788535902778'))!.title, 'Dom Casmurro');
      expect(await arquivos(), [
        'catalog.db',
      ], reason: 'sem .part, .gz ou temporário');
    },
  );

  test(
    'já verificado hoje: não consulta; no dia seguinte, igual → em dia',
    () async {
      await updater.update();
      final n = server.requests.length;
      expect(
        await updater.update(),
        isA<CatalogUpdateSkipped>().having(
          (s) => s.reason,
          'motivo',
          'verificado_hoje',
        ),
      );
      expect(server.requests.length, n);
      agora = agora.add(const Duration(days: 1));
      expect(await updater.update(), isA<CatalogUpToDate>());
      expect(server.downloads, 1, reason: 'só o manifesto');
    },
  );

  test(
    'mês seguinte: aplica só o delta (o arquivo inteiro não desce de novo)',
    () async {
      await updater.update();
      server.current = v2;
      agora = agora.add(const Duration(days: 31));
      final r = await updater.update();
      expect(
        r,
        isA<CatalogInstalled>().having(
          (i) => (i.version, i.fromDelta),
          'delta',
          (v2, v1),
        ),
      );
      expect(
        server.requests.where((q) => q.url.path.endsWith('catalog.db.gz')),
        hasLength(1),
      );
      final cat = (await updater.catalog())!;
      expect(await cat.version(), v2);
      expect(
        (await cat.byIsbn('9788535910667'))!.title,
        'Memórias póstumas de Brás Cubas',
      );
    },
  );

  test('delta corrompido: cai para o arquivo inteiro da versão nova', () async {
    await updater.update();
    server.current = v2;
    server.overrides['catalog/v1/$v2/delta-$v1.jsonl.gz'] = Uint8List.fromList(
      fixtureBytes('catalog/v1/$v2/delta-$v1.jsonl.gz').toList()..[20] ^= 0xff,
    );
    agora = agora.add(const Duration(days: 31));
    final r = await updater.update();
    expect(
      r,
      isA<CatalogInstalled>().having(
        (i) => (i.version, i.fromDelta),
        'inteiro',
        (v2, null),
      ),
    );
    expect(await (await updater.catalog())!.version(), v2);
  });

  test('corte no meio: a próxima vez RETOMA do ponto (Range + If-Range), não do zero', () async {
    server.cutAfterBytes = 1000;
    await expectLater(updater.update(), throwsA(isA<CatalogOffline>()));
    expect(await arquivos(), ['catalog.db.gz.part', 'catalog.db.gz.part.json']);
    expect(
      await File('${dir.path}/catalogo/catalog.db.gz.part').length(),
      1000,
    );
    final r = await updater.update(force: true);
    expect(r, isA<CatalogInstalled>());
    final retomada = server.requests.lastWhere(
      (q) => q.url.path.endsWith('catalog.db.gz'),
    );
    expect(retomada.headers['Range'], 'bytes=1000-');
    expect(retomada.headers['If-Range'], isNotNull);
    expect(await arquivos(), ['catalog.db']);
  });

  test('arquivo diferente do manifesto (sha256): descarta, tenta de novo e desiste', () async {
    final bom = fixtureBytes('catalog/v1/$v1/catalog.db.gz');
    server.overrides['catalog/v1/$v1/catalog.db.gz'] = Uint8List.fromList(
      bom.toList()..[100] ^= 0xff,
    );
    await expectLater(
      updater.update(),
      throwsA(isA<CatalogCorrupted>().having((e) => e.code, 'code', 'sha')),
    );
    expect(await updater.catalog(), isNull);
    expect(await arquivos(), isNot(contains('catalog.db')));
  });

  test(
    'servidor fora do ar ou no limite: falha tipada, nada instalado',
    () async {
      server.statuses.add(503);
      await expectLater(updater.update(), throwsA(isA<CatalogOffline>()));
      server.statuses.add(429);
      await expectLater(
        updater.update(force: true),
        throwsA(isA<CatalogQuotaExceeded>()),
      );
      expect(await updater.catalog(), isNull);
    },
  );

  test('falha que não é de rede (sha do banco errado no manifesto): espera o dia seguinte e reaproveita o .gz conferido', () async {
    server.editManifest = (m) => {
      ...m,
      'db': {...(m['db']! as Map<String, Object?>), 'db_sha256': 'f' * 64},
    };
    await expectLater(
      updater.update(),
      throwsA(isA<CatalogCorrupted>().having((e) => e.code, 'code', 'db_sha')),
    );
    expect(server.downloads, 1);
    // abrir o app de novo / voltar ao Wi-Fi no mesmo dia: não baixa tudo de novo (achado 6)
    expect(await updater.update(), isA<CatalogUpdateSkipped>());
    expect(server.downloads, 1);
    // no dia seguinte, com o manifesto certo
    server.editManifest = null;
    agora = agora.add(const Duration(days: 1, minutes: 1));
    expect(await updater.update(), isA<CatalogInstalled>());
  });

  test('o .gz já baixado e conferido não desce de novo (disco cheio ao descompactar, por exemplo)', () async {
    final gz = File('${dir.path}/catalogo/catalog.db.gz');
    await gz.parent.create(recursive: true);
    await gz.writeAsBytes(fixtureBytes('catalog/v1/$v1/catalog.db.gz'));
    expect(await updater.update(), isA<CatalogInstalled>());
    expect(server.downloads, 0);
    expect(await arquivos(), ['catalog.db']);
  });

  test('sem rede no meio: a próxima volta ao Wi-Fi tenta de novo (não espera o dia seguinte)', () async {
    server.cutAfterBytes = 500;
    await expectLater(updater.update(), throwsA(isA<CatalogOffline>()));
    expect(await updater.update(), isA<CatalogInstalled>());
  });

  test('troca da versão: quem pede o catálogo durante a instalação recebe o novo (nunca um fechado)', () async {
    await updater.update();
    final antigo = (await updater.catalog())!;
    expect(await antigo.version(), v1);
    server.current = v2;
    server.overrides['catalog/v1/$v2/delta-$v1.jsonl.gz'] = Uint8List(3);
    agora = agora.add(const Duration(days: 31));
    var terminou = false;
    final instalando = updater.update().whenComplete(() => terminou = true);
    // pedidos durante a instalação (o scanner buscando enquanto o catálogo troca)
    while (!terminou) {
      await updater.catalog();
      await Future<void>.delayed(Duration.zero);
    }
    await instalando;
    final depois = (await updater.catalog())!;
    expect(
      await depois.version(),
      v2,
      reason: 'nunca fica preso ao arquivo antigo',
    );
    expect(await depois.byIsbn('9780199535569'), isNotNull);
    expect(await arquivos(), ['catalog.db']);
  });

  test('gzip quebrado (publicado com o sha certo): falha tipada e nenhuma sobra na pasta', () async {
    final lixo = Uint8List.fromList(List.generate(4096, (i) => (i * 7) % 256));
    server.overrides['catalog/v1/$v1/catalog.db.gz'] = lixo;
    final sha = sha256.convert(lixo).toString();
    server.editManifest = (m) => {
      ...m,
      'db': {
        ...(m['db']! as Map<String, Object?>),
        'sha256': sha,
        'bytes': lixo.length,
      },
    };
    await expectLater(
      updater.update(),
      throwsA(isA<CatalogCorrupted>().having((e) => e.code, 'code', 'gzip')),
    );
    expect(await arquivos(), isEmpty);
  });
}
