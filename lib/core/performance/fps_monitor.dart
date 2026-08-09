import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FpsMonitor extends StatefulWidget {
  final Widget child;
  final bool showInRelease;

  const FpsMonitor({
    super.key,
    required this.child,
    this.showInRelease = false,
  });

  @override
  State<FpsMonitor> createState() => _FpsMonitorState();
}

class _FpsMonitorState extends State<FpsMonitor> {
  int _fps = 60;
  int _frameCount = 0;
  late DateTime _lastCalcTime;

  @override
  void initState() {
    super.initState();
    _lastCalcTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _onFrame(Duration timeStamp) {
    if (!mounted) return;

    _frameCount++;
    final now = DateTime.now();
    final diff = now.difference(_lastCalcTime).inMilliseconds;

    if (diff >= 1000) {
      setState(() {
        _fps = ((_frameCount * 1000) / diff).round();
      });
      _frameCount = 0;
      _lastCalcTime = now;
    }

    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
  }

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode && !widget.showInRelease) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 40,
          right: 12,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _fps >= 55 ? const Color(0xFF10B981) : Colors.amber),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _fps >= 55 ? const Color(0xFF10B981) : Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_fps FPS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
