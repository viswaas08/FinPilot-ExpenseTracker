import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HiveService {
  static const String expensesBoxName = 'expenses_box';
  static const String categoriesBoxName = 'categories_box';
  static const String authBoxName = 'auth_box';
  static const String aiInsightsBoxName = 'ai_insights_box';
  static const String budgetBoxName = 'budget_box';
  static const String recurringBoxName = 'recurring_box';
  static const String notificationsBoxName = 'notifications_box';
  static const String notificationSettingsBoxName = 'notification_settings_box';
  static const String settingsBoxName = 'settings_box';
  static const String savingsGoalsBoxName = 'savings_goals_box';
  static const String incomeBoxName = 'income_box';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(expensesBoxName);
    await Hive.openBox<Map>(categoriesBoxName);
    await Hive.openBox<Map>(authBoxName);
    await Hive.openBox<Map>(aiInsightsBoxName);
    await Hive.openBox<Map>(budgetBoxName);
    await Hive.openBox<Map>(recurringBoxName);
    await Hive.openBox<Map>(notificationsBoxName);
    await Hive.openBox<Map>(notificationSettingsBoxName);
    await Hive.openBox<Map>(settingsBoxName);
    await Hive.openBox<Map>(savingsGoalsBoxName);
    await Hive.openBox<Map>(incomeBoxName);
  }

  Box<Map> get _expensesBox => Hive.box<Map>(expensesBoxName);
  Box<Map> get _categoriesBox => Hive.box<Map>(categoriesBoxName);
  Box<Map> get _authBox => Hive.box<Map>(authBoxName);
  Box<Map> get _aiInsightsBox => Hive.box<Map>(aiInsightsBoxName);
  Box<Map> get _budgetBox => Hive.box<Map>(budgetBoxName);
  Box<Map> get _recurringBox => Hive.box<Map>(recurringBoxName);
  Box<Map> get _notificationsBox => Hive.box<Map>(notificationsBoxName);
  Box<Map> get _notificationSettingsBox => Hive.box<Map>(notificationSettingsBoxName);
  Box<Map> get _settingsBox => Hive.box<Map>(settingsBoxName);
  Box<Map> get _savingsGoalsBox => Hive.box<Map>(savingsGoalsBoxName);
  Box<Map> get _incomeBox => Hive.box<Map>(incomeBoxName);

  static Map<String, dynamic> _deepConvertMap(Map input) {
    final Map<String, dynamic> result = {};
    input.forEach((key, value) {
      final String stringKey = key.toString();
      result[stringKey] = _deepConvertValue(value);
    });
    return result;
  }

  static dynamic _deepConvertValue(dynamic value) {
    if (value is Map) {
      return _deepConvertMap(value);
    } else if (value is List) {
      return value.map((e) => _deepConvertValue(e)).toList();
    }
    return value;
  }

  // Expenses operations
  Future<void> saveExpense(String id, Map<String, dynamic> json) async {
    await _expensesBox.put(id, json);
  }

  Map<String, dynamic>? getExpense(String id) {
    final data = _expensesBox.get(id);
    if (data == null) return null;
    return _deepConvertMap(data);
  }

  List<Map<String, dynamic>> getAllExpenses() {
    return _expensesBox.values
        .map((e) => _deepConvertMap(e))
        .toList();
  }

  Future<void> deleteExpense(String id) async {
    await _expensesBox.delete(id);
  }

  Future<void> clearExpenses() async {
    await _expensesBox.clear();
  }

  // Categories operations
  Future<void> saveCategory(String id, Map<String, dynamic> json) async {
    await _categoriesBox.put(id, json);
  }

  List<Map<String, dynamic>> getAllCategories() {
    return _categoriesBox.values
        .map((e) => _deepConvertMap(e))
        .toList();
  }

  // Auth / Session operations
  Future<void> saveUserSession(Map<String, dynamic> userMap) async {
    await _authBox.put('current_user', userMap);
  }

  Map<String, dynamic>? getUserSession() {
    final data = _authBox.get('current_user');
    if (data == null) return null;
    return _deepConvertMap(data);
  }

  Future<void> clearUserSession() async {
    await _authBox.delete('current_user');
  }

  // AI Insights Caching operations
  Future<void> saveAIInsights(Map<String, dynamic> insightsMap) async {
    await _aiInsightsBox.put('cached_insights', insightsMap);
  }

  Map<String, dynamic>? getCachedAIInsights() {
    final data = _aiInsightsBox.get('cached_insights');
    if (data == null) return null;
    return _deepConvertMap(data);
  }

  Future<void> clearAIInsights() async {
    await _aiInsightsBox.delete('cached_insights');
  }

  // Budget Persistence operations
  Future<void> saveBudget(String monthYear, Map<String, dynamic> budgetMap) async {
    await _budgetBox.put(monthYear, budgetMap);
  }

  Map<String, dynamic>? getBudget(String monthYear) {
    final data = _budgetBox.get(monthYear);
    if (data == null) return null;
    return _deepConvertMap(data);
  }

  // Recurring Transactions Persistence operations
  Future<void> saveRecurringTransaction(String id, Map<String, dynamic> recurringMap) async {
    await _recurringBox.put(id, recurringMap);
  }

  List<Map<String, dynamic>> getAllRecurringTransactions() {
    return _recurringBox.values
        .map((e) => _deepConvertMap(e))
        .toList();
  }

  Future<void> deleteRecurringTransaction(String id) async {
    await _recurringBox.delete(id);
  }

  // Notifications operations
  Future<void> saveNotification(String id, Map<String, dynamic> jsonMap) async {
    await _notificationsBox.put(id, jsonMap);
  }

  List<Map<String, dynamic>> getAllNotifications() {
    return _notificationsBox.values
        .map((e) => _deepConvertMap(e))
        .toList();
  }

  Future<void> deleteNotification(String id) async {
    await _notificationsBox.delete(id);
  }

  Future<void> clearAllNotifications() async {
    await _notificationsBox.clear();
  }

  // Notification Settings operations
  Future<void> saveNotificationSettings(Map<String, dynamic> settingsMap) async {
    await _notificationSettingsBox.put('user_settings', settingsMap);
  }

  Map<String, dynamic>? getNotificationSettings() {
    final data = _notificationSettingsBox.get('user_settings');
    if (data == null) return null;
    return _deepConvertMap(data);
  }

  // User Preferences operations (Currency, Theme, Biometrics)
  Future<void> savePreferences(Map<String, dynamic> prefsMap) async {
    await _settingsBox.put('user_preferences', prefsMap);
  }

  Map<String, dynamic>? getPreferences() {
    final data = _settingsBox.get('user_preferences');
    if (data == null) return null;
    return _deepConvertMap(data);
  }

  // Savings Goals operations
  Future<void> saveSavingsGoal(String id, Map<String, dynamic> jsonMap) async {
    await _savingsGoalsBox.put(id, jsonMap);
  }

  List<Map<String, dynamic>> getAllSavingsGoals() {
    return _savingsGoalsBox.values
        .map((e) => _deepConvertMap(e))
        .toList();
  }

  Future<void> deleteSavingsGoal(String id) async {
    await _savingsGoalsBox.delete(id);
  }

  // Income Tracker operations
  Future<void> saveIncome(String id, Map<String, dynamic> jsonMap) async {
    await _incomeBox.put(id, jsonMap);
  }

  List<Map<String, dynamic>> getAllIncome() {
    return _incomeBox.values
        .map((e) => _deepConvertMap(e))
        .toList();
  }

  Future<void> deleteIncome(String id) async {
    await _incomeBox.delete(id);
  }
}

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});
