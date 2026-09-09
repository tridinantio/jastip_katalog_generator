import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/backup.dart';
import '../../domain/services/backup_restore_service.dart';

class BackupRestoreServiceImpl implements BackupRestoreService {
  BackupRestoreServiceImpl(this._database, this._sharer);

  static const _formatVersion = 1;
  static const _manifestPath = 'manifest.json';
  static const _dataPath = 'data.json';

  final AppDatabase _database;
  final BackupFileSharer _sharer;

  @override
  Future<BackupResult> createAndShare() async {
    final createdAt = DateTime.now().toUtc();
    final trips = await _database.select(_database.trips).get();
    final products = await _database.select(_database.products).get();
    final generatedAssets = await _database
        .select(_database.generatedAssets)
        .get();
    final exchangeRates = await _database
        .select(_database.exchangeRateCaches)
        .get();
    final requests = await _loadShoppingRequests();
    final summary = BackupSummary(
      createdAt: createdAt,
      tripCount: trips.length,
      productCount: products.length,
      buyerRequestCount: requests.length,
      generatedAssetCount: generatedAssets.length,
    );

    final archive = Archive();
    final productData = <Map<String, Object?>>[];
    for (final product in products) {
      final imagePath = 'images/${product.id}.bin';
      final thumbnailPath = 'thumbnails/${product.id}.bin';
      archive.addFile(ArchiveFile.bytes(imagePath, product.imageBytes));
      archive.addFile(ArchiveFile.bytes(thumbnailPath, product.thumbnailBytes));
      productData.add({
        'id': product.id,
        'tripId': product.tripId,
        'name': product.name,
        'originalPriceMinor': product.originalPriceMinor,
        'sellingPriceIdr': product.sellingPriceIdr,
        'markupBasisPointsOverride': product.markupBasisPointsOverride,
        'fixedFeeIdrOverride': product.fixedFeeIdrOverride,
        'weightGrams': product.weightGrams,
        'note': product.note,
        'category': product.category,
        'imageMimeType': product.imageMimeType,
        'latitude': product.latitude,
        'longitude': product.longitude,
        'locationLabel': product.locationLabel,
        'locationCapturedAt': _date(product.locationCapturedAt),
        'createdAt': _date(product.createdAt),
        'updatedAt': _date(product.updatedAt),
        'imagePath': imagePath,
        'thumbnailPath': thumbnailPath,
      });
    }

    final assetData = <Map<String, Object?>>[];
    for (final asset in generatedAssets) {
      final path = 'generated_assets/${asset.id}.png';
      archive.addFile(ArchiveFile.bytes(path, asset.pngBytes));
      assetData.add({
        'id': asset.id,
        'productId': asset.productId,
        'backgroundColor': asset.backgroundColor,
        'createdAt': _date(asset.createdAt),
        'path': path,
      });
    }

    final data = <String, Object?>{
      'trips': trips
          .map(
            (trip) => {
              'id': trip.id,
              'name': trip.name,
              'country': trip.country,
              'currencyCode': trip.currencyCode,
              'currencyName': trip.currencyName,
              'currencySymbol': trip.currencySymbol,
              'rateMicros': trip.rateMicros,
              'rateDate': _date(trip.rateDate),
              'rateFetchedAt': _date(trip.rateFetchedAt),
              'markupBasisPoints': trip.markupBasisPoints,
              'fixedFeeIdr': trip.fixedFeeIdr,
              'roundingUnitIdr': trip.roundingUnitIdr,
              'isActive': trip.isActive,
              'createdAt': _date(trip.createdAt),
              'updatedAt': _date(trip.updatedAt),
            },
          )
          .toList(growable: false),
      'products': productData,
      'generatedAssets': assetData,
      'shoppingRequests': requests,
      'exchangeRateCaches': exchangeRates
          .map(
            (rate) => {
              'baseCurrency': rate.baseCurrency,
              'quoteCurrency': rate.quoteCurrency,
              'rateMicros': rate.rateMicros,
              'rateDate': _date(rate.rateDate),
              'fetchedAt': _date(rate.fetchedAt),
            },
          )
          .toList(growable: false),
    };
    final manifest = <String, Object?>{
      'format': 'jastip-katalog-backup',
      'formatVersion': _formatVersion,
      'createdAt': createdAt.toIso8601String(),
      'tripCount': summary.tripCount,
      'productCount': summary.productCount,
      'buyerRequestCount': summary.buyerRequestCount,
      'generatedAssetCount': summary.generatedAssetCount,
    };
    archive.addFile(ArchiveFile.string(_manifestPath, jsonEncode(manifest)));
    archive.addFile(ArchiveFile.string(_dataPath, jsonEncode(data)));

    final zipBytes = Uint8List.fromList(ZipEncoder().encode(archive));
    final fileName = 'jastip_backup_${_fileDate(createdAt)}.jastip';
    await _sharer.share(BackupShareFile(fileName: fileName, bytes: zipBytes));
    return BackupResult(fileName: fileName, summary: summary);
  }

