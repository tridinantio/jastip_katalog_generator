import 'package:equatable/equatable.dart';

class Trip extends Equatable {
  const Trip({
    required this.id,
    required this.name,
    required this.country,
    required this.currencyCode,
    required this.currencyName,
    required this.currencySymbol,
    required this.rateMicros,
    required this.rateDate,
    required this.rateFetchedAt,
    required this.markupBasisPoints,
    required this.fixedFeeIdr,
    required this.roundingUnitIdr,
  });

  final String id;
  final String name;
  final String country;
  final String currencyCode;
  final String currencyName;
  final String currencySymbol;
  final int rateMicros;
  final DateTime? rateDate;
  final DateTime? rateFetchedAt;
  final int markupBasisPoints;
  final int fixedFeeIdr;
  final int roundingUnitIdr;

  double get markupPercent => markupBasisPoints / 100;
  bool get hasRate => rateMicros > 0;

  Trip copyWith({
    String? name,
    String? country,
    String? currencyCode,
    String? currencyName,
    String? currencySymbol,
    int? rateMicros,
    DateTime? rateDate,
    DateTime? rateFetchedAt,
    int? markupBasisPoints,
    int? fixedFeeIdr,
    int? roundingUnitIdr,
  }) {
    return Trip(
      id: id,
      name: name ?? this.name,
      country: country ?? this.country,
      currencyCode: currencyCode ?? this.currencyCode,
      currencyName: currencyName ?? this.currencyName,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      rateMicros: rateMicros ?? this.rateMicros,
      rateDate: rateDate ?? this.rateDate,
      rateFetchedAt: rateFetchedAt ?? this.rateFetchedAt,
      markupBasisPoints: markupBasisPoints ?? this.markupBasisPoints,
      fixedFeeIdr: fixedFeeIdr ?? this.fixedFeeIdr,
      roundingUnitIdr: roundingUnitIdr ?? this.roundingUnitIdr,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    country,
    currencyCode,
    currencyName,
    currencySymbol,
    rateMicros,
    rateDate,
    rateFetchedAt,
    markupBasisPoints,
    fixedFeeIdr,
    roundingUnitIdr,
  ];
}

class NewTrip {
  const NewTrip({
    required this.name,
    required this.currencyCode,
    required this.currencyName,
    required this.currencySymbol,
    required this.rateMicros,
    required this.rateDate,
    required this.rateFetchedAt,
    this.country = '',
    this.markupBasisPoints = 1500,
    this.fixedFeeIdr = 0,
    this.roundingUnitIdr = 1000,
  });

  final String name;
  final String country;
  final String currencyCode;
  final String currencyName;
  final String currencySymbol;
  final int rateMicros;
  final DateTime rateDate;
  final DateTime rateFetchedAt;
  final int markupBasisPoints;
  final int fixedFeeIdr;
  final int roundingUnitIdr;
}

class CurrencyOption extends Equatable {
  const CurrencyOption({
    required this.code,
    required this.name,
    required this.symbol,
  });

  final String code;
  final String name;
  final String symbol;

  @override
  List<Object?> get props => [code, name, symbol];
}

class ExchangeRateQuote extends Equatable {
  const ExchangeRateQuote({
    required this.base,
    required this.quote,
    required this.rateMicros,
    required this.rateDate,
    required this.fetchedAt,
    required this.fromCache,
  });

  final String base;
  final String quote;
  final int rateMicros;
  final DateTime rateDate;
  final DateTime fetchedAt;
  final bool fromCache;

  @override
  List<Object?> get props => [
    base,
    quote,
    rateMicros,
    rateDate,
    fetchedAt,
    fromCache,
  ];
}
