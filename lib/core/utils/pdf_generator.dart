import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'qr_generator.dart';
import 'image_helper.dart';
import 'qr_image_helper.dart';

class PdfGenerator {
  // ID Card dimensions: 54mm x 86mm (standard ID Card)
  static const double tagWidthMm = 54;
  static const double tagHeightMm = 86;
  static const double tagWidth = tagWidthMm * PdfPageFormat.mm;
  static const double tagHeight = tagHeightMm * PdfPageFormat.mm;

  static Future<Uint8List?> generateBiodata({
    required String nis,
    required String fullName,
    required String className,
    required String gender,
    String? birthDate,
    String? address,
    String? parentName,
    String? parentPhone,
    String? schoolName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (schoolName != null && schoolName.isNotEmpty)
            pw.Center(
              child: pw.Text(schoolName,
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text('FORM BIODATA SISWA',
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          _buildRow('NIS', nis),
          _buildRow('Nama Lengkap', fullName),
          _buildRow('Kelas', className),
          _buildRow('Jenis Kelamin', gender),
          _buildRow('Tanggal Lahir', birthDate ?? '-'),
          _buildRow('Alamat', address ?? '-'),
          _buildRow('Nama Orang Tua', parentName ?? '-'),
          _buildRow('No. HP Orang Tua', parentPhone ?? '-'),
        ],
      ),
    ));

    return pdf.save();
  }

  static Future<Uint8List?> generateStudentCards({
    required List<Map<String, dynamic>> students,
    String? schoolName,
  }) async {
    final pdf = pw.Document();

    // Each student = 1 page with ID Card size (54mm x 86mm)
    for (final student in students) {
      // Process photo with auto-rotate
      Uint8List? photoBytes = student['photoBytes'] as Uint8List?;
      if (photoBytes != null) {
        photoBytes = ImageHelper.autoRotatePhoto(photoBytes);
      }

      // Generate QR Code PNG
      final payload = QrGenerator.encodePayload(
        nis: (student['nis'] as String?) ?? '',
        name: (student['name'] as String?) ?? '',
        className: (student['class'] as String?) ?? '',
      );
      final qrCodeBytes = QrImageHelper.generatePng(payload, size: 200);

      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat(tagWidth, tagHeight),
        margin: pw.EdgeInsets.zero,
        build: (context) => _buildIdCard(student, schoolName, photoBytes, qrCodeBytes),
      ));
    }

    return pdf.save();
  }

  static pw.Widget _buildIdCard(
    Map<String, dynamic> student,
    String? schoolName,
    Uint8List? photoBytes,
    Uint8List? qrCodeBytes,
  ) {
    // Colors
    final headerColor = PdfColor.fromHex('#2D3748');
    final accentColor = PdfColor.fromHex('#4FD1C5');
    final lightBg = PdfColor.fromHex('#F7FAFC');
    final borderColor = PdfColor.fromHex('#CBD5E0');

    return pw.Container(
      width: tagWidth,
      height: tagHeight,
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: borderColor, width: 1),
      ),
      child: pw.Column(
        children: [
          // Header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: pw.BoxDecoration(
              color: headerColor,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  schoolName ?? 'SEKOLAH',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: accentColor,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    'KARTU SISWA',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(8),
              color: lightBg,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  // Photo
                  if (photoBytes != null)
                    pw.Container(
                      width: 50,
                      height: 60,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: accentColor,
                          width: 2,
                        ),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.ClipRRect(
                        horizontalRadius: 4,
                        verticalRadius: 4,
                        child: pw.Image(
                          pw.MemoryImage(photoBytes),
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    pw.Container(
                      width: 50,
                      height: 60,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        border: pw.Border.all(
                          color: accentColor,
                          width: 2,
                        ),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'FOTO',
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey500,
                          ),
                        ),
                      ),
                    ),
                  pw.SizedBox(height: 8),

                  // Student Info
                  pw.Text(
                    'NIS   : ${student['nis'] ?? ''}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Nama  : ${student['name'] ?? ''}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: headerColor,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Kelas : ${student['class'] ?? ''}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // QR Code footer
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border(
                top: pw.BorderSide(color: borderColor, width: 0.5),
              ),
            ),
            child: pw.Column(
              children: [
                if (qrCodeBytes != null)
                  pw.Image(
                    pw.MemoryImage(qrCodeBytes),
                    width: 40,
                    height: 40,
                  ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'SCAN UNTUK VERIFIKASI',
                  style: pw.TextStyle(
                    fontSize: 6,
                    color: PdfColors.grey500,
                  ),
                ),
              ],
            ),
          ),

          // Bottom accent line
          pw.Container(
            height: 4,
            decoration: pw.BoxDecoration(
              color: accentColor,
              borderRadius: const pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(8),
                bottomRight: pw.Radius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<Uint8List?> generateReportCard({
    required String studentName,
    required String nis,
    required String className,
    required String semester,
    required List<Map<String, dynamic>> grades,
    required int totalViolationPoints,
    required int totalAchievementPoints,
    required int rank,
    required int totalStudents,
    String? schoolName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (schoolName != null && schoolName.isNotEmpty)
            pw.Center(
              child: pw.Text(schoolName,
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text('LAPORAN HASIL BELAJAR',
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Text('Semester: $semester',
              style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 20),
          _buildRow('Nama', studentName),
          _buildRow('NIS', nis),
          _buildRow('Kelas', className),
          pw.SizedBox(height: 20),
          pw.Header(text: 'Daftar Nilai', level: 2),
          pw.TableHelper.fromTextArray(
            headers: ['No', 'Mapel', 'UTS', 'UAS', 'Tugas', 'Rata-rata'],
            data: grades.asMap().entries.map((e) {
              final g = e.value;
              return [
                '${e.key + 1}',
                g['subject'] ?? '',
                (g['uts'] ?? 0).toString(),
                (g['uas'] ?? 0).toString(),
                (g['tugas'] ?? 0).toString(),
                (g['average'] ?? 0).toStringAsFixed(1),
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          _buildRow('Poin Prestasi', '+$totalAchievementPoints'),
          _buildRow('Poin Pelanggaran', '-$totalViolationPoints'),
          _buildRow('Peringkat', '$rank dari $totalStudents'),
        ],
      ),
    ));

    return pdf.save();
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 150, child: pw.Text(label)),
          pw.Text(': $value'),
        ],
      ),
    );
  }
}
