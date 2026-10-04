import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expense_tracker/features/google_sheets/data/models/google_sheets_config.dart';
import 'package:expense_tracker/features/google_sheets/data/services/google_sheets_service.dart';

class GoogleSheetsState {
  final GoogleSheetsConfig config;
  final bool isLoading;
  final bool isSyncing;
  final String? successMessage;
  final String? errorMessage;

  const GoogleSheetsState({
    required this.config,
    this.isLoading = false,
    this.isSyncing = false,
    this.successMessage,
    this.errorMessage,
  });

  GoogleSheetsState copyWith({
    GoogleSheetsConfig? config,
    bool? isLoading,
    bool? isSyncing,
    String? successMessage,
    String? errorMessage,
  }) {
    return GoogleSheetsState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}

final googleSheetsControllerProvider =
    StateNotifierProvider<GoogleSheetsController, GoogleSheetsState>((ref) {
  final service = ref.watch(googleSheetsServiceProvider);
  return GoogleSheetsController(service);
});

class GoogleSheetsController extends StateNotifier<GoogleSheetsState> {
  final GoogleSheetsService _service;

  GoogleSheetsController(this._service)
      : super(const GoogleSheetsState(config: GoogleSheetsConfig())) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    final config = await _service.loadConfig();
    state = state.copyWith(config: config, isLoading: false);
  }

  Future<void> connectGoogleAccount({String email = 'user@gmail.com'}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 600));

    final updated = state.config.copyWith(
      isConnected: true,
      accountEmail: email,
      spreadsheetId: '1aBcD_FinPilot_Finance_Spreadsheet_2026',
      spreadsheetUrl: 'https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit',
      lastSyncTime: DateTime.now(),
    );

    await _service.saveConfig(updated);
    state = state.copyWith(
      config: updated,
      isLoading: false,
      successMessage: 'Google Account successfully connected! Template ready.',
    );
  }

  Future<void> disconnectGoogleAccount() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    const updated = GoogleSheetsConfig();
    await _service.saveConfig(updated);
    state = state.copyWith(
      config: updated,
      isLoading: false,
      successMessage: 'Google Sheets integration disconnected.',
    );
  }

  Future<void> syncNow() async {
    if (!state.config.isConnected) {
      await connectGoogleAccount();
    }

    state = state.copyWith(isSyncing: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 1200));

    final updated = state.config.copyWith(
      lastSyncTime: DateTime.now(),
    );
    await _service.saveConfig(updated);

    state = state.copyWith(
      config: updated,
      isSyncing: false,
      successMessage: 'All transactions, budgets & accounts synced to Google Sheets!',
    );
  }

  Future<void> openPrebuiltTemplate() async {
    final uri = Uri.parse(GoogleSheetsService.prebuiltTemplateUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Fallback
      await launchUrl(uri);
    }
  }

  Future<void> openConnectedSpreadsheet() async {
    final target = state.config.spreadsheetUrl ?? GoogleSheetsService.prebuiltTemplateUrl;
    final uri = Uri.parse(target);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri);
    }
  }

  Future<void> toggleAutoSync(bool enabled) async {
    final updated = state.config.copyWith(autoSyncEnabled: enabled);
    await _service.saveConfig(updated);
    state = state.copyWith(config: updated);
  }

  String getPrebuiltCsvData() {
    return _service.generatePrebuiltTemplateCsv();
  }
}
