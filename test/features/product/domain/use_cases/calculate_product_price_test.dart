import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/features/product/domain/use_cases/calculate_product_price.dart';
import 'package:jastip_katalog_generator/features/trip/domain/entities/trip.dart';

void main() {
  const trip = Trip(
    id: 'trip-1',
    name: 'Japan Trip',
    country: 'Jepang',
    currencyCode: 'JPY',
    currencyName: 'Japanese Yen',
    currencySymbol: '¥',
    rateMicros: 110000000,
    rateDate: null,
    rateFetchedAt: null,
    markupBasisPoints: 1500,
    fixedFeeIdr: 0,
    roundingUnitIdr: 1000,
  );

  test('menghitung harga dan membulatkan ke atas', () {
    final result = CalculateProductPrice.call(
      originalPriceMinor: 300000,
      trip: trip,
    );

    expect(result.capitalIdr, 330000);
    expect(result.percentageFeeIdr, 49500);
    expect(result.sellingPriceIdr, 380000);
  });

  test('memasukkan biaya tetap sebelum pembulatan', () {
    final result = CalculateProductPrice.call(
      originalPriceMinor: 10000,
      trip: trip.copyWith(fixedFeeIdr: 2500),
    );

    expect(result.capitalIdr, 11000);
    expect(result.percentageFeeIdr, 1650);
    expect(result.sellingPriceIdr, 16000);
  });
}
