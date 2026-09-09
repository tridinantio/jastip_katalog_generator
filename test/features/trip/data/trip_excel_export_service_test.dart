import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/core/database/app_database.dart';
import 'package:jastip_katalog_generator/features/trip/data/services/trip_excel_export_service_impl.dart';
import 'package:jastip_katalog_generator/features/trip/domain/entities/trip.dart';
import 'package:jastip_katalog_generator/features/trip/domain/entities/trip_export_file.dart';
import 'package:jastip_katalog_generator/features/trip/domain/services/trip_export_service.dart';

void main() {
  late AppDatabase database;
  late _FakeSharer sharer;
  late Trip trip;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    sharer = _FakeSharer();
    final now = DateTime(2026, 9, 6, 10);
    trip = Trip(
      id: 'trip-1',
      name: 'Japan Trip',
      country: 'Japan',
      currencyCode: 'JPY',
      currencyName: 'Japanese Yen',
      currencySymbol: '¥',
      rateMicros: 110000000,
      rateDate: now,
      rateFetchedAt: now,
      markupBasisPoints: 1500,
      fixedFeeIdr: 1000,
      roundingUnitIdr: 1000,
    );
    await database
        .into(database.trips)
        .insert(
          TripsCompanion.insert(
            id: trip.id,
            name: trip.name,
            currencyCode: trip.currencyCode,
            currencyName: trip.currencyName,
            currencySymbol: trip.currencySymbol,
            rateMicros: Value(trip.rateMicros),
            rateDate: Value(now),
            rateFetchedAt: Value(now),
            markupBasisPoints: Value(trip.markupBasisPoints),
            fixedFeeIdr: Value(trip.fixedFeeIdr),
            roundingUnitIdr: Value(trip.roundingUnitIdr),
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
            tripId: trip.id,
            name: 'Matcha',
            originalPriceMinor: 50000,
            sellingPriceIdr: 65000,
            note: const Value('Kemasan hijau'),
            category: const Value('Makanan'),
            imageBytes: Uint8List.fromList([1]),
            thumbnailBytes: Uint8List.fromList([1]),
            imageMimeType: 'image/jpeg',
            latitude: const Value(35.6812),
            longitude: const Value(139.7671),
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
        Variable<String>(trip.id),
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

  test('mengekspor ringkasan, produk, dan pembeli sebagai file xlsx', () async {
    final service = TripExcelExportServiceImpl(database, sharer);

    final result = await service.export(trip);

    expect(result.fileName, endsWith('.xlsx'));
    expect(sharer.file, isNotNull);
    expect(sharer.file!.fileName, result.fileName);
    expect(sharer.file!.bytes.length, greaterThan(100));
    expect(sharer.file!.bytes.take(2), orderedEquals([0x50, 0x4b]));
  });
}

class _FakeSharer implements TripExportFileSharer {
  TripExportFile? file;

  @override
  Future<void> share(TripExportFile value) async {
    file = value;
  }
}
