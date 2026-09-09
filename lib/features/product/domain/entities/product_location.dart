import 'package:equatable/equatable.dart';

class ProductLocation extends Equatable {
  const ProductLocation({
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    this.label,
  });

  final double latitude;
  final double longitude;
  final DateTime capturedAt;
  final String? label;

  ProductLocation withLabel(String? value) {
    final normalized = value?.trim();
    return ProductLocation(
      latitude: latitude,
      longitude: longitude,
      capturedAt: capturedAt,
      label: normalized == null || normalized.isEmpty ? null : normalized,
    );
  }

  String get coordinates =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  Uri get mapsUri => Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': '$latitude,$longitude',
  });

  @override
  List<Object?> get props => [latitude, longitude, capturedAt, label];
}
