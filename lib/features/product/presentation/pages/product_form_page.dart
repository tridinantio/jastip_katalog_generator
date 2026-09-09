import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatters/app_formatters.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/services/image_services.dart';
import '../../domain/services/location_services.dart';
import '../cubit/product_form_cubit.dart';

class ProductFormPage extends StatelessWidget {
  const ProductFormPage({
    required this.trip,
    required this.productRepository,
    required this.imagePicker,
    required this.locationService,
    this.productId,
    super.key,
  });

  final Trip trip;
  final ProductRepository productRepository;
  final ProductImagePicker imagePicker;
  final ProductLocationService locationService;
  final String? productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductFormCubit(
        imagePicker,
        locationService,
        trip: trip,
        productRepository: productRepository,
        productId: productId,
      )..initialize(),
      child: _ProductFormView(isEditing: productId != null),
    );
  }
}

class _ProductFormView extends StatelessWidget {
  const _ProductFormView({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductFormCubit, ProductFormState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.message != current.message,
      listener: (context, state) {
        if (state.status == ProductFormStatus.success) {
          Navigator.of(context).pop();
          return;
        }
        if (state.message != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit produk' : 'Tambah produk'),
        ),
        body: BlocBuilder<ProductFormCubit, ProductFormState>(
          builder: (context, state) {
            if (state.status == ProductFormStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (isEditing &&
                state.status == ProductFormStatus.failure &&
                state.originalImageBytes == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.message ?? 'Produk gagal dibuka.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final cubit = context.read<ProductFormCubit>();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                const _PromptTitle(
                  number: '01',
                  title: 'Foto produknya',
                  subtitle: 'Foto asli akan disimpan langsung di perangkat.',
                ),
                const SizedBox(height: 12),
                _ImagePickerCard(state: state),
                const SizedBox(height: 30),
                const _PromptTitle(number: '02', title: 'Apa nama produknya?'),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: state.name,
                  textCapitalization: TextCapitalization.words,
                  onChanged: cubit.nameChanged,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Lip Balm Strawberry',
                  ),
                ),
                const SizedBox(height: 30),
                _PromptTitle(
                  number: '03',
                  title: 'Berapa harga aslinya?',
                  subtitle:
                      'Kurs: 1 ${state.trip.currencyCode} = Rp${formatRate(state.trip.rateMicros)}',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: state.priceText,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                  ],
                  onChanged: cubit.priceChanged,
                  decoration: InputDecoration(
                    prefixText: '${state.trip.currencySymbol} ',
                    hintText: '500',
                    helperText: 'Masukkan tanpa pemisah ribuan',
                  ),
                ),
                const SizedBox(height: 18),
                _PricePreview(state: state),
                const SizedBox(height: 24),
                ExpansionTile(
                  initiallyExpanded: state.usesCustomPricing,
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  shape: const Border(),
                  title: const Text(
                    'Harga khusus produk',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    state.usesCustomPricing
                        ? 'Produk ini tidak mengikuti markup trip.'
                        : 'Gunakan markup dan biaya tetap dari trip.',
                  ),
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Gunakan pengaturan khusus'),
                      value: state.usesCustomPricing,
                      onChanged: cubit.customPricingChanged,
                    ),
                    if (state.usesCustomPricing) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: state.markupText,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                        ],
                        onChanged: cubit.markupChanged,
                        decoration: const InputDecoration(
                          labelText: 'Margin produk',
                          suffixText: '%',
                          hintText: '15',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: state.fixedFeeText,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: cubit.fixedFeeChanged,
                        decoration: const InputDecoration(
                          labelText: 'Biaya tetap produk',
                          prefixText: 'Rp ',
                          hintText: '0',
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                ExpansionTile(
                  initiallyExpanded:
                      state.category.isNotEmpty || state.note.isNotEmpty,
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  shape: const Border(),
                  title: const Text(
                    'Tambahkan detail',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Opsional'),
                  children: [
                    TextFormField(
                      initialValue: state.category,
                      textCapitalization: TextCapitalization.words,
                      onChanged: cubit.categoryChanged,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        hintText: 'Kosmetik, makanan, fashion…',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: state.weightText,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: cubit.weightChanged,
                      decoration: const InputDecoration(
                        labelText: 'Berat barang',
                        suffixText: 'gram',
                        hintText: 'Contoh: 250',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: state.note,
                      minLines: 2,
                      maxLines: 4,
                      onChanged: cubit.noteChanged,
                      decoration: const InputDecoration(
                        labelText: 'Catatan',
                        hintText: 'Varian, ukuran, atau informasi tambahan',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _PromptTitle(
                  number: '04',
                  title: 'Di mana produk ini ditemukan?',
                  subtitle: 'Opsional · beri nama agar lokasi mudah dikenali.',
                ),
                const SizedBox(height: 12),
                _LocationLabelInput(
                  value: state.locationLabel,
                  options: state.locationLabels,
                  onChanged: cubit.locationLabelChanged,
                ),
                const SizedBox(height: 12),
                _LocationCaptureCard(state: state),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: state.status == ProductFormStatus.saving
                      ? null
                      : () => _confirmAndSubmit(context, cubit),
                  child: state.status == ProductFormStatus.saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEditing ? 'Simpan perubahan' : 'Simpan produk'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmAndSubmit(
    BuildContext context,
    ProductFormCubit cubit,
  ) async {
    if (!isEditing) {
      await cubit.submit();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Simpan perubahan produk?'),
        content: const Text(
          'Data dan harga katalog produk akan diperbarui menggunakan nilai terbaru.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) await cubit.submit();
  }
}

class _LocationLabelInput extends StatefulWidget {
  const _LocationLabelInput({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  State<_LocationLabelInput> createState() => _LocationLabelInputState();
}

class _LocationLabelInputState extends State<_LocationLabelInput> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(covariant _LocationLabelInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text == widget.value) return;
    _controller.value = TextEditingValue(
      text: widget.value,
      selection: TextSelection.collapsed(offset: widget.value.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextFormField(
        controller: _controller,
        textCapitalization: TextCapitalization.words,
        onChanged: widget.onChanged,
        decoration: const InputDecoration(
          labelText: 'Nama lokasi',
          hintText: 'Contoh: Don Quijote Shinjuku',
          prefixIcon: Icon(Icons.storefront_outlined),
        ),
      ),
      if (widget.options.isNotEmpty) ...[
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: null,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Pilih lokasi tersimpan',
            prefixIcon: Icon(Icons.history_outlined),
          ),
          items: widget.options
              .map(
                (label) => DropdownMenuItem(
                  value: label,
                  child: Text(label, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value != null) widget.onChanged(value);
          },
        ),
      ],
    ],
  );
}

class _LocationCaptureCard extends StatelessWidget {
  const _LocationCaptureCard({required this.state});

  final ProductFormState state;

  @override
  Widget build(BuildContext context) {
    final location = state.location;
    final cubit = context.read<ProductFormCubit>();
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: location == null
          ? Row(
              children: [
                const Icon(Icons.location_on_outlined),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Simpan titik lokasi Anda saat ini.'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: state.isCapturingLocation
                      ? null
                      : cubit.captureCurrentLocation,
                  child: state.isCapturingLocation
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            )
          : Row(
              children: [
                Icon(Icons.location_on, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.label ?? 'Lokasi tersimpan',
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        location.coordinates,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus lokasi',
                  onPressed: cubit.clearLocation,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
    );
  }
}

class _ImagePickerCard extends StatelessWidget {
  const _ImagePickerCard({required this.state});

  final ProductFormState state;

  @override
  Widget build(BuildContext context) {
    final image = state.originalImageBytes;
    final loading = state.status == ProductFormStatus.pickingImage;
    return Container(
      height: image == null ? 184 : 260,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: image == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const CircularProgressIndicator()
                else ...[
                  const Icon(Icons.add_photo_alternate_outlined, size: 38),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => context
                            .read<ProductFormCubit>()
                            .pickImage(ImagePickSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Kamera'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context
                            .read<ProductFormCubit>()
                            .pickImage(ImagePickSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Galeri'),
                      ),
                    ],
                  ),
                ],
              ],
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(image, fit: BoxFit.cover),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FilledButton.tonalIcon(
                    onPressed: loading
                        ? null
                        : () => _chooseReplacementSource(context),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Ganti foto'),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _chooseReplacementSource(BuildContext context) async {
    final source = await showModalBottomSheet<ImagePickSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil dari kamera'),
              onTap: () => Navigator.pop(sheetContext, ImagePickSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.pop(sheetContext, ImagePickSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source != null && context.mounted) {
      await context.read<ProductFormCubit>().pickImage(source);
    }
  }
}

class _PromptTitle extends StatelessWidget {
  const _PromptTitle({
    required this.number,
    required this.title,
    this.subtitle,
  });

  final String number;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE9E9E5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(number, style: Theme.of(context).textTheme.labelSmall),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PricePreview extends StatelessWidget {
  const _PricePreview({required this.state});

  final ProductFormState state;

  @override
  Widget build(BuildContext context) {
    final breakdown = state.priceBreakdown;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Harga katalog', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 5),
          Text(
            breakdown == null ? '—' : formatIdr(breakdown.sellingPriceIdr),
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.8),
          ),
          if (breakdown != null) ...[
            const SizedBox(height: 5),
            Text(
              'Modal ${formatIdr(breakdown.capitalIdr)} · Margin ${_markupLabel(state)} · Biaya ${formatIdr(breakdown.fixedFeeIdr)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

String _markupLabel(ProductFormState state) {
  if (!state.usesCustomPricing) {
    return '${state.trip.markupPercent.toStringAsFixed(0)}%';
  }
  return '${state.markupText.replaceAll(',', '.')}%';
}
