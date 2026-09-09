import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/core/database/app_database.dart';
import 'package:jastip_katalog_generator/features/product/data/data_sources/product_local_data_source.dart';
import 'package:jastip_katalog_generator/features/trip/data/data_sources/trip_local_data_source.dart';
import 'package:jastip_katalog_generator/features/trip/data/repositories/trip_repository_impl.dart';
import 'package:jastip_katalog_generator/features/trip/domain/entities/trip.dart';

void main() {
  late AppDatabase database;
  late TripLocalDataSource tripLocal;
  late ProductLocalDataSource productLocal;
  late TripRepositoryImpl repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    tripLocal = TripLocalDataSource(database);
    productLocal = ProductLocalDataSource(database);
    repository = TripRepositoryImpl(tripLocal);
  });

  tearDown(() => database.close());

  test(
    'perubahan markup menghitung ulang produk hanya pada trip terkait',
    () async {
      final japan = await repository.ensureDefaultTrip();
      await repository.updateTrip(
        japan.copyWith(
          rateMicros: 100000000,
          rateDate: DateTime(2026, 9, 5),
          rateFetchedAt: DateTime(2026, 9, 5),
          markupBasisPoints: 0,
          roundingUnitIdr: 1000,
        ),
      );
      final korea = await repository.createTrip(
        NewTrip(
          name: 'Korea Trip',
          currencyCode: 'KRW',
          currencyName: 'South Korean Won',
          currencySymbol: '₩',
          rateMicros: 12000000,
          rateDate: DateTime(2026, 9, 5),
          rateFetchedAt: DateTime(2026, 9, 5),
        ),
      );
      await _insertProduct(productLocal, id: 'japan-product', tripId: japan.id);
      await _insertProduct(productLocal, id: 'korea-product', tripId: korea.id);

      await repository.updateTrip(
        japan.copyWith(
          rateMicros: 100000000,
          rateDate: DateTime(2026, 9, 5),
          rateFetchedAt: DateTime(2026, 9, 5),
          markupBasisPoints: 2000,
          roundingUnitIdr: 1000,
        ),
      );

      final japanProduct = await productLocal.getProduct('japan-product');
      final koreaProduct = await productLocal.getProduct('korea-product');
      expect(japanProduct.sellingPriceIdr, 12000);
      expect(koreaProduct.sellingPriceIdr, 1);
    },
  );

  test(
    'produk dengan harga khusus tidak ikut berubah saat trip diperbarui',
    () async {
      final japan = await repository.ensureDefaultTrip();
      await repository.updateTrip(
        japan.copyWith(
          rateMicros: 100000000,
          rateDate: DateTime(2026, 9, 5),
          rateFetchedAt: DateTime(2026, 9, 5),
          markupBasisPoints: 1000,
          fixedFeeIdr: 0,
          roundingUnitIdr: 1000,
        ),
      );
      await _insertProduct(
        productLocal,
        id: 'custom-product',
        tripId: japan.id,
        markupBasisPointsOverride: 500,
        fixedFeeIdrOverride: 0,
      );

      await repository.updateTrip(
        japan.copyWith(
          rateMicros: 100000000,
          rateDate: DateTime(2026, 9, 5),
          rateFetchedAt: DateTime(2026, 9, 5),
          markupBasisPoints: 3000,
          fixedFeeIdr: 0,
          roundingUnitIdr: 1000,
        ),
      );

      final product = await productLocal.getProduct('custom-product');
      expect(product.sellingPriceIdr, 11000);
      expect(product.markupBasisPointsOverride, 500);
      expect(product.fixedFeeIdrOverride, 0);
    },
  );

  test(
    'hapus trip menghapus produk terkait dan mengaktifkan trip lain',
    () async {
      final japan = await repository.ensureDefaultTrip();
      final korea = await repository.createTrip(
        NewTrip(
          name: 'Korea Trip',
          currencyCode: 'KRW',
          currencyName: 'South Korean Won',
          currencySymbol: '₩',
          rateMicros: 12000000,
          rateDate: DateTime(2026, 9, 5),
          rateFetchedAt: DateTime(2026, 9, 5),
        ),
      );
      await _insertProduct(productLocal, id: 'korea-product', tripId: korea.id);

      await repository.deleteTrip(korea.id);

      final active = await repository.getActiveTrip();
      final products = await database.select(database.products).get();
      expect(active.id, japan.id);
      expect(await repository.getTrips(), hasLength(1));
      expect(products, isEmpty);
    },
  );

  test('trip terakhir tidak dapat dihapus', () async {
    final trip = await repository.ensureDefaultTrip();

    expect(() => repository.deleteTrip(trip.id), throwsA(isA<Exception>()));
  });
}

Future<void> _insertProduct(
  ProductLocalDataSource dataSource, {
  required String id,
  required String tripId,
  int? markupBasisPointsOverride,
  int? fixedFeeIdrOverride,
}) {
  final now = DateTime(2026, 9, 5);
  return dataSource.insertProduct(
    ProductsCompanion.insert(
      id: id,
      tripId: tripId,
      name: id,
      originalPriceMinor: 10000,
      sellingPriceIdr: 1,
      markupBasisPointsOverride: Value(markupBasisPointsOverride),
      fixedFeeIdrOverride: Value(fixedFeeIdrOverride),
      imageBytes: Uint8List.fromList([1]),
      thumbnailBytes: Uint8List.fromList([1]),
      imageMimeType: 'image/jpeg',
      createdAt: now,
      updatedAt: now,
    ),
  );
}
