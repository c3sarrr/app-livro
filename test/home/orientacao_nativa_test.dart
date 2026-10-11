// G20 (D-209) — o retrato travado também no nativo: Android e iPhone desde a abertura (antes do Flutter
// chamar `setPreferredOrientations`); o iPad em retrato e em tela cheia (sem dividir a tela).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// As orientações da lista [chave] do Info.plist.
List<String> _orientacoes(String plist, String chave) {
  final lista = RegExp(
    '<key>${RegExp.escape(chave)}</key>\\s*<array>(.*?)</array>',
    dotAll: true,
  ).firstMatch(plist)!.group(1)!;
  return [
    for (final m in RegExp('<string>(.*?)</string>').allMatches(lista))
      m.group(1)!,
  ];
}

void main() {
  test('Android: a MainActivity só em retrato', () {
    final m = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    final atividade = RegExp(
      r'<activity\s[^>]*android:name="\.MainActivity"[^>]*>',
      dotAll: true,
    ).firstMatch(m)!.group(0)!;
    expect(atividade, contains('android:screenOrientation="portrait"'));
  });

  test('iOS: iPhone e iPad só em retrato; o iPad em tela cheia', () {
    final p = File('ios/Runner/Info.plist').readAsStringSync();
    expect(_orientacoes(p, 'UISupportedInterfaceOrientations'), [
      'UIInterfaceOrientationPortrait',
    ]);
    expect(_orientacoes(p, 'UISupportedInterfaceOrientations~ipad'), [
      'UIInterfaceOrientationPortrait',
    ]);
    expect(p, matches(RegExp(r'<key>UIRequiresFullScreen</key>\s*<true/>')));
  });

  test('o Flutter também pede só o retrato (D-06)', () {
    final main = File('lib/main.dart').readAsStringSync();
    expect(
      main,
      matches(
        RegExp(
          r'setPreferredOrientations\(const \[\s*DeviceOrientation\.portraitUp,\s*\]\)',
        ),
      ),
    );
  });
}
