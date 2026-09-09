import '../entities/product_location.dart';

abstract interface class ProductLocationService {
  Future<ProductLocation> captureCurrentLocation();
  Future<bool> openInMaps(ProductLocation location);
}

class ProductLocationException implements Exception {
  const ProductLocationException(this.message);

  final String message;

  @override
  String toString() => message;
}
