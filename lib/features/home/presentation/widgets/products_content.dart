import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/domain/repositories/product_repository.dart';
import '../../../product/domain/services/image_services.dart';
import '../../../product/domain/services/location_services.dart';
import '../../../product/presentation/cubit/product_list_cubit.dart';
import '../../../product/presentation/pages/catalog_preview_page.dart';
import '../../../product/presentation/pages/product_form_page.dart';
import '../../../product/presentation/widgets/product_filter_sheet.dart';
import '../../../trip/presentation/cubit/active_trip_cubit.dart';
import '../../../shopping/domain/repositories/shopping_repository.dart';
import 'product_tile.dart';

class ProductsContent extends StatelessWidget {
  const ProductsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveTripCubit, ActiveTripState>(
      builder: (context, tripState) {
        final trip = tripState.trip;
        if (trip == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Semua produk',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1),
              ),
            ),
            BlocBuilder<ProductListCubit, ProductListState>(
              builder: (context, state) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.search,
                        onChanged: context.read<ProductListCubit>().search,
                        decoration: const InputDecoration(
                          hintText: 'Cari produk',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Filter produk',
                      onPressed: () => _openFilter(context, state),
                      icon: state.filter.isDefault
                          ? const Icon(Icons.filter_list)
                          : Badge.count(
                              count: state.filter.activeCount,
                              child: const Icon(Icons.filter_list),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            BlocBuilder<ProductListCubit, ProductListState>(
              builder: (context, state) {
                if (state.filter.isDefault) return const SizedBox(height: 8);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${state.filter.activeCount} filter aktif · ${state.products.length} produk',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<ProductListCubit, ProductListState>(
                builder: (context, state) {
                  if (state.status == ProductListStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.products.isEmpty) {
                    return Center(
                      child: Text(
                        state.filter.isDefault
                            ? 'Produk tidak ditemukan.'
                            : 'Tidak ada produk sesuai filter.',
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: state.products.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return ProductTile(
                        product: product,
                        trip: trip,
                        isDeleting: state.deletingProductId == product.id,
                        onTap: () => Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(
                              productId: product.id,
                              trip: trip,
                              productRepository: context
                                  .read<ProductRepository>(),
                              exportService: context
                                  .read<CatalogExportService>(),
                              shoppingRepository: context
                                  .read<ShoppingRepository>(),
                              locationService: context
                                  .read<ProductLocationService>(),
                            ),
                          ),
                        ),
                        onEdit: () => Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (_) => ProductFormPage(
                              trip: trip,
                              productId: product.id,
                              productRepository: context
                                  .read<ProductRepository>(),
                              imagePicker: context.read<ProductImagePicker>(),
                              locationService: context
                                  .read<ProductLocationService>(),
                            ),
                          ),
                        ),
                        onDelete: () => confirmAndDeleteProduct(
                          context,
                          product.id,
                          product.name,
                        ),
                        shoppingProgress: state.progressByProductId[product.id],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openFilter(BuildContext context, ProductListState state) async {
    final categories =
        state.allProducts
            .map((product) => product.category.trim())
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final filter = await showProductFilterSheet(
      context: context,
      initialFilter: state.filter,
      categories: categories,
    );
    if (!context.mounted || filter == null) return;
    context.read<ProductListCubit>().setFilter(filter);
  }
}
