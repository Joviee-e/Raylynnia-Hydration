import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/entities/hydration_log.dart';
import '../../../../domain/entities/reminder_schedule.dart';
import '../../../../domain/usecases/get_user_profile_usecase.dart';
import '../../../../domain/usecases/log_hydration_intake_usecase.dart';
import '../../../../domain/usecases/get_daily_history_usecase.dart';
import '../../../../domain/usecases/compute_reminder_schedule_usecase.dart';

class HomeState {
  const HomeState({
    this.userProfile,
    this.todayLogs = const [],
    this.todaySchedule,
    this.isLoading = false,
    this.error,
  });

  final UserProfile? userProfile;
  final List<HydrationLog> todayLogs;
  final ReminderSchedule? todaySchedule;
  final bool isLoading;
  final String? error;

  HomeState copyWith({
    UserProfile? userProfile,
    List<HydrationLog>? todayLogs,
    ReminderSchedule? todaySchedule,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return HomeState(
      userProfile: userProfile ?? this.userProfile,
      todayLogs: todayLogs ?? this.todayLogs,
      todaySchedule: todaySchedule ?? this.todaySchedule,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  int getTotalIntakeMl() {
    return todayLogs.fold(0, (sum, log) => sum + log.volumeMl);
  }

  double getProgressPercentage() {
    if (userProfile == null) return 0.0;
    final progress = (getTotalIntakeMl() / userProfile!.dailyGoalMl * 100).clamp(0.0, 100.0).toDouble();
    return progress;
  }

  DateTime? getNextReminderTime() {
    if (todaySchedule == null || todaySchedule!.times.isEmpty) return null;
    final now = DateTime.now();
    try {
      return todaySchedule!.times.firstWhere((time) => time.isAfter(now));
    } catch (e) {
      return null;
    }
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel({
    required this.getUserProfileUseCase,
    required this.logHydrationIntakeUseCase,
    required this.getDailyHistoryUseCase,
    required this.computeReminderScheduleUseCase,
  }) : super(const HomeState()) {
    _initialize();
  }

  final GetUserProfileUseCase getUserProfileUseCase;
  final LogHydrationIntakeUseCase logHydrationIntakeUseCase;
  final GetDailyHistoryUseCase getDailyHistoryUseCase;
  final ComputeReminderScheduleUseCase computeReminderScheduleUseCase;

  Future<void> _initialize() async {
    await loadTodayData();
  }

  Future<void> loadTodayData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Load user profile
      final profile = await getUserProfileUseCase.execute();
      if (profile == null) {
        state = state.copyWith(error: 'No user profile found', isLoading: false);
        return;
      }
      state = state.copyWith(userProfile: profile);

      // Load today's logs
      final today = DateTime.now();
      final summary = await getDailyHistoryUseCase.execute(today);
      
      state = state.copyWith(
        todayLogs: summary?.logs ?? [],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load home data: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> logDrink(int volumeMl) async {
    try {
      await logHydrationIntakeUseCase.execute(
        timestamp: DateTime.now(),
        volumeMl: volumeMl,
      );
      // Reload today's data to reflect the new log
      await loadTodayData();
    } catch (e) {
      state = state.copyWith(error: 'Failed to log drink: ${e.toString()}');
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
