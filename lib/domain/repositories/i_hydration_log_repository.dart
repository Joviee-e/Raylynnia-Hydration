import '../entities/hydration_log.dart';
import '../entities/daily_hydration_summary.dart';

abstract class IHydrationLogRepository {
  Future<void> addHydrationLog(HydrationLog hydrationLog);
  Future<List<HydrationLog>> getHydrationLogs();
  Future<void> appendEntry(HydrationLog log);
  Future<DailyHydrationSummary?> getDailyHistory(DateTime date);
  Future<Map<DateTime, int>> getWeeklyProgress(DateTime startDate);
}

