import '../entities/shopping_request.dart';

abstract interface class ShoppingRepository {
  Stream<List<ShoppingRequest>> watchRequests(String productId);
  Stream<List<ShoppingRequest>> watchRequestsForTrip(String tripId);
  Stream<Map<String, ShoppingProgress>> watchProgress(String tripId);
  Future<List<String>> getBuyerNames(String tripId);
  Future<String> addRequest(NewShoppingRequest request);
  Future<void> setPurchased(String requestId, bool isPurchased);
  Future<void> deleteRequest(String requestId);
}
