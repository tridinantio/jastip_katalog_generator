import 'package:equatable/equatable.dart';

class ShoppingSummary extends Equatable {
  const ShoppingSummary({
    required this.requestCount,
    required this.totalQuantity,
    required this.purchasedQuantity,
    required this.estimatedCapitalIdr,
    required this.actualCapitalIdr,
    required this.estimatedProfitIdr,
  });

  const ShoppingSummary.empty()
    : requestCount = 0,
      totalQuantity = 0,
      purchasedQuantity = 0,
      estimatedCapitalIdr = 0,
      actualCapitalIdr = 0,
      estimatedProfitIdr = 0;

  final int requestCount;
  final int totalQuantity;
  final int purchasedQuantity;
  final int estimatedCapitalIdr;
  final int actualCapitalIdr;
  final int estimatedProfitIdr;

  int get remainingQuantity => totalQuantity - purchasedQuantity;

  bool get isEmpty => requestCount == 0;

  @override
  List<Object> get props => [
    requestCount,
    totalQuantity,
    purchasedQuantity,
    estimatedCapitalIdr,
    actualCapitalIdr,
    estimatedProfitIdr,
  ];
}
