import 'package:intl/intl.dart';

final NumberFormat _idrFormat = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp',
  decimalDigits: 0,
);

String formatIdr(int value) => _idrFormat.format(value);

String formatForeignMinor(int minor, String symbol, String currencyCode) {
  final decimalDigits = _zeroDecimalCurrencies.contains(currencyCode) ? 0 : 2;
  final value = minor / 100;
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: symbol,
    decimalDigits: decimalDigits,
  ).format(value);
}

String formatRate(int rateMicros) {
  final rate = rateMicros / 1000000;
  return NumberFormat.decimalPatternDigits(
    locale: 'id_ID',
    decimalDigits: rate == rate.roundToDouble() ? 0 : 4,
  ).format(rate);
}

String formatWeight(int grams) {
  if (grams < 1000) return '$grams g';
  final kilograms = grams / 1000;
  return '${NumberFormat.decimalPattern('id_ID').format(kilograms)} kg';
}

String formatShortDate(DateTime date) =>
    DateFormat('d MMM yyyy', 'id_ID').format(date.toLocal());

const _zeroDecimalCurrencies = <String>{
  'BIF',
  'CLP',
  'DJF',
  'GNF',
  'ISK',
  'JPY',
  'KMF',
  'KRW',
  'PYG',
  'RWF',
  'UGX',
  'VND',
  'VUV',
  'XAF',
  'XOF',
  'XPF',
};
