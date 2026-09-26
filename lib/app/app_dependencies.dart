import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../core/database/app_database.dart';
import '../features/backup/data/services/backup_restore_service_impl.dart';
import '../features/backup/data/services/share_plus_backup_file_sharer.dart';
import '../features/backup/domain/services/backup_restore_service.dart';
import '../features/product/data/data_sources/product_local_data_source.dart';
import '../features/product/data/repositories/product_repository_impl.dart';
import '../features/product/data/services/catalog_export_service_impl.dart';
import '../features/product/data/services/product_image_picker_impl.dart';
import '../features/product/data/services/product_location_service_impl.dart';
import '../features/product/domain/repositories/product_repository.dart';
import '../features/product/domain/services/image_services.dart';
import '../features/product/domain/services/location_services.dart';
import '../features/trip/data/data_sources/frankfurter_service.dart';
import '../features/trip/data/data_sources/trip_local_data_source.dart';
import '../features/trip/data/repositories/trip_repository_impl.dart';
import '../features/trip/data/services/share_plus_trip_export_file_sharer.dart';
import '../features/trip/data/services/trip_excel_export_service_impl.dart';
import '../features/trip/domain/repositories/trip_repository.dart';
import '../features/trip/domain/services/trip_export_service.dart';
import '../features/shopping/data/data_sources/shopping_local_data_source.dart';
import '../features/shopping/data/repositories/shopping_repository_impl.dart';
import '../features/shopping/data/services/shopping_checklist_workbook_service_impl.dart';
import '../features/shopping/domain/repositories/shopping_repository.dart';
import '../features/shopping/domain/services/shopping_checklist_workbook_service.dart';

class AppDependencies {
  const AppDependencies({
    required this.database,
    required this.tripRepository,
    required this.exchangeRateRepository,
    required this.productRepository,
    required this.imagePicker,
    required this.locationService,
    required this.catalogExportService,
    required this.tripExportService,
    required this.shoppingRepository,
    required this.shoppingChecklistWorkbookService,
    required this.backupRestoreService,
  });

  factory AppDependencies.create() {
    final database = AppDatabase();
    final tripLocal = TripLocalDataSource(database);
    final productLocal = ProductLocalDataSource(database);
    final shoppingLocal = ShoppingLocalDataSource(database);
    final client = http.Client();
    return AppDependencies(
      database: database,
      tripRepository: TripRepositoryImpl(tripLocal),
      exchangeRateRepository: ExchangeRateRepositoryImpl(
        FrankfurterService(client),
        tripLocal,
      ),
      productRepository: ProductRepositoryImpl(productLocal),
      imagePicker: ProductImagePickerImpl(ImagePicker()),
      locationService: const ProductLocationServiceImpl(),
      catalogExportService: const CatalogExportServiceImpl(),
      tripExportService: TripExcelExportServiceImpl(
        database,
        const SharePlusTripExportFileSharer(),
      ),
      shoppingRepository: ShoppingRepositoryImpl(shoppingLocal),
      shoppingChecklistWorkbookService:
          const ShoppingChecklistWorkbookServiceImpl(
            SharePlusShoppingChecklistFileSharer(),
          ),
      backupRestoreService: BackupRestoreServiceImpl(
        database,
        const SharePlusBackupFileSharer(),
      ),
    );
  }

  final AppDatabase database;
  final TripRepository tripRepository;
  final ExchangeRateRepository exchangeRateRepository;
  final ProductRepository productRepository;
  final ProductImagePicker imagePicker;
  final ProductLocationService locationService;
  final CatalogExportService catalogExportService;
  final TripExportService tripExportService;
  final ShoppingRepository shoppingRepository;
  final ShoppingChecklistWorkbookService shoppingChecklistWorkbookService;
  final BackupRestoreService backupRestoreService;
}
