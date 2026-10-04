import 'dart:io';

import 'package:flutter/services.dart';

const fontesLeitor = <String, String>{
  'S3VF': '../../assets/fonts/Literata-VF.ttf',
  'S3VFExt': '../../assets/fonts/Literata-VFExt.ttf',
  'S3VFVi': '../../assets/fonts/Literata-VFVi.ttf',
};

Future<void> carregarFontes() async {
  for (final MapEntry(key: familia, value: caminho) in fontesLeitor.entries) {
    final bytes = File(caminho).readAsBytesSync();
    await (FontLoader(
      familia,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
}
