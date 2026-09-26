import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/features/home/presentation/widgets/product_tile.dart';
import 'package:jastip_katalog_generator/features/product/domain/entities/product.dart';
import 'package:jastip_katalog_generator/features/trip/domain/entities/trip.dart';

void main() {
  testWidgets('foto galeri mengisi seluruh lebar kartu', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 360,
            child: ProductTile(
              gallery: true,
              product: _product,
              trip: _trip,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    final imageWidth = tester.getSize(find.byType(Image)).width;
    final tileWidth = tester.getSize(find.byType(InkWell)).width;
    expect(imageWidth, tileWidth);
  });
}

final _product = ProductSummary(
  id: 'product-1',
  tripId: 'trip-1',
  name: 'Produk Jepang',
  originalPriceMinor: 120000,
  sellingPriceIdr: 150000,
  thumbnailBytes: Uint8List.fromList(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    ),
  ),
  createdAt: DateTime(2026),
);

final _trip = Trip(
  id: 'trip-1',
  name: 'Japan Trip',
  country: 'Japan',
  currencyCode: 'JPY',
  currencyName: 'Japanese Yen',
  currencySymbol: '¥',
  rateMicros: 105000000,
  rateDate: DateTime(2026),
  rateFetchedAt: DateTime(2026),
  markupBasisPoints: 1500,
  fixedFeeIdr: 0,
  roundingUnitIdr: 1000,
);
