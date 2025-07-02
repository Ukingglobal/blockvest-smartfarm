import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _faceDataKey = 'face_data';
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.isDeviceSupported();
      if (!isAvailable) return false;

      final List<BiometricType> availableBiometrics = 
          await _localAuth.getAvailableBiometrics();
      
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Check if face ID/recognition is available
  Future<bool> isFaceAuthAvailable() async {
    try {
      final List<BiometricType> availableBiometrics = 
          await _localAuth.getAvailableBiometrics();
      
      return availableBiometrics.contains(BiometricType.face) ||
             availableBiometrics.contains(BiometricType.strong);
    } catch (e) {
      return false;
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticateWithBiometrics({
    String reason = 'Please authenticate to access your account',
  }) async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      // Handle specific platform exceptions
      switch (e.code) {
        case 'NotAvailable':
          throw BiometricException('Biometric authentication not available');
        case 'NotEnrolled':
          throw BiometricException('No biometrics enrolled on device');
        case 'LockedOut':
          throw BiometricException('Too many failed attempts. Try again later');
        case 'PermanentlyLockedOut':
          throw BiometricException('Biometric authentication permanently disabled');
        default:
          throw BiometricException('Authentication failed: ${e.message}');
      }
    } catch (e) {
      throw BiometricException('Authentication failed: $e');
    }
  }

  /// Enable biometric authentication for the user
  Future<bool> enableBiometricAuth() async {
    try {
      final bool authenticated = await authenticateWithBiometrics(
        reason: 'Enable biometric authentication for secure access',
      );

      if (authenticated) {
        await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometricAuth() async {
    await _secureStorage.delete(key: _biometricEnabledKey);
  }

  /// Check if biometric authentication is enabled for the user
  Future<bool> isBiometricEnabled() async {
    final String? enabled = await _secureStorage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }

  /// Store face data for KYC verification
  Future<void> storeFaceData(String faceData) async {
    await _secureStorage.write(key: _faceDataKey, value: faceData);
  }

  /// Get stored face data
  Future<String?> getFaceData() async {
    return await _secureStorage.read(key: _faceDataKey);
  }

  /// Clear stored face data
  Future<void> clearFaceData() async {
    await _secureStorage.delete(key: _faceDataKey);
  }

  /// Verify face for KYC process
  Future<bool> verifyFaceForKYC(String capturedFaceData) async {
    try {
      final String? storedFaceData = await getFaceData();
      if (storedFaceData == null) return false;

      // In a real implementation, this would use face comparison algorithms
      // For now, we'll simulate the verification process
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock verification - in production, use proper face matching
      return capturedFaceData.isNotEmpty && storedFaceData.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get biometric authentication status message
  String getBiometricStatusMessage(List<BiometricType> biometrics) {
    if (biometrics.isEmpty) {
      return 'No biometric authentication available';
    }

    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID available';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint authentication available';
    } else if (biometrics.contains(BiometricType.strong)) {
      return 'Strong biometric authentication available';
    } else if (biometrics.contains(BiometricType.weak)) {
      return 'Weak biometric authentication available';
    }

    return 'Biometric authentication available';
  }
}

/// Custom exception for biometric authentication errors
class BiometricException implements Exception {
  final String message;
  
  BiometricException(this.message);
  
  @override
  String toString() => 'BiometricException: $message';
}
