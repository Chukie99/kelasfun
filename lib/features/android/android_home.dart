import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/features/android/android_scanner.dart';
import 'package:kelasfun/features/android/android_sync_screen.dart';
import 'package:kelasfun/core/sync/sync_config.dart';

class AndroidHome extends StatefulWidget {
  const AndroidHome({super.key});

  @override
  State<AndroidHome> createState() => _AndroidHomeState();
}

class _AndroidHomeState extends State<AndroidHome> {
  final _syncConfig = SyncConfig(serverUrl: '', apiKey: '');

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('kelasFun Presensi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AndroidSyncScreen(config: _syncConfig),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF5B9BD5),
            child: Text(
              'Presensi Hari Ini - $today',
              style: const TextStyle(color: Colors.white, fontSize: 18),
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
                    child: Text('Belum ada presensi',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF70C1B3),
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                          title: Text(student.fullName),
                          subtitle: Text('${student.className} - ${att.scanMethod}'),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AndroidScanner()),
        ),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR'),
      ),
    );
  }
}
