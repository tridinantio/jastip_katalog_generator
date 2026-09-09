import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatters/app_formatters.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_location.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/services/image_services.dart';
import '../../domain/services/location_services.dart';
import '../../../shopping/domain/entities/shopping_request.dart';
import '../../../shopping/domain/repositories/shopping_repository.dart';
import '../../../shopping/presentation/cubit/shopping_requests_cubit.dart';
import '../cubit/catalog_preview_cubit.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    required this.productId,
    required this.trip,
    required this.productRepository,
    required this.exportService,
    required this.shoppingRepository,
    required this.locationService,
    super.key,
  });

  final String productId;
  final Trip trip;
  final ProductRepository productRepository;
  final CatalogExportService exportService;
  final ShoppingRepository shoppingRepository;
  final ProductLocationService locationService;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              CatalogPreviewCubit(productRepository, exportService)
                ..load(productId),
        ),
        BlocProvider(
          create: (_) =>
              ShoppingRequestsCubit(shoppingRepository, productId)
                ..initialize(),
        ),
      ],
      child: _ProductDetailView(trip: trip, locationService: locationService),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  const _ProductDetailView({required this.trip, required this.locationService});

  final Trip trip;
  final ProductLocationService locationService;

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  final _boundaryKey = GlobalKey();
  bool _capturing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          BlocBuilder<CatalogPreviewCubit, CatalogPreviewState>(
            builder: (context, state) {
              final busy = _isBusy(state);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Simpan ke galeri',
                    onPressed: busy ? null : () => _save(context),
                    icon: busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download_outlined),
                  ),
                  IconButton(
                    tooltip: 'Bagikan',
                    onPressed: busy ? null : () => _share(context),
                    icon: const Icon(Icons.share_outlined),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<CatalogPreviewCubit, CatalogPreviewState>(
        listenWhen: (previous, current) =>
            current.message != null && current.message != previous.message,
        listener: (context, state) =>
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message!))),
        builder: (context, state) {
          final product = state.product;
          if (state.status == CatalogPreviewStatus.loading || product == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth > 420
                  ? 420.0
                  : constraints.maxWidth - 40;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  Center(
                    child: SizedBox(
                      width: width,
                      child: RepaintBoundary(
                        key: _boundaryKey,
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: CatalogCard(
                            product: product,
                            trip: widget.trip,
                            backgroundColor: Color(state.backgroundColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: context
                        .read<CatalogPreviewCubit>()
                        .randomizeColor,
                    icon: const Icon(Icons.palette_outlined),
                    label: const Text('Acak warna'),
                  ),
                  if (product.location != null) ...[
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: () =>
                          _openLocation(context, product.location!),
                      icon: const Icon(Icons.map_outlined),
                      label: Text(
                        product.location!.label == null
                            ? 'Buka lokasi produk'
                            : 'Buka ${product.location!.label}',
                      ),
                    ),
                  ],
                  if (product.weightGrams != null ||
                      product.usesCustomPricing) ...[
                    const SizedBox(height: 12),
                    _ProductInfoCard(product: product, trip: widget.trip),
                  ],
                  const SizedBox(height: 22),
                  _ShoppingRequestsSection(trip: widget.trip),
                ],
              );
            },
          );
        },
      ),
    );
  }

  bool _isBusy(CatalogPreviewState state) =>
      _capturing || state.status == CatalogPreviewStatus.exporting;

  Future<void> _save(BuildContext context) async {
    final bytes = await _capture();
    if (!context.mounted || bytes == null) return;
    await context.read<CatalogPreviewCubit>().saveToGallery(bytes);
  }

  Future<void> _share(BuildContext context) async {
    final bytes = await _capture();
    if (!context.mounted || bytes == null) return;
    await context.read<CatalogPreviewCubit>().share(bytes);
  }

  Future<void> _openLocation(
    BuildContext context,
    ProductLocation location,
  ) async {
    try {
      final opened = await widget.locationService.openInMaps(location);
      if (!context.mounted || opened) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aplikasi peta tidak dapat dibuka.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lokasi gagal dibuka: $error')));
    }
  }

  Future<Uint8List?> _capture() async {
    if (_capturing) return null;
    setState(() => _capturing = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null || boundary.size.width == 0) return null;
      final pixelRatio = 1080 / boundary.size.width;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }
}

class _ProductInfoCard extends StatelessWidget {
  const _ProductInfoCard({required this.product, required this.trip});

  final Product product;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final customMarkup =
        product.markupBasisPointsOverride ?? trip.markupBasisPoints;
    final customFixedFee = product.fixedFeeIdrOverride ?? trip.fixedFeeIdr;
    final details = <String>[
      if (product.weightGrams != null) 'Berat ${product.weightGrams} gram',
      if (product.usesCustomPricing)
        'Margin khusus ${(customMarkup / 100).toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')}% · Biaya ${formatIdr(customFixedFee)}',
    ];
    return Card(
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('Detail produk'),
        subtitle: Text(details.join('\n')),
      ),
    );
  }
}

