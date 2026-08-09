import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class LiquidLoadingOrb extends StatefulWidget {
  final String? customMessage;

  const LiquidLoadingOrb({super.key, this.customMessage});

  @override
  State<LiquidLoadingOrb> createState() => _LiquidLoadingOrbState();
}

class _LiquidLoadingOrbState extends State<LiquidLoadingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _messageIndex = 0;

  static const List<String> _loadingMessages = [
    'Analyzing financial patterns...',
    'Building liquid dashboards...',
    'Syncing encrypted Hive storage...',
    'Calculating budget limits...',
    'Preparing AI Insights...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _rotateMessages();
  }

  void _rotateMessages() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const SweepGradient(
                    colors: [
                      AppColors.primary,
                      Color(0xFF2563EB),
                      AppColors.secondary,
                      AppColors.primary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F172A),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            widget.customMessage ?? _loadingMessages[_messageIndex],
            key: ValueKey<int>(_messageIndex),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}
