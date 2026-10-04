// Sessão do Supabase no armazenamento SEGURO do sistema (Keychain no iOS, Keystore no Android) — G05,
// §4.4: o padrão do supabase_flutter (SharedPreferences) guarda o token em texto puro.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// O mínimo do armazenamento seguro (interface → fake em memória nos testes).
abstract interface class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// [SecureStore] real.
final class FlutterSecureStore implements SecureStore {
  FlutterSecureStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Sessão (tokens de acesso e de renovação) do Supabase Auth.
final class SecureSessionStorage extends LocalStorage {
  const SecureSessionStorage(this._store, {this.key = sessionKey});

  static const String sessionKey = 'booknest.auth.sessao';

  final SecureStore _store;
  final String key;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async => (await _store.read(key)) != null;

  @override
  Future<String?> accessToken() => _store.read(key);

  @override
  Future<void> removePersistedSession() => _store.delete(key);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _store.write(key, persistSessionString);
}

/// Verificador PKCE do login pelo navegador (Apple no Android) — também no armazenamento seguro.
final class SecurePkceStorage extends GotrueAsyncStorage {
  const SecurePkceStorage(this._store);

  static const String prefix = 'booknest.auth.pkce.';

  final SecureStore _store;

  @override
  Future<String?> getItem({required String key}) => _store.read('$prefix$key');

  @override
  Future<void> setItem({required String key, required String value}) =>
      _store.write('$prefix$key', value);

  @override
  Future<void> removeItem({required String key}) =>
      _store.delete('$prefix$key');
}
