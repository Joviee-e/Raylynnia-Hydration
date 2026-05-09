import '../interfaces/i_hydration_log_datasource.dart';

class HydrationLogLocalDataSource implements IHydrationLogLocalDataSource {
  HydrationLogLocalDataSource();

  final List<Map<String, dynamic>> _logs = <Map<String, dynamic>>[];

  @override
  Future<void> addHydrationLog(Map<String, dynamic> json) async {
    _logs.add(Map<String, dynamic>.from(json));
  }

  @override
  Future<List<Map<String, dynamic>>> getHydrationLogs() async {
    return _logs
        .map((Map<String, dynamic> value) => Map<String, dynamic>.from(value))
        .toList(growable: false);
  }
}
