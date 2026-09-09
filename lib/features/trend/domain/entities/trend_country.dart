import 'package:equatable/equatable.dart';

class TrendCountry extends Equatable {
  const TrendCountry({
    required this.code,
    required this.name,
    required this.googleGeo,
    required this.marketplaceName,
    required this.marketplaceBaseUrl,
  });

  final String code;
  final String name;
  final String googleGeo;
  final String marketplaceName;
  final String marketplaceBaseUrl;

  @override
  List<Object> get props => [
    code,
    name,
    googleGeo,
    marketplaceName,
    marketplaceBaseUrl,
  ];
}

const defaultTrendCountry = TrendCountry(
  code: 'ID',
  name: 'Indonesia',
  googleGeo: 'ID',
  marketplaceName: 'Tokopedia',
  marketplaceBaseUrl: 'https://www.tokopedia.com/search?st=product&q=',
);

const trendCountries = <TrendCountry>[
  defaultTrendCountry,
  TrendCountry(
    code: 'JP',
    name: 'Jepang',
    googleGeo: 'JP',
    marketplaceName: 'Amazon Jepang',
    marketplaceBaseUrl: 'https://www.amazon.co.jp/s?k=',
  ),
  TrendCountry(
    code: 'KR',
    name: 'Korea Selatan',
    googleGeo: 'KR',
    marketplaceName: 'Coupang',
    marketplaceBaseUrl: 'https://www.coupang.com/np/search?q=',
  ),
  TrendCountry(
    code: 'SG',
    name: 'Singapura',
    googleGeo: 'SG',
    marketplaceName: 'Amazon Singapura',
    marketplaceBaseUrl: 'https://www.amazon.sg/s?k=',
  ),
  TrendCountry(
    code: 'MY',
    name: 'Malaysia',
    googleGeo: 'MY',
    marketplaceName: 'Shopee Malaysia',
    marketplaceBaseUrl: 'https://shopee.com.my/search?keyword=',
  ),
  TrendCountry(
    code: 'TH',
    name: 'Thailand',
    googleGeo: 'TH',
    marketplaceName: 'Shopee Thailand',
    marketplaceBaseUrl: 'https://shopee.co.th/search?keyword=',
  ),
  TrendCountry(
    code: 'US',
    name: 'Amerika Serikat',
    googleGeo: 'US',
    marketplaceName: 'Amazon US',
    marketplaceBaseUrl: 'https://www.amazon.com/s?k=',
  ),
  TrendCountry(
    code: 'GB',
    name: 'Inggris',
    googleGeo: 'GB',
    marketplaceName: 'Amazon UK',
    marketplaceBaseUrl: 'https://www.amazon.co.uk/s?k=',
  ),
  TrendCountry(
    code: 'AU',
    name: 'Australia',
    googleGeo: 'AU',
    marketplaceName: 'Amazon Australia',
    marketplaceBaseUrl: 'https://www.amazon.com.au/s?k=',
  ),
];
