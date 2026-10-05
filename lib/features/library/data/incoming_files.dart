// G09.4 — "Abrir com"/"Compartilhar" (D-87): o lado nativo copia o arquivo recebido para a pasta temporária do
// app e guarda a lista; o Dart pega ("pendentes") quando abre e a cada aviso ("chegaram"). Em plataforma sem o
// canal (desktop, testes), nada chega.
import 'dart:async';

import 'package:flutter/services.dart';

final class IncomingFile {
  const IncomingFile({required this.path, required this.name});

  /// Cópia recebida (o importador copia de novo para `livros/` e esta é apagada).
  final String path;

  /// Nome do arquivo como veio (dá o título quando o arquivo não tem).
  final String name;
}

abstract interface class IncomingFiles {
  /// Avisa que chegou arquivo novo com o app aberto.
  Stream<void> get arrivals;

  /// Os arquivos recebidos desde a última vez (e limpa a lista do lado nativo).
  Future<List<IncomingFile>> take();
}

final class ChannelIncomingFiles implements IncomingFiles {
  ChannelIncomingFiles([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel(channelName) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'chegaram') _arrivals.add(null);
      return null;
    });
  }

  static const String channelName = 'booknest/arquivos';

  final MethodChannel _channel;
  final StreamController<void> _arrivals = StreamController<void>.broadcast();

  @override
  Stream<void> get arrivals => _arrivals.stream;

  @override
  Future<List<IncomingFile>> take() async {
    try {
      final list =
          await _channel.invokeListMethod<Object?>('pendentes') ?? const [];
      return [
        for (final e in list)
          if (e case {'path': final String path, 'name': final String name})
            IncomingFile(path: path, name: name),
      ];
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    }
  }
}
