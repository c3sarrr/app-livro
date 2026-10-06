// Falhas inesperadas do leitor que não podem parar a leitura (gravar a posição ou o tempo): vão para o
// relatório de falhas (sem dado da pessoa) e a próxima gravação tenta de novo. Os testes trocam.
import 'package:flutter/foundation.dart';

typedef ReaderErrorReporter = void Function(Object error, StackTrace stack);

void reportReaderError(Object error, StackTrace stack) =>
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stack, library: 'leitor'),
    );
