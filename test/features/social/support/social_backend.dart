// G21.3 — o servidor de mentira da G05 com a conta já entrada, para os repositórios do social e dos clubes.
import 'package:supabase_flutter/supabase_flutter.dart'
    show OtpType, SupabaseClient;

import '../../account/support/fake_backend.dart';

export '../../account/support/fake_backend.dart';

/// Um `SupabaseClient` real sobre o [FakeBackend]; com [entrar], a conta de teste entra e os pedidos do login
/// saem da lista (só ficam os do social).
Future<(FakeBackend, SupabaseClient)> servidorSocial({
  Map<String, Resposta>? respostas,
  Map<String, Map<String, String>>? cabecalhos,
  bool entrar = true,
}) async {
  final b = FakeBackend(respostas: respostas, cabecalhos: cabecalhos);
  final c = b.client();
  if (entrar) {
    await c.auth.verifyOTP(
      email: emailTeste,
      token: '123456',
      type: OtpType.email,
    );
    b.pedidos.clear();
  }
  return (b, c);
}

/// O filtro de uma coluna no pedido (`eq.x`, `is.null`, …).
String? filtro(Pedido p, String coluna) => p.url.queryParameters[coluna];
