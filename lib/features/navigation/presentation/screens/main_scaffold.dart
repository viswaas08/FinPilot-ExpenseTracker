import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/features/dashboard/presentation/screens/personal_finance_dashboard_screen.dart';
import 'package:expense_tracker/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:expense_tracker/features/income/presentation/screens/income_tracker_screen.dart';
import 'package:expense_tracker/features/savings_goals/presentation/screens/savings_goals_dashboard_screen.dart';
import 'package:expense_tracker/features/budget/presentation/screens/budget_dashboard_screen.dart';
import 'package:expense_tracker/features/recurring/presentation/screens/recurring_dashboard_screen.dart';
import 'package:expense_tracker/features/categories/presentation/screens/category_management_screen.dart';
import 'package:expense_tracker/features/settings/presentation/screens/settings_dashboard_screen.dart';
import 'package:expense_tracker/features/notifications/presentation/screens/notification_center_screen.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget? child;

  const MainScaffold({super.key, this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    PersonalFinanceDashboardScreen(),
    AnalyticsScreen(),
    IncomeTrackerScreen(),
    SavingsGoalsDashboardScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showAllFeatureSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Financial Apps & Tools',
                style: AppTypography.screenTitle.copyWith(
                  fontSize: 18,
                  color: isDark ? AppColors.primaryText : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildHubTile(Icons.pie_chart_outline_rounded, 'Budgets', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetDashboardScreen()));
                  }),
                  _buildHubTile(Icons.repeat_rounded, 'Subscriptions', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RecurringDashboardScreen()));
                  }),
                  _buildHubTile(Icons.category_outlined, 'Categories', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryManagementScreen()));
                  }),
                  _buildHubTile(Icons.notifications_none_rounded, 'Alerts', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationCenterScreen()));
                  }),
                  _buildHubTile(Icons.settings_outlined, 'Settings', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsDashboardScreen()));
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHubTile(IconData icon, String title, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.card : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.primaryText : AppColors.lightTextPrimary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surface : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Text(
              'FinPilot',
              style: AppTypography.screenTitle.copyWith(
                fontSize: 18,
                color: isDark ? AppColors.primaryText : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.apps_rounded, size: 20),
            color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary,
            onPressed: _showAllFeatureSheet,
            tooltip: 'All Apps',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          final content = IndexedStack(
            index: _selectedIndex,
            children: _pages,
          );

          if (isDesktop) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: content,
              ),
            );
          }

          return content;
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        key: const Key('main_add_expense_fab'),
        onPressed: () => context.push('/add-expense'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
      ),
      bottomNavigationBar: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.border : AppColors.lightBorder,
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.grid_view_rounded, 'Overview'),
            _buildNavItem(1, Icons.analytics_outlined, 'Analytics'),
            _buildNavItem(2, Icons.account_balance_rounded, 'Income'),
            _buildNavItem(3, Icons.savings_outlined, 'Goals'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.mutedText : AppColors.lightTextMuted);

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
