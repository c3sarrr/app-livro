// G19.7 — a entrega dos arquivos da exportação da tela 25 (D-194): grava num temporário do app e abre a folha de
// compartilhar do sistema (salvar em Arquivos, mandar por e-mail…). Nada sobe para o servidor (Grátis: o dado pessoal
// só sai do aparelho quando a pessoa escolhe para onde).
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class HighlightsFileSink {
  Future<void> share({
    required String fileName,
    required String content,
    required String mimeType,
  });
}

final class ShareHighlightsFileSink implements HighlightsFileSink {
  const ShareHighlightsFileSink();

  @override
  Future<void> share({
    required String fileName,
    required String content,
    required String mimeType,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(utf8.encode(content), flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: mimeType)],
        subject: 'Grifos e notas',
      ),
    );
  }
}
