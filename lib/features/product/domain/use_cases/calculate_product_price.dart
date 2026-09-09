import 'package:equatable/equatable.dart';

import '../../../trip/domain/entities/trip.dart';

class PriceBreakdown extends Equatable {
  const PriceBreakdown({
    required this.capitalIdr,
    required this.percentageFeeIdr,
    required this.fixedFeeIdr,
    required this.sellingPriceIdr,
  });

  final int capitalIdr;
  final int percentageFeeIdr;
  final int fixedFeeIdr;
  final int sellingPriceIdr;

  @override
  List<Object?> get props => [
    capitalIdr,
    percentageFeeIdr,
    fixedFeeIdr,
    sellingPriceIdr,
  ];
}

abstract final class CalculateProductPrice {
  static PriceBreakdown call({
    required int originalPriceMinor,
    required Trip trip,
    int? markupBasisPointsOverride,
    int? fixedFeeIdrOverride,
  }) {
    if (originalPriceMinor < 0) {
      throw ArgumentError.value(originalPriceMinor, 'originalPriceMinor');
    }
    final markupBasisPoints =
        markupBasisPointsOverride ?? trip.markupBasisPoints;
    final fixedFeeIdr = fixedFeeIdrOverride ?? trip.fixedFeeIdr;
    if (markupBasisPoints < 0 || fixedFeeIdr < 0) {
      throw ArgumentError('Pengaturan harga produk tidak valid.');
    }
    if (trip.rateMicros <= 0) {
      return PriceBreakdown(
        capitalIdr: 0,
        percentageFeeIdr: 0,
        fixedFeeIdr: fixedFeeIdr,
        sellingPriceIdr: 0,
      );
    }
    const rateScale = 1000000;
    const minorScale = 100;
    const basisPointScale = 10000;
    final conversionDivisor = minorScale * rateScale;
    final conversionNumerator = originalPriceMinor * trip.rateMicros;
    final capitalIdr =
        (conversionNumerator + conversionDivisor ~/ 2) ~/ conversionDivisor;
    final percentageFeeIdr =
        (capitalIdr * markupBasisPoints + basisPointScale - 1) ~/
        basisPointScale;
    final subtotal = capitalIdr + percentageFeeIdr + fixedFeeIdr;
    final roundingUnit = trip.roundingUnitIdr <= 0 ? 1 : trip.roundingUnitIdr;
    final sellingPrice =
        ((subtotal + roundingUnit - 1) ~/ roundingUnit) * roundingUnit;
    return PriceBreakdown(
      capitalIdr: capitalIdr,
      percentageFeeIdr: percentageFeeIdr,
      fixedFeeIdr: fixedFeeIdr,
      sellingPriceIdr: sellingPrice,
    );
  }
}
