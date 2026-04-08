import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../interfaces/i_user_profile_datasource.dart';

class UserProfileLocalDataSource implements IUserProfileLocalDataSource {
  UserProfileLocalDataSource(this._sharedPreferences);

  static const String _profileKey = 'user_profile';

  final SharedPreferences _sharedPreferences;

  @override
  Future<Map<String, dynamic>?> getUserProfile() async {
    final String? rawJson = _sharedPreferences.getString(_profileKey);
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(
      jsonDecode(rawJson) as Map<dynamic, dynamic>,
    );
  }

  @override
  Future<void> saveUserProfile(Map<String, dynamic> json) async {
    await _sharedPreferences.setString(_profileKey, jsonEncode(json));
  }
}
