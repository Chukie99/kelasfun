import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/utils/barcode_helpers.dart';
import 'package:kelasfun/features/attendance/widgets/attendance_card.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _scanBuffer = StringBuffer();
  Timer? _scanTimer;
  final _focusNode = FocusNode();
  String? _lastScanResult;

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
    _focusNode.dispose();
    super.dispose();
  }

  void _processScan(String scanned) {
    final nis = BarcodeHelpers.extractNisFromScan(scanned);
    _handleScan(nis);
  }

  Future<void> _handleScan(String nis) async {
    final db = context.read<AppDatabase>();
    final student = await db.studentDao.getStudentByNis(nis);
    if (student == null) {
      setState(() => _lastScanResult = 'Siswa tidak ditemukan: $nis');
      return;
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await db.attendanceDao.markAttendance(
      studentId: student.id,
      date: today,
      status: 'Hadir',
      scanMethod: 'QR_SCAN',
    );

    setState(() => _lastScanResult = '${student.fullName} - Hadir');
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Presensi Hari Ini')),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: (event) {
          if (event is RawKeyDownEvent && event.character != null) {
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              final scanned = _scanBuffer.toString();
              _scanBuffer.clear();
              if (scanned.isNotEmpty) _processScan(scanned);
            } else {
              _scanBuffer.write(event.character);
            }
          }
        },
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF5B9BD5),
              child: Text(
                'Scan kartu barcode siswa - $today',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            if (_lastScanResult != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: _lastScanResult!.contains('Hadir')
                    ? const Color(0xFF70C1B3)
                    : const Color(0xFFFF6B6B),
                child: Text(
                  _lastScanResult!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            Expanded(
              child: StreamBuilder<List<AttendanceData>>(
                stream: (db.select(db.attendance)
                  ..where((t) => t.date.equals(today))
                ).watch(),
                builder: (context, snapshot) {
                  final attendances = snapshot.data ?? [];
                  if (attendances.isEmpty) {
                    return const Center(
                      child: Text('Belum ada presensi hari ini',
                          style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return ListView.builder(
                    itemCount: attendances.length,
                    itemBuilder: (context, index) {
                      final att = attendances[index];
                      return FutureBuilder<Student?>(
                        future: db.studentDao.getStudentById(att.studentId),
                        builder: (context, studentSnap) {
                          final student = studentSnap.data;
                          if (student == null) return const SizedBox();
                          return AttendanceCard(attendance: att, student: student);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
