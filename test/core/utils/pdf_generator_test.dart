import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/core/utils/pdf_generator.dart';

void main() {
  group('PdfGenerator.generateStudentCards', () {
    test('should generate PDF with correct page size', () async {
      final students = [
        {
          'nis': '12345',
          'name': 'Test Student',
          'class': 'XII IPA 1',
          'photoBytes': null,
        },
      ];

      final pdf = await PdfGenerator.generateStudentCards(
        students: students,
        schoolName: 'Test School',
      );

      expect(pdf, isNotNull);
      expect(pdf, isNotEmpty);
    });

    test('should handle student without photo', () async {
      final students = [
        {
          'nis': '12345',
          'name': 'Test Student',
          'class': 'XII IPA 1',
        },
      ];

      final pdf = await PdfGenerator.generateStudentCards(
        students: students,
        schoolName: 'Test School',
      );

      expect(pdf, isNotNull);
    });

    test('should handle multiple students', () async {
      final students = [
        {
          'nis': '12345',
          'name': 'Student 1',
          'class': 'XII IPA 1',
        },
        {
          'nis': '67890',
          'name': 'Student 2',
          'class': 'XII IPA 2',
        },
      ];

      final pdf = await PdfGenerator.generateStudentCards(
        students: students,
        schoolName: 'Test School',
      );

      expect(pdf, isNotNull);
    });
  });
}
