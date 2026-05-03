import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_schedule_preferences_model.dart';

class ScheduleLocalDataSource {
  ScheduleLocalDataSource(this._sharedPreferences);

  static const String _schedulePreferencesKey = 'schedule_preferences';

  final SharedPreferences _sharedPreferences;

  Future<UserSchedulePreferencesModel?> getSchedulePreferences() async {
    final String? raw = _sharedPreferences.getString(_schedulePreferencesKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final Map<String, dynamic> json =
        Map<String, dynamic>.from(jsonDecode(raw) as Map<dynamic, dynamic>);
    return UserSchedulePreferencesModel.fromJson(json);
  }

  Future<void> saveSchedulePreferences(
    UserSchedulePreferencesModel model,
  ) async {
    await _sharedPreferences.setString(
      _schedulePreferencesKey,
      jsonEncode(model.toJson()),
    );
  }
}
