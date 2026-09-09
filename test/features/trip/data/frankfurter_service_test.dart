import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jastip_katalog_generator/features/trip/data/data_sources/frankfurter_service.dart';

void main() {
  test('memetakan kurs pasangan mata uang ke fixed precision', () async {
    final client = MockClient(
      (_) async => http.Response(
        '{"date":"2026-09-05","base":"JPY","quote":"IDR","rate":110.123456}',
        200,
      ),
    );

    final quote = await FrankfurterService(client).getLatestRate('JPY');

    expect(quote.base, 'JPY');
    expect(quote.quote, 'IDR');
    expect(quote.rateMicros, 110123456);
    expect(quote.rateDate, DateTime(2026, 9, 5));
    expect(quote.fromCache, isFalse);
  });

  test('memetakan daftar mata uang dan mengecualikan IDR', () async {
    final client = MockClient(
      (_) async => http.Response(
        '[{"iso_code":"JPY","name":"Japanese Yen","symbol":"¥"},'
        '{"iso_code":"IDR","name":"Indonesian Rupiah","symbol":"Rp"}]',
        200,
      ),
    );

    final currencies = await FrankfurterService(client).getCurrencies();

    expect(currencies, hasLength(1));
    expect(currencies.single.code, 'JPY');
  });
}
