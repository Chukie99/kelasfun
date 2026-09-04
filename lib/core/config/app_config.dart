/// Central configuration for KelasFun.
///
/// API keys and URLs are loaded from environment variables at build time,
/// with fallback values for development. In production, set these via
/// `--dart-define` flags:
///
///   flutter run --dart-define=SUPABASE_URL=https://... --dart-define=SUPABASE_ANON_KEY=...
class AppConfig {
  AppConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://cdgnqhdmsnrlzylgoecz.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_HLnBeenbfNLvlF7sc6-lcg_fSIS87e3',
  );
}

/// Shared semester helpers used by multiple screens.
class SemesterHelper {
  SemesterHelper._();

  static String currentSemester() {
    final now = DateTime.now();
    if (now.month >= 7) {
      return 'Ganjil ${now.year}/${now.year + 1}';
    } else {
      return 'Genap ${now.year - 1}/${now.year}';
    }
  }

  static List<String> semesterOptions() {
    final now = DateTime.now();
    if (now.month >= 7) {
      return [
        'Ganjil ${now.year}/${now.year + 1}',
        'Genap ${now.year}/${now.year + 1}',
      ];
    } else {
      return [
        'Ganjil ${now.year - 1}/${now.year}',
        'Genap ${now.year - 1}/${now.year}',
      ];
    }
  }
}
