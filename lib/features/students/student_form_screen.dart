import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/database/tables/students.dart';
import 'package:kelasfun/core/utils/qr_generator.dart';
import 'package:kelasfun/core/utils/photo_helper.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
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
  late TextEditingController _notesController;
  String? _gender;
  String? _photoPath;

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
    _notesController = TextEditingController(text: widget.student?.notes ?? '');
    _gender = widget.student?.gender;
    _photoPath = widget.student?.photoPath;
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
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final sourceFile = File(result.files.single.path!);
        final nis = _nisController.text.isNotEmpty ? _nisController.text : 'temp_${DateTime.now().millisecondsSinceEpoch}';
        final savedPath = await PhotoHelper.savePhoto(nis: nis, sourceFile: sourceFile);
        setState(() => _photoPath = savedPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih foto: $e')),
        );
      }
    }
  }

  Widget _buildAvatar() {
    final name = _nameController.text.isNotEmpty ? _nameController.text : '?';
    final initials = PhotoHelper.getInitials(name);

    if (_photoPath != null && File(_photoPath!).existsSync()) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(File(_photoPath!)),
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundColor: AppTheme.cyan.withOpacity(0.2),
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppTheme.cyan,
        ),
      ),
    );
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
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      _buildAvatar(),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.cyan,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('Klik untuk ganti foto', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ),
              const SizedBox(height: 24),
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
              AppTextField(label: 'Catatan', controller: _notesController, maxLines: 3, onChanged: (_) {}),
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
                  final notes = _notesController.text.isNotEmpty ? _notesController.text : null;

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
                      photoPath: Value(_photoPath),
                      qrData: Value(qrData),
                      notes: Value(notes),
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
                      photoPath: _photoPath,
                      notes: notes,
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
