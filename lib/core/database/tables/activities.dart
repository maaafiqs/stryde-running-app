import 'package:drift/drift.dart';
import 'shoes.dart';

class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get activityType => text().withDefault(const Constant('run'))();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  RealColumn get distanceKm => real()();
  IntColumn get durationSeconds => integer()();
  IntColumn get movingTimeSeconds => integer()();
  RealColumn get avgPaceSecondsPerKm => real()();
  RealColumn get maxPaceSecondsPerKm => real().withDefault(const Constant(0.0))();
  RealColumn get avgSpeedKmh => real().withDefault(const Constant(0.0))();
  RealColumn get maxSpeedKmh => real().withDefault(const Constant(0.0))();
  RealColumn get elevationGainMeters => real().withDefault(const Constant(0.0))();
  RealColumn get caloriesBurned => real().withDefault(const Constant(0.0))();
  IntColumn get shoeId => integer().nullable().references(Shoes, #id, onDelete: KeyAction.setNull)();
  TextColumn get splitPacesJson => text().withDefault(const Constant('[]'))();
  TextColumn get gpxFilePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

