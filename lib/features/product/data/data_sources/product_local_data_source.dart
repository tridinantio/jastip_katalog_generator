import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

class ProductListRecord {
  const ProductListRecord({
    required this.id,
    required this.tripId,
    required this.name,
    required this.originalPriceMinor,
    required this.sellingPriceIdr,
    required this.markupBasisPointsOverride,
    required this.fixedFeeIdrOverride,
    required this.thumbnailBytes,
    required this.createdAt,
    required this.category,
    required this.hasLocation,
  });

  final String id;
  final String tripId;
  final String name;
  final int originalPriceMinor;
  final int sellingPriceIdr;
  final int? markupBasisPointsOverride;
  final int? fixedFeeIdrOverride;
  final Uint8List thumbnailBytes;
  final DateTime createdAt;
  final String category;
  final bool hasLocation;
}

class ProductLocalDataSource {
  const ProductLocalDataSource(this._database);

  final AppDatabase _database;

  Stream<List<ProductListRecord>> watchProducts(
    String tripId, {
    String query = '',
  }) {
    final products = _database.products;
    final select = _database.selectOnly(products)
      ..addColumns([
        products.id,
        products.tripId,
        products.name,
        products.originalPriceMinor,
        products.sellingPriceIdr,
        products.markupBasisPointsOverride,
        products.fixedFeeIdrOverride,
        products.thumbnailBytes,
        products.createdAt,
        products.category,
        products.latitude,
        products.longitude,
      ])
      ..where(products.tripId.equals(tripId))
      ..orderBy([OrderingTerm.desc(products.createdAt)]);
    final normalized = query.trim();
    if (normalized.isNotEmpty) {
      select.where(products.name.lower().like('%${normalized.toLowerCase()}%'));
    }
    return select.watch().map(
      (rows) => rows
          .map(
            (row) => ProductListRecord(
              id: row.read(products.id)!,
              tripId: row.read(products.tripId)!,
              name: row.read(products.name)!,
              originalPriceMinor: row.read(products.originalPriceMinor)!,
              sellingPriceIdr: row.read(products.sellingPriceIdr)!,
              markupBasisPointsOverride: row.read(
                products.markupBasisPointsOverride,
              ),
              fixedFeeIdrOverride: row.read(products.fixedFeeIdrOverride),
              thumbnailBytes: row.read(products.thumbnailBytes)!,
              createdAt: row.read(products.createdAt)!,
              category: row.read(products.category) ?? '',
              hasLocation:
                  row.read(products.latitude) != null &&
                  row.read(products.longitude) != null,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<ProductRecord> getProduct(String id) {
    final query = _database.select(_database.products)
      ..where((table) => table.id.equals(id));
    return query.getSingle();
  }

  Future<List<String>> getLocationLabels(String tripId) async {
    final rows = await _database
        .customSelect(
          '''SELECT DISTINCT location_label
             FROM products
             WHERE trip_id = ? AND TRIM(COALESCE(location_label, '')) <> ''
             ORDER BY location_label COLLATE NOCASE''',
          variables: [Variable<String>(tripId)],
        )
        .get();
    return rows
        .map((row) => row.read<String>('location_label'))
        .toList(growable: false);
  }

  Future<void> insertProduct(ProductsCompanion product) =>
      _database.into(_database.products).insert(product);

  Future<int> updateProduct(String id, ProductsCompanion product) =>
      (_database.update(
        _database.products,
      )..where((table) => table.id.equals(id))).write(product);

  Future<void> deleteProduct(String id) {
    return _database.transaction(() async {
      await (_database.delete(
        _database.generatedAssets,
      )..where((table) => table.productId.equals(id))).go();
      await (_database.delete(
        _database.products,
      )..where((table) => table.id.equals(id))).go();
    });
  }

  Future<void> insertGeneratedAsset(GeneratedAssetsCompanion asset) =>
      _database.into(_database.generatedAssets).insert(asset);
}
