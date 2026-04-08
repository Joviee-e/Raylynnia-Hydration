import 'package:hive/hive.dart';

import '../interfaces/i_hydration_log_datasource.dart';

class HydrationLogLocalDataSource implements IHydrationLogLocalDataSource {
  HydrationLogLocalDataSource(this._hydrationLogBox);

  final Box<Map<dynamic, dynamic>> _hydrationLogBox;

  @override
  Future<void> addHydrationLog(Map<String, dynamic> json) async {
    await _hydrationLogBox.add(Map<dynamic, dynamic>.from(json));
  }

  @override
  Future<List<Map<String, dynamic>>> getHydrationLogs() async {
    return _hydrationLogBox.values
        .map((Map<dynamic, dynamic> value) => Map<String, dynamic>.from(value))
        .toList(growable: false);
  }
}
