import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/features/product/domain/entities/product.dart';
import 'package:jastip_katalog_generator/features/product/domain/repositories/product_repository.dart';
import 'package:jastip_katalog_generator/features/shopping/domain/entities/shopping_request.dart';
import 'package:jastip_katalog_generator/features/shopping/domain/repositories/shopping_repository.dart';
import 'package:jastip_katalog_generator/features/shopping/presentation/cubit/buyer_data_cubit.dart';

void main() {
  test(
    'mengelompokkan titipan per pembeli dan memisahkan status beli',
    () async {
      final products = StreamController<List<ProductSummary>>();
      final requests = StreamController<List<ShoppingRequest>>();
      final cubit = BuyerDataCubit(
        _FakeProductRepository(products.stream),
        _FakeShoppingRepository(requests.stream),
      );
      addTearDown(() async {
        await cubit.close();
        await products.close();
        await requests.close();
      });

      await cubit.watchTrip('trip-1');
      final ready = cubit.stream.firstWhere(
        (state) =>
            state.status == BuyerDataStatus.ready && state.buyers.length == 2,
      );
      products.add([
        _product('product-1', 'Matcha'),
        _product('product-2', 'Lip Balm', sellingPriceIdr: 17500),
      ]);
      requests.add([
        _request(
          'request-1',
          ' Rina ',
          'product-1',
          quantity: 2,
          isPurchased: true,
        ),
        _request('request-2', 'rina', 'product-2', quantity: 3),
        _request('request-3', 'Dina', 'product-1'),
        _request('request-4', 'Dina', 'deleted-product'),
      ]);

      final state = await ready;
      final rina = state.buyers.firstWhere((buyer) => buyer.name == 'Rina');
      expect(rina.items, hasLength(2));
      expect(rina.purchasedItemCount, 1);
      expect(rina.pendingItemCount, 1);
      expect(rina.totalAmountIdr, 74500);
      final dina = state.buyers.firstWhere((buyer) => buyer.name == 'Dina');
      expect(dina.totalAmountIdr, isNull);
      expect(
        rina.items.map((item) => item.productName),
        containsAll(['Matcha', 'Lip Balm']),
      );
    },
  );
}

ProductSummary _product(
  String id,
  String name, {
  int sellingPriceIdr = 11000,
}) => ProductSummary(
  id: id,
  tripId: 'trip-1',
  name: name,
  originalPriceMinor: 10000,
  sellingPriceIdr: sellingPriceIdr,
  thumbnailBytes: Uint8List.fromList([1]),
  createdAt: DateTime(2026, 9, 8),
);

ShoppingRequest _request(
  String id,
  String buyerName,
  String productId, {
  int quantity = 1,
  bool isPurchased = false,
}) => ShoppingRequest(
  id: id,
  tripId: 'trip-1',
  productId: productId,
  buyerName: buyerName,
  quantity: quantity,
  note: '',
  isPurchased: isPurchased,
  purchasedAt: null,
  createdAt: DateTime(2026, 9, 8),
  updatedAt: DateTime(2026, 9, 8),
);

class _FakeProductRepository implements ProductRepository {
  const _FakeProductRepository(this._products);

  final Stream<List<ProductSummary>> _products;

  @override
  Future<String> createProduct(NewProduct product) =>
      throw UnimplementedError();

  @override
  Future<void> deleteProduct(String id) => throw UnimplementedError();

  @override
  Future<Product> getProduct(String id) => throw UnimplementedError();

  @override
  Future<List<String>> getLocationLabels(String tripId) async => const [];

  @override
  Future<void> saveGeneratedAsset({
    required String productId,
    required Uint8List pngBytes,
    required int backgroundColor,
  }) => throw UnimplementedError();

  @override
  Future<void> updateProduct(String id, NewProduct product) =>
      throw UnimplementedError();

  @override
  Stream<List<ProductSummary>> watchProducts(
    String tripId, {
    String query = '',
  }) => _products;
}

class _FakeShoppingRepository implements ShoppingRepository {
  const _FakeShoppingRepository(this._requests);

  final Stream<List<ShoppingRequest>> _requests;

  @override
  Future<String> addRequest(NewShoppingRequest request) =>
      throw UnimplementedError();

  @override
  Future<void> updateRequest(ShoppingRequest request) =>
      throw UnimplementedError();

  @override
  Future<void> deleteRequest(String requestId) => throw UnimplementedError();

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
  Future<List<String>> getBuyerNames(String tripId) async => const [];

  @override
  Stream<Map<String, ShoppingProgress>> watchProgress(String tripId) =>
      const Stream.empty();

  @override
  Stream<List<ShoppingRequest>> watchRequests(String productId) =>
      const Stream.empty();

  @override
  Stream<List<ShoppingRequest>> watchRequestsForTrip(String tripId) =>
      _requests;
}
