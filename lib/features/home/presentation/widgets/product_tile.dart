import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatters/app_formatters.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/cubit/product_list_cubit.dart';
import '../../../shopping/domain/entities/shopping_request.dart';
import '../../../trip/domain/entities/trip.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({
    required this.product,
    required this.trip,
    required this.isDeleting,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.shoppingProgress,
    this.gallery = false,
    super.key,
  });

  final ProductSummary product;
  final Trip trip;
  final bool isDeleting;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ShoppingProgress? shoppingProgress;
  final bool gallery;

  @override
  Widget build(BuildContext context) {
    if (gallery) return _buildGallery(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  product.thumbnailBytes,
                  width: 88,
                  height: 108,
                  fit: BoxFit.cover,
                  cacheWidth: 180,
                  errorBuilder: (_, _, _) => const SizedBox.square(
                    dimension: 72,
                    child: ColoredBox(
                      color: Color(0xFFEAEAE6),
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.category.isNotEmpty) ...[
                      Text(
                        product.category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.2,
                          color: AppTheme.rust,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatForeignMinor(
                        product.originalPriceMinor,
                        trip.currencySymbol,
                        trip.currencyCode,
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatIdr(product.sellingPriceIdr),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.forest,
                        fontSize: 16,
                      ),
                    ),
                    if (shoppingProgress != null) ...[
                      const SizedBox(height: 6),
                      _ShoppingProgressLabel(progress: shoppingProgress!),
                    ],
                  ],
                ),
              ),
              if (isDeleting)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                PopupMenuButton<String>(
                  tooltip: 'Menu produk',
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 10),
                          Text('Edit produk'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline),
                          SizedBox(width: 10),
                          Text('Hapus produk'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGallery(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(
                  product.thumbnailBytes,
                  fit: BoxFit.cover,
                  cacheWidth: 480,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: AppTheme.cream,
                    child: Icon(
                      Icons.image_outlined,
                      color: AppTheme.muted,
                      size: 36,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: AppTheme.paper,
                    shape: const CircleBorder(),
                    child: isDeleting
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : PopupMenuButton<String>(
                            tooltip: 'Menu produk',
                            icon: const Icon(Icons.more_horiz, size: 20),
                            onSelected: (value) {
                              if (value == 'edit') onEdit();
                              if (value == 'delete') onDelete();
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit produk'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Hapus produk'),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category.isEmpty
                      ? 'KOLEKSI TRIP'
                      : product.category.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.rust,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: MediaQuery.textScalerOf(context).scale(14) * 2.8,
                  child: Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatIdr(product.sellingPriceIdr),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  formatForeignMinor(
                    product.originalPriceMinor,
                    trip.currencySymbol,
                    trip.currencyCode,
                  ),
                  style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: MediaQuery.textScalerOf(context).scale(12) * 1.6,
                  child: shoppingProgress == null
                      ? null
                      : _ShoppingProgressLabel(progress: shoppingProgress!),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ShoppingProgressLabel extends StatelessWidget {
  const _ShoppingProgressLabel({required this.progress});

  final ShoppingProgress progress;

  @override
  Widget build(BuildContext context) {
    final isComplete = progress.isComplete;
    final color = isComplete
        ? Colors.green.shade700
        : Theme.of(context).colorScheme.secondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isComplete ? Icons.check_circle_outline : Icons.radio_button_checked,
          size: 15,
          color: color,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            'Checklist ${progress.purchasedRequests}/${progress.totalRequests}',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> confirmAndDeleteProduct(
  BuildContext context,
  String productId,
  String productName,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Hapus produk?'),
      content: Text(
        '“$productName” beserta foto dan seluruh gambar katalog akan dihapus permanen.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final success = await context.read<ProductListCubit>().deleteProduct(
    productId,
  );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success ? 'Produk berhasil dihapus.' : 'Produk gagal dihapus.',
      ),
    ),
  );
}
