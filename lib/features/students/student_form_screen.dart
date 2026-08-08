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
  late TextEditingController _birthDateController;
  late TextEditingController _addressController;
  late TextEditingController _parentNameController;
  late TextEditingController _parentPhoneController;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _nisController = TextEditingController(text: widget.student?.nis ?? '');
    _nameController = TextEditingController(text: widget.student?.fullName ?? '');
    _classController = TextEditingController(text: widget.student?.className ?? '');
    _birthDateController = TextEditingController(text: widget.student?.birthDate ?? '');
    _addressController = TextEditingController(text: widget.student?.address ?? '');
    _parentNameController = TextEditingController(text: widget.student?.parentName ?? '');
    _parentPhoneController = TextEditingController(text: widget.student?.parentPhone ?? '');
    _gender = widget.student?.gender;
  }

  @override
  void dispose() {
    _nisController.dispose();
    _nameController.dispose();
    _classController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
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
              AppTextField(
                label: 'Tanggal Lahir (YYYY-MM-DD)',
                controller: _birthDateController,
                onChanged: (_) {},
              ),
              AppTextField(label: 'Alamat', controller: _addressController, onChanged: (_) {}),
              AppTextField(label: 'Nama Orang Tua', controller: _parentNameController, onChanged: (_) {}),
              AppTextField(label: 'No. HP Orang Tua', controller: _parentPhoneController, onChanged: (_) {}),
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
                      birthDate: Value(_birthDateController.text),
                      address: Value(_addressController.text),
                      parentName: Value(_parentNameController.text),
                      parentPhone: Value(_parentPhoneController.text),
                      qrData: Value(qrData),
                    ));
                  } else {
                    await db.studentDao.insertStudent(
                      nis: nis, fullName: name,
                      className: className, gender: _gender ?? '',
                      qrData: qrData,
                      birthDate: _birthDateController.text,
                      address: _addressController.text,
                      parentName: _parentNameController.text,
                      parentPhone: _parentPhoneController.text,
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
