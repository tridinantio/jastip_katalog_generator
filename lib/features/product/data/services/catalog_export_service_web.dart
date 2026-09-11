import 'dart:typed_data';
import 'dart:ui';

import 'package:share_plus/share_plus.dart';

import '../../domain/services/image_services.dart';

/// On the web, browsers do not allow an app to write directly to Photos.
/// Share Plus opens Safari's share sheet or downloads the image instead.
class CatalogExportServiceImpl implements CatalogExportService {
  const CatalogExportServiceImpl();

  @override
  Future<void> saveToGallery(Uint8List pngBytes) => SharePlus.instance.share(
    ShareParams(
      title: 'Unduh katalog',
      text: 'Simpan gambar katalog ini ke Foto atau Files.',
      files: [XFile.fromData(pngBytes, mimeType: 'image/png')],
      fileNameOverrides: [
        'jastip_${DateTime.now().millisecondsSinceEpoch}.png',
      ],
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
    ),
  );

  @override
  Future<void> share(Uint8List pngBytes, {required String productName}) =>
      SharePlus.instance.share(
        ShareParams(
          text: '$productName — tersedia via jastip',
          files: [XFile.fromData(pngBytes, mimeType: 'image/png')],
          fileNameOverrides: ['${_safeName(productName)}.png'],
          sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
        ),
      );
}

String _safeName(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp('[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_|_$'), '');
