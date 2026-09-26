import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/features/product/domain/entities/product.dart';
import 'package:jastip_katalog_generator/features/product/domain/repositories/product_repository.dart';
import 'package:jastip_katalog_generator/features/product/presentation/cubit/product_list_cubit.dart';
import 'package:jastip_katalog_generator/features/shopping/domain/entities/shopping_request.dart';
import 'package:jastip_katalog_generator/features/shopping/domain/repositories/shopping_repository.dart';

void main() {
  test('filter produk menggabungkan kategori, checklist, dan lokasi', () async {
    final products = _FakeProductRepository();
    final shopping = _FakeShoppingRepository();
    final cubit = ProductListCubit(products, shopping);
    addTearDown(cubit.close);
    addTearDown(products.productsController.close);
    addTearDown(shopping.progressController.close);

    await cubit.watchTrip('trip-1');
    products.productsController.add([
      _product('p1', 'Snack Jepang', 'Makanan', hasLocation: true),
      _product('p2', 'Jaket', 'Fashion'),
      _product('p3', 'Permen', 'Makanan'),
    ]);
    shopping.progressController.add({
      'p1': const ShoppingProgress(
        productId: 'p1',
        totalRequests: 2,
        purchasedRequests: 1,
      ),
      'p2': const ShoppingProgress(
        productId: 'p2',
        totalRequests: 1,
        purchasedRequests: 1,
      ),
    });
    await Future<void>.delayed(Duration.zero);

    cubit.setFilter(const ProductListFilter(category: 'Makanan'));
    expect(cubit.state.products.map((product) => product.id), ['p1', 'p3']);

    cubit.setFilter(
      const ProductListFilter(purchase: ProductPurchaseFilter.pending),
    );
    expect(cubit.state.products.map((product) => product.id), ['p1']);

    cubit.setFilter(
      const ProductListFilter(location: ProductLocationFilter.withoutLocation),
    );
    expect(cubit.state.products.map((product) => product.id), ['p2', 'p3']);
  });
}

ProductSummary _product(
  String id,
  String name,
  String category, {
  bool hasLocation = false,
}) => ProductSummary(
  id: id,
  tripId: 'trip-1',
  name: name,
  originalPriceMinor: 100,
  sellingPriceIdr: 100000,
  thumbnailBytes: Uint8List(0),
  createdAt: DateTime(2026, 9, 8),
  category: category,
  hasLocation: hasLocation,
);

class _FakeProductRepository implements ProductRepository {
  final productsController = StreamController<List<ProductSummary>>.broadcast();

  @override
  Stream<List<ProductSummary>> watchProducts(
    String tripId, {
    String query = '',
  }) => productsController.stream;

  @override
  Future<Product> getProduct(String id) => throw UnimplementedError();

  @override
  Future<List<String>> getLocationLabels(String tripId) =>
      throw UnimplementedError();

  @override
  Future<String> createProduct(NewProduct product) =>
      throw UnimplementedError();

  @override
  Future<void> updateProduct(String id, NewProduct product) =>
      throw UnimplementedError();

  @override
  Future<void> deleteProduct(String id) => throw UnimplementedError();

  @override
  Future<void> saveGeneratedAsset({
    required String productId,
    required Uint8List pngBytes,
    required int backgroundColor,
  }) => throw UnimplementedError();
}

class _FakeShoppingRepository implements ShoppingRepository {
  final progressController =
      StreamController<Map<String, ShoppingProgress>>.broadcast();

  @override
  Stream<Map<String, ShoppingProgress>> watchProgress(String tripId) =>
      progressController.stream;

  @override
  Stream<List<ShoppingRequest>> watchRequests(String productId) =>
      const Stream.empty();

  @override
  Stream<List<ShoppingRequest>> watchRequestsForTrip(String tripId) =>
      const Stream.empty();

  @override
  Future<List<String>> getBuyerNames(String tripId) =>
      throw UnimplementedError();

  @override
  Future<String> addRequest(NewShoppingRequest request) =>
      throw UnimplementedError();

  @override
  Future<void> setPurchased(String requestId, bool isPurchased) =>
      throw UnimplementedError();

  @override
  Future<void> setPurchasedForProduct(
    String tripId,
    String productId,
    bool isPurchased,
  ) => throw UnimplementedError();

  @override
  Future<void> deleteRequest(String requestId) => throw UnimplementedError();
}
