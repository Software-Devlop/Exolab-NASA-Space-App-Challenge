import 'package:exolab/core/database/app_database.dart';
import 'package:exolab/core/database/database_factory_io.dart';
import 'package:exolab/core/statics/AppConstants.dart';
import 'package:exolab/core/theme/AppTheme.dart';
import 'package:exolab/features/llm/presentation/controllers/llmController.dart';
import 'package:exolab/features/main/presentation/pages/base/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// flutter run -d windows --enable-flutter-gpu
// give me suggestions that I can do to improve my mental health situation
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite.
  initDatabaseFactory();

  final database = AppDatabase();

  await database.database;

  debugPrint('Database initialized at: ${database.databasePath}');

  final container = ProviderContainer();

  try {
    await container.read(aiInitializationProvider.future);
  } catch (e) {
    debugPrint('AI initialization failed: $e');
  }

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const BaseScreen(),
    );
  }
}
