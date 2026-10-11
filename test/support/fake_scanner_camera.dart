// Câmera de mentira do scanner (G07): sem plugin nem canal de plataforma; o teste "lê" um código com
// [read] e controla a permissão e a lanterna.
import 'package:app_leitura/features/scanner/presentation/scanner_camera.dart';
import 'package:flutter/widgets.dart';

final class FakeScannerCamera implements ScannerCamera {
  FakeScannerCamera({
    CameraStatus status = CameraStatus.running,
    bool? torch = false,
  }) : status = ValueNotifier(status),
       torch = ValueNotifier(torch);

  @override
  final ValueNotifier<CameraStatus> status;

  @override
  final ValueNotifier<bool?> torch;

  ValueChanged<String>? _onCode;
  int torchToggles = 0;
  bool disposed = false;

  /// Simula a leitura de um código de barras.
  void read(String code) => _onCode?.call(code);

  @override
  Widget preview(ValueChanged<String> onCode) {
    _onCode = onCode;
    return const ColoredBox(
      key: ValueKey('scanner.camera.fake'),
      color: Color(0xFF2B2622),
    );
  }

  @override
  Future<void> toggleTorch() async {
    torchToggles++;
    torch.value = !(torch.value ?? false);
  }

  @override
  Future<void> dispose() async => disposed = true;
}
