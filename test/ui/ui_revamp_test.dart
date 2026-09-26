import 'dart:io';

import 'package:intl/date_symbol_data_local.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/core/theme/app_theme.dart';
import 'package:jastip_katalog_generator/features/home/presentation/pages/home_page.dart';
import 'package:jastip_katalog_generator/features/backup/domain/services/backup_restore_service.dart';
import 'package:jastip_katalog_generator/features/product/domain/entities/product.dart';
import 'package:jastip_katalog_generator/features/product/domain/repositories/product_repository.dart';
import 'package:jastip_katalog_generator/features/product/domain/services/image_services.dart';
import 'package:jastip_katalog_generator/features/product/domain/services/location_services.dart';
import 'package:jastip_katalog_generator/features/shopping/domain/entities/shopping_request.dart';
import 'package:jastip_katalog_generator/features/shopping/domain/repositories/shopping_repository.dart';
import 'package:jastip_katalog_generator/features/trip/domain/entities/trip.dart';
import 'package:jastip_katalog_generator/features/trip/domain/repositories/trip_repository.dart';
import 'package:jastip_katalog_generator/features/trip/domain/services/trip_export_service.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    for (final family in ['Manrope', 'Fraunces']) {
      final loader = FontLoader(family)
        ..addFont(rootBundle.load('assets/fonts/$family.ttf'));
      await loader.load();
    }
  });

  for (final scenario in [
    (name: 'phone', size: const Size(390, 844), scale: 1.0),
    (name: 'compact', size: const Size(320, 740), scale: 1.0),
    (name: 'accessible', size: const Size(390, 844), scale: 1.8),
    (name: 'desktop', size: const Size(1100, 900), scale: 1.0),
  ]) {
    testWidgets(
      'navigation, search, filter and product routes at ${scenario.name}',
      (tester) async {
        tester.view.physicalSize = scenario.size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final fixtures = await tester.runAsync(_Fixtures.create);
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(_app(fixtures!, boundaryKey, scenario.scale));
        await tester.pumpAndSettle();
        expect(find.text('Pergi. Temukan. Titip.'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await _snapshot(tester, boundaryKey, '${scenario.name}-trip');

        Future<void> tab(String label) async {
          final navigation = find.byType(
            scenario.size.width >= 840 ? NavigationRail : NavigationBar,
          );
          await tester.tap(
            find.descendant(of: navigation, matching: find.text(label)),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        await tab('Pembeli');
        await _snapshot(tester, boundaryKey, '${scenario.name}-buyers');
        await tester.tap(find.text('Nadia Putri'));
        await tester.pumpAndSettle();
        expect(find.text('Terbeli'), findsWidgets);
        expect(tester.takeException(), isNull);
        await tab('Produk');
        await _snapshot(tester, boundaryKey, '${scenario.name}-products');
        await tester.enterText(find.byType(TextField).first, 'Matcha');
        await tester.runAsync(() async {});
        await tester.pumpAndSettle();
        expect(find.text('Matcha ritual set'), findsOneWidget);
        expect(find.text('Everyday canvas tote'), findsNothing);
        await tester.enterText(find.byType(TextField).first, '');
        await tester.runAsync(() async {});
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Filter produk'));
        await tester.pumpAndSettle();
        expect(find.text('Filter produk'), findsWidgets);
        expect(tester.takeException(), isNull);
        await _snapshot(tester, boundaryKey, '${scenario.name}-filter');
        await tester.tap(find.byTooltip('Tutup'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Matcha ritual set').hitTestable(),
          180,
          scrollable: find
              .descendant(
                of: find.byKey(const PageStorageKey('products-category-list')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.tap(find.text('Matcha ritual set'));
        await tester.pumpAndSettle();
        expect(find.text('Detail Produk'), findsOneWidget);
        expect(find.text('Sudah termasuk jasa titip'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await _snapshot(tester, boundaryKey, '${scenario.name}-catalog');
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tab('Pengaturan');
        await _snapshot(tester, boundaryKey, '${scenario.name}-settings');
        await tab('Trip');
        await tester.scrollUntilVisible(
          find.text('Tambah produk').hitTestable(),
          180,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Tambah produk'));
        await tester.pumpAndSettle();
        expect(find.text('Kamera'), findsOneWidget);
        expect(find.text('Galeri'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await _snapshot(tester, boundaryKey, '${scenario.name}-form');
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );
  }

  testWidgets('empty collections remain usable on a compact phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fixtures = await tester.runAsync(_Fixtures.create);
    final key = GlobalKey();
    await tester.pumpWidget(_app(_Fixtures(fixtures!.trip, [], []), key, 1));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Belum ada produk').hitTestable(),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
    await _snapshot(tester, key, 'empty-trip');
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Pembeli'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Belum ada data pembeli'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _snapshot(tester, key, 'empty-buyers');
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Produk'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Produk tidak ditemukan.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _snapshot(tester, key, 'empty-products');
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}

Widget _app(_Fixtures fixtures, GlobalKey key, double scale) =>
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TripRepository>.value(value: _Trips(fixtures.trip)),
        RepositoryProvider<ExchangeRateRepository>.value(value: _Rates()),
        RepositoryProvider<ProductRepository>.value(
          value: _Products(fixtures.products),
        ),
        RepositoryProvider<ShoppingRepository>.value(
          value: _Shopping(fixtures.requests),
        ),
        RepositoryProvider<ProductImagePicker>.value(value: _Picker()),
        RepositoryProvider<ProductLocationService>.value(value: _Location()),
        RepositoryProvider<CatalogExportService>.value(value: _CatalogExport()),
        RepositoryProvider<TripExportService>.value(value: _TripExport()),
        RepositoryProvider<BackupRestoreService>.value(value: _Backup()),
      ],
      child: RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const HomePage(),
        ),
      ),
    );

Future<void> _snapshot(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      await precacheImage((element.widget as Image).image, element);
    }
  });
  await tester.pumpAndSettle();
  if (!const bool.fromEnvironment('UPDATE_UI_PREVIEWS')) return;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.5);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = File('build/ui-preview/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
  });
}

class _Fixtures {
  _Fixtures(this.trip, this.products, this.requests);
  final Trip trip;
  final List<Product> products;
  final List<ShoppingRequest> requests;
  static Future<_Fixtures> create() async {
    final now = DateTime.now();
    final trip = Trip(
      id: 'trip',
      name: 'Japan, autumn finds',
      country: 'Japan',
      currencyCode: 'JPY',
      currencyName: 'Japanese Yen',
      currencySymbol: '¥',
      rateMicros: 105000000,
      rateDate: DateTime(2026, 9, 9),
      rateFetchedAt: now,
      markupBasisPoints: 1500,
      fixedFeeIdr: 0,
      roundingUnitIdr: 1000,
    );
    final products = <Product>[];
    final names = [
      'Everyday canvas tote',
      'Matcha ritual set',
      'Hinoki hand cream',
      'Tokyo travel journal',
    ];
    final categories = ['LIFESTYLE', 'HOME & LIVING', 'BEAUTY', 'STATIONERY'];
    for (var i = 0; i < names.length; i++) {
      final image = await _sampleImage(i);
      products.add(
        Product(
          id: 'p$i',
          tripId: 'trip',
          name: names[i],
          originalPriceMinor: (1200 + i * 500) * 100,
          sellingPriceIdr: 145000 + i * 60000,
          note: '',
          category: categories[i],
          imageBytes: image,
          thumbnailBytes: image,
          imageMimeType: 'image/png',
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    return _Fixtures(
      trip,
      products,
      List.generate(
        4,
        (i) => ShoppingRequest(
          id: 'r$i',
          tripId: 'trip',
          productId: 'p$i',
          buyerName: i < 2 ? 'Nadia Putri' : 'Alya Rahma',
          quantity: 2,
          note: 'Warna natural',
          isPurchased: i.isEven,
          purchasedAt: i.isEven ? now : null,
          createdAt: now,
          updatedAt: now,
        ),
      ),
    );
  }
}

// Locally drawn fixture images: no network or customer data in UI tests.
Future<Uint8List> _sampleImage(int index) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final backgrounds = [
    const Color(0xFFE8DDCC),
    const Color(0xFFD8DECD),
    const Color(0xFFEACDC0),
    const Color(0xFFD6DEDF),
  ];
  canvas.drawColor(backgrounds[index], BlendMode.src);
  final shadow = Paint()
    ..color = const Color(0x22000000)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
  canvas.drawOval(const Rect.fromLTWH(85, 290, 230, 40), shadow);
  final body = Paint()
    ..color = index == 1 ? const Color(0xFF5B7148) : const Color(0xFFF6F0E0);
  if (index == 0) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(95, 140, 210, 180),
        const Radius.circular(16),
      ),
      body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(150, 85, 100, 120),
        const Radius.circular(45),
      ),
      Paint()
        ..color = const Color(0xFFB9A887)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14,
    );
    canvas.drawRect(
      const Rect.fromLTWH(170, 225, 60, 42),
      Paint()..color = AppTheme.forest,
    );
  } else if (index == 1) {
    canvas.drawOval(const Rect.fromLTWH(85, 185, 230, 135), body);
    canvas.drawOval(
      const Rect.fromLTWH(85, 170, 230, 65),
      Paint()..color = const Color(0xFFB7C68D),
    );
    canvas.drawOval(
      const Rect.fromLTWH(105, 183, 190, 42),
      Paint()..color = const Color(0xFF57712D),
    );
  } else {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(index == 2 ? 140 : 100, 100, index == 2 ? 120 : 200, 220),
        const Radius.circular(10),
      ),
      body,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        index == 2 ? 140 : 100,
        100,
        index == 2 ? 120 : 18,
        index == 2 ? 40 : 220,
      ),
      Paint()..color = AppTheme.forest,
    );
    canvas.drawRect(
      const Rect.fromLTWH(166, 194, 70, 3),
      Paint()..color = AppTheme.rust,
    );
    canvas.drawRect(
      const Rect.fromLTWH(176, 208, 50, 2),
      Paint()..color = AppTheme.rust,
    );
  }
  final picture = recorder.endRecording();
  final image = await picture.toImage(400, 400);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return bytes!.buffer.asUint8List();
}

