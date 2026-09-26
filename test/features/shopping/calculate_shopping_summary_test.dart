import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/features/product/domain/entities/product.dart';
import 'package:jastip_katalog_generator/features/shopping/domain/entities/shopping_request.dart';
import 'package:jastip_katalog_generator/features/shopping/domain/use_cases/calculate_shopping_summary.dart';
import 'package:jastip_katalog_generator/features/trip/domain/entities/trip.dart';

void main() {
  final trip = Trip(
    id: 'trip-1',
    name: 'Japan Trip',
    country: 'Jepang',
    currencyCode: 'JPY',
    currencyName: 'Japanese Yen',
    currencySymbol: '¥',
    rateMicros: 110000000,
    rateDate: DateTime(2026, 9, 5),
    rateFetchedAt: DateTime(2026, 9, 5),
    markupBasisPoints: 1500,
    fixedFeeIdr: 0,
    roundingUnitIdr: 1000,
  );
  final product = ProductSummary(
    id: 'product-1',
    tripId: 'trip-1',
    name: 'Lip Balm',
    originalPriceMinor: 300000,
    sellingPriceIdr: 380000,
    weightGrams: 250,
    thumbnailBytes: Uint8List.fromList([1]),
    createdAt: DateTime(2026, 9, 5),
  );

  test('menghitung modal, belanja aktual, dan keuntungan berdasarkan qty', () {
    final summary = CalculateShoppingSummary.call(
      products: [product],
      requests: [
        ShoppingRequest(
          id: 'request-1',
          tripId: 'trip-1',
          productId: 'product-1',
          buyerName: 'Rina',
          quantity: 2,
          note: '',
          isPurchased: true,
          purchasedAt: DateTime(2026, 9, 5),
          createdAt: DateTime(2026, 9, 5),
          updatedAt: DateTime(2026, 9, 5),
        ),
        ShoppingRequest(
          id: 'request-2',
          tripId: 'trip-1',
          productId: 'product-1',
          buyerName: 'Dina',
          quantity: 1,
          note: '',
          isPurchased: false,
          purchasedAt: null,
          createdAt: DateTime(2026, 9, 5),
          updatedAt: DateTime(2026, 9, 5),
        ),
      ],
      trip: trip,
    );

    expect(summary.requestCount, 2);
    expect(summary.totalQuantity, 3);
    expect(summary.purchasedQuantity, 2);
    expect(summary.estimatedCapitalIdr, 990000);
    expect(summary.actualCapitalIdr, 660000);
    expect(summary.estimatedProfitIdr, 150000);
    expect(summary.estimatedWeightGrams, 750);
  });

  test('menggunakan pengaturan trip terbaru untuk menghitung ulang', () {
    final summary = CalculateShoppingSummary.call(
      products: [product],
      requests: [
        ShoppingRequest(
          id: 'request-1',
          tripId: 'trip-1',
          productId: 'product-1',
          buyerName: 'Rina',
          quantity: 1,
          note: '',
          isPurchased: false,
          purchasedAt: null,
          createdAt: DateTime(2026, 9, 5),
          updatedAt: DateTime(2026, 9, 5),
        ),
      ],
      trip: trip.copyWith(markupBasisPoints: 2000),
    );

    expect(summary.estimatedCapitalIdr, 330000);
    expect(summary.estimatedProfitIdr, 66000);
  });
}
