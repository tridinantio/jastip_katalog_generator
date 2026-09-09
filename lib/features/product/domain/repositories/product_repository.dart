import 'dart:typed_data';

import '../entities/product.dart';

abstract interface class ProductRepository {
  Stream<List<ProductSummary>> watchProducts(
    String tripId, {
    String query = '',
  });
  Future<Product> getProduct(String id);
  Future<List<String>> getLocationLabels(String tripId);
  Future<String> createProduct(NewProduct product);
  Future<void> updateProduct(String id, NewProduct product);
  Future<void> deleteProduct(String id);
  Future<void> saveGeneratedAsset({
    required String productId,
    required Uint8List pngBytes,
    required int backgroundColor,
  });
}
