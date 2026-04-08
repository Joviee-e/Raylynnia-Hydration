import '../entities/hydration_log.dart';

abstract class IHydrationLogRepository {
  Future<void> addHydrationLog(HydrationLog hydrationLog);
  Future<List<HydrationLog>> getHydrationLogs();
}
