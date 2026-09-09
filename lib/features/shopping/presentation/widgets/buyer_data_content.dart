import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/buyer_data_cubit.dart';

class BuyerDataContent extends StatelessWidget {
  const BuyerDataContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyerDataCubit, BuyerDataState>(
      builder: (context, state) {
        if (state.status == BuyerDataStatus.loading && state.buyers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == BuyerDataStatus.failure && state.buyers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(state.message ?? 'Data pembeli belum tersedia.'),
            ),
          );
        }
        if (state.buyers.isEmpty) return const _EmptyBuyerData();
        final totalPending = state.buyers.fold<int>(
          0,
          (sum, buyer) => sum + buyer.pendingItemCount,
        );
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          itemCount: state.buyers.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _BuyerHeader(
                buyerCount: state.buyers.length,
                pendingItemCount: totalPending,
              );
            }
            return _BuyerCard(buyer: state.buyers[index - 1]);
          },
        );
      },
    );
  }
}

class _BuyerHeader extends StatelessWidget {
  const _BuyerHeader({
    required this.buyerCount,
    required this.pendingItemCount,
  });

  final int buyerCount;
  final int pendingItemCount;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Data Pembeli',
        style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1),
      ),
      const SizedBox(height: 8),
      Text(
        '$buyerCount pembeli · $pendingItemCount item belum dibeli',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 8),
      Text(
        'Buka nama pembeli untuk melihat status setiap titipan.',
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ],
  );
}

class _BuyerCard extends StatelessWidget {
  const _BuyerCard({required this.buyer});

  final BuyerDataGroup buyer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: scheme.secondaryContainer,
          foregroundColor: scheme.onSecondaryContainer,
          child: const Icon(Icons.person_outline),
        ),
        title: Text(
          buyer.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${buyer.totalQuantity} pcs · ${buyer.items.length} titipan',
        ),
        trailing: _ProgressBadge(
          purchased: buyer.purchasedItemCount,
          pending: buyer.pendingItemCount,
        ),
        children: buyer.items
            .map((item) => _BuyerItemTile(item: item))
            .toList(growable: false),
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({required this.purchased, required this.pending});

  final int purchased;
  final int pending;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.check_circle, size: 17, color: Colors.green.shade700),
      const SizedBox(width: 2),
      Text('$purchased'),
      const SizedBox(width: 6),
      Icon(
        Icons.pending_outlined,
        size: 17,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 2),
      Text('$pending'),
    ],
  );
}

class _BuyerItemTile extends StatelessWidget {
  const _BuyerItemTile({required this.item});

  final BuyerDataItem item;

  @override
  Widget build(BuildContext context) {
    final purchased = item.request.isPurchased;
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: Icon(
        purchased ? Icons.check_circle : Icons.radio_button_unchecked,
        color: purchased ? Colors.green.shade700 : scheme.onSurfaceVariant,
      ),
      title: Text(
        item.productName,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          decoration: purchased ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        '${item.request.quantity} pcs${item.request.note.isEmpty ? '' : ' · ${item.request.note}'}',
      ),
      trailing: Text(
        purchased ? 'Terbeli' : 'Belum',
        style: TextStyle(
          color: purchased ? Colors.green.shade700 : scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyBuyerData extends StatelessWidget {
  const _EmptyBuyerData();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, size: 48),
          const SizedBox(height: 14),
          Text(
            'Belum ada data pembeli',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Tambahkan pembeli dari Detail Produk untuk melihat titipannya di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}
