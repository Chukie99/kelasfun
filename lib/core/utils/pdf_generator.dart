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
    // Professional color scheme
    final primaryColor = PdfColor.fromHex('#1E3A5F');    // Deep navy blue
    final secondaryColor = PdfColor.fromHex('#C9A227');   // Gold accent
    final lightBg = PdfColor.fromHex('#F8F9FA');          // Light gray background
    final darkText = PdfColor.fromHex('#2C3E50');         // Dark text
    final mediumText = PdfColor.fromHex('#5D6D7E');       // Medium gray text
    final borderColor = PdfColor.fromHex('#DEE2E6');      // Light border
    final white = PdfColors.white;

    return pw.Container(
      width: tagWidth,
      height: tagHeight,
      decoration: pw.BoxDecoration(
        color: white,
        border: pw.Border.all(color: borderColor, width: 0.5),
      ),
      child: pw.Column(
        children: [
          // Header with school name
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: pw.BoxDecoration(
              color: primaryColor,
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  schoolName ?? 'SEKOLAH',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: white,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 3),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: secondaryColor,
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                  child: pw.Text(
                    'KARTU SISWA',
                    style: pw.TextStyle(
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold,
                      color: white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Gold accent line
          pw.Container(
            height: 2,
            color: secondaryColor,
          ),

          // Content area
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(8),
              color: lightBg,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  // Photo with professional frame
                  if (photoBytes != null)
                    pw.Container(
                      width: 45,
                      height: 55,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: secondaryColor,
                          width: 2,
                        ),
                        boxShadow: [
                          pw.BoxShadow(
                            color: PdfColors.grey300,
                            blurRadius: 3,
                            offset: const PdfPoint(1, 1),
                          ),
                        ],
                      ),
                      child: pw.ClipRRect(
                        child: pw.Image(
                          pw.MemoryImage(photoBytes),
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    pw.Container(
                      width: 45,
                      height: 55,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        border: pw.Border.all(
                          color: secondaryColor,
                          width: 2,
                        ),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'FOTO',
                          style: pw.TextStyle(
                            fontSize: 7,
                            color: mediumText,
                          ),
                        ),
                      ),
                    ),
                  pw.SizedBox(height: 6),

                  // Student Info - compact and clean
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(
                      color: white,
                      border: pw.Border.all(color: borderColor, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.Column(
                      children: [
                        _buildInfoRow('NIS', student['nis'] ?? '', darkText, mediumText),
                        pw.SizedBox(height: 2),
                        _buildInfoRow('NAMA', student['name'] ?? '', darkText, mediumText),
                        pw.SizedBox(height: 2),
                        _buildInfoRow('KELAS', student['class'] ?? '', darkText, mediumText),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // QR Code footer
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 5),
            decoration: pw.BoxDecoration(
              color: white,
              border: pw.Border(
                top: pw.BorderSide(color: borderColor, width: 0.5),
              ),
            ),
            child: pw.Column(
              children: [
                if (qrCodeBytes != null)
                  pw.Image(
                    pw.MemoryImage(qrCodeBytes),
                    width: 35,
                    height: 35,
                  ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'SCAN UNTUK VERIFIKASI',
                  style: pw.TextStyle(
                    fontSize: 5,
                    color: mediumText,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Bottom accent line
          pw.Container(
            height: 3,
            color: primaryColor,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, PdfColor labelColor, PdfColor valueColor) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 35,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 6,
              fontWeight: pw.FontWeight.bold,
              color: labelColor,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            ': $value',
            style: pw.TextStyle(
              fontSize: 6,
              color: valueColor,
            ),
          ),
        ),
      ],
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
