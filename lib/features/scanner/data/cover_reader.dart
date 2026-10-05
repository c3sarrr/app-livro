// Leitura da capa para "adicionar este livro" (Anexo 02 §7.4): foto pela câmera do sistema e
// reconhecimento de texto do ML Kit NO APARELHO (modelo latino embutido — nada vai para a rede). A foto
// é apagada logo depois da leitura.
import 'dart:io' show File, FileSystemException;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/cover_text.dart';

abstract interface class CoverReader {
  /// As linhas lidas na capa; null = a pessoa cancelou a foto.
  Future<List<CoverLine>?> read();
}

final class MlKitCoverReader implements CoverReader {
  const MlKitCoverReader();

  @override
  Future<List<CoverLine>?> read() async {
    final foto = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (foto == null) return null;
    final leitor = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final r = await leitor.processImage(InputImage.fromFilePath(foto.path));
      return [
        for (final bloco in r.blocks)
          for (final linha in bloco.lines)
            CoverLine(
              linha.text,
              linha.boundingBox.height,
              top: linha.boundingBox.top,
            ),
      ];
    } finally {
      await leitor.close();
      try {
        await File(foto.path).delete();
      } on FileSystemException {
        // o sistema já limpou
      }
    }
  }
}
