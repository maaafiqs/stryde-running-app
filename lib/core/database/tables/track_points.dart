import 'package:drift/drift.dart';
import 'activities.dart';

class TrackPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get activityId => integer().references(Activities, #id, onDelete: KeyAction.cascade)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitude => real().withDefault(const Constant(0.0))();
  RealColumn get speed => real().withDefault(const Constant(0.0))(); // meters per second
  RealColumn get accuracy => real().withDefault(const Constant(0.0))(); // meters
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isPausedPoint => boolean().withDefault(const Constant(false))();
}

