import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  String? _lastScanResult;
  String _selectedFilter = 'Semua';
  DateTime _selectedDate = DateTime.now();
  late final Stream<List<Student>> _studentsStream;

  static const List<String> _filters = [
    'Semua', 'Hadir', 'Sakit', 'Izin', 'Alpa', 'Belum Absen',
  ];

  @override
  void initState() {
    super.initState();
    final db = context.read<AppDatabase>();
    _studentsStream = db.studentDao.watchAllStudents();
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
  }

  Future<void> _markAttendance({
    required Student student,
    required String status,
    String? description,
  }) async {
    final db = context.read<AppDatabase>();

    try {
      await db.attendanceDao.markAttendance(
        studentId: student.id,
        date: _dateStr,
        status: status,
        scanMethod: 'MANUAL',
        description: description,
      );
    } catch (e) {
      debugPrint('Error marking attendance: $e');
    }
    if (!mounted) return;

    setState(() => _lastScanResult = '${student.fullName} - $status');
  }

  Future<void> _resetAttendance(Student student) async {
    final db = context.read<AppDatabase>();

    try {
      await db.attendanceDao.resetAttendance(student.id, _dateStr);
    } catch (e) {
      debugPrint('Error resetting attendance: $e');
    }
    if (!mounted) return;

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
        title: Text('Keterangan $status', style: AppTheme.h3(context)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Masukkan keterangan...',
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
    controller.dispose();
  }

  Widget _buildFilterChip(String label, int count, bool isDark) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = label),
      selectedColor: (isDark ? AppTheme.accent : AppTheme.lightAccent).withOpacity(0.2),
      checkmarkColor: isDark ? AppTheme.accent : AppTheme.lightAccent,
      labelStyle: AppTheme.body(context).copyWith(
        fontSize: 13,
        color: isSelected
            ? (isDark ? AppTheme.accent : AppTheme.lightAccent)
            : (isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  String get _dateStr =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  void _openCameraScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CameraScanScreen(
          onScanned: (nis) {
            _handleScan(nis);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppTheme.accent : AppTheme.lightAccent;
    final mintColor = isDark ? AppTheme.mint : AppTheme.lightMint;
    final amberColor = isDark ? AppTheme.amber : AppTheme.lightAmber;
    final coralColor = isDark ? AppTheme.coral : AppTheme.lightCoral;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Presensi', style: AppTheme.h2(context)),
            Text(_dateStr, style: AppTheme.caption(context)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _openCameraScan,
          ),
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
        label: const Text('Scan Kamera'),
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
              color: accentColor,
              child: Text(
                'Scan kartu barcode siswa - $_dateStr',
                  style: AppTheme.body(context).copyWith(
                    color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                  ),
              ),
            ),
            if (_lastScanResult != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                color: _lastScanResult!.contains('Hadir')
                    ? mintColor
                    : _lastScanResult!.contains('reset')
                        ? amberColor
                        : coralColor,
                child: Text(
                  _lastScanResult!,
                  textAlign: TextAlign.center,
                  style: AppTheme.body(context).copyWith(
                    color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            StreamBuilder<List<Student>>(
              stream: _studentsStream,
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
                    final belumAbsenCount = (allStudents.length - attendances.length).clamp(0, allStudents.length);

                    return Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingBase,
                            ),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildFilterChip('Semua', allStudents.length, isDark),
                                const SizedBox(width: AppTheme.spacingSm),
                                _buildFilterChip('Hadir', hadirCount, isDark),
                                const SizedBox(width: AppTheme.spacingSm),
                                _buildFilterChip('Sakit', sakitCount, isDark),
                                const SizedBox(width: AppTheme.spacingSm),
                                _buildFilterChip('Izin', izinCount, isDark),
                                const SizedBox(width: AppTheme.spacingSm),
                                _buildFilterChip('Alpa', alpaCount, isDark),
                                const SizedBox(width: AppTheme.spacingSm),
                                _buildFilterChip('Belum Absen', belumAbsenCount, isDark),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _buildStudentList(allStudents, attendances, isDark),
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

  Widget _buildStudentList(
    List<Student> allStudents,
    List<AttendanceData> attendances,
    bool isDark,
  ) {
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
          style: AppTheme.bodySmall(context),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingBase),
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

class _CameraScanScreen extends StatefulWidget {
  final Function(String nis) onScanned;
  const _CameraScanScreen({required this.onScanned});

  @override
  State<_CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<_CameraScanScreen> {
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
