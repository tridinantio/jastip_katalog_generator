import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/trend_country.dart';
import '../../domain/entities/trend_item.dart';

class GoogleTrendsRssService {
  GoogleTrendsRssService(this._client);

  final http.Client _client;

  Future<List<TrendItem>> fetch(TrendCountry country) async {
    final uri = Uri.https('trends.google.com', '/trending/rss', {
      'geo': country.googleGeo,
    });
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw const NetworkException('Data tren belum dapat dimuat.');
    }

    final itemMatches = RegExp(
      r'<item>([\s\S]*?)</item>',
      caseSensitive: false,
    ).allMatches(response.body);
    final results = <TrendItem>[];
    for (final match in itemMatches) {
      final block = match.group(1) ?? '';
      final title = _field(block, 'title');
      if (title.isEmpty) continue;
      results.add(_toTrendItem(block, title, country));
      if (results.length == 10) break;
    }
    if (results.isEmpty) {
      throw const NetworkException('Sumber tren tidak mengembalikan data.');
    }
    return results;
  }

  TrendItem _toTrendItem(String block, String title, TrendCountry country) {
    final sources = <TrendSource>[
      TrendSource(
        label: 'Google Trends',
        url: Uri.https('trends.google.com', '/trends/explore', {
          'geo': country.googleGeo,
          'q': title,
        }).toString(),
      ),
      TrendSource(
        label: 'TikTok Creative Center',
        url: Uri.https('ads.tiktok.com', '/creative/creativeCenter/trends', {
          'countryCode': country.code,
        }).toString(),
      ),
      TrendSource(
        label: country.marketplaceName,
        url: '${country.marketplaceBaseUrl}${Uri.encodeQueryComponent(title)}',
      ),
    ];

    final newsBlocks = RegExp(
      r'<ht:news_item>([\s\S]*?)</ht:news_item>',
      caseSensitive: false,
    ).allMatches(block);
    for (final news in newsBlocks) {
      final newsBlock = news.group(1) ?? '';
      final url = _field(newsBlock, 'ht:news_item_url');
      if (url.isEmpty || sources.any((source) => source.url == url)) continue;
      sources.add(
        TrendSource(
          label: _field(
            newsBlock,
            'ht:news_item_source',
          ).ifEmpty('Berita terkait'),
          url: url,
        ),
      );
      if (sources.length == 6) break;
    }

    return TrendItem(
      title: title,
      approxTraffic: _field(block, 'ht:approx_traffic').ifEmpty('—'),
      startedAt: _parseRssDate(_field(block, 'pubDate')),
      imageUrl: _field(block, 'ht:picture').ifEmpty(null),
      sources: List.unmodifiable(sources),
    );
  }

  String _field(String block, String tag) {
    final match = RegExp(
      '<${RegExp.escape(tag)}>([\\s\\S]*?)</${RegExp.escape(tag)}>',
      caseSensitive: false,
    ).firstMatch(block);
    return _decodeXml(match?.group(1)?.trim() ?? '');
  }

  DateTime? _parseRssDate(String value) {
    if (value.isEmpty) return null;
    final withoutWeekday = value.replaceFirst(RegExp(r'^[^,]+,\s*'), '');
    try {
      return DateFormat(
        'd MMM yyyy HH:mm:ss Z',
        'en_US',
      ).parse(withoutWeekday, true);
    } on FormatException {
      return DateTime.tryParse(withoutWeekday);
    }
  }

  String _decodeXml(String value) => value
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAllMapped(RegExp(r'&#(x?[0-9a-f]+);', caseSensitive: false), (
        match,
      ) {
        final raw = match.group(1)!;
        final isHex = raw.toLowerCase().startsWith('x');
        final digits = isHex ? raw.substring(1) : raw;
        final codePoint = int.tryParse(digits, radix: isHex ? 16 : 10);
        return codePoint == null
            ? match.group(0)!
            : String.fromCharCode(codePoint);
      });
}

extension on String {
  String ifEmpty(String? fallback) => isEmpty ? (fallback ?? '') : this;
}