  @override
  Future<BackupCandidate?> pickBackup() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['jastip', 'zip'],
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    if (bytes.isEmpty) {
      throw const FormatException('File backup tidak dapat dibaca.');
    }
    final decoded = _decode(Uint8List.fromList(bytes), picked.name);
    return BackupCandidate(
      fileName: picked.name,
      bytes: Uint8List.fromList(bytes),
      summary: decoded.summary,
    );
  }

  @override
  Future<void> restore(BackupCandidate candidate) async {
    final decoded = _decode(candidate.bytes, candidate.fileName);
    final prepared = _prepare(decoded);
    await _database.transaction(() async {
      await _database.customStatement('DELETE FROM generated_assets');
      await _database.customStatement('DELETE FROM shopping_requests');
      await _database.customStatement('DELETE FROM products');
      await _database.customStatement('DELETE FROM trips');
      await _database.customStatement('DELETE FROM exchange_rate_caches');

      for (final trip in prepared.trips) {
        await _database.into(_database.trips).insert(trip);
      }
      for (final product in prepared.products) {
        await _database.into(_database.products).insert(product);
      }
      for (final request in prepared.requests) {
        await _database.customStatement(
          '''INSERT INTO shopping_requests
             (id, trip_id, product_id, buyer_name, quantity, note,
              is_purchased, purchased_at, created_at, updated_at)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
          [
            request.id,
            request.tripId,
            request.productId,
            request.buyerName,
            request.quantity,
            request.note,
            request.isPurchased ? 1 : 0,
            request.purchasedAt,
            request.createdAt,
            request.updatedAt,
          ],
        );
      }
      for (final asset in prepared.generatedAssets) {
        await _database.into(_database.generatedAssets).insert(asset);
      }
      for (final rate in prepared.exchangeRates) {
        await _database.into(_database.exchangeRateCaches).insert(rate);
      }
    });
  }

  Future<List<Map<String, Object?>>> _loadShoppingRequests() async {
    final rows = await _database.customSelect(
      '''SELECT id, trip_id, product_id, buyer_name, quantity, note,
                    is_purchased, purchased_at, created_at, updated_at
             FROM shopping_requests ORDER BY created_at ASC''',
    ).get();
    return rows
        .map(
          (row) => {
            'id': row.read<String>('id'),
            'tripId': row.read<String>('trip_id'),
            'productId': row.read<String>('product_id'),
            'buyerName': row.read<String>('buyer_name'),
            'quantity': row.read<int>('quantity'),
            'note': row.read<String>('note'),
            'isPurchased': row.read<int>('is_purchased') == 1,
            'purchasedAt': row.readNullable<String>('purchased_at') ?? '',
            'createdAt': row.read<String>('created_at'),
            'updatedAt': row.read<String>('updated_at'),
          },
        )
        .toList(growable: false);
  }

  _DecodedBackup _decode(Uint8List bytes, String fileName) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final manifest = _readJsonMap(archive, _manifestPath);
      final data = _readJsonMap(archive, _dataPath);
      if (manifest['format'] != 'jastip-katalog-backup' ||
          manifest['formatVersion'] != _formatVersion) {
        throw const FormatException('Format backup tidak didukung.');
      }
      final createdAt = _parseDate(manifest['createdAt'], 'createdAt');
      final trips = _list(data, 'trips');
      final products = _list(data, 'products');
      final requests = _list(data, 'shoppingRequests');
      final assets = _list(data, 'generatedAssets');
      final activeCount = trips
          .where((item) => item['isActive'] == true)
          .length;
      if (trips.isEmpty || activeCount != 1) {
        throw const FormatException(
          'Backup tidak memiliki trip aktif yang valid.',
        );
      }
      for (final product in products) {
        _requireFile(archive, product['imagePath'], 'foto produk');
        _requireFile(archive, product['thumbnailPath'], 'thumbnail produk');
      }
      for (final asset in assets) {
        _requireFile(archive, asset['path'], 'aset katalog');
      }
      return _DecodedBackup(
        archive: archive,
        data: data,
        summary: BackupSummary(
          createdAt: createdAt,
          tripCount: trips.length,
          productCount: products.length,
          buyerRequestCount: requests.length,
          generatedAssetCount: assets.length,
        ),
      );
    } on FormatException {
      rethrow;
    } catch (error) {
      throw FormatException('File backup rusak atau tidak valid: $error');
    }
  }

  _PreparedBackup _prepare(_DecodedBackup decoded) {
    final trips = _list(decoded.data, 'trips')
        .map(
          (item) => TripsCompanion.insert(
            id: _string(item, 'id'),
            name: _string(item, 'name'),
            country: Value(_string(item, 'country')),
            currencyCode: _string(item, 'currencyCode'),
            currencyName: _string(item, 'currencyName'),
            currencySymbol: _string(item, 'currencySymbol'),
            rateMicros: Value(_int(item, 'rateMicros')),
            rateDate: Value(_nullableDate(item['rateDate'], 'rateDate')),
            rateFetchedAt: Value(
              _nullableDate(item['rateFetchedAt'], 'rateFetchedAt'),
            ),
            markupBasisPoints: Value(_int(item, 'markupBasisPoints')),
            fixedFeeIdr: Value(_int(item, 'fixedFeeIdr')),
            roundingUnitIdr: Value(_int(item, 'roundingUnitIdr')),
            isActive: Value(item['isActive'] == true),
            createdAt: _dateRequired(item, 'createdAt'),
            updatedAt: _dateRequired(item, 'updatedAt'),
          ),
        )
        .toList(growable: false);
    final products = _list(decoded.data, 'products')
        .map(
          (item) => ProductsCompanion.insert(
            id: _string(item, 'id'),
            tripId: _string(item, 'tripId'),
            name: _string(item, 'name'),
            originalPriceMinor: _int(item, 'originalPriceMinor'),
            sellingPriceIdr: _int(item, 'sellingPriceIdr'),
            markupBasisPointsOverride: Value(
              _nullableInt(item['markupBasisPointsOverride']),
            ),
            fixedFeeIdrOverride: Value(
              _nullableInt(item['fixedFeeIdrOverride']),
            ),
            weightGrams: Value(_nullableInt(item['weightGrams'])),
            note: Value(_string(item, 'note')),
            category: Value(_string(item, 'category')),
            imageBytes: _archiveBytes(decoded.archive, item['imagePath']),
            thumbnailBytes: _archiveBytes(
              decoded.archive,
              item['thumbnailPath'],
            ),
            imageMimeType: _string(item, 'imageMimeType'),
            latitude: Value(_nullableDouble(item['latitude'])),
            longitude: Value(_nullableDouble(item['longitude'])),
            locationLabel: Value(_nullableString(item['locationLabel'])),
            locationCapturedAt: Value(
              _nullableDate(item['locationCapturedAt'], 'locationCapturedAt'),
            ),
            createdAt: _dateRequired(item, 'createdAt'),
            updatedAt: _dateRequired(item, 'updatedAt'),
          ),
        )
        .toList(growable: false);
    final requests = _list(decoded.data, 'shoppingRequests')
        .map(
          (item) => _RequestData(
            id: _string(item, 'id'),
            tripId: _string(item, 'tripId'),
            productId: _string(item, 'productId'),
            buyerName: _string(item, 'buyerName'),
            quantity: _int(item, 'quantity'),
            note: _string(item, 'note'),
            isPurchased: item['isPurchased'] == true,
            purchasedAt: _string(item, 'purchasedAt'),
            createdAt: _string(item, 'createdAt'),
            updatedAt: _string(item, 'updatedAt'),
          ),
        )
        .toList(growable: false);
    final generatedAssets = _list(decoded.data, 'generatedAssets')
        .map(
          (item) => GeneratedAssetsCompanion.insert(
            id: _string(item, 'id'),
            productId: _string(item, 'productId'),
            pngBytes: _archiveBytes(decoded.archive, item['path']),
            backgroundColor: _int(item, 'backgroundColor'),
            createdAt: _dateRequired(item, 'createdAt'),
          ),
        )
        .toList(growable: false);
    final exchangeRates = _list(decoded.data, 'exchangeRateCaches')
        .map(
          (item) => ExchangeRateCachesCompanion.insert(
            baseCurrency: _string(item, 'baseCurrency'),
            quoteCurrency: Value(_string(item, 'quoteCurrency')),
            rateMicros: _int(item, 'rateMicros'),
            rateDate: _dateRequired(item, 'rateDate'),
            fetchedAt: _dateRequired(item, 'fetchedAt'),
          ),
        )
        .toList(growable: false);
    return _PreparedBackup(
      trips: trips,
      products: products,
      requests: requests,
      generatedAssets: generatedAssets,
      exchangeRates: exchangeRates,
    );
  }

  static Map<String, dynamic> _readJsonMap(Archive archive, String path) {
    final file = _findFile(archive, path);
    final decoded = jsonDecode(utf8.decode(file.readBytes()!));
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('$path tidak valid.');
    }
    return decoded;
  }

  static List<Map<String, dynamic>> _list(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];
    if (value is! List) throw FormatException('$key tidak valid.');
    return value
        .map((item) {
          if (item is! Map) throw FormatException('$key berisi data invalid.');
          return Map<String, dynamic>.from(item);
        })
        .toList(growable: false);
  }

  static void _requireFile(Archive archive, Object? path, String label) {
    if (path is! String || path.isEmpty) {
      throw FormatException('$label tidak memiliki referensi file.');
    }
    _findFile(archive, path);
  }

  static ArchiveFile _findFile(Archive archive, String path) {
    for (final file in archive) {
      if (file.isFile && file.name == path) return file;
    }
    throw FormatException('File backup tidak lengkap: $path.');
  }

  static Uint8List _archiveBytes(Archive archive, Object? path) {
    if (path is! String) {
      throw const FormatException('Referensi gambar invalid.');
    }
    return _findFile(archive, path).readBytes()!;
  }

  static String _string(Map<String, dynamic> item, String key) {
    final value = item[key];
    if (value is! String) throw FormatException('$key tidak valid.');
    return value;
  }

  static String? _nullableString(Object? value) =>
      value is String ? value : null;

  static int _int(Map<String, dynamic> item, String key) {
    final value = item[key];
    if (value is! num) throw FormatException('$key tidak valid.');
    return value.toInt();
  }

  static int? _nullableInt(Object? value) =>
      value is num ? value.toInt() : null;

  static double? _nullableDouble(Object? value) =>
      value is num ? value.toDouble() : null;

  static DateTime _dateRequired(Map<String, dynamic> item, String key) =>
      _parseDate(item[key], key);

  static DateTime? _nullableDate(Object? value, String key) {
    if (value == null || value == '') return null;
    return _parseDate(value, key);
  }

  static DateTime _parseDate(Object? value, String key) {
    if (value is! String) throw FormatException('$key tidak valid.');
    final parsed = DateTime.tryParse(value);
    if (parsed == null) throw FormatException('$key tidak valid.');
    return parsed;
  }

  static String? _date(DateTime? value) => value?.toUtc().toIso8601String();

  static String _fileDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}'
      '${value.month.toString().padLeft(2, '0')}'
      '${value.day.toString().padLeft(2, '0')}_'
      '${value.hour.toString().padLeft(2, '0')}'
      '${value.minute.toString().padLeft(2, '0')}';
}

class _DecodedBackup {
  const _DecodedBackup({
    required this.archive,
    required this.data,
    required this.summary,
  });

  final Archive archive;
  final Map<String, dynamic> data;
  final BackupSummary summary;
}

class _PreparedBackup {
  const _PreparedBackup({
    required this.trips,
    required this.products,
    required this.requests,
    required this.generatedAssets,
    required this.exchangeRates,
  });

  final List<TripsCompanion> trips;
  final List<ProductsCompanion> products;
  final List<_RequestData> requests;
  final List<GeneratedAssetsCompanion> generatedAssets;
  final List<ExchangeRateCachesCompanion> exchangeRates;
}

class _RequestData {
  const _RequestData({
    required this.id,
    required this.tripId,
    required this.productId,
    required this.buyerName,
    required this.quantity,
    required this.note,
    required this.isPurchased,
    required this.purchasedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String tripId;
  final String productId;
  final String buyerName;
  final int quantity;
  final String note;
  final bool isPurchased;
  final String purchasedAt;
  final String createdAt;
  final String updatedAt;
}
