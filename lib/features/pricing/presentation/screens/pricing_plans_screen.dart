import 'package:flutter/material.dart';
import 'package:expense_tracker/core/design_system/quantum_tokens.dart';
import 'package:expense_tracker/core/design_system/quantum_glass_card.dart';
import 'package:expense_tracker/core/design_system/quantum_button.dart';

class PricingPlansScreen extends StatefulWidget {
  const PricingPlansScreen({super.key});

  @override
  State<PricingPlansScreen> createState() => _PricingPlansScreenState();
}

class _PricingPlansScreenState extends State<PricingPlansScreen> {
  bool _isAnnual = true;
  String _selectedPlan = 'Pro';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            'Supercharge Your Financial Intelligence',
            style: QuantumTypography.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Unlock real-time AI budget forecasting, unlimited custom goals, and multi-currency tracking.',
            style: QuantumTypography.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Billing Toggle Button Container
          QuantumGlassCard(
            material: QuantumGlassMaterial.sm,
            padding: const EdgeInsets.all(6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleOption('Monthly Billing', !_isAnnual, () => setState(() => _isAnnual = false)),
                _buildToggleOption('Annual Billing (Save 20%)', _isAnnual, () => setState(() => _isAnnual = true)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Pricing Tier Cards Row / Column
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 850;
              final cards = [
                _buildPlanCard(
                  name: 'Starter',
                  price: '₹0',
                  period: 'Forever free',
                  description: 'Basic expense tracking & standard category management.',
                  features: ['Up to 50 expenses/month', '3 Custom Savings Goals', 'Basic Budget Alerts', 'Standard Analytics'],
                  color: QuantumColors.mutedText,
                  isPopular: false,
                ),
                _buildPlanCard(
                  name: 'Pro FinPilot',
                  price: _isAnnual ? '₹249' : '₹299',
                  period: '/month billed ${_isAnnual ? 'annually' : 'monthly'}',
                  description: 'AI-powered expense engine, auto insights & unlimited goals.',
                  features: ['Unlimited Transactions', 'Unlimited Savings Goals', 'Real-time FinPilot AI Advisor', 'Debt & Income Tracker', 'CSV & PDF Data Export'],
                  color: QuantumColors.primaryAccent,
                  isPopular: true,
                ),
                _buildPlanCard(
                  name: 'Quantum Ultra',
                  price: _isAnnual ? '₹799' : '₹999',
                  period: '/month billed ${_isAnnual ? 'annually' : 'monthly'}',
                  description: 'Full multi-account sync, predictive AI & priority support.',
                  features: ['Everything in Pro Plan', 'Multi-Wallet & Family Sharing', 'Custom AI Prompt Engine', 'Automated Recurring Rules', 'Priority 24/7 Support'],
                  color: QuantumColors.violet,
                  isPopular: false,
                ),
              ];

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: c))).toList(),
                );
              }
              return Column(
                children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 20.0), child: c)).toList(),
              );
            },
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: QuantumMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? QuantumColors.primaryAccent : Colors.transparent,
          borderRadius: QuantumRadius.borderCapsule,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : QuantumColors.mutedText,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String name,
    required String price,
    required String period,
    required String description,
    required List<String> features,
    required Color color,
    required bool isPopular,
  }) {
    final isCurrent = _selectedPlan == name;

    return QuantumGlassCard(
      material: isPopular ? QuantumGlassMaterial.xl : QuantumGlassMaterial.md,
      borderColor: isPopular ? color : QuantumColors.glassBorder,
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
              child: Text(
                '★ MOST POPULAR',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 12),
          ],

          Text(name, style: QuantumTypography.headlineMedium),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color)),
              const SizedBox(width: 4),
              Text(period, style: QuantumTypography.caption),
            ],
          ),
          const SizedBox(height: 12),
          Text(description, style: QuantumTypography.bodyMedium),
          const SizedBox(height: 20),
          const Divider(color: QuantumColors.glassBorder),
          const SizedBox(height: 16),

          ...features.map((feat) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 16, color: color),
                    const SizedBox(width: 10),
                    Expanded(child: Text(feat, style: QuantumTypography.bodyLarge)),
                  ],
                ),
              )),
          const SizedBox(height: 24),

          Center(
            child: QuantumButton(
              label: isCurrent ? 'Active Plan' : 'Upgrade to $name',
              backgroundColor: isCurrent ? color : color.withValues(alpha: 0.8),
              onPressed: () {
                setState(() => _selectedPlan = name);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Switched plan to $name!')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
