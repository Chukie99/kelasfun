import 'dart:async';
import 'package:mobile_scanner/mobile_scanner.dart';

abstract class ScannerController {
  Stream<String> get barcodes;
  Future<void> dispose();
}

class FakeScannerController implements ScannerController {
  final _controller = StreamController<String>.broadcast();

  @override
  Stream<String> get barcodes => _controller.stream;

  void emit(String raw) => _controller.add(raw);

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

class MobileScannerControllerImpl implements ScannerController {
  final MobileScannerController _mobile;
  final _barcodes = StreamController<String>.broadcast();

  MobileScannerControllerImpl()
      : _mobile = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
        );

  @override
  Stream<String> get barcodes => _barcodes.stream;

  MobileScannerController get nativeController => _mobile;

  void onDetect(BarcodeCapture capture) {
    if (_barcodes.isClosed) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null && raw.isNotEmpty) {
        _barcodes.add(raw);
        break;
      }
    }
  }

  @override
  Future<void> dispose() async {
    await _mobile.dispose();
    await _barcodes.close();
  }
}
