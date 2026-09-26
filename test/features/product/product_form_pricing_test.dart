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
  test(
    'field margin dan biaya tetap kosong dihitung dan disimpan sebagai nol',
    () async {
      final repository = _FakeProductRepository();
      final cubit = ProductFormCubit(
        _FakeProductImagePicker(),
        _FakeLocationService(),
        trip: _trip,
        productRepository: repository,
      );
      addTearDown(cubit.close);

      cubit.nameChanged('Lip Balm');
      cubit.priceChanged('100');
      cubit.customPricingChanged(true);
      cubit.markupChanged('');
      cubit.fixedFeeChanged('');

      expect(cubit.state.priceBreakdown, isNotNull);
      expect(cubit.state.priceBreakdown!.percentageFeeIdr, 0);
      expect(cubit.state.priceBreakdown!.fixedFeeIdr, 0);

      final image = await cubit.pickImage(ImagePickSource.gallery);
      await cubit.applyCroppedImage(
        image!.originalBytes,
        mimeType: image.mimeType,
      );
      await cubit.submit();

      expect(repository.createdProduct, isNotNull);
      expect(repository.createdProduct!.markupBasisPointsOverride, 0);
      expect(repository.createdProduct!.fixedFeeIdrOverride, 0);
    },
  );
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

class _FakeProductImagePicker implements ProductImagePicker {
  @override
  Future<PickedProductImage?> pick(ImagePickSource source) async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    return PickedProductImage(
      originalBytes: bytes,
      thumbnailBytes: bytes,
      mimeType: 'image/jpeg',
    );
  }

  @override
  Future<PickedProductImage> prepare(
    Uint8List originalBytes, {
    required String mimeType,
  }) async => PickedProductImage(
    originalBytes: originalBytes,
    thumbnailBytes: originalBytes,
    mimeType: mimeType,
  );
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

  @override
  Future<String> createProduct(NewProduct product) async {
    createdProduct = product;
    return 'product-1';
  }

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
  }) => const Stream.empty();
}
