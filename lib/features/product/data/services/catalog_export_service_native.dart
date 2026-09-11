import 'dart:typed_data';
import 'dart:ui';

import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/services/image_services.dart';

class CatalogExportServiceImpl implements CatalogExportService {
  const CatalogExportServiceImpl();

  @override
  Future<void> saveToGallery(Uint8List pngBytes) async {
    var hasAccess = await Gal.hasAccess();
    if (!hasAccess) hasAccess = await Gal.requestAccess();
    if (!hasAccess) throw StateError('Izin galeri tidak diberikan.');
    await Gal.putImageBytes(
      pngBytes,
      album: 'Jastip Katalog',
      name: 'jastip_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<void> share(Uint8List pngBytes, {required String productName}) async {
    await SharePlus.instance.share(
      ShareParams(
        text: '$productName — tersedia via jastip',
        files: [XFile.fromData(pngBytes, mimeType: 'image/png')],
        fileNameOverrides: ['${_safeName(productName)}.png'],
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
      ),
    );
  }
}

String _safeName(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp('[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_|_$'), '');
