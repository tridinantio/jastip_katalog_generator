import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_location.dart';
import '../../domain/repositories/product_repository.dart';
import '../data_sources/product_local_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._localDataSource);

  final ProductLocalDataSource _localDataSource;

  @override
  Stream<List<ProductSummary>> watchProducts(
    String tripId, {
    String query = '',
  }) => _localDataSource
      .watchProducts(tripId, query: query)
      .map(
        (records) => records
            .map(
              (record) => ProductSummary(
                id: record.id,
                tripId: record.tripId,
                name: record.name,
                originalPriceMinor: record.originalPriceMinor,
                sellingPriceIdr: record.sellingPriceIdr,
                markupBasisPointsOverride: record.markupBasisPointsOverride,
                fixedFeeIdrOverride: record.fixedFeeIdrOverride,
                weightGrams: record.weightGrams,
                thumbnailBytes: record.thumbnailBytes,
                createdAt: record.createdAt,
                category: record.category,
                hasLocation: record.hasLocation,
              ),
            )
            .toList(growable: false),
      );

  @override
  Future<String> createProduct(NewProduct product) async {
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    await _localDataSource.insertProduct(
      ProductsCompanion.insert(
        id: id,
        tripId: product.tripId,
        name: product.name,
        originalPriceMinor: product.originalPriceMinor,
        sellingPriceIdr: product.sellingPriceIdr,
        markupBasisPointsOverride: Value(product.markupBasisPointsOverride),
        fixedFeeIdrOverride: Value(product.fixedFeeIdrOverride),
        weightGrams: Value(product.weightGrams),
        note: Value(product.note),
        category: Value(product.category),
        imageBytes: product.imageBytes,
        thumbnailBytes: product.thumbnailBytes,
        imageMimeType: product.imageMimeType,
        latitude: Value(product.location?.latitude),
        longitude: Value(product.location?.longitude),
        locationLabel: Value(product.location?.label),
        locationCapturedAt: Value(product.location?.capturedAt),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }

  @override
  Future<void> updateProduct(String id, NewProduct product) async {
    final updatedRows = await _localDataSource.updateProduct(
      id,
      ProductsCompanion(
        tripId: Value(product.tripId),
        name: Value(product.name),
        originalPriceMinor: Value(product.originalPriceMinor),
        sellingPriceIdr: Value(product.sellingPriceIdr),
        markupBasisPointsOverride: Value(product.markupBasisPointsOverride),
        fixedFeeIdrOverride: Value(product.fixedFeeIdrOverride),
        weightGrams: Value(product.weightGrams),
        note: Value(product.note),
        category: Value(product.category),
        imageBytes: Value(product.imageBytes),
        thumbnailBytes: Value(product.thumbnailBytes),
        imageMimeType: Value(product.imageMimeType),
        latitude: Value(product.location?.latitude),
        longitude: Value(product.location?.longitude),
        locationLabel: Value(product.location?.label),
        locationCapturedAt: Value(product.location?.capturedAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (updatedRows == 0) {
      throw StateError('Produk tidak ditemukan.');
    }
  }

  @override
  Future<void> deleteProduct(String id) => _localDataSource.deleteProduct(id);

  @override
  Future<Product> getProduct(String id) async {
    final record = await _localDataSource.getProduct(id);
    return Product(
      id: record.id,
      tripId: record.tripId,
      name: record.name,
      originalPriceMinor: record.originalPriceMinor,
      sellingPriceIdr: record.sellingPriceIdr,
      markupBasisPointsOverride: record.markupBasisPointsOverride,
      fixedFeeIdrOverride: record.fixedFeeIdrOverride,
      weightGrams: record.weightGrams,
      note: record.note,
      category: record.category,
      imageBytes: record.imageBytes,
      thumbnailBytes: record.thumbnailBytes,
      imageMimeType: record.imageMimeType,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      location:
          record.latitude == null ||
              record.longitude == null ||
              record.locationCapturedAt == null
          ? null
          : ProductLocation(
              latitude: record.latitude!,
              longitude: record.longitude!,
              capturedAt: record.locationCapturedAt!,
              label: record.locationLabel,
            ),
    );
  }

  @override
  Future<List<String>> getLocationLabels(String tripId) =>
      _localDataSource.getLocationLabels(tripId);

  @override
  Future<void> saveGeneratedAsset({
    required String productId,
    required Uint8List pngBytes,
    required int backgroundColor,
  }) async {
    final now = DateTime.now();
    await _localDataSource.insertGeneratedAsset(
      GeneratedAssetsCompanion.insert(
        id: now.microsecondsSinceEpoch.toString(),
        productId: productId,
        pngBytes: pngBytes,
        backgroundColor: backgroundColor,
        createdAt: now,
      ),
    );
  }
}
