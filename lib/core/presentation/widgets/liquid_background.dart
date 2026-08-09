import 'package:flutter/material.dart';
import 'ocean_mesh_background.dart';

class LiquidBackground extends StatelessWidget {
  final Widget child;

  const LiquidBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return OceanMeshBackground(
      child: child,
    );
  }
}

