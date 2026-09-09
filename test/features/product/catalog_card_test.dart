import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/core/theme/app_theme.dart';
import 'package:jastip_katalog_generator/features/product/domain/entities/product.dart';
import 'package:jastip_katalog_generator/features/product/presentation/pages/catalog_preview_page.dart';
import 'package:jastip_katalog_generator/features/trip/domain/entities/trip.dart';

void main() {
  testWidgets('katalog hanya menampilkan harga jual rupiah', (tester) async {
    final now = DateTime(2026);
    final imageBytes = Uint8List.fromList(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      ),
    );
    final product = Product(
      id: 'product-1',
      tripId: 'trip-1',
      name: 'Produk Jepang',
      originalPriceMinor: 120000,
      sellingPriceIdr: 150000,
      note: '',
      category: '',
      imageBytes: imageBytes,
      thumbnailBytes: imageBytes,
      imageMimeType: 'image/png',
      createdAt: now,
      updatedAt: now,
    );
    final trip = Trip(
      id: 'trip-1',
      name: 'Japan Trip',
      country: 'Japan',
      currencyCode: 'JPY',
      currencyName: 'Japanese Yen',
      currencySymbol: '¥',
      rateMicros: 105000000,
      rateDate: now,
      rateFetchedAt: now,
      markupBasisPoints: 1500,
      fixedFeeIdr: 0,
      roundingUnitIdr: 1000,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              height: 640,
              child: CatalogCard(
                product: product,
                trip: trip,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Rp150.000'), findsOneWidget);
    expect(find.textContaining('JPY'), findsNothing);
    expect(find.textContaining('¥'), findsNothing);
    expect(find.text('Sudah termasuk jasa titip'), findsOneWidget);
  });

  testWidgets(
    'tombol tonal bisa dipakai di Positioned tanpa lebar tak hingga',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FilledButton.tonalIcon(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh),
                    label: const Text('Ganti foto'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Ganti foto'), findsOneWidget);
    },
  );
}
