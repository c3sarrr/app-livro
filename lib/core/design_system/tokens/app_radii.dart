import 'package:flutter/painting.dart';

/// Raios de borda do arquivo. `pill` (999) normaliza para metade do menor lado, como no CSS.
abstract final class AppRadii {
  static const double pill = 999; // normaliza para metade do menor lado
  static const double card = 28; // hero, cartão do dia, ticket, navegação
  static const double cardM = 22; // cards "Também lendo", cartão da semana
  static const double list = 24; // lista Recém-chegados
  static const double navItem = 20; // item ativo da navegação

  /// Capas 104×156 e 116×174 (ordem CSS: TL, TR, BR, BL).
  static const BorderRadius coverL = BorderRadius.only(
    topLeft: Radius.circular(4),
    topRight: Radius.circular(10),
    bottomRight: Radius.circular(10),
    bottomLeft: Radius.circular(4),
  );

  /// Capas 54×81 e 44×66 (ordem CSS: TL, TR, BR, BL).
  static const BorderRadius coverS = BorderRadius.only(
    topLeft: Radius.circular(3),
    topRight: Radius.circular(7),
    bottomRight: Radius.circular(7),
    bottomLeft: Radius.circular(3),
  );
}
