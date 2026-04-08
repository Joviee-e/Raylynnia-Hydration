import '../../domain/entities/hydration_log.dart';
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
}
