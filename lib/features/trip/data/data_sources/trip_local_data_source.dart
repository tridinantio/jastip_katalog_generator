import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

class TripLocalDataSource {
  const TripLocalDataSource(this._database);

  final AppDatabase _database;

  Stream<TripRecord> watchActiveTrip() {
    final query = _database.select(_database.trips)
      ..where((table) => table.isActive.equals(true))
      ..limit(1);
    return query.watchSingle();
  }

  Stream<List<TripRecord>> watchTrips() {
    final query = _database.select(_database.trips)
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);
    return query.watch();
  }

  Future<List<TripRecord>> getTrips() {
    final query = _database.select(_database.trips)
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);
    return query.get();
  }

  Future<TripRecord?> getTripOrNull(String id) {
    final query = _database.select(_database.trips)
      ..where((table) => table.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<TripRecord?> getActiveTripOrNull() {
    final query = _database.select(_database.trips)
      ..where((table) => table.isActive.equals(true))
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<void> insertTrip(TripsCompanion trip) =>
      _database.into(_database.trips).insert(trip);

  Future<void> insertAndActivateTrip(TripsCompanion trip) {
    return _database.transaction(() async {
      await _database
          .update(_database.trips)
          .write(const TripsCompanion(isActive: Value(false)));
      await _database.into(_database.trips).insert(trip);
    });
  }

  Future<bool> setActiveTrip(String id) {
    return _database.transaction(() async {
      final target = await getTripOrNull(id);
      if (target == null) return false;
      await _database
          .update(_database.trips)
          .write(const TripsCompanion(isActive: Value(false)));
      await (_database.update(
        _database.trips,
      )..where((table) => table.id.equals(id))).write(
        TripsCompanion(
          isActive: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return true;
    });
  }

  Future<void> updateTrip(TripRecord trip) =>
      _database.update(_database.trips).replace(trip);

  Future<bool> updateTripAndRecalculateProducts(
    TripRecord trip,
    int Function(ProductRecord product) calculateSellingPrice,
  ) {
    return _database.transaction(() async {
      final updated = await _database.update(_database.trips).replace(trip);
      if (!updated) return false;
      final productRows = await (_database.select(
        _database.products,
      )..where((table) => table.tripId.equals(trip.id))).get();
      final now = DateTime.now();
      for (final product in productRows) {
        await (_database.update(
          _database.products,
        )..where((table) => table.id.equals(product.id))).write(
          ProductsCompanion(
            sellingPriceIdr: Value(calculateSellingPrice(product)),
            updatedAt: Value(now),
          ),
        );
      }
      return true;
    });
  }

  Future<String> deleteTrip(String id) {
    return _database.transaction(() async {
      final trips = await getTrips();
      if (trips.length <= 1) {
        throw StateError('Trip terakhir tidak dapat dihapus.');
      }
      final target = trips.where((trip) => trip.id == id).firstOrNull;
      if (target == null) throw StateError('Trip tidak ditemukan.');
      final fallback = trips.firstWhere((trip) => trip.id != id);

      await (_database.delete(
        _database.trips,
      )..where((table) => table.id.equals(id))).go();
      if (target.isActive) {
        await (_database.update(
          _database.trips,
        )..where((table) => table.id.equals(fallback.id))).write(
          TripsCompanion(
            isActive: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
      return target.isActive
          ? fallback.id
          : trips.firstWhere((e) => e.isActive).id;
    });
  }

  Future<ExchangeRateCacheRecord?> getCachedRate(String base) {
    final query = _database.select(_database.exchangeRateCaches)
      ..where(
        (table) =>
            table.baseCurrency.equals(base) & table.quoteCurrency.equals('IDR'),
      );
    return query.getSingleOrNull();
  }

  Future<void> upsertRate(ExchangeRateCachesCompanion rate) =>
      _database.into(_database.exchangeRateCaches).insertOnConflictUpdate(rate);
}
