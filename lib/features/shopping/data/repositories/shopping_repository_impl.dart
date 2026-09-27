import 'dart:math';

import '../../domain/entities/shopping_request.dart';
import '../../domain/repositories/shopping_repository.dart';
import '../data_sources/shopping_local_data_source.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  const ShoppingRepositoryImpl(this._localDataSource);

  final ShoppingLocalDataSource _localDataSource;
  static final _random = Random.secure();

  @override
  Stream<List<ShoppingRequest>> watchRequests(String productId) =>
      _localDataSource
          .watchRequests(productId)
          .map((records) => records.map(_mapRequest).toList(growable: false));

  @override
  Stream<List<ShoppingRequest>> watchRequestsForTrip(String tripId) =>
      _localDataSource
          .watchTripRequests(tripId)
          .map((records) => records.map(_mapRequest).toList(growable: false));

  @override
  Stream<Map<String, ShoppingProgress>> watchProgress(String tripId) =>
      _localDataSource.watchTripRequests(tripId).map((records) {
        final grouped = <String, List<ShoppingRequestRow>>{};
        for (final record in records) {
          grouped.putIfAbsent(record.productId, () => []).add(record);
        }
        return Map.unmodifiable(
          grouped.map(
            (productId, requests) => MapEntry(
              productId,
              ShoppingProgress(
                productId: productId,
                totalRequests: requests.length,
                purchasedRequests: requests
                    .where((request) => request.isPurchased)
                    .length,
              ),
            ),
          ),
        );
      });

  @override
  Future<List<String>> getBuyerNames(String tripId) =>
      _localDataSource.getBuyerNames(tripId);

  @override
  Future<String> addRequest(NewShoppingRequest request) async {
    final now = DateTime.now();
    final id = '${now.microsecondsSinceEpoch}_${_random.nextInt(0x7fffffff)}';
    await _localDataSource.insertRequest(
      id: id,
      tripId: request.tripId,
      productId: request.productId,
      buyerName: request.buyerName,
      quantity: request.quantity,
      note: request.note,
      createdAt: now,
      updatedAt: now,
    );
    return id;
  }

  @override
  Future<void> updateRequest(ShoppingRequest request) async {
    final updated = await _localDataSource.updateRequest(
      id: request.id,
      buyerName: request.buyerName,
      quantity: request.quantity,
      note: request.note,
      updatedAt: DateTime.now(),
    );
    if (updated == 0) throw StateError('Permintaan pembelian tidak ditemukan.');
  }

  @override
  Future<void> setPurchased(String requestId, bool isPurchased) async {
    final updated = await _localDataSource.updatePurchaseStatus(
      requestId,
      isPurchased,
      isPurchased ? DateTime.now() : null,
    );
    if (updated == 0) throw StateError('Permintaan pembelian tidak ditemukan.');
  }

  @override
  Future<void> setPurchasedForProduct(
    String tripId,
    String productId,
    bool isPurchased,
  ) async {
    final updated = await _localDataSource.updatePurchaseStatusForProduct(
      tripId,
      productId,
      isPurchased,
      isPurchased ? DateTime.now() : null,
    );
    if (updated == 0) throw StateError('Produk belanja tidak ditemukan.');
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    final deleted = await _localDataSource.deleteRequest(requestId);
    if (deleted == 0) throw StateError('Permintaan pembelian tidak ditemukan.');
  }

  ShoppingRequest _mapRequest(ShoppingRequestRow record) => ShoppingRequest(
    id: record.id,
    tripId: record.tripId,
    productId: record.productId,
    buyerName: record.buyerName,
    quantity: record.quantity,
    note: record.note,
    isPurchased: record.isPurchased,
    purchasedAt: record.purchasedAt,
    createdAt: record.createdAt,
    updatedAt: record.updatedAt,
  );
}
