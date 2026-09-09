import 'package:flutter/material.dart';

import '../cubit/product_list_cubit.dart';

Future<ProductListFilter?> showProductFilterSheet({
  required BuildContext context,
  required ProductListFilter initialFilter,
  required List<String> categories,
}) {
  return showModalBottomSheet<ProductListFilter>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _ProductFilterSheet(
      initialFilter: initialFilter,
      categories: categories,
    ),
  );
}

class _ProductFilterSheet extends StatefulWidget {
  const _ProductFilterSheet({
    required this.initialFilter,
    required this.categories,
  });

  final ProductListFilter initialFilter;
  final List<String> categories;

  @override
  State<_ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<_ProductFilterSheet> {
  late String? _category;
  late ProductPurchaseFilter _purchase;
  late ProductLocationFilter _location;

  @override
  void initState() {
    super.initState();
    _category = widget.initialFilter.category;
    _purchase = widget.initialFilter.purchase;
    _location = widget.initialFilter.location;
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * .82;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filter produk',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                children: [
                  const _FilterSectionLabel('Kategori'),
                  DropdownButtonFormField<String>(
                    initialValue: _category ?? '',
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Kategori produk',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Semua kategori'),
                      ),
                      ...widget.categories.map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(
                      () => _category = value == null || value.isEmpty
                          ? null
                          : value,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _FilterSectionLabel('Status checklist'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _purchaseChip(ProductPurchaseFilter.all, 'Semua'),
                      _purchaseChip(
                        ProductPurchaseFilter.withoutBuyer,
                        'Belum ada pembeli',
                      ),
                      _purchaseChip(
                        ProductPurchaseFilter.pending,
                        'Belum semua terbeli',
                      ),
                      _purchaseChip(
                        ProductPurchaseFilter.purchased,
                        'Sudah terbeli semua',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _purchaseDescription(_purchase),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _FilterSectionLabel('Lokasi produk'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _locationChip(ProductLocationFilter.all, 'Semua'),
                      _locationChip(
                        ProductLocationFilter.withLocation,
                        'Ada lokasi',
                      ),
                      _locationChip(
                        ProductLocationFilter.withoutLocation,
                        'Tanpa lokasi',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context, const ProductListFilter()),
                    child: const Text('Reset'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      ProductListFilter(
                        category: _category,
                        purchase: _purchase,
                        location: _location,
                      ),
                    ),
                    child: const Text('Terapkan filter'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationChip(ProductLocationFilter value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _location == value,
      onSelected: (_) => setState(() => _location = value),
    );
  }

  Widget _purchaseChip(ProductPurchaseFilter value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _purchase == value,
      onSelected: (_) => setState(() => _purchase = value),
    );
  }
}

String _purchaseDescription(ProductPurchaseFilter filter) {
  switch (filter) {
    case ProductPurchaseFilter.all:
      return 'Tampilkan semua produk.';
    case ProductPurchaseFilter.withoutBuyer:
      return 'Produk yang belum memiliki checklist pembeli.';
    case ProductPurchaseFilter.pending:
      return 'Produk dengan sebagian checklist yang belum selesai.';
    case ProductPurchaseFilter.purchased:
      return 'Produk dengan seluruh checklist pembeli sudah selesai.';
  }
}

class _FilterSectionLabel extends StatelessWidget {
  const _FilterSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}
