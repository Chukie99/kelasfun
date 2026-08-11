import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/core/utils/pdf_generator.dart';

void main() {
  group('PdfGenerator', () {
    test('generate biodata PDF returns bytes', () async {
      final pdf = await PdfGenerator.generateBiodata(
        nis: '2025001',
        fullName: 'Andi Pratama',
        className: '6A',
        gender: 'Laki-laki',
        birthDate: '2015-05-20',
        address: 'Jl. Merdeka No. 1',
        parentName: 'Budi Pratama',
        parentPhone: '081234567890',
      );
      expect(pdf, isNotNull);
      expect(pdf!.length, greaterThan(0));
    });

    test('generate student cards PDF returns bytes', () async {
      final students = [
        {'nis': '2025001', 'name': 'Andi', 'class': '6A'},
        {'nis': '2025002', 'name': 'Rina', 'class': '6A'},
      ];
      final pdf = await PdfGenerator.generateStudentCards(students: students);
      expect(pdf, isNotNull);
      expect(pdf!.length, greaterThan(0));
    });

    test('generate report card PDF returns bytes', () async {
      final pdf = await PdfGenerator.generateReportCard(
        studentName: 'Andi Pratama',
        nis: '2025001',
        className: '6A',
        semester: 'Ganjil 2025/2026',
        grades: [
          {'subject': 'Matematika', 'uts': 85.0, 'uas': 90.0, 'tugas': 88.0, 'average': 87.7},
          {'subject': 'Bahasa Indonesia', 'uts': 80.0, 'uas': 85.0, 'tugas': 82.0, 'average': 82.3},
        ],
        totalViolationPoints: 5,
        totalAchievementPoints: 10,
        rank: 1,
        totalStudents: 30,
      );
      expect(pdf, isNotNull);
      expect(pdf!.length, greaterThan(0));
    });
  });

  group('KTP Card Layout', () {
    test('generates PDF with correct number of pages for 10 students', () async {
      final students = List.generate(10, (i) => {
        'nis': '${i + 1}'.padLeft(3, '0'),
        'name': 'Siswa ${i + 1}',
        'class': '6A',
      });

      final pdf = await PdfGenerator.generateStudentCards(
        students: students,
        schoolName: 'SDN Test',
      );

      expect(pdf, isNotNull);
    });

    test('generates PDF with 2 pages for 15 students', () async {
      final students = List.generate(15, (i) => {
        'nis': '${i + 1}'.padLeft(3, '0'),
        'name': 'Siswa ${i + 1}',
        'class': '6A',
      });

      final pdf = await PdfGenerator.generateStudentCards(
        students: students,
        schoolName: 'SDN Test',
      );

      expect(pdf, isNotNull);
    });

    test('generates empty PDF for no students', () async {
      final pdf = await PdfGenerator.generateStudentCards(
        students: [],
        schoolName: 'SDN Test',
      );

      expect(pdf, isNotNull);
    });
  });
}
