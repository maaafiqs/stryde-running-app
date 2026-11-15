// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stryde_database.dart';

// ignore_for_file: type=lint
class $ShoesTable extends Shoes with TableInfo<$ShoesTable, Shoe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
      'brand', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
      'model', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _totalDistanceKmMeta =
      const VerificationMeta('totalDistanceKm');
  @override
  late final GeneratedColumn<double> totalDistanceKm = GeneratedColumn<double>(
      'total_distance_km', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _maxDistanceKmMeta =
      const VerificationMeta('maxDistanceKm');
  @override
  late final GeneratedColumn<double> maxDistanceKm = GeneratedColumn<double>(
      'max_distance_km', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(700.0));
  static const VerificationMeta _isRetiredMeta =
      const VerificationMeta('isRetired');
  @override
  late final GeneratedColumn<bool> isRetired = GeneratedColumn<bool>(
      'is_retired', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_retired" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        brand,
        model,
        nickname,
        totalDistanceKm,
        maxDistanceKm,
        isRetired,
        isDefault,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shoes';
  @override
  VerificationContext validateIntegrity(Insertable<Shoe> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('brand')) {
      context.handle(
          _brandMeta, brand.isAcceptableOrUnknown(data['brand']!, _brandMeta));
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
          _modelMeta, model.isAcceptableOrUnknown(data['model']!, _modelMeta));
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    }
    if (data.containsKey('total_distance_km')) {
      context.handle(
          _totalDistanceKmMeta,
          totalDistanceKm.isAcceptableOrUnknown(
              data['total_distance_km']!, _totalDistanceKmMeta));
    }
    if (data.containsKey('max_distance_km')) {
      context.handle(
          _maxDistanceKmMeta,
          maxDistanceKm.isAcceptableOrUnknown(
              data['max_distance_km']!, _maxDistanceKmMeta));
    }
    if (data.containsKey('is_retired')) {
      context.handle(_isRetiredMeta,
          isRetired.isAcceptableOrUnknown(data['is_retired']!, _isRetiredMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shoe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shoe(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      brand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand'])!,
      model: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model'])!,
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname']),
      totalDistanceKm: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_distance_km'])!,
      maxDistanceKm: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}max_distance_km'])!,
      isRetired: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_retired'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ShoesTable createAlias(String alias) {
    return $ShoesTable(attachedDatabase, alias);
  }
}

class Shoe extends DataClass implements Insertable<Shoe> {
  final int id;
  final String brand;
  final String model;
  final String? nickname;
  final double totalDistanceKm;
  final double maxDistanceKm;
  final bool isRetired;
  final bool isDefault;
  final DateTime createdAt;
  const Shoe(
      {required this.id,
      required this.brand,
      required this.model,
      this.nickname,
      required this.totalDistanceKm,
      required this.maxDistanceKm,
      required this.isRetired,
      required this.isDefault,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['brand'] = Variable<String>(brand);
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    map['total_distance_km'] = Variable<double>(totalDistanceKm);
    map['max_distance_km'] = Variable<double>(maxDistanceKm);
    map['is_retired'] = Variable<bool>(isRetired);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ShoesCompanion toCompanion(bool nullToAbsent) {
    return ShoesCompanion(
      id: Value(id),
      brand: Value(brand),
      model: Value(model),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      totalDistanceKm: Value(totalDistanceKm),
      maxDistanceKm: Value(maxDistanceKm),
      isRetired: Value(isRetired),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
    );
  }

  factory Shoe.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shoe(
      id: serializer.fromJson<int>(json['id']),
      brand: serializer.fromJson<String>(json['brand']),
      model: serializer.fromJson<String>(json['model']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      totalDistanceKm: serializer.fromJson<double>(json['totalDistanceKm']),
      maxDistanceKm: serializer.fromJson<double>(json['maxDistanceKm']),
      isRetired: serializer.fromJson<bool>(json['isRetired']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'brand': serializer.toJson<String>(brand),
      'model': serializer.toJson<String>(model),
      'nickname': serializer.toJson<String?>(nickname),
      'totalDistanceKm': serializer.toJson<double>(totalDistanceKm),
      'maxDistanceKm': serializer.toJson<double>(maxDistanceKm),
      'isRetired': serializer.toJson<bool>(isRetired),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Shoe copyWith(
          {int? id,
          String? brand,
          String? model,
          Value<String?> nickname = const Value.absent(),
          double? totalDistanceKm,
          double? maxDistanceKm,
          bool? isRetired,
          bool? isDefault,
          DateTime? createdAt}) =>
      Shoe(
        id: id ?? this.id,
        brand: brand ?? this.brand,
        model: model ?? this.model,
        nickname: nickname.present ? nickname.value : this.nickname,
        totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
        maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
        isRetired: isRetired ?? this.isRetired,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt ?? this.createdAt,
      );
  Shoe copyWithCompanion(ShoesCompanion data) {
    return Shoe(
      id: data.id.present ? data.id.value : this.id,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      totalDistanceKm: data.totalDistanceKm.present
          ? data.totalDistanceKm.value
          : this.totalDistanceKm,
      maxDistanceKm: data.maxDistanceKm.present
          ? data.maxDistanceKm.value
          : this.maxDistanceKm,
      isRetired: data.isRetired.present ? data.isRetired.value : this.isRetired,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shoe(')
          ..write('id: $id, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('nickname: $nickname, ')
          ..write('totalDistanceKm: $totalDistanceKm, ')
          ..write('maxDistanceKm: $maxDistanceKm, ')
          ..write('isRetired: $isRetired, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, brand, model, nickname, totalDistanceKm,
      maxDistanceKm, isRetired, isDefault, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shoe &&
          other.id == this.id &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.nickname == this.nickname &&
          other.totalDistanceKm == this.totalDistanceKm &&
          other.maxDistanceKm == this.maxDistanceKm &&
          other.isRetired == this.isRetired &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt);
}

class ShoesCompanion extends UpdateCompanion<Shoe> {
  final Value<int> id;
  final Value<String> brand;
  final Value<String> model;
  final Value<String?> nickname;
  final Value<double> totalDistanceKm;
  final Value<double> maxDistanceKm;
  final Value<bool> isRetired;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  const ShoesCompanion({
    this.id = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.nickname = const Value.absent(),
    this.totalDistanceKm = const Value.absent(),
    this.maxDistanceKm = const Value.absent(),
    this.isRetired = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ShoesCompanion.insert({
    this.id = const Value.absent(),
    required String brand,
    required String model,
    this.nickname = const Value.absent(),
    this.totalDistanceKm = const Value.absent(),
    this.maxDistanceKm = const Value.absent(),
    this.isRetired = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : brand = Value(brand),
        model = Value(model);
  static Insertable<Shoe> custom({
    Expression<int>? id,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<String>? nickname,
    Expression<double>? totalDistanceKm,
    Expression<double>? maxDistanceKm,
    Expression<bool>? isRetired,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (nickname != null) 'nickname': nickname,
      if (totalDistanceKm != null) 'total_distance_km': totalDistanceKm,
      if (maxDistanceKm != null) 'max_distance_km': maxDistanceKm,
      if (isRetired != null) 'is_retired': isRetired,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ShoesCompanion copyWith(
      {Value<int>? id,
      Value<String>? brand,
      Value<String>? model,
      Value<String?>? nickname,
      Value<double>? totalDistanceKm,
      Value<double>? maxDistanceKm,
      Value<bool>? isRetired,
      Value<bool>? isDefault,
      Value<DateTime>? createdAt}) {
    return ShoesCompanion(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      nickname: nickname ?? this.nickname,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      isRetired: isRetired ?? this.isRetired,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (totalDistanceKm.present) {
      map['total_distance_km'] = Variable<double>(totalDistanceKm.value);
    }
    if (maxDistanceKm.present) {
      map['max_distance_km'] = Variable<double>(maxDistanceKm.value);
    }
    if (isRetired.present) {
      map['is_retired'] = Variable<bool>(isRetired.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoesCompanion(')
          ..write('id: $id, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('nickname: $nickname, ')
          ..write('totalDistanceKm: $totalDistanceKm, ')
          ..write('maxDistanceKm: $maxDistanceKm, ')
          ..write('isRetired: $isRetired, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _activityTypeMeta =
      const VerificationMeta('activityType');
  @override
  late final GeneratedColumn<String> activityType = GeneratedColumn<String>(
      'activity_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('run'));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _distanceKmMeta =
      const VerificationMeta('distanceKm');
  @override
  late final GeneratedColumn<double> distanceKm = GeneratedColumn<double>(
      'distance_km', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _movingTimeSecondsMeta =
      const VerificationMeta('movingTimeSeconds');
  @override
  late final GeneratedColumn<int> movingTimeSeconds = GeneratedColumn<int>(
      'moving_time_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _avgPaceSecondsPerKmMeta =
      const VerificationMeta('avgPaceSecondsPerKm');
  @override
  late final GeneratedColumn<double> avgPaceSecondsPerKm =
      GeneratedColumn<double>('avg_pace_seconds_per_km', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _maxPaceSecondsPerKmMeta =
      const VerificationMeta('maxPaceSecondsPerKm');
  @override
  late final GeneratedColumn<double> maxPaceSecondsPerKm =
      GeneratedColumn<double>('max_pace_seconds_per_km', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _avgSpeedKmhMeta =
      const VerificationMeta('avgSpeedKmh');
  @override
  late final GeneratedColumn<double> avgSpeedKmh = GeneratedColumn<double>(
      'avg_speed_kmh', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _maxSpeedKmhMeta =
      const VerificationMeta('maxSpeedKmh');
  @override
  late final GeneratedColumn<double> maxSpeedKmh = GeneratedColumn<double>(
      'max_speed_kmh', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _elevationGainMetersMeta =
      const VerificationMeta('elevationGainMeters');
  @override
  late final GeneratedColumn<double> elevationGainMeters =
      GeneratedColumn<double>('elevation_gain_meters', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _caloriesBurnedMeta =
      const VerificationMeta('caloriesBurned');
  @override
  late final GeneratedColumn<double> caloriesBurned = GeneratedColumn<double>(
      'calories_burned', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _shoeIdMeta = const VerificationMeta('shoeId');
  @override
  late final GeneratedColumn<int> shoeId = GeneratedColumn<int>(
      'shoe_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES shoes (id) ON DELETE SET NULL'));
  static const VerificationMeta _splitPacesJsonMeta =
      const VerificationMeta('splitPacesJson');
  @override
  late final GeneratedColumn<String> splitPacesJson = GeneratedColumn<String>(
      'split_paces_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _gpxFilePathMeta =
      const VerificationMeta('gpxFilePath');
  @override
  late final GeneratedColumn<String> gpxFilePath = GeneratedColumn<String>(
      'gpx_file_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        activityType,
        startTime,
        endTime,
        distanceKm,
        durationSeconds,
        movingTimeSeconds,
        avgPaceSecondsPerKm,
        maxPaceSecondsPerKm,
        avgSpeedKmh,
        maxSpeedKmh,
        elevationGainMeters,
        caloriesBurned,
        shoeId,
        splitPacesJson,
        gpxFilePath,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(Insertable<Activity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('activity_type')) {
      context.handle(
          _activityTypeMeta,
          activityType.isAcceptableOrUnknown(
              data['activity_type']!, _activityTypeMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('distance_km')) {
      context.handle(
          _distanceKmMeta,
          distanceKm.isAcceptableOrUnknown(
              data['distance_km']!, _distanceKmMeta));
    } else if (isInserting) {
      context.missing(_distanceKmMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('moving_time_seconds')) {
      context.handle(
          _movingTimeSecondsMeta,
          movingTimeSeconds.isAcceptableOrUnknown(
              data['moving_time_seconds']!, _movingTimeSecondsMeta));
    } else if (isInserting) {
      context.missing(_movingTimeSecondsMeta);
    }
    if (data.containsKey('avg_pace_seconds_per_km')) {
      context.handle(
          _avgPaceSecondsPerKmMeta,
          avgPaceSecondsPerKm.isAcceptableOrUnknown(
              data['avg_pace_seconds_per_km']!, _avgPaceSecondsPerKmMeta));
    } else if (isInserting) {
      context.missing(_avgPaceSecondsPerKmMeta);
    }
    if (data.containsKey('max_pace_seconds_per_km')) {
      context.handle(
          _maxPaceSecondsPerKmMeta,
          maxPaceSecondsPerKm.isAcceptableOrUnknown(
              data['max_pace_seconds_per_km']!, _maxPaceSecondsPerKmMeta));
    }
    if (data.containsKey('avg_speed_kmh')) {
      context.handle(
          _avgSpeedKmhMeta,
          avgSpeedKmh.isAcceptableOrUnknown(
              data['avg_speed_kmh']!, _avgSpeedKmhMeta));
    }
    if (data.containsKey('max_speed_kmh')) {
      context.handle(
          _maxSpeedKmhMeta,
          maxSpeedKmh.isAcceptableOrUnknown(
              data['max_speed_kmh']!, _maxSpeedKmhMeta));
    }
    if (data.containsKey('elevation_gain_meters')) {
      context.handle(
          _elevationGainMetersMeta,
          elevationGainMeters.isAcceptableOrUnknown(
              data['elevation_gain_meters']!, _elevationGainMetersMeta));
    }
    if (data.containsKey('calories_burned')) {
      context.handle(
          _caloriesBurnedMeta,
          caloriesBurned.isAcceptableOrUnknown(
              data['calories_burned']!, _caloriesBurnedMeta));
    }
    if (data.containsKey('shoe_id')) {
      context.handle(_shoeIdMeta,
          shoeId.isAcceptableOrUnknown(data['shoe_id']!, _shoeIdMeta));
    }
    if (data.containsKey('split_paces_json')) {
      context.handle(
          _splitPacesJsonMeta,
          splitPacesJson.isAcceptableOrUnknown(
              data['split_paces_json']!, _splitPacesJsonMeta));
    }
    if (data.containsKey('gpx_file_path')) {
      context.handle(
          _gpxFilePathMeta,
          gpxFilePath.isAcceptableOrUnknown(
              data['gpx_file_path']!, _gpxFilePathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      activityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_type'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time'])!,
      distanceKm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}distance_km'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      movingTimeSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}moving_time_seconds'])!,
      avgPaceSecondsPerKm: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}avg_pace_seconds_per_km'])!,
      maxPaceSecondsPerKm: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}max_pace_seconds_per_km'])!,
      avgSpeedKmh: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}avg_speed_kmh'])!,
      maxSpeedKmh: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}max_speed_kmh'])!,
      elevationGainMeters: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}elevation_gain_meters'])!,
      caloriesBurned: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}calories_burned'])!,
      shoeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}shoe_id']),
      splitPacesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}split_paces_json'])!,
      gpxFilePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gpx_file_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class Activity extends DataClass implements Insertable<Activity> {
  final int id;
  final String title;
  final String activityType;
  final DateTime startTime;
  final DateTime endTime;
  final double distanceKm;
  final int durationSeconds;
  final int movingTimeSeconds;
  final double avgPaceSecondsPerKm;
  final double maxPaceSecondsPerKm;
  final double avgSpeedKmh;
  final double maxSpeedKmh;
  final double elevationGainMeters;
  final double caloriesBurned;
  final int? shoeId;
  final String splitPacesJson;
  final String? gpxFilePath;
  final DateTime createdAt;
  const Activity(
      {required this.id,
      required this.title,
      required this.activityType,
      required this.startTime,
      required this.endTime,
      required this.distanceKm,
      required this.durationSeconds,
      required this.movingTimeSeconds,
      required this.avgPaceSecondsPerKm,
      required this.maxPaceSecondsPerKm,
      required this.avgSpeedKmh,
      required this.maxSpeedKmh,
      required this.elevationGainMeters,
      required this.caloriesBurned,
      this.shoeId,
      required this.splitPacesJson,
      this.gpxFilePath,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['activity_type'] = Variable<String>(activityType);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    map['distance_km'] = Variable<double>(distanceKm);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['moving_time_seconds'] = Variable<int>(movingTimeSeconds);
    map['avg_pace_seconds_per_km'] = Variable<double>(avgPaceSecondsPerKm);
    map['max_pace_seconds_per_km'] = Variable<double>(maxPaceSecondsPerKm);
    map['avg_speed_kmh'] = Variable<double>(avgSpeedKmh);
    map['max_speed_kmh'] = Variable<double>(maxSpeedKmh);
    map['elevation_gain_meters'] = Variable<double>(elevationGainMeters);
    map['calories_burned'] = Variable<double>(caloriesBurned);
    if (!nullToAbsent || shoeId != null) {
      map['shoe_id'] = Variable<int>(shoeId);
    }
    map['split_paces_json'] = Variable<String>(splitPacesJson);
    if (!nullToAbsent || gpxFilePath != null) {
      map['gpx_file_path'] = Variable<String>(gpxFilePath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      title: Value(title),
      activityType: Value(activityType),
      startTime: Value(startTime),
      endTime: Value(endTime),
      distanceKm: Value(distanceKm),
      durationSeconds: Value(durationSeconds),
      movingTimeSeconds: Value(movingTimeSeconds),
      avgPaceSecondsPerKm: Value(avgPaceSecondsPerKm),
      maxPaceSecondsPerKm: Value(maxPaceSecondsPerKm),
      avgSpeedKmh: Value(avgSpeedKmh),
      maxSpeedKmh: Value(maxSpeedKmh),
      elevationGainMeters: Value(elevationGainMeters),
      caloriesBurned: Value(caloriesBurned),
      shoeId:
          shoeId == null && nullToAbsent ? const Value.absent() : Value(shoeId),
      splitPacesJson: Value(splitPacesJson),
      gpxFilePath: gpxFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(gpxFilePath),
      createdAt: Value(createdAt),
    );
  }

  factory Activity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      activityType: serializer.fromJson<String>(json['activityType']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      distanceKm: serializer.fromJson<double>(json['distanceKm']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      movingTimeSeconds: serializer.fromJson<int>(json['movingTimeSeconds']),
      avgPaceSecondsPerKm:
          serializer.fromJson<double>(json['avgPaceSecondsPerKm']),
      maxPaceSecondsPerKm:
          serializer.fromJson<double>(json['maxPaceSecondsPerKm']),
      avgSpeedKmh: serializer.fromJson<double>(json['avgSpeedKmh']),
      maxSpeedKmh: serializer.fromJson<double>(json['maxSpeedKmh']),
      elevationGainMeters:
          serializer.fromJson<double>(json['elevationGainMeters']),
      caloriesBurned: serializer.fromJson<double>(json['caloriesBurned']),
      shoeId: serializer.fromJson<int?>(json['shoeId']),
      splitPacesJson: serializer.fromJson<String>(json['splitPacesJson']),
      gpxFilePath: serializer.fromJson<String?>(json['gpxFilePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'activityType': serializer.toJson<String>(activityType),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'distanceKm': serializer.toJson<double>(distanceKm),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'movingTimeSeconds': serializer.toJson<int>(movingTimeSeconds),
      'avgPaceSecondsPerKm': serializer.toJson<double>(avgPaceSecondsPerKm),
      'maxPaceSecondsPerKm': serializer.toJson<double>(maxPaceSecondsPerKm),
      'avgSpeedKmh': serializer.toJson<double>(avgSpeedKmh),
      'maxSpeedKmh': serializer.toJson<double>(maxSpeedKmh),
      'elevationGainMeters': serializer.toJson<double>(elevationGainMeters),
      'caloriesBurned': serializer.toJson<double>(caloriesBurned),
      'shoeId': serializer.toJson<int?>(shoeId),
      'splitPacesJson': serializer.toJson<String>(splitPacesJson),
      'gpxFilePath': serializer.toJson<String?>(gpxFilePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Activity copyWith(
          {int? id,
          String? title,
          String? activityType,
          DateTime? startTime,
          DateTime? endTime,
          double? distanceKm,
          int? durationSeconds,
          int? movingTimeSeconds,
          double? avgPaceSecondsPerKm,
          double? maxPaceSecondsPerKm,
          double? avgSpeedKmh,
          double? maxSpeedKmh,
          double? elevationGainMeters,
          double? caloriesBurned,
          Value<int?> shoeId = const Value.absent(),
          String? splitPacesJson,
          Value<String?> gpxFilePath = const Value.absent(),
          DateTime? createdAt}) =>
      Activity(
        id: id ?? this.id,
        title: title ?? this.title,
        activityType: activityType ?? this.activityType,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        distanceKm: distanceKm ?? this.distanceKm,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        movingTimeSeconds: movingTimeSeconds ?? this.movingTimeSeconds,
        avgPaceSecondsPerKm: avgPaceSecondsPerKm ?? this.avgPaceSecondsPerKm,
        maxPaceSecondsPerKm: maxPaceSecondsPerKm ?? this.maxPaceSecondsPerKm,
        avgSpeedKmh: avgSpeedKmh ?? this.avgSpeedKmh,
        maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
        elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
        caloriesBurned: caloriesBurned ?? this.caloriesBurned,
        shoeId: shoeId.present ? shoeId.value : this.shoeId,
        splitPacesJson: splitPacesJson ?? this.splitPacesJson,
        gpxFilePath: gpxFilePath.present ? gpxFilePath.value : this.gpxFilePath,
        createdAt: createdAt ?? this.createdAt,
      );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      distanceKm:
          data.distanceKm.present ? data.distanceKm.value : this.distanceKm,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      movingTimeSeconds: data.movingTimeSeconds.present
          ? data.movingTimeSeconds.value
          : this.movingTimeSeconds,
      avgPaceSecondsPerKm: data.avgPaceSecondsPerKm.present
          ? data.avgPaceSecondsPerKm.value
          : this.avgPaceSecondsPerKm,
      maxPaceSecondsPerKm: data.maxPaceSecondsPerKm.present
          ? data.maxPaceSecondsPerKm.value
          : this.maxPaceSecondsPerKm,
      avgSpeedKmh:
          data.avgSpeedKmh.present ? data.avgSpeedKmh.value : this.avgSpeedKmh,
      maxSpeedKmh:
          data.maxSpeedKmh.present ? data.maxSpeedKmh.value : this.maxSpeedKmh,
      elevationGainMeters: data.elevationGainMeters.present
          ? data.elevationGainMeters.value
          : this.elevationGainMeters,
      caloriesBurned: data.caloriesBurned.present
          ? data.caloriesBurned.value
          : this.caloriesBurned,
      shoeId: data.shoeId.present ? data.shoeId.value : this.shoeId,
      splitPacesJson: data.splitPacesJson.present
          ? data.splitPacesJson.value
          : this.splitPacesJson,
      gpxFilePath:
          data.gpxFilePath.present ? data.gpxFilePath.value : this.gpxFilePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('activityType: $activityType, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('movingTimeSeconds: $movingTimeSeconds, ')
          ..write('avgPaceSecondsPerKm: $avgPaceSecondsPerKm, ')
          ..write('maxPaceSecondsPerKm: $maxPaceSecondsPerKm, ')
          ..write('avgSpeedKmh: $avgSpeedKmh, ')
          ..write('maxSpeedKmh: $maxSpeedKmh, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('caloriesBurned: $caloriesBurned, ')
          ..write('shoeId: $shoeId, ')
          ..write('splitPacesJson: $splitPacesJson, ')
          ..write('gpxFilePath: $gpxFilePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      activityType,
      startTime,
      endTime,
      distanceKm,
      durationSeconds,
      movingTimeSeconds,
      avgPaceSecondsPerKm,
      maxPaceSecondsPerKm,
      avgSpeedKmh,
      maxSpeedKmh,
      elevationGainMeters,
      caloriesBurned,
      shoeId,
      splitPacesJson,
      gpxFilePath,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.title == this.title &&
          other.activityType == this.activityType &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.distanceKm == this.distanceKm &&
          other.durationSeconds == this.durationSeconds &&
          other.movingTimeSeconds == this.movingTimeSeconds &&
          other.avgPaceSecondsPerKm == this.avgPaceSecondsPerKm &&
          other.maxPaceSecondsPerKm == this.maxPaceSecondsPerKm &&
          other.avgSpeedKmh == this.avgSpeedKmh &&
          other.maxSpeedKmh == this.maxSpeedKmh &&
          other.elevationGainMeters == this.elevationGainMeters &&
          other.caloriesBurned == this.caloriesBurned &&
          other.shoeId == this.shoeId &&
          other.splitPacesJson == this.splitPacesJson &&
          other.gpxFilePath == this.gpxFilePath &&
          other.createdAt == this.createdAt);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> activityType;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<double> distanceKm;
  final Value<int> durationSeconds;
  final Value<int> movingTimeSeconds;
  final Value<double> avgPaceSecondsPerKm;
  final Value<double> maxPaceSecondsPerKm;
  final Value<double> avgSpeedKmh;
  final Value<double> maxSpeedKmh;
  final Value<double> elevationGainMeters;
  final Value<double> caloriesBurned;
  final Value<int?> shoeId;
  final Value<String> splitPacesJson;
  final Value<String?> gpxFilePath;
  final Value<DateTime> createdAt;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.activityType = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.movingTimeSeconds = const Value.absent(),
    this.avgPaceSecondsPerKm = const Value.absent(),
    this.maxPaceSecondsPerKm = const Value.absent(),
    this.avgSpeedKmh = const Value.absent(),
    this.maxSpeedKmh = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    this.caloriesBurned = const Value.absent(),
    this.shoeId = const Value.absent(),
    this.splitPacesJson = const Value.absent(),
    this.gpxFilePath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.activityType = const Value.absent(),
    required DateTime startTime,
    required DateTime endTime,
    required double distanceKm,
    required int durationSeconds,
    required int movingTimeSeconds,
    required double avgPaceSecondsPerKm,
    this.maxPaceSecondsPerKm = const Value.absent(),
    this.avgSpeedKmh = const Value.absent(),
    this.maxSpeedKmh = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    this.caloriesBurned = const Value.absent(),
    this.shoeId = const Value.absent(),
    this.splitPacesJson = const Value.absent(),
    this.gpxFilePath = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : title = Value(title),
        startTime = Value(startTime),
        endTime = Value(endTime),
        distanceKm = Value(distanceKm),
        durationSeconds = Value(durationSeconds),
        movingTimeSeconds = Value(movingTimeSeconds),
        avgPaceSecondsPerKm = Value(avgPaceSecondsPerKm);
  static Insertable<Activity> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? activityType,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<double>? distanceKm,
    Expression<int>? durationSeconds,
    Expression<int>? movingTimeSeconds,
    Expression<double>? avgPaceSecondsPerKm,
    Expression<double>? maxPaceSecondsPerKm,
    Expression<double>? avgSpeedKmh,
    Expression<double>? maxSpeedKmh,
    Expression<double>? elevationGainMeters,
    Expression<double>? caloriesBurned,
    Expression<int>? shoeId,
    Expression<String>? splitPacesJson,
    Expression<String>? gpxFilePath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (activityType != null) 'activity_type': activityType,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (movingTimeSeconds != null) 'moving_time_seconds': movingTimeSeconds,
      if (avgPaceSecondsPerKm != null)
        'avg_pace_seconds_per_km': avgPaceSecondsPerKm,
      if (maxPaceSecondsPerKm != null)
        'max_pace_seconds_per_km': maxPaceSecondsPerKm,
      if (avgSpeedKmh != null) 'avg_speed_kmh': avgSpeedKmh,
      if (maxSpeedKmh != null) 'max_speed_kmh': maxSpeedKmh,
      if (elevationGainMeters != null)
        'elevation_gain_meters': elevationGainMeters,
      if (caloriesBurned != null) 'calories_burned': caloriesBurned,
      if (shoeId != null) 'shoe_id': shoeId,
      if (splitPacesJson != null) 'split_paces_json': splitPacesJson,
      if (gpxFilePath != null) 'gpx_file_path': gpxFilePath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ActivitiesCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? activityType,
      Value<DateTime>? startTime,
      Value<DateTime>? endTime,
      Value<double>? distanceKm,
      Value<int>? durationSeconds,
      Value<int>? movingTimeSeconds,
      Value<double>? avgPaceSecondsPerKm,
      Value<double>? maxPaceSecondsPerKm,
      Value<double>? avgSpeedKmh,
      Value<double>? maxSpeedKmh,
      Value<double>? elevationGainMeters,
      Value<double>? caloriesBurned,
      Value<int?>? shoeId,
      Value<String>? splitPacesJson,
      Value<String?>? gpxFilePath,
      Value<DateTime>? createdAt}) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      activityType: activityType ?? this.activityType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distanceKm: distanceKm ?? this.distanceKm,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      movingTimeSeconds: movingTimeSeconds ?? this.movingTimeSeconds,
      avgPaceSecondsPerKm: avgPaceSecondsPerKm ?? this.avgPaceSecondsPerKm,
      maxPaceSecondsPerKm: maxPaceSecondsPerKm ?? this.maxPaceSecondsPerKm,
      avgSpeedKmh: avgSpeedKmh ?? this.avgSpeedKmh,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      shoeId: shoeId ?? this.shoeId,
      splitPacesJson: splitPacesJson ?? this.splitPacesJson,
      gpxFilePath: gpxFilePath ?? this.gpxFilePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(activityType.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<double>(distanceKm.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (movingTimeSeconds.present) {
      map['moving_time_seconds'] = Variable<int>(movingTimeSeconds.value);
    }
    if (avgPaceSecondsPerKm.present) {
      map['avg_pace_seconds_per_km'] =
          Variable<double>(avgPaceSecondsPerKm.value);
    }
    if (maxPaceSecondsPerKm.present) {
      map['max_pace_seconds_per_km'] =
          Variable<double>(maxPaceSecondsPerKm.value);
    }
    if (avgSpeedKmh.present) {
      map['avg_speed_kmh'] = Variable<double>(avgSpeedKmh.value);
    }
    if (maxSpeedKmh.present) {
      map['max_speed_kmh'] = Variable<double>(maxSpeedKmh.value);
    }
    if (elevationGainMeters.present) {
      map['elevation_gain_meters'] =
          Variable<double>(elevationGainMeters.value);
    }
    if (caloriesBurned.present) {
      map['calories_burned'] = Variable<double>(caloriesBurned.value);
    }
    if (shoeId.present) {
      map['shoe_id'] = Variable<int>(shoeId.value);
    }
    if (splitPacesJson.present) {
      map['split_paces_json'] = Variable<String>(splitPacesJson.value);
    }
    if (gpxFilePath.present) {
      map['gpx_file_path'] = Variable<String>(gpxFilePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('activityType: $activityType, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('movingTimeSeconds: $movingTimeSeconds, ')
          ..write('avgPaceSecondsPerKm: $avgPaceSecondsPerKm, ')
          ..write('maxPaceSecondsPerKm: $maxPaceSecondsPerKm, ')
          ..write('avgSpeedKmh: $avgSpeedKmh, ')
          ..write('maxSpeedKmh: $maxSpeedKmh, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('caloriesBurned: $caloriesBurned, ')
          ..write('shoeId: $shoeId, ')
          ..write('splitPacesJson: $splitPacesJson, ')
          ..write('gpxFilePath: $gpxFilePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TrackPointsTable extends TrackPoints
    with TableInfo<$TrackPointsTable, TrackPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _activityIdMeta =
      const VerificationMeta('activityId');
  @override
  late final GeneratedColumn<int> activityId = GeneratedColumn<int>(
      'activity_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES activities (id) ON DELETE CASCADE'));
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _altitudeMeta =
      const VerificationMeta('altitude');
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
      'altitude', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
      'speed', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _accuracyMeta =
      const VerificationMeta('accuracy');
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
      'accuracy', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isPausedPointMeta =
      const VerificationMeta('isPausedPoint');
  @override
  late final GeneratedColumn<bool> isPausedPoint = GeneratedColumn<bool>(
      'is_paused_point', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_paused_point" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        activityId,
        latitude,
        longitude,
        altitude,
        speed,
        accuracy,
        timestamp,
        isPausedPoint
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_points';
  @override
  VerificationContext validateIntegrity(Insertable<TrackPoint> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('activity_id')) {
      context.handle(
          _activityIdMeta,
          activityId.isAcceptableOrUnknown(
              data['activity_id']!, _activityIdMeta));
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(_altitudeMeta,
          altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta));
    }
    if (data.containsKey('speed')) {
      context.handle(
          _speedMeta, speed.isAcceptableOrUnknown(data['speed']!, _speedMeta));
    }
    if (data.containsKey('accuracy')) {
      context.handle(_accuracyMeta,
          accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('is_paused_point')) {
      context.handle(
          _isPausedPointMeta,
          isPausedPoint.isAcceptableOrUnknown(
              data['is_paused_point']!, _isPausedPointMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackPoint(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      activityId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}activity_id'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      altitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}altitude'])!,
      speed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}speed'])!,
      accuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      isPausedPoint: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_paused_point'])!,
    );
  }

  @override
  $TrackPointsTable createAlias(String alias) {
    return $TrackPointsTable(attachedDatabase, alias);
  }
}

class TrackPoint extends DataClass implements Insertable<TrackPoint> {
  final int id;
  final int activityId;
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final double accuracy;
  final DateTime timestamp;
  final bool isPausedPoint;
  const TrackPoint(
      {required this.id,
      required this.activityId,
      required this.latitude,
      required this.longitude,
      required this.altitude,
      required this.speed,
      required this.accuracy,
      required this.timestamp,
      required this.isPausedPoint});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['activity_id'] = Variable<int>(activityId);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['altitude'] = Variable<double>(altitude);
    map['speed'] = Variable<double>(speed);
    map['accuracy'] = Variable<double>(accuracy);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_paused_point'] = Variable<bool>(isPausedPoint);
    return map;
  }

  TrackPointsCompanion toCompanion(bool nullToAbsent) {
    return TrackPointsCompanion(
      id: Value(id),
      activityId: Value(activityId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitude: Value(altitude),
      speed: Value(speed),
      accuracy: Value(accuracy),
      timestamp: Value(timestamp),
      isPausedPoint: Value(isPausedPoint),
    );
  }

  factory TrackPoint.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackPoint(
      id: serializer.fromJson<int>(json['id']),
      activityId: serializer.fromJson<int>(json['activityId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitude: serializer.fromJson<double>(json['altitude']),
      speed: serializer.fromJson<double>(json['speed']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isPausedPoint: serializer.fromJson<bool>(json['isPausedPoint']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'activityId': serializer.toJson<int>(activityId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitude': serializer.toJson<double>(altitude),
      'speed': serializer.toJson<double>(speed),
      'accuracy': serializer.toJson<double>(accuracy),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isPausedPoint': serializer.toJson<bool>(isPausedPoint),
    };
  }

  TrackPoint copyWith(
          {int? id,
          int? activityId,
          double? latitude,
          double? longitude,
          double? altitude,
          double? speed,
          double? accuracy,
          DateTime? timestamp,
          bool? isPausedPoint}) =>
      TrackPoint(
        id: id ?? this.id,
        activityId: activityId ?? this.activityId,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        altitude: altitude ?? this.altitude,
        speed: speed ?? this.speed,
        accuracy: accuracy ?? this.accuracy,
        timestamp: timestamp ?? this.timestamp,
        isPausedPoint: isPausedPoint ?? this.isPausedPoint,
      );
  TrackPoint copyWithCompanion(TrackPointsCompanion data) {
    return TrackPoint(
      id: data.id.present ? data.id.value : this.id,
      activityId:
          data.activityId.present ? data.activityId.value : this.activityId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      speed: data.speed.present ? data.speed.value : this.speed,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isPausedPoint: data.isPausedPoint.present
          ? data.isPausedPoint.value
          : this.isPausedPoint,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackPoint(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('speed: $speed, ')
          ..write('accuracy: $accuracy, ')
          ..write('timestamp: $timestamp, ')
          ..write('isPausedPoint: $isPausedPoint')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, activityId, latitude, longitude, altitude,
      speed, accuracy, timestamp, isPausedPoint);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackPoint &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitude == this.altitude &&
          other.speed == this.speed &&
          other.accuracy == this.accuracy &&
          other.timestamp == this.timestamp &&
          other.isPausedPoint == this.isPausedPoint);
}

class TrackPointsCompanion extends UpdateCompanion<TrackPoint> {
  final Value<int> id;
  final Value<int> activityId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> altitude;
  final Value<double> speed;
  final Value<double> accuracy;
  final Value<DateTime> timestamp;
  final Value<bool> isPausedPoint;
  const TrackPointsCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitude = const Value.absent(),
    this.speed = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isPausedPoint = const Value.absent(),
  });
  TrackPointsCompanion.insert({
    this.id = const Value.absent(),
    required int activityId,
    required double latitude,
    required double longitude,
    this.altitude = const Value.absent(),
    this.speed = const Value.absent(),
    this.accuracy = const Value.absent(),
    required DateTime timestamp,
    this.isPausedPoint = const Value.absent(),
  })  : activityId = Value(activityId),
        latitude = Value(latitude),
        longitude = Value(longitude),
        timestamp = Value(timestamp);
  static Insertable<TrackPoint> custom({
    Expression<int>? id,
    Expression<int>? activityId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitude,
    Expression<double>? speed,
    Expression<double>? accuracy,
    Expression<DateTime>? timestamp,
    Expression<bool>? isPausedPoint,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (speed != null) 'speed': speed,
      if (accuracy != null) 'accuracy': accuracy,
      if (timestamp != null) 'timestamp': timestamp,
      if (isPausedPoint != null) 'is_paused_point': isPausedPoint,
    });
  }

  TrackPointsCompanion copyWith(
      {Value<int>? id,
      Value<int>? activityId,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<double>? altitude,
      Value<double>? speed,
      Value<double>? accuracy,
      Value<DateTime>? timestamp,
      Value<bool>? isPausedPoint}) {
    return TrackPointsCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      isPausedPoint: isPausedPoint ?? this.isPausedPoint,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<int>(activityId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isPausedPoint.present) {
      map['is_paused_point'] = Variable<bool>(isPausedPoint.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackPointsCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('speed: $speed, ')
          ..write('accuracy: $accuracy, ')
          ..write('timestamp: $timestamp, ')
          ..write('isPausedPoint: $isPausedPoint')
          ..write(')'))
        .toString();
  }
}

abstract class _$StrydeDatabase extends GeneratedDatabase {
  _$StrydeDatabase(QueryExecutor e) : super(e);
  $StrydeDatabaseManager get managers => $StrydeDatabaseManager(this);
  late final $ShoesTable shoes = $ShoesTable(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $TrackPointsTable trackPoints = $TrackPointsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [shoes, activities, trackPoints];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('shoes',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('activities', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('activities',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('track_points', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$ShoesTableCreateCompanionBuilder = ShoesCompanion Function({
  Value<int> id,
  required String brand,
  required String model,
  Value<String?> nickname,
  Value<double> totalDistanceKm,
  Value<double> maxDistanceKm,
  Value<bool> isRetired,
  Value<bool> isDefault,
  Value<DateTime> createdAt,
});
typedef $$ShoesTableUpdateCompanionBuilder = ShoesCompanion Function({
  Value<int> id,
  Value<String> brand,
  Value<String> model,
  Value<String?> nickname,
  Value<double> totalDistanceKm,
  Value<double> maxDistanceKm,
  Value<bool> isRetired,
  Value<bool> isDefault,
  Value<DateTime> createdAt,
});

class $$ShoesTableTableManager extends RootTableManager<
    _$StrydeDatabase,
    $ShoesTable,
    Shoe,
    $$ShoesTableFilterComposer,
    $$ShoesTableOrderingComposer,
    $$ShoesTableCreateCompanionBuilder,
    $$ShoesTableUpdateCompanionBuilder> {
  $$ShoesTableTableManager(_$StrydeDatabase db, $ShoesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ShoesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ShoesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> brand = const Value.absent(),
            Value<String> model = const Value.absent(),
            Value<String?> nickname = const Value.absent(),
            Value<double> totalDistanceKm = const Value.absent(),
            Value<double> maxDistanceKm = const Value.absent(),
            Value<bool> isRetired = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ShoesCompanion(
            id: id,
            brand: brand,
            model: model,
            nickname: nickname,
            totalDistanceKm: totalDistanceKm,
            maxDistanceKm: maxDistanceKm,
            isRetired: isRetired,
            isDefault: isDefault,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String brand,
            required String model,
            Value<String?> nickname = const Value.absent(),
            Value<double> totalDistanceKm = const Value.absent(),
            Value<double> maxDistanceKm = const Value.absent(),
            Value<bool> isRetired = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ShoesCompanion.insert(
            id: id,
            brand: brand,
            model: model,
            nickname: nickname,
            totalDistanceKm: totalDistanceKm,
            maxDistanceKm: maxDistanceKm,
            isRetired: isRetired,
            isDefault: isDefault,
            createdAt: createdAt,
          ),
        ));
}

class $$ShoesTableFilterComposer
    extends FilterComposer<_$StrydeDatabase, $ShoesTable> {
  $$ShoesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get brand => $state.composableBuilder(
      column: $state.table.brand,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get model => $state.composableBuilder(
      column: $state.table.model,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nickname => $state.composableBuilder(
      column: $state.table.nickname,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get totalDistanceKm => $state.composableBuilder(
      column: $state.table.totalDistanceKm,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get maxDistanceKm => $state.composableBuilder(
      column: $state.table.maxDistanceKm,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isRetired => $state.composableBuilder(
      column: $state.table.isRetired,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter activitiesRefs(
      ComposableFilter Function($$ActivitiesTableFilterComposer f) f) {
    final $$ActivitiesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.activities,
        getReferencedColumn: (t) => t.shoeId,
        builder: (joinBuilder, parentComposers) =>
            $$ActivitiesTableFilterComposer(ComposerState($state.db,
                $state.db.activities, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ShoesTableOrderingComposer
    extends OrderingComposer<_$StrydeDatabase, $ShoesTable> {
  $$ShoesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get brand => $state.composableBuilder(
      column: $state.table.brand,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get model => $state.composableBuilder(
      column: $state.table.model,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nickname => $state.composableBuilder(
      column: $state.table.nickname,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get totalDistanceKm => $state.composableBuilder(
      column: $state.table.totalDistanceKm,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get maxDistanceKm => $state.composableBuilder(
      column: $state.table.maxDistanceKm,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isRetired => $state.composableBuilder(
      column: $state.table.isRetired,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ActivitiesTableCreateCompanionBuilder = ActivitiesCompanion Function({
  Value<int> id,
  required String title,
  Value<String> activityType,
  required DateTime startTime,
  required DateTime endTime,
  required double distanceKm,
  required int durationSeconds,
  required int movingTimeSeconds,
  required double avgPaceSecondsPerKm,
  Value<double> maxPaceSecondsPerKm,
  Value<double> avgSpeedKmh,
  Value<double> maxSpeedKmh,
  Value<double> elevationGainMeters,
  Value<double> caloriesBurned,
  Value<int?> shoeId,
  Value<String> splitPacesJson,
  Value<String?> gpxFilePath,
  Value<DateTime> createdAt,
});
typedef $$ActivitiesTableUpdateCompanionBuilder = ActivitiesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> activityType,
  Value<DateTime> startTime,
  Value<DateTime> endTime,
  Value<double> distanceKm,
  Value<int> durationSeconds,
  Value<int> movingTimeSeconds,
  Value<double> avgPaceSecondsPerKm,
  Value<double> maxPaceSecondsPerKm,
  Value<double> avgSpeedKmh,
  Value<double> maxSpeedKmh,
  Value<double> elevationGainMeters,
  Value<double> caloriesBurned,
  Value<int?> shoeId,
  Value<String> splitPacesJson,
  Value<String?> gpxFilePath,
  Value<DateTime> createdAt,
});

class $$ActivitiesTableTableManager extends RootTableManager<
    _$StrydeDatabase,
    $ActivitiesTable,
    Activity,
    $$ActivitiesTableFilterComposer,
    $$ActivitiesTableOrderingComposer,
    $$ActivitiesTableCreateCompanionBuilder,
    $$ActivitiesTableUpdateCompanionBuilder> {
  $$ActivitiesTableTableManager(_$StrydeDatabase db, $ActivitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ActivitiesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ActivitiesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> activityType = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime> endTime = const Value.absent(),
            Value<double> distanceKm = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<int> movingTimeSeconds = const Value.absent(),
            Value<double> avgPaceSecondsPerKm = const Value.absent(),
            Value<double> maxPaceSecondsPerKm = const Value.absent(),
            Value<double> avgSpeedKmh = const Value.absent(),
            Value<double> maxSpeedKmh = const Value.absent(),
            Value<double> elevationGainMeters = const Value.absent(),
            Value<double> caloriesBurned = const Value.absent(),
            Value<int?> shoeId = const Value.absent(),
            Value<String> splitPacesJson = const Value.absent(),
            Value<String?> gpxFilePath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ActivitiesCompanion(
            id: id,
            title: title,
            activityType: activityType,
            startTime: startTime,
            endTime: endTime,
            distanceKm: distanceKm,
            durationSeconds: durationSeconds,
            movingTimeSeconds: movingTimeSeconds,
            avgPaceSecondsPerKm: avgPaceSecondsPerKm,
            maxPaceSecondsPerKm: maxPaceSecondsPerKm,
            avgSpeedKmh: avgSpeedKmh,
            maxSpeedKmh: maxSpeedKmh,
            elevationGainMeters: elevationGainMeters,
            caloriesBurned: caloriesBurned,
            shoeId: shoeId,
            splitPacesJson: splitPacesJson,
            gpxFilePath: gpxFilePath,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String> activityType = const Value.absent(),
            required DateTime startTime,
            required DateTime endTime,
            required double distanceKm,
            required int durationSeconds,
            required int movingTimeSeconds,
            required double avgPaceSecondsPerKm,
            Value<double> maxPaceSecondsPerKm = const Value.absent(),
            Value<double> avgSpeedKmh = const Value.absent(),
            Value<double> maxSpeedKmh = const Value.absent(),
            Value<double> elevationGainMeters = const Value.absent(),
            Value<double> caloriesBurned = const Value.absent(),
            Value<int?> shoeId = const Value.absent(),
            Value<String> splitPacesJson = const Value.absent(),
            Value<String?> gpxFilePath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ActivitiesCompanion.insert(
            id: id,
            title: title,
            activityType: activityType,
            startTime: startTime,
            endTime: endTime,
            distanceKm: distanceKm,
            durationSeconds: durationSeconds,
            movingTimeSeconds: movingTimeSeconds,
            avgPaceSecondsPerKm: avgPaceSecondsPerKm,
            maxPaceSecondsPerKm: maxPaceSecondsPerKm,
            avgSpeedKmh: avgSpeedKmh,
            maxSpeedKmh: maxSpeedKmh,
            elevationGainMeters: elevationGainMeters,
            caloriesBurned: caloriesBurned,
            shoeId: shoeId,
            splitPacesJson: splitPacesJson,
            gpxFilePath: gpxFilePath,
            createdAt: createdAt,
          ),
        ));
}

class $$ActivitiesTableFilterComposer
    extends FilterComposer<_$StrydeDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get activityType => $state.composableBuilder(
      column: $state.table.activityType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get startTime => $state.composableBuilder(
      column: $state.table.startTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get endTime => $state.composableBuilder(
      column: $state.table.endTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get distanceKm => $state.composableBuilder(
      column: $state.table.distanceKm,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get durationSeconds => $state.composableBuilder(
      column: $state.table.durationSeconds,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get movingTimeSeconds => $state.composableBuilder(
      column: $state.table.movingTimeSeconds,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get avgPaceSecondsPerKm => $state.composableBuilder(
      column: $state.table.avgPaceSecondsPerKm,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get maxPaceSecondsPerKm => $state.composableBuilder(
      column: $state.table.maxPaceSecondsPerKm,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get avgSpeedKmh => $state.composableBuilder(
      column: $state.table.avgSpeedKmh,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get maxSpeedKmh => $state.composableBuilder(
      column: $state.table.maxSpeedKmh,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get elevationGainMeters => $state.composableBuilder(
      column: $state.table.elevationGainMeters,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get caloriesBurned => $state.composableBuilder(
      column: $state.table.caloriesBurned,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get splitPacesJson => $state.composableBuilder(
      column: $state.table.splitPacesJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get gpxFilePath => $state.composableBuilder(
      column: $state.table.gpxFilePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ShoesTableFilterComposer get shoeId {
    final $$ShoesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shoeId,
        referencedTable: $state.db.shoes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ShoesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.shoes, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter trackPointsRefs(
      ComposableFilter Function($$TrackPointsTableFilterComposer f) f) {
    final $$TrackPointsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.trackPoints,
        getReferencedColumn: (t) => t.activityId,
        builder: (joinBuilder, parentComposers) =>
            $$TrackPointsTableFilterComposer(ComposerState($state.db,
                $state.db.trackPoints, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ActivitiesTableOrderingComposer
    extends OrderingComposer<_$StrydeDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get activityType => $state.composableBuilder(
      column: $state.table.activityType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get startTime => $state.composableBuilder(
      column: $state.table.startTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get endTime => $state.composableBuilder(
      column: $state.table.endTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get distanceKm => $state.composableBuilder(
      column: $state.table.distanceKm,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get durationSeconds => $state.composableBuilder(
      column: $state.table.durationSeconds,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get movingTimeSeconds => $state.composableBuilder(
      column: $state.table.movingTimeSeconds,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get avgPaceSecondsPerKm => $state.composableBuilder(
      column: $state.table.avgPaceSecondsPerKm,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get maxPaceSecondsPerKm => $state.composableBuilder(
      column: $state.table.maxPaceSecondsPerKm,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get avgSpeedKmh => $state.composableBuilder(
      column: $state.table.avgSpeedKmh,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get maxSpeedKmh => $state.composableBuilder(
      column: $state.table.maxSpeedKmh,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get elevationGainMeters => $state.composableBuilder(
      column: $state.table.elevationGainMeters,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get caloriesBurned => $state.composableBuilder(
      column: $state.table.caloriesBurned,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get splitPacesJson => $state.composableBuilder(
      column: $state.table.splitPacesJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get gpxFilePath => $state.composableBuilder(
      column: $state.table.gpxFilePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ShoesTableOrderingComposer get shoeId {
    final $$ShoesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shoeId,
        referencedTable: $state.db.shoes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ShoesTableOrderingComposer(
            ComposerState(
                $state.db, $state.db.shoes, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$TrackPointsTableCreateCompanionBuilder = TrackPointsCompanion
    Function({
  Value<int> id,
  required int activityId,
  required double latitude,
  required double longitude,
  Value<double> altitude,
  Value<double> speed,
  Value<double> accuracy,
  required DateTime timestamp,
  Value<bool> isPausedPoint,
});
typedef $$TrackPointsTableUpdateCompanionBuilder = TrackPointsCompanion
    Function({
  Value<int> id,
  Value<int> activityId,
  Value<double> latitude,
  Value<double> longitude,
  Value<double> altitude,
  Value<double> speed,
  Value<double> accuracy,
  Value<DateTime> timestamp,
  Value<bool> isPausedPoint,
});

class $$TrackPointsTableTableManager extends RootTableManager<
    _$StrydeDatabase,
    $TrackPointsTable,
    TrackPoint,
    $$TrackPointsTableFilterComposer,
    $$TrackPointsTableOrderingComposer,
    $$TrackPointsTableCreateCompanionBuilder,
    $$TrackPointsTableUpdateCompanionBuilder> {
  $$TrackPointsTableTableManager(_$StrydeDatabase db, $TrackPointsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TrackPointsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TrackPointsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> activityId = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<double> altitude = const Value.absent(),
            Value<double> speed = const Value.absent(),
            Value<double> accuracy = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<bool> isPausedPoint = const Value.absent(),
          }) =>
              TrackPointsCompanion(
            id: id,
            activityId: activityId,
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            speed: speed,
            accuracy: accuracy,
            timestamp: timestamp,
            isPausedPoint: isPausedPoint,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int activityId,
            required double latitude,
            required double longitude,
            Value<double> altitude = const Value.absent(),
            Value<double> speed = const Value.absent(),
            Value<double> accuracy = const Value.absent(),
            required DateTime timestamp,
            Value<bool> isPausedPoint = const Value.absent(),
          }) =>
              TrackPointsCompanion.insert(
            id: id,
            activityId: activityId,
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            speed: speed,
            accuracy: accuracy,
            timestamp: timestamp,
            isPausedPoint: isPausedPoint,
          ),
        ));
}

class $$TrackPointsTableFilterComposer
    extends FilterComposer<_$StrydeDatabase, $TrackPointsTable> {
  $$TrackPointsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get latitude => $state.composableBuilder(
      column: $state.table.latitude,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get longitude => $state.composableBuilder(
      column: $state.table.longitude,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get altitude => $state.composableBuilder(
      column: $state.table.altitude,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get speed => $state.composableBuilder(
      column: $state.table.speed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get accuracy => $state.composableBuilder(
      column: $state.table.accuracy,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isPausedPoint => $state.composableBuilder(
      column: $state.table.isPausedPoint,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ActivitiesTableFilterComposer get activityId {
    final $$ActivitiesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityId,
        referencedTable: $state.db.activities,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ActivitiesTableFilterComposer(ComposerState($state.db,
                $state.db.activities, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$TrackPointsTableOrderingComposer
    extends OrderingComposer<_$StrydeDatabase, $TrackPointsTable> {
  $$TrackPointsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get latitude => $state.composableBuilder(
      column: $state.table.latitude,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get longitude => $state.composableBuilder(
      column: $state.table.longitude,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get altitude => $state.composableBuilder(
      column: $state.table.altitude,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get speed => $state.composableBuilder(
      column: $state.table.speed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get accuracy => $state.composableBuilder(
      column: $state.table.accuracy,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isPausedPoint => $state.composableBuilder(
      column: $state.table.isPausedPoint,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ActivitiesTableOrderingComposer get activityId {
    final $$ActivitiesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityId,
        referencedTable: $state.db.activities,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ActivitiesTableOrderingComposer(ComposerState($state.db,
                $state.db.activities, joinBuilder, parentComposers)));
    return composer;
  }
}

class $StrydeDatabaseManager {
  final _$StrydeDatabase _db;
  $StrydeDatabaseManager(this._db);
  $$ShoesTableTableManager get shoes =>
      $$ShoesTableTableManager(_db, _db.shoes);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$TrackPointsTableTableManager get trackPoints =>
      $$TrackPointsTableTableManager(_db, _db.trackPoints);
}
