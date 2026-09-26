import 'dart:typed_data';

enum ShoppingChecklistStatus { pending, partial, purchased }

class ShoppingChecklist {
  const ShoppingChecklist({
    required this.tripId,
    required this.tripName,
    required this.items,
  });

  final String tripId;
  final String tripName;
  final List<ShoppingChecklistItem> items;

  bool get isEmpty => items.isEmpty;
}

class ShoppingChecklistItem {
  const ShoppingChecklistItem({
    required this.productId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.thumbnailBytes,
    required this.status,
  });

  final String productId;
  final String name;
  final String category;
  final int quantity;
  final Uint8List thumbnailBytes;
  final ShoppingChecklistStatus status;

  bool get isPurchased => status == ShoppingChecklistStatus.purchased;
}

class ShoppingChecklistUpdate {
  const ShoppingChecklistUpdate({
    required this.productId,
    required this.isPurchased,
  });

  final String productId;
  final bool isPurchased;
}

class ShoppingChecklistImportResult {
  const ShoppingChecklistImportResult({
    required this.wasCancelled,
    this.updates = const [],
  });

  const ShoppingChecklistImportResult.cancelled()
    : wasCancelled = true,
      updates = const [];

  final bool wasCancelled;
  final List<ShoppingChecklistUpdate> updates;
}
