// Foto real da capa (G08, D-79/D-85): baixada direto da fonte pelo aparelho — sem conta nem identificador; a
// fonte vê o IP e qual capa — e guardada na pasta de suporte do app, para aparecer offline. Um arquivo por
// endereço (`<hash>.img`); "sem capa" fica marcado (`<hash>.none`) e só é tentado de novo depois de 7 dias.
// As capas dos livros da estante nunca saem; as outras (Para você) saem pela menos usada acima de 40 MB.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../domain/models.dart';

/// Hosts de onde a foto pode vir (G08.6): só os das fontes de capa — a requisição mostra o IP de quem pede,
/// então nenhuma URL vinda de dado externo leva o aparelho a outro lugar. Medido em 05/10/2026: o Open Library
/// responde direto ou redireciona para `archive.org` → `iaNNNNNN.us.archive.org`; o Google Books serve a miniatura
/// em `books.google.com` (às vezes `books.googleusercontent.com`); Hardcover e ISBNdb (só com chave) usam
/// `assets.hardcover.app` e `images.isbndb.com`. Fora da lista: sem foto por aquele endereço (fica o recuo
/// pelo ISBN ou a capa gerada).
bool coverHostAllowed(String host) {
  final h = host.toLowerCase();
  return _coverHosts.contains(h) || _archiveNode.hasMatch(h);
}

const Set<String> _coverHosts = {
  'covers.openlibrary.org',
  'archive.org',
  'books.google.com',
  'books.googleusercontent.com',
  'assets.hardcover.app',
  'images.isbndb.com',
};

final RegExp _archiveNode = RegExp(r'^ia\d+\.us\.archive\.org$');

/// Endereços da foto, em ordem: o `cover_ref` do livro (`ol:<id>` → Open Library por id, sem limite de taxa;
/// ou a URL da API externa, sempre em https e de um host da lista) e o recuo pelo ISBN no Open Library
/// (100 a cada 5 min por IP).
List<Uri> coverCandidates(PhotoCover cover) {
  final out = <Uri>[];
  final ref = cover.ref?.trim();
  if (ref != null && ref.isNotEmpty) {
    final ol = RegExp(r'^ol:(\d+)$').firstMatch(ref);
    if (ol != null) {
      out.add(
        Uri.parse(
          'https://covers.openlibrary.org/b/id/${ol[1]}-M.jpg?default=false',
        ),
      );
    } else {
      final u = Uri.tryParse(ref);
      if (u != null && coverHostAllowed(u.host)) {
        if (u.scheme == 'https') out.add(u);
        if (u.scheme == 'http') out.add(u.replace(scheme: 'https'));
      }
    }
  }
  final isbn = cover.isbn13;
  if (isbn != null && RegExp(r'^97[89]\d{10}$').hasMatch(isbn)) {
    out.add(
      Uri.parse(
        'https://covers.openlibrary.org/b/isbn/$isbn-M.jpg?default=false',
      ),
    );
  }
  return out;
}

/// As fotos de capa do aparelho.
abstract interface class CoverImages {
  /// A foto já guardada (sem rede); `null` = ainda não tem.
  Future<File?> cached(PhotoCover cover);

  /// Do aparelho ou da rede; `null` = sem foto agora (a capa gerada fica — D-79).
  Future<File?> resolve(PhotoCover cover);

  /// A foto guardada não abre (arquivo corrompido): apaga e marca "sem capa" (só tenta de novo em 7 dias).
  Future<void> discard(PhotoCover cover);
}

enum _Fetch { ok, missing, transient }

final class CoverStore implements CoverImages {
  CoverStore({
    required this._dir,
    required this._client,
    required this._pinned,
    this._fileCovers,
    DateTime Function()? now,
    this.maxBytes = defaultMaxBytes,
  }) : _now = now ?? DateTime.now;

  /// Pasta das capas (criada na primeira escrita).
  final Future<Directory> Function() _dir;

  /// Pasta das capas que vieram dentro dos arquivos (`<sha256>.img`, G09/D-90): primeiro lugar, sem rede.
  final Future<Directory> Function()? _fileCovers;
  final http.Client _client;

  /// Endereços das capas dos livros da estante (nunca saem do cache).
  final Future<Set<Uri>> Function() _pinned;
  final DateTime Function() _now;

