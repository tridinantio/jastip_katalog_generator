import '../../../product/domain/entities/product.dart';
import '../../domain/entities/shopping_checklist.dart';
import '../../domain/entities/shopping_request.dart';

class BuildShoppingChecklist {
  const BuildShoppingChecklist._();

  static ShoppingChecklist call({
    required String tripId,
    required String tripName,
    required List<ProductSummary> products,
    required List<ShoppingRequest> requests,
  }) {
    final productsById = {for (final product in products) product.id: product};
    final requestsByProductId = <String, List<ShoppingRequest>>{};
    for (final request in requests) {
      if (productsById.containsKey(request.productId)) {
        (requestsByProductId[request.productId] ??= []).add(request);
      }
    }

    final items = requestsByProductId.entries.map((entry) {
      final product = productsById[entry.key]!;
      final productRequests = entry.value;
      final purchasedCount = productRequests
          .where((request) => request.isPurchased)
          .length;
      final status = purchasedCount == 0
          ? ShoppingChecklistStatus.pending
          : purchasedCount == productRequests.length
          ? ShoppingChecklistStatus.purchased
          : ShoppingChecklistStatus.partial;
      return ShoppingChecklistItem(
        productId: product.id,
        name: product.name,
        category: product.category,
        quantity: productRequests.fold(0, (sum, request) => sum + request.quantity),
        thumbnailBytes: product.thumbnailBytes,
        status: status,
      );
    }).toList()
      ..sort((left, right) {
        final category = left.category.compareTo(right.category);
        return category != 0 ? category : left.name.compareTo(right.name);
      });

    return ShoppingChecklist(tripId: tripId, tripName: tripName, items: items);
  }
}
