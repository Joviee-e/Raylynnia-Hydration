import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../interfaces/i_user_profile_datasource.dart';

class UserProfileLocalDataSource implements IUserProfileLocalDataSource {
  UserProfileLocalDataSource(this._sharedPreferences);

  static const String _profileKey = 'user_profile';
  static const String _preferencesKey = 'user_preferences';
  static const String _onboardingKey = 'onboarding_complete';

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

  @override
  Future<void> savePreferences(Map<String, dynamic> json) async {
    await _sharedPreferences.setString(_preferencesKey, jsonEncode(json));
  }

  @override
  Future<void> markOnboardingComplete() async {
    await _sharedPreferences.setBool(_onboardingKey, true);
  }

  @override
  Future<Map<String, dynamic>?> getPreferences() async {
    final String? rawJson = _sharedPreferences.getString(_preferencesKey);
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(
      jsonDecode(rawJson) as Map<dynamic, dynamic>,
    );
  }
}

