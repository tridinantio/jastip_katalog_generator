import 'package:flutter/material.dart';

import '../../domain/entities/trip.dart';
import 'currency_picker_sheet.dart';

class TripCreateDraft {
  const TripCreateDraft({required this.name, required this.currency});

  final String name;
  final CurrencyOption currency;
}

class TripCreateDialog extends StatefulWidget {
  const TripCreateDialog({
    required this.currencies,
    required this.initialCurrencyCode,
    super.key,
  });

  final List<CurrencyOption> currencies;
  final String initialCurrencyCode;

  @override
  State<TripCreateDialog> createState() => _TripCreateDialogState();
}

class _TripCreateDialogState extends State<TripCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late String _selectedCurrencyCode;

  @override
  void initState() {
    super.initState();
    _selectedCurrencyCode = widget.initialCurrencyCode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Tambah trip'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama trip',
                hintText: 'Contoh: Korea Trip',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Nama trip wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            CurrencyPickerField(
              currencies: widget.currencies,
              selectedCurrencyCode: _selectedCurrencyCode,
              onSelected: (currency) =>
                  setState(() => _selectedCurrencyCode = currency.code),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(
              context,
              TripCreateDraft(
                name: _nameController.text.trim(),
                currency: widget.currencies.firstWhere(
                  (item) => item.code == _selectedCurrencyCode,
                ),
              ),
            );
          },
          child: const Text('Buat trip'),
        ),
      ],
    );
  }
}
