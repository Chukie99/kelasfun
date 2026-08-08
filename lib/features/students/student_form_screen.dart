import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/database/tables/students.dart';
import 'package:kelasfun/core/utils/qr_generator.dart';
import 'package:kelasfun/shared/widgets/app_text_field.dart';
import 'package:kelasfun/shared/widgets/app_button.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? student;
  const StudentFormScreen({super.key, this.student});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nisController;
  late TextEditingController _nameController;
  late TextEditingController _classController;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _nisController = TextEditingController(text: widget.student?.nis ?? '');
    _nameController = TextEditingController(text: widget.student?.fullName ?? '');
    _classController = TextEditingController(text: widget.student?.className ?? '');
    _gender = widget.student?.gender;
  }

  @override
  void dispose() {
    _nisController.dispose();
    _nameController.dispose();
    _classController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final isEditing = widget.student != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Siswa' : 'Tambah Siswa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AppTextField(label: 'NIS', controller: _nisController, onChanged: (_) {}),
              AppTextField(label: 'Nama Lengkap', controller: _nameController, onChanged: (_) {}),
              AppTextField(label: 'Kelas', controller: _classController, onChanged: (_) {}),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                items: const [
                  DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                ],
                onChanged: (value) => setState(() => _gender = value),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: isEditing ? 'Simpan' : 'Tambah',
                icon: Icons.save,
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final nis = _nisController.text;
                  final name = _nameController.text;
                  final className = _classController.text;
                  final qrData = QrGenerator.encodePayload(
                    nis: nis, name: name, className: className,
                  );

                  if (isEditing) {
                    await db.studentDao.updateStudent(StudentsCompanion(
                      id: Value(widget.student!.id),
                      nis: Value(nis),
                      fullName: Value(name),
                      className: Value(className),
                      gender: Value(_gender ?? ''),
                      qrData: Value(qrData),
                    ));
                  } else {
                    await db.studentDao.insertStudent(
                      nis: nis, fullName: name,
                      className: className, gender: _gender ?? '',
                      qrData: qrData,
                    );
                  }
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
