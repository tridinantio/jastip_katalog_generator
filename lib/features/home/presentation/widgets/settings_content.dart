import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatters/app_formatters.dart';
import '../../../../core/widgets/atelier_widgets.dart';
import '../../../backup/presentation/cubit/backup_restore_cubit.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../../trip/presentation/cubit/active_trip_cubit.dart';
import '../../../trip/presentation/cubit/trip_export_cubit.dart';
import '../../../trip/presentation/widgets/trip_create_dialog.dart';
import '../../../trip/presentation/widgets/currency_picker_sheet.dart';

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _markupController = TextEditingController();
  final _fixedFeeController = TextEditingController();
  String? _initializedTripId;
  String? _selectedCurrencyCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ActiveTripCubit>().loadCurrencies();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _markupController.dispose();
    _fixedFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BackupRestoreCubit, BackupRestoreState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          (current.status == BackupRestoreStatus.success ||
              current.status == BackupRestoreStatus.failure),
      listener: (context, state) {
        final message = state.status == BackupRestoreStatus.success
            ? state.action == BackupRestoreAction.backup
                  ? 'Backup ${state.fileName} siap dibagikan.'
                  : 'Restore berhasil. Data aplikasi sudah dipulihkan.'
            : state.errorMessage ?? 'Proses backup gagal.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      },
      child: BlocListener<TripExportCubit, TripExportState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status != TripExportStatus.exporting &&
            current.status != TripExportStatus.idle,
        listener: (context, state) {
          final message = state.status == TripExportStatus.success
              ? 'File ${state.fileName} siap dibagikan.'
              : state.errorMessage!;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        },
        child: BlocConsumer<ActiveTripCubit, ActiveTripState>(
          listenWhen: (previous, current) =>
              previous.message != current.message && current.message != null,
          listener: (context, state) =>
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message!))),
          builder: (context, state) {
            final trip = state.trip;
            if (trip == null) {
              return const Center(child: CircularProgressIndicator());
            }
            _initializeControllers(trip);
            final currencies = _withCurrentCurrency(state.currencies, trip);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                AtelierHeading(
                  eyebrow: 'MAKE IT YOURS',
                  title: 'Pengaturan',
                  subtitle: 'Atur perjalanan, harga, dan ruang kerja Anda.',
                  trailing: IconButton(
                    tooltip: 'Lihat changelog aplikasi',
                    onPressed: () => _showChangelog(context),
                    icon: const Icon(Icons.info_outline),
                  ),
                ),
                const SizedBox(height: 24),
                _TripManagerCard(
                  state: state,
                  onCreate: () => _showCreateTrip(context, state),
                  onDelete: () => _confirmDeleteTrip(context, trip),
                ),
                const SizedBox(height: 12),
                _TripExportCard(trip: trip),
                const SizedBox(height: 12),
                _BackupRestoreCard(onRestore: () => _restoreBackup(context)),
                const SizedBox(height: 28),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('Nama trip'),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Nama trip wajib diisi'
                            : null,
                        decoration: const InputDecoration(
                          hintText: 'Japan Trip',
                        ),
                      ),
                      const SizedBox(height: 22),
                      const _SectionLabel('Mata uang belanja'),
                      CurrencyPickerField(
                        currencies: currencies,
                        selectedCurrencyCode:
                            _selectedCurrencyCode ?? trip.currencyCode,
                        enabled: !state.isManagingTrips,
                        onSelected: (currency) => setState(
                          () => _selectedCurrencyCode = currency.code,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _RateCard(
                        trip: trip,
                        state: state,
                        pendingCurrencyCode:
                            _selectedCurrencyCode == trip.currencyCode
                            ? null
                            : _selectedCurrencyCode,
                        onRefresh: () => _confirmRefreshRate(context),
                      ),
                      const SizedBox(height: 22),
                      const _SectionLabel('Markup'),
                      TextFormField(
                        controller: _markupController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                        ],
                        decoration: const InputDecoration(
                          suffixText: '%',
                          hintText: '15',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final parsed = double.tryParse(
                            value.replaceAll(',', '.'),
                          );
                          return parsed == null || parsed < 0
                              ? 'Markup tidak valid'
                              : null;
                        },
                      ),
                      if (_selectedCurrencyCode != trip.currencyCode)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Kurs ${_selectedCurrencyCode!} terbaru akan diambil saat pengaturan disimpan.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                      const SizedBox(height: 22),
                      const _SectionLabel('Biaya tetap per produk'),
                      TextFormField(
                        controller: _fixedFeeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(prefixText: 'Rp '),
                      ),
                      const SizedBox(height: 22),
                      const _SectionLabel('Pembulatan harga ke atas'),
                      DropdownButtonFormField<int>(
                        key: ValueKey('rounding-${trip.roundingUnitIdr}'),
                        initialValue: trip.roundingUnitIdr,
                        items: const [
                          DropdownMenuItem(value: 100, child: Text('Rp100')),
                          DropdownMenuItem(value: 500, child: Text('Rp500')),
                          DropdownMenuItem(value: 1000, child: Text('Rp1.000')),
                          DropdownMenuItem(value: 5000, child: Text('Rp5.000')),
                        ],
                        onChanged: (value) {
                          if (value != null) _roundingUnit = value;
                        },
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: state.isManagingTrips
                              ? null
                              : () => _confirmAndSave(context, currencies),
                          child: const Text('Simpan pengaturan'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Kurs disediakan oleh Frankfurter dari sumber institusional dan dapat berbeda dari kurs kartu atau money changer.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _restoreBackup(BuildContext context) async {
    final cubit = context.read<BackupRestoreCubit>();
    final candidate = await cubit.pickBackup();
    if (!context.mounted || candidate == null) return;
    final summary = candidate.summary;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore backup?'),
        content: Text(
          'Data lokal saat ini akan diganti dengan isi backup.\n\n'
          'Trip: ${summary.tripCount}\n'
          'Produk: ${summary.productCount}\n'
          'Checklist pembeli: ${summary.buyerRequestCount}\n'
          'Aset katalog: ${summary.generatedAssetCount}\n\n'
          'Tindakan ini tidak dapat dibatalkan dari aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (confirmed != true) {
      cubit.reset();
      return;
    }
    await cubit.restore(candidate);
  }

  Future<void> _showChangelog(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => const _ChangelogSheet(),
      );

  int _roundingUnit = 1000;

  void _initializeControllers(Trip trip) {
    if (_initializedTripId == trip.id) return;
    _initializedTripId = trip.id;
    _nameController.text = trip.name;
    _markupController.text = trip.markupPercent.toStringAsFixed(
      trip.markupPercent == trip.markupPercent.roundToDouble() ? 0 : 2,
    );
    _fixedFeeController.text = trip.fixedFeeIdr.toString();
    _roundingUnit = trip.roundingUnitIdr;
    _selectedCurrencyCode = trip.currencyCode;
  }

  Future<void> _confirmAndSave(
    BuildContext context,
    List<CurrencyOption> currencies,
  ) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final selectedCode = _selectedCurrencyCode;
    final currency = currencies.firstWhere((item) => item.code == selectedCode);
    final currencyChanged =
        currency.code !=
        context.read<ActiveTripCubit>().state.trip?.currencyCode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Simpan perubahan trip?'),
        content: Text(
          !currencyChanged
              ? 'Semua harga jual produk dalam trip ini akan dihitung ulang menggunakan pengaturan terbaru.'
              : 'Kurs ${currency.code} terbaru akan diambil, lalu semua harga jual produk dalam trip ini dihitung ulang.',
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
    if (confirmed != true || !context.mounted) return;
    final saved = await context.read<ActiveTripCubit>().saveSettings(
      name: _nameController.text,
      currency: currency,
      markupPercent: _markupController.text.trim().isEmpty
          ? 0
          : double.parse(_markupController.text.replaceAll(',', '.')),
      fixedFeeIdr: int.tryParse(_fixedFeeController.text) ?? 0,
      roundingUnitIdr: _roundingUnit,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Pengaturan tersimpan. Kurs ${currency.code} diperbarui.'
              : 'Gagal menyimpan.',
        ),
      ),
    );
  }

  Future<void> _showCreateTrip(
    BuildContext context,
    ActiveTripState state,
  ) async {
    final activeTrip = state.trip;
    if (activeTrip == null) return;
    final currencies = _withCurrentCurrency(state.currencies, activeTrip);
    if (currencies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daftar mata uang belum tersedia.')),
      );
      return;
    }

    final draft = await showDialog<TripCreateDraft>(
      context: context,
      builder: (_) => TripCreateDialog(
        currencies: currencies,
        initialCurrencyCode: activeTrip.currencyCode,
      ),
    );
    if (draft == null || !context.mounted) return;

    final created = await context.read<ActiveTripCubit>().createTrip(
      name: draft.name,
      currency: draft.currency,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(created ? 'Trip berhasil dibuat.' : 'Trip gagal dibuat.'),
      ),
    );
  }

  Future<void> _confirmDeleteTrip(BuildContext context, Trip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus trip?'),
        content: Text(
          '“${trip.name}” beserta seluruh produk, foto, dan gambar katalog di dalamnya akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus trip'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final deleted = await context.read<ActiveTripCubit>().deleteTrip(trip.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted ? 'Trip berhasil dihapus.' : 'Trip gagal dihapus.',
        ),
      ),
    );
  }

  Future<void> _confirmRefreshRate(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Perbarui kurs?'),
        content: const Text(
          'Kurs terbaru akan disimpan dan seluruh harga jual produk pada trip ini akan dihitung ulang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Perbarui'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ActiveTripCubit>().refreshRate();
    }
  }
}

