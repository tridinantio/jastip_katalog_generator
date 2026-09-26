import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/unfocus_on_tap.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import 'app_dependencies.dart';

class JastipApp extends StatelessWidget {
  const JastipApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: dependencies.tripRepository),
        RepositoryProvider.value(value: dependencies.exchangeRateRepository),
        RepositoryProvider.value(value: dependencies.productRepository),
        RepositoryProvider.value(value: dependencies.imagePicker),
        RepositoryProvider.value(value: dependencies.locationService),
        RepositoryProvider.value(value: dependencies.catalogExportService),
        RepositoryProvider.value(value: dependencies.tripExportService),
        RepositoryProvider.value(value: dependencies.shoppingRepository),
        RepositoryProvider.value(value: dependencies.backupRestoreService),
      ],
      child: MaterialApp(
        title: 'Jastip Katalog',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashPage(nextPage: HomePage()),
        builder: (context, child) =>
            UnfocusOnTap(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
