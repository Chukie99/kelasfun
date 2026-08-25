/// Util semester TERPUSAT untuk seluruh aplikasi.
///
/// Konvensi Indonesia:
/// - Bulan Juli-Desember  = Ganjil, tahun ajaran berjalan (mis. "Ganjil 2026/2027")
/// - Bulan Januari-Juni   = Genap, tahun ajaran sebelumnya (mis. "Genap 2025/2026")
///
/// PENTING: Jangan buat format semester sendiri-sendiri lagi!
/// Nilai disimpan pakai string ini sebagai kunci — kalau format beda antar
/// modul, ranking/dashboard/report gak akan pernah match (bug lama).
class SemesterUtils {
  /// Kunci semester saat ini, format "Ganjil YYYY/YYYY+1" atau "Genap YYYY-1/YYYY".
  static String currentSemester([DateTime? now]) {
    final d = now ?? DateTime.now();
    if (d.month >= 7) {
      return 'Ganjil ${d.year}/${d.year + 1}';
    }
    return 'Genap ${d.year - 1}/${d.year}';
  }

  /// Dua opsi tahun ajaran berjalan (untuk dropdown pemilih semester).
  static List<String> options([DateTime? now]) {
    final d = now ?? DateTime.now();
    if (d.month >= 7) {
      return [
        'Ganjil ${d.year}/${d.year + 1}',
        'Genap ${d.year}/${d.year + 1}',
      ];
    }
    return [
      'Ganjil ${d.year - 1}/${d.year}',
      'Genap ${d.year - 1}/${d.year}',
    ];
  }

  /// Rentang tanggal [startDate, endDate] dari sebuah kunci semester.
  /// Contoh input "Ganjil 2026/2027" -> ("2026-07-01", "2026-12-31").
  /// Input rusak -> fallback ke tahun kalender berjalan.
  static ({String start, String end}) dateRange(String semesterKey) {
    final now = DateTime.now();
    final parts = semesterKey.trim().split(RegExp(r'\s+'));
    final yearToken =
        parts.length > 1 ? parts.last : '${now.year}/${now.year}';
    final startYear = int.tryParse(yearToken.split('/').first) ?? now.year;
    final isGanjil = semesterKey.startsWith('Ganjil');

    if (isGanjil) {
      return (start: '$startYear-07-01', end: '$startYear-12-31');
    }
    return (start: '$startYear-01-01', end: '$startYear-06-30');
  }
}
