import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/features/home/presentation/widgets/product_category_groups.dart';
import 'package:jastip_katalog_generator/features/product/domain/entities/product.dart';

void main() {
  test('menggabungkan kategori tanpa membedakan kapitalisasi dan spasi', () {
    final groups = groupProductsByCategory([
      _product('1', ' Snack '),
      _product('2', 'snack'),
      _product('3', 'Minuman'),
      _product('4', ''),
    ]);

    expect(groups.map((group) => group.label), [
      'Minuman',
      'Snack',
      'Tanpa kategori',
    ]);
    expect(groups[1].products.map((product) => product.id), ['1', '2']);
    expect(groups.last.isUncategorized, isTrue);
  });
}

ProductSummary _product(String id, String category) => ProductSummary(
  id: id,
  tripId: 'trip-1',
  name: 'Produk $id',
  originalPriceMinor: 10000,
  sellingPriceIdr: 15000,
  thumbnailBytes: Uint8List(0),
  createdAt: DateTime(2026),
  category: category,
);
