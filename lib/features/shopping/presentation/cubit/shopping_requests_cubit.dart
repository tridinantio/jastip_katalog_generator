import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/shopping_request.dart';
import '../../domain/repositories/shopping_repository.dart';

enum ShoppingRequestsStatus { loading, ready, failure }

class ShoppingRequestsState extends Equatable {
  const ShoppingRequestsState({
    this.status = ShoppingRequestsStatus.loading,
    this.requests = const [],
    this.message,
    this.mutatingRequestId,
  });

  final ShoppingRequestsStatus status;
  final List<ShoppingRequest> requests;
  final String? message;
  final String? mutatingRequestId;

  int get purchasedCount => requests.where((item) => item.isPurchased).length;

  ShoppingRequestsState copyWith({
    ShoppingRequestsStatus? status,
    List<ShoppingRequest>? requests,
    String? message,
    String? mutatingRequestId,
    bool clearMessage = false,
    bool clearMutatingRequest = false,
  }) => ShoppingRequestsState(
    status: status ?? this.status,
    requests: requests ?? this.requests,
    message: clearMessage ? null : message ?? this.message,
    mutatingRequestId: clearMutatingRequest
        ? null
        : mutatingRequestId ?? this.mutatingRequestId,
  );

  @override
  List<Object?> get props => [status, requests, message, mutatingRequestId];
}

class ShoppingRequestsCubit extends Cubit<ShoppingRequestsState> {
  ShoppingRequestsCubit(this._repository, this.productId)
    : super(const ShoppingRequestsState());

  final ShoppingRepository _repository;
  final String productId;
  StreamSubscription<List<ShoppingRequest>>? _subscription;

  void initialize() {
    _subscription ??= _repository
        .watchRequests(productId)
        .listen(
          (requests) => emit(
            state.copyWith(
              status: ShoppingRequestsStatus.ready,
              requests: requests,
              clearMessage: true,
            ),
          ),
          onError: (Object error) => emit(
            state.copyWith(
              status: ShoppingRequestsStatus.failure,
              message: 'Checklist gagal dimuat: $error',
            ),
          ),
        );
  }

  Future<bool> addRequest({
    required String tripId,
    required String buyerName,
    required int quantity,
    required String note,
  }) async {
    final normalizedName = buyerName.trim();
    if (normalizedName.isEmpty || quantity <= 0) return false;
    try {
      await _repository.addRequest(
        NewShoppingRequest(
          tripId: tripId,
          productId: productId,
          buyerName: normalizedName,
          quantity: quantity,
          note: note.trim(),
        ),
      );
      return true;
    } catch (error) {
      emit(state.copyWith(message: 'Pembeli gagal ditambahkan: $error'));
      return false;
    }
  }

  Future<bool> updateRequest({
    required ShoppingRequest request,
    required String buyerName,
    required int quantity,
    required String note,
  }) async {
    final normalizedName = buyerName.trim();
    if (normalizedName.isEmpty || quantity <= 0) return false;
    if (state.mutatingRequestId != null) return false;
    emit(state.copyWith(mutatingRequestId: request.id, clearMessage: true));
    try {
      await _repository.updateRequest(
        ShoppingRequest(
          id: request.id,
          tripId: request.tripId,
          productId: request.productId,
          buyerName: normalizedName,
          quantity: quantity,
          note: note.trim(),
          isPurchased: request.isPurchased,
          purchasedAt: request.purchasedAt,
          createdAt: request.createdAt,
          updatedAt: request.updatedAt,
        ),
      );
      emit(state.copyWith(clearMutatingRequest: true));
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          clearMutatingRequest: true,
          message: 'Data pembeli gagal diubah: $error',
        ),
      );
      return false;
    }
  }

  Future<void> setPurchased(ShoppingRequest request, bool value) async {
    if (state.mutatingRequestId != null) return;
    emit(state.copyWith(mutatingRequestId: request.id, clearMessage: true));
    try {
      await _repository.setPurchased(request.id, value);
      emit(state.copyWith(clearMutatingRequest: true));
    } catch (error) {
      emit(
        state.copyWith(
          clearMutatingRequest: true,
          message: 'Status pembelian gagal diubah: $error',
        ),
      );
    }
  }

  Future<bool> deleteRequest(String requestId) async {
    try {
      await _repository.deleteRequest(requestId);
      return true;
    } catch (error) {
      emit(state.copyWith(message: 'Pembeli gagal dihapus: $error'));
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
