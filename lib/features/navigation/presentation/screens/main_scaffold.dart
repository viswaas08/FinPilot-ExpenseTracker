import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/theme_provider.dart';
import 'package:expense_tracker/features/dashboard/presentation/screens/personal_finance_dashboard_screen.dart';
import 'package:expense_tracker/features/google_sheets/presentation/screens/google_sheets_screen.dart';
import 'package:expense_tracker/features/google_sheets/presentation/controllers/google_sheets_controller.dart';
import 'package:expense_tracker/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:expense_tracker/features/income/presentation/screens/income_tracker_screen.dart';
import 'package:expense_tracker/features/budget/presentation/screens/budget_dashboard_screen.dart';
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
    GoogleSheetsScreen(),
    AnalyticsScreen(),
    IncomeTrackerScreen(),
    BudgetDashboardScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = const [
    {'title': 'Dashboard', 'icon': Icons.dashboard_rounded},
    {'title': 'Google Sheets', 'icon': Icons.table_chart_rounded, 'badge': 'SHEETS'},
    {'title': 'Analytics', 'icon': Icons.insights_rounded},
    {'title': 'Income & Accounts', 'icon': Icons.account_balance_wallet_rounded},
    {'title': 'Budgets & Goals', 'icon': Icons.pie_chart_rounded},
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetsState = ref.watch(googleSheetsControllerProvider);
    final sheetsController = ref.read(googleSheetsControllerProvider.notifier);

    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        return Scaffold(
          backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
          // Desktop / Web Top Navbar
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(isDesktop ? 68 : 58),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.border : AppColors.lightBorder,
                    width: 1.0,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
              child: SafeArea(
                child: Row(
                  children: [
                    // Brand Logo & Title
                    InkWell(
                      onTap: () => _onItemTapped(0),
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.bluePrimary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'FinPilot',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.elevatedSurface : AppColors.blueSoft,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'PRO',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.bluePrimary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                'FINANCIAL OS & SHEETS',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blueLight,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Center Navigation Links for Desktop
                    if (isDesktop) ...[
                      const SizedBox(width: 32),
                      Expanded(
                        child: Row(
                          children: List.generate(_navItems.length, (index) {
                            final item = _navItems[index];
                            final isSelected = _selectedIndex == index;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: InkWell(
                                onTap: () => _onItemTapped(index),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark ? AppColors.elevatedSurface : AppColors.blueSoft)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.bluePrimary.withValues(alpha: 0.3)
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item['icon'] as IconData,
                                        size: 17,
                                        color: isSelected
                                            ? AppColors.bluePrimary
                                            : subTextColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item['title'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isSelected
                                              ? (isDark ? Colors.white : AppColors.bluePrimary)
                                              : subTextColor,
                                        ),
                                      ),
                                      if (item.containsKey('badge')) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.bluePrimary,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item['badge'] as String,
                                            style: const TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ] else
                      const Spacer(),

                    // Right Actions
                    // 1. Google Sheets Sync Status Button
                    InkWell(
                      onTap: () {
                        if (_selectedIndex != 1) {
                          _onItemTapped(1);
                        } else {
                          sheetsController.syncNow();
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.elevatedSurface : AppColors.blueSoft,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.bluePrimary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: sheetsState.config.isConnected
                                    ? AppColors.income
                                    : AppColors.bluePrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isDesktop
                                  ? (sheetsState.isSyncing
                                      ? 'Syncing Sheets...'
                                      : (sheetsState.config.isConnected ? 'Sheets Synced' : 'Link Sheets'))
                                  : 'Sheets',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.bluePrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 2. Add Expense Quick Button
                    ElevatedButton.icon(
                      onPressed: () => context.push('/add-expense'),
                      icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                      label: Text(
                        isDesktop ? 'Add Expense' : 'Add',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bluePrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 14 : 10,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 3. Theme Toggle Button
                    IconButton(
                      tooltip: 'Toggle Theme',
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        size: 20,
                        color: subTextColor,
                      ),
                      onPressed: () {
                        ref.read(themeProvider.notifier).toggleTheme();
                      },
                    ),

                    // 4. Notifications / Alerts
                    IconButton(
                      tooltip: 'Notifications',
                      icon: const Icon(Icons.notifications_none_rounded, size: 20),
                      color: subTextColor,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
                        );
                      },
                    ),

                    // 5. Settings
                    IconButton(
                      tooltip: 'Settings',
                      icon: const Icon(Icons.settings_outlined, size: 20),
                      color: subTextColor,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsDashboardScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, contentConstraints) {
              final content = IndexedStack(
                index: _selectedIndex,
                children: _pages,
              );

              if (isDesktop) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1300),
                    child: content,
                  ),
                );
              }

              return content;
            },
          ),
          // Bottom Navigation for Mobile / Narrow screens only
          bottomNavigationBar: isDesktop
              ? null
              : Container(
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
                    children: List.generate(_navItems.length, (index) {
                      final item = _navItems[index];
                      final isSelected = _selectedIndex == index;
                      final color = isSelected
                          ? AppColors.bluePrimary
                          : (isDark ? AppColors.mutedText : AppColors.lightTextMuted);

                      return InkWell(
                        onTap: () => _onItemTapped(index),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item['icon'] as IconData, size: 20, color: color),
                              const SizedBox(height: 3),
                              Text(
                                item['title'] == 'Google Sheets'
                                    ? 'Sheets'
                                    : (item['title'] == 'Income & Accounts'
                                        ? 'Income'
                                        : (item['title'] == 'Budgets & Goals'
                                            ? 'Budgets'
                                            : item['title'] as String)),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
        );
      },
    );
  }
}
