import '../domain/models.dart';

/// Fonte dos dados da tela Início.
///
/// A implementação real (banco local + Supabase) chega na G08. Até lá, os testes e o app de
/// desenvolvimento usam a fixture do mundo de referência (`test/fixtures/`, D-34): produção não tem
/// dado de usuário escrito no código (PROMPT MESTRE §4.3.1).
abstract interface class HomeRepository {
  HomeSnapshot snapshot(DateTime now);
}
