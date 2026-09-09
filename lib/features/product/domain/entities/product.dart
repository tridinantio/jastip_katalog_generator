import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import 'product_location.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.tripId,
    required this.name,
    required this.originalPriceMinor,
    required this.sellingPriceIdr,
    this.markupBasisPointsOverride,
    this.fixedFeeIdrOverride,
    this.weightGrams,
    required this.note,
    required this.category,
    required this.imageBytes,
    required this.thumbnailBytes,
    required this.imageMimeType,
    required this.createdAt,
    required this.updatedAt,
    this.location,
  });

  final String id;
  final String tripId;
  final String name;
  final int originalPriceMinor;
  final int sellingPriceIdr;
  final int? markupBasisPointsOverride;
  final int? fixedFeeIdrOverride;
  final int? weightGrams;
  bool get usesCustomPricing =>
      markupBasisPointsOverride != null || fixedFeeIdrOverride != null;
  final String note;
  final String category;
  final Uint8List imageBytes;
  final Uint8List thumbnailBytes;
  final String imageMimeType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProductLocation? location;

  @override
  List<Object?> get props => [
    id,
    tripId,
    name,
    originalPriceMinor,
    sellingPriceIdr,
    markupBasisPointsOverride,
    fixedFeeIdrOverride,
    weightGrams,
    note,
    category,
    imageBytes,
    thumbnailBytes,
    imageMimeType,
    createdAt,
    updatedAt,
    location,
  ];
}

class ProductSummary extends Equatable {
  const ProductSummary({
    required this.id,
    required this.tripId,
    required this.name,
    required this.originalPriceMinor,
    required this.sellingPriceIdr,
    this.markupBasisPointsOverride,
    this.fixedFeeIdrOverride,
    required this.thumbnailBytes,
    required this.createdAt,
    this.category = '',
    this.hasLocation = false,
  });

  final String id;
  final String tripId;
  final String name;
  final int originalPriceMinor;
  final int sellingPriceIdr;
  final int? markupBasisPointsOverride;
  final int? fixedFeeIdrOverride;
  final Uint8List thumbnailBytes;
  final DateTime createdAt;
  final String category;
  final bool hasLocation;

  @override
  List<Object?> get props => [
    id,
    tripId,
    name,
    originalPriceMinor,
    sellingPriceIdr,
    markupBasisPointsOverride,
    fixedFeeIdrOverride,
    thumbnailBytes,
    createdAt,
    category,
    hasLocation,
  ];
}

class NewProduct {
  const NewProduct({
    required this.tripId,
    required this.name,
    required this.originalPriceMinor,
    required this.sellingPriceIdr,
    this.markupBasisPointsOverride,
    this.fixedFeeIdrOverride,
    this.weightGrams,
    required this.note,
    required this.category,
    required this.imageBytes,
    required this.thumbnailBytes,
    required this.imageMimeType,
    this.location,
  });

  final String tripId;
  final String name;
  final int originalPriceMinor;
  final int sellingPriceIdr;
  final int? markupBasisPointsOverride;
  final int? fixedFeeIdrOverride;
  final int? weightGrams;
  final String note;
  final String category;
  final Uint8List imageBytes;
  final Uint8List thumbnailBytes;
  final String imageMimeType;
  final ProductLocation? location;
}
