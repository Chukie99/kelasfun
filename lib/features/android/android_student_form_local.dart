import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/utils/qr_generator.dart';

class AndroidStudentFormLocal extends StatefulWidget {
  const AndroidStudentFormLocal({super.key});

  @override
  State<AndroidStudentFormLocal> createState() => _AndroidStudentFormLocalState();
}

class _AndroidStudentFormLocalState extends State<AndroidStudentFormLocal> {
  final _formKey = GlobalKey<FormState>();
  final _nisController = TextEditingController();
  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  String _gender = 'Laki-laki';
  bool _isSaving = false;

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final db = context.read<AppDatabase>();
      final nis = _nisController.text.trim();

      final existing = await db.studentDao.getStudentByNis(nis);
      if (existing != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NIS sudah digunakan'),
            backgroundColor: AppTheme.coral,
          ),
        );
        setState(() => _isSaving = false);
        return;
      }

      final qrData = QrGenerator.encodePayload(
        nis: nis,
        name: _nameController.text.trim(),
        className: _classController.text.trim(),
      );

      await db.studentDao.insertStudent(
        nis: nis,
        fullName: _nameController.text.trim(),
        className: _classController.text.trim(),
        gender: _gender,
        qrData: qrData,
        birthDate: _birthDateController.text.trim().isNotEmpty
            ? _birthDateController.text.trim()
            : null,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        parentName: _parentNameController.text.trim().isNotEmpty
            ? _parentNameController.text.trim()
            : null,
        parentPhone: _parentPhoneController.text.trim().isNotEmpty
            ? _parentPhoneController.text.trim()
            : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Siswa berhasil disimpan'),
          backgroundColor: AppTheme.mint,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: AppTheme.coral,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Siswa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingBase),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nisController,
                decoration: const InputDecoration(
                  labelText: 'NIS *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: AppTheme.spacingBase),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: AppTheme.spacingBase),
              TextFormField(
                controller: _classController,
                decoration: const InputDecoration(
                  labelText: 'Kelas *',
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: 6A',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: AppTheme.spacingBase),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: 'Jenis Kelamin *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'Laki-laki'),
              ),
              const SizedBox(height: AppTheme.spacingBase),
              TextFormField(
                controller: _birthDateController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Lahir',
                  border: OutlineInputBorder(),
                  hintText: 'YYYY-MM-DD',
                ),
              ),
              const SizedBox(height: AppTheme.spacingBase),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppTheme.spacingBase),
              TextFormField(
                controller: _parentNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Orang Tua',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppTheme.spacingBase),
              TextFormField(
                controller: _parentPhoneController,
                decoration: const InputDecoration(
                  labelText: 'No. HP Orang Tua',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Simpan Siswa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
