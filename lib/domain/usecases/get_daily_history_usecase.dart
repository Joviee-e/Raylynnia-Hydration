import '../entities/daily_hydration_summary.dart';
import '../repositories/i_hydration_log_repository.dart';

/// Use case: Get daily hydration history.
/// Retrieves all log entries for a specific date.
class GetDailyHistoryUseCase {
  const GetDailyHistoryUseCase(this.hydrationLogRepository);

  final IHydrationLogRepository hydrationLogRepository;

  /// Execute the use case.
  /// Returns logs for the specified date.
  Future<DailyHydrationSummary?> execute(DateTime date) async {
    return hydrationLogRepository.getDailyHistory(date);
  }
}