class _Trips extends Fake implements TripRepository {
  _Trips(this.trip);
  final Trip trip;
  @override
  Future<Trip> ensureDefaultTrip() async => trip;
  @override
  Stream<Trip> watchActiveTrip() => Stream.value(trip);
  @override
  Stream<List<Trip>> watchTrips() => Stream.value([trip]);
  @override
  Future<Trip> getActiveTrip() async => trip;
  @override
  Future<List<Trip>> getTrips() async => [trip];
}

class _Rates extends Fake implements ExchangeRateRepository {
  @override
  Future<List<CurrencyOption>> getCurrencies() async => const [
    CurrencyOption(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
  ];
}

class _Products extends Fake implements ProductRepository {
  _Products(this.products);
  final List<Product> products;
  @override
  Stream<List<ProductSummary>> watchProducts(
    String tripId, {
    String query = '',
  }) => Stream.value(
    products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .map(
          (p) => ProductSummary(
            id: p.id,
            tripId: p.tripId,
            name: p.name,
            originalPriceMinor: p.originalPriceMinor,
            sellingPriceIdr: p.sellingPriceIdr,
            thumbnailBytes: p.thumbnailBytes,
            createdAt: p.createdAt,
            category: p.category,
          ),
        )
        .toList(),
  );
  @override
  Future<Product> getProduct(String id) async =>
      products.firstWhere((p) => p.id == id);
  @override
  Future<List<String>> getLocationLabels(String tripId) async => [];
}

class _Shopping extends Fake implements ShoppingRepository {
  _Shopping(this.requests);
  final List<ShoppingRequest> requests;
  @override
  Stream<List<ShoppingRequest>> watchRequestsForTrip(String tripId) =>
      Stream.value(requests);
  @override
  Stream<List<ShoppingRequest>> watchRequests(String productId) =>
      Stream.value(requests.where((r) => r.productId == productId).toList());
  @override
  Stream<Map<String, ShoppingProgress>> watchProgress(String tripId) =>
      Stream.value({
        for (final r in requests)
          r.productId: ShoppingProgress(
            productId: r.productId,
            totalRequests: 1,
            purchasedRequests: r.isPurchased ? 1 : 0,
          ),
      });
  @override
  Future<List<String>> getBuyerNames(String tripId) async => [
    'Nadia Putri',
    'Alya Rahma',
  ];
}

class _Picker extends Fake implements ProductImagePicker {}

class _Location extends Fake implements ProductLocationService {}

class _CatalogExport extends Fake implements CatalogExportService {}

class _TripExport extends Fake implements TripExportService {}

class _Backup extends Fake implements BackupRestoreService {}
