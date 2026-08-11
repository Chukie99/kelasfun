import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ExcelGenerator {
  static Future<String> generateReport({
    required String semester,
    required String className,
    required List<Map<String, dynamic>> students,
    required List<String> subjects,
  }) async {
    final excel = Excel.createExcel();
    excel.rename('Sheet1', 'Rapor');

    final headerStyle = CellStyle(
      bold: true,
      fontSize: 12,
      fontColorHex: ExcelColor.fromHexString('#FFFFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#FF1565C0'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final centerStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final headerRow = [
      'No',
      'NIS',
      'Nama Siswa',
    ];

    for (final subject in subjects) {
      headerRow.add(subject);
    }

    headerRow.addAll(['Rata-rata', 'Ranking']);

    final sheet = excel['Rapor'];

    final headerCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
    headerCell.value = TextCellValue('Rapor Digital - Kelas $className - Semester $semester');
    headerCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: HorizontalAlign.Left,
    );

    final subtitleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1));
    subtitleCell.value = TextCellValue('Periode: $semester');

    final gradeHeaderRow = 3;
    for (int i = 0; i < headerRow.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: gradeHeaderRow));
      cell.value = TextCellValue(headerRow[i]);
      cell.cellStyle = headerStyle;
    }

    final attHeaderRow = gradeHeaderRow + students.length + 2;
    final attHeaders = ['No', 'NIS', 'Nama Siswa', '', '', '', '', '', '', 'Hadir', 'Izin', 'Sakit', 'Alpa'];
    for (int i = 0; i < attHeaders.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: attHeaderRow));
      cell.value = TextCellValue(attHeaders[i]);
      cell.cellStyle = headerStyle;
    }

    final attTitleRow = attHeaderRow - 1;
    final attTitleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: attTitleRow));
    attTitleCell.value = TextCellValue('Rekapitulasi Presensi');
    attTitleCell.cellStyle = CellStyle(bold: true, fontSize: 12);

    final rankings = <int, int>{};
    for (int i = 0; i < students.length; i++) {
      rankings[students[i]['id'] as int] = i + 1;
    }

    for (int i = 0; i < students.length; i++) {
      final student = students[i];
      final row = gradeHeaderRow + 1 + i;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = IntCellValue(i + 1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).cellStyle = centerStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(student['nis'] as String);

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(student['fullName'] as String);

      final grades = student['grades'] as Map<String, double>;
      double totalScore = 0;
      int gradeCount = 0;

      for (int j = 0; j < subjects.length; j++) {
        final score = grades[subjects[j]] ?? 0;
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3 + j, rowIndex: row));
        cell.value = score > 0 ? DoubleCellValue(score) : TextCellValue('-');
        cell.cellStyle = centerStyle;
        if (score > 0) {
          totalScore += score;
          gradeCount++;
        }
      }

      final avg = gradeCount > 0 ? totalScore / gradeCount : 0;
      final avgCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3 + subjects.length, rowIndex: row));
      avgCell.value = DoubleCellValue(double.parse(avg.toStringAsFixed(1)));
      avgCell.cellStyle = centerStyle;

      final rankCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4 + subjects.length, rowIndex: row));
      rankCell.value = IntCellValue(rankings[student['id'] as int] ?? i + 1);
      rankCell.cellStyle = centerStyle;
    }

    final attDataStartRow = attHeaderRow + 1;
    for (int i = 0; i < students.length; i++) {
      final student = students[i];
      final row = attDataStartRow + i;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = IntCellValue(i + 1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(student['nis'] as String);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(student['fullName'] as String);

      final attendance = student['attendance'] as Map<String, int>;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row)).value = IntCellValue(attendance['hadir'] ?? 0);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: row)).value = IntCellValue(attendance['izin'] ?? 0);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: row)).value = IntCellValue(attendance['sakit'] ?? 0);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: row)).value = IntCellValue(attendance['alpa'] ?? 0);
    }

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'rapor_${className.replaceAll(' ', '_')}_${semester.replaceAll(' ', '_')}.xlsx';
    final filePath = p.join(appDir.path, fileName);

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    }

    return filePath;
  }
}
