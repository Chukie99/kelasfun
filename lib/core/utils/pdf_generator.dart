import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'qr_generator.dart';

class PdfGenerator {
  static Future<Uint8List?> generateBiodata({
    required String nis,
    required String fullName,
    required String className,
    required String gender,
    String? birthDate,
    String? address,
    String? parentName,
    String? parentPhone,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Header(text: 'FORM BIODATA SISWA', level: 1),
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
    required List<Map<String, String>> students,
  }) async {
    final pdf = pw.Document();
    const cardsPerPage = 10;

    for (var i = 0; i < students.length; i += cardsPerPage) {
      final batch = students.skip(i).take(cardsPerPage).toList();
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => pw.Column(
          children: batch.map((s) {
            final payload = QrGenerator.encodePayload(
              nis: s['nis']!,
              name: s['name']!,
              className: s['class']!,
            );
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(style: pw.BorderStyle.dashed),
              ),
              child: pw.Row(
                children: [
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: payload,
                    width: 60,
                    height: 60,
                  ),
                  pw.SizedBox(width: 12),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(s['name']!, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('NIS: ${s['nis']} - Kelas: ${s['class']}'),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ));
    }

    return pdf.save();
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
  }) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Header(text: 'LAPORAN HASIL BELAJAR', level: 1),
          pw.Text('Semester: $semester'),
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
