import 'package:flutter/widgets.dart';

class PerformanceManager {
  static final PerformanceManager _instance = PerformanceManager._internal();
  factory PerformanceManager() => _instance;
  PerformanceManager._internal();

  void init() {
    WidgetsBinding.instance.addObserver(_LifecycleObserver());
  }

  void trimMemory() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}

class _LifecycleObserver extends WidgetsBindingObserver {
  @override
  void didHaveMemoryPressure() {
    PerformanceManager().trimMemory();
  }
}
