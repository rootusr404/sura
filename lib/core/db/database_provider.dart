import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

/// Base locale unique de l'application (fermée proprement à l'arrêt).
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
