import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../trip/domain/entities/trip.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_location.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/services/image_services.dart';
import '../../domain/services/location_services.dart';
import '../../domain/use_cases/calculate_product_price.dart';

enum ProductFormStatus {
  loading,
  editing,
  pickingImage,
  saving,
  success,
  failure,
}

class ProductFormState extends Equatable {
  const ProductFormState({
    required this.trip,
    this.status = ProductFormStatus.editing,
    this.name = '',
    this.priceText = '',
    this.note = '',
    this.category = '',
    this.usesCustomPricing = false,
    this.markupText = '',
    this.fixedFeeText = '',
    this.weightText = '',
    this.location,
    this.locationLabel = '',
    this.locationLabels = const [],
    this.isCapturingLocation = false,
    this.originalImageBytes,
    this.thumbnailBytes,
    this.imageMimeType,
    this.priceBreakdown,
    this.createdProductId,
    this.message,
  });

  final Trip trip;
  final ProductFormStatus status;
  final String name;
  final String priceText;
  final String note;
  final String category;
  final bool usesCustomPricing;
  final String markupText;
  final String fixedFeeText;
  final String weightText;
  final ProductLocation? location;
  final String locationLabel;
  final List<String> locationLabels;
  final bool isCapturingLocation;
  final Uint8List? originalImageBytes;
  final Uint8List? thumbnailBytes;
  final String? imageMimeType;
  final PriceBreakdown? priceBreakdown;
  final String? createdProductId;
  final String? message;

  ProductFormState copyWith({
    ProductFormStatus? status,
    String? name,
    String? priceText,
    String? note,
    String? category,
    bool? usesCustomPricing,
    String? markupText,
    String? fixedFeeText,
    String? weightText,
    ProductLocation? location,
    String? locationLabel,
    List<String>? locationLabels,
    bool? isCapturingLocation,
    Uint8List? originalImageBytes,
    Uint8List? thumbnailBytes,
    String? imageMimeType,
    PriceBreakdown? priceBreakdown,
    String? createdProductId,
    String? message,
    bool clearMessage = false,
    bool clearLocation = false,
  }) => ProductFormState(
    trip: trip,
    status: status ?? this.status,
    name: name ?? this.name,
    priceText: priceText ?? this.priceText,
    note: note ?? this.note,
    category: category ?? this.category,
    usesCustomPricing: usesCustomPricing ?? this.usesCustomPricing,
    markupText: markupText ?? this.markupText,
    fixedFeeText: fixedFeeText ?? this.fixedFeeText,
    weightText: weightText ?? this.weightText,
    location: clearLocation ? null : location ?? this.location,
    locationLabel: locationLabel ?? this.locationLabel,
    locationLabels: locationLabels ?? this.locationLabels,
    isCapturingLocation: isCapturingLocation ?? this.isCapturingLocation,
    originalImageBytes: originalImageBytes ?? this.originalImageBytes,
    thumbnailBytes: thumbnailBytes ?? this.thumbnailBytes,
    imageMimeType: imageMimeType ?? this.imageMimeType,
    priceBreakdown: priceBreakdown ?? this.priceBreakdown,
    createdProductId: createdProductId ?? this.createdProductId,
    message: clearMessage ? null : message ?? this.message,
  );

  @override
  List<Object?> get props => [
    trip,
    status,
    name,
    priceText,
    note,
    category,
    usesCustomPricing,
    markupText,
    fixedFeeText,
    weightText,
    location,
    locationLabel,
    locationLabels,
    isCapturingLocation,
    originalImageBytes,
    thumbnailBytes,
    imageMimeType,
    priceBreakdown,
    createdProductId,
    message,
  ];
}

class ProductFormCubit extends Cubit<ProductFormState> {
  ProductFormCubit(
    this._imagePicker,
    this._locationService, {
    required Trip trip,
    required ProductRepository productRepository,
    String? productId,
    String? duplicateProductId,
  }) : _repository = productRepository,
       _productId = productId,
       _duplicateProductId = duplicateProductId,
       super(
         ProductFormState(
           trip: trip,
           status: productId == null && duplicateProductId == null
               ? ProductFormStatus.editing
               : ProductFormStatus.loading,
         ),
       );

  final ProductRepository _repository;
  final ProductImagePicker _imagePicker;
  final ProductLocationService _locationService;
  final String? _productId;
  final String? _duplicateProductId;

