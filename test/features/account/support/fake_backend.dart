// Servidor de mentira para os testes da conta (G05): um `SupabaseClient` de verdade sobre um
// cliente HTTP próprio que responde como o Supabase local e grava cada pedido (teste de privacidade — G05.6).
import 'dart:convert';

import 'package:app_leitura/features/account/data/secure_session_storage.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

const String contaTeste = '0199a7c4-2f00-7a10-8b20-0000000000aa';
const String emailTeste = 'leitora@exemplo.com';

/// Armazenamento seguro em memória.
final class MemorySecureStore implements SecureStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// JWT sem assinatura válida (o cliente só lê `exp` e `sub`).
String jwtTeste(String userId, {int validadeSegundos = 3600}) {
  String b64(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  final exp = DateTime.now().millisecondsSinceEpoch ~/ 1000 + validadeSegundos;
  return '${b64({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${b64({'sub': userId, 'exp': exp, 'role': 'authenticated'})}.assinatura';
}

Map<String, Object?> sessaoAuthTeste({
  String userId = contaTeste,
  String email = emailTeste,
}) => {
  'access_token': jwtTeste(userId),
  'token_type': 'bearer',
  'expires_in': 3600,
  'refresh_token': 'renovacao-$userId',
  'user': {
    'id': userId,
    'aud': 'authenticated',
    'email': email,
    'app_metadata': {'provider': 'email'},
    'user_metadata': <String, Object?>{},
    'created_at': '2026-10-04T12:00:00Z',
  },
};

/// Um pedido recebido.
final class Pedido {
  Pedido(this.method, this.url, this.body, this.headers);
  final String method;
  final Uri url;
  final String body;
  final Map<String, String> headers;

  /// O JWT que foi junto (sem "Bearer ").
  String? get jwt => headers['authorization']?.replaceFirst('Bearer ', '');

  String get path => url.path;
  Object? get json => body.isEmpty ? null : jsonDecode(body);

  @override
  String toString() =>
      '$method ${url.path}${url.hasQuery ? '?${url.query}' : ''}';
}

/// Resposta programada: status + corpo JSON.
typedef Resposta = (int, Object?);

/// Supabase de mentira. Respostas por "MÉTODO /caminho" (sem a query); o padrão responde como o
/// servidor local responderia a um login de e-mail e às chamadas da conta.
final class FakeBackend {
  FakeBackend({Map<String, Resposta>? respostas, this.offline = false})
    : respostas = {..._padrao, ...?respostas};

  static final Map<String, Resposta> _padrao = {
    'POST /auth/v1/otp': (200, <String, Object?>{}),
    'POST /auth/v1/verify': (200, sessaoAuthTeste()),
    'POST /auth/v1/token': (200, sessaoAuthTeste()),
    'POST /auth/v1/logout': (204, null),
    'POST /rest/v1/rpc/my_account': (200, contaJson()),
    'POST /rest/v1/rpc/set_my_age_band': (
      200,
      {'band': '18_plus', 'source': 'birthdate', 'minor': false},
    ),
    'PATCH /rest/v1/profiles': (204, null),
    'POST /functions/v1/export-data': (
      200,
      {'format_version': 2, 'profile': <String, Object?>{}},
    ),
    'POST /functions/v1/delete-account': (200, {'ok': true}),
  };

  final Map<String, Resposta> respostas;

  /// Sem rede: todo pedido falha com `ClientException`.
  bool offline;
  final List<Pedido> pedidos = [];

  late final http.Client httpClient = _HttpDeMentira(this);

  /// Cliente real do Supabase sobre o servidor de mentira (sem renovação automática do token).
  SupabaseClient client({MemorySecureStore? store}) => SupabaseClient(
    'http://supabase.teste',
    'sb_publishable_teste',
    httpClient: httpClient,
    authOptions: AuthClientOptions(
      autoRefreshToken: false,
      pkceAsyncStorage: SecurePkceStorage(store ?? MemorySecureStore()),
    ),
  );

  Iterable<String> get caminhos => pedidos.map((p) => '${p.method} ${p.path}');
}

/// `public.my_account()` como o servidor devolve.
Map<String, Object?> contaJson({
  String id = contaTeste,
  String handle = 'leitor_0199a7c42f007a10',
  bool provisorio = true,
  String? faixa = '18_plus',
  bool pro = false,
}) => {
  'id': id,
  'handle': handle,
  'display_name': 'Leitora',
  'visibility': 'public',
  'handle_provisional': provisorio,
  'age_band': faixa,
  'pro': pro,
};

/// Erro do PostgREST (formato do corpo).
Resposta erroPostgrest(int status, String code, String message) =>
    (status, {'code': code, 'message': message, 'details': null, 'hint': null});

/// Erro do Supabase Auth (formato da API 2024-01-01).
Resposta erroAuth(int status, String code, String msg) =>
    (status, {'code': code, 'msg': msg});

/// Cliente HTTP do servidor de mentira. (O `MockClient` do pacote http não liga a resposta ao pedido —
/// `response.request` fica nulo — e o PostgREST do Supabase depende disso.)
final class _HttpDeMentira extends http.BaseClient {
  _HttpDeMentira(this._b);
  final FakeBackend _b;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest req) async {
    final body = utf8.decode(await req.finalize().toBytes());
    _b.pedidos.add(
      Pedido(req.method, req.url, body, {
        for (final e in req.headers.entries) e.key.toLowerCase(): e.value,
      }),
    );
    if (_b.offline) throw http.ClientException('sem rede', req.url);
    final r =
        _b.respostas['${req.method} ${req.url.path}'] ??
        (
          404,
          {
            'code': 'nao_programado',
            'message': '${req.method} ${req.url.path}',
          },
        );
    final (status, corpo) = r;
    final bytes = corpo == null ? <int>[] : utf8.encode(jsonEncode(corpo));
    return http.StreamedResponse(
      http.ByteStream.fromBytes(bytes),
      status,
      contentLength: bytes.length,
      request: req,
      headers: {
        'content-type': 'application/json',
        // o Auth atual responde com a versão da API (erros com `code` em texto)
        if (req.url.path.startsWith('/auth/v1'))
          'x-supabase-api-version': '2024-01-01',
      },
    );
  }
}
