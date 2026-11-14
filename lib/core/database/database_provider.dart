import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stryde_database.dart';

final databaseProvider = Provider<StrydeDatabase>((ref) {
  final db = StrydeDatabase();
  ref.onDispose(() {
    db.close();
  });
  return db;
});

final activitiesStreamProvider = StreamProvider<List<Activity>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllActivities();
});

final shoesStreamProvider = StreamProvider<List<Shoe>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllShoes();
});

final defaultShoeProvider = FutureProvider<Shoe?>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getDefaultShoe();
});

