// G11 — o leitor ligado ao app: o provider monta as dependências da sessão com o banco, a conta ativa, a pasta dos
// livros, a indexação da G09 (só quando a sessão pede), a fila de layout, a tela acesa e o relógio do app; a
// barra de status (D-105) vai ao sistema pelo canal da plataforma; a tela acesa de verdade (D-111) pelo
// `wakelock_plus`.
import 'dart:io';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/local_database.dart';
import 'package:app_leitura/core/data/database/local_sql.dart' show deviceIdKey;
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/sync/sync_providers.dart';
import 'package:app_leitura/features/account/application/account_providers.dart';
import 'package:app_leitura/features/account/data/local_library.dart';
import 'package:app_leitura/features/home/application/home_providers.dart'
    show clockProvider;
import 'package:app_leitura/features/library/application/book_importer.dart';
import 'package:app_leitura/features/library/application/library_import.dart';
import 'package:app_leitura/features/library/data/pdf_inspector.dart';
import 'package:app_leitura/features/reader/application/reader_providers.dart';
import 'package:app_leitura/features/reader/application/screen_awake.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_reader.dart';

final class _SemPdf implements PdfInspector {
  @override
  Future<PdfInfo> inspect(String path) => throw StateError('sem PDF aqui');
}

Future<T> _aqui<T>(T Function() task) async => task();

/// Lê o pedido do Pigeon (`ToggleMessage` = tipo próprio com a lista dos campos) e acha o `enable`.
final class _Pigeon extends StandardMessageCodec {
  const _Pigeon();

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) =>
      type >= 129 ? readValue(buffer) : super.readValueOfType(type, buffer);
}

bool? _ligar(Object? pedido) => switch (pedido) {
  final bool b => b,
  final List<Object?> l =>
    l.map(_ligar).firstWhere((b) => b != null, orElse: () => null),
  _ => null,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('readerDepsProvider: banco, conta ativa, pasta, fila, tela acesa e relógio do app; indexa pelo importador', () async {
    final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    addTearDown(db.close);
    final raiz = Directory.systemTemp.createTempSync('booknest_g11_deps_');
    addTearDown(() => raiz.deleteSync(recursive: true));
    final livros = Directory('${raiz.path}${Platform.pathSeparator}livros');
    await KvDao(db).set(deviceIdKey, 'aparelhoX');
    final versioning = LocalVersioning(db, HlcClock(deviceId: 'aparelhoX'));
    final awake = RecordingScreenAwake();
    final c = ProviderContainer(
      overrides: [
        localDatabaseProvider.overrideWith((ref) async => db),
        localLibraryProvider.overrideWith((ref) async => LocalLibrary(db)),
        localVersioningProvider.overrideWith((ref) async => versioning),
        booksDirProvider.overrideWithValue(() async => livros),
        bookImporterProvider.overrideWith(
          (ref) async => BookImporter(
            db: db,
            versioning: versioning,
            owner: () async => 'dona',
            booksDir: () async => livros,
            fileCoversDir: () async => raiz,
            pdf: _SemPdf(),
            run: _aqui,
          ),
        ),
        clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 6)),
        screenAwakeProvider.overrideWithValue(awake),
      ],
    );
    addTearDown(c.dispose);
    final deps = await c.read(readerDepsProvider.future);
    expect(deps.db, same(db));
    expect(deps.versioning, same(versioning));
    expect(deps.deviceId, 'aparelhoX');
    expect((await deps.booksDir()).path, livros.path);
    expect(deps.scheduler, same(c.read(layoutSchedulerProvider)));
    expect(deps.screenAwake, same(awake));
    expect(deps.now!(), DateTime.utc(2026, 10, 6));
    expect(await deps.owner(), await LocalLibrary(db).activeOwnerId());
    expect(
      await deps.indexBook('livro-que-nao-existe'),
      isFalse,
      reason: 'pelo importador da G09',
    );
  });

  test('a barra de status do leitor vai ao sistema: imersiva (D-105) e de volta ao padrão (D-13)', () async {
    final pedidos = <MethodCall>[];
    final mensageiro =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          ..setMockMethodCallHandler(SystemChannels.platform, (call) async {
            pedidos.add(call);
            return null;
          });
    addTearDown(
      () => mensageiro.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    const ui = PlatformReaderSystemUi();
    await ui.immersive();
    await ui.edgeToEdge();
    expect(
      [
        for (final p in pedidos)
          if (p.method == 'SystemChrome.setEnabledSystemUIMode') p.arguments,
      ],
      ['SystemUiMode.immersiveSticky', 'SystemUiMode.edgeToEdge'],
    );
  });

  test('a tela acesa de verdade liga e desliga pelo wakelock_plus (D-111)', () async {
    const canal =
        'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle';
    final pedidos = <bool?>[];
    final mensageiro =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          ..setMockMessageHandler(canal, (dados) async {
            pedidos.add(_ligar(const _Pigeon().decodeMessage(dados)));
            return const StandardMessageCodec().encodeMessage(<Object?>[null]);
          });
    addTearDown(() => mensageiro.setMockMessageHandler(canal, null));
    const tela = WakelockScreenAwake();
    await tela.enable();
    await tela.disable();
    expect(pedidos, [true, false]);
  });
}
