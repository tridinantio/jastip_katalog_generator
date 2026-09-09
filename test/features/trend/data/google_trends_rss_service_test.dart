import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jastip_katalog_generator/features/trend/data/data_sources/google_trends_rss_service.dart';
import 'package:jastip_katalog_generator/features/trend/domain/entities/trend_country.dart';

void main() {
  test(
    'membatasi tren menjadi 10 item dan menyiapkan minimal tiga sumber',
    () async {
      final client = MockClient(
        (_) async => http.Response('''<?xml version="1.0"?>
        <rss><channel>
          <item>
            <title>Produk &amp; Baru</title>
            <ht:approx_traffic>10K+</ht:approx_traffic>
            <pubDate>Sat, 5 Sep 2026 08:30:00 -0700</pubDate>
            <ht:news_item>
              <ht:news_item_url>https://example.com/news</ht:news_item_url>
              <ht:news_item_source>Contoh</ht:news_item_source>
            </ht:news_item>
          </item>
          <item><title>Tren kedua</title></item>
        </channel></rss>''', 200),
      );

      final items = await GoogleTrendsRssService(client)
          .fetch(defaultTrendCountry);

      expect(items, hasLength(2));
      expect(items.first.title, 'Produk & Baru');
      expect(items.first.startedAt, isNotNull);
      expect(items.first.sources.length, greaterThanOrEqualTo(3));
      expect(items.first.sources.first.url, contains('trends.google.com'));
      expect(items.first.sources[2].url, contains('tokopedia.com'));
    },
  );
}
