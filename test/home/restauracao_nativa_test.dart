// G20 (D-207) — a restauração do lado nativo: no Android a FlutterActivity guarda o estado sozinha; no iOS o
// FlutterViewController precisa de um identificador de restauração (a documentação do RestorationManager). Sem Mac
// nesta máquina, a prova no aparelho fica para a G27.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS: o FlutterViewController do storyboard tem o identificador de restauração', () {
    final s = File('ios/Runner/Base.lproj/Main.storyboard').readAsStringSync();
    final controlador = RegExp(
      r'<viewController\s[^>]*customClass="FlutterViewController"[^>]*>',
      dotAll: true,
    ).firstMatch(s)!.group(0)!;
    expect(controlador, matches(RegExp(r'restorationIdentifier="[^"]+"')));
  });

  test('Android: a MainActivity é uma FlutterActivity (o estado vai no Bundle dela)', () {
    final k = File(
      'android/app/src/main/kotlin/com/example/app_leitura/MainActivity.kt',
    ).readAsStringSync();
    expect(k, contains('class MainActivity : FlutterActivity()'));
  });
}
