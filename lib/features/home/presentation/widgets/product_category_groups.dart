import '../../../product/domain/entities/product.dart';

class ProductCategoryGroup {
  const ProductCategoryGroup({
    required this.label,
    required this.products,
    this.isUncategorized = false,
  });

  final String label;
  final List<ProductSummary> products;
  final bool isUncategorized;
}

List<ProductCategoryGroup> groupProductsByCategory(
  List<ProductSummary> products,
) {
  final groups = <String, List<ProductSummary>>{};
  final labels = <String, String>{};

  for (final product in products) {
    final label = product.category.trim();
    final key = label.toLowerCase();
    groups.putIfAbsent(key, () => []).add(product);
    if (label.isNotEmpty) labels.putIfAbsent(key, () => label);
  }

  final categoryKeys = groups.keys.where((key) => key.isNotEmpty).toList()
    ..sort();
  final result = categoryKeys
      .map(
        (key) => ProductCategoryGroup(
          label: labels[key]!,
          products: List.unmodifiable(groups[key]!),
        ),
      )
      .toList();
  final uncategorizedProducts = groups[''];
  if (uncategorizedProducts != null) {
    result.add(
      ProductCategoryGroup(
        label: 'Tanpa kategori',
        products: List.unmodifiable(uncategorizedProducts),
        isUncategorized: true,
      ),
    );
  }
  return List.unmodifiable(result);
}
