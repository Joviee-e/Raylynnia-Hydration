import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/hydration_log.dart';
import '../../../../domain/usecases/get_daily_history_usecase.dart';
import '../../../../domain/usecases/get_weekly_progress_usecase.dart';

class HistoryState {
  const HistoryState({
    this.selectedDate,
    this.dailyLogs = const [],
    this.weeklyData = const {},
    this.isLoading = false,
    this.error,
  });

  final DateTime? selectedDate;
  final List<HydrationLog> dailyLogs;
  final Map<DateTime, int> weeklyData;
  final bool isLoading;
  final String? error;

  HistoryState copyWith({
    DateTime? selectedDate,
    List<HydrationLog>? dailyLogs,
    Map<DateTime, int>? weeklyData,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return HistoryState(
      selectedDate: selectedDate ?? this.selectedDate,
      dailyLogs: dailyLogs ?? this.dailyLogs,
      weeklyData: weeklyData ?? this.weeklyData,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  int getDailyTotal() {
    return dailyLogs.fold(0, (sum, log) => sum + log.volumeMl);
  }
}

class HistoryViewModel extends StateNotifier<HistoryState> {
  HistoryViewModel({
    required this.getDailyHistoryUseCase,
    required this.getWeeklyProgressUseCase,
  }) : super(HistoryState(selectedDate: DateTime.now())) {
    _initialize();
  }

  final GetDailyHistoryUseCase getDailyHistoryUseCase;
  final GetWeeklyProgressUseCase getWeeklyProgressUseCase;

  Future<void> _initialize() async {
    await loadWeeklyData();
    await loadDailyData(DateTime.now());
  }

  Future<void> loadDailyData(DateTime date) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final summary = await getDailyHistoryUseCase.execute(date);
      state = state.copyWith(
        selectedDate: date,
        dailyLogs: summary?.logs ?? [],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load daily history: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> loadWeeklyData() async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: now.weekday - 1));
      final weeklyData = await getWeeklyProgressUseCase.execute(startDate);
      state = state.copyWith(weeklyData: weeklyData);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load weekly data: ${e.toString()}');
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
