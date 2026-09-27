import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';

enum ActiveTripStatus { initial, loading, ready, failure }

class ActiveTripState extends Equatable {
  const ActiveTripState({
    this.status = ActiveTripStatus.initial,
    this.trip,
    this.trips = const [],
    this.currencies = const [],
    this.isRefreshingRate = false,
    this.isManagingTrips = false,
    this.isUsingCachedRate = false,
    this.message,
  });

  final ActiveTripStatus status;
  final Trip? trip;
  final List<Trip> trips;
  final List<CurrencyOption> currencies;
  final bool isRefreshingRate;
  final bool isManagingTrips;
  final bool isUsingCachedRate;
  final String? message;

  ActiveTripState copyWith({
    ActiveTripStatus? status,
    Trip? trip,
    List<Trip>? trips,
    List<CurrencyOption>? currencies,
    bool? isRefreshingRate,
    bool? isManagingTrips,
    bool? isUsingCachedRate,
    String? message,
    bool clearMessage = false,
  }) {
    return ActiveTripState(
      status: status ?? this.status,
      trip: trip ?? this.trip,
      trips: trips ?? this.trips,
      currencies: currencies ?? this.currencies,
      isRefreshingRate: isRefreshingRate ?? this.isRefreshingRate,
      isManagingTrips: isManagingTrips ?? this.isManagingTrips,
      isUsingCachedRate: isUsingCachedRate ?? this.isUsingCachedRate,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    trip,
    trips,
    currencies,
    isRefreshingRate,
    isManagingTrips,
    isUsingCachedRate,
    message,
  ];
}

class ActiveTripCubit extends Cubit<ActiveTripState> {
  ActiveTripCubit(this._tripRepository, this._exchangeRateRepository)
    : super(const ActiveTripState());

  final TripRepository _tripRepository;
  final ExchangeRateRepository _exchangeRateRepository;
  StreamSubscription<Trip>? _activeTripSubscription;
  StreamSubscription<List<Trip>>? _tripsSubscription;

  Future<void> initialize() async {
    emit(state.copyWith(status: ActiveTripStatus.loading, clearMessage: true));
    await _tripRepository.ensureDefaultTrip();
    await _activeTripSubscription?.cancel();
    await _tripsSubscription?.cancel();
    _activeTripSubscription = _tripRepository.watchActiveTrip().listen(
      (trip) =>
          emit(state.copyWith(status: ActiveTripStatus.ready, trip: trip)),
      onError: (Object error) => emit(
        state.copyWith(
          status: ActiveTripStatus.failure,
          message: error.toString(),
        ),
      ),
    );
    _tripsSubscription = _tripRepository.watchTrips().listen(
      (trips) => emit(state.copyWith(trips: trips)),
      onError: (Object error) =>
          emit(state.copyWith(message: error.toString())),
    );
    final trip = await _tripRepository.getActiveTrip();
    final trips = await _tripRepository.getTrips();
    emit(
      state.copyWith(status: ActiveTripStatus.ready, trip: trip, trips: trips),
    );
    // Kurs dikunci saat trip dibuat. Trip tanpa kurs hanya dapat terjadi pada
    // trip default/legacy yang baru dibuat, sehingga perlu diinisialisasi sekali.
    if (!trip.hasRate) {
      await refreshRate();
    }
  }

  Future<void> loadCurrencies() async {
    final currencies = await _exchangeRateRepository.getCurrencies();
    emit(state.copyWith(currencies: currencies));
  }

  Future<bool> createTrip({
    required String name,
    required CurrencyOption currency,
  }) async {
    if (state.isManagingTrips || name.trim().isEmpty) return false;
    emit(
      state.copyWith(
        isManagingTrips: true,
        isRefreshingRate: true,
        clearMessage: true,
      ),
    );
    try {
      final quote = await _exchangeRateRepository.getLatestRate(currency.code);
      final created = await _tripRepository.createTrip(
        NewTrip(
          name: name.trim(),
          currencyCode: currency.code,
          currencyName: currency.name,
          currencySymbol: currency.symbol,
          rateMicros: quote.rateMicros,
          rateDate: quote.rateDate,
          rateFetchedAt: quote.fetchedAt,
        ),
      );
      emit(
        state.copyWith(
          trip: created,
          isManagingTrips: false,
          isRefreshingRate: false,
          isUsingCachedRate: quote.fromCache,
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          isManagingTrips: false,
          isRefreshingRate: false,
          message: error.toString(),
        ),
      );
      return false;
    }
  }

