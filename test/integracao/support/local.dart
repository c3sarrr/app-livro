// Apoio dos testes de integração contra o Supabase LOCAL do WSL (G05/G06): variáveis do ambiente,
// código do e-mail no Mailpit e SQL direto no banco local (pela entrada padrão do psql no contêiner —
// nada de senha ou chave no repositório).
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

final String? supabaseUrlLocal = Platform.environment['BOOKNEST_SUPABASE_URL'];
final String? supabaseChaveLocal =
    Platform.environment['BOOKNEST_SUPABASE_PUBLISHABLE_KEY'];
final String powersyncUrlLocal =
    Platform.environment['BOOKNEST_POWERSYNC_URL'] ?? 'http://127.0.0.1:54330';
final String mailpitLocal =
    Platform.environment['BOOKNEST_MAILPIT_URL'] ?? 'http://127.0.0.1:54324';

/// O código de 6 dígitos que chegou para [email] depois de [depoisDe].
Future<String> codigoNoMailpit(
  String email, {
  required DateTime depoisDe,
}) async {
  final c = http.Client();
  try {
    for (var i = 0; i < 40; i++) {
      final r = await c.get(
        Uri.parse('$mailpitLocal/api/v1/messages?limit=50'),
      );
      final lista =
          (jsonDecode(r.body) as Map)['messages'] as List? ?? const [];
      for (final m in lista.cast<Map>()) {
        final para = (m['To'] as List).cast<Map>().map((t) => t['Address']);
        final quando = DateTime.parse(m['Created'] as String);
        if (!para.contains(email) || quando.isBefore(depoisDe)) continue;
        final msg = await c.get(
          Uri.parse('$mailpitLocal/api/v1/message/${m['ID']}'),
        );
        final corpo = jsonDecode(msg.body) as Map;
        final codigo = RegExp(r'\b(\d{6})\b')
            .firstMatch('${corpo['Text'] ?? ''} ${corpo['HTML'] ?? ''}');
        if (codigo != null) return codigo[1]!;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    throw StateError('o e-mail com o código não chegou ao Mailpit');
  } finally {
    c.close();
  }
}

/// Roda [comando] no Postgres do Supabase local (contêiner `supabase_db_booknest` no WSL) e devolve a
/// saída sem cabeçalho. O SQL vai pela entrada padrão (sem aspas na linha de comando).
Future<String> sqlLocal(String comando) async {
  final p = await Process.start('wsl', [
    '-d',
    'Ubuntu',
    '-u',
    'root',
    '--',
    'docker',
    'exec',
    '-i',
    'supabase_db_booknest',
    'psql',
    '-U',
    'postgres',
    '-tA',
    '-q',
    '-v',
    'ON_ERROR_STOP=1',
  ]);
  p.stdin.write(comando);
  await p.stdin.close();
  final saida = await p.stdout.transform(utf8.decoder).join();
  final erro = await p.stderr.transform(utf8.decoder).join();
  if (await p.exitCode != 0) throw StateError('psql: $erro');
  return saida.trim();
}
