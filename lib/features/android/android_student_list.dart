import 'package:flutter/material.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'scanner_service.dart';
import 'android_student_form.dart';
import 'android_student_detail.dart';

class AndroidStudentList extends StatefulWidget {
  final ScannerService service;
  const AndroidStudentList({super.key, required this.service});

  @override
  State<AndroidStudentList> createState() => _AndroidStudentListState();
}

class _AndroidStudentListState extends State<AndroidStudentList> {
  List<StudentCacheEntry> _students = [];
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    await widget.service.syncStudents();
    final cache = await widget.service.loadStudentCache();
    if (!mounted) return;
    setState(() {
      _students = cache;
      _isLoading = false;
    });
  }

  void _addStudent() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AndroidStudentForm(service: widget.service),
      ),
    );
    if (result == true) _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _search.isEmpty
        ? _students
        : _students
            .where((s) =>
                s.name.toLowerCase().contains(_search.toLowerCase()) ||
                s.nis.contains(_search))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Siswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStudent,
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingBase),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari nama atau NIS...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          _students.isEmpty
                              ? 'Belum ada siswa'
                              : 'Tidak ditemukan',
                          style: AppTheme.bodySmall(context),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadStudents,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingBase),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final s = filtered[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.accent.withOpacity(0.2),
                                  child: Text(
                                    s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                                    style: TextStyle(color: AppTheme.accent),
                                  ),
                                ),
                                title: Text(s.name),
                                subtitle: Text('NIS: ${s.nis} | Kelas: ${s.className}'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AndroidStudentDetailScreen(
                                        student: s,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
