import 'dart:typed_data';

class TripExportFile {
  const TripExportFile({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;
}

class TripExportResult {
  const TripExportResult({required this.fileName});

  final String fileName;
}
