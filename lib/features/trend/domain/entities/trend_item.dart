import 'package:equatable/equatable.dart';

class TrendSource extends Equatable {
  const TrendSource({required this.label, required this.url});

  final String label;
  final String url;

  @override
  List<Object> get props => [label, url];
}

class TrendItem extends Equatable {
  const TrendItem({
    required this.title,
    required this.approxTraffic,
    required this.startedAt,
    required this.imageUrl,
    required this.sources,
  });

  final String title;
  final String approxTraffic;
  final DateTime? startedAt;
  final String? imageUrl;
  final List<TrendSource> sources;

  @override
  List<Object?> get props => [
    title,
    approxTraffic,
    startedAt,
    imageUrl,
    sources,
  ];
}
