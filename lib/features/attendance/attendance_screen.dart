import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
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
  String _selectedFilter = 'Semua';
  DateTime _selectedDate = DateTime.now();

  static const List<String> _filters = [
    'Semua', 'Hadir', 'Sakit', 'Izin', 'Alpa', 'Belum Absen',
  ];

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

    await db.attendanceDao.markAttendance(
      studentId: student.id,
      date: _dateStr,
      status: 'Hadir',
      scanMethod: 'QR_SCAN',
    );

    setState(() => _lastScanResult = '${student.fullName} - Hadir');
  }

  Future<void> _markAttendance({
    required Student student,
    required String status,
    String? description,
  }) async {
    final db = context.read<AppDatabase>();

    await db.attendanceDao.markAttendance(
      studentId: student.id,
      date: _dateStr,
      status: status,
      scanMethod: 'MANUAL',
      description: description,
    );

    setState(() => _lastScanResult = '${student.fullName} - $status');
  }

  Future<void> _resetAttendance(Student student) async {
    final db = context.read<AppDatabase>();

    await db.attendanceDao.resetAttendance(student.id, _dateStr);

    setState(() => _lastScanResult = '${student.fullName} - Status direset');
  }

  Future<void> _showDescriptionDialog({
    required Student student,
    required String status,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Keterangan $status'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Masukkan keterangan...',
            border: const OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _markAttendance(
        student: student,
        status: status,
        description: result.isNotEmpty ? result : null,
      );
    }
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = label),
      selectedColor: AppTheme.cyan.withOpacity(0.2),
      checkmarkColor: AppTheme.cyan,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.cyan : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  String get _dateStr =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Presensi'),
            Text(_dateStr, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
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
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
        ],
      ),
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
              color: AppTheme.cyan,
              child: Text(
                'Scan kartu barcode siswa - $_dateStr',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            if (_lastScanResult != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: _lastScanResult!.contains('Hadir')
                    ? AppTheme.mint
                    : _lastScanResult!.contains('reset')
                        ? AppTheme.amber
                        : AppTheme.coral,
                child: Text(
                  _lastScanResult!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

                    final hadirCount = attendances.where((a) => a.status == 'Hadir').length;
                    final sakitCount = attendances.where((a) => a.status == 'Sakit').length;
                    final izinCount = attendances.where((a) => a.status == 'Izin').length;
                    final alpaCount = attendances.where((a) => a.status == 'Alpa').length;
                    final belumAbsenCount = allStudents.length - attendances.length;

                    return Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildFilterChip('Semua', allStudents.length),
                                const SizedBox(width: 8),
                                _buildFilterChip('Hadir', hadirCount),
                                const SizedBox(width: 8),
                                _buildFilterChip('Sakit', sakitCount),
                                const SizedBox(width: 8),
                                _buildFilterChip('Izin', izinCount),
                                const SizedBox(width: 8),
                                _buildFilterChip('Alpa', alpaCount),
                                const SizedBox(width: 8),
                                _buildFilterChip('Belum Absen', belumAbsenCount),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _buildStudentList(allStudents, attendances),
                          ),
                        ],
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

  Widget _buildStudentList(List<Student> allStudents, List<AttendanceData> attendances) {
    final attendanceMap = {for (final a in attendances) a.studentId: a};

    List<Student> filteredStudents;
    if (_selectedFilter == 'Semua') {
      filteredStudents = allStudents;
    } else if (_selectedFilter == 'Belum Absen') {
      filteredStudents = allStudents.where((s) => !attendanceMap.containsKey(s.id)).toList();
    } else {
      filteredStudents = allStudents.where((s) {
        final att = attendanceMap[s.id];
        return att != null && att.status == _selectedFilter;
      }).toList();
    }

    if (filteredStudents.isEmpty) {
      return Center(
        child: Text(
          _selectedFilter == 'Belum Absen'
              ? 'Semua siswa sudah absen hari ini'
              : 'Tidak ada siswa dengan status $_selectedFilter',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        final attendance = attendanceMap[student.id];

        return AttendanceCard(
          attendance: attendance,
          student: student,
          onIzin: () => _showDescriptionDialog(student: student, status: 'Izin'),
          onSakit: () => _showDescriptionDialog(student: student, status: 'Sakit'),
          onAlpa: () => _showDescriptionDialog(student: student, status: 'Alpa'),
          onReset: () => _resetAttendance(student),
        );
      },
    );
  }
}
