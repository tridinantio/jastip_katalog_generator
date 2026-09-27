import 'dart:async';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

class ShoppingRequestRow {
  const ShoppingRequestRow({
    required this.id,
    required this.tripId,
    required this.productId,
    required this.buyerName,
    required this.quantity,
    required this.note,
    required this.isPurchased,
    required this.purchasedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String tripId;
  final String productId;
  final String buyerName;
  final int quantity;
  final String note;
  final bool isPurchased;
  final DateTime? purchasedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ShoppingLocalDataSource {
  ShoppingLocalDataSource(this._database);

  final AppDatabase _database;
  final _changes = StreamController<void>.broadcast();

  Stream<List<ShoppingRequestRow>> watchRequests(String productId) async* {
    yield await _getRequests(
      'SELECT * FROM shopping_requests WHERE product_id = ? ORDER BY created_at ASC',
      [Variable<String>(productId)],
    );
    yield* _changes.stream.asyncMap(
      (_) => _getRequests(
        'SELECT * FROM shopping_requests WHERE product_id = ? ORDER BY created_at ASC',
        [Variable<String>(productId)],
      ),
    );
  }

  Stream<List<ShoppingRequestRow>> watchTripRequests(String tripId) async* {
    yield await _getRequests(
      'SELECT * FROM shopping_requests WHERE trip_id = ?',
      [Variable<String>(tripId)],
    );
    yield* _changes.stream.asyncMap(
      (_) => _getRequests('SELECT * FROM shopping_requests WHERE trip_id = ?', [
        Variable<String>(tripId),
      ]),
    );
  }

  Future<List<String>> getBuyerNames(String tripId) async {
    final rows = await _database
        .customSelect(
          '''SELECT DISTINCT buyer_name
             FROM shopping_requests
             WHERE trip_id = ? AND TRIM(buyer_name) <> ''
             ORDER BY buyer_name COLLATE NOCASE''',
          variables: [Variable<String>(tripId)],
        )
        .get();
    return rows
        .map((row) => row.read<String>('buyer_name'))
        .toList(growable: false);
  }

  Future<void> insertRequest({
    required String id,
    required String tripId,
    required String productId,
    required String buyerName,
    required int quantity,
    required String note,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) async {
    await _database.customInsert(
      '''INSERT INTO shopping_requests
      (id, trip_id, product_id, buyer_name, quantity, note, purchased_at, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      variables: [
        Variable<String>(id),
        Variable<String>(tripId),
        Variable<String>(productId),
        Variable<String>(buyerName),
        Variable<int>(quantity),
        Variable<String>(note),
        Variable<String>(''),
        Variable<String>(createdAt.toIso8601String()),
        Variable<String>(updatedAt.toIso8601String()),
      ],
    );
    _changes.add(null);
  }

  Future<int> updatePurchaseStatus(
    String requestId,
    bool isPurchased,
    DateTime? purchasedAt,
  ) async {
    final updated = await _database.customUpdate(
      '''UPDATE shopping_requests
      SET is_purchased = ?, purchased_at = ?, updated_at = ? WHERE id = ?''',
      variables: [
        Variable<int>(isPurchased ? 1 : 0),
        Variable<String>(purchasedAt?.toIso8601String() ?? ''),
        Variable<String>(DateTime.now().toIso8601String()),
        Variable<String>(requestId),
      ],
    );
    if (updated > 0) _changes.add(null);
    return updated;
  }

  Future<int> updateRequest({
    required String id,
    required String buyerName,
    required int quantity,
    required String note,
    required DateTime updatedAt,
  }) async {
    final updated = await _database.customUpdate(
      '''UPDATE shopping_requests
      SET buyer_name = ?, quantity = ?, note = ?, updated_at = ?
      WHERE id = ?''',
      variables: [
        Variable<String>(buyerName),
        Variable<int>(quantity),
        Variable<String>(note),
        Variable<String>(updatedAt.toIso8601String()),
        Variable<String>(id),
      ],
    );
    if (updated > 0) _changes.add(null);
    return updated;
  }

  Future<int> updatePurchaseStatusForProduct(
    String tripId,
    String productId,
    bool isPurchased,
    DateTime? purchasedAt,
  ) async {
    final updated = await _database.customUpdate(
      '''UPDATE shopping_requests
      SET is_purchased = ?, purchased_at = ?, updated_at = ?
      WHERE trip_id = ? AND product_id = ?''',
      variables: [
        Variable<int>(isPurchased ? 1 : 0),
        Variable<String>(purchasedAt?.toIso8601String() ?? ''),
        Variable<String>(DateTime.now().toIso8601String()),
        Variable<String>(tripId),
        Variable<String>(productId),
      ],
    );
    if (updated > 0) _changes.add(null);
    return updated;
  }

  Future<int> deleteRequest(String requestId) => _deleteRequest(requestId);

  Future<int> _deleteRequest(String requestId) async {
    final deleted = await _database.customUpdate(
      'DELETE FROM shopping_requests WHERE id = ?',
      variables: [Variable<String>(requestId)],
    );
    if (deleted > 0) _changes.add(null);
    return deleted;
  }

  Future<List<ShoppingRequestRow>> _getRequests(
    String sql,
    List<Variable<Object>> variables,
  ) async {
    final rows = await _database.customSelect(sql, variables: variables).get();
    return rows.map(_mapRow).toList(growable: false);
  }

  ShoppingRequestRow _mapRow(QueryRow row) => ShoppingRequestRow(
    id: row.read<String>('id'),
    tripId: row.read<String>('trip_id'),
    productId: row.read<String>('product_id'),
    buyerName: row.read<String>('buyer_name'),
    quantity: row.read<int>('quantity'),
    note: row.read<String>('note'),
    isPurchased: row.read<int>('is_purchased') == 1,
    purchasedAt: DateTime.tryParse(row.read<String>('purchased_at')),
    createdAt: DateTime.parse(row.read<String>('created_at')),
    updatedAt: DateTime.parse(row.read<String>('updated_at')),
  );
}
