import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'qr_generator.dart';

class PdfGenerator {
  // KTP Card dimensions: 85.6mm x 53.9mm
  static const double ktpWidthMm = 85.6;
  static const double ktpHeightMm = 53.9;
  static const double ktpWidth = ktpWidthMm * PdfPageFormat.mm;
  static const double ktpHeight = ktpHeightMm * PdfPageFormat.mm;

  // A4 grid: 2 columns x 5 rows = 10 cards per page
  static const int cardsPerRow = 2;
  static const int rowsPerPage = 5;
  static const int cardsPerPage = cardsPerRow * rowsPerPage;

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
    required List<Map<String, String>> students,
    String? schoolName,
  }) async {
    final pdf = pw.Document();

    for (var i = 0; i < students.length; i += cardsPerPage) {
      final batch = students.skip(i).take(cardsPerPage).toList();
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => pw.Column(
          children: _buildCardGrid(batch, schoolName),
        ),
      ));
    }

    return pdf.save();
  }

  static List<pw.Widget> _buildCardGrid(
      List<Map<String, String>> students, String? schoolName) {
    final rows = <pw.Widget>[];

    for (var row = 0; row < rowsPerPage; row++) {
      final startIndex = row * cardsPerRow;
      final rowStudents = students
          .skip(startIndex)
          .take(cardsPerRow)
          .toList();

      if (rowStudents.isEmpty) break;

      final cards = rowStudents.map((s) {
        return _buildKtpCard(s, schoolName);
      }).toList();

      // Pad with empty containers if row is not full
      while (cards.length < cardsPerRow) {
        cards.add(pw.SizedBox(width: ktpWidth, height: ktpHeight));
      }

      rows.add(pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: cards,
      ));

      // Add crop marks between rows
      if (row < rowsPerPage - 1) {
        rows.add(pw.SizedBox(height: 4));
        rows.add(pw.Container(
          height: 0.5,
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(
                color: PdfColors.grey400,
                width: 0.5,
                style: pw.BorderStyle.dashed,
              ),
            ),
          ),
        ));
        rows.add(pw.SizedBox(height: 4));
      }
    }

    return rows;
  }

  static pw.Widget _buildKtpCard(
      Map<String, String> student, String? schoolName) {
    final payload = QrGenerator.encodePayload(
      nis: student['nis']!,
      name: student['name']!,
      className: student['class']!,
    );

    return pw.Container(
      width: ktpWidth,
      height: ktpHeight,
      margin: const pw.EdgeInsets.all(4),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
          width: 0.5,
        ),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Text(
            schoolName ?? 'SEKOLAH',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(height: 4, color: PdfColors.grey400),
          pw.SizedBox(height: 4),

          // Content
          pw.Expanded(
            child: pw.Row(
              children: [
                // QR Code
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: payload,
                  width: 50,
                  height: 50,
                ),
                pw.SizedBox(width: 8),

                // Student info
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        student['name']!,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'NIS: ${student['nis']}',
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                      pw.Text(
                        'Kelas: ${student['class']}',
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                    ],
                  ),
                ),
              ],
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
