import '../../domain/entities/user_schedule_preferences.dart';
import '../../domain/repositories/i_scheduling_repository.dart';
import '../datasources/local/schedule_local_datasource.dart';
import '../mappers/schedule_preferences_mapper.dart';

class SchedulingRepositoryImpl implements ISchedulingRepository {
  SchedulingRepositoryImpl(this._localDataSource);

  final ScheduleLocalDataSource _localDataSource;

  @override
  Future<UserSchedulePreferences?> getSchedulePreferences() async {
    final model = await _localDataSource.getSchedulePreferences();
    if (model == null) {
      return null;
    }

    return SchedulePreferencesMapper.toEntity(model);
  }

  @override
  Future<void> saveSchedulePreferences(UserSchedulePreferences preferences) {
    final model = SchedulePreferencesMapper.toModel(preferences);
    return _localDataSource.saveSchedulePreferences(model);
  }
}
