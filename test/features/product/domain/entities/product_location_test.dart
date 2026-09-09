import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/features/product/domain/entities/product_location.dart';

void main() {
  test('membuat tautan Google Maps dari koordinat produk', () {
    final location = ProductLocation(
      latitude: 35.68124,
      longitude: 139.76712,
      capturedAt: DateTime(2026, 9, 6, 10),
    );

    expect(location.coordinates, '35.68124, 139.76712');
    expect(location.mapsUri.host, 'www.google.com');
    expect(location.mapsUri.path, '/maps/search/');
    expect(location.mapsUri.queryParameters['api'], '1');
    expect(location.mapsUri.queryParameters['query'], '35.68124,139.76712');
  });

  test('menyimpan label lokasi secara opsional', () {
    final location = ProductLocation(
      latitude: 35.68124,
      longitude: 139.76712,
      capturedAt: DateTime(2026, 9, 6, 10),
    ).withLabel('  Don Quijote Shinjuku  ');

    expect(location.label, 'Don Quijote Shinjuku');
  });
}
