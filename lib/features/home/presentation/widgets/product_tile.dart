import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatters/app_formatters.dart';
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
    super.key,
  });

  final ProductSummary product;
  final Trip trip;
  final bool isDeleting;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ShoppingProgress? shoppingProgress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  product.thumbnailBytes,
                  width: 72,
                  height: 72,
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
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
        Text(
          'Checklist ${progress.purchasedRequests}/${progress.totalRequests}',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
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
