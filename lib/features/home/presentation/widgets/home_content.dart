import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatters/app_formatters.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../product/domain/services/image_services.dart';
import '../../../product/domain/services/location_services.dart';
import '../../../product/presentation/cubit/product_list_cubit.dart';
import '../../../product/presentation/pages/catalog_preview_page.dart';
import '../../../shopping/domain/repositories/shopping_repository.dart';
import '../../../shopping/presentation/cubit/shopping_summary_cubit.dart';
import '../../../product/presentation/pages/product_form_page.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../../trip/presentation/cubit/active_trip_cubit.dart';
import 'product_tile.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveTripCubit, ActiveTripState>(
      builder: (context, tripState) {
        final trip = tripState.trip;
        if (trip == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return BlocBuilder<ProductListCubit, ProductListState>(
          builder: (context, productState) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: _Header(trip: trip, state: tripState),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  sliver: SliverToBoxAdapter(
                    child:
                        BlocBuilder<ShoppingSummaryCubit, ShoppingSummaryState>(
                          builder: (context, summaryState) {
                            return _ShoppingSummaryCard(state: summaryState);
                          },
                        ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: FilledButton.icon(
                      onPressed: trip.hasRate
                          ? () => _openForm(context, trip)
                          : null,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(
                        trip.hasRate ? 'Tambah produk' : 'Menunggu kurs',
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Text(
                          'Produk terbaru',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text('${productState.products.length} produk'),
                      ],
                    ),
                  ),
                ),
                if (productState.status == ProductListStatus.loading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (productState.products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyProducts(hasRate: trip.hasRate),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList.separated(
                      itemCount: productState.products.length > 5
                          ? 5
                          : productState.products.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final product = productState.products[index];
                        return ProductTile(
                          product: product,
                          trip: trip,
                          isDeleting:
                              productState.deletingProductId == product.id,
                          onTap: () => _openPreview(context, product.id, trip),
                          onEdit: () =>
                              _openEditForm(context, product.id, trip),
                          onDelete: () => confirmAndDeleteProduct(
                            context,
                            product.id,
                            product.name,
                          ),
                          shoppingProgress:
                              productState.progressByProductId[product.id],
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openForm(BuildContext context, Trip trip) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ProductFormPage(
          trip: trip,
          productRepository: context.read<ProductRepository>(),
          imagePicker: context.read<ProductImagePicker>(),
          locationService: context.read<ProductLocationService>(),
        ),
      ),
    );
  }

  Future<void> _openEditForm(
    BuildContext context,
    String productId,
    Trip trip,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ProductFormPage(
          trip: trip,
          productId: productId,
          productRepository: context.read<ProductRepository>(),
          imagePicker: context.read<ProductImagePicker>(),
          locationService: context.read<ProductLocationService>(),
        ),
      ),
    );
  }

  void _openPreview(BuildContext context, String productId, Trip trip) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(
          productId: productId,
          trip: trip,
          productRepository: context.read<ProductRepository>(),
          exportService: context.read<CatalogExportService>(),
          shoppingRepository: context.read<ShoppingRepository>(),
          locationService: context.read<ProductLocationService>(),
        ),
      ),
    );
  }
}

class _ShoppingSummaryCard extends StatelessWidget {
  const _ShoppingSummaryCard({required this.state});

  final ShoppingSummaryState state;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLoading =
        state.status == ShoppingSummaryStatus.loading ||
        state.status == ShoppingSummaryStatus.initial;
    final progressLabel = summary.isEmpty
        ? 'Belum ada daftar belanja'
        : '${summary.purchasedQuantity} dari ${summary.totalQuantity} pcs terbeli';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Rekap belanja',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (isLoading)
                  const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    progressLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    label: 'Modal estimasi',
                    value: formatIdr(summary.estimatedCapitalIdr),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Belanja aktual',
                    value: formatIdr(summary.actualCapitalIdr),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Keuntungan',
                    value: formatIdr(summary.estimatedProfitIdr),
                    valueColor: colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (summary.isEmpty && !isLoading) ...[
              const SizedBox(height: 10),
              Text(
                'Tambahkan pembeli dari Detail Produk untuk mengisi rekap.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (state.status == ShoppingSummaryStatus.failure &&
                state.message != null) ...[
              const SizedBox(height: 10),
              Text(
                state.message!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.trip, required this.state});

  final Trip trip;
  final ActiveTripState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Jastip',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1),
              ),
            ),
            Chip(
              avatar: state.isRefreshingRate
                  ? const SizedBox.square(
                      dimension: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.currency_exchange, size: 16),
              label: Text(trip.currencyCode),
            ),
          ],
        ),
        const SizedBox(height: 20),
        PopupMenuButton<String>(
          enabled: !state.isManagingTrips,
          onSelected: context.read<ActiveTripCubit>().selectTrip,
          itemBuilder: (_) => state.trips
              .map(
                (item) => PopupMenuItem(
                  value: item.id,
                  child: Row(
                    children: [
                      Icon(
                        item.id == trip.id
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(item.name, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              )
              .toList(growable: false),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  trip.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
        const SizedBox(height: 6),
        if (trip.hasRate)
          Text(
            '1 ${trip.currencyCode} = Rp${formatRate(trip.rateMicros)}'
            '${trip.rateDate == null ? '' : ' · ${formatShortDate(trip.rateDate!)}'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )
        else
          Text(
            state.message ?? 'Mengambil kurs terbaru…',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        const SizedBox(height: 22),
      ],
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts({required this.hasRate});

  final bool hasRate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 44),
          const SizedBox(height: 14),
          Text(
            hasRate ? 'Belum ada produk' : 'Kurs belum tersedia',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            hasRate
                ? 'Foto produk pertama Anda dan buat katalog dalam beberapa langkah.'
                : 'Buka Pengaturan untuk memilih mata uang dan mencoba lagi.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
