import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _user;
  UserProfile? get user => _user;

  String? _uid; // User ID
  String? get uid => _uid;

  static const _prefsKey = 'user_profile';
  final ApiService _api;
  ApiService get api => _api;

  UserProvider({ApiService? api}) : _api = api ?? ApiService();

  /// Set Firebase UID and optionally fetch remote profile.
  Future<void> setUid(String uid) async {
    _uid = uid;
    // Try to fetch profile from backend.
    try {
      final resp = await _api.getProfile(uid);
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        _user = UserProfile.fromJson(data);
        await _saveLocal();
        notifyListeners();
        return;
      }
    } catch (_) {}
    // If not found, keep local (or empty) profile.
    notifyListeners();
  }

  /// Load profile from local storage. Returns true if a profile existed.
  Future<bool> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> map = json.decode(jsonString);
        _user = UserProfile.fromJson(map);
        notifyListeners();
        return true;
      } catch (_) {}
    }
    // No local profile; keep null.
    _user = null;
    return false;
  }

  /// Save to local storage.
  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null) {
      await prefs.setString(_prefsKey, json.encode(_user!.toJson()));
    }
  }

  /// Persist profile to backend and local storage.
  Future<void> upsertProfile() async {
    if (_user == null || _uid == null) return;
    try {
      await _api.upsertProfile(_user!.toJson()..['user_id'] = _uid);
    } catch (_) {}
    await _saveLocal();
    notifyListeners();
  }

  /// Update basic info (age & gender) and sync.
  void updateBasicInfo(int age, String gender) {
    _user = UserProfile(age: age, gender: gender);
    upsertProfile();
  }

  /// Update additional health metrics.
  void updateMetrics({double? height, double? weight}) {
    _user ??= UserProfile();
    _user = UserProfile(
      age: _user?.age,
      gender: _user?.gender,
      height: height ?? _user?.height,
      weight: weight ?? _user?.weight,
    );
    upsertProfile();
  }

  /// Clear profile (sign‑out).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    _user = null;
  }
}
