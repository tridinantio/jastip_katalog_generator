import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/domain/entities/product.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../domain/entities/shopping_request.dart';
import '../../domain/repositories/shopping_repository.dart';

enum BuyerDataStatus { initial, loading, ready, failure }

class BuyerDataItem extends Equatable {
  const BuyerDataItem({required this.productName, required this.request});

  final String productName;
  final ShoppingRequest request;

  @override
  List<Object> get props => [productName, request];
}

class BuyerDataGroup extends Equatable {
  const BuyerDataGroup({required this.name, required this.items});

  final String name;
  final List<BuyerDataItem> items;

  int get purchasedItemCount =>
      items.where((item) => item.request.isPurchased).length;
  int get pendingItemCount => items.length - purchasedItemCount;
  int get totalQuantity =>
      items.fold<int>(0, (sum, item) => sum + item.request.quantity);

  @override
  List<Object> get props => [name, items];
}

class BuyerDataState extends Equatable {
  const BuyerDataState({
    this.status = BuyerDataStatus.initial,
    this.buyers = const [],
    this.message,
  });

  final BuyerDataStatus status;
  final List<BuyerDataGroup> buyers;
  final String? message;

  BuyerDataState copyWith({
    BuyerDataStatus? status,
    List<BuyerDataGroup>? buyers,
    String? message,
    bool clearMessage = false,
  }) => BuyerDataState(
    status: status ?? this.status,
    buyers: buyers ?? this.buyers,
    message: clearMessage ? null : message ?? this.message,
  );

  @override
  List<Object?> get props => [status, buyers, message];
}

class BuyerDataCubit extends Cubit<BuyerDataState> {
  BuyerDataCubit(this._productRepository, this._shoppingRepository)
    : super(const BuyerDataState());

  final ProductRepository _productRepository;
  final ShoppingRepository _shoppingRepository;
  StreamSubscription<List<ProductSummary>>? _productsSubscription;
  StreamSubscription<List<ShoppingRequest>>? _requestsSubscription;
  List<ProductSummary> _products = const [];
  List<ShoppingRequest> _requests = const [];
  String? _tripId;

  Future<void> watchTrip(String tripId) async {
    if (_tripId == tripId && _productsSubscription != null) return;
    _tripId = tripId;
    _products = const [];
    _requests = const [];
    emit(
      state.copyWith(
        status: BuyerDataStatus.loading,
        buyers: const [],
        clearMessage: true,
      ),
    );
    await _productsSubscription?.cancel();
    await _requestsSubscription?.cancel();
    final watchedTripId = tripId;
    _productsSubscription = _productRepository
        .watchProducts(tripId)
        .listen(
          (products) {
            if (_tripId != watchedTripId) return;
            _products = products;
            _emitBuyers();
          },
          onError: (Object error) {
            if (_tripId == watchedTripId) _handleError(error);
          },
        );
    _requestsSubscription = _shoppingRepository
        .watchRequestsForTrip(tripId)
        .listen(
          (requests) {
            if (_tripId != watchedTripId) return;
            _requests = requests;
            _emitBuyers();
          },
          onError: (Object error) {
            if (_tripId == watchedTripId) _handleError(error);
          },
        );
  }

  void _emitBuyers() {
    final productsById = {for (final product in _products) product.id: product};
    final groups = <String, _BuyerGroupBuilder>{};
    for (final request in _requests) {
      final normalizedName = request.buyerName.trim().toLowerCase();
      if (normalizedName.isEmpty) continue;
      final group = groups.putIfAbsent(
        normalizedName,
        () => _BuyerGroupBuilder(request.buyerName.trim()),
      );
      group.items.add(
        BuyerDataItem(
          productName:
              productsById[request.productId]?.name ?? 'Produk dihapus',
          request: request,
        ),
      );
    }
    final buyers =
        groups.values.map((group) {
          group.items.sort(
            (a, b) => b.request.createdAt.compareTo(a.request.createdAt),
          );
          return BuyerDataGroup(
            name: group.name,
            items: List.unmodifiable(group.items),
          );
        }).toList()..sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    emit(
      state.copyWith(
        status: BuyerDataStatus.ready,
        buyers: List.unmodifiable(buyers),
        clearMessage: true,
      ),
    );
  }

  void _handleError(Object error) => emit(
    state.copyWith(
      status: BuyerDataStatus.failure,
      message: 'Data pembeli gagal dimuat: $error',
    ),
  );

  @override
  Future<void> close() async {
    await _productsSubscription?.cancel();
    await _requestsSubscription?.cancel();
    return super.close();
  }
}

class _BuyerGroupBuilder {
  _BuyerGroupBuilder(this.name);

  final String name;
  final List<BuyerDataItem> items = [];
}
