import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatters/app_formatters.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/atelier_widgets.dart';
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
      const AtelierHeading(
        eyebrow: 'PEOPLE & THEIR FINDS',
        title: 'Data Pembeli',
        subtitle: 'Setiap titipan, tercatat dengan baik.',
      ),
      const SizedBox(height: 22),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.sage,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$buyerCount',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const Text(
                    'pembeli dalam trip',
                    style: TextStyle(fontSize: 11, color: AppTheme.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 55,
              child: VerticalDivider(width: 32, color: Color(0xFFC4CEBB)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$pendingItemCount',
                    style: Theme.of(context).textTheme.headlineLarge
                        ?.copyWith(color: AppTheme.rust),
                  ),
                  const Text(
                    'item belum dibeli',
                    style: TextStyle(fontSize: 11, color: AppTheme.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      const Text(
        'Buka nama pembeli untuk melihat status setiap titipan.',
        style: TextStyle(fontSize: 12, color: AppTheme.muted),
      ),
      const SizedBox(height: 4),
    ],
  );
}

class _BuyerCard extends StatelessWidget {
  const _BuyerCard({required this.buyer});

  final BuyerDataGroup buyer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final totalAmountIdr = buyer.totalAmountIdr;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: scheme.secondaryContainer,
          foregroundColor: scheme.onSecondaryContainer,
          child: Text(
            buyer.name.trim().isEmpty
                ? '?'
                : buyer.name.trim().characters.first.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        title: Text(
          buyer.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${buyer.totalQuantity} pcs · ${buyer.items.length} titipan'),
            const SizedBox(height: 2),
            Text(
              totalAmountIdr == null
                  ? 'Total bayar tidak tersedia'
                  : 'Total bayar ${formatIdr(totalAmountIdr)}',
              style: const TextStyle(
                color: AppTheme.rust,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
  Widget build(BuildContext context) => const CustomScrollView(
    slivers: [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
        sliver: SliverToBoxAdapter(
          child: AtelierHeading(
            eyebrow: 'PEOPLE & THEIR FINDS',
            title: 'Data Pembeli',
            subtitle: 'Setiap titipan, tercatat dengan baik.',
          ),
        ),
      ),
      SliverFillRemaining(
        hasScrollBody: false,
        child: AtelierEmptyState(
          icon: Icons.people_outline,
          title: 'Belum ada data pembeli',
          message: 'Tambahkan pembeli dari Detail Produk untuk melihat titipannya di sini.',
        ),
      ),
    ],
  );
}
