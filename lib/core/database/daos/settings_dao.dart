import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/settings.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<void> setSetting(String key, String value) async {
    final existing = await (select(settings)..where((t) => t.key.equals(key))).getSingleOrNull();
    if (existing != null) {
      await (update(settings)..where((t) => t.key.equals(key)))
          .write(SettingsCompanion(value: Value(value)));
    } else {
      await into(settings).insert(SettingsCompanion.insert(key: key, value: value));
    }
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(settings)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watchSetting(String key) {
    return (select(settings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<Map<String, String>> getAllSettings() async {
    final rows = await select(settings).get();
    return {for (final r in rows) r.key: r.value};
  }

  Stream<Map<String, String>> watchAllSettings() {
    return select(settings).watch().map((rows) {
      return {for (final r in rows) r.key: r.value};
    });
  }

  Future<void> setSchoolProfile({
    required String name,
    String? address,
    String? city,
    String? province,
    String? phone,
    String? email,
  }) async {
    await setSetting('school_name', name);
    if (address != null) await setSetting('school_address', address);
    if (city != null) await setSetting('school_city', city);
    if (province != null) await setSetting('school_province', province);
    if (phone != null) await setSetting('school_phone', phone);
    if (email != null) await setSetting('school_email', email);
  }
}
