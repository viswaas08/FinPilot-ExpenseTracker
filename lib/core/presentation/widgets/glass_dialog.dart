import 'package:flutter/material.dart';

abstract class GlassDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    double borderRadius = 20.0,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        final theme = Theme.of(ctx);
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null) ...[
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                letterSpacing: -0.4,
                                color: theme.colorScheme.onSurface,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                      ],
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutBack,
          ).value,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }
}
