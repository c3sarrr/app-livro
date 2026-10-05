// G09.4 — seletor de arquivo do sistema (D-87), só EPUB e PDF, lido em pedaços (nada inteiro na memória).
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

final class PickedBook {
  const PickedBook({required this.name, required this.bytes});

  final String name;
  final Stream<List<int>> bytes;
}

abstract interface class BookPicker {
  /// `null` = a pessoa cancelou.
  Future<PickedBook?> pick();
}

final class SystemBookPicker implements BookPicker {
  const SystemBookPicker();

  @override
  Future<PickedBook?> pick() async {
    final f = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['epub', 'pdf'],
    );
    if (f == null) return null;
    final Stream<Uint8List> s = f.readAsByteStream();
    return PickedBook(name: f.name, bytes: s);
  }
}