class _ChangelogSheet extends StatelessWidget {
  const _ChangelogSheet();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Changelog',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Perubahan terbaru di Jastip Katalog',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              const _ChangelogEntry(
                version: 'Versi 1.0.0',
                date: '27 September 2026',
                changes: [
                  'Data pembeli pada detail produk kini dapat diedit.',
                  'Kurs trip dikunci saat dibuat dan hanya berubah melalui tindakan Perbarui kurs.',
                  'Rekap pembeli menampilkan total titipan dan status pembelian.',
                  'Backup, restore, dan export Excel tersedia untuk data trip.',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChangelogEntry extends StatelessWidget {
  const _ChangelogEntry({
    required this.version,
    required this.date,
    required this.changes,
  });

  final String version;
  final String date;
  final List<String> changes;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(version, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(
          date,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ...changes.map(
          (change) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 7),
                  child: Icon(Icons.circle, size: 6),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(change)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _TripManagerCard extends StatelessWidget {
  const _TripManagerCard({
    required this.state,
    required this.onCreate,
    required this.onDelete,
  });

  final ActiveTripState state;
  final VoidCallback onCreate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final activeTrip = state.trip!;
    final trips = state.trips.isEmpty ? [activeTrip] : state.trips;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip aktif',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              key: ValueKey('${activeTrip.id}-${trips.length}'),
              initialValue: activeTrip.id,
              isExpanded: true,
              items: trips
                  .map(
                    (trip) => DropdownMenuItem(
                      value: trip.id,
                      child: Text(trip.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(growable: false),
              onChanged: state.isManagingTrips
                  ? null
                  : (id) {
                      if (id != null) {
                        context.read<ActiveTripCubit>().selectTrip(id);
                      }
                    },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isManagingTrips ? null : onCreate,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah trip'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: trips.length <= 1
                      ? 'Trip terakhir tidak dapat dihapus'
                      : 'Hapus trip aktif',
                  onPressed: state.isManagingTrips || trips.length <= 1
                      ? null
                      : onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupRestoreCard extends StatelessWidget {
  const _BackupRestoreCard({required this.onRestore});

  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackupRestoreCubit, BackupRestoreState>(
      builder: (context, state) {
        final isCreating = state.status == BackupRestoreStatus.creating;
        final isPicking = state.status == BackupRestoreStatus.picking;
        final isRestoring = state.status == BackupRestoreStatus.restoring;
        final isBusy = state.isBusy;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Backup & restore',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Simpan atau pulihkan semua trip, produk, foto, buyer, dan checklist.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: isBusy
                            ? null
                            : () => context
                                  .read<BackupRestoreCubit>()
                                  .createBackup(),
                        icon: isCreating
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.backup_outlined),
                        label: Text(isCreating ? 'Menyiapkan...' : 'Backup'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isBusy ? null : onRestore,
                        icon: isPicking || isRestoring
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.restore),
                        label: Text(
                          isPicking
                              ? 'Memilih...'
                              : isRestoring
                              ? 'Memulihkan...'
                              : 'Restore',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TripExportCard extends StatelessWidget {
  const _TripExportCard({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripExportCubit, TripExportState>(
      builder: (context, state) {
        final isExporting = state.status == TripExportStatus.exporting;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Export trip',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Buat Excel dengan ringkasan, produk, foto thumbnail, dan daftar pembeli.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: isExporting
                        ? null
                        : () => context.read<TripExportCubit>().export(trip),
                    icon: isExporting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.table_view_outlined),
                    label: Text(
                      isExporting
                          ? 'Menyiapkan file Excel...'
                          : 'Export ke Excel',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}

class _RateCard extends StatelessWidget {
  const _RateCard({
    required this.trip,
    required this.state,
    this.pendingCurrencyCode,
    required this.onRefresh,
  });

  final Trip trip;
  final ActiveTripState state;
  final String? pendingCurrencyCode;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.sync, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pendingCurrencyCode != null
                      ? 'Kurs $pendingCurrencyCode akan diperbarui saat disimpan'
                      : trip.hasRate
                      ? '1 ${trip.currencyCode} = Rp${formatRate(trip.rateMicros)}'
                      : 'Kurs belum tersedia',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (pendingCurrencyCode == null && trip.rateDate != null)
                  Text(
                    '${state.isUsingCachedRate ? 'Cache · ' : ''}${formatShortDate(trip.rateDate!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Perbarui kurs',
            onPressed: state.isRefreshingRate ? null : onRefresh,
            icon: state.isRefreshingRate
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

List<CurrencyOption> _withCurrentCurrency(
  List<CurrencyOption> currencies,
  Trip trip,
) {
  if (currencies.any((item) => item.code == trip.currencyCode)) {
    return currencies;
  }
  return [
    CurrencyOption(
      code: trip.currencyCode,
      name: trip.currencyName,
      symbol: trip.currencySymbol,
    ),
    ...currencies,
  ];
}
