import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/backup.dart';
import '../../domain/services/backup_restore_service.dart';

enum BackupRestoreStatus {
  idle,
  creating,
  picking,
  readyToRestore,
  restoring,
  success,
  failure,
}

enum BackupRestoreAction { backup, restore }

class BackupRestoreState extends Equatable {
  const BackupRestoreState({
    this.status = BackupRestoreStatus.idle,
    this.action,
    this.fileName,
    this.summary,
    this.candidate,
    this.errorMessage,
  });

  final BackupRestoreStatus status;
  final BackupRestoreAction? action;
  final String? fileName;
  final BackupSummary? summary;
  final BackupCandidate? candidate;
  final String? errorMessage;

  bool get isBusy =>
      status == BackupRestoreStatus.creating ||
      status == BackupRestoreStatus.picking ||
      status == BackupRestoreStatus.restoring;

  @override
  List<Object?> get props => [
    status,
    action,
    fileName,
    summary,
    candidate,
    errorMessage,
  ];
}

class BackupRestoreCubit extends Cubit<BackupRestoreState> {
  BackupRestoreCubit(this._service) : super(const BackupRestoreState());

  final BackupRestoreService _service;

  Future<void> createBackup() async {
    if (state.isBusy) return;
    emit(
      const BackupRestoreState(
        status: BackupRestoreStatus.creating,
        action: BackupRestoreAction.backup,
      ),
    );
    try {
      final result = await _service.createAndShare();
      emit(
        BackupRestoreState(
          status: BackupRestoreStatus.success,
          action: BackupRestoreAction.backup,
          fileName: result.fileName,
          summary: result.summary,
        ),
      );
    } catch (error) {
      emit(
        BackupRestoreState(
          status: BackupRestoreStatus.failure,
          action: BackupRestoreAction.backup,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<BackupCandidate?> pickBackup() async {
    if (state.isBusy) return null;
    emit(
      const BackupRestoreState(
        status: BackupRestoreStatus.picking,
        action: BackupRestoreAction.restore,
      ),
    );
    try {
      final candidate = await _service.pickBackup();
      if (candidate == null) {
        emit(const BackupRestoreState());
        return null;
      }
      emit(
        BackupRestoreState(
          status: BackupRestoreStatus.readyToRestore,
          action: BackupRestoreAction.restore,
          fileName: candidate.fileName,
          summary: candidate.summary,
          candidate: candidate,
        ),
      );
      return candidate;
    } catch (error) {
      emit(
        BackupRestoreState(
          status: BackupRestoreStatus.failure,
          action: BackupRestoreAction.restore,
          errorMessage: error.toString(),
        ),
      );
      return null;
    }
  }

  Future<bool> restore(BackupCandidate candidate) async {
    if (state.isBusy) return false;
    emit(
      BackupRestoreState(
        status: BackupRestoreStatus.restoring,
        action: BackupRestoreAction.restore,
        fileName: candidate.fileName,
        summary: candidate.summary,
        candidate: candidate,
      ),
    );
    try {
      await _service.restore(candidate);
      emit(
        BackupRestoreState(
          status: BackupRestoreStatus.success,
          action: BackupRestoreAction.restore,
          fileName: candidate.fileName,
          summary: candidate.summary,
        ),
      );
      return true;
    } catch (error) {
      emit(
        BackupRestoreState(
          status: BackupRestoreStatus.failure,
          action: BackupRestoreAction.restore,
          fileName: candidate.fileName,
          summary: candidate.summary,
          errorMessage: error.toString(),
        ),
      );
      return false;
    }
  }

  void reset() => emit(const BackupRestoreState());
}
