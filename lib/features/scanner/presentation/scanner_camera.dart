// Câmera do scanner atrás de uma interface: o app usa o `mobile_scanner` (ML Kit no Android, Vision no
// iOS — leitura no aparelho, sem chave); os testes de widget trocam por uma de mentira.
import 'package:flutter/foundation.dart' show ValueListenable, ValueNotifier;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum CameraStatus { starting, running, denied, unavailable }

abstract interface class ScannerCamera {
  ValueListenable<CameraStatus> get status;

  /// Lanterna: true/false; null = o aparelho não tem.
  ValueListenable<bool?> get torch;

  /// Prévia da câmera; [onCode] recebe o texto de cada código de barras lido.
  Widget preview(ValueChanged<String> onCode);

  Future<void> toggleTorch();
  Future<void> dispose();
}

/// Fábrica da câmera (uma por abertura da tela).
final scannerCameraProvider = Provider<ScannerCamera Function()>(
  (ref) => MobileScannerCamera.new,
);

final class MobileScannerCamera implements ScannerCamera {
  MobileScannerCamera()
    : _c = MobileScannerController(
        // o ISBN impresso é um EAN-13 (978/979); o código de preço ao lado (EAN-5) fica de fora
        formats: const [BarcodeFormat.ean13],
        detectionSpeed: DetectionSpeed.noDuplicates,
      ) {
    _c.addListener(_sync);
  }

  final MobileScannerController _c;
  final ValueNotifier<CameraStatus> _status = ValueNotifier(
    CameraStatus.starting,
  );
  final ValueNotifier<bool?> _torch = ValueNotifier(null);

  void _sync() {
    final v = _c.value;
    _status.value = switch (v.error?.errorCode) {
      MobileScannerErrorCode.permissionDenied => CameraStatus.denied,
      null => v.isRunning ? CameraStatus.running : CameraStatus.starting,
      _ => CameraStatus.unavailable,
    };
    _torch.value = switch (v.torchState) {
      TorchState.on => true,
      TorchState.off || TorchState.auto => false,
      TorchState.unavailable => null,
    };
  }

  @override
  ValueListenable<CameraStatus> get status => _status;

  @override
  ValueListenable<bool?> get torch => _torch;

  @override
  Widget preview(ValueChanged<String> onCode) => MobileScanner(
    controller: _c,
    onDetect: (capture) {
      for (final b in capture.barcodes) {
        final v = b.rawValue;
        if (v != null) onCode(v);
      }
    },
    // o estado de erro é mostrado pela tela (status), não pelo widget do pacote
    errorBuilder: (context, error) => const SizedBox.expand(),
  );

  @override
  Future<void> toggleTorch() => _c.toggleTorch();

  @override
  Future<void> dispose() async {
    _c.removeListener(_sync);
    await _c.dispose();
    _status.dispose();
    _torch.dispose();
  }
}
