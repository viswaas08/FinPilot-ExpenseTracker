import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/features/ai_insights/presentation/screens/ai_insights_screen.dart';
import 'package:expense_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:expense_tracker/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/login_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/register_screen.dart';
import 'package:expense_tracker/features/budget/presentation/screens/budget_dashboard_screen.dart';
import 'package:expense_tracker/features/categories/presentation/screens/category_management_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/expense_detail_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/expense_form_screen.dart';
import 'package:expense_tracker/features/navigation/presentation/screens/main_scaffold.dart';
import 'package:expense_tracker/features/notifications/presentation/screens/notification_center_screen.dart';
import 'package:expense_tracker/features/recurring/presentation/screens/recurring_dashboard_screen.dart';
import 'package:expense_tracker/features/savings_goals/presentation/screens/savings_goals_dashboard_screen.dart';
import 'package:expense_tracker/features/settings/presentation/screens/settings_dashboard_screen.dart';

import 'package:expense_tracker/features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'package:expense_tracker/features/income/presentation/screens/income_tracker_screen.dart';
import 'package:expense_tracker/features/pricing/presentation/screens/pricing_plans_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MainScaffold(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/categories',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CategoryManagementScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/ai-insights',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AIInsightsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/budget',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BudgetDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/savings-goals',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SavingsGoalsDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/recurring',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RecurringDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/pricing',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PricingPlansScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/analytics',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AnalyticsDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/income',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const IncomeTrackerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationCenterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/add-expense',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ExpenseFormScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/expense-detail/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: ExpenseDetailScreen(expenseId: id),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
    ],
  );
});
