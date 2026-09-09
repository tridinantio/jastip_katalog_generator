import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class BackupSummary extends Equatable {
  const BackupSummary({
    required this.createdAt,
    required this.tripCount,
    required this.productCount,
    required this.buyerRequestCount,
    required this.generatedAssetCount,
  });

  final DateTime createdAt;
  final int tripCount;
  final int productCount;
  final int buyerRequestCount;
  final int generatedAssetCount;

  @override
  List<Object?> get props => [
    createdAt,
    tripCount,
    productCount,
    buyerRequestCount,
    generatedAssetCount,
  ];
}

class BackupCandidate extends Equatable {
  const BackupCandidate({
    required this.fileName,
    required this.bytes,
    required this.summary,
  });

  final String fileName;
  final Uint8List bytes;
  final BackupSummary summary;

  @override
  List<Object?> get props => [fileName, summary];
}

class BackupResult extends Equatable {
  const BackupResult({required this.fileName, required this.summary});

  final String fileName;
  final BackupSummary summary;

  @override
  List<Object?> get props => [fileName, summary];
}
