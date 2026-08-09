class QuantumGlassMaterial {
  final double sigma;
  final double opacity;
  final double borderOpacity;
  final double reflectionOpacity;
  final double shadowBlur;

  const QuantumGlassMaterial({
    required this.sigma,
    required this.opacity,
    required this.borderOpacity,
    required this.reflectionOpacity,
    required this.shadowBlur,
  });

  static const QuantumGlassMaterial xs = QuantumGlassMaterial(
    sigma: 8.0,
    opacity: 0.03,
    borderOpacity: 0.04,
    reflectionOpacity: 0.08,
    shadowBlur: 10.0,
  );

  static const QuantumGlassMaterial sm = QuantumGlassMaterial(
    sigma: 14.0,
    opacity: 0.05,
    borderOpacity: 0.06,
    reflectionOpacity: 0.12,
    shadowBlur: 16.0,
  );

  static const QuantumGlassMaterial md = QuantumGlassMaterial(
    sigma: 20.0,
    opacity: 0.08,
    borderOpacity: 0.10,
    reflectionOpacity: 0.18,
    shadowBlur: 24.0,
  );

  static const QuantumGlassMaterial lg = QuantumGlassMaterial(
    sigma: 28.0,
    opacity: 0.12,
    borderOpacity: 0.14,
    reflectionOpacity: 0.24,
    shadowBlur: 36.0,
  );

  static const QuantumGlassMaterial xl = QuantumGlassMaterial(
    sigma: 40.0,
    opacity: 0.16,
    borderOpacity: 0.18,
    reflectionOpacity: 0.32,
    shadowBlur: 48.0,
  );
}
