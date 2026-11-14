import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/activities.dart';
import 'tables/track_points.dart';
import 'tables/shoes.dart';

part 'stryde_database.g.dart';

@DriftDatabase(tables: [Activities, TrackPoints, Shoes])
class StrydeDatabase extends _$StrydeDatabase {
  StrydeDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'stryde.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  // Activity Queries
  Stream<List<Activity>> watchAllActivities() {
    return (select(activities)
          ..orderBy([(t) => OrderingTerm(expression: t.startTime, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<Activity>> getAllActivities() {
    return (select(activities)
          ..orderBy([(t) => OrderingTerm(expression: t.startTime, mode: OrderingMode.desc)]))
        .get();
  }

  Future<Activity?> getActivityById(int id) {
    return (select(activities)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertActivity(ActivitiesCompanion activity) {
    return into(activities).insert(activity);
  }

  Future<bool> updateActivity(Activity activity) {
    return update(activities).replace(activity);
  }

  Future<int> deleteActivity(int id) {
    return (delete(activities)..where((t) => t.id.equals(id))).go();
  }

  // Track Points Queries
  Future<void> insertTrackPointsBatch(List<TrackPointsCompanion> points) async {
    await batch((batch) {
      batch.insertAll(trackPoints, points);
    });
  }

  Future<int> insertTrackPoint(TrackPointsCompanion point) {
    return into(trackPoints).insert(point);
  }

  Future<List<TrackPoint>> getTrackPointsForActivity(int activityId) {
    return (select(trackPoints)
          ..where((t) => t.activityId.equals(activityId))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.asc)]))
        .get();
  }

  Stream<List<TrackPoint>> watchTrackPointsForActivity(int activityId) {
    return (select(trackPoints)
          ..where((t) => t.activityId.equals(activityId))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.asc)]))
        .watch();
  }

  // Shoe Queries
  Stream<List<Shoe>> watchAllShoes() {
    return (select(shoes)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<Shoe>> getAllShoes() {
    return (select(shoes)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  Future<Shoe?> getDefaultShoe() {
    return (select(shoes)
          ..where((t) => t.isDefault.equals(true) & t.isRetired.equals(false)))
        .getSingleOrNull();
  }

  Future<int> insertShoe(ShoesCompanion shoe) {
    return into(shoes).insert(shoe);
  }

  Future<bool> updateShoe(Shoe shoe) {
    return update(shoes).replace(shoe);
  }

  Future<void> setDefaultShoe(int shoeId) async {
    await transaction(() async {
      // Clear previous default
      await (update(shoes)..where((t) => t.isDefault.equals(true)))
          .write(const ShoesCompanion(isDefault: Value(false)));
      // Set new default
      await (update(shoes)..where((t) => t.id.equals(shoeId)))
          .write(const ShoesCompanion(isDefault: Value(true)));
    });
  }

  Future<void> addMileageToShoe(int shoeId, double additionalKm) async {
    final shoe = await (select(shoes)..where((t) => t.id.equals(shoeId))).getSingleOrNull();
    if (shoe != null) {
      final updatedDistance = shoe.totalDistanceKm + additionalKm;
      await (update(shoes)..where((t) => t.id.equals(shoeId)))
          .write(ShoesCompanion(totalDistanceKm: Value(updatedDistance)));
    }
  }

  Future<int> deleteShoe(int id) {
    return (delete(shoes)..where((t) => t.id.equals(id))).go();
  }
}

