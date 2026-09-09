import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/trip.dart';
import '../../domain/services/trip_export_service.dart';

enum TripExportStatus { idle, exporting, success, failure }

class TripExportState extends Equatable {
  const TripExportState({
    this.status = TripExportStatus.idle,
    this.fileName,
    this.errorMessage,
  });

  final TripExportStatus status;
  final String? fileName;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, fileName, errorMessage];
}

class TripExportCubit extends Cubit<TripExportState> {
  TripExportCubit(this._service) : super(const TripExportState());

  final TripExportService _service;

  Future<void> export(Trip trip) async {
    if (state.status == TripExportStatus.exporting) return;
    emit(const TripExportState(status: TripExportStatus.exporting));
    try {
      final result = await _service.export(trip);
      emit(
        TripExportState(
          status: TripExportStatus.success,
          fileName: result.fileName,
        ),
      );
    } catch (_) {
      emit(
        const TripExportState(
          status: TripExportStatus.failure,
          errorMessage: 'Export gagal. Silakan coba lagi.',
        ),
      );
    }
  }
}
