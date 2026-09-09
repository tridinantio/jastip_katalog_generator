import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/core/database/app_database.dart';
import 'package:jastip_katalog_generator/features/product/data/data_sources/product_local_data_source.dart';
import 'package:jastip_katalog_generator/features/product/data/repositories/product_repository_impl.dart';
import 'package:jastip_katalog_generator/features/product/domain/entities/product.dart';
import 'package:jastip_katalog_generator/features/product/domain/entities/product_location.dart';

void main() {
  late AppDatabase database;
  late ProductLocalDataSource dataSource;
  late ProductRepositoryImpl repository;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = ProductLocalDataSource(database);
    repository = ProductRepositoryImpl(dataSource);
    final now = DateTime(2026, 9, 5);
    await database
        .into(database.trips)
        .insert(
          TripsCompanion.insert(
            id: 'trip-1',
            name: 'Japan Trip',
            currencyCode: 'JPY',
            currencyName: 'Japanese Yen',
            currencySymbol: '¥',
            isActive: const Value(true),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await dataSource.insertProduct(
      ProductsCompanion.insert(
        id: 'product-1',
        tripId: 'trip-1',
        name: 'Lip Balm',
        originalPriceMinor: 50000,
        sellingPriceIdr: 64000,
        imageBytes: Uint8List.fromList([1, 2, 3]),
        thumbnailBytes: Uint8List.fromList([1]),
        imageMimeType: 'image/jpeg',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await dataSource.insertGeneratedAsset(
      GeneratedAssetsCompanion.insert(
        id: 'asset-1',
        productId: 'product-1',
        pngBytes: Uint8List.fromList([4, 5, 6]),
        backgroundColor: 0xFFFFE4D6,
        createdAt: now,
      ),
    );
  });

  tearDown(() => database.close());

  test('menghapus produk dan generated asset dalam satu transaksi', () async {
    await dataSource.deleteProduct('product-1');

    expect(await database.select(database.products).get(), isEmpty);
    expect(await database.select(database.generatedAssets).get(), isEmpty);
  });

  test('memperbarui produk yang sama tanpa membuat baris baru', () async {
    await repository.updateProduct(
      'product-1',
      NewProduct(
        tripId: 'trip-1',
        name: 'Lip Balm Sakura',
        originalPriceMinor: 75000,
        sellingPriceIdr: 96000,
        note: 'Varian baru',
        category: 'Kosmetik',
        imageBytes: Uint8List.fromList([7, 8, 9]),
        thumbnailBytes: Uint8List.fromList([7]),
        imageMimeType: 'image/png',
        location: ProductLocation(
          latitude: 35.68124,
          longitude: 139.76712,
          capturedAt: DateTime(2026, 9, 6, 10),
          label: 'Don Quijote Shinjuku',
        ),
      ),
    );

    final products = await database.select(database.products).get();
    final updated = await repository.getProduct('product-1');

    expect(products, hasLength(1));
    expect(updated.name, 'Lip Balm Sakura');
    expect(updated.originalPriceMinor, 75000);
    expect(updated.sellingPriceIdr, 96000);
    expect(updated.note, 'Varian baru');
    expect(updated.category, 'Kosmetik');
    expect(updated.imageBytes, Uint8List.fromList([7, 8, 9]));
    expect(updated.location?.latitude, 35.68124);
    expect(updated.location?.longitude, 139.76712);
    expect(updated.location?.label, 'Don Quijote Shinjuku');
    expect(await repository.getLocationLabels('trip-1'), [
      'Don Quijote Shinjuku',
    ]);
  });
}
