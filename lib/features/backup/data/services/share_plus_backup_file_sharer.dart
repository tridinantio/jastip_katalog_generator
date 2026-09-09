import 'dart:ui';

import 'package:share_plus/share_plus.dart';

import '../../domain/services/backup_restore_service.dart';

class SharePlusBackupFileSharer implements BackupFileSharer {
  const SharePlusBackupFileSharer();

  @override
  Future<void> share(BackupShareFile file) => SharePlus.instance.share(
    ShareParams(
      title: 'Backup Jastip Katalog',
      text: 'Backup data lokal dari Jastip Katalog.',
      files: [XFile.fromData(file.bytes, mimeType: 'application/zip')],
      fileNameOverrides: [file.fileName],
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
    ),
  );
}