  Future<void> initialize() async {
    await _loadLocationLabels();
    final sourceProductId = _productId ?? _duplicateProductId;
    if (sourceProductId == null) return;
    try {
      final product = await _repository.getProduct(sourceProductId);
      if (product.tripId != state.trip.id) {
        throw StateError('Produk tidak termasuk dalam trip aktif.');
      }
      emit(
        state.copyWith(
          status: ProductFormStatus.editing,
          name: _duplicateProductId == null
              ? product.name
              : '${product.name} (salinan)',
          priceText: _formatMinorForInput(product.originalPriceMinor),
          note: product.note,
          category: product.category,
          usesCustomPricing: product.usesCustomPricing,
          markupText: _formatMarkup(
            product.markupBasisPointsOverride ?? state.trip.markupBasisPoints,
          ),
          fixedFeeText: (product.fixedFeeIdrOverride ?? state.trip.fixedFeeIdr)
              .toString(),
          weightText: product.weightGrams?.toString() ?? '',
          location: product.location,
          locationLabel: product.location?.label ?? '',
          originalImageBytes: product.imageBytes,
          thumbnailBytes: product.thumbnailBytes,
          imageMimeType: product.imageMimeType,
          priceBreakdown: CalculateProductPrice.call(
            originalPriceMinor: product.originalPriceMinor,
            trip: state.trip,
            markupBasisPointsOverride: product.markupBasisPointsOverride,
            fixedFeeIdrOverride: product.fixedFeeIdrOverride,
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProductFormStatus.failure,
          message: 'Produk gagal dibuka: $error',
        ),
      );
    }
  }

  Future<void> _loadLocationLabels() async {
    try {
      final labels = await _repository.getLocationLabels(state.trip.id);
      if (!isClosed) emit(state.copyWith(locationLabels: labels));
    } catch (_) {
      // Label lokasi bersifat pelengkap; form tetap dapat digunakan.
    }
  }

  void nameChanged(String value) => emit(state.copyWith(name: value));
  void noteChanged(String value) => emit(state.copyWith(note: value));
  void categoryChanged(String value) => emit(state.copyWith(category: value));
  void locationLabelChanged(String value) => emit(
    state.copyWith(
      locationLabel: value,
      location: state.location?.withLabel(value),
    ),
  );
  void weightChanged(String value) => emit(state.copyWith(weightText: value));

  void customPricingChanged(bool enabled) {
    final markupText = enabled && state.markupText.isEmpty
        ? _formatMarkup(state.trip.markupBasisPoints)
        : state.markupText;
    final fixedFeeText = enabled && state.fixedFeeText.isEmpty
        ? state.trip.fixedFeeIdr.toString()
        : state.fixedFeeText;
    emit(
      state.copyWith(
        usesCustomPricing: enabled,
        markupText: markupText,
        fixedFeeText: fixedFeeText,
        priceBreakdown: _calculateBreakdown(
          _parsePriceMinor(state.priceText),
          usesCustomPricing: enabled,
        ),
      ),
    );
  }

  void markupChanged(String value) => _updatePricing(markupText: value);
  void fixedFeeChanged(String value) => _updatePricing(fixedFeeText: value);

  void _updatePricing({String? markupText, String? fixedFeeText}) {
    emit(
      state.copyWith(
        markupText: markupText,
        fixedFeeText: fixedFeeText,
        priceBreakdown: _calculateBreakdown(
          _parsePriceMinor(state.priceText),
          markupText: markupText,
          fixedFeeText: fixedFeeText,
        ),
      ),
    );
  }

  Future<void> captureCurrentLocation() async {
    if (state.isCapturingLocation || state.status == ProductFormStatus.saving) {
      return;
    }
    emit(state.copyWith(isCapturingLocation: true, clearMessage: true));
    try {
      final location = await _locationService.captureCurrentLocation();
      if (isClosed) return;
      emit(
        state.copyWith(
          isCapturingLocation: false,
          location: location.withLabel(state.locationLabel),
          status: ProductFormStatus.editing,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isCapturingLocation: false,
          status: ProductFormStatus.editing,
          message: 'Lokasi gagal disimpan: $error',
        ),
      );
    }
  }

  void clearLocation() =>
      emit(state.copyWith(clearLocation: true, locationLabel: ''));

  void priceChanged(String value) {
    final minor = _parsePriceMinor(value);
    final breakdown = _calculateBreakdown(minor);
    emit(state.copyWith(priceText: value, priceBreakdown: breakdown));
  }

  Future<void> pickImage(ImagePickSource source) async {
    if (state.status == ProductFormStatus.pickingImage) return;
    emit(
      state.copyWith(
        status: ProductFormStatus.pickingImage,
        clearMessage: true,
      ),
    );
    try {
      final image = await _imagePicker.pick(source);
      if (image == null) {
        emit(state.copyWith(status: ProductFormStatus.editing));
        return;
      }
      emit(
        state.copyWith(
          status: ProductFormStatus.editing,
          originalImageBytes: image.originalBytes,
          thumbnailBytes: image.thumbnailBytes,
          imageMimeType: image.mimeType,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProductFormStatus.failure,
          message: 'Foto gagal dibuka: $error',
        ),
      );
    }
  }

  Future<void> submit() async {
    if (state.status == ProductFormStatus.saving) return;
    final originalPriceMinor = _parsePriceMinor(state.priceText);
    final markupBasisPoints = _parseMarkupBasisPoints(state.markupText);
    final fixedFeeIdr = _parseFixedFeeIdr(state.fixedFeeText);
    final weightGrams = int.tryParse(state.weightText.trim());
    if (state.name.trim().isEmpty) return _fail('Nama produk wajib diisi.');
    if (state.originalImageBytes == null || state.thumbnailBytes == null) {
      return _fail('Pilih foto produk terlebih dahulu.');
    }
    if (originalPriceMinor == null || originalPriceMinor <= 0) {
      return _fail('Harga asli harus lebih dari 0.');
    }
    if (!state.trip.hasRate) {
      return _fail('Kurs belum tersedia. Perbarui kurs pada pengaturan trip.');
    }
    if (state.usesCustomPricing &&
        (markupBasisPoints == null ||
            markupBasisPoints < 0 ||
            fixedFeeIdr == null ||
            fixedFeeIdr < 0)) {
      return _fail(
        'Margin dan biaya tetap khusus harus bernilai 0 atau lebih.',
      );
    }
    if (state.weightText.trim().isNotEmpty &&
        (weightGrams == null || weightGrams <= 0)) {
      return _fail('Berat harus berupa angka dalam gram.');
    }
    final breakdown = CalculateProductPrice.call(
      originalPriceMinor: originalPriceMinor,
      trip: state.trip,
      markupBasisPointsOverride: state.usesCustomPricing
          ? markupBasisPoints
          : null,
      fixedFeeIdrOverride: state.usesCustomPricing ? fixedFeeIdr : null,
    );
    emit(state.copyWith(status: ProductFormStatus.saving, clearMessage: true));
    try {
      final product = NewProduct(
        tripId: state.trip.id,
        name: state.name.trim(),
        originalPriceMinor: originalPriceMinor,
        sellingPriceIdr: breakdown.sellingPriceIdr,
        markupBasisPointsOverride: state.usesCustomPricing
            ? markupBasisPoints
            : null,
        fixedFeeIdrOverride: state.usesCustomPricing ? fixedFeeIdr : null,
        weightGrams: state.weightText.trim().isEmpty ? null : weightGrams,
        note: state.note.trim(),
        category: state.category.trim(),
        imageBytes: state.originalImageBytes!,
        thumbnailBytes: state.thumbnailBytes!,
        imageMimeType: state.imageMimeType ?? 'image/jpeg',
        location: state.location?.withLabel(state.locationLabel),
      );
      final existingId = _productId;
      final id = existingId ?? await _repository.createProduct(product);
      if (existingId != null) {
        await _repository.updateProduct(existingId, product);
      }
      emit(
        state.copyWith(status: ProductFormStatus.success, createdProductId: id),
      );
    } catch (error) {
      _fail('Produk gagal disimpan: $error');
    }
  }

  void _fail(String message) =>
      emit(state.copyWith(status: ProductFormStatus.failure, message: message));

  PriceBreakdown? _calculateBreakdown(
    int? originalPriceMinor, {
    String? markupText,
    String? fixedFeeText,
    bool? usesCustomPricing,
  }) {
    if (originalPriceMinor == null) return null;
    final usesCustom = usesCustomPricing ?? state.usesCustomPricing;
    final currentMarkup = _parseMarkupBasisPoints(
      markupText ?? state.markupText,
    );
    final currentFixedFee = _parseFixedFeeIdr(
      fixedFeeText ?? state.fixedFeeText,
    );
    if (usesCustom &&
        (currentMarkup == null ||
            currentMarkup < 0 ||
            currentFixedFee == null ||
            currentFixedFee < 0)) {
      return null;
    }
    return CalculateProductPrice.call(
      originalPriceMinor: originalPriceMinor,
      trip: state.trip,
      markupBasisPointsOverride: usesCustom ? currentMarkup : null,
      fixedFeeIdrOverride: usesCustom ? currentFixedFee : null,
    );
  }
}

int? _parsePriceMinor(String value) {
  final normalized = value.trim().replaceAll(',', '.');
  final amount = double.tryParse(normalized);
  if (amount == null || !amount.isFinite) return null;
  return (amount * 100).round();
}

String _formatMinorForInput(int value) {
  final whole = value ~/ 100;
  final fraction = value.abs() % 100;
  if (fraction == 0) return whole.toString();
  return '$whole.${fraction.toString().padLeft(2, '0')}'.replaceFirst(
    RegExp(r'0$'),
    '',
  );
}

int? _parseMarkupBasisPoints(String value) {
  if (value.trim().isEmpty) return 0;
  final percent = double.tryParse(value.trim().replaceAll(',', '.'));
  if (percent == null || !percent.isFinite) return null;
  return (percent * 100).round();
}

int? _parseFixedFeeIdr(String value) {
  if (value.trim().isEmpty) return 0;
  return int.tryParse(value.trim());
}

String _formatMarkup(int basisPoints) {
  final percent = basisPoints / 100;
  return percent == percent.roundToDouble()
      ? percent.toStringAsFixed(0)
      : percent.toStringAsFixed(2);
}
