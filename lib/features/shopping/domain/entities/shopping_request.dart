import 'package:equatable/equatable.dart';

class ShoppingRequest extends Equatable {
  const ShoppingRequest({
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

  @override
  List<Object?> get props => [
    id,
    tripId,
    productId,
    buyerName,
    quantity,
    note,
    isPurchased,
    purchasedAt,
    createdAt,
    updatedAt,
  ];
}

class NewShoppingRequest {
  const NewShoppingRequest({
    required this.tripId,
    required this.productId,
    required this.buyerName,
    required this.quantity,
    required this.note,
  });

  final String tripId;
  final String productId;
  final String buyerName;
  final int quantity;
  final String note;
}

class ShoppingProgress extends Equatable {
  const ShoppingProgress({
    required this.productId,
    required this.totalRequests,
    required this.purchasedRequests,
  });

  final String productId;
  final int totalRequests;
  final int purchasedRequests;

  bool get isComplete =>
      totalRequests > 0 && purchasedRequests == totalRequests;

  @override
  List<Object> get props => [productId, totalRequests, purchasedRequests];
}
