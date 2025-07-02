import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

enum AuthenticationLevel {
  low, // Basic app access
  medium, // Wallet operations
  high, // Critical transactions
}

class BiometricService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _authLevelKey = 'auth_level_settings';
  static const String _lastAuthKey = 'last_biometric_auth';
  static const String _failedAttemptsKey = 'failed_biometric_attempts';

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Check if biometric authentication is available on device
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.isDeviceSupported();
      final isEnrolled = await _localAuth.canCheckBiometrics;
      return isAvailable && isEnrolled;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types on device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics;
    } catch (e) {
      return [];
    }
  }

  /// Authenticate user with biometrics
  Future<bool> authenticateWithBiometrics({
    required String reason,
    AuthenticationLevel level = AuthenticationLevel.medium,
    bool allowFallback = true,
  }) async {
    try {
      // Check if biometric is enabled for this level
      final isEnabled = await _isBiometricEnabledForLevel(level);
      if (!isEnabled) {
        return false;
      }

      // Check failed attempts
      final failedAttempts = await _getFailedAttempts();
      if (failedAttempts >= 3) {
        throw Exception('Too many failed attempts. Please try again later.');
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: !allowFallback,
          stickyAuth: true,
          sensitiveTransaction: level == AuthenticationLevel.high,
        ),
      );

      if (isAuthenticated) {
        await _recordSuccessfulAuth();
        await _resetFailedAttempts();
      } else {
        await _incrementFailedAttempts();
      }

      return isAuthenticated;
    } catch (e) {
      await _incrementFailedAttempts();
      throw Exception('Biometric authentication failed: ${e.toString()}');
    }
  }

  /// Enable biometric authentication for specific level
  Future<void> enableBiometricForLevel(AuthenticationLevel level) async {
    try {
      final settings = await _getAuthLevelSettings();
      settings[level.name] = true;
      await _secureStorage.write(
        key: _authLevelKey,
        value: json.encode(settings),
      );
    } catch (e) {
      throw Exception('Failed to enable biometric: ${e.toString()}');
    }
  }

  /// Disable biometric authentication for specific level
  Future<void> disableBiometricForLevel(AuthenticationLevel level) async {
    try {
      final settings = await _getAuthLevelSettings();
      settings[level.name] = false;
      await _secureStorage.write(
        key: _authLevelKey,
        value: json.encode(settings),
      );
    } catch (e) {
      throw Exception('Failed to disable biometric: ${e.toString()}');
    }
  }

  /// Check if biometric is enabled for specific level
  Future<bool> _isBiometricEnabledForLevel(AuthenticationLevel level) async {
    try {
      final settings = await _getAuthLevelSettings();
      return settings[level.name] ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get authentication level settings
  Future<Map<String, bool>> _getAuthLevelSettings() async {
    try {
      final settingsJson = await _secureStorage.read(key: _authLevelKey);
      if (settingsJson != null) {
        final settings = Map<String, dynamic>.from(json.decode(settingsJson));
        return settings.map((key, value) => MapEntry(key, value as bool));
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Record successful authentication
  Future<void> _recordSuccessfulAuth() async {
    try {
      await _secureStorage.write(
        key: _lastAuthKey,
        value: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // Non-critical error
    }
  }

  /// Get failed attempts count
  Future<int> _getFailedAttempts() async {
    try {
      final attemptsStr = await _secureStorage.read(key: _failedAttemptsKey);
      return int.tryParse(attemptsStr ?? '0') ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Increment failed attempts
  Future<void> _incrementFailedAttempts() async {
    try {
      final currentAttempts = await _getFailedAttempts();
      await _secureStorage.write(
        key: _failedAttemptsKey,
        value: (currentAttempts + 1).toString(),
      );
    } catch (e) {
      // Non-critical error
    }
  }

  /// Reset failed attempts
  Future<void> _resetFailedAttempts() async {
    try {
      await _secureStorage.delete(key: _failedAttemptsKey);
    } catch (e) {
      // Non-critical error
    }
  }

  /// Get last authentication time
  Future<DateTime?> getLastAuthenticationTime() async {
    try {
      final lastAuthStr = await _secureStorage.read(key: _lastAuthKey);
      if (lastAuthStr != null) {
        return DateTime.parse(lastAuthStr);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if authentication is still valid (within time limit)
  Future<bool> isAuthenticationValid({
    Duration validityDuration = const Duration(minutes: 15),
  }) async {
    try {
      final lastAuth = await getLastAuthenticationTime();
      if (lastAuth == null) return false;

      final now = DateTime.now();
      return now.difference(lastAuth) < validityDuration;
    } catch (e) {
      return false;
    }
  }

  /// Generate secure authentication token
  Future<String> generateAuthToken() async {
    try {
      final random = Random.secure();
      final bytes = List<int>.generate(32, (i) => random.nextInt(256));
      final token = base64Url.encode(bytes);

      // Store token with timestamp
      final tokenData = {
        'token': token,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _secureStorage.write(
        key: 'auth_token',
        value: json.encode(tokenData),
      );

      return token;
    } catch (e) {
      throw Exception('Failed to generate auth token: ${e.toString()}');
    }
  }

  /// Validate authentication token
  Future<bool> validateAuthToken(String token) async {
    try {
      final tokenDataStr = await _secureStorage.read(key: 'auth_token');
      if (tokenDataStr == null) return false;

      final tokenData = Map<String, dynamic>.from(json.decode(tokenDataStr));
      final storedToken = tokenData['token'] as String?;
      final timestampStr = tokenData['timestamp'] as String?;

      if (storedToken != token || timestampStr == null) return false;

      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();

      // Token valid for 1 hour
      return now.difference(timestamp) < const Duration(hours: 1);
    } catch (e) {
      return false;
    }
  }

  /// Clear all biometric data
  Future<void> clearBiometricData() async {
    try {
      await _secureStorage.delete(key: _biometricEnabledKey);
      await _secureStorage.delete(key: _authLevelKey);
      await _secureStorage.delete(key: _lastAuthKey);
      await _secureStorage.delete(key: _failedAttemptsKey);
      await _secureStorage.delete(key: 'auth_token');
    } catch (e) {
      throw Exception('Failed to clear biometric data: ${e.toString()}');
    }
  }

  /// Get biometric status summary
  Future<Map<String, dynamic>> getBiometricStatus() async {
    try {
      final isAvailable = await isBiometricAvailable();
      final availableTypes = await getAvailableBiometrics();
      final settings = await _getAuthLevelSettings();
      final lastAuth = await getLastAuthenticationTime();
      final failedAttempts = await _getFailedAttempts();

      return {
        'isAvailable': isAvailable,
        'availableTypes': availableTypes.map((e) => e.name).toList(),
        'enabledLevels': settings,
        'lastAuthentication': lastAuth?.toIso8601String(),
        'failedAttempts': failedAttempts,
        'isLocked': failedAttempts >= 3,
      };
    } catch (e) {
      return {
        'isAvailable': false,
        'availableTypes': [],
        'enabledLevels': {},
        'lastAuthentication': null,
        'failedAttempts': 0,
        'isLocked': false,
      };
    }
  }
}
