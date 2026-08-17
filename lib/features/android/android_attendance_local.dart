import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/utils/barcode_helpers.dart';

class AndroidAttendanceLocal extends StatefulWidget {
  const AndroidAttendanceLocal({super.key});

  @override
  State<AndroidAttendanceLocal> createState() => _AndroidAttendanceLocalState();
}

class _AndroidAttendanceLocalState extends State<AndroidAttendanceLocal> {
  final _scanBuffer = StringBuffer();
  Timer? _scanTimer;
  String? _lastScanResult;
  DateTime _selectedDate = DateTime.now();

  String get _dateStr =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _scanTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_scanBuffer.isNotEmpty) {
        final scanned = _scanBuffer.toString();
        _scanBuffer.clear();
        _processScan(scanned);
      }
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }

  void _processScan(String scanned) {
    final nis = BarcodeHelpers.extractNisFromScan(scanned);
    _handleScan(nis);
  }

  Future<void> _handleScan(String nis) async {
    final db = context.read<AppDatabase>();
    final student = await db.studentDao.getStudentByNis(nis);
    if (!mounted) return;
    if (student == null) {
      setState(() => _lastScanResult = 'Siswa tidak ditemukan: $nis');
      return;
    }

    try {
      await db.attendanceDao.markAttendance(
        studentId: student.id,
        date: _dateStr,
        status: 'Hadir',
        scanMethod: 'QR_SCAN',
      );
    } catch (e) {
      debugPrint('Error marking attendance: $e');
    }
    if (!mounted) return;

    setState(() => _lastScanResult = '${student.fullName} - Hadir');
    HapticFeedback.vibrate();
  }

  void _openCameraScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _AndroidCameraScan(
          onScanned: (nis) => _handleScan(nis),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Presensi'),
            Text(_dateStr, style: AppTheme.caption(context)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (!mounted) return;
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCameraScan,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR'),
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            final character = event.character;
            if (character != null) {
              if (event.logicalKey == LogicalKeyboardKey.enter) {
                final scanned = _scanBuffer.toString();
                _scanBuffer.clear();
                if (scanned.isNotEmpty) _processScan(scanned);
              } else {
                _scanBuffer.write(character);
              }
            }
          }
          return KeyEventResult.handled;
        },
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingBase),
              color: AppTheme.accent,
              child: Text(
                'Scan kartu barcode siswa',
                style: AppTheme.body(context).copyWith(color: Colors.white),
              ),
            ),
            if (_lastScanResult != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                color: _lastScanResult!.contains('Hadir')
                    ? AppTheme.mint
                    : AppTheme.coral,
                child: Text(
                  _lastScanResult!,
                  textAlign: TextAlign.center,
                  style: AppTheme.body(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            StreamBuilder<List<Student>>(
              stream: db.studentDao.watchAllStudents(),
              builder: (context, studentSnapshot) {
                final allStudents = studentSnapshot.data ?? [];
                return StreamBuilder<List<AttendanceData>>(
                  stream: db.attendanceDao.watchAttendanceByDate(_dateStr),
                  builder: (context, attendanceSnapshot) {
                    final attendances = attendanceSnapshot.data ?? [];
                    final attendanceMap = {for (final a in attendances) a.studentId: a};

                    return Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppTheme.spacingBase),
                        itemCount: allStudents.length,
                        itemBuilder: (context, index) {
                          final student = allStudents[index];
                          final attendance = attendanceMap[student.id];
                          final status = attendance?.status ?? 'Belum';

                          Color statusColor;
                          switch (status) {
                            case 'Hadir':
                              statusColor = AppTheme.mint;
                              break;
                            case 'Sakit':
                              statusColor = AppTheme.amber;
                              break;
                            case 'Izin':
                              statusColor = AppTheme.accent;
                              break;
                            case 'Alpa':
                              statusColor = AppTheme.coral;
                              break;
                            default:
                              statusColor = AppTheme.textSecondary;
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.accent.withOpacity(0.2),
                                child: Text(
                                  student.fullName.isNotEmpty
                                      ? student.fullName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(color: AppTheme.accent),
                                ),
                              ),
                              title: Text(student.fullName),
                              subtitle: Text('NIS: ${student.nis}'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AndroidCameraScan extends StatefulWidget {
  final Function(String nis) onScanned;
  const _AndroidCameraScan({required this.onScanned});

  @override
  State<_AndroidCameraScan> createState() => _AndroidCameraScanState();
}

class _AndroidCameraScanState extends State<_AndroidCameraScan> {
  MobileScannerController? _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    _isProcessing = true;
    final nis = BarcodeHelpers.extractNisFromScan(barcode.rawValue!);
    widget.onScanned(nis);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scan: $nis'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Siswa'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _controller?.toggleTorch(),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: MobileScanner(
        controller: _controller!,
        onDetect: _onDetect,
      ),
    );
  }
}
