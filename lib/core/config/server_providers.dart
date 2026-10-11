// Configuração pública e o cliente do Supabase (Riverpod). Sem servidor configurado
// (AppEnv.hasServer = false) não há cliente e o app é só convidado (D-64). O `main()` injeta o
// cliente depois do `Supabase.initialize`.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import 'app_env.dart';

final appEnvProvider = Provider<AppEnv>((ref) => AppEnv.fromDefines());

/// Cliente do Supabase (null = sem servidor nesta versão).
final supabaseClientProvider = Provider<SupabaseClient?>((ref) => null);