  /// Limite das capas fora da estante.
  final int maxBytes;

  static const int defaultMaxBytes = 40 * 1024 * 1024;
  static const int maxImageBytes = 2 * 1024 * 1024;
  static const Duration timeout = Duration(seconds: 15);
  static const Duration missingRetry = Duration(days: 7);
  static const Duration transientBackoff = Duration(minutes: 10);
  static const int maxConcurrent = 4;
  static const int maxRedirects = 3;
  static const String userAgent =
      'BookNest/1.0 (app de leitura; capas no aparelho)';

  final Map<String, Future<_Fetch>> _inFlight = {};
  final Map<String, DateTime> _backoffUntil = {};
  int _running = 0;
  final List<Completer<void>> _waiting = [];
  Future<void> _eviction = Future<void>.value();

  /// Fim da limpeza agendada (para os testes).
  Future<void> get evictionDone => _eviction;

  static String _key(Uri u) =>
      sha256.convert(utf8.encode(u.toString())).toString().substring(0, 40);

  Future<File> _file(String key, String ext) async =>
      File('${(await _dir()).path}${Platform.pathSeparator}$key.$ext');

  /// A capa do próprio arquivo do livro, quando existe (D-90).
  Future<File?> _fromFile(PhotoCover cover) async {
    final sha = cover.fileSha;
    final dir = _fileCovers;
    if (sha == null ||
        dir == null ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(sha)) {
      return null;
    }
    final f = File('${(await dir()).path}${Platform.pathSeparator}$sha.img');
    return await f.exists() ? f : null;
  }

  @override
  Future<File?> cached(PhotoCover cover) async {
    final own = await _fromFile(cover);
    if (own != null) return own;
    for (final u in coverCandidates(cover)) {
      final f = await _file(_key(u), 'img');
      if (await f.exists()) return f;
    }
    return null;
  }

  @override
  Future<void> discard(PhotoCover cover) async {
    // a capa do arquivo que não abre sai; a da fonte (se houver) entra no lugar
    final own = await _fromFile(cover);
    if (own != null) {
      try {
        await own.delete();
      } on FileSystemException {
        // em uso: tenta na próxima
      }
      return;
    }
    for (final u in coverCandidates(cover)) {
      final key = _key(u);
      final img = await _file(key, 'img');
      if (!await img.exists()) continue;
      try {
        await img.delete();
      } on FileSystemException {
        // em uso: a marca abaixo já impede de usar de novo
      }
      final none = await _file(key, 'none');
      await none.writeAsBytes(const []);
      await none.setLastModified(_now());
    }
  }

  @override
  Future<File?> resolve(PhotoCover cover) async {
    final own = await _fromFile(cover);
    if (own != null) return own;
    for (final u in coverCandidates(cover)) {
      final key = _key(u);
      final img = await _file(key, 'img');
      if (await img.exists()) {
        await _touch(img);
        return img;
      }
      final none = await _file(key, 'none');
      if (await none.exists() &&
          _now().difference(await none.lastModified()) < missingRetry) {
        continue;
      }
      final until = _backoffUntil[key];
      if (until != null && _now().isBefore(until)) return null;
      final r = await (_inFlight[key] ??= _fetch(u, key).whenComplete(() {
        // sem devolver o Future removido: o whenComplete esperaria por ele mesmo
        _inFlight.remove(key);
      }));
      switch (r) {
        case _Fetch.ok:
          _scheduleEviction();
          return img;
        case _Fetch.missing:
          continue;
        case _Fetch.transient:
          return null;
      }
    }
    return null;
  }

  Future<void> _touch(File f) async {
    try {
      await f.setLastModified(_now());
    } on FileSystemException {
      // só a ordem da limpeza depende disso
    }
  }

  Future<_Fetch> _fetch(Uri u, String key) async {
    await _acquire();
    try {
      final r = await _download(u);
      if (r == null) {
        _backoffUntil[key] = _now().add(transientBackoff);
        return _Fetch.transient;
      }
      final dir = await _dir();
      await dir.create(recursive: true);
      final none = await _file(key, 'none');
      if (r.isEmpty) {
        await none.writeAsBytes(const []);
        await none.setLastModified(_now());
        return _Fetch.missing;
      }
      final img = await _file(key, 'img');
      final part = await _file(key, 'part');
      await part.writeAsBytes(r, flush: true);
      await part.rename(img.path);
      await _touch(img);
      if (await none.exists()) await none.delete();
      _backoffUntil.remove(key);
      return _Fetch.ok;
    } finally {
      _release();
    }
  }

