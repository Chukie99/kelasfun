import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/jurnal.dart';

part 'jurnal_dao.g.dart';

@DriftAccessor(tables: [Jurnals])
class JurnalDao extends DatabaseAccessor<AppDatabase> with _$JurnalDaoMixin {
  JurnalDao(super.db);

  Future<int> insertJurnal(JurnalsCompanion entry) => into(jurnals).insert(entry);

  Future<List<Jurnal>> getAllJurnals() => select(jurnals).get();

  Stream<List<Jurnal>> watchJurnalsByClass(String className) {
    return (select(jurnals)
      ..where((t) => t.className.equals(className))
      ..orderBy([(t) => OrderingTerm.desc(t.date)])
    ).watch();
  }

  Future<void> deleteJurnal(int id) => (delete(jurnals)..where((t) => t.id.equals(id))).go();
}
