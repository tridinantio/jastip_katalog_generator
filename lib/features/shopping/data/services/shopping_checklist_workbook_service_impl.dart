import 'dart:typed_data';
import 'dart:ui';

import 'package:excel_community/excel_community.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/shopping_checklist.dart';
import '../../domain/services/shopping_checklist_workbook_service.dart';

class ShoppingChecklistWorkbookServiceImpl
    implements ShoppingChecklistWorkbookService {
  const ShoppingChecklistWorkbookServiceImpl(this._sharer);

  static const _listSheetName = 'Daftar Belanja';
  static const _syncSheetName = 'Sinkronisasi';
  static const _firstItemRow = 5;
  static const _workbookTitle = 'DAFTAR BELANJA JASTIP';

  final ShoppingChecklistFileSharer _sharer;

  @override
  Future<void> export(ShoppingChecklist checklist) async {
    final workbook = Excel.createExcel();
    workbook.rename('Sheet1', _listSheetName);
    final listSheet = workbook[_listSheetName];
    final syncSheet = workbook[_syncSheetName];
    _writeListSheet(listSheet, checklist);
    _writeSyncSheet(syncSheet, checklist);

    final bytes = workbook.encode();
    if (bytes == null || bytes.isEmpty) {
      throw StateError('File Excel tidak dapat dibuat.');
    }
    final fileName =
        'daftar_belanja_${_safeFileName(checklist.tripName)}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
    await _sharer.share(fileName, Uint8List.fromList(bytes));
  }

  @override
  Future<ShoppingChecklistImportResult> importChecklist(String tripId) async {
    final result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result == null) return const ShoppingChecklistImportResult.cancelled();
    final bytes = await result.readAsBytes();
    if (bytes.isEmpty) {
      throw const FormatException('File Excel tidak dapat dibaca.');
    }
    return parseImport(Uint8List.fromList(bytes), tripId);
  }

  ShoppingChecklistImportResult parseImport(Uint8List bytes, String tripId) {
    final workbook = Excel.decodeBytes(bytes);
    final listSheet = workbook.tables[_listSheetName];
    final syncSheet = workbook.tables[_syncSheetName];
    if (listSheet == null || syncSheet == null) {
      throw const FormatException(
        'Gunakan file daftar belanja dari Jastip Katalog.',
      );
    }
    if (_cellText(listSheet, 0, 0) != _workbookTitle) {
      throw const FormatException('Format daftar belanja tidak dikenali.');
    }
    if (_cellText(syncSheet, 1, 1) != tripId) {
      throw const FormatException('Daftar belanja ini berasal dari trip lain.');
    }

    final updates = <ShoppingChecklistUpdate>[];
    for (var row = _firstItemRow; row < syncSheet.maxRows; row++) {
      final productId = _cellText(syncSheet, row, 0);
      if (productId.isEmpty) continue;
      final originalStatus = _cellText(syncSheet, row, 1);
      final originalValue = _statusValue(originalStatus);
      final currentValue = _checklistValue(_cellText(listSheet, row, 0));
      if (currentValue == null || currentValue == originalValue) continue;
      updates.add(
        ShoppingChecklistUpdate(
          productId: productId,
          isPurchased: currentValue,
        ),
      );
    }
    return ShoppingChecklistImportResult(wasCancelled: false, updates: updates);
  }

  void _writeListSheet(Sheet sheet, ShoppingChecklist checklist) {
    _put(sheet, 0, 0, TextCellValue(_workbookTitle), style: _titleStyle);
    _put(sheet, 0, 1, TextCellValue('Trip'), style: _headerStyle);
    _put(sheet, 1, 1, TextCellValue(checklist.tripName));
    _put(
      sheet,
      0,
      2,
      TextCellValue(
        'Ubah checklist: kosong untuk belum dibeli, tanda centang untuk sudah dibeli.',
      ),
    );
    const headers = ['Checklist', 'Foto', 'Produk', 'Jumlah'];
    for (var column = 0; column < headers.length; column++) {
      _put(
        sheet,
        column,
        4,
        TextCellValue(headers[column]),
        style: _headerStyle,
      );
    }
    for (var index = 0; index < checklist.items.length; index++) {
      final item = checklist.items[index];
      final row = _firstItemRow + index;
      _put(sheet, 0, row, TextCellValue(item.isPurchased ? '☑' : '☐'));
      _put(sheet, 2, row, TextCellValue(item.name));
      _put(sheet, 3, row, IntCellValue(item.quantity));
      _addThumbnail(sheet, item.thumbnailBytes, row);
      sheet.setRowHeight(row, 52);
    }
    sheet.frozenRows = _firstItemRow;
    sheet.setColumnWidth(0, 15);
    sheet.setColumnWidth(1, 12);
    sheet.setColumnWidth(2, 36);
    sheet.setColumnWidth(3, 12);
  }

  void _writeSyncSheet(Sheet sheet, ShoppingChecklist checklist) {
    _put(sheet, 0, 0, TextCellValue('DATA SINKRONISASI'), style: _titleStyle);
    _put(sheet, 0, 1, TextCellValue('ID Trip'), style: _headerStyle);
    _put(sheet, 1, 1, TextCellValue(checklist.tripId));
    _put(sheet, 0, 4, TextCellValue('ID Produk'), style: _headerStyle);
    _put(sheet, 1, 4, TextCellValue('Status awal'), style: _headerStyle);
    for (var index = 0; index < checklist.items.length; index++) {
      final item = checklist.items[index];
      final row = _firstItemRow + index;
      _put(sheet, 0, row, TextCellValue(item.productId));
      _put(sheet, 1, row, TextCellValue(item.status.name));
    }
    sheet.setColumnWidth(0, 26);
    sheet.setColumnWidth(1, 18);
  }

  void _addThumbnail(Sheet sheet, Uint8List bytes, int row) {
    final imageType = _imageType(bytes);
    if (imageType == null) return;
    sheet.addImage(
      ExcelImage(
        imageBytes: bytes,
        imageType: imageType,
        anchor: ImageAnchor.fromPixels(
          column: 1,
          row: row,
          widthPixels: 48,
          heightPixels: 48,
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

  String _cellText(Sheet sheet, int row, int column) {
    if (row >= sheet.maxRows || column >= sheet.maxColumns) return '';
    return sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
            )
            .value
            ?.toString()
            .trim() ??
        '';
  }

  bool? _checklistValue(String value) {
    final normalized = value.trim().toLowerCase();
    if (const {
      '☑',
      '✓',
      'v',
      'x',
      'ya',
      'yes',
      'true',
      '1',
      'done',
    }.contains(normalized)) {
      return true;
    }
    if (const {'☐', '', 'tidak', 'no', 'false', '0'}.contains(normalized)) {
      return false;
    }
    return null;
  }

  bool _statusValue(String value) =>
      value == ShoppingChecklistStatus.purchased.name;

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

abstract interface class ShoppingChecklistFileSharer {
  Future<void> share(String fileName, Uint8List bytes);
}

class SharePlusShoppingChecklistFileSharer
    implements ShoppingChecklistFileSharer {
  const SharePlusShoppingChecklistFileSharer();

  @override
  Future<void> share(String fileName, Uint8List bytes) =>
      SharePlus.instance.share(
        ShareParams(
          title: 'Daftar belanja',
          text: 'Daftar belanja dari Jastip Katalog.',
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            ),
          ],
          fileNameOverrides: [fileName],
          sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
        ),
      );
}

final _titleStyle = CellStyle(bold: true, fontSize: 14);
final _headerStyle = CellStyle(bold: true);

String _safeFileName(String value) {
  final sanitized = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return sanitized.isEmpty ? 'jastip' : sanitized;
}
