import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/features/product/domain/entities/product.dart';
import 'package:jastip_katalog_generator/features/product/domain/entities/product_location.dart';
import 'package:jastip_katalog_generator/features/product/domain/repositories/product_repository.dart';
import 'package:jastip_katalog_generator/features/product/domain/services/image_services.dart';
import 'package:jastip_katalog_generator/features/product/domain/services/location_services.dart';
import 'package:jastip_katalog_generator/features/product/presentation/pages/product_form_page.dart';
import 'package:jastip_katalog_generator/features/trip/domain/entities/trip.dart';

void main() {
  testWidgets('ganti foto menyediakan kamera dan galeri', (tester) async {
    final picker = _FakeProductImagePicker();
    await tester.pumpWidget(
      MaterialApp(
        home: ProductFormPage(
          trip: _trip,
          productRepository: const _FakeProductRepository(),
          imagePicker: picker,
          locationService: _FakeProductLocationService(),
        ),
      ),
    );

    await tester.tap(find.text('Galeri'));
    await tester.pump();
    expect(find.text('Ganti foto'), findsOneWidget);

    await tester.tap(find.text('Ganti foto'));
    await tester.pumpAndSettle();
    expect(find.text('Ambil dari kamera'), findsOneWidget);
    expect(find.text('Pilih dari galeri'), findsOneWidget);

    await tester.tap(find.text('Ambil dari kamera'));
    await tester.pumpAndSettle();

    expect(picker.sources, [ImagePickSource.gallery, ImagePickSource.camera]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lokasi saat ini dapat disimpan secara opsional', (tester) async {
    final locationService = _FakeProductLocationService();
    await tester.pumpWidget(
      MaterialApp(
        home: ProductFormPage(
          trip: _trip,
          productRepository: const _FakeProductRepository(),
          imagePicker: _FakeProductImagePicker(),
          locationService: locationService,
        ),
      ),
    );

    final saveLocation = find.text('Simpan');
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(saveLocation, 240, scrollable: scrollable);
    await tester.drag(scrollable, const Offset(0, -120));
    await tester.pump();
    await tester.tap(saveLocation);
    await tester.pumpAndSettle();

    expect(locationService.captureCalls, 1);
    expect(find.text('Lokasi tersimpan'), findsOneWidget);
    expect(find.text('35.68124, 139.76712'), findsOneWidget);
  });
}

class _FakeProductLocationService implements ProductLocationService {
  int captureCalls = 0;

  @override
  Future<ProductLocation> captureCurrentLocation() async {
    captureCalls++;
    return ProductLocation(
      latitude: 35.68124,
      longitude: 139.76712,
      capturedAt: DateTime(2026, 9, 6, 10),
    );
  }

  @override
  Future<bool> openInMaps(ProductLocation location) async => true;
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
  final sources = <ImagePickSource>[];

  @override
  Future<PickedProductImage?> pick(ImagePickSource source) async {
    sources.add(source);
    final bytes = Uint8List.fromList(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      ),
    );
    return PickedProductImage(
      originalBytes: bytes,
      thumbnailBytes: bytes,
      mimeType: 'image/png',
    );
  }
}

class _FakeProductRepository implements ProductRepository {
  const _FakeProductRepository();

  @override
  Future<String> createProduct(NewProduct product) async => 'product-1';

  @override
  Future<void> deleteProduct(String id) async {}

  @override
  Future<Product> getProduct(String id) => throw UnimplementedError();

  @override
  Future<List<String>> getLocationLabels(String tripId) async => const [];

  @override
  Future<void> saveGeneratedAsset({
    required String productId,
    required Uint8List pngBytes,
    required int backgroundColor,
  }) async {}

  @override
  Future<void> updateProduct(String id, NewProduct product) async {}

  @override
  Stream<List<ProductSummary>> watchProducts(
    String tripId, {
    String query = '',
  }) => const Stream.empty();
}
