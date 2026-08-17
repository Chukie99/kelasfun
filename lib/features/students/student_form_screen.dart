import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kelasfun/core/database/app_database.dart';
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
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final nis = _nisController.text.isNotEmpty
          ? _nisController.text
          : 'temp_${DateTime.now().millisecondsSinceEpoch}';

      final bytes = await pickedFile.readAsBytes();
      final savedPath = await PhotoHelper.savePhotoBytes(nis: nis, bytes: bytes);
      if (mounted) {
        setState(() => _photoPath = savedPath);
      }
    } catch (e, stackTrace) {
      debugPrint('PICK PHOTO ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal memilih foto'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _pickBirthDate() async {
    DateTime initialDate = DateTime(2010, 1, 1);
    if (_birthDateController.text.isNotEmpty) {
      try {
        final parts = _birthDateController.text.split('-');
        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        _birthDateController.text =
            '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Widget _buildAvatar() {
    final name = _nameController.text.isNotEmpty ? _nameController.text : '?';
    final initials = PhotoHelper.getInitials(name);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_photoPath != null && _photoPath!.isNotEmpty) {
      try {
        final file = File(_photoPath!);
        if (file.existsSync()) {
          return CircleAvatar(
            radius: 50,
            backgroundImage: FileImage(file),
          );
        }
      } catch (_) {}
    }

    return CircleAvatar(
      radius: 50,
      backgroundColor: (isDark ? AppTheme.accent : AppTheme.lightAccent).withOpacity(0.2),
      child: Text(
        initials,
        style: AppTheme.h2(context).copyWith(
          color: isDark ? AppTheme.accent : AppTheme.lightAccent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final isEditing = widget.student != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Siswa' : 'Tambah Siswa')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 768;
          
          if (isDesktop) {
            return _buildDesktopLayout(db, isEditing, isDark);
          } else {
            return _buildMobileLayout(db, isEditing, isDark);
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout(AppDatabase db, bool isEditing, bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: _buildTwoPanelLayout(isDark),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                _buildButtonArea(db, isEditing, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(AppDatabase db, bool isEditing, bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                children: [
                  _buildMobileAvatarSection(isDark),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildMobileFormSection(isDark),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surface : AppTheme.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppTheme.border : AppTheme.lightBorder,
                ),
              ),
            ),
            child: _buildButtonArea(db, isEditing, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileAvatarSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surface : AppTheme.lightSurface,
        border: Border.all(
          color: isDark ? AppTheme.border : AppTheme.lightBorder,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickPhoto,
            child: Stack(
              children: [
                _buildAvatar(),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingSm),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.accent : AppTheme.lightAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Klik untuk ganti foto',
            style: AppTheme.caption(context),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: AppButton(
                  label: 'Ubah Foto',
                  icon: Icons.camera_alt,
                  type: AppButtonType.secondary,
                  isOutlined: true,
                  onPressed: _pickPhoto,
                ),
              ),
              if (_photoPath != null) ...[
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: AppButton(
                    label: 'Hapus Foto',
                    icon: Icons.delete_outline,
                    type: AppButtonType.danger,
                    isOutlined: true,
                    onPressed: () => setState(() => _photoPath = null),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFormSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surface : AppTheme.lightSurface,
        border: Border.all(
          color: isDark ? AppTheme.border : AppTheme.lightBorder,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Data Pribadi', isDark),
          const SizedBox(height: AppTheme.spacingMd),
          _buildMobileDataPribadiGrid(isDark),
          const SizedBox(height: AppTheme.spacingLg),
          _buildSectionHeader('Data Orang Tua', isDark),
          const SizedBox(height: AppTheme.spacingMd),
          _buildMobileDataOrangTuaGrid(isDark),
        ],
      ),
    );
  }

  Widget _buildMobileDataPribadiGrid(bool isDark) {
    return Column(
      children: [
        AppTextField(
          label: 'NIS',
          controller: _nisController,
          onChanged: (_) => setState(() {}),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'NIS wajib diisi';
            }
            return null;
          },
        ),
        AppTextField(
          label: 'Nama Lengkap',
          controller: _nameController,
          onChanged: (_) {},
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama wajib diisi';
            }
            return null;
          },
        ),
        AppTextField(
          label: 'Kelas',
          controller: _classController,
          onChanged: (_) => setState(() {}),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Kelas wajib diisi';
            }
            return null;
          },
        ),
        _buildGenderDropdown(isDark),
        AppTextField(
          label: 'Tanggal Lahir',
          controller: _birthDateController,
          readOnly: true,
          onTap: _pickBirthDate,
          suffixIcon: Icons.calendar_today,
          onChanged: (_) {},
        ),
        AppTextField(
          label: 'Alamat',
          controller: _addressController,
          onChanged: (_) {},
        ),
      ],
    );
  }

  Widget _buildMobileDataOrangTuaGrid(bool isDark) {
    return Column(
      children: [
        AppTextField(
          label: 'Nama Orang Tua',
          controller: _parentNameController,
          onChanged: (_) {},
        ),
        AppTextField(
          label: 'No. HP Orang Tua',
          controller: _parentPhoneController,
          onChanged: (_) {},
        ),
        AppTextField(
          label: 'Catatan',
          controller: _notesController,
          maxLines: 3,
          onChanged: (_) {},
        ),
      ],
    );
  }

  Widget _buildTwoPanelLayout(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surface : AppTheme.lightSurface,
        border: Border.all(
          color: isDark ? AppTheme.border : AppTheme.lightBorder,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeftPanel(isDark),
          Expanded(child: _buildRightPanel(isDark)),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(bool isDark) {
    return SizedBox(
      width: 280,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: isDark ? AppTheme.border : AppTheme.lightBorder,
            ),
          ),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                children: [
                  _buildAvatar(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingSm),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.accent : AppTheme.lightAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Klik untuk ganti foto',
              style: AppTheme.caption(context),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            _buildStatusCard(isDark),
            const SizedBox(height: AppTheme.spacingLg),
            _buildPhotoActions(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.inputFill : AppTheme.lightInputFill,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: isDark ? AppTheme.border : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusRow('NIS', _nisController.text.isNotEmpty ? _nisController.text : '-', isDark),
          const SizedBox(height: AppTheme.spacingXs),
          _buildStatusRow('Kelas', _classController.text.isNotEmpty ? _classController.text : '-', isDark),
          const SizedBox(height: AppTheme.spacingXs),
          _buildStatusRow('Jenis Kelamin', _gender ?? '-', isDark),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.caption(context).copyWith(
            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: AppTheme.bodySmall(context).copyWith(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoActions(bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'Hapus Foto',
            icon: Icons.delete_outline,
            type: AppButtonType.danger,
            isOutlined: true,
            onPressed: _photoPath != null ? () => setState(() => _photoPath = null) : null,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'Reset',
            icon: Icons.refresh,
            type: AppButtonType.secondary,
            isOutlined: true,
            onPressed: () {
              _nisController.clear();
              _nameController.clear();
              _classController.clear();
              _birthDateController.clear();
              _addressController.clear();
              _parentNameController.clear();
              _parentPhoneController.clear();
              _notesController.clear();
              setState(() {
                _gender = null;
                _photoPath = null;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Data Pribadi', isDark),
          const SizedBox(height: AppTheme.spacingMd),
          _buildDataPribadiGrid(isDark),
          const SizedBox(height: AppTheme.spacingLg),
          _buildSectionHeader('Data Orang Tua', isDark),
          const SizedBox(height: AppTheme.spacingMd),
          _buildDataOrangTuaGrid(isDark),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: AppTheme.h3(context).copyWith(
        color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
      ),
    );
  }

  Widget _buildDataPribadiGrid(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            AppTextField(
              label: 'NIS',
              controller: _nisController,
              onChanged: (_) => setState(() {}),
              flex: 1,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'NIS wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(width: AppTheme.spacingMd),
            AppTextField(
              label: 'Nama Lengkap',
              controller: _nameController,
              onChanged: (_) {},
              flex: 1,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama wajib diisi';
                }
                return null;
              },
            ),
          ],
        ),
        Row(
          children: [
            AppTextField(
              label: 'Kelas',
              controller: _classController,
              onChanged: (_) => setState(() {}),
              flex: 1,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kelas wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(child: _buildGenderDropdown(isDark)),
          ],
        ),
        Row(
          children: [
            AppTextField(
              label: 'Tanggal Lahir',
              controller: _birthDateController,
              readOnly: true,
              onTap: _pickBirthDate,
              suffixIcon: Icons.calendar_today,
              onChanged: (_) {},
              flex: 1,
            ),
            const SizedBox(width: AppTheme.spacingMd),
            AppTextField(
              label: 'Alamat',
              controller: _addressController,
              onChanged: (_) {},
              flex: 1,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderDropdown(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
      child: DropdownButtonFormField<String>(
        value: _gender,
        decoration: InputDecoration(
          labelText: 'Jenis Kelamin',
          filled: true,
          fillColor: isDark ? AppTheme.inputFill : AppTheme.lightInputFill,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            borderSide: BorderSide(
              color: isDark ? AppTheme.inputBorder : AppTheme.lightInputBorder,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            borderSide: BorderSide(
              color: isDark ? AppTheme.inputBorder : AppTheme.lightInputBorder,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            borderSide: BorderSide(
              color: isDark ? AppTheme.accent : AppTheme.lightAccent,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            borderSide: BorderSide(
              color: isDark ? AppTheme.coral : AppTheme.lightCoral,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            borderSide: BorderSide(
              color: isDark ? AppTheme.coral : AppTheme.lightCoral,
              width: 1.5,
            ),
          ),
          labelStyle: AppTheme.caption(context).copyWith(
            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        style: AppTheme.bodySmall(context).copyWith(
          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
        ),
        items: const [
          DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
          DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
        ],
        onChanged: (value) => setState(() => _gender = value),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Jenis kelamin wajib dipilih';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDataOrangTuaGrid(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            AppTextField(
              label: 'Nama Orang Tua',
              controller: _parentNameController,
              onChanged: (_) {},
              flex: 1,
            ),
            const SizedBox(width: AppTheme.spacingMd),
            AppTextField(
              label: 'No. HP Orang Tua',
              controller: _parentPhoneController,
              onChanged: (_) {},
              flex: 1,
            ),
          ],
        ),
        AppTextField(
          label: 'Catatan',
          controller: _notesController,
          maxLines: 3,
          onChanged: (_) {},
        ),
      ],
    );
  }

  Widget _buildButtonArea(AppDatabase db, bool isEditing, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        label: isEditing ? 'Simpan' : 'Tambah',
        icon: Icons.save,
        onPressed: () async {
          if (_formKey.currentState == null || !_formKey.currentState!.validate()) return;
          
          final nis = _nisController.text.trim();
          final name = _nameController.text.trim();
          final className = _classController.text.trim();
          final gender = _gender ?? '';
          
          if (gender.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Jenis kelamin wajib dipilih'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
          
          final qrData = QrGenerator.encodePayload(
            nis: nis, name: name, className: className,
          );
          final notes = _notesController.text.isNotEmpty ? _notesController.text : null;
          final birthDate = _birthDateController.text.isNotEmpty ? _birthDateController.text : null;
          final address = _addressController.text.isNotEmpty ? _addressController.text : null;
          final parentName = _parentNameController.text.isNotEmpty ? _parentNameController.text : null;
          final parentPhone = _parentPhoneController.text.isNotEmpty ? _parentPhoneController.text : null;

          try {
            if (isEditing) {
              await db.studentDao.updateStudent(StudentsCompanion(
                id: Value(widget.student!.id),
                nis: Value(nis),
                fullName: Value(name),
                className: Value(className),
                gender: Value(gender),
                birthDate: Value.absentIfNull(birthDate),
                address: Value.absentIfNull(address),
                parentName: Value.absentIfNull(parentName),
                parentPhone: Value.absentIfNull(parentPhone),
                photoPath: Value(_photoPath),
                qrData: Value(qrData),
                notes: Value.absentIfNull(notes),
              ));
            } else {
              await db.studentDao.insertStudent(
                nis: nis, fullName: name,
                className: className, gender: gender,
                qrData: qrData,
                birthDate: birthDate,
                address: address,
                parentName: parentName,
                parentPhone: parentPhone,
                photoPath: _photoPath,
                notes: notes,
              );
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEditing ? 'Data siswa berhasil diperbarui' : 'Siswa baru berhasil ditambahkan'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          } catch (e, stackTrace) {
            debugPrint('SAVE ERROR: $e');
            debugPrint('STACK TRACE: $stackTrace');
            if (mounted) {
              String errorMessage = 'Gagal menyimpan data: $e';
              if (e.toString().contains('UNIQUE constraint failed')) {
                if (e.toString().contains('students.nis')) {
                  errorMessage = 'NIS sudah digunakan oleh siswa lain';
                } else if (e.toString().contains('students.qr_data')) {
                  errorMessage = 'Data QR sudah ada, coba lagi';
                } else {
                  errorMessage = 'Data duplikat ditemukan';
                }
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
