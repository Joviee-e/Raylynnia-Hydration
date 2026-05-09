import '../repositories/i_hydration_log_repository.dart';

/// Use case: Get weekly hydration progress.
/// Retrieves aggregated data for the past week.
class GetWeeklyProgressUseCase {
  const GetWeeklyProgressUseCase(this.hydrationLogRepository);

  final IHydrationLogRepository hydrationLogRepository;

  /// Execute the use case.
  /// Returns weekly summary starting from the specified date.
  Future<Map<DateTime, int>> execute(DateTime startDate) async {
    return hydrationLogRepository.getWeeklyProgress(startDate);
  }
}
