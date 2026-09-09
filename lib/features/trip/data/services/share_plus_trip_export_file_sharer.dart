import 'dart:ui';

import 'package:share_plus/share_plus.dart';

import '../../domain/entities/trip_export_file.dart';
import '../../domain/services/trip_export_service.dart';

class SharePlusTripExportFileSharer implements TripExportFileSharer {
  const SharePlusTripExportFileSharer();

  @override
  Future<void> share(TripExportFile file) => SharePlus.instance.share(
    ShareParams(
      title: 'Export trip',
      text: 'Export data trip dari Jastip Katalog.',
      files: [
        XFile.fromData(
          file.bytes,
          mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ),
      ],
      fileNameOverrides: [file.fileName],
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
    ),
  );
}
