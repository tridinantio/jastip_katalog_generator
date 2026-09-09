import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/double_back_exit_scope.dart';
import '../../../backup/presentation/cubit/backup_restore_cubit.dart';
import '../../../backup/domain/services/backup_restore_service.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../product/presentation/cubit/product_list_cubit.dart';
import '../../../trip/domain/repositories/trip_repository.dart';
import '../../../trip/presentation/cubit/active_trip_cubit.dart';
import '../../../trip/presentation/cubit/trip_export_cubit.dart';
import '../../../trip/domain/services/trip_export_service.dart';
import '../../../shopping/domain/repositories/shopping_repository.dart';
import '../../../shopping/presentation/cubit/buyer_data_cubit.dart';
import '../../../shopping/presentation/cubit/shopping_summary_cubit.dart';
import '../../../shopping/presentation/widgets/buyer_data_content.dart';
import '../widgets/home_content.dart';
import '../widgets/products_content.dart';
import '../widgets/settings_content.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ActiveTripCubit(
            context.read<TripRepository>(),
            context.read<ExchangeRateRepository>(),
          )..initialize(),
        ),
        BlocProvider(
          create: (context) => ProductListCubit(
            context.read<ProductRepository>(),
            context.read<ShoppingRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => ShoppingSummaryCubit(
            context.read<ProductRepository>(),
            context.read<ShoppingRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              TripExportCubit(context.read<TripExportService>()),
        ),
        BlocProvider(
          create: (context) =>
              BackupRestoreCubit(context.read<BackupRestoreService>()),
        ),
        BlocProvider(
          create: (context) => BuyerDataCubit(
            context.read<ProductRepository>(),
            context.read<ShoppingRepository>(),
          ),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActiveTripCubit, ActiveTripState>(
      listenWhen: (previous, current) => previous.trip != current.trip,
      listener: (context, state) {
        final trip = state.trip;
        if (trip == null) return;
        context.read<ProductListCubit>().watchTrip(trip.id);
        context.read<ShoppingSummaryCubit>().watchTrip(trip);
        context.read<BuyerDataCubit>().watchTrip(trip.id);
      },
      child: DoubleBackExitScope(
        child: Scaffold(
          body: SafeArea(
            child: IndexedStack(
              index: _index,
              children: const [
                HomeContent(),
                BuyerDataContent(),
                ProductsContent(),
                SettingsContent(),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Trip',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Pembeli',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: 'Produk',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined),
                selectedIcon: Icon(Icons.tune),
                label: 'Pengaturan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
