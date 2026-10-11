// G06.4 — e-books na nuvem: upload só pela URL assinada, em pedaços e RETOMÁVEL (TUS com o token);
// o caminho vai para o livro com versão nova; download sob demanda que só guarda o arquivo certo.
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/core/sync/ebook_cloud.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../../features/account/support/fake_backend.dart';
import '../../support/personal_builders.dart';

/// Storage de mentira: o protocolo TUS do Supabase (`/upload/resumable/sign` com x-signature) e o GET
/// da URL assinada de download.
final class StorageTeste extends http.BaseClient {
  final Map<String, (String path, int total, BytesBuilder recebido)> envios =
      {};
  final Map<String, Uint8List> objetos = {};
  final List<String> pedidos = [];
  int bytesEnviados = 0;
  int patches = 0;

  /// Corta a conexão neste PATCH (1 = o primeiro).
  int? cortarNoPatch;

  /// Recusa o token (403) neste PATCH — a URL assinada venceu no meio do envio.
  int? negarNoPatch;

  /// Roda quando o último pedaço chega (antes da resposta).
  Future<void> Function()? aoCompletar;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest req) async {
    final corpo = await req.finalize().toBytes();
    final caminho = req.url.path;
    pedidos.add('${req.method} $caminho');
    http.StreamedResponse resp(
      int s, [
      Map<String, String> h = const {},
      List<int> b = const [],
    ]) => http.StreamedResponse(Stream.value(b), s, headers: h, request: req);
    if (caminho.startsWith('/download/')) {
      final o = objetos[caminho.substring('/download/'.length)];
      return o == null ? resp(404) : resp(200, const {}, o);
    }
    if (req.headers['x-signature'] != 'tok' ||
        req.headers['Tus-Resumable'] != '1.0.0') {
      return resp(400);
    }
    if (req.method == 'POST') {
      final meta = {
        for (final par in req.headers['Upload-Metadata']!.split(','))
          par.split(' ')[0]: utf8.decode(base64.decode(par.split(' ')[1])),
      };
      expect(meta['bucketName'], 'ebooks');
      final id = 'up${envios.length + 1}';
      envios[id] = (
        meta['objectName']!,
        int.parse(req.headers['Upload-Length']!),
        BytesBuilder(),
      );
      return resp(201, {'location': '/storage/v1/upload/resumable/sign/$id'});
    }
    final id = caminho.split('/').last;
    final e = envios[id];
    if (e == null) return resp(404);
    final (path, total, recebido) = e;
    if (req.method == 'HEAD') {
      return resp(200, {'upload-offset': '${recebido.length}'});
    }
    if (req.method == 'PATCH') {
      patches++;
      if (patches == cortarNoPatch) {
        throw http.ClientException('conexão caiu', req.url);
      }
      if (patches == negarNoPatch) return resp(403);
      if (int.parse(req.headers['Upload-Offset']!) != recebido.length) {
        return resp(409);
      }
      recebido.add(corpo);
      bytesEnviados += corpo.length;
      if (recebido.length == total) {
        objetos[path] = recebido.toBytes();
        await aoCompletar?.call();
      }
      return resp(204, {'upload-offset': '${recebido.length}'});
    }
    return resp(405);
  }
}

final class ApiTeste implements EbookCloudApi {
  int tickets = 0;
  EbookCloudFailure? falha;

  @override
  Future<UploadTicket> uploadTicket({
    required String userBookId,
    required String sha256,
    required int bytes,
  }) async {
    tickets++;
    if (falha != null) throw falha!;
    return UploadTicket(
      path: '$usuarioTeste/$userBookId/$sha256.epub',
      token: 'tok',
    );
  }

  @override
  Future<DownloadTicket> downloadTicket(String userBookId) async {
    if (falha != null) throw falha!;
    return DownloadTicket(
      path: 'x',
      url: Uri.parse('http://storage.teste/download/caminho-$userBookId'),
    );
  }
}

