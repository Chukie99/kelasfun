import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/utils/barcode_helpers.dart';

class AndroidScanner extends StatefulWidget {
  const AndroidScanner({super.key});

  @override
  State<AndroidScanner> createState() => _AndroidScannerState();
}

class _AndroidScannerState extends State<AndroidScanner> {
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  String? _lastResult;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null) {
        _processScan(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _processScan(String rawValue) async {
    setState(() => _isProcessing = true);
    
    final nis = BarcodeHelpers.extractNisFromScan(rawValue);
    final db = context.read<AppDatabase>();
    final student = await db.studentDao.getStudentByNis(nis);
    
    if (student == null) {
      setState(() {
        _lastResult = 'Siswa tidak ditemukan: $nis';
        _isProcessing = false;
      });
      return;
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await db.attendanceDao.markAttendance(
      studentId: student.id,
      date: today,
      status: 'Hadir',
      scanMethod: 'QR_SCAN',
    );

    setState(() {
      _lastResult = '${student.fullName} - Hadir';
      _isProcessing = false;
    });

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _lastResult = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Siswa')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            ),
          ),
          if (_lastResult != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _lastResult!.contains('Hadir')
                  ? const Color(0xFF70C1B3)
                  : const Color(0xFFFF6B6B),
              child: Text(
                _lastResult!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: const Text(
              'Arahkan kamera ke QR code siswa',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
