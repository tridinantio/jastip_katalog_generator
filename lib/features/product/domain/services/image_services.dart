import 'dart:typed_data';

enum ImagePickSource { camera, gallery }

class PickedProductImage {
  const PickedProductImage({
    required this.originalBytes,
    required this.thumbnailBytes,
    required this.mimeType,
  });

  final Uint8List originalBytes;
  final Uint8List thumbnailBytes;
  final String mimeType;
}

abstract interface class ProductImagePicker {
  Future<PickedProductImage?> pick(ImagePickSource source);
}

abstract interface class CatalogExportService {
  Future<void> saveToGallery(Uint8List pngBytes);
  Future<void> share(Uint8List pngBytes, {required String productName});
}
