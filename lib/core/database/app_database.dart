import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('TripRecord')
class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get country => text().withDefault(const Constant(''))();
  TextColumn get currencyCode => text()();
  TextColumn get currencyName => text()();
  TextColumn get currencySymbol => text()();
  IntColumn get rateMicros => integer().withDefault(const Constant(0))();
  DateTimeColumn get rateDate => dateTime().nullable()();
  DateTimeColumn get rateFetchedAt => dateTime().nullable()();
  IntColumn get markupBasisPoints =>
      integer().withDefault(const Constant(1500))();
  IntColumn get fixedFeeIdr => integer().withDefault(const Constant(0))();
  IntColumn get roundingUnitIdr =>
      integer().withDefault(const Constant(1000))();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ProductRecord')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  IntColumn get originalPriceMinor => integer()();
  IntColumn get sellingPriceIdr => integer()();
  IntColumn get markupBasisPointsOverride => integer().nullable()();
  IntColumn get fixedFeeIdrOverride => integer().nullable()();
  IntColumn get weightGrams => integer().nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant(''))();
  BlobColumn get imageBytes => blob()();
  BlobColumn get thumbnailBytes => blob()();
  TextColumn get imageMimeType => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get locationLabel => text().nullable()();
  DateTimeColumn get locationCapturedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('GeneratedAssetRecord')
class GeneratedAssets extends Table {
  TextColumn get id => text()();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.cascade)();
  BlobColumn get pngBytes => blob()();
  IntColumn get backgroundColor => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ExchangeRateCacheRecord')
class ExchangeRateCaches extends Table {
  TextColumn get baseCurrency => text()();
  TextColumn get quoteCurrency => text().withDefault(const Constant('IDR'))();
  IntColumn get rateMicros => integer()();
  DateTimeColumn get rateDate => dateTime()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {baseCurrency, quoteCurrency};
}

@DriftDatabase(tables: [Trips, Products, GeneratedAssets, ExchangeRateCaches])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'jastip_catalog'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createShoppingRequestsTable();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) await _createShoppingRequestsTable();
      if (from < 3) {
        await migrator.addColumn(products, products.latitude);
        await migrator.addColumn(products, products.longitude);
        await migrator.addColumn(products, products.locationCapturedAt);
      }
      if (from < 4) {
        await customStatement(
          'ALTER TABLE products ADD COLUMN markup_basis_points_override INTEGER',
        );
        await customStatement(
          'ALTER TABLE products ADD COLUMN fixed_fee_idr_override INTEGER',
        );
        await customStatement(
          'ALTER TABLE products ADD COLUMN weight_grams INTEGER',
        );
      }
      if (from < 5) {
        await customStatement(
          'ALTER TABLE products ADD COLUMN location_label TEXT',
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createShoppingRequestsTable() => customStatement('''
    CREATE TABLE IF NOT EXISTS shopping_requests (
      id TEXT NOT NULL PRIMARY KEY,
      trip_id TEXT NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
      product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
      buyer_name TEXT NOT NULL,
      quantity INTEGER NOT NULL DEFAULT 1,
      note TEXT NOT NULL DEFAULT '',
      is_purchased INTEGER NOT NULL DEFAULT 0,
      purchased_at TEXT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');
}
