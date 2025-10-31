import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor openLocalDatabaseExecutor() {
  return WebDatabase.withStorage(
    DriftWebStorage.indexedDb('khodan_local'),
    logStatements: false,
  );
}
