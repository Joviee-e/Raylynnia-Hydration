import '../../domain/entities/hydration_log.dart';
import '../models/hydration_log_model.dart';

abstract final class HydrationLogMapper {
  static HydrationLog toEntity(HydrationLogModel model) {
    return HydrationLog(
      id: model.id,
      timestamp: model.timestamp,
      volumeMl: model.volumeMl,
    );
  }

  static HydrationLogModel toModel(HydrationLog entity) {
    return HydrationLogModel(
      id: entity.id,
      timestamp: entity.timestamp,
      volumeMl: entity.volumeMl,
    );
  }
}
