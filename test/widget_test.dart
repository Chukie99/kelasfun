import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kelasfun/app.dart';
import 'package:kelasfun/core/database/app_database.dart';

AppDatabase createTestDb() =>
    AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));

void main() {
  testWidgets('App renders license gate then home', (WidgetTester tester) async {
    // LicenseCheckScreen membaca SharedPreferences — mock agar future-nya
    // resolve (tanpa ini pumpAndSettle timeout karena spinner selamanya).
    SharedPreferences.setMockInitialValues({});
    TestWidgetsFlutterBinding.ensureInitialized();

    final db = createTestDb();
    await tester.pumpWidget(KelasFunApp(database: db));

    // Pump terbatas (bukan pumpAndSettle): stream tema & license check
    // butuh beberapa frame, tapi ada timer/animasi yang bikin settle
    // tidak pernah selesai di lingkungan test.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Setelah lisensi check selesai (belum aktif di test env), layar
    // aktivasi yang muncul. Kalau suatu saat env terdeteksi aktif,
    // dashboard yang akan dirender.
    final isActivationVisible =
        find.text('Aktivasi kelasFun').evaluate().isNotEmpty;
    final isDashboardVisible =
        find.text('Dashboard').evaluate().isNotEmpty;
    expect(
      isActivationVisible || isDashboardVisible,
      isTrue,
      reason:
          'App harus menampilkan layar aktivasi ATAU dashboard setelah license check',
    );
    await db.close();
  });
}