  /// Bytes da imagem; vazio = a fonte não tem capa (404/410, grande demais, redireciona para fora do https ou
  /// da lista de hosts); `null` = falha passageira (rede, servidor, ou uma resposta que não é imagem — Wi-Fi com
  /// página de login). Redirecionamentos seguidos à mão, até 3, só para https e só para hosts da lista.
  Future<Uint8List?> _download(Uri first) async {
    try {
      var u = first;
      for (var hop = 0; hop <= maxRedirects; hop++) {
        final req = http.Request('GET', u)
          ..headers['User-Agent'] = userAgent
          ..followRedirects = false;
        final res = await _client.send(req).timeout(timeout);
        final code = res.statusCode;
        if (code >= 300 && code < 400) {
          await _discardBody(res);
          final to = res.headers['location'];
          final next = to == null ? null : u.resolve(to);
          if (next == null ||
              next.scheme != 'https' ||
              !coverHostAllowed(next.host)) {
            return Uint8List(0);
          }
          u = next;
          continue;
        }
        if (code == 404 || code == 410) {
          await _discardBody(res);
          return Uint8List(0);
        }
        if (code != 200) {
          await _discardBody(res);
          return null;
        }
        final declared =
            int.tryParse(res.headers['content-length'] ?? '') ??
            res.contentLength;
        if (declared != null && declared > maxImageBytes) {
          await _discardBody(res);
          return Uint8List(0);
        }
        final out = BytesBuilder(copy: false);
        await for (final chunk in res.stream.timeout(timeout)) {
          out.add(chunk);
          if (out.length > maxImageBytes) return Uint8List(0);
        }
        final bytes = out.takeBytes();
        return _isImage(bytes) ? bytes : null;
      }
      return Uint8List(0);
    } on Object {
      return null;
    }
  }

  /// Fecha a resposta sem baixar o corpo.
  static Future<void> _discardBody(http.StreamedResponse res) async {
    try {
      await res.stream.listen(null).cancel();
    } on Object {
      // já fechada
    }
  }

  /// Assinatura de JPEG, PNG, GIF ou WebP.
  static bool _isImage(Uint8List b) {
    bool starts(List<int> sig, [int at = 0]) {
      if (b.length < at + sig.length) return false;
      for (var i = 0; i < sig.length; i++) {
        if (b[at + i] != sig[i]) return false;
      }
      return true;
    }

    return starts(const [0xFF, 0xD8, 0xFF]) ||
        starts(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) ||
        starts('GIF8'.codeUnits) ||
        (starts('RIFF'.codeUnits) && starts('WEBP'.codeUnits, 8));
  }

  Future<void> _acquire() async {
    if (_running < maxConcurrent) {
      _running++;
      return;
    }
    final c = Completer<void>();
    _waiting.add(c);
    await c.future;
  }

  void _release() {
    if (_waiting.isNotEmpty) {
      _waiting.removeAt(0).complete();
    } else {
      _running--;
    }
  }

  void _scheduleEviction() {
    _eviction = _eviction.then((_) => _evict()).catchError((Object _) {});
  }

  /// Fora da estante acima de [maxBytes]: apaga a menos usada até caber.
  Future<void> _evict() async {
    final dir = await _dir();
    if (!await dir.exists()) return;
    final pinned = {for (final u in await _pinned()) _key(u)};
    final files = <(File, int, DateTime)>[];
    var total = 0;
    await for (final e in dir.list()) {
      if (e is! File || !e.path.endsWith('.img')) continue;
      final name = e.uri.pathSegments.last;
      if (pinned.contains(name.substring(0, name.length - 4))) continue;
      final st = await e.stat();
      files.add((e, st.size, st.modified));
      total += st.size;
    }
    if (total <= maxBytes) return;
    files.sort((a, b) => a.$3.compareTo(b.$3));
    for (final (f, size, _) in files) {
      if (total <= maxBytes) break;
      try {
        await f.delete();
        total -= size;
      } on FileSystemException {
        // em uso ou já apagado: segue
      }
    }
  }
}
