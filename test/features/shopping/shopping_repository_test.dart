import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/core/database/app_database.dart';
import 'package:jastip_katalog_generator/features/product/data/data_sources/product_local_data_source.dart';
import 'package:jastip_katalog_generator/features/shopping/data/data_sources/shopping_local_data_source.dart';
import 'package:jastip_katalog_generator/features/shopping/data/repositories/shopping_repository_impl.dart';
import 'package:jastip_katalog_generator/features/shopping/domain/entities/shopping_request.dart';

void main() {
  late AppDatabase database;
  late ShoppingRepositoryImpl repository;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ShoppingRepositoryImpl(ShoppingLocalDataSource(database));
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
    await ProductLocalDataSource(database).insertProduct(
      ProductsCompanion.insert(
        id: 'product-1',
        tripId: 'trip-1',
        name: 'Lip Balm',
        originalPriceMinor: 50000,
        sellingPriceIdr: 64000,
        imageBytes: Uint8List.fromList([1]),
        thumbnailBytes: Uint8List.fromList([1]),
        imageMimeType: 'image/jpeg',
        createdAt: now,
        updatedAt: now,
      ),
    );
  });

  tearDown(() => database.close());

  test(
    'menyimpan pembeli, menandai terbeli, dan menghitung progress',
    () async {
      final requestId = await repository.addRequest(
        const NewShoppingRequest(
          tripId: 'trip-1',
          productId: 'product-1',
          buyerName: 'Rina',
          quantity: 2,
          note: 'Warna merah',
        ),
      );
      final request = await repository.watchRequests('product-1').first;

      expect(request.single.id, requestId);
      expect(request.single.isPurchased, isFalse);
      expect(request.single.quantity, 2);

      await repository.setPurchased(requestId, true);
      final progress = await repository.watchProgress('trip-1').first;
      expect(progress['product-1']?.totalRequests, 1);
      expect(progress['product-1']?.purchasedRequests, 1);
      expect(await repository.getBuyerNames('trip-1'), ['Rina']);
    },
  );

  test('memperbarui checklist seluruh pesanan produk sekaligus', () async {
    await repository.addRequest(
      const NewShoppingRequest(
        tripId: 'trip-1',
        productId: 'product-1',
        buyerName: 'Rina',
        quantity: 1,
        note: '',
      ),
    );
    await repository.addRequest(
      const NewShoppingRequest(
        tripId: 'trip-1',
        productId: 'product-1',
        buyerName: 'Dina',
        quantity: 2,
        note: '',
      ),
    );

    await repository.setPurchasedForProduct('trip-1', 'product-1', true);

    final requests = await repository.watchRequests('product-1').first;
    expect(requests.every((request) => request.isPurchased), isTrue);
  });
}
