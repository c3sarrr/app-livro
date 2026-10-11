// Entrega do arquivo de exportação (D-65): grava o JSON numa pasta temporária do app e abre o menu
// de compartilhar do sistema (salvar em Arquivos, enviar por e-mail…). Nada sobe para o servidor.
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class ExportSink {
  Future<void> deliver({required String fileName, required String json});
}

final class ShareExportSink implements ExportSink {
  const ShareExportSink();

  @override
  Future<void> deliver({required String fileName, required String json}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    await file.writeAsString(json, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'Meus dados do BookNest',
      ),
    );
  }
}