class _ShoppingRequestsSection extends StatelessWidget {
  const _ShoppingRequestsSection({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShoppingRequestsCubit, ShoppingRequestsState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.message!)));
      },
      builder: (context, state) {
        final progress = '${state.purchasedCount}/${state.requests.length}';
        return Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Checklist pembeli',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            state.requests.isEmpty
                                ? 'Belum ada yang memesan produk ini.'
                                : '$progress sudah dibeli',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddBuyerSheet(context, trip),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Tambah'),
                    ),
                  ],
                ),
                if (state.status == ShoppingRequestsStatus.loading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.requests.isNotEmpty)
                  ...state.requests.map(
                    (request) => _ShoppingRequestTile(request: request),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddBuyerSheet(BuildContext context, Trip trip) async {
    final requestsCubit = context.read<ShoppingRequestsCubit>();
    List<String> buyerNames = const [];
    try {
      buyerNames = await context.read<ShoppingRepository>().getBuyerNames(
        trip.id,
      );
    } catch (_) {
      // Nama tersimpan hanya bantuan input; formulir tetap dapat dipakai.
    }
    if (!context.mounted) return;
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: requestsCubit,
        child: _AddBuyerSheet(trip: trip, buyerNames: buyerNames),
      ),
    );
    if (added == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembeli ditambahkan ke checklist.')),
      );
    }
  }
}

class _ShoppingRequestTile extends StatelessWidget {
  const _ShoppingRequestTile({required this.request});

  final ShoppingRequest request;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ShoppingRequestsCubit>();
    final isMutating = cubit.state.mutatingRequestId == request.id;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: request.isPurchased,
        onChanged: isMutating
            ? null
            : (value) {
                if (value != null) cubit.setPurchased(request, value);
              },
      ),
      title: Text(
        request.buyerName,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          decoration: request.isPurchased
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
      subtitle: Text(
        '${request.quantity} pcs${request.note.isEmpty ? '' : ' · ${request.note}'}',
      ),
      trailing: IconButton(
        tooltip: 'Hapus pembeli',
        onPressed: () => _confirmDelete(context, request),
        icon: const Icon(Icons.delete_outline),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ShoppingRequest request,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus pembeli?'),
        content: Text(
          'Permintaan ${request.buyerName} akan dihapus dari checklist produk ini.',
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
    await context.read<ShoppingRequestsCubit>().deleteRequest(request.id);
  }
}

class _AddBuyerSheet extends StatefulWidget {
  const _AddBuyerSheet({required this.trip, required this.buyerNames});

  final Trip trip;
  final List<String> buyerNames;

  @override
  State<_AddBuyerSheet> createState() => _AddBuyerSheetState();
}

class _AddBuyerSheetState extends State<_AddBuyerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _noteController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tambah pembeli',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama pembeli',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nama pembeli wajib diisi.'
                    : null,
              ),
              if (widget.buyerNames.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Pilih pembeli sebelumnya',
                    prefixIcon: Icon(Icons.history_outlined),
                  ),
                  items: widget.buyerNames
                      .map(
                        (name) => DropdownMenuItem(
                          value: name,
                          child: Text(name, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (name) {
                    if (name == null) return;
                    setState(() => _nameController.text = name);
                  },
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  suffixText: 'pcs',
                  prefixIcon: Icon(Icons.numbers_outlined),
                ),
                validator: (value) {
                  final quantity = int.tryParse(value?.trim() ?? '');
                  return quantity == null || quantity <= 0
                      ? 'Masukkan jumlah yang valid.'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  hintText: 'Contoh: warna merah, ukuran L',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan pembeli'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final quantity = int.parse(_quantityController.text.trim());
    setState(() => _saving = true);
    final added = await context.read<ShoppingRequestsCubit>().addRequest(
      tripId: widget.trip.id,
      buyerName: _nameController.text,
      quantity: quantity,
      note: _noteController.text,
    );
    if (!mounted) return;
    if (added) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _saving = false);
    }
  }
}

class CatalogCard extends StatelessWidget {
  const CatalogCard({
    required this.product,
    required this.trip,
    required this.backgroundColor,
    super.key,
  });

  final Product product;
  final Trip trip;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    trip.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF202123),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'OPEN PO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              flex: 7,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ColoredBox(
                  color: Colors.white,
                  child: SizedBox.expand(
                    child: Image.memory(product.imageBytes, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              product.name.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 26,
                height: 1.05,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: Color(0xFF202123),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatIdr(product.sellingPriceIdr),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
                color: Color(0xFF202123),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Sudah termasuk jasa titip',
              style: TextStyle(fontSize: 11, color: Color(0xFF555555)),
            ),
          ],
        ),
      ),
    );
  }
}
