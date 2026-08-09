import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/ai_insights/domain/entities/ai_insight_entity.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:expense_tracker/services/gemini_service.dart';

class AIInsightsState {
  final AIInsightEntity? insight;
  final bool isLoading;
  final String loadingMessage;
  final String? errorMessage;

  const AIInsightsState({
    this.insight,
    this.isLoading = false,
    this.loadingMessage = 'Analyzing expenses...',
    this.errorMessage,
  });

  AIInsightsState copyWith({
    AIInsightEntity? insight,
    bool? isLoading,
    String? loadingMessage,
    String? errorMessage,
  }) {
    return AIInsightsState(
      insight: insight ?? this.insight,
      isLoading: isLoading ?? this.isLoading,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      errorMessage: errorMessage,
    );
  }
}

class AIInsightsController extends StateNotifier<AIInsightsState> {
  final GeminiService _geminiService;

  static const List<String> _loadingPhrases = [
    'Analyzing expenses...',
    'Understanding spending habits...',
    'Finding savings opportunities...',
    'Building future predictions...',
    'Generating AI recommendations...',
  ];

  Timer? _phraseTimer;
  int _phraseIdx = 0;

  AIInsightsController(this._geminiService) : super(const AIInsightsState());

  void _startLoadingAnimation() {
    _phraseIdx = 0;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      loadingMessage: _loadingPhrases[0],
    );

    _phraseTimer?.cancel();
    _phraseTimer = Timer.periodic(const Duration(milliseconds: 1600), (timer) {
      _phraseIdx = (_phraseIdx + 1) % _loadingPhrases.length;
      if (mounted) {
        state = state.copyWith(loadingMessage: _loadingPhrases[_phraseIdx]);
      }
    });
  }

  void _stopLoadingAnimation() {
    _phraseTimer?.cancel();
  }

  Future<void> fetchInsights(dynamic expenses) async {
    _startLoadingAnimation();
    try {
      final insights = await _geminiService.generateFinancialInsights(expenses);
      _stopLoadingAnimation();
      if (mounted) {
        state = state.copyWith(insight: insights, isLoading: false);
      }
    } catch (e) {
      _stopLoadingAnimation();
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        );
      }
    }
  }

  @override
  void dispose() {
    _phraseTimer?.cancel();
    super.dispose();
  }
}

final aiInsightsControllerProvider =
    StateNotifierProvider<AIInsightsController, AIInsightsState>((ref) {
  final geminiService = ref.watch(geminiServiceProvider);
  final controller = AIInsightsController(geminiService);
  final expenseState = ref.watch(expenseControllerProvider);

  Future.microtask(() {
    controller.fetchInsights(expenseState.expenses);
  });

  return controller;
});
