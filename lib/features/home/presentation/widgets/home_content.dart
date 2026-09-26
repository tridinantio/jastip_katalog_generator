import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatters/app_formatters.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/atelier_widgets.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../product/domain/services/image_services.dart';
import '../../../product/domain/services/location_services.dart';
import '../../../product/presentation/cubit/product_list_cubit.dart';
import '../../../product/presentation/pages/catalog_preview_page.dart';
import '../../../shopping/domain/repositories/shopping_repository.dart';
import '../../../shopping/domain/entities/shopping_checklist.dart';
import '../../../shopping/domain/services/shopping_checklist_workbook_service.dart';
import '../../../shopping/domain/use_cases/build_shopping_checklist.dart';
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
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: _DashboardOverview(
                      trip: trip,
                      state: tripState,
                      onAdd: () => _openForm(context, trip),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Produk terbaru',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                          onTap: () => _openPreview(context, product.id, trip),
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

class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview({
    required this.trip,
    required this.state,
    required this.onAdd,
  });
  final Trip trip;
  final ActiveTripState state;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AtelierHeading(
        eyebrow: 'JASTIP / YOUR TRAVEL ATELIER',
        title: 'Pergi. Temukan. Titip.',
        subtitle: 'Temuan istimewa, dari perjalanan Anda.',
      ),
      const SizedBox(height: 24),
      LayoutBuilder(
        builder: (context, constraints) {
          final summary = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BlocBuilder<ShoppingSummaryCubit, ShoppingSummaryState>(
                builder: (context, state) =>
                    _ShoppingSummaryCard(trip: trip, state: state),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: trip.hasRate ? onAdd : null,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(trip.hasRate ? 'Tambah produk' : 'Menunggu kurs'),
              ),
            ],
          );
          if (constraints.maxWidth >= 760) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _Header(trip: trip, state: state),
                ),
                const SizedBox(width: 20),
                Expanded(flex: 5, child: summary),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(trip: trip, state: state),
              const SizedBox(height: 12),
              summary,
            ],
          );
        },
      ),
    ],
  );
}

class _ShoppingSummaryCard extends StatefulWidget {
  const _ShoppingSummaryCard({required this.trip, required this.state});

  final Trip trip;
  final ShoppingSummaryState state;

  @override
  State<_ShoppingSummaryCard> createState() => _ShoppingSummaryCardState();
}

