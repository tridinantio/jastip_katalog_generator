import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../domain/services/image_services.dart';

class ProductImagePickerImpl implements ProductImagePicker {
  ProductImagePickerImpl(this._picker);

  final ImagePicker _picker;

  @override
  Future<PickedProductImage?> pick(ImagePickSource source) async {
    final file = await _picker.pickImage(
      source: source == ImagePickSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
    );
    if (file == null) return null;
    final original = await file.readAsBytes();
    return prepare(
      original,
      mimeType: file.mimeType ?? _guessMimeType(file.name),
    );
  }

  @override
  Future<PickedProductImage> prepare(
    Uint8List originalBytes, {
    required String mimeType,
  }) async {
    final thumbnail = await compute(_makeThumbnail, originalBytes);
    return PickedProductImage(
      originalBytes: originalBytes,
      thumbnailBytes: thumbnail,
      mimeType: mimeType,
    );
  }
}

Uint8List _makeThumbnail(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;
  final thumbnail = img.copyResize(
    decoded,
    width: decoded.width >= decoded.height ? 360 : null,
    height: decoded.height > decoded.width ? 360 : null,
    interpolation: img.Interpolation.average,
  );
  return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 82));
}

String _guessMimeType(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.heic')) return 'image/heic';
  return 'image/jpeg';
}
