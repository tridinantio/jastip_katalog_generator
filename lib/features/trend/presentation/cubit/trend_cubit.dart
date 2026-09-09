import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/trend_country.dart';
import '../../domain/entities/trend_item.dart';
import '../../domain/repositories/trend_repository.dart';

enum TrendStatus { initial, loading, ready, failure }

class TrendState extends Equatable {
  const TrendState({
    this.status = TrendStatus.initial,
    this.country = defaultTrendCountry,
    this.items = const [],
    this.message,
  });

  final TrendStatus status;
  final TrendCountry country;
  final List<TrendItem> items;
  final String? message;

  TrendState copyWith({
    TrendStatus? status,
    TrendCountry? country,
    List<TrendItem>? items,
    String? message,
    bool clearMessage = false,
  }) => TrendState(
    status: status ?? this.status,
    country: country ?? this.country,
    items: items ?? this.items,
    message: clearMessage ? null : message ?? this.message,
  );

  @override
  List<Object?> get props => [status, country, items, message];
}

class TrendCubit extends Cubit<TrendState> {
  TrendCubit(this._repository) : super(const TrendState());

  final TrendRepository _repository;
  int _requestId = 0;

  Future<void> initialize({TrendCountry? country}) async {
    if (country != null) emit(state.copyWith(country: country));
    if (state.status == TrendStatus.initial) await refresh();
  }

  Future<void> selectCountry(TrendCountry country) async {
    if (country == state.country && state.status == TrendStatus.loading) return;
    emit(
      state.copyWith(
        country: country,
        status: TrendStatus.initial,
        items: const [],
        clearMessage: true,
      ),
    );
    await refresh();
  }

  Future<void> refresh() async {
    final requestId = ++_requestId;
    emit(state.copyWith(status: TrendStatus.loading, clearMessage: true));
    try {
      final items = await _repository.getTrends(state.country);
      if (requestId != _requestId || isClosed) return;
      emit(state.copyWith(status: TrendStatus.ready, items: items));
    } catch (error) {
      if (requestId != _requestId || isClosed) return;
      final message = error is AppException
          ? error.message
          : 'Data tren belum dapat dimuat. Periksa koneksi internet.';
      emit(state.copyWith(status: TrendStatus.failure, message: message));
    }
  }
}
