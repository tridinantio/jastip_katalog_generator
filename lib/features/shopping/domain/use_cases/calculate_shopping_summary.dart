import '../../../product/domain/entities/product.dart';
import '../../../product/domain/use_cases/calculate_product_price.dart';
import '../../../trip/domain/entities/trip.dart';
import '../entities/shopping_request.dart';
import '../entities/shopping_summary.dart';

abstract final class CalculateShoppingSummary {
  static ShoppingSummary call({
    required List<ProductSummary> products,
    required List<ShoppingRequest> requests,
    required Trip trip,
  }) {
    if (requests.isEmpty || products.isEmpty) {
      return const ShoppingSummary.empty();
    }

    final productsById = {for (final product in products) product.id: product};
    var totalQuantity = 0;
    var purchasedQuantity = 0;
    var estimatedCapitalIdr = 0;
    var actualCapitalIdr = 0;
    var estimatedProfitIdr = 0;
    var estimatedWeightGrams = 0;
    var requestCount = 0;

    for (final request in requests) {
      final product = productsById[request.productId];
      if (product == null || request.quantity <= 0) continue;

      final quantity = request.quantity;
      final breakdown = CalculateProductPrice.call(
        originalPriceMinor: product.originalPriceMinor,
        trip: trip,
        markupBasisPointsOverride: product.markupBasisPointsOverride,
        fixedFeeIdrOverride: product.fixedFeeIdrOverride,
      );
      final profitPerUnit = breakdown.sellingPriceIdr - breakdown.capitalIdr;

      requestCount++;
      totalQuantity += quantity;
      estimatedCapitalIdr += breakdown.capitalIdr * quantity;
      estimatedProfitIdr += profitPerUnit * quantity;
      estimatedWeightGrams += (product.weightGrams ?? 0) * quantity;
      if (request.isPurchased) {
        purchasedQuantity += quantity;
        actualCapitalIdr += breakdown.capitalIdr * quantity;
      }
    }

    return ShoppingSummary(
      requestCount: requestCount,
      totalQuantity: totalQuantity,
      purchasedQuantity: purchasedQuantity,
      estimatedCapitalIdr: estimatedCapitalIdr,
      actualCapitalIdr: actualCapitalIdr,
      estimatedProfitIdr: estimatedProfitIdr,
      estimatedWeightGrams: estimatedWeightGrams,
    );
  }
}
