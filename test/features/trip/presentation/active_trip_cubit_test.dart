import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/features/trip/domain/entities/trip.dart';
import 'package:jastip_katalog_generator/features/trip/domain/repositories/trip_repository.dart';
import 'package:jastip_katalog_generator/features/trip/presentation/cubit/active_trip_cubit.dart';

void main() {
  test(
    'refresh kurs memperbarui trip di state agar kartu kurs tidak stale',
    () async {
      final tripRepository = _MemoryTripRepository();
      final exchangeRepository = _FakeExchangeRateRepository();
      final cubit = ActiveTripCubit(tripRepository, exchangeRepository);
      addTearDown(cubit.close);

      await cubit.initialize();
      await cubit.changeCurrency(
        const CurrencyOption(
          code: 'KRW',
          name: 'South Korean Won',
          symbol: '₩',
        ),
      );

      expect(cubit.state.trip?.currencyCode, 'KRW');
      expect(cubit.state.trip?.rateMicros, 13000000);
      expect(tripRepository.trip.currencyCode, 'KRW');
    },
  );

  test(
    'mengganti mata uang pengaturan mengambil dan menyimpan kurs baru',
    () async {
      final tripRepository = _MemoryTripRepository();
      final exchangeRepository = _FakeExchangeRateRepository();
      final cubit = ActiveTripCubit(tripRepository, exchangeRepository);
      addTearDown(cubit.close);

      await cubit.initialize();
      final saved = await cubit.saveSettings(
        name: 'Korea Trip',
        currency: const CurrencyOption(
          code: 'KRW',
          name: 'South Korean Won',
          symbol: '₩',
        ),
        markupPercent: 15,
        fixedFeeIdr: 0,
        roundingUnitIdr: 1000,
      );

      expect(saved, isTrue);
      expect(exchangeRepository.requestedCodes, ['KRW']);
      expect(tripRepository.trip.currencyCode, 'KRW');
      expect(tripRepository.trip.rateMicros, 13000000);
      expect(cubit.state.trip?.currencyCode, 'KRW');
      expect(cubit.state.trip?.rateMicros, 13000000);
    },
  );
}

class _MemoryTripRepository implements TripRepository {
  Trip trip = Trip(
    id: 'trip-1',
    name: 'Japan Trip',
    country: 'Jepang',
    currencyCode: 'JPY',
    currencyName: 'Japanese Yen',
    currencySymbol: '¥',
    rateMicros: 110000000,
    rateDate: DateTime(2026, 9, 8),
    rateFetchedAt: DateTime.now(),
    markupBasisPoints: 1500,
    fixedFeeIdr: 0,
    roundingUnitIdr: 1000,
  );

  @override
  Future<Trip> createTrip(NewTrip trip) => throw UnimplementedError();

  @override
  Future<void> deleteTrip(String id) => throw UnimplementedError();

  @override
  Future<Trip> ensureDefaultTrip() async => trip;

  @override
  Future<Trip> getActiveTrip() async => trip;

  @override
  Future<List<Trip>> getTrips() async => [trip];

  @override
  Future<void> setActiveTrip(String id) => throw UnimplementedError();

  @override
  Future<void> updateTrip(Trip value) async {
    trip = value;
  }

  @override
  Stream<Trip> watchActiveTrip() => const Stream.empty();

  @override
  Stream<List<Trip>> watchTrips() => const Stream.empty();
}

class _FakeExchangeRateRepository implements ExchangeRateRepository {
  final requestedCodes = <String>[];

  @override
  Future<List<CurrencyOption>> getCurrencies() async => const [];

  @override
  Future<ExchangeRateQuote> getLatestRate(String baseCurrency) async {
    requestedCodes.add(baseCurrency);
    return ExchangeRateQuote(
      base: baseCurrency,
      quote: 'IDR',
      rateMicros: 13000000,
      rateDate: DateTime(2026, 9, 8),
      fetchedAt: DateTime.now(),
      fromCache: false,
    );
  }
}
