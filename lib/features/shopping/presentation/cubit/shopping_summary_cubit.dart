import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/domain/entities/product.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../domain/entities/shopping_request.dart';
import '../../domain/entities/shopping_summary.dart';
import '../../domain/repositories/shopping_repository.dart';
import '../../domain/use_cases/calculate_shopping_summary.dart';

enum ShoppingSummaryStatus { initial, loading, ready, failure }

class ShoppingSummaryState extends Equatable {
  const ShoppingSummaryState({
    this.status = ShoppingSummaryStatus.initial,
    this.summary = const ShoppingSummary.empty(),
    this.message,
  });

  final ShoppingSummaryStatus status;
  final ShoppingSummary summary;
  final String? message;

  ShoppingSummaryState copyWith({
    ShoppingSummaryStatus? status,
    ShoppingSummary? summary,
    String? message,
    bool clearMessage = false,
  }) => ShoppingSummaryState(
    status: status ?? this.status,
    summary: summary ?? this.summary,
    message: clearMessage ? null : message ?? this.message,
  );

  @override
  List<Object?> get props => [status, summary, message];
}

class ShoppingSummaryCubit extends Cubit<ShoppingSummaryState> {
  ShoppingSummaryCubit(this._productRepository, this._shoppingRepository)
    : super(const ShoppingSummaryState());

  final ProductRepository _productRepository;
  final ShoppingRepository _shoppingRepository;
  StreamSubscription<List<ProductSummary>>? _productsSubscription;
  StreamSubscription<List<ShoppingRequest>>? _requestsSubscription;
  Trip? _trip;
  List<ProductSummary> _products = const [];
  List<ShoppingRequest> _requests = const [];
  String? _tripId;

  Future<void> watchTrip(Trip trip) async {
    final tripChanged = _tripId != trip.id;
    _trip = trip;
    if (!tripChanged && _productsSubscription != null) {
      _emitSummary();
      return;
    }

    _tripId = trip.id;
    _products = const [];
    _requests = const [];
    emit(
      state.copyWith(
        status: ShoppingSummaryStatus.loading,
        summary: const ShoppingSummary.empty(),
        clearMessage: true,
      ),
    );
    await _productsSubscription?.cancel();
    await _requestsSubscription?.cancel();
    final watchedTripId = trip.id;
    _productsSubscription = _productRepository
        .watchProducts(trip.id)
        .listen(
          (products) {
            if (_tripId != watchedTripId) return;
            _products = products;
            _emitSummary();
          },
          onError: (Object error) {
            if (_tripId == watchedTripId) _handleError(error);
          },
        );
    _requestsSubscription = _shoppingRepository
        .watchRequestsForTrip(trip.id)
        .listen(
          (requests) {
            if (_tripId != watchedTripId) return;
            _requests = requests;
            _emitSummary();
          },
          onError: (Object error) {
            if (_tripId == watchedTripId) _handleError(error);
          },
        );
  }

  void _emitSummary() {
    final trip = _trip;
    if (trip == null) return;
    emit(
      state.copyWith(
        status: ShoppingSummaryStatus.ready,
        summary: CalculateShoppingSummary.call(
          products: _products,
          requests: _requests,
          trip: trip,
        ),
        clearMessage: true,
      ),
    );
  }

  void _handleError(Object error) {
    emit(
      state.copyWith(
        status: ShoppingSummaryStatus.failure,
        message: 'Rekap gagal dimuat: $error',
      ),
    );
  }

  @override
  Future<void> close() async {
    await _productsSubscription?.cancel();
    await _requestsSubscription?.cancel();
    return super.close();
  }
}
