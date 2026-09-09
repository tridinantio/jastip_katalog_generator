// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TripsTable extends Trips with TableInfo<$TripsTable, TripRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyNameMeta = const VerificationMeta(
    'currencyName',
  );
  @override
  late final GeneratedColumn<String> currencyName = GeneratedColumn<String>(
    'currency_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencySymbolMeta = const VerificationMeta(
    'currencySymbol',
  );
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
    'currency_symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMicrosMeta = const VerificationMeta(
    'rateMicros',
  );
  @override
  late final GeneratedColumn<int> rateMicros = GeneratedColumn<int>(
    'rate_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rateDateMeta = const VerificationMeta(
    'rateDate',
  );
  @override
  late final GeneratedColumn<DateTime> rateDate = GeneratedColumn<DateTime>(
    'rate_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rateFetchedAtMeta = const VerificationMeta(
    'rateFetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> rateFetchedAt =
      GeneratedColumn<DateTime>(
        'rate_fetched_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _markupBasisPointsMeta = const VerificationMeta(
    'markupBasisPoints',
  );
  @override
  late final GeneratedColumn<int> markupBasisPoints = GeneratedColumn<int>(
    'markup_basis_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1500),
  );
  static const VerificationMeta _fixedFeeIdrMeta = const VerificationMeta(
    'fixedFeeIdr',
  );
  @override
  late final GeneratedColumn<int> fixedFeeIdr = GeneratedColumn<int>(
    'fixed_fee_idr',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _roundingUnitIdrMeta = const VerificationMeta(
    'roundingUnitIdr',
  );
  @override
  late final GeneratedColumn<int> roundingUnitIdr = GeneratedColumn<int>(
    'rounding_unit_idr',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1000),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    country,
    currencyCode,
    currencyName,
    currencySymbol,
    rateMicros,
    rateDate,
    rateFetchedAt,
    markupBasisPoints,
    fixedFeeIdr,
    roundingUnitIdr,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('currency_name')) {
      context.handle(
        _currencyNameMeta,
        currencyName.isAcceptableOrUnknown(
          data['currency_name']!,
          _currencyNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyNameMeta);
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
        _currencySymbolMeta,
        currencySymbol.isAcceptableOrUnknown(
          data['currency_symbol']!,
          _currencySymbolMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencySymbolMeta);
    }
    if (data.containsKey('rate_micros')) {
      context.handle(
        _rateMicrosMeta,
        rateMicros.isAcceptableOrUnknown(data['rate_micros']!, _rateMicrosMeta),
      );
    }
    if (data.containsKey('rate_date')) {
      context.handle(
        _rateDateMeta,
        rateDate.isAcceptableOrUnknown(data['rate_date']!, _rateDateMeta),
      );
    }
    if (data.containsKey('rate_fetched_at')) {
      context.handle(
        _rateFetchedAtMeta,
        rateFetchedAt.isAcceptableOrUnknown(
          data['rate_fetched_at']!,
          _rateFetchedAtMeta,
        ),
      );
    }
    if (data.containsKey('markup_basis_points')) {
      context.handle(
        _markupBasisPointsMeta,
        markupBasisPoints.isAcceptableOrUnknown(
          data['markup_basis_points']!,
          _markupBasisPointsMeta,
        ),
      );
    }
    if (data.containsKey('fixed_fee_idr')) {
      context.handle(
        _fixedFeeIdrMeta,
        fixedFeeIdr.isAcceptableOrUnknown(
          data['fixed_fee_idr']!,
          _fixedFeeIdrMeta,
        ),
      );
    }
    if (data.containsKey('rounding_unit_idr')) {
      context.handle(
        _roundingUnitIdrMeta,
        roundingUnitIdr.isAcceptableOrUnknown(
          data['rounding_unit_idr']!,
          _roundingUnitIdrMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      currencyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_name'],
      )!,
      currencySymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_symbol'],
      )!,
      rateMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_micros'],
      )!,
      rateDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}rate_date'],
      ),
      rateFetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}rate_fetched_at'],
      ),
      markupBasisPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}markup_basis_points'],
      )!,
      fixedFeeIdr: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fixed_fee_idr'],
      )!,
      roundingUnitIdr: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rounding_unit_idr'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class TripRecord extends DataClass implements Insertable<TripRecord> {
  final String id;
  final String name;
  final String country;
  final String currencyCode;
  final String currencyName;
  final String currencySymbol;
  final int rateMicros;
  final DateTime? rateDate;
  final DateTime? rateFetchedAt;
  final int markupBasisPoints;
  final int fixedFeeIdr;
  final int roundingUnitIdr;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TripRecord({
    required this.id,
    required this.name,
    required this.country,
    required this.currencyCode,
    required this.currencyName,
    required this.currencySymbol,
    required this.rateMicros,
    this.rateDate,
    this.rateFetchedAt,
    required this.markupBasisPoints,
    required this.fixedFeeIdr,
    required this.roundingUnitIdr,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['country'] = Variable<String>(country);
    map['currency_code'] = Variable<String>(currencyCode);
    map['currency_name'] = Variable<String>(currencyName);
    map['currency_symbol'] = Variable<String>(currencySymbol);
    map['rate_micros'] = Variable<int>(rateMicros);
    if (!nullToAbsent || rateDate != null) {
      map['rate_date'] = Variable<DateTime>(rateDate);
    }
    if (!nullToAbsent || rateFetchedAt != null) {
      map['rate_fetched_at'] = Variable<DateTime>(rateFetchedAt);
    }
    map['markup_basis_points'] = Variable<int>(markupBasisPoints);
    map['fixed_fee_idr'] = Variable<int>(fixedFeeIdr);
    map['rounding_unit_idr'] = Variable<int>(roundingUnitIdr);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      name: Value(name),
      country: Value(country),
      currencyCode: Value(currencyCode),
      currencyName: Value(currencyName),
      currencySymbol: Value(currencySymbol),
      rateMicros: Value(rateMicros),
      rateDate: rateDate == null && nullToAbsent
          ? const Value.absent()
          : Value(rateDate),
      rateFetchedAt: rateFetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(rateFetchedAt),
      markupBasisPoints: Value(markupBasisPoints),
      fixedFeeIdr: Value(fixedFeeIdr),
      roundingUnitIdr: Value(roundingUnitIdr),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TripRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      country: serializer.fromJson<String>(json['country']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      currencyName: serializer.fromJson<String>(json['currencyName']),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      rateMicros: serializer.fromJson<int>(json['rateMicros']),
      rateDate: serializer.fromJson<DateTime?>(json['rateDate']),
      rateFetchedAt: serializer.fromJson<DateTime?>(json['rateFetchedAt']),
      markupBasisPoints: serializer.fromJson<int>(json['markupBasisPoints']),
      fixedFeeIdr: serializer.fromJson<int>(json['fixedFeeIdr']),
      roundingUnitIdr: serializer.fromJson<int>(json['roundingUnitIdr']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'country': serializer.toJson<String>(country),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'currencyName': serializer.toJson<String>(currencyName),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'rateMicros': serializer.toJson<int>(rateMicros),
      'rateDate': serializer.toJson<DateTime?>(rateDate),
      'rateFetchedAt': serializer.toJson<DateTime?>(rateFetchedAt),
      'markupBasisPoints': serializer.toJson<int>(markupBasisPoints),
      'fixedFeeIdr': serializer.toJson<int>(fixedFeeIdr),
      'roundingUnitIdr': serializer.toJson<int>(roundingUnitIdr),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TripRecord copyWith({
    String? id,
    String? name,
    String? country,
    String? currencyCode,
    String? currencyName,
    String? currencySymbol,
    int? rateMicros,
    Value<DateTime?> rateDate = const Value.absent(),
    Value<DateTime?> rateFetchedAt = const Value.absent(),
    int? markupBasisPoints,
    int? fixedFeeIdr,
    int? roundingUnitIdr,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TripRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    country: country ?? this.country,
    currencyCode: currencyCode ?? this.currencyCode,
    currencyName: currencyName ?? this.currencyName,
    currencySymbol: currencySymbol ?? this.currencySymbol,
    rateMicros: rateMicros ?? this.rateMicros,
    rateDate: rateDate.present ? rateDate.value : this.rateDate,
    rateFetchedAt: rateFetchedAt.present
        ? rateFetchedAt.value
        : this.rateFetchedAt,
    markupBasisPoints: markupBasisPoints ?? this.markupBasisPoints,
    fixedFeeIdr: fixedFeeIdr ?? this.fixedFeeIdr,
    roundingUnitIdr: roundingUnitIdr ?? this.roundingUnitIdr,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TripRecord copyWithCompanion(TripsCompanion data) {
    return TripRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      country: data.country.present ? data.country.value : this.country,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      currencyName: data.currencyName.present
          ? data.currencyName.value
          : this.currencyName,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      rateMicros: data.rateMicros.present
          ? data.rateMicros.value
          : this.rateMicros,
      rateDate: data.rateDate.present ? data.rateDate.value : this.rateDate,
      rateFetchedAt: data.rateFetchedAt.present
          ? data.rateFetchedAt.value
          : this.rateFetchedAt,
      markupBasisPoints: data.markupBasisPoints.present
          ? data.markupBasisPoints.value
          : this.markupBasisPoints,
      fixedFeeIdr: data.fixedFeeIdr.present
          ? data.fixedFeeIdr.value
          : this.fixedFeeIdr,
      roundingUnitIdr: data.roundingUnitIdr.present
          ? data.roundingUnitIdr.value
          : this.roundingUnitIdr,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('country: $country, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencyName: $currencyName, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('rateMicros: $rateMicros, ')
          ..write('rateDate: $rateDate, ')
          ..write('rateFetchedAt: $rateFetchedAt, ')
          ..write('markupBasisPoints: $markupBasisPoints, ')
          ..write('fixedFeeIdr: $fixedFeeIdr, ')
          ..write('roundingUnitIdr: $roundingUnitIdr, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    country,
    currencyCode,
    currencyName,
    currencySymbol,
    rateMicros,
    rateDate,
    rateFetchedAt,
    markupBasisPoints,
    fixedFeeIdr,
    roundingUnitIdr,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.country == this.country &&
          other.currencyCode == this.currencyCode &&
          other.currencyName == this.currencyName &&
          other.currencySymbol == this.currencySymbol &&
          other.rateMicros == this.rateMicros &&
          other.rateDate == this.rateDate &&
          other.rateFetchedAt == this.rateFetchedAt &&
          other.markupBasisPoints == this.markupBasisPoints &&
          other.fixedFeeIdr == this.fixedFeeIdr &&
          other.roundingUnitIdr == this.roundingUnitIdr &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TripsCompanion extends UpdateCompanion<TripRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> country;
  final Value<String> currencyCode;
  final Value<String> currencyName;
  final Value<String> currencySymbol;
  final Value<int> rateMicros;
  final Value<DateTime?> rateDate;
  final Value<DateTime?> rateFetchedAt;
  final Value<int> markupBasisPoints;
  final Value<int> fixedFeeIdr;
  final Value<int> roundingUnitIdr;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.country = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.currencyName = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.rateMicros = const Value.absent(),
    this.rateDate = const Value.absent(),
    this.rateFetchedAt = const Value.absent(),
    this.markupBasisPoints = const Value.absent(),
    this.fixedFeeIdr = const Value.absent(),
    this.roundingUnitIdr = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    required String name,
    this.country = const Value.absent(),
    required String currencyCode,
    required String currencyName,
    required String currencySymbol,
    this.rateMicros = const Value.absent(),
    this.rateDate = const Value.absent(),
    this.rateFetchedAt = const Value.absent(),
    this.markupBasisPoints = const Value.absent(),
    this.fixedFeeIdr = const Value.absent(),
    this.roundingUnitIdr = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       currencyCode = Value(currencyCode),
       currencyName = Value(currencyName),
       currencySymbol = Value(currencySymbol),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TripRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? country,
    Expression<String>? currencyCode,
    Expression<String>? currencyName,
    Expression<String>? currencySymbol,
    Expression<int>? rateMicros,
    Expression<DateTime>? rateDate,
    Expression<DateTime>? rateFetchedAt,
    Expression<int>? markupBasisPoints,
    Expression<int>? fixedFeeIdr,
    Expression<int>? roundingUnitIdr,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (country != null) 'country': country,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (currencyName != null) 'currency_name': currencyName,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (rateMicros != null) 'rate_micros': rateMicros,
      if (rateDate != null) 'rate_date': rateDate,
      if (rateFetchedAt != null) 'rate_fetched_at': rateFetchedAt,
      if (markupBasisPoints != null) 'markup_basis_points': markupBasisPoints,
      if (fixedFeeIdr != null) 'fixed_fee_idr': fixedFeeIdr,
      if (roundingUnitIdr != null) 'rounding_unit_idr': roundingUnitIdr,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? country,
    Value<String>? currencyCode,
    Value<String>? currencyName,
    Value<String>? currencySymbol,
    Value<int>? rateMicros,
    Value<DateTime?>? rateDate,
    Value<DateTime?>? rateFetchedAt,
    Value<int>? markupBasisPoints,
    Value<int>? fixedFeeIdr,
    Value<int>? roundingUnitIdr,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      currencyCode: currencyCode ?? this.currencyCode,
      currencyName: currencyName ?? this.currencyName,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      rateMicros: rateMicros ?? this.rateMicros,
      rateDate: rateDate ?? this.rateDate,
      rateFetchedAt: rateFetchedAt ?? this.rateFetchedAt,
      markupBasisPoints: markupBasisPoints ?? this.markupBasisPoints,
      fixedFeeIdr: fixedFeeIdr ?? this.fixedFeeIdr,
      roundingUnitIdr: roundingUnitIdr ?? this.roundingUnitIdr,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (currencyName.present) {
      map['currency_name'] = Variable<String>(currencyName.value);
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
    }
    if (rateMicros.present) {
      map['rate_micros'] = Variable<int>(rateMicros.value);
    }
    if (rateDate.present) {
      map['rate_date'] = Variable<DateTime>(rateDate.value);
    }
    if (rateFetchedAt.present) {
      map['rate_fetched_at'] = Variable<DateTime>(rateFetchedAt.value);
    }
    if (markupBasisPoints.present) {
      map['markup_basis_points'] = Variable<int>(markupBasisPoints.value);
    }
    if (fixedFeeIdr.present) {
      map['fixed_fee_idr'] = Variable<int>(fixedFeeIdr.value);
    }
    if (roundingUnitIdr.present) {
      map['rounding_unit_idr'] = Variable<int>(roundingUnitIdr.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('country: $country, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencyName: $currencyName, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('rateMicros: $rateMicros, ')
          ..write('rateDate: $rateDate, ')
          ..write('rateFetchedAt: $rateFetchedAt, ')
          ..write('markupBasisPoints: $markupBasisPoints, ')
          ..write('fixedFeeIdr: $fixedFeeIdr, ')
          ..write('roundingUnitIdr: $roundingUnitIdr, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalPriceMinorMeta =
      const VerificationMeta('originalPriceMinor');
  @override
  late final GeneratedColumn<int> originalPriceMinor = GeneratedColumn<int>(
    'original_price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sellingPriceIdrMeta = const VerificationMeta(
    'sellingPriceIdr',
  );
  @override
  late final GeneratedColumn<int> sellingPriceIdr = GeneratedColumn<int>(
    'selling_price_idr',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markupBasisPointsOverrideMeta =
      const VerificationMeta('markupBasisPointsOverride');
  @override
  late final GeneratedColumn<int> markupBasisPointsOverride =
      GeneratedColumn<int>(
        'markup_basis_points_override',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fixedFeeIdrOverrideMeta =
      const VerificationMeta('fixedFeeIdrOverride');
  @override
  late final GeneratedColumn<int> fixedFeeIdrOverride = GeneratedColumn<int>(
    'fixed_fee_idr_override',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightGramsMeta = const VerificationMeta(
    'weightGrams',
  );
  @override
  late final GeneratedColumn<int> weightGrams = GeneratedColumn<int>(
    'weight_grams',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imageBytesMeta = const VerificationMeta(
    'imageBytes',
  );
  @override
  late final GeneratedColumn<Uint8List> imageBytes = GeneratedColumn<Uint8List>(
    'image_bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailBytesMeta = const VerificationMeta(
    'thumbnailBytes',
  );
  @override
  late final GeneratedColumn<Uint8List> thumbnailBytes =
      GeneratedColumn<Uint8List>(
        'thumbnail_bytes',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _imageMimeTypeMeta = const VerificationMeta(
    'imageMimeType',
  );
  @override
  late final GeneratedColumn<String> imageMimeType = GeneratedColumn<String>(
    'image_mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationLabelMeta = const VerificationMeta(
    'locationLabel',
  );
  @override
  late final GeneratedColumn<String> locationLabel = GeneratedColumn<String>(
    'location_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationCapturedAtMeta =
      const VerificationMeta('locationCapturedAt');
  @override
  late final GeneratedColumn<DateTime> locationCapturedAt =
      GeneratedColumn<DateTime>(
        'location_captured_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    name,
    originalPriceMinor,
    sellingPriceIdr,
    markupBasisPointsOverride,
    fixedFeeIdrOverride,
    weightGrams,
    note,
    category,
    imageBytes,
    thumbnailBytes,
    imageMimeType,
    latitude,
    longitude,
    locationLabel,
    locationCapturedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('original_price_minor')) {
      context.handle(
        _originalPriceMinorMeta,
        originalPriceMinor.isAcceptableOrUnknown(
          data['original_price_minor']!,
          _originalPriceMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalPriceMinorMeta);
    }
    if (data.containsKey('selling_price_idr')) {
      context.handle(
        _sellingPriceIdrMeta,
        sellingPriceIdr.isAcceptableOrUnknown(
          data['selling_price_idr']!,
          _sellingPriceIdrMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sellingPriceIdrMeta);
    }
    if (data.containsKey('markup_basis_points_override')) {
      context.handle(
        _markupBasisPointsOverrideMeta,
        markupBasisPointsOverride.isAcceptableOrUnknown(
          data['markup_basis_points_override']!,
          _markupBasisPointsOverrideMeta,
        ),
      );
    }
    if (data.containsKey('fixed_fee_idr_override')) {
      context.handle(
        _fixedFeeIdrOverrideMeta,
        fixedFeeIdrOverride.isAcceptableOrUnknown(
          data['fixed_fee_idr_override']!,
          _fixedFeeIdrOverrideMeta,
        ),
      );
    }
    if (data.containsKey('weight_grams')) {
      context.handle(
        _weightGramsMeta,
        weightGrams.isAcceptableOrUnknown(
          data['weight_grams']!,
          _weightGramsMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('image_bytes')) {
      context.handle(
        _imageBytesMeta,
        imageBytes.isAcceptableOrUnknown(data['image_bytes']!, _imageBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_imageBytesMeta);
    }
    if (data.containsKey('thumbnail_bytes')) {
      context.handle(
        _thumbnailBytesMeta,
        thumbnailBytes.isAcceptableOrUnknown(
          data['thumbnail_bytes']!,
          _thumbnailBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_thumbnailBytesMeta);
    }
    if (data.containsKey('image_mime_type')) {
      context.handle(
        _imageMimeTypeMeta,
        imageMimeType.isAcceptableOrUnknown(
          data['image_mime_type']!,
          _imageMimeTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_imageMimeTypeMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('location_label')) {
      context.handle(
        _locationLabelMeta,
        locationLabel.isAcceptableOrUnknown(
          data['location_label']!,
          _locationLabelMeta,
        ),
      );
    }
    if (data.containsKey('location_captured_at')) {
      context.handle(
        _locationCapturedAtMeta,
        locationCapturedAt.isAcceptableOrUnknown(
          data['location_captured_at']!,
          _locationCapturedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      originalPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_price_minor'],
      )!,
      sellingPriceIdr: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selling_price_idr'],
      )!,
      markupBasisPointsOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}markup_basis_points_override'],
      ),
      fixedFeeIdrOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fixed_fee_idr_override'],
      ),
      weightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight_grams'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      imageBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}image_bytes'],
      )!,
      thumbnailBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}thumbnail_bytes'],
      )!,
      imageMimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_mime_type'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      locationLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_label'],
      ),
      locationCapturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}location_captured_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRecord extends DataClass implements Insertable<ProductRecord> {
  final String id;
  final String tripId;
  final String name;
  final int originalPriceMinor;
  final int sellingPriceIdr;
  final int? markupBasisPointsOverride;
  final int? fixedFeeIdrOverride;
  final int? weightGrams;
  final String note;
  final String category;
  final Uint8List imageBytes;
  final Uint8List thumbnailBytes;
  final String imageMimeType;
  final double? latitude;
  final double? longitude;
  final String? locationLabel;
  final DateTime? locationCapturedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProductRecord({
    required this.id,
    required this.tripId,
    required this.name,
    required this.originalPriceMinor,
    required this.sellingPriceIdr,
    this.markupBasisPointsOverride,
    this.fixedFeeIdrOverride,
    this.weightGrams,
    required this.note,
    required this.category,
    required this.imageBytes,
    required this.thumbnailBytes,
    required this.imageMimeType,
    this.latitude,
    this.longitude,
    this.locationLabel,
    this.locationCapturedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['name'] = Variable<String>(name);
    map['original_price_minor'] = Variable<int>(originalPriceMinor);
    map['selling_price_idr'] = Variable<int>(sellingPriceIdr);
    if (!nullToAbsent || markupBasisPointsOverride != null) {
      map['markup_basis_points_override'] = Variable<int>(
        markupBasisPointsOverride,
      );
    }
    if (!nullToAbsent || fixedFeeIdrOverride != null) {
      map['fixed_fee_idr_override'] = Variable<int>(fixedFeeIdrOverride);
    }
    if (!nullToAbsent || weightGrams != null) {
      map['weight_grams'] = Variable<int>(weightGrams);
    }
    map['note'] = Variable<String>(note);
    map['category'] = Variable<String>(category);
    map['image_bytes'] = Variable<Uint8List>(imageBytes);
    map['thumbnail_bytes'] = Variable<Uint8List>(thumbnailBytes);
    map['image_mime_type'] = Variable<String>(imageMimeType);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || locationLabel != null) {
      map['location_label'] = Variable<String>(locationLabel);
    }
    if (!nullToAbsent || locationCapturedAt != null) {
      map['location_captured_at'] = Variable<DateTime>(locationCapturedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      name: Value(name),
      originalPriceMinor: Value(originalPriceMinor),
      sellingPriceIdr: Value(sellingPriceIdr),
      markupBasisPointsOverride:
          markupBasisPointsOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(markupBasisPointsOverride),
      fixedFeeIdrOverride: fixedFeeIdrOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(fixedFeeIdrOverride),
      weightGrams: weightGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(weightGrams),
      note: Value(note),
      category: Value(category),
      imageBytes: Value(imageBytes),
      thumbnailBytes: Value(thumbnailBytes),
      imageMimeType: Value(imageMimeType),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      locationLabel: locationLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(locationLabel),
      locationCapturedAt: locationCapturedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(locationCapturedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProductRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRecord(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      name: serializer.fromJson<String>(json['name']),
      originalPriceMinor: serializer.fromJson<int>(json['originalPriceMinor']),
      sellingPriceIdr: serializer.fromJson<int>(json['sellingPriceIdr']),
      markupBasisPointsOverride: serializer.fromJson<int?>(
        json['markupBasisPointsOverride'],
      ),
      fixedFeeIdrOverride: serializer.fromJson<int?>(
        json['fixedFeeIdrOverride'],
      ),
      weightGrams: serializer.fromJson<int?>(json['weightGrams']),
      note: serializer.fromJson<String>(json['note']),
      category: serializer.fromJson<String>(json['category']),
      imageBytes: serializer.fromJson<Uint8List>(json['imageBytes']),
      thumbnailBytes: serializer.fromJson<Uint8List>(json['thumbnailBytes']),
      imageMimeType: serializer.fromJson<String>(json['imageMimeType']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      locationLabel: serializer.fromJson<String?>(json['locationLabel']),
      locationCapturedAt: serializer.fromJson<DateTime?>(
        json['locationCapturedAt'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'name': serializer.toJson<String>(name),
      'originalPriceMinor': serializer.toJson<int>(originalPriceMinor),
      'sellingPriceIdr': serializer.toJson<int>(sellingPriceIdr),
      'markupBasisPointsOverride': serializer.toJson<int?>(
        markupBasisPointsOverride,
      ),
      'fixedFeeIdrOverride': serializer.toJson<int?>(fixedFeeIdrOverride),
      'weightGrams': serializer.toJson<int?>(weightGrams),
      'note': serializer.toJson<String>(note),
      'category': serializer.toJson<String>(category),
      'imageBytes': serializer.toJson<Uint8List>(imageBytes),
      'thumbnailBytes': serializer.toJson<Uint8List>(thumbnailBytes),
      'imageMimeType': serializer.toJson<String>(imageMimeType),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'locationLabel': serializer.toJson<String?>(locationLabel),
      'locationCapturedAt': serializer.toJson<DateTime?>(locationCapturedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProductRecord copyWith({
    String? id,
    String? tripId,
    String? name,
    int? originalPriceMinor,
    int? sellingPriceIdr,
    Value<int?> markupBasisPointsOverride = const Value.absent(),
    Value<int?> fixedFeeIdrOverride = const Value.absent(),
    Value<int?> weightGrams = const Value.absent(),
    String? note,
    String? category,
    Uint8List? imageBytes,
    Uint8List? thumbnailBytes,
    String? imageMimeType,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> locationLabel = const Value.absent(),
    Value<DateTime?> locationCapturedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ProductRecord(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    name: name ?? this.name,
    originalPriceMinor: originalPriceMinor ?? this.originalPriceMinor,
    sellingPriceIdr: sellingPriceIdr ?? this.sellingPriceIdr,
    markupBasisPointsOverride: markupBasisPointsOverride.present
        ? markupBasisPointsOverride.value
        : this.markupBasisPointsOverride,
    fixedFeeIdrOverride: fixedFeeIdrOverride.present
        ? fixedFeeIdrOverride.value
        : this.fixedFeeIdrOverride,
    weightGrams: weightGrams.present ? weightGrams.value : this.weightGrams,
    note: note ?? this.note,
    category: category ?? this.category,
    imageBytes: imageBytes ?? this.imageBytes,
    thumbnailBytes: thumbnailBytes ?? this.thumbnailBytes,
    imageMimeType: imageMimeType ?? this.imageMimeType,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    locationLabel: locationLabel.present
        ? locationLabel.value
        : this.locationLabel,
    locationCapturedAt: locationCapturedAt.present
        ? locationCapturedAt.value
        : this.locationCapturedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProductRecord copyWithCompanion(ProductsCompanion data) {
    return ProductRecord(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      name: data.name.present ? data.name.value : this.name,
      originalPriceMinor: data.originalPriceMinor.present
          ? data.originalPriceMinor.value
          : this.originalPriceMinor,
      sellingPriceIdr: data.sellingPriceIdr.present
          ? data.sellingPriceIdr.value
          : this.sellingPriceIdr,
      markupBasisPointsOverride: data.markupBasisPointsOverride.present
          ? data.markupBasisPointsOverride.value
          : this.markupBasisPointsOverride,
      fixedFeeIdrOverride: data.fixedFeeIdrOverride.present
          ? data.fixedFeeIdrOverride.value
          : this.fixedFeeIdrOverride,
      weightGrams: data.weightGrams.present
          ? data.weightGrams.value
          : this.weightGrams,
      note: data.note.present ? data.note.value : this.note,
      category: data.category.present ? data.category.value : this.category,
      imageBytes: data.imageBytes.present
          ? data.imageBytes.value
          : this.imageBytes,
      thumbnailBytes: data.thumbnailBytes.present
          ? data.thumbnailBytes.value
          : this.thumbnailBytes,
      imageMimeType: data.imageMimeType.present
          ? data.imageMimeType.value
          : this.imageMimeType,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      locationLabel: data.locationLabel.present
          ? data.locationLabel.value
          : this.locationLabel,
      locationCapturedAt: data.locationCapturedAt.present
          ? data.locationCapturedAt.value
          : this.locationCapturedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRecord(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('originalPriceMinor: $originalPriceMinor, ')
          ..write('sellingPriceIdr: $sellingPriceIdr, ')
          ..write('markupBasisPointsOverride: $markupBasisPointsOverride, ')
          ..write('fixedFeeIdrOverride: $fixedFeeIdrOverride, ')
          ..write('weightGrams: $weightGrams, ')
          ..write('note: $note, ')
          ..write('category: $category, ')
          ..write('imageBytes: $imageBytes, ')
          ..write('thumbnailBytes: $thumbnailBytes, ')
          ..write('imageMimeType: $imageMimeType, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationLabel: $locationLabel, ')
          ..write('locationCapturedAt: $locationCapturedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    name,
    originalPriceMinor,
    sellingPriceIdr,
    markupBasisPointsOverride,
    fixedFeeIdrOverride,
    weightGrams,
    note,
    category,
    $driftBlobEquality.hash(imageBytes),
    $driftBlobEquality.hash(thumbnailBytes),
    imageMimeType,
    latitude,
    longitude,
    locationLabel,
    locationCapturedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRecord &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.name == this.name &&
          other.originalPriceMinor == this.originalPriceMinor &&
          other.sellingPriceIdr == this.sellingPriceIdr &&
          other.markupBasisPointsOverride == this.markupBasisPointsOverride &&
          other.fixedFeeIdrOverride == this.fixedFeeIdrOverride &&
          other.weightGrams == this.weightGrams &&
          other.note == this.note &&
          other.category == this.category &&
          $driftBlobEquality.equals(other.imageBytes, this.imageBytes) &&
          $driftBlobEquality.equals(
            other.thumbnailBytes,
            this.thumbnailBytes,
          ) &&
          other.imageMimeType == this.imageMimeType &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.locationLabel == this.locationLabel &&
          other.locationCapturedAt == this.locationCapturedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProductsCompanion extends UpdateCompanion<ProductRecord> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> name;
  final Value<int> originalPriceMinor;
  final Value<int> sellingPriceIdr;
  final Value<int?> markupBasisPointsOverride;
  final Value<int?> fixedFeeIdrOverride;
  final Value<int?> weightGrams;
  final Value<String> note;
  final Value<String> category;
  final Value<Uint8List> imageBytes;
  final Value<Uint8List> thumbnailBytes;
  final Value<String> imageMimeType;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> locationLabel;
  final Value<DateTime?> locationCapturedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.name = const Value.absent(),
    this.originalPriceMinor = const Value.absent(),
    this.sellingPriceIdr = const Value.absent(),
    this.markupBasisPointsOverride = const Value.absent(),
    this.fixedFeeIdrOverride = const Value.absent(),
    this.weightGrams = const Value.absent(),
    this.note = const Value.absent(),
    this.category = const Value.absent(),
    this.imageBytes = const Value.absent(),
    this.thumbnailBytes = const Value.absent(),
    this.imageMimeType = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationLabel = const Value.absent(),
    this.locationCapturedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String tripId,
    required String name,
    required int originalPriceMinor,
    required int sellingPriceIdr,
    this.markupBasisPointsOverride = const Value.absent(),
    this.fixedFeeIdrOverride = const Value.absent(),
    this.weightGrams = const Value.absent(),
    this.note = const Value.absent(),
    this.category = const Value.absent(),
    required Uint8List imageBytes,
    required Uint8List thumbnailBytes,
    required String imageMimeType,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationLabel = const Value.absent(),
    this.locationCapturedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       name = Value(name),
       originalPriceMinor = Value(originalPriceMinor),
       sellingPriceIdr = Value(sellingPriceIdr),
       imageBytes = Value(imageBytes),
       thumbnailBytes = Value(thumbnailBytes),
       imageMimeType = Value(imageMimeType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProductRecord> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? name,
    Expression<int>? originalPriceMinor,
    Expression<int>? sellingPriceIdr,
    Expression<int>? markupBasisPointsOverride,
    Expression<int>? fixedFeeIdrOverride,
    Expression<int>? weightGrams,
    Expression<String>? note,
    Expression<String>? category,
    Expression<Uint8List>? imageBytes,
    Expression<Uint8List>? thumbnailBytes,
    Expression<String>? imageMimeType,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? locationLabel,
    Expression<DateTime>? locationCapturedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (name != null) 'name': name,
      if (originalPriceMinor != null)
        'original_price_minor': originalPriceMinor,
      if (sellingPriceIdr != null) 'selling_price_idr': sellingPriceIdr,
      if (markupBasisPointsOverride != null)
        'markup_basis_points_override': markupBasisPointsOverride,
      if (fixedFeeIdrOverride != null)
        'fixed_fee_idr_override': fixedFeeIdrOverride,
      if (weightGrams != null) 'weight_grams': weightGrams,
      if (note != null) 'note': note,
      if (category != null) 'category': category,
      if (imageBytes != null) 'image_bytes': imageBytes,
      if (thumbnailBytes != null) 'thumbnail_bytes': thumbnailBytes,
      if (imageMimeType != null) 'image_mime_type': imageMimeType,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationLabel != null) 'location_label': locationLabel,
      if (locationCapturedAt != null)
        'location_captured_at': locationCapturedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? name,
    Value<int>? originalPriceMinor,
    Value<int>? sellingPriceIdr,
    Value<int?>? markupBasisPointsOverride,
    Value<int?>? fixedFeeIdrOverride,
    Value<int?>? weightGrams,
    Value<String>? note,
    Value<String>? category,
    Value<Uint8List>? imageBytes,
    Value<Uint8List>? thumbnailBytes,
    Value<String>? imageMimeType,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? locationLabel,
    Value<DateTime?>? locationCapturedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      originalPriceMinor: originalPriceMinor ?? this.originalPriceMinor,
      sellingPriceIdr: sellingPriceIdr ?? this.sellingPriceIdr,
      markupBasisPointsOverride:
          markupBasisPointsOverride ?? this.markupBasisPointsOverride,
      fixedFeeIdrOverride: fixedFeeIdrOverride ?? this.fixedFeeIdrOverride,
      weightGrams: weightGrams ?? this.weightGrams,
      note: note ?? this.note,
      category: category ?? this.category,
      imageBytes: imageBytes ?? this.imageBytes,
      thumbnailBytes: thumbnailBytes ?? this.thumbnailBytes,
      imageMimeType: imageMimeType ?? this.imageMimeType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationLabel: locationLabel ?? this.locationLabel,
      locationCapturedAt: locationCapturedAt ?? this.locationCapturedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (originalPriceMinor.present) {
      map['original_price_minor'] = Variable<int>(originalPriceMinor.value);
    }
    if (sellingPriceIdr.present) {
      map['selling_price_idr'] = Variable<int>(sellingPriceIdr.value);
    }
    if (markupBasisPointsOverride.present) {
      map['markup_basis_points_override'] = Variable<int>(
        markupBasisPointsOverride.value,
      );
    }
    if (fixedFeeIdrOverride.present) {
      map['fixed_fee_idr_override'] = Variable<int>(fixedFeeIdrOverride.value);
    }
    if (weightGrams.present) {
      map['weight_grams'] = Variable<int>(weightGrams.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (imageBytes.present) {
      map['image_bytes'] = Variable<Uint8List>(imageBytes.value);
    }
    if (thumbnailBytes.present) {
      map['thumbnail_bytes'] = Variable<Uint8List>(thumbnailBytes.value);
    }
    if (imageMimeType.present) {
      map['image_mime_type'] = Variable<String>(imageMimeType.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (locationLabel.present) {
      map['location_label'] = Variable<String>(locationLabel.value);
    }
    if (locationCapturedAt.present) {
      map['location_captured_at'] = Variable<DateTime>(
        locationCapturedAt.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('originalPriceMinor: $originalPriceMinor, ')
          ..write('sellingPriceIdr: $sellingPriceIdr, ')
          ..write('markupBasisPointsOverride: $markupBasisPointsOverride, ')
          ..write('fixedFeeIdrOverride: $fixedFeeIdrOverride, ')
          ..write('weightGrams: $weightGrams, ')
          ..write('note: $note, ')
          ..write('category: $category, ')
          ..write('imageBytes: $imageBytes, ')
          ..write('thumbnailBytes: $thumbnailBytes, ')
          ..write('imageMimeType: $imageMimeType, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationLabel: $locationLabel, ')
          ..write('locationCapturedAt: $locationCapturedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeneratedAssetsTable extends GeneratedAssets
    with TableInfo<$GeneratedAssetsTable, GeneratedAssetRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeneratedAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pngBytesMeta = const VerificationMeta(
    'pngBytes',
  );
  @override
  late final GeneratedColumn<Uint8List> pngBytes = GeneratedColumn<Uint8List>(
    'png_bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backgroundColorMeta = const VerificationMeta(
    'backgroundColor',
  );
  @override
  late final GeneratedColumn<int> backgroundColor = GeneratedColumn<int>(
    'background_color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    pngBytes,
    backgroundColor,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'generated_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<GeneratedAssetRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('png_bytes')) {
      context.handle(
        _pngBytesMeta,
        pngBytes.isAcceptableOrUnknown(data['png_bytes']!, _pngBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_pngBytesMeta);
    }
    if (data.containsKey('background_color')) {
      context.handle(
        _backgroundColorMeta,
        backgroundColor.isAcceptableOrUnknown(
          data['background_color']!,
          _backgroundColorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_backgroundColorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeneratedAssetRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeneratedAssetRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      pngBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}png_bytes'],
      )!,
      backgroundColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}background_color'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GeneratedAssetsTable createAlias(String alias) {
    return $GeneratedAssetsTable(attachedDatabase, alias);
  }
}

class GeneratedAssetRecord extends DataClass
    implements Insertable<GeneratedAssetRecord> {
  final String id;
  final String productId;
  final Uint8List pngBytes;
  final int backgroundColor;
  final DateTime createdAt;
  const GeneratedAssetRecord({
    required this.id,
    required this.productId,
    required this.pngBytes,
    required this.backgroundColor,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['png_bytes'] = Variable<Uint8List>(pngBytes);
    map['background_color'] = Variable<int>(backgroundColor);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GeneratedAssetsCompanion toCompanion(bool nullToAbsent) {
    return GeneratedAssetsCompanion(
      id: Value(id),
      productId: Value(productId),
      pngBytes: Value(pngBytes),
      backgroundColor: Value(backgroundColor),
      createdAt: Value(createdAt),
    );
  }

  factory GeneratedAssetRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeneratedAssetRecord(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      pngBytes: serializer.fromJson<Uint8List>(json['pngBytes']),
      backgroundColor: serializer.fromJson<int>(json['backgroundColor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'pngBytes': serializer.toJson<Uint8List>(pngBytes),
      'backgroundColor': serializer.toJson<int>(backgroundColor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GeneratedAssetRecord copyWith({
    String? id,
    String? productId,
    Uint8List? pngBytes,
    int? backgroundColor,
    DateTime? createdAt,
  }) => GeneratedAssetRecord(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    pngBytes: pngBytes ?? this.pngBytes,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    createdAt: createdAt ?? this.createdAt,
  );
  GeneratedAssetRecord copyWithCompanion(GeneratedAssetsCompanion data) {
    return GeneratedAssetRecord(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      pngBytes: data.pngBytes.present ? data.pngBytes.value : this.pngBytes,
      backgroundColor: data.backgroundColor.present
          ? data.backgroundColor.value
          : this.backgroundColor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeneratedAssetRecord(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('pngBytes: $pngBytes, ')
          ..write('backgroundColor: $backgroundColor, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    $driftBlobEquality.hash(pngBytes),
    backgroundColor,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeneratedAssetRecord &&
          other.id == this.id &&
          other.productId == this.productId &&
          $driftBlobEquality.equals(other.pngBytes, this.pngBytes) &&
          other.backgroundColor == this.backgroundColor &&
          other.createdAt == this.createdAt);
}

class GeneratedAssetsCompanion extends UpdateCompanion<GeneratedAssetRecord> {
  final Value<String> id;
  final Value<String> productId;
  final Value<Uint8List> pngBytes;
  final Value<int> backgroundColor;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GeneratedAssetsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.pngBytes = const Value.absent(),
    this.backgroundColor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeneratedAssetsCompanion.insert({
    required String id,
    required String productId,
    required Uint8List pngBytes,
    required int backgroundColor,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       pngBytes = Value(pngBytes),
       backgroundColor = Value(backgroundColor),
       createdAt = Value(createdAt);
  static Insertable<GeneratedAssetRecord> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<Uint8List>? pngBytes,
    Expression<int>? backgroundColor,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (pngBytes != null) 'png_bytes': pngBytes,
      if (backgroundColor != null) 'background_color': backgroundColor,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeneratedAssetsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<Uint8List>? pngBytes,
    Value<int>? backgroundColor,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return GeneratedAssetsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      pngBytes: pngBytes ?? this.pngBytes,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (pngBytes.present) {
      map['png_bytes'] = Variable<Uint8List>(pngBytes.value);
    }
    if (backgroundColor.present) {
      map['background_color'] = Variable<int>(backgroundColor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeneratedAssetsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('pngBytes: $pngBytes, ')
          ..write('backgroundColor: $backgroundColor, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExchangeRateCachesTable extends ExchangeRateCaches
    with TableInfo<$ExchangeRateCachesTable, ExchangeRateCacheRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeRateCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta(
    'baseCurrency',
  );
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quoteCurrencyMeta = const VerificationMeta(
    'quoteCurrency',
  );
  @override
  late final GeneratedColumn<String> quoteCurrency = GeneratedColumn<String>(
    'quote_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('IDR'),
  );
  static const VerificationMeta _rateMicrosMeta = const VerificationMeta(
    'rateMicros',
  );
  @override
  late final GeneratedColumn<int> rateMicros = GeneratedColumn<int>(
    'rate_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateDateMeta = const VerificationMeta(
    'rateDate',
  );
  @override
  late final GeneratedColumn<DateTime> rateDate = GeneratedColumn<DateTime>(
    'rate_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    baseCurrency,
    quoteCurrency,
    rateMicros,
    rateDate,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exchange_rate_caches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExchangeRateCacheRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('base_currency')) {
      context.handle(
        _baseCurrencyMeta,
        baseCurrency.isAcceptableOrUnknown(
          data['base_currency']!,
          _baseCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseCurrencyMeta);
    }
    if (data.containsKey('quote_currency')) {
      context.handle(
        _quoteCurrencyMeta,
        quoteCurrency.isAcceptableOrUnknown(
          data['quote_currency']!,
          _quoteCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('rate_micros')) {
      context.handle(
        _rateMicrosMeta,
        rateMicros.isAcceptableOrUnknown(data['rate_micros']!, _rateMicrosMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMicrosMeta);
    }
    if (data.containsKey('rate_date')) {
      context.handle(
        _rateDateMeta,
        rateDate.isAcceptableOrUnknown(data['rate_date']!, _rateDateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateDateMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {baseCurrency, quoteCurrency};
  @override
  ExchangeRateCacheRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRateCacheRecord(
      baseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency'],
      )!,
      quoteCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_currency'],
      )!,
      rateMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_micros'],
      )!,
      rateDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}rate_date'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $ExchangeRateCachesTable createAlias(String alias) {
    return $ExchangeRateCachesTable(attachedDatabase, alias);
  }
}

class ExchangeRateCacheRecord extends DataClass
    implements Insertable<ExchangeRateCacheRecord> {
  final String baseCurrency;
  final String quoteCurrency;
  final int rateMicros;
  final DateTime rateDate;
  final DateTime fetchedAt;
  const ExchangeRateCacheRecord({
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.rateMicros,
    required this.rateDate,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['base_currency'] = Variable<String>(baseCurrency);
    map['quote_currency'] = Variable<String>(quoteCurrency);
    map['rate_micros'] = Variable<int>(rateMicros);
    map['rate_date'] = Variable<DateTime>(rateDate);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  ExchangeRateCachesCompanion toCompanion(bool nullToAbsent) {
    return ExchangeRateCachesCompanion(
      baseCurrency: Value(baseCurrency),
      quoteCurrency: Value(quoteCurrency),
      rateMicros: Value(rateMicros),
      rateDate: Value(rateDate),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory ExchangeRateCacheRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRateCacheRecord(
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
      quoteCurrency: serializer.fromJson<String>(json['quoteCurrency']),
      rateMicros: serializer.fromJson<int>(json['rateMicros']),
      rateDate: serializer.fromJson<DateTime>(json['rateDate']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'baseCurrency': serializer.toJson<String>(baseCurrency),
      'quoteCurrency': serializer.toJson<String>(quoteCurrency),
      'rateMicros': serializer.toJson<int>(rateMicros),
      'rateDate': serializer.toJson<DateTime>(rateDate),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  ExchangeRateCacheRecord copyWith({
    String? baseCurrency,
    String? quoteCurrency,
    int? rateMicros,
    DateTime? rateDate,
    DateTime? fetchedAt,
  }) => ExchangeRateCacheRecord(
    baseCurrency: baseCurrency ?? this.baseCurrency,
    quoteCurrency: quoteCurrency ?? this.quoteCurrency,
    rateMicros: rateMicros ?? this.rateMicros,
    rateDate: rateDate ?? this.rateDate,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  ExchangeRateCacheRecord copyWithCompanion(ExchangeRateCachesCompanion data) {
    return ExchangeRateCacheRecord(
      baseCurrency: data.baseCurrency.present
          ? data.baseCurrency.value
          : this.baseCurrency,
      quoteCurrency: data.quoteCurrency.present
          ? data.quoteCurrency.value
          : this.quoteCurrency,
      rateMicros: data.rateMicros.present
          ? data.rateMicros.value
          : this.rateMicros,
      rateDate: data.rateDate.present ? data.rateDate.value : this.rateDate,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRateCacheRecord(')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('quoteCurrency: $quoteCurrency, ')
          ..write('rateMicros: $rateMicros, ')
          ..write('rateDate: $rateDate, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(baseCurrency, quoteCurrency, rateMicros, rateDate, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeRateCacheRecord &&
          other.baseCurrency == this.baseCurrency &&
          other.quoteCurrency == this.quoteCurrency &&
          other.rateMicros == this.rateMicros &&
          other.rateDate == this.rateDate &&
          other.fetchedAt == this.fetchedAt);
}

class ExchangeRateCachesCompanion
    extends UpdateCompanion<ExchangeRateCacheRecord> {
  final Value<String> baseCurrency;
  final Value<String> quoteCurrency;
  final Value<int> rateMicros;
  final Value<DateTime> rateDate;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const ExchangeRateCachesCompanion({
    this.baseCurrency = const Value.absent(),
    this.quoteCurrency = const Value.absent(),
    this.rateMicros = const Value.absent(),
    this.rateDate = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExchangeRateCachesCompanion.insert({
    required String baseCurrency,
    this.quoteCurrency = const Value.absent(),
    required int rateMicros,
    required DateTime rateDate,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : baseCurrency = Value(baseCurrency),
       rateMicros = Value(rateMicros),
       rateDate = Value(rateDate),
       fetchedAt = Value(fetchedAt);
  static Insertable<ExchangeRateCacheRecord> custom({
    Expression<String>? baseCurrency,
    Expression<String>? quoteCurrency,
    Expression<int>? rateMicros,
    Expression<DateTime>? rateDate,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (baseCurrency != null) 'base_currency': baseCurrency,
      if (quoteCurrency != null) 'quote_currency': quoteCurrency,
      if (rateMicros != null) 'rate_micros': rateMicros,
      if (rateDate != null) 'rate_date': rateDate,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExchangeRateCachesCompanion copyWith({
    Value<String>? baseCurrency,
    Value<String>? quoteCurrency,
    Value<int>? rateMicros,
    Value<DateTime>? rateDate,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return ExchangeRateCachesCompanion(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      quoteCurrency: quoteCurrency ?? this.quoteCurrency,
      rateMicros: rateMicros ?? this.rateMicros,
      rateDate: rateDate ?? this.rateDate,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    if (quoteCurrency.present) {
      map['quote_currency'] = Variable<String>(quoteCurrency.value);
    }
    if (rateMicros.present) {
      map['rate_micros'] = Variable<int>(rateMicros.value);
    }
    if (rateDate.present) {
      map['rate_date'] = Variable<DateTime>(rateDate.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRateCachesCompanion(')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('quoteCurrency: $quoteCurrency, ')
          ..write('rateMicros: $rateMicros, ')
          ..write('rateDate: $rateDate, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $GeneratedAssetsTable generatedAssets = $GeneratedAssetsTable(
    this,
  );
  late final $ExchangeRateCachesTable exchangeRateCaches =
      $ExchangeRateCachesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    trips,
    products,
    generatedAssets,
    exchangeRateCaches,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('products', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'products',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('generated_assets', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TripsTableCreateCompanionBuilder = TripsCompanion Function({
  required String id,
  required String name,
  Value<String> country,
  required String currencyCode,
  required String currencyName,
  required String currencySymbol,
  Value<int> rateMicros,
  Value<DateTime?> rateDate,
  Value<DateTime?> rateFetchedAt,
  Value<int> markupBasisPoints,
  Value<int> fixedFeeIdr,
  Value<int> roundingUnitIdr,
  Value<bool> isActive,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TripsTableUpdateCompanionBuilder = TripsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> country,
  Value<String> currencyCode,
  Value<String> currencyName,
  Value<String> currencySymbol,
  Value<int> rateMicros,
  Value<DateTime?> rateDate,
  Value<DateTime?> rateFetchedAt,
  Value<int> markupBasisPoints,
  Value<int> fixedFeeIdr,
  Value<int> roundingUnitIdr,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$TripsTableReferences
    extends BaseReferences<_$AppDatabase, $TripsTable, TripRecord> {
  $$TripsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductsTable, List<ProductRecord>>
  _productsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.products,
    aliasName: 'trips__id__products__trip_id',
  );

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyName => $composableBuilder(
    column: $table.currencyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rateMicros => $composableBuilder(
    column: $table.rateMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rateDate => $composableBuilder(
    column: $table.rateDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rateFetchedAt => $composableBuilder(
    column: $table.rateFetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get markupBasisPoints => $composableBuilder(
    column: $table.markupBasisPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fixedFeeIdr => $composableBuilder(
    column: $table.fixedFeeIdr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roundingUnitIdr => $composableBuilder(
    column: $table.roundingUnitIdr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productsRefs(
    Expression<bool> Function($$ProductsTableFilterComposer f) f,
  ) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyName => $composableBuilder(
    column: $table.currencyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rateMicros => $composableBuilder(
    column: $table.rateMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rateDate => $composableBuilder(
    column: $table.rateDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rateFetchedAt => $composableBuilder(
    column: $table.rateFetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get markupBasisPoints => $composableBuilder(
    column: $table.markupBasisPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fixedFeeIdr => $composableBuilder(
    column: $table.fixedFeeIdr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roundingUnitIdr => $composableBuilder(
    column: $table.roundingUnitIdr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyName => $composableBuilder(
    column: $table.currencyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rateMicros => $composableBuilder(
    column: $table.rateMicros,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get rateDate =>
      $composableBuilder(column: $table.rateDate, builder: (column) => column);

  GeneratedColumn<DateTime> get rateFetchedAt => $composableBuilder(
    column: $table.rateFetchedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get markupBasisPoints => $composableBuilder(
    column: $table.markupBasisPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fixedFeeIdr => $composableBuilder(
    column: $table.fixedFeeIdr,
    builder: (column) => column,
  );

  GeneratedColumn<int> get roundingUnitIdr => $composableBuilder(
    column: $table.roundingUnitIdr,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> productsRefs<T extends Object>(
    Expression<T> Function($$ProductsTableAnnotationComposer a) f,
  ) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTable,
          TripRecord,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (TripRecord, $$TripsTableReferences),
          TripRecord,
          PrefetchHooks Function({bool productsRefs})
        > {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> currencyName = const Value.absent(),
                Value<String> currencySymbol = const Value.absent(),
                Value<int> rateMicros = const Value.absent(),
                Value<DateTime?> rateDate = const Value.absent(),
                Value<DateTime?> rateFetchedAt = const Value.absent(),
                Value<int> markupBasisPoints = const Value.absent(),
                Value<int> fixedFeeIdr = const Value.absent(),
                Value<int> roundingUnitIdr = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                name: name,
                country: country,
                currencyCode: currencyCode,
                currencyName: currencyName,
                currencySymbol: currencySymbol,
                rateMicros: rateMicros,
                rateDate: rateDate,
                rateFetchedAt: rateFetchedAt,
                markupBasisPoints: markupBasisPoints,
                fixedFeeIdr: fixedFeeIdr,
                roundingUnitIdr: roundingUnitIdr,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> country = const Value.absent(),
                required String currencyCode,
                required String currencyName,
                required String currencySymbol,
                Value<int> rateMicros = const Value.absent(),
                Value<DateTime?> rateDate = const Value.absent(),
                Value<DateTime?> rateFetchedAt = const Value.absent(),
                Value<int> markupBasisPoints = const Value.absent(),
                Value<int> fixedFeeIdr = const Value.absent(),
                Value<int> roundingUnitIdr = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                name: name,
                country: country,
                currencyCode: currencyCode,
                currencyName: currencyName,
                currencySymbol: currencySymbol,
                rateMicros: rateMicros,
                rateDate: rateDate,
                rateFetchedAt: rateFetchedAt,
                markupBasisPoints: markupBasisPoints,
                fixedFeeIdr: fixedFeeIdr,
                roundingUnitIdr: roundingUnitIdr,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TripsTable, TripRecord>(table),
                  $$TripsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productsRefs) db.products],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productsRefs)
                    await $_getPrefetchedData<
                      TripRecord,
                      $TripsTable,
                      ProductRecord
                    >(
                      currentTable: table,
                      referencedTable: $$TripsTableReferences
                          ._productsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TripsTableReferences(db, table, p0).productsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tripId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTable,
      TripRecord,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (TripRecord, $$TripsTableReferences),
      TripRecord,
      PrefetchHooks Function({bool productsRefs})
    >;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  required String tripId,
  required String name,
  required int originalPriceMinor,
  required int sellingPriceIdr,
  Value<int?> markupBasisPointsOverride,
  Value<int?> fixedFeeIdrOverride,
  Value<int?> weightGrams,
  Value<String> note,
  Value<String> category,
  required Uint8List imageBytes,
  required Uint8List thumbnailBytes,
  required String imageMimeType,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> locationLabel,
  Value<DateTime?> locationCapturedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<String> tripId,
  Value<String> name,
  Value<int> originalPriceMinor,
  Value<int> sellingPriceIdr,
  Value<int?> markupBasisPointsOverride,
  Value<int?> fixedFeeIdrOverride,
  Value<int?> weightGrams,
  Value<String> note,
  Value<String> category,
  Value<Uint8List> imageBytes,
  Value<Uint8List> thumbnailBytes,
  Value<String> imageMimeType,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> locationLabel,
  Value<DateTime?> locationCapturedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, ProductRecord> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('products__trip_id__trips__id');

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GeneratedAssetsTable, List<GeneratedAssetRecord>>
  _generatedAssetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.generatedAssets,
    aliasName: 'products__id__generated_assets__product_id',
  );

  $$GeneratedAssetsTableProcessedTableManager get generatedAssetsRefs {
    final manager = $$GeneratedAssetsTableTableManager(
      $_db,
      $_db.generatedAssets,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _generatedAssetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalPriceMinor => $composableBuilder(
    column: $table.originalPriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellingPriceIdr => $composableBuilder(
    column: $table.sellingPriceIdr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get markupBasisPointsOverride => $composableBuilder(
    column: $table.markupBasisPointsOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fixedFeeIdrOverride => $composableBuilder(
    column: $table.fixedFeeIdrOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get imageBytes => $composableBuilder(
    column: $table.imageBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get thumbnailBytes => $composableBuilder(
    column: $table.thumbnailBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageMimeType => $composableBuilder(
    column: $table.imageMimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationLabel => $composableBuilder(
    column: $table.locationLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get locationCapturedAt => $composableBuilder(
    column: $table.locationCapturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> generatedAssetsRefs(
    Expression<bool> Function($$GeneratedAssetsTableFilterComposer f) f,
  ) {
    final $$GeneratedAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.generatedAssets,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GeneratedAssetsTableFilterComposer(
            $db: $db,
            $table: $db.generatedAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalPriceMinor => $composableBuilder(
    column: $table.originalPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellingPriceIdr => $composableBuilder(
    column: $table.sellingPriceIdr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get markupBasisPointsOverride => $composableBuilder(
    column: $table.markupBasisPointsOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fixedFeeIdrOverride => $composableBuilder(
    column: $table.fixedFeeIdrOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get imageBytes => $composableBuilder(
    column: $table.imageBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get thumbnailBytes => $composableBuilder(
    column: $table.thumbnailBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageMimeType => $composableBuilder(
    column: $table.imageMimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationLabel => $composableBuilder(
    column: $table.locationLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get locationCapturedAt => $composableBuilder(
    column: $table.locationCapturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get originalPriceMinor => $composableBuilder(
    column: $table.originalPriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sellingPriceIdr => $composableBuilder(
    column: $table.sellingPriceIdr,
    builder: (column) => column,
  );

  GeneratedColumn<int> get markupBasisPointsOverride => $composableBuilder(
    column: $table.markupBasisPointsOverride,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fixedFeeIdrOverride => $composableBuilder(
    column: $table.fixedFeeIdrOverride,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<Uint8List> get imageBytes => $composableBuilder(
    column: $table.imageBytes,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get thumbnailBytes => $composableBuilder(
    column: $table.thumbnailBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageMimeType => $composableBuilder(
    column: $table.imageMimeType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get locationLabel => $composableBuilder(
    column: $table.locationLabel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get locationCapturedAt => $composableBuilder(
    column: $table.locationCapturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> generatedAssetsRefs<T extends Object>(
    Expression<T> Function($$GeneratedAssetsTableAnnotationComposer a) f,
  ) {
    final $$GeneratedAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.generatedAssets,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GeneratedAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.generatedAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ProductRecord,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (ProductRecord, $$ProductsTableReferences),
          ProductRecord,
          PrefetchHooks Function({bool tripId, bool generatedAssetsRefs})
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> originalPriceMinor = const Value.absent(),
                Value<int> sellingPriceIdr = const Value.absent(),
                Value<int?> markupBasisPointsOverride = const Value.absent(),
                Value<int?> fixedFeeIdrOverride = const Value.absent(),
                Value<int?> weightGrams = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<Uint8List> imageBytes = const Value.absent(),
                Value<Uint8List> thumbnailBytes = const Value.absent(),
                Value<String> imageMimeType = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> locationLabel = const Value.absent(),
                Value<DateTime?> locationCapturedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                tripId: tripId,
                name: name,
                originalPriceMinor: originalPriceMinor,
                sellingPriceIdr: sellingPriceIdr,
                markupBasisPointsOverride: markupBasisPointsOverride,
                fixedFeeIdrOverride: fixedFeeIdrOverride,
                weightGrams: weightGrams,
                note: note,
                category: category,
                imageBytes: imageBytes,
                thumbnailBytes: thumbnailBytes,
                imageMimeType: imageMimeType,
                latitude: latitude,
                longitude: longitude,
                locationLabel: locationLabel,
                locationCapturedAt: locationCapturedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String name,
                required int originalPriceMinor,
                required int sellingPriceIdr,
                Value<int?> markupBasisPointsOverride = const Value.absent(),
                Value<int?> fixedFeeIdrOverride = const Value.absent(),
                Value<int?> weightGrams = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> category = const Value.absent(),
                required Uint8List imageBytes,
                required Uint8List thumbnailBytes,
                required String imageMimeType,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> locationLabel = const Value.absent(),
                Value<DateTime?> locationCapturedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                tripId: tripId,
                name: name,
                originalPriceMinor: originalPriceMinor,
                sellingPriceIdr: sellingPriceIdr,
                markupBasisPointsOverride: markupBasisPointsOverride,
                fixedFeeIdrOverride: fixedFeeIdrOverride,
                weightGrams: weightGrams,
                note: note,
                category: category,
                imageBytes: imageBytes,
                thumbnailBytes: thumbnailBytes,
                imageMimeType: imageMimeType,
                latitude: latitude,
                longitude: longitude,
                locationLabel: locationLabel,
                locationCapturedAt: locationCapturedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductsTable, ProductRecord>(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tripId = false, generatedAssetsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (generatedAssetsRefs) db.generatedAssets,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tripId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.tripId,
                            referencedTable: $$ProductsTableReferences
                                ._tripIdTable(db),
                            referencedColumn: $$ProductsTableReferences
                                ._tripIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (generatedAssetsRefs)
                        await $_getPrefetchedData<
                          ProductRecord,
                          $ProductsTable,
                          GeneratedAssetRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._generatedAssetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).generatedAssetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ProductRecord,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductRecord, $$ProductsTableReferences),
      ProductRecord,
      PrefetchHooks Function({bool tripId, bool generatedAssetsRefs})
    >;
typedef $$GeneratedAssetsTableCreateCompanionBuilder =
    GeneratedAssetsCompanion Function({
      required String id,
      required String productId,
      required Uint8List pngBytes,
      required int backgroundColor,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$GeneratedAssetsTableUpdateCompanionBuilder =
    GeneratedAssetsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<Uint8List> pngBytes,
      Value<int> backgroundColor,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$GeneratedAssetsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GeneratedAssetsTable,
          GeneratedAssetRecord
        > {
  $$GeneratedAssetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('generated_assets__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GeneratedAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $GeneratedAssetsTable> {
  $$GeneratedAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get pngBytes => $composableBuilder(
    column: $table.pngBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get backgroundColor => $composableBuilder(
    column: $table.backgroundColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GeneratedAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $GeneratedAssetsTable> {
  $$GeneratedAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get pngBytes => $composableBuilder(
    column: $table.pngBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get backgroundColor => $composableBuilder(
    column: $table.backgroundColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GeneratedAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeneratedAssetsTable> {
  $$GeneratedAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get pngBytes =>
      $composableBuilder(column: $table.pngBytes, builder: (column) => column);

  GeneratedColumn<int> get backgroundColor => $composableBuilder(
    column: $table.backgroundColor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GeneratedAssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GeneratedAssetsTable,
          GeneratedAssetRecord,
          $$GeneratedAssetsTableFilterComposer,
          $$GeneratedAssetsTableOrderingComposer,
          $$GeneratedAssetsTableAnnotationComposer,
          $$GeneratedAssetsTableCreateCompanionBuilder,
          $$GeneratedAssetsTableUpdateCompanionBuilder,
          (GeneratedAssetRecord, $$GeneratedAssetsTableReferences),
          GeneratedAssetRecord,
          PrefetchHooks Function({bool productId})
        > {
  $$GeneratedAssetsTableTableManager(
    _$AppDatabase db,
    $GeneratedAssetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeneratedAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeneratedAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeneratedAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<Uint8List> pngBytes = const Value.absent(),
                Value<int> backgroundColor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GeneratedAssetsCompanion(
                id: id,
                productId: productId,
                pngBytes: pngBytes,
                backgroundColor: backgroundColor,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required Uint8List pngBytes,
                required int backgroundColor,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => GeneratedAssetsCompanion.insert(
                id: id,
                productId: productId,
                pngBytes: pngBytes,
                backgroundColor: backgroundColor,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GeneratedAssetsTable, GeneratedAssetRecord>(
                    table,
                  ),
                  $$GeneratedAssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.productId,
                        referencedTable: $$GeneratedAssetsTableReferences
                            ._productIdTable(db),
                        referencedColumn: $$GeneratedAssetsTableReferences
                            ._productIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GeneratedAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GeneratedAssetsTable,
      GeneratedAssetRecord,
      $$GeneratedAssetsTableFilterComposer,
      $$GeneratedAssetsTableOrderingComposer,
      $$GeneratedAssetsTableAnnotationComposer,
      $$GeneratedAssetsTableCreateCompanionBuilder,
      $$GeneratedAssetsTableUpdateCompanionBuilder,
      (GeneratedAssetRecord, $$GeneratedAssetsTableReferences),
      GeneratedAssetRecord,
      PrefetchHooks Function({bool productId})
    >;
typedef $$ExchangeRateCachesTableCreateCompanionBuilder =
    ExchangeRateCachesCompanion Function({
      required String baseCurrency,
      Value<String> quoteCurrency,
      required int rateMicros,
      required DateTime rateDate,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$ExchangeRateCachesTableUpdateCompanionBuilder =
    ExchangeRateCachesCompanion Function({
      Value<String> baseCurrency,
      Value<String> quoteCurrency,
      Value<int> rateMicros,
      Value<DateTime> rateDate,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$ExchangeRateCachesTableFilterComposer
    extends Composer<_$AppDatabase, $ExchangeRateCachesTable> {
  $$ExchangeRateCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quoteCurrency => $composableBuilder(
    column: $table.quoteCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rateMicros => $composableBuilder(
    column: $table.rateMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rateDate => $composableBuilder(
    column: $table.rateDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExchangeRateCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExchangeRateCachesTable> {
  $$ExchangeRateCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quoteCurrency => $composableBuilder(
    column: $table.quoteCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rateMicros => $composableBuilder(
    column: $table.rateMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rateDate => $composableBuilder(
    column: $table.rateDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExchangeRateCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExchangeRateCachesTable> {
  $$ExchangeRateCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quoteCurrency => $composableBuilder(
    column: $table.quoteCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rateMicros => $composableBuilder(
    column: $table.rateMicros,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get rateDate =>
      $composableBuilder(column: $table.rateDate, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ExchangeRateCachesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExchangeRateCachesTable,
          ExchangeRateCacheRecord,
          $$ExchangeRateCachesTableFilterComposer,
          $$ExchangeRateCachesTableOrderingComposer,
          $$ExchangeRateCachesTableAnnotationComposer,
          $$ExchangeRateCachesTableCreateCompanionBuilder,
          $$ExchangeRateCachesTableUpdateCompanionBuilder,
          (
            ExchangeRateCacheRecord,
            BaseReferences<
              _$AppDatabase,
              $ExchangeRateCachesTable,
              ExchangeRateCacheRecord
            >,
          ),
          ExchangeRateCacheRecord,
          PrefetchHooks Function()
        > {
  $$ExchangeRateCachesTableTableManager(
    _$AppDatabase db,
    $ExchangeRateCachesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExchangeRateCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExchangeRateCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExchangeRateCachesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> baseCurrency = const Value.absent(),
                Value<String> quoteCurrency = const Value.absent(),
                Value<int> rateMicros = const Value.absent(),
                Value<DateTime> rateDate = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExchangeRateCachesCompanion(
                baseCurrency: baseCurrency,
                quoteCurrency: quoteCurrency,
                rateMicros: rateMicros,
                rateDate: rateDate,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String baseCurrency,
                Value<String> quoteCurrency = const Value.absent(),
                required int rateMicros,
                required DateTime rateDate,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => ExchangeRateCachesCompanion.insert(
                baseCurrency: baseCurrency,
                quoteCurrency: quoteCurrency,
                rateMicros: rateMicros,
                rateDate: rateDate,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ExchangeRateCachesTable,
                    ExchangeRateCacheRecord
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ExchangeRateCachesTable,
                    ExchangeRateCacheRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExchangeRateCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExchangeRateCachesTable,
      ExchangeRateCacheRecord,
      $$ExchangeRateCachesTableFilterComposer,
      $$ExchangeRateCachesTableOrderingComposer,
      $$ExchangeRateCachesTableAnnotationComposer,
      $$ExchangeRateCachesTableCreateCompanionBuilder,
      $$ExchangeRateCachesTableUpdateCompanionBuilder,
      (
        ExchangeRateCacheRecord,
        BaseReferences<
          _$AppDatabase,
          $ExchangeRateCachesTable,
          ExchangeRateCacheRecord
        >,
      ),
      ExchangeRateCacheRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$GeneratedAssetsTableTableManager get generatedAssets =>
      $$GeneratedAssetsTableTableManager(_db, _db.generatedAssets);
  $$ExchangeRateCachesTableTableManager get exchangeRateCaches =>
      $$ExchangeRateCachesTableTableManager(_db, _db.exchangeRateCaches);
}
