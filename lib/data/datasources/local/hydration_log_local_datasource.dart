import 'package:hive/hive.dart';
import '../interfaces/i_hydration_log_datasource.dart';

class HydrationLogLocalDataSource implements IHydrationLogLocalDataSource {
  HydrationLogLocalDataSource();

  static const String _boxName = 'hydration_logs';

  @override
  Future<void> addHydrationLog(Map<String, dynamic> json) async {
    final box = Hive.box(_boxName);
    final Map<String, dynamic> safeMap = Map<String, dynamic>.from(json);
    await box.put(json['id'], safeMap);
  }

  @override
  Future<List<Map<String, dynamic>>> getHydrationLogs() async {
    final box = Hive.box(_boxName);
    final List<Map<String, dynamic>> list = [];
    for (final dynamic item in box.values) {
      if (item is Map) {
        list.add(Map<String, dynamic>.from(item));
      }
    }
    return list;
  }
}
