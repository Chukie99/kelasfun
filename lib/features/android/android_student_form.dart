import 'package:flutter/material.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'scanner_service.dart';

class AndroidStudentForm extends StatefulWidget {
  final ScannerService service;
  const AndroidStudentForm({super.key, required this.service});

  @override
  State<AndroidStudentForm> createState() => _AndroidStudentFormState();
}

class _AndroidStudentFormState extends State<AndroidStudentForm> {
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

    final result = await widget.service.createStudent(
      nis: _nisController.text.trim(),
      fullName: _nameController.text.trim(),
      className: _classController.text.trim(),
      gender: _gender,
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
    setState(() => _isSaving = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Siswa berhasil disimpan'),
          backgroundColor: AppTheme.mint,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Gagal menyimpan'),
          backgroundColor: AppTheme.coral,
        ),
      );
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
