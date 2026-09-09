import 'package:drift/drift.dart';
import 'package:excel_community/excel_community.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../product/domain/use_cases/calculate_product_price.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_export_file.dart';
import '../../domain/services/trip_export_service.dart';

class TripExcelExportServiceImpl implements TripExportService {
  TripExcelExportServiceImpl(this._database, this._sharer);

  final AppDatabase _database;
  final TripExportFileSharer _sharer;

  @override
  Future<TripExportResult> export(Trip trip) async {
    final products =
        await (_database.select(_database.products)
              ..where((table) => table.tripId.equals(trip.id))
              ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
            .get();
    final requests = await _loadRequests(trip.id);
    final requestsByProduct = <String, List<_ExportRequest>>{};
    for (final request in requests) {
      (requestsByProduct[request.productId] ??= []).add(request);
    }

    final workbook = Excel.createExcel();
    workbook.rename('Sheet1', 'Ringkasan');
    final summarySheet = workbook['Ringkasan'];
    final productsSheet = workbook['Produk'];
    final buyersSheet = workbook['Pembeli'];

    _writeSummary(summarySheet, trip, products, requests);
    _writeProducts(productsSheet, trip, products, requestsByProduct);
    _writeBuyers(buyersSheet, products, requests);

    final bytes = workbook.encode();
    if (bytes == null || bytes.isEmpty) {
      throw StateError('File Excel tidak dapat dibuat.');
    }

    final file = TripExportFile(
      fileName:
          'trip_${_safeFileName(trip.name)}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx',
      bytes: Uint8List.fromList(bytes),
    );
    await _sharer.share(file);
    return TripExportResult(fileName: file.fileName);
  }

  Future<List<_ExportRequest>> _loadRequests(String tripId) async {
    final rows = await _database
        .customSelect(
          '''SELECT id, product_id, buyer_name, quantity, note, is_purchased,
                    purchased_at, created_at, updated_at
             FROM shopping_requests
             WHERE trip_id = ?
             ORDER BY created_at ASC''',
          variables: [Variable<String>(tripId)],
        )
        .get();
    return rows
        .map(
          (row) => _ExportRequest(
            id: row.read<String>('id'),
            productId: row.read<String>('product_id'),
            buyerName: row.read<String>('buyer_name'),
            quantity: row.read<int>('quantity'),
            note: row.read<String>('note'),
            isPurchased: row.read<int>('is_purchased') == 1,
            purchasedAt: DateTime.tryParse(row.read<String>('purchased_at')),
            createdAt: DateTime.parse(row.read<String>('created_at')),
            updatedAt: DateTime.parse(row.read<String>('updated_at')),
          ),
        )
        .toList(growable: false);
  }

  void _writeSummary(
    Sheet sheet,
    Trip trip,
    List<ProductRecord> products,
    List<_ExportRequest> requests,
  ) {
    final perProduct = <String, PriceBreakdown>{
      for (final product in products)
        product.id: CalculateProductPrice.call(
          originalPriceMinor: product.originalPriceMinor,
          trip: trip,
          markupBasisPointsOverride: product.markupBasisPointsOverride,
          fixedFeeIdrOverride: product.fixedFeeIdrOverride,
        ),
    };
    final totalUnits = requests.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final purchasedUnits = requests
        .where((item) => item.isPurchased)
        .fold<int>(0, (sum, item) => sum + item.quantity);
    final estimatedCapital = requests.fold<int>(
      0,
      (sum, item) =>
          sum + (perProduct[item.productId]?.capitalIdr ?? 0) * item.quantity,
    );
    final actualCapital = requests
        .where((item) => item.isPurchased)
        .fold<int>(
          0,
          (sum, item) =>
              sum +
              (perProduct[item.productId]?.capitalIdr ?? 0) * item.quantity,
        );
    final estimatedRevenue = requests.fold<int>(
      0,
      (sum, item) =>
          sum +
          (perProduct[item.productId]?.sellingPriceIdr ?? 0) * item.quantity,
    );

    _put(
      sheet,
      0,
      0,
      TextCellValue('EXPORT TRIP · JASTIP KATALOG'),
      style: _titleStyle,
    );
    _put(sheet, 0, 2, TextCellValue('Trip'), style: _headerStyle);
    _put(sheet, 1, 2, TextCellValue(trip.name));
    _put(sheet, 0, 3, TextCellValue('Diekspor pada'), style: _headerStyle);
    _put(sheet, 1, 3, _dateTimeCell(DateTime.now()));
    _put(sheet, 0, 4, TextCellValue('Negara'), style: _headerStyle);
    _put(sheet, 1, 4, TextCellValue(trip.country));
    _put(sheet, 0, 5, TextCellValue('PENGATURAN HARGA'), style: _titleStyle);
    _put(sheet, 0, 6, TextCellValue('Mata uang'), style: _headerStyle);
    _put(
      sheet,
      1,
      6,
      TextCellValue('${trip.currencyCode} · ${trip.currencyName}'),
    );
    _put(sheet, 0, 7, TextCellValue('Kurs ke IDR'), style: _headerStyle);
    _put(sheet, 1, 7, DoubleCellValue(trip.rateMicros / 1000000));
    _put(sheet, 0, 8, TextCellValue('Tanggal kurs'), style: _headerStyle);
    _put(
      sheet,
      1,
      8,
      trip.rateDate == null
          ? TextCellValue('-')
          : _dateTimeCell(trip.rateDate!),
    );
    _put(sheet, 0, 9, TextCellValue('Markup'), style: _headerStyle);
    _put(sheet, 1, 9, DoubleCellValue(trip.markupPercent));
    _put(
      sheet,
      0,
      10,
      TextCellValue('Biaya tetap / produk (Rp)'),
      style: _headerStyle,
    );
    _put(sheet, 1, 10, IntCellValue(trip.fixedFeeIdr));
    _put(sheet, 0, 11, TextCellValue('Pembulatan (Rp)'), style: _headerStyle);
    _put(sheet, 1, 11, IntCellValue(trip.roundingUnitIdr));
    _put(
      sheet,
      0,
      12,
      TextCellValue('Kurs diperbarui pada'),
      style: _headerStyle,
    );
    _put(
      sheet,
      1,
      12,
      trip.rateFetchedAt == null
          ? TextCellValue('-')
          : _dateTimeCell(trip.rateFetchedAt!),
    );

    _put(sheet, 0, 13, TextCellValue('REKAP PESANAN'), style: _titleStyle);
    _put(sheet, 0, 14, TextCellValue('Produk'), style: _headerStyle);
    _put(sheet, 1, 14, IntCellValue(products.length));
    _put(sheet, 0, 15, TextCellValue('Pesanan'), style: _headerStyle);
    _put(sheet, 1, 15, IntCellValue(requests.length));
    _put(sheet, 0, 16, TextCellValue('Unit dipesan'), style: _headerStyle);
    _put(sheet, 1, 16, IntCellValue(totalUnits));
    _put(sheet, 0, 17, TextCellValue('Unit terbeli'), style: _headerStyle);
    _put(sheet, 1, 17, IntCellValue(purchasedUnits));
    _put(
      sheet,
      0,
      18,
      TextCellValue('Estimasi modal (Rp)'),
      style: _headerStyle,
    );
    _put(sheet, 1, 18, IntCellValue(estimatedCapital));
    _put(
      sheet,
      0,
      19,
      TextCellValue('Belanja aktual (Rp)'),
      style: _headerStyle,
    );
    _put(sheet, 1, 19, IntCellValue(actualCapital));
    _put(
      sheet,
      0,
      20,
      TextCellValue('Estimasi omzet (Rp)'),
      style: _headerStyle,
    );
    _put(sheet, 1, 20, IntCellValue(estimatedRevenue));
    _put(
      sheet,
      0,
      21,
      TextCellValue('Estimasi keuntungan (Rp)'),
      style: _headerStyle,
    );
    _put(sheet, 1, 21, IntCellValue(estimatedRevenue - estimatedCapital));

    sheet.setColumnWidth(0, 31);
    sheet.setColumnWidth(1, 30);
  }

  void _writeProducts(
    Sheet sheet,
    Trip trip,
    List<ProductRecord> products,
    Map<String, List<_ExportRequest>> requestsByProduct,
  ) {
    const headers = [
      'Foto',
      'ID Produk',
      'Nama',
      'Kategori',
      'Berat (gram)',
      'Harga asli',
      'Mata uang',
      'Modal (Rp)',
      'Harga jual (Rp)',
      'Keuntungan/unit (Rp)',
      'Margin khusus (%)',
      'Biaya tetap khusus (Rp)',
      'Catatan',
      'Nama lokasi',
      'Latitude',
      'Longitude',
      'Link Maps',
      'Pesanan',
      'Terbeli',
      'Belum terbeli',
      'Dibuat',
      'Diubah',
    ];
    _writeHeaders(sheet, headers);
    for (var index = 0; index < products.length; index++) {
      final product = products[index];
      final row = index + 1;
      final pricing = CalculateProductPrice.call(
        originalPriceMinor: product.originalPriceMinor,
        trip: trip,
        markupBasisPointsOverride: product.markupBasisPointsOverride,
        fixedFeeIdrOverride: product.fixedFeeIdrOverride,
      );
      final requests =
          requestsByProduct[product.id] ?? const <_ExportRequest>[];
      final units = requests.fold<int>(0, (sum, item) => sum + item.quantity);
      final purchased = requests
          .where((item) => item.isPurchased)
          .fold<int>(0, (sum, item) => sum + item.quantity);
      final mapUrl = product.latitude == null || product.longitude == null
          ? ''
          : 'https://www.google.com/maps/search/?api=1&query=${product.latitude},${product.longitude}';
      final values = <CellValue>[
        TextCellValue(''),
        TextCellValue(product.id),
        TextCellValue(product.name),
        TextCellValue(product.category),
        product.weightGrams == null
            ? TextCellValue('')
            : IntCellValue(product.weightGrams!),
        DoubleCellValue(product.originalPriceMinor / 100),
        TextCellValue(trip.currencyCode),
        IntCellValue(pricing.capitalIdr),
        IntCellValue(pricing.sellingPriceIdr),
        IntCellValue(pricing.sellingPriceIdr - pricing.capitalIdr),
        product.markupBasisPointsOverride == null
            ? TextCellValue('')
            : DoubleCellValue(product.markupBasisPointsOverride! / 100),
        product.fixedFeeIdrOverride == null
            ? TextCellValue('')
            : IntCellValue(product.fixedFeeIdrOverride!),
        TextCellValue(product.note),
        TextCellValue(product.locationLabel ?? ''),
        product.latitude == null
            ? TextCellValue('')
            : DoubleCellValue(product.latitude!),
        product.longitude == null
            ? TextCellValue('')
            : DoubleCellValue(product.longitude!),
        TextCellValue(mapUrl),
        IntCellValue(units),
        IntCellValue(purchased),
        IntCellValue(units - purchased),
        _dateTimeCell(product.createdAt),
        _dateTimeCell(product.updatedAt),
      ];
      for (var column = 0; column < values.length; column++) {
        _put(sheet, column, row, values[column]);
      }
      _addThumbnail(sheet, product.thumbnailBytes, row);
      sheet.setRowHeight(row, 56.0);
    }
    _configureProductSheet(sheet);
  }

  void _writeBuyers(
    Sheet sheet,
    List<ProductRecord> products,
    List<_ExportRequest> requests,
  ) {
    const headers = [
      'No.',
      'ID Pesanan',
      'ID Produk',
      'Produk',
      'Nama pembeli',
      'Jumlah',
      'Status',
      'Catatan',
      'Dibeli pada',
      'Dibuat',
      'Diubah',
    ];
    _writeHeaders(sheet, headers);
    final productNames = {
      for (final product in products) product.id: product.name,
    };
    for (var index = 0; index < requests.length; index++) {
      final request = requests[index];
      final row = index + 1;
      final values = <CellValue>[
        IntCellValue(index + 1),
        TextCellValue(request.id),
        TextCellValue(request.productId),
        TextCellValue(productNames[request.productId] ?? '-'),
        TextCellValue(request.buyerName),
        IntCellValue(request.quantity),
        TextCellValue(request.isPurchased ? 'Terbeli' : 'Belum terbeli'),
        TextCellValue(request.note),
        request.purchasedAt == null
            ? TextCellValue('')
            : _dateTimeCell(request.purchasedAt!),
        _dateTimeCell(request.createdAt),
        _dateTimeCell(request.updatedAt),
      ];
      for (var column = 0; column < values.length; column++) {
        _put(sheet, column, row, values[column]);
      }
    }
    sheet.frozenRows = 1;
    sheet.setColumnWidth(0, 7);
    sheet.setColumnWidth(1, 24);
    sheet.setColumnWidth(2, 24);
    sheet.setColumnWidth(3, 28);
    sheet.setColumnWidth(4, 22);
    sheet.setColumnWidth(5, 10);
    sheet.setColumnWidth(6, 16);
    sheet.setColumnWidth(7, 32);
    sheet.setColumnWidth(8, 20);
    sheet.setColumnWidth(9, 20);
    sheet.setColumnWidth(10, 20);
  }

  void _writeHeaders(Sheet sheet, List<String> headers) {
    for (var column = 0; column < headers.length; column++) {
      _put(
        sheet,
        column,
        0,
        TextCellValue(headers[column]),
        style: _headerStyle,
      );
    }
    sheet.frozenRows = 1;
  }

  void _configureProductSheet(Sheet sheet) {
    sheet.frozenRows = 1;
    sheet.frozenColumns = 1;
    const widths = <double>[
      12,
      24,
      30,
      18,
      14,
      16,
      12,
      16,
      18,
      21,
      18,
      22,
      34,
      28,
      14,
      14,
      48,
      12,
      12,
      16,
      20,
      20,
    ];
    for (var index = 0; index < widths.length; index++) {
      sheet.setColumnWidth(index, widths[index]);
    }
  }

  void _addThumbnail(Sheet sheet, Uint8List bytes, int row) {
    final imageType = _imageType(bytes);
    if (imageType == null) return;
    sheet.addImage(
      ExcelImage(
        imageBytes: bytes,
        imageType: imageType,
        anchor: ImageAnchor.fromPixels(
          column: 0,
          row: row,
          widthPixels: 52,
          heightPixels: 52,
        ),
      ),
    );
  }

  ExcelImageType? _imageType(Uint8List bytes) {
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4e &&
        bytes[3] == 0x47) {
      return ExcelImageType.png;
    }
    if (bytes.length >= 2 && bytes[0] == 0xff && bytes[1] == 0xd8) {
      return ExcelImageType.jpeg;
    }
    return null;
  }

  void _put(
    Sheet sheet,
    int column,
    int row,
    CellValue value, {
    CellStyle? style,
  }) {
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
      value,
      cellStyle: style,
    );
  }
}

final _titleStyle = CellStyle(bold: true, fontSize: 14);
final _headerStyle = CellStyle(bold: true);

DateTimeCellValue _dateTimeCell(DateTime dateTime) => DateTimeCellValue(
  year: dateTime.year,
  month: dateTime.month,
  day: dateTime.day,
  hour: dateTime.hour,
  minute: dateTime.minute,
  second: dateTime.second,
  millisecond: dateTime.millisecond,
);

String _safeFileName(String value) {
  final sanitized = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return sanitized.isEmpty ? 'jastip' : sanitized;
}

class _ExportRequest {
  const _ExportRequest({
    required this.id,
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
  final String productId;
  final String buyerName;
  final int quantity;
  final String note;
  final bool isPurchased;
  final DateTime? purchasedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}
