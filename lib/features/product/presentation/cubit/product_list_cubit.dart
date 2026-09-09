import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../shopping/domain/entities/shopping_request.dart';
import '../../../shopping/domain/repositories/shopping_repository.dart';

enum ProductListStatus { initial, loading, ready, failure }

enum ProductPurchaseFilter { all, withoutBuyer, pending, purchased }

enum ProductLocationFilter { all, withLocation, withoutLocation }

class ProductListFilter extends Equatable {
  const ProductListFilter({
    this.category,
    this.purchase = ProductPurchaseFilter.all,
    this.location = ProductLocationFilter.all,
  });

  final String? category;
  final ProductPurchaseFilter purchase;
  final ProductLocationFilter location;

  bool get isDefault =>
      category == null &&
      purchase == ProductPurchaseFilter.all &&
      location == ProductLocationFilter.all;

  int get activeCount =>
      (category == null ? 0 : 1) +
      (purchase == ProductPurchaseFilter.all ? 0 : 1) +
      (location == ProductLocationFilter.all ? 0 : 1);

  @override
  List<Object?> get props => [category, purchase, location];
}

class ProductListState extends Equatable {
  const ProductListState({
    this.status = ProductListStatus.initial,
    this.products = const [],
    this.allProducts = const [],
    this.query = '',
    this.filter = const ProductListFilter(),
    this.deletingProductId,
    this.message,
    this.progressByProductId = const {},
  });

  final ProductListStatus status;
  final List<ProductSummary> products;
  final List<ProductSummary> allProducts;
  final String query;
  final ProductListFilter filter;
  final String? deletingProductId;
  final String? message;
  final Map<String, ShoppingProgress> progressByProductId;

  ProductListState copyWith({
    ProductListStatus? status,
    List<ProductSummary>? products,
    List<ProductSummary>? allProducts,
    String? query,
    ProductListFilter? filter,
    String? deletingProductId,
    String? message,
    bool clearDeleting = false,
    bool clearMessage = false,
    Map<String, ShoppingProgress>? progressByProductId,
  }) => ProductListState(
    status: status ?? this.status,
    products: products ?? this.products,
    allProducts: allProducts ?? this.allProducts,
    query: query ?? this.query,
    filter: filter ?? this.filter,
    deletingProductId: clearDeleting
        ? null
        : deletingProductId ?? this.deletingProductId,
    message: clearMessage ? null : message ?? this.message,
    progressByProductId: progressByProductId ?? this.progressByProductId,
  );

  @override
  List<Object?> get props => [
    status,
    products,
    allProducts,
    query,
    filter,
    deletingProductId,
    message,
    progressByProductId,
  ];
}

class ProductListCubit extends Cubit<ProductListState> {
  ProductListCubit(this._repository, this._shoppingRepository)
    : super(const ProductListState());

  final ProductRepository _repository;
  final ShoppingRepository _shoppingRepository;
  StreamSubscription<List<ProductSummary>>? _subscription;
  StreamSubscription<Map<String, ShoppingProgress>>? _progressSubscription;
  String? _tripId;

  Future<void> watchTrip(String tripId) async {
    if (_tripId == tripId && _subscription != null) return;
    _tripId = tripId;
    emit(
      state.copyWith(
        products: const [],
        allProducts: const [],
        filter: const ProductListFilter(),
        progressByProductId: const {},
      ),
    );
    await _listen();
    await _listenProgress();
  }

  Future<void> search(String query) async {
    emit(state.copyWith(query: query));
    await _listen();
  }

  Future<void> _listen() async {
    final tripId = _tripId;
    if (tripId == null) return;
    emit(state.copyWith(status: ProductListStatus.loading, clearMessage: true));
    await _subscription?.cancel();
    _subscription = _repository
        .watchProducts(tripId, query: state.query)
        .listen(
          (products) => emit(
            state.copyWith(
              status: ProductListStatus.ready,
              allProducts: products,
              products: _filterProducts(
                products,
                state.filter,
                state.progressByProductId,
              ),
            ),
          ),
          onError: (Object error) => emit(
            state.copyWith(
              status: ProductListStatus.failure,
              message: error.toString(),
            ),
          ),
        );
  }

  Future<void> _listenProgress() async {
    final tripId = _tripId;
    if (tripId == null) return;
    await _progressSubscription?.cancel();
    _progressSubscription = _shoppingRepository
        .watchProgress(tripId)
        .listen(
          (progress) => emit(
            state.copyWith(
              progressByProductId: progress,
              products: _filterProducts(
                state.allProducts,
                state.filter,
                progress,
              ),
            ),
          ),
          onError: (Object error) =>
              emit(state.copyWith(message: 'Checklist gagal dimuat: $error')),
        );
  }

  void setFilter(ProductListFilter filter) {
    emit(
      state.copyWith(
        filter: filter,
        products: _filterProducts(
          state.allProducts,
          filter,
          state.progressByProductId,
        ),
      ),
    );
  }

  void clearFilter() => setFilter(const ProductListFilter());

  Future<bool> deleteProduct(String productId) async {
    if (state.deletingProductId != null) return false;
    emit(state.copyWith(deletingProductId: productId, clearMessage: true));
    try {
      await _repository.deleteProduct(productId);
      emit(state.copyWith(clearDeleting: true));
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          clearDeleting: true,
          message: 'Produk gagal dihapus: $error',
        ),
      );
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _progressSubscription?.cancel();
    return super.close();
  }
}

List<ProductSummary> _filterProducts(
  List<ProductSummary> products,
  ProductListFilter filter,
  Map<String, ShoppingProgress> progressByProductId,
) {
  return products
      .where((product) {
        if (filter.category != null && product.category != filter.category) {
          return false;
        }
        if (filter.location == ProductLocationFilter.withLocation &&
            !product.hasLocation) {
          return false;
        }
        if (filter.location == ProductLocationFilter.withoutLocation &&
            product.hasLocation) {
          return false;
        }
        final progress = progressByProductId[product.id];
        final total = progress?.totalRequests ?? 0;
        final purchased = progress?.purchasedRequests ?? 0;
        switch (filter.purchase) {
          case ProductPurchaseFilter.all:
            return true;
          case ProductPurchaseFilter.withoutBuyer:
            return total == 0;
          case ProductPurchaseFilter.pending:
            return total > 0 && purchased < total;
          case ProductPurchaseFilter.purchased:
            return total > 0 && purchased == total;
        }
      })
      .toList(growable: false);
}
