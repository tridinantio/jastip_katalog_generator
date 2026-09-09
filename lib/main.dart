import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/app_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  final dependencies = AppDependencies.create();
  await dependencies.tripRepository.ensureDefaultTrip();
  runApp(JastipApp(dependencies: dependencies));
}
