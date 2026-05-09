import '../../domain/entities/hydration_log.dart';
import '../../domain/entities/daily_hydration_summary.dart';
import '../../domain/repositories/i_hydration_log_repository.dart';
import '../datasources/interfaces/i_hydration_log_datasource.dart';
import '../mappers/hydration_log_mapper.dart';
import '../models/hydration_log_model.dart';

class HydrationLogRepositoryImpl implements IHydrationLogRepository {
  HydrationLogRepositoryImpl(this._localDataSource);

  final IHydrationLogLocalDataSource _localDataSource;

  @override
  Future<void> addHydrationLog(HydrationLog hydrationLog) async {
    final HydrationLogModel model = HydrationLogMapper.toModel(hydrationLog);
    await _localDataSource.addHydrationLog(model.toJson());
  }

  @override
  Future<List<HydrationLog>> getHydrationLogs() async {
    final List<Map<String, dynamic>> jsonList =
        await _localDataSource.getHydrationLogs();

    return jsonList
        .map(HydrationLogModel.fromJson)
        .map(HydrationLogMapper.toEntity)
        .toList(growable: false);
  }

  @override
  Future<void> appendEntry(HydrationLog log) async {
    return addHydrationLog(log);
  }

  @override
  Future<DailyHydrationSummary?> getDailyHistory(DateTime date) async {
    final List<HydrationLog> logs = await getHydrationLogs();
    
    final dailyLogs = logs.where((log) {
      final logDate = log.timestamp;
      return logDate.year == date.year &&
          logDate.month == date.month &&
          logDate.day == date.day;
    }).toList();

    if (dailyLogs.isEmpty) {
      return null;
    }

    final totalMl = dailyLogs.fold<int>(0, (sum, log) => sum + log.volumeMl);
    
    return DailyHydrationSummary(
      date: date,
      totalVolumeMl: totalMl,
      logs: dailyLogs,
    );
  }

  @override
  Future<Map<DateTime, int>> getWeeklyProgress(DateTime startDate) async {
    final List<HydrationLog> logs = await getHydrationLogs();
    final progress = <DateTime, int>{};

    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      final dailyLogs = logs.where((log) {
        final logDate = log.timestamp;
        return logDate.year == date.year &&
            logDate.month == date.month &&
            logDate.day == date.day;
      }).toList();

      final totalMl = dailyLogs.fold<int>(0, (sum, log) => sum + log.volumeMl);
      progress[date] = totalMl;
    }

    return progress;
  }
}

