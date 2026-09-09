import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/product_location.dart';
import '../../domain/services/location_services.dart';

class ProductLocationServiceImpl implements ProductLocationService {
  const ProductLocationServiceImpl();

  @override
  Future<ProductLocation> captureCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const ProductLocationException(
        'Aktifkan layanan lokasi perangkat untuk menyimpan lokasi produk.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const ProductLocationException('Izin lokasi tidak diberikan.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const ProductLocationException(
        'Izin lokasi diblokir. Aktifkan kembali melalui pengaturan aplikasi.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return ProductLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      capturedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> openInMaps(ProductLocation location) async {
    final openedInMaps = await launchUrl(
      location.mapsUri,
      mode: LaunchMode.externalNonBrowserApplication,
    );
    if (openedInMaps) return true;
    return launchUrl(location.mapsUri, mode: LaunchMode.externalApplication);
  }
}
