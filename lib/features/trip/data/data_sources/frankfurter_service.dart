import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/trip.dart';

class FrankfurterService {
  FrankfurterService(this._client);

  static const _baseUrl = 'https://api.frankfurter.dev/v2';
  final http.Client _client;

  Future<List<CurrencyOption>> getCurrencies() async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/currencies'))
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw const NetworkException('Daftar mata uang belum dapat dimuat.');
    }
    final json = jsonDecode(response.body);
    if (json is! List) {
      throw const NetworkException('Format daftar mata uang tidak dikenali.');
    }
    final currencies =
        json
            .whereType<Map<String, dynamic>>()
            .map(
              (item) => CurrencyOption(
                code: item['iso_code'] as String? ?? '',
                name: item['name'] as String? ?? '',
                symbol: item['symbol'] as String? ?? '',
              ),
            )
            .where(
              (currency) => currency.code.isNotEmpty && currency.code != 'IDR',
            )
            .toList(growable: false)
          ..sort((a, b) => a.code.compareTo(b.code));
    return currencies;
  }

  Future<ExchangeRateQuote> getLatestRate(String baseCurrency) async {
    final uri = Uri.parse('$_baseUrl/rate/$baseCurrency/IDR');
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw NetworkException(
        'Kurs $baseCurrency ke IDR belum dapat diperbarui.',
      );
    }
    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) {
      throw const NetworkException('Format kurs tidak dikenali.');
    }
    final rate = json['rate'];
    final date = DateTime.tryParse(json['date'] as String? ?? '');
    if (rate is! num || rate <= 0 || date == null) {
      throw const NetworkException('Data kurs dari server tidak lengkap.');
    }
    return ExchangeRateQuote(
      base: baseCurrency,
      quote: 'IDR',
      rateMicros: (rate.toDouble() * 1000000).round(),
      rateDate: date,
      fetchedAt: DateTime.now(),
      fromCache: false,
    );
  }
}
