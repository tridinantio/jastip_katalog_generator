import 'dart:math';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/services/image_services.dart';

enum CatalogPreviewStatus { loading, ready, exporting, success, failure }

class CatalogPreviewState extends Equatable {
  const CatalogPreviewState({
    this.status = CatalogPreviewStatus.loading,
    this.product,
    this.backgroundColor = 0xFFFFE4D6,
    this.message,
  });

  final CatalogPreviewStatus status;
  final Product? product;
  final int backgroundColor;
  final String? message;

  CatalogPreviewState copyWith({
    CatalogPreviewStatus? status,
    Product? product,
    int? backgroundColor,
    String? message,
    bool clearMessage = false,
  }) => CatalogPreviewState(
    status: status ?? this.status,
    product: product ?? this.product,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    message: clearMessage ? null : message ?? this.message,
  );

  @override
  List<Object?> get props => [status, product, backgroundColor, message];
}

class CatalogPreviewCubit extends Cubit<CatalogPreviewState> {
  CatalogPreviewCubit(this._repository, this._exportService)
    : super(const CatalogPreviewState());

  final ProductRepository _repository;
  final CatalogExportService _exportService;

  static const colors = <int>[
    0xFFFFF3D6,
    0xFFFFE4D6,
    0xFFEDE4FF,
    0xFFDDEEFF,
    0xFFDDF4E7,
    0xFFFFF0B8,
  ];

  Future<void> load(String productId) async {
    try {
      final product = await _repository.getProduct(productId);
      emit(
        state.copyWith(status: CatalogPreviewStatus.ready, product: product),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CatalogPreviewStatus.failure,
          message: 'Produk gagal dibuka: $error',
        ),
      );
    }
  }

  void randomizeColor() {
    final candidates = colors
        .where((color) => color != state.backgroundColor)
        .toList();
    emit(
      state.copyWith(
        backgroundColor: candidates[Random().nextInt(candidates.length)],
      ),
    );
  }

  Future<void> saveToGallery(Uint8List pngBytes) async {
    await _performExport(
      pngBytes,
      () => _exportService.saveToGallery(pngBytes),
      'Gambar katalog tersimpan di galeri.',
    );
  }

  Future<void> share(Uint8List pngBytes) async {
    final product = state.product;
    if (product == null) return;
    await _performExport(
      pngBytes,
      () => _exportService.share(pngBytes, productName: product.name),
      'Share sheet dibuka.',
    );
  }

  Future<void> _performExport(
    Uint8List pngBytes,
    Future<void> Function() action,
    String successMessage,
  ) async {
    final product = state.product;
    if (product == null || state.status == CatalogPreviewStatus.exporting) {
      return;
    }
    emit(
      state.copyWith(
        status: CatalogPreviewStatus.exporting,
        clearMessage: true,
      ),
    );
    try {
      await _repository.saveGeneratedAsset(
        productId: product.id,
        pngBytes: pngBytes,
        backgroundColor: state.backgroundColor,
      );
      await action();
      emit(
        state.copyWith(
          status: CatalogPreviewStatus.success,
          message: successMessage,
        ),
      );
      emit(state.copyWith(status: CatalogPreviewStatus.ready));
    } catch (error) {
      emit(
        state.copyWith(
          status: CatalogPreviewStatus.failure,
          message: 'Gambar gagal diproses: $error',
        ),
      );
      emit(state.copyWith(status: CatalogPreviewStatus.ready));
    }
  }
}