class _ShoppingSummaryCardState extends State<_ShoppingSummaryCard> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final summary = state.summary;
    final isLoading =
        state.status == ShoppingSummaryStatus.loading ||
        state.status == ShoppingSummaryStatus.initial;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 20,
                  color: AppTheme.rust,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rekap belanja',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (isLoading)
                  const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final singleColumn =
                    MediaQuery.textScalerOf(context).scale(14) > 19;
                final columnCount = singleColumn
                    ? 1
                    : constraints.maxWidth >= 520
                    ? 4
                    : 2;
                final width =
                    (constraints.maxWidth - (12 * (columnCount - 1))) /
                    columnCount;
                return Wrap(
                  spacing: 12,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: width,
                      child: _SummaryMetric(
                        label: 'Modal estimasi',
                        value: formatIdr(summary.estimatedCapitalIdr),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _SummaryMetric(
                        label: 'Belanja aktual',
                        value: formatIdr(summary.actualCapitalIdr),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _SummaryMetric(
                        label: 'Keuntungan',
                        value: formatIdr(summary.estimatedProfitIdr),
                        valueColor: AppTheme.rust,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _SummaryMetric(
                        label: 'Berat estimasi',
                        value: formatWeight(summary.estimatedWeightGrams),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 5,
                value: summary.totalQuantity == 0
                    ? 0
                    : (summary.purchasedQuantity / summary.totalQuantity).clamp(
                        0,
                        1,
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              summary.isEmpty
                  ? 'Belum ada daftar belanja'
                  : '${summary.purchasedQuantity} dari ${summary.totalQuantity} pcs terbeli',
              style: const TextStyle(fontSize: 11, color: AppTheme.muted),
            ),
            if (summary.isEmpty && !isLoading) ...[
              const SizedBox(height: 5),
              const Text(
                'Tambahkan pembeli dari Detail Produk untuk mengisi rekap.',
                style: TextStyle(fontSize: 11, color: AppTheme.muted),
              ),
            ],
            if (!summary.isEmpty) ...[
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 330;
                  final exportButton = FilledButton.tonalIcon(
                    onPressed: _isProcessing ? null : _exportChecklist,
                    icon: _isProcessing
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.table_view_outlined),
                    label: const Text('Ekspor Excel'),
                  );
                  final importButton = OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _importChecklist,
                    icon: const Icon(Icons.file_upload_outlined),
                    label: const Text('Impor checklist'),
                  );
                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        exportButton,
                        const SizedBox(height: 8),
                        importButton,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: exportButton),
                      const SizedBox(width: 8),
                      Expanded(child: importButton),
                    ],
                  );
                },
              ),
            ],
            if (state.status == ShoppingSummaryStatus.failure &&
                state.message != null) ...[
              const SizedBox(height: 10),
              Text(
                state.message!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _exportChecklist() async {
    await _runChecklistAction(
      (service, checklist) => service.export(checklist),
    );
  }

  Future<void> _importChecklist() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final result = await context
          .read<ShoppingChecklistWorkbookService>()
          .importChecklist(widget.trip.id);
      if (!mounted || result.wasCancelled) return;
      final repository = context.read<ShoppingRepository>();
      for (final update in result.updates) {
        await repository.setPurchasedForProduct(
          widget.trip.id,
          update.productId,
          update.isPurchased,
        );
      }
      if (!mounted) return;
      final message = result.updates.isEmpty
          ? 'Tidak ada perubahan checklist untuk diperbarui.'
          : '${result.updates.length} checklist berhasil diperbarui.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checklist gagal diimpor: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _runChecklistAction(
    Future<void> Function(
      ShoppingChecklistWorkbookService service,
      ShoppingChecklist checklist,
    )
    action,
  ) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final trip = widget.trip;
    final productRepository = context.read<ProductRepository>();
    final shoppingRepository = context.read<ShoppingRepository>();
    final workbookService = context.read<ShoppingChecklistWorkbookService>();
    try {
      final products = await productRepository.watchProducts(trip.id).first;
      final requests = await shoppingRepository
          .watchRequestsForTrip(trip.id)
          .first;
      final checklist = BuildShoppingChecklist.call(
        tripId: trip.id,
        tripName: trip.name,
        products: products,
        requests: requests,
      );
      if (checklist.isEmpty) return;
      await action(workbookService, checklist);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Daftar belanja gagal diekspor: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
      const SizedBox(height: 6),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: -.6,
          color: valueColor,
        ),
      ),
    ],
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.trip, required this.state});
  final Trip trip;
  final ActiveTripState state;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppTheme.forest,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Stack(
          children: [
            const Positioned(
              right: -28,
              top: -28,
              child: JourneyGlobe(size: 190, color: Color(0xFF3D6050)),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.flight_takeoff_rounded,
                        color: Color(0xFFD8E5B7),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'TRIP AKTIF',
                          style: TextStyle(
                            color: Color(0xFFD8E5B7),
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (state.isRefreshingRate)
                        const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PopupMenuButton<String>(
                    tooltip: 'Ganti trip',
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
                                  child: Text(
                                    item.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(growable: false),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              trip.name,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF648174),
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.expand_more,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const TicketDivider(),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MATA UANG',
                              style: TextStyle(
                                color: Color(0xFFB8CABB),
                                fontSize: 9,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              trip.currencyCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        child: Icon(
                          Icons.east_rounded,
                          size: 20,
                          color: Color(0xFFD8E5B7),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'KURS KE RUPIAH',
                              style: TextStyle(
                                color: Color(0xFFB8CABB),
                                fontSize: 9,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              trip.hasRate
                                  ? 'Rp${formatRate(trip.rateMicros)}'
                                  : 'Mengambil kurs…',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    trip.hasRate
                        ? 'Per 1 ${trip.currencyCode}${trip.rateDate == null ? '' : ' · ${formatShortDate(trip.rateDate!)}'}'
                        : state.message ?? 'Menunggu kurs terbaru',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFCFDACF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 4),
    ],
  );
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts({required this.hasRate});
  final bool hasRate;
  @override
  Widget build(BuildContext context) => AtelierEmptyState(
    icon: Icons.shopping_bag_outlined,
    title: hasRate ? 'Belum ada produk' : 'Kurs belum tersedia',
    message: hasRate
        ? 'Setiap perjalanan punya temuan istimewa. Foto produk pertama Anda dan mulai koleksinya.'
        : 'Buka Pengaturan untuk memilih mata uang dan mencoba lagi.',
  );
}
