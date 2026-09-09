import '../../domain/entities/trend_country.dart';
import '../../domain/entities/trend_item.dart';
import '../../domain/repositories/trend_repository.dart';
import '../data_sources/google_trends_rss_service.dart';

class TrendRepositoryImpl implements TrendRepository {
  const TrendRepositoryImpl(this._remote);

  final GoogleTrendsRssService _remote;

  @override
  Future<List<TrendItem>> getTrends(TrendCountry country) =>
      _remote.fetch(country);
}
