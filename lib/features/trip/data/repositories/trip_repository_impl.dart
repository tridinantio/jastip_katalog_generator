import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/app_exception.dart';
import '../../../product/domain/use_cases/calculate_product_price.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../data_sources/frankfurter_service.dart';
import '../data_sources/trip_local_data_source.dart';

class TripRepositoryImpl implements TripRepository {
  const TripRepositoryImpl(this._localDataSource);

  final TripLocalDataSource _localDataSource;

  @override
  Future<Trip> ensureDefaultTrip() async {
    final existing = await _localDataSource.getActiveTripOrNull();
    if (existing != null) return _mapTrip(existing);
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    await _localDataSource.insertTrip(
      TripsCompanion.insert(
        id: id,
        name: 'Japan Trip',
        country: const Value('Jepang'),
        currencyCode: 'JPY',
        currencyName: 'Japanese Yen',
        currencySymbol: '¥',
        isActive: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return getActiveTrip();
  }

  @override
  Future<Trip> getActiveTrip() async {
    final record = await _localDataSource.getActiveTripOrNull();
    if (record == null) return ensureDefaultTrip();
    return _mapTrip(record);
  }

  @override
  Future<List<Trip>> getTrips() async =>
      (await _localDataSource.getTrips()).map(_mapTrip).toList(growable: false);

  @override
  Stream<Trip> watchActiveTrip() =>
      _localDataSource.watchActiveTrip().map(_mapTrip);

  @override
  Stream<List<Trip>> watchTrips() => _localDataSource.watchTrips().map(
    (records) => records.map(_mapTrip).toList(growable: false),
  );

  @override
  Future<Trip> createTrip(NewTrip trip) async {
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    await _localDataSource.insertAndActivateTrip(
      TripsCompanion.insert(
        id: id,
        name: trip.name,
        country: Value(trip.country),
        currencyCode: trip.currencyCode,
        currencyName: trip.currencyName,
        currencySymbol: trip.currencySymbol,
        rateMicros: Value(trip.rateMicros),
        rateDate: Value(trip.rateDate),
        rateFetchedAt: Value(trip.rateFetchedAt),
        markupBasisPoints: Value(trip.markupBasisPoints),
        fixedFeeIdr: Value(trip.fixedFeeIdr),
        roundingUnitIdr: Value(trip.roundingUnitIdr),
        isActive: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    );
    final created = await _localDataSource.getTripOrNull(id);
    if (created == null) {
      throw const StorageException('Trip gagal dibuat.');
    }
    return _mapTrip(created);
  }

  @override
  Future<void> setActiveTrip(String id) async {
    final activated = await _localDataSource.setActiveTrip(id);
    if (!activated) throw const StorageException('Trip tidak ditemukan.');
  }

  @override
  Future<void> updateTrip(Trip trip) async {
    final current = await _localDataSource.getTripOrNull(trip.id);
    if (current == null) {
      throw const StorageException('Trip tidak ditemukan.');
    }
    final persistedTrip = current.copyWith(
      name: trip.name,
      country: trip.country,
      currencyCode: trip.currencyCode,
      currencyName: trip.currencyName,
      currencySymbol: trip.currencySymbol,
      rateMicros: trip.rateMicros,
      rateDate: Value(trip.rateDate),
      rateFetchedAt: Value(trip.rateFetchedAt),
      markupBasisPoints: trip.markupBasisPoints,
      fixedFeeIdr: trip.fixedFeeIdr,
      roundingUnitIdr: trip.roundingUnitIdr,
      updatedAt: DateTime.now(),
    );
    final updated = await _localDataSource.updateTripAndRecalculateProducts(
      persistedTrip,
      (product) => CalculateProductPrice.call(
        originalPriceMinor: product.originalPriceMinor,
        trip: trip,
        markupBasisPointsOverride: product.markupBasisPointsOverride,
        fixedFeeIdrOverride: product.fixedFeeIdrOverride,
      ).sellingPriceIdr,
    );
    if (!updated) throw const StorageException('Trip gagal diperbarui.');
  }

  @override
  Future<void> deleteTrip(String id) async {
    try {
      await _localDataSource.deleteTrip(id);
    } on StateError catch (error) {
      throw StorageException(error.message.toString());
    }
  }

  Trip _mapTrip(TripRecord record) => Trip(
    id: record.id,
    name: record.name,
    country: record.country,
    currencyCode: record.currencyCode,
    currencyName: record.currencyName,
    currencySymbol: record.currencySymbol,
    rateMicros: record.rateMicros,
    rateDate: record.rateDate,
    rateFetchedAt: record.rateFetchedAt,
    markupBasisPoints: record.markupBasisPoints,
    fixedFeeIdr: record.fixedFeeIdr,
    roundingUnitIdr: record.roundingUnitIdr,
  );
}

class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  const ExchangeRateRepositoryImpl(this._remote, this._local);

  final FrankfurterService _remote;
  final TripLocalDataSource _local;

  @override
  Future<List<CurrencyOption>> getCurrencies() async {
    try {
      return await _remote.getCurrencies();
    } catch (_) {
      return _fallbackCurrencies;
    }
  }

  @override
  Future<ExchangeRateQuote> getLatestRate(String baseCurrency) async {
    try {
      final quote = await _remote.getLatestRate(baseCurrency);
      await _local.upsertRate(
        ExchangeRateCachesCompanion.insert(
          baseCurrency: quote.base,
          quoteCurrency: Value(quote.quote),
          rateMicros: quote.rateMicros,
          rateDate: quote.rateDate,
          fetchedAt: quote.fetchedAt,
        ),
      );
      return quote;
    } catch (_) {
      final cached = await _local.getCachedRate(baseCurrency);
      if (cached == null) {
        throw NetworkException(
          'Tidak dapat mengambil kurs $baseCurrency. Periksa koneksi internet.',
        );
      }
      return ExchangeRateQuote(
        base: cached.baseCurrency,
        quote: cached.quoteCurrency,
        rateMicros: cached.rateMicros,
        rateDate: cached.rateDate,
        fetchedAt: cached.fetchedAt,
        fromCache: true,
      );
    }
  }
}

const _fallbackCurrencies = <CurrencyOption>[
  CurrencyOption(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
  CurrencyOption(code: 'USD', name: 'United States Dollar', symbol: r'$'),
  CurrencyOption(code: 'SGD', name: 'Singapore Dollar', symbol: r'$'),
  CurrencyOption(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM'),
  CurrencyOption(code: 'THB', name: 'Thai Baht', symbol: '฿'),
  CurrencyOption(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
  CurrencyOption(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
  CurrencyOption(code: 'HKD', name: 'Hong Kong Dollar', symbol: r'$'),
  CurrencyOption(code: 'EUR', name: 'Euro', symbol: '€'),
  CurrencyOption(code: 'GBP', name: 'British Pound', symbol: '£'),
  CurrencyOption(code: 'AUD', name: 'Australian Dollar', symbol: r'$'),
];
