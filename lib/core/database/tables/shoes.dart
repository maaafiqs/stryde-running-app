import 'package:drift/drift.dart';

class Shoes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get brand => text().withLength(min: 1, max: 100)();
  TextColumn get model => text().withLength(min: 1, max: 100)();
  TextColumn get nickname => text().nullable().withLength(max: 100)();
  RealColumn get totalDistanceKm => real().withDefault(const Constant(0.0))();
  RealColumn get maxDistanceKm => real().withDefault(const Constant(700.0))();
  BoolColumn get isRetired => boolean().withDefault(const Constant(false))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}