void main() {
  final projeto = Uri.parse('https://projeto.exemplo');
  late Directory dir;
  late AppDatabase db;
  late StorageTeste storage;
  late ApiTeste api;
  late EbookCloud nuvem;
  late Uint8List conteudo;
  late String sha;
  var agora = DateTime.utc(2026, 10, 4, 12);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('booknest_ebook_');
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    storage = StorageTeste();
    api = ApiTeste();
    agora = DateTime.utc(2026, 10, 4, 12);
    final rnd = Random(7);
    conteudo = Uint8List.fromList(List.generate(2500, (_) => rnd.nextInt(256)));
    sha = sha256.convert(conteudo).toString();
    nuvem = EbookCloud(
      db: db,
      api: api,
      uploader: ResumableUploader(
        endpoint: Uri.parse(
          'http://storage.teste/storage/v1/upload/resumable/sign',
        ),
        apiKey: 'sb_publishable_teste',
        client: storage,
        chunkSize: 1000,
      ),
      versioning: await LocalVersioning.open(
        db,
        deviceId: 'aparelhoA',
        nowMs: () => agora.millisecondsSinceEpoch,
      ),
      bookFilePath: (id, f) async =>
          '${dir.path}${Platform.pathSeparator}$id.$f',
      download: storage,
      now: () => agora,
    );
  });
  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<void> livroComArquivo() async {
    await UserBooksDao(db)
        .upsert(livroTeste(1).copyWith(contentSha256: Nullable(sha)));
    final f = File('${dir.path}${Platform.pathSeparator}local.epub');
    await f.writeAsBytes(conteudo);
    await db
        .into(db.localFiles)
        .insert(
          LocalFilesCompanion.insert(
            userBookId: idTeste(1),
            path: f.path,
            bytes: conteudo.length,
            sha256: sha,
            updatedAt: t0Teste,
          ),
        );
  }

  Future<String> estadoDoEnvio() async =>
      (await (db.select(db.localFiles)).getSingle()).uploadState;

  group('upload', () {
    test('em pedaços pela URL assinada (TUS); o caminho vai para o livro com versão nova', () async {
      await livroComArquivo();
      final antes = (await UserBooksDao(db).byId(idTeste(1)))!.meta.version;
      final caminho = await nuvem.upload(idTeste(1));
      expect(caminho, '$usuarioTeste/${idTeste(1)}/$sha.epub');
      expect(storage.objetos[caminho], conteudo);
      expect(storage.pedidos.where((p) => p.startsWith('PATCH')), hasLength(3));
      final livro = (await UserBooksDao(db).byId(idTeste(1)))!;
      expect(livro.storageObjectPath, caminho);
      expect(livro.meta.version.compareTo(antes) > 0, isTrue);
      expect(await estadoDoEnvio(), 'uploaded');
      expect(await KvDao(db).get(EbookCloud.resumeKey(idTeste(1))), isNull);
    });

    test('corte no meio: tenta de novo depois e RETOMA do ponto (não reenvia o que já subiu)', () async {
      await livroComArquivo();
      storage.cortarNoPatch = 2;
      await expectLater(
        nuvem.upload(idTeste(1)),
        throwsA(isA<EbookTransient>()),
      );
      expect(await estadoDoEnvio(), 'failed');
      expect(storage.bytesEnviados, 1000);
      agora = agora.add(const Duration(minutes: 30));
      await nuvem.upload(idTeste(1));
      expect(api.tickets, 1, reason: 'mesma URL assinada (ainda vale)');
      expect(
        storage.pedidos,
        contains('HEAD /storage/v1/upload/resumable/sign/up1'),
      );
      expect(storage.bytesEnviados, 2500, reason: 'só o que faltava');
      expect(storage.objetos.values.single, conteudo);
      expect(await estadoDoEnvio(), 'uploaded');
    });

    test(
      'URL assinada vencida (> 1h50): pede outra e começa um envio novo',
      () async {
        await livroComArquivo();
        storage.cortarNoPatch = 2;
        await expectLater(
          nuvem.upload(idTeste(1)),
          throwsA(isA<EbookTransient>()),
        );
        agora = agora.add(const Duration(hours: 2));
        await nuvem.upload(idTeste(1));
        expect(api.tickets, 2);
        expect(storage.envios.keys, ['up1', 'up2']);
        expect(storage.objetos.values.single, conteudo);
      },
    );

    test(
      'envio que o servidor esqueceu (HEAD 404): começa de novo do zero',
      () async {
        await livroComArquivo();
        await KvDao(db).set(
          EbookCloud.resumeKey(idTeste(1)),
          jsonEncode({
            'path': '$usuarioTeste/${idTeste(1)}/$sha.epub',
            'token': 'tok',
            'at': agora.millisecondsSinceEpoch,
            'sha': sha,
            'bytes': conteudo.length,
            'location':
                'http://storage.teste/storage/v1/upload/resumable/sign/sumiu',
          }),
        );
        await nuvem.upload(idTeste(1));
        expect(api.tickets, 0, reason: 'o token guardado ainda vale');
        expect(
          storage.pedidos.first,
          'HEAD /storage/v1/upload/resumable/sign/sumiu',
        );
        expect(storage.objetos.values.single, conteudo);
        expect(storage.bytesEnviados, 2500);
      },
    );

    test('arquivo do livro trocado depois do corte: não retoma o envio antigo (URL nova)', () async {
      await livroComArquivo();
      storage.cortarNoPatch = 2;
      await expectLater(
        nuvem.upload(idTeste(1)),
        throwsA(isA<EbookTransient>()),
      );
      // mesmo tamanho, outro conteúdo: só o sha256 distingue
      final novo = Uint8List.fromList(List.filled(2500, 9));
      final novoSha = sha256.convert(novo).toString();
      final f = await (db.select(db.localFiles)).getSingle();
      await File(f.path).writeAsBytes(novo);
      await db.customStatement(
        'UPDATE local_files SET sha256 = ?, bytes = ? WHERE user_book_id = ?',
        [novoSha, novo.length, idTeste(1)],
      );
      final caminho = await nuvem.upload(idTeste(1));
      expect(api.tickets, 2);
      expect(storage.envios.keys, ['up1', 'up2']);
      expect(caminho, endsWith('$novoSha.epub'));
      expect(storage.objetos[caminho], novo);
    });

    test('token recusado no meio (403): o envio guardado é esquecido e a próxima tentativa pede outro', () async {
      await livroComArquivo();
      storage.negarNoPatch = 2;
      await expectLater(
        nuvem.upload(idTeste(1)),
        throwsA(isA<EbookTicketExpired>()),
      );
      expect(await estadoDoEnvio(), 'failed');
      expect(await KvDao(db).get(EbookCloud.resumeKey(idTeste(1))), isNull);
      await nuvem.upload(idTeste(1));
      expect(api.tickets, 2);
      expect(storage.objetos.values.single, conteudo);
    });

    test(
      'app fechou no meio do envio: ao abrir, fica como falho (tenta de novo)',
      () async {
        await livroComArquivo();
        await db.customStatement(
          "UPDATE local_files SET upload_state = 'uploading'",
        );
        await nuvem.recover();
        expect(await estadoDoEnvio(), 'failed');
      },
    );

    test(
      'livro apagado enquanto subia: o caminho não vai para o livro',
      () async {
        await livroComArquivo();
        storage.aoCompletar = () async {
          final l = (await UserBooksDao(db).byId(idTeste(1)))!;
          await UserBooksDao(db).upsert(
            l.copyWith(
              meta: l.meta.deleted(
                agora,
                Hlc(agora.millisecondsSinceEpoch, 5, 'aparelhoB'),
              ),
            ),
          );
        };
        await nuvem.upload(idTeste(1));
        final livro = (await UserBooksDao(db).byId(idTeste(1)))!;
        expect(livro.meta.isDeleted, isTrue);
        expect(livro.storageObjectPath, isNull);
        expect(await KvDao(db).get(EbookCloud.resumeKey(idTeste(1))), isNull);
      },
    );

    test('sem Pro (ou cota cheia): a função recusa e nada sobe', () async {
      await livroComArquivo();
      api.falha = const EbookProRequired();
      await expectLater(
        nuvem.upload(idTeste(1)),
        throwsA(isA<EbookProRequired>()),
      );
      expect(storage.pedidos, isEmpty);
      expect(await estadoDoEnvio(), 'failed');
      expect(
        (await UserBooksDao(db).byId(idTeste(1)))!.storageObjectPath,
        isNull,
      );
    });
  });

  group('download (2º aparelho, sob demanda)', () {
    Future<void> livroNaNuvem() => UserBooksDao(db).upsert(
      livroTeste(1).copyWith(
        contentSha256: Nullable(sha),
        storageObjectPath: Nullable('$usuarioTeste/${idTeste(1)}/$sha.epub'),
      ),
    );

    test(
      'baixa pela URL curta e guarda o arquivo (sha256 conferido)',
      () async {
        await livroNaNuvem();
        storage.objetos['caminho-${idTeste(1)}'] = conteudo;
        final p = await nuvem.download(idTeste(1));
        expect(await File(p).readAsBytes(), conteudo);
        final f = await (db.select(db.localFiles)).getSingle();
        expect(
          (f.path, f.sha256, f.bytes, f.uploadState),
          (p, sha, 2500, 'uploaded'),
        );
      },
    );

    test('arquivo diferente do livro (sha256 não bate): descartado, nada fica no aparelho', () async {
      await livroNaNuvem();
      storage.objetos['caminho-${idTeste(1)}'] = Uint8List.fromList(
        List.filled(2500, 1),
      );
      await expectLater(
        nuvem.download(idTeste(1)),
        throwsA(isA<EbookCorrupted>()),
      );
      expect(dir.listSync(), isEmpty);
      expect(await (db.select(db.localFiles)).get(), isEmpty);
    });

    test('livro sem arquivo na nuvem: nem pede a URL', () async {
      await UserBooksDao(db).upsert(livroTeste(1));
      await expectLater(
        nuvem.download(idTeste(1)),
        throwsA(isA<EbookNotFound>()),
      );
      expect(storage.pedidos, isEmpty);
    });
  });

  group(
    'SupabaseEbookCloudApi (cliente real do Supabase, servidor de mentira)',
    () {
      Future<EbookCloudFailure> falha(Resposta r) async {
        final fb = FakeBackend(
          respostas: {'POST /functions/v1/ebook-upload-url': r},
        );
        try {
          await SupabaseEbookCloudApi(
            fb.client(),
            projectUrl: projeto,
          ).uploadTicket(userBookId: 'l', sha256: 's', bytes: 1);
        } on EbookCloudFailure catch (f) {
          return f;
        }
        fail('não lançou');
      }

      test('URL assinada e os erros da função', () async {
        final fb = FakeBackend(
          respostas: {
            'POST /functions/v1/ebook-upload-url': (
              200,
              {'path': 'u/l/s.epub', 'signed_url': 'x', 'token': 'tok'},
            ),
            'POST /functions/v1/ebook-download-url': (
              200,
              {
                'path': 'u/l/s.epub',
                'signed_path':
                    '/storage/v1/object/sign/ebooks/u/l/s.epub?token=t',
                'expires_in': 300,
              },
            ),
          },
        );
        final api = SupabaseEbookCloudApi(fb.client(), projectUrl: projeto);
        final t = await api.uploadTicket(
          userBookId: 'l',
          sha256: 's',
          bytes: 1,
        );
        expect((t.path, t.token), ('u/l/s.epub', 'tok'));
        expect(fb.pedidos.last.json, {
          'user_book_id': 'l',
          'sha256': 's',
          'bytes': 1,
        });
        expect(
          (await api.downloadTicket('l')).url,
          Uri.parse(
            'https://projeto.exemplo/storage/v1/object/sign/ebooks/u/l/s.epub?token=t',
          ),
        );
        expect(
          await falha((403, {'erro': 'pro_required'})),
          isA<EbookProRequired>(),
        );
        expect(
          await falha((413, {'erro': 'quota_exceeded'})),
          isA<EbookQuotaExceeded>(),
        );
        expect(
          await falha((404, {'erro': 'book_not_found'})),
          isA<EbookNotFound>(),
        );
        expect(await falha((503, {'erro': 'x'})), isA<EbookTransient>());
      });

      test('sem rede: passageiro', () async {
        final fb = FakeBackend(offline: true);
        await expectLater(
          SupabaseEbookCloudApi(
            fb.client(),
            projectUrl: projeto,
          ).downloadTicket('l'),
          throwsA(isA<EbookTransient>()),
        );
      });
    },
  );
}
