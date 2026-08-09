import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:kelasfun/core/theme/app_theme.dart';

void main() {
  group('AppTheme Color Palette', () {
    test('dark background is #0F172A', () {
      expect(AppTheme.background, const Color(0xFF0F172A));
    });

    test('dark surface is #1E293B', () {
      expect(AppTheme.surface, const Color(0xFF1E293B));
    });

    test('accent cyan is #38BDF8', () {
      expect(AppTheme.accentCyan, const Color(0xFF38BDF8));
    });

    test('accent mint is #34D399', () {
      expect(AppTheme.accentMint, const Color(0xFF34D399));
    });

    test('accent amber is #FBBF24', () {
      expect(AppTheme.accentAmber, const Color(0xFFFBBF24));
    });

    test('accent coral is #FB7185', () {
      expect(AppTheme.accentCoral, const Color(0xFFFB7185));
    });

    test('text primary is #F8FAFC', () {
      expect(AppTheme.textPrimary, const Color(0xFFF8FAFC));
    });

    test('border is #334155', () {
      expect(AppTheme.border, const Color(0xFF334155));
    });
  });
}
