import '../entities/trip.dart';

abstract interface class TripRepository {
  Stream<Trip> watchActiveTrip();
  Stream<List<Trip>> watchTrips();
  Future<Trip> getActiveTrip();
  Future<List<Trip>> getTrips();
  Future<Trip> ensureDefaultTrip();
  Future<Trip> createTrip(NewTrip trip);
  Future<void> setActiveTrip(String id);
  Future<void> updateTrip(Trip trip);
  Future<void> deleteTrip(String id);
}

abstract interface class ExchangeRateRepository {
  Future<List<CurrencyOption>> getCurrencies();
  Future<ExchangeRateQuote> getLatestRate(String baseCurrency);
}
