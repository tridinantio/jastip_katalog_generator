import 'package:flutter/material.dart';

import '../../domain/entities/trip.dart';

Future<CurrencyOption?> showCurrencyPickerSheet({
  required BuildContext context,
  required List<CurrencyOption> currencies,
  required String? selectedCurrencyCode,
}) {
  return showModalBottomSheet<CurrencyOption>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _CurrencyPickerSheet(
      currencies: currencies,
      selectedCurrencyCode: selectedCurrencyCode,
    ),
  );
}

class CurrencyPickerField extends StatelessWidget {
  const CurrencyPickerField({
    required this.currencies,
    required this.selectedCurrencyCode,
    required this.onSelected,
    this.labelText = 'Mata uang belanja',
    this.enabled = true,
    super.key,
  });

  final List<CurrencyOption> currencies;
  final String? selectedCurrencyCode;
  final ValueChanged<CurrencyOption> onSelected;
  final String labelText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final selected = _findCurrency(currencies, selectedCurrencyCode);
    return Semantics(
      button: true,
      enabled: enabled,
      label: labelText,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: !enabled
            ? null
            : () async {
                final picked = await showCurrencyPickerSheet(
                  context: context,
                  currencies: currencies,
                  selectedCurrencyCode: selectedCurrencyCode,
                );
                if (picked != null && context.mounted) onSelected(picked);
              },
        child: InputDecorator(
          isEmpty: selected == null,
          decoration: InputDecoration(
            labelText: labelText,
            enabled: enabled,
            suffixIcon: const Icon(Icons.expand_more),
          ),
          child: selected == null
              ? Text(
                  'Pilih mata uang',
                  style: Theme.of(context).inputDecorationTheme.hintStyle,
                )
              : Text(
                  '${selected.code} · ${selected.name}',
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ),
    );
  }
}

class _CurrencyPickerSheet extends StatefulWidget {
  const _CurrencyPickerSheet({
    required this.currencies,
    required this.selectedCurrencyCode,
  });

  final List<CurrencyOption> currencies;
  final String? selectedCurrencyCode;

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final visibleCurrencies = widget.currencies
        .where(
          (currency) =>
              query.isEmpty ||
              currency.code.toLowerCase().contains(query) ||
              currency.name.toLowerCase().contains(query) ||
              currency.symbol.toLowerCase().contains(query),
        )
        .toList(growable: false);
    final maxHeight = MediaQuery.sizeOf(context).height * .8;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Pilih mata uang',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Cari mata uang',
                  hintText: 'Kode, nama, atau simbol',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.tune),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: visibleCurrencies.isEmpty
                  ? Center(
                      child: Text(
                        'Mata uang tidak ditemukan.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                      itemCount: visibleCurrencies.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 2),
                      itemBuilder: (context, index) {
                        final currency = visibleCurrencies[index];
                        final selected =
                            currency.code == widget.selectedCurrencyCode;
                        return ListTile(
                          selected: selected,
                          selectedTileColor: Theme.of(context)
                              .colorScheme
                              .secondaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: Text(
                              currency.code,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          title: Text(currency.name),
                          subtitle: Text(
                            '${currency.code} · ${currency.symbol}',
                          ),
                          trailing: selected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () => Navigator.pop(context, currency),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

CurrencyOption? _findCurrency(List<CurrencyOption> currencies, String? code) {
  for (final currency in currencies) {
    if (currency.code == code) return currency;
  }
  return null;
}
