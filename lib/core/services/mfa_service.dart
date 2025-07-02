import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'biometric_service.dart';

enum MFAMethod {
  sms,
  email,
  authenticatorApp,
  biometric,
  backupCodes,
}

enum MFARequirement {
  disabled,
  optional,
  required,
}

class MFAService {
  static const String _mfaEnabledKey = 'mfa_enabled';
  static const String _mfaMethodsKey = 'mfa_methods';
  static const String _backupCodesKey = 'mfa_backup_codes';
  static const String _mfaSettingsKey = 'mfa_settings';
  static const String _pendingVerificationKey = 'pending_mfa_verification';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final BiometricService _biometricService = BiometricService();

  /// Check if MFA is enabled
  Future<bool> isMFAEnabled() async {
    try {
      final enabledStr = await _secureStorage.read(key: _mfaEnabledKey);
      return enabledStr == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Get enabled MFA methods
  Future<List<MFAMethod>> getEnabledMethods() async {
    try {
      final methodsStr = await _secureStorage.read(key: _mfaMethodsKey);
      if (methodsStr != null) {
        final methodsList = List<String>.from(json.decode(methodsStr));
        return methodsList
            .map((method) => MFAMethod.values.firstWhere(
                  (m) => m.name == method,
                  orElse: () => MFAMethod.sms,
                ))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Enable MFA method
  Future<void> enableMFAMethod(MFAMethod method) async {
    try {
      final currentMethods = await getEnabledMethods();
      if (!currentMethods.contains(method)) {
        currentMethods.add(method);
        await _saveMFAMethods(currentMethods);
        await _secureStorage.write(key: _mfaEnabledKey, value: 'true');
      }
    } catch (e) {
      throw Exception('Failed to enable MFA method: ${e.toString()}');
    }
  }

  /// Disable MFA method
  Future<void> disableMFAMethod(MFAMethod method) async {
    try {
      final currentMethods = await getEnabledMethods();
      currentMethods.remove(method);
      await _saveMFAMethods(currentMethods);
      
      // If no methods left, disable MFA entirely
      if (currentMethods.isEmpty) {
        await _secureStorage.write(key: _mfaEnabledKey, value: 'false');
      }
    } catch (e) {
      throw Exception('Failed to disable MFA method: ${e.toString()}');
    }
  }

  /// Save MFA methods to storage
  Future<void> _saveMFAMethods(List<MFAMethod> methods) async {
    try {
      final methodNames = methods.map((m) => m.name).toList();
      await _secureStorage.write(
        key: _mfaMethodsKey,
        value: json.encode(methodNames),
      );
    } catch (e) {
      throw Exception('Failed to save MFA methods: ${e.toString()}');
    }
  }

  /// Generate SMS/Email verification code
  Future<String> generateVerificationCode({
    required MFAMethod method,
    required String destination, // phone number or email
  }) async {
    try {
      // Generate 6-digit code
      final random = Random.secure();
      final code = (100000 + random.nextInt(900000)).toString();
      
      // Store pending verification
      final verificationData = {
        'code': code,
        'method': method.name,
        'destination': destination,
        'expiresAt': DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
        'attempts': 0,
      };
      
      await _secureStorage.write(
        key: _pendingVerificationKey,
        value: json.encode(verificationData),
      );
      
      // In production, send SMS/Email here
      await _sendVerificationCode(method, destination, code);
      
      return code; // Return for testing purposes
    } catch (e) {
      throw Exception('Failed to generate verification code: ${e.toString()}');
    }
  }

  /// Send verification code (mock implementation)
  Future<void> _sendVerificationCode(
    MFAMethod method,
    String destination,
    String code,
  ) async {
    try {
      // Simulate sending delay
      await Future.delayed(const Duration(seconds: 1));
      
      switch (method) {
        case MFAMethod.sms:
          // In production: integrate with SMS service (Twilio, AWS SNS, etc.)
          print('SMS sent to $destination: Your BlockVest verification code is $code');
          break;
        case MFAMethod.email:
          // In production: integrate with email service (SendGrid, AWS SES, etc.)
          print('Email sent to $destination: Your BlockVest verification code is $code');
          break;
        default:
          break;
      }
    } catch (e) {
      throw Exception('Failed to send verification code: ${e.toString()}');
    }
  }

  /// Verify MFA code
  Future<bool> verifyCode(String inputCode) async {
    try {
      final verificationStr = await _secureStorage.read(key: _pendingVerificationKey);
      if (verificationStr == null) {
        throw Exception('No pending verification found');
      }
      
      final verificationData = Map<String, dynamic>.from(json.decode(verificationStr));
      final storedCode = verificationData['code'] as String;
      final expiresAtStr = verificationData['expiresAt'] as String;
      final attempts = verificationData['attempts'] as int;
      
      // Check if expired
      final expiresAt = DateTime.parse(expiresAtStr);
      if (DateTime.now().isAfter(expiresAt)) {
        await _secureStorage.delete(key: _pendingVerificationKey);
        throw Exception('Verification code expired');
      }
      
      // Check attempts limit
      if (attempts >= 3) {
        await _secureStorage.delete(key: _pendingVerificationKey);
        throw Exception('Too many failed attempts');
      }
      
      // Verify code
      if (inputCode == storedCode) {
        await _secureStorage.delete(key: _pendingVerificationKey);
        return true;
      } else {
        // Increment attempts
        verificationData['attempts'] = attempts + 1;
        await _secureStorage.write(
          key: _pendingVerificationKey,
          value: json.encode(verificationData),
        );
        return false;
      }
    } catch (e) {
      throw Exception('Code verification failed: ${e.toString()}');
    }
  }

  /// Perform MFA challenge
  Future<bool> performMFAChallenge({
    required String operation,
    MFAMethod? preferredMethod,
  }) async {
    try {
      final enabledMethods = await getEnabledMethods();
      if (enabledMethods.isEmpty) {
        return true; // No MFA configured
      }
      
      // Determine which method to use
      MFAMethod methodToUse;
      if (preferredMethod != null && enabledMethods.contains(preferredMethod)) {
        methodToUse = preferredMethod;
      } else {
        // Use first available method
        methodToUse = enabledMethods.first;
      }
      
      switch (methodToUse) {
        case MFAMethod.biometric:
          return await _biometricService.authenticateWithBiometrics(
            reason: 'Verify your identity for $operation',
            level: AuthenticationLevel.high,
          );
        case MFAMethod.sms:
        case MFAMethod.email:
          // For SMS/Email, the verification is handled separately
          // This would typically trigger the code generation
          return false; // Indicates that additional verification is needed
        case MFAMethod.authenticatorApp:
          // For authenticator apps, this would validate TOTP codes
          return false; // Indicates that additional verification is needed
        case MFAMethod.backupCodes:
          return false; // Indicates that backup code input is needed
      }
    } catch (e) {
      throw Exception('MFA challenge failed: ${e.toString()}');
    }
  }

  /// Generate backup codes
  Future<List<String>> generateBackupCodes() async {
    try {
      final random = Random.secure();
      final backupCodes = <String>[];
      
      // Generate 10 backup codes
      for (int i = 0; i < 10; i++) {
        final code = List.generate(8, (index) => 
          '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'[random.nextInt(36)]
        ).join();
        backupCodes.add(code);
      }
      
      // Hash and store codes
      final hashedCodes = backupCodes.map((code) => 
        sha256.convert(utf8.encode(code)).toString()
      ).toList();
      
      await _secureStorage.write(
        key: _backupCodesKey,
        value: json.encode(hashedCodes),
      );
      
      return backupCodes;
    } catch (e) {
      throw Exception('Failed to generate backup codes: ${e.toString()}');
    }
  }

  /// Verify backup code
  Future<bool> verifyBackupCode(String inputCode) async {
    try {
      final codesStr = await _secureStorage.read(key: _backupCodesKey);
      if (codesStr == null) {
        return false;
      }
      
      final hashedCodes = List<String>.from(json.decode(codesStr));
      final inputHash = sha256.convert(utf8.encode(inputCode)).toString();
      
      if (hashedCodes.contains(inputHash)) {
        // Remove used code
        hashedCodes.remove(inputHash);
        await _secureStorage.write(
          key: _backupCodesKey,
          value: json.encode(hashedCodes),
        );
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get remaining backup codes count
  Future<int> getRemainingBackupCodesCount() async {
    try {
      final codesStr = await _secureStorage.read(key: _backupCodesKey);
      if (codesStr != null) {
        final codes = List<String>.from(json.decode(codesStr));
        return codes.length;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Configure MFA requirements for operations
  Future<void> configureMFARequirement({
    required String operation,
    required MFARequirement requirement,
  }) async {
    try {
      final settings = await _getMFASettings();
      settings[operation] = requirement.name;
      await _secureStorage.write(
        key: _mfaSettingsKey,
        value: json.encode(settings),
      );
    } catch (e) {
      throw Exception('Failed to configure MFA requirement: ${e.toString()}');
    }
  }

  /// Check if MFA is required for operation
  Future<bool> isMFARequiredForOperation(String operation) async {
    try {
      final settings = await _getMFASettings();
      final requirementStr = settings[operation];
      
      if (requirementStr != null) {
        final requirement = MFARequirement.values.firstWhere(
          (r) => r.name == requirementStr,
          orElse: () => MFARequirement.optional,
        );
        return requirement == MFARequirement.required;
      }
      
      // Default requirements for sensitive operations
      const sensitiveOperations = [
        'large_investment',
        'withdrawal',
        'wallet_transfer',
        'settings_change',
      ];
      
      return sensitiveOperations.contains(operation);
    } catch (e) {
      return false;
    }
  }

  /// Get MFA settings
  Future<Map<String, String>> _getMFASettings() async {
    try {
      final settingsStr = await _secureStorage.read(key: _mfaSettingsKey);
      if (settingsStr != null) {
        return Map<String, String>.from(json.decode(settingsStr));
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Get MFA status summary
  Future<Map<String, dynamic>> getMFAStatus() async {
    try {
      final isEnabled = await isMFAEnabled();
      final enabledMethods = await getEnabledMethods();
      final backupCodesCount = await getRemainingBackupCodesCount();
      final settings = await _getMFASettings();
      
      return {
        'isEnabled': isEnabled,
        'enabledMethods': enabledMethods.map((m) => m.name).toList(),
        'backupCodesCount': backupCodesCount,
        'operationSettings': settings,
        'recommendedMethods': _getRecommendedMethods(),
      };
    } catch (e) {
      return {
        'isEnabled': false,
        'enabledMethods': [],
        'backupCodesCount': 0,
        'operationSettings': {},
        'recommendedMethods': [],
      };
    }
  }

  /// Get recommended MFA methods
  List<String> _getRecommendedMethods() {
    return [
      'Enable biometric authentication for quick access',
      'Set up SMS verification as backup',
      'Generate backup codes for emergency access',
      'Consider authenticator app for enhanced security',
    ];
  }

  /// Clear all MFA data
  Future<void> clearMFAData() async {
    try {
      await _secureStorage.delete(key: _mfaEnabledKey);
      await _secureStorage.delete(key: _mfaMethodsKey);
      await _secureStorage.delete(key: _backupCodesKey);
      await _secureStorage.delete(key: _mfaSettingsKey);
      await _secureStorage.delete(key: _pendingVerificationKey);
    } catch (e) {
      throw Exception('Failed to clear MFA data: ${e.toString()}');
    }
  }
}