  Future<void> selectTrip(String id) async {
    if (state.isManagingTrips || state.trip?.id == id) return;
    emit(state.copyWith(isManagingTrips: true, clearMessage: true));
    try {
      await _tripRepository.setActiveTrip(id);
      final trip = await _tripRepository.getActiveTrip();
      emit(state.copyWith(trip: trip, isManagingTrips: false));
      if (!trip.hasRate) await refreshRate();
    } catch (error) {
      emit(state.copyWith(isManagingTrips: false, message: error.toString()));
    }
  }

  Future<bool> deleteTrip(String id) async {
    if (state.isManagingTrips || state.trips.length <= 1) return false;
    emit(state.copyWith(isManagingTrips: true, clearMessage: true));
    try {
      await _tripRepository.deleteTrip(id);
      final trip = await _tripRepository.getActiveTrip();
      final trips = await _tripRepository.getTrips();
      emit(state.copyWith(trip: trip, trips: trips, isManagingTrips: false));
      if (!trip.hasRate) await refreshRate();
      return true;
    } catch (error) {
      emit(state.copyWith(isManagingTrips: false, message: error.toString()));
      return false;
    }
  }

  Future<void> changeCurrency(CurrencyOption currency) async {
    final trip = state.trip;
    if (trip == null || state.isRefreshingRate) return;
    emit(state.copyWith(isRefreshingRate: true, clearMessage: true));
    try {
      final quote = await _exchangeRateRepository.getLatestRate(currency.code);
      final updatedTrip = trip.copyWith(
        currencyCode: currency.code,
        currencyName: currency.name,
        currencySymbol: currency.symbol,
        rateMicros: quote.rateMicros,
        rateDate: quote.rateDate,
        rateFetchedAt: quote.fetchedAt,
      );
      await _tripRepository.updateTrip(updatedTrip);
      emit(
        state.copyWith(
          trip: updatedTrip,
          isRefreshingRate: false,
          isUsingCachedRate: quote.fromCache,
          clearMessage: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isRefreshingRate: false, message: error.toString()));
    }
  }

  Future<void> refreshRate() async {
    final trip = state.trip ?? await _tripRepository.getActiveTrip();
    final option = CurrencyOption(
      code: trip.currencyCode,
      name: trip.currencyName,
      symbol: trip.currencySymbol,
    );
    await changeCurrency(option);
  }

  Future<bool> saveSettings({
    required String name,
    required CurrencyOption currency,
    required double markupPercent,
    required int fixedFeeIdr,
    required int roundingUnitIdr,
  }) async {
    final trip = state.trip;
    if (trip == null || state.isManagingTrips) return false;
    final currencyChanged = currency.code != trip.currencyCode;
    emit(
      state.copyWith(
        isManagingTrips: true,
        isRefreshingRate: currencyChanged,
        clearMessage: true,
      ),
    );
    try {
      var updatedTrip = trip.copyWith(
        name: name.trim().isEmpty ? trip.name : name.trim(),
        markupBasisPoints: (markupPercent * 100).round(),
        fixedFeeIdr: fixedFeeIdr,
        roundingUnitIdr: roundingUnitIdr,
      );
      var usingCachedRate = state.isUsingCachedRate;
      if (currencyChanged) {
        final quote = await _exchangeRateRepository.getLatestRate(
          currency.code,
        );
        updatedTrip = updatedTrip.copyWith(
          currencyCode: currency.code,
          currencyName: currency.name,
          currencySymbol: currency.symbol,
          rateMicros: quote.rateMicros,
          rateDate: quote.rateDate,
          rateFetchedAt: quote.fetchedAt,
        );
        usingCachedRate = quote.fromCache;
      }
      await _tripRepository.updateTrip(updatedTrip);
      emit(
        state.copyWith(
          trip: updatedTrip,
          isManagingTrips: false,
          isRefreshingRate: false,
          isUsingCachedRate: usingCachedRate,
          clearMessage: true,
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          isManagingTrips: false,
          isRefreshingRate: false,
          message: error.toString(),
        ),
      );
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _activeTripSubscription?.cancel();
    await _tripsSubscription?.cancel();
    return super.close();
  }
}
