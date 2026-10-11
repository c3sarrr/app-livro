// §4.4: a sessão do Supabase (tokens) e o verificador PKCE ficam no armazenamento SEGURO do sistema,
// nunca no SharedPreferences.
import 'package:app_leitura/features/account/data/secure_session_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_backend.dart';

void main() {
  test(
    'sessão: grava, lê, informa se existe e remove — tudo pelo SecureStore',
    () async {
      final store = MemorySecureStore();
      final s = SecureSessionStorage(store);
      await s.initialize();
      expect(await s.hasAccessToken(), isFalse);
      expect(await s.accessToken(), isNull);

      await s.persistSession('{"access_token":"x"}');
      expect(store.values, {
        SecureSessionStorage.sessionKey: '{"access_token":"x"}',
      });
      expect(await s.hasAccessToken(), isTrue);
      expect(await s.accessToken(), '{"access_token":"x"}');

      await s.removePersistedSession();
      expect(store.values, isEmpty);
      expect(await s.hasAccessToken(), isFalse);
    },
  );

  test('PKCE: chaves com prefixo próprio (não colidem com a sessão)', () async {
    final store = MemorySecureStore();
    final p = SecurePkceStorage(store);
    await p.setItem(key: 'sb-code-verifier', value: 'v');
    expect(store.values, {'${SecurePkceStorage.prefix}sb-code-verifier': 'v'});
    expect(await p.getItem(key: 'sb-code-verifier'), 'v');
    await p.removeItem(key: 'sb-code-verifier');
    expect(store.values, isEmpty);
  });
}
