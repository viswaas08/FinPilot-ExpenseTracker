import 'package:flutter/widgets.dart';
import 'package:expense_tracker/core/performance/performance_manager.dart';
import 'package:expense_tracker/core/storage/hive_service.dart';

abstract class StartupOptimizer {
  static Future<HiveService> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    final hiveService = HiveService();

    // Parallel deferred initialization
    await Future.wait([
      hiveService.init(),
      Future.microtask(() => PerformanceManager().init()),
    ]);

    return hiveService;
  }
}
