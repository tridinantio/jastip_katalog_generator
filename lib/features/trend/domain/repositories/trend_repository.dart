import '../entities/trend_country.dart';
import '../entities/trend_item.dart';

abstract interface class TrendRepository {
  Future<List<TrendItem>> getTrends(TrendCountry country);
}
