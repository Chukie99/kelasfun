import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/features/students/student_form_screen.dart';
import 'package:kelasfun/features/students/student_detail_screen.dart';
import 'package:kelasfun/features/students/widgets/student_card.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  String _searchQuery = '';
  String _selectedClass = 'Semua';

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      appBar: AppBar(title: const Text('Data Siswa')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Student>>(
        stream: db.studentDao.watchAllStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final students = snapshot.data ?? [];
          
          final classes = ['Semua', ...students.map((s) => s.className).toSet()];
          
          final filteredStudents = students.where((s) {
            final matchesSearch = _searchQuery.isEmpty ||
                s.nis.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesClass = _selectedClass == 'Semua' || s.className == _selectedClass;
            return matchesSearch && matchesClass;
          }).toList();

          if (students.isEmpty) {
            return const Center(child: Text('Belum ada siswa'));
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari siswa...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  value: _selectedClass,
                  items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _selectedClass = v ?? 'Semua'),
                ),
              ),
              Expanded(
                child: filteredStudents.isEmpty
                    ? const Center(child: Text('Tidak ada siswa ditemukan'))
                    : ListView.builder(
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          return StudentCard(
                            student: student,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentDetailScreen(student: student),
                              ),
                            ),
                            onDelete: () async {
                              await db.studentDao.deleteStudent(student.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
