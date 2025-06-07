import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/userModel.dart';

class LocalStorageService {
  // Singleton instance
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // Keys for storage
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  // SharedPreferences instance
  late SharedPreferences _prefs;

  // Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save authentication token
  Future<void> saveAuthToken(String token) async {
    try {
      await _prefs.setString(_authTokenKey, token);
    } catch (e) {
      print('Error saving token: $e');
      throw Exception('Failed to save token');
    }
  }

  // Get authentication token
  Future<String?> getAuthToken() async {
    try {
      return _prefs.getString(_authTokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Remove authentication token (logout)
  Future<void> removeAuthToken() async {
    try {
      await _prefs.remove(_authTokenKey);
    } catch (e) {
      print('Error removing token: $e');
      throw Exception('Failed to remove token');
    }
  }

  // Save user data
  Future<void> saveUserData(User user) async {
    try {
      await _prefs.setString(_userDataKey, json.encode(user.toJson()));
    } catch (e) {
      print('Error saving user data: $e');
      throw Exception('Failed to save user data');
    }
  }

  // Get user data
  Future<User?> getUserData() async {
    try {
      final userData = _prefs.getString(_userDataKey);
      if (userData != null) {
        return User.fromJson(json.decode(userData));
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Remove user data (logout)
  Future<void> removeUserData() async {
    try {
      await _prefs.remove(_userDataKey);
    } catch (e) {
      print('Error removing user data: $e');
      throw Exception('Failed to remove user data');
    }
  }

  // Clear all stored data (full logout)
  Future<void> clearAll() async {
    try {
      await _prefs.clear();
    } catch (e) {
      print('Error clearing storage: $e');
      throw Exception('Failed to clear storage');
    }
  }
}