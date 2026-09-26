import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel_community/excel_community.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/features/product/domain/entities/product.dart';
import 'package:jastip_katalog_generator/features/shopping/data/services/shopping_checklist_workbook_service_impl.dart';
import 'package:jastip_katalog_generator/features/shopping/domain/entities/shopping_checklist.dart';
import 'package:jastip_katalog_generator/features/shopping/domain/entities/shopping_request.dart';
import 'package:jastip_katalog_generator/features/shopping/domain/use_cases/build_shopping_checklist.dart';

void main() {
  test(
    'menggabungkan permintaan per produk dan mempertahankan status parsial',
    () {
      final checklist = BuildShoppingChecklist.call(
        tripId: 'trip-1',
        tripName: 'Japan',
        products: [
          _product('product-1', 'Matcha'),
          _product('product-2', 'Socks'),
        ],
        requests: [
          _request('request-1', 'product-1', 2),
          _request('request-2', 'product-1', 1, isPurchased: true),
          _request('request-3', 'product-2', 3, isPurchased: true),
        ],
      );

      expect(checklist.items, hasLength(2));
      expect(checklist.items[0].quantity, 3);
      expect(checklist.items[0].status, ShoppingChecklistStatus.partial);
      expect(checklist.items[1].status, ShoppingChecklistStatus.purchased);
    },
  );

  test('membaca kembali hanya checklist yang diubah', () async {
    final sharer = _FakeSharer();
    final service = ShoppingChecklistWorkbookServiceImpl(sharer);
    final checklist = ShoppingChecklist(
      tripId: 'trip-1',
      tripName: 'Japan',
      items: [
        ShoppingChecklistItem(
          productId: 'product-1',
          name: 'Matcha',
          category: '',
          quantity: 2,
          thumbnailBytes: Uint8List(0),
          status: ShoppingChecklistStatus.pending,
        ),
        ShoppingChecklistItem(
          productId: 'product-2',
          name: 'Socks',
          category: '',
          quantity: 1,
          thumbnailBytes: Uint8List(0),
          status: ShoppingChecklistStatus.purchased,
        ),
      ],
    );

    await service.export(checklist);
    final workbook = Excel.decodeBytes(sharer.bytes!);
    workbook['Daftar Belanja']
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5))
        .value = TextCellValue(
      'Terbeli',
    );
    workbook['Daftar Belanja']
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 6))
        .value = TextCellValue(
      'Belum dibeli',
    );
    final bytes = workbook.encode();

    final result = service.parseImport(Uint8List.fromList(bytes!), 'trip-1');

    expect(result.updates.map((item) => (item.productId, item.isPurchased)), [
      ('product-1', true),
      ('product-2', false),
    ]);
  });

  test('menambahkan dropdown status ke kolom checklist', () async {
    final sharer = _FakeSharer();
    final service = ShoppingChecklistWorkbookServiceImpl(sharer);
    final checklist = ShoppingChecklist(
      tripId: 'trip-1',
      tripName: 'Japan',
      items: [
        ShoppingChecklistItem(
          productId: 'product-1',
          name: 'Matcha',
          category: '',
          quantity: 1,
          thumbnailBytes: Uint8List(0),
          status: ShoppingChecklistStatus.pending,
        ),
      ],
    );

    await service.export(checklist);

    final archive = ZipDecoder().decodeBytes(sharer.bytes!);
    final worksheet = archive.files
        .singleWhere((file) => file.name == 'xl/worksheets/sheet1.xml')
        .readBytes()!;
    final xml = String.fromCharCodes(worksheet);
    expect(xml, contains('<dataValidations count="1">'));
    expect(xml, contains('sqref="A6:A6"'));
    expect(xml, contains('"Belum dibeli,Terbeli"'));
  });

  test('menolak file dari trip lain', () async {
    final sharer = _FakeSharer();
    final service = ShoppingChecklistWorkbookServiceImpl(sharer);
    const checklist = ShoppingChecklist(
      tripId: 'trip-1',
      tripName: 'Japan',
      items: [],
    );

    await service.export(checklist);

    expect(
      () => service.parseImport(sharer.bytes!, 'trip-2'),
      throwsFormatException,
    );
  });
}

ProductSummary _product(String id, String name) => ProductSummary(
  id: id,
  tripId: 'trip-1',
  name: name,
  originalPriceMinor: 100,
  sellingPriceIdr: 1000,
  thumbnailBytes: Uint8List(0),
  createdAt: DateTime(2026),
);

ShoppingRequest _request(
  String id,
  String productId,
  int quantity, {
  bool isPurchased = false,
}) => ShoppingRequest(
  id: id,
  tripId: 'trip-1',
  productId: productId,
  buyerName: '',
  quantity: quantity,
  note: '',
  isPurchased: isPurchased,
  purchasedAt: null,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

class _FakeSharer implements ShoppingChecklistFileSharer {
  Uint8List? bytes;

  @override
  Future<void> share(String fileName, Uint8List value) async {
    bytes = value;
  }
}
