import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/atelier_widgets.dart';

import '../../../product/domain/repositories/product_repository.dart';
import '../../../product/domain/services/image_services.dart';
import '../../../product/domain/services/location_services.dart';
import '../../../product/presentation/cubit/product_list_cubit.dart';
import '../../../product/presentation/pages/catalog_preview_page.dart';
import '../../../product/presentation/widgets/product_filter_sheet.dart';
import '../../../trip/presentation/cubit/active_trip_cubit.dart';
import '../../../shopping/domain/repositories/shopping_repository.dart';
import 'product_category_groups.dart';
import 'product_tile.dart';

class ProductsContent extends StatefulWidget {
  const ProductsContent({super.key});

  @override
  State<ProductsContent> createState() => _ProductsContentState();
}

class _ProductsContentState extends State<ProductsContent> {
  final Map<String, bool> _categoryExpansion = {};

  bool _isCategoryExpanded(ProductCategoryGroup group, int index) =>
      _categoryExpansion[group.key] ?? index == 0;

  void _toggleCategory(ProductCategoryGroup group, int index) {
    setState(() {
      _categoryExpansion[group.key] = !_isCategoryExpanded(group, index);
    });
  }

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
              child: AtelierHeading(
                eyebrow: 'THE COLLECTION',
                title: 'Semua produk',
                subtitle: 'Temuan pilihan dari ${trip.name}.',
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
                    return AtelierEmptyState(
                      icon: Icons.manage_search_rounded,
                      title: state.filter.isDefault
                          ? 'Produk tidak ditemukan.'
                          : 'Tidak ada produk sesuai filter.',
                      message: 'Coba kata kunci lain, ubah filter, atau tambahkan temuan baru dari halaman Trip.',
                    );
                  }
                  final groups = groupProductsByCategory(state.products);
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final textScale = MediaQuery.textScalerOf(context)
                          .scale(14);
                      final gridDelegate =
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                constraints.maxWidth < 360 || textScale > 21
                                ? 1
                                : constraints.maxWidth < 700
                                ? 2
                                : 3,
                            mainAxisExtent: 340 + (textScale - 14) * 8,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          );
                      return CustomScrollView(
                        key: const PageStorageKey('products-category-list'),
                        slivers: [
                          for (
                            var index = 0;
                            index < groups.length;
                            index++
                          ) ...[
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                20,
                                index == 0 ? 0 : 14,
                                20,
                                0,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: _CategorySectionHeader(
                                  group: groups[index],
                                  isExpanded: _isCategoryExpanded(
                                    groups[index],
                                    index,
                                  ),
                                  onTap: () =>
                                      _toggleCategory(groups[index], index),
                                ),
                              ),
                            ),
                            if (_isCategoryExpanded(groups[index], index))
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  10,
                                  20,
                                  0,
                                ),
                                sliver: SliverGrid(
                                  gridDelegate: gridDelegate,
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    productIndex,
                                  ) {
                                    final product =
                                        groups[index].products[productIndex];
                                    return ProductTile(
                                      gallery: true,
                                      product: product,
                                      trip: trip,
                                      onTap: () => Navigator.of(context)
                                          .push<void>(
                                            MaterialPageRoute(
                                              builder: (_) => ProductDetailPage(
                                                productId: product.id,
                                                trip: trip,
                                                productRepository: context
                                                    .read<ProductRepository>(),
                                                exportService: context
                                                    .read<
                                                      CatalogExportService
                                                    >(),
                                                shoppingRepository: context
                                                    .read<ShoppingRepository>(),
                                                locationService: context
                                                    .read<
                                                      ProductLocationService
                                                    >(),
                                              ),
                                            ),
                                          ),
                                      shoppingProgress:
                                          state.progressByProductId[product.id],
                                    );
                                  }, childCount: groups[index].products.length),
                                ),
                              ),
                          ],
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                        ],
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

class _CategorySectionHeader extends StatelessWidget {
  const _CategorySectionHeader({
    required this.group,
    required this.isExpanded,
    required this.onTap,
  });

  final ProductCategoryGroup group;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      key: ValueKey('category-${group.key}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                group.representativeProduct.thumbnailBytes,
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                cacheWidth: 96,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const SizedBox.square(
                    dimension: 46,
                    child: Icon(Icons.inventory_2_outlined),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.label.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: group.isUncategorized
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : AppTheme.forest,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${group.products.length} produk',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    ),
  );
}
