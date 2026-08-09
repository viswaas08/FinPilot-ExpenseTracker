import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/presentation/widgets/glass_container.dart';
import 'package:expense_tracker/core/presentation/widgets/glass_dialog.dart';
import 'package:expense_tracker/core/presentation/widgets/ocean_mesh_background.dart';
import 'package:expense_tracker/core/presentation/widgets/primary_button.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

import 'package:expense_tracker/features/ai_insights/presentation/screens/ai_insights_screen.dart';
import 'package:expense_tracker/features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'package:expense_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:expense_tracker/features/budget/presentation/screens/budget_dashboard_screen.dart';
import 'package:expense_tracker/features/categories/presentation/screens/category_management_screen.dart';
import 'package:expense_tracker/features/dashboard/presentation/screens/personal_finance_dashboard_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:expense_tracker/features/income/presentation/screens/income_tracker_screen.dart';
import 'package:expense_tracker/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:expense_tracker/features/notifications/presentation/screens/notification_center_screen.dart';
import 'package:expense_tracker/features/pricing/presentation/screens/pricing_plans_screen.dart';
import 'package:expense_tracker/features/recurring/presentation/screens/recurring_dashboard_screen.dart';
import 'package:expense_tracker/features/savings_goals/presentation/screens/savings_goals_dashboard_screen.dart';
import 'package:expense_tracker/features/settings/presentation/controllers/settings_controller.dart';
import 'package:expense_tracker/features/settings/presentation/screens/settings_dashboard_screen.dart';
import 'package:expense_tracker/core/design_system/quantum_sidebar.dart';
import 'package:expense_tracker/core/theme/theme_provider.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final int initialTab;

  const MainScaffold({super.key, this.initialTab = 0});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  final List<Widget> _screens = const [
    PersonalFinanceDashboardScreen(),
    PricingPlansScreen(),
    RecurringDashboardScreen(),
    SavingsGoalsDashboardScreen(),
    AIInsightsScreen(),
    IncomeTrackerScreen(),
    ExpenseListScreen(),
    CategoryManagementScreen(),
    BudgetDashboardScreen(),
    AnalyticsDashboardScreen(),
    SettingsDashboardScreen(),
    NotificationCenterScreen(),
    _ProfileTabScreen(),
  ];

  final List<_DesktopNavItemData> _navItems = const [
    _DesktopNavItemData(icon: Icons.grid_view_outlined, selectedIcon: Icons.grid_view_rounded, label: 'Dashboard', route: ''),
    _DesktopNavItemData(icon: Icons.credit_card_outlined, selectedIcon: Icons.credit_card_rounded, label: 'Pricing & Plans', route: '/pricing'),
    _DesktopNavItemData(icon: Icons.history_toggle_off_rounded, selectedIcon: Icons.history_toggle_off_rounded, label: 'Recurring', route: '/recurring'),
    _DesktopNavItemData(icon: Icons.savings_outlined, selectedIcon: Icons.savings_rounded, label: 'Savings Goals', route: '/savings-goals'),
    _DesktopNavItemData(icon: Icons.smart_toy_outlined, selectedIcon: Icons.smart_toy_rounded, label: 'AI Advisor', route: '/ai-insights'),
    _DesktopNavItemData(icon: Icons.trending_up_rounded, selectedIcon: Icons.trending_up_rounded, label: 'Income', route: '/income'),
    _DesktopNavItemData(icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long_rounded, label: 'Expenses', route: '/home'),
    _DesktopNavItemData(icon: Icons.category_outlined, selectedIcon: Icons.category_rounded, label: 'Categories', route: '/categories'),
    _DesktopNavItemData(icon: Icons.account_balance_wallet_outlined, selectedIcon: Icons.account_balance_wallet_rounded, label: 'Budgets', route: '/budget'),
    _DesktopNavItemData(icon: Icons.show_chart_rounded, selectedIcon: Icons.show_chart_rounded, label: 'Analytics', route: '/analytics'),
    _DesktopNavItemData(icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded, label: 'Settings', route: '/settings'),
    _DesktopNavItemData(icon: Icons.notifications_none_rounded, selectedIcon: Icons.notifications_rounded, label: 'Notification Settings', route: '/notifications'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    if (isDesktop) {
      final authState = ref.watch(authControllerProvider);
      final userName = authState.user?.displayName ?? 'Viswaa S';
      final userEmail = authState.user?.email ?? 'viswaas08@gmail.com';

      final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
      final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
      final sidebarBorder = isDark ? const Color(0xFF1E293B) : AppColors.lightBorder;

      final quantumNavItems = _navItems.map((item) {
        return QuantumSidebarItem(
          icon: item.icon,
          selectedIcon: item.selectedIcon,
          label: item.label,
          route: item.route,
        );
      }).toList();

      return OceanMeshBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Row(
            children: [
              QuantumSidebar(
                items: quantumNavItems,
                selectedIndex: _currentIndex,
                onItemSelected: (index) {
                  setState(() => _currentIndex = index);
                },
                onProfileTap: () {
                  setState(() => _currentIndex = 12);
                },
                userName: userName,
                userEmail: userEmail,
              ),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // FinPilot AI Top Header Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.8),
                      border: Border(bottom: BorderSide(color: sidebarBorder.withValues(alpha: 0.5))),
                    ),
                    child: Row(
                      children: [
                        // Left Breadcrumb
                        Row(
                          children: [
                            Text(
                              'FINPILOT AI',
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text('  /  ', style: TextStyle(color: subTextColor.withValues(alpha: 0.4))),
                            Text(
                              _currentIndex < _navItems.length
                                  ? _navItems[_currentIndex].label
                                  : 'Profile',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Center Search Bar
                        Container(
                          width: 320,
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded, size: 16, color: subTextColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Search transactions or AI insights... (Ctrl+K)',
                                  style: TextStyle(fontSize: 12, color: subTextColor),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Bell Icon
                        IconButton(
                          onPressed: () => context.push('/notifications'),
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(Icons.notifications_none_rounded, size: 19, color: textColor),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF3B82F6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Theme Toggle
                        Consumer(
                          builder: (context, ref, _) {
                            return IconButton(
                              onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
                              icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined, size: 18, color: textColor),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        // User Profile Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: const Color(0xFF2563EB),
                                child: Text(
                                  userName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(userName, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: subTextColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main View Stack
                  Expanded(
                    child: KeyedSubtree(
                      key: ValueKey<int>(_currentIndex),
                      child: _screens[_currentIndex < _screens.length ? _currentIndex : 0],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    }

    // Mobile Viewport Layout
    final mobileNavBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final mobileNavBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return OceanMeshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'FinPilot AI',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'All Features Hub',
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.apps_rounded, color: AppColors.primary, size: 20),
              ),
              onPressed: () => _showFeatureHubSheet(context),
            ),
            IconButton(
              tooltip: 'Toggle Theme',
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: textColor,
                size: 20,
              ),
              onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex < _screens.length ? _currentIndex : 0],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 70.0, right: 6.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              heroTag: 'main_add_expense_fab',
              onPressed: () => context.push('/add-expense'),
              elevation: 0,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
              label: const Text(
                'Add Entry',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: mobileNavBg,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: mobileNavBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    isSelected: _currentIndex == 0,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                  _NavItem(
                    icon: Icons.receipt_long_outlined,
                    selectedIcon: Icons.receipt_long_rounded,
                    label: 'Expenses',
                    isSelected: _currentIndex == 6,
                    onTap: () => setState(() => _currentIndex = 6),
                  ),
                  _NavItem(
                    icon: Icons.auto_awesome_outlined,
                    selectedIcon: Icons.auto_awesome_rounded,
                    label: 'AI Insights',
                    isSelected: _currentIndex == 4,
                    onTap: () => setState(() => _currentIndex = 4),
                  ),
                  _NavItem(
                    icon: Icons.pie_chart_outline_rounded,
                    selectedIcon: Icons.pie_chart_rounded,
                    label: 'Analytics',
                    isSelected: _currentIndex == 9,
                    onTap: () => setState(() => _currentIndex = 9),
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    label: 'Profile',
                    isSelected: _currentIndex == 12,
                    onTap: () => setState(() => _currentIndex = 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFeatureHubSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final featureItems = [
      {'icon': Icons.grid_view_rounded, 'label': 'Dashboard', 'index': 0, 'color': const Color(0xFF3B82F6)},
      {'icon': Icons.trending_up_rounded, 'label': 'Income Stream', 'index': 5, 'color': const Color(0xFF10B981)},
      {'icon': Icons.savings_rounded, 'label': 'Savings Goals', 'index': 3, 'color': const Color(0xFFA855F7)},
      {'icon': Icons.account_balance_wallet_rounded, 'label': 'Budgets', 'index': 8, 'color': const Color(0xFFF59E0B)},
      {'icon': Icons.show_chart_rounded, 'label': 'Analytics', 'index': 9, 'color': const Color(0xFF06B6D4)},
      {'icon': Icons.history_toggle_off_rounded, 'label': 'Recurring Bills', 'index': 2, 'color': const Color(0xFFEC4899)},
      {'icon': Icons.smart_toy_rounded, 'label': 'AI Advisor', 'index': 4, 'color': const Color(0xFF8B5CF6)},
      {'icon': Icons.category_rounded, 'label': 'Categories', 'index': 7, 'color': const Color(0xFF14B8A6)},
      {'icon': Icons.receipt_long_rounded, 'label': 'Expenses', 'index': 6, 'color': const Color(0xFFEF4444)},
      {'icon': Icons.settings_rounded, 'label': 'Settings', 'index': 10, 'color': const Color(0xFF64748B)},
      {'icon': Icons.notifications_rounded, 'label': 'Notifications', 'index': 11, 'color': const Color(0xFFF97316)},
      {'icon': Icons.diamond_rounded, 'label': 'Pricing Plans', 'index': 1, 'color': const Color(0xFF3B82F6)},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Feature Apps',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: textColor),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: featureItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (ctx, idx) {
                    final item = featureItems[idx];
                    final tileColor = item['color'] as Color;

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        setState(() => _currentIndex = item['index'] as int);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: tileColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: tileColor.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item['icon'] as IconData, color: tileColor, size: 24),
                            const SizedBox(height: 6),
                            Text(
                              item['label'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }
}

class _DesktopNavItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _DesktopNavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.route = '',
  });
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected
                  ? AppColors.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileTabScreen extends ConsumerWidget {
  const _ProfileTabScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final notificationState = ref.watch(notificationControllerProvider);
    final settingsState = ref.watch(settingsControllerProvider);

    final theme = Theme.of(context);
    final user = authState.user;
    final prefs = settingsState.preferences;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                (user?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'Alex',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'alex@expensetracker.app',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 28),

            GlassContainer(
              borderRadius: 32.0,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: Color(0xFF10B981)),
                    title: const Text('Settings & Preferences', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Currency: ${prefs.currencySymbol} (${prefs.currencyCode})'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/settings'),
                  ),
                  const Divider(height: 16),
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined, color: Color(0xFF06B6D4)),
                    title: const Text('Notification Center', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${notificationState.unreadCount} unread alerts'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/notifications'),
                  ),
                  const Divider(height: 16),
                  ListTile(
                    leading: const Icon(Icons.autorenew_rounded, color: Color(0xFF8B5CF6)),
                    title: const Text('Recurring Transactions', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Subscriptions & Scheduled Bills'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/recurring'),
                  ),
                  const Divider(height: 16),
                  ListTile(
                    leading: const Icon(Icons.savings_outlined, color: Color(0xFF2563EB)),
                    title: const Text('Savings Goals', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Track target goals, deposits & progress'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/savings-goals'),
                  ),
                  const Divider(height: 16),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF10B981)),
                    title: const Text('Smart Budget System', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Monthly Limits & Health Score'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/budget'),
                  ),
                  const Divider(height: 16),
                  ListTile(
                    leading: const Icon(Icons.auto_awesome_outlined, color: Color(0xFF06B6D4)),
                    title: const Text('Gemini AI Engine', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('AI Financial Score & Predictions'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/ai-insights'),
                  ),
                  const Divider(height: 16),
                  ListTile(
                    leading: const Icon(Icons.category_outlined, color: Color(0xFF8B5CF6)),
                    title: const Text('Manage Categories', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Custom icons, colors & budget limits'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/categories'),
                  ),
                  const Divider(height: 16),
                  ListTile(
                    leading: const Icon(Icons.security_outlined, color: AppColors.primary),
                    title: const Text('Security & Data Privacy', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Hive Encryption & Firebase Auth'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      GlassDialog.show(
                        context: context,
                        title: 'Security & Privacy',
                        child: Column(
                          children: [
                            const Text(
                              'Your financial records are encrypted locally using Hive boxes and synchronized via Google Firebase Cloud Infrastructure with zero-knowledge token standards.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, height: 1.4),
                            ),
                            const SizedBox(height: 20),
                            PrimaryButton(
                              label: 'Got it',
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 16),
                  ListTile(
                    leading: const Icon(Icons.cloud_sync_outlined, color: AppColors.secondary),
                    title: const Text('Cloud Data Sync', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Firestore Offline Synchronization'),
                    trailing: const Icon(Icons.check_circle, color: AppColors.secondary, size: 20),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            PrimaryButton(
              label: 'Sign Out',
              icon: Icons.logout_rounded,
              backgroundColor: AppColors.expense,
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
