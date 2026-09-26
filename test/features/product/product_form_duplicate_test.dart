import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/features/product/domain/entities/product.dart';
import 'package:jastip_katalog_generator/features/product/domain/entities/product_location.dart';
import 'package:jastip_katalog_generator/features/product/domain/repositories/product_repository.dart';
import 'package:jastip_katalog_generator/features/product/domain/services/image_services.dart';
import 'package:jastip_katalog_generator/features/product/domain/services/location_services.dart';
import 'package:jastip_katalog_generator/features/product/presentation/cubit/product_form_cubit.dart';
import 'package:jastip_katalog_generator/features/trip/domain/entities/trip.dart';

void main() {
  test('duplikat produk membuat produk baru dengan data produk asal', () async {
    final repository = _FakeProductRepository();
    final cubit = ProductFormCubit(
      _FakeProductImagePicker(),
      _FakeLocationService(),
      trip: _trip,
      productRepository: repository,
      duplicateProductId: 'product-1',
    );
    addTearDown(cubit.close);

    await cubit.initialize();

    expect(cubit.state.status, ProductFormStatus.editing);
    expect(cubit.state.name, 'Lip Balm (salinan)');
    expect(cubit.state.originalImageBytes, _sourceProduct.imageBytes);

    await cubit.submit();

    expect(repository.createdProduct, isNotNull);
    expect(repository.updatedProductId, isNull);
    expect(repository.createdProduct!.name, 'Lip Balm (salinan)');
    expect(repository.createdProduct!.tripId, _sourceProduct.tripId);
    expect(repository.createdProduct!.imageBytes, _sourceProduct.imageBytes);
    expect(repository.createdProduct!.weightGrams, _sourceProduct.weightGrams);
  });
}

final _trip = Trip(
  id: 'trip-1',
  name: 'Japan Trip',
  country: 'Jepang',
  currencyCode: 'JPY',
  currencyName: 'Japanese Yen',
  currencySymbol: '¥',
  rateMicros: 105000000,
  rateDate: DateTime(2026, 9, 5),
  rateFetchedAt: DateTime(2026, 9, 5),
  markupBasisPoints: 1500,
  fixedFeeIdr: 0,
  roundingUnitIdr: 1000,
);

final _sourceProduct = Product(
  id: 'product-1',
  tripId: 'trip-1',
  name: 'Lip Balm',
  originalPriceMinor: 10000,
  sellingPriceIdr: 11000,
  weightGrams: 120,
  note: 'Warna merah',
  category: 'Kosmetik',
  imageBytes: Uint8List.fromList([1, 2, 3]),
  thumbnailBytes: Uint8List.fromList([1, 2]),
  imageMimeType: 'image/jpeg',
  createdAt: DateTime(2026, 9, 5),
  updatedAt: DateTime(2026, 9, 5),
);

class _FakeProductImagePicker implements ProductImagePicker {
  @override
  Future<PickedProductImage?> pick(ImagePickSource source) =>
      throw UnimplementedError();

  @override
  Future<PickedProductImage> prepare(
    Uint8List originalBytes, {
    required String mimeType,
  }) => throw UnimplementedError();
}

class _FakeLocationService implements ProductLocationService {
  @override
  Future<ProductLocation> captureCurrentLocation() =>
      throw UnimplementedError();

  @override
  Future<bool> openInMaps(ProductLocation location) =>
      throw UnimplementedError();
}

class _FakeProductRepository implements ProductRepository {
  NewProduct? createdProduct;
  String? updatedProductId;

  @override
  Future<String> createProduct(NewProduct product) async {
    createdProduct = product;
    return 'product-2';
  }

  @override
  Future<void> deleteProduct(String id) => throw UnimplementedError();

  @override
  Future<Product> getProduct(String id) async => _sourceProduct;

  @override
  Future<List<String>> getLocationLabels(String tripId) async => const [];

  @override
  Future<void> saveGeneratedAsset({
    required String productId,
    required Uint8List pngBytes,
    required int backgroundColor,
  }) => throw UnimplementedError();

  @override
  Future<void> updateProduct(String id, NewProduct product) async {
    updatedProductId = id;
  }

  @override
  Stream<List<ProductSummary>> watchProducts(
    String tripId, {
    String query = '',
  }) => const Stream.empty();
}
