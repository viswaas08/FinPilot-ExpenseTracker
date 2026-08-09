import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'radius.dart';

class QuantumDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const QuantumDialog({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => QuantumDialog(
        title: title,
        actions: actions,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget dialogContainer = Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: QuantumColors.surface.withValues(alpha: 0.95),
        borderRadius: QuantumRadius.borderXl,
        border: Border.all(
          color: QuantumColors.primaryAccent.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: QuantumColors.primaryAccent.withValues(alpha: 0.2),
            blurRadius: 36,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: QuantumColors.primaryText,
                  letterSpacing: -0.4,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: QuantumColors.mutedText, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(child: child),
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
          ],
        ],
      ),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: QuantumRadius.borderXl,
        child: kIsWeb
            ? dialogContainer
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: dialogContainer,
              ),
      ),
    );
  }
}
