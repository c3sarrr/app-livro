import 'dart:io';

/// O HTML literal das seções da prancha 01 (as fases L01a1…L01a9, geradas da extração na T02): a fonte da verdade
/// dos textos da Início desde a T03 (D-240), versionada em `docs/design/fases/`.
String htmlDaPrancha01() {
  final html = StringBuffer();
  final fases =
      Directory('docs/design/fases')
          .listSync()
          .whereType<File>()
          .where((f) => RegExp(r'L01a\d_[^/\\]+\.md$').hasMatch(f.path))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  if (fases.length != 9) {
    throw StateError('as fases L01a1…L01a9: ${fases.length}');
  }
  for (final f in fases) {
    final m = RegExp(
      r'```html\n(.*?)\n```',
      dotAll: true,
    ).firstMatch(f.readAsStringSync().replaceAll('\r\n', '\n'));
    html.writeln(m!.group(1));
  }
  return html.toString();
}
