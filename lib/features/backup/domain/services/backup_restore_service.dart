import 'dart:typed_data';

import '../entities/backup.dart';

class BackupShareFile {
  const BackupShareFile({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;
}

abstract interface class BackupFileSharer {
  Future<void> share(BackupShareFile file);
}

abstract interface class BackupRestoreService {
  Future<BackupResult> createAndShare();

  Future<BackupCandidate?> pickBackup();

  Future<void> restore(BackupCandidate candidate);
}
