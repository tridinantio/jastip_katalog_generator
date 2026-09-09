import '../entities/trip.dart';
import '../entities/trip_export_file.dart';

abstract interface class TripExportService {
  Future<TripExportResult> export(Trip trip);
}

abstract interface class TripExportFileSharer {
  Future<void> share(TripExportFile file);
}
