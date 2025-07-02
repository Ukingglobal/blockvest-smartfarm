import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeKey = 'app_theme_mode';
  static const String _languageKey = 'app_language';
  static const String _countryKey = 'app_country';
  static const String _notificationsKey = 'notification_settings';
  static const String _additionalSettingsKey = 'additional_settings';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late SharedPreferences _prefs;

  // Default settings
  static const String _defaultTheme = 'system';
  static const String _defaultLanguage = 'en';
  static const String _defaultCountry = '';
  static const Map<String, bool> _defaultNotifications = {
    'push_notifications': true,
    'email_notifications': true,
    'investment_updates': true,
    'price_alerts': true,
    'security_alerts': true,
    'marketing_notifications': false,
    'transaction_notifications': true,
    'kyc_updates': true,
  };

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme Settings
  Future<String> getThemeMode() async {
    return _prefs.getString(_themeKey) ?? _defaultTheme;
  }

  Future<void> setThemeMode(String themeMode) async {
    await _prefs.setString(_themeKey, themeMode);
  }

  // Language Settings
  Future<Locale> getLocale() async {
    final languageCode = _prefs.getString(_languageKey) ?? _defaultLanguage;
    final countryCode = _prefs.getString(_countryKey) ?? _defaultCountry;
    return Locale(languageCode, countryCode);
  }

  Future<void> setLocale(String languageCode, [String countryCode = '']) async {
    await _prefs.setString(_languageKey, languageCode);
    await _prefs.setString(_countryKey, countryCode);
  }

  // Notification Settings
  Future<Map<String, bool>> getNotificationSettings() async {
    final notificationsJson = _prefs.getString(_notificationsKey);
    if (notificationsJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(notificationsJson);
        return decoded.map((key, value) => MapEntry(key, value as bool));
      } catch (e) {
        // If there's an error decoding, return defaults
        return Map.from(_defaultNotifications);
      }
    }
    return Map.from(_defaultNotifications);
  }

  Future<void> setNotificationSettings(Map<String, bool> settings) async {
    final notificationsJson = json.encode(settings);
    await _prefs.setString(_notificationsKey, notificationsJson);
  }

  Future<void> updateNotificationSetting(String key, bool value) async {
    final currentSettings = await getNotificationSettings();
    currentSettings[key] = value;
    await setNotificationSettings(currentSettings);
  }

  // Additional Settings
  Future<Map<String, dynamic>> getAdditionalSettings() async {
    final settingsJson = _prefs.getString(_additionalSettingsKey);
    if (settingsJson != null) {
      try {
        return json.decode(settingsJson) as Map<String, dynamic>;
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  Future<void> setAdditionalSettings(Map<String, dynamic> settings) async {
    final settingsJson = json.encode(settings);
    await _prefs.setString(_additionalSettingsKey, settingsJson);
  }

  // Get all settings
  Future<Map<String, dynamic>> getAllSettings() async {
    final themeMode = await getThemeMode();
    final locale = await getLocale();
    final notifications = await getNotificationSettings();
    final additional = await getAdditionalSettings();

    return {
      'themeMode': themeMode,
      'locale': {
        'languageCode': locale.languageCode,
        'countryCode': locale.countryCode,
      },
      'notificationSettings': notifications,
      'additionalSettings': additional,
    };
  }

  // Import/Export functionality
  Future<String> exportSettings() async {
    final allSettings = await getAllSettings();
    return json.encode(allSettings);
  }

  Future<void> importSettings(String settingsJson) async {
    try {
      final Map<String, dynamic> settings = json.decode(settingsJson);
      
      // Import theme
      if (settings.containsKey('themeMode')) {
        await setThemeMode(settings['themeMode']);
      }
      
      // Import locale
      if (settings.containsKey('locale')) {
        final locale = settings['locale'];
        await setLocale(
          locale['languageCode'] ?? _defaultLanguage,
          locale['countryCode'] ?? _defaultCountry,
        );
      }
      
      // Import notifications
      if (settings.containsKey('notificationSettings')) {
        final notifications = Map<String, bool>.from(settings['notificationSettings']);
        await setNotificationSettings(notifications);
      }
      
      // Import additional settings
      if (settings.containsKey('additionalSettings')) {
        await setAdditionalSettings(settings['additionalSettings']);
      }
    } catch (e) {
      throw Exception('Failed to import settings: ${e.toString()}');
    }
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    await setThemeMode(_defaultTheme);
    await setLocale(_defaultLanguage, _defaultCountry);
    await setNotificationSettings(Map.from(_defaultNotifications));
    await setAdditionalSettings({});
  }

  // Clear all settings
  Future<void> clearAllSettings() async {
    await _prefs.remove(_themeKey);
    await _prefs.remove(_languageKey);
    await _prefs.remove(_countryKey);
    await _prefs.remove(_notificationsKey);
    await _prefs.remove(_additionalSettingsKey);
  }
}
