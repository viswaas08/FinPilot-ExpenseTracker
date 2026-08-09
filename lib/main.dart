import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/firebase/firebase_service.dart';
import 'core/performance/cache_manager.dart';
import 'core/performance/fps_monitor.dart';
import 'core/performance/startup_optimizer.dart';
import 'core/storage/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'routing/app_router.dart';

void main() async {
  final hiveService = await StartupOptimizer.initialize();
  CacheManager.configureImageCache();

  // Initialize Firebase Service
  final firebaseService = FirebaseService();
  await firebaseService.init();

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
        firebaseServiceProvider.overrideWithValue(firebaseService),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return FpsMonitor(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
