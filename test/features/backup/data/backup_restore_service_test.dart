import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/core/database/app_database.dart';
import 'package:jastip_katalog_generator/features/backup/data/services/backup_restore_service_impl.dart';
import 'package:jastip_katalog_generator/features/backup/domain/entities/backup.dart';
import 'package:jastip_katalog_generator/features/backup/domain/services/backup_restore_service.dart';

void main() {
  late AppDatabase database;
  late _FakeSharer sharer;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    sharer = _FakeSharer();
    final now = DateTime(2026, 9, 8, 10);
    await database
        .into(database.trips)
        .insert(
          TripsCompanion.insert(
            id: 'trip-1',
            name: 'Japan Trip',
            country: const Value('Jepang'),
            currencyCode: 'JPY',
            currencyName: 'Japanese Yen',
            currencySymbol: '¥',
            rateMicros: const Value(110000000),
            rateDate: Value(now),
            rateFetchedAt: Value(now),
            isActive: const Value(true),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: 'product-1',
            tripId: 'trip-1',
            name: 'Matcha',
            originalPriceMinor: 50000,
            sellingPriceIdr: 65000,
            weightGrams: const Value(200),
            note: const Value('Kemasan hijau'),
            category: const Value('Makanan'),
            imageBytes: Uint8List.fromList([1, 2, 3]),
            thumbnailBytes: Uint8List.fromList([4, 5]),
            imageMimeType: 'image/jpeg',
            latitude: const Value(35.6812),
            longitude: const Value(139.7671),
            locationLabel: const Value('Tokyo Station'),
            locationCapturedAt: Value(now),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database.customInsert(
      '''INSERT INTO shopping_requests
        (id, trip_id, product_id, buyer_name, quantity, note, is_purchased,
         purchased_at, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      variables: [
        const Variable<String>('request-1'),
        const Variable<String>('trip-1'),
        const Variable<String>('product-1'),
        const Variable<String>('Rina'),
        const Variable<int>(2),
        const Variable<String>('Titip dua'),
        const Variable<int>(1),
        Variable<String>(now.toIso8601String()),
        Variable<String>(now.toIso8601String()),
        Variable<String>(now.toIso8601String()),
      ],
    );
  });

  tearDown(() => database.close());

  test(
    'backup mengarsipkan data dan restore mengganti database secara utuh',
    () async {
      final service = BackupRestoreServiceImpl(database, sharer);

      final result = await service.createAndShare();
      expect(result.fileName, endsWith('.jastip'));
      expect(result.summary.tripCount, 1);
      expect(result.summary.productCount, 1);
      expect(result.summary.buyerRequestCount, 1);
      expect(sharer.file, isNotNull);
      expect(sharer.file!.bytes.take(2), orderedEquals([0x50, 0x4b]));

      await database
          .into(database.trips)
          .insert(
            TripsCompanion.insert(
              id: 'trip-2',
              name: 'Extra Trip',
              currencyCode: 'USD',
              currencyName: 'United States Dollar',
              currencySymbol: r'$',
              isActive: const Value(false),
              createdAt: DateTime(2026, 9, 9),
              updatedAt: DateTime(2026, 9, 9),
            ),
          );

      await service.restore(
        BackupCandidate(
          fileName: result.fileName,
          bytes: sharer.file!.bytes,
          summary: result.summary,
        ),
      );

      expect(await database.select(database.trips).get(), hasLength(1));
      final products = await database.select(database.products).get();
      expect(products, hasLength(1));
      expect(products.single.name, 'Matcha');
      expect(products.single.imageBytes, orderedEquals([1, 2, 3]));
      final requests = await database
          .customSelect('SELECT * FROM shopping_requests')
          .get();
      expect(requests, hasLength(1));
      expect(requests.single.read<String>('buyer_name'), 'Rina');
    },
  );
}

class _FakeSharer implements BackupFileSharer {
  BackupShareFile? file;

  @override
  Future<void> share(BackupShareFile value) async {
    file = value;
  }
}